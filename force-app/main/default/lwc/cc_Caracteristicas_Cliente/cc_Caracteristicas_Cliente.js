import { LightningElement, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCaracteristicas from '@salesforce/apex/CC_Caracteristica.conseguirCaracteristicaCuenta'

export default class cc_Caracteristicas_Asociadas_Caso extends NavigationMixin(LightningElement) {
    @api recordId;
    @wire(getCaracteristicas,{idCaso: '$recordId'}) ccaracteristics;
    
    navigateToCaracteristica(event) {
        var oId = event.target.dataset.key;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: oId,
                actionName: 'view'
            }
        });
    }
}