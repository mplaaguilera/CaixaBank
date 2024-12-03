import { LightningElement, api } from 'lwc';

export default class Cibe_NewContactRelatedList extends LightningElement {
    @api recordId;
    
    connectedCallback() {
        this.contactIcon    = "standard:employee_contact";
        this.apoderadoIcon  = "standard:employee_contact";
    }
}