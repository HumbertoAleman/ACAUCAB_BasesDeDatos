import { sql } from "bun";
import { CORS_HEADERS } from "../globals";

class InventoryService {
	routes = {
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
		}
	}
}

export default new InventoryService();
