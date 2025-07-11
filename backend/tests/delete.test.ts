import { expect, test } from "bun:test";
import type { StringIndexable } from "../src/types/StringIndexable";

const client: StringIndexable = {
	table: "Cliente",
	info: {
		tipo_clie: "Natural",
		primer_nom_natu: "Humberto",
		segundo_nom_natu: "Florencio",
		primer_ape_natu: "Aleman",
		segundo_ape_natu: "Odreman",
		ci_natu: 30142718,
		rif_clie: "30142718",
		direccion_fiscal_clie: "Mi casa",
		direccion_fisica_clie: "Por alla",
		fk_luga_1: 1,
		fk_luga_2: 1
	}
}

const delete_test: StringIndexable = {
	table: "Cliente",
	primaryKeyName: "rif_clie",
	primaryKey: "'30142718'",
}

test("Delete", async () => {
	// Insert Client
	await fetch("http://127.0.0.1:3000/quick", {
		method: "POST",
		body: JSON.stringify(client),
	}).catch(expect().fail)

	// Delete it
	await fetch("http://127.0.0.1:3000/quick", {
		method: "DELETE",
		body: JSON.stringify(delete_test),
	}).then(async res => {
		const r: any = JSON.parse(await res.text())[0]
		expect(r).toBeDefined()
		for (const val in r)
			expect(r[val] ?? undefined).toBe(client.info[val])
	}).catch(_ => {
		expect().fail()
	})
});
