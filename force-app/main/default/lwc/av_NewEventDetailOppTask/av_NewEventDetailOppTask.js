import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
import updateMain from '@salesforce/apex/AV_DetailOppTask_Controller.updateMainRecord';
import unlinkOpp from '@salesforce/apex/AV_DetailOppTask_Controller.unlinkOpp';

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

export default class Av_NewEventDetailOppTask extends LightningElement {
	@api opptask;
	@api justOne;

	@track isModalOpen = false;
	@track actionType;

	showDetail = false;
	showDetailMain = true;
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
		saveButtonLabel
	};

	toggleShowOppTask() {
		if(this.showDetail === true){
			this.showDetail = false;
		}else{
			this.showDetail = true;
		}
	}

	toggleShowOppTaskMain() {
		if(this.showDetailMain === true){
			this.showDetailMain = false;
		}else{
			this.showDetailMain = true;
		}
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

	handleMain() {
		this.actionType = 'main';
		//this.isModalOpen = true;
		this.updateMainOppTask(this.opptask);
	}

	handleUnlink() {
		this.actionType = 'unlink';
		//this.isModalOpen = true;
		this.unlinkOpp();
	}

	handleCloseModal() {
		this.isModalOpen = false;
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
				this.showToast('Error', error.body.message, 'error', 'pester');
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
				this.showToast('Error', error.body.message, 'error', 'pester');
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
}