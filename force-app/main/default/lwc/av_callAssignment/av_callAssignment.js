import { LightningElement,api,wire,track} from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { NavigationMixin }      from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import updateCall from '@salesforce/apex/AV_CallAssignment_Controller.updateCall';
import getAccount from '@salesforce/apex/RainbowConnector.getAccountsByPhoneNumber';


export default class av_callAssignment extends NavigationMixin(LightningElement) {

	currentPageReference;
	phoneFormat;
	@track accounts = [];
	@track accountId;
	@track isMissed = false;
	@track callId;
	selectedAccountId;

	showSpinner = true;
	loadedData = false;

	// Button
	disableButtonCancel = false;
	disableButtonSave = true;
	disableButtonSaveAndReport = true;

    // Opciones de los botones de radio
    options = [];
	buttonName;

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
		this.isMissed = this.currentPageReference?.state?.c__isMissed;
		this.phoneFormat = '+34' + this.currentPageReference?.state?.c__callPhone;
		this.callId = this.currentPageReference?.state?.c__callId;
		this.getAccount(this.phoneFormat, this.currentPageReference?.state?.c__callTipo);
	}

	getAccount(phone, tipo){
		getAccount({phoneNumber:phone, direction:tipo })
		.then(result =>{
				if(result != null){
					this.accounts = JSON.parse(result);
					this.options = this.accounts.map(account => ({
						
						label: account.Name.split('/')[0].trim(),
						value: account.Id,
						eapGestor: 'Empleado: ' + (account.AV_EAPGestor__r && account.AV_EAPGestor__r.Name ? account.AV_EAPGestor__r.Name : 'Sin gestor')
					}));

					this.showSpinner = false;
					this.loadedData = true;
				}
			}).catch(error => {
				console.error(error);
				this.showSpinner = false;
			})
	}

	updateCall(callId, accountId, buttonName){

		if(callId.includes('/')){
			callId = callId.replace('/','');
		}
		updateCall({ callId : callId, accountId: accountId})
		.then(result =>{
				if(result){
					this.showSpinner = false;
					this.loadedData = true;
					this.showToast('Éxito', 'El cliente ha sido asignado correctamente', 'success');
					this.closeTabAndRedirect(buttonName);
				}
			}).catch(error => {
				this.showToast('Error', 'No se ha podido asignar el cliente a la llamada', 'error');
                this.closeTabAndRedirect(buttonName);
				console.error(error);
			})
	}

	
	navegateToAccount(e) {
		let accountId = e.target.getAttribute('data-account');
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Account',
				recordId: accountId,
				actionName:'view'
			}
		})
	}

	handleRadioChange(event){
		this.selectedAccountId = event.target.value;
		if(this.selectedAccountId != null){
			this.disableButtonSave = false;
			this.disableButtonSaveAndReport = false;
		}

	}

	handleSave(e) {
		this.buttonName = e.target.name;
        this.updateCall(this.callId, this.selectedAccountId, this.buttonName);
		
    }

	handleSaveReport(e){
		this.buttonName = e.target.name;
		this.updateCall(this.callId, this.selectedAccountId, this.buttonName);

	}

	handleCancel(){
		
		this.dispatchEvent(new CustomEvent('closetab'));
		const newUrl = '/lightning/page/home'
		this[NavigationMixin.Navigate](
			{
				type: "standard__webPage",
				attributes: {
					url: newUrl
				},
			},
			false, // No Replaces the current page in the browser history with the URL
		);
	}

	closeTabAndRedirect(buttonName) {
        this.dispatchEvent(new CustomEvent('closetab'));
		if (buttonName === 'save'){
			this[NavigationMixin.Navigate]({
				type : 'standard__namedPage',
				attributes: {
					pageName: 'home'
				},
				state: {
					c__id: true
				}
			});
		}

		if (buttonName === 'saveAndReport'){
			this[NavigationMixin.Navigate]({
				type: 'standard__navItemPage',
				attributes: {
					apiName: 'AV_Reporte_de_llamada'
				},
				state: {
					c__callId: this.callId
				}
			});
		}
    }

	hideFlowAction(e){
		this.isShowFlowAction = false;
	}

	showToast(title, message, variant, mode) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}
}