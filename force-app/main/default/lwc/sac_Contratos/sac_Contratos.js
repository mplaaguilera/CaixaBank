import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import obtenerContratos from '@salesforce/apex/SAC_Contratos_Controller.obtenerContratos';

export default class Sac_Contratos extends LightningElement {

    @api recordId;
    listContratos = [];
    showDetail= false;
    isShowModal = false;
    
    solicitarContratos() {
        obtenerContratos({
            idRegistro: this.recordId
        }).then(data => {
            console.log(data);
            this.listContratos = data.lstContratos;
            this.customerId = data.customerId;
            console.log(this.listContratos);
            //this.showTable = true;
            this.isShowModal = true;
        }).catch(error => {
            console.error(error);
			this.mostrarToast('error', 'Problema recuperando los contratos', JSON.stringify(error));
        });
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

    hideModalBox() {  
        this.isShowModal = false;
    }
}