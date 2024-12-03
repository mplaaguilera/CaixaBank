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
import validatePFNewOppAndForbiddenWords from '@salesforce/apex/AV_NewOpportunity_Controller.validatePFNewOppAndForbiddenWords';
import getUserInfo from '@salesforce/apex/AV_ReportAppointment_Controller.getUserInfo';  



//Label
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';
const IDPROVISIONAL = 'idProvisional';

export default class Av_ReportAppointment extends NavigationMixin(LightningElement) {

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
	buttonEventToNoComercial;
	opporeporting;
	isChecked;
	taskIdNew;
	newEventId;
	isShowFlowAction = false;
	istheretasks = true;
	showSpinner = true;
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
	isReportOpportunity;
	userLogged; 
    @track showModal = false; 
	switchModal = false; 
	currentMultigest;
	

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
	typeLabel = {
		'030':'Muro',
		'ESE':'Email,sms,etc',
		'OFT':'Tarea de oficina'
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
		if(this.userLogged == null){
			getUserInfo()
				.then(data => {
					if (data) {
						this.userLogged = data.gestor;
						if(data.multigestor){
							this.currentMultigest = data.multigestor.Id;
						}
					} else {
						console.error(data);
					
					}
				}).catch(error => {
					console.log(error);
				})
		}
		this.recordId = this.currentPageReference.state.c__recId;
		this.accountName = this.currentPageReference.state.c__id;
		this.isLegalEntity = this.currentPageReference.state.c__rt == 'CC_Cliente';
		this.isIntouch = this.currentPageReference.state.c__intouch == 'true';
		this.isReportOpportunity = this.currentPageReference.state.c__objectname == 'Opportunity';
		this.clientid = (this.isReportOpportunity) ? this.currentPageReference.state.c__account : this.recordId;
		this.showSpinner = false;
	}

	
	@wire(getUserInfo)
    wiredUser({ error, data }) {
        if (data) {
            this.userLogged = data.gestor;
			if(data.multigestor){
				this.currentMultigest = data.multigestor.Id;
			}
        } else if (error) {
            console.error(error);
        
        }
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
	restoreeventreport(){
		this.isShowNewEvent = false;
		this.citaComercial = false;
		this.opposObject = {};
		this.eventInfo = {};
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
		this.showNoOpportunityMessage = false;
		(this.goPlanAppointment) ? this.handleSaveAndEvent() : this.handleSave();
	}
	
	sumMinutes(initialHour,duration){
		let initialDateTomSeconds = new Date(initialHour).getTime();
		let durationInms = parseInt(duration,10)*60*1000;
		let finalDateInMs = initialDateTomSeconds + durationInms;
		return new Date(finalDateInMs).toISOString();
	}
	async handleSaveAndEvent(){  
		this.goPlanAppointment = true;
		this.buttonEventToNoComercial='true';
		var nowReference = new Date().toJSON();
		let error = null;
		let comentarios = [];

	

		if (this.taskOrEventInfo.type == 'task' ){
			if (!this.radioButtonSelected && this.clientetab=='tabTask') {
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

		let auxOppo = [];
		let countAgend = 0;
		let vinculatedOppos = [];
		let vinculatedTasks = [];
		if(this.opposObject != null ){
			for(let oppoId in this.opposObject){
				vinculatedOppos.push(this.opposObject[oppoId]);
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

	

		let count = 1;
		let recordName;
		this.opposScheduled = [];
		let dateTask;
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
					,owneridopp : opp['owneridopp']   

				}
			);
			if(opp['agendado']){
				count++;
			}
			if(opp['mainVinculed']){
				recordName = opp['productName'];
				dateTask = opp['proximaGestion'];
			}
			
		})

		let orignAppValue;
		let subjectValue;
		if(this.nolocalizado==true){
			orignAppValue = 'AV_SFReportNoLocalizado';
			subjectValue = 'No localizado'
		}else{
			orignAppValue = 'AV_SalesforceClientReport';
			subjectValue = this.typeLabel[this.taskOrEventInfo.typeTask];
		}
		if(this.taskOrEventInfo.type == 'event'){
			this.objectInfo = {
				originReport : 'Opportunity',
				objectToReport : {
					sobjectType: 'Event',
					AV_Tipo__c: this.taskOrEventInfo['typeEvent'],
					StartDateTime : this.taskOrEventInfo['activityDateTime'],
					EndDateTime : this.sumMinutes(this.taskOrEventInfo['activityDateTime'],this.taskOrEventInfo['duracion']),
					AV_MemorableInterview__c: this.taskOrEventInfo['memorableInterview'],
					Description: this.taskOrEventInfo['comment'],
					AV_BranchPhysicalMeet__c: this.taskOrEventInfo['office'],
					WhoId: this.taskOrEventInfo['contactPerson'],
					Location: this.taskOrEventInfo['location'],
					WhatId : this.clientid,
					Subject : (!this.citaComercial && recordName != undefined) ? recordName : 'Gestión operativa',
					AV_OrigenApp__c: 'AV_SalesforceClientReport',
					RecordTypeId : 'AV_EventosConCliente',
					CSBD_Evento_Estado__c : 'Gestionada Positiva'
					,AV_Purpose__c : this.taskOrEventInfo['purpose']  
				},
				citaComercial: this.taskOrEventInfo['comercial'],
				vinculatedOpportunities:this.opposObject,
				vinculatedTasks : vinculatedTasks,
				oldOppos : this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates(),
				HeaderId:this.headerId
			}
			if(this.objectInfo.objectToReport.citaComercial){
				this.objectInfo.objectToReport.AV_Purpose__c = '002';
			}else{
				this.objectInfo.objectToReport.AV_Purpose__c = '001';
			}
			
		}else if(this.taskOrEventInfo.type == 'task'){
			this.objectInfo = {
				originReport : 'Opportunity',
				objectToReport : {
					sobjectType: 'Task',
					AV_Tipo__c: this.taskOrEventInfo.typeTask,
					Status: 'Gestionada positiva',
					WhatId : this.clientid,
					ActivityDate: new Date().toISOString().substring(0,10),
					Subject : subjectValue,  
					RecordTypeId : 'AV_Otros',
					Description : this.taskOrEventInfo.comentaryTask,
					AV_OrigenApp__c : orignAppValue  
					

				}
				,vinculatedOpportunities:this.opposObject,
				vinculatedTasks : vinculatedTasks,
				oldOppos : this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates(),
				HeaderId:this.headerId
			}
			
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
		if(this.taskOrEventInfo.comment != null && this.taskOrEventInfo.comment.trim() !== ''){
			coment = this.taskOrEventInfo.comment
		}else if(this.taskOrEventInfo.comentaryTask != null && this.taskOrEventInfo.comentaryTask.trim() !== ''){
			coment = this.taskOrEventInfo.comentaryTask;
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
				});

				if((error == null && result == 'OK') || (error == null && result.includes('Warning'))){
					if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
						if (result.includes('Warning')) {
							this.showToast('Warning', result, 'warning', 'sticky');
						}
							try{
								await this.evaluateReassignation();
								this.objectInfo.vinculatedOpportunities = this.opposObject;
								this.opposScheduled.forEach(oppo => {
									oppo.owneridopp = this.opposObject[oppo.Id]['owneridopp'];
								})
								this.isShowNewEvent = true;
								this.showSpinner = false;
							}catch(error){
								console.log('modal cerrado:'+error);
							}
					}	
				} else if(result != 'OK'){
					if(result == 'KO'){
						this.showToast('Error', errorMsgLabel, 'error', 'pester');
					}else if (!result.includes('Warning')) {
						this.showToast('Error', result, 'error', 'pester');
					}
				}

			}catch(error){
				console.error(error);
			}


			}else{
			this.handleError();
			this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
			this.showSpinner = false;
		}
	}
	
	async handleSave(){    
		this.goPlanAppointment = false;
		this.buttonEventToNoComercial='false';
		let error = null;
		let comentarios = [];
		var nowReference = new Date().toJSON();
			
		if(this.taskOrEventInfo.type == 'task'){
			if(this.nolocalizado != null || this.nolocalizado != undefined){
				this.noLocalizadoAfterSave= this.nolocalizado;
			}

			if (!this.radioButtonSelected && this.clientetab=='tabTask') {
				this.handleError();
				this.showToast('Error', 'Por favor, seleccione un tipo de tarea.', 'error', 'pester');
				error='KO';
			}	
		} else if (this.taskOrEventInfo.type == 'event') {

			if (this.taskOrEventInfo.typeEvent == 'CTOOC' && this.taskOrEventInfo.office == null  && this.clientetab=='tabEvent') {
				this.handleError();
				this.showToast('Error', 'Cuando se selecciona "Cita en otra oficina" debes rellena el campo "Oficina".', 'error', 'pester');
				error='KO';
			}else if((this.taskOrEventInfo.activityDateTime == null || this.taskOrEventInfo.activityDateTime > nowReference) && this.clientetab=='tabEvent'){
				this.handleError();
				this.showToast('Error', 'La fecha no puede ser superior a hoy.', 'error', 'pester');
				error='KO';
			}
		}

		for(let oppoId in this.opposObject){
			let comentario = this.opposObject[oppoId]['comentario'];
			comentarios.push(comentario);
		}

		let coment = null;
		if(this.taskOrEventInfo.comment != null && this.taskOrEventInfo.comment.trim() !== ''){
			coment = this.taskOrEventInfo.comment
		}else if(this.taskOrEventInfo.comentaryTask != null && this.taskOrEventInfo.comentaryTask.trim() !== ''){
			coment = this.taskOrEventInfo.comentaryTask;
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
				});

				if((error == null && result == 'OK') || (error == null && result.includes('Warning'))){
					if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
						if (result.includes('Warning')) {
							this.showToast('Warning', result, 'warning', 'sticky');
						}
						try{
							await this.evaluateReassignation();
						}catch(error){
							console.log('modal cerrado:'+error);
						}
						this.focusRecord();
						this.showSpinner = true;
						if (this.listOppInsert != null && Object.keys(this.listOppInsert).length > 0) {
							this.createOpportunityInsert('false');
						} else if (this.listOppUpdate != null && Object.keys(this.listOppUpdate).length > 0) {
							this.createOpportunityUpdate('false', null);
						} else {
							this.createTaskEvent(null, null, null, 'false');
						}
						
					}  else {
						if(error == null){
							if(this.taskOrEventInfo.type == 'event'){ 
								this.switchModal = true;  
								this.handleError();
								this.showEventPopup = true;
								this.showNoOpportunityMessage = true;
							}else  if(this.taskOrEventInfo.type == 'task'){
								this.switchModal = true;  
								this.handleError();
								this.showTaskPopup = true;
								this.showNoOpportunityMessage = true;
							}
						}
					}	
				} else if(result != 'OK'){
					if(result == 'KO'){
						this.showToast('Error', errorMsgLabel, 'error', 'pester');
					}else if (!result.includes('Warning')) {
						this.showToast('Error', result, 'error', 'pester');
					}
				}

			}catch(error){
				console.error(error);
			}


			}else{
			this.handleError();
			this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
			this.showSpinner = false;
		}

	}

	async evaluateReassignation(){
		this.showModal = false;

		
		if((this.opposObject != undefined && Object.keys(this.opposObject)[0] != undefined ) || this.switchModal){  
			
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
			
	
			if (ownerMismatch || ownerMismatch2) {  
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
							if (this.tasksObject[key]['owner'] != this.userLogged.Id) {
								this.tasksObject[key]['owner'] = this.userLogged.Id;
							}
						}
					}
				} 
				this.showModal = false;
			}
		}
	}
	createOpportunityInsert(buttonEvent) {
		if(this.noLocalizadoAfterSave == undefined || this.noLocalizadoAfterSave == null){
			this.noLocalizadoAfterSave = false;
		}
		unWrappOpportunities({ opportunities:this.listOppInsert, accountId:this.clientid, isInsert: true,isNoLocalizado: this.noLocalizadoAfterSave})  
			.then(result=> {
				if (result != null) {
					if (result.results == 'OK') {
						this.listOppIdsNews = result.opposId;
 						this.createOpportunityUpdate(buttonEvent,this.listOppIdsNews);
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

	createOpportunityUpdate(buttonEvent,listOppNews) {
		if(this.noLocalizadoAfterSave == undefined || this.noLocalizadoAfterSave == null){
			this.noLocalizadoAfterSave = false;
		}
		unWrappOpportunities({ opportunities:this.listOppUpdate, accountId:this.clientid,isInsert: false,isNoLocalizado:this.noLocalizadoAfterSave})   
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
		if(this.nolocalizado == undefined || this.nolocalizado == null){
			this.nolocalizado = false;
		}
		sendDataToController({ eventOrTsk: this.taskOrEventInfo, opportunities: this.opposObject, mapOldOpp: listOppOlds, opposId: listOppNews,isNoLocalizadoActive: this.nolocalizado})
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
							this.redirectToPlanificarCita();
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
						if (buttonEvent != 'true') {
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
		createTaskOpp({jsonResultTaskEvent: JSON.stringify(resultTaskEvent)})
		.then(result =>{
			if (result != null) {
				if(result == 'OK'){
					if(listOppIdsAll != null) { 
						this.sendToGcfOpportunity(listOppIdsAll,buttonEvent);
					}else{
						if (buttonEvent != 'true') {
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
		if(this.taskOrEventInfo.type == 'task'){
			sendOppToGCF({listIdsOppUpdateCreated:listIdsOpps,newEvTsk:this.taskOrEventInfo.typeTask})  
			.then(result =>{
				if(buttonEvent != 'true'){
					this.handleCancel();
				}
				this.showSpinner = false;
				if(result != 'OK') {
					console.log('Error sendOppToGCF '+result);
				}
			}).catch(error => {
				if(buttonEvent != 'true'){
					this.handleCancel();
				}
				this.showSpinner = false;
				console.log(error);
			})

		}else if(this.taskOrEventInfo.type == 'event'){
			sendOppToGCF({listIdsOppUpdateCreated:listIdsOpps,newEvTsk:this.taskOrEventInfo.typeEvent})  
			.then(result =>{
				if(buttonEvent != 'true'){
					this.handleCancel();
				}
				this.showSpinner = false;
				if(result != 'OK') {
					console.log('Error sendOppToGCF '+result);
				}
			}).catch(error => {
				if(buttonEvent != 'true'){
					this.handleCancel();
				}
				this.showSpinner = false;
				console.log(error);
			})

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

	evaluateAgendeds(e){
		this.disableButtonSave = e.detail;
		this.disableButtonSaveAndEvent = e.detail;
	}

	setOppoForController(e){
		this.opposObject = e.detail;
		var oppInsert = {};
		var oppUpdate = {};
		for(let oppoId in this.opposObject){
			if (oppoId.includes(IDPROVISIONAL)) {
				oppInsert[oppoId]= this.opposObject[oppoId];
				oppInsert[oppoId]['owneridopp']= this.userLogged.Id; 
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
		this.template.querySelector('[data-id="saveAndEventButton"]').disabled = !e.detail;
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