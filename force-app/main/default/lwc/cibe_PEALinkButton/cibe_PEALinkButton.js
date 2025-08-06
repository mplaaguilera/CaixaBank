import { LightningElement, api } from 'lwc';

import getObjectLink   from '@salesforce/apex/CIBE_LinkOperativoController.getOppLinkPEA';

//Labels 
import haHabidoUnProblema from '@salesforce/label/c.CIBE_HaHabidoUnProblema';
import enlaceInformativo from '@salesforce/label/c.CIBE_EnlaceInformativo';

export default class cibe_PEALinkButton extends LightningElement {

    labels = {
        haHabidoUnProblema,
        enlaceInformativo
    }

    @api recordId;
    @api objectApiName;
    @api typeOfPea;
    url;
    label;

    connectedCallback(){
        this.getLink();
    }

    getLink(){
        getObjectLink({id : this.recordId, objApiName: this.objectApiName, peaF: this.typeOfPea })
            .then(result => {
                let defaultLabel = this.enlaceInformativo;
                this.url = result.url != null ? result.url : null;
                this.label = result.label != null ? result.label : defaultLabel;
                
            })
            .catch(error=>{
                this.label = this.haHabidoUnProblema;
                console.log(error);
            });
    }
}