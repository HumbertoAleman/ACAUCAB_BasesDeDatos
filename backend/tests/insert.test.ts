import { expect, test } from "bun:test";

const case_natural = {
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

test("Insert", async () => {
	await fetch("http://127.0.0.1:3000/insert", {
		method: "POST",
		body: JSON.stringify(case_natural),
	}).then(async res => {
		const r = JSON.parse(await res.text())[0]
		for (const val in r)
			expect(r[val] ?? undefined).toBe(case_natural.info[val])
	})
});
