import { LightningElement, api, wire } from 'lwc';
import { MessageContext, publish } from 'lightning/messageService';
import derivarInteraccionChannel from "@salesforce/messageChannel/CC_DerivarInteraccionChannel__c";
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';

export default class Cc_Responder_Cliente_Button extends LightningElement {
    @api recordId;
    subscription = null;
    currentRecordId;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    pageRef;

    connectedCallback() {
        // Intentar obtener el recordId de diferentes fuentes
        this.currentRecordId = this.recordId || 
            (this.pageRef?.attributes?.recordId) || 
            (this.pageRef?.state?.recordId);           
   
    }

    renderedCallback() {

        let datosAdicionales = '';
        let origen = 'remitirColaboradorButton';
        let destino = 'remitirColaboradorBotonera';
        
        if (this.currentRecordId) {      
            // Publicar el mensaje
            this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
            // Cerrar el Quick Action
            this.cerrarQuickAction();
        } else {
            this.cerrarQuickAction();
        }
    }

    publicarMensajeDerivarInteraccion(origenDerivacion, destinoDerivacion, datosAdicionales) {       
        if (this.messageContext) {
            const payload = {
                recordId: this.currentRecordId,
                origen: origenDerivacion,
                destino: destinoDerivacion,
                datosAdicionales: datosAdicionales
            };
            publish(this.messageContext, derivarInteraccionChannel, payload);
        }
    }

    cerrarQuickAction() {
       //dar un tiempo para que se publique en el canal de mensajes
       window.setTimeout(() => this.dispatchEvent(new CloseActionScreenEvent()), 100);
    }
}