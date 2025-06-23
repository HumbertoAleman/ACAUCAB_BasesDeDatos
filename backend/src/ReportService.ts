import { sql } from "bun";
import PDFDocument from "pdf-lib/cjs/api/PDFDocument";
import { StandardFonts } from "pdf-lib/cjs/api/StandardFonts";
import { CORS_HEADERS } from "../globals";
import { rgb } from "pdf-lib/cjs/api/colors";

class ReportService {
	routes = {
		"/api/reportes/periodo_tipo_cliente/pdf": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async (req: any) => {
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

				let y = 750;

				page.drawText("ACAUCAB", { x: 50, y, size: 28, font, color: rgb(0, 0.2, 0.6) });
				y -= 40;

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
}

export default new ReportService();
