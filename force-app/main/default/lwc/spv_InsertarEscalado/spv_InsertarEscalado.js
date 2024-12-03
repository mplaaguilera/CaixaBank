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
import MOTIVO_ESCALADO from '@salesforce/schema/SAC_Interaccion__c.SAC_MotivoEscalado__c';

const FIELDS = ['Case.OwnerId', 'Case.Status', 'Case.RecordType.DeveloperName', 'Case.SEG_Subestado__c'];

export default class Spv_InsertarEscalado extends NavigationMixin(LightningElement) {
    @api recordId;
    @track spinnerLoading = false;
    @track modalInsertarEscalado = false;
    @track isModalAdjuntos = false;
    @track modalWarning = false;
    @track isEstadoEscalado = false;
    @track propuesta;
    @track titulo;
    @track observaciones;
    @track motivo;
    @track motivoLabel;
    @track propietario;
    @track hayEscaladoAbierto = false;
    @track existeEscaladoReclamacion = false;
    @track valueEquipo = 'Asesoría Jurídica'; 
    @track options = []

    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: MOTIVO_ESCALADO })
    getMotivoValues;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({data, error}){
        if(data){
            this.status = data.fields.SEG_Subestado__c.value;
            if(this.status == 'Allanamiento') {
                this.motivo = 'SPV_Allanamiento';
                this.motivoLabel = 'Allanamiento';
            } else if(this.status == 'Alegaciones') {
                this.motivo = 'SPV_Alegación';
                this.motivoLabel = 'Alegación';
            } else {
                this.motivo = 'SAC_OtrosMotivosEsc';
                this.motivoLabel = 'Otros';
            }
            if(data.fields.Status.value == 'SAC_002') {
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

    abrirModalWarning() {
        this.spinnerLoading = true;
        this.modalWarning = true;
        this.spinnerLoading = false;
    }

    cerrarModalInsertarEscalado() {
        this.modalInsertarEscalado = false;
    }

    cerrarModalWarning() {
        this.modalWarning = false;
    }

    handlePropuestaChange(event) {
        this.propuesta = event.target.value;
    }

    handleTituloChange(event) {
        this.titulo = event.target.value;
    }

    handleObservacionesChange(event) {
        this.observaciones = event.target.value;
    }

    handleChangeEquipo(event) { 
        this.valueEquipo = event.detail.value; 
    }

    insertarEscalado() {
        this.spinnerLoading = true;
        if ((this.titulo == null || this.titulo == '') || (this.propuesta == null || this.propuesta == '')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Precaución',
                    message: 'Recuerde completar el título y la propuesta.',
                    variant: 'warning'
                })
            ); 
            this.dispatchEvent(new RefreshEvent());
            this.spinnerLoading = false;
        } else {
            insertarEscalado({caseId: this.recordId, propuesta: this.propuesta, titulo: this.titulo, motivo: this.motivo, observaciones: this.observaciones, equipoId: this.valueEquipo}).then(result => {
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