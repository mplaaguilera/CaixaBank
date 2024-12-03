import { LightningElement, track, api, wire } from 'lwc';

//Labels
import verFirma from '@salesforce/label/c.CIBE_VerFirma';

// Methods
import getUrl  from '@salesforce/apex/CIBE_OpportunityTFButton.getUrl';

export default class cibe_linkApoderados extends LightningElement {

    labels = {
        verFirma
    };
    @track label = 'Ver Firma';
    @track url = '';
   
    @api recordId;



    @wire(getUrl, { recordId: '$recordId' })
    getUrlTF({ error, data }){
        if(data){
            this.url = data;
            console.log('URL  _>' + data);
        } else if(error){
            console.log(error);
        }
    }
    
   
}