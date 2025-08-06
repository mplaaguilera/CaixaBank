import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Spv_GestionEmails extends NavigationMixin(LightningElement) {

    @api usarComponente = false;
    @track isOpen = false;
    @track spinnerLoading = false;
    @track para = '';
    @track copia = '';
    @track copiaOculta = '';
    @track asunto = '';
    @track cuerpo = '';
    @track muestraModal = false;

    reescalado() {
        this.isOpen = !this.isOpen;
    }

    cambiaPara(event) {
        this.para = event.target.value;
    }

    cambiaCopia(event) {
        this.copia = event.target.value;
    }

    cambiaCopiaOculta(event) {
        this.copiaOculta = event.target.value;
    }

    cambiaAsunto(event) {
        this.asunto = event.target.value;
    }

    cambiaCuerpo(event) {
        this.cuerpo = event.target.value;
    }

    handleEnviar() {

        if(this.para != '' && this.para != undefined && this.para != null){
            this.muestraModal = true;
        }else{
            console.log('entro en el else');
            this.showToast('Precaución', 'Recuerde completar la dirección de correo.', 'warning');
        }       
    }

    cerrarModal() {
        this.muestraModal = false;
    }

    handleConfirmarEnvio() {

    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }
}