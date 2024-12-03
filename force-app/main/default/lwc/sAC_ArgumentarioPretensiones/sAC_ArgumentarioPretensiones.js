import { LightningElement, api, wire} from 'lwc';
import argumentarioPrete from '@salesforce/apex/SAC_LCMP_RedaccionPretension.argumentarioPrete';

export default class SAC_ArgumentarioPretensiones extends LightningElement {

    @api myVal;
    @api recordId;

    @wire(argumentarioPrete, { idCaso: '$recordId' }) 
    wiredResult({ data, error }) {
        if (data) {
            console.log('Entra carlos');
            this.myVal = data;
        } else if (error) {
       
            console.error(error);
        }
    }

}