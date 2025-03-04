import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export function toast(variant, title, message) {
	dispatchEvent(new ShowToastEvent({variant, title, message, mode: 'dismissable', duration: 4000}));
}

export function formatExcepcion(error) {
	if (error.body) {
		if (error.body?.fieldErrors && Object.keys(error.body.fieldErrors).length > 0) {
			return Object.values(error.body.fieldErrors).flat().map(fieldError => fieldError.message).join('; ');
		} else if (error.body?.pageErrors?.length) {
			return error.body.pageErrors.map(pageError => pageError.message).join('; ');
		} else if (error.body.message) {
			return error.body.message;
		} else {
			return JSON.stringify(error.body);
		}
	} else if (error.message) {
		return error.message;
	} else if (Array.isArray(error) && error[0]?.message) {
		return error[0].message;
	} else {
		return String(error);
	}
}

export function errorApex(component, error, title, message) {
	console.error(error);
	message = message || formatExcepcion(error);
	if (component) {
		component.dispatchEvent(new ShowToastEvent({variant: 'error', title, message, mode: 'dismissable', duration: 4000}));
	}
	return message;
}

export function formatearIsoDate(isoDate) {
	if (!isoDate || isNaN(new Date(isoDate).getTime())) {
		return '';
	}
	const date = new Date(isoDate);
	const hours = date.getHours().toString().padStart(2, '0');
	const minutes = date.getMinutes().toString().padStart(2, '0');
	return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()} a las ${hours}:${minutes}`;
}

export function publicarEvento(scope, nombre, parametros) {
	scope.dispatchEvent(new CustomEvent(nombre, {detail: parametros}));
}

export async function copiarTextoAlPortapapeles(texto, mostrarError = true) {
	try {
		await navigator.clipboard.writeText(texto);
	} catch (error) {
		console.error(error);
		if (mostrarError) {
			toast('error', 'Problema copiando texto al portapapeles', error.message);
		}
	}
}