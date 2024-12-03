import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { NavigationMixin }      from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getEventData         from '@salesforce/apex/AV_EventReport_Controller.getEventData';
import insertOrUpdateOpp from '@salesforce/apex/AV_EventReport_Controller.insertOrUpdateOpp';
import eventAndTaskProcess   from '@salesforce/apex/AV_EventReport_Controller.eventAndTaskProcess';
import createTaskOpp   from '@salesforce/apex/AV_EventReport_Controller.createTaskOpp';
import updateDeleteTaskCheckOnOff from '@salesforce/apex/AV_ReportAppointment_Controller.updateDeleteTaskCheckOnOff';
import updateBackReportTaskEvent from '@salesforce/apex/AV_ReportAppointment_Controller.updateBackReportTaskEvent';
import updateBackReport from '@salesforce/apex/AV_ReportAppointment_Controller.updateBackReport';
import sendOppToGCF from '@salesforce/apex/AV_ReportAppointment_Controller.sendOppToGCF';

//Label
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';

export default class Av_EventReport extends NavigationMixin(LightningElement) {

	@api recordId;
	@track showSpinner = true;
	@track citaComercial = false;
	@track istheretasks = true;
	@track radioButtonSelected = false;
	@track getInfoContact;
	@track listOppInsert;
	@track listOppIdsNews;
	@track listOppUpdate;
	@track listOppOld;
	@track listOppIdsAll;
	isLegalEntity = false;
	isDataLoaded = false;
	isIntouch = false;
	buttonEventToNoComercial;
	comment;
	dateEvent;
	idAccount;
	headerId;
	accountName;
	subjectEvent;
	statusEvent;
	endDateTime;
	startDateTime;
	idEvent;
	isShowFlowAction = false;
	showSpinner = false;
	showNoOpportunityMessage = false;

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
        this.getEventData();
    }

	getEventData(){
		getEventData({id: this.recordId})
		.then(result => {
			this.idEvent = result.id;
			this.comment = result.comment;
			this.type = result.tipo;
			this.accountName = result.accountName;
			this.subjectEvent = result.subjectEvent;
			this.idAccount = result.accountId;
			this.isLegalEntity = result.accountRt == 'CC_Cliente';
			this.statusEvent = result.statusEvent;
			this.endDateTime = result.endDateTime; 
			this.startDateTime = result.startDateTime;
			this.isIntouch = result.contactIntouch;
			this.headerId = result.headerId;
			this.isDataLoaded = true;
			this.showSpinner = false;
		})
		.catch(error => {
			console.log(error);
			this.showToast('Error', error, 'error', 'pester');
			this.showSpinner = false;
		})
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

	handleChangeCita(e){
		this.citaComercial = e.detail.value;
	}

	setInfo(e){
		this.getInfoContact = e.detail;
	}

	handleCancel(){
		this.dispatchEvent(new CustomEvent('closetab'));
	}

	handleRadioButtonSelection(event){
		this.radioButtonSelected = event.detail.radioButtonSelected;
	}

	evaluateAgendeds(e){
		this.template.querySelector('[data-id="saveButton"]').disabled = e.detail;
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

	setTaskVisibility(e){
		this.istheretasks = e.detail;
	}

	settaskfromcontroller(e){
		this.tasksObject = e.detail;
	}

	handleError(){
		this.dispatchEvent(new CustomEvent('focustab'));
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


	handleSave(){
		this.buttonEventToNoComercial='false';
		let error = null;
		var nowReference = new Date().toJSON();
		if(this.getInfoContact.activityDateTime == null || this.getInfoContact.activityDateTime.split('T')[0] > nowReference.split('T')[0]){
			this.handleError();
			this.showToast('Error', 'Si quieres agendar un evento futuro planifique una cita.', 'error', 'pester');
			error='KO';
		} else if (this.getInfoContact.type == 'CTOOC' && this.getInfoContact.office == null) {
			this.handleError();
			this.showToast('Error', 'Cuando se selecciona "Cita en otra oficina" debes rellena el campo "Oficina".', 'error', 'pester');
			error='KO';
		}

		if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
			if(error == null) {
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
				this.handleError();
				this.showNoOpportunityMessage = true;
			}
		}
	}

	handleSaveAndEvent(){
		this.buttonEventToNoComercial ='true';
		let error = null;
		var nowReference = new Date().toJSON();
		if(this.getInfoContact.activityDateTime == null || this.getInfoContact.activityDateTime.split('T')[0] > nowReference.split('T')[0]){
			this.handleError();
			this.showToast('Error', 'Si quieres agendar un evento futuro planifique una cita.', 'error', 'pester');
			error='KO';
		} else if (this.getInfoContact.type == 'CTOOC' && this.getInfoContact.office == null) {
			this.handleError();
			this.showToast('Error', 'Cuando se selecciona "Cita en otra oficina" debes rellena el campo "Oficina".', 'error', 'pester');
			error='KO';
		}

		if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
			if(error == null) {
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
				this.handleError();
				this.showNoOpportunityMessage = true;
			}
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



	saveOpportunityInsert(buttonEvent){
		console.log('Inicia saveOpportunityInsert');
		insertOrUpdateOpp({ opportunities:this.listOppInsert, accountId:this.idAccount, isInsert: true})
		.then(result=> {
			if (result != null) {
				if (result.results == 'OK') {
					if(this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0){
						this.listOppIdsNews = result.opposId;
						this.saveOpportunityUpdate(buttonEvent,this.listOppIdsNews);
					}
					else{
						this.saveTaskAndEvent(this.listOppIdsNews, null,this.listOppIdsNews, buttonEvent);
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
		})
	}

	saveOpportunityUpdate(buttonEvent,listOppNews) {
		console.log('Inicia saveOpportunityUpdate');
		insertOrUpdateOpp({ opportunities:this.listOppUpdate, accountId:this.idAccount,isInsert: false})
			.then(result=> {
				if (result != null) {
					if (result.results == 'OK') {
						this.listOppOld = result.mapOldOpp;
						this.listOppIdsAll = result.opposId;
						if (listOppNews != null) {
							Array.prototype.push.apply(this.listOppIdsAll,listOppNews);
						}
 						this.saveTaskAndEvent(listOppNews,this.listOppOld,this.listOppIdsAll,buttonEvent);
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
			})
	}

	saveTaskAndEvent(listOppNews, listOppOlds, listOppIdsAll, buttonEvent) {
		console.log('Inicia saveTaskAndEvent');
		eventAndTaskProcess({event: this.getInfoContact, taskBlock: this.tasksObject, opportunities: this.opposObject, mapOldOpp: listOppOlds, opposId: listOppNews})
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
		createTaskOpp({jsonResultTaskEvent: JSON.stringify(resultTaskEvent), event: this.getInfoContact})
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