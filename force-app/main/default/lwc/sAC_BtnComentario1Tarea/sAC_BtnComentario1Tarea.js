import { LightningElement, wire, api, track} from 'lwc';
import ESTADO from '@salesforce/schema/SAC_Accion__c.SAC_Estado__c';
import OWNER from '@salesforce/schema/SAC_Accion__c.OwnerId';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getComentarios1 from '@salesforce/apex/SAC_LCMP_BtnComentarioTarea.getComentarios1';
import guardarComentario1Apex from '@salesforce/apex/SAC_LCMP_BtnComentarioTarea.guardarComentario1Apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import { RefreshEvent } from 'lightning/refresh';

const fields = [ESTADO, OWNER];

export default class SAC_BtnComentario1Tarea extends LightningElement {

    @api recordId;
    @api isLoading = false;
    @track modalComentarios = false;
    comentario1 = false;
    contenidoComentario = '';
    userId = Id;
    deshabilitar = true;

    @wire(getRecord, { recordId: '$recordId', fields })
    tarea1;

    @api
    get comentario1() {
        let estado = getFieldValue(this.tarea1.data, ESTADO);
        return (estado == 'SAC_PendienteEnviar' || estado == 'SAC_PendienteAsignar');
    }
    @api
    get deshabilitar(){
        let ownerID = getFieldValue(this.tarea1.data, OWNER);
        return (ownerID == this.userId)? false : true;
    }

    closeModal() {
        this.modalComentarios = false;
    }
    
    insertarComentario(){
        this.modalComentarios = true;
    }

   

    insertarComentario(){
        getComentarios1({idTarea: this.recordId}).then(result =>{
            this.contenidoComentario = result;
        })
        .catch(error => {
          
        })    
        this.modalComentarios = true;
    }


    guardarComentarioJS(){ 
        var inp = this.template.querySelector("lightning-input-rich-text[data-my-id=textoComentario]");
        var comentario = inp.value;
         
        guardarComentario1Apex({idTarea: this.recordId, comentario: comentario}).then(result =>{
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