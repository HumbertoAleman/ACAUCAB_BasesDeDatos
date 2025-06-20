import { sql } from "bun";
import { quickDelete } from "./src/delete";
import { quickInsert } from "./src/insert";
import getRol from "./src/query_rol";
import getUsuario from "./src/query_usuario";

const CORS_HEADERS = {
	headers: {
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Methods': 'OPTIONS, POST',
		'Access-Control-Allow-Headers': '*',
	},
};

console.log("Opening Backend on Port 3000");

Bun.serve({
	routes: {
		"/ping": () => new Response("pong"),
		"/quick": {
			POST: quickInsert,
			DELETE: quickDelete,
		},
		"/rol": { GET: getRol, },
		"/usuario": { GET: getUsuario, },
		"/api/auth/verify": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			GET: (req, _) => {
				console.log(req.headers)
				return Response.json({ success: true }, CORS_HEADERS)
			}
		},
		"/api/auth/login": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			POST: async req => {
				const body = await req.json() as { username: string, password: string };
				const authorization: Array<any> = await sql`
					SELECT U.username_usua, R.nombre_rol
					FROM USUARIO AS U
					JOIN ROL AS R ON R.cod_rol = U.fk_rol
					WHERE username_usua = ${body.username} AND contra_usua = ${body.password}`
				if (authorization.length > 0) {
					const user = authorization[0];
					return Response.json(
						{
							"authenticated": true,
							"user": {
								"username": user.username_usua,
								"rol": user.nombre_rol
							}
						}
						, CORS_HEADERS)
				}
				return Response.json({ authenticated: false }, CORS_HEADERS)
			}
		}
	}
})
