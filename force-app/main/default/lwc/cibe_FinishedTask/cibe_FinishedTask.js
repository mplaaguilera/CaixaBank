import { LightningElement, api,track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getRecordType            from '@salesforce/apex/CIBE_TabManagementTask_Controller.getRecordType';
import lookupSearchContact      from '@salesforce/apex/CIBE_UtilitiesWOS.getContact';
import getAccountRTCliente      from '@salesforce/apex/CIBE_TabManagementTask_Controller.acccountCliente';
import getContactTask           from '@salesforce/apex/CIBE_TabManagementTask_Controller.getContactTask';
import CIBE_CMP_ErrorMessage 	from '@salesforce/label/c.CIBE_CMP_ErrorMessage';
import getPickList              from '@salesforce/apex/CIBE_TabManagementTask_Controller.getPickListValuesByRecordTypeId2';
import roleEmp             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleEMP';
import roleCib             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleCIB';


//Labels
import tareaFinalizada from '@salesforce/label/c.CIBE_TareaFinalizada';
import tipo from '@salesforce/label/c.CIBE_Tipo';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import fechaGestion from '@salesforce/label/c.CIBE_FechaGestion';
import estado from '@salesforce/label/c.CIBE_Estado';
import personaContacto from '@salesforce/label/c.CIBE_PersonadeContactoTask';
import gestionadaNegativa from '@salesforce/label/c.CIBE_GestionadaNegativa';
import gestionadaPositiva from '@salesforce/label/c.CIBE_GestionadaPositiva';
import buscarContacto from '@salesforce/label/c.CIBE_BuscarContacto';

export default class cibe_FinishedTask extends LightningElement {

	labels = {
        tareaFinalizada, 
        tipo, 
		comentario,
		fechaGestion,
		estado,
		personaContacto,
		gestionadaPositiva,
		gestionadaNegativa,
		buscarContacto
    };

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
	//picklist tipo
	formattedFechaGestion;
	@track valueTipo ;
	//role user
	@track roleEmpValue = null;
	@track roleCibValue = null;





	@wire(roleEmp)
	getRoleEmp({data, error}) {
        if(data) {
            this.roleEmpValue = data;
			this.valueTipo = this.roleEmpValue === true ? 'LMD' : '';

			console.log(this.valueTipo);
		} else if(error) {
			console.log(error);
		}
    }

	
	@wire(roleCib)
	getRoleCib({data, error}) {
        if(data) {
            this.roleEmpValue = data;
			this.valueTipo = this.roleEmpValue === true ? 'LT' : '';

			console.log(this.valueTipo);
		} else if(error) {
			console.log(error);
		}
    }

	

	handleChangeTipo(event) {
		this.valueTipo = event.detail.value;
		this.sendData();
	}

	//picklist estado
	//No tenía track antes de QC
	@track valueEstado = 'Gestionada positiva';

	get optionsEstado() {
		return [
			{ label: this.labels.gestionadaNegativa , value: 'Gestionada negativa' },
			{ label: this.labels.gestionadaPositiva, value: 'Gestionada positiva' }
		];
	}

	handleChangeEstado(event) {
		this.valueEstado = event.detail.value;
		this.sendData();
	}

	getContactoTarea() {
		getContactTask({idRecords: this.recordId})
			.then((results) => {
				console.log('result');
				console.log('results.WhoId'+results.WhoId);
				console.log('results.WhatId'+results.WhatId);

				if (results!= null) {
					if (results.WhoId != null) {
						this.initialSelection=[{id: results.WhoId, icon:'standard:contact', title: results.Who.Name}];
						this.valueContact = results.WhoId;
					}
					if (results.WhatId != null) {
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
						title: CIBE_CMP_ErrorMessage,
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
						title: CIBE_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
			});
	}

	handleSearchContact(event) {
		console.log('event.detail.searchTerm');
		console.log(event.detail.searchTerm);
		console.log('event.detail.selectedIds');
		console.log(event.detail.selectedIds);

		lookupSearchContact({searchTerm: event.detail.searchTerm, selectedIds: event.detail.selectedIds, accountId: this.valueCliente})
			.then((results) => {
				console.log('results');
				console.log(results);
				this.template.querySelector('[data-id="clookup3"]').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
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
				this.valueContact = null;
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
		console.log(this.valueTipo);
		this.getPickListType();
		this.getContactoTarea();
		this.formattedFechaGestion = this.formatFechaGestion(this.fecha);
	}

	sendData() {

		const sendData  = new CustomEvent('datareport', {
			detail: {
				estado: this.valueEstado,
				tipo: this.valueTipo,
				fecha: this.fecha,
				comentario:this.comment,
				contacto: this.valueContact,
				rtAccCliente:this.rtClienteAccount
			}
		});
		this.dispatchEvent(sendData);
		

	}

	@api
	fetchData() {
		console.log('@@@@' + this.valueTipo);
		return ({
			estado: this.valueEstado,
			tipo: this.valueTipo,
			fecha: this.fecha,
			comentario:this.comment,
			contacto: this.valueContact,
			rtAccCliente: this.rtClienteAccount
		})

	}
	

	getPickListType() {
		getPickList({objectName: 'Task', recordId: this.recordId, fieldApiName: 'AV_Tipo__c'})
		.then(result => {
			console.log(result);
			this.optionsTipo = result;
		})
		.catch(error => {
			console.log('Display ShowToastEvent error (catch): ', error);
			this.dispatchEvent(
				new ShowToastEvent({
					title: CIBE_CMP_ErrorMessage,
					message: JSON.stringify(error),
					variant: 'error'
				})
			);
		});

		
		
	}

	getRecordType() {
		getRecordType({id: this.recordId})
			.then(recordType => {
				if ('CIBE_ExperienciaClienteCIB' == recordType || 'CIBE_ExperienciaClienteEMP' == recordType || 'CIBE_OnboardingCIB' == recordType || 'CIBE_OnboardingEMP' == recordType || 'CIBE_AvisosEMP' == recordType || 'CIBE_AvisosCIB' == recordType) {
					this.showState = true;
				}
				this.recordType = recordType;
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: CIBE_CMP_ErrorMessage,
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
		return null;
	}
}