import { sql } from "bun";
import { AddOptionsMethod, LogFunctionExecution, sqlProtection, } from "./logger/decorators";
import { CORS_HEADERS } from "../globals";
import MetodoPagoService from "./MetodoPagoService";
import TasaService from "./TasaService";

type Carrito = {
	cod_vent: number
	fecha_vent: string
	iva_vent: number
	base_imponible_vent: number
	total_vent: number
	online: boolean
	fk_clie: string
	fk_tien: 1
	items: unknown[] // TODO: Change from unknown to the object
}

type CarritoItemIdentifier = {
	cerveza: number
	presentacion: number
	lugar_tien?: number
}

type CarritoItem = {
	precio_unitario: number
	cantidad: number
	tienda: 1
} & CarritoItemIdentifier

// Cerveza, Presentacion
// Siempre de tienda 1, siempre del almacen principal

@AddOptionsMethod
class CarritoService {
	@sqlProtection
	@LogFunctionExecution
	async getCarritoObjectFromCliente(clienteID: string): Promise<Carrito | undefined> {
		const carrito: Carrito[] = await sql`
			SELECT *
			FROM Venta V
			WHERE
				fk_clie = ${clienteID}
				AND online = true
				AND cod_vent NOT IN (
						SELECT fk_vent
						FROM ESTA_VENT
						WHERE fk_vent = V.cod_vent AND fk_esta = 5)
			ORDER BY cod_vent DESC
			LIMIT 1`

		if (carrito.length === 0)
			return undefined

		return carrito[0]
	}

	@sqlProtection
	@LogFunctionExecution
	async getCarritoAndItems(clienteID: string) {
		const carrito = await this.getCarritoObjectFromCliente(clienteID);

		if (carrito === undefined)
			return new Response("", { ...CORS_HEADERS, status: 204 }); // If no carrito found, return No Content

		const detalles = await sql`
			SELECT *
			FROM Detalle_Venta
			WHERE fk_vent = ${carrito.cod_vent}`;

		return Response.json({ ...carrito, items: detalles });
	}

	@sqlProtection
	@LogFunctionExecution
	async createCarritoForCliente(clienteID: string) {
		const carrito = await this.getCarritoAndItems(clienteID);
		if (carrito.status === 200) return carrito;

		const newCarrito = (
			await sql`INSERT INTO Venta(fecha_vent, iva_vent, base_imponible_vent, total_vent, online, fk_clie, fk_tien)
			VALUES(CURRENT_DATE, 0, 0, 0, true, ${clienteID}, 1) RETURNING *`
		)[0];

		return Response.json(newCarrito, CORS_HEADERS);
	}

	@sqlProtection
	@LogFunctionExecution
	async clearCarritoForCliente(clienteID: string) {
		const carritoResponse = await this.getCarritoAndItems(clienteID);
		if (carritoResponse.status === 204)
			return new Response('', { ...CORS_HEADERS, status: 204 })
		const body: any = await carritoResponse.json()
		await sql`DELETE FROM Venta WHERE cod_vent = ${body.cod_vent}`
		return Response.json(body, CORS_HEADERS)
	}

	@sqlProtection
	@LogFunctionExecution
	async addItemsToCarrito(clienteID: string, items: CarritoItem[]) {
		// Get carrito or create if doesn't exist
		const carrito = await ((await this.createCarritoForCliente(clienteID)).json()) as Carrito

		for (const item of items) {
			await sql`INSERT INTO Detalle_Venta (cant_deta_vent, precio_unitario_vent,
				fk_vent, fk_inve_tien_1, fk_inve_tien_2, fk_inve_tien_3, fk_inve_tien_4)
				VALUES (${item.cantidad}, ${item.precio_unitario},
				${carrito.cod_vent}, ${item.cerveza}, ${item.presentacion},
				1, ${item.lugar_tien}) -- Insert new detalle
				ON CONFLICT (fk_vent, fk_inve_tien_1, fk_inve_tien_2)
				DO UPDATE SET -- If conflicts, just update the amount
					cant_deta_vent = ${item.cantidad},
					fk_inve_tien_4 = ${item.lugar_tien}`
		}
		return await this.getCarritoAndItems(clienteID)
	}

	@sqlProtection
	@LogFunctionExecution
	async removeItemsFromCarrito(clienteID: string, items: CarritoItemIdentifier[]) {
		// Get carrito or create if doesn't exist
		const carrito = await ((await this.createCarritoForCliente(clienteID)).json()) as Carrito
		if (carrito.items.length === 0) // If empty carrito, do nothing
			return await this.getCarritoAndItems(clienteID);

		const deletions = []
		for (const item of items)
			deletions.push(await sql`DELETE FROM Detalle_Venta
				WHERE fk_vent = ${carrito.cod_vent}
				AND fk_inve_tien_1 = ${item.cerveza}
				AND fk_inve_tien_2 = ${item.presentacion}
				AND fk_inve_tien_4 = ${item.lugar_tien}`)
		await Promise.all(deletions)

		return await this.getCarritoAndItems(clienteID);
	}

	@sqlProtection
	@LogFunctionExecution
	async payForCarrito(clienteID: string) {
		const carrito = await this.getCarritoObjectFromCliente(clienteID);
		if (carrito === undefined)
			return new Response('', { ...CORS_HEADERS, status: 204 })
		const res = await sql`INSERT INTO ESTA_VENT (fk_vent, fk_esta, fecha_ini)
			VALUES (${carrito.cod_vent}, 5, CURRENT_DATE) RETURNING *`;
		return Response.json(res, { ...CORS_HEADERS, status: 200 })
	}

	@sqlProtection
	@LogFunctionExecution
	async registerPayment(clienteID: string, payments: any[]) {
		const carrito = await ((await this.createCarritoForCliente(clienteID)).json()) as Carrito
		const metodos_pago: [number, number][] = []
		for (const pago of payments) {
			if (pago.tipo === "Tarjeta")
				metodos_pago.push([await MetodoPagoService.insertTarjeta(
					pago.numero_tarj,
					pago.fecha_venci_tarj,
					pago.cvv_tarj,
					pago.nombre_titu_tarj,
					pago.credito), pago.monto])
			else
				metodos_pago.push([await MetodoPagoService.getPuntoCanjeo(), pago.monto])
		}

		const tasa = (await TasaService.getTasaDiaActualObject())[0];
		const pagos = []
		for (const metodo of metodos_pago)
			pagos.push(await sql`INSERT INTO Pago (fk_vent, fk_meto_pago, monto_pago, fecha_pago, fk_tasa)
				VALUES (${carrito.cod_vent}, ${metodo.at(0)}, ${metodo.at(1)}, CURRENT_DATE, ${tasa?.cod_tasa}) RETURNING *`)

		return Response.json(pagos, CORS_HEADERS)
	}

	routes = {
		"/api/carrito/:clienteID": {
			GET: async (req: any) =>
				await this.getCarritoAndItems(req.params.clienteID),
			POST: async (req: any) =>
				await this.createCarritoForCliente(req.params.clienteID),
			DELETE: async (req: any) =>
				await this.clearCarritoForCliente(req.params.clienteID),
		},
		"/api/carrito/:clienteID/items": {
			GET: async (req: any) =>
				(await this.getCarritoObjectFromCliente(req.params.clienteID))?.items || new Response('', { ...CORS_HEADERS, status: 204 }),
			POST: async (req: any) =>
				await this.addItemsToCarrito(req.params.clienteID, await req.json()),
			DELETE: async (req: any) =>
				await this.removeItemsFromCarrito(req.params.clienteID, await req.json())
		},
		"/api/carrito/:clienteID/pay": {
			GET: async (req: any) =>
				await this.payForCarrito(req.params.clienteID),
			POST: async (req: any) =>
				await this.registerPayment(req.params.clienteID, await req.json())
		}
	};
}

export default new CarritoService();
