import { sql } from "bun";
import { quickDelete } from "./src/delete";
import { quickInsert } from "./src/insert";
import getRol from "./src/query_rol";
import getUsuario from "./src/query_usuario";

function generateUserToken(length: number = 32): string {
	const characters = '0123456789abcdef';
	let token = '';
	for (let i = 0; i < length; i++) {
		const randomIndex = Math.floor(Math.random() * characters.length);
		token += characters[randomIndex];
	}
	return token;
}

const user_tokens: { [key: string]: string } = {};

const CORS_HEADERS = {
	headers: {
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Methods': 'OPTIONS, POST',
		'Access-Control-Allow-Headers': '*, Authorization',
	},
};

console.log("Opening Backend on Port 3000");

Bun.serve({
	routes: {
		"/ping": () => new Response("pong"),
		"/quick/:table": {
			GET: async (req, _) => {
				const sqlString = `SELECT * FROM ${req.params.table}`;
				const res = await sql.unsafe(sqlString);
				return Response.json(res, CORS_HEADERS)
			},
			POST: quickInsert,
			DELETE: quickDelete,
		},
		"/rol": { GET: getRol, },
		"/usuario": { GET: getUsuario, },

		"/api/roles": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			GET: async _ => {
				const res = await sql`SELECT * FROM Rol`;
				return Response.json(res, CORS_HEADERS)
			},
			POST: async (req, _) => {
				const body = await req.json();
				const res = await sql`INSERT INTO Rol ${sql(body.insert_data)}`
				return Response.json(res, CORS_HEADERS)
			},
		},

		"/api/roles/:id": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			GET: async (req) => {
				const id = req.params.id;
				const res = await sql`SELECT * FROM Rol WHERE cod_rol = ${id} LIMIT 1`;
				return Response.json(res, CORS_HEADERS)
			}
		},

		"/api/roles/:id/privileges": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			GET: async (req) => {
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
			POST: async (req, _) => {
				const fk_rol = req.params.id;
				const fk_priv = await req.json()
				const priv_rol = { fk_rol, fk_priv }
				const res = await sql`INSERT INTO PRIV_ROL ${priv_rol} RETURNING *`
				return Response.json(res, CORS_HEADERS);
			},
			DELETE: async (req, _) => {
				const fk_rol = req.params.id;
				const fk_priv = await req.json()
				const res = await sql`DELETE FROM PRIV_ROL WHERE fk_rol = ${fk_rol} AND fk_priv = ${fk_priv} RETURNING *`
				return Response.json(res, CORS_HEADERS);
			},
		},

		"/api/form/parroquias": {
			async GET() {
				const res = await sql`
				  SELECT p.cod_luga as eid, e.nombre_luga || ', ' || m.nombre_luga || ', ' || p.nombre_luga as "displayName"
				  FROM Lugar AS e
				  JOIN Lugar AS m ON e.cod_luga = m.fk_luga
				  JOIN Lugar AS p ON m.cod_luga = p.fk_luga`
				return Response.json(res, CORS_HEADERS);
			},
		},

		"/api/privileges": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			GET: async _ => {
				const res = await sql`SELECT * FROM Privilegio`;
				return Response.json(res, CORS_HEADERS)
			},
		},

		"/api/privileges/:id": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			GET: async (req) => {
				const id = req.params.id;
				const res = await sql`SELECT * FROM Privilegio WHERE cod_priv = ${id} LIMIT 1`;
				return Response.json(res, CORS_HEADERS)
			}
		},

		"/api/auth/verify": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			GET: (req, _) => {
				console.log(req.headers)
				return Response.json({ success: true }, CORS_HEADERS)
			}
		},

		"/api/users_with_details": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			GET: async (req, _) => {
				const users = await sql`
					SELECT U.cod_usua, U.username_usua, U.fk_rol, R.cod_rol, R.nombre_rol, R.descripcion_rol
					FROM Usuario AS U
					JOIN Rol AS R ON R.cod_rol = U.fk_rol`;

				if (users.length === 0)
					return Response.json(users, CORS_HEADERS)

				for (const user of users) {
					user.rol = { cod_rol: user.cod_rol, nombre_rol: user.nombre_rol, descripcion_rol: user.descripcion_rol }
					delete user.cod_rol;
					delete user.nombre_rol;
					delete user.descripcion_rol;
				}

				for (const user of users) {
					const privileges = await sql`
						SELECT P.cod_priv, P.nombre_priv, P.descripcion_priv
						FROM Privilegio AS P
						JOIN PRIV_ROL AS RP ON RP.fk_priv = P.cod_priv
						JOIN Rol AS R ON RP.fk_rol = ${user.rol.cod_rol}
						group by P.cod_priv
						order by P.cod_priv`
					user.rol.privileges = privileges;
				}

				return Response.json(users, CORS_HEADERS);
			}
		},

		"/api/auth/login": {
			OPTIONS: _ => new Response('Departed', CORS_HEADERS),
			POST: async req => {
				const body = await req.json() as { username: string, password: string };
				const authorization: Array<any> = await sql`
					SELECT U.cod_usua, U.username_usua, R.nombre_rol
					FROM USUARIO AS U
					JOIN ROL AS R ON R.cod_rol = U.fk_rol
					WHERE username_usua = ${body.username} AND contra_usua = ${body.password}`
				if (authorization.length > 0) {
					const user = authorization[0];
					const token = generateUserToken();
					user_tokens[token] = user.cod_usua;
					return Response.json(
						{
							"authenticated": true,
							"token": token,
							"user": {
								"username": user.username_usua,
								"rol": user.nombre_rol
							}
						}
						, CORS_HEADERS)
				}
				return Response.json({ authenticated: false }, CORS_HEADERS)
			}
		},

		"/api/privileges/:rol": {
			OPTIONS() { return new Response('Departed', CORS_HEADERS) },
			async GET(req) {
				const rol = req.params.rol;
				const missing = new URL(req.url).searchParams.get("missing");
				let res;
				if (missing === "true")
					res = await sql`
            SELECT eid as "eid", nombre||': '||descripcion as "displayName"
            FROM privilegio where eid NOT IN (SELECT fk_priv
            FROM Privilegio p, ROL_PRIV rp
            WHERE rp.fk_priv = p.cod_priv AND rp.fk_rol = ${Number(rol)})`
				else
					res = await sql`
            SELECT eid as "eid", nombre||': '||descripcion as "displayName"
            FROM privilegio WHERE eid IN (SELECT fk_priv
            FROM Privilegio p, ROL_PRIV rp
            WHERE rp.fk_priv = p.cod_priv AND rp.fk_rol = ${Number(rol)})`
				return Response.json(res, CORS_HEADERS);
			},
			async POST(req, _) {
				const body = await req.json()
				const rol_id = req.params.rol;
				const res = await RolManagementService.postRolPrivSQL({ fk_priv: body.insert_data.fk_priv, fk_rol: Number(rol_id) })
				return Response.json(res, CORS_HEADERS);
			},
			async DELETE(req, _) {
				const body = await req.json()
				const rol_id = req.params.rol;
				const res = await RolManagementService.deleteRolPrivSQL({ fk_priv: body.insert_data.fk_priv, fk_rol: Number(rol_id) })
				return Response.json(res, CORS_HEADERS);
			},
		},
	}
})
