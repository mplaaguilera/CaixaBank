import { LightningElement, api, wire, track } from 'lwc';
import responderConsulta from '@salesforce/apex/SAC_LCMP_ResponderConsulta.responderConsulta';
import guardarConsulta from '@salesforce/apex/SAC_LCMP_ResponderConsulta.guardarConsulta';
import getRespuestaConsulta from '@salesforce/apex/SAC_LCMP_ResponderConsulta.getRespuestaConsulta';
import insertarAdjuntoCaso from '@salesforce/apex/SAC_LCMP_ResponderConsulta.insertarAdjuntoCaso';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ESDEMIGRUPO from '@salesforce/schema/SAC_Interaccion__c.SAC_EsMiGrupo__c';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import INTERACCION_OBJECT from '@salesforce/schema/SAC_Interaccion__c'; 
import MOTIVODEVOLUCION_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_Motivo_Devolucion__c';
import { RefreshEvent } from 'lightning/refresh';


const fields = [ESDEMIGRUPO, MOTIVODEVOLUCION_FIELD];

export default class SAC_ResponderConsulta extends LightningElement {

    @track modalRespuesta = false;
    @track disableGuardar = true; 
    @track disableResponder = true; 
    @track motivoDevolucionConsulta;
    @track motivoDevolucion;
    @api recordId;
    @api isLoading = false;
    valorRespuesta = '';   
    
    @wire (getObjectInfo, {objectApiName: INTERACCION_OBJECT})
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVODEVOLUCION_FIELD })
    getMotivoDevolucionValues;

    @wire(getRecord, {recordId: '$recordId', fields})
    actualConsulta({ data, error }) {
        if(data){
            this.motivoDevolucionConsulta = data.fields.SAC_Motivo_Devolucion__c.displayValue; 
            this.motivoDevolucion = data.fields.SAC_Motivo_Devolucion__c.value; 
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    consulta;

    get esDeMiGrupo() {
        return getFieldValue(this.consulta.data, ESDEMIGRUPO);
    }    

    get desabilitarBoton(){
        return (this.esDeMiGrupo) ? false : true;
    }

    get disableGuardar(){
        return this.disableGuardar;
    }

    get acceptedFormats() {
        return ['.pdf','.png','.jpg', '.jpeg'];
    }

    onChangeInput(event){ 
        var inputvalue = event.target.value; 
        this.disableGuardar = (inputvalue == '') ? true : false; 
    }

    responder(){
        getRespuestaConsulta({consultaId: this.recordId}).then(result =>{           
            this.valorRespuesta = result;
            if(this.valorRespuesta != '') {
                this.disableResponder = false;
            }
        })
        .catch(error => {
        
        }) 
        this.modalRespuesta = true;
    }
    closeModal() {
        this.modalRespuesta = false;
    }

    responderConsulta(){ 
        var inp = this.template.querySelector("lightning-textarea[data-my-id=textoRespuesta]");
        var respuesta = inp.value;
        
        if(respuesta != '') {
            responderConsulta({consultaId: this.recordId, respuesta: respuesta, motivo : this.motivoDevolucion}).then(result =>{
                this.isLoading = false;
                this.dispatchEvent(
    
                    new ShowToastEvent({
                        title: 'Estado actualizado',
                        message: this.mensaje,
                        variant: 'success'
                    }),
                );
                
                this.dispatchEvent(new RefreshEvent());
    
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMsg = error;
    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al actualizar',
                        message: error.body.message,
                        variant: 'error'
                    }),
                );
            })    
        } else{
            const evt = new ShowToastEvent({
                title: 'Fallo al responder',
                message: 'Recuerde completar el campo respuesta',
                variant: 'error'
            });

            this.dispatchEvent(evt);
        }
    }
        

    guardarConsulta(){ 
        var inp = this.template.querySelector("lightning-textarea[data-my-id=textoRespuesta]");
        var respuesta = inp.value;
         
        guardarConsulta({consultaId: this.recordId, respuesta: respuesta, motivo: this.motivoDevolucion}).then(result =>{
            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Consulta guardada',
                    message: this.mensaje,
                    variant: 'success'
                }),
            );
            this.modalRespuesta = false;

            this.dispatchEvent(new RefreshEvent());

        })
        .catch(error => {
            this.isLoading = false;
            this.errorMsg = error;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                }),
            );
        })    
    }

    handleUploadFinished(event) {
        let uploadedFiles = event.detail.files;
        insertarAdjuntoCaso({caseId: this.recordId, numFicheros: uploadedFiles.length}).then(() => {

            const evt = new ShowToastEvent({
                title: 'Éxito!',
                message: 'Los archivos se han subido con éxito.',
                variant: 'success'
            });

            this.dispatchEvent(evt);
            this.disableGuardar = false;

        }).catch(error => {

                const evt = new ShowToastEvent({
                    title: 'Fallo al subir los archivos',
                    message: error.body.message,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
            })
    }

    handleMotivoChange(event) {
        this.motivoDevolucion = event.target.value;
    }
}