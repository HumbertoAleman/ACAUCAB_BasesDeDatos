import { quickDelete } from "./src/delete";
import { quickInsert } from "./src/insert";
import getRol from "./src/query_rol";
import getUsuario from "./src/query_usuario";

Bun.serve({
	routes: {
		"/ping": () => new Response("pong"),
		"/quick": {
			POST: quickInsert,
			DELETE: quickDelete,
		},
		"/rol": { GET: getRol, },
		"/usuario": { GET: getUsuario, }
	}
})
