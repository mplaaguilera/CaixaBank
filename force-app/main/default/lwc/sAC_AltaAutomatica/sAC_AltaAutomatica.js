import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SACCASORELACIONADO_FIELD from '@salesforce/schema/Case.SAC_CasoRelacionado__c';
import CASORELACIONADOPADRE_FIELD from '@salesforce/schema/Case.SAC_Reclamacion__r.SAC_CasoRelacionado__c';
import SACALTAUTOMATICA_FIELD from '@salesforce/schema/Case.SAC_AltaAutomatica__c';
import SACENTIDADAFECTADA_FIELD from '@salesforce/schema/Case.SAC_Entidad_Afectada__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SACSENTIDORESOLUCION_FIELD from '@salesforce/schema/Case.SAC_SentidoResolucion__c';
import SACRECLAMACIONPADRE_FIELD from '@salesforce/schema/Case.SAC_Reclamacion__c';
import SACM2P_FIELD from '@salesforce/schema/Case.SAC_M2P__c';
import SACRECLAMACIONPADREM2P_FIELD from '@salesforce/schema/Case.SAC_Reclamacion__r.SAC_M2P__c';
import RECORDTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import recuperarCasos from "@salesforce/apex/SAC_LCMP_AltaAutomatica.recuperarCasos";

const fields = [SACCASORELACIONADO_FIELD, CASORELACIONADOPADRE_FIELD, SACALTAUTOMATICA_FIELD, SACENTIDADAFECTADA_FIELD, STATUS_FIELD, SACSENTIDORESOLUCION_FIELD, SACRECLAMACIONPADRE_FIELD, SACM2P_FIELD, SACRECLAMACIONPADREM2P_FIELD, RECORDTYPEID_FIELD];

export default class SAC_AltaAutomatica extends LightningElement {

    @api recordId;
    @track mostrarAvisoM2P = false;
    @track listaAvisoM2P;
    @track mostrarAvisoCopiaMasiva = false;
    @track avisoCopiaMasiva;



    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    //getters campos
    get SAC_CasoRelacionado__c() {
        return getFieldValue(this.case.data, SACCASORELACIONADO_FIELD);
    }
    get casoRelacionadoPadre() {
        return getFieldValue(this.case.data, CASORELACIONADOPADRE_FIELD);
    }
    get SAC_AltaAutomatica__c() {
        return getFieldValue(this.case.data, SACALTAUTOMATICA_FIELD);
    }
    get SAC_Entidad_Afectada__c() {
        return getFieldValue(this.case.data, SACENTIDADAFECTADA_FIELD);
    }
    get status() {
        return getFieldValue(this.case.data, STATUS_FIELD);
    }
    get SAC_SentidoResolucion__c() {
        return getFieldValue(this.case.data, SACSENTIDORESOLUCION_FIELD);
    }
    get caseRecordTypeId() {
        return getFieldValue(this.case.data, RECORDTYPEID_FIELD);
    }
    get SAC_Reclamacion__c() {
        return getFieldValue(this.case.data, SACRECLAMACIONPADRE_FIELD);
    }
    get SAC_ReclamacionPadreM2P() {
        return getFieldValue(this.case.data, SACRECLAMACIONPADREM2P_FIELD);
    }
    get SAC_M2P__c() {
        return getFieldValue(this.case.data, SACM2P_FIELD);
    }

    @wire(recuperarCasos, { caseId: '$recordId', caseRecordTypeId: '$caseRecordTypeId', reclamacionPadre: '$SAC_Reclamacion__c', recPadreEsM2P: '$SAC_ReclamacionPadreM2P', esM2P: '$SAC_M2P__c', entidadAfectada: '$SAC_Entidad_Afectada__c', sentidoResolucion: '$SAC_SentidoResolucion__c', status: '$status', casoRelacionado: '$SAC_CasoRelacionado__c' }) casos({ error, data }) {
        if (data) {
            this.mostrarAvisoM2P = data.mostrarAvisoM2P;
            this.listaAvisoM2P = data.listaAvisos;
            this.mostrarAvisoCopiaMasiva = data.mostrarAvisoCopiaMasiva;
            this.avisoCopiaMasiva = data.avisoCopiaMasiva;
        }
    };

}