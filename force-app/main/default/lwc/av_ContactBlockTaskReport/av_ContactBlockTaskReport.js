import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import lookupSearchOffice from '@salesforce/apex/AV_TaskReport_Controller.searchOffice';
import lookupSearchContact from '@salesforce/apex/AV_TaskReport_Controller.searchContact';
import isbpr from '@salesforce/customPermission/AV_PrivateBanking';
export default class Av_ContactBlockTaskReport extends LightningElement {

    @api islegalentity;
	@api isintouch;
	@api accountid;
	@api recordid;
	@api recordtype;
	commentary;
	showComentary = false;
	showOffice = false;
	showLocation = false;
	location;
	@track showContactPerson = false;
	radioButtonSelected = false;
	activityDateTime = new Date(Date.now()).toISOString();
	durationValueInitial;
	memorableInterview = false;
	isMultiEntry2 = false;
	find = '';
	statusValue = 'Gestionada positiva';
	initialSelection = [];
	initialSelectionOffice = [];
	officePlaceholder = 'Buscar oficina...';
	contactPlaceholder = 'Buscar contacto...';
	officeNumberCompany = null;
	contactPerson = null;
	firstRender = true;
    isbpr=isbpr;
	selectedTab = 'tabEvent';
	tabselected;
	comentaryTask;
	
	@api get checkboxStatus(){
		return this.showComentary;
	}

	@api
	switchCitaCheckBox(value){
		this.template.querySelector("[data-id='citanocomercialcb']").checked = value;

	}
	

    get optionsDuration(){
		return [
			{label:'5 min',value:'5'},
			{label:'30 min',value:'30'},
			{label:'1 h',value:'60'}
		]
	}
    get optionsStatus(){
		return [
			{label:'Gestionada positiva',value:'Gestionada positiva'},
			{label:'Gestionada negativa',value:'Gestionada negativa'}
		]
	}
	
	connectedCallback(){
		this.durationValueInitial = (this.isintouch) ? '30' : '5';
		this.durationValue = (this.isintouch) ? 30 : 5;
		this.selectedOption = (this.isintouch) ? 'CTF' : 'LMD';
	}
	handleChangeComentary(e){
		this.comentaryTask = e.detail.value;
		this.sendDataToReport();
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

	handleComment(e) {
 		this.commentary=e.target.value;
		this.sendDataToReport();
	}

	handleMemorableInterview(e){
		this.memorableInterview = e.target.checked;
		this.sendDataToReport();
	}

    handleChangeStatus(e) {
		this.statusValue = e.target.value;
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
			this.statusValue = 'Gestionada positiva';
		}else if(this.selectedOption === 'CTO'){
			this.durationValueInitial = '60';
			this.durationValue = 60;
			this.showOffice = false;
			this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
			this.statusValue = 'Gestionada positiva';	
		}else if(this.selectedOption === 'CTF'){
			this.durationValueInitial = '30' ;
			this.durationValue = 30 ;
			this.showOffice = false;
			this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
			this.statusValue = 'Gestionada positiva';
			
		}else if(this.selectedOption === 'VLD'){
			this.durationValueInitial = '30' ;
			this.durationValue = 30 ;
			this.showOffice = false;
			this.showLocation = false;
			this.location = null;
			this.officeNumberCompany= null;
			this.statusValue = 'Gestionada positiva';
			

		}else if(this.selectedOption === 'CTOOC'){
			this.durationValueInitial = '60';
			this.durationValue = 60;
			this.showLocation = false;
			this.showOffice = true;
			this.location = null;
			this.officeNumberCompany= null;
			this.statusValue = 'Gestionada positiva';
			
		}else if(this.selectedOption === '001'){
			this.durationValueInitial = '60';
			this.durationValue = 60;
			this.showOffice = false;
			this.showLocation = true;
			this.location = null;
			this.officeNumberCompany= null;
			this.statusValue = 'Gestionada positiva';

		}
		this.sendDataToReport();
	}

	handleOptionChangeTask(event){
		this.selectedOptionTask = event.target.value;
		if (this.selectedOptionTask === '030' || this.selectedOptionTask === 'ESE' || this.selectedOptionTask === 'OFT') {
			this.radioButtonSelected = true;
		} else {
			this.radioButtonSelected = false;
		}
		const radioButtonSelectedTask = new CustomEvent('radiobuttonselected',{
			detail: {radioButtonSelected: this.radioButtonSelected}
		});
		this.dispatchEvent(radioButtonSelectedTask);
		this.sendDataToReport();
	}

	handleDateChange(event){
		this.activityDateTime = event.target.value;
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

	handleTabActive(event){
		this.selectedTab = event.target.value;
		this.sendDataToReport();
		
	}
	
	notifyUser(title, message, variant) {
		if (this.notifyViaAlerts) {
			alert(`${title}\n${message}`);
		} else {
			const toastEvent = new ShowToastEvent({ title, message, variant });
			this.dispatchEvent(toastEvent);
		}
	}

	sendDataToReport() {
		if (this.selectedTab == 'tabEvent') {
			this.dispatchEvent(
				new CustomEvent('changeclient',
				{
					detail:{ 
						eventClosed: {
							type: 'event',
							tab: this.selectedTab,
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
						},
						taskClosed: {
							type: 'task',
							tab: this.selectedTab,
							idTask: this.recordid,
							typeTask: null,
							accountId: this.accountid,
							statusTask: this.statusValue,
							recordType: this.recordtype,
							comentaryTask: this.comentaryTask
						}
					}
				})
			);
		} else {
			this.dispatchEvent(
				new CustomEvent('changeclient',
				{
					detail:{ 
						eventClosed: {},
						taskClosed: {
							type: 'task',
							tab: this.selectedTab,
							idTask: this.recordid,
							typeTask: this.selectedOptionTask,
							accountId: this.accountid,
							statusTask: this.statusValue,
							recordType: this.recordtype,
							comentaryTask: this.comentaryTask
						}
					}
				})
			);
		}
	}

	
}