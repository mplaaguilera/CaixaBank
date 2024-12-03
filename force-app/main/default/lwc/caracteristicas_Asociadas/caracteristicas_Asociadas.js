import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getCaracteristicas from '@salesforce/apex/CC_Caracteristica.conseguirCaracteristica';

export default class caracteristicas_Asociadas extends NavigationMixin(LightningElement) {
	@api recordId;

	@wire(getCaracteristicas, {idCliente: '$recordId'}) ccaracteristics;

	navigateToCaracteristica(event) {
		let oId = event.target.dataset.key;

		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: oId,
				actionName: 'view'
			}
		});
	}
}