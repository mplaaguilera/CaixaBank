import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import showAllContracts from '@salesforce/apex/SAC_Contratos_Controller.showAllContracts';
import linkarContrato from '@salesforce/apex/SAC_Contratos_Controller.linkarContrato';

export default class Sac_Contratos extends LightningElement {

    @api recordId;
    @track listProducts = [];
    @track listContracts = [];
    @track nameProduct;
    @api isLoaded = false;
    @track showBackdrop = false;

    showDetail = false;
    showContratos = false;
    isShowModal = false;
    // idTimeouts = {};
    // mostarSpinner = false;
    // cargandoCasos = false;
    // get accionesDisabled() {
	// 	return this.cargandoCasos;
	// }

    
    
    solicitarContratos() {
        this.isLoaded = !this.isLoaded;
        this.showBackdrop = !this.showBackdrop;
        showAllContracts({
            idRegistro: this.recordId
        }).then(data => {
            this.listProducts = data.lstProducts;
            this.listProducts = data.lstProducts.map(product => ({
                 ...product,
                showDetail: false
             }));
             this.listProducts.forEach(product => {
                this.listContracts = product.lstContratos;
              });
             if(this.listContracts != null && this.listContracts.length > 0){
                this.showContratos = true;
             }else{
                this.showContratos = false;
             }
            this.nameProduct = this.listProducts.nameProduct;
            this.customerId = data.customerId;
            this.isShowModal = true;
            this.isLoaded = !this.isLoaded;
            this.showBackdrop = !this.showBackdrop;
        }).catch(error => {
            console.log('RSR -  error ' + error);
            console.log('RSR -  error ' + JSON.stringify(error));

            
			this.mostrarToast('error', 'Problema recuperando los contratos', JSON.stringify(error));
        });
    }

    mostrarDetalle(event) {
        this.listProducts = this.listProducts.map(product => {
            if (product.codProduct == event.currentTarget.dataset.id) {
                return { ...product, showDetail: !product.showDetail };
            }
            return product;
        });
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

    handleLink(event) {

        linkarContrato({
            idRecord: this.recordId,
            tipo: event.currentTarget.dataset.product,
            numContrato: event.currentTarget.dataset.id,
            descripcion: event.currentTarget.dataset.description,
            fechaApertura: event.currentTarget.dataset.apertura,
            fechaCancelacion: event.currentTarget.dataset.cancelacion
        }).then(data => {
            this.mostrarToast('success', 'Producto creado.', 'El contrato ha sido relacionado correctamente con la pretensión.');
        }).catch(error => {
            this.mostrarToast('error', 'Problema relacionando el contrato con la pretensión.', JSON.stringify(error));
        });
    }

    setCargandoCasos(mostrar) {
        window.clearTimeout(this.idTimeouts.cargandoCasosTrue);
		if (mostrar) {
			this.template.querySelector('.solicitarContratos').classList.add('disabled');
			this.cargandoCasos = true;
			this.mostarSpinner = true;
		} else {
			this.cargandoCasos = false;
			this.mostarSpinner = false;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.template.querySelector('.solicitarContratos').classList.remove('disabled'), 600, this);
		}
	}



    hideModalBox() {  
        this.isShowModal = false;
    }

    get cardClass() {
        return this.isLoaded ? 'opaque-card' : '';
      }
    
}