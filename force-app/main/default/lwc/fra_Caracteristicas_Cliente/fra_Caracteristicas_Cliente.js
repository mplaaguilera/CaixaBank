import { LightningElement, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCaracteristicas from '@salesforce/apex/FRA_Caracteristica.conseguirCaracteristicaCuenta'

export default class Fra_Caracteristicas_Cliente extends LightningElement  {

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