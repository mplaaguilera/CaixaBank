import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";

import ANALISIS_SENTIMIENTO from '@salesforce/schema/LiveChatTranscript.CSBD_AnalisisSentimiento__c';
import STATUS from '@salesforce/schema/LiveChatTranscript.Status';
import ID_FIELD from '@salesforce/schema/LiveChatTranscript.Id';
import resolverPromptDinamico from '@salesforce/apex/CSBD_ChatGPT_Controller.resolverPromptDinamico';

export default class Csbd_analisisSentimientoChat extends LightningElement {
    @api recordId;
    @api planSentimiento = 'CSBD_AnalisisSentimiento';
    @track refrescando = false;
    @track error = false;

    @wire (getRecord, { recordId: '$recordId', fields: [ ID_FIELD, ANALISIS_SENTIMIENTO, STATUS] }) chat;

    get estado() {
        return getFieldValue(this.chat.data, STATUS);
    }

    get analisisSentimiento() {
        return getFieldValue(this.chat.data, ANALISIS_SENTIMIENTO);
    }

    renderedCallback() {
        console.log('estado');
        console.log(this.estado);
        if(this.estado === 'Completed' && this.analisisSentimiento === null && !this.refrescando && !this.error) {
            console.log('id');
            console.log(this.recordId);
            console.log('prompt');
            console.log(this.planSentimiento);
            this.refrescando = true;
            this.handlePromptSentimiento();
        }

    }

    handlePromptSentimiento() {
        resolverPromptDinamico({recordId: this.recordId, apiPrompt: this.planSentimiento, valueKey: 'Input:LiveChatTranscript'})
        .then(response => {
            const fields = {};
            fields[ANALISIS_SENTIMIENTO.fieldApiName] = response;
            fields[ID_FIELD.fieldApiName] = this.recordId;
            const recordInput = {fields};
            updateRecord(recordInput);
            this.refrescando = false;
        })
        .catch(error => {
            console.error('Error realizando el análisis de sentimiento', error);
            this.refrescando = false;
            this.error = true;
        });
    }

}