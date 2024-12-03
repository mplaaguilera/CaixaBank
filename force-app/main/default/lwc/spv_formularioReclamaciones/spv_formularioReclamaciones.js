import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import currentUserId from '@salesforce/user/Id';

//import fields
//Campos de Case
import CASEID from '@salesforce/schema/Case.Id';
import CASERT from '@salesforce/schema/Case.RecordTypeId';
import CASENUMBER from '@salesforce/schema/Case.CaseNumber';
import OWNERID from '@salesforce/schema/Case.OwnerId';
import STATUS from '@salesforce/schema/Case.Status';
import SUBESTADO from '@salesforce/schema/Case.SEG_Subestado__c';
import CASORELACIONADO from '@salesforce/schema/Case.CC_CasoRelacionado__c';
import GRUPOSAC from '@salesforce/schema/Case.CC_CasoRelacionado__r.SEG_Grupo__c';

// import methods
import getFormularioExistente from '@salesforce/apex/SPV_LCMP_FormularioReclamaciones.getFormularioExistente';
import getPretensionesReclamacion from '@salesforce/apex/SPV_LCMP_FormularioReclamaciones.getPretensionesReclamacion';
import notificarCambioFicha from '@salesforce/apex/SPV_LCMP_FormularioReclamaciones.notificarCambioFicha';

const FIELDS = [CASEID, CASERT, CASENUMBER, OWNERID, STATUS, SUBESTADO, CASORELACIONADO, GRUPOSAC];

export default class Spv_formularioReclamaciones extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track idFormularioCaso;
    @track estadoAlegaciones = false;
    @track estadoAllanamiento = false;
    @track substatus;
    @track caseNumber;
    @track casoSAC;
    @track camposReadOnly = false;
    @track notificado = false;
    @track tienePermisosEditar = false;
    @track mostrarDocumentacionNecesaria = false;
    @track spinnerLoading = false;
    @track pretensiones = [];

    @track toggleIconGeneral = "slds-section slds-is-open";
    @track bExpanseGeneral = true;

    @track toggleIconAntecentes = "slds-section slds-is-open";
    @track bExpanseAntecentes = true;

    @track toggleIconValoracion = "slds-section slds-is-open";
    @track bExpanseValoracion = true;

    @track toggleIconComprobaciones = "slds-section slds-is-open";
    @track bExpanseComprobaciones = true;

    @track toggleIconAlegaciones = "slds-section slds-is-open";
    @track bExpanseAlegaciones = true;

    @track toggleIconAllanamiento = "slds-section slds-is-open";
    @track bExpanseAllanamiento = true;

    @track toggleIconFondo = "slds-section slds-is-open";
    @track bExpanseFondo = true;

    @track toggleIconPropuesta = "slds-section slds-is-open";
    @track bExpansePropuesta = true;

    @track toggleIconResolucion = "slds-section slds-is-open";
    @track bExpanseResolucion = true;

    @track toggleIconObservaciones = "slds-section slds-is-open";
    @track bExpanseObservaciones = true;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({data, error}){
        if(data){
            this.substatus = data.fields.SEG_Subestado__c.value;
            this.casoSAC = data.fields.CC_CasoRelacionado__c.value;
            this.caseNumber = data.fields.CaseNumber.value;
            const ownerId = data.fields.OwnerId.value;
            this.estadoAllanamiento = false;
            this.estadoAlegaciones = false;
            if(this.substatus == 'Allanamiento') {
                this.estadoAllanamiento = true;
            } else if(this.substatus == 'Alegaciones') {
                this.estadoAlegaciones = true;
            }
            if(ownerId == currentUserId) {
                this.tienePermisosEditar = true;
            } else {
                this.camposReadOnly = true;
            }
            const grupoSAC = getFieldValue(data, GRUPOSAC);
        }
    }

    @wire(getFormularioExistente, { casoId: '$recordId'})
    getFormulario({ error, data }){
        if(data){
            this.idFormularioCaso = data;
        }
    }

    @wire(getPretensionesReclamacion, { casoId: '$recordId'})
    getPretensiones({ error, data }){
        if(data){
            this.pretensiones = data;
        }
    }

    handleExpandableGeneral() {
        if(this.bExpanseGeneral){
            this.bExpanseGeneral = false;
            this.toggleIconGeneral = "slds-section"; 
        } else {
            this.bExpanseGeneral = true;
            this.toggleIconGeneral = "slds-section slds-is-open";
        }
    }

    handleExpandableAntecentes() {
        if(this.bExpanseAntecentes){
            this.bExpanseAntecentes = false;
            this.toggleIconAntecentes = "slds-section"; 
        } else {
            this.bExpanseAntecentes = true;
            this.toggleIconAntecentes = "slds-section slds-is-open";
        }
    }

    handleExpandableValoracion() {
        if(this.bExpanseValoracion){
            this.bExpanseValoracion = false;
            this.toggleIconValoracion = "slds-section"; 
        } else {
            this.bExpanseValoracion = true;
            this.toggleIconValoracion = "slds-section slds-is-open";
        }
    }

    handleExpandableComprobaciones() {
        if(this.bExpanseComprobaciones){
            this.bExpanseComprobaciones = false;
            this.toggleIconComprobaciones = "slds-section"; 
        } else {
            this.bExpanseComprobaciones = true;
            this.toggleIconComprobaciones = "slds-section slds-is-open";
        }
    }

    handleExpandableAlegaciones() {
        if(this.bExpanseAlegaciones){
            this.bExpanseAlegaciones = false;
            this.toggleIconAlegaciones = "slds-section"; 
        } else {
            this.bExpanseAlegaciones = true;
            this.toggleIconAlegaciones = "slds-section slds-is-open";
        }
    }

    handleExpandableAllanamiento() {
        if(this.bExpanseAllanamiento){
            this.bExpanseAllanamiento = false;
            this.toggleIconAllanamiento = "slds-section"; 
        } else {
            this.bExpanseAllanamiento = true;
            this.toggleIconAllanamiento = "slds-section slds-is-open";
        }
    }

    handleExpandableFondo() {
        if(this.bExpanseFondo){
            this.bExpanseFondo = false;
            this.toggleIconFondo = "slds-section"; 
        } else {
            this.bExpanseFondo = true;
            this.toggleIconFondo = "slds-section slds-is-open";
        }
    }

    handleExpandablePropuesta() {
        if(this.bExpansePropuesta){
            this.bExpansePropuesta = false;
            this.toggleIconPropuesta = "slds-section"; 
        } else {
            this.bExpansePropuesta = true;
            this.toggleIconPropuesta = "slds-section slds-is-open";
        }
    }

    handleExpandableResolucion() {
        if(this.bExpanseResolucion){
            this.bExpanseResolucion = false;
            this.toggleIconResolucion = "slds-section"; 
        } else {
            this.bExpanseResolucion = true;
            this.toggleIconResolucion = "slds-section slds-is-open";
        }
    }

    handleExpandableObservaciones() {
        if(this.bExpanseObservaciones){
            this.bExpanseObservaciones = false;
            this.toggleIconObservaciones = "slds-section"; 
        } else {
            this.bExpanseObservaciones = true;
            this.toggleIconObservaciones = "slds-section slds-is-open";
        }
    }

    handleSubmit(event) {
        this.notificado = false;  
        this.spinnerLoading = true;
        const fields = event.detail.fields;

        //this.template.querySelectorAll('lightning-record-edit-form').forEach((form) => {console.log('form  ' + JSON.stringify(form)); form.submit()});
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        const record = event.detail;
        const myRecordId = record.id; // ID of updated or created record
        this.idFormularioCaso = myRecordId;

        if(!this.notificado) {
            notificarCambioFicha({casoId: this.recordId, caseNumber: this.caseNumber}).then(result => {
                const toast = new ShowToastEvent({
                    title: 'Formulario de la reclamación',
                    message: 'Se han actualizado los campos del formulario.',
                    variant: 'success'
                });
                this.dispatchEvent(toast);            
            }).catch(error => {
                const toast = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error al actualizar los campos del formulario.',
                    variant: 'error'
                });
                this.dispatchEvent(toast);
            }) 
            this.notificado = true;  
        }
        
        this.spinnerLoading = false;
    }

    handleOptionChangeDisponeDocumentacion(event) {
        this.mostrarDocumentacionNecesaria = false;
        const opcionSeleccionada = event.detail.value;
        if(opcionSeleccionada === 'No') {
            this.mostrarDocumentacionNecesaria = true;
        }       
    }
}