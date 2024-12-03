import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent }   			from 'lightning/platformShowToastEvent';
import updateOffice         			from '@salesforce/apex/AV_OfficeUtility_Controller.updateUserOffice';
import getOriginal          			from '@salesforce/apex/AV_OfficeUtility_Controller.getOriginalOffice';
import getCurrent           			from '@salesforce/apex/AV_OfficeUtility_Controller.getCurrentOffice';
import checkSession         			from '@salesforce/apex/AV_OfficeUtility_Controller.isNewSession';
import getOfficesGivenByPemission		from '@salesforce/apex/AV_OfficeUtility_Controller.getAllOffices';
import USER_ID 							from '@salesforce/user/Id';

import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import datosRegistro from '@salesforce/apex/CC_Busqueda_ALF_Controller.datosRegistro';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import FUNCION from '@salesforce/schema/User.AV_Funcion__c';
import NAME from '@salesforce/schema/User.Name';
import ORIGINALNUMBER from '@salesforce/schema/User.AV_OriginalOfficeNumber__c';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const FIELDS = ['User.AV_OriginalOfficeNumber__c'];

export default class Av_ChangeOffice extends LightningElement {
	
	@api recordId;
	@track officeList = [];
	@track officeListCopy = [];
	@track filteredOfficeList = [];
	@track filteredOfficePermList = [];
	@track showSpinner = false;
	@track current = false;
	@track originalOffice;
	@track currentOffice;
	@track previousOfficeAux;
	@track officesPermited = [];
	@track officesPermitedCopy = [];
	@track officesPermitedMatrix = []
	@track empleOfi;
	@track empleFuncion;
	@track empleOriginalNumber;
	@track empleName;

	@wire(getRecord, {recordId:USER_ID,fields:[OFICINA,FUNCION,ORIGINALNUMBER,NAME]})
    wiredUser({error,data}){
        if(data){
            this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value;
			this.empleFuncion = data.fields.AV_Funcion__c.value;
			this.empleOriginalNumber = data.fields.AV_OriginalOfficeNumber__c.value;
			this.empleName = data.fields.Name.value;
			this.checkUserSession();
        }else if (error){
			console.log(error);
        }
    }

	connectedCallback() {
	}

	checkUserSession() {
		checkSession()
			.then(result => {
				this.getOffices();
				if (result === true) {
					this.dispatchEvent(new CustomEvent('refresh'));
				}
			})
			.catch(error => {
				console.log(error);
			})
	}

	@api
	getOffices() {
		if(this.empleOfi != null){
		this.enableSpinner();
			let userInfo = 
							{
								Id:USER_ID,
								Name:this.empleName,
								Funcion:this.empleFuncion,
								NumeroOficina:this.empleOfi,
								OriginalNumber:this.empleOriginalNumber,
								IsMainUser:'true'
						};
			this.officesPermitedMatrix = [];
			this.officeList = [];
			this.officeListCopy = [];
			getOfficesGivenByPemission({userMap:userInfo})
			.then(offices => {
				offices.forEach(ofi => {
					if(ofi.isMain){
						this.officeList = ofi.officesList;
						this.officeListCopy  = ofi.officesList;
						this.highlightCurrentAndOldOffices();
					}else{
						let oficeListToDisplay = [];
						ofi.officesList.forEach(oficina =>{
							if(oficina.numOficinaEmpresa != this.empleOfi){
								oficeListToDisplay.push(oficina)
							}
						})
						this.officesPermitedMatrix.push({id:ofi.id,name:'Cedido por '+ ofi.name,offSet:oficeListToDisplay});	
					}
				})
				this.disableSpinner();
			}).catch(error => {
				console.log(error);
				this.disableSpinner();
			})
		}

							
				}
				
	updateSelfUserOffice(event){
		this.updateUserOffice(event.currentTarget.dataset.id);
	}

	highlightCurrentAndOldOffices() {
		const highlightOffices = () => new Promise(async (resolve, reject) => {
				if (this.originalOffice == null || typeof this.originalOffice == 'undefined') {
					this.originalOffice = await getOriginal();
				}
				if (this.currentOffice == null || typeof this.currentOffice == 'undefined') {
					this.currentOffice = await getCurrent();
				}
				for (let i = 0; i < this.officeList.length; i++) {
					if (this.officeList[i].numOficinaEmpresa.toUpperCase().includes(this.originalOffice)) {
						setTimeout(() => {
							this.template.querySelector(`[data-id=\"` + this.officeList[i].numOficinaEmpresa + `\"] > div > lightning-tile > div:last-child > div > slot > p`).innerHTML = 'Oficina original';
						}, 10);
						continue;
					}
					if (this.officeList[i].numOficinaEmpresa.toUpperCase().includes(this.previousOfficeAux)) {
						setTimeout(() => {
							this.template.querySelector(`[data-id=\"` + this.officeList[i].numOficinaEmpresa + `\"] > div > lightning-tile > div:last-child > div > slot > p`).innerHTML = '';
						}, 10);
					}
					if (this.officeList[i].numOficinaEmpresa.toUpperCase().includes(this.currentOffice)) {
						setTimeout(() => {
							this.template.querySelector(`[data-id=\"` + this.officeList[i].numOficinaEmpresa + `\"] > div > lightning-tile > div:last-child > div > slot > p`).innerHTML = 'Asignada actualmente';
						}, 10);
					}
				}
			
			resolve(this.currentOffice);
		})
		const launchPromiseHighlight = async() => {
			// Launch promise and wait for it to finish
			await highlightOffices();
		}
		launchPromiseHighlight();
	}

	getCurrentOffice() {
		getCurrent()
			.then(result => {
				if (result) {
					this.currentOffice = result;
					return result;
				}
			})
			.catch(error => {
				console.log(error);
			})
	}

	getOriginalOffice() {
		getOriginal()
			.then(result => {
				if (result) {
					this.originalOffice = result;
					return result;
				}
			})
			.catch(error => {
				console.log(error);
			})
	}

	updateUserOffice(numOffi) {
		let selectedOffice = numOffi;
		this.previousOfficeAux = this.currentOffice;
		if(!this.empleOfi.includes(numOffi)){
			this.enableSpinner();
			updateOffice({newOffice: selectedOffice})
			.then(result => {
				if (result != 'KO') {
					this.currentOffice = selectedOffice;
					this.empleOfi = numOffi;
					this.empleOriginalNumber = result;
					this.showToast('Operación correcta', 'Se ha actualizado la oficina correctamente', 'success', 'pester');
				} else {
					this.showToast('Error', 'No se pudo asignar la oficina', 'error', 'pester');
				}

				this.dispatchEvent(new CustomEvent('refresh'));
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error', 'pester');
				this.disableSpinner();
			})
		}
	}

	handleSearch(event) {
		this.filteredOfficeList = [];
		this.filteredOfficePermList = [];
		if (this.officeListCopy != null) {
			for (let i = 0; i < this.officeListCopy.length; i++) {
				if (this.officeListCopy[i].name.toUpperCase().includes(event.target.value.toUpperCase()) || event.target.value == '*') {
					this.filteredOfficeList.push(this.officeListCopy[i]);
				}
			}
			for (let i = 0; i < this.officesPermitedCopy.length; i++) {
				if (this.officesPermitedCopy[i].name.toUpperCase().includes(event.target.value.toUpperCase()) || event.target.value == '*') {
					this.filteredOfficePermList.push(this.officesPermitedCopy[i]);
				}
			}
			//this.filteredOfficeList = this.searchInOfficeList(searchTerm);
			if (this.filteredOfficeList != []) {
				this.officeList = this.filteredOfficeList;
				// this.officesPermited = this.filteredOfficePermList;
				this.highlightCurrentAndOldOffices();
			}
			
			if (this.filteredOfficePermList != []) {
				this.officesPermited = this.filteredOfficePermList;
			}

		}
	}

	showToast(title, message, variant, mode) {
		this.dispatchEvent(new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		}));
	}

	disableSpinner() {
		this.showSpinner = false;
	}

	enableSpinner() {
		this.showSpinner = true;
	}
}