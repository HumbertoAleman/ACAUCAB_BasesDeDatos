import { quickDelete } from "./src/delete";
import { quick_insert } from "./src/insert";

Bun.serve({
	routes: {
		"/": () => new Response(),
		"/insert": { POST: quick_insert, },
		"/delete": { DELETE: quickDelete, },
	}
})
