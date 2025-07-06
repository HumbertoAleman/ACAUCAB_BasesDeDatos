import { sql } from "bun";
import { CORS_HEADERS } from "../globals";

class AuthService {
	generateUserToken(length: number = 32): string {
		const characters = '0123456789abcdef';
		let token = '';
		for (let i = 0; i < length; i++) {
			const randomIndex = Math.floor(Math.random() * characters.length);
			token += characters[randomIndex];
		}
		return token;
	}

	user_tokens: { [key: string]: string } = {};

	routes = {
		"/api/auth/verify": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: () => { return Response.json({ success: true }, CORS_HEADERS) }
		},

		"/api/auth/login": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any) => {
				const body = await req.json() as { username: string, password: string };
				const authorization: Array<any> = await sql`
					SELECT U.cod_usua, U.username_usua, R.nombre_rol, U.fk_clie, U.fk_empl, U.fk_miem
					FROM USUARIO AS U
					JOIN ROL AS R ON R.cod_rol = U.fk_rol
					WHERE username_usua = ${body.username} AND contra_usua = ${body.password}`
				if (authorization.length > 0) {
					const user = authorization[0];
					const token = this.generateUserToken();
					this.user_tokens[token] = user.cod_usua;
					return Response.json(
						{
							"authenticated": true,
							"token": token,
							"user": {
								"username": user.username_usua,
								"rol": user.nombre_rol,
								"fk_clie": user.fk_clie,
								"fk_empl": user.fk_empl,
								"fk_miem": user.fk_miem
							}
						}
						, CORS_HEADERS)
				}
				return Response.json({ authenticated: false }, CORS_HEADERS)
			}
		},
	}
}

export default new AuthService();
