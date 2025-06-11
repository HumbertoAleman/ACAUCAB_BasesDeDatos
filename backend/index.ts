import { quickDelete } from "./src/delete";
import { quickInsert } from "./src/insert";

Bun.serve({
	routes: {
		"/": () => new Response(),
		"/quick": {
			POST: quickInsert,
			DELETE: quickDelete,
		},
	}
})
