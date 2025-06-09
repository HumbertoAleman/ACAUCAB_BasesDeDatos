import { expect, test } from "bun:test";
import type { Cliente, Natural, Juridico } from "../src/cliente";

const case_natural: Natural = {
	tipo_clie: "Natural",
	primer_nom_natu: "Humberto",
	segundo_nom_natu: "Florencio",
	primer_ape_natu: "Aleman",
	segundo_ape_natu: "Odreman",
	ci_natu: 30142718,
	rif: "30142718",
	direccion_fiscal_clie: "Mi casa",
	direccion_fisica_clie: "Por alla",
	fk_lugar_1: 0,
	fk_lugar_2: 0
}

test("Client GET", async () => {
	await fetch("http://127.0.0.1:3000/clientes/natural/", {
		method: "GET",
	}).then(res => {
		console.log(res)
	})
})


test("Client POST", async () => {
	await fetch("http://127.0.0.1:3000/clientes/natural/", {
		method: "POST",
		body: JSON.stringify(case_natural),
	}).then(res => {
		console.log(res)
	})
});
