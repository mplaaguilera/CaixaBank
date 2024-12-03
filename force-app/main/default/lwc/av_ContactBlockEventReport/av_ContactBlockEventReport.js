import { LightningElement, api, track, wire } from 'lwc';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import lookupSearchOffice from '@salesforce/apex/AV_EventReport_Controller.searchOffice';
import lookupSearchContact from '@salesforce/apex/AV_EventReport_Controller.searchContact';

import ISBPR from '@salesforce/customPermission/AV_PrivateBanking';
export default class Av_ContactBlockEventReport extends LightningElement {

	@api islegalentity;
	@api isintouch;
	@api accountid;
    @api typeevent;
	@api startdatetime;
	@api idevent;
	commentary;
	showComentary = false;
	showOffice = false;
	showLocation = false;
	location = null;
	@track showContactPerson = false;
	radioButtonSelected = false;
	now;
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
	hora;
	activityTime;

	@api get checkboxStatus(){
		return this.showComentary;
	}

	@api
	switchCitaCheckBox(value){
		this.template.querySelector("[data-id='citanocomercialcb']").checked = value;
	}
	

	connectedCallback() {
		this.isbpr = ISBPR;
		const currentUTCDate = new Date();

		const formatDateToLocalString = (date) => {
			let day = String(date.getDate()).padStart(2, '0');
			let month = String(date.getMonth() + 1).padStart(2, '0');
			let year = date.getFullYear();
			let hours = String(date.getHours()).padStart(2, '0');
			let minutes = String(date.getMinutes()).padStart(2, '0');
			
			return `${day}/${month}/${year}, ${hours}:${minutes}`;
		};

		let currentLocalDate = formatDateToLocalString(currentUTCDate);

		const parseLocalStringToDate = (dateString) => {
			let [datePart, timePart] = dateString.split(', ');
			let [day, month, year] = datePart.split('/');
			let [hours, minutes] = timePart.split(':');
			return new Date(year, month - 1, day, hours, minutes);
		};
	
		let startDateTimeObj = parseLocalStringToDate(this.startdatetime);
		let currentDateTimeObj = parseLocalStringToDate(currentLocalDate);
	
		if (startDateTimeObj > currentDateTimeObj) {
			this.now = currentDateTimeObj.toISOString(); 
		} else {
			this.now = startDateTimeObj.toISOString();
		}
	
		this.sendDataToReport();
	}
	
	renderedCallback(){
		if(this.firstRender){
			this.checkedradio();
			this.firstRender = false;
		}
		if(this.islegalentity){
			this.showContactPerson = true;
		}
	}

	get optionsDuration(){
		return [
			{label:'5 min', value:'5'},
			{label:'30 min',value:'30'},
			{label:'1 h',value:'60'}
		]
	}

	checkedradio() {
		if(this.typeevent === 'LMD'){
			const radioButtonToChecked = this.template.querySelector('[data-id="lmd"]');
			if(radioButtonToChecked){
				this.selectedOption = 'LMD';
				radioButtonToChecked.checked = true;
				this.durationValueInitial = '5';
				this.durationValue = 5;
				this.showOffice = false;
			}
		} else if(this.typeevent === 'CTO'){
			const radioButtonToChecked = this.template.querySelector('[data-id="cto"]');
			if(radioButtonToChecked){
				this.selectedOption = 'CTO';
				radioButtonToChecked.checked = true;
				this.durationValueInitial = '60';
				this.durationValue = 60;
				this.showOffice = false;
			}
		} else if(this.typeevent === 'CTF'){
			const radioButtonToChecked = this.template.querySelector('[data-id="ctf"]');
			if(radioButtonToChecked){
				this.selectedOption = 'CTF';
				radioButtonToChecked.checked = true;
				this.durationValueInitial = '30';
				this.durationValue = 30;
				this.showOffice = false;
			}
		} else if(this.typeevent === 'VLD'){
			const radioButtonToChecked = this.template.querySelector('[data-id="vld"]');
			if(radioButtonToChecked){
				this.selectedOption = 'VLD';
				radioButtonToChecked.checked = true;
				this.durationValueInitial = '30';
				this.durationValue = 30;
				this.showOffice = false;
			}
		} else if(this.typeevent === 'CTOOC'){
			const radioButtonToChecked = this.template.querySelector('[data-id="ctooc"]');
			if(radioButtonToChecked){
				this.selectedOption = 'CTOOC';
				radioButtonToChecked.checked = true;
				this.durationValueInitial = '60';
				this.durationValue = 60;
				this.showOffice = true;
			}
		} else if(this.typeevent === '001'){
			const radioButtonToChecked = this.template.querySelector('[data-id="001"]');
			if(radioButtonToChecked){
				this.selectedOption = '001';
				radioButtonToChecked.checked = true;
				this.durationValueInitial = '60';
				this.durationValue = 60;
				this.showOffice = false;
				this.showLocation = true;
			}
		}
		this.sendDataToReport();
	}

	handleComment(e) {
 		this.commentary=e.target.value;
		this.sendDataToReport();
	}

	handleMemorableInterview(e){
		this.memorableInterview = e.target.checked;
		this.sendDataToReport();
	}

	handleChangeDuration(e){
		this.durationValue = parseInt(e.target.value);
		this.sendDataToReport();
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
		this.sendDataToReport();
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

		} else if(this.selectedOption === 'CTO'){
            this.durationValueInitial = '60';
            this.durationValue = 60;
            this.showOffice = false;
            this.showLocation = false;
            this.location = null;
			this.officeNumberCompany= null;
        } else if(this.selectedOption === 'CTF'){
            this.durationValueInitial = '30';
            this.durationValue = 30;
            this.showOffice = false;
            this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
        } else if(this.selectedOption === 'VLD'){
            this.durationValueInitial = '30';
            this.durationValue = 30;
            this.showOffice = false;
            this.showLocation = false;
            this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
        } else if(this.selectedOption === 'CTOOC'){
            this.durationValueInitial = '60';
            this.durationValue = 60;
            this.showLocation = false;
            this.showOffice = event.target.value;
			this.location = null;
			this.officeNumberCompany= null;
        } else if(this.selectedOption === '001'){
            this.durationValueInitial = '60';
			this.durationValue = 60;
			this.showOffice = false;
			this.showLocation = event.target.value;
			this.location = null;
			this.officeNumberCompany= null;
        }
		this.sendDataToReport();
    }


	handleDateChange(event){
		this.now = event.target.value;
		this.sendDataToReport();
	}

	handleTimeChange(event){
		this.activityTime = event.target.value;
		this.sendDataToReport();
	}

	handleChangeLocation(event){
		this.location = event.target.value;
		this.sendDataToReport();
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
					this.sendDataToReport();
				}
			} else {
				this.officeNumberCompany = null;
				this.template.querySelector(`[data-id="${targetId}"]`).handleBlur();
				this.sendDataToReport();
			}
		} else if (targetId == 'clookup6') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.contactPerson = sel.id;
					this.sendDataToReport();
				}
			} else {
				this.contactPerson = null;
				this.find='';
				this.template.querySelector(`[data-id="${targetId}"]`).handleBlur();
				this.sendDataToReport();
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

	
	notifyUser(title, message, variant) {
		if (this.notifyViaAlerts) {
			alert(`${title}\n${message}`);
		} else {
			const toastEvent = new ShowToastEvent({ title, message, variant });
			this.dispatchEvent(toastEvent);
		}
	}

	sendDataToReport(){	
		this.dispatchEvent(
			new CustomEvent('setinfo',
			{
				detail:{ 
					id: this.idevent,
					type: this.selectedOption,
					duracion: this.durationValue,
					activityDateTime: this.now,
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
		
}