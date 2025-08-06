import { LightningElement,api,wire,track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import NAME from '@salesforce/schema/User.Name';
import CENTER from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import {getRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ISBPR from '@salesforce/customPermission/AV_PrivateBanking';


import searchClients      from '@salesforce/apex/AV_NewEvent_Controller.searchClients';
import searchEmployee     from '@salesforce/apex/AV_NewEvent_Controller.searchEmployees';
import searchContact      from '@salesforce/apex/AV_NewEvent_Controller.searchContact';
import searchAttende      from '@salesforce/apex/AV_NewEvent_Controller.searchAttendees';
import searchOffice       from '@salesforce/apex/AV_NewEvent_Controller.searchOffice';
import getEmployeeInfo    from '@salesforce/apex/AV_NewEvent_Controller.getEmployeeInfo';

export default class Av_NewEventReportDetail extends LightningElement {

	@api clientinfo;//Contiene el id y el bombre del cliente
	@api issummary;
	@api timeinfo;

	initialemployee;
	error;
	initialclient = null;
	initialselection;
	//variables de input

	clientToSend;
	noComercial = false;
	employeeToSend = USER_ID;
	centerToSend;
	contactToSend;
	attendesToSend = [];
	subjectToSend;
	comentaryToSend;
	selectedAttendesToSend = [];
	typeToSend;
	ubicationToSend;
	accountName;
	employeeName;
	contactPersonName;
	attendeesNames;
	officeName;
	typeName;
	find = '';
	
	officeToSend;
	otherOfficeNumberToSend;
	memorableInterviewToSend = false;
	//Variables de if:true
	attendes = false;
	isIntouch;
	showUbication;
	showOfficeInput;
	isPersonaJuridica;
	disabledContact=false;
	isBpr = ISBPR;
	radioButtonChecked = false;
	@track selectedAttendes = [];
	multiSelectionAttendee = 0;

	mapType = {
		'CTO':'Cita en la oficina',
		'CTF':'Cita telefónica',
		'VLD':'Videollamada',
		'CTOOC':'Cita en otra oficina',
		'001':'Visita del gestor'
	}
	@api
	setClientLookup(){
		if(this.clientToSend != null && this.accountName != null){
			this.initialclient = (this.clientToSend != null) ? [{id:this.clientToSend,title:this.accountName,icon:'standard:user'}] : null;
		}
	}
	
	@wire(getRecord, {recordId:USER_ID,fields:[NAME,CENTER]})
	wiredUser({error, data}) {    
		if (data && this.clientinfo != null && this.initialclient == null)  { 
			let info = {};
			this.subjectToSend = this.clientinfo.eventSubject;
	
			if(this.clientinfo.contactPlate !== undefined){
				getEmployeeInfo({contactPlate : this.clientinfo.contactPlate})
					.then(result => {
						if(result.error == null){

							info.employeId = result.contactId ;
							info.employeName = result.contactName ;
							info.employeeOfficeNumber = result.contactOfficeNumber ;
							this.fillVars(info);
							if(this.clientinfo.eventType != null){
								this.radioButtonChecked = true;
								this.typeToSend = this.clientinfo.eventType;
								this.typeName = this.mapType[this.typeToSend];
							}
						}else{
							this.showToast('Error',result.error,'error');
						}
					}).catch(error => {
						console.error(error);
					})
					
				}else{
					info.employeId = USER_ID;
					info.employeName = data.fields.Name.value;
					info.employeeOfficeNumber = data.fields.AV_NumeroOficinaEmpresa__c.value;
					this.fillVars(info);
					if(this.clientinfo.eventType != null){
						this.radioButtonChecked = true;
						this.typeToSend = this.clientinfo.eventType;
						this.typeName = this.mapType[this.typeToSend];
					}
				}
				
		} else if (error) {
			this.error = error ;
		}
	}


	renderedCallback(){
		if(this.radioButtonChecked){
			this.setCheckedRadioButton();
			this.radioButtonChecked = false;
		}
	}

	setCheckedRadioButton() {
		const radioButtons = this.template.querySelectorAll('input[name="typeInput"]');
		radioButtons.forEach(radio => {
			if (radio.value === this.typeToSend) {
				radio.checked = true;  
			} else {
				radio.checked = false; 
			}
		});
	}
	
	fillVars(info){
		
		this.clientToSend = this.clientinfo.accountId;
		this.initialclient = (this.clientToSend != null) ? [{id:this.clientinfo.accountId,title:this.clientinfo.name,icon:'standard:user'}] : null;
		this.initialemployee = [{id:info.employeId,title:info.employeName,icon:'standard:account'}];
		this.accountName = this.clientinfo.name;
		this.employeeName = info.employeName;
		this.isIntouch = (this.clientinfo.intouch == 'true')?true:false;
		this.typeToSend =(this.isIntouch) ? 'CTF' : 'CTO';
		this.typeName = this.mapType[this.typeToSend];
		this.isPersonaJuridica = this.clientinfo.recordtype == 'CC_Cliente';
		this.centerToSend = info.employeeOfficeNumber?.split('-')[1] || '';
		this.sendEventInfoToParent();

	}


	handleSearchClient(e){
		searchClients({searchTerm:e.detail.searchTerm})
		.then(result => {
			if(result != null){
				this.template.querySelector('[data-id="clientlookup"]').setSearchResults(result);
			}
		}).catch(error =>{
			console.log(error);
		});
	}

	handleSelectionClient(){
		let clientSelection = this.template.querySelector('[data-id="clientlookup"]').getSelection()[0];
		if( clientSelection != null && clientSelection != undefined){
			this.clientToSend = clientSelection.id;
			this.accountName = clientSelection.title;
			this.sendEventInfoToParent(true);
			this.disabledContact = false;
		}else{
			this.disabledContact = true;
			this.clientToSend = null;
			this.accountName = null;
			this.sendEventInfoToParent();
		}
	}

	handleSearchEmployee(e){
		let currentAttendes = [];
		this.selectedAttendes.forEach(att => {
			currentAttendes.push(att.id);
		})
		searchEmployee({searchTerm:e.detail.searchTerm,selectedIds: currentAttendes})
		.then(result => {
			if(result != null ){
				this.template.querySelector('[data-id="employeelookup"]').setSearchResults(result);
			}
		}).catch(error =>{
			console.log(error);
		});
	}
	handleSelectionEmployee(){
		let employeeSelection = this.template.querySelector('[data-id="employeelookup"]').getSelection()[0];
		if(employeeSelection != null && employeeSelection != undefined && employeeSelection.id != this.employeeToSend ){
			let currentAttendes = [];
			this.selectedAttendes.forEach(att => {
				currentAttendes.push(att.id);
			})
			if(!currentAttendes.includes(employeeSelection.id)){

				this.employeeToSend = employeeSelection.id;
				this.employeeName = employeeSelection.title;
				this.centerToSend = employeeSelection.subtitle?.split('-')[1];
				this.sendEventInfoToParent();
			}else{
				this.showToast('Cuidado','No puedes introducir como acompañante al gestor de la cita','Warning');
				this.template.querySelector('[data-id="employeelookup"]').handleClearSelection();
			}
		}else{
			this.employeeToSend = null;
			this.employeeName = null;
			this.centerToSend = null;
			this.sendEventInfoToParent();
		}
		
	}

	handleSearchContactPerson(e){
		this.find = e.detail.searchTerm;
		searchContact({searchTerm:e.detail.searchTerm,selectedIds:null,accountId:this.clientToSend})
		.then(result => {
			if(result != null){
				this.template.querySelector('[data-id="contactpersonlookup"]').setSearchResults(result);
			}
		}).catch(error =>{
			console.log(error);
		});
	}

	handleSearchContactPersonClick(e) {
		if (this.find == '' && this.contactToSend == null) {
			searchContact({searchTerm:e.detail.searchTerm,selectedIds:null,accountId:this.clientToSend})
			.then(result => {
				if(result != null){
					this.template.querySelector('[data-id="contactpersonlookup"]').setSearchResults(result);
				}
			}).catch(error =>{
				console.log(error);
			});
		}
	}

	handleSelectionContactPerson(){
		let contactSelection = this.template.querySelector('[data-id="contactpersonlookup"]').getSelection()[0];
		if(contactSelection != null && contactSelection != undefined ){
			this.contactToSend= contactSelection.id;
			this.contactPersonName = contactSelection.title;
			this.sendEventInfoToParent();
		}else{
			this.contactToSend = null;
			this.contactPersonName = null;
			this.find='';
			this.template.querySelector('[data-id="contactpersonlookup"]').handleBlur();
			this.sendEventInfoToParent();
		}
	}

	handleSearchAttendes(e){
		searchAttende({searchTerm:e.detail.searchTerm,selectedIds:this.selectedAttendesToSend,currentUser:this.employeeToSend})
		.then(result => {
			if(result != null){
				this.template.querySelector('[data-id="attendeeslookup"]').setSearchResults(result);
			}
		}).catch(error =>{
			console.log(error);
		})
		
	}
	
	handleSelectionAttendee(){
		let attendeeLookup = this.template.querySelector('[data-id="attendeeslookup"]');
		let attendeeSelection = attendeeLookup.getSelection()[0];
		if(attendeeSelection != null && attendeeSelection != undefined ){
			this.selectedAttendes.push({
				id:attendeeSelection.id,
				label:attendeeSelection.title,
				bucleId:++this.multiSelectionAttendee}
			);
			this.attendes = true;
			attendeeLookup.handleClearSelection();
			this.sendEventInfoToParent();
		}
		this.attendeesNames='';
		for(let i=0; i < this.selectedAttendes.length ; i++){
			if (i == this.selectedAttendes.length-1) {
				this.attendeesNames = this.attendeesNames + this.selectedAttendes[i].label;
			}else {
				this.attendeesNames = this.attendeesNames + this.selectedAttendes[i].label + ', ';
			}
		}
	}
	handleRemoveAttende(e){
		let idToDel = e.target.name;
		this.attendeesNames='';
		for(let i=0; i < this.selectedAttendes.length ; i++){
			if(this.selectedAttendes[i].id === idToDel){
				this.selectedAttendes.splice(i,1);
				break;
			}
			if (i == this.selectedAttendes.length-1) {
				this.attendeesNames = this.attendeesNames + this.selectedAttendes[i].label;
			}else {
				this.attendeesNames = this.attendeesNames + this.selectedAttendes[i].label + ', ';
			}
		}
		this.sendEventInfoToParent();
		this.attendes = this.selectedAttendesToSend.length > 0;
	}

	handleChangeSubject(e){
		this.subjectToSend = e.target.value;
		this.sendEventInfoToParent();
	}

	handleChangeComentary(e){
		this.comentaryToSend = e.target.value;
		this.sendEventInfoToParent();
	}

	handleMemorableInterview(e){
		this.memorableInterviewToSend = e.target.checked;
		this.sendEventInfoToParent();
	}

	handleNoComercial(e){
		this.noComercial = e.target.checked;
		this.sendEventInfoToParent();
	}
	
	hnadleChangeEventType(e){
		this.typeToSend = e.target.value;
		this.typeName = this.mapType[this.typeToSend];
		this.showUbication = (this.typeToSend == '001' );
		this.showOfficeInput = this.typeToSend == 'CTOOC';
		this.ubicationToSend = null;
		this.officeToSend = null;
		this.officeName = null;
		this.otherOfficeNumberToSend = null;
		this.sendEventInfoToParent();
	}
	
	handleChangeUbication(e){
		this.ubicationToSend = e.target.value;
		this.sendEventInfoToParent();
	}

	handleSearchOffice(e){
		searchOffice({searchTerm:e.detail.searchTerm,selectedIds:null})
		.then(result => {
			if(result != null){
				this.template.querySelector('[data-id="officelookup"]').setSearchResults(result);
			}
		}).catch(error =>{
			console.log(error);
		})
	}

	handleSelectionOffice(){
	  let officeSelection = this.template.querySelector('[data-id="officelookup"]').getSelection()[0];
		if(officeSelection != null && officeSelection != undefined ){
			this.officeToSend = officeSelection.id;
			this.officeName = officeSelection.title;
			this.otherOfficeNumberToSend = officeSelection.subtitle.substring(officeSelection.subtitle.length -5);
			this.sendEventInfoToParent();
		}else{
			this.officeToSend = null;
			this.officeName = null;
		}
	}
   
	sendEventInfoToParent(changeClient){
		if(changeClient == undefined){
			changeClient = false;
		}
		this.selectedAttendesToSend = [];
		if(this.selectedAttendes.length > 0){
			this.selectedAttendes.forEach(att =>{
				this.selectedAttendesToSend.push(att.id);
			});
		}
		this.dispatchEvent(
		new CustomEvent('eventinfo',{
				detail:{
					client:this.clientToSend,
					owner:this.employeeToSend,
					center:this.centerToSend,
					personaContacto:this.contactToSend,
					attendes:this.selectedAttendesToSend,
					subject:this.subjectToSend,
					comentary:this.comentaryToSend,
					type:this.typeToSend,
					ubication:this.ubicationToSend,
					office:this.officeToSend,
					otherOfficeNumber:this.otherOfficeNumberToSend,
					memorableInterview:this.memorableInterviewToSend,
					nocomercial:this.noComercial,
					changeClient: changeClient
				}
			}
			)
		)
	}

	@api
	validateRequiredInputs(){
		if(this.clientToSend == null){
		   this.scrollIntoElement('clientlookup');
		   this.showToast('Faltan datos','Introduce un cliente para la cita','error')
		   return false;
		}
		if(this.employeeToSend == null){
			this.showToast('Faltan datos','Introduce un empleado para la cita','error')
			this.scrollIntoElement('employeelookup');
			return false;
		}
		if(this.subjectToSend == null || this.subjectToSend == '' || !this.template.querySelector('[data-id="subjectinput"]').reportValidity()){ 
			this.showToast('Faltan datos','Por favor, introduce un asunto para la cita','error')
			this.template.querySelector('[data-id="subjectinput"]').click();
			this.template.querySelector('[data-id="subjectinput"]').focus();
			this.scrollIntoElement('subjectinput');
			return false;
		}
		if(this.typeToSend == null){
			this.scrollIntoElement('radioButtonDiv');
			this.showToast('Faltan datos','Introduce un tipo para la cita','error')
			return false;
		}
		if(this.officeToSend == null && this.showOfficeInput){
			this.showToast('Faltan datos','Para este tipo de cita es necesario indicar una oficina','error')
			this.scrollIntoElement('officelookup');
			return false;
		}
		return true;
	}

	scrollIntoElement(id){
		this.template.querySelector('[data-id="'+id+'"]').scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});;
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