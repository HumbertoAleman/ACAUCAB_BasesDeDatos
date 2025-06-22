import { sql } from "bun"
import { LogFunctionExecution } from "./logger/decorators"
import { CORS_HEADERS } from "../globals";

class PrivilegesService {
	@LogFunctionExecution
	async getMissingPrivilegesForForm(rol: Number): Promise<{ eid: any; displayName: any; }[]> {
		return sql`
            SELECT cod_priv as "eid", nombre_priv||': '||descripcion_priv as "displayName"
            FROM privilegio where cod_priv NOT IN (SELECT fk_priv
            FROM Privilegio p, PRIV_ROL rp
            WHERE rp.fk_priv = p.cod_priv AND rp.fk_rol = ${rol})`;
	}

	@LogFunctionExecution
	async getPossiblePrivilegesForForm(rol: Number): Promise<{ eid: any; displayName: any; }[]> {
		return sql`
            SELECT cod_priv as "eid", nombre_priv||': '||descripcion_priv as "displayName"
            FROM privilegio WHERE cod_priv IN (SELECT fk_priv
            FROM Privilegio p, PRIV_ROL rp
            WHERE rp.fk_priv = p.cod_priv AND rp.fk_rol = ${Number(rol)})`
	}

	@LogFunctionExecution
	async getPrivilegesFromRol(rol: Number): Promise<any[]> {
		return sql`
            SELECT *
            FROM privilegio WHERE cod_priv IN (SELECT fk_priv
            FROM Privilegio p, PRIV_ROL rp
            WHERE rp.fk_priv = p.cod_priv AND rp.fk_rol = ${Number(rol)})`
	}

	@LogFunctionExecution
	async relatePrivilegeRol(fk_priv: Number, fk_rol: Number): Promise<any[]> {
		const rol_priv = { fk_priv, fk_rol };
		return await sql`INSERT INTO PRIV_ROL ${sql(rol_priv)} RETURNING *`;
	}

	@LogFunctionExecution
	async removeRelationPrivilegeRol(fk_priv: Number, fk_rol: Number): Promise<any[]> {
		return await sql`DELETE FROM PRIV_ROL WHERE fk_rol = ${fk_rol} AND fk_priv = ${fk_priv}`;
	}

	privilegesRoutes = {
		"/api/privileges/:rol": {
			OPTIONS() { return new Response('Departed', CORS_HEADERS) },
			GET: async (req: any) => {
				let res = [];
				res = await this.getPrivilegesFromRol(Number(req.params.rol));
				return Response.json(res, CORS_HEADERS);
			},
			POST: async (req: any) => {
				const body: any = await req.json()
				const res = await this.relatePrivilegeRol(Number(body.info.fk_priv), Number(req.params.rol));
				return Response.json(res, CORS_HEADERS);
			},
			DELETE: async (req: any) => {
				const body: any = await req.json()
				const res = await this.removeRelationPrivilegeRol(Number(body.info.fk_priv), Number(req.params.rol));
				return Response.json(res, CORS_HEADERS);
			},
		},

		"/api/privileges/:rol/form": {
			GET: async (req: any) => {
				let res = [];
				if (new URL(req.url).searchParams.get("missing") === "true")
					res = await this.getMissingPrivilegesForForm(Number(req.params.rol));
				else
					res = await this.getPossiblePrivilegesForForm(Number(req.params.rol));
				return Response.json(res, CORS_HEADERS);
			},
		},
	}
}

export default new PrivilegesService();
