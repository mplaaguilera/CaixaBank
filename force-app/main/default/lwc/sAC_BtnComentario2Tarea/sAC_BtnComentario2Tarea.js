import { LightningElement, wire, api, track} from 'lwc';
import ESTADO from '@salesforce/schema/SAC_Accion__c.SAC_Estado__c';
import OWNER from '@salesforce/schema/SAC_Accion__c.OwnerId';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getComentarios2 from '@salesforce/apex/SAC_LCMP_BtnComentarioTarea.getComentarios2';
import guardarComentario2Apex from '@salesforce/apex/SAC_LCMP_BtnComentarioTarea.guardarComentario2Apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import { RefreshEvent } from 'lightning/refresh';

const fields = [ESTADO, OWNER];

export default class SAC_BtnComentario2Tarea extends LightningElement {
    
    @api recordId;
    @api isLoading = false;
    @track modalComentarios = false;
    comentario2 = false;
    contenidoComentario = '';
    userId = Id;
    deshabilitar = true;

    @wire(getRecord, { recordId: '$recordId', fields })
    tarea2;

    @api
    get comentario2() { 
        let estado = getFieldValue(this.tarea2.data, ESTADO);
        if(estado == 'SAC_EnGestion' || estado == 'SAC_StandBy' || estado == 'SAC_PendienteRevision' || estado == 'SAC_Finalizada' || estado == 'SAC_FinalizadaIncompleta'){            
            return true;  
        }         
        return false;
    }

    @api
    get deshabilitar(){
        let ownerID = getFieldValue(this.tarea2.data, OWNER);
        let btnHabilitado = (ownerID == this.userId)? false : true
        return (ownerID == this.userId)? false : true;
    }

    closeModal() {
        this.modalComentarios = false;
    }

    onChangeInput(event){
        var inputvalue = event.target.value;
        this.disableGuardar = (inputvalue == '') ? true : false;
    }

    insertarComentario(){
        getComentarios2({idTarea: this.recordId}).then(result =>{
            this.contenidoComentario = result;
        })
        .catch(error => {
          
        })    
        this.modalComentarios = true;
    }

    guardarComentarioJS(){ 
        var inp = this.template.querySelector("lightning-input-rich-text[data-my-id=textoComentario]");
        var comentario = inp.value;
         
        guardarComentario2Apex({idTarea: this.recordId, comentario: comentario}).then(result =>{
            this.isLoading = false;
            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Comentarios actualizados',
                    message: this.mensaje,
                    variant: 'success'
                }),
            );
            this.closeModal();
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
}