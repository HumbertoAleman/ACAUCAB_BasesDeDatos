import { sql } from "bun"
import { AddOptionsMethod, LogFunctionExecution, sqlProtection } from "./logger/decorators"
import { CORS_HEADERS } from "../globals"
import MetodoPagoService from "./MetodoPagoService"

type APIPago = {
	[x: string]: any
	tipo: "Efectivo" | "Punto_Canjeo" | "Tarjeta" | "Cheque",
	monto: number
}

type APIItem = {
	fk_cerv_pres_1: number,
	fk_cerv_pres_2: number,
	fk_tien: 1,
	fk_luga_tien: number,
	cantidad: number
}

type APIVenta = {
	fecha_vent: string,
	iva_vent: number,
	base_imponible_vent: number,
	online: boolean,
	fk_clie: string,
	fk_tien: 1,
	items: APIItem[],
	pagos: APIPago[],
}

@AddOptionsMethod
class VentaService {
	@sqlProtection
	@LogFunctionExecution
	async getOrInsertMetodoPago(pago: APIPago): Promise<number> {
		switch (pago.tipo) {
			case "Efectivo":
				return await MetodoPagoService.getOrInsertEfectivo(pago.denominacion_efec as string)
			case "Punto_Canjeo":
				return await MetodoPagoService.getPuntoCanjeo();
			case "Tarjeta":
				return await MetodoPagoService.insertTarjeta(pago.numero_tarj, pago.fecha_venci_tarj, pago.cvv_tarj, pago.nombre_titu_tarj, pago.credito);
			case "Cheque":
				return await MetodoPagoService.insertCheque(pago.numero_cheque, pago.numero_cuenta_cheque, pago.fk_banc)
			default:
				return 1
		}
	}

	@sqlProtection
	@LogFunctionExecution
	async registerVenta(venta: APIVenta) {
		const metodos_de_pago: number[] = [];
		for (const pago of venta.pagos)
			metodos_de_pago.push(Number(await this.getOrInsertMetodoPago(pago)))

		const montos = venta.pagos.map(x => Math.round(x.monto * 100) / 100)
		const cantidades = venta.items.map(x => x.cantidad)
		const cervezas = venta.items.map(x => x.fk_cerv_pres_1)
		const presentaciones = venta.items.map(x => x.fk_cerv_pres_2)
		const lugares = venta.items.map(x => x.fk_luga_tien)

		const sql_string = `
			CALL venta_en_tienda(
			'${venta.fecha_vent}',
			${venta.online},
			'${venta.fk_clie}',
			${venta.fk_tien},
			ARRAY [ ${metodos_de_pago} ],
			ARRAY [ ${(montos)} ],
			ARRAY [ ${(cantidades)} ],
			ARRAY [ ${(cervezas)} ],
			ARRAY [ ${(presentaciones)} ] ,
			ARRAY [ ${(lugares)} ])`

		try {
			await sql.unsafe(sql_string)
			const res = (await sql`SELECT cod_vent FROM Venta ORDER BY cod_vent DESC LIMIT 1`)[0]
			return res;
		} catch (e) {
			const msg = "Could not complete purchase"
			console.error(e, msg)
			return { "error": msg }
		}
	}

	routes = {
		"/api/venta": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any, _) => {
				const res = await this.registerVenta((await req.json()) as APIVenta)
				return Response.json(res, CORS_HEADERS);
			}
		},
	}
}

export default new VentaService();

export type { APIVenta };
