import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

//Methods
import retrieveListOpp from '@salesforce/apex/AV_ListOpportunities_Controller.retrieveListOpp';
import getStatusValues from '@salesforce/apex/AV_ListOpportunities_Controller.getStatusValues';
import retrieveListWithOutTask from '@salesforce/apex/AV_ListOpportunities_Controller.retrieveListWithOutTask';
import getRecInfo from '@salesforce/apex/AV_ListOpportunities_Controller.getRecordInfo';
import saveOppRecords from '@salesforce/apex/AV_NewOpportunity_Controller.saveOppRecords';

//Labels
import oppTask from '@salesforce/label/c.AV_oppoTask';
import oppLinked from '@salesforce/label/c.AV_OppLinked';
import oppUnLinked from '@salesforce/label/c.AV_OppUnLinked';
import oppUnLinkedMobile from '@salesforce/label/c.AV_OppUnLinkedMobile';
import noDataFoundLabel from '@salesforce/label/c.AV_CMP_NoDataFound';
import errorMsgLabel from '@salesforce/label/c.AV_CMP_SaveMsgError';

export default class Av_ListOpportunities extends LightningElement {
	
	@api recid;
	@api sobjname;
	@api newrecord;
	@api isreport;
	@api eventnoplanificado;
	

	label = {
		oppLinked,
		oppUnLinked,
		oppUnLinkedMobile,
		noDataFoundLabel,
		oppTask
	};

	icon = 'standard:opportunity';

	@track listOppTask;
	@track listaVincular=[];
	@track listOpp;
	@track stagesValuesOppTask;
	@track stagesValuesOpp;
	@track showSpinner = true;
	@track recInfo;
	@track taskHeaderId;
	@track onlyOneOppTask = false;
	@track isEvent=false;
	@track recordInfo;

	get isBrowser() {
		if(FORM_FACTOR == 'Large'){
			this.formFactorBrowser = true;
		}else{
			this.formFactorBrowser = false;
		}

		return this.formFactorBrowser;
	  }

	connectedCallback() {
		if (this.sobjname=='Event') {
			this.isEvent=true;
		}
		if (this.eventnoplanificado == null) {
			this.eventnoplanificado =false;
		}
		this.getRecordInfo();
	}

	refreshCmp(){
		this.enableSpinner();
		this.listOppTask = undefined;
		this.listaVincular = [];
		this.onlyOneOppTask = false;
		this.listOpp = undefined;
		this.stagesValuesOppTask = undefined;
		this.stagesValuesOpp = undefined;
		this.dispatchEvent(new CustomEvent('refreshlink'));
		this.getDataOppTask();
		this.getDataOpp();
	}

	refreshMainCmp(){
		this.enableSpinner();
		this.listOppTask = undefined;
		this.onlyOneOppTask = false;
		this.stagesValuesOppTask = undefined;
		this.getDataOppTask();
	}

	getDataOppTask(){
		retrieveListOpp({recordInfoJson: this.recInfo})
			.then(result => {
				if(result != null) {
					this.listOppTask = result;
					if(this.listOppTask.length === 1) {
						this.onlyOneOppTask = true;
					}
					this.getStatus('AV_CustomActivityOpportunity__c', 'AV_Stage__c');
				} else {
					this.disableSpinner();
				}
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error');
				console.log(error.body);
				this.disableSpinner();
		});
	}

	getDataOpp() {
		retrieveListWithOutTask({recordInfoJson: this.recInfo})
			.then(result => {
				if(result != null) {
					this.listOpp = result;
					this.getStatus('Opportunity', 'StageName');
				} else {
					this.disableSpinner();
				}
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error');
				console.log(error.body);
				this.disableSpinner();
		});
	}

	getRecordInfo(){
		getRecInfo({recordId: this.recid, objectName: this.sobjname})
			.then(result => {
				if(result != null) {
					this.recInfo = result;
					this.taskHeaderId = JSON.parse(result).taskHeader;
					this.recordInfo = JSON.parse(result);
					console.log('result',result);
					this.getDataOppTask();
					this.getDataOpp();
				}
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error');
				this.disableSpinner();
		});
	}

	getStatus(objName, fldName){
		getStatusValues({objectName: objName, fieldName: fldName})
			.then(result => {
				if(objName === 'AV_CustomActivityOpportunity__c') {
					this.stagesValuesOppTask = result;
					for(var item of this.template.querySelectorAll('c-av_-detail-opp-task')) {
						item.pathValues(this.stagesValuesOppTask);
					}
				} else if(objName === 'Opportunity') {
					this.stagesValuesOpp = result;
					for(var item of this.template.querySelectorAll('c-av_-detail-opp')) {
						item.pathValues(this.stagesValuesOpp);
					}
				}
				this.disableSpinner();
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error');
				this.disableSpinner();
		});
	}

	callLaunchFlow(event) {
		var flowName = event.detail.flow;
		var oppId = event.detail.recId;
		const flwEvent = new CustomEvent('launchflow', {
			detail: {
				value: flowName,
				oppId: oppId
			}
		});
		this.dispatchEvent(flwEvent);
	}

	disableSpinner() {
		this.showSpinner = false;
	}

	enableSpinner() {
		this.showSpinner = true;
	}

	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}

	sendData(event) {       
	
		const sendData = new CustomEvent('datareport', {
			detail: event.detail
		});
		this.dispatchEvent(sendData);
	}

	sendDataFlow(event) {
		this.showSpinner=true;
		var listData = [];
		for(let i = 0; i < this.listaVincular.length; i++) {
			if(this.listaVincular[i].id != event.detail.id) {
				listData.push(this.listaVincular[i]);
			}
		}
		listData.push(event.detail);
		this.listaVincular = listData;

		saveOppRecords({listOppRecords: this.listaVincular})
			.then(result => {
				if (result.includes('Warning')) {
					this.dispatchEvent(new CustomEvent('textflow', {
						detail: {
							textError: 'OK'
						}
					}));
					this.showToast('Warning', result, 'warning', 'sticky');
				} else if (result != 'OK' && result != 'KO') {
					this.dispatchEvent(new CustomEvent('textflow', {
						detail: {
							textError: result
						}
					}));
					this.showToast('Error', result, 'error', 'pester');
				}
			})
			.catch(error => {
				console.log(error);
				this.showToast('Error', result, 'error', 'pester');
			})
			.finally(()=>{
				console.log('@finaly');
				this.showSpinner=false;
			});
	}

}