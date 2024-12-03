import { LightningElement,api,wire,track} from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { NavigationMixin }      from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import sendOppToGCF from '@salesforce/apex/AV_ReportAppointment_Controller.sendOppToGCF';
import validatePFNewOppAndForbiddenWords from '@salesforce/apex/AV_NewOpportunity_Controller.validatePFNewOppAndForbiddenWords';
import getCallInfo from '@salesforce/apex/AV_CallReport_Controller.getCallInfo';
import processEventAndCall from '@salesforce/apex/AV_CallReport_Controller.processEventAndCall';
import createOrUpdateOpportunitiesFromReport    			   from '@salesforce/apex/AV_CallReport_Controller.createOrUpdateOpportunitiesFromReport';
import processCheckOnOffCreate				    			   from '@salesforce/apex/AV_NewEvent_Controller.processCheckOnOffCreate';
import processCheckOnOffUpdate				    			   from '@salesforce/apex/AV_NewEvent_Controller.processCheckOnOffUpdate';
import processCheckOnOffDelete				    			   from '@salesforce/apex/AV_NewEvent_Controller.processCheckOnOffDelete';
import backClosedTaskReport					  	    		   from '@salesforce/apex/AV_NewEvent_Controller.backClosedTaskReport';
import processVinculations					  	    		   from '@salesforce/apex/AV_CallReport_Controller.processVinculations';
import backCreatedOrUpdtOppos     	   		    			   from '@salesforce/apex/AV_NewEvent_Controller.backReportOppos';
import backUpsertedEventAndCall     	   		    		   from '@salesforce/apex/AV_CallReport_Controller.backUpsertedEventAndCall';




//Label
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';
const IDPROVISIONAL = 'idProvisional';

export default class Av_callReport extends NavigationMixin(LightningElement) {

	@api recordId;
	@api accountName;
	@api objectApiName;
	clientid;
	oppoName;
	oppoStage;
	oppoFecha;
	objectInfo;
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
	@track isShowNewEvent;
	@track nolocalizado; 
	@track optionevent; 
	@track clientetab ='tabEvent';  
	noLocalizadoAfterSave= false;  
	goPlanAppointment;
	objectInfo;
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
	disableButtonSaveAndEvent = true;
	opposIdsSet = [];
	oppIdMainCAO = '';
	customActivitys = [];
	opposScheduled = [];
	opposList = [];
	opposVinculed = [];
	isReportOpportunity = false;
	accountRt;
	loadedData = false;
	callRecord;
	nolocalizadocb;
	personal = false;
	showOpportunities = true;
	noCheck = true;
	callId;
	gestorAsignado;
	evtUpserted;
	mapProvIdToBBDDId = {};
	mapIdBBDIDToProv = {};
	editedOpportunitiesFromReport;
	editedCheckTaskOnOffToUpdateBack;
	taskInsertedCheckOnOff;
	caosInsertedCheckOnOff;
	deletedCheckOnOffBack;
	createdOpposIds;
	eventHeaderId;
	opposScheduled;
	isShowNewEvent  = false;
	createdOpposIds = [];
	originalCallToBack;
	originalEvent;

	eventInfo = {
		sobjectType:'Event',
		WhatId:'',
		StardDateTime:'',
		DurationInMinutes: 0 ,
		OwnerId:'',
		Subject:'',
		Description:'',
		CSBD_Evento_Estado__c: 'Gestionada Positiva',
		CC_Llamada_Id__c:null
	};
	eventInfoAux;
	showReportAgendeds = true;

	typeLabel = {
		'030':'Muro',
		'ESE':'Email,sms,etc',
		'OFT':'Tarea de oficina'
	}
	
	evaluateShowOpportunitiesAndNoCheck(){
		let auxShowOpportunities = this.showOpportunities;
		this.noCheck = !this.nolocalizado && !this.citaComercial && !this.personal;
		this.showOpportunities = this.noCheck || this.nolocalizado;
		this.eventInfo.CC_Llamada_Id__c = (this.noCheck) ? this.callId : null;
		this.eventInfo.AV_Purpose__c = (this.citaComercial) ? '002' : '001';
		if(this.showOpportunities != auxShowOpportunities && this.showOpportunities){
			this.evaluateAgendeds({detail:!this.showOpportunities});
		}

	}

	getCallInfo(callId){
		if(callId.includes('/')){
			this.callId = callId.replace('/','');
		}	
		getCallInfo({callId:this.callId})
			.then(result =>{
				if(result != null){
					this.callRecord = result;
					this.loadedData = true;
					this.nolocalizadocb = (result.typeAppointment == 'Corta' && result.origin == 'Saliente');
					this.eventInfo.WhatId = result.clientId;
					this.eventInfo.StardDateTime = result.startTimeFull;
					this.eventInfo.ActivityDateTime = result.startTimeFull;
					this.eventInfo.DurationInMinutes = parseInt(result.duration,10);
					this.eventInfo.OwnerId = result.assignedEmployeeId;
					this.eventInfo.Subject = result.subject;
					this.eventInfo.AV_Tipo__c = (result.typeAppointment == 'Cita Telefónica')? 'CTF' : 'LMD';
					this.gestorAsignado = result.assignedEmployeeExternalId	;
					this.evaluateShowOpportunitiesAndNoCheck();
					this.eventInfoAux = this.eventInfo;
					this.originalCallToBack = result.originalCallToBack;
				}
			}).catch(error => {
				console.error(error);
			})

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
	setsubject(e){
		this.eventInfo.Subject = e.detail;

	}
	

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
		this.callId = this.currentPageReference?.state?.c__callId;
		this.getCallInfo(this.currentPageReference?.state?.c__callId);
	}
	
	handleSaveAndEvent(){  
		var nowReference = new Date().toJSON();
		let error = null;
		let comentarios = [];

		let auxOppo = [];
		let countAgend = 0;
		let vinculatedOppos = [];
		if(this.opposObject != null ){
			for(let oppoId in this.opposObject){
				vinculatedOppos.push(this.opposObject[oppoId]);
				auxOppo.push(this.opposObject[oppoId]);
				if(this.opposObject[oppoId]['agendado']){
					countAgend++;
				}
			}
		}
		let count = 1;
		this.opposScheduled = [];
		auxOppo.forEach(opp => {
			
			this.opposScheduled.push(
				{
					Id: opp['id'],
					Name :  opp['Name'],
					Stage :  opp['newPath'],
					Fecha :  opp['proximaGestion'],
					Comentarios :  opp['comentario'],
					Potencial :  opp['expectativa'],
					ImportePropio :  opp['importe'],
					Margen :  opp['margin'],
					ProductoMain :  opp['ProdId'],
					ImporteCuota :  opp['cuota'],
					ImporteOtraEntidad :  opp['importeOtraEntidad'],
					OtraEntidadNombre :  opp['otraEntidad'],
					NotInserted : (opp['id'].includes(IDPROVISIONAL)) ? true : undefined,
					isVinculed : false,
					mainVinculed: opp['mainVinculed'],
					isTheLastItem : count == countAgend,
					HistoryComment : opp['commentHistory'],
					PrioritzingCustomer : opp['prioritzingCustomer'],
					Agendado: opp['agendado'],
					Subestado : opp['subestado'],
					IsNewProduct: opp['isnewprod'],
					Resolucion: opp['resolucion']
					

				}
			);
			if(opp['agendado']){
				count++;
			}
			
		})

		
			this.eventInfo.AV_CodigoGestorAsignado__c = this.gestorAsignado;
			this.eventInfo.AV_Purpose__c = (this.opposObject != null && !this.citaComercial) ? '001' : '002';

			this.objectInfo = {
				originReport : 'CC_Llamada__c',
				objectToReport : this.eventInfo,
				citaComercial: this.citaComercial,
				dateToQuery:this.callRecord.dateCallParsed,
				objectCall:this.getCallObj(),
				vinculatedOpportunities:this.opposObject,
				oldOppos : this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates(),
				HeaderId:this.eventHeaderId
			}
			
		
			
	
		for(let key in this.objectInfo.objectToReport){
			if(this.objectInfo.objectToReport[key] == null || this.objectInfo.objectToReport[key] == undefined){
				delete this.objectInfo.objectToReport[key];
			}
		}

		for(let oppoId in this.opposObject){
			let comentario = this.opposObject[oppoId]['comentario'];
			comentarios.push(comentario);
		}

	
		
		let coment = null;
		if(this.eventInfo.Description != null && this.eventInfo.Description.trim() !== ''){
			coment = this.eventInfo.Description
		}
		if(coment != null){
			comentarios.push(coment);
		}

		validatePFNewOppAndForbiddenWords({
			prodId : null,
			tskId : this.recordId,
			comments : comentarios,
			names : null
		}).then(result => {
			if(error == null && result == 'OK'){
				if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
					let validateResponse = this.validateDatesOppos();
					if(validateResponse == true){
						if(this.eventInfo.Subject.trim() != ''){
							this.isShowNewEvent = true;
							this.showSpinner = false;

						}else{
							this.handleError();
							this.showSpinner = false;
							this.showToast('Error', 'Introduce un asunto porfavor', 'error', 'pester');
						}
					}else{
						this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
					}
				} else {
					if(error == null){
							this.handleError();
							this.showEventPopup = true;
							this.showNoOpportunityMessage = true;
						
					}
				}
			} else if(result != 'OK'){
				if(result == 'KO'){
					this.showToast('Error', errorMsgLabel, 'error', 'pester');
				}else if (result.includes('Warning')) {
					this.showToast('Warning', result, 'warning', 'sticky');
				} else {
					this.showToast('Error', result, 'error', 'pester');
				}	
			}
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
			this.hideFlowAction(event);
			this.handleCancel();
		}
	}


	restoreeventreport(){
		this.isShowNewEvent = false;
		this.citaComercial = false;
		this.opposObject = {};
		this.eventInfo = this.eventInfoAux;
	}
	seteventcoment(e){
		this.eventInfo.Description = e.detail;
	}
	focusRecord(){
		// this.dispatchEvent(new CustomEvent('focusrecordtab'));
		this[NavigationMixin.Navigate]({
            type : 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        })
	}

	handleCancel(){
		this.showSpinner = false;
		this.dispatchEvent(new CustomEvent('closetab'));
	}

	handleCloseAndFocus(){
		this.dispatchEvent(new CustomEvent('focusrecordtabandclose'));
	}
	
	handleError(){
		this.dispatchEvent(new CustomEvent('focustab'));
	}
	highlightOppo(id){
		let b =  this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(id);
		let closedStatus = ['No interesado','Producto Rechazado'];
			if(this.opposObject[id].newPath == 'En gestión/insistir'){
				this.showToast('Faltan datos','Indica una fecha de próxima gestión que sea mayor o igual a hoy.','error','pester');
			}else if(this.opposObject[id].newPath == 'No interesado' && this.opposObject[id].resolucion == null){
				this.showToast('Faltan datos','Debes de rellenar el campo de resolución.','error','pester');
			}else if(closedStatus.includes(this.opposObject[id].newPath) &&  this.opposObject[id].resolucion == 'O' &&  (this.opposObject[id].comentario == null || this.opposObject[id].comentario == '')){
				this.showToast('Faltan datos', 'Debes de rellenar el campo de comentario.', 'error', 'pester');
			}else if(closedStatus.includes(this.opposObject[id].newPath) &&  this.opposObject[id].resolucion == 'No Apto' && this.opposObject[id].noofrecerhasta == null){
				this.showToast('Faltan datos', 'Por favor, rellena los campos obligatorios.', 'error', 'pester');
			}
		b.scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});
		b.highlightBadInput();
	}
	handleRadioButtonSelection(event){
		this.radioButtonSelected = event.detail.radioButtonSelected;
	}

	handleLinkOpportunity(){
		this.showNoOpportunityMessage = false;
	}

	handleNoCommercial(){
		this.citaComercial = true;
		this.showNoOpportunityMessage = false;
		this.handleSave();
	}
	
	sumMinutes(initialHour,duration){
		let initialDateTomSeconds = new Date(initialHour).getTime();
		let durationInms = parseInt(duration,10)*60*1000;
		let finalDateInMs = initialDateTomSeconds + durationInms;
		return new Date(finalDateInMs).toISOString();
	}

	
	handleSave(){
		this.goPlanAppointment = false;
		this.focusRecord();
		this.showSpinner = true;
		this.buttonEventToNoComercial='false';
		let error = null;
		let comentarios = [];
		var nowReference = new Date().toJSON();
		

		for(let oppoId in this.opposObject){
			let comentario = this.opposObject[oppoId]['comentario'];
			comentarios.push(comentario);
		}

		let coment = null;
		if(this.eventInfo.Description != null && this.eventInfo.Description.trim() !== ''){
			coment = this.eventInfo.Description
		}
		if(coment != null){
			comentarios.push(coment);
		}
		validatePFNewOppAndForbiddenWords({
			prodId : null,
			tskId : this.recordId,
			comments : comentarios,
			names : null
		}).then(result => {
			if((error == null && result == 'OK') || (error == null && result.includes('Warning'))){
					if (result.includes('Warning')) {
						this.showToast('Warning', result, 'warning', 'sticky');
					}
					let validateResponse = (this.opposObject != null) ? this.validateDatesOppos() : true;
					if(validateResponse == true){
						if(this.eventInfo.Subject.trim() != ''){
							this.eventInfo.AV_Purpose__c = (this.opposObject != null) ? '001' : '002';
							this.processEventAndCall();
						}else{
							this.handleError();
							this.showSpinner = false;
							this.showToast('Error', 'Introduce un asunto porfavor', 'error', 'pester');
						}
					}else{
						this.handleError();
						this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
						this.showSpinner = false;
	
					}
			} else if(result != 'OK'){
				if(result == 'KO'){
					this.showToast('Error', errorMsgLabel, 'error', 'pester');
				}else if (!result.includes('Warning')) {
					this.showToast('Error', result, 'error', 'pester');
				}
				this.showSpinner = false;
			}
		})
	}

	checkboxchange(e){
		this.nolocalizado = false,
		this.citaComercial = false;
		this.personal = false;
		let key = Object.keys(e.detail)[0];
		if(key == 'nolocalizado'){	
			this.nolocalizado = e.detail['nolocalizado'];
		}else if(key == 'citanocomercial'){
			this.citaComercial = e.detail['citanocomercial'];
		}else if(key == 'personal'){
			this.personal = e.detail['personal'];
		}

		this.evaluateShowOpportunitiesAndNoCheck();
	}

	sendToGcfOpportunity() {
			let listIdsOpps = [];
			for(let id in this.editedOpportunitiesFromReport){
			
				listIdsOpps.push(this.editedOpportunitiesFromReport[id]['id']);
			}
			sendOppToGCF({listIdsOppUpdateCreated:listIdsOpps,canal:this.eventInfo.AV_Tipo__c})  
			.then(result =>{
				if(result != 'OK'){
					console.log('Error sendOppToGCF ', result);
				}
					this.finishReport();
			}).catch(error => {
			
				this.showSpinner = false;
				console.log(error);
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

	validateDatesOppos(){
		var nowReference = new Date().toJSON().slice(0, 10);
		let response = true;
		for(let oppoId in this.opposObject){
			let date = this.opposObject[oppoId]['proximaGestion'];
			let stage = this.opposObject[oppoId]['newPath'];
			let resolucion = this.opposObject[oppoId]['resolucion'];
			let comentario = this.opposObject[oppoId]['comentario'];
			let agendado = this.opposObject[oppoId]['agendado'];
			let validable = this.opposObject[oppoId]['validable'];
			let noofrecerhasta = this.opposObject[oppoId]['noofrecerhasta'];

			if(!validable){
				continue;
			}
			if((stage == 'En gestión/insistir') &&
			((date != null && date != undefined && date < nowReference) || (date == null && date == undefined)) && !agendado){
				return  this.opposObject[oppoId]['id'];
			}
			if((stage == 'No interesado' || stage == 'Producto Rechazado') && ((resolucion == 'O') && (comentario == null | comentario == '') || resolucion == 'No Apto' && (noofrecerhasta == null || noofrecerhasta == undefined))){
				return  this.opposObject[oppoId]['id'];
			}

		}
		return response;
	}



	setOppoForController(e){
		this.opposObject = e.detail;
		var oppInsert = {};
		var oppUpdate = {};
		for(let oppoId in this.opposObject){
			if (oppoId.includes(IDPROVISIONAL)) {
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

	hideFlowAction(e){
		this.isShowFlowAction = false;
	}

	closeModal(e) {
		this.isShowFlowAction = false;
		this.handleCloseAndFocus();
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
	buildOpportunities(){
		let oldOppos = this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates();
		createOrUpdateOpportunitiesFromReport({opposToInsertOrUpdate: this.opposObject, mapOldOpp:oldOppos,accountId:this.callRecord.clientId,eventId:this.evtUpserted})
		.then(result => {
			if(result.errorList == null ){ 
				this.editedOpportunitiesFromReport = result.editedOpportunities;
				this.processCheckOnOffJs(result);
			}else{
				this.backFromOpportunitysProcess();
				result.errorList.forEach(err => {
					console.log(err);
				})
			}
		}).catch(error => {
			this.backFromOpportunitysProcess();
			console.error(error)
		});
	}
	processCheckOnOffJs(reportObject){
		processCheckOnOffCreate({checkOnOff:reportObject.checkOnOffOpposId,accountId : this.callRecord.clientId})
		.then(result => {
			if(result.errorList == null){
				if(result.bckCOF.createdIdsToDelete.length > 0){
					this.taskInsertedCheckOnOff = result.bckCOF.createdIdsToDelete;
					this.caosInsertedCheckOnOff = result.bckCOF.createdCaosToDelete;
				}
				processCheckOnOffUpdate({checkOnOff:reportObject.checkOnOffOpposId,accountId : this.callRecord.clientId})
				.then(result => {
					if(result.errorList == null){
						this.editedCheckTaskOnOffToUpdateBack = result.bckCOF.updatedTasksToRestore;
						processCheckOnOffDelete({checkOnOff:reportObject.checkOnOffOpposId,accountId : this.callRecord.clientId})
						.then(result => {
							if(result.errorList == null){
								this.deletedCheckOnOffBack = result.bckCOF;
								this.vinculateOpportunitiesFromReport();
							}else{
								result.errorList.forEach(err => {
									console.log(err);
								})
								this.backReportFromCheckOnOffDelete();
							}
						}).catch(error => {
							console.error('Error processCheckOnOffDelete: ',error);
							this.showSpinner = false;
							this.backReportFromCheckOnOffDelete();
						});	
					}else{
						result.errorList.forEach(err => {
							console.log('Error processCheckOnOffUpdate: ',err);
						})
						this.backReportFromCheckOnOffEdit();
					}
				}).catch(error => {
					console.error('Error processCheckOnOffUpdate: ', error);
					this.backReportFromCheckOnOffEdit();
				});
			}else{
				result.errorList.forEach(err => {
					console.log(err);
				})
				this.backReportFromCheckOnOffCreate();
			}
		}).catch(error => {
			console.error('Error processCheckOnOffCreate ', error);
			this.backReportFromCheckOnOffCreate();
		});
	}

	
	backReportFromCheckOnOffCreate(){
		let oldOppos = [];
		let getOldOppos = this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates();

		Object.keys(this.editedOpportunitiesFromReport).forEach((oppoId) => {
			if(oppoId.includes(IDPROVISIONAL)){
				this.createdOpposIds.push(this.editedOpportunitiesFromReport[oppoId]['id']);
			}else{
				oldOppos.push(getOldOppos[oppoId]);
			}
		});
		backCreatedOrUpdtOppos({createdIds:this.createdOpposIds, tskCheckOnOffToDel : this.taskInsertedCheckOnOff, caoCheckOnOffToDel : this.caosInsertedCheckOnOff, oldOppos:oldOppos})
		.then((response) =>{
			this.backFromOpportunitysProcess();
		}).catch(error => {
			console.error(error);
			this.backFromOpportunitysProcess();
		});
	}

	backReportFromCheckOnOffEdit(){
		this.backReportFromCheckOnOffCreate();
	}
	backFromOpportunitysProcess(){
		let objToBackMethod = {callToRollBack:this.originalCallToBack,eventToDel:null,evtToRollBack:null};
		if(typeof this.originalEvent == 'string'){
			objToBackMethod.eventToDel = this.originalEvent;
		}else{
			objToBackMethod.evtToRollBack = this.originalEvent;
		}
		backUpsertedEventAndCall(objToBackMethod)
		.then(result => {
			if(result == 'OK'){
				this.showToast('Error actualizando las oportunidades','Se han desecho todos los cambios.','Error');
			}else{
				this.showToast('Error actualizando las oportunidades','El evento ha quedado registrado mal. Por favor, eliminelo manualmente.','Error');
			}
			this.handleError();
			this.showSpinner = false;
		}).catch(error => {
			this.showSpinner = false;
			this.handleError();
			console.error(error);
			this.showToast('Error actualizando las oportunidades','El evento ha quedado registrado mal. Por favor, eliminelo manualmente.','Error');
		});
	}
	backReportFromCheckOnOffDelete(){
		backClosedTaskReport({tskToBack : this.editedCheckTaskOnOffToUpdateBack})
		.then(() => {
			this.backReportFromCheckOnOffEdit();
		}).catch(error => {
			console.error(error);
			this.backReportFromCheckOnOffEdit();
		});
	}
	vinculateOpportunitiesFromReport(){
		let listOpposReport = {};
		var listCaosForNewRecord = [];
		if(typeof this.evtUpserted == 'string'){
			for(let id in this.editedOpportunitiesFromReport){
				let currentOppo = this.editedOpportunitiesFromReport[id];
				let oppoId = currentOppo['id'];
				let mainVinculed = currentOppo['mainVinculed'];
				listOpposReport[oppoId] = mainVinculed;
				listCaosForNewRecord.push({
					sobjectType:'AV_CustomActivityOpportunity__c',
					AV_Opportunity__c: oppoId,
					AV_IsMain__c : mainVinculed,
					AV_Task__c : this.eventHeaderId,
					AV_OrigenApp__c : 'AV_SalesforceClientReport'
				});	
			}	
			
		}else{
			for(let id in this.editedOpportunitiesFromReport){
				
				let oppoId = this.editedOpportunitiesFromReport['id'];
				let mainVinculed = this.editedOpportunitiesFromReport['mainVinculed'];
				listOpposReport[oppoId] = mainVinculed;
			}
			
		}

		
		let commentsHistory = [];
		let oldOppos = 	 this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates();
		
		for(let oppId in this.editedOpportunitiesFromReport){
			
			commentsHistory.push(
				{		
					sobjectType:'AV_CommentsHistory__c',
					AV_Opportunity__c:this.editedOpportunitiesFromReport[oppId]['id'],
					AV_NewComment__c:this.editedOpportunitiesFromReport[oppId]?.['comentario'],
					AV_OldComment__c: oldOppos?.AV_Comentarios__c,
					AV_OpportunityStatus__c:this.editedOpportunitiesFromReport[oppId]?.['newPath'],
					AV_Event__c:this.evtUpserted,
					AV_AssignedEmployee:null
				}
			)
		}
		processVinculations({opposAndMain:listOpposReport,
			recordHeaderId:this.eventHeaderId,
			commentsHistory:commentsHistory
		})
			.then(result => {
				if(result[0] == 'OK'){
					this.sendToGcfOpportunity();
				}else{
					console.error(result[1]);
					this.backFromVinculateReport();
				}
			}).catch(error => {
				this.showToast('Error',error,'error','pester');
				this.backFromVinculateReport();
				console.error(error);
			})
	}

	finishReport(){
		this.handleFinish();
		this.showSpinner = false;
	}
	handleFinish(){
		this.dispatchEvent(new CustomEvent('closetab'))
	}
	backFromVinculateReport(){
		backCreatedOrUpdtOppos({deleteIdCommentsHistoryInsert: this.deletedCheckOnOffBack.deleteIdCommentsHistoryInsert, tskToRestore: this.deletedCheckOnOffBack.taskToRestoreBack, caoToRestore: this.deletedCheckOnOffBack.caoToRestoreBack, entityRelations: this.deletedCheckOnOffBack.taskOpposRelation})
		.then( () => {
			this.backReportFromCheckOnOffDelete();
		}).catch(error =>{
			this.backReportFromCheckOnOffDelete();
			console.error(error);
		});
	}
	getCallObj(){
		let callStatus = ( () =>  {
			if(this.noCheck || this.citaComercial){
				return 'Gestionada';
			}

			if(this.nolocalizado){
				return 'No localizado';
			}
			if(this.personal){
				return 'Descartada';
			}
		})();
		return {
			sobjectType: 'CC_Llamada__c',
			Id: this.callId,
			AV_State__c: callStatus
		}
	}
	processEventAndCall(){
		
		processEventAndCall({evtToUpsert:this.eventInfo,callToReport: this.getCallObj(),accountId:this.callRecord.clientId,evtDate:this.callRecord.dateCallParsed,gestorAsociado:this.gestorAsignado})
			.then(result => {
				if(result.result){

					this.evtUpserted = (result.evtBack != null) ? result.evtBack.Id : result.evtToDelBack;
					this.originalEvent = (result.evtBack != null) ? result.evtBack : result.evtToDelBack;
					this.eventHeaderId = (result.evtBack != null) ? result.evtBack.AV_Task__c : result.headerNewEvt;
					if(this.showOpportunities && (this.opposObject != undefined || this.opposObject != null)){
						this.buildOpportunities();
					}else{
						this.finishReport();
					}
				}else{
					console.error(result.error);
					this.showToast('Error',result.error,'error','pester');
				}
			}).catch(error => {
				console.error(error);
				this.showToast('Error',error,'error','pester');

			})
	}
	evaluateAgendeds(e){
		this.template.querySelector('[data-id="saveButton"]').disabled = e.detail;
		if(this.template.querySelector('[data-id="saveAndEventButton"]') != null){
			this.template.querySelector('[data-id="saveAndEventButton"]').disabled = !e.detail;
		}
	}

	switchButtons(){
		this.disableButtonCancel = true;
		this.disableButtonSave = true;
		this.disableButtonSaveAndEvent = true;
	}

	
	handleNoLocalizado(e){
		this.nolocalizado = e.detail.value;
		if(this.nolocalizado){
			this.disableButtonSaveAndEvent = true;				
		}

	}
	
	handleChangeOptionEvent(e){
		this.optionevent = e.detail.value;
		if(this.optionevent != 'LMD'){
			this.nolocalizado = false;
		}
	}
	
	handleTabConCliente(e){
		this.clientetab = e.detail.value;
		
	}

	valueOppoList(e){
		this.opposList = e.detail.opportunitiesList;
		this.opposVinculed = e.detail.opportunitiesVinculed;
	}

	
	
}