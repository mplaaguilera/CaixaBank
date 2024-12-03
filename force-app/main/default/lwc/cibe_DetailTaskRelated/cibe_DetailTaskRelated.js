import { LightningElement, api , wire, track}   from 'lwc';
import { ShowToastEvent }                       from 'lightning/platformShowToastEvent';
import { NavigationMixin }                      from 'lightning/navigation';
import userId                                   from "@salesforce/user/Id";

import getTaskFields                 from '@salesforce/apex/CIBE_Related_Task_Controller.getTaskFields';
import unlinkTask                    from '@salesforce/apex/CIBE_Related_Task_Controller.unlinkTask';
import updateMain                   from '@salesforce/apex/CIBE_Related_Task_Controller.updateMainRecord';
import getAccountTeamMember             from '@salesforce/apex/CIBE_Related_Task_Controller.getAccountTeamMember';

//Label
import successLabel             from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel    from '@salesforce/label/c.AV_CMP_SuccessUnlinkOpp';
import successMsgLabel          from '@salesforce/label/c.AV_CMP_SaveMsgSuccess';
import etapa                    from '@salesforce/label/c.CIBE_Etapa';
import vincularOportunidad      from '@salesforce/label/c.CIBE_VincularOportunidad';
import desvincularOportunidad   from '@salesforce/label/c.CIBE_DesvincularOportunidad';
import marcarPrincipal          from '@salesforce/label/c.CIBE_MarcarOppPrincipal';
import oppPrincipal             from '@salesforce/label/c.CIBE_OportunidadPrincipal';
import incluirClienteLabel from '@salesforce/label/c.CIBE_IncluirCliPriorizados';


import asunto from '@salesforce/label/c.CIBE_Asunto';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import fechaVencimiento from '@salesforce/label/c.CIBE_FechaDeVencimiento';
import propietario from '@salesforce/label/c.CIBE_Propietario';
import comentario from '@salesforce/label/c.CIBE_Comentario';

export default class Cibe_DetailTaskRelated extends NavigationMixin (LightningElement) {

    labels = {
        etapa, 
        vincularOportunidad,
        desvincularOportunidad,
        marcarPrincipal,
        oppPrincipal,
        incluirClienteLabel,
        asunto,
        cliente,
        fechaVencimiento,
        propietario,
        comentario
    };

    @api recordId;
    @api taskId;
    @api editable;
    @api avEventId;
    @api principal;
    @api single;
    @api event;
    
    @track showSpinner = true;
    @track currentTask;

    @track isAccountTeamMember;
    @track editMode;

    @track subject;
    @track account;
    @track closeDate;
    @track owner;
    @track avTask;
    @track comment; 
    @track showDetail = false;

    @track currentName;

    connectedCallback(){
        this.getTaskField();
        this.getAccountTeam();

        if(this.principal) {
            this.showDetail = true;
        }
     }
    getTaskField(){
        getTaskFields({recordId: this.taskId})
            .then(result => {
                this.currentTask = result; 
                this.currentName = this.currentTask.Subject;
                this.account = result?.Account.Name == null ? '' : result?.Account.Name;
                this.owner = result?.Owner.Name == null ? '' : result?.Owner.Name;
                this.activityDate = this.currentTask.ActivityDate == null ? '' : this.currentTask.ActivityDate;
                this.comment = this.currentTask.Description == null ? '' : this.currentTask.Description;
                this.avTask = result.AV_Task__c;
                this.showSpinner=false;
                
            })
            .catch(error => {
                console.log(error);
        });
    }

    getAccountTeam(){
        getAccountTeamMember({taskId: this.taskId, currentUser: userId})
        .then(result => {
            this.isAccountTeamMember = result;
            this.editMode = !result;
        })

    }

    handleUnlink() {
        this.showSpinner = true;
		unlinkTask({taskId: this.taskId, eventId: this.event})
			.then(() => {
                this.showSpinner = false;
				this.showToast(successLabel, successUnlinkMsgLabel, 'success', 'pester');
                this.refreshParentLink();
			})
			.catch(error => {
                this.showSpinner = false;
				this.showToast('Error', error.body.message, 'error', 'pester');
                this.refreshParentLink();
		});
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

    handleNavigateOpp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.taskId,
                objectApiName: 'Task',
                actionName: 'view'
            }
        });
    }

    toggleShowOpp() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }

    refreshParentLink() {
        this.dispatchEvent(new CustomEvent('refreshlinkrelated'));
    }
	
    updateMainEventTask() {
        this.showSpinner = true;
        updateMain({eventId: this.event, taskId: this.taskId})
            .then(() => {
                this.showSpinner = false;
                this.showToast(successLabel, successMsgLabel, 'success', 'pester');
                this.refreshParentLink();
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('Error', error.body.message, 'error', 'pester');
                this.refreshParentLink();
        });
    }

    get showVincular () {
        return ((this.single && this.principal) || !this.principal);
    }
    
    handleDataPadre(){
        const sendData = new CustomEvent('datareport', {
            detail: {
                id: this.taskId,
                subject: this.subject,
                account: this.account,
                activityDate: this.activityDate,
                owner: this.owner,
                av_task: this.av_task,
                comment: this.comment
            }
        });
        this.dispatchEvent(sendData);
    }
    
    handleSubject(event){
        this.subject=event.target.value;
        this.handleDataPadre();
        
    }
    handleActivityDate(event){
        this.activityDate=event.target.value;
        this.handleDataPadre();
    }
    handleComment(event){
        this.comment=event.target.value;
        this.handleDataPadre();
    }
    

    handleOppSuccess(){
        this.showToast(successLabel, 'La oportunidad se ha guardado con exito', 'success', 'pester');
        /*this.currentStage = this.status;
        this.cambioStage = !this.cambioStage;
        this.handleDataPadre();*/
    }

    handleOppError(error){
        this.showToast('Error', error.body.message, 'error', 'pester');
    }
}