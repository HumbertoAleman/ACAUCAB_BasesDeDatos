import { sql } from "bun";
import Logger from "./logger/logger.ts";

export default async function getRol(req: Bun.BunRequest): Promise<Response> {
	try {
		Logger.debug(`Querying for all Roles`);
		const res = await sql`SELECT nombre_rol FROM Rol`;
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
