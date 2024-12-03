//import {LightningElement} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

//export default class csbdlwcUtils extends LightningElement {}

export async function errorApex(component, error, title, message) {
	console.error(error);

	if (!message) {
		if (error.body) {
			if (error.body?.fieldErrors?.length) {
				message = Object.values(error.body.fieldErrors).flat().map(fieldError => fieldError.message).join('; ');
			} else if (error.body?.pageErrors?.length) {
				message = error.body.pageErrors.map(pageError => pageError.message).join('; ');
			} else if (error.body.message) {
				message = error.body.message;
			} else {
				message = JSON.stringify(error.body);
			}
		} else if (error.message) {
			message = error.message;
		} else if (Array.isArray(error) && error[0]?.message) {
			message = error[0].message;
		} else {
			message = String(error);
		}
	}
	if (component) {
		component.dispatchEvent(new ShowToastEvent({variant: 'error', title, message, mode: 'dismissable', duration: 4000}));
	}
}

export function formatearIsoDate(isoDate) {
	const date = new Date(isoDate);
	const day = date.getDate();
	const month = date.getMonth() + 1;
	const year = date.getFullYear();
	const hours = date.getHours().toString().padStart(2, '0');
	const minutes = date.getMinutes().toString().padStart(2, '0');
	return `${day}/${month}/${year} a las ${hours}:${minutes}`;
}