public without sharing class SAC_LCMP_FichaDocumentoEnvio {


    @AuraEnabled
    public static String recuperarDocumento(Id documentoEnviarId){

        SAC_DocumentoEnvio__c documentoEnviar = [SELECT Id, SAC_Documento__c FROM SAC_DocumentoEnvio__c WHERE id =: documentoEnviarId LIMIT 1];

        
        if(documentoEnviar.SAC_Documento__c != null){

            return documentoEnviar.SAC_Documento__c;

        }

        return null; 
    }

}