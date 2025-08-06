import { LightningElement, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCaracteristicas from '@salesforce/apex/HDT_Caracteristicas_Controller.conseguirCaracteristicaCuenta'

export default class Hdt_caracteristicas_cliente extends LightningElement {

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