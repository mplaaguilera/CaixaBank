import { LightningElement, api,track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getRecordType            from '@salesforce/apex/AV_TabManagementTask_Controller.getRecordType';
import lookupSearchContact            from '@salesforce/apex/AV_TabManagementTask_Controller.getContact';
import getAccountRTCliente           from '@salesforce/apex/AV_TabManagementTask_Controller.acccountCliente';
import getContactTask            from '@salesforce/apex/AV_TabManagementTask_Controller.getContactTask';
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';
import getPickList            from '@salesforce/apex/AV_TabManagementTask_Controller.getPickListValuesByRecordTypeId';
import getIsIntouch            from '@salesforce/apex/AV_TabManagementTask_Controller.getIsIntouch';


import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import USER_EXTERNAL_ID from '@salesforce/schema/User.AV_ExternalID__c';


import AV_CTF_Type from '@salesforce/label/c.AV_CallMeet';
import AV_VDO_Type from '@salesforce/label/c.AV_Videocall';
import AV_001_Type from '@salesforce/label/c.AV_GestorVisit';
import AV_LMD_Type from '@salesforce/label/c.AV_RegularCall';
import AV_CTO_Type from '@salesforce/label/c.AV_OfficeMeeting';



export default class Av_FinishedTask extends LightningElement {
	@api recordId;
	@track fecha;
	@track error;
	@track recordType;
	@track showState = false;
	@track showSpinner = false;
	@track optionsTipo;
	@track comment;
	@track initialSelection = [];
	@track errors = [];
	@track valueContact;
	@track accountId;
	@track rtClienteAccount = false;
	@track nowReference = new Date(Date.now()).toISOString();
	@track now = this.nowReference;
	//picklist tipo
	@track valueTipo = 'LMD';
	@track tipoEvento = false;
	@track activityDateTime = this.now;
	@track find = '';
	@track inputControlValue;
	@track formattedFechaGestion;
	//2020-09-12T18:13:41Z//
	userExternalId;
	
	@track eventRelatedTypes = [
		AV_CTF_Type,
		AV_VDO_Type,
		AV_001_Type,
		AV_LMD_Type,
		AV_CTO_Type];
		@track eventRelatedBox = (this.eventRelatedTypes.includes(this.valueTipo))
		
		handleChangeTipo(event) {
		this.valueTipo = event.detail.value;
		this.eventRelatedBox = (this.eventRelatedTypes.includes(this.valueTipo))
		this.sendData();
	}


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
	
	
	//picklist estado
	@track valueEstado = 'Gestionada positiva';
	//
	get optionsEstado() {
		return [
			{ label: 'Gestionada negativa', value: 'Gestionada negativa' },
			{ label: 'Gestionada positiva', value: 'Gestionada positiva' }
		];
	}
	handleChangeEstado(event) {
		this.valueEstado = event.detail.value;
		this.sendData();
	}

	getContactoTarea() {
		getContactTask({idRecords: this.recordId})
			.then((results) => {
				if (results!= null) {
					if (results.WhoId != null) {
						this.initialSelection=[{id: results.WhoId, icon:'standard:contact', title: results.Who.Name}];
						this.valueContact = results.WhoId;
					}
					if(results.WhatId != null){
						this.valueCliente = results.WhatId;
					}
					this.accountId = results.AccountId;
					this.getAccountCliente(this.accountId);
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

	getAccountCliente(acc) {
		getAccountRTCliente({accountId:acc})
			.then((results) => {
				this.rtClienteAccount = results;
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

	handleSearchContact(event) {
		this.find = event.detail.searchTerm;
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

	handleSearchContactClick(event) {
		if (this.find == '' && this.valueContact == null) {
			lookupSearchContact({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, accountId: this.valueCliente})
			.then((results) => {
				this.template.querySelector('[data-id="clookup3"]').setSearchResults(results);
			})
			.catch((error) => {
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
		}
	}

	handleSelectionChange(event) {
		this.checkForErrors(event);
	}

	checkForErrors(event) {
		this.errors = [];
		let targetId = event.target.dataset.id;
		if (targetId==='clookup3'){
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

	//cambio fecha
	handleChangeDate(event) {
		this.fecha = event.target.value;
		this.formattedFechaGestion = this.formatFechaGestion(this.fecha);
		this.sendData();
	}
	handleChangeComment(event) {
		this.comment = event.target.value;
		this.sendData();
	}

	connectedCallback() {
		this.fecha=(new Date()).toISOString().substring(0,10);
		this.recordId;
		this.getRecordType();
		this.getPickListType();
		this.getContactoTarea();
		this.formattedFechaGestion = this.formatFechaGestion(this.fecha);
	}

	sendData() {
		this.dispatchEvent(new CustomEvent('getData', {
			detail: {
				estado: this.valueEstado,
				tipo: this.valueTipo,
				fecha: this.fecha,
				comentario:this.comment,
				contacto: this.valueContact,
				rtAccCliente:this.rtClienteAccount
			}
		}));
	}

	@api
	fetchData() {
		return ({
			estado: this.valueEstado,
			tipo: this.valueTipo,
			fecha: this.fecha,
			comentario:this.comment,
			contacto: this.valueContact,
			rtAccCliente: this.rtClienteAccount,
			activityDateTime:this.activityDateTime
		})

	}

	getPickListType() {
		getPickList({objectName: 'Task', recordId: this.recordId, fieldApiName: 'AV_Tipo__c', picklistDevName: 'AV_TaskTipoOtros'})
			.then(result => {
				this.optionsTipo = result;
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
			// let dateArr = date.split("-");
			return date.split("-").reverse().join("/");
		}
		return null;
	}

	getOldValue(event){
		this.inputControlValue = event.target.value;
	}

	handleEventRelatedDateTime(event){
		if( (new Date(event.target.value).getTime()) < (new Date(Date.now()))){
			this.activityDateTime = event.target.value;
		}else{
			this.template.querySelector('[data-id="dtInput"]').value= this.inputControlValue;
			this.dispatchEvent(
				new ShowToastEvent({
					title: AV_CMP_ErrorMessage,
					message: 'No se puede poner una fecha a futuro',
					variant: 'error'
				})
			);
		}
	}
}