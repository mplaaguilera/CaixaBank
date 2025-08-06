import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import findSPersona from '@salesforce/apex/CC_Busqueda_ALF_Controller.buscarSocialPersona';

//export default class Cc_RelatedSocialPersona extends LightningElement {
export default class Cc_RelatedSocialPersona extends NavigationMixin(LightningElement) {
    @api recordId;
    @track registro;
    @wire (findSPersona, {caseId: '$recordId' }) parameters;

    handleContactView() {
        // Navigate to case record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.parameters.data.Id,
                objectApiName: 'SocialPersona',
                actionName: 'view',
            },
        });
    }
}