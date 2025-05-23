import { LightningElement, api, wire } from 'lwc';
import { MessageContext, publish } from 'lightning/messageService';
import { CurrentPageReference } from 'lightning/navigation';
import derivarInteraccionChannel from "@salesforce/messageChannel/CC_DerivarInteraccionChannel__c";

export default class ccRemitirColaboradorQuickAction extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    @wire(MessageContext) messageContext;

    @api invoke() {
        const recordId = this.pageRef?.attributes?.recordId || this.pageRef?.state?.recordId;
        if (recordId && this.messageContext) {
            publish(this.messageContext, derivarInteraccionChannel, {
                recordId,
                origen: 'remitirColaboradorButton',
                destino: 'remitirColaboradorBotonera',
                datosAdicionales: ''
            });
        }
    }
}