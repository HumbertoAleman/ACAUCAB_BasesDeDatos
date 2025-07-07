import { sql } from "bun";
import { AddOptionsMethod, LogFunctionExecution, sqlProtection } from "./logger/decorators";
import { CORS_HEADERS } from "../globals";

type Evento = {
	cod_even: number,
	nombre_even: string,
	fecha_hora_ini_even: string
	fecha_hora_fin_even: string
	direccion_even: string
	capacidad_even: number
	descripcion_even: string
	precio_entrada_even: number
	cant_entradas_evento: number
	fk_tipo_even: number
	fk_luga: number
}

@AddOptionsMethod
class EventoService {
	@sqlProtection
	@LogFunctionExecution
	async getEventos() {
		const res = await sql`SELECT * FROM Evento`;
		return Response.json(res, CORS_HEADERS);
	}

	@sqlProtection
	@LogFunctionExecution
	async getEvento(id: number) {
		const res = await sql`SELECT * FROM Evento WHERE cod_even = ${id}`;
		return Response.json(res, CORS_HEADERS)
	}

	@sqlProtection
	@LogFunctionExecution
	async createEvento(evento: Evento) {
		const res = await sql`INSERT INTO Evento ${sql(evento)} RETURNING *`;
		return Response.json(res, CORS_HEADERS);
	}

	@sqlProtection
	@LogFunctionExecution
	async getJuecesEvento(id: number) {
		const res = await sql`
			SELECT J.* FROM Registro_Evento RE
			JOIN Juez J ON RE.fk_juez = J.cod_juez
			WHERE RE.fk_even = ${id}
		`;
		return Response.json(res, CORS_HEADERS);
	}

	@sqlProtection
	@LogFunctionExecution
	async addJuecesEvento(id: number, jueces: number[], fecha_hora_regi_even: string) {
		if (!Array.isArray(jueces) || jueces.length === 0) {
			return Response.json({ success: false, message: 'No se enviaron jueces.' }, CORS_HEADERS);
		}
		const inserts = [];
		for (const juezId of jueces) {
			inserts.push(sql`
				INSERT INTO Registro_Evento (fk_even, fk_juez, fecha_hora_regi_even)
				VALUES (${id}, ${juezId}, ${fecha_hora_regi_even})
				ON CONFLICT DO NOTHING
			`);
		}
		await Promise.all(inserts);
		return Response.json({ success: true }, CORS_HEADERS);
	}

	routes = {
		"/api/evento": {
			GET: async () => await this.getEventos(),
			POST: async (req: any) => await this.createEvento(await req.json())
		},

		"/api/evento/:id": {
			GET: async (req: any) => await this.getEvento(req.params.id)
		},

		"/api/evento/:id/jueces": {
			GET: async (req: any) => await this.getJuecesEvento(Number(req.params.id)),
			POST: async (req: any) => {
				const body = await req.json();
				return await this.addJuecesEvento(Number(req.params.id), body.jueces, body.fecha_hora_regi_even);
			}
		}
	}
}

export default new EventoService();
