import { LightningElement,wire,track } from 'lwc';
import { CurrentPageReference  } 	   from 'lightning/navigation';
import getRelatedOppos 				   from '@salesforce/apex/AV_NewEvent_Controller.retrieveAccountOpportunities';
import getComboboxValues 			   from '@salesforce/apex/AV_NewEvent_Controller.getPicklistValues';
import searchProduct 				   from '@salesforce/apex/AV_NewEvent_Controller.searchProduct';
import createEvent                     from '@salesforce/apex/AV_NewEvent_Controller.createEvent';
import createAttendesRelation          from '@salesforce/apex/AV_NewEvent_Controller.createEventRelation';
import createOrUpdateOpportunities     from '@salesforce/apex/AV_NewEvent_Controller.createOpportunities';
import deleteCreatedEventOrAttendes    from '@salesforce/apex/AV_NewEvent_Controller.backupEventsAndAttendes';
import vinculateOpportunities     	   from '@salesforce/apex/AV_NewEvent_Controller.vinculateOpposToTheNewEvent';
import backCreatedOrUpdtOppos     	   from '@salesforce/apex/AV_NewEvent_Controller.backReportOppos';
import sendToGfc			     	   from '@salesforce/apex/AV_NewEvent_Controller.sendOppToGCF';
import {ShowToastEvent}				   from 'lightning/platformShowToastEvent';

import {getRecord}                      from 'lightning/uiRecordApi';
import {NavigationMixin}               from 'lightning/navigation';

import ISBPR 						   from '@salesforce/customPermission/AV_PrivateBanking';

import USER_ID 						   from '@salesforce/user/Id';
import FUNCION 						   from '@salesforce/schema/User.AV_Funcion__c';



const FIELDS_TO_RETRIEVE = ['AV_Potencial__c'];
const GESTOR = 'Gestor';
const IDPROVISIONAL = 'idProvisional';

export default class Av_newEvent extends NavigationMixin(LightningElement) {

    recordId;
    clientinfo;
    newEvent;

    oppoObj = {};
    opposCount = 0;
    selectedProds = [];
    @track oppoList;
    @track oppoNewList = [];
    potentialList;
	showSpinner = true;
	showOpposList = false;

	//Variables para el calendario
	durationToCalendar;
	activityDateToCalendar;
	employeeToCalendar;
	subjectToCalendar;
	overlapToCalendar;
	currentMainVinculed;

	showCalendar = false;
	currentUserFunction;
    productToAdd = true;
    idProvisional = 0;
	//rollback vars
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
	disableButtonCancel = false;
	disableButtonSave = false;

	get tomorrow(){
        let msInADay = 24*60*60*1000;
        let msForTomorrow = (new Date().getTime()) + msInADay;
        return  new Date(msForTomorrow).toJSON().slice(0,10);
        
    }
    @wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference.state.c__recId;
		this.accountId = (this.currentPageReference.state.c__account != '') ? this.currentPageReference.state.c__account : null;
        this.clientinfo = {
            id:this.recordId,   
            name:this.currentPageReference.state.c__id,
            intouch:this.currentPageReference.state.c__intouch,
            recordtype:this.currentPageReference.state.c__rt,
			accountId:this.accountId
			// accountId:this.currentPageReference.state.c__account
        };
	}

	@wire(getRecord, {recordId:USER_ID,fields:[FUNCION]})
	wiredUser({error, data}) {    
    if (data)  { 
		this.currentUserFunction = data.fields.AV_Funcion__c.value;
    } else if (error) {
        this.error = error ;
    }
}
    @wire(getComboboxValues,{ fields: FIELDS_TO_RETRIEVE} )
	getComboboxValues(wireResult){
		let error = wireResult.error;
		let data  = wireResult.data;
		if(data){
			this.potentialList = data;
	}else if(error){
			console.log('Error => ',error);
		}
	}
    connectedCallback(){
		console.log(this.accountId)
		if(this.accountId != null){
			console.log('me voy a pillar oportunidades');
			this.getRelatedOpportunities();
		}else{
			this.showSpinner = false;
		}
		
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
		this.durationToCalendar = this.newEvent['duration'];
		this.activityDateToCalendar = this.newEvent['activityDate'];
		this.employeeToCalendar = this.newEvent['owner'];
		this.subjectToCalendar = this.newEvent['subject'];
		if(this.employeeToCalendar == USER_ID){
			this.overlapToCalendar = true;
		}else{
			this.overlapToCalendar = this.currentUserFunction != GESTOR;
		}
		if(e.detail.changeClient){
			this.accountId = e.detail.client;
			this.getRelatedOpportunities();
		}
    }

    handleSave(){
       let nextScreen =  this.template.querySelector('[data-id="detailCmp"]').validateRequiredInputs();
	   this.showCalendar = nextScreen;
	   if(this.showCalendar){
			this.disableButtonCancel = true;
			this.disableButtonSave = true;
	   }
    }

    

	buildOppoObj(e){
		let nextOppo = (e.detail != null) ? e.detail : e 
		let id = (e.detail != null) ? e.detail.id : e.Id;
		let vinculed = (e.detail != null) ? e.detail.isVinculed : e.isVinculed;
		if(Object.keys(this.oppoObj).includes(id) && !vinculed){
				delete this.oppoObj[id];
			}else{
				this.oppoObj[id] = nextOppo;
		}
	}

	handleMainOpp(e){
		let itemOppId = e.detail.oppoId;
		this.currentMainVinculed = itemOppId;
		let auxList = (this.oppoList != undefined) ? this.oppoList.concat(this.oppoNewList) : this.oppoNewList; 
		auxList.forEach(opp => {
			this.template.querySelector('[data-id="'+opp.Id+'"]').mainVinculed = (opp.Id == itemOppId);
			if(opp.Id == itemOppId && Object.keys(this.oppoObj).includes(itemOppId)){
				this.oppoObj[itemOppId]['mainVinculed'] = true;
			}
		})
	}
    

    handleVinculation(e){
		(e.detail.sum)?this.opposCount++:this.opposCount--;
		let itemOppId = e.detail.oppoId;
		let onlyOneVinculed = (this.opposCount <= 1)
		let auxList = (this.oppoList != undefined) ? this.oppoList.concat(this.oppoNewList) : this.oppoNewList; 
		this.currentMainVinculed = null;
		let firtstVinculedId = null;
		// this.oppoObj[itemOppId]['proximaGestion'] = this.newEvent['activityDate'];
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
        let cmp = this.template.querySelector("[data-id='newproductlookup']");
		let selection = cmp.getSelection()[0];
		if(selection != null){
			this.selectedProds.push(selection.id);
			this.oppoNewList.push(
				{
					Id:IDPROVISIONAL+this.idProvisional++,
					Name:selection.title,
					Stage:'En Gestión/Insistir',
					ProductoMain:selection.id,  
					Fecha:(this.newEvent['activityDate'] != undefined ) ? this.newEvent['activityDate'] : new Date().toJSON().slice(0,10),
					// Fecha:this.parseTodayDate(),
					NotInserted:true,
					unFoldCmp:true
				}
			);
			cmp.handleClearSelection();
			this.evaluateProductToAdd();
		}
    }

	handleCreateEvent(){
		let calendar = this.template.querySelector('[data-id="customcalendar"]');
		let inittime = calendar.initTime;
		let finaltime = calendar.endTime;
		if(inittime == undefined || finaltime == undefined){
			this.showToast('Faltan datos',
						   'Marca una franja en el calendario para continuar',
						   'Error');
		}else if(new Date(inittime) < new Date() ){
			this.showToast('Fechas incorrectas',
			'Por favor, introduce una fecha futura',
			'Error');
		}else{
			let eventToInsert = {
				sobjectype: 'Event',
				WhatId:this.newEvent['client'],
				WhoId:this.newEvent['personaContacto'],
				AV_Center__c:this.newEvent['center'],
				OwnerId:this.newEvent['owner'],
				Subject:this.newEvent['subject'],
				Description:this.newEvent['comentary'],
				AV_Tipo__c:this.newEvent['type'],
				StartDateTime:inittime,
				EndDateTime:finaltime,
				DurationInMinutes:this.newEvent['duracion'],
				ActivityDate:this.newEvent['activityDate'],
				AV_BranchPhysicalMeet__c:this.newEvent['otherOfficeNumber'],
				Location: this.newEvent['ubication']
			}
			if(eventToInsert.AV_Tipo__c == 'CTO'){
				eventToInsert.AV_BranchPhysicalMeet__c = eventToInsert.AV_Center__c;
			}	
			if(ISBPR){
				eventToInsert.AV_MemorableInterview__c = this.newEvent['memorableInterview'] 
			}
			this.startReportLogic(eventToInsert);
			
		}
	}

	startReportLogic(eventToInsert){
		this.focusRecord()
		this.showSpinner = true;
		createEvent({evt:eventToInsert,attendes:this.newEvent['attendes']})
		.then(result =>{
			if(!result.includes('Fail-')){
				this.createdEventId = result;
				this.createdAttendesOrEventId.push(this.createdEventId);
				if(this.newEvent['attendes'].length > 0){
					this.createAttendes();
				}else{
					this.updateOrCreateOpportunities();
				}
			}else{	
				//REPENSAR EL BACK
				this.showSpinner = false;
				this.showToast('Error creando el evento',result,'error');
				this.handleError();
			}
		}).catch(error => {
			this.handleError();
			this.showToast('Error creando el evento',result,'error');
			console.log(error);
			this.showSpinner = false;
		})
	}

	closeModal(){
		this.showCalendar = false;
		this.disableButtonCancel = false;
		this.disableButtonSave = false;
	}

	updateOrCreateOpportunities(){
		for(let oppo in this.oppoObj){
			this.oppoObj[oppo]['proximaGestion'] = this.newEvent['activityDate'];
		}
		createOrUpdateOpportunities({newOppos:this.oppoObj,accountId:this.accountId})
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
					console.log(err);
				})
				this.deleteEventRegisters();
				//BACKUP ATTENDES
			}
		}).catch(error => {
			//BACKUP ATTENDES
			console.log(error);
			this.deleteEventRegisters();
			

			
		})
		
	}

	deleteEventRegisters(){
		deleteCreatedEventOrAttendes({recordsToDelete:this.createdAttendesOrEventId})
		.then(result => {
		if(result == 'OK'){

			this.showToast(
				'Error actualizando las oportunidades',
				'Se han desecho todos los cambios.',
				'Error');
			}else{
				this.showToast(
					'Error actualizando las oportunidades',
					'El evento ha quedado registrado mal. Porfavor, eliminelo manualmente.',
					'Error');
			}
			this.handleError();
			this.showSpinner = false;
			
		}).catch(error => {
			this.showSpinner = false;
			console.log(error);
			this.showToast(
				'Error actualizando las oportunidades',
				'El evento ha quedado registrado mal. Porfavor, eliminelo manualmente.',
				'Error');
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

		this.dispatchEvent( new CustomEvent( 'closetab'))
		
	}
	
	handleCloseFinish(){
		
		this.dispatchEvent( new CustomEvent( 'closetabfinish',{detail:{neweventid:this.createdEventId}}))
	}

	
	handleError(){
		this.dispatchEvent(new CustomEvent('focustab'));
		this.closeModal();
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
			preBuildCaoList.push(
				{
					sobjectype:'AV_CustomActivityOpportunity__c',
					AV_Opportunity__c: currentOppo['id'],
					AV_IsMain__c: this.template.querySelector('[data-id="'+id+'"]').mainVinculed
				}
			);
		}
		vinculateOpportunities({
			caosToInsert:preBuildCaoList,
			evtId:this.createdEventId
			
		})
			.then(result => {
				if(result == 'OK'){
					if(updatedOrCreatedOppos.length > 0){

						this.sendToGcfOpportunity(updatedOrCreatedOppos);
					}else{
						this.finishReport();
						}
				}else{
					//GESTIONAR ROLLBACK
					console.log(result)
					this.backReportOpportunities();
				}
					this.showSpinner = false;
			}).catch(error => {
				console.log(error);
				this.backReportOpportunities();
				//GESTIONAR ROLLBACK
			})
	}

	finishReport(){
		this.handleCancel();
		this.showSpinner = false;
	}

	sendToGcfOpportunity(listIdsOpps) {
		sendToGfc({listIdsOppUpdateCreated:listIdsOpps})
		.then(result =>{
			if(result != 'OK'){
				console.log('sendOppToGCF '+result);
			}
			this.finishReport();
		}).catch(error => {
			this.finishReport();
			this.showSpinner = false;
			console.log('sendOppToGCF '+error);
		})
	}
	
	backReportOpportunities(){
		let oldOpposToReportBack = [];
		for(let oppoId in this.oppoObj){
			if(!oppoId.includes(IDPROVISIONAL)){
				oldOpposToReportBack.push(
					this.template.querySelector('[data-id="'+oppoId+'"]').initialState
					);
			}

		}

		backCreatedOrUpdtOppos({createdIds:this.createdOpposIds,
			oldOppos:oldOpposToReportBack,
			tskToRestore: this.checkOnOffTasksBackUp,
			caoToRestore: this.caosCheckOnOffBackUp,
			entityRelations: this.taskAndOpposRel
		})
			.then((result) =>{
				this.deleteEventRegisters();
				if(result != 'OK'){
				}else{
				}
				this.showToast(
					'Error en el reporte',
					'No se ha editado ni creado ninguna oportunidad,ni se ha creado ningún evento',
					'error');
				this.showSpinner = false;
				this.handleError();

				}).catch(error =>{
					console.log(error);
					this.showToast(
						'Error vinculando las oportunidades con el evento',
						'Cuidado, no se han podido deshacer los cambios en las oportunidades',
						'warning');
					})
				this.handleError();
				this.showSpinner = false;
	}

	createAttendes(){
		createAttendesRelation({eventId:this.createdEventId,attendes:this.newEvent['attendes']})
							.then(result =>{
								if(result[0] != 'Fail'){
									result.forEach(attId => {
										this.createdAttendesOrEventId.push(attId);
									})
									this.updateOrCreateOpportunities();
								}else{
									console.log(result);
									this.deleteEventRegisters();
									this.showSpinner = false;

								}
							}).catch(error => {
								
								this.deleteEventRegisters();
								this.showSpinner = false;
								console.log(error)
							})
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


    
}