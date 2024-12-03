import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { NavigationMixin }      from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTaskData         from '@salesforce/apex/AV_TaskReport_Controller.getTaskData';
import insertOrUpdateOpp   from '@salesforce/apex/AV_TaskReport_Controller.insertOrUpdateOpp';
import eventAndTaskProcess   from '@salesforce/apex/AV_TaskReport_Controller.eventAndTaskProcess';
import createTaskOpp   from '@salesforce/apex/AV_TaskReport_Controller.createTaskOpp';
import updateDeleteTaskCheckOnOff from '@salesforce/apex/AV_ReportAppointment_Controller.updateDeleteTaskCheckOnOff';
import updateBackReportTaskEvent from '@salesforce/apex/AV_ReportAppointment_Controller.updateBackReportTaskEvent';
import updateBackReport from '@salesforce/apex/AV_ReportAppointment_Controller.updateBackReport';
import sendOppToGCF from '@salesforce/apex/AV_ReportAppointment_Controller.sendOppToGCF';

//Label
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';

export default class Av_TaskReport extends NavigationMixin(LightningElement) {
    @api recordId;
	@track recordTask;
	@track showSpinner = true;
	@track showAllsBlocks = false;
	@track getTask;
	@track getEvent;
	@track citaComercial = false;
	@track istheretasks = true;
	@track tasksObject;
	buttonEventToNoComercial;
	isLegalEntity = false;
	isShowFlowAction = false;
	isIntouch = false;
	headerId;
	statusTask;
	activityDateTask;
	priorityTask;
	currentPageReference;
	nameAccount;
	idAccount;
	opposObject;
	listOppInsert;
	listOppUpdate;
	showEventPopup = false;
	showNoOpportunityMessage = false;
	showTaskPopup = false;
	nowReference = new Date().toJSON();
	@track radioButtonSelected = false;
	get inputFlowVariables() {
		return [
			{
				name: 'recordId',
				type: 'String',
				value: this.idAccount
			},
			{
				name: 'AV_VinculedOpportunities',
				type: 'String',
				value: this.opposIdsSet
			},
			{
				name:'AV_VinculedMainOpportunity',
				type:'String',
				value:this.oppIdMainCAO
			}
		];
	}

	closeModal(e) {
		this.isShowFlowAction = false;
		this.handleCloseAndFocus();
	}

	focusRecord(){
		this.dispatchEvent(new CustomEvent('focusrecordtab'));
	}

	handleCloseAndFocus(){
		this.dispatchEvent(new CustomEvent('focusrecordtabandclose'));
	}

	@wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

	connectedCallback(){
        this.recordId = this.currentPageReference.state.c__recId;
        const selectedEvent = new CustomEvent("renametab");
		this.dispatchEvent(selectedEvent);
		this.getTaskData();
    }

	getTaskData(){
		getTaskData({id: this.recordId})
		.then(result => {
			this.recordTask = result;
			this.nameAccount = result.accountName;
			this.idAccount = result.accountId;
			this.isLegalEntity = result.accountRt == 'CC_Cliente';
			this.isIntouch = result.contactIntouch;
			this.headerId = result.headerId;
			this.statusTask = result.statusTask;
			this.activityDateTask = result.activityDateTask;
			this.priorityTask = result.priorityTask; 
			this.showSpinner= false;
			this.showAllsBlocks = true;
 		}).catch(error => {
			console.log(error);
			this.showToast('Error', error, 'error', 'pester');
			this.showSpinner= false;
			this.showAllsBlocks = true;
		})
	}

	getDataBlockTask(e) {
 		this.getTask = e.detail.task;
		this.getEvent = e.detail.event;
	}

	handleChangeCita(e){
		this.citaComercial = e.detail.value;
	}

	handleStatusChange(event){
		const status = event.detail.status;
		const outputVariables = event.detail.outputVariables;
		if(status === 'FINISHED') {
			outputVariables.forEach(ot => {
				if(ot.name == 'AV_TaskIdNew'){
					this.taskIdNew = ot.value;
				}   
				if(ot.name == 'AV_NewEventId'){
					this.newEventId = ot.value;
				}
			})
			if(this.opposObject != null ){
				for(let oppoId in this.opposObject){
					if(this.opposObject[oppoId]['agendado']){
						this.opposObject[oppoId]['taskId'] = this.taskIdNew;					
					}
				}
			}
			this.isShowFlowAction = false;
			this.handleCancel();
		}
	}

	handleChangeSinConClient(e){
		this.getTask = e.detail.taskClosed;
		this.getEvent = e.detail.eventClosed;
		if(this.getEvent.comercial == true){
			this.citaComercial = true;
		}
	}

	evaluateAgendeds(e){
		this.template.querySelector('[data-id="saveButton"]').disabled = e.detail;
	}

	setOppoForController(e){
		this.opposObject = e.detail;
		var oppInsert = {};
		var oppUpdate = {};
		for(let oppoId in this.opposObject){
			if (oppoId.includes('idProvisional')) {
				oppInsert[oppoId]= this.opposObject[oppoId];
			} else {
				oppUpdate[oppoId]= this.opposObject[oppoId];
			}
		}
		if (oppInsert != null) {
			this.listOppInsert = oppInsert;
		}
		if (oppUpdate != null) {
			this.listOppUpdate = oppUpdate;
		}
	}

	setTaskVisibility(e){
		this.istheretasks = e.detail;
	}

	setCustomActivityInfoForFlow(info){
		this.opposIdsSet = [];
		this.oppIdMainCAO = '';
		for(let oppoId in info){
			let oppo = info[oppoId];
			if(oppo['agendado']){
				if(oppo['mainVinculed']){
					this.oppIdMainCAO = oppo['id']
				}else{
					this.opposIdsSet.push(oppo['id'])
				}
			}
		}
		if(this.oppIdMainCAO == '' && this.opposIdsSet.length > 0){
			this.oppIdMainCAO = this.opposIdsSet.shift();
		}
	}

	settaskfromcontroller(e){
		this.tasksObject = e.detail;
	}

	handleCancel(){
		this.dispatchEvent(new CustomEvent('closetab'));
	}

	handleError(){
		this.dispatchEvent(new CustomEvent('focustab'));
	}
	
	handleRadioButtonSelection(event){
		this.radioButtonSelected = event.detail.radioButtonSelected;
	}

	showToast(title, message, variant, mode) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

	navegateToAccount() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Account',
				recordId: this.idAccount,
				actionName:'view'
			}
		})
	}

	validateDates(){
		var nowReference = new Date().toJSON().slice(0, 10);
		let response = true;
		for(let oppoId in this.opposObject){
			let date = this.opposObject[oppoId]['proximaGestion'];
			let stage = this.opposObject[oppoId]['newPath'];
			let resolucion = this.opposObject[oppoId]['resolucion'];
			let comentario = this.opposObject[oppoId]['comentario'];
			let agendado = this.opposObject[oppoId]['agendado'];
			let validable = this.opposObject[oppoId]['validable'];
			if (validable) {
				if((stage == 'En gestión/insistir' || stage == 'No apto') && ((date != null && date != undefined && date < nowReference) || (date == null && date == undefined)) && !agendado){
					return  this.opposObject[oppoId]['id'];
				}
				if((stage == 'No interesado') && (resolucion == 'O') && (comentario == null | comentario == '')){
					return  this.opposObject[oppoId]['id'];
				}
			}
		}
		return response;
	}

	setCustomActivityInfoForFlow(info){
		this.opposIdsSet = [];
		this.oppIdMainCAO = '';
		for(let oppoId in info){
			let oppo = info[oppoId];
			if(oppo['agendado']){
				if(oppo['mainVinculed']){
					this.oppIdMainCAO = oppo['id']
				}else{
					this.opposIdsSet.push(oppo['id'])
				}
			}
		}
		if(this.oppIdMainCAO == '' && this.opposIdsSet.length > 0){
			this.oppIdMainCAO = this.opposIdsSet.shift();
		}
	}

	handleLinkOpportunity(){
		this.showNoOpportunityMessage = false;
	}

	handleNoCommercial(){
		let error = null;
		if (error == null) {
			let validateResponse = this.validateDates();
			if(validateResponse == true){
				this.showSpinner = true;
				if (this.buttonEventToNoComercial == 'false') {
					this.focusRecord();
				}
				if (this.listOppInsert != null && Object.keys(this.listOppInsert).length > 0) {
					this.saveOpportunityInsert(this.buttonEventToNoComercial);
				} else if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
					this.saveOpportunityUpdate(this.buttonEventToNoComercial, null);
				} else {
					this.saveTaskAndEvent(null, null, null, this.buttonEventToNoComercial);
				}
			}else{
				this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
				this.showSpinner = false;
			}
		}
		this.showNoOpportunityMessage = false;
	}

	handleSaveAndEvent(){
		this.buttonEventToNoComercial='true';
		let error = null;
		var vacio = '{}';
		var nowReference = new Date().toJSON();
		if(JSON.stringify(this.getEvent) == vacio && this.getTask != null && JSON.stringify(this.getTask) != vacio){
			if (!this.radioButtonSelected) {
				this.showToast('Error', 'Debes seleccionar al menos un radio button en la pestaña "Sin cliente".', 'error', 'pester');
				error='KO';
			}
		}
		if (this.getEvent != null && JSON.stringify(this.getEvent) != vacio) {
			if (this.getEvent.typeEvent == 'CTOOC' && this.getEvent.office == null) {
				this.showToast('Error', 'Cuando se selecciona "Cita en otra oficina" debes rellena el campo "Oficina".', 'error', 'pester');
				error='KO';
			}else if(this.getEvent.activityDateTime == null || this.getEvent.activityDateTime > nowReference){
				this.showToast('Error', 'La fecha no puede ser superior a hoy.', 'error', 'pester');
				error='KO';
			}
		}
		if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
			if (error == null) {
				let validateResponse = this.validateDates();
				if(validateResponse == true){
					this.showSpinner = true;
					if (this.listOppInsert != null && Object.keys(this.listOppInsert).length > 0) {
						this.saveOpportunityInsert('true');
					} else if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
						this.saveOpportunityUpdate('true', null);
					} else {
						this.saveTaskAndEvent(null, null, null, 'true');
					}
				}else{
					this.handleError();
					this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
					this.showSpinner = false;
				}
			}
		} else {
			if(error == null){
				if (JSON.stringify(this.getEvent) != vacio){
					this.handleError();
					this.showEventPopup = true;
					this.showNoOpportunityMessage = true;
				}else {
					this.handleError();
					this.showTaskPopup = true;
					this.showNoOpportunityMessage = true;
				}
			}
		}
	}

	handleSave(){
		this.buttonEventToNoComercial='false';
		let error = null;
		var vacio = '{}';
		var nowReference = new Date().toJSON();		
		if(JSON.stringify(this.getEvent) == vacio && this.getTask != null && JSON.stringify(this.getTask) != vacio){
			if (!this.radioButtonSelected) {
				this.showToast('Error', 'Debes seleccionar al menos un radio button en la pestaña "Sin cliente".', 'error', 'pester');
				error='KO';
			}
		}
		if (this.getEvent != null && JSON.stringify(this.getEvent) != vacio) {
			if (this.getEvent.typeEvent == 'CTOOC' && this.getEvent.office == null) {
				this.showToast('Error', 'Cuando se selecciona "Cita en otra oficina" debes rellena el campo "Oficina".', 'error', 'pester');
				error='KO';
				
			}
			else if(this.getEvent.activityDateTime == null || this.getEvent.activityDateTime.split('T')[0] > nowReference.split('T')[0]){
				this.showToast('Error', 'La fecha no puede ser superior a hoy.', 'error', 'pester');
				error='KO';
			}
		}
		if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
			if (error == null) {
				let validateResponse = this.validateDates();
				if(validateResponse == true){
					this.focusRecord();
					this.showSpinner = true;
					if (this.listOppInsert != null && Object.keys(this.listOppInsert).length > 0) {
						this.saveOpportunityInsert('false');
					} else if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
						this.saveOpportunityUpdate('false', null);
					} else {
						this.saveTaskAndEvent(null, null, null, 'false');
					}
				}else{
					this.handleError();
					this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
					this.showSpinner = false;
				}
			}
		} else {
			if(error == null){
				if (JSON.stringify(this.getEvent) != vacio){
					this.handleError();
					this.showEventPopup = true;
					this.showNoOpportunityMessage = true;
				}else {
					this.handleError();
					this.showTaskPopup = true;
					this.showNoOpportunityMessage = true;
				}
			}
		}
	}

	saveOpportunityInsert(buttonEvent) {
		console.log('Inicia saveOpportunityInsert');
		insertOrUpdateOpp({opportunities:this.listOppInsert, accountId:this.idAccount, isInsert: true})
		.then(result=> {
			if (result != null) {
				if (result.results == 'OK') {
					if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
						this.saveOpportunityUpdate(buttonEvent,result.opposId);
					} else {
						this.saveTaskAndEvent(result.opposId,null,result.opposId,buttonEvent);
					}
				} else {
					this.handleError();
					console.log('saveOpportunityInsert '+result.results);
					this.showToast('Error',result.results,'error','pester');
					this.showSpinner = false;
					if (buttonEvent == 'true') {
						this.isShowFlowAction = false;
					}
				}
			}else {
				this.handleError();
				this.showToast('Error',errorMsgLabel,'error','pester');
				this.showSpinner = false;
				if (buttonEvent == 'true') {
					this.isShowFlowAction = false;
				}
			}
		}).catch(error => {
			this.handleError();
			this.showToast('Error',errorMsgLabel,'error','pester');
			console.log(error);
			this.showSpinner = false;
			if (buttonEvent == 'true') {
				this.isShowFlowAction = false;
			}
		});
	}

	saveOpportunityUpdate(buttonEvent, listOppNews) {
		console.log('Inicia saveOpportunityUpdate');
		insertOrUpdateOpp({ opportunities:this.listOppUpdate, accountId:this.idAccount, isInsert: false})
		.then(result=> {
			if (result != null) {
				if (result.results == 'OK') {
					var listOppIdsAll = result.opposId;
					if (listOppNews != null) {
						Array.prototype.push.apply(listOppIdsAll,listOppNews);
					}
					this.saveTaskAndEvent(listOppNews,result.mapOldOpp,listOppIdsAll,buttonEvent);
				} else {
					if (listOppNews != null) {
						this.backOpportunity(result.results,null,listOppNews,buttonEvent);
					} else {
						this.handleError();
						console.log('saveOpportunityUpdate '+result.results);
						this.showToast('Error',result.results,'error','pester');
						this.showSpinner = false;
						if (buttonEvent == 'true') {
							this.isShowFlowAction = false;
						}
					}
				}
			}else {
				if (listOppNews != null) {
					this.backOpportunity(errorMsgLabel,null,listOppNews,buttonEvent);
				} else {
					this.handleError();
					this.showToast('Error',errorMsgLabel,'error','pester');
					this.showSpinner = false;
					if (buttonEvent == 'true') {
						this.isShowFlowAction = false;
					}
				}
			}
		}).catch(error => {
			if (listOppNews != null) {
				this.backOpportunity(errorMsgLabel,null,listOppNews,buttonEvent);
			} else {
				this.handleError();
				this.showToast('Error',errorMsgLabel,'error','pester');
				console.log(error);
				this.showSpinner = false;
				if (buttonEvent == 'true') {
					this.isShowFlowAction = false;
				}
			}
		});
	}

	saveTaskAndEvent(listOppNews, listOppOlds, listOppIdsAll, buttonEvent) {
		console.log('Inicia saveTaskAndEvent');
		eventAndTaskProcess({event: this.getEvent,task: this.getTask, taskBlock: this.tasksObject, opportunities: this.opposObject, mapOldOpp: listOppOlds, opposId: listOppNews})
		.then(result =>{
			if (result != null) {
				if(result.result == 'OK'){ 
					this.setCustomActivityInfoForFlow(result.opportunities);
					if ((listOppNews != null || listOppOlds != null) && ((result.listTaskChangeDate != null && result.listTaskChangeDate != '') || (result.listTaskToDelete != null && result.listTaskToDelete != '') || (result.listTaskOpportunityDelete != null && result.listTaskOpportunityDelete != ''))) {
						this.saveCheckOnOff(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
					} else if (listOppNews != null || listOppOlds != null) {
						this.saveTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
					} else {
						if (buttonEvent == 'true') {
							this.isShowFlowAction = true;
						}
						else{
							this.handleCancel();
						}
						this.showSpinner = false;
					}
				}else {
					if (listOppNews != null || listOppOlds != null) {
						this.backOpportunity(result.result,listOppOlds,listOppNews,buttonEvent);
					} else {
						this.handleError();
						console.log('createTaskEvent '+result.result);
						if (buttonEvent == 'true') {
							this.isShowFlowAction = false;
						}
						this.showToast('Error', result.result, 'error', 'pester');
						this.showSpinner = false;
					}
				}
			} else {
				if (listOppNews != null || listOppOlds != null) {
					this.backOpportunity(errorMsgLabel,listOppOlds,listOppNews,buttonEvent);
				}else{
					this.handleError();
					if(buttonEvent == 'true') {
						this.isShowFlowAction = false;
					}
					this.showToast('Error', errorMsgLabel, 'error', 'pester');
					this.showSpinner = false;
				}
			}
		}).catch(error => {
			if (listOppNews != null || listOppOlds != null) {
				this.backOpportunity(errorMsgLabel,listOppOlds,listOppNews,buttonEvent);
			}else{
				this.handleError();
				if(buttonEvent == 'true') {
					this.isShowFlowAction = false;
				}
				this.showToast('Error', errorMsgLabel, 'error', 'pester');
				this.showSpinner = false;
			}
			console.log(error);
		});
	}

	saveCheckOnOff(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, resultTaskEvent) {
		console.log('Inicia saveCheckOnOff');
		updateDeleteTaskCheckOnOff({listTaskChangeDate: resultTaskEvent.listTaskChangeDate,  listTaskToDelete: resultTaskEvent.listTaskToDelete,  listTaskOpportunityDelete: resultTaskEvent.listTaskOpportunityDelete})
		.then(result => {
			if (result != null) {
				if(result == 'OK'){ 
					if (listOppNews != null || listOppOlds != null) {
						this.saveTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, resultTaskEvent);
					}
				}else {
					resultTaskEvent.dataBack.insertTasksDelete = null;
					resultTaskEvent.dataBack.insertTaskOppDelete = null;
					resultTaskEvent.dataBack.updateTaskUpdated = null;
					this.backTaskEvent(result,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
				}
			} else {
				resultTaskEvent.dataBack.insertTasksDelete = null;
				resultTaskEvent.dataBack.insertTaskOppDelete = null;
				resultTaskEvent.dataBack.updateTaskUpdated = null;
				this.backTaskEvent(errorMsgLabel,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
			}
		}).catch(error => {
			resultTaskEvent.dataBack.insertTasksDelete = null;
			resultTaskEvent.dataBack.insertTaskOppDelete = null;
			resultTaskEvent.dataBack.updateTaskUpdated = null;
			this.backTaskEvent(errorMsgLabel,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
			console.log(error);
		});
	}

	saveTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, resultTaskEvent) {
		console.log('Inicia saveTaskOpp');
		createTaskOpp({jsonResultTaskEvent: JSON.stringify(resultTaskEvent), task: this.getTask})
		.then(result =>{
			if (result != null) {
				if(result == 'OK'){
					if(listOppIdsAll != null) { 
						this.sendToGcf(listOppIdsAll,buttonEvent);
					}else{
						if (buttonEvent == 'true') {
							this.isShowFlowAction = true;
						}
						else{
							this.handleCancel();
						}
						this.showSpinner = false;
					}
				}else {
					this.backTaskEvent(result,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
				}
			} else {
				this.backTaskEvent(errorMsgLabel,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
			}
		}).catch(error => {
			this.backTaskEvent(errorMsgLabel,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
			console.log(error);
		})
	}

	sendToGcf(listIdsOpps, buttonEvent) {
		console.log('Inicia sendToGcf');
		sendOppToGCF({listIdsOppUpdateCreated:listIdsOpps})
		.then(result =>{
			if(buttonEvent == 'true'){
				this.isShowFlowAction = true;
			}
			else{
				this.handleCancel();
			}
			this.showSpinner = false;
			if(result != 'OK') {
				console.log('sendOppToGCF '+result);
			}	
		}).catch(error => {
			if(buttonEvent == 'true'){
				this.isShowFlowAction = true;
			}
			else{
				this.handleCancel();
			}
			this.showSpinner = false;
			console.log('sendOppToGCF '+error);
		})
	}

	backOpportunity(errorOpp, listOppUpdate, listIdOppInsert, buttonEvent) {
		console.log('Inicia backOpportunity');
		updateBackReport({jsonListOpp: JSON.stringify(listOppUpdate), listIdsOpp: listIdOppInsert})
		.then(result => {
			if(result != null) {
				console.log('Error back Opp: '+result);
			}
			this.handleError();
			if (buttonEvent == 'true') {
				this.isShowFlowAction = false;
			}
			this.showToast('Error', errorOpp, 'error', 'pester');
			this.showSpinner = false;
		}).catch(error => {
			this.handleError();
			this.showToast('Error',errorOpp,'error','pester');
			console.log('Error back Opp catch: '+error);
			if (buttonEvent == 'true') {
				this.isShowFlowAction = false;
			}
			this.showSpinner = false;
		});
	}

	backTaskEvent(errorView, listOppUpdate, listIdOppInsert, backResult, buttonEvent) {
		console.log('Inicia backTaskEvent');
		updateBackReportTaskEvent({jsonBackAll: backResult})
		.then(result => {
			if(result != null) {
				console.log('Error back event/task: '+result);
			}
			if (listOppUpdate != null || listIdOppInsert != null) {
				this.backOpportunity(errorView,listOppUpdate,listIdOppInsert,buttonEvent);
			} else {
				this.handleError();
				if (buttonEvent == 'true') {
					this.isShowFlowAction = false;
				}
				this.showToast('Error', errorView, 'error', 'pester');
				this.showSpinner = false;
			}
		}).catch(error => {
			if (listOppUpdate != null || listIdOppInsert != null) {
				this.backOpportunity(errorView,listOppUpdate,listIdOppInsert,buttonEvent);
			} else {
				this.handleError();
				this.showToast('Error',errorView,'error','pester');
				console.log('Error back event/task catch: '+error);
				if (buttonEvent == 'true') {
					this.isShowFlowAction = false;
				}
				this.showSpinner = false;
			}
		});
	}
}