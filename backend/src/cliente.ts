interface Cliente {
	rif: String
	direccion_fiscal_clie: String
	direccion_fisica_clie: String
	fk_lugar_1: Number
	fk_lugar_2: Number
}

interface Natural extends Cliente {
	tipo_clie: "Natural"
	primer_nom_natu: String
	segundo_nom_natu: String | undefined
	primer_ape_natu: String
	segundo_ape_natu: String | undefined
	ci_natu: Number
}

interface Juridico extends Cliente {
	tipo_clie: "Juridico"
	razon_social_juri: String
	denom_comercial_juri: String
	capital: Number
	pag_web_juri: String | undefined
}

export type { Cliente, Natural, Juridico };
