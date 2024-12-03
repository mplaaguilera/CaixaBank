import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivities from '@salesforce/apex/CIBE_ComentarioCitaActExController.getComentario';

export default class cibe_ComentarioCitaActEx extends LightningElement {

    @api recordId;
    @track comentarioCita;
    activeSections = ['A'];
    activeSectionsMessage = '';


    @wire(getActivities, {recordId: '$recordId'})
    getComentario({error, data}){
        if(data){
            this.comentarioCita = data;
        }
        if(error){
            this.comentarioCita = '';
            console.log('Error GetComentario',error);
            console.log(error);

        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }
}