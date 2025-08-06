/**
* @description       : 
* @group             : 
* @last modified on  : 03-29-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   03-29-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class SEG_Auditoria_BI_TRHan extends CC_TriggerHandlerBase{
    /**
    * @description   Método principal del trigger.
    * param tp -> Contexto del trigger.
    */ 
    public override void mainEntry(CC_TriggerParameters tp) {
        system.debug('SEG_Auditoria__c TRHAN');
        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId();
        List<SEG_Auditoria__c> segAuditorias = new List<SEG_Auditoria__c>();

        for(SEG_Auditoria__c aud : (List<SEG_Auditoria__c>)tp.newList){
            if(aud.RecordTypeId == recordTypeSEG){
                segAuditorias.add(aud);
            }
        }

        if(!segAuditorias.isEmpty()){
            process(segAuditorias, (Map<ID, SEG_Auditoria__c>)tp.newMap);
        }
    }
    private void process(List<SEG_Auditoria__c> listNewObj, Map<ID, SEG_Auditoria__c> mapObj)
    {
        setNifAndDateAuditorias(listNewObj);
        concatFechaNif(listNewObj);
    }
    
    private void setNifAndDateAuditorias (List<SEG_Auditoria__c> listNewObj)
    {
        Set<Id> casId = New Set<Id>();
        for(SEG_Auditoria__c audits:listNewObj)
        {
            if(audits.SEG_NumeroSR__c != null){
                casId.add(audits.SEG_NumeroSR__c);
            }
        }
        
        Map<Id, Case> caseMap = new Map<Id,Case>([SELECT Id,Account.CC_Numero_Documento__c FROM Case WHERE Id IN :casId]);
        for(SEG_Auditoria__c auditorias:listNewObj)
        {
            auditorias.SEG_FAuditoria__c = auditorias.SEG_FechaAuditoriaFormato__c;
            if(caseMap.get(auditorias.SEG_NumeroSR__c).Account.CC_Numero_Documento__c != null && auditorias.SEG_NIF__c == null){
                auditorias.SEG_NIF__c = caseMap.get(auditorias.SEG_NumeroSR__c).Account.CC_Numero_Documento__c;                
            }
        }
    }

    public static void concatFechaNif(List<SEG_Auditoria__c> listNewObj) {
        for (SEG_Auditoria__c auditoria : listNewObj) {
            if(auditoria.SEG_FechaAuditoriaFormato__c != null ){
                String fechaAuditoria = '';
                if(auditoria.SEG_NIF__c != null ){
                    fechaAuditoria = fechaAuditoria + auditoria.SEG_NIF__c;
                }
                auditoria.NIF_FechaAuditoria__c = fechaAuditoria + String.valueOf(auditoria.SEG_FechaAuditoriaFormato__c);
            }
        }
    }
}