import { sql } from "bun";
import {
	AddOptionsMethod,
	LogFunctionExecution,
	sqlProtection,
} from "./logger/decorators";
import { CORS_HEADERS } from "../globals";

@AddOptionsMethod
class CarritoService {
	@sqlProtection
	@LogFunctionExecution
	async getCarritoFromCliente(clienteID: string) {
		const carritos = await sql`
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
			LIMIT 1;`; // Get latest online Venta that hasn't been bought yet

		if (carritos.length === 0)
			return new Response("", { ...CORS_HEADERS, status: 204 }); // If no carrito found, return No Content

		const carrito = carritos[0];
		const detalles = await sql`
			SELECT *
			FROM Detalle_Venta
			WHERE fk_vent = ${carrito.cod_vent}`;

		return Response.json({ ...carrito, items: detalles });
	}

	@sqlProtection
	@LogFunctionExecution
	async createCarritoForCliente(clienteID: string) {
		const carrito = await this.getCarritoFromCliente(clienteID);
		if (carrito.status === 200) return carrito;

		const newCarrito = (
			await sql`INSERT INTO Venta(fecha_vent, iva_vent, base_imponible_vent, total_vent, online, fk_clie, fk_tien)
			VALUES(CURRENT_DATE, 0, 0, 0, true, ${clienteID}, 1) RETURNING *`
		)[0];

		return Response.json(newCarrito, CORS_HEADERS);
	}

	routes = {
		"/api/carrito/:clienteID": {
			GET: async (req: any) =>
				await this.getCarritoFromCliente(req.params.clienteID),
			POST: async (req: any) =>
				await this.createCarritoForCliente(req.params.clienteID),
		},
	};
}

export default new CarritoService();
