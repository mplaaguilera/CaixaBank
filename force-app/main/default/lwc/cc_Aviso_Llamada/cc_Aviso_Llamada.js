import { LightningElement, api, wire, track } from 'lwc';
import verificarSiTieneCasos from '@salesforce/apex/CC_Aviso_Llamada_Controller.verificarSiTieneCasos';
import CUENTA from '@salesforce/schema/CC_Llamada__c.CC_Cuenta__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
 
export default class Cc_Aviso_Llamada extends LightningElement {
    @api recordId;
    //api es para variables que me traigo del navegador, como el recodType
    @track tieneCasosAnteriores = false;
    //track para cosas que se vallan a actualizar tras cargar la pagina

    @wire(getRecord, { recordId: '$recordId', fields: [CUENTA] })
    wiredRecord({ error, data }) {
        if (error) {
            this.mostrarToast('error', 'Problema recuperando los datos la cuenta', JSON.stringify(error));
        } else if (data) {
            this.account = data;
            this.verificarSiTieneCasos();
        }
    }
    verificarSiTieneCasos(){
        verificarSiTieneCasos({
            idAccount: getFieldValue(this.account, CUENTA)
        })
        .then(response => {
            this.tieneCasosAnteriores = response;
        })
        .catch(error => {
            console.error(JSON.stringify(error));
            this.mostrarToast('error', 'Problema validando los datos la cuenta', error.body.message);
        });
    }

    mostrarToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({
			variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000
		}));
	}
}