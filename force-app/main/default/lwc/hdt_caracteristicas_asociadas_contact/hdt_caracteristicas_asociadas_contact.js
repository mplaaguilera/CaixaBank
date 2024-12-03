import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getCaracteristicas from '@salesforce/apex/HDT_Caracteristicas_Controller.conseguirCaracteristica';

export default class Hdt_caracteristicas_asociadas_contact extends NavigationMixin(LightningElement) {
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