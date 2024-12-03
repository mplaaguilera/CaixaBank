import { LightningElement, api, track, wire } from 'lwc';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import lookupSearchOffice from '@salesforce/apex/AV_ReportAppointment_Controller.searchOffice';
import lookupSearchContact from '@salesforce/apex/AV_ReportAppointment_Controller.searchContact';

import ISBPR from '@salesforce/customPermission/AV_PrivateBanking';
export default class Av_ContactBlockAppointment extends LightningElement {

	@api islegalentity;
	@api isintouch;
	@api accountid;
	@api isreport;
	commentary;
	showComentary = false;
	showOffice = false;
	showLocation = false;
	location = null;
	@track showContactPerson = false;
	radioButtonSelected = false;
	nowReference = new Date(Date.now()).toISOString();
	now = this.nowReference;
	activityDateTime = this.now;
	durationValueInitial;
	memorableInterview = false;
	isMultiEntry2 = false;
	find = '';
	initialSelection = [];
	initialSelectionOffice = [];
	officePlaceholder = 'Buscar oficina...';
	contactPlaceholder = 'Buscar contacto...';
	officeNumberCompany = null;
	contactPerson = null;
	firstRender = true;
	isbpr;
	statusValue = 'Gestionada positiva';
	comentaryToSend;
	showNoLocalizado = false; 
	isCheckedNoLocalizado = false; 
	@api get checkboxStatus(){
		return this.showComentary;
	}

	@api
	switchCitaCheckBox(value){
		this.template.querySelector("[data-id='citanocomercialcb']").checked = value;

	}
	get optionsStatus(){
		return [
			{label:'Gestionada positiva',value:'Gestionada positiva'},
			{label:'Gestionada negativa',value:'Gestionada negativa'}
		]
	}
	
    handleChangeStatus(e) {
		this.statusValue = e.target.value;
		this.sendDataToReportTask();
    }
	connectedCallback(){
		this.isbpr = ISBPR;
		this.durationValueInitial = (this.isintouch) ? '30' : '5';
		this.durationValue = (this.isintouch) ? 30 : 5;
		this.selectedOption = (this.isintouch) ? 'CTF' : 'LMD';
		  
		if(this.selectedOption == 'LMD'){
			this.showNoLocalizado = true;
		}
		
	}
	
	renderedCallback(){
		if(this.firstRender){
			let idToCheck = (this.isintouch) ? 'cita-telefonicacheked' : 'llamada';
			this.template.querySelector('[data-id="'+idToCheck+'"]').checked = true;
			this.firstRender = false;
		}
		if(this.islegalentity){
			this.showContactPerson = true;
		}
	}

	get optionsDuration(){
		return [
			{label:'5 min',value:'5'},
			{label:'30 min',value:'30'},
			{label:'1 h',value:'60'}
		]
	}

	handleComment(e) {
		if(this.isCheckedNoLocalizado){
			this.comentaryToSend = e.target.value;
			this.sendDataToReportTask();
		}else{
			this.commentary=e.target.value;
			this.sendDataToReportEvent();
		}
	}

	handleMemorableInterview(e){
		this.memorableInterview = e.target.checked;
		this.sendDataToReportEvent();
	}

	handleChangeDuration(e){
		this.durationValue = parseInt(e.target.value);
		this.sendDataToReportEvent();
	}

	handleCheckboxChange(event){
		this.showComentary = event.target.checked;
		this.dispatchEvent(
			new CustomEvent('changecita',
			{
				detail:{
					value:event.target.checked
				}
			})
		)
		
		if(this.isCheckedNoLocalizado){
			this.sendDataToReportTask();
		}else{
			this.sendDataToReportEvent();
		}
		
	}

	handleOptionChange(event){
		
		this.selectedOption = event.target.value;
		if(this.selectedOption === 'LMD'){
			this.durationValueInitial = '5';
			this.durationValue = 5;
			this.showOffice = false;
			this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
			this.showNoLocalizado = true;  
		}else if(this.selectedOption === 'CTO'){
			this.durationValueInitial = '60';
			this.durationValue = 60;
			this.showOffice = false;
			this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
			this.showNoLocalizado = false;  
			this.isCheckedNoLocalizado = false; 			
		}else if(this.selectedOption === 'CTF'){
			this.durationValueInitial = '30' ;
			this.durationValue = 30 ;
			this.showOffice = false;
			this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
			this.showNoLocalizado = false;  
			this.isCheckedNoLocalizado = false; 
		}else if(this.selectedOption === 'VLD'){
			this.durationValueInitial = '30' ;
			this.durationValue = 30 ;
			this.showOffice = false;
			this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
			this.showNoLocalizado = false;  
		    this.isCheckedNoLocalizado = false; 
		}else if(this.selectedOption === 'CTOOC'){
			this.durationValueInitial = '60';
			this.durationValue = 60;
			this.showLocation = false;
			this.showOffice = event.target.value;
			this.location = null;
			this.officeNumberCompany= null;
			this.showNoLocalizado = false;  
			this.isCheckedNoLocalizado = false; 
		}else if(this.selectedOption === '001'){
			this.durationValueInitial = '60';
			this.durationValue = 60;
			this.showOffice = false;
			this.showLocation = event.target.value;
			this.location = null;
			this.officeNumberCompany= null;
			this.showNoLocalizado = false;  
			this.isCheckedNoLocalizado = false; 
		}
		

		if(this.isCheckedNoLocalizado == false){
			this.sendDataToReportEvent();
		}

		
		this.dispatchEvent(
			new CustomEvent('changeoptionevent',
			{
				detail:{
					value:event.target.value
				}
			})
		)
	}

	handleOptionChangeTask(event){
		this.selectedOptionTask = event.target.value;
		if ((this.selectedOptionTask === '030' || this.selectedOptionTask === 'ESE' || this.selectedOptionTask === 'OFT')) {   
			this.radioButtonSelected = true;
		} else {
			this.radioButtonSelected = false;
		}
		const radioButtonSelectedTask = new CustomEvent('radiobuttonselected',{
			detail: {radioButtonSelected: this.radioButtonSelected}
		});
		this.dispatchEvent(radioButtonSelectedTask);
		this.sendDataToReportTask();
	}

	handleDateChange(event){
		this.activityDateTime = event.target.value;
		this.sendDataToReportEvent();
	}

	handleChangeLocation(event){
		this.location = event.target.value;
		this.sendDataToReportEvent();
	}

	handleSearchOffice(event) {
		lookupSearchOffice(event.detail)
		.then((results) => {
			this.template.querySelector('[data-id="clookup5"]').setSearchResults(results);
		})
		.catch((error) => {
			this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
			console.log('Lookup error', error);
		});
	}

	checkForErrors(event) {
		let targetId = event.target.dataset.id;
		if (targetId == 'clookup5') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.officeNumberCompany = sel.title.substring(0,5);
					this.sendDataToReportEvent();
				}
			} else {
				this.officeNumberCompany = null;
				this.template.querySelector(`[data-id="${targetId}"]`).handleBlur();
				this.sendDataToReportEvent();
			}
		} else if (targetId == 'clookup6') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.contactPerson = sel.id;
					this.sendDataToReportEvent();
				}
			} else {
				this.contactPerson = null;
				this.find='';
				this.template.querySelector(`[data-id="${targetId}"]`).handleBlur();
				this.sendDataToReportEvent();
			}
		}
	}

	handleSelectionChange(event) {
		this.checkForErrors(event);
	}

	handleSearchContact(event) {
		this.find = event.detail.searchTerm;
		lookupSearchContact({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, accountId: this.accountid})
		.then((results) => {
			this.template.querySelector('[data-id="clookup6"]').setSearchResults(results);
		})
		.catch((error) => {
			this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
			console.log('Lookup error '+error);
		});
	}

	handleSearchContactClick(event) {
		if (this.find == '' && this.contactPerson == null) {
			lookupSearchContact({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, accountId: this.accountid})
			.then((results) => {
				this.template.querySelector('[data-id="clookup6"]').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.log('Lookup error '+error);
			});
		}
	}

	handleTabActive(event){
		this.selectedTab = event.target.value;
		if(this.selectedTab === 'tabEvent'){
			this.sendDataToReportEvent();
		}else if(this.selectedTab === 'tabTask'){
			this.sendDataToReportTask();
		}
		
		if(this.selectedTab == 'tabTask'){
			const checkbox =this.template.querySelector('lightning-input[data-id="no-localizado"]');
			if (checkbox) {
				checkbox.click();
				checkbox.checked= false;
			}
		}
		
		this.dispatchEvent(
			new CustomEvent('changetabconsincliente',
			{
				detail:{
					value:this.selectedTab
				}
			})
		)
		
	}
	
	notifyUser(title, message, variant) {
		if (this.notifyViaAlerts) {
			alert(`${title}\n${message}`);
		} else {
			const toastEvent = new ShowToastEvent({ title, message, variant });
			this.dispatchEvent(toastEvent);
		}
	}

	sendDataToReportEvent(){	
		this.dispatchEvent(
			new CustomEvent('setinfo',
			{
				detail:{ 
					type: 'event',
					typeEvent: this.selectedOption,
					duracion: this.durationValue,
					activityDateTime: this.activityDateTime,
					accountId: this.accountid,
					memorableInterview: this.memorableInterview,
					comercial: this.showComentary,
					comment: this.commentary,
					office: this.officeNumberCompany,
					contactPerson: this.contactPerson,
					location: this.location
				}
			})
		);
	}
		
	sendDataToReportTask(){
		this.dispatchEvent(
			new CustomEvent('setinfo',
			{
				detail:{ 
					type: 'task',
					typeTask: this.selectedOptionTask,
					accountId:this.accountid,
					statusTask: this.statusValue,
					comentaryTask: this.comentaryToSend
				}
			})
		);
	}

	handleChangeComentary(e){
		this.comentaryToSend = e.detail.value;
		this.sendDataToReportTask();
	}

	handleNoLocalizado(event){
		
		if(this.selectedOption == 'LMD' && this.selectedTab=='tabEvent'){
		    this.isCheckedNoLocalizado = event.target.checked;
		}else{
			this.isCheckedNoLocalizado = false;
		}
		
		if(this.selectedTab=='tabTask'){
		    this.isCheckedNoLocalizado = false;

		}
		

		
		
		this.dispatchEvent(
			new CustomEvent('changenolocalizado',
			{
				detail:{
					value: this.isCheckedNoLocalizado
				}
			})
		)
		if(this.isCheckedNoLocalizado && this.selectedTab=='tabEvent'){
			this.dispatchEvent(
				new CustomEvent('setinfo',
				{
					detail:{ 
						type: 'task',
						accountId:this.accountid,
						statusTask: this.statusValue
						
					}
				})
			);
		}
		
		else if(this.isCheckedNoLocalizado == false && this.selectedTab=='tabEvent'){
			this.sendDataToReportEvent();
		}
		
		
	}

	
}