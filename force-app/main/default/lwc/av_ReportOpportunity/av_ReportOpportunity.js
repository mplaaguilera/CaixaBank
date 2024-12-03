import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import { createRecord }     from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

import saveOppRecords       from '@salesforce/apex/AV_NewOpportunity_Controller.saveOppRecords';
import validateOppRecords   from '@salesforce/apex/AV_NewOpportunity_Controller.validateOppRecords';
import deleteReportOpp   	from '@salesforce/apex/AV_NewOpportunity_Controller.deleteReportOpp';
import updateTask           from '@salesforce/apex/AV_TabManagementTask_Controller.updateTaskReportOpp';
import createOppTasks       from '@salesforce/apex/AV_NewOpportunity_Controller.createOppTasks';
import getRecordType        from '@salesforce/apex/AV_TabManagementTask_Controller.getRecordType';
import updateTasksAviso     from '@salesforce/apex/AV_PendingTasks_Controller.updateTasksAviso';


//Labels
import successLabel         from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel from '@salesforce/label/c.AV_CMP_ReportCompleted';
import successDeleteMsgLabel from '@salesforce/label/c.AV_deleteItems';
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';

export default class av_ReportOpportunity extends LightningElement {

	listOppTask = [];
	listTaskPending = [];
	newOpp = [];
	showSpinner = false;
	saveButton = false;
	pendingTask;
	@api recordId;
	@api showFinished = false;
    @api showNewoppo = false;
    @api taskId;
    @api taskIds;

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
	}
	connectedCallback(){
        this.recordId = this.currentPageReference.state.c__recId;
		this.createTarea(this.recordId);
  
	
	}

    getRecordType() {
		getRecordType({id: this.taskIds})
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

    handelCancelNewOpp() {
		this.newOpp = [];
		this.showNewoppo = false;
	}
    handleRefresh() {
		this.listOppTask=[];
	}

    handleDataOpp(event) {
		var listData = [];
		listData.push(event.detail);
		this.newOpp = listData;
		//this.sendDataFlow(event);
	}

    disableSpinner() {
		this.showSpinner = false;
		this.saveButton = false;
		this.cancelButton = false;
	}

	enableSpinner() {
		this.showSpinner = true;
		this.saveButton = true;
		this.cancelButton = true;
	}

    createTarea(){	
		//Update Task
		createOppTasks({id: this.recordId})
			.then(result => {
				if(result != null) {
                    this.taskId = result;
                    this.taskIds = result.Id;
                    this.showFinished = true;
                    const selectedEvent = new CustomEvent("renametab");
                    this.dispatchEvent(selectedEvent);
                    this.getRecordType();
				}else {
					let error = result;
					this.showToast('Error', error.body.message, 'error', 'pester');
					this.disableSpinner();
				}          
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', error.body.message, 'error', 'pester');
				this.disableSpinner();
			});
	}

    updateTarea(listAllOpps){
		var repData = this.template.querySelector('c-av_-finished-task-report-opp').fetchData();
		//Update Task
			updateTask({id: this.taskIds, asunto: repData.asunto, tipo: repData.tipo, comentario: repData.comentario, fecha: repData.fecha, empleado: repData.empleado, cliente: repData.cliente, contacto: repData.contacto})
				.then(result => {
					if(result == 'OK') {
						this.updateOpp(repData, listAllOpps);
					}else {
						//this.showToast('Error', error.body.message, 'error', 'pester');
						this.disableSpinner();
					}          
				})
				.catch(error => {
					console.log(error);
					this.showToast('Error', error.body.message, 'error', 'pester');
					this.disableSpinner();
				});
	}

    handleSave(){
		var listOppTskAux = this.listOppTask;
		var listAllOpps; 
		if(this.newOpp.length > 0) {
			listAllOpps = listOppTskAux.concat(this.newOpp);
		} else {
			listAllOpps = listOppTskAux;
		}
		this.enableSpinner();
		validateOppRecords({listOppRecords: listAllOpps, listParseOppRecords: null})
			.then(result => {
				if(result == 'OK') {
					this.updateTarea(listAllOpps);
				} else if(result == 'KO'){
					this.showToast('Error', errorMsgLabel, 'error', 'pester');
					this.disableSpinner();
				} else if(result.includes('Warning')) {
					this.showToast('Warning', result, 'warning', 'sticky');
					this.updateTarea(listAllOpps);
				}  else {
					this.showToast('Error', result, 'error', 'pester');
					this.disableSpinner();
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', error, 'error', 'pester');
				this.disableSpinner();
		});
	}

	handleCancel(){
		this.enableSpinner();
		deleteReportOpp({taskId: this.taskIds})
			.then(result => {
				if(result == 'OK') {
					this.showToast(successLabel, successDeleteMsgLabel, 'success', 'pester');
					this.disableSpinner();
					const selectedEvent = new CustomEvent("closetab");
					this.dispatchEvent(selectedEvent);
				} else{
					this.showToast('Error', errorMsgLabel, 'error', 'pester');
					this.disableSpinner();
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', error, 'error', 'pester');
				this.disableSpinner();
		});
	}

    updateOpp(repData, listAllOpps){
		saveOppRecords({listOppRecords: listAllOpps})
			.then(result => {
				if(result == 'OK') {
					if (this.listTaskPending.length!=0) {
						this.updateTareasAviso(repData);
					} else {
						this.insertHistorialGestion(repData);
					}
				} else if(result == 'KO'){
					this.showToast('Error', errorMsgLabel, 'error', 'pester');
					this.disableSpinner();
				} else if(result.includes('Warning')) {
					if (this.listTaskPending.length!=0) {
						this.updateTareasAviso(repData);
					} else {
						this.insertHistorialGestion(repData);
					}
				} else {
					this.showToast('Error', result, 'error', 'pester');
					this.disableSpinner();
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', error.body.message, 'error', 'pester');
				this.disableSpinner();
		});
	}

    updateTareasAviso(repData) {
		var dataJson=JSON.stringify(this.listTaskPending);
		updateTasksAviso({jsonString: dataJson})
			.then(result => {
				if(result == 'OK') {
					this.insertHistorialGestion(repData);
				} else if(result == 'KO'){
					this.showToast('Error', errorMsgLabel, 'error', 'pester');
					this.disableSpinner();
				} else {
					this.showToast('Error', result, 'error', 'pester');
					this.disableSpinner();
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', error.body.message, 'error', 'pester');
				this.disableSpinner();
		});
	}

	insertHistorialGestion(repData) {
		//Insert AV_ManagementHistory__c
		var record = {
			"apiName": "AV_ManagementHistory__c",
			"fields": {
				"AV_ActivityId__c": this.taskIds,
				"AV_Date__c": repData.fecha,
				"AV_Type__c": repData.tipo,
				"AV_Status__c": repData.estado,
				"AV_Comment__c": repData.comentario
			}
		};
		createRecord(record)
			.then(() => {
				this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
				this.disableSpinner();
				const selectedEvent = new CustomEvent("closetab");
				this.dispatchEvent(selectedEvent);
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error', 'pester');
				this.disableSpinner();
		});
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

    showToast(title, message, variant, mode) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}



	
}