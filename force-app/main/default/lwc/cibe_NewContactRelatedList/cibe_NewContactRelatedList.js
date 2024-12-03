import { LightningElement, api } from 'lwc';

import apoderado from '@salesforce/label/c.CIBE_Apoderado';
import contacto from '@salesforce/label/c.CIBE_ContactoSin';

export default class Cibe_NewContactRelatedList extends LightningElement {
    labels = {
        apoderado,
        contacto
    }
    
    @api recordId;
    
    connectedCallback() {
        this.contactIcon    = "standard:employee_contact";
        this.apoderadoIcon  = "standard:employee_contact";
    }
}