import { LightningElement,wire,track, api }    				   from 'lwc';
import { CurrentPageReference  } 	   		   				   from 'lightning/navigation';
import {ShowToastEvent}				   						   from 'lightning/platformShowToastEvent';
import {getRecord}                     						   from 'lightning/uiRecordApi';
import {NavigationMixin}  									   from 'lightning/navigation';

import getRelatedOppos 				   		   				   from '@salesforce/apex/AV_NewEvent_Controller.retrieveAccountOpportunities';
import getComboboxValues 									   from '@salesforce/apex/AV_ReportAppointment_Controller.getPicklistValues';
import searchProduct 				   		   				   from '@salesforce/apex/AV_NewEvent_Controller.searchProduct';
import createEvent                     		   				   from '@salesforce/apex/AV_NewEvent_Controller.createEvent';
import createEventFromReport                   				   from '@salesforce/apex/AV_NewEvent_Controller.createEventFromReport';
import createAttendesRelation          		   				   from '@salesforce/apex/AV_NewEvent_Controller.createEventRelation';
import createOrUpdateOpportunities     		   				   from '@salesforce/apex/AV_NewEvent_Controller.createOrUpdateOpportunities';
import deleteCreatedEventOrAttendesAndReportedTasks    		   from '@salesforce/apex/AV_NewEvent_Controller.backupEventsAndAttendes';
import vinculateOpportunities     	   		    			   from '@salesforce/apex/AV_NewEvent_Controller.vinculateOpposToTheNewEvent';
import backCreatedOrUpdtOppos     	   		    			   from '@salesforce/apex/AV_NewEvent_Controller.backReportOppos';
import sendToGfc			     	   		    			   from '@salesforce/apex/AV_NewEvent_Controller.sendOppToGCF';
import createOrUpdateOpportunitiesFromReport    			   from '@salesforce/apex/AV_NewEvent_Controller.createOrUpdateOpportunitiesFromReport';
import processCheckOnOffCreate				    			   from '@salesforce/apex/AV_NewEvent_Controller.processCheckOnOffCreate';
import processCheckOnOffUpdate				    			   from '@salesforce/apex/AV_NewEvent_Controller.processCheckOnOffUpdate';
import processCheckOnOffDelete				    			   from '@salesforce/apex/AV_NewEvent_Controller.processCheckOnOffDelete';
import vinculateFromReport					    			   from '@salesforce/apex/AV_NewEvent_Controller.vinculateFromReport';
import closeClientTasks					  	    			   from '@salesforce/apex/AV_NewEvent_Controller.closeClientTasks';
import backClosedTaskReport					  	    		   from '@salesforce/apex/AV_NewEvent_Controller.backClosedTaskReport';
import syncWithGcf 											   from '@salesforce/apex/AV_NewEvent_Controller.syncWithGcf';
import getName      										   from '@salesforce/apex/AV_Header_Controller.getAccountInfo';
import validatePFNewOppAndForbiddenWords 					   from '@salesforce/apex/AV_NewOpportunity_Controller.validatePFNewOppAndForbiddenWords';

import ISBPR 						   						   from '@salesforce/customPermission/AV_PrivateBanking';
import USER_ID 						   						   from '@salesforce/user/Id';
import FUNCION 						   						   from '@salesforce/schema/User.AV_Funcion__c';
import getUserInfo                                             from '@salesforce/apex/AV_ReportAppointment_Controller.getUserInfo';  


const GESTOR = 'Gestor';
const IDPROVISIONAL = 'idProvisional';
const SEPARATOR = '{|}';

export default class Av_newEvent extends NavigationMixin(LightningElement) {

	@api opposlist;
	@api opposvinculed;
	@api opposscheduled;
	@api recordId;
	@track opposscheduledagended = [];
	@api comesfromevent;
	@api reportedevent;
	@api reportedetask;
	userTimeZone;
	newEventHeaderId;
	thereisoppos;
	backEventReported = null;
    recordId;
    clientinfo;
    newEvent;
    oppoObj = {};
    opposCount = 0;
    selectedProds = [];
    @track oppoList;
    @track oppoNewList = [];
	@track resolutionList
    potentialList;
	showSpinner = true;
	noComercial = false;
	dateIniFinal;
	dateFinFinal;
	editedOpportunitiesFromReport;
	newRecordFromTaskReport;
	reportedActivityHeaderId;
	updatedClientTasksBack = null;
	closedTaskToBack = null;
	closedManagementHistoryToBack = null;
	insertedMMHofClosedTasks = null;
	taskInsertedCheckOnOff = [];
	caosInsertedCheckOnOff = [];
	editedCheckTaskOnOffToUpdateBack;
	deletedCheckOnOffBack;
	durationToCalendar;
	activityDateToCalendar;
	employeeToCalendar;
	subjectToCalendar;
	overlapToCalendar;
	currentMainVinculed;
	nextScreen = false; 
	today = new Date().toJSON().slice(0,10);
	newRecordFromReportHeaderId
	showCalendar = false;
	currentUserFunction;
    productToAdd = true;
    idProvisional = 0;
	createdEventId;
	createdAttendesOrEventId = [];
	createdOpposIds = [];
	copyOpposBeforeUpdt;
	updatedOpposId;
	altaDeActividadLabel = 'Alta de actividad';
	checkOnOffTasksBackUp;
	caosCheckOnOffBackUp;
	taskAndOpposRel;
	accountId;
	@track initialDuration;
	durationToSend;
	clientNumper;
	loadedData = false;
	evtIdInsert;
	objFirstOrignRp; 
	objScondOrignRp;
	@track showButtonDelete = false;
	hasRendered = true;
	hasRenderedCalendar = true;
	opposscheduledagendedIds = [];
	opposscheduledclosed = [];
	opposscheduledclosedIds = [];
	parseOpposFromScreen = {};
	parseListOpposFromScreen = {};
	mapProvIdToBBDDId = {};
	mapIdBBDIDToProv = {};
	showOpposlistClient = false;
	caosFirstScreen = [];
	caosSecondScreen = [];
	mapMainForFirstScreen = {};
	@api clientfromcall;
	callReportBack;
	operatedEventInCallReport;
	isCallRecord = false;
	currentEventType;
	typeEventValue = false;
	@track showModal = false; 
	userLogged;
	switchModal = false;  
	currentMultigest; 
	eventDateTimeCalendar;
	eventId;
	mapTypeDuration = {
		'CTO':'60',
		'CTF':'30',
		'VLD':'30',
		'CTOOC':'60',
		'001':'60'
	}
	mapDurationText = {
		5:'5 min',
		15:'15 min',
		30:'30 min',
		60:'1 h',
		120:'2 h',
		0:'Otra'
	}
	typeLabel = {
		'030':'Muro',
		'ESE':'Email,sms,etc',
		'OFT':'Tarea de oficina'
	}
	disableButtonCancel = false;
	disableButtonSave = false;
	timeInicio = this.setHours(new Date().getHours())+':'+this.setHours(new Date().getMinutes());
	get tomorrow(){
        let msInADay = 24*60*60*1000;
        let msForTomorrow = (new Date().getTime()) + msInADay;
        return  new Date(msForTomorrow).toJSON().slice(0,10);
    }
	activityDateToSend = this.tomorrow;
	timeFin;
	timeInfo; //Guarda la informacion de la hora del evento
	timeInicioEvent;
	timeFinEvent;
	get optionsTime(){
		return [
			{label:'5 min',value:'5'},
			{label:'15 min',value:'15'},
			{label:'30 min',value:'30'},
			{label:'1 h',value:'60'},
			{label:'2 h',value:'120'},
			{label:'Otra',value:'0'}
		];
	}
	
	setHours(hour) {
		var listNums = [0,1,2,3,4,5,6,7,8,9];
		if(listNums.includes(hour)) {
			hour = '0'+hour;
		}
		return hour;
	}
	@wire(getComboboxValues,{ fields: ['AV_Resolucion__c','AV_Potencial__c']} )
	getComboboxValues(wireResult){
		let error = wireResult.error;
		let data = wireResult.data;
		if(data){
			this.resolutionList = data[0].filter(item => item.value !== 'VD' && item.value !== 'Vencida');
			this.potentialList = data[1];
		}else if(error){
			console.log('Error => ',error);
		}
	}
	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
		if(this.comesfromevent){
			this.recordId = this.currentPageReference.state.c__recId;
			this.accountId = (this.currentPageReference.state.c__account != '') ? this.currentPageReference.state.c__account : null;
			if(this.clientfromcall != null){
				this.accountId = this.clientfromcall.clientId;
				this.clientinfo = {
					id:this.accountId,   
					name:this.clientfromcall.clientName,
					intouch:this.clientfromcall.clientIntouch,
					recordtype:this.clientfromcall.clientRtDevName,
					accountId:this.accountId
				}
			}else{

				this.clientinfo = {
					id:this.recordId,   
					name:this.currentPageReference.state.c__id,
					intouch:this.currentPageReference.state.c__intouch,
					recordtype:this.currentPageReference.state.c__rt,
					accountId:this.accountId
				}
			}
			this.loadedData = true;
			this.setCalendarInfo();
		}else{
			this.clientNumper = this.currentPageReference.state.c__clientNumper;
			this.eventId =  this.currentPageReference.state.c__id;

			this.getComponentData();
		}
	}

	getComponentData(){
		let dataToController = (this.clientNumper != null) ? {clientNumper:this.clientNumper}: {recordId: this.eventId};
		getName(dataToController)
		.then(data =>{
			if(data){
				this.recordId = this.currentPageReference.state.c__recId;
			
				this.clientinfo = {
					id:this.recordId,   
					name:data.accountName,
					intouch:data.isIntouch,
					recordtype:data.rtDevName,
					accountId:data.accountId,
					eventSubject:data.nameRecord,
					eventType: data.eventType,
					eventDateTime: data.eventDateTime,
					eventInitTime: data.eventInitTime,
					eventEndTime: data.eventEndTime
				}
				
				if(data.eventDateTime != null){
					this.eventDateTimeCalendar = data.eventDateTime;
					this.activityDateToSend = data.eventDateTime;
					if(data.eventInitTime != null){
						this.timeInicio = data.eventInitTime;
					}
					if(data.eventEndTime != null){
						this.timeFin = data.eventEndTime;
					}
				}

				if(data.eventType != null){
					this.currentEventType = data.eventType;
					this.initialDuration = this.mapTypeDuration[data.eventType];
				}
			
				this.accountId = data.accountId;
				this.loadedData = true;
				this.getRelatedOpportunities();
				this.setCalendarInfo();
			
				
			}
		}).catch(error =>{
			console.error(error);
		});
	}

	setCalendarInfo(){

		if(!this.initialDuration){
			this.initialDuration = (this.clientinfo.intouch == 'true') ? '30' : '60';

			this.durationToSend = parseInt(this.initialDuration,10);
			var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
			iniDate.setHours(iniDate.getHours(),iniDate.getMinutes()+this.durationToSend,'00');
			this.timeFin = this.setHours(iniDate.getHours())+':'+this.setHours(iniDate.getMinutes());
			this.timeInfo = {
				date : this.formatDate(this.activityDateToSend),
				hourini : this.timeInicio,
				hourfin : this.timeFin,
				duration : this.mapDurationText[this.durationToSend]
			};
		}
	}

	@wire(getRecord, {recordId:USER_ID,fields:[FUNCION]})
	wiredUser({error, data}) {    
		if (data)  { 
			this.currentUserFunction = data.fields.AV_Funcion__c.value;
		} else if (error) {
			this.error = error ;
		}
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

	handleChangeActivityDate(e){
		this.template.querySelector('[data-id="activityDateInput"]').reportValidity();
		this.activityDateToSend = e.target.value;
		this.activityDateToCalendar = this.activityDateToSend;
		this.timeInfo = {
			date : this.formatDate(this.activityDateToSend),
			hourini : this.timeInicio,
			hourfin : this.timeFin,
			duration : this.mapDurationText[this.durationToSend]
		};
	}

	handleChangeTimeInicio(e){
		this.timeInicio = e.target.value;
		var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
		var finDate = new Date(this.activityDateToSend+' '+this.timeFin);
		var numDiff = finDate.getTime()-iniDate.getTime();
		numDiff /= (1000*60);
		if (numDiff != 5 && numDiff != 15 && numDiff != 30 && numDiff != 60 && numDiff != 120) {
			this.durationToSend = 0;
			this.initialDuration = '0';
		}else {
			this.durationToSend = numDiff;
			this.initialDuration = numDiff.toString();
		}
		if(this.durationToSend == 0) {
			this.durationToCalendar = numDiff;
		} else {
			this.durationToCalendar = this.durationToSend;
		}
		this.timeInfo = {
			date : this.formatDate(this.activityDateToSend),
			hourini : this.timeInicio,
			hourfin : this.timeFin,
			duration : this.mapDurationText[this.durationToSend]
		};
	}

	handleChangeTimeFin(e){
		this.timeFin = e.target.value;
		var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
		var finDate = new Date(this.activityDateToSend+' '+this.timeFin);
		var numDiff = finDate.getTime()-iniDate.getTime();
		numDiff /= (1000*60);
		if (numDiff != 5 && numDiff != 15 && numDiff != 30 && numDiff != 60 && numDiff != 120) {
			this.durationToSend = 0;
			this.initialDuration = '0';
		}else {
			this.durationToSend = numDiff;
			this.initialDuration = numDiff.toString();
		}
		if(this.durationToSend == 0) {
			this.durationToCalendar = numDiff;
		} else {
			this.durationToCalendar = this.durationToSend;
		}
		this.timeInfo = {
			date : this.formatDate(this.activityDateToSend),
			hourini : this.timeInicio,
			hourfin : this.timeFin,
			duration : this.mapDurationText[this.durationToSend]
		};
	}

	handleChangeDuration(e){
		this.durationToSend = parseInt(e.target.value);
		this.initialDuration = e.target.value;
		var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
		var finDate = new Date(this.activityDateToSend+' '+this.timeFin);
		iniDate.setHours(iniDate.getHours(),iniDate.getMinutes()+this.durationToSend,'00');
		if(this.durationToSend == 0) {
			var numDiff = finDate.getTime()-iniDate.getTime();
			numDiff /= (1000*60);
			this.durationToCalendar = numDiff;
		} else {
			this.durationToCalendar = this.durationToSend;
			this.timeFin = this.setHours(iniDate.getHours())+':'+this.setHours(iniDate.getMinutes());
		}
		this.timeInfo = {
			date : this.formatDate(this.activityDateToSend),
			hourini : this.timeInicio,
			hourfin : this.timeFin,
			duration : this.mapDurationText[this.durationToSend]
		};
	}

	handleTime(){
		if (this.validateInputsAddEvents()) {
			if(this.durationToSend == 0) {
				var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
				var finDate = new Date(this.activityDateToSend+' '+this.timeFin);
				var numDiff = finDate.getTime()-iniDate.getTime();
				numDiff /= (1000*60);
				this.durationToCalendar = numDiff;
			} else {
				this.durationToCalendar = this.durationToSend;
			}
			this.activityDateToCalendar = this.activityDateToSend;
			this.template.querySelector('[data-id="customcalendar"]').addEvent(new Date(this.activityDateToSend+' '+this.timeInicio));

			this.timeInfo = {
				date : this.formatDate(this.activityDateToSend),
				hourini : this.timeInicio,
				hourfin : this.timeFin,
				duration : this.mapDurationText[this.durationToSend]
			};
		}
	}

    connectedCallback(){
		if(this.comesfromevent){
			this.objectToController = (this.reportedetask == undefined) ? this.reportedevent : this.reportedetask;
			this.parseOpposFromScreen = JSON.parse(JSON.stringify(this.objectToController.vinculatedOpportunities));
			this.filterListFromReport();
		}
    }

	renderedCallback(){
		if(this.nextScreen){
			if(this.hasRendered){
				let thereisMain = false;
				if(this.opposscheduledagended){
					this.opposscheduledagended.forEach(opp => {
						this.template.querySelector('[data-id="' + opp.Id + '"]').clickbutton();
						if(opp.mainVinculed){
							thereisMain = true;
						}
					})
				}

				if(this.mapMainForFirstScreen != null && thereisMain){
					if(this.opposCount > 1){
						for(let Id in this.mapMainForFirstScreen){
							const oppDetail = this.template.querySelector('[data-id="'+Id+'"]');
							if(oppDetail){
								oppDetail.mainVinculed = this.mapMainForFirstScreen[Id];
							}
						}
					}
				}
			
				this.hasRendered = false;
			}
		}		
	}

	calendarRendered(event){
		const isRendered = event.detail.rendered;
		if(isRendered){
			var customcalendar =  this.template.querySelector('[data-id="customcalendar"]');
			if(this.eventDateTimeCalendar != null){
				if(customcalendar != null){
					if(this.hasRenderedCalendar){
						this.template.querySelector('[data-id="addButton"]').click();
						this.hasRenderedCalendar = false;
					}
				}
			}
		}
	}

	filterListFromReport(){
		let auxList = [];
		let parseopposlist = [];
		if(this.opposlist != null){
			parseopposlist = JSON.parse(JSON.stringify(this.opposlist));
		}
		if(this.opposscheduled != null){
			this.opposscheduled.forEach(oppo => {
				if(oppo.Agendado){
					this.opposscheduledagended.push(oppo);
					this.selectedProds.push(oppo.ProductoMain);
				}
				if(oppo.Stage == 'Cerrado Positivo' || oppo.Stage == 'No interesado' || oppo.Stage == 'Producto Rechazado' || oppo.Stage == 'Producto Contratado'){
					this.opposscheduledclosed.push(oppo);
				}
				if(oppo.Id.includes(IDPROVISIONAL)){
					let oppoCopy = JSON.parse(JSON.stringify(oppo));
					oppoCopy.mainVinculed = false;
					auxList.push(oppoCopy);
					this.idProvisional++;
				}
				if(oppo.mainVinculed){
					if (!parseopposlist.some(existingOppo => existingOppo.Id === oppo.Id)){
						let oppoCopy = JSON.parse(JSON.stringify(oppo));
						oppoCopy.mainVinculed = false;
						parseopposlist.push(oppoCopy);
					}
				}
				
				this.mapMainForFirstScreen[oppo.Id] = oppo.mainVinculed;

				if (!parseopposlist.some(existingOppo => existingOppo.Id === oppo.Id)){
					parseopposlist.push(oppo);
					this.selectedProds.push(oppo.ProductoMain);
				}
			})	
		}

		if(this.opposvinculed != null){
			auxList = auxList.concat(this.opposvinculed);	
		}
		
		if(auxList != null){
			auxList.forEach(oppo => {
				if (!parseopposlist.some(existingOppo => existingOppo.Id === oppo.Id)){
					parseopposlist.push(oppo);
					this.selectedProds.push(oppo.ProductoMain);
				}
			});
		}

		this.opposscheduledagendedIds = this.opposscheduledagended.map(oppo => oppo.Id);
		this.opposscheduledclosedIds = this.opposscheduledclosed.map(oppo => oppo.Id);
		this.opposlist = parseopposlist.filter(oppo => !this.opposscheduledagendedIds.includes(oppo.Id) && !this.opposscheduledclosedIds.includes(oppo.Id));

		if(this.opposlist != undefined && this.opposlist != null){
			if(this.opposlist.length > 0){
				this.showOpposlistClient = true;
			}
			this.opposlist.forEach(oppo => {
				this.selectedProds.push(oppo.ProductoMain);
			})
		}
		this.showSpinner = false;
		this.thereisoppos = this.opposscheduledagended.length > 0;
	}

    getRelatedOpportunities(){
		if(this.accountId != null){
			getRelatedOppos({accountId:this.accountId})
			.then(response => {
				if(response){
					this.oppoList = response.clientOppos;
					this.selectedProds = response.productsToNotShow;
					if(this.oppsBeforeUpdate != null){
						this.oppsBeforeUpdate = this.oppoList;
					}
					this.showSpinner = false;
					this.oppoNewList = [];
					this.oppoObj = {};
					this.opposCount = 0;
					this.showOpposList = true;
                }
            })
		}else{
			this.showSpinner = false;
			this.oppoNewList = [];
			this.oppoObj = {};
			this.opposCount = 0;
			this.showOpposList = false;
		}
    }

	setEventObject(e){
        this.newEvent = e.detail;
		this.initialDuration = (this.currentEventType != null && !this.typeEventValue)  ? this.mapTypeDuration[this.currentEventType] : this.mapTypeDuration[this.newEvent['type']];
		this.typeEventValue = true;


		this.durationToSend = parseInt(this.initialDuration, 10);
		this.durationToCalendar = this.durationToSend;
		this.activityDateToCalendar = this.activityDateToSend;
		if(this.newEvent['owner'] == USER_ID){
			this.overlapToCalendar = true;
		}else{
			this.overlapToCalendar = this.currentUserFunction != GESTOR;
		}
		if (this.employeeToCalendar != this.newEvent['owner'] && this.showCalendar) {
			this.employeeToCalendar = this.newEvent['owner'];
			this.template.querySelector('[data-id="customcalendar"]').changeOwnerEvent(this.employeeToCalendar , this.overlapToCalendar);
		}
		this.employeeToCalendar = this.newEvent['owner'];
		if(this.subjectToCalendar != this.newEvent['subject']) {

			this.subjectToCalendar = this.newEvent['subject'];
			let calendar = this.template.querySelector('[data-id="customcalendar"]');
			if(calendar != null){
				let inittime = calendar.initTime;
				let finaltime = calendar.endTime;
				if (inittime != null && finaltime != null) {
					calendar.changeSubjectEvent(this.subjectToCalendar);
				}
			}
		}
		this.subjectToCalendar = this.newEvent['subject'];
		this.noComercial = this.newEvent['nocomercial'];
		var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
		iniDate.setHours(iniDate.getHours(),iniDate.getMinutes()+this.durationToSend,'00');
		this.timeFin = this.setHours(iniDate.getHours())+':'+this.setHours(iniDate.getMinutes());
		this.timeInfo = {
			date : this.formatDate(this.activityDateToSend),
			hourini : this.timeInicio,
			hourfin : this.timeFin,
			duration : this.mapDurationText[this.durationToSend]
		};
		this.showCalendar = true;
		if(e.detail.changeClient){
			this.accountId = e.detail.client;
			this.getRelatedOpportunities();
		}	

    }

    handleSave(){
		validatePFNewOppAndForbiddenWords(
			{prodId : null,
			tskId : null,
			comments : this.newEvent.comentary,
			names : this.newEvent.subject
		}).then(result => {
			if(( result == 'OK')|| (result.includes('Warning'))) {
				if (result.includes('Warning')) {
					this.showToast('Warning', result, 'warning', 'sticky');
				}
		var next = this.template.querySelector('[data-id="detailCmp"]').validateRequiredInputs();
		if(next) {
			next = this.validateRequiredInputs();
		}
		if(next) {
			let calendar = this.template.querySelector('[data-id="customcalendar"]');
			this.dateIniFinal = calendar.initTime;
			this.dateFinFinal = calendar.endTime;
		
		}
		this.nextScreen = next;
		if(this.nextScreen) {
			this.template.querySelector('[data-id="headerEvent"]').scrollIntoView({behavior: 'auto',block: 'center',inline: 'center'});
		}
				
			}else if(result != 'OK'){
				if(result == 'KO'){
					this.showToast('Error', errorMsgLabel, 'error', 'pester');
					this.disableSpinner();
				}else if (!result.includes('Warning')) {
					this.showToast('Error', result, 'error', 'pester');
				}
				
			}
		})
    }

	validateInputsAddEvents() {
		if(this.activityDateToSend == null || this.activityDateToSend == '' || !this.template.querySelector('[data-id="activityDateInput"]').reportValidity() ){
			this.scrollIntoElement('activityDateInput');
			this.showToast('Faltan datos','Por favor, introduce una fecha futura','error');
			return false;
		}
		var dateSend = new Date(this.activityDateToSend);
		if(dateSend.getDay() == 0) {
			this.showToast('Fecha incorrecta','Por favor, introduce una fecha que sea de lunes a sábado','error');
			return false;
		}
		if(this.timeInicio == null || this.timeInicio == '' || !this.template.querySelector('[data-id="timeInicioInput"]').reportValidity() ){
			this.scrollIntoElement('timeInicioInput');
			this.showToast('Faltan datos','Por favor, introduce una hora de inicio','error');
			return false;
		}
		if(this.timeFin == null || this.timeFin == '' || !this.template.querySelector('[data-id="timeFinInput"]').reportValidity() ){
			this.scrollIntoElement('timeFinInput');
			this.showToast('Faltan datos','Por favor, introduce una hora de fin','error');
			return false;
		}
		var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
		var finDate = new Date(this.activityDateToSend+' '+this.timeFin);
		var numDiff = finDate.getTime()-iniDate.getTime();
		numDiff /= (1000*60);
		if(numDiff < 5){
			this.showToast('Fecha incorrecta','La duración mínima es de 5 minutos','error');
			return false;
		}
		if (this.newEvent['owner'] != USER_ID) {
			var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
			var finDate = new Date(this.activityDateToSend+' '+this.timeFin);
			var finDateMax = new Date(this.activityDateToSend+' 18:00');
			var iniDateMin = new Date(this.activityDateToSend+' 8:00');
			var numDiffMax = finDateMax.getTime()-finDate.getTime();
			numDiffMax /= (1000*60);
			var numDiffMin = iniDate.getTime()-iniDateMin.getTime();
			numDiffMin /= (1000*60);
			if (numDiffMax < 0 || numDiffMin < 0) {
				this.showToast('Fecha incorrecta','Por favor, introduce una fecha que esté entre la franja horaria de 08:00 a 18:00','error');
				return false;
			}
		} else {
			var iniDate = new Date(this.activityDateToSend+' '+this.timeInicio);
			var finDate = new Date(this.activityDateToSend+' '+this.timeFin);
			var finDateMax = new Date(this.activityDateToSend+' 21:00');
			var iniDateMin = new Date(this.activityDateToSend+' 8:00');
			var numDiffMax = finDateMax.getTime()-finDate.getTime();
			numDiffMax /= (1000*60);
			var numDiffMin = iniDate.getTime()-iniDateMin.getTime();
			numDiffMin /= (1000*60);
			if (numDiffMax < 0 || numDiffMin < 0) {
				this.showToast('Fecha incorrecta','Por favor, introduce una fecha que este entre la franja horaria de 08:00 a 21:00','error');
				return false;
			}
		}
		if(this.newEvent['owner'] == null) {
			this.showToast('Faltan datos','Por favor, introduce un empleado/a asignado','error');
			return false;
		}
		if(this.newEvent['client'] == null) {
			this.showToast('Faltan datos','Por favor, introduce un cliente','error');
			return false;
		}
		return true;
	}

	validateRequiredInputs() {
		let calendar = this.template.querySelector('[data-id="customcalendar"]');
		let inittime = calendar.initTime;
		let finaltime = calendar.endTime;
		if(inittime == undefined || finaltime == undefined || inittime == null || finaltime == null || inittime == '' || finaltime == ''){
			this.showToast('Faltan datos','Marca una franja en el calendario para continuar o darle al botón de añadir','Error');
			return false;
		}else if(new Date(inittime) < new Date() ){
			this.showToast('Fechas incorrectas','Por favor, introduce una fecha futura en el  calendario','Error');
			return false;
		}
		return true;
	}

	handleBack(){
		this.employeeToCalendar = USER_ID;
		this.overlapToCalendar = true;
		this.dateFinFinal = null;
		this.dateIniFinal = null;
		this.nextScreen = false;
		this.oppoObj = {};
		this.opposCount = 0;
		if(this.template.querySelector('[data-id="detailCmp"]') != null){
			this.template.querySelector('[data-id="detailCmp"]').setClientLookup();
		}
	}


	buildOppoObj(e){
		if(this.comesfromevent){
			let nextOppo = (e.detail != null) ? e.detail : e 
			let id = (e.detail != null) ? e.detail.id : e.Id;
			let vinculed = (e.detail != null) ? e.detail.isVinculed : e.isVinculed;
			if(Object.keys(this.parseOpposFromScreen).includes(id) && !vinculed){
				delete this.parseOpposFromScreen[id];
			}else{
				this.parseOpposFromScreen[id] = nextOppo;
			}
		} else {
			let nextOppo = (e.detail != null) ? e.detail : e 
			let id = (e.detail != null) ? e.detail.id : e.Id;
			let vinculed = (e.detail != null) ? e.detail.isVinculed : e.isVinculed;
			if(Object.keys(this.oppoObj).includes(id) && !vinculed){
				delete this.oppoObj[id];
			}else{
				this.oppoObj[id] = nextOppo;
			}
		}
	}

	handleMainOpp(e){
		if(this.comesfromevent){
			let itemOppId = e.detail.oppoId;
			let auxList = [];
			if(this.opposlist != null && this.opposlist.length > 0) {
				auxList = auxList.concat(this.opposlist);
			} 
			if (this.oppoNewList != null && this.oppoNewList.length > 0) {
				auxList = auxList.concat(this.oppoNewList);
			}
			if (this.opposscheduledagended != null && this.opposscheduledagended.length > 0) {
				auxList = auxList.concat(this.opposscheduledagended);
			}
			if (auxList != null && auxList.length > 0) {
				auxList.forEach(opp => {
					this.template.querySelector('[data-id="'+opp.Id+'"]').mainVinculed = (opp.Id == itemOppId);
					if(opp.Id == itemOppId && Object.keys(this.parseOpposFromScreen).includes(itemOppId)){
						this.parseOpposFromScreen[itemOppId]['mainVinculed'] = true;
					}
				});
			}
			
		} else{
			let itemOppId = e.detail.oppoId;
			this.currentMainVinculed = itemOppId;
			let auxList;
			if(this.comesfromevent){
				auxList = this.opposscheduledagended;
			}else{
				if(this.oppoList == [] ||this.oppoList == undefined){
					auxList =  this.oppoNewList;
				}else{
					auxList =  this.oppoList.concat(this.oppoNewList);
				}
			}
			auxList.forEach(opp => {
				this.template.querySelector('[data-id="'+opp.Id+'"]').mainVinculed = (opp.Id == itemOppId);
				if(opp.Id == itemOppId && Object.keys(this.oppoObj).includes(itemOppId)){
					this.oppoObj[itemOppId]['mainVinculed'] = true;
				}
			});
		}	
	}

	handleVinculation(e){
		if(this.comesfromevent){
			(e.detail.sum)?this.opposCount++:this.opposCount--;
			var auxList = [];
			if(this.opposlist != null && this.opposlist.length > 0) {
				auxList = auxList.concat(this.opposlist);
			}
			if (this.oppoNewList != null && this.oppoNewList.length > 0) {
				auxList = auxList.concat(this.oppoNewList);
			} 
			if (this.opposscheduledagended != null && this.opposscheduledagended.length > 0) {
				auxList = auxList.concat(this.opposscheduledagended);
			}
			var oppoDetail = this.template.querySelector('[data-id="'+e.detail.oppoId+'"]');
			
			if (e.detail.sum) {
				if (this.opposCount <= 1) {
					oppoDetail.mainVinculed = true;
				}
			} else {
				if (this.opposCount < 1) {
					oppoDetail.mainVinculed = true;
				} else {
					if (oppoDetail.mainVinculed) {
						var cont = true;
						auxList.forEach(opp => {
							var oppoDetailToMain = this.template.querySelector('[data-id="'+opp.Id+'"]');
							if(opp.Id != e.detail.oppoId && cont && oppoDetailToMain.vinculed){
								oppoDetailToMain.mainVinculed = true;
								cont = false;
							}
						})
						oppoDetail.mainVinculed = false;
					}
				}
			}
		} else {
			(e.detail.sum)?this.opposCount++:this.opposCount--;
			let itemOppId = e.detail.oppoId;
			let onlyOneVinculed = (this.opposCount <= 1)
			let auxList;
			if(this.comesfromevent){
				auxList = this.opposscheduledagended;
			}else{
				if(this.oppoList == [] ||this.oppoList == undefined){
					auxList =  this.oppoNewList;
				}else{
					auxList =  this.oppoList.concat(this.oppoNewList);
				}
			}
			this.currentMainVinculed = null;
			let firtstVinculedId = null;
			if(onlyOneVinculed){
				this.template.querySelector('[data-id="'+itemOppId+'"]').mainVinculed = true;
				this.currentMainVinculed = itemOppId;
			}else{
				auxList.forEach(opp => {
					let oppoDetail = this.template.querySelector('[data-id="'+opp.Id+'"]');
					if(oppoDetail.vinculed && firtstVinculedId == null){
						firtstVinculedId = opp.Id;
					}
					if(opp.Id == itemOppId ){
						oppoDetail.mainVinculed = onlyOneVinculed && e.detail.sum;
					}else if(opp.Id != itemOppId && onlyOneVinculed ){
						oppoDetail.mainVinculed = oppoDetail.vinculed;
					}
					if(oppoDetail.mainVinculed){
						this.currentMainVinculed = opp.Id;
					}				
				})
			}
			if(this.currentMainVinculed == null && firtstVinculedId != null){
				this.template.querySelector('[data-id="'+firtstVinculedId+'"]').mainVinculed = true;
			}
		}		
	}


    handleSearchProduct(e){
        searchProduct({searchTerm:e.detail.searchTerm,selectedIds:this.selectedProds})
        .then((results) => {
            this.template.querySelector('[data-id="newproductlookup"]').setSearchResults(results);
        })
        .catch((error) => {
            this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    evaluateProductToAdd(){
		this.productToAdd = this.template.querySelector("[data-id='newproductlookup']").getSelection().length == 0;
	}
    

    handleAddOppo(){
			this.showButtonDelete = true;
			let cmp = this.template.querySelector("[data-id='newproductlookup']");
			let selection = cmp.getSelection()[0];
			if(selection != null){
				this.selectedProds.push(selection.id);
				this.oppoNewList.push(
					{
						Id:IDPROVISIONAL+this.idProvisional++,
						Name:selection.title,
						Stage:'En gestión/insistir',
						ProductoMain:selection.id,  
						Fecha:(this.newEvent['activityDate'] != undefined ) ? this.newEvent['activityDate'] : new Date().toJSON().slice(0,10),
						NotInserted:true,
						unFoldCmp:true,
						IsNewProduct: selection.prodNewAction
						,owneridopp : USER_ID  
					}
				);
				cmp.handleClearSelection();
				this.evaluateProductToAdd();
			}
    }

	eventCreateCalendar(e) {
		if (e.detail.validation.toString() == 'false' && (this.newEvent['subject'] == null || this.newEvent['subject'] == '')) {
			this.showToast('Error','Es necesario rellenar el asunto antes de seleccionar una fecha en el calendario','Error');
		}else {
			let hourRegex = /T(\d{2}:\d{2})/;
			var dateIni= new Date(e.detail.initTiment.toString());
			this.timeInicio = e.detail.initTiment.toString().match(hourRegex)[1];
			this.timeFin = e.detail.endTime.toString().match(hourRegex)[1];
			this.activityDateToSend = dateIni.toJSON().slice(0,10);
			this.timeInfo = {
				date : this.formatDate(this.activityDateToSend),
				hourini : this.timeInicio,
				hourfin : this.timeFin,
				duration : this.mapDurationText[this.durationToSend]
			};
		}
	}

	formatDate(date) {
		var dateToFormat = new Date(date);
		return this.setHours(dateToFormat.getDate())+'/'+this.setMonths(dateToFormat.getMonth())+'/'+dateToFormat.getFullYear();
	}

	setMonths(month) {
		month = month + 1 ;
		var listNums = [0,1,2,3,4,5,6,7,8,9];
		if(listNums.includes(month)) {
			month = '0'+month;
		}
		return month;
	}
	validateDates(){
		let currentOppoObject = (this.comesfromevent) ? this.parseOpposFromScreen  : this.oppoObj;
		var nowReference = new Date().toJSON().slice(0, 10);
		let response = true;
		for(let oppoId in currentOppoObject){
			let date = currentOppoObject[oppoId]['proximaGestion'];
			let stage = currentOppoObject[oppoId]['newPath'];
			let resolucion = currentOppoObject[oppoId]['resolucion'];
			let comentario = currentOppoObject[oppoId]['comentario'];
			let agendado = currentOppoObject[oppoId]['agendado'];
			let validable = currentOppoObject[oppoId]['validable'];
			let noofrecerhasta = currentOppoObject[oppoId]['noofrecerhasta'];

			if (validable) {
				if((stage == 'En gestión/insistir') && ((date != null && date != undefined && date < nowReference) || (date == null && date == undefined)) && !agendado){
					return  currentOppoObject[oppoId]['id'];
				}
				if((stage == 'No interesado' || stage == 'Producto Rechazado') && ((resolucion == 'O') && (comentario == null | comentario == '') || resolucion == 'No Apto' && (noofrecerhasta == null || noofrecerhasta == undefined))){
					return  currentOppoObject[oppoId]['id'];
				}
			}
		}
		return response;
	}

	highlightOppo(id){
		let currentOppoObject = (this.comesfromevent) ? this.parseOpposFromScreen  : this.oppoObj;
		let b =  this.template.querySelector('[data-id="'+id+'"]');
		let closedStatus = ['No interesado','Producto Rechazado'];
			if(currentOppoObject[id].newPath == 'En gestión/insistir'){
				this.showToast('Faltan datos','Indica una fecha de próxima gestión que sea mayor o igual a hoy.','error','pester');
			}else if(currentOppoObject[id].newPath == 'No interesado' && currentOppoObject[id].resolucion == null){
				this.showToast('Faltan datos','Debes de rellenar el campo de resolución.','error','pester');
			}else if(closedStatus.includes(currentOppoObject[id].newPath) &&  currentOppoObject[id].resolucion == 'O' &&  (currentOppoObject[id].comentario == null || currentOppoObject[id].comentario == '')){
				this.showToast('Faltan datos', 'Debes de rellenar el campo de comentario.', 'error', 'pester');
			}else if(closedStatus.includes(currentOppoObject[id].newPath) &&  currentOppoObject[id].resolucion == 'No Apto' && currentOppoObject[id].noofrecerhasta == null){
				this.showToast('Faltan datos', 'Por favor, rellena los campos obligatorios.', 'error', 'pester');
			}
		b.scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});
		b.highlightBadInput();
	}
	 
	async handleCreateEvent(){     
		let currentOppoObject = (this.comesfromevent) ? this.parseOpposFromScreen  : this.oppoObj;
		let comentarios = [];
		let error = null;
		
		for(let oppoId in currentOppoObject){
			let comentario = currentOppoObject[oppoId]['comentario'];
			comentarios.push(comentario);
		}

		let secondOpportunities = (this.comesfromevent) ?
		
		Object.fromEntries(Object.entries(this.parseOpposFromScreen).filter(
			([key, value]) => !Object.keys(this.objectToController.vinculatedOpportunities).includes(key) && !key.includes(IDPROVISIONAL)

		) )
		: currentOppoObject;
		
		
		let ownerMismatch = false;
		if(secondOpportunities != null && Object.keys(secondOpportunities).length >0){
			
			for(let key in secondOpportunities){
				if( secondOpportunities[key]['owneridopp'] == this.currentMultigest){
					if(this.comesfromevent){
						this.parseOpposFromScreen[key]['owneridopp'] = this.userLogged.Id;
					}else{
						this.oppoObj[key]['owneridopp'] = this.userLogged.Id;
					}
					continue;
				}
				
				if(secondOpportunities[key]['owneridopp'] != this.userLogged.Id){
					ownerMismatch = true;
					break;
					
				}
				this.showModal=false;
			}
			

			if (ownerMismatch ) {      
				this.showModal = true;
				const result = await this.waitForUserDecision();
				if (result) {
					for (let key in secondOpportunities) {
						if (secondOpportunities['owneridopp'] != this.userLogged.Id   && secondOpportunities['owneridopp'] != this.currentMultigest) {   
							if(this.comesfromevent){
								this.parseOpposFromScreen[key]['owneridopp'] = this.userLogged.Id;
							}else{
								this.oppoObj[key]['owneridopp'] = this.userLogged.Id;
							}
						}
					}
					
					
				}
				this.showModal = false;
			}
		}

		validatePFNewOppAndForbiddenWords({
			prodId : null,
			tskId : this.recordId,
			comments : comentarios,
			names : null
		}).then(result => {
			if((error == null && result == 'OK') || (result.includes('Warning'))){
				if (result.includes('Warning')) {
					this.showToast('Warning', result, 'warning', 'sticky');
				}
				var next = false;
				if(this.noComercial) {
					next = this.template.querySelector('[data-id="detailCmp"]').validateRequiredInputs();
					if(next) {
						next = this.validateRequiredInputs();
					}
				}
				let validateResponse = this.validateDates();

				if(validateResponse == true){
					if (next || !this.noComercial) {
					let inittime = this.dateIniFinal;
					let finaltime = this.dateFinFinal;
					let calendar = this.template.querySelector('[data-id="customcalendar"]');
					if(calendar != null) {
						inittime = calendar.initTime;
						finaltime = calendar.endTime;
					} 
					
					if(inittime == undefined || finaltime == undefined){
						this.showToast('Faltan datos',
									'Marca una franja en el calendario para continuar',
									'Error');
					}else if(new Date(inittime) < new Date() ){
						this.showToast('Fechas incorrectas',
						'Por favor, introduce una fecha futura',
						'Error');
					}else{
						var eventToInsert = {
							sobjectType: 'Event',
							WhatId:this.newEvent['client'],
							WhoId:this.newEvent['personaContacto'],
							AV_Center__c:this.newEvent['center'],
							OwnerId:this.newEvent['owner'],
							Subject:this.newEvent['subject'],
							Description:this.newEvent['comentary'],
							AV_Tipo__c:this.newEvent['type'],
							StartDateTime:inittime,
							EndDateTime:finaltime,
							ActivityDate:this.activityDateToSend,
							AV_BranchPhysicalMeet__c:this.newEvent['otherOfficeNumber'],
							Location: this.newEvent['ubication']
						};
						if(this.eventId != null && this.eventId != undefined){

							eventToInsert.Id =  this.eventId;
						}
						if(this.newEvent['nocomercial']){
								eventToInsert.AV_Purpose__c = '002';
							}else{
								
								if (currentOppoObject && Object.keys(currentOppoObject).length > 0) {
									eventToInsert.AV_Purpose__c = '001';
								}else {  
									eventToInsert.AV_Purpose__c = '002';
								}
							}
							
							
							if(eventToInsert.AV_Tipo__c == 'CTO'){
								eventToInsert.AV_BranchPhysicalMeet__c = eventToInsert.AV_Center__c;
							}	
							if(ISBPR){
								eventToInsert.AV_MemorableInterview__c = this.newEvent['memorableInterview'];
							}
							if(!this.comesfromevent){
								this.startReportLogic(eventToInsert);
							}else{
								this.reportAndNewEventLogic(eventToInsert);
							}
						}
					}
				}else{
					this.handleError();
					this.switchModal = true;  
					this.highlightOppo(validateResponse)
					this.showSpinner = false;
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

	reportAndNewEventLogic(eventToInsert){
		this.focusRecord();
		this.showSpinner = true;
		let nonCallReportSign = {evt:eventToInsert, objectToReport: this.objectToController.objectToReport, taskToClose: this.objectToController.TaskToClose, originReport: this.objectToController.originReport};
		let callReportSign = {evt:eventToInsert, objectToReport: this.objectToController.objectToReport, callObj: this.objectToController.objectCall, dateToQuery: this.objectToController.dateToQuery,originReport: this.objectToController.originReport}
		createEventFromReport(this.clientfromcall != null ? callReportSign : nonCallReportSign)
		.then(result => {

			if(result.errorResult == undefined){
				this.createdEventId = result.newEventIdWithHeader.split(SEPARATOR)[0];
				this.newEventHeaderId = result.newEventIdWithHeader.split(SEPARATOR)[1];
				this.objFirstOrignRp = this.objectToController.originReport
				this.objScondOrignRp = this.objectToController.objectToReport.sobjectType
				if(this.objectToController.originReport == 'Event'){
					this.backEventReported = result.backReportEvent;
					this.reportedActivityHeaderId = this.objectToController.HeaderId;
					this.evtIdInsert = this.reportedActivityHeaderId; 
				}else if(this.objectToController.originReport == 'Task'){
					if(this.objectToController.objectToReport.sobjectType == 'Event'){
						this.newRecordFromTaskReport = result.insertedId;
						this.evtIdInsert = result.insertedHeaderId; 
						this.newRecordFromReportHeaderId = result.insertedHeaderId;
						this.reportedActivityHeaderId = this.objectToController.HeaderId;
					}else{
						this.reportedActivityHeaderId = this.objectToController.HeaderId;
						this.evtIdInsert = this.reportedActivityHeaderId; 
					}
				}else if(this.objectToController.originReport == 'Opportunity'){
					this.newRecordFromTaskReport = result.insertedId;
					this.newRecordFromReportHeaderId = result.insertedHeaderId;
					this.evtIdInsert = this.newRecordFromReportHeaderId; 
				}else if(this.objectToController.originReport == 'CC_Llamada__c'){
					this.isCallRecord = true;
					if(result.operation == 'update'){
						this.backEventReported = result.evtBack;
						this.newRecordFromReportHeaderId = result.updatedEventHeaderId;
					}else if(result.operation == 'insert'){
						this.createdAttendesOrEventId.push(result.evtBackId);
						this.newRecordFromReportHeaderId = result.headerNewEvt;
					}
					this.operatedEventInCallReport = result.operatedEventId;
					this.callReportBack = result.callBackRep;
					this.reportedActivityHeaderId = this.newRecordFromReportHeaderId;
					this.evtIdInsert = this.reportedActivityHeaderId; 

				}
				this.createdAttendesOrEventId.push(this.createdEventId);
				if(this.newEvent['attendes'].length > 0){
					this.createAttendes();
				}else if(this.objectToController?.vinculatedTasks?.length > 0){
					this.closeClientTasksFromReport();
				}else if(this.objectToController?.vinculatedOpportunities != undefined){
					this.updateOrCreateOpportunitiesFromReport();
				}
			}else{
				this.showSpinner = false;
				this.showToast('Error creando el evento',result.errorResult,'error');
				this.handleError();
			}
		}).catch(error => {
			this.showToast('Error creando el evento',error,'error');
			console.error(error);
			this.handleError();
			this.showSpinner = false;
		});
	}
	
	closeClientTasksFromReport(){
		let tsksToUpdate = [];
		this.objectToController?.vinculatedTasks.forEach(task => {
			tsksToUpdate.push({
				sobjectType : 'Task',
				Id : task['id'],
				Status : task['status'],
				Description : task['comment']
				,OwnerId : task['owner']
			});
		});
		closeClientTasks({tasksToClose:tsksToUpdate})
		.then(result => {
			if(result.errorList == null){
				this.updatedClientTasksBack = result.updatedClientTasksBack;
				this.insertedMMHofClosedTasks = result.insertedMMHofClosedTasks;
				if(Object.keys(this.objectToController?.vinculatedOpportunities).length > 0){
					this.updateOrCreateOpportunitiesFromReport();
				}else{
					this.syncGcf();
				}
			}else{
				this.deleteEventRegistersAndBackReportedTasks();
			}
		}).catch (error => {
			console.error(error);
			this.deleteEventRegistersAndBackReportedTasks();
		});
	}

	startReportLogic(eventToInsert){
		this.focusRecord();
		this.showSpinner = true;
		createEvent({evt:eventToInsert})
		.then(result =>{
			if(!result.includes('Fail-')){
				this.createdEventId = result.split(SEPARATOR)[0];
				this.newEventHeaderId = result.split(SEPARATOR)[1];
				this.createdAttendesOrEventId.push(this.createdEventId);
				if(this.newEvent['attendes'].length > 0){
					this.createAttendes();
				}else{
					this.updateOrCreateOpportunities(this.createdEventId);
				}
			}else{	
				this.showSpinner = false;
				this.showToast('Error creando el evento',result,'error');
				this.handleError();
			}
		}).catch(error => {
			this.showToast('Error creando el evento',result,'error');
			this.handleError();
			console.error(error);
			this.showSpinner = false;
		});
	}

	setCommentsHistoryForReport(){
		let commentsForSecondScreen = [];
		let commentsForFirstScreen = [];
	
			this.caosFirstScreen.forEach( cao => {
				let oppId = (Object.keys(this.mapIdBBDIDToProv).includes(cao.AV_Opportunity__c)) ? this.mapIdBBDIDToProv[cao.AV_Opportunity__c] : cao.AV_Opportunity__c;
				commentsForSecondScreen.push(
					{
					sobjectType:'AV_CommentsHistory__c',
					AV_Opportunity__c:cao.AV_Opportunity__c,
					AV_NewComment__c:this.editedOpportunitiesFromReport[oppId]?.['comentario'],
					AV_OldComment__c: this.objectToController.oldOppos[oppId]?.AV_Comentarios__c,
					AV_OpportunityStatus__c:this.editedOpportunitiesFromReport[oppId]?.['newPath'],
					AV_Event__c:this.createdEventId,
					AV_AssignedEmployee:null
					
				});
			});
			this.caosSecondScreen.forEach(cao => {
				let oppId = (Object.keys(this.mapIdBBDIDToProv).includes(cao.AV_Opportunity__c)) ? this.mapIdBBDIDToProv[cao.AV_Opportunity__c] : cao.AV_Opportunity__c;
				let taskReportCmmh = null;
			let nextCmmh = {
				sobjectType:'AV_CommentsHistory__c',
				AV_Opportunity__c:cao.AV_Opportunity__c,
				AV_NewComment__c:this.objectToController.vinculatedOpportunities[oppId]?.['comentario'],
				AV_OldComment__c: this.objectToController.oldOppos[oppId]?.AV_Comentarios__c,
				AV_OpportunityStatus__c:this.editedOpportunitiesFromReport[oppId]?.['newPath'],
				AV_Event__c:null,
				AV_Task__c:null,
				AV_AssignedEmployee:null
			}

			if(this.objectToController.originReport == 'Opportunity'){
				if(this.objectToController.objectToReport.sobjectType == 'Task'){
					nextCmmh.AV_Task__c = this.newRecordFromTaskReport;
				}else if(this.objectToController.objectToReport.sobjectType == 'Event'){
					nextCmmh.AV_Event__c = this.newRecordFromTaskReport;
					
				}
			}else if(this.objectToController.originReport == 'Task'){
					taskReportCmmh = {
						sobjectType:'AV_CommentsHistory__c',
						AV_Opportunity__c:cao.AV_Opportunity__c,
						AV_NewComment__c:this.editedOpportunitiesFromReport[oppId]?.['comentario'],
						AV_OldComment__c: this.objectToController.oldOppos[oppId]?.AV_Comentarios__c,
						AV_OpportunityStatus__c:this.editedOpportunitiesFromReport[oppId]?.['newPath'],
						AV_Task__c:this.objectToController.TaskToClose.AV_ActivityId__c,
						AV_AssignedEmployee:null
				}
				if(this.objectToController.objectToReport.sobjectType == 'Task'){
					nextCmmh.AV_Task__c = this.newRecordFromTaskReport;
				}else if(this.objectToController.objectToReport == 'Event'){
					nextCmmh.AV_Event__c = this.newRecordFromTaskReport;
					
				}

			}else if(this.objectToController.originReport == 'Event'){
				nextCmmh.AV_Event__c = this.objectToController.objectToReport.Id;
			}else if(this.objectToController.originReport == 'CC_Llamada__c'){
				nextCmmh.AV_Event__c = this.operatedEventInCallReport;
			}

			commentsForFirstScreen.push(nextCmmh);
			if(taskReportCmmh != null){
				commentsForFirstScreen.push(taskReportCmmh);
			}
		})
		return commentsForFirstScreen.concat(commentsForSecondScreen);
	
	}

	vinculateOpportunitiesFromReport(){
		let listOpposReport = {};
		var listCaosInsert = [];
		var listCaosForNewRecord = [];
		this.caosFirstScreen = [];
		this.caosSecondScreen = [];
	
		for(let id in this.objectToController.vinculatedOpportunities){
			let currentOppo = this.objectToController.vinculatedOpportunities[id];
			let oppoId = (currentOppo['id'].includes(IDPROVISIONAL)) ? this.mapProvIdToBBDDId[id] : currentOppo['id'];
			let mainVinculed = currentOppo['mainVinculed'];
			listOpposReport[oppoId] = mainVinculed;
			if((this.objectToController.originReport == 'Opportunity') || (this.objectToController.originReport == 'Task' && this.objectToController.objectToReport.sobjectType == 'Event') || this.objectToController.originReport == 'CC_Llamada__c'){
				listCaosForNewRecord.push({
					sobjectType:'AV_CustomActivityOpportunity__c',
					AV_Opportunity__c: oppoId,
					AV_IsMain__c : mainVinculed,
					AV_Task__c : this.newRecordFromReportHeaderId,
					AV_OrigenApp__c : 'AV_SalesforceClientReport'
				});	
			}
		}	

		let allIds = this.opposscheduledagended.concat(this.opposlist).concat(this.oppoNewList).map(opp => opp.Id);
		let vinculedSecondScreen = [];
		let currentScreeMainState = {};
		allIds.forEach(id => {
			let detailOpp = this.template.querySelector('[data-id="'+id+'"]');
			if( detailOpp != null){
				if(detailOpp.vinculed){
					let nextId = (id.includes(IDPROVISIONAL)) ? this.mapProvIdToBBDDId[id] : id;
					vinculedSecondScreen.push(nextId);
					currentScreeMainState[nextId] = detailOpp.mainVinculed;
				}
			}
		})
		for(let id in this.editedOpportunitiesFromReport){
			let currentOppo = this.editedOpportunitiesFromReport[id];
			let oppoId = currentOppo['id'];
			let mainVinculed = currentOppo['mainVinculed'];
			if(vinculedSecondScreen.includes(oppoId)){
				listCaosInsert.push({
					sobjectType:'AV_CustomActivityOpportunity__c',
					AV_Opportunity__c: oppoId,
					AV_IsMain__c : currentScreeMainState[oppoId],
					AV_Task__c : this.newEventHeaderId,
					AV_OrigenApp__c : 'AV_SalesforceClientReport'
				});
				
			}
		}	
		this.caosFirstScreen = listCaosInsert;
		this.caosSecondScreen = listCaosForNewRecord;
		
		let commentsHistoryFromReport = this.setCommentsHistoryForReport();
		vinculateFromReport({opposAndMain:listOpposReport, recordHeaderId:this.reportedActivityHeaderId, caosInsertedEvent : listCaosInsert, caosTaskRecordReport : listCaosForNewRecord,commentsHistoryFromReport:commentsHistoryFromReport,isCallReport:this.isCallRecord})
		.then(result => {
			if(result[0] == 'OK'){
				if(Object.keys(this.editedOpportunitiesFromReport).length > 0){
					this.sendToGcfOpportunityFromReport(this.editedOpportunitiesFromReport);

				}else{
					this.syncGcf();
				}
			}else{
				this.backFromVinculateReport();
				console.log(result); //para ver el error
			}
		}).catch(error => {
			this.backFromVinculateReport();
			console.error(JSON.stringify(error));
		});
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

	processCheckOnOffJs(reportObject){
		processCheckOnOffCreate({checkOnOff:reportObject.checkOnOffOpposId,accountId : this.accountId})
		.then(result => {
			if(result.errorList == null){
				if(result.bckCOF.createdIdsToDelete.length > 0){
					this.taskInsertedCheckOnOff = result.bckCOF.createdIdsToDelete;
					this.caosInsertedCheckOnOff = result.bckCOF.createdCaosToDelete;
				}
				processCheckOnOffUpdate({checkOnOff:reportObject.checkOnOffOpposId,accountId : this.accountId})
				.then(result => {
					if(result.errorList == null){
						this.editedCheckTaskOnOffToUpdateBack = result.bckCOF.updatedTasksToRestore;
						processCheckOnOffDelete({checkOnOff:reportObject.checkOnOffOpposId,accountId : this.accountId})
						.then(result => {
							if(result.errorList == null){
								this.deletedCheckOnOffBack = result.bckCOF;
								this.vinculateOpportunitiesFromReport();
							}else{
								result.errorList.forEach(err => {
									console.log(err); // para ver el error que devuelve
								})
								this.backReportFromCheckOnOffDelete();
							}
						}).catch(error => {
							console.error(error); 
							this.backReportFromCheckOnOffDelete();
						});	
					}else{
						result.errorList.forEach(err => {
							console.log(err); // para ver el error que devuelve
						})
						this.backReportFromCheckOnOffEdit();
					}
				}).catch(error => {
					console.error(error);
					this.backReportFromCheckOnOffEdit();
				});
			}else{
				result.errorList.forEach(err => {
					console.log(err); // para ver el error que devuelve
				})
				this.backReportFromCheckOnOffCreate();
			}
		}).catch(error => {
			console.error(error);
			this.backReportFromCheckOnOffCreate();
		});
	}

	
	backReportFromCheckOnOffCreate(){
		let oldOppos = [];
		for(let oppo in this.objectToController.oldOppos){
			oldOppos.push(this.objectToController.oldOppos[oppo]);
		}
		Object.keys(this.editedOpportunitiesFromReport).forEach((oppoId) => {
			if(oppoId.includes(IDPROVISIONAL)){
				this.createdOpposIds.push(this.editedOpportunitiesFromReport[oppoId]['id']);
			}
		});
		backCreatedOrUpdtOppos({createdIds:this.createdOpposIds, tskCheckOnOffToDel : this.taskInsertedCheckOnOff, caoCheckOnOffToDel : this.caosInsertedCheckOnOff, oldOppos:oldOppos})
		.then(() =>{
			this.backFromOpportunitysProcess();
		}).catch(error => {
			console.error(error);
			this.backFromOpportunitysProcess();
		});
	}

	backReportFromCheckOnOffEdit(){
		this.backReportFromCheckOnOffCreate();
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

	updateOrCreateOpportunitiesFromReport(){
		for(let oppo in this.parseOpposFromScreen){
			this.parseOpposFromScreen[oppo]['proximaGestion'] = this.activityDateToSend;
		}
		let opposToEdit = {};
		this.objectToController.vinculatedOpportunities
		let allOppos = new Set([...Object.keys(this.parseOpposFromScreen),...Object.keys(this.objectToController.vinculatedOpportunities)]);
		for(let oppo of allOppos) {
			if(Object.keys(this.parseOpposFromScreen).includes(oppo)){
				opposToEdit[oppo] = this.parseOpposFromScreen[oppo];
				continue;
			}
			if(Object.keys(this.objectToController.vinculatedOpportunities).includes(oppo)){
				opposToEdit[oppo] = this.objectToController.vinculatedOpportunities[oppo];
			}
		}
		createOrUpdateOpportunitiesFromReport({opposToInsertOrUpdate: opposToEdit, mapOldOpp:this.objectToController.oldOppos,accountId:this.accountId,eventId:this.evtIdInsert,objectFirstReport:this.objFirstOrignRp,objectSecondaryReport:this.objScondOrignRp})
		.then(result => {
			if(result.errorList == null ){ 
				this.editedOpportunitiesFromReport = result.editedOpportunities;
				for(let id in this.editedOpportunitiesFromReport){
					if(id.includes(IDPROVISIONAL)){
						this.mapProvIdToBBDDId[id] = this.editedOpportunitiesFromReport[id]['id'];
						this.mapIdBBDIDToProv[this.editedOpportunitiesFromReport[id]['id']] = id;
					}
				}
				this.processCheckOnOffJs(result);
			}else{
				this.backFromOpportunitysProcess();
				result.errorList.forEach(err => {
					console.log(err); // para ver el error que devuelve
				})
			}
		}).catch(error => {
			console.error(error);
			this.backFromOpportunitysProcess();
		});
	}

	backFromOpportunitysProcess(){
		if(this.updatedClientTasksBack != null){
			let listTasksToRestore = [];
			this.updatedClientTasksBack.forEach(t => {
				let task = JSON.parse(t);
				listTasksToRestore.push({
					sobjectType : 'Task',
					Id: task.Id,
					AV_Tipo__c : task.AV_Tipo__c,
					Description : task.Description,
					Status : task.Status,
					ActivityDate : task.ActivityDate,
					AV_OrigenApp__c : 'AV_BackReport',
					AV_ContactGenerateAppointment__c : task.AV_ContactGenerateAppointment__c
				});
			});
			backClosedTaskReport({tskToBack: listTasksToRestore ,mmhToDel:this.insertedMMHofClosedTasks})
			.then(() => {
				this.deleteEventRegistersAndBackReportedTasks();
			}).catch(error => {
				console.log(error);
			});
		}else{
			this.deleteEventRegistersAndBackReportedTasks();
		}
	}

	updateOrCreateOpportunities(idCreateEvent){	
		for(let oppo in this.oppoObj){
			this.oppoObj[oppo]['proximaGestion'] = this.activityDateToSend;
		}
		createOrUpdateOpportunities({opposToInsertOrUpdate: this.oppoObj, accountId: this.accountId, eventIdCreated: idCreateEvent})
		.then(result => {
			if(result.errorList == null){
				this.oppoObj = result.editedOpportunities;
				this.checkOnOffTasksBackUp = result.taskToRestoreBack;
				this.caosCheckOnOffBackUp = result.caoToRestoreBack;
				this.taskAndOpposRel = result.taskOpposRelation;
				for(let oppo in this.oppoObj){
					if(oppo.includes(IDPROVISIONAL)){
						this.createdOpposIds.push(this.oppoObj[oppo]['id']);
					}
				}
				this.vinculateOpportunities();
			}else{
				result.errorList.forEach(err => {
					console.log(err); // para ver el error que devuelve
				});
				this.deleteEventRegistersAndBackReportedTasks();
			}
		}).catch(error => {
			console.error(error);
			this.deleteEventRegistersAndBackReportedTasks();
		});	
		
	}

	deleteEventRegistersAndBackReportedTasks(){
		deleteCreatedEventOrAttendesAndReportedTasks({recordsToDelete:this.createdAttendesOrEventId, jsonEventToBackReport:this.backEventReported, newRecordFromTaskToDel:this.newRecordFromTaskReport, jsonTaskToReOpen:this.closedTaskToBack, mmhToDel: this.closedManagementHistoryToBack,jsonCallBack:this.callReportBack})
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
			console.error(error);
			this.showToast('Error actualizando las oportunidades','El evento ha quedado registrado mal. Por favor, eliminelo manualmente.','Error');
		});
		this.handleError();
	}

	redirectToNewEvent(){
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Event',
				recordId: this.createdEventId,
				actionName:'view'
			}
		})
	}

	handleCancel(){
		let goRecordOrHome = (this.clientNumper == null);
		if(this.comesfromevent){

			this.dispatchEvent(new CustomEvent('cancelback'));
		}else{
			this.dispatchEvent(new CustomEvent('closetab',{detail:{goRecordOrHome}}));

		}
	}

	handleFinish(){
		let goRecordOrHome = (this.clientNumper == null);
		this.dispatchEvent(new CustomEvent('closetab',{detail:{goRecordOrHome}}));
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
	handleCloseFinish(){
		this.dispatchEvent( new CustomEvent( 'closetabfinish',{detail:{neweventid:this.createdEventId}}));
	}

	handleError(){
		this.dispatchEvent(new CustomEvent('focustab'));
	}

	focusRecord(){
		this.dispatchEvent(new CustomEvent('focusrecordtab'));
	}
	
	vinculateOpportunities(){
		let preBuildCaoList = [];
		let updatedOrCreatedOppos = [];
		for(let id in this.oppoObj){
			let currentOppo = this.oppoObj[id]
			updatedOrCreatedOppos.push(currentOppo['id'])
			preBuildCaoList.push({
				sobjectType:'AV_CustomActivityOpportunity__c',
				AV_Opportunity__c: currentOppo['id'],
				AV_Task__c : this.newEventHeaderId,
				AV_IsMain__c: this.template.querySelector('[data-id="'+id+'"]').mainVinculed,
				AV_OrigenApp__c : 'AV_SalesforceClientReport'
			});
		}
		vinculateOpportunities({caosToInsert:preBuildCaoList, evtId:this.createdEventId})
		.then(result => {
			if(result == 'OK'){
				if(updatedOrCreatedOppos.length > 0){
					this.sendToGcfOpportunity(updatedOrCreatedOppos);
				}else{
					this.syncGcf();
				}
			}else{
				this.backReportOpportunities();
			}
				this.showSpinner = false;
		}).catch(error => {
			console.error(error);
			this.backReportOpportunities();
		});
	}

	finishReport(){
		this.handleFinish();
		this.showSpinner = false;
	}

	sendToGcfOpportunityFromReport(listIdsOpps) {
		let listStringIdsOpps= [];
		Object.keys(listIdsOpps).forEach((oppoId) => {
			listStringIdsOpps.push(listIdsOpps[oppoId]['id']);
		});
		sendToGfc({listIdsOppUpdateCreated:listStringIdsOpps,canal:this.objectToController.objectToReport.AV_Tipo__c})
		.then(result =>{
			if(result != 'OK'){
				console.log('Error sendOppToGCF '+result); // para ver el error que devuelve
			}
			this.syncGcf();
		}).catch(error => {
			this.syncGcf();
			this.showSpinner = false;
			console.log(error);
		});
	}

	sendToGcfOpportunity(listIdsOpps) {
		sendToGfc({listIdsOppUpdateCreated:listIdsOpps,canal:this.newEvent.type})
		.then(result =>{
			if(result != 'OK'){
				console.log('Error sendOppToGCF '+result); // para ver el error que devuelve
			}
			this.syncGcf();
		}).catch(error => {
			this.syncGcf();
			this.showSpinner = false;
			console.log(error);
		});
	}
	
	backReportOpportunities(){
		let oldOpposToReportBack = [];
		for(let oppoId in this.oppoObj){
			if(!oppoId.includes(IDPROVISIONAL)){
				oldOpposToReportBack.push(this.template.querySelector('[data-id="'+oppoId+'"]').initialState);
			}
		}
		backCreatedOrUpdtOppos({createdIds:this.createdOpposIds, oldOppos:oldOpposToReportBack, tskToRestore: this.checkOnOffTasksBackUp, caoToRestore: this.caosCheckOnOffBackUp, entityRelations: this.taskAndOpposRel})
		.then((result) =>{
			this.deleteEventRegistersAndBackReportedTasks();
			if(result != 'OK'){
				this.showToast('Error vinculando las oportunidades con el evento','Cuidado, no se han podido deshacer los cambios en las oportunidades','warning');
			}
			this.showToast('Error en el reporte','No se ha editado ni creado ninguna oportunidad,ni se ha creado ningún evento','error');
			this.showSpinner = false;
			this.handleError();
		}).catch(error =>{
			console.error(error);
			this.showToast('Error vinculando las oportunidades con el evento','Cuidado, no se han podido deshacer los cambios en las oportunidades','warning');
		});
		this.handleError();
		this.showSpinner = false;
	}

	createAttendes(){
		createAttendesRelation({eventId:this.createdEventId,attendes:this.newEvent['attendes']})
		.then(result =>{
			if(result[0] != 'Fail'){
				result.forEach(attId => {
					this.createdAttendesOrEventId.push(attId);
				});
				if(this.objectToController?.vinculatedTasks?.length > 0){
					this.closeClientTasksFromReport();
				}else if(this.objectToController?.vinculatedOpportunities != undefined){
					this.updateOrCreateOpportunitiesFromReport();
				}else{
					this.syncGcf();
				}
			}else{
				this.deleteEventRegistersAndBackReportedTasks();
				this.showSpinner = false;
			}
		}).catch(error => {
			console.error(error);
			this.deleteEventRegistersAndBackReportedTasks();
			this.showSpinner = false;
		});
	}

    handleSelectionProduct(){
        this.evaluateProductToAdd();    
    }

	showToast(title, message, variant) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: 'pester'
		});
		this.dispatchEvent(event);
	} 

	handleOppoDelete(event) {   
		const oppoIdToDelete = event.detail;
		const deletedOppo = this.oppoNewList.find(oppo => oppo.Id === oppoIdToDelete);
		if (deletedOppo) {
			this.selectedProds = this.selectedProds.filter(id => id !== deletedOppo.ProductoMain);
		}
		this.oppoNewList = this.oppoNewList.filter(oppo => oppo.Id !== oppoIdToDelete);
		this.handleVinculation({ detail: { sum: false, oppoId: oppoIdToDelete } });
		if (this.oppoObj[oppoIdToDelete]) {
			delete this.oppoObj[oppoIdToDelete];
		}
	}

	syncGcf(){
		syncWithGcf({idEvent:this.createdEventId})
		.then(result =>{
			if (result != 'OK') {
				console.log('Not sync event with GCF'); // para ver el error que devuelve
			}
			this.finishReport();
		}).catch(error => {
			this.finishReport();
			console.error(error);
			this.showSpinner = false;
		});
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