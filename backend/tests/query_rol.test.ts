import { expect, test } from "bun:test";

test("Insert", async () => {
	await fetch("http://127.0.0.1:3000/rol", {
		method: "GET",
	}).then(async res => {
		expect(res.status).toBe(200);
		const r = await res.json();
		expect(r).toBeArray()
	}).catch(_ => {
		expect().fail()
	})
});

