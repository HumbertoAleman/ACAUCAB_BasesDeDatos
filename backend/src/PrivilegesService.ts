import { sql } from "bun"
import { AddOptionsMethod, LogFunctionExecution, sqlProtection } from "./logger/decorators"
import { CORS_HEADERS } from "../globals";

@AddOptionsMethod
class PrivilegesService {

	@sqlProtection
	@LogFunctionExecution
	async getAllPrivileges() {
		const res = await sql`SELECT * FROM Privilegio`;
		return Response.json(res, CORS_HEADERS);
	}

	@sqlProtection
	@LogFunctionExecution
	async getPrivilegesFromRol(rol: Number) {
		const res = sql`
            SELECT *
            FROM privilegio WHERE cod_priv IN (SELECT fk_priv
            FROM Privilegio p, PRIV_ROL rp
            WHERE rp.fk_priv = p.cod_priv AND rp.fk_rol = ${Number(rol)})`
		return Response.json(res, CORS_HEADERS)
	}

	routes = {
		"/api/privileges": {
			GET: async () => await this.getAllPrivileges()
		},

		"/api/privileges/:rol": {
			GET: async (req: any) => await this.getPrivilegesFromRol(Number(req.params.rol))
		},
	}
}

export default new PrivilegesService();
