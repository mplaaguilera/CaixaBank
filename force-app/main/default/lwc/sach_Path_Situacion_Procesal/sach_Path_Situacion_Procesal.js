import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';

import CASE_SITUACION_PROCESAL from '@salesforce/schema/Case.SACH_Situacion_Procesal__c';


//eslint-disable-next-line camelcase
export default class Sach_Path_Situacion_Procesal extends LightningElement {

	@api recordId;

	opciones = [
		{posicion: 1, nombre: 'Pre-demanda', clases: 'slds-path__item slds-is-incomplete'},
		{posicion: 2, nombre: 'Admitida a trámite', clases: 'slds-path__item slds-is-incomplete'},
		{posicion: 3, nombre: 'Señalamiento de subasta', clases: 'slds-path__item slds-is-incomplete'},
		{posicion: 4, nombre: 'Post-subasta', clases: 'slds-path__item slds-is-incomplete'}
	]

	renderedCallback() {
		document.body.style.setProperty('--lwc-colorBackgroundPathComplete', 'rgb(69, 198, 90');
		document.body.style.setProperty('--lwc-colorBackgroundPathActive', 'rgb(1, 68, 134)');
	}

	@wire(getRecord, {recordId: '$recordId', fields: [CASE_SITUACION_PROCESAL]})
	wiredRecord({error, data}) {
		if (error) {
			console.error(JSON.stringify(error));
		} else if (data) {
			let opcionSeleccionada = this.opciones.find(opcion => opcion.nombre === getFieldValue(data, CASE_SITUACION_PROCESAL));
			if (opcionSeleccionada) {
				let posicionSeleccionada = opcionSeleccionada.posicion;
				this.opciones.forEach(opcion => {
					if (opcion.posicion < posicionSeleccionada) {
						opcion.clases = 'slds-path__item slds-is-complete';
					} else if (opcion.posicion === posicionSeleccionada) {
						opcion.clases = 'slds-path__item slds-is-current slds-is-active';
					} else {
						opcion.clases = 'slds-path__item slds-is-incomplete';
					}
				});
				this.opciones = [...this.opciones];
			}
		}
	}
}