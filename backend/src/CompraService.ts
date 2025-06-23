import { sql } from "bun";
import { CORS_HEADERS } from "../globals";

function formatDate(date: Date) {
	const year = date.getFullYear();
	const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are zero-based
	const day = String(date.getDate()).padStart(2, '0');

	return `${year}-${month}-${day}`;
}

class CompraService {
	routes = {
		"/api/compra": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async () => {
				const res = await sql`
					SELECT
						c.cod_comp,
						ce.nombre_cerv,
						c.fecha_comp,
						dc.cant_deta_comp,
						c.total_comp,
						m.denom_comercial_miem
					FROM
						compra AS c
						JOIN detalle_compra AS dc ON dc.fk_comp = c.cod_comp
						JOIN cerv_pres AS cp ON cp.fk_cerv = dc.fk_cerv_pres_1
							AND cp.fk_pres = dc.fk_cerv_pres_2
						JOIN cerveza AS ce ON cp.fk_cerv = ce.cod_cerv
						JOIN miembro AS m ON m.rif_miem = cp.fk_miem`

				for (const compra of res) {
					const status = await sql`SELECT E.nombre_esta
						FROM ESTA_COMP AS EC
						JOIN Estatus AS E ON EC.fk_esta = E.cod_esta
						WHERE EC.fk_comp = ${compra.cod_comp}
						ORDER BY EC.cod_esta_comp DESC
						LIMIT 1`
					delete compra.cod_comp;
					compra.nombre_estatus = status[0].nombre_esta
				}

				return Response.json(res, CORS_HEADERS)
			}
		},
		"/api/set_compra_pagada": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any) => {
				const body = await req.json();
				const new_status = { fk_comp: body.fk_comp, fk_esta: 4, fecha_ini: formatDate(new Date()) }; // HACK: FK_ROL = 4 es compra pagada
				const res = await sql`INSERT INTO ESTA_COMP ${sql(new_status)} RETURNING *`
				console.log(res)
				return Response.json(res, CORS_HEADERS);
			}
		}
	}
}

export default new CompraService();
