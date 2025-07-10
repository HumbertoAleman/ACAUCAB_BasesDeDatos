import { sql } from "bun";
import PDFDocument from "pdf-lib/cjs/api/PDFDocument";
import { StandardFonts } from "pdf-lib/cjs/api/StandardFonts";
import { CORS_HEADERS } from "../globals";
import { rgb } from "pdf-lib/cjs/api/colors";

class ReportService {
		routes = {
			"/api/reportes/periodo_tipo_cliente/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async (req) => {
					try {
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

					const pdfDoc = await PDFDocument.create();
					let page = pdfDoc.addPage([780, 800]);
					const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

					let y = 750;

					page.drawText("ACAUCAB", { x: 50, y, size: 28, font, color: rgb(0, 0.2, 0.6) });
					y -= 40;

					page.drawText(`Reporte: Periodo Tipo Cliente (${modalidad}, ${year})`, { x: 50, y, size: 16, font, color: rgb(0, 0, 0.8) });
					y -= 30;

					page.drawText("Tipo", { x: 50, y, size: 12, font });
					page.drawText("Periodo", { x: 200, y, size: 12, font });
					page.drawText("Cantidad", { x: 300, y, size: 12, font });
					page.drawText("Año", { x: 400, y, size: 12, font });
					y -= 20;

					for (const row of data) {
						page.drawText(String(row["Tipo"]), { x: 50, y, size: 10, font });
						page.drawText(String(row["Periodo"]), { x: 200, y, size: 10, font });
						page.drawText(String(row["Cantidad"]), { x: 300, y, size: 10, font });
						page.drawText(String(row["Año"]), { x: 400, y, size: 10, font });
						y -= 15;
						if (y < 50){
							page = pdfDoc.addPage([750, 800]);
							y = 780;
							page.drawText("N° Empleado", { x: 50, y, size: 12, font });
							page.drawText("Cédula", { x: 150, y, size: 12, font });
							page.drawText("Horas trabajadas", { x: 250, y, size: 12, font });
							page.drawText("Periodo", { x: 400, y, size: 12, font });
							y -= 20;
						}; // Evita desbordar la página
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
					} catch (error) {
						console.error(error);
						return new Response("Error interno del servidor", {
							status: 500,
							headers: {
								"Access-Control-Allow-Origin": "*",
								"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
								"Access-Control-Allow-Headers": "Content-Type, Authorization",
								"Content-Type": "text/plain",
							},
						});
						
					}
					
				}
			},

			"/api/reportes/consolidar_horas/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async (req) => {
					try {
						// La url debe verse así /api/reportes/consolidar_horas/pdf?year=año&month=mes&trimonth=trimestre&modalidad=modalidad
					const url = new URL(req.url);
					const year = parseInt(url.searchParams.get("year") || "");
					const month = parseInt(url.searchParams.get("month") || "");
					const trimonth = parseInt(url.searchParams.get("trimonth") || "");
					const modalidad = url.searchParams.get("modalidad");

					// Valida que modalidad esté presente
					if (!modalidad) {
						return new Response("El parámetro 'modalidad' es requerido", { status: 400 });
					}

					const data = await sql`
					SELECT * FROM consolidar_horas(
						${isNaN(year) ? null : year}, 
						${isNaN(month) ? null : month}, 
						${isNaN(trimonth) ? null : trimonth}, 
						${modalidad}
					)
					`;

					const pdfDoc = await PDFDocument.create();
					let page = pdfDoc.addPage([780, 800]);
					const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

					let y = 750;

					page.drawText("ACAUCAB", { x: 50, y, size: 28, font, color: rgb(0, 0.2, 0.6) });
					y -= 40;

					page.drawText(`Reporte: Consolidar Horas (${modalidad})`, { x: 50, y, size: 16, font, color: rgb(0, 0, 0.8) });
					y -= 30;

					page.drawText("N° Empleado", { x: 50, y, size: 12, font });
					page.drawText("Cédula", { x: 150, y, size: 12, font });
					page.drawText("Horas trabajadas", { x: 250, y, size: 12, font });
					page.drawText("Periodo", { x: 400, y, size: 12, font });
					y -= 20;

					for (const row of data) {
						let fecha = String(row["Periodo"]);
						fecha = fecha.slice(3, 15);
						page.drawText(String(row["Numero de Empleado"]), { x: 50, y, size: 10, font });
						page.drawText(String(row["Cedula Empleado"]), { x: 150, y, size: 10, font });
						page.drawText(String(row["Horas trabajadas"]), { x: 250, y, size: 10, font });
						page.drawText(String(fecha), { x: 400, y, size: 10, font });
						y -= 15;
						if (y < 50){
							page = pdfDoc.addPage([780, 800]);
							y = 750;
							page.drawText("N° Empleado", { x: 50, y, size: 12, font });
							page.drawText("Cédula", { x: 150, y, size: 12, font });
							page.drawText("Horas trabajadas", { x: 250, y, size: 12, font });
							page.drawText("Periodo", { x: 400, y, size: 12, font });
							y -= 20;
						}; // Evita desbordar la página
					}

					const pdfBytes = await pdfDoc.save();

					return new Response(pdfBytes, {
					headers: {
						"Content-Type": "application/pdf",
						"Content-Disposition": `attachment; filename=consolidar_horas_${year ? year : ""}${month ? month : ""}${trimonth ? trimonth : ""}_${modalidad}.pdf`,
						"Access-Control-Allow-Origin": "*",
						"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
						"Access-Control-Allow-Headers": "Content-Type, Authorization",
					},
					});
					} catch (error) {
						console.error(error);
						return new Response("Error interno del servidor", {
							status: 500,
							headers: {
								"Access-Control-Allow-Origin": "*",
								"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
								"Access-Control-Allow-Headers": "Content-Type, Authorization",
								"Content-Type": "text/plain",
							},
						});
						
					}
					
				}
			},

			"/api/reportes/productos_reposicion/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async () => {
					try {
						// La url debe verse así /api/reportes/productos_reposicion/pdf
						const data = await sql`SELECT * FROM productos_generan_repo_view`;
						const pdfDoc = await PDFDocument.create();
						let page = pdfDoc.addPage([780, 800]);
						const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

						let y = 750;

						page.drawText("ACAUCAB", { x: 50, y, size: 28, font, color: rgb(0, 0.2, 0.6) });
						y -= 40;

						page.drawText(`Reporte: Productos que generaron Ordenes de Compra`, { x: 50, y, size: 16, font, color: rgb(0, 0, 0.8) });
						y -= 30;
						
						page.drawText("Código de Cerveza", { x: 50, y, size: 12, font });
						page.drawText("Nombre de la Cerveza", { x: 200, y, size: 12, font });
						page.drawText("Código de Presentación", { x: 350, y, size: 12, font });
						page.drawText("Nombre Presentación", { x: 500, y, size: 12, font });
						y -= 20;

						for (const row of data) {
							page.drawText(String(row["Código de Cerveza"]), { x: 50, y, size: 10, font });
							page.drawText(String(row["Nombre"]), { x: 200, y, size: 10, font });
							page.drawText(String(row["Código de Presentación"]), { x: 350, y, size: 10, font });
							page.drawText(String(row["Nombre Presentación"]), { x: 500, y, size: 10, font });
							y -= 15;
							if (y < 50){
								page = pdfDoc.addPage([780, 800]);
								y = 750;
								page.drawText("Código de Cerveza", { x: 50, y, size: 12, font });
								page.drawText("Nombre de la Cerveza", { x: 200, y, size: 12, font });
								page.drawText("Código de Presentación", { x: 350, y, size: 12, font });
								page.drawText("Nombre Presentación", { x: 500, y, size: 12, font });
								y -= 20;
							}; // Evita desbordar la página
						}
						const pdfBytes = await pdfDoc.save();

						return new Response(pdfBytes, {
						headers: {
							"Content-Type": "application/pdf",
							"Content-Disposition": "attachment; filename=productos_orden_compra.pdf",
							"Access-Control-Allow-Origin": "*",
							"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
							"Access-Control-Allow-Headers": "Content-Type, Authorization",
						},
						});
					} catch (error) {
						console.error(error);
						return new Response("Error interno del servidor", {
						status: 500,
						headers: {
							"Access-Control-Allow-Origin": "*",
							"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
							"Access-Control-Allow-Headers": "Content-Type, Authorization",
							"Content-Type": "text/plain",
						},
						});
					}
					
				}
			},

			"/api/reportes/rentabilidad_por_tipo/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async () => {
					try {
						// La url debe verse así /api/reportes/rentabilidad_por_tipo/pdfd
					const data = await sql`SELECT * FROM rentabilidad_tipo_view`;
					const pdfDoc = await PDFDocument.create();
					let page = pdfDoc.addPage([780, 800]);
					const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

					let y = 750;

					page.drawText("ACAUCAB", { x: 50, y, size: 28, font, color: rgb(0, 0.2, 0.6) });
					y -= 40;

					page.drawText(`Reporte: Rentabilidad por Tipo de Cerveza`, { x: 50, y, size: 16, font, color: rgb(0, 0, 0.8) });
					y -= 30;

					page.drawText("Tipo de Cerveza", { x: 50, y, size: 12, font });
					page.drawText("Nombre del Tipo", { x: 200, y, size: 12, font });
					page.drawText("Fecha de Venta", { x: 350, y, size: 12, font });
					page.drawText("Ganancia por venta($)", { x: 500, y, size: 12, font });
					y -= 20;

					for (const row of data) {
						let fecha = String(row["Fecha de Venta"]);
						fecha = fecha.slice(3, 15);
						page.drawText(String(row["Código Tipo"]), { x: 50, y, size: 10, font });
						page.drawText(String(row["Nombre Tipo de Cerveza"]), { x: 200, y, size: 10, font });
						page.drawText(String(fecha), { x: 350, y, size: 10, font });
						page.drawText(String(row["Ganancia total entre todas las Ventas"]), { x: 500, y, size: 10, font });
						// Agrega más columnas si tu vista tiene más datos
						y -= 15;
						if (y < 50){
							page = pdfDoc.addPage([780, 800]);
							y = 750;
							page.drawText("Tipo de Cerveza", { x: 50, y, size: 12, font });
							page.drawText("Rentabilidad", { x: 250, y, size: 12, font });
							page.drawText("Fecha de Venta", { x: 350, y, size: 12, font });
							page.drawText("Ganancia por venta", { x: 500, y, size: 12, font });
							y -= 20;
						}
					}

					const data2 = await sql`SELECT * FROM rentabilidad_tipo_total_view`;
					page = pdfDoc.addPage([780, 800]);
					y = 750;
					page.drawText("ACAUCAB", { x: 50, y, size: 28, font, color: rgb(0, 0.2, 0.6) });
					y -= 40;
					page.drawText(`Reporte: Rentabilidad Total por Tipo de Cerveza`, { x: 50, y, size: 16, font, color: rgb(0, 0, 0.8) });
					y -= 30;

					page.drawText("Tipo de Cerveza", { x: 50, y, size: 12, font });
					page.drawText("Nombre del Tipo", { x: 200, y, size: 12, font });
					page.drawText("Ganancia por venta($)", { x: 350, y, size: 12, font });
					y -= 20;

					for (const row of data2) {
						page.drawText(String(row["Código Tipo"]), { x: 50, y, size: 10, font });
						page.drawText(String(row["Nombre Tipo de Cerveza"]), { x: 200, y, size: 10, font });
						page.drawText(String(row["Ganancia total entre todas las Ventas"]), { x: 350, y, size: 10, font });
						// Agrega más columnas si tu vista tiene más datos
						y -= 15;
						if (y < 50){
							page = pdfDoc.addPage([780, 800]);
							y = 750;
							page.drawText("Tipo de Cerveza", { x: 50, y, size: 12, font });
							page.drawText("Nombre del Tipo", { x: 200, y, size: 12, font });
							page.drawText("Ganancia por venta($)", { x: 350, y, size: 12, font });
							y -= 20;
						}
					}

					const pdfBytes = await pdfDoc.save();

					return new Response(pdfBytes, {
						headers: {
							"Content-Type": "application/pdf",
							"Content-Disposition": "attachment; filename=rentabilidad_tipo.pdf",
							"Access-Control-Allow-Origin": "*",
							"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
							"Access-Control-Allow-Headers": "Content-Type, Authorization",
						},
					});
					} catch (error) {
						console.error(error);
						return new Response("Error interno del servidor", {
						status: 500,
						headers: {
							"Access-Control-Allow-Origin": "*",
							"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
							"Access-Control-Allow-Headers": "Content-Type, Authorization",
							"Content-Type": "text/plain",
						},
						});
					}
					
				}
			},

			"/api/reportes/proporcion_tarjetas/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async () => {
					try {
						// La url debe verse así /api/reportes/proporcion_tarjetas/pdf
					const data = await sql`SELECT * FROM proporcion_tarjetas_view`;
					const pdfDoc = await PDFDocument.create();
					let page = pdfDoc.addPage([780, 800]);
					const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

					let y = 750;

					page.drawText("ACAUCAB", { x: 50, y, size: 28, font, color: rgb(0, 0.2, 0.6) });
					y -= 40;

					page.drawText(`Reporte: Proporción de Tarjetas`, { x: 50, y, size: 16, font, color: rgb(0, 0, 0.8) });
					y -= 30;

					page.drawText("Es Tarjeta de Crédito", { x: 50, y, size: 12, font });
					page.drawText("Cantidad", { x: 250, y, size: 12, font });
					y -= 20;

					for (const row of data) {
						let booleanValue = row["Es de Crédito"] == 1 ? "Sí" : "No"; // Permite saber si es crédito o no
						page.drawText(booleanValue, { x: 50, y, size: 10, font });
						page.drawText(String(row["count"]), { x: 250, y, size: 10, font });
						y -= 15;
						if (y < 50){
							page = pdfDoc.addPage([780, 800]);
							y = 750;
							page.drawText("Es Tarjeta de Crédito", { x: 50, y, size: 12, font });
							page.drawText("Cantidad", { x: 250, y, size: 12, font });
							y -= 20;
						}
					}
					const pdfBytes = await pdfDoc.save();

					return new Response(pdfBytes, {
						headers: {
							"Content-Type": "application/pdf",
							"Content-Disposition": "attachment; filename=proporcion_tarjetas.pdf",
							"Access-Control-Allow-Origin": "*",
							"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
							"Access-Control-Allow-Headers": "Content-Type, Authorization",
						},
					});
					} catch (error) {
						console.error(error);
						return new Response("Error interno del servidor", {
						status: 500,
						headers: {
							"Access-Control-Allow-Origin": "*",
							"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
							"Access-Control-Allow-Headers": "Content-Type, Authorization",
							"Content-Type": "text/plain",
						},
						});
					}
				}
			},

			"/api/reportes/orden_compra/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async (req) => {
					try {
						// Obtener parámetros de la URL
						const url = new URL(req.url);
						const producto = url.searchParams.get("producto");
						const fecha = url.searchParams.get("fecha");
						const cantidad = url.searchParams.get("cantidad");
						const precio_total = url.searchParams.get("precio_total");
						const miembro = url.searchParams.get("miembro");
						if (!producto || !fecha || !cantidad || !precio_total || !miembro) {
							return new Response("Faltan parámetros requeridos", { status: 400 });
						}

						// Normalizar la fecha a formato yyyy-mm-dd
						function toSQLDate(fechaStr: string): string {
						    // Si ya está en formato yyyy-mm-dd, la devolvemos igual
						    if (/^\d{4}-\d{2}-\d{2}$/.test(fechaStr)) return fechaStr;
						    // Si está en formato dd/mm/yyyy, la convertimos
						    const match = fechaStr.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
						    if (match) {
						        const [, dd, mm, yyyy] = match;
						        return `${yyyy}-${mm}-${dd}`;
						    }
						    // Si no, la devolvemos igual (puede fallar la consulta, pero es lo más seguro)
						    return fechaStr;
						}
						const fechaSQL = toSQLDate(fecha);

						// Buscar datos del proveedor (miembro)
						const proveedor = (await sql`
							SELECT razon_social_miem, rif_miem, direccion_fiscal_miem
							FROM Miembro
							WHERE denom_comercial_miem = ${miembro}
							LIMIT 1
						`)[0];
						if (!proveedor) {
							return new Response("Proveedor no encontrado", { status: 404 });
						}
						// Eliminar la consulta y uso de teléfono del proveedor

						// Buscar datos del producto
						const prod = (await sql`
							SELECT c.cod_cerv, c.nombre_cerv
							FROM Cerveza c
							WHERE c.nombre_cerv = ${producto}
							LIMIT 1
						`)[0];
						if (!prod) {
							return new Response("Producto no encontrado", { status: 404 });
						}

						// Buscar el código de la orden de compra usando fechaSQL
						const orden = (await sql`
							SELECT c.cod_comp
							FROM Compra c
							JOIN Detalle_Compra dc ON dc.fk_comp = c.cod_comp
							JOIN CERV_PRES cp ON cp.fk_cerv = dc.fk_cerv_pres_1 AND cp.fk_miem = c.fk_miem
							WHERE c.fecha_comp = ${fechaSQL}
								AND c.fk_miem = ${proveedor.rif_miem}
								AND dc.fk_cerv_pres_1 = ${prod.cod_cerv}
							LIMIT 1
						`)[0];
						const cod_comp = orden ? orden.cod_comp : 'N/A';

						// Formatear la fecha a dd/mm/yyyy
						function toDisplayDate(fechaStr: string) {
						  // Si la fecha ya está en formato dd/mm/yyyy, la devolvemos igual
						  if (/^\d{2}\/\d{2}\/\d{4}$/.test(fechaStr)) return fechaStr;
						  
						  const d = new Date(fechaStr);
						  if (!isNaN(d.getTime())) {
						    const day = String(d.getDate()).padStart(2, '0');
						    const month = String(d.getMonth() + 1).padStart(2, '0');
						    const year = d.getFullYear();
						    return `${day}/${month}/${year}`;
						  }
						  // Si no es una fecha válida, devolver como está
						  return fechaStr;
						}
						const fechaDisplay = toDisplayDate(fechaSQL);

						// Buscar el nombre del jefe de compras (primer usuario con rol 'Empleado Compras' y empleado asociado)
						const jefeCompras = (await sql`
							SELECT e.primer_nom_empl, e.segundo_nom_empl, e.primer_ape_empl, e.segundo_ape_empl
							FROM Usuario u
							JOIN Rol r ON u.fk_rol = r.cod_rol
							JOIN Empleado e ON u.fk_empl = e.cod_empl
							WHERE r.nombre_rol = 'Empleado Compras'
							LIMIT 1
						`)[0];
						let nombreJefeCompras = 'Empleado Compras';
						if (jefeCompras) {
						  nombreJefeCompras = [jefeCompras.primer_nom_empl, jefeCompras.segundo_nom_empl, jefeCompras.primer_ape_empl, jefeCompras.segundo_ape_empl]
						    .filter(Boolean).join(' ');
						}

						// Datos del cliente (ACAUCAB, fijo)
						const cliente = {
							razon_social: "ACAUCAB",
							rif: "J-12345678-9",
							direccion: "Av. Universidad, Caracas, Venezuela",
							telefono: "+58 212-555-1234"
						};

						// Calcular precio unitario
						const precioUnitario = (parseFloat(precio_total) / parseFloat(cantidad)).toFixed(2);

						// Crear PDF
						const pdfDoc = await PDFDocument.create();
						let page = pdfDoc.addPage([780, 900]);
						const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
						let y = 850;

						// Título
						page.drawText("ACAUCAB", { x: 600, y, size: 32, font, color: rgb(0, 0.2, 0.6) });
						y -= 50;
						page.drawText("Propuesta de Orden de Compra", { x: 50, y, size: 16, font });
						y -= 30;
						page.drawText(`Orden de Compra Número: ${cod_comp}` , { x: 50, y, size: 12, font });
						y -= 20;
						page.drawText(`Fecha: ${fechaDisplay}` , { x: 50, y, size: 12, font });
						y -= 30;

						// Datos del proveedor y cliente (tabla)
						page.drawText("Datos del Proveedor", { x: 50, y, size: 12, font });
						page.drawText("Datos del Cliente", { x: 400, y, size: 12, font });
						y -= 18;
						// Proveedor
						page.drawText(`Razón Social: ${proveedor.razon_social_miem}`, { x: 50, y, size: 11, font });
						page.drawText(`Razón Social: ${cliente.razon_social}`, { x: 400, y, size: 11, font });
						y -= 15;
						page.drawText(`RIF/CI: ${proveedor.rif_miem}`, { x: 50, y, size: 11, font });
						page.drawText(`RIF/CI: ${cliente.rif}`, { x: 400, y, size: 11, font });
						y -= 15;
						page.drawText(`Dirección: ${proveedor.direccion_fiscal_miem}`, { x: 50, y, size: 11, font });
						page.drawText(`Dirección: ${cliente.direccion}`, { x: 400, y, size: 11, font });
						y -= 15;
						// Quitar línea de teléfono del proveedor
						y -= 30;

						// Asunto
						page.drawText("Departamento de Compras ACAUCAB", { x: 50, y, size: 12, font });
						y -= 18;
						page.drawText("Asunto: Este es un mensaje automáticamente enviado por el sistema de ACAUCAB debido a que el producto de nombre " + producto + " cuenta con menos de 100 unidades disponibles para la venta.", { x: 50, y, size: 11, font, maxWidth: 680 });
						y -= 40;

						// Productos solicitados
						page.drawText("1. Producto(s) solicitado(s):", { x: 50, y, size: 12, font });
						y -= 15;
						page.drawText(`   - Nombre: ${prod.nombre_cerv}`, { x: 70, y, size: 11, font });
						y -= 13;
						page.drawText(`   - Código del Producto: ${prod.cod_cerv}`, { x: 70, y, size: 11, font });
						y -= 20;
						page.drawText("2. Cantidad Requerida:", { x: 50, y, size: 12, font });
						y -= 15;
						page.drawText(`   - Cantidad: ${cantidad}`, { x: 70, y, size: 11, font });
						y -= 13;
						page.drawText(`   - Unidad de Medida: unidades`, { x: 70, y, size: 11, font });
						y -= 20;
						page.drawText("3. Precio Unitario:", { x: 50, y, size: 12, font });
						y -= 15;
						page.drawText(`   - Precio por Unidad: $${precioUnitario}`, { x: 70, y, size: 11, font });
						y -= 13;
						page.drawText(`   - Total Estimado: $${parseFloat(precio_total).toFixed(2)}`, { x: 70, y, size: 11, font });
						y -= 30;
						// Quitar Observaciones Adicionales
						// Agregar autorizado por
						page.drawText(`Autorizado por: ${nombreJefeCompras}`, { x: 50, y, size: 12, font });

						const pdfBytes = await pdfDoc.save();
						return new Response(pdfBytes, {
							headers: {
								"Content-Type": "application/pdf",
								"Content-Disposition": `attachment; filename=orden_compra_${cod_comp}.pdf`,
								"Access-Control-Allow-Origin": "*",
								"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
								"Access-Control-Allow-Headers": "Content-Type, Authorization",
							},
						});
					} catch (error) {
						console.error(error);
						return new Response("Error interno del servidor", {
							status: 500,
							headers: {
								"Access-Control-Allow-Origin": "*",
								"Access-Control-Allow-Methods": "GET,POST,OPTIONS,DELETE,PUT",
								"Access-Control-Allow-Headers": "Content-Type, Authorization",
								"Content-Type": "text/plain",
							},
						});
					}
				}
			}
		}
	}

export default new ReportService();