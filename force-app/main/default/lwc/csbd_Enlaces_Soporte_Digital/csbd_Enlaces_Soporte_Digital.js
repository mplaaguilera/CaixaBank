import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';

import getEnlaces from '@salesforce/apex/CSBD_Enlaces_Soporte_Digital_Controller.getEnlaces';

import OPP_PRODUCTO from '@salesforce/schema/Opportunity.CSBD_Producto__c';
import OPP_NOW_ORIGEN from '@salesforce/schema/Opportunity.CSBD_Now_Origen__c';

//eslint-disable-next-line camelcase, new-cap
export default class csbd_Enlaces_Soporte_Digital extends LightningElement {

	@api recordId;

	cardAbierta = true;

	enlaces;

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_PRODUCTO, OPP_NOW_ORIGEN]})
	wiredRecord({error, data}) {
		if (data && getFieldValue(data, OPP_PRODUCTO)) {
			getEnlaces({nombreProducto: getFieldValue(data, OPP_PRODUCTO), origen: getFieldValue(data, OPP_NOW_ORIGEN)})
				.then(enlaces => {
					if (enlaces) {
						this.enlaces = enlaces.map(enlace => ({...enlace, warning: enlace.label === 'Campañas'}));
						this.template.querySelector('.botonExpandirContraer').classList.remove('slds-hide');
					}
				}).catch(errorApex => console.error(errorApex));
		} else if (error) {
			console.error(error);
		}
	}

	enlaceOnclick({currentTarget: {dataset: {url}}}) {
		window.open(url.includes('://') ? url : 'https://' + url, '_blank');
	}

	abrirCerrarCard() {
		this.cardAbierta = !this.cardAbierta;
		const botonExpandirContraer = this.template.querySelector('.botonExpandirContraer');
		botonExpandirContraer.classList.toggle('expandido', this.cardAbierta);
		botonExpandirContraer.querySelector('lightning-button-icon').title = this.cardAbierta ? 'Cerrar' : 'Abrir';
	}
}