import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';

import getRecordTypes from '@salesforce/apex/SPV_Utils.obtenerRecordTypes';
import comprobarExpDuplicado from '@salesforce/apex/SPV_LCMP_CrearCaso.comprobarExpDuplicado';

import ENTIDADAFECTADA_FIELD from '@salesforce/schema/Case.SAC_Entidad_Afectada__c';


export default class Spv_CrearCaso extends LightningElement {

    @api idRecordType;
    @track rtReclamacion;
    @track spinnerLoading = false;
    @track expDuplicado = false;
    @track numExpediente = '';
    @track entAfectada = '';
    @track valoresPicklistEntidad = [];


    @wire(getRecordTypes)
    getRecordTypesResult(result){
        if(result.data){
            result.data.forEach(element => {
                if(element.DeveloperName == 'SPV_Reclamacion'){
                    this.rtReclamacion = element.Id;
                }
            });
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtReclamacion', fieldApiName: ENTIDADAFECTADA_FIELD })
    wiredPicklistMotivoDescarte({error, data}){
        if(data){
            this.valoresPicklistEntidad = data.values;
        }
    }

    handleOnSubmit(event) { 
        const camposValidados = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((valido, campoAValidar) => {
                campoAValidar.reportValidity();
                return valido && campoAValidar.checkValidity();
            }, true);
 
        if(camposValidados){
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
        } else {
            event.preventDefault();
        }
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