import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import obtenerDetalleContrato from '@salesforce/apex/SAC_Contratos_Controller.obtenerDetalleContrato';
import linkarContrato from '@salesforce/apex/SAC_Contratos_Controller.linkarContrato';


export default class sac_ContratoDetail extends LightningElement {

    @api con;
    @api recordId;
    @api customerId;
    showContratos = false;
    showDetail = false;
    description;	
	state;
	revDate;	
	openingDate;	
	isPotential;
	totalBalance;	
    contratos = [];

    toggleShowDetail() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
            obtenerDetalleContrato({
                numPerso: this.customerId,
                codProducto: this.con.codProduct
            }).then(data => {
                this.description = data.description;
                this.state = data.state;
                this.revDate = data.revDate;
                this.openingDate = data.openingDate;
                this.isPotential = data.isPotential;
                this.totalBalance = data.totalBalance;
                if(data.contratos != null && data.contratos.length > 0){
                    this.showContratos = true;
                    this.contratos = data.contratos;
                }else{
                    this.showContratos = false;
                }
                
                this.isShowModal = true;
            }).catch(error => {
                this.mostrarToast('error', 'Problema recuperando los contratos', JSON.stringify(error));
            });
        }
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

    handleLink(event) {

        linkarContrato({
            idRecord: this.recordId,
            tipo: this.con.nameProduct,
            numContrato: event.currentTarget.dataset.id,
            descripcion: event.currentTarget.dataset.description
        }).then(data => {
            this.mostrarToast('success', 'Producto creado.', 'El contrato ha sido relacionado correctamente con la pretensión.');
        }).catch(error => {
            this.mostrarToast('error', 'Problema relacionando el contrato con la pretensión.', JSON.stringify(error));
        });
    }

}