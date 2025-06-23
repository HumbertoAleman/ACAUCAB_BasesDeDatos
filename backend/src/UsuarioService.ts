import { sql } from "bun";
import { CORS_HEADERS } from "../globals";

class UsuarioService {
	routes = {
		"/api/user": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any) => {
				const body = await req.json();
				body.tipo_clie = body.tipo_clie === "Natural" ? 200 : 201;
				delete body.tipo_clie;
				const res = await sql`INSERT INTO Usuario ${sql(body)} RETURNING *`
				return Response.json(res, CORS_HEADERS);
			},
			PUT: async (req: any) => {
				const body = await req.json();
				if ('fk_rol' in body)
					await sql`UPDATE Usuario SET fk_rol = ${body.fk_rol} WHERE cod_usua = ${body.cod_usua}`;
				if ('username_usua' in body)
					await sql`UPDATE Usuario SET username_usua = ${body.username_usua} WHERE cod_usua = ${body.cod_usua}`;
				const res = await sql`select * from usuario where cod_usua = ${body.cod_usua}`
				return Response.json(res, CORS_HEADERS);
			}
		}
	}
}

export default new UsuarioService();
