import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import showOpp from '@salesforce/label/c.AV_showOpportunity';

export default class AV_ButtonLinkOpportunity extends NavigationMixin(LightningElement){
    @api reportId;
    labelShowOpp=showOpp;
    button() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.reportId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }
}