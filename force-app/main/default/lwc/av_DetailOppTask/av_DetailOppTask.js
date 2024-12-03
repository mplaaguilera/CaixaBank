import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

import updateMain from '@salesforce/apex/AV_DetailOppTask_Controller.updateMainRecord';
import unlinkOpp from '@salesforce/apex/AV_DetailOppTask_Controller.unlinkOpp';
import validateFields from '@salesforce/apex/AV_DetailOppTask_Controller.validateForbWords';

//Labels
import successLabel from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successMsgLabel from '@salesforce/label/c.AV_CMP_SaveMsgSuccess';
import errorMsgLabel from '@salesforce/label/c.AV_CMP_SaveMsgError';
import errorLabel from '@salesforce/label/c.AV_CMP_ErrorEvent';
import successUnlinkMsgLabel from '@salesforce/label/c.AV_CMP_SuccessUnlinkOpp';
import valueFieldLabel from '@salesforce/label/c.AV_ValueFieldOppTask';
import conceptFieldLabel from '@salesforce/label/c.AV_ConceptFieldOppTask';
import productFieldLabel from '@salesforce/label/c.AV_ProductFieldOppTask';
import recordtypeFieldLabel from '@salesforce/label/c.AV_RecordTypeFieldOppTask';
import modifyButtonLabel from '@salesforce/label/c.AV_CMP_Modify';
import cancelButtonLabel from '@salesforce/label/c.AV_CMP_Cancel';
import saveButtonLabel from '@salesforce/label/c.AV_CMP_Save';
import warningTitleLabel from '@salesforce/label/c.AV_CMP_WarningEvent';
import unlink from '@salesforce/label/c.AV_CMP_UnLink';
import makeMain from '@salesforce/label/c.AV_CMP_ConvertMain';
import unlinkLabel from '@salesforce/label/c.AV_UnlinkOpp_Error';
import mainLabel from '@salesforce/label/c.AV_Main_Error';
import getOppLink from '@salesforce/apex/AV_LinkOperativoController.getOppLinkPEA';

export default class Av_DetailOppTask extends NavigationMixin (LightningElement) {

	@api opptask;
	@api justOne;
	@api nameobject;
    @api idobject;
    @track listLinks;
	@track listLinksLabel;
    @track hasLinks = false;
	@track allStages = [];
	@track stage;
	@track isModalOpen = false;
	@track actionType;
	@track formFactorBrowser;
	@track formFactorMobile;
	@track incluir;
	peaOpp = 'AV_PEA__c';

	

    connectedCallback(){ 
		this.incluir=this.opptask.AV_IncludeInPrioritizingCustomers__c;
		this.getOppLinks();
	}

	get isBrowser() {
		if(FORM_FACTOR == 'Large'){
			this.formFactorBrowser = true;
		}else{
			this.formFactorBrowser = false;
		}

		return this.formFactorBrowser;
	  }

	showDetail = false;
	showFooter = false;

	label = {
		successLabel,
		successMsgLabel,
		errorMsgLabel,
		errorLabel,
		successUnlinkMsgLabel,
		valueFieldLabel,
		conceptFieldLabel,
		productFieldLabel,
		recordtypeFieldLabel,
		modifyButtonLabel,
		cancelButtonLabel,
		saveButtonLabel,
		unlink,
		makeMain
	};

	toggleShowOppTask() {
		if(this.showDetail === true){
			this.showDetail = false;
		}else{
			this.showDetail = true;
		}
	}

	handleEdit() {
		this.showFooter = true;
		if(this.showDetail === false) {
			this.showDetail = true;
		}
	}

	handleEditMain() {
		this.showFooter = true;
	}

	handleCancel() {
		this.showFooter = false;
		for(var item of this.template.querySelectorAll('c-av_-custom-path')) {
			item.resetSelection();
			item.updateCurrentStage(this.opptask.AV_Stage__c);
		}
		
	}

	handleSuccess() {

		this.showFooter = false;
		this.disableSpinner();
		this.showToast(successLabel, successMsgLabel, 'success');
	}

	handleError() {
		this.disableSpinner();
		if (this.stage=='Con venta' || this.stage=='Vencido' || this.stage=='Potencial') {
			this.showToast(errorLabel, 'No es posible realizar el cambio de etapa. Las etapas Potencial, Vencida y Con venta son etapas automáticas.', 'error');
		} else {
			this.showToast(errorLabel, errorMsgLabel, 'error');
		}
		
	}

	handleChangeStage(event) {
		this.stage = event.detail.newValue;
	}

	showToast(title, message, variant, mode) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}
	
	@api
	pathValues(listValues) {
		var aux = [];
        for(var value of listValues) {
            //aux.push(value.label);
            aux.push({value: value.value, label: value.label});
        }
        this.allStages = this.allStages.concat(aux);
	}

	handleMain() {
		this.actionType = 'main';
		//this.isModalOpen = true;
		this.updateMainOppTask(this.opptask);
	}

	handleUnlink() {
		this.actionType = 'unlink';
		//this.isModalOpen = true;
		this.enableSpinner();
		this.unlinkOpp();
	}

	handleCloseModal() {
		this.isModalOpen = false;
	}

	handleFlow(event) {
		var flowName = event.currentTarget.name;
		const flowEvent = new CustomEvent('flow', {
			detail: {
				flow: flowName,
				recId: event.currentTarget.dataset.key
			}
		});
		this.dispatchEvent(flowEvent);
	}

	doAction(event) {
		var actionType = event.detail.action;
		
		switch (actionType) {
			case 'main':
				this.updateMainOppTask(this.opptask);
				break;
			case 'unlink':
				this.unlinkOpp();
				break;    
		}
	}

	updateMainOppTask(oppTaskId) {
		updateMain({oppTask: oppTaskId})
			.then(() => {
				this.refreshParentMain();
				this.showToast(successLabel, successMsgLabel, 'success', 'pester');
				this.handleCloseModal();
			})
			.catch(error => {
				this.refreshParentMain();
				this.showToast('Error', mainLabel, 'error', 'pester');
				this.handleCloseModal();
		});
	}

	unlinkOpp() {
		unlinkOpp({oppTask: this.opptask})
			.then(() => {
				this.refreshParentUnlink();
				this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
				this.handleCloseModal();
			})
			.catch(error => {
				this.refreshParentUnlink();
				this.showToast('Error', unlinkLabel, 'error', 'pester');
				this.handleCloseModal();
		});
	}
	
	refreshParentMain() {
		this.dispatchEvent(new CustomEvent('refreshmain'));
	}

	refreshParentUnlink() {
		this.dispatchEvent(new CustomEvent('refreshunlink'));
	}

	disableSpinner() {
		this.dispatchEvent(new CustomEvent('disablespin'));
	}

	enableSpinner() {
		this.dispatchEvent(new CustomEvent('enablespin'));
	}

	validateFields(fields) {
		var values = [];
		for(var field of fields) {
			switch (field.fieldName) {
				case 'AV_Entity__c':
					values.push(field.value);
					break;
				case 'AV_Commentary__c':
					values.push(field.value);
					break;
			}
		}
		validateFields({listValues: values})
			.then(result => {
				if(result !== 'OK' && result !== 'KO') {
					var res = JSON.parse(result);
					if(res.type === 'E') {
						this.showToast('Error', res.message, 'error', 'sticky');
						this.disableSpinner();
					} else {
						this.showToast(warningTitleLabel, res.message, 'warning', 'sticky');
						this.template.querySelector('lightning-record-edit-form').submit();
					}
				} else if(result === 'KO') {
					this.handleError();
				} else {
					this.template.querySelector('lightning-record-edit-form').submit();
				}
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error', 'pester');
		});
	}

	handleSave() {
		this.enableSpinner();
		const inputFields = this.template.querySelectorAll('lightning-input-field');
		this.validateFields(inputFields, );
	}

	handleNavigateOpp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opptask.AV_Opportunity__c,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

	handleIncluir(event) {
        this.incluir = event.target.checked;
    }

	getOppLinks() {

	//	getOppLink({id: this.idobject, objApiName: this.nameobject})
		getOppLink({id: this.opptask.AV_Opportunity__c, objApiName: 'Opportunity', peaF: this.peaOpp})
			.then(result => {
				if (result != null) {
					this.listLinks = result.url;
					this.listLinksLabel = result.label != null ? result.label : 'Enlace informativo';
					if (this.listLinks!=null) {
						this.hasLinks = true;
					}
				}
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ',error);
				const evt = new ShowToastEvent({
					title: "AV_CMP_ErrorMessage",
					message: JSON.stringify(error),
					variant: 'error'
				});
				this.dispatchEvent(evt);
		});
	}

	navigateToWebPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: ''
            }
        }).then(url => {
            window.open(this.listLinks, "_self");
        });
    }
}