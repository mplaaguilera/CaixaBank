import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getCaracteristicas from '@salesforce/apex/FRA_Caracteristica.conseguirCaracteristica';

export default class Fra_Caracteristicas_Contacto extends LightningElement {
    @api recordId;

	caracteristicas = [];

	@wire(getCaracteristicas, {idCliente: '$recordId'})
	wiredCaracteristicas(retorno) {
		if (retorno.data) {
			this.caracteristicas = retorno.data;
		}
	}

	navigateToCaracteristica(event) {
		console.log('Navigating to record: ', event.currentTarget.dataset.id); // Verifica el ID
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: event.currentTarget.dataset.id, 
				actionName: 'view'
			}
		});
	}
}