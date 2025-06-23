import { sql } from "bun";
import { CORS_HEADERS } from "../globals";

class CompraService {
	routes = {
		"/api/compra": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async () => {
				const res = await sql`
					SELECT
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
				return Response.json(res, CORS_HEADERS)
			}
		},
		"/api/set_compra_pagada": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any) => {
				const body = await req.json();
				const new_status = { fk_comp: body.fk_comp, fk_rol: 4 }; // HACK: FK_ROL = 4 es compra pagada
				const res = sql`insert into esta_comp ${sql(new_status)}`
				return Response.json(res, CORS_HEADERS);
			}
		}
	}
}

export default new CompraService();
