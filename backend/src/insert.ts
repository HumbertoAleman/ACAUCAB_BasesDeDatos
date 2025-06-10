import { sql } from "bun";

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

async function quick_insert(req: Bun.BunRequest): Promise<Response> {
	const body: any = await req.json();

	let columns = "(";
	for (const col of sqlColumns(body.info))
		columns += col + ", "
	columns = columns.substring(0, columns.length - 2) + ")"

	let values = "(";
	for (const val of sqlValues(body.info))
		values += val + ", ";
	values = values.substring(0, values.length - 2) + ")"

	const sql_string = `INSERT INTO ${body.table} ${columns} VALUES ${values} RETURNING *;`;

	const res = await sql.unsafe(sql_string);
	return Response.json(res);
}

export { quick_insert };
