import { sql } from "bun";
import Logger from "./logger/logger";

function* sqlColumns(obj: Object) {
	for (const val of Object.keys(obj))
		yield String(val)
}

function* sqlValues(obj: Object) {
	for (const val of Object.values(obj)) {
		if (typeof (val) === "string")
			yield `'${val}'`
		else
			yield String(val)
	}
}

async function quickInsert(req: Bun.BunRequest): Promise<Response> {
	Logger.info(`Insert request incoming ${req.method}:${req.url}`)
	const body: any = await req.json();

	let columns = "(";
	for (const col of sqlColumns(body.info))
		columns += col + ", "
	columns = columns.substring(0, columns.length - 2) + ")"

	let values = "(";
	for (const val of sqlValues(body.info))
		values += val + ", ";
	values = values.substring(0, values.length - 2) + ")"

	try {
		const sqlString = `INSERT INTO ${body.table} ${columns} VALUES ${values} RETURNING *;`;
		Logger.debug(`Generated SQL String: ${sqlString}`)
		const res = await sql.unsafe(sqlString);
		return Response.json(res);
	} catch (e: unknown) {
		let response: string = 'quickInsert() -> '
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

export { quickInsert };
