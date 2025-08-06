import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Methods
import linkOpp from '@salesforce/apex/AV_DetailOpp_Controller.linkOpp';

//Labels
import valueFieldLabel from '@salesforce/label/c.AV_ValueFieldOppTask';
import conceptFieldLabel from '@salesforce/label/c.AV_ConceptFieldOppTask';
import productFieldLabel from '@salesforce/label/c.AV_ProductFieldOppTask';
import recordtypeFieldLabel from '@salesforce/label/c.AV_RecordTypeFieldOppTask';
 
export default class Av_NewEventDetailOpp extends LightningElement {
    
    @api opp;
    @api taskHeaderId;
    @api recordInfo;
    @track stageLabel;
    @track isModalOpen = false;
    @track actionType;

    label = {
        valueFieldLabel,
        conceptFieldLabel,
        productFieldLabel,
        recordtypeFieldLabel
    };
    connectedCallback(){
        this.stageLabel = (this.opp.StageName == 'En gestión/insistir') ? 'En Gestión' : this.opp.StageName;
    }
    showDetail = false;

    toggleShowOpp() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }
	
	handleLink() {
        this.actionType = 'link';
        this.dispatchEvent(new CustomEvent("enablespin"));
        //this.isModalOpen = true;
        this.linkOpp();
        /**/
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
                    this.showToast('Error', 'Error al vincular la oportunidad.', 'error');
                }
                this.handleCloseModal();
            })
            .catch(error => {
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
}