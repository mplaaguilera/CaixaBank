import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

export const DATATABLE_COLUMNS = {
	datatableEnCurso: [
		{type: 'button-icon', fixedWidth: 55, hideDefaultActions: true, typeAttributes: {
			name: {fieldName: '_accionName'}, title: {fieldName: '_accionTitle'}, iconName: {fieldName: '_accionIconName'}, variant: 'border-filled', iconClass: {fieldName: '_accionIconClass'}}},
		{label: 'Fecha de creación', fieldName: 'CreatedDate', type: 'date', initialWidth: 150, hideDefaultActions: true, sortable: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit'}},
		{label: 'Nivel', fieldName: 'CC_Nivel__c', type: 'text', initialWidth: 110, hideDefaultActions: true},
		{label: 'Estado', fieldName: 'CC_Estado__c', type: 'text', initialWidth: 130, hideDefaultActions: true, cellAttributes: {
			class: {fieldName: '_estadoClass'}}},
		{label: 'Fecha de envío', fieldName: 'CC_Fecha_Envio__c', type: 'date', initialWidth: 133, hideDefaultActions: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit'}},
		{label: 'Fecha de validación', fieldName: 'CC_Fecha_Validacion__c', type: 'date', initialWidth: 150, hideDefaultActions: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit'}},
		{label: 'Resultado', fieldName: 'CC_Resultado_Validacion__c', initialWidth: 200, hideDefaultActions: true, cellAttributes: {
			class: {fieldName: '_resultadoClass'}}},
		{label: 'Error', fieldName: 'CC_Mensaje_Error__c', wrapText: true}
	],
	datatableHistorico: [
		{type: 'button-icon', fixedWidth: 55, hideDefaultActions: true, typeAttributes: {
			name: 'verOportunidad', title: {fieldName: '_accionTitle'}, iconName: {fieldName: '_accionIconName'}, variant: {fieldName: '_accionIconVariant'}}},
		{label: 'Fecha de creación', fieldName: 'CreatedDate', type: 'date', initialWidth: 150, hideDefaultActions: true, sortable: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit'}},
		{label: 'Nivel', fieldName: 'CC_Nivel__c', type: 'text', initialWidth: 110, hideDefaultActions: true},
		{label: 'Oportunidad', fieldName: '_oportunidadUrl', type: 'url', initialWidth: 120, hideDefaultActions: true, typeAttributes: {
			label: {fieldName: '_oportunidadIdentificador'}}},
		{label: 'Estado', fieldName: 'CC_Estado__c', type: 'text', initialWidth: 160, hideDefaultActions: true, cellAttributes: {
			class: {fieldName: '_estadoClass'}}},
		{label: 'Fecha de envío', fieldName: 'CC_Fecha_Envio__c', type: 'date', initialWidth: 133, hideDefaultActions: true, sortable: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit'}},
		{label: 'Fecha de validación', fieldName: 'CC_Fecha_Validacion__c', type: 'date', initialWidth: 150, hideDefaultActions: true, typeAttributes: {
			year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit'}},
		{label: 'Resultado', fieldName: 'CC_Resultado_Validacion__c', initialWidth: 200, hideDefaultActions: true, cellAttributes: {
			class: {fieldName: '_resultadoClass'}}},
		{label: 'Error', fieldName: 'CC_Mensaje_Error__c', wrapText: true}
	]
};

export const NAME_COLUMN = {
	label: 'Nombre', fieldName: '_autenticacionUrl', type: 'url', initialWidth: 113, hideDefaultActions: true, typeAttributes: {label: {fieldName: 'Name'}}
};

export function toast(variant, title, message) {
	dispatchEvent(new ShowToastEvent({variant, title, message, mode: 'dismissable', duration: 4000}));
}

export async function confirmarInicioAutenticacion(tipo) {
	return await LightningConfirm.open({
		variant: 'header',
		theme: tipo === 'Emergencia' ? 'warning' : 'alt-inverse',
		label: 'Iniciar autenticación de ' + tipo.toLowerCase(),
		message: '¿Quieres iniciar una nueva autenticación segura de ' + tipo.toLowerCase() + '?'
	});
}