import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import { createRecord }     from 'lightning/uiRecordApi';

import saveOppRecords       from '@salesforce/apex/AV_NewOpportunity_Controller.saveOppRecords';
import validateOppRecords   from '@salesforce/apex/AV_NewOpportunity_Controller.validateOppRecords';
import updateTask           from '@salesforce/apex/AV_TabManagementTask_Controller.updateTask';
import getRecordType        from '@salesforce/apex/AV_TabManagementTask_Controller.getRecordType';
import updateTasksAviso     from '@salesforce/apex/AV_PendingTasks_Controller.updateTasksAviso';

//Labels
import successLabel         from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel from '@salesforce/label/c.AV_CMP_ReportCompleted';
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';

export default class Av_CloseTaskAndOppTab extends LightningElement {

	listOppTask = [];
	listTaskPending = [];
	newOpp = [];
	showSpinner = false;
	saveButton = false;
	pendingTask;
	launchFlow;
	flowPromise = false;
	@api recordId;
	@api showNewoppo = false;
	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
	}
	connectedCallback(){
		this.recordId = this.currentPageReference.state.c__recId;
		this.getRecordType();
		const selectedEvent = new CustomEvent("renametab");
		this.dispatchEvent(selectedEvent);		
	}

	getRecordType() {
		getRecordType({id: this.recordId})
			.then(recordType => {
				if ('AV_Otros' == recordType ||
				'AV_Priorizador' == recordType ||
				'AV_AlertaComercial' == recordType) {
					this.pendingTask=true;
				} else {
					this.pendingTask=false;
				}
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
			});
	}

	handleNewOpp(){
		this.showNewoppo = true;
	}

	handleRefresh() {
		this.listOppTask=[];
	}

	handleDataReport(event) { //trae del hijo
		var listData = [];
		for(let i = 0; i < this.listOppTask.length; i++) {
			if(this.listOppTask[i].id != event.detail.id) {
				listData.push(this.listOppTask[i]);
			}
		}
		listData.push(event.detail);
		this.listOppTask = listData;
		/*this.enableSpinner();
		saveOppRecords({listOppRecords: this.listOppTask})
			.then(result => {
				if (result != 'OK' && result != 'KO') {
					this.showToast('Error', result, 'error', 'pester');
					this.disableSpinner();
				}
				if (result == 'OK') {
					this.showToast('Success', 'Oportunidad guardada con éxito.', 'success');
					this.disableSpinner();
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', result, 'error', 'pester');
				this.disableSpinner();
		});*/
	}

	handleDataPendingTask(event) { //list Task Pending of aviso  
		var listData = [];
		for(let i = 0; i < this.listTaskPending.length; i++) {
			if(this.listTaskPending[i].id != event.detail.id) {
				listData.push(this.listTaskPending[i]);
			}
		}
		listData.push(event.detail);
		for(let i = 0; i < listData.length; i++) {
			if (listData[i].estado == null){
				listData.splice(i,1);
			}
		}
		this.listTaskPending = listData;
	}

	handleDataOpp(event) {
		var listData = [];
		listData.push(event.detail);
		this.newOpp = listData;
		//this.sendDataFlow(event);
	}

	handelCancelNewOpp() {
		this.newOpp = [];
		this.showNewoppo = false;
	}

	handleSave(button){
		this.template.querySelector('c-av_-finished-task').scrollIntoView(false);
		var listOppTskAux = this.listOppTask;
		var listAllOpps; 
		if(this.newOpp.length > 0) {
			listAllOpps = listOppTskAux.concat(this.newOpp);
		} else {
			listAllOpps = listOppTskAux;
		}
		if(this.flowPromise){
			this.handleSaveAndNewEvent();
		}
		this.enableSpinner();
		validateOppRecords({listOppRecords: listAllOpps, listParseOppRecords: null})
			.then(result => {
				if(result == 'OK') {
					this.updateTarea(listAllOpps, button);
				} else {
					this.setFlowPromiseOFF();
					if(result == 'KO'){
						this.showToast('Error', errorMsgLabel, 'error', 'pester');
						this.disableSpinner();
					} else if(result.includes('Warning')) {
						this.showToast('Warning', result, 'warning', 'sticky');
						this.updateTarea(listAllOpps, button);
					}  else {
						this.showToast('Error', result, 'error', 'pester');
						this.disableSpinner();
					}
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', error, 'error', 'pester');
				this.disableSpinner();
		});
	}

	updateTarea(listAllOpps, button){
		var repData = this.template.querySelector('c-av_-finished-task').fetchData();
		//Update Task
			updateTask({id: this.recordId, estado: repData.estado, canal: repData.canal, tipo: repData.tipo, comentario: repData.comentario, fecha: repData.fecha, acciones: null, motivo: null, valoracion: null,contacto: repData.contacto,activityDateTime:repData.activityDateTime})
				.then(result => {
					if(result == 'OK') {
						this.updateOpp(repData, listAllOpps,button);

					}else {
						this.setFlowPromiseOFF();
						if(result == 'WARNEVENT'){
							this.showToast('Evento relacionado', 'Error insertando el evento relacionado', 'warning', 'pester');
							this.updateOpp(repData, listAllOpps,button);
							
						}else {
							this.showToast('Error', result, 'error', 'pester');
							this.disableSpinner();
						}          
					}
				})
				.catch(error => {
					console.log(error);
					this.showToast('Error', error.body.message, 'error', 'pester');
					this.disableSpinner();
				});
		
	}

	updateOpp(repData, listAllOpps,button){
		saveOppRecords({listOppRecords: listAllOpps})
			.then(result => {
				if(result == 'OK') {
					if(!this.flowPromise){
						if (this.listTaskPending.length!=0) {
							this.updateTareasAviso(repData,button);
						} else {
							this.insertHistorialGestion(repData,button);
						}
					}
				} else {
					this.setFlowPromiseOFF();
					if(result == 'KO'){
						this.showToast('Error', errorMsgLabel, 'error', 'pester');
						this.disableSpinner();
					} else if(result.includes('Warning')) {
						if (this.listTaskPending.length!=0) {
							this.updateTareasAviso(repData,button);
						} else {
							this.insertHistorialGestion(repData,button);
						}
					} else {
						this.showToast('Error', result, 'error', 'pester');
						this.disableSpinner();
					}
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', error.body.message, 'error', 'pester');
				this.disableSpinner();
		});
	}

	updateTareasAviso(repData,button) {
		var dataJson=JSON.stringify(this.listTaskPending);
		updateTasksAviso({jsonString: dataJson})
			.then(result => {
				if(result == 'OK') {
					this.insertHistorialGestion(repData,button);
				
				} else {
					this.setFlowPromiseOFF();
					if(result == 'KO'){
						this.showToast('Error', errorMsgLabel, 'error', 'pester');
						this.disableSpinner();
					} else {
						this.showToast('Error', result, 'error', 'pester');
						this.disableSpinner();
					}
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', error.body.message, 'error', 'pester');
				this.disableSpinner();
		});
	}

	insertHistorialGestion(repData,button) {
		//Insert AV_ManagementHistory__c
		var record = {
			"apiName": "AV_ManagementHistory__c",
			"fields": {
				"AV_ActivityId__c": this.recordId,
				"AV_Date__c": repData.fecha,
				"AV_Type__c": repData.tipo,
				"AV_Status__c": repData.estado,
				"AV_Channel__c": repData.canal,
				"AV_Comment__c":repData.comentario
			}
		};
		createRecord(record)
			.then(() => {
					if (button == true) {
						this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
						this.disableSpinner();
						this.setFlowPromiseON();
					} else {
						this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
						this.disableSpinner();
						const selectedEvent = new CustomEvent("closetab");
						this.dispatchEvent(selectedEvent);
					}
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error', 'pester');
				this.disableSpinner();
		});
	}

	showToast(title, message, variant, mode) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

	disableSpinner() {
		this.showSpinner = false;
		this.saveButton = false;
	}

	enableSpinner() {
		this.showSpinner = true;
		this.saveButton = true;
	}

	handleSaveAndNewEvent(){
		this.launchFlow = true;
	}

	handleSaveAndNewEventButton(){
		this.handleSave(true);
	}

	setFlowPromiseON(){
		this.launchFlow = true;
		this.flowPromise = true;
	}
	setFlowPromiseOFF(){
		if(this.flowPromise){
			this.launchFlow = false;
		}
		this.flowPromise = false;
	}


	get inputVariables(){
 		return [
				{
					name: 'recordId',
					type: 'String',
					value: this.recordId
				}
        ];
	}

	handleStatusChange(event) {
		if(event.detail.status === 'FINISHED'){
			this.launchFlow = false;
			this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
			this.disableSpinner();
			const selectedEvent = new CustomEvent("closetab");
			this.dispatchEvent(selectedEvent);
		}
    }

	handleClose(){
		this.launchFlow = false;
		const selectedEvent = new CustomEvent("closetab");
		this.dispatchEvent(selectedEvent);
	}
}