/*eslint-disable @lwc/lwc/no-async-await */
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export function errorApex(error, toastTitle) {
	console.error(error);

	let mensajeErrorToast;
	if (Array.isArray(error.body)) {
		mensajeErrorToast = error.body.map(e => e.message).join(', ');
	} else if (typeof error?.body?.message === 'string') {
		mensajeErrorToast = error.body.message;
	} else {
		mensajeErrorToast = JSON.stringify(error);
	}
	mostrarToast('error', toastTitle, mensajeErrorToast);
}

export function mensajeErrorExcepcion(error) {
	let mensajeError = '';
	if (error.body?.message) {
		mensajeError = error.body.message;
	}
	if (error.stack) {
		mensajeError += (mensajeError ? '\n\n' : '') + error.stack;
	}
	return mensajeError;
}

export function copiarAlPortapapeles(texto) {
	if (texto) {
		let hiddenElement = document.createElement('textarea');
		hiddenElement.value = texto;
		document.body.appendChild(hiddenElement);
		hiddenElement.select();
		document.execCommand('copy');
		document.body.removeChild(hiddenElement);
	}
}

/*
export function objetosIguales(obj1, obj2) {
	if (Object.prototype.toString.call(obj1) === Object.prototype.toString.call(obj2)) {
		if (Object.prototype.toString.call(obj1) === '[object Object]' || Object.prototype.toString.call(obj1) === '[object Array]') {
			if (Object.keys(obj1).length !== Object.keys(obj2).length) {
				return false;
			}
			return Object.keys(obj1).every(key => objetosIguales(obj1[key], obj2[key]));
		}
		return obj1 === obj2;
	}
	return false;
}
*/

export const TIPOS_BANNER = {
	offline: {
		iconName: 'utility:offline',
		texto: 'Sin subscripción al canal de eventos.',
		class: 'bannerEstadoSuscripcion slds-scoped-notification slds-media slds-media_center slds-scoped-notification_dark slds-var-m-bottom_large'
	},
	online: {
		iconName: 'utility:broadcast',
		texto: 'Suscrito al canal purecloud__ClientEvent__c.',
		class: 'bannerEstadoSuscripcion slds-scoped-notification slds-media slds-media_center slds-theme_success slds-var-m-bottom_large'
	},
	pendienteApex: {
		iconName: 'utility:apex',
		texto: 'Esperando la respuesta del método Apex...',
		class: 'bannerEstadoSuscripcion slds-scoped-notification slds-media slds-media_center pendienteApex slds-var-m-bottom_large'
	}
};

export const HISTORIAL_TIPOS = {
	'evento': {class: 'logEvento', mensajeCabeceraClass: 'logMensajeCabecera logMensajeCabeceraEvento slds-var-m-right_x-small', iconName: 'utility:anywhere_alert'},
	'info': {class: 'logInfo', mensajeCabeceraClass: 'logMensajeCabecera logMensajeCabeceraInfo slds-var-m-right_x-small', iconName: 'utility:info_alt'},
	'error': {class: 'logError', mensajeCabeceraClass: 'logMensajeCabecera logMensajeCabeceraError slds-var-m-right_x-small', iconName: 'utility:warning'},
	'Invocación Apex': {class: 'logApex', mensajeCabeceraClass: 'logMensajeCabecera logMensajeCabeceraApex slds-var-m-right_x-small', iconName: 'utility:apex'},
	'Respuesta Apex': {class: 'logRespuestaApex', mensajeCabeceraClass: 'logMensajeCabecera logMensajeCabeceraRespuestaApex slds-var-m-right_x-small', iconName: 'utility:apex'},
	'Custom attributes': {class: 'logCustomAttributes', mensajeCabeceraClass: 'logMensajeCabecera logMensajeCabeceraCustomAttributes slds-var-m-right_x-small', iconName: 'utility:list'},
	'API Purecloud': {class: 'logApiPurecloud', mensajeCabeceraClass: 'logMensajeCabecera logMensajeCabeceraApiPurecloud slds-var-m-right_x-small', iconName: 'utility:http'}
};

export function actualizarBotonesAtributos(subscription) {
	return ({
		suscribirVariant: subscription ? 'brand' : null,
		suscribirIconClass: subscription ? null : 'slds-icon-text-success',
		desuscribirVariant: subscription ? null : 'brand',
		desuscribirIconClass: subscription ? 'slds-icon-text-error' : null
	});
}

export async function resaltarBotonMetodoApex(nombreMetodoApex, scope) {
	const botonMetodoApex = scope.template.querySelector('.botonMetodoApex[data-nombre="' + nombreMetodoApex + '"]');
	if (!botonMetodoApex.classList.contains('botonMetodoApexBlink')) {
		scope.botonesMetodoApexOntransitionendBind[nombreMetodoApex] = botonMetodoApexOntransitionend.bind(scope, botonMetodoApex, nombreMetodoApex, scope);
		botonMetodoApex.addEventListener('animationend', scope.botonesMetodoApexOntransitionendBind[nombreMetodoApex]);
		botonMetodoApex.classList.add('botonMetodoApexBlink');
	}
}

function botonMetodoApexOntransitionend(botonMetodoApex, nombreMetodoApex, scope) {
	botonMetodoApex.removeEventListener('animationend', scope.botonesMetodoApexOntransitionendBind[nombreMetodoApex]);
	botonMetodoApex.classList.remove('botonMetodoApexBlink');
}

export function mostrarToast(variant, title, message) {
	dispatchEvent(new ShowToastEvent({variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000}));
}

export function copiarObjeto(objeto) {
	return JSON.parse(JSON.stringify(objeto));
}