import { LightningElement, track, api } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OPERATION_OBJECT from '@salesforce/schema/SEG_Operacion__c';
import N_OP_CSO_FIELD from '@salesforce/schema/SEG_Operacion__c.SEG_N_Operaciones__c';
import SR_FIELD from '@salesforce/schema/SEG_Operacion__c.SEG_SR__c';
import USER_FIELD from '@salesforce/schema/SEG_Operacion__c.SEG_Usuario__c';
import Id from '@salesforce/user/Id';

export default class Seg_addOperation extends LightningElement {
	@api recordId;
	@api objectApiName = OPERATION_OBJECT.objectApiName;
	createFields = [N_OP_CSO_FIELD, USER_FIELD];
	userId = Id;
	operationId;

	handleCreateOperation() {
		var inputCmp = this.template.querySelector("lightning-input");
		if (inputCmp.checkValidity()) {
			this.createOperation(inputCmp.value);
		} else {
			inputCmp.reportValidity();
			//inputCmp.setCustomValidity("Ejemplo de validación custom");
		}
	}

	createOperation(nOp) {
		const fields = {};
		fields[N_OP_CSO_FIELD.fieldApiName] = nOp;
		fields[SR_FIELD.fieldApiName] = this.recordId;
		fields[USER_FIELD.fieldApiName] = this.userId;
		const recordInput = { apiName: OPERATION_OBJECT.objectApiName, fields };
		createRecord(recordInput)
			.then(op => {
				this.operationId = op.id;
				this.mostrarToast('success', 'Operaciones añadidas', 'Se han añadido operaciones al caso');
				/*this.dispatchEvent(
					new ShowToastEvent({
						title: "success",
						message: "Operaciones añadidas",
						variant: "success",
						mode: 'dismissable',
						duration: 4000
					})
				)*/
			})
			.catch(error => {
				let errorMessage = error.body ? error.body.message : error.message;
				this.mostrarToast('error', 'No se han podido añadir Operaciones al caso', errorMessage);
				/*this.dispatchEvent(
					new ShowToastEvent({
						title: 'Error añadiendo las operaciones',
						message: error.body.message,
						variant: 'error',
						mode: 'dismissable',
						duration: 4000
					}),
				);*/
			});
		//eval("$A.get('e.force:refreshView').fire();");
		//this.closeModal();
	}

	mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo,
			title: titulo,
			message: mensaje,
			mode: 'dismissable',
			duration: 4000
		}));
		this.closeModal();
	}

	closeModal() {
		const closeEvent = new CustomEvent('close' , {detail: { close }});
		this.dispatchEvent(closeEvent);
	}
}