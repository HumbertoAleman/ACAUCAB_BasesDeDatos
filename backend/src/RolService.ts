import { sql } from "bun";
import { CORS_HEADERS } from "../globals";
import { AddOptionsMethod, LogFunctionExecution, sqlProtection } from "./logger/decorators";

type Rol = {
	cod_rol?: number
	nombre_rol: string
	descripcion_rol: string
}

type Privilegio = {
	cod_priv?: number
	nombre_priv: string
	descripcion_priv: string
}

type PRIV_ROL = {
	fk_rol: number
	fk_priv: number
}

@AddOptionsMethod
class RolService {
	@sqlProtection
	@LogFunctionExecution
	async getRolFromId(id: number): Promise<any> {
		const res: Rol[] = await sql`SELECT * FROM Rol WHERE cod_rol = ${id} LIMIT 1`;
		return Response.json(res, CORS_HEADERS)
	}

	@sqlProtection
	@LogFunctionExecution
	async getAllRoles() {
		const res: Rol[] = await sql`SELECT * FROM Rol`;
		return Response.json(res, CORS_HEADERS);
	}

	@sqlProtection
	@LogFunctionExecution
	async createNewRol(rol: Rol) {
		const res: Rol[] = await sql`INSERT INTO Rol ${sql(rol)} RETURNING *`
		return Response.json(res, CORS_HEADERS)
	}

	@sqlProtection
	@LogFunctionExecution
	async getPrivilegesFromRol(id: number) {
		const res: Privilegio[] = await sql`
			SELECT P.cod_priv, P.nombre_priv, P.descripcion_priv
			FROM Privilegio AS P
			JOIN PRIV_ROL AS RP ON RP.fk_priv = P.cod_priv
			JOIN Rol AS R ON RP.fk_rol = ${id}
			group by P.cod_priv
			order by P.cod_priv`;
		return Response.json(res, CORS_HEADERS)
	}

	@sqlProtection
	@LogFunctionExecution
	async relatePrivilegeWithRol(fk_rol: number, fk_priv: number) {
		const res: PRIV_ROL[] = await sql`INSERT INTO PRIV_ROL ${sql({ fk_rol, fk_priv })} RETURNING *`
		return Response.json(res, CORS_HEADERS);
	}

	@sqlProtection
	@LogFunctionExecution
	async unrelatePrivilegeWithRol(fk_rol: number, fk_priv: number) {
		const res: PRIV_ROL[] = await sql`DELETE FROM PRIV_ROL WHERE fk_rol = ${fk_rol} AND fk_priv = ${fk_priv} RETURNING *`
		return Response.json(res, CORS_HEADERS);
	}

	routes = {
		"/api/roles": {
			GET: async () => await this.getAllRoles(),
			POST: async (req: any) => await this.createNewRol(await req.json()),
		},

		"/api/roles/:id": {
			GET: async (req: any) => await this.getRolFromId(req.params.id)
		},

		"/api/roles/:id/privileges": {
			GET: async (req: any) => await this.getPrivilegesFromRol(req.params.id),
			POST: async (req: any) => await this.relatePrivilegeWithRol(req.params.id, (await req.json()).fk_priv),
			DELETE: async (req: any) => await this.unrelatePrivilegeWithRol(req.params.id, (await req.json()).fk_priv)
		},
	}
}

export default new RolService();
