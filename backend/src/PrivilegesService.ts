import { sql } from "bun"
import { LogFunctionExecution } from "./logger/decorators"

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
}

export default new PrivilegesService();
