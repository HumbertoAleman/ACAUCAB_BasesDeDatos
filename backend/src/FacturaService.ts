import { sql } from "bun";
import PDFDocument from "pdf-lib/cjs/api/PDFDocument";
import { StandardFonts } from "pdf-lib/cjs/api/StandardFonts";
import { CORS_HEADERS } from "../globals";
import { rgb } from "pdf-lib/cjs/api/colors";

class FacturaService {
  routes = {
    "/api/factura/producto/pdf": {
      OPTIONS: () => new Response("Departed", CORS_HEADERS),
      GET: async (req) => {
        try {
          const url = new URL(req.url);
          const id_venta = url.searchParams.get("id_venta");
          if (!id_venta) {
            return new Response("Parámetro 'id_venta' requerido", { status: 400 });
          }
          const data = await sql`
            SELECT * FROM factura_venta_productos_view WHERE id_venta = ${id_venta}
          `;
          if (!data.length) {
            return new Response("Venta no encontrada", { status: 404 });
          }
          // Datos generales de la factura
          const factura = data[0];
          const pdfDoc = await PDFDocument.create();
          let page = pdfDoc.addPage([780, 900]);
          const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
          let y = 850;
          page.drawText("ACAUCAB - FACTURA DE VENTA", { x: 50, y, size: 22, font, color: rgb(0, 0.2, 0.6) });
          y -= 30;
          const fechaVenta = new Date(factura.fecha);
          const fechaStr = `${fechaVenta.getDate().toString().padStart(2, '0')}/${(fechaVenta.getMonth()+1).toString().padStart(2, '0')}/${fechaVenta.getFullYear()}`;
          const now = new Date();
          const horaActualStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
          page.drawText(`Fecha: ${fechaStr}  Hora: ${horaActualStr}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`N° Venta: ${factura.id_venta}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Cliente: ${factura.tipo_cliente === 'Natural' ? (factura.nombre_cliente + ' ' + (factura.apellido_cliente || '')) : factura.razon_social}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`RIF/Cédula: ${factura.rif_cliente || ''}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Correo: ${factura.correo_cliente || ''}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Dirección: ${factura.direccion_fiscal || ''}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Tienda: ${factura.nombre_tienda || ''}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Dirección Tienda: ${factura.direccion_tienda || ''}`, { x: 50, y, size: 12, font });
          y -= 30;
          page.drawText("Detalle de productos:", { x: 50, y, size: 14, font, color: rgb(0, 0, 0.8) });
          y -= 20;
          page.drawText("Producto", { x: 50, y, size: 12, font });
          page.drawText("Presentación", { x: 200, y, size: 12, font });
          page.drawText("Cantidad", { x: 350, y, size: 12, font });
          page.drawText("Precio Unit.", { x: 450, y, size: 12, font });
          page.drawText("Subtotal", { x: 550, y, size: 12, font });
          y -= 15;
          for (const row of data) {
            page.drawText(String(row.producto), { x: 50, y, size: 10, font });
            page.drawText(String(row.presentacion), { x: 200, y, size: 10, font });
            page.drawText(String(row.cantidad), { x: 350, y, size: 10, font });
            page.drawText(String(row.precio_unitario), { x: 450, y, size: 10, font });
            page.drawText(String(row.subtotal), { x: 550, y, size: 10, font });
            y -= 15;
            if (y < 50) {
              page = pdfDoc.addPage([780, 900]);
              y = 850;
            }
          }
          y -= 20;
          page.drawText(`Base Imponible: ${factura.base_imponible}`, { x: 450, y, size: 12, font });
          y -= 15;
          page.drawText(`IVA: ${factura.iva}`, { x: 450, y, size: 12, font });
          y -= 15;
          page.drawText(`TOTAL: ${factura.total}`, { x: 450, y, size: 14, font, color: rgb(0, 0.5, 0) });
          const pdfBytes = await pdfDoc.save();
          return new Response(pdfBytes, {
            headers: {
              "Content-Type": "application/pdf",
              "Content-Disposition": `attachment; filename=factura_venta_${factura.id_venta}.pdf`,
              ...CORS_HEADERS,
            },
          });
        } catch (error) {
          console.error(error);
          return new Response("Error interno del servidor", {
            status: 500,
            headers: {
              ...CORS_HEADERS,
              "Content-Type": "text/plain",
            },
          });
        }
      },
    },
    "/api/factura/entrada/pdf": {
      OPTIONS: () => new Response("Departed", CORS_HEADERS),
      GET: async (req) => {
        try {
          const url = new URL(req.url);
          const id_venta = url.searchParams.get("id_venta");
          if (!id_venta) {
            return new Response("Parámetro 'id_venta' requerido", { status: 400 });
          }
          const data = await sql`
            SELECT * FROM factura_venta_entradas_view WHERE id_venta = ${id_venta}
          `;
          if (!data.length) {
            return new Response("Venta no encontrada", { status: 404 });
          }
          const factura = data[0];
          const pdfDoc = await PDFDocument.create();
          let page = pdfDoc.addPage([780, 900]);
          const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
          let y = 850;
          page.drawText("ACAUCAB - FACTURA DE ENTRADAS", { x: 50, y, size: 22, font, color: rgb(0, 0.2, 0.6) });
          y -= 30;
          const fechaVenta2 = new Date(factura.fecha);
          const fechaStr2 = `${fechaVenta2.getDate().toString().padStart(2, '0')}/${(fechaVenta2.getMonth()+1).toString().padStart(2, '0')}/${fechaVenta2.getFullYear()}`;
          const now2 = new Date();
          const horaActualStr2 = `${now2.getHours().toString().padStart(2, '0')}:${now2.getMinutes().toString().padStart(2, '0')}`;
          page.drawText(`Fecha: ${fechaStr2}  Hora: ${horaActualStr2}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`N° Venta: ${factura.id_venta}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Cliente: ${factura.tipo_cliente === 'Natural' ? (factura.nombre_cliente + ' ' + (factura.apellido_cliente || '')) : factura.razon_social}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`RIF/Cédula: ${factura.rif_cliente || ''}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Correo: ${factura.correo_cliente || ''}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Dirección: ${factura.direccion_fiscal || ''}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Evento: ${factura.nombre_evento || ''}`, { x: 50, y, size: 12, font });
          y -= 20;
          page.drawText(`Dirección Evento: ${factura.direccion_evento || ''}`, { x: 50, y, size: 12, font });
          y -= 30;
          page.drawText("Detalle de entradas:", { x: 50, y, size: 14, font, color: rgb(0, 0, 0.8) });
          y -= 20;
          page.drawText("Cantidad", { x: 50, y, size: 12, font });
          page.drawText("Precio Unit.", { x: 200, y, size: 12, font });
          page.drawText("Subtotal", { x: 350, y, size: 12, font });
          y -= 15;
          for (const row of data) {
            page.drawText(String(row.cantidad), { x: 50, y, size: 10, font });
            page.drawText(String(row.precio_unitario), { x: 200, y, size: 10, font });
            page.drawText(String(row.subtotal), { x: 350, y, size: 10, font });
            y -= 15;
            if (y < 50) {
              page = pdfDoc.addPage([780, 900]);
              y = 850;
            }
          }
          y -= 20;
          page.drawText(`Base Imponible: ${factura.base_imponible}`, { x: 450, y, size: 12, font });
          y -= 15;
          page.drawText(`IVA: ${factura.iva}`, { x: 450, y, size: 12, font });
          y -= 15;
          page.drawText(`TOTAL: ${factura.total}`, { x: 450, y, size: 14, font, color: rgb(0, 0.5, 0) });
          const pdfBytes = await pdfDoc.save();
          return new Response(pdfBytes, {
            headers: {
              "Content-Type": "application/pdf",
              "Content-Disposition": `attachment; filename=factura_entrada_${factura.id_venta}.pdf`,
              ...CORS_HEADERS,
            },
          });
        } catch (error) {
          console.error(error);
          return new Response("Error interno del servidor", {
            status: 500,
            headers: {
              ...CORS_HEADERS,
              "Content-Type": "text/plain",
            },
          });
        }
      },
    },
  };
}

export default new FacturaService(); 