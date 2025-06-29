import { sql } from "bun"
import { AddOptionsMethod, LogFunctionExecution, sqlProtection } from "./logger/decorators";
import { CORS_HEADERS } from "../globals";

type Tasa = {
	cod_tasa: number,
	tasa_dolar_bcv: number
	tasa_punto: number
	fecha_ini_tasa: string
	fecha_fin_tasa: string
}

@AddOptionsMethod
class TasaService {
	@sqlProtection
	@LogFunctionExecution
	async getTasaDiaActual() {
		const res: Tasa[] = await sql` SELECT * FROM Tasa WHERE fecha_fin_tasa IS NULL LIMIT 1`
		return Response.json(res, CORS_HEADERS)
	}

	routes = {
		"/api/tasa": {
			GET: async () => await this.getTasaDiaActual()
		},
	}
}

export default new TasaService();
