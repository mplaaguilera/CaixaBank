public with sharing class SPV_LCMP_DocsEnviadosOrganismos {
   
    @AuraEnabled(cacheable=true)
    public static List<SAC_DocumentoEnvio__c> getDocsEnviadosOrg(String caseId){

        if(Schema.sObjectType.SAC_DocumentoEnvio__c.isAccessible()) {
        List<SAC_DocumentoEnvio__c> docs = [SELECT id, Name, SAC_TipoDocumento__c, SAC_Documento__c, CreatedDate FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =: caseId AND SAC_TipoDocumento__c != 'generacionDocSPV'];
        if (!docs.isEmpty()) {    
            return docs;           
        }
    }
    return null;
}

}