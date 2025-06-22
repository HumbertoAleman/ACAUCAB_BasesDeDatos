import { sql } from "bun"
import { LogFunctionExecution } from "./logger/decorators";

class TasaService {
	@LogFunctionExecution
	async getTasaDiaActual(): Promise<any[]> {
		return sql` SELECT * FROM Tasa WHERE fecha_fin_tasa IS NULL LIMIT 1`
	}
}

export default new TasaService();
