import { sql } from "bun"
import { AddOptionsMethod, LogFunctionExecution, sqlProtection } from "./logger/decorators"
import { CORS_HEADERS } from "../globals"
import MetodoPagoService from "./MetodoPagoService"
import TasaService from "./TasaService"

type APIPago = {
	[x: string]: any
	tipo: "Efectivo" | "Punto_Canjeo" | "Tarjeta" | "Cheque",
	monto: number
}

type APIItem = {
	fk_cerv_pres_1: number,
	fk_cerv_pres_2: number,
	fk_tien: 1,
	fk_luga_tien: number,
	cantidad: number
}

type APIVenta = {
	fecha_vent: string,
	iva_vent: number,
	base_imponible_vent: number,
	online: boolean,
	fk_clie: string,
	fk_tien: 1,
	items: APIItem[],
	pagos: APIPago[],
}

// NUEVO: Tipo para venta de entradas
export type APIDetalleEntrada = {
	cant_deta_entr: number;
	precio_unitario_entr: number;
	fk_even: number;
};

export type APIVentaEntrada = {
	fecha_vent: string;
	iva_vent: number;
	base_imponible_vent: number;
	online: boolean;
	fk_clie: string;
	fk_even: number;
	items: APIDetalleEntrada[];
	pagos: APIPago[];
};

@AddOptionsMethod
class VentaService {
	@sqlProtection
	@LogFunctionExecution
	async getOrInsertMetodoPago(pago: APIPago): Promise<number> {
		switch (pago.tipo) {
			case "Efectivo":
				return await MetodoPagoService.getOrInsertEfectivo(pago.denominacion_efec as string)
			case "Punto_Canjeo":
				return await MetodoPagoService.getPuntoCanjeo();
			case "Tarjeta":
				return await MetodoPagoService.insertTarjeta(pago.numero_tarj, pago.fecha_venci_tarj, pago.cvv_tarj, pago.nombre_titu_tarj, pago.credito);
			case "Cheque":
				return await MetodoPagoService.insertCheque(pago.numero_cheque, pago.numero_cuenta_cheque, pago.fk_banc)
			default:
				return 1
		}
	}

	@sqlProtection
	@LogFunctionExecution
	async getCarritoActivo(clienteID: string) {
		const carrito = await sql`
			SELECT *
			FROM Venta V
			WHERE
				fk_clie = ${clienteID}
				AND online = true
				AND cod_vent NOT IN (
						SELECT fk_vent
						FROM ESTA_VENT
						WHERE fk_vent = V.cod_vent AND fk_esta = 5)
			ORDER BY cod_vent DESC
			LIMIT 1`
		
		return carrito[0] || null
	}

	@sqlProtection
	@LogFunctionExecution
	async registerVenta(venta: APIVenta) {
		if (venta.online) {
			// --- FLUJO ONLINE: Actualizar carrito existente ---
			const carritoActivo = await this.getCarritoActivo(venta.fk_clie)
			if (!carritoActivo) {
				return { success: false, message: "No se encontró un carrito activo para procesar" }
			}
			const tasa = (await TasaService.getTasaDiaActualObject())[0]
			if (!tasa) {
				return { success: false, message: "No se pudo obtener la tasa de cambio actual" }
			}
			try {
				const metodos_de_pago: number[] = []
				for (const pago of venta.pagos) {
					const metodoPagoId = await this.getOrInsertMetodoPago(pago)
					metodos_de_pago.push(Number(metodoPagoId))
				}
				for (let i = 0; i < venta.pagos.length; i++) {
					const pago = venta.pagos[i]
					const monto = Math.round(pago.monto * 100) / 100
					await sql`
						INSERT INTO Pago (fk_vent, fk_meto_pago, monto_pago, fecha_pago, fk_tasa)
						VALUES (${carritoActivo.cod_vent}, ${metodos_de_pago[i]}, ${monto}, ${venta.fecha_vent}, ${tasa.cod_tasa})
					`
				}
				await sql`
					UPDATE Venta 
					SET 
						iva_vent = ${venta.iva_vent},
						base_imponible_vent = ${venta.base_imponible_vent},
						total_vent = ${venta.iva_vent + venta.base_imponible_vent}
					WHERE cod_vent = ${carritoActivo.cod_vent}
				`
				await sql`
					INSERT INTO ESTA_VENT (fk_vent, fk_esta, fecha_ini)
					VALUES (${carritoActivo.cod_vent}, 5, ${venta.fecha_vent})
				`
				return { success: true, cod_vent: carritoActivo.cod_vent }
			} catch (e) {
				const msg = "Could not complete purchase"
				return { success: false, message: msg }
			}
		} else {
			// --- FLUJO FÍSICO: Crear nueva venta y detalles ---
			try {
				const ventaRes = (await sql`
					INSERT INTO Venta (fecha_vent, iva_vent, base_imponible_vent, total_vent, online, fk_clie, fk_tien)
					VALUES (${venta.fecha_vent}, ${venta.iva_vent}, ${venta.base_imponible_vent}, ${venta.iva_vent + venta.base_imponible_vent}, false, ${venta.fk_clie}, ${venta.fk_tien})
					RETURNING *
				`)[0];
				const cod_vent = ventaRes.cod_vent;
				for (const item of venta.items) {
					await sql`
						INSERT INTO Detalle_Venta (cant_deta_vent, precio_unitario_vent, fk_vent, fk_inve_tien_1, fk_inve_tien_2, fk_inve_tien_3, fk_inve_tien_4)
						VALUES (${item.cantidad}, 0, ${cod_vent}, ${item.fk_cerv_pres_1}, ${item.fk_cerv_pres_2}, 1, ${item.fk_luga_tien})
					`
				}
				const tasa = (await TasaService.getTasaDiaActualObject())[0]
				const metodos_de_pago: number[] = []
				for (const pago of venta.pagos) {
					const metodoPagoId = await this.getOrInsertMetodoPago(pago)
					metodos_de_pago.push(Number(metodoPagoId))
				}
				for (let i = 0; i < venta.pagos.length; i++) {
					const pago = venta.pagos[i]
					const monto = Math.round(pago.monto * 100) / 100
					await sql`
						INSERT INTO Pago (fk_vent, fk_meto_pago, monto_pago, fecha_pago, fk_tasa)
						VALUES (${cod_vent}, ${metodos_de_pago[i]}, ${monto}, ${venta.fecha_vent}, ${tasa.cod_tasa})
					`
				}
				await sql`
					INSERT INTO ESTA_VENT (fk_vent, fk_esta, fecha_ini)
					VALUES (${cod_vent}, 5, ${venta.fecha_vent})
				`
				return { success: true, cod_vent }
			} catch (e) {
				const msg = "Could not complete purchase"
				return { success: false, message: msg }
			}
		}
	}

	@sqlProtection
	@LogFunctionExecution
	async registerVentaEntrada(venta: APIVentaEntrada) {
		try {
			const ventaRes = (await sql`
				INSERT INTO Venta (fecha_vent, iva_vent, base_imponible_vent, total_vent, online, fk_clie, fk_even)
				VALUES (${venta.fecha_vent}, ${venta.iva_vent}, ${venta.base_imponible_vent}, ${venta.iva_vent + venta.base_imponible_vent}, true, ${venta.fk_clie}, ${venta.fk_even})
				RETURNING *
			`)[0];
			const cod_vent = ventaRes.cod_vent;
			// Insertar detalle de entrada
			for (const item of venta.items) {
				await sql`
					INSERT INTO Detalle_Entrada (cant_deta_entr, precio_unitario_entr, fk_vent, fk_even)
					VALUES (${item.cant_deta_entr}, ${item.precio_unitario_entr}, ${cod_vent}, ${item.fk_even})
				`;
				// Descontar entradas del evento
				await sql`
					UPDATE Evento SET cant_entradas_evento = cant_entradas_evento - ${item.cant_deta_entr}
					WHERE cod_even = ${item.fk_even}
				`;
			}
			// Insertar pago
			const tasa = (await TasaService.getTasaDiaActualObject())[0];
			const metodos_de_pago: number[] = [];
			for (const pago of venta.pagos) {
				const metodoPagoId = await this.getOrInsertMetodoPago(pago);
				metodos_de_pago.push(Number(metodoPagoId));
			}
			for (let i = 0; i < venta.pagos.length; i++) {
				const pago = venta.pagos[i];
				const monto = Math.round(pago.monto * 100) / 100;
				await sql`
					INSERT INTO Pago (fk_vent, fk_meto_pago, monto_pago, fecha_pago, fk_tasa)
					VALUES (${cod_vent}, ${metodos_de_pago[i]}, ${monto}, ${venta.fecha_vent}, ${tasa.cod_tasa})
				`;
			}
			await sql`
				INSERT INTO ESTA_VENT (fk_vent, fk_esta, fecha_ini)
				VALUES (${cod_vent}, 5, ${venta.fecha_vent})
			`;
			return { success: true, cod_vent };
		} catch (e) {
			const msg = "No se pudo completar la compra de entradas";
			return { success: false, message: msg };
		}
	}

	routes = {
		"/api/venta": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any, _) => {
				const res = await this.registerVenta((await req.json()) as APIVenta)
				return Response.json(res, CORS_HEADERS);
			}
		},
		"/api/venta-entrada": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any, _) => {
				const res = await this.registerVentaEntrada((await req.json()) as APIVentaEntrada)
				return Response.json(res, CORS_HEADERS);
			}
		},
	}
}

export default new VentaService();

export type { APIVenta };
