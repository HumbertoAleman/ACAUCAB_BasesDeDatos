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
				}
			},

			"/api/reportes/consolidar_horas/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async (req) => {
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
				}
			},

			"/api/reportes/productos_reposicion/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async () => {
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
						page.drawText(String(row["Código Cerveza"]), { x: 50, y, size: 10, font });
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
				}
			},

			"/api/reportes/rentabilidad_por_tipo/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async () => {
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
					page.drawText("Ganancia por venta", { x: 500, y, size: 12, font });
					y -= 20;

					for (const row of data) {
						page.drawText(String(row["Código Tipo"]), { x: 50, y, size: 10, font });
						page.drawText(String(row["Nombre Tipo de Cerveza"]), { x: 200, y, size: 10, font });
						page.drawText(String(row["Fecha de Venta"]), { x: 350, y, size: 12, font });
						page.drawText(String(row["Ganancia total entre todas las Ventas"]), { x: 500, y, size: 12, font });
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
				}
			},

			"/api/reportes/proporcion_tarjetas/pdf": {
				OPTIONS: () => new Response('Departed', CORS_HEADERS),
				GET: async () => {
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

					page.drawText("Es de Crédito", { x: 50, y, size: 12, font });
					page.drawText("Cantidad", { x: 250, y, size: 12, font });
					y -= 20;

					for (const row of data) {
						page.drawText(String(row["Es de Crédito"]), { x: 50, y, size: 10, font });
						page.drawText(String(row["count"]), { x: 250, y, size: 10, font });
						y -= 15;
						if (y < 50){
							page = pdfDoc.addPage([780, 800]);
							y = 750;
							page.drawText("Es de Crédito", { x: 50, y, size: 12, font });
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
				}
			}
		}
	}

export default new ReportService();