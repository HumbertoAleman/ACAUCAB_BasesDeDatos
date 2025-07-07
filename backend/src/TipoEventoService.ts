import { sql } from "bun";
import { AddOptionsMethod, LogFunctionExecution, sqlProtection } from "./logger/decorators";
import { CORS_HEADERS } from "../globals";

export type TipoEvento = {
  cod_tipo_even?: number;
  nombre_tipo_even: string;
  fk_tipo_even?: number | null;
};

@AddOptionsMethod
class TipoEventoService {
  @sqlProtection
  @LogFunctionExecution
  async getTiposEvento() {
    const res = await sql`SELECT * FROM Tipo_Evento`;
    return Response.json(res, CORS_HEADERS);
  }

  @sqlProtection
  @LogFunctionExecution
  async createTipoEvento(tipoEvento: TipoEvento) {
    const res = await sql`INSERT INTO Tipo_Evento ${sql(tipoEvento)} RETURNING *`;
    return Response.json({ success: true, data: res }, CORS_HEADERS);
  }

  @sqlProtection
  @LogFunctionExecution
  async updateTipoEvento(id: number, data: Partial<TipoEvento>) {
    if (data.fk_tipo_even) {
      if (id === data.fk_tipo_even) {
        return Response.json({ success: false, error: 'Un tipo de evento no puede ser su propio padre.' }, CORS_HEADERS);
      }
      const hijos = await sql`SELECT cod_tipo_even FROM Tipo_Evento WHERE fk_tipo_even = ${id}`;
      if (hijos.length > 0) {
        return Response.json({ success: false, error: 'Un tipo de evento que es padre no puede ser asignado como hijo.' }, CORS_HEADERS);
      }
      let current = data.fk_tipo_even;
      while (current) {
        if (current === id) {
          return Response.json({ success: false, error: 'No se pueden crear ciclos en la jerarquía de tipos de evento.' }, CORS_HEADERS);
        }
        const next = await sql`SELECT fk_tipo_even FROM Tipo_Evento WHERE cod_tipo_even = ${current}`;
        current = next[0]?.fk_tipo_even ?? null;
      }
    }
    const res = await sql`UPDATE Tipo_Evento SET fk_tipo_even = ${data.fk_tipo_even} WHERE cod_tipo_even = ${id} RETURNING *`;
    return Response.json({ success: true, data: res }, CORS_HEADERS);
  }

  routes = {
    "/api/tipo_evento": {
      GET: async () => await this.getTiposEvento(),
      POST: async (req: any) => await this.createTipoEvento(await req.json())
    },
    "/api/tipo_evento/:id": {
      PUT: async (req: any) => await this.updateTipoEvento(Number(req.params.id), await req.json())
    }
  }
}

export default new TipoEventoService(); 