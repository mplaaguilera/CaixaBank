import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getCaracteristicas from '@salesforce/apex/CC_Caracteristica.conseguirCaracteristicaCuenta';

//eslint-disable-next-line camelcase, new-cap
export default class cc_Caracteristicas_Asociadas_Caso extends NavigationMixin(LightningElement) {
	@api recordId;

	@wire(getCaracteristicas, {idCaso: '$recordId'}) ccaracteristics;

	navigateToCaracteristica(event) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {recordId: event.target.dataset.key, actionName: 'view'}
		});
	}
}