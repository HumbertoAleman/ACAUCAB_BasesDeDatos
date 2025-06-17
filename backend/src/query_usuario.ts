import { sql } from "bun";
import Logger from "./logger/logger.ts";
import type { StringIndexable } from "./types/StringIndexable.ts";

function add_type(arr: Array<StringIndexable>) {
	for (const el of arr) {
		if (el.fk_empl !== null) {
			el.type = "Empleado"
			continue;
		}
		if (el.fk_miem !== null) {
			el.type = "Miembro"
			continue;
		}
		if (el.fk_clie !== null) {
			el.type = "Cliente"
			continue;
		}
		el.type = "Unknown";
	}

	for (const el of arr) {
		delete el.fk_clie;
		delete el.fk_miem;
		delete el.fk_empl;
	}
}

export default async function getUsuario(_: Bun.BunRequest): Promise<Response> {
	try {
		Logger.debug(`Querying for all Users`);
		const res = await sql`SELECT cod_usua, username_usua, fk_empl, fk_miem, fk_clie FROM Usuario`;
		add_type(res);
		return Response.json(res);
	} catch (e: unknown) {
		let response: string = 'getRol() -> '
		if (typeof e === 'string')
			response += `An error has occurred: ${e}`
		else if (e instanceof Error)
			response += `An error has occurred: ${e.message}\n`
		Logger.error(response)
		return new Response(response, {
			status: 400,
			headers: {
				'Content-Type': 'text/plain',
			}
		})
	}
}
