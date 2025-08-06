import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import MCCDETALLE_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_CasoEscalado__r.SEG_Detalle__r.Name';
import MCCTEMATICA_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_CasoEscalado__r.CC_MCC_Tematica__r.Name';
import MCCMOTIVO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_CasoEscalado__r.CC_MCC_Motivo__r.Name';
import MCCPRODUCTO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SAC_CasoEscalado__r.CC_MCC_ProdServ__r.Name';
import INTERACCION_OBJECT from '@salesforce/schema/SAC_Interaccion__c';


const fields = [MCCDETALLE_FIELD, MCCTEMATICA_FIELD, MCCMOTIVO_FIELD, MCCPRODUCTO_FIELD];

export default class SAC_InfoMCCInteraccion extends LightningElement {
    @api recordId;

    @wire (getObjectInfo, {objectApiName: INTERACCION_OBJECT})
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields})
    interaccion;

    get mccDetalle() {
        return getFieldValue(this.interaccion.data, MCCDETALLE_FIELD);
    }
    
    get mccTematica() {
        return getFieldValue(this.interaccion.data, MCCTEMATICA_FIELD);
    }
    
    get mccMotivo() {
        return getFieldValue(this.interaccion.data, MCCMOTIVO_FIELD);
    }
    
    get mccProducto() {
        return getFieldValue(this.interaccion.data, MCCPRODUCTO_FIELD);
    }


}