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
	fk_even: number | undefined
}

@AddOptionsMethod
class EventoService {
	@sqlProtection
	@LogFunctionExecution
	async getEventos() {
		const res = await sql`SELECT * FROM Evento WHERE fk_even IS NULL`;
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

	routes = {
		"/api/evento": {
			GET: async () => await this.getEventos(),
			POST: async (req: any) => await this.createEvento(await req.json())
		},

		"/api/evento/:id": {
			GET: async (req: any) => await this.getEvento(req.params.id),
			POST: async (req: any) => await this.createEvento({ ...(await req.json()), fk_even: req.params.id })
		}
	}
}

export default new EventoService();
