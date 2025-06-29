import { sql } from "bun";
import { AddOptionsMethod, LogFunctionExecution, sqlProtection } from "./logger/decorators";
import { CORS_HEADERS } from "../globals";

@AddOptionsMethod
class BancoService {
	@sqlProtection
	@LogFunctionExecution
	async getBancos() {
		const res = await sql`SELECT * FROM Banco`;
		return Response.json(res, CORS_HEADERS);
	}

	routes = {
		"/api/bancos": {
			GET: async () => await this.getBancos()
		}
	}
}

export default new BancoService();
