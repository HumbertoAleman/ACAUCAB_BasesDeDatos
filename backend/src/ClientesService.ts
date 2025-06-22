import { sql } from "bun";
import { LogFunctionExecution } from "./logger/decorators";

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

}

export default new ClientesService();
