import { LightningElement, wire, api, track } from 'lwc';
import getInterlocutores from '@salesforce/apex/SIR_LCMP_interlocutor.getInterlocutores';

export default class Sir_lwc_interlocutor extends LightningElement {
    @api recordId;
    @track idInformacionCliente;

    @wire(getInterlocutores, { idCliente: '$recordId'})
    getInterlocutores({ error, data }) { 
        if(data){
            this.idInformacionCliente = data;          
        }                 
    }
}