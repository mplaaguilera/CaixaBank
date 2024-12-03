import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SACCASORELACIONADO_FIELD from '@salesforce/schema/Case.SAC_CasoRelacionado__c';
import CASORELACIONADOPADRE_FIELD from '@salesforce/schema/Case.SAC_Reclamacion__r.SAC_CasoRelacionado__c';

const fields = [SACCASORELACIONADO_FIELD, CASORELACIONADOPADRE_FIELD];

export default class Sac_InfoCopiasMasivas extends LightningElement {

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    get SAC_CasoRelacionado__c() {
        return getFieldValue(this.case.data, SACCASORELACIONADO_FIELD);
    }

    get casoRelacionadoPadre() {
        return getFieldValue(this.case.data, CASORELACIONADOPADRE_FIELD);
    }

}