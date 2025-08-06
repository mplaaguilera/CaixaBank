import { LightningElement, track } from 'lwc';

import notaPrecios from '@salesforce/label/c.CIBE_NotaPrecios';

export default class Cibe_SectionNotesAndAttachments extends LightningElement {


    @track showEquipoAnalista = true;

    labels = {
        notaPrecios
    }   

}