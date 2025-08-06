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
import unlinkOpp from '@salesforce/apex/AV_TaskReport_Controller.unlinkOpp';
import unlinkLabel from '@salesforce/label/c.AV_UnlinkOpp_Error';
import successLabel from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel from '@salesforce/label/c.AV_CMP_SuccessUnlinkOpp';
import validatePFNewOppAndForbiddenWords from '@salesforce/apex/AV_NewOpportunity_Controller.validatePFNewOppAndForbiddenWords';
import getUserInfo from '@salesforce/apex/AV_ReportAppointment_Controller.getUserInfo';  




//Label
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';
const IDPROVISIONAL = 'idProvisional';

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
	@track isShowNewEvent = false;
	@track objectInfo;
	buttonEventToNoComercial;
	isLegalEntity = false;
	isShowFlowAction = false;
	goPlanAppointment;
	isIntouch = false;
	headerId;
	statusTask;
	activityDateTask;
	priorityTask;
	currentPageReference;
	nameAccount;
	idAccount;
	idTask;
	opposObject;
	listOppInsert;
	listOppUpdate;
	showEventPopup = false;
	showNoOpportunityMessage = false;
	showTaskPopup = false;
	nowReference = new Date().toJSON();
	@track radioButtonSelected = false;
	opposScheduled = [];
	descripcion;
	reminder;
	typeTask;
	disableButtonSaveAndEvent = true;
	descartadas = [];
	diferentes = [];
	opposList =  [];
	opposVinculed = [];
	userLogged; 
	ownerToReport;
    @track showModal = false; 
	switchModal = false; 
	
	taskOwner;
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
	typeLabel = {
		'030':'Muro',
		'ESE':'Email,sms,etc',
		'OFT':'Tarea de oficina'
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

	connectedCallback(){
        this.recordId = this.currentPageReference.state.c__recId;
        const selectedEvent = new CustomEvent("renametab");
		this.dispatchEvent(selectedEvent);
		this.getTaskData();
		
		
    }

	getTaskData(){
		getTaskData({id: this.recordId})
		.then(result => {
			this.idTask = result.id;
			this.recordTask = result;
			this.nameAccount = result.accountName;
			this.idAccount = result.accountId;
			this.isLegalEntity = result.accountRt == 'CC_Cliente';
			this.isIntouch = result.contactIntouch;
			this.headerId = result.headerId;
			this.statusTask = result.statusTask;
			this.activityDateTask =  result.activityDateTask;
			this.priorityTask = result.priorityTask; 
			this.showSpinner= false;
			this.showAllsBlocks = true;
			this.descripcion = result.descripcion;
			this.reminder = result.reminder;
			this.typeTask = result.tipo;
			this.taskOwner = result.owner;
			
			
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
		this.disableButtonSave = e.detail;
		this.disableButtonSaveAndEvent = !e.detail;
	}

	setOppoForController(e){
		this.opposObject = e.detail;
		let discardedOpps = []
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
			if (!discardedOpps.includes(this.descartadas[i]) &&  this.descartadas[i]!= null) {
				this.diferentes.push(this.descartadas[i]);
				this.descartadas[i]= null;
				
			}
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
		let cntcBlck = this.template.querySelector("[data-id='contactBlock']");
		if(cntcBlck.checkboxStatus){
			cntcBlck.switchCitaCheckBox(false);
		}
		this.showNoOpportunityMessage = false;
	}

	restoreeventreport(){
		this.isShowNewEvent = false;
		this.opposObject = {};
		this.eventInfo = {};
		this.citaComercial = false;

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
		let error = null;
		var vacio = '{}';
		let comentarios = [];
		var nowReference = new Date().toJSON();

		

		if(JSON.stringify(this.getEvent) == vacio && this.getTask != null && JSON.stringify(this.getTask) != vacio){
			if (!this.radioButtonSelected) {
				this.showToast('Error', 'Debes seleccionar al menos un radio button en la pestaña "Sin cliente".', 'error', 'pester');
				error='KO';
			}
		}else if (this.getEvent != null && JSON.stringify(this.getEvent) != vacio) {
			if (this.getEvent.typeEvent == 'CTOOC' && this.getEvent.office == null) {
				this.showToast('Error', 'Cuando se selecciona "Cita en otra oficina" debes rellena el campo "Oficina".', 'error', 'pester');
				error='KO';
			}else if(this.getEvent.activityDateTime == null || this.getEvent.activityDateTime > nowReference){
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
					Closedate: opp['closedate'],
					ProductName: opp['productName'],
					isVinculed : false,
					mainVinculed: opp['mainVinculed'],
					isTheLastItem : count == countAgend,
					HistoryComment : opp['commentHistory'],
					PrioritzingCustomer : opp['prioritzingCustomer'],
					Agendado: opp['agendado'],
					IsNewProduct: opp['isnewprod']	
					,owneridopp : opp['owneridopp']   
				}
			);
			if(opp['agendado']){
				count++;
			}

			if(opp['mainVinculed']){
				recordName = opp['productName'];
			}
		})
		
		if(this.getEvent.tab == 'tabEvent'){
			this.objectInfo = {
				originReport : 'Task',
				objectToReport : {
					sobjectType: 'Event',
					AV_Tipo__c: this.getEvent['typeEvent'],
					StartDateTime : this.getEvent['activityDateTime'],
					EndDateTime : this.sumMinutes(this.getEvent['activityDateTime'],this.getEvent['duracion']),
					AV_MemorableInterview__c: this.getEvent['memorableInterview'],
					Description: this.getEvent['comment'],
					AV_BranchPhysicalMeet__c: this.getEvent['office'],
					WhoId: this.getEvent['contactPerson'],
					Location: this.getEvent['location'],
					WhatId : this.idAccount,
					Subject : (!this.citaComercial && recordName != undefined) ? recordName : 'Gestión operativa',
					RecordTypeId : 'AV_EventosConCliente',
					AV_OrigenApp__c : 'AV_SalesforceClientReport',
					CSBD_Evento_Estado__c : 'Gestionada Positiva' 
				},
				citaComercial: this.getEvent['comercial'],
				vinculatedOpportunities:this.opposObject,
				vinculatedTasks : vinculatedTasks,
				oldOppos : this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates(),
				TaskToClose: {
					sobjectType : 'AV_ManagementHistory__c',
					AV_ActivityId__c : this.idTask,
					AV_Comment__c : this.descripcion,
					AV_Date__c : this.activityDateTask,
					AV_Reminder__c : this.reminder,
					AV_Status__c : 'Gestionada positiva',
					AV_Type__c : this.typeTask,
					OwnerId: null
				},
				HeaderId:this.headerId
			}
			
			if(this.objectInfo.objectToReport.citaComercial){
				this.objectInfo.objectToReport.AV_Purpose__c = '002';
			}else{
				this.objectInfo.objectToReport.AV_Purpose__c = '001';
			}
		}else if(this.getTask.tab == 'tabTask'){
			this.objectInfo = {
				originReport : 'Task',
				objectToReport : {
					sobjectType: 'Task',
					Id : this.idTask,
					AV_Tipo__c: this.getTask.typeTask,
					Status: this.getTask.statusTask,
					WhatId : this.idAccount,
					ActivityDate: this.activityDateTask,
					Subject : (!this.citaComercial && recordName != undefined) ? recordName : this.typeLabel[this.getTask['typeTask']],
					RecordTypeId : 'AV_Otros',
					Description : this.getTask.comentaryTask

				}
				,vinculatedOpportunities:this.opposObject,
				vinculatedTasks : vinculatedTasks,
				oldOppos : this.template.querySelector('[data-id="oppoCmp"]').sendInitialStates(),
				TaskToClose: {
					sobjectType : 'AV_ManagementHistory__c',
					AV_ActivityId__c : this.idTask,
					AV_Comment__c : this.getTask.comentaryTask,
					AV_Date__c : this.activityDateTask,
					AV_Reminder__c : this.reminder,
					AV_Status__c :this.getTask.statusTask,
					AV_Type__c :this.getTask.typeTask,
					OwnerId: null
				},
				HeaderId:this.headerId
			}
		} 
		for(let key in this.objectInfo.objectToReport){
			if(this.objectInfo.objectToReport[key] == null || this.objectInfo.objectToReport[key] == undefined){
				delete this.objectInfo.objectToReport[key];
			}
		}
		for(let key in this.objectInfo.TaskToClose){
			if(this.objectInfo.TaskToClose[key] == null || this.objectInfo.TaskToClose[key] == undefined){
				delete this.objectInfo.TaskToClose[key];
			}
		}

		for(let oppoId in this.opposObject){
			let comentario = this.opposObject[oppoId]['comentario'];
			comentarios.push(comentario);
		}

		if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial) {
			let coment = null;
			if(this.getEvent.comment !=null){
				coment = this.getEvent.comment;
			}else if(this.getTask.comentaryTask != null){
				coment = this.getTask.comentaryTask;
			}
			if(coment != null){
				comentarios.push(coment);
			}
			let validateResponse = this.validateDates();
			if(validateResponse == true){

			try{	
				const result = await validatePFNewOppAndForbiddenWords(
					{prodId : null,
					tskId : this.recordId,
					comments : comentarios,
					names : null
				});

				if (error == null && result == 'OK') {
					await this.evaluateReassignation();
					this.objectInfo.vinculatedOpportunities = this.opposObject;
					this.objectInfo.TaskToClose.OwnerId = this.getTask.ownerid;
					this.opposScheduled.forEach(oppo => {
						oppo.owneridopp = this.opposObject[oppo.Id]['owneridopp'];
					})
					this.isShowNewEvent = true;
					this.showSpinner = false;
				
					if(this.diferentes != null && this.diferentes.length > 0){
						this.unlinkOpp();
					}
				}else if(result != 'OK'){
					if(result == 'KO'){
						this.showToast('Error', errorMsgLabel, 'error', 'pester');
					}else if (result.includes('Warning')) {
						this.showToast('Warning', result, 'warning', 'sticky');
					}else {
						this.showToast('Error', result, 'error', 'pester');
					}	
				}
			}catch(error){
				console.error('Error: ',error);
			}
			}else{
				this.handleError();
				this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
				this.showSpinner = false;
			}
			
			


		} else {
			if(error == null){
				if (JSON.stringify(this.getEvent) != vacio){
					this.switchModal = true;  
					this.handleError();
					this.showEventPopup = true;
					this.showNoOpportunityMessage = true;
				}else {
					this.switchModal = true;  
					this.handleError();
					this.showTaskPopup = true;
					this.showNoOpportunityMessage = true;
				}
			}
		}
	}
	formatDate(date){
		let auxArray = date.split('/');
		return auxArray[2] +'-'+this.fillNumbers(auxArray[1])+'-'+this.fillNumbers(auxArray[0]);
	}

	fillNumbers(n){
		return (n >= 10) ? n : '0'+n;
	}
	async evaluateReassignation(){
		if((this.opposObject != undefined  && Object.keys(this.opposObject)[0] != undefined )|| this.switchModal){  
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
			
			let reportMismatch = (this.userLogged.Id != this.taskOwner && this.currentMultigest !=  this.taskOwner);
			if (ownerMismatch || ownerMismatch2 || reportMismatch) {
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

					if(reportMismatch || this.taskOwner == this.currentMultigest){
						this.getTask.ownerid = this.userLogged.Id;
					}
					
				} else if(this.taskOwner == this.currentMultigest){
					this.getTask.ownerid = this.userLogged.Id;
				}else{
					this.getTask.ownerid = this.taskOwner;
				}
				this.showModal = false;
				
			}else if(this.taskOwner == this.currentMultigest){
				this.getTask.ownerid = this.userLogged.Id;
			}else{
				this.getTask.ownerid = this.taskOwner;
			}
			
		
		}
	}
	async handleSave(){  
		this.goPlanAppointment = false;
		this.buttonEventToNoComercial='false';
		let error = null;
		var vacio = '{}';
		let comentarios = [];
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

		for(let oppoId in this.opposObject){
			let comentario = this.opposObject[oppoId]['comentario'];
			comentarios.push(comentario);
		}
		
		let coment = null;
		if(this.getEvent.comment !=null && this.getEvent.comment.trim() !== ''){
			coment = this.getEvent.comment;
		}else if(this.getTask.comentaryTask != null && this.getTask.comentaryTask.trim() !== ''){
			coment = this.getTask.comentaryTask;
		}
		if(coment != null){
			comentarios.push(coment);
		}
			
		let validateResponse = this.validateDates();
		if(validateResponse == true){

			console.log('recordId-->',JSON.stringify(this.recordId));
			console.log('opposobj-->',JSON.stringify(this.opposObject));

		try{	
			const result = await validatePFNewOppAndForbiddenWords(
				{prodId : null,
				tskId : this.recordId,
				comments : comentarios,
				names : null
			});
			
			if((error == null && result == 'OK')|| (error == null && result.includes('Warning'))) {
				if((this.opposObject != null && Object.keys(this.opposObject).length > 0) || this.citaComercial){
					if (result.includes('Warning')) {
						console.log('result error-->'+result);
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
								
				} else {
					if(error == null){
						if (JSON.stringify(this.getEvent) != vacio){
							this.switchModal = true;  
							this.handleError();
							this.showEventPopup = true;
							this.showNoOpportunityMessage = true;
						}else {
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
			console.error('Error: ',error);
		}
		}else{
			this.handleError();
			this.template.querySelector('[data-id="oppoCmp"]').highlightOppo(validateResponse);
			this.showSpinner = false;
		}
		
	}

	saveOpportunityInsert(buttonEvent) {
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
		console.log('Lista de oppos => ',this.listOppUpdate);
		console.log('Lista de oppos => ',JSON.stringify(this.listOppUpdate));
		insertOrUpdateOpp({ opportunities:this.listOppUpdate, accountId:this.idAccount, isInsert: false})
		.then(result=> {
			if (result != null) {
				if (result.results == 'OK') {
					var listOppIdsAll = result.opposId;
					if (listOppNews != null) {
						Array.prototype.push.apply(listOppIdsAll,listOppNews);
					}
					
					this.saveTaskAndEvent(listOppNews,result.mapOldOpp,listOppIdsAll,buttonEvent);
					
					this.showSpinner = false;
				} else {
					if (listOppNews != null) {
						this.backOpportunity(result.results,null,listOppNews,buttonEvent);
					} else {
						console.log('e codigog se acaba aqui');
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
		});
	}

	saveTaskAndEvent(listOppNews, listOppOlds, listOppIdsAll, buttonEvent) {
		eventAndTaskProcess({event: this.getEvent,task: this.getTask, taskBlock: this.tasksObject, opportunities: this.opposObject, mapOldOpp: listOppOlds, opposId: listOppNews})
		.then(result =>{
			if (result != null) {
				if(result.result == 'OK'){ 
					if ((listOppNews != null || listOppOlds != null) && ((result.listTaskChangeDate != null && result.listTaskChangeDate != '') || (result.listTaskToDelete != null && result.listTaskToDelete != '') || (result.listTaskOpportunityDelete != null && result.listTaskOpportunityDelete != ''))) {
						this.saveCheckOnOff(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
					} else if (listOppNews != null || listOppOlds != null) {
						this.saveTaskOpp(listOppNews, listOppOlds, listOppIdsAll, buttonEvent, result);
					} else {
						if (buttonEvent != 'true') {
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
		createTaskOpp({jsonResultTaskEvent: JSON.stringify(resultTaskEvent), task: this.getTask})
		.then(result =>{
			if (result != null) {
				if(result == 'OK'){
					if(listOppIdsAll != null) { 
						this.sendToGcf(listOppIdsAll,buttonEvent);
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

	

	sendToGcf(listIdsOpps, buttonEvent) {
		if(this.getEvent.typeEvent!= null){
			sendOppToGCF({listIdsOppUpdateCreated:listIdsOpps, newEvTsk:this.getEvent.typeEvent})
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
		}else if(this.getTask.typeTask!= null){
			sendOppToGCF({listIdsOppUpdateCreated:listIdsOpps, newEvTsk:this.getTask.typeTask})
			.then(result =>{
				if(buttonEvent != 'true'){
					this.handleCancel();
				}
				this.showSpinner = false;
				if(result != 'OK') {
					console.log('Error sendOppToGC '+result);
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