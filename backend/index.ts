import { sql } from "bun"
import type { Cliente, Natural, Juridico } from "./src/cliente";


console.log("Started Backend on port 3000")

Bun.serve({
	routes: {
		"/": () => new Response(),
		"/clientes/natural": {
			GET: async () => {
				const naturales = await sql`SELECT * FROM Cliente WHERE tipo_clie = 'Natural';`
				return Response.json(JSON.stringify(naturales));
			},
			POST: async req => {
				const body: any = await req.json();

				let cliente: Cliente = {
					rif: body.rif,
					direccion_fiscal_clie: body.direccion_fiscal_clie,
					direccion_fisica_clie: body.direccion_fisica_clie,
					fk_lugar_1: body.fk_lugar_1,
					fk_lugar_2: body.fk_lugar_2
				};

				if (body.tipo_clie === "Natural") {
					cliente = { 
						primer_nom_natu: body.primer_nom_natu,
						segundo_nom_natu: body?.segundo_nom_natu,
						primer_ape_natu: body.primer_ape_natu,
						segundo_ape_natu: body?.segundo_ape_natu,
						ci_natu: body.ci_natu,

						...cliente 
					} as Natural;
				} else {
					cliente = { 
						capital: body.capital,
						denom_comercial_juri: body.denom_comercial_juri,
						razon_social_juri: body.razon_social_juri,
						pag_web_juri: body?.pag_web_juri,
						...cliente 
					} as Juridico;
				}

				await sql`INSERT INTO Cliente ${sql(cliente)}`;

				return new Response();
			}
		}
	}
})


/* TODO:
 * - Insert Client: Natural y Juridico
 *   - TODO: General:
	 *   - RIF: String(20)
	 *   - Direccion Fiscal: String
	 *   - Direccion Fisica: String
	 *   - Lugar_1: int
	 *   - Lugar_2: int
 *
 *   - TODO: Natural
	 *   - Primer nom: String(40)
	 *   - Segundo nom: String(40) | undefined
	 *   - Primer ape: String(40)
	 *   - Segundo ape: String(40) | undefined
	 *   - ci_natu: int
 *
 *   - TODO: Juridico
	*   - Razon social: String(40)
	*   - Denominacion Comercial: String(40)
	*   - Capital: String(40)
	*   - Pagina web: String | undefined
 *
 * - Insert Proveedor
 */
