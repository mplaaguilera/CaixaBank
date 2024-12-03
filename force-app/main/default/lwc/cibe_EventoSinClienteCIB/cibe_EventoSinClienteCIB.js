import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import citaSinCli from '@salesforce/label/c.CIBE_Citasincliente';



export default class Cibe_EventoSinClienteCIB extends NavigationMixin (LightningElement) {

    labels = {
        citaSinCli
    }

    handleClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'CIBE_PlanificarCitaCIB'
            }
        });
    }
}