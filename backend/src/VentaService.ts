import { sql } from "bun"
import { LogFunctionExecution } from "./logger/decorators"

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

class VentaService {
	@LogFunctionExecution
	createMetodoPago(pago: APIPago): Bun.SQLQuery<any> {
		if (pago.tipo === "Tarjeta")
			return sql`CALL add_tarjeta(${pago.numero}, ${pago.fecha_venci}, ${pago.cvv}, ${pago.nombre_titu}, ${pago.credito})`
		if (pago.tipo === "Cheque")
			return sql`CALL add_cheque(${pago.numero}, ${pago.numero_cuenta}, ${pago.nombre_banco})`
		if (pago.tipo === "Efectivo")
			return sql`CALL add_efectivo(${pago.denominacion_efec})`
		return sql`CALL add_punto_canjeo()`
	}

	@LogFunctionExecution
	async registerVenta(venta: APIVenta) {
		const metodos_de_pago: number[] = [];
		for (const pago of venta.pagos) {
			await this.createMetodoPago(pago)
			const id_pago = (await sql`SELECT cod_meto_pago FROM Metodo_Pago ORDER BY cod_meto_pago DESC LIMIT 1`)[0];
			metodos_de_pago.push(Number(id_pago.cod_meto_pago));
		}

		const montos = venta.pagos.map(x => Math.round(x.monto))
		const cantidades = venta.items.map(x => x.cantidad)
		const cervezas = venta.items.map(x => x.fk_cerv_pres_1)
		const presentaciones = venta.items.map(x => x.fk_cerv_pres_2)
		const lugares = venta.items.map(x => x.fk_luga_tien)

		try {
			await sql`
				CALL venta_en_tienda(
				CAST(${venta.fecha_vent} AS Date),
				CAST(${venta.online} AS Boolean),
				CAST(${venta.fk_clie} AS Text),
				CAST(${venta.fk_tien} AS integer),
				CAST(ARRAY [ ${metodos_de_pago} ] AS integer[]),
				CAST(ARRAY [ ${montos} ] AS numeric(32 ,2)[]),
				ARRAY [ ${cantidades} ],
				ARRAY [ ${cervezas} ],
				ARRAY [ ${presentaciones} ] ,
				ARRAY [ ${lugares} ])`
			const res = (await sql`SELECT cod_vent FROM Venta ORDER BY cod_vent DESC LIMIT 1`)[0]
			return res;
		} catch (e) {
			const msg = "Could not complete purchase"
			console.error(e, msg)
			return { "error": msg }
		}
	}
}

export default new VentaService();

export type { APIVenta };
