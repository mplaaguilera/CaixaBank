import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import comprobarExpDuplicado from '@salesforce/apex/SPV_LCMP_CrearCaso.comprobarExpDuplicado';

export default class Spv_CrearCaso extends LightningElement {

    @api idRecordType;
    @track spinnerLoading = false;
    @track expDuplicado = false;
    @track numExpediente = '';
    @track entAfectada = '';

    handleOnSubmit(event) {
        this.spinnerLoading = true;

        comprobarExpDuplicado({numeroExpediente: this.numExpediente, entidadAfectada: this.entAfectada}).then(result => {  
            this.spinnerLoading = false;

            if(result != null){
                //Coincide con reclamaciones con el mismo expediente y entidad afectada, notificamos al usuario que ya existe una reclamación con estas características
                this.expDuplicado = true;
                this.lanzarToast("Advertencia!", 'Ya existe una reclamación dada de alta con el expediente y entidad afectada informados. Por favor revisela ' + result + '.', "warning");
            }else{
                //No coincide con ningun expediente/entidad afectada existente, luego crearemos la nueva reclamación
                this.expDuplicado = false;
                event.preventDefault();
                this.spinnerLoading = true;
            }
        })
        .catch(error => {
            this.spinnerLoading = false;
            this.lanzarToast("Error", 'Error al crear la reclamación', "error");
        })
    }

    handleOnSuccess(event) {

        if(!this.expDuplicado){
            const recordId = event.detail.id;

            this.abrirTabNuevoCaso(recordId);

            this.lanzarToast("Éxito!", 'Se creó correctamente el caso ' + event.detail.fields.CaseNumber.value + '.', "success");

            this.spinnerLoading = false;
        }
    }

    abrirTabNuevoCaso(idReclamacion){
        let abrirTab = true; 
        const abrirTabChangeEvent = new CustomEvent("senddata", {
            detail: { abrirTab, idReclamacion }
        });

        // Fire the custom event
        this.dispatchEvent(abrirTabChangeEvent);
    }

    cerrarTabCrearCaso(){
        let cerrarTab = true; 
        const cerrarChangeEvent = new CustomEvent("senddata", {
            detail: { cerrarTab }
        });

        // Fire the custom event
        this.dispatchEvent(cerrarChangeEvent);
    }

    changeNumExpediente(event){
        this.numExpediente = event.target.value;
    }

    changeEntidadAfectada(event){
        this.entAfectada = event.target.value;
    }

    lanzarToast(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(event);
    }
}