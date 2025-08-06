export const DATATABLE_COLUMNS = {
	oportunidad: [
		{label: 'Creación', fieldName: 'CreatedDate', type: 'date', initialWidth: 90, hideDefaultActions: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit'}},
		{label: 'Derecho', fieldName: '_url', type: 'url', initialWidth: 146, hideDefaultActions: true, tooltip: 'Ver derecho', typeAttributes: {
			label: {fieldName: 'Name'}}, cellAttributes: {iconName: 'custom:custom20'}},
		{label: 'Tipo', fieldName: '_tipo', wrapText: true},
		{label: 'Estado', fieldName: 'CC_Estado__c', initialWidth: 122, hideDefaultActions: true, cellAttributes: {
			class: {fieldName: '_estadoClass'}}},
		{label: 'Fecha de envío', fieldName: 'CC_FechaEnvioCierre__c', type: 'date', initialWidth: 118, hideDefaultActions: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit'}},
		{label: 'Documento', fieldName: 'CC_DocumentoCliente__c', initialWidth: 95, hideDefaultActions: true}
	],
	cliente: [
		{label: 'Creación', fieldName: 'CreatedDate', type: 'date', initialWidth: 90, hideDefaultActions: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit'}},
		{label: 'Derecho', fieldName: '_url', type: 'url', initialWidth: 146, hideDefaultActions: true, tooltip: 'Ver derecho', typeAttributes: {
			label: {fieldName: 'Name'}}, cellAttributes: {iconName: 'custom:custom20'}},
		{label: 'Tipo', fieldName: '_tipo', wrapText: true},
		{label: 'Oportunidad', fieldName: '_oportunidadUrl', type: 'url', initialWidth: 116, hideDefaultActions: true, tooltip: 'Ver oportunidad', typeAttributes: {
			label: {fieldName: '_oportunidadIdentificador'}}},
		{label: 'Estado', fieldName: 'CC_Estado__c', initialWidth: 122, hideDefaultActions: true, cellAttributes: {
			class: {fieldName: '_estadoClass'}}},
		{label: 'Fecha de envío', fieldName: 'CC_FechaEnvioCierre__c', type: 'date', initialWidth: 118, hideDefaultActions: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit'}},
		{label: 'Documento', fieldName: 'CC_DocumentoCliente__c', initialWidth: 95, hideDefaultActions: true}
	]
};