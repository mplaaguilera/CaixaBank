import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FORMULARIO_OBJECT from '@salesforce/schema/SPV_Formulario__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import currentUserId from '@salesforce/user/Id';

import CASEID from '@salesforce/schema/Case.Id';
import CASERT from '@salesforce/schema/Case.RecordTypeId';
import CASENUMBER from '@salesforce/schema/Case.CaseNumber';
import OWNERID from '@salesforce/schema/Case.OwnerId';
import STATUS from '@salesforce/schema/Case.Status';

import getFormularioExistente from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.getFormularioExistente';
import getRectificacionesAnteriores from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.getRectificacionesAnteriores';
import compruebaLetradoSPV from '@salesforce/apex/SPV_LCMP_FormularioRectificacion.compruebaLetradoSPV';



const FIELDS = [CASEID, CASERT, CASENUMBER, OWNERID, STATUS];

const columns = [
    { label: 'Fecha', fieldName: 'SPV_FechaRectificacion__c', type: 'date',
    typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    }},
    { label: 'Propuesta Rectificacion', fieldName: 'SPV_PropuestaRectificacion__c', type: 'text' , wrapText: true  },
    { label: 'Instrucciones', fieldName: 'SPV_InstruccionesRect__c', type: 'text', cwrapText: true }
];


export default class Spv_formularioRectificacion extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track recordTypeId;
    @track idFormularioCaso;
    @track spinnerLoading;
    @track rectificaciones;
    @track tienePermisosEditar = false;

    @track toggleIconReclamacionesAJN = "slds-section slds-is-open";
    @track bExpanseReclamacionesAJN = true;

    @track toggleIconAnalisisBDE= "slds-section slds-is-open";
    @track bExpanseAnalisisBDE = true;

    @track toggleIconPropuestaRect = "slds-section slds-is-open";
    @track bExpansePropuestaRect = true;

    @track toggleIconListadoRectificaciones = "slds-section slds-is-open";
    @track bExpanseListadoRectificaciones = true;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({data, error}){
        if(data){
            const ownerId = data.fields.OwnerId.value;
            compruebaLetradoSPV({'caseId': this.recordId}).then(result => {
                if(result){
                    this.tienePermisosEditar = result;
                }
            });

            // if(ownerId == currentUserId) {
            //     this.tienePermisosEditar = true;
            // } else {
            //     this.camposReadOnly = true;
            // }
        }
    }

    @wire(getObjectInfo, { objectApiName: FORMULARIO_OBJECT })
    objectInfo({ data, error }) {
        if (data) {

            // Filtra el tipo de registro según el nombre (opcional)
            const recordTypeInfos = data.recordTypeInfos;
            this.recordTypeId = Object.keys(recordTypeInfos).find(rt => recordTypeInfos[rt].name === 'Formulario Rectificacion SPV');
        }
    }

    @wire(getRectificacionesAnteriores, { casoId: '$recordId'})
    wiredRectificaciones({data, error}){
        if(data){
            this.rectificaciones = data;
        }
    }

    @wire(getFormularioExistente, { casoId: '$recordId'})
    getFormulario({ error, data }){
        if(data){
            this.idFormularioCaso = data;
        }
    }

    handleExpandableReclamacionesAJN() {
        if(this.bExpanseReclamacionesAJN){
            this.bExpanseReclamacionesAJN = false;
            this.toggleIconReclamacionesAJN = "slds-section"; 
        } else {
            this.bExpanseReclamacionesAJN = true;
            this.toggleIconReclamacionesAJN = "slds-section slds-is-open";
        }
    }

    handleExpandablePropuestaRect() {
        if(this.bExpansePropuestaRect){
            this.bExpansePropuestaRect = false;
            this.toggleIconPropuestaRect = "slds-section"; 
        } else {
            this.bExpansePropuestaRect = true;
            this.toggleIconPropuestaRect = "slds-section slds-is-open";
        }
    }

    handleExpandableListadoRectificaciones() {
        if(this.bExpanseListadoRectificaciones){
            this.bExpanseListadoRectificaciones = false;
            this.toggleIconListadoRectificaciones = "slds-section"; 
        } else {
            this.bExpanseListadoRectificaciones = true;
            this.toggleIconListadoRectificaciones = "slds-section slds-is-open";
        }
    }


    handleSubmit(event) {
        this.spinnerLoading = true;
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        const record = event.detail;
        const myRecordId = record.id; // ID of updated or created record
        this.idFormularioCaso = myRecordId; 

        const toast = new ShowToastEvent({
            title: 'Formulario de la reclamación',
            message: 'Se han actualizado los campos del formulario.',
            variant: 'success'
        });
        this.dispatchEvent(toast);  
        
        this.spinnerLoading = false;
    }

    get camposReadOnly() {
        return !this.tienePermisosEditar; // Si no tiene permisos, los campos serán deshabilitados
    }

    get columns() {
        return columns;
    }

}