import {LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getLinksApex from '@salesforce/apex/SEG_Link_TF9_Controller.getLinks';
import insertarChatter from '@salesforce/apex/SEG_Link_TF9_Controller.insertarChatter';



//eslint-disable-next-line new-cap
export default class segLinkTf9 extends NavigationMixin(LightningElement) {
	@api recordId;

	@api objectApiName;

	@track listLinks;

	connectedCallback() {
		this.cargarLinks();
	}

	abrirEnlace(event) {

		this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {url: event.currentTarget.dataset.url}
		});
		insertarChatter({seccion: this.objectApiName, customerId: this.recordId, title: event.currentTarget.title, nif: event.currentTarget.dataset.nif, trazadoNif :event.currentTarget.dataset.trazadonif});

	}

	toast(tipo, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant: tipo, title, message}));
	}

	cargarLinks(){
		getLinksApex({seccion: this.objectApiName, customerId: this.recordId})
		.then(enlaces => {
			this.listLinks = enlaces;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los enlaces al termincal financiero', error.body.message);
		});
	}

}