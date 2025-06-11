import { sql } from "bun";

async function quickDelete(req: Bun.BunRequest): Promise<Response> {
	const body: any = await req.json();

	const table: string = body.table;
	const primaryKeyName: string = body.primaryKeyName
	const primaryKey: string = body.primaryKey;

	const sql_string = `DELETE FROM ${table} WHERE ${primaryKeyName} = ${primaryKey} RETURNING *`

	const res = await sql.unsafe(sql_string);
	return Response.json(res);
}

export { quickDelete };
