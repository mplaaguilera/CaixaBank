import { LightningElement, api, wire, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';

import comprobarPermisosCreacionAuditoria from '@salesforce/apex/SAC_LCMP_AuditoriasController.comprobarPermisosCreacionAuditoria';
import crearAuditoriaReclamacion from '@salesforce/apex/SAC_LCMP_AuditoriasController.crearAuditoriaReclamacion';

import AUDITORIA_OBJECT from '@salesforce/schema/SEG_Auditoria__c';
import TIPOAUDITORIA_FIELD from '@salesforce/schema/SEG_Auditoria__c.SAC_Tipo__c';
import SLACALIDAD_FIELD from '@salesforce/schema/SEG_Auditoria__c.SAC_SLACalidad__c';

import AUDITORIACASO from '@salesforce/schema/Case.SEG_SRAuditoria__c';
import IDCASO from '@salesforce/schema/Case.Id';
import STATUSCASO from '@salesforce/schema/Case.Status';
import GRUPOLETRADO from '@salesforce/schema/Case.SEG_Grupo__c';
import SUBSANACION from '@salesforce/schema/Case.SAC_TipoSubsanacion__c';
import ANALISIS from '@salesforce/schema/Case.SAC_FechaUltimaAsignacionLetrado__c';
import NEGOCIACION from '@salesforce/schema/Case.SAC_FechaFinNegociacion__c';
import RESOLUCION from '@salesforce/schema/Case.OS_Fecha_Resolucion__c';
import EJECUCION from '@salesforce/schema/Case.SAC_FechaEjecucion__c';
import DERIVACION from '@salesforce/schema/Case.SAC_FechaDerivacion__c';


const FIELDS = [
    AUDITORIACASO,
    IDCASO,
    STATUSCASO,
    GRUPOLETRADO,
    SUBSANACION,
    ANALISIS,
    NEGOCIACION,
    RESOLUCION,
    EJECUCION,
    DERIVACION
];

export default class Sac_RealizarAuditoria extends LightningElement {
    valueNombre = '';
    valueTipo = '';
    valueSLACalidad = '';
    @api recordId;
    @track auditoriaRealizada;
    @track tienePermisos;
    @track reclamacionCerrada;
    @track modalRealizarAuditoria = false;
    @track requeridoNombre = false;
    @track requeridoSLACalidad = false;
    @track requeridoTipo = false;
    @track objetoCase = {};
    @track subsanacion = false;
    @track analisis = false;
    @track negociacion = false;
    @track resolucion = false;
    @track ejecucion = false;
    @track derivacion = false;
    @track listTipos = {};


    @wire(getRecord, {recordId: '$recordId', fields : FIELDS})
    getCaseRecord({ error, data }){
        if (data) {
            let objetoInterno = {};
            
            for (const campo in data.fields){
                objetoInterno[campo] = data.fields[campo].value;
                
                if (campo == 'SEG_SRAuditoria__c'){
                    if (data.fields[campo].value === true){
                        // Tiene auditoría creada en la reclamacion
                        this.auditoriaRealizada = true;
                    } else {
                        // NO tiene auditoría creada en la reclamacion
                        this.auditoriaRealizada = false;
                    }
                }
                if (campo == 'Status'){
                    if (data.fields[campo].value == 'Cerrado' || data.fields[campo].value == 'SAC_008'){
                        // La reclamación está cerrada o derivada
                        this.reclamacionCerrada = true;
                    } else {
                        // La reclamación NO está cerrada o derivada
                        this.reclamacionCerrada = false;
                    }
                }
                if(campo == 'SAC_TipoSubsanacion__c' && data.fields[campo].value != null){
                    this.subsanacion = true;
                }
                if(campo == 'SAC_FechaUltimaAsignacionLetrado__c' && data.fields[campo].value != null){
                    this.analisis = true;
                }
                if(campo == 'SAC_FechaFinNegociacion__c' && data.fields[campo].value != null){
                    this.negociacion = true;
                }
                if(campo == 'OS_Fecha_Resolucion__c' && data.fields[campo].value != null){
                    this.resolucion = true;
                }
                if(campo == 'SAC_FechaEjecucion__c' && data.fields[campo].value != null){
                    this.ejecucion = true;
                }
                if(campo == 'SAC_FechaDerivacion__c' && data.fields[campo].value != null){
                    this.derivacion = true;
                }
            }
            this.objetoCase = objetoInterno;
        } else if (error) {
            console.log(error);
        }
    }

    @wire (getObjectInfo, {objectApiName: AUDITORIA_OBJECT})
    objectInfoAuditoria;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoAuditoria.data.defaultRecordTypeId', fieldApiName: TIPOAUDITORIA_FIELD })
    listaTiposAuditorias;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoAuditoria.data.defaultRecordTypeId', fieldApiName: SLACALIDAD_FIELD })
    auditoriaSLACalidad;

    @wire(comprobarPermisosCreacionAuditoria, {casoOriginal: '$objetoCase'}) 
    permisosAuditoria({ error, data }) {
        if(data){            						
            this.tienePermisos = data;
        }
        if(error){
            this.error = error;
        }        
    };

    mostrarModalRealizarAuditoria(){

        //US844784 - 24/04/2024 - Raúl Santos - mostrar solo los tipos de auditoría que cumplan las condiciones
        // Parsea el JSON en un objeto JavaScript
        let jsonResponse = JSON.parse(JSON.stringify(this.listaTiposAuditorias));

        // Extrae el array 'values' del objeto
        let values = jsonResponse.data.values;

        // Itera sobre el array 'values' y verifica si cada elemento cumple con las condiciones deseadas
        for (let i = 0; i < values.length; i++) {
            let value = values[i];
            let label = value.label;

            //Si la reclamación NO ha pasado por subsanación, quitamos este tipo del selector
            if(label === 'Subsanación' && !this.subsanacion){
                values.splice(i, 1);
                i--; // Ajusta el índice para evitar saltar elementos
            }
            //Si la reclamación NO ha pasado por análisis, quitamos este tipo del selector
            if(label === 'Análisis' && !this.analisis){
                values.splice(i, 1);
                i--; // Ajusta el índice para evitar saltar elementos
            }
            //Si la reclamación NO ha pasado por negociación, quitamos este tipo del selector
            if(label === 'Negociación' && !this.negociacion){
                values.splice(i, 1);
                i--; // Ajusta el índice para evitar saltar elementos
            }
            //Si la reclamación NO ha pasado por resolución, quitamos este tipo del selector
            if(label === 'Resolución' && !this.resolucion){
                values.splice(i, 1);
                i--; // Ajusta el índice para evitar saltar elementos
            }
            //Si la reclamación NO ha pasado por ejecución, quitamos este tipo del selector
            if(label === 'Ejecución' && !this.ejecucion){
                values.splice(i, 1);
                i--; // Ajusta el índice para evitar saltar elementos
            }
            //Si la reclamación NO ha pasado por derivación, quitamos este tipo del selector
            if(label === 'Derivación' && !this.derivacion){
                values.splice(i, 1);
                i--; // Ajusta el índice para evitar saltar elementos
            }
            //Si el selector no ha pasado por todos los estados (subsanación, análisis, negociación, resolución, ejecución, derivación) no muestro el todas
            if(label === 'Todas' && (this.subsanacion !== true && this.analisis !== true || this.negociacion !== true || this.resolucion !== true || this.ejecucion !== true || this.derivacion !== true)){
                values.splice(i, 1);
                i--; // Ajusta el índice para evitar saltar elementos
            }
        }

        this.listTipos = jsonResponse;

        this.modalRealizarAuditoria = true;
    }

    cerrarModalRealizarAuditoria(){
        this.modalRealizarAuditoria = false;
    }

    handleChangeNombreAuditoria(event) {
        this.valueNombre = event.target.value;
    }

    handleChangeTipoAuditoria(event) {
        this.valueTipo = event.detail.value;
    }

    handleChangeSLACalidadAuditoria(event) {
        this.valueSLACalidad = event.detail.value;
    }

    confirmarRealizarAuditoria(){
        if(this.valueNombre === '' || this.valueNombre === null){
            this.requeridoNombre = true;
        }else if(this.valueTipo === '' || this.valueTipo === null){
            this.requeridoTipo = true;
        }else if(this.valueSLACalidad === '' || this.valueSLACalidad === null){
            this.requeridoSLACalidad = true;
        }else{
            this.requeridoNombre = false;
            this.requeridoTipo = false;
            this.requeridoSLACalidad = false;
            this.modalRealizarAuditoria = false;
            this.valueTipo = this.valueTipo.join(';');
            this.spinnerLoading = true;

            crearAuditoriaReclamacion({casoOriginal: this.objetoCase, tipoAuditoria: this.valueTipo, nombreAuditoria: this.valueNombre, auditoriaSLACalidad: this.valueSLACalidad}).then(result => {  //devolver algo para asi finalizar el modal y mostar un mensaje informativo 
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'El proceso ha terminado con éxito, puede consultar la auditoría creada en la pestaña de la reclamación',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new RefreshEvent());
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })
        }
    }
}