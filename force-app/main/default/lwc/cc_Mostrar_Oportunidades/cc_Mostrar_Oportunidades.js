import {LightningElement, wire, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getOportunidades from '@salesforce/apex/CC_Mostrar_Oportunidades_Controller.getOportunidades';

export default class Cc_Mostrar_Oportunidades extends LightningElement {
    error;
    oportunidades = [];
    
    @api recordId;
    @wire(getOportunidades, {recordId: '$recordId'})
    wiredgetOportunidades({data, error}) {
        if (data) {
            this.oportunidades = data;
        } else if (error) {
            this.error = error;
        }
        console.log('VMLS data ' + data);
        console.log('VMLS error ' + error);
        console.log('VMLS data ' + JSON.stringify(data));
    }

    navigate(event) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: event.currentTarget.dataset.recordId,
				actionName: 'view'
			}
		});
	}
}