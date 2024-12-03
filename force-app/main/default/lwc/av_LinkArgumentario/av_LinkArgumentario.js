import { LightningElement,track, api} from 'lwc';

import getProductData 		        from '@salesforce/apex/AV_LinkArgumentario_Controller.getProductData';

export default class Av_LinkArgumentario extends LightningElement {

    @api recordId;
    @track isLoading = true;
    @track listData;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getProductData({ idOpp: this.recordId })
            .then(result => {
                this.isLoading = false;
                this.listData = result;
            })
            .catch(error => {
                console.error('Error obteniendo datos: ', error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Ocurrió un error al obtener los datos',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            });
    }
           

}