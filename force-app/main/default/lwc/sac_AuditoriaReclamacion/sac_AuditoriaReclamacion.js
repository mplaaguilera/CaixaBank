import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getAuditoriaReclamacion from '@salesforce/apex/SAC_LCMP_AuditoriasController.getAuditoriaReclamacion';
import finalizarAuditoriaReclamacion from '@salesforce/apex/SAC_LCMP_AuditoriasController.finalizarAuditoriaReclamacion';
import replicarAuditoriaReclamacion from '@salesforce/apex/SAC_LCMP_AuditoriasController.replicarAuditoriaReclamacion';
import reabrirAuditoriaReclamacion from '@salesforce/apex/SAC_LCMP_AuditoriasController.crearAuditoriaReclamacion';
import comprobarEnvioEmail from '@salesforce/apex/SAC_LCMP_AuditoriasController.comprobarEnvioEmail';
import enviarEmailsAuditores from '@salesforce/apex/SAC_LCMP_AuditoriasController.enviarEmailsAuditores';

import AUDITORIA_OBJECT from '@salesforce/schema/SEG_Auditoria__c';
import AUDITORIACASO from '@salesforce/schema/Case.SEG_SRAuditoria__c';
import IDCASO from '@salesforce/schema/Case.Id';
import OWNERID from '@salesforce/schema/Case.OwnerId';
import GRUPOGESTOR from '@salesforce/schema/Case.SEG_Grupo__c';
import SLACALIDAD_FIELD from '@salesforce/schema/SEG_Auditoria__c.SAC_SLACalidad__c';


const FIELDS = [
    AUDITORIACASO,
    IDCASO,
    OWNERID,
    GRUPOGESTOR
];

export default class Sac_AuditoriaReclamacion extends NavigationMixin(LightningElement) {
    @api recordId;

    @track idAuditoria;
    @track estadoAuditoria;
    @track auditoriaRealizada;
    @track auditoriaReplicada = false;
    @track objetoCase = {};
    @track nombreAuditoriaPadre = '';
    @track idAuditoriaPadre;

    @track spinnerLoading = true;
    @track spinnerGuardar = false;
    @track modalFinalizarAuditoria = false;
    @track modalReabrirAuditoria = false;
    @track modalReplicarAuditoria = false;
    @track modalEnvioEmail = false;

    valueNombre = '';
    valueTipo = '';
    valueSLACalidad = '';
    @track auditoriaFinalizada = false;
    @track permitirReabrir = false;
    @track tiposDisponibles = [];
    @track puntosControl = [];
    @track listaAuditoria = [];
    @track requeridoNombre = false;
    @track requeridoTipo = false;
    @track requeridoSLACalidad = false;
    @track tienePermisosReplicar = false;
    @track tienePermisosEditar = false;
    @track hayAuditoriasFinalizadas = false;
    @track esGestorLetrado = false;
    auditoriaResult;

    @track datosAuditoria = "slds-section slds-is-open";
    @track bExpanseDatosAuditoria = true;
    @track dictamenAuditoria = "slds-section slds-is-open";
    @track bExpanseDictamenAuditoria = true;

    @wire (getObjectInfo, {objectApiName: AUDITORIA_OBJECT})
    objectInfoAuditoria;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoAuditoria.data.defaultRecordTypeId', fieldApiName: SLACALIDAD_FIELD })
    auditoriaSLACalidad;

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
            }
            
            this.objetoCase = objetoInterno;
            this.spinnerLoading = false
        }
    }

    // Metodo las secciones de los datos de la auditoria
    handleExpandableDatosAuditoria() {
        if(this.bExpanseDatosAuditoria){
            this.bExpanseDatosAuditoria = false;
            this.datosAuditoria = "slds-section"; 
        } else {
            this.bExpanseDatosAuditoria = true;
            this.datosAuditoria = "slds-section slds-is-open";
        }
    }
    handleExpandableDictamenAuditoria() {
        if(this.bExpanseDictamenAuditoria){
            this.bExpanseDictamenAuditoria = false;
            this.dictamenAuditoria = "slds-section"; 
        } else {
            this.bExpanseDictamenAuditoria = true;
            this.dictamenAuditoria = "slds-section slds-is-open";
        }
    }

    // Metodo para obtener la auditoria asociada y sus puntos de control
    @wire(getAuditoriaReclamacion, { casoOriginal: '$objetoCase'})
    getAuditoria(result){
        this.auditoriaResult = result;
        if(result.data){
            this.idAuditoria = result.data.auditoria.Id;
            this.estadoAuditoria = result.data.auditoria.SAC_Estado__c;
            this.listaAuditoria = result.data.lstAuditoria;
            this.tienePermisosEditar = result.data.tienePermisosEditar;
            this.idAuditoriaPadre = result.data.auditoria.SAC_AuditoriaGeneral__c;
            this.nombreAuditoriaPadre = result.data.auditoria.SAC_AuditoriaGeneral__r.SAC_NombreAuditoria__c;
            
            this.listaAuditoria = this.listaAuditoria.map((item) => 
                Object.assign({}, item, {Replicada: false, PermisosReplicar: false, PuntosControl:[]})
            )

            if(this.listaAuditoria.length > 0) {
                this.hayAuditoriasFinalizadas = true;
            }
            
            for (let key in result.data.mapAuditoriaPuntos) {                
                for (var i = 0, l = this.listaAuditoria.length; i < l; i++) {
                    if(this.listaAuditoria[i].Id === key) {
                        this.listaAuditoria[i].PuntosControl = result.data.mapAuditoriaPuntos[key];
                    }
                    if(this.listaAuditoria[i].SAC_Estado__c === 'SAC_Revisada') {
                        this.listaAuditoria[i].Replicada = true;
                    }
                    // Permisos de replicar de las auditorias finalizadas
                    if(this.listaAuditoria[i].SAC_Tipo__c === 'SAC_Altas' && result.data.esAuditorGestor && this.listaAuditoria[i].SAC_Estado__c === 'SAC_Completada') {
                        this.listaAuditoria[i].PermisosReplicar = true;
                    }else if(this.listaAuditoria[i].SAC_Tipo__c !== 'SAC_Altas' && result.data.esAuditorLetrado && this.listaAuditoria[i].SAC_Estado__c === 'SAC_Completada') {
                        this.listaAuditoria[i].PermisosReplicar = true;
                    }
                }
            }
            this.tiposDisponibles = [];
            for (let key in result.data.mapTiposDisponibles) {
                this.tiposDisponibles.push({value:key, label:result.data.mapTiposDisponibles[key]});
            }

            if(this.tienePermisosEditar) {
                this.permitirReabrir = result.data.permitirReabrir;
            }
            
            this.puntosControl = result.data.lstPuntos;

            if(this.estadoAuditoria === 'SAC_Completada') {
                this.auditoriaFinalizada = true;
                // Permisos de replicar de la auditoria actual
                if(result.data.auditoria.SAC_Tipo__c === 'SAC_Altas' && result.data.esAuditorGestor) {
                    this.tienePermisosReplicar = true;
                } else if (result.data.auditoria.SAC_Tipo__c !== 'SAC_Altas' && result.data.esAuditorLetrado) {
                    this.tienePermisosReplicar = true;
                }
            }

            if((result.data.esAuditorGestor || result.data.esAuditorLetrado) && !this.tienePermisosEditar) {
                this.esGestorLetrado = true;
            }

            if(this.estadoAuditoria === 'SAC_Pendiente') {
                this.auditoriaFinalizada = false;
            }

            this.auditoriaReplicada = false;
            if(this.estadoAuditoria === 'SAC_Revisada') {
                this.auditoriaFinalizada = true;
                this.auditoriaReplicada = true;
            }

            this.spinnerLoading = false;
        } else if(result.error){
            this.auditoriaRealizada = false;
            this.spinnerLoading = false;
        }
    }

    // Botones para guardar y finalizar la edición de la auditoría de la reclamación
    handleSubmit(event) {
        this.spinnerGuardar = true;

        this.template.querySelectorAll('lightning-record-edit-form').forEach((form) => {form.submit()});
    }

    handleSuccess(event) {
        const toast = new ShowToastEvent({
            title: 'Auditoría de la reclamación',
            message: 'Se han actualizado los campos de la auditoría.',
            variant: 'success'
        });
        this.dispatchEvent(toast);
        this.spinnerGuardar = false;
    }

    // FUNCIONALIDAD PARA FINALIZAR LA AUDITORIA
    handleFinalizar(event) {
        var buttonName = event.target.dataset.name;
        this.idAuditoria = buttonName;
        this.modalFinalizarAuditoria = true;
    }

    cerrarModalFinalizarAuditoria(){
        this.modalFinalizarAuditoria = false;
    }

    confirmarFinalizarAuditoria(){
        this.modalFinalizarAuditoria = false;
        this.spinnerLoading = true;
        

        comprobarEnvioEmail({idAuditoria: this.idAuditoria}).then(result => {              
            if(result === true){
                this.spinnerLoading = false;
                this.modalEnvioEmail = true;
            }else{
                // this.spinnerLoading = true;
                this.finalizar();   
            }
        })
        .catch(error => {
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error al comprobar el envio de auditoria finalizada',
                    variant: 'error'
                })
            ); 
            this.dispatchEvent(new RefreshEvent());
        })   
    }

    finalizar(){
        finalizarAuditoriaReclamacion({casoOriginal: this.objetoCase, idAuditoria: this.idAuditoria}).then(result => {  
            this.spinnerLoading = false;
            this.auditoriaFinalizada = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'La auditoría se ha finalizado con éxito',
                    variant: 'success'
                })
            );
            refreshApex(this.auditoriaResult);
            this.dispatchEvent(new RefreshEvent());
        })
        .catch(error => {
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error al finalizar la auditoría',
                    message: error.body.message,
                    variant: 'error'
                })
            ); 
            this.dispatchEvent(new RefreshEvent());
        })
    }


    // FUNCIONALIDAD PARA REABRIR LA AUDITORIA
    handleReabrir(event) {
        this.modalReabrirAuditoria = true;
    }

    cerrarModalReabrirAuditoria(){
        this.modalReabrirAuditoria = false;
    }

    handleChangeNombreAuditoria(event) {
        this.valueNombre = event.target.value;
    }

    handleChangeSLACalidadAuditoria(event) {
        this.valueSLACalidad = event.detail.value;
    }

    handleChangeTipoAuditoria(event) {
        this.valueTipo = event.detail.value;
    }

    confirmarReabrirAuditoria(){
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
            this.modalReabrirAuditoria = false;
            this.valueTipo = this.valueTipo.join(';');
            this.spinnerLoading = true;

            reabrirAuditoriaReclamacion({casoOriginal: this.objetoCase, tipoAuditoria: this.valueTipo, nombreAuditoria: this.valueNombre, auditoriaSLACalidad: this.valueSLACalidad}).then(result => {  
                this.spinnerLoading = false;
                this.permitirReabrir = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Se ha creado el nuevo bloque de la auditoría correctamente',
                        variant: 'success'
                    })
                );
                refreshApex(this.auditoriaResult);
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


    // FUNCIONALIDAD PARA REPLICAR LA AUDITORIA
    handleReplicar(event) {
        var buttonName = event.target.dataset.name;
        this.idAuditoria = buttonName;
        this.modalReplicarAuditoria = true;
    }

    cerrarModalReplicarAuditoria(){
        this.modalReplicarAuditoria = false;
    }

    confirmarReplicarAuditoria(){
        this.modalReplicarAuditoria = false;
        this.spinnerLoading = true;

        replicarAuditoriaReclamacion({casoOriginal: this.objetoCase, idAuditoria: this.idAuditoria}).then(result => {  
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Se ha enviado la réplica de la auditoría con éxito',
                    variant: 'success'
                })
            );
            refreshApex(this.auditoriaResult);
            this.dispatchEvent(new RefreshEvent());
        })
        .catch(error => {
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error al replicar la auditoría',
                    message: error.body.message,
                    variant: 'error'
                })
            ); 
            this.dispatchEvent(new RefreshEvent());
        })
    }

    // FUNCIONALIDAD PARA EL ENVIO DE CORREO
    cerrarModalEnvioEmail(){
        this.modalEnvioEmail = false;
        this.finalizar();
        // refreshApex(this.auditoriaResult);
        // this.dispatchEvent(new RefreshEvent());
    }

    confirmarEnviarCorreo(){
        this.modalEnvioEmail = false;
        this.spinnerLoading = true;   
        
        this.finalizar();  

        //US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList. Comprueba si los emails son correctos. Si son correctos continua el proceso, sino muestra mensaje informativo
        enviarEmailsAuditores({idAuditoria: this.idAuditoria}).then(result => {  
            this.spinnerLoading = false;

            if(result === true){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Se ha enviado el email correctamente',
                        variant: 'success'
                    })
                );
                refreshApex(this.auditoriaResult);
                this.dispatchEvent(new RefreshEvent());
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Advertencia!',
                        message: 'No se ha enviado el email. No existen auditores en el grupo correspondiente o no está permitido el envío de emails a sus direcciones.',
                        variant: 'warning',
                        duration: 8000
                    })
                );
                refreshApex(this.auditoriaResult);
                this.dispatchEvent(new RefreshEvent());
            }
        })
        .catch(error => {
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error al enviar el correo de auditoría completada',
                    variant: 'error'
                })
            ); 
            this.dispatchEvent(new RefreshEvent());
            
        })
    }

    navigateToRecord(event) {
        const auditoriaId = event.currentTarget.dataset.value;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: auditoriaId,
                objectApiName: 'SEG_Auditoria__c',
                actionName: 'view'
            }
        });
    }
}