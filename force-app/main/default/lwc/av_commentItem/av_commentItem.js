import { LightningElement, api, track } from 'lwc';

import productFieldLabel from '@salesforce/label/c.AV_ProductFieldOppTask';
import employeeLabel from '@salesforce/label/c.AV_Employee';
import commentLabel from '@salesforce/label/c.AV_HistoricalComment';

import { NavigationMixin } from 'lightning/navigation';

const STATUS_COLORS = {
    'En gestión/insistir': 'red',
    'Closed Positively': 'green'
    // Agrega más colores según sea necesario para otros estados
};
 
export default class Av_commentItem extends NavigationMixin(LightningElement) {
    @api item;

    @track divClass = "slds-timeline__item_expandable";
    @track iconName = 'standard:';
    @track isType = false;
    @track isStatus = false;
    @track isEmployee = false;
    @track isDate = false;
    @track isProduct = false;
    @track isChannel = false;
    @track hasOpps = false; 
    @track statusColorStyles; 
    @track isDateNull = false;

    label = {
        productFieldLabel,
        employeeLabel,
        commentLabel
    }

    connectedCallback() {
        switch (this.item.type) {
            case 'task':
                this.divClass += ' slds-timeline__item_task';
                this.iconName += this.item.type;
                this.isType = true;
                this.isStatus = true;
                this.isEmployee = true;
                this.isDate = true;
               
                if(this.item.nestedOpportunities[0] != null){
                    this.hasOpps = true;
                }
                break;
            case 'event':
                this.divClass += ' slds-timeline__item_event';
                this.iconName += this.item.type;
                this.isType = true;
                this.isEmployee = true;
                this.isDate = true;
                this.isStatus = true;  
            
                if(this.item.nestedOpportunities[0] != null){
                    this.hasOpps = true;
                }
                
                break;
            case 'opportunity':
                this.divClass += ' slds-timeline__item_opportunity';
                this.iconName += this.item.type;
                this.isProduct = true;
                this.isStatus = true;
                this.isEmployee = true;
                this.isDate = true;
                break;
            case 'case':
                this.divClass += ' slds-timeline__item_red';
                this.iconName += this.item.type;
                this.isStatus = true;
                this.isChannel = true;
                this.isDate = true;
                break;  
           
            case 'proceso':
                this.divClass += ' slds-timeline__item_event';
                this.iconName = 'custom:custom55';
                this.isDate = true;
                this.isType = true;
                this.isStatus = true;
                this.isEmployee = true;
                break;
            case 'accion':
                this.divClass += ' slds-timeline__item_event';
                this.iconName = null;
                this.iconName = 'custom:custom25';
                this.isDate = true;
                this.isType = true;
                this.isStatus = true;
                this.isEmployee = true;
                break;         
        }
        if (this.item.modifiedDate == null) {
            this.isDateNull=true;
        }
    }

    renderedCallback() {
        if (this.hasOpps) {
            this.applyStylesToBadges();
            this.showCommentWithDate();
        }
    }

    

    viewRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.item.recordId,
                "objectApiName": this.item.type,
                "actionName": "view"
            },
        });
    }

    viewRecordOppo(event){
        const recordId = event.target.dataset.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": recordId,
                "objectApiName": "opportunity",
                "actionName": "view"
            }
        });
    }

    applyStylesToBadges() {
        this.item.nestedOpportunities.forEach(nestedOpportunity => {
            const ele = this.template.querySelector('[data-id="' + nestedOpportunity.recordId + '"]');
            if (ele) {
                ele.style.backgroundColor = nestedOpportunity.colorStageNameLabelOppsNested; 
            }
        });
    }

    showCommentWithDate(){
        this.item.nestedOpportunities.forEach(nestedOpportunity => {
            if(nestedOpportunity.comment == null){
            const it =  this.template.querySelector('[data-id="' + nestedOpportunity.subject + '"]');
                if(it){
                    it.style.display=  'none';
                }
            }
        });
    }

    

    

    

   

    

}