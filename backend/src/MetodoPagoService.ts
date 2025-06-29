import { sql } from "bun";
import { LogFunctionExecution, sqlProtection } from "./logger/decorators";
import Logger from "./logger/logger";

type Efectivo = {
	fk_meto_pago?: number
	denominacion_efec: string
}

type Cheque = {
	fk_meto_pago?: number
	numero_cheque: number
	numero_cuenta_cheque: number
	fk_banc: number
}

type Tarjeta = {
	fk_meto_pago?: number
	numero_tarj: number
	fecha_venci_tarj: string
	cvv_tarj: number
	nombre_titu_tarj: string
	credito: boolean
}

class MetodoPagoService {
	@sqlProtection
	@LogFunctionExecution
	async newMetodoPagoEntry(): Promise<number> {
		return (await sql`INSERT INTO Metodo_Pago DEFAULT VALUES RETURNING *`)[0].cod_meto_pago;
	}

	@sqlProtection
	@LogFunctionExecution
	async insertTarjeta(numero_tarj: number, fecha_venci_tarj: string, cvv_tarj: number, nombre_titu_tarj: string, credito: boolean): Promise<number> {
		const t: Tarjeta = { numero_tarj, fecha_venci_tarj, cvv_tarj, nombre_titu_tarj, credito }
		t.fk_meto_pago = await this.newMetodoPagoEntry()
		await sql`INSERT INTO Tarjeta (fk_meto_pago, numero_tarj, fecha_venci_tarj, cvv_tarj, nombre_titu_tarj, credito)
			VALUES(${t.fk_meto_pago}, ${t.numero_tarj}, TO_DATE(${t.fecha_venci_tarj}, 'MM/YY'), ${t.cvv_tarj}, ${t.nombre_titu_tarj}, ${t.credito})`;
		return t.fk_meto_pago
	}

	@sqlProtection
	@LogFunctionExecution
	async insertCheque(numero_cheque: number, numero_cuenta_cheque: number, fk_banc: number = 1): Promise<number> {
		const cheque: Cheque = { numero_cheque, numero_cuenta_cheque, fk_banc }
		cheque.fk_meto_pago = await this.newMetodoPagoEntry()
		await sql`INSERT INTO Cheque ${sql(cheque)}`
		return cheque.fk_meto_pago
	}

	@sqlProtection
	@LogFunctionExecution
	async getOrInsertEfectivo(denominacion: string): Promise<number> {
		let metodo: number
		let efec: Efectivo[] = await sql`SELECT * FROM Efectivo WHERE denominacion_efec = ${denominacion} LIMIT 1`;
		if (efec.length === 0) {
			metodo = await this.newMetodoPagoEntry()
			efec = await sql`INSERT INTO Efectivo ${sql({ fk_meto_pago: metodo, denominacion_efec: denominacion })} RETURNING *`
		}
		metodo = efec[0]!.fk_meto_pago!
		return metodo;
	}

	@sqlProtection
	@LogFunctionExecution
	async getPuntoCanjeo(): Promise<number> {
		const res = (await sql`SELECT * FROM Punto_Canjeo ORDER BY fk_metodo_pago DESC LIMIT 1`)[0].fk_meto_pago;
		return res
	}
}

export default new MetodoPagoService();
