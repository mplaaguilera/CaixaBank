import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import DOCUMENTOENVIO from '@salesforce/schema/SAC_DocumentoEnvio__c';
import getDocsEnviadosOrg from '@salesforce/apex/SPV_LCMP_DocsEnviadosOrganismos.getDocsEnviadosOrg';


const columns = [
    { label: 'Fecha', fieldName: 'CreatedDate', type: 'date',
    typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    }},
    { label: 'Título', fieldName: 'Name', type: 'text' },
    { label: 'Tipo Documento', fieldName: 'SAC_TipoDocumento__c', type: 'text' },
    { label: 'Enviado a', fieldName: 'SAC_Documento__c', type: 'text' }
];
export default class Spv_DocsEnviadosOrganismos extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track documentos;
    @track wiredgetDocsEnviadosOrg;

    @wire(getRecord, { recordId: '$recordId' })
    wiredGetRecord;

    @wire(getObjectInfo, {objectApiName: DOCUMENTOENVIO})
    objectInfo;

    @wire(getDocsEnviadosOrg, { caseId: '$recordId'})
    wiredgetDocsEnviadosOrg(result){
        this.wiredgetDocsEnviadosOrg = result;
        if(result.data){
            this.documentos = result.data;
        }
    }

    handleRefreshClick() {
        return refreshApex(this.wiredgetDocsEnviadosOrg);
    }

    get columns() {
        return columns;
    }
}