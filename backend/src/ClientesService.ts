import { sql } from "bun";
import { LogFunctionExecution } from "./logger/decorators";
import { CORS_HEADERS } from "../globals";

// Common properties for both types
interface BaseCliente {
    rif_clie: string;
    direccion_fiscal_clie: string;
    direccion_fisica_clie: string;
    fk_luga_1: number;
    fk_luga_2: number;
    tipo_clie: 'Natural' | 'Juridico';
    fecha_ingr_clie?: Date; // Optional, defaults to CURRENT_DATE
}

// Type for Natural client
interface NaturalCliente extends BaseCliente {
    tipo_clie: 'Natural';
    primer_nom_natu: string;
    segundo_nom_natu?: string; // Optional
    primer_ape_natu: string;
    segundo_ape_natu?: string; // Optional
    ci_natu: number;
    razon_social_juri?: never; // Not applicable
    denom_comercial_juri?: never; // Not applicable
    capital_juri?: never; // Not applicable
    pag_web_juri?: never; // Not applicable
}

// Type for Juridico client
interface JuridicoCliente extends BaseCliente {
    tipo_clie: 'Juridico';
    razon_social_juri: string;
    denom_comercial_juri: string;
    capital_juri: number; // Use numeric type
    pag_web_juri?: string; // Optional
    primer_nom_natu?: never; // Not applicable
    segundo_nom_natu?: never; // Not applicable
    primer_ape_natu?: never; // Not applicable
    segundo_ape_natu?: never; // Not applicable
    ci_natu?: never; // Not applicable
}

// Union type for Cliente
type Cliente = NaturalCliente | JuridicoCliente;

class ClientesService {
	@LogFunctionExecution
	async getAllClientes(): Promise<any[]> {
		return Promise.all([this.getClientesNaturales(), this.getClientesJuridicos()].flat())
	}

	@LogFunctionExecution
	async getClientesJuridicos(): Promise<any[]> {
		return sql`
			SELECT C.rif_clie, C.tipo_clie, C.primer_nom_natu, C.primer_ape_natu, C.direccion_fiscal_clie, C.direccion_fisica_clie, C.fk_luga_1, C.fk_luga_2, C.fecha_ingr_clie, SUM(COALESCE(PC.cant_puntos_acum, 0)) as "puntos_acumulados", COALESCE(STRING_AGG(CAST(T.cod_area_tele AS text)||'-'||CAST(T.num_tele AS text), ','), 'No Phone Number') AS "telefonos", COALESCE(STRING_AGG(CAST(Co.prefijo_corr AS text), ','), 'No Mail') AS "correos"
			FROM Cliente C
			FULL JOIN PUNT_CLIE PC ON C.rif_clie = PC.fk_clie
			FULL JOIN Telefono T ON C.rif_clie = T.fk_clie
			FULL JOIN Correo Co ON C.rif_clie = Co.fk_clie
			WHERE tipo_clie = 'Natural'
			GROUP BY C.rif_clie`;
	}

	@LogFunctionExecution
	async getClientesNaturales(): Promise<any[]> {
		return sql`
			SELECT C.rif_clie, C.tipo_clie, C.razon_social_juri, C.denom_comercial_juri, C.direccion_fiscal_clie, C.direccion_fisica_clie, C.fk_luga_1, C.fk_luga_2, C.fecha_ingr_clie, SUM(COALESCE(PC.cant_puntos_acum, 0)) as "puntos_acumulados", COALESCE(STRING_AGG(CAST(T.cod_area_tele AS text)||'-'||CAST(T.num_tele AS text), ','), 'No Phone Number') AS "telefonos", COALESCE(STRING_AGG(CAST(Co.prefijo_corr AS text), ','), 'No Mail') AS "correos"
			FROM Cliente C
			FULL JOIN PUNT_CLIE PC ON C.rif_clie = PC.fk_clie
			FULL JOIN Telefono T ON C.rif_clie = T.fk_clie
			FULL JOIN Correo Co ON C.rif_clie = Co.fk_clie
			WHERE tipo_clie = 'Juridico'
			GROUP BY C.rif_clie`;
	};

	routes = {
		"/api/clientes": {
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			GET: async () => {
				const res = await this.getAllClientes()
				return Response.json(res, CORS_HEADERS);
			},
		},

		"/api/natural": { 
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any) => {
				const body = await req.json();
				const cliente: NaturalCliente = { ...body, tipo_clie: "Natural" };
				delete cliente.telefonos;
				delete cliente.correos;

				const res = await sql`INSERT INTO Cliente ${sql(cliente)} RETURNING *`;

				for (const telf of body.telefonos)
					await sql`insert into telefono ${sql({ ...telf, fk_clie: res[0].rif_clie })}`
				for (const corr of body.correos)
					await sql`insert into correo ${sql({ ...corr, fk_clie: res[0].rif_clie })}`

				return Response.json(res, CORS_HEADERS)
			}
		},

		"/api/juridico": { 
			OPTIONS: () => new Response('Departed', CORS_HEADERS),
			POST: async (req: any) => {
				const body = await req.json();
				const cliente: JuridicoCliente = { ...body, tipo_clie: "Juridico" };
				delete cliente.telefonos;
				delete cliente.correos;


				const res = await sql`INSERT INTO Cliente ${sql(cliente)} RETURNING *`;

				for (const telf of body.telefonos)
					await sql`insert into telefono ${sql({ ...telf, fk_clie: res[0].rif_clie })}`
				for (const corr of body.correos)
					await sql`insert into correo ${sql({ ...corr, fk_clie: res[0].rif_clie })}`

				return Response.json(res, CORS_HEADERS)
			}
		}
	}
}

export default new ClientesService();
