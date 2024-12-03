import { LightningElement, api , wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


import getStatusValues       from '@salesforce/apex/CIBE_NewOpportunity_Controller.getStatusValues';
import getOppFields          from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getOppFields';
import linkOpp             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.linkOpp';
import correcto from '@salesforce/label/c.CIBE_Correcto';
import oppVinEx from '@salesforce/label/c.CIBE_OportunidadVinculadaExito';
import error from '@salesforce/label/c.CIBE_Error';
import errorVinOpp from '@salesforce/label/c.CIBE_ErrorVincularOportunidad';
import etapa from '@salesforce/label/c.CIBE_Etapa';
import vincularOportunidad from '@salesforce/label/c.CIBE_VincularOportunidad';


export default class Cibe_DetailOppUnRelated extends NavigationMixin (LightningElement) {

    labels = {
        correcto,
        oppVinEx,
        error,
        errorVinOpp,
        etapa,
        vincularOportunidad
    };

    @api customactivityopp;
    @api event;

    @track showSpinner = true;
    @track allStages = [];
    @track currentStage;
    @track currentOpportunity;
    @track currentName;
    @track lastComment;
    @track showDetail = false;

    connectedCallback(){
        this.getStatus();
        this.getOppField();
        
        if(this.opendetail) {
            this.showDetail = true;
        }
     }

    getStatus(){
        getStatusValues({objectName: 'Opportunity', fieldName: 'StageName'})
            .then(result => {
                this.pathValues(result);
            })
            .catch(error => {
                console.log(error);
        });
    }
    pathValues(listValues) {
        var aux = [];
        for(var value of listValues) {
            aux.push({value: value.value, label: value.label});
        }
       
        this.allStages = this.allStages.concat(aux);
    }
    getOppField(){
        getOppFields({oppoId: this.customactivityopp})
            .then(result => {
                this.currentOpportunity = result; 
                this.currentStage = this.currentOpportunity.StageName;
                this.currentName = this.currentOpportunity.Name;
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
                recordId: this.customactivityopp,
                objectApiName: 'Opportunity',
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

    handlelink() {
        this.showSpinner = true;
        linkOpp({recordId: this.event, opp: this.customactivityopp})
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