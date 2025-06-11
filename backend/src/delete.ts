import { sql } from "bun";
import Logger from "./logger/logger";

async function quickDelete(req: Bun.BunRequest): Promise<Response> {
	Logger.info(`Insert request incoming from ${req.url}`)
	const body: any = await req.json();

	const table: string = body.table;
	const primaryKeyName: string = body.primaryKeyName
	const primaryKey: string = body.primaryKey;

	try {
		const sqlString = `DELETE FROM ${table} WHERE ${primaryKeyName} = ${primaryKey} RETURNING *`
		Logger.debug(`Generated SQL String: ${sqlString}`)
		const res = await sql.unsafe(sqlString);
		Logger.debug(`SQL Query result: ${res}`)
		return Response.json(res);
	} catch (e: unknown) {
		let response: string = ''
		if (typeof e === 'string')
			response = `An error has occurred: ${e}`
		else if (e instanceof Error)
			response = `An error has occurred: ${e.message}`
		Logger.error(response)
		return new Response(response, {
			status: 400,
			headers: {
				'Content-Type': 'text/plain',
			}
		})
	}
}

export { quickDelete };
