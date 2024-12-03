import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

import getTaskStatus        from '@salesforce/apex/CIBE_TabManagementTask_Controller.getTaskStatus';
import getRecordType        from '@salesforce/apex/CIBE_TabManagementTask_Controller.getRecordType';
import getShowAssignPurse   from '@salesforce/apex/CIBE_TabManagementTask_Controller.showAssignPurse';
import isBankTeller         from '@salesforce/apex/CIBE_AppUtilities.isBankTeller';
import getNoGestionable   from '@salesforce/apex/CIBE_TabManagementTask_Controller.getNoGestionable';


//Labels
import CIBE_CMP_ErrorMessage  from '@salesforce/label/c.CIBE_CMP_ErrorMessage';
import gestionarTarea from '@salesforce/label/c.CIBE_GestionarTarea';
import gestionarTask from '@salesforce/label/c.CIBE_GestionarTask';
import noLocalizado from '@salesforce/label/c.CIBE_NoLocalizado';
import posponer from '@salesforce/label/c.CIBE_PosponerLlamarMasTarde';
import cerrarTarea from '@salesforce/label/c.CIBE_CerrarTarea';
import tareaInfNoGest from '@salesforce/label/c.CIBE_TareaInformativaNoGestionable';


export default class cibe_TaskTabs extends NavigationMixin(LightningElement) {

	labels = {
        gestionarTarea,
		gestionarTask,
		noLocalizado,
		posponer,
		cerrarTarea,
		tareaInfNoGest
    };

	@api active;
	@api recordId;
	@track progressValue;
	@track showDetail=true;
	@track fecha;
	@track recordType;
	@track buttonDisabled;
	@track disableBtn = false;
	@track showAssignPurse = false;
	@track showSpinner=false;

	// controls the visibility of closeTaskAndOppTab tab if current page is experiencia cliente
	@track isExperiencia;
	@track isEMP = false;
	@track preventClick = false;

	@api isNoGestionable;
	
	@wire(getNoGestionable, {recordId: '$recordId'})
	
    getNoGestionableData({error, data}) {
	
		console.log('data nogestionable: ');
		console.log(data);
        if(data) {
            this.isNoGestionable = data;
        } 
        else if(error) {

            console.log('error ====> ' + JSON.stringify(error))
        } 
    }

	hanldeProgressValueChange(event) {
		this.progressValue = event.detail.progress;
		this.template.querySelector('lightning-tabset').activeTabValue = this.progressValue;
		this.template.querySelector('c-cibe_-management-history').refresh();
		this.template.querySelector('c-cibe_-management-history').scrollIntoView(false);
		if (event.detail.closing) {
	
			var tabClosed = this.template.querySelector('c-cibe_-tab-closed');
			var closeTaskAndOpp = this.template.querySelector('c-cibe_-close-task-and-opp')
			if(tabClosed){
				tabClosed.getPreviousData();
			}
			if(closeTaskAndOpp){
				closeTaskAndOpp.botonDisabled();
			} 

		}
		this.buttonDisabled=event.detail.boton;
		if (this.buttonDisabled) {
			if (!event.detail.disableTab) {
				this.template.querySelector('c-cibe_-tab-closed').getRecordType();
			}
			var cmp1=this.template.querySelector('c-cibe_-tab-not-located');
			if (cmp1){
				cmp1.getRecordType();
			}
			var cmp2=this.template.querySelector('c-cibe_-postpone-call');
			if (cmp2){
				cmp2.getRecordType();
			}
			this.getRecordType();

		}		
		eval("$A.get('e.force:refreshView').fire();");
	}

	connectedCallback() {
		this.showSpinner=true;
		var today = new Date();
		this.fecha=today.toISOString().substring(0,10);
		this.getRecordType();
		this.disableTabs();
	}

	getRecordType() {
        getRecordType({id: this.recordId})
            .then(result => {
				this.recordType = result;
				this.btnDisabled();
				if (this.recordType == 'CIBE_ExperienciaClienteCIB' || this.recordType == 'CIBE_ExperienciaClienteEMP') {
					this.isExperiencia = true;
					this.isEMP = false;
				}else if(this.recordType != 'CIBE_ExperienciaClienteEMP' && this.recordType && this.recordType.includes('EMP')){
					this.isExperiencia = false;
					this.isEMP = true;
				} else {				
					this.isExperiencia = false;
					this.isEMP = false;
				}
            })
            .catch(error => {
				console.log(error);
                this.dispatchEvent(
					new ShowToastEvent({
						title: CIBE_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
				this.showSpinner=false;
            });
	}

	btnDisabled() {
		getTaskStatus({id: this.recordId})
		
		.then(tarea => {
			if(this.recordType == 'CIBE_ExperienciaClienteCIB' || this.recordType == 'CIBE_ExperienciaClienteEMP' || this.recordType == 'CIBE_GestionarPriorizadosCIB' || this.recordType == 'CIBE_GestionarPriorizadosEMP'  || this.recordType == 'CIBE_AlertaComercialCIB' || this.recordType == 'CIBE_AlertaComercialEMP'){
				if(tarea.ActivityDate < this.fecha){
					this.disableBtn = true;
				}
			}else if(this.recordType == 'CIBE_OnboardingCIB' || this.recordType == 'CIBE_OnboardingEMP'){
				if(tarea.ActivityDate < this.fecha || tarea.Status == 'Gestionada positiva'){
					this.disableBtn = true;
				}
				if(tarea.Status == 'Gestionada positiva'){  
					this.getAssignPurse();
				}
			} else if (this.recordType == 'CIBE_AvisosEMP' || this.recordType == 'CIBE_AvisosCIB') {
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
			console.log(error);
			this.dispatchEvent(
				new ShowToastEvent({
					title: CIBE_CMP_ErrorMessage,
					message: JSON.stringify(error),
					variant: 'error'
				})
			);
			this.showSpinner=false;
		});
	}


	getAssignPurse(){
		getShowAssignPurse({taskId: this.recordId}).then(result => {
			this.showAssignPurse = result;
		})
		.catch(error => {
			console.log(error);
			this.dispatchEvent(
				new ShowToastEvent({
					title: CIBE_CMP_ErrorMessage,
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
				//Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
				apiName: 'CIBE_CloseTask'
			},state: {
				c__recId: this.recordId
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
				console.error(error);
				this.errors = [error];
			});
	}

}