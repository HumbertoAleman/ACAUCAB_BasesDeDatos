import { sql } from "bun";
import { CORS_HEADERS } from "../globals";
import { AddOptionsMethod } from "./logger/decorators";

@AddOptionsMethod
class InventoryService {
	async getInventory() {
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

	async updateInventory(cantidad: number, cerveza: number, presentacion: number, tienda: number, lugar_tienda: number) {
		const res = await sql`
			UPDATE Inventario_Tienda
			SET cant_pres = ${cantidad}
			WHERE fk_cerv_pres_1 = ${cerveza}
				AND fk_cerv_pres_2 = ${presentacion}
				AND fk_tien = ${tienda}
				AND fk_luga_tien = ${lugar_tienda} RETURNING *`
		return Response.json(res, CORS_HEADERS);
	}

	routes = {
		"/api/inventory": {
			GET: async () => await this.getInventory(),
			PUT: async (req: any) => {
				const body = await req.json()
				return await this.updateInventory(
					body.cant_pres,
					body.fk_cerv_pres_1,
					body.fk_cerv_pres_2,
					body.fk_tien,
					body.fk_luga_tien
				)
			}
		}
	}
}

export default new InventoryService();
