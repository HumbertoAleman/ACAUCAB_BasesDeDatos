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
			metodos_de_pago.push(id_pago);
		}

		const res = await sql`CALL venta_en_tienda(
			${venta.fecha_vent},
			${venta.online},
			${venta.fk_clie},
			${venta.fk_tien},
			${metodos_de_pago},
			${venta.pagos.map(x => x.monto)},
			${venta.items.map(x => x.cantidad)},
			${venta.items.map(x => x.fk_cerv_pres_1)},
			${venta.items.map(x => x.fk_cerv_pres_2)},
			${venta.items.map(x => x.fk_luga_tien)}
		)`

		return res
	}
}

export default new VentaService();

export type { APIVenta };
