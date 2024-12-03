import { LightningElement,api,wire,track} from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { NavigationMixin }      from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import sendDataToController from '@salesforce/apex/AV_ReportAppointment_Controller.processReportData';
import updateBackReport from '@salesforce/apex/AV_ReportAppointment_Controller.updateBackReport';
import unWrappOpportunities from '@salesforce/apex/AV_ReportAppointment_Controller.unWrappOpportunities';
import sendOppToGCF from '@salesforce/apex/AV_ReportAppointment_Controller.sendOppToGCF';
import updateBackReportTaskEvent from '@salesforce/apex/AV_ReportAppointment_Controller.updateBackReportTaskEvent';
import createTaskOpp from '@salesforce/apex/AV_ReportAppointment_Controller.createTaskOpp';
import updateTaskBlock from '@salesforce/apex/AV_ReportAppointment_Controller.updateTaskBlock';
import updateDeleteTaskCheckOnOff from '@salesforce/apex/AV_ReportAppointment_Controller.updateDeleteTaskCheckOnOff';

//Label
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';

export default class Av_ReportAppointment extends NavigationMixin(LightningElement) {

	@api recordId;
	@api accountName;
@api objectApiName;

	clientid;
	oppoName;
	oppoStage;
	oppoFecha;
	@track iconClient = "standard:report"
	@track iconOpportunity = "standard:opportunity"
	@track isLegalEntity;
	@track isIntouch;
	@track citaComercial = false;
	@track opposObject;
	@track listOppInsert;
	@track listOppIdsNews;
	@track listOppIdsAll;
	@track listOppOld;
	@track listOppUpdate;
	@track tasksObject;
	@track taskOrEventInfo;
	@track radioButtonSelected = false;
	buttonEventToNoComercial;
	opporeporting;
	isChecked;
	taskIdNew;
	newEventId;
	isShowFlowAction = false;
	istheretasks = true;
	showSpinner = false;
	showEventPopup = false;
	showTaskPopup =  false;
	showNoOpportunityMessage = false;
	disableButtonCancel = false;
	disableButtonSave = false;
	disableButtonSaveAndEvent = false;
	opposIdsSet = [];
	oppIdMainCAO = '';
	customActivitys = [];
	isReportOpportunity;
	get inputFlowVariables() {
		return [
			{
				name: 'recordId',
				type: 'String',
				value: this.clientid
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

	connectedCallback(){
		this.recordId = this.currentPageReference.state.c__recId;
		this.accountName = this.currentPageReference.state.c__id;
		this.isLegalEntity = this.currentPageReference.state.c__rt == 'CC_Cliente';
		this.isIntouch = this.currentPageReference.state.c__intouch == 'true';
		this.isReportOpportunity = this.currentPageReference.state.c__objectname == 'Opportunity';
		this.clientid = (this.isReportOpportunity) ? this.currentPageReference.state.c__account : this.recordId;
	}

	setOppoName(e){
		this.opporeporting = e.detail.reportingopp;
		this.oppoName  = e.detail.reportingopp.Name;
		this.oppoStage = e.detail.reportingopp.Stage;
		let unOrderedDateString = e.detail.reportingopp.CloseDate;
		if(unOrderedDateString != null && unOrderedDateString != undefined){
			let unOrderedDate = unOrderedDateString.split('-');
			this.oppoFecha = (unOrderedDate[2] + '/'+unOrderedDate[1]+'/'+unOrderedDate[0]);
		}
	}

	navegateToAccount() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Account',
				recordId: this.clientid,
				actionName:'view'
			}
		})
	}

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
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
			this.hideFlowAction(event);
			this.handleCancel();
		}
	}

	handleChangeCita(e){
		this.citaComercial = e.detail.value;
		if(e.detail.value == true){
			this.opposObject = {};
			this.listOppInsert = {};
			this.listOppUpdate = {};
		}
	}

	focusRecord(){
		this.dispatchEvent(new CustomEvent('focusrecordtab'));
	}

	handleCancel(){
		this.dispatchEvent(new CustomEvent('closetab'));
	}

	handleCloseAndFocus(){
		this.dispatchEvent(new CustomEvent('focusrecordtabandclose'));
	}
	
	handleError(){
		this.dispatchEvent(new CustomEvent('focustab'));
	}

	handleRadioButtonSelection(event){
		this.radioButtonSelected = event.detail.radioButtonSelected;
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
					this.createOpportunityInsert(this.buttonEventToNoComercial);
				} else if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
					this.createOpportunityUpdate(this.buttonEventToNoComercial, null);
				} else {
					this.createTaskEvent(null, null, null, this.buttonEventToNoComercial);
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
		var nowReference = new Date().toJSON();
		let error = null;
		if (this.taskOrEventInfo.type == 'task'){
			if (!this.radioButtonSelected) {
				this.handleError();
				this.showToast('Error', 'Por favor, seleccione un tipo de tarea.', 'error', 'pester');
				error='KO';
			}
		} else if (this.taskOrEventInfo.type == 'event') {
			if (this.taskOrEventInfo.typeEvent == 'CTOOC' && this.taskOrEventInfo.office == null) {
				this.handleError();
				this.showToast('Error', 'Cuando se selecciona "Cita en otra oficina" debes rellena el campo "Oficina".', 'error', 'pester');
				error='KO';
			} else if(this.taskOrEventInfo.activityDateTime == null || this.taskOrEventInfo.activityDateTime > nowReference){
				this.handleError();
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
						this.createOpportunityInsert('true');
					} else if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
						this.createOpportunityUpdate('true', null);
					} else {
						this.createTaskEvent(null, null, null, 'true');
					}
				}else{
					this.handleError();
					this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
					this.showSpinner = false;
				}
			}
		} else {
			if(error == null){
				if(this.taskOrEventInfo.type == 'event'){
					this.handleError();
					this.showEventPopup = true;
					this.showNoOpportunityMessage = true;
				}else  if(this.taskOrEventInfo.type == 'task'){
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
		var nowReference = new Date().toJSON();
		if(this.taskOrEventInfo.type == 'task'){
			if (!this.radioButtonSelected) {
				this.handleError();
				this.showToast('Error', 'Por favor, seleccione un tipo de tarea.', 'error', 'pester');
				error='KO';
			}
		} else if (this.taskOrEventInfo.type == 'event') {

			if (this.taskOrEventInfo.typeEvent == 'CTOOC' && this.taskOrEventInfo.office == null) {
				this.handleError();
				this.showToast('Error', 'Cuando se selecciona "Cita en otra oficina" debes rellena el campo "Oficina".', 'error', 'pester');
				error='KO';
			}else if(this.taskOrEventInfo.activityDateTime == null || this.taskOrEventInfo.activityDateTime > nowReference){
				this.handleError();
				this.showToast('Error', 'La fecha no puede ser superior a hoy.', 'error', 'pester');
				error='KO';
			}
		}

		if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
			if(error == null) {
				let validateResponse = this.validateDates();//If all the dates are correct return true.Either return the Id of the first oppo to fail
				if(validateResponse == true){
					this.focusRecord();
					this.showSpinner = true;
					if (this.listOppInsert != null && Object.keys(this.listOppInsert).length > 0) {
						this.createOpportunityInsert('false');
					} else if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
						this.createOpportunityUpdate('false', null);
					} else {
						this.createTaskEvent(null, null, null, 'false');
					}
				}else{
					this.handleError();
					this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
					this.showSpinner = false;
				}
			}
		} else {
			if(error == null){
				if(this.taskOrEventInfo.type == 'event'){
					this.handleError();
					this.showEventPopup = true;
					this.showNoOpportunityMessage = true;
				}else  if(this.taskOrEventInfo.type == 'task'){
					this.handleError();
					this.showTaskPopup = true;
					this.showNoOpportunityMessage = true;
				}
			}
		}
	}

	createOpportunityInsert(buttonEvent) {
		console.log('Inicia createOpportunityInsert');
		unWrappOpportunities({ opportunities:this.listOppInsert, accountId:this.clientid, isInsert: true})
			.then(result=> {
				if (result != null) {
					if (result.results == 'OK') {
						this.listOppIdsNews = result.opposId;
 						this.createOpportunityUpdate(buttonEvent,this.listOppIdsNews);
					} else {
						this.handleError();
						console.log('createOpportunityInsert '+result.results);
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

	createOpportunityUpdate(buttonEvent,listOppNews) {
		console.log('Inicia createOpportunityUpdate');
		unWrappOpportunities({ opportunities:this.listOppUpdate, accountId:this.clientid,isInsert: false})
			.then(result=> {
				if (result != null) {
					if (result.results == 'OK') {
						this.listOppOld = result.mapOldOpp;
						this.listOppIdsAll = result.opposId;
						if (listOppNews != null) {
							Array.prototype.push.apply(this.listOppIdsAll,listOppNews);
						}
 						this.createTaskEvent(listOppNews,this.listOppOld,this.listOppIdsAll,buttonEvent);
					} else {
						if (listOppNews != null) {
							this.backOpportunity(result.results,null,listOppNews,buttonEvent);
						} else {
							this.handleError();
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

	createTaskEvent(listOppNews, listOppOlds, listOppIdsAll, buttonEvent) {
		console.log('Inicia createTaskEvent');	
		sendDataToController({ eventOrTsk: this.taskOrEventInfo, opportunities: this.opposObject, mapOldOpp: listOppOlds, opposId: listOppNews})
		.then(result =>{
			if (result != null) {
				if(result.results == 'OK'){ 
					this.setCustomActivityInfoForFlow(result.opportunities);
					if ((listOppNews != null || listOppOlds != null) && ((result.listTaskChangeDate != null && result.listTaskChangeDate != '') || (result.listTaskToDelete != null && result.listTaskToDelete != '') || (result.listTaskOpportunityDelete != null && result.listTaskOpportunityDelete != ''))) {
						this.updateDeleteTask(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
					} else if (this.tasksObject != null) {
						this.blockTask(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
					} else if (listOppNews != null || listOppOlds != null) {
						this.createTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
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
						this.backOpportunity(result.results,listOppOlds,listOppNews,buttonEvent);
					} else {
						this.handleError();
						console.log('createTaskEvent '+result.results);
						if (buttonEvent == 'true') {
							this.isShowFlowAction = false;
						}
						this.showToast('Error', result.results, 'error', 'pester');
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
		})
	}

	updateDeleteTask(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, resultTaskEvent) {
		console.log('Inicia updateDeleteTask');
		updateDeleteTaskCheckOnOff({listTaskChangeDate: resultTaskEvent.listTaskChangeDate,  listTaskToDelete: resultTaskEvent.listTaskToDelete,  listTaskOpportunityDelete: resultTaskEvent.listTaskOpportunityDelete})
		.then(result => {
			if (result != null) {
				if(result == 'OK'){ 
					if (this.tasksObject != null) {
						this.blockTask(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, resultTaskEvent);
					} else if (listOppNews != null || listOppOlds != null) {
						this.createTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, resultTaskEvent);
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
		})
	}

	blockTask(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, resultTaskEvent) {
		console.log('Inicia blockTask');
		updateTaskBlock({eventOrTsk: this.taskOrEventInfo, tasks: this.tasksObject})
		.then(result =>{
			if (result != null) {
				if(result.results == 'OK'){
					if (listOppNews != null || listOppOlds != null) {
						if (resultTaskEvent.dataBack.updateTaskUpdated != null) {
							resultTaskEvent.dataBack.updateTaskUpdated = resultTaskEvent.dataBack.updateTaskUpdated.concat(result.updateTaskUpdated);
						} else {
							resultTaskEvent.dataBack.updateTaskUpdated = result.updateTaskUpdated;
						}
						resultTaskEvent.dataBack.deleteManageHistInsert = result.deleteManageHistInsert;
						this.createTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent,resultTaskEvent);
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
					this.backTaskEvent(result.results,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
				}
			} else {
				this.backTaskEvent(errorMsgLabel,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
			}
		}).catch(error => {
			this.backTaskEvent(errorMsgLabel,listOppOlds,listOppNews,JSON.stringify(resultTaskEvent.dataBack),buttonEvent);
			console.log(error);
		})
	}

	createTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, resultTaskEvent) {
		console.log('Inicia createTaskOpp');
		createTaskOpp({jsonResultTaskEvent: JSON.stringify(resultTaskEvent)})
		.then(result =>{
			if (result != null) {
				if(result == 'OK'){
					if(listOppIdsAll != null) { 
						this.sendToGcfOpportunity(listOppIdsAll,buttonEvent);
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

	backOpportunity(errorOpp,listOppUpdate,listIdOppInsert,buttonEvent) {
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

	backTaskEvent(errorView,listOppUpdate,listIdOppInsert,backResult,buttonEvent) {
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

	sendToGcfOpportunity(listIdsOpps,buttonEvent) {
		console.log('Inicia sendToGcfOpportunity');
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

			if(!validable){
				continue;
			}
			if((stage == 'En gestión/insistir' || stage == 'No apto') &&
			((date != null && date != undefined && date < nowReference) || (date == null && date == undefined)) && !agendado){
				return  this.opposObject[oppoId]['id'];
			}
			if((stage == 'No interesado') && (resolucion == 'O') && (comentario == null | comentario == '')){
				return  this.opposObject[oppoId]['id'];
			}
		}
		return response;
	}

	evaluateAgendeds(e){
		this.disableButtonSave = e.detail;
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

	getContactRecord(id){
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName:'Opportunity',
				recordId:id,
				actionName:'view'
			}
		})
	}

	goNewEvent(id){
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName:'Event',
				recordId:id,
				actionName:'view'
			}
		})
	}

	settaskfromcontroller(e){
		this.tasksObject = e.detail;
	}

	setTaskVisibility(e){
		this.istheretasks = e.detail;
	}

	hideFlowAction(e){
		this.isShowFlowAction = false;
	}

	closeModal(e) {
		this.isShowFlowAction = false;
		this.handleCloseAndFocus();
	}

	setInfo(e){
		this.taskOrEventInfo = e.detail;
		if((this.taskOrEventInfo.type == 'task') && (this.citaComercial)){
			this.citaComercial = false;
		}
		if((this.taskOrEventInfo.type == 'event') && (this.taskOrEventInfo.comercial == true)){
			this.citaComercial = true;
		}
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

	evaluateAgendeds(e){
		this.template.querySelector('[data-id="saveButton"]').disabled = e.detail;
	}

	switchButtons(){
		this.disableButtonCancel = true;
		this.disableButtonSave = true;
		this.disableButtonSaveAndEvent = true;
	}
}