import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

//Methods
import linkOpp from '@salesforce/apex/AV_DetailOpp_Controller.linkOpp';

//Labels
import valueFieldLabel from '@salesforce/label/c.AV_ValueFieldOppTask';
import conceptFieldLabel from '@salesforce/label/c.AV_ConceptFieldOppTask';
import productFieldLabel from '@salesforce/label/c.AV_ProductFieldOppTask';
import recordtypeFieldLabel from '@salesforce/label/c.AV_RecordTypeFieldOppTask';
import link from '@salesforce/label/c.AV_CMP_Link';

export default class Av_DetailOpp extends NavigationMixin (LightningElement) {

    @api opp;
    @api taskHeaderId;
    @api listformat = false;
    @api opendetail = false;
    @api recordInfo;
    
    showSpinner=false;

    @track allStages = [];
    @track stage;
    @track isModalOpen = false;
    @track actionType;
    
    label = {
        valueFieldLabel,
        conceptFieldLabel,
        productFieldLabel,
        recordtypeFieldLabel,
        link
    };

    connectedCallback() {
        if(this.opendetail) {
            this.showDetail = true;
        }
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

    toggleShowOpp() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }

    @api
    pathValues(listValues) {
        var aux = [];
        for(var value of listValues) {
            aux.push({value: value.value, label: value.label});
        }
        this.allStages = this.allStages.concat(aux);
    }
	
	handleLink() {
        this.actionType = 'link';
        this.dispatchEvent(new CustomEvent("enablespin"));
        this.linkOpp();
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    doAction(event) {
        var actionType = event.detail.action;
        switch (actionType) {
            case 'link':
                this.linkOpp();
                break;   
        }
    }

    linkOpp() {
        linkOpp({recordInfo: JSON.stringify(this.recordInfo), opp: this.opp})
            .then(result => {
                if(result === 'OK') {
                    this.refreshParentLink();
                    this.showToast('Correcto', 'Oportunidad vinculada con éxito.', 'success');
                } else if(result === 'KO') {
                    this.refreshParentLink();
                    this.showToast('Error', 'Error al vincular la oportunidad.', 'error');
                }
                this.handleCloseModal();
            })
            .catch(error => {
                this.refreshParentLink();
                this.showToast('Error', 'Error al vincular la oportunidad.', 'error');
            });
        
        
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
			message: message,
			variant: variant
        });
        this.dispatchEvent(event);
    }

    refreshParentLink() {
        this.dispatchEvent(new CustomEvent('refreshlink'));
    }

    handleNavigateOpp() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opp.Id,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }
    enableSpinner(){
        this.showSpinner=true;
    }
    disableSpinner(){
        this.showSpinner=false;
    }
}