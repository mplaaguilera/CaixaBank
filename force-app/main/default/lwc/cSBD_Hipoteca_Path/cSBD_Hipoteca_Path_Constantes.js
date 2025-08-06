const SUBETAPAS = {
	solicitud: [
		{label: 'Propuesta viable enviada', value: 'Propuesta viable enviada', title: 'Propuesta viable enviada'},
		{label: 'Opendesk enviado', value: 'Opendesk enviado', title: 'Opendesk enviado'},
		{label: 'Pendiente llamada', value: 'Pendiente llamada', title: 'Pendiente llamada'},
		{label: 'Pendiente OK cliente', value: 'Pendiente OK cliente', title: 'Pendiente OK cliente'},
		{label: 'Pendiente onboarding nacional', value: 'Pendiente onboarding nacional', title: 'Pendiente onboarding nacional'},
		{label: 'Pendiente firma SUA', value: 'Pendiente firma SUA', title: 'Pendiente firma SUA'}
	],

	solicitudInternacional: [
		{label: 'Propuesta viable enviada', value: 'Propuesta viable enviada', title: 'Propuesta viable enviada'},
		{label: 'Opendesk enviado', value: 'Opendesk enviado', title: 'Opendesk enviado'},
		{label: 'Pendiente llamada', value: 'Pendiente llamada', title: 'Pendiente llamada'},
		{label: 'Pendiente OK cliente', value: 'Pendiente OK cliente', title: 'Pendiente OK cliente'},
		{label: 'Pendiente onboarding nacional', value: 'Pendiente onboarding nacional', title: 'Pendiente onboarding nacional'},
		{label: 'Pendiente MAF/Checklist', value: 'Pendiente MAF/Checklist', title: 'Pendiente MAF/Checklist'},
		{label: 'Pendiente firma SUA', value: 'Pendiente firma SUA', title: 'Pendiente firma SUA'}
	],

	documentacion: [
		{label: 'Pendiente documentación', value: 'Pendiente documentación', title: 'Pendiente documentación'},
		{label: 'Pendiente nota simple', value: 'Pendiente nota simple', title: 'Pendiente nota simple'},
		{label: 'Pendiente CIRBE', value: 'Pendiente CIRBE', title: 'Pendiente CIRBE'},
		{label: 'Pendiente valija electrónica', value: 'Pendiente valija electrónica', title: 'Pendiente valija electrónica'}
	],

	estudioEconomico: [
		{label: 'Pendiente informe', value: 'Pendiente informe', title: 'Pendiente informe'},
		{label: 'Traslado aprobación tarifa', value: 'Traslado aprobación tarifa', title: 'Traslado aprobación tarifa'},
		{label: 'Traslado aprobación CARP', value: 'Traslado aprobación CARP', title: 'Traslado aprobación CARP'},
		{label: 'Aprobada pendiente tasación', value: 'Aprobada pendiente tasación', title: 'Aprobada pendiente tasación'},
		{label: 'Validación tasación homologada', value: 'Validación tasación homologada', title: 'Validación tasación homologada'},
		{label: 'Tasación en curso', value: 'Tasación en curso', title: 'Tasación en curso'},
		{label: 'Pendiente provisión de fondos', value: 'Pendiente provisión de fondos', title: 'Pendiente provisión de fondos'},
		{label: 'Aprobada pendiente FEIN', value: 'Aprobada pendiente FEIN', title: 'Aprobada pendiente FEIN'}
	],

	estudioEconomicoInternacional: [
		{label: 'Pendiente informe CCI', value: 'Pendiente informe CCI', title: 'Pendiente informe CCI'},
		{label: 'Pendiente nueva doc CCI', value: 'Pendiente nueva doc CCI', title: 'Pendiente nueva doc CCI'},
		{label: 'Traslado aprobación tarifa', value: 'Traslado aprobación tarifa', title: 'Traslado aprobación tarifa'},
		{label: 'Traslado aprobación CARP', value: 'Traslado aprobación CARP', title: 'Traslado aprobación CARP'},
		{label: 'Aprobada pendiente tasación', value: 'Aprobada pendiente tasación', title: 'Aprobada pendiente tasación'},
		{label: 'Pendiente onboarding internacional', value: 'Pendiente onboarding internacional', title: 'Pendiente onboarding internacional'},
		{label: 'Aprobada pendiente FEIN', value: 'Aprobada pendiente FEIN', title: 'Aprobada pendiente FEIN'}
	],

	firma: [
		{label: 'Aprobada pendiente fecha', value: 'Aprobada pendiente fecha', title: 'Aprobada pendiente fecha'},
		{label: 'Pendiente acta notarial', value: 'Pendiente acta notarial', title: 'Pendiente acta notarial'},
		{label: 'Aprobada pendiente escritura', value: 'Aprobada pendiente escritura', title: 'Aprobada pendiente escritura'}
	]
};

export function getSubetapas(etapa, internacional = false) {
	const relacion = [
		{value: 'Solicitud', claveEtapa: 'solicitud'},
		{value: 'Documentación', claveEtapa: 'documentacion'},
		{value: 'Estudio económico', claveEtapa: 'estudioEconomico'},
		{value: 'Firma', claveEtapa: 'firma'}
	];

	let claveEtapa = relacion.find(rel => rel.value === etapa).claveEtapa;
	let subetapas = SUBETAPAS[claveEtapa];

	if (internacional && etapa === 'Solicitud') {
		subetapas = SUBETAPAS.solicitudInternacional;
	} else if (internacional && etapa === 'Estudio económico') {
		subetapas = SUBETAPAS.estudioEconomicoInternacional;
	}

	return subetapas;
}

export function mensajeErrorGetRecord(error) {
	return error.body.message;
}