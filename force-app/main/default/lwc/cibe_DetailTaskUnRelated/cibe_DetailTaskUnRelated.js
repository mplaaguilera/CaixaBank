import { LightningElement, api , wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getTaskFields                 from '@salesforce/apex/CIBE_Related_Task_Controller.getTaskFields';
import linkTask             from '@salesforce/apex/CIBE_Related_Task_Controller.linkTask';

import correcto from '@salesforce/label/c.CIBE_Correcto';
import oppVinEx from '@salesforce/label/c.CIBE_OportunidadVinculadaExito';
import error from '@salesforce/label/c.CIBE_Error';
import errorVinOpp from '@salesforce/label/c.CIBE_ErrorVincularOportunidad';
import etapa from '@salesforce/label/c.CIBE_Etapa';
import vincularOportunidad from '@salesforce/label/c.CIBE_VincularOportunidad';

import asunto from '@salesforce/label/c.CIBE_Asunto';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import fechaVencimiento from '@salesforce/label/c.CIBE_FechaDeVencimiento';
import propietario from '@salesforce/label/c.CIBE_Propietario';
import comentario from '@salesforce/label/c.CIBE_Comentario';


export default class Cibe_DetailTaskUnRelated extends NavigationMixin (LightningElement) {

    labels = {
        correcto,
        oppVinEx,
        error,
        errorVinOpp,
        etapa,
        vincularOportunidad,
        asunto,
        cliente,
        fechaVencimiento,
        propietario,
        comentario
    };

    @api taskId;
    @api event;

    @track showSpinner = true;
    @track allStages = [];
    @track currentTask;
    @track currentName;
    @track showDetail = false;

    @track subject;
    @track account;
    @track activityDate;
    @track owner;
    @track av_task;
    @track comment; 

    connectedCallback(){
        this.getTaskField();
        
     }

    getTaskField(){
        getTaskFields({recordId: this.taskId})
            .then(result => {
                console.log('### task ', result);
                this.currentTask = result; 
                this.currentName = this.currentTask.Subject;
                this.account = result?.Account.Name == null ? '' : result?.Account.Name;
                this.owner = result?.Owner.Name == null ? '' : result?.Owner.Name;
                this.activityDate = this.currentTask.ActivityDate == null ? '' : this.currentTask.ActivityDate;
                this.comment = this.currentTask.Description == null ? '' : this.currentTask.Description;
                this.showSpinner=false;
            })
            .catch(error => {
                console.log(error);
        });
    }

    showToast(title, message, variant, mode) {
		this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            })
        );
	}

    handleNavigateOpp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.taskId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    toggleShowTask() {
       
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }

    handlelink() {
        this.showSpinner = true;
        linkTask({recordId: this.event, taskId: this.taskId})
            .then(result => {
                this.showSpinner = false;
                if(result === 'OK') {
                    this.showToast(this.labels.correcto, this.labels.oppVinEx, 'success');
                } else if(result === 'KO') {
                    this.showToast(this.labels.error, this.labels.errorVinOpp, 'error');
                }
                this.refreshParentLink();
            })
            .catch(error => {
                this.showToast(this.labels.error, this.labels.errorVinOpp, 'error');
                this.refreshParentLink();
            });
            
    }
	
    refreshParentLink() {
        console.log("Lanzamos evento al padre desde unrelated.");
        this.dispatchEvent(new CustomEvent('refreshlinkunrelated'));
    }
    


}