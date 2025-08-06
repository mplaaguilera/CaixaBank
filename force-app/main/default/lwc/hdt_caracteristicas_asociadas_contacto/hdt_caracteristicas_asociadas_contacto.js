import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getCaracteristicas from '@salesforce/apex/HDT_Caracteristicas_Controller.conseguirCaracteristica';

export default class Hdt_caracteristicas_asociadas_contacto extends LightningElement {

    @api recordId;

	caracteristicas = [];

	@wire(getCaracteristicas, {idCliente: '$recordId'})
	wiredCaracteristicas(retorno) {
		if (retorno.data) {
			this.caracteristicas = retorno.data;
		}
	}

	navigateToCaracteristica(event) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {recordId: event.currentTarget.dataset.id, actionName: 'view'}
		});
	}
}