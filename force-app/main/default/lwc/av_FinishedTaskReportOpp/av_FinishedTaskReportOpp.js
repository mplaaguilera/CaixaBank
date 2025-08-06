import { LightningElement, api,track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getRecordType            from '@salesforce/apex/AV_TabManagementTask_Controller.getRecordType';
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';
import getAccountRTCliente            from '@salesforce/apex/AV_TabManagementTask_Controller.acccountCliente';
import lookupSearchContact            from '@salesforce/apex/AV_TabManagementTask_Controller.getContact';
import lookupSearch from '@salesforce/apex/AV_MassReassignOwner_Controller.searchUser';
import lookupSearchAccount from '@salesforce/apex/AV_MassReassignOwner_Controller.searchAccount';
import getIsIntouch            from '@salesforce/apex/AV_TabManagementTask_Controller.getIsIntouch';
import getPickList            from '@salesforce/apex/AV_TabManagementTask_Controller.getPickListValuesByRecordTypeId';


import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import USER_EXTERNAL_ID from '@salesforce/schema/User.AV_ExternalID__c';


export default class Av_FinishedTaskReportOpp extends LightningElement {
    @api recordId;
	@track fecha;
	@track error;
    @track recordType;
    @track showState = false;
	@track showSpinner = false;
	@track optionsTipo;
    @track iconName;
    @api taskId;
	@track valueCliente;
	@track valueContact;
	@track valueEmpleado;
	@track rtClienteAccount=false;
	//Estos no tenian track
    @track initialSelection = [];
    @track initialSelection2 = [];
	@track initialSelection3 = [];
	@track errors = [];
    @track clientPlaceholder = 'Buscar cliente...';
    @track employeePlaceholder = 'Buscar empleado...';
    //
	@track isMultiEntry = false;
	@track find = '';
	@track formattedFechaGestion;
    valueTipo = 'LMD';
	@track optionsTaskType;



	@wire(getRecord,{recordId:Id,fields:[USER_EXTERNAL_ID]})
	wiredUser({error,data}){
		if(data){
			this.userExternalId = data.fields.AV_ExternalID__c.value;
			this.getIsIntouchEmployee();
			
		}else if(error){
			console.log(error);
		}
	}

	getIsIntouchEmployee() {
		getIsIntouch({userExternalId: this.userExternalId}) 
			.then((results) => {
				var isIntouch = results;
				if(isIntouch){
					this.valueTipo = 'CTF';
				}else{
					this.valueTipo = 'LMD';
				}
			})
			.catch((error) => {
				console.log('Display ShowToastEvent error (catch): ', error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
			});
	}


    handleLookupTypeChange(event) {
		this.initialSelection = [];
        this.initialSelection2 = [];
		this.initialSelection3 = [];
		this.errors = [];
		this.isMultiEntry = event.target.checked;
	}

    handleSearchAccount(event) {
		lookupSearchAccount(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup1"]').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				// eslint-disable-next-line no-console
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}
    handleSearch(event) {
		lookupSearch(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup2"]').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				// eslint-disable-next-line no-console
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearchContact(event) {
		this.find = event.detail.searchTerm;
		lookupSearchContact({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, accountId: this.valueCliente})
			.then((results) => {
				this.template.querySelector('[data-id="clookup3"]').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				// eslint-disable-next-line no-console
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearchContactClick(event) {
		if (this.find == '' && this.valueContact == null) {
			lookupSearchContact({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, accountId: this.valueCliente})
			.then((results) => {
				this.template.querySelector('[data-id="clookup3"]').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
		}
		
	}

    handleSelectionChange(event) {
		this.checkForErrors(event);
	}



    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
      }

    handleClear() {
		this.initialSelection = [];
        this.initialSelection2 = [];
		this.initialSelection3 = [];
		this.errors = [];
	}

    checkForErrors(event) {
		this.errors = [];
		let targetId = event.target.dataset.id;
		if (targetId==='clookup1') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.valueCliente  = String(sel.id);
					this.getAccountCliente(this.valueCliente);
				}
			} else {
				this.valueCliente = null;
			}
		} else if (targetId==='clookup2'){
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.valueEmpleado  = String(sel.id);
				}
			} else {
				this.valueEmpleado = null;
			}
		} else if (targetId==='clookup3'){
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.valueContact  = String(sel.id);
				}
			} else {
				this.find = '';
				this.valueContact = null;
				this.template.querySelector('[data-id="clookup3"]').handleBlur();
			}
		}
	}

	// get optionsTaskType() {
	// 	return [
	// 		{ label: 'Cita en la oficina', value: 'CTO' },
	// 		{ label: 'Cita telefónica', value: 'CTF' },
	// 		{ label: 'Videollamada', value: 'VLD' },
	// 		{ label: 'Visita del gestor', value: '001' },
	// 		{ label: 'Llamada', value: 'LMD' },
	// 		{ label: 'Email,sms,etc', value: 'ESE' },
	// 		{ label: 'Muro', value: '030' }
	// 	];
	// }
	
	getPickListType() {
		getPickList({objectName: 'Task', recordId: this.recordId, fieldApiName: 'AV_Tipo__c', picklistDevName: 'AV_TaskTipoOtros'})
			.then(result => {
				this.optionsTaskType = result;
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
			});
	}

	handleChangeType(event) {
		this.valueTipo = event.detail.value;
        this.sendData();
	}
    handleChangeComentario(event) {
		this.valueComentario = event.detail.value;
        this.sendData();
	}

    handleChangeAsunto(event) {
		this.valueAsunto = event.detail.value;
        this.sendData();
	}

    //cambio fecha
	handleChangeDate(event) {
		this.valueFecha = event.target.value;
        this.sendData();
	}
    

    connectedCallback() {
		this.initialSelection=[{id: this.taskId.WhatId, icon:'standard:account', title: this.taskId.What.Name}];
		this.valueCliente = this.initialSelection[0].id;
		this.getAccountCliente(this.taskId.WhatId);
		this.getPickListType();
		this.initialSelection2=[{id: this.taskId.OwnerId, icon:'standard:user', title: this.taskId.Owner.Name}];
		this.initialSelection3=[];
		this.valueFecha=(new Date()).toISOString().substring(0,10);
		// this.valueFecha=today.toISOString().substring(0,10);
        this.valueAsunto = this.taskId.Subject;
        this.recordId = this.taskId.Id;
		this.getRecordType();
		this.formattedFechaGestion = this.formatFechaGestion(this.valueFecha);
	}

	getAccountCliente(acc) {
		getAccountRTCliente({accountId:acc})
			.then((results) => {
				this.rtClienteAccount = results;
				this.valueContact = null;
				this.initialSelection3 = [];
			})
			.catch((error) => {
				console.log('Display ShowToastEvent error (catch): ', error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
			});
	}

    sendData() {
		this.dispatchEvent(new CustomEvent('getData', {
			detail: {
                id: this.taskId.Id,
				asunto: this.valueAsunto,
				tipo: this.valueTipo,
                fecha: this.valueFecha,
                comentario: this.valueComentario,
                empleado: this.valueEmpleado,
                cliente: this.valueCliente,
				estado: this.taskId.Status,
				contacto: this.valueContact,
				rtAccCliente: this.rtClienteAccount
			}
		}));
	}

	@api
	fetchData() {
		return ({
            id: this.taskId.Id,
			asunto: this.valueAsunto,
            tipo: this.valueTipo,
            fecha: this.valueFecha,
            comentario: this.valueComentario,
            empleado: this.valueEmpleado,
            cliente: this.valueCliente,
			estado: this.taskId.Status,
			contacto: this.valueContact,
			rtAccCliente: this.rtClienteAccount
		})

	}

    getRecordType() {
        getRecordType({id: this.recordId})
            .then(recordType => {
                if ('AV_ExperienciaCliente' == recordType ||
                'AV_Onboarding' == recordType ||
                'AV_MorosidadNormativa' == recordType) {
                    this.showState = true;
                }
            })
            .catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
                this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            });
	}

	disableSpinner() {
        this.showSpinner = false;
    }

    enableSpinner() {
        this.showSpinner = true;
    }

	/**
	 * @description		Takes yyyy-mm-dd date and transforms it into dd/mm/yyyy date
	 * @param date 		Date (yyyy-mm-dd)
	 * @returns 		Date (dd/mm/yyyy)
	 */
	formatFechaGestion(date) {
		if (date != null) {
			return date.split("-").reverse().join("/");
		}
		return null
	}
}