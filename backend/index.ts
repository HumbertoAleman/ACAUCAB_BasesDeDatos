import { sql } from "bun";
import { quickDelete } from "./src/delete";
import { quickInsert } from "./src/insert";
import { CORS_HEADERS } from "./globals";
import getRol from "./src/query_rol";
import getUsuario from "./src/query_usuario";
import PrivilegesService from "./src/PrivilegesService";
import ClientesService from "./src/ClientesService";
import TasaService from "./src/TasaService";
import VentaService, { type APIVenta } from "./src/VentaService";
import AuthService from "./src/AuthService";
import RolService from "./src/RolService";
import { PDFDocument, StandardFonts, rgb } from "pdf-lib";

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

		"/api/users_with_details": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async () => {
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

		...AuthService.routes,
		...PrivilegesService.routes,
		...ClientesService.routes,
		...RolService.routes,

		"/api/tasa": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			async GET(req, _) {
				const res = (await TasaService.getTasaDiaActual())
				return Response.json(res, CORS_HEADERS)
			}
		},

		"/api/venta": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			async POST(req, _) {
				const res = await VentaService.registerVenta((await req.json()) as APIVenta)
				return Response.json(res, CORS_HEADERS);
			}
		},

		"/api/inventory": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			async GET() {
				const res = await sql`SELECT C.nombre_cerv AS "nombre_producto", P.nombre_pres AS "nombre_presentacion", SUM(IT.cant_pres) AS "stock_actual", AVG(IT.precio_actual_pres)::numeric(8,2) AS "precio_usd", LT.nombre_luga_tien AS "lugar_tienda", M.razon_social_miem AS "miembro_proveedor"
					FROM Inventario_Tienda AS IT
					JOIN Cerveza AS C ON C.cod_cerv = IT.fk_cerv_pres_1
					JOIN Presentacion AS P ON P.cod_pres = IT.fk_cerv_pres_2
					JOIN CERV_PRES AS CP ON CP.fk_cerv = C.cod_cerv AND CP.fk_pres = P.cod_pres
					JOIN Miembro AS M ON CP.fk_miem = M.rif_miem
					JOIN Lugar_Tienda AS LT ON LT.cod_luga_tien = IT.fk_luga_tien
					WHERE fk_tien = 1
					GROUP BY C.nombre_cerv, P.nombre_pres, LT.nombre_luga_tien, M.razon_social_miem`
				for (const item of res)
					item.estado = (item.stock_actual > 100) ? "Disponible" : ((item.stock_actual === 0) ? "Agotado" : "Bajo Stock")
				return Response.json(res, CORS_HEADERS);
			}
		},

		"/api/reportes/periodo_tipo_cliente/pdf": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async (req) => {
				// La url debe verse así /api/reportes/periodo_tipo_cliente/pdf?year=año&modalidad=modalidad donde año y modalidad son parámetros requeridos
				const url = new URL(req.url);
				const year = parseInt(url.searchParams.get("year") || "");
				const modalidad = url.searchParams.get("modalidad") || "";

				if (!year || !modalidad) {
				return new Response("Parámetros 'year' y 'modalidad' requeridos", { status: 400 });
				}

				const data = await sql`
				SELECT * FROM periodo_tipo_cliente(${year}, ${modalidad})
				`;

				// 3. Crea el PDF
				const pdfDoc = await PDFDocument.create();
				const page = pdfDoc.addPage([700, 800]);
				const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

				let y = 780;

				page.drawText("ACAUCAB", { x: 50, y, size: 28, font, color: rgb(0, 0.2, 0.6) });
				y -= 40;

				y = 750;
				page.drawText(`Reporte: Periodo Tipo Cliente (${modalidad}, ${year})`, { x: 50, y, size: 16, font, color: rgb(0, 0, 0.8) });
				y -= 30;

				// Encabezados
				page.drawText("Tipo", { x: 50, y, size: 12, font });
				page.drawText("Periodo", { x: 200, y, size: 12, font });
				page.drawText("Cantidad", { x: 300, y, size: 12, font });
				page.drawText("Año", { x: 400, y, size: 12, font });
				y -= 20;

				// Datos
				for (const row of data) {
				page.drawText(String(row["Tipo"]), { x: 50, y, size: 10, font });
				page.drawText(String(row["Periodo"]), { x: 200, y, size: 10, font });
				page.drawText(String(row["Cantidad"]), { x: 300, y, size: 10, font });
				page.drawText(String(row["Año"]), { x: 400, y, size: 10, font });
				y -= 15;
				if (y < 50) break; // Evita desbordar la página
				}

				const pdfBytes = await pdfDoc.save();

				return new Response(pdfBytes, {
				headers: {
					"Content-Type": "application/pdf",
					"Content-Disposition": `attachment; filename=periodo${year}_tipo_cliente_${modalidad}.pdf`,
					"Access-Control-Allow-Origin": "*",
					"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
					"Access-Control-Allow-Headers": "Content-Type, Authorization",
				},
				});
			}
		},
	}
})
