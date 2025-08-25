import { LightningElement, api, wire } from 'lwc';
import { MessageContext, publish } from 'lightning/messageService';
import derivarInteraccionChannel from "@salesforce/messageChannel/CC_DerivarInteraccionChannel__c";
import { CurrentPageReference } from 'lightning/navigation';

export default class Cc_Solicitar_Informacion_Button extends LightningElement {
	@api recordId;

	@wire(MessageContext) messageContext;

	@wire(CurrentPageReference) pageRef;

	@api invoke() {
		const currentRecordId = this.recordId || this.pageRef?.attributes?.recordId || this.pageRef?.state?.recordId;

		if (currentRecordId) {
			if (this.messageContext) {
				publish(this.messageContext, derivarInteraccionChannel, {
					recordId: currentRecordId,
					origen: 'solicitarInfoButton',
					destino: 'solicitarInfoBotonera',
					datosAdicionales: ''
				});
			}
		}
	}
}