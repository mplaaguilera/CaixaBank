import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTaskStatus            from '@salesforce/apex/AV_TabManagementTask_Controller.getTaskStatus';
import getRecordType            from '@salesforce/apex/AV_TabManagementTask_Controller.getRecordType';
import getShowAssignPurse       from '@salesforce/apex/AV_TabManagementTask_Controller.showAssignPurse';
import isBankTeller from '@salesforce/apex/AV_AppUtilities.isBankTeller';
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';
import oldReports from '@salesforce/customPermission/AV_OldReports';
import getName      from '@salesforce/apex/AV_Header_Controller.getAccountInfo';

export default class AV_TaskTabs extends NavigationMixin(LightningElement) {
	@api active;
	@api recid;
	@api recordId;
	@track progressValue;
	@track showDetail=true;
	@track fecha;
	@track recordType;
	@track buttonDisabled;
	@track disableBtn = false;
	@track showAssignPurse = false;
	showSpinner=false;
	showOldReports = oldReports;
	@track name;
	@track recordType;
	@track isIntouch;
    @track account;
	nameRecord;

	// controls the visibility of closeTaskAndOppTab tab if current page is experiencia cliente
	isExperiencia = false;
	preventClick = false;

	hanldeProgressValueChange(event) {
		
		this.progressValue = event.detail.progress;
		this.template.querySelector('lightning-tabset').activeTabValue = this.progressValue;
		this.template.querySelector('c-av_-management-history').refresh();
		this.template.querySelector('c-av_-management-history').scrollIntoView(false);
		if (event.detail.closing) {
	
			var tabClosed = this.template.querySelector('c-av_-tab-closed');
			var closeTaskAndOpp = this.template.querySelector('c-av_-close-task-and-opp-tab')

			if(tabClosed){
				tabClosed.getPreviousData();
			}
			if(closeTaskAndOpp){
				closeTaskAndOpp.botonDisabled();
				// this.refresh();
			} 

		}
		this.buttonDisabled=event.detail.boton;
		if (this.buttonDisabled) {
			if (!event.detail.disableTab) {
				this.template.querySelector('c-av_-tab-closed').getRecordType();
			}
			var cmp1=this.template.querySelector('c-av_-tab-not-located');
			if (cmp1){
				cmp1.getRecordType();
			}
			var cmp2=this.template.querySelector('c-av_-postpone-call');
			if (cmp2){
				cmp2.getRecordType();
			}
			this.getRecordType();
		}		
	}

	connectedCallback() {
		this.showSpinner=true;
		var today = new Date();
		this.fecha=today.toISOString().substring(0,10);
		this.getRecordType();
		this.disableTabs();
		this.getNameData();	
	}

	getNameData(){
        getName({recordId:this.recid})
            .then(data => {
                if (data) {
					this.name = data.accountName;
                    this.recordType = data.rtDevName;
                    this.isIntouch = data.isIntouch;
                    this.nameRecord = data.nameRecord;
                    this.account = data.accountId;
                } else if (error) {
                    console.log(error);
                }
            }).catch(error => {
                console.log(error);
            })
	}

	getRecordType() {
        getRecordType({id: this.recid})
            .then(recordType => {
				this.recordType = recordType;
				this.btnDisabled();
				if (this.recordType == 'AV_ExperienciaCliente') {
					this.isExperiencia = true;
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
				this.showSpinner=false;
            });
	}

	btnDisabled() {
		// Desactiva botón 'Grabar' si la tarea ha sido cerrada
		getTaskStatus({id: this.recid})
		.then(tarea => {
			/*if (status == 'Gestionada positiva' ||
				status == 'Gestionada negativa' ||
				status == 'Gestionado no localizado' ||
				status == 'No gestionada') {
				this.disableBtn = true;
			}*/
			if(this.recordType == 'AV_ExperienciaCliente' || this.recordType == 'AV_Priorizador' || this.recordType == 'AV_AlertaComercial'){
				if(tarea.ActivityDate < this.fecha){
					this.disableBtn = true;
				}
			}else if(this.recordType == 'AV_Onboarding' ){
				if(tarea.ActivityDate < this.fecha || tarea.Status == 'Gestionada positiva'){
					this.disableBtn = true;
				}
				if(tarea.Status == 'Gestionada positiva') { 
					this.getAssignPurse();
				}
			} else if (this.recordType == 'AV_MorosidadNormativa') {
				var date = new Date(tarea.ActivityDate);
				date.setDate(date.getDate() + 7);
				var day = date.getDate();
				if (day <= 9) {
					day='0'+day;
				}
				var month = date.getMonth()+1;
				if (month <= 9) {
					month='0'+month;
				}
				var year = date.getFullYear();
				var fechave=year+'-'+month+'-'+day;
				if (fechave < this.fecha) {
					this.disableBtn = true;
				}
				if(tarea.AV_OrigenApp__c=='AV_NowIn'){
					this.disableBtn = true;
				}
			}
			this.showSpinner=false;
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
			this.showSpinner=false;
		});
	}


	getAssignPurse(){
		getShowAssignPurse({taskId: this.recid}).then(result => {
			this.showAssignPurse = result;
			//console.log(this.showAssignPurse);
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

	toggleShow() {
		if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
	}

	navigateToTab() {
		this[NavigationMixin.Navigate]({
			type: 'standard__navItemPage',
			attributes: {
				//Name of any CustomTab. Visualforce tabviweb tabs, Lightning Pages, and Lightning Component tabs
				apiName: 'AV_CloseTaskAndNewOpp'
			},state: {
				c__recId: this.recid
			}
		});
    }

	navigateToTabVersion2() {
		this[NavigationMixin.Navigate]({
			type: 'standard__navItemPage',
			attributes: {
				//Name of any CustomTab. Visualforce tabviweb tabs, Lightning Pages, and Lightning Component tabs
				apiName: 'AV_TaskReportParentTab'
			},state: {
				c__recId: this.recid,
				c__id:this.name,
				c__rt:this.recordType,
				c__intouch:this.isIntouch,
				c__account:this.account
			}
			
		});
	}

	disableTabs() {
		isBankTeller()
			.then((result) => {
				if (result){
					this.preventClick = true;
				} 
			})
			.catch((error) => {
				console.error('Disable tabs error', JSON.stringify(error));
				this.errors = [error];
			});
	}
}