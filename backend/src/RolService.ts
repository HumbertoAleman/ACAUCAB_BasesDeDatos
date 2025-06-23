import { sql } from "bun";
import { CORS_HEADERS } from "../globals";

class RolService {
	routes = {
		"/api/roles": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async () => {
				const res = await sql`SELECT * FROM Rol`;
				return Response.json(res, CORS_HEADERS)
			},
			POST: async (req: any) => {
				const body = await req.json();
				const res = await sql`INSERT INTO Rol ${sql(body.insert_data)}`
				return Response.json(res, CORS_HEADERS)
			},
		},

		"/api/roles/:id": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async (req: any) => {
				const id = req.params.id;
				const res = await sql`SELECT * FROM Rol WHERE cod_rol = ${id} LIMIT 1`;
				return Response.json(res, CORS_HEADERS)
			}
		},

		"/api/roles/:id/privileges": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async (req: any) => {
				const id = req.params.id;
				const res = await sql`
					SELECT P.cod_priv, P.nombre_priv, P.descripcion_priv
					FROM Privilegio AS P
					JOIN PRIV_ROL AS RP ON RP.fk_priv = P.cod_priv
					JOIN Rol AS R ON RP.fk_rol = ${id}
					group by P.cod_priv
					order by P.cod_priv`;
				return Response.json(res, CORS_HEADERS)
			},
			POST: async (req: any) => {
				const fk_rol = req.params.id;
				const fk_priv = await req.json()
				const priv_rol = { fk_rol, fk_priv }
				const res = await sql`INSERT INTO PRIV_ROL ${priv_rol} RETURNING *`
				return Response.json(res, CORS_HEADERS);
			},
			DELETE: async (req: any) => {
				const fk_rol = req.params.id;
				const fk_priv = await req.json()
				const res = await sql`DELETE FROM PRIV_ROL WHERE fk_rol = ${fk_rol} AND fk_priv = ${fk_priv} RETURNING *`
				return Response.json(res, CORS_HEADERS);
			},
		},
	}
}

export default new RolService();
