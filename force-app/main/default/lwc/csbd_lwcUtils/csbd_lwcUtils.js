import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getUsuarioDesarrolladorApex from '@salesforce/apex/CSBD_LwcUtils_Apex.usuarioDesarrollador';

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

export function formatearIsoDate(isoDate, corto = true, hora = true) {

	if (!isoDate || isNaN(new Date(isoDate).getTime())) {
		return '';
	}
	const date = new Date(isoDate);
	const hours = date.getHours().toString().padStart(2, '0');
	const minutes = date.getMinutes().toString().padStart(2, '0');

	let fecha;
	if (corto) {
		fecha = `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}`;
	} else {
		const meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
		fecha = `${date.getDate()} de ${meses[date.getMonth()]} de ${date.getFullYear()}`;
	}
	if (hora) {
		fecha += ` a las ${hours}:${minutes}`;
	}
	return fecha;
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

export function esperar(callback, delay = 0) {
	return new Promise(resolve => setTimeout(resolve, delay))
	.then(() => typeof callback === 'function' && callback());
}

export function usuarioDesarrollador(idUsuario) {
	return getUsuarioDesarrolladorApex({idUsuario});
}

export function transitionThenCallback(element, className, callback, property) {
	if (element && className && element instanceof HTMLElement) {
		let called = false;
		let idTimeout;

		const callCallback = idTimeoutAux => {
			if (!called) {
				called = true;
				clearTimeout(idTimeoutAux);
				callback(element);
			}
		};

		const onTransitionEnd = ({propertyName}) => {
			if (!property || propertyName === property) {
				callCallback(idTimeout);
				element.removeEventListener('transitionend', onTransitionEnd);
			}
		};
		element.addEventListener('transitionend', onTransitionEnd);

		idTimeout = setTimeout(() => callCallback(idTimeout), 1000);
		element.classList.toggle(className);
	}
}