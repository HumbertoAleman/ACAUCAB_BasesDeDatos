import { quickDelete } from "./src/delete";
import { quickInsert } from "./src/insert";

Bun.serve({
	routes: {
		"/": () => new Response(),
		"/insert": { POST: quickInsert, },
		"/delete": { DELETE: quickDelete, },
	}
})
