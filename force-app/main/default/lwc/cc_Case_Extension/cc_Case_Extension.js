import {LightningElement, api, wire} from 'lwc';

import getCaseExtensionIdApex from '@salesforce/apex/CC_CaseExtensionController.getCaseExtensionId';
import ESTADO_ONB from '@salesforce/schema/CBK_Case_Extension__c.CC_EstadoONB__c';
import SUBESTADO_ONB from '@salesforce/schema/CBK_Case_Extension__c.CC_SubestadoONB__c';
import EMPRESA_ONB from '@salesforce/schema/CBK_Case_Extension__c.CC_EmpresaONB__c';
import FECHA_ESTADO_ONB from '@salesforce/schema/CBK_Case_Extension__c.CC_FechaEstadoONB__c';
import MOTIVO_CIERRE_ONB from '@salesforce/schema/CBK_Case_Extension__c.CC_MotivoCierreONB__c';
import NUMSR_ONB from '@salesforce/schema/CBK_Case_Extension__c.CC_NumSR__c';

export default class Cc_Case_Extension extends LightningElement {
    
    campos = [NUMSR_ONB, FECHA_ESTADO_ONB, ESTADO_ONB, EMPRESA_ONB, SUBESTADO_ONB, MOTIVO_CIERRE_ONB];
    @api recordId;

    caseExtensionId;

    @wire(getCaseExtensionIdApex, {recordId: '$recordId'})
    wiredCaseExtension({data, error}) {
        if (data) {
            this.caseExtensionId = data;
        } else if (error) {
            console.error(error);
        }
    }
}