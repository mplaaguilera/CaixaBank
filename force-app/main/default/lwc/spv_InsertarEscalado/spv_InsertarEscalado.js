import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { RefreshEvent } from 'lightning/refresh';
import { NavigationMixin } from 'lightning/navigation';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import insertarEscalado from '@salesforce/apex/SPV_LCMP_InsertarEscalado.insertarEscalado';
import esPropietario from '@salesforce/apex/SPV_LCMP_InsertarEscalado.esPropietario';
import hayEscaladosAbiertos from '@salesforce/apex/SPV_LCMP_InsertarEscalado.hayEscaladosAbiertos';
import recogerGruposParaEscalados from '@salesforce/apex/SPV_LCMP_InsertarEscalado.recogerGruposParaEscalados';
import getRecordTypes from '@salesforce/apex/SPV_Utils.obtenerRecordTypes';
import comprobarCamposEscalar from '@salesforce/apex/SPV_LCMP_InsertarEscalado.comprobarCamposEscalar';
import MOTIVO_ESCALADO from '@salesforce/schema/SAC_Interaccion__c.SAC_MotivoEscalado__c';
import TIPO_ESCALADO from '@salesforce/schema/SAC_Interaccion__c.SPV_TipoEscalado__c';

const FIELDS = ['Case.OwnerId', 'Case.Status', 'Case.RecordType.DeveloperName', 'Case.SEG_Subestado__c'];

export default class Spv_InsertarEscalado extends NavigationMixin(LightningElement) {
    @api recordId;
    @track spinnerLoading = false;
    @track modalInsertarEscalado = false;
    @track isModalAdjuntos = false;
    @track modalWarning = false;
    @track isEstadoEscalado = false;
    @track propuestaLetrado;
    @track titulo;
    @track motivo;
    @track propietario;
    @track hayEscaladoAbierto = false;
    @track existeEscaladoReclamacion = false;
    @track valueEquipo = 'Asesoría Jurídica'; 
    @track options = []

    @track camposPendientesParaEscalar = '';
    @track mostrarModalCamposPorRellenar = false;

    @track rtEscaladosSPV;

    @track selectedTipoEscalado = '';
    @track mostrarObservacionesTipoEscalado = false;
    @track observacionesTipoEscalado = '';

    @track selectedMotivo = '';
    @track mostrarObservacionesMotivo = false;
    @track observacionesMotivoEscalado = '';

    @track mostrarPropuestaLetrado = false;

    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;


    //Se obtienen el RecordType de escalados de SPV
    @wire(getRecordTypes)
    getRecordTypesResult(result){
        if(result.data){
            
            result.data.forEach(element => {
                if(element.DeveloperName == 'SPV_Escalado'){
                    this.rtEscaladosSPV = element.Id;
                }
            });
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$rtEscaladosSPV', fieldApiName: MOTIVO_ESCALADO })
    getMotivoValues;

    @wire(getPicklistValues, { recordTypeId: '$rtEscaladosSPV', fieldApiName: TIPO_ESCALADO})
    getTipoEscaladoValues;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({data, error}){
        if(data){
            this.status = data.fields.SEG_Subestado__c.value;
            /*if(this.status == 'Allanamiento') {
                this.motivo = 'SPV_Allanamiento';
                this.motivoLabel = 'Allanamiento';
            } else if(this.status == 'Alegaciones') {
                this.motivo = 'SPV_Alegación';
                this.motivoLabel = 'Alegación';
            } else {
                this.motivo = 'SAC_OtrosMotivosEsc';
                this.motivoLabel = 'Otros';
            }*/
            if(data.fields.Status.value == 'SPV_AnalisisDecision') {
                this.isEstadoEscalado = false;
            } else {
                this.isEstadoEscalado = true;
            }
        }
    }
    
    @wire(recogerGruposParaEscalados, {idCase: '$recordId'})
    gruposParaEscalar(result) {
        if (result.data) { 
            result.data.forEach(element => {
                let opcAux = { label: element.Name, value: element.Id };
                this.valueEquipo = element.id;
                this.options = [...this.options, opcAux];   
            });
        } 
        else if (result.error) {
            this.error = result.error;
        }
    }

    get existeEscalado() {
        hayEscaladosAbiertos({ caseId: this.recordId }).then(result => {             
            this.hayEscaladoAbierto = result;
            this.mensaje = 'Tiene escalados abiertos en la reclamación.';  
        })
        return this.hayEscaladoAbierto;
    }

    comprobarPropietario() {
        this.spinnerLoading = true;
        esPropietario({caseId: this.recordId}).then(result => {
            this.propietario = result;
            if(this.propietario){
                //Si es propietario, compruebo si ya hay escalados que estén abiertos
                if(this.hayEscaladoAbierto){
                    const evt = new ShowToastEvent({
                        title: 'La reclamación ya ha sido escalada',
                        message: 'Ya existe un escalado abierto en esta reclamación',
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                } else {
                        this.abrirModalInsertarEscalado();
                }
            } else {
                this.abrirModalWarning();
            }
            this.spinnerLoading = false;
        })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al crear el escalado',
                        message: error.body.message,
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
                
                this.spinnerLoading = false;
            })
    }


    abrirModalInsertarEscalado() {
        this.spinnerLoading = true;
        this.modalInsertarEscalado = true;
        this.spinnerLoading = false;
    }

    cerrarModalInsertarEscalado() {
        this.modalInsertarEscalado = false;
        this.selectedTipoEscalado = '';
        this.observacionesTipoEscalado ='';
        this.mostrarObservacionesTipoEscalado = false;
        this.selectedMotivo = '';
        this.observacionesMotivoEscalado = '';
        this.mostrarObservacionesMotivo = false;
        this.mostrarPropuestaLetrado = false;
        this.propuestaLetrado = '';
        this.valueEquipo = '';
    }

    handleOptionChangeTipoEscalado(event){
        this.selectedTipoEscalado = event.target.value;
        if(this.selectedTipoEscalado == 'SPV_Otros'){
            this.mostrarObservacionesTipoEscalado = true;
            this.mostrarPropuestaLetrado = true;
        }else{
            this.mostrarObservacionesTipoEscalado = false;
            this.mostrarPropuestaLetrado = false;
        }
    }

    handleChangeObservTipoEscalado(event){
        this.observacionesTipoEscalado = event.target.value;
    }

    handleOptionChangeMotivo(event){
        this.selectedMotivo = event.target.value;
        if(this.selectedMotivo == 'SAC_OtrosMotivosEsc'){
            this.mostrarObservacionesMotivo = true;
        }else{
            this.mostrarObservacionesMotivo = false;
        }
    }

    handleChangeObservMotivoEscalado(event){
        this.observacionesMotivoEscalado = event.target.value;
    }

    abrirModalWarning() {
        this.spinnerLoading = true;
        this.modalWarning = true;
        this.spinnerLoading = false;
    }
    cerrarModalWarning() {
        this.modalWarning = false;
    }

    handlePropuestaChange(event) {
        this.propuestaLetrado = event.target.value;
    }

    handleTituloChange(event) {
        this.titulo = event.target.value;
    }

    handleChangeEquipo(event) { 
        this.valueEquipo = event.detail.value; 
    }


    comprobarCamposInsertarEscalado(){
        this.spinnerLoading = true;
        comprobarCamposEscalar({'caseId': this.recordId})
        .then(data=>{
            this.camposPendientesParaEscalar = data;
            if(this.camposPendientesParaEscalar) {
                this.spinnerLoading = false;
                this.mostrarModalCamposPorRellenar = true;
            }else{
                this.comprobarPropietario();
            }
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
        }); 
    }

    closeModalComprobarCampos(){
        this.mostrarModalCamposPorRellenar = false;
        this.camposPendientesParaEscalar = '';
    }


    insertarEscalado() {
        this.spinnerLoading = true;
        if ((this.selectedTipoEscalado == '' || this.selectedTipoEscalado == null) || (this.selectedTipoEscalado == 'SPV_Otros' && ((this.observacionesTipoEscalado == '' || this.observacionesTipoEscalado == null) || (this.propuestaLetrado == '' || this.propuestaLetrado == null))) || (this.valueEquipo == '' || this.valueEquipo == null) || (this.selectedMotivo == '' || this.selectedMotivo == null) || (this.selectedMotivo == 'SAC_OtrosMotivosEsc' && (this.observacionesMotivoEscalado == '' || this.observacionesMotivoEscalado == null))     ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Precaución',
                    message: 'Recuerde completar todos los campos marcados como obligatorios para crear el escalado.',
                    variant: 'warning'
                })
            ); 
            this.dispatchEvent(new RefreshEvent());
            this.spinnerLoading = false;
        } else {
            insertarEscalado({caseId: this.recordId, tipoEscalado: this.selectedTipoEscalado, observacionesTipoEscalado: this.observacionesTipoEscalado, propuestaLetrado: this.propuestaLetrado, equipoId: this.valueEquipo, motivoEscalado: this.selectedMotivo, observacionesMotivoEscalado: this.observacionesMotivoEscalado}).then(result => {
                this.spinnerLoading = false;
                let idNuevoEscalado = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Escalado creado',
                        message: 'Se ha creado el escalado con éxito',
                        variant: 'success'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: idNuevoEscalado,
                        objectApiName: 'SAC_Interaccion__c',
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al crear el escalado',
                        message: error.body.message,
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
                this.spinnerLoading = false;
            })
            this.cerrarModalInsertarEscalado();
        }    
    }
}