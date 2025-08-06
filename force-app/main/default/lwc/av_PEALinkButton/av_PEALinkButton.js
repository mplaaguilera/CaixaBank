import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getObjectLink   from '@salesforce/apex/AV_LinkOperativoController.getOppLinkPEA';
       
export default class Av_PEALinkButton extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    @api typeOfPea;
    url;
    label;

    navigateToWebPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: ''
            }
        }).then(url => {
            window.open(this.url, "_self");
        });
    }

    

    connectedCallback(){
        console.log('ID ' + this.objectApiName)
        console.log(this.typeOfPea)
 
        this.getLink();
        
       
        console.log(this.objectApiName);
    }

     

    getLink(){
        getObjectLink({id : this.recordId, objApiName: this.objectApiName, peaF: this.typeOfPea })
            .then(result => {
                let defaultLabel = 'Enlace informativo';
                this.url = result.url != null ? result.url : null;
                this.label = result.label != null ? result.label : defaultLabel;
                
            })
            .catch(error=>{
                this.label = 'Ha habido un problema';
                console.log(error);
            });
    }

}