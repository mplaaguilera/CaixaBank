import { LightningElement, api, track } from 'lwc';

import productFieldLabel from '@salesforce/label/c.CIBE_Producto';
import employeeLabel from '@salesforce/label/c.CIBE_Empleado';
import commentLabel from '@salesforce/label/c.CIBE_ComentarioHistorico';

import { NavigationMixin } from 'lightning/navigation';

export default class cibe_TimelineEMPItem extends NavigationMixin(LightningElement) {
    @api item;

    @track divClass = 'slds-timeline__item_expandable';
    @track iconName = 'standard:';
    //@track isOpp = false;
    //@track isSale = false;
    //@track isCase = false;
    //@track isTask = false;
    //@track isEvent = false;

    @track isType = false;
    @track isStatus = false;
    @track isEmployee = false;
    @track isDate = false;
    @track isProduct = false;
    @track isChannel = false;
    @track isDateNull = false;
    @track isDateComment = false;
    @track isOpp = false;
    @track hasOpps = false;

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

                if(this.item.nestedOpportunities != null){
                    this.hasOpps = true;
                    this.isProduct = true;
                }

                break;

            case 'event':
                this.divClass += ' slds-timeline__item_event';
                this.iconName += this.item.type;
                this.isType = true;
                this.isStatus = true;
                this.isEmployee = true;
                this.isDate = true;

                if(this.item.nestedOpportunities != null){
                    this.isProduct = true;
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
                this.isDateComment = true;
                this.isOpp = true;
                break;

            case 'case':
                this.divClass += ' slds-timeline__item_red';
                this.iconName += this.item.type;
                this.isStatus = true;
                this.isChannel = true;
                this.isDate = true;
                break;            
        }
        if (this.item.modifiedDate == null) {
            this.isDateNull=true;
        }
    }

    viewRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.item.recordId,
                "objectApiName": this.item.type,
                "actionName": "view"
            }
        });
    }

    viewRecordOpp(event){
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
        const ele = this.template.querySelector('[data-id="' + this.item.recordId + '"]');
        
        if(ele != null){
            ele.style.backgroundColor = this.item.colorStageNameLabelOppsNested;
        }

       

        this.item.nestedOpportunities?.forEach(nestedOpportunity => {
            const ele2 = this.template.querySelector('[data-id="' +nestedOpportunity.recordId + '"]');
            if (ele2) {
                ele2.style.backgroundColor = nestedOpportunity.colorStageNameLabelOppsNested; 
            }
        });

    }

    renderedCallback() {
        //if (this.hasOpps) {
            this.applyStylesToBadges();
            //this.showCommentWithDate();
        //}
    }
}