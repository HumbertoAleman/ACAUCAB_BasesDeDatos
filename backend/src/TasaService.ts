import { sql } from "bun"
import { LogFunctionExecution } from "./logger/decorators";
import { CORS_HEADERS } from "../globals";

class TasaService {
	@LogFunctionExecution
	async getTasaDiaActual(): Promise<any[]> {
		return sql` SELECT * FROM Tasa WHERE fecha_fin_tasa IS NULL LIMIT 1`
	}

	tasaRoutes = {
		"/api/tasa": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async () => {
				const res = (await this.getTasaDiaActual())
				return Response.json(res, CORS_HEADERS)
			}
		},
	}
}

export default new TasaService();
