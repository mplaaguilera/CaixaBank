import { LightningElement, track, api } from 'lwc';
import SIR_CMP_Message from '@salesforce/label/c.SIR_CMP_Message';


export default class Sire_lwc_linkFichaComercial extends LightningElement {
   
    @api recordId;
    @track enlace;
    message = SIR_CMP_Message;
    a_Record_URL;
    
    connectedCallback() {
        this.a_Record_URL = window.location.origin;
        this.enlace = this.a_Record_URL + '/lightning/app/c__CIBE_MisClientesEMP/r/Account/'+ this.recordId + '/view?_vmcNewtab=true';
    } 
   
}