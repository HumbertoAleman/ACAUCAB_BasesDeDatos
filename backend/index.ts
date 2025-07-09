import { sql } from "bun";
import { quickDelete } from "./src/delete";
import { quickInsert } from "./src/insert";
import { CORS_HEADERS } from "./globals";

import AuthService from "./src/AuthService";
import ClientesService from "./src/ClientesService";
import InventoryService from "./src/InventoryService";
import PrivilegesService from "./src/PrivilegesService";
import ReportService from "./src/ReportService";
import RolService from "./src/RolService";
import TasaService from "./src/TasaService";
import UsuarioService from "./src/UsuarioService";
import VentaService from "./src/VentaService";
import getRol from "./src/query_rol";
import getUsuario from "./src/query_usuario";
import CompraService from "./src/CompraService";
import BancoService from "./src/BancoService";
import CarritoService from "./src/CarritoService";
import EventoService from "./src/EventoService";
import TipoEventoService from "./src/TipoEventoService";
import { dashboardRoutes } from "./src/DashboardService";

console.log("Opening Backend on Port 3000");

Bun.serve({
	routes: {
		"/ping": () => new Response("pong"),
		"/quick/:table": {
			OPTIONS: () => new Response("OK", CORS_HEADERS),
			GET: async (req, _) => {
				const sqlString = `SELECT * FROM ${req.params.table}`;
				const res = await sql.unsafe(sqlString);
				return Response.json(res, CORS_HEADERS);
			},
			POST: quickInsert,
			DELETE: quickDelete,
		},

		"/rol": { GET: getRol },

		"/usuario": { GET: getUsuario },

		"/api/parroquias": {
			OPTIONS: () => new Response("OK", CORS_HEADERS),
			async GET() {
				const res = await sql`
					SELECT p.cod_luga, e.nombre_luga || ', ' || m.nombre_luga || ', ' || p.nombre_luga as "nombre_luga"
					FROM Lugar AS e
					JOIN Lugar AS m ON e.cod_luga = m.fk_luga
					JOIN Lugar AS p ON m.cod_luga = p.fk_luga
					`;
				return Response.json(res, CORS_HEADERS);
			},
		},

		"/api/users_with_details": {
			OPTIONS: () => new Response("Departed", CORS_HEADERS),
			GET: async () => {
				const users = await sql`
					SELECT U.cod_usua, U.username_usua, U.fk_rol, R.cod_rol, R.nombre_rol, R.descripcion_rol
					FROM Usuario AS U
					JOIN Rol AS R ON R.cod_rol = U.fk_rol`;

				if (users.length === 0) return Response.json(users, CORS_HEADERS);

				for (const user of users) {
					user.rol = {
						cod_rol: user.cod_rol,
						nombre_rol: user.nombre_rol,
						descripcion_rol: user.descripcion_rol,
					};
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
						order by P.cod_priv`;
					user.rol.privileges = privileges;
				}

				return Response.json(users, CORS_HEADERS);
			},
		},

		...AuthService.routes,
		...PrivilegesService.routes,
		...ClientesService.routes,
		...RolService.routes,
		...TasaService.routes,
		...VentaService.routes,
		...InventoryService.routes,
		...ReportService.routes,
		...UsuarioService.routes,
		...CompraService.routes,
		...BancoService.routes,
		...CarritoService.routes,
		...EventoService.routes,
		...TipoEventoService.routes,
		...dashboardRoutes({}),
	}
});
