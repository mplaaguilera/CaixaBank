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
import unlinkOpp from '@salesforce/apex/AV_EventReport_Controller.unlinkOpp';
import unlinkLabel from '@salesforce/label/c.AV_UnlinkOpp_Error';
import successLabel from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel from '@salesforce/label/c.AV_CMP_SuccessUnlinkOpp';
import validatePFNewOppAndForbiddenWords from '@salesforce/apex/AV_NewOpportunity_Controller.validatePFNewOppAndForbiddenWords';
import getUserInfo from '@salesforce/apex/AV_ReportAppointment_Controller.getUserInfo';  



//Label
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';
const IDPROVISIONAL = 'idProvisional';
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
	@track isShowNewEvent = false;
	@track eventInfo;
	goPlanAppointment;
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
	showNoOpportunityMessage = false;
	opposScheduled = [];
	taskevent;
	descartadas = [];
	diferentes = []
	opposList = [];
	opposVinculed = [];
	disableButtonSaveAndEvent = true;
	userLogged; 
    @track showModal = false; 
	switchModal = false; 
	eventOwner;


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
	restoreeventreport(){
		this.isShowNewEvent = false;
		this.citaComercial = false;
		this.opposObject = {};
		this.eventInfo = {};
	}
	handleCloseAndFocus(){
		this.dispatchEvent(new CustomEvent('focusrecordtabandclose'));
	}
	
	@wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

	
	@wire(getUserInfo)
    wiredUser({ error, data }) {
        if (data) {
			this.userLogged = data.gestor;
			if(data.multigestor){
				this.currentMultigest = data.multigestor.Id;
			}
        } else if (error) {
            console.log(error);
			
        }
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
			this.eventOwner = result.owner;
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
		this.template.querySelector('[data-id="saveAndEventButton"]').disabled = !e.detail;
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
		let discardedOpps = [];
		var oppInsert = {};
		var oppUpdate = {};
		for(let oppoId in this.opposObject){
			if (oppoId.includes(IDPROVISIONAL)) {
				oppInsert[oppoId]= this.opposObject[oppoId];
				oppInsert[oppoId]['owneridopp']= this.userLogged.Id; 
			} else {
				oppUpdate[oppoId]= this.opposObject[oppoId];
				discardedOpps.push(this.opposObject[oppoId]['id']);
			}
		}
		if (oppInsert != null) {
			this.listOppInsert = oppInsert;
		}
		
		if (oppUpdate != null) {
			this.listOppUpdate = oppUpdate;
		}
		this.storeDiscardedOpportunities(discardedOpps);
		
	}

	storeDiscardedOpportunities(discardedOpps) {
		discardedOpps.forEach(id=>{
			if(!this.descartadas.includes(id)){
				this.descartadas.push(id);
			}
		})
		for (let i = 0; i < this.descartadas.length; i++) {
			if (!discardedOpps.includes(this.descartadas[i])) {
				this.diferentes.push(this.descartadas[i])
			}
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
	@api
	navigateHome(){
			this[NavigationMixin.Navigate]({
				type : 'standard__namedPage',
				attributes: {
					pageName: 'home'
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
			let noofrecerhasta = this.opposObject[oppoId]['noofrecerhasta'];
			
			if (validable) {
				if((stage == 'En gestión/insistir') && ((date != null && date != undefined && date < nowReference) || (date == null && date == undefined)) && !agendado){
					return  this.opposObject[oppoId]['id'];
				}
				if((stage == 'No interesado' || stage == 'Producto Rechazado') && ((resolucion == 'O') && (comentario == null | comentario == '') || resolucion == 'No Apto' && (noofrecerhasta == null || noofrecerhasta == undefined))){
					return  this.opposObject[oppoId]['id'];
				}
			}
		}
		return response;
	}

	async evaluateReassignation(){
		if((this.opposObject != undefined  && Object.keys(this.opposObject)[0] != undefined ) || this.switchModal){  
			
			let ownerMismatch = false;
			for(let key in this.opposObject){
				if( this.opposObject[key]['owneridopp'] == this.currentMultigest){
					this.opposObject[key]['owneridopp'] = this.userLogged.Id;
					continue;
				}
				if((this.opposObject[key]['owneridopp'] != this.userLogged.Id)){
					ownerMismatch = true;
					continue;
				}
				this.showModal=false;
			}
	
			
			let ownerMismatch2 = false;
			for(let key in this.tasksObject){
				if( this.tasksObject[key]['owner'] == this.currentMultigest){
					this.tasksObject[key]['owner'] = this.userLogged.Id;
					continue;
				}
				if((this.tasksObject[key]['owner'] != this.userLogged.Id)){
					ownerMismatch2 = true;
					continue;
				}
				
				this.showModal=false;
			}
			//
	
			let reportMismatch = (this.userLogged.Id != this.eventOwner && this.currentMultigest !=  this.eventOwner);
			if (ownerMismatch || ownerMismatch2 || reportMismatch ) {   
				this.showModal = true;
				const result = await this.waitForUserDecision();
				if (result) {
					if(ownerMismatch){  
						for (let key in this.opposObject) {
							if (this.opposObject[key]['owneridopp'] != this.userLogged.Id && this.opposObject[key]['owneridopp'] != this.currentMultigest) {
								this.opposObject[key]['owneridopp'] = this.userLogged.Id;
							}
						}
					}
					
					if(ownerMismatch2){  
						for (let key in this.tasksObject) {
							if (this.tasksObject[key]['owner'] != this.userLogged.Id && this.tasksObject[key]['owner'] != this.currentMultigest) {
								this.tasksObject[key]['owner'] = this.userLogged.Id;
							}
						}
					}
					if(reportMismatch || this.eventOwner == this.currentMultigest){
						this.getInfoContact.ownerid = this.userLogged.Id;
					}
				}else if(this.eventOwner == this.currentMultigest){
					this.getInfoContact.ownerid = this.userLogged.Id;
				}else{
					this.getInfoContact.ownerid = this.eventOwner;
				}
					this.showModal = false;
			}else if(this.eventOwner == this.currentMultigest){
				this.getInfoContact.ownerid = this.userLogged.Id;
			}else{
				this.getInfoContact.ownerid = this.eventOwner;
			}
			
		}
	}



	async handleSave(){  
		this.goPlanAppointment = false;
		this.buttonEventToNoComercial='false';
		let error = null;
		let comentarios = [];
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

		for(let oppoId in this.opposObject){
			let comentario = this.opposObject[oppoId]['comentario'];
			comentarios.push(comentario);
		}

		let coment = null;
		if(this.getInfoContact.comment != null && this.getInfoContact.comment.trim() !== ''){
			coment = this.getInfoContact.comment;
		}

		if(coment != null){
			comentarios.push(coment);
		}

		let validateResponse = this.validateDates();
		if(validateResponse == true){
		try{
			const result = await validatePFNewOppAndForbiddenWords(
				{
					prodId: null,
					tskId: this.recordId,
					comments: comentarios,
					names: null
	
				});

			if((error == null && result == 'OK') || (error == null && result.includes('Warning'))){
					if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
						if(result.includes('Warning')){
							this.showToast('Warning', result, 'warning', 'sticky');
						}

						await this.evaluateReassignation();
						this.focusRecord();
						this.showSpinner = true;
						if (this.listOppInsert != null && Object.keys(this.listOppInsert).length > 0) {
							this.saveOpportunityInsert('false');
						} else if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
							this.saveOpportunityUpdate('false', null);
						} else {
							this.saveTaskAndEvent(null, null, null, 'false');	
						}
						if(this.diferentes != null && this.diferentes.length > 0){
							this.unlinkOpp();
						}			
					}	
					else {
						if(error == null){
							this.switchModal = true;  
							this.handleError();
							this.showNoOpportunityMessage = true;
						}
					}
				}else if(result != 'OK'){
					if(result == 'KO'){
						this.showToast('Error', errorMsgLabel, 'error', 'pester');
					}else if (!result.includes('Warning')) {
						this.showToast('Error', result, 'error', 'pester');
					}
				}		

		}catch(error){
			console.error('Error: ',error);
		}
		}else{
			this.handleError();
			this.template.querySelector('[data-id="oppoCmp"]')?.highlightOppo(validateResponse);
			this.showSpinner = false;
		}	
		
	}

	unlinkOpp() {
		let auxOppo = [];
		if(this.opposObject != null ){
			auxOppo = this.diferentes;
		}
		unlinkOpp({ oppId: auxOppo, recInfo: this.headerId })
			.then(() => {
				this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
			})
			.catch(error => {
				this.showToast('Error', unlinkLabel, 'error', 'pester');
			});
	}

	
	sumMinutes(initialHour,duration){
		let initialDateTomSeconds = new Date(initialHour).getTime();
		let durationInms = parseInt(duration,10)*60*1000;
		let finalDateInMs = initialDateTomSeconds + durationInms;
		return new Date(finalDateInMs).toISOString();
	}

	async handleSaveAndEvent(){   
		this.goPlanAppointment = true;
		this.buttonEventToNoComercial ='true';
		let error = null;
		let comentarios = [];
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
		

		let auxOppo = [];
		let countAgend = 0;
		let vinculatedTasks = [];
		if(this.opposObject != null ){
			for(let oppoId in this.opposObject){
				auxOppo.push(this.opposObject[oppoId]);
				if(this.opposObject[oppoId]['agendado']){
					countAgend++;
				}

			}
		}

		if(this.tasksObject != null){
			for(let tskId in this.tasksObject){
				vinculatedTasks.push(this.tasksObject[tskId]);
			}
		}
		this.opposScheduled = [];
		let count = 1;
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
					ProductName: opp['productName'],
					IsNewProduct: opp['isnewprod']	
					,owneridopp : opp['owneridopp']  

				}
			);
			if(opp['agendado']){
				count++;
			}
			
		})
		this.eventInfo = {
			originReport : 'Event',
			objectToReport : {
				sobjectType: 'Event',
				Id : this.idEvent,
				AV_Tipo__c : this.getInfoContact['type'],
				StartDateTime : this.getInfoContact['activityDateTime'],
				EndDateTime : this.sumMinutes(this.getInfoContact['activityDateTime'],this.getInfoContact['duracion']),
				AV_MemorableInterview__c : this.getInfoContact['memorableInterview'],
				Description: this.getInfoContact['comment'],
				AV_BranchPhysicalMeet__c : this.getInfoContact['office'],
				WhoId : this.getInfoContact['contactPerson'],
				Location : this.getInfoContact['location'],
				AV_ContactGenerateAppointment__c : 'Cita generada',
				CSBD_Evento_Estado__c : 'Gestionada Positiva',
				OwnerId: null
				
			}
			,citaComercial: this.getInfoContact['comercial'],
			vinculatedOpportunities:this.opposObject,
		 	vinculatedTasks : vinculatedTasks,
			oldOppos : this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates(),
			HeaderId : this.headerId
		}

		if(this.eventInfo.objectToReport.citaComercial){
			this.eventInfo.objectToReport.AV_Purpose__c = '002';
		}else{
			this.eventInfo.objectToReport.AV_Purpose__c = '001';
		}
		
		for(let key in this.eventInfo.evt){
			if(this.eventInfo.evt[key] == null || this.eventInfo.evt[key] == undefined){
				delete this.eventInfo.evt[key];
			}
		}

		for(let oppoId in this.opposObject){
			let comentario = this.opposObject[oppoId]['comentario'];
			comentarios.push(comentario);
		}

		let coment = null;
		if(this.getInfoContact.comment != null && this.getInfoContact.comment.trim() !== ''){
			coment = this.getInfoContact.comment;
		}

		if(coment != null){
			comentarios.push(coment);
		}

		let validateResponse = this.validateDates();
			if(validateResponse == true){
			try{
				const result = await validatePFNewOppAndForbiddenWords({
					prodId : null,
					tskId : this.recordId,
					comments : comentarios,
					names : null
				})

				if(error == null && result == 'OK'){
					if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
						
						await this.evaluateReassignation();
						this.eventInfo.vinculatedOpportunities = this.opposObject;
						this.eventInfo.objectToReport.OwnerId = this.getInfoContact.ownerid;
						this.opposScheduled.forEach(oppo => {
							oppo.owneridopp = this.opposObject[oppo.Id]['owneridopp'];
						})
						this.isShowNewEvent = true;
						this.showSpinner = false;
						
						if(this.diferentes != null && this.diferentes.length > 0){
							this.unlinkOpp();
						}
					} else {
						if(error == null){
							this.switchModal = true;  
							this.handleError();
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
			}catch(error){
				console.error('Error: ',error);
			}
            }else{
				this.handleError();
				this.template.querySelector('[data-id="oppoCmp"]')?.highlightOppo(validateResponse);
				this.showSpinner = false;
			}

		
			
		
	}

	handleLinkOpportunity(){
		let cntcBlck = this.template.querySelector("[data-id='contactBlock']");
		if(cntcBlck.checkboxStatus){
			cntcBlck.switchCitaCheckBox(false);
		}
		this.showNoOpportunityMessage = false;
	}

	handleNoCommercial(){
		let cntcBlck = this.template.querySelector('[data-id="contactBlock"]');
		if(!cntcBlck.checkboxStatus){
			cntcBlck.switchCitaCheckBox(true);
		}
		this.citaComercial = true;
		this.getInfoContact.comercial = true;  
		this.showNoOpportunityMessage = false;
		(this.goPlanAppointment) ? this.handleSaveAndEvent() : this.handleSave();
	}

	saveOpportunityInsert(buttonEvent){
		insertOrUpdateOpp({ opportunities:this.listOppInsert, accountId:this.idAccount, isInsert: true})
		.then(result=> {
			if (result != null) {
				if (result.results == 'OK') {
					if(this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0){
					
						this.saveOpportunityUpdate(buttonEvent, result.opposId);
					}
					else{
						// this.redirectToPlanificarCita();
						this.saveTaskAndEvent(result.opposId, null,result.opposId, buttonEvent);
					}
				} else {
					this.handleError();
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
		eventAndTaskProcess({event: this.getInfoContact, taskBlock: this.tasksObject, opportunities: this.opposObject, mapOldOpp: listOppOlds, opposId: listOppNews})
		.then(result =>{
			if (result != null) {
				if(result.result == 'OK'){ 
					if ((listOppNews != null || listOppOlds != null) && ((result.listTaskChangeDate != null && result.listTaskChangeDate != '') || (result.listTaskToDelete != null && result.listTaskToDelete != '') || (result.listTaskOpportunityDelete != null && result.listTaskOpportunityDelete != ''))) {
						this.saveCheckOnOff(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
					} else if ( listOppNews != null || listOppOlds != null) {
						this.saveTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
					} else {
						if (buttonEvent == 'true') {
							// this.isShowFlowAction = true;
							// this.redirectToPlanificarCita();
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
		createTaskOpp({jsonResultTaskEvent: JSON.stringify(resultTaskEvent), event: this.getInfoContact})
		.then(result =>{
			if (result != null) {
				if(result == 'OK'){
					if(listOppIdsAll != null) { 
						this.sendToGcf(listOppIdsAll,buttonEvent);
					}else{
						if (buttonEvent == 'true') {
							// this.isShowFlowAction = true;
							// this.redirectToPlanificarCita();
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
		sendOppToGCF({listIdsOppUpdateCreated:listIdsOpps,newEvTsk:this.getInfoContact.type})
		.then(result =>{
			if(buttonEvent != 'true'){
				this.handleCancel();
			}
			this.showSpinner = false;
			if(result != 'OK') {
				console.log('sendOppToGCF '+result);
			}	
		}).catch(error => {
			if(buttonEvent != 'true'){
				this.handleCancel();
			}
			this.showSpinner = false;
			console.log('sendOppToGCF '+error);
		})
	}

	backOpportunity(errorOpp, listOppUpdate, listIdOppInsert, buttonEvent) {
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

	valueOppoList(e){
		this.opposList = e.detail.opportunitiesList;
		this.opposVinculed = e.detail.opportunitiesVinculed;
	}

	
	waitForUserDecision() {
        return new Promise((resolve) => {
            this.decisionResolver = resolve;
        });
    }
    handleYes() {
        this.decisionResolver(true);
    }
    handleNo() {
        this.decisionResolver(false);
        
    }
    handleCloseModal() {
        this.showModal = false;
    }
    
}