/*****************************************************************
 * Name: SAC_LCMP_EnvioComunicacionCartaPostal
 * Copyright © 2021  CaixaBank
 * 
 *          Esta clase se testea con SAC_LCMP_EnvioComun_Test
 * 
 * Historial
 * -------
*****************************************************************/



public without sharing class SAC_LCMP_EnvioComunicacionCartaPostal {
    
    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    
    @AuraEnabled
    public static SAC_LCMP_EnvioCartaPostal.WrappedInfo getInfoPostal(String caseId){
        SAC_LCMP_EnvioCartaPostal.WrappedInfo result = SAC_LCMP_EnvioCartaPostal.getInfoPostal(caseId);
        return result;
    }


    @AuraEnabled
    public static void envioCarta(Id record){
        SAC_DocumentoEnvio__c carta = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:record  AND SAC_Documento__c = null AND SAC_TipoDocumento__c = 'comunicación' LIMIT 1]; 

        /*
        Ya no se utiliza, ahora sacamos la URL de visualforce directamente con la nueva clase DomainCreator
        String hostname = System.Url.getSalesforceBaseUrl().getHost();
        String myDomain = hostname.split('\\.')[0];
        */

        String vfHostname = DomainCreator.getVisualforceHostname(null);
        String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=' + carta.Id;
        SAC_GeneracionCartas.adjuntarPDFaCaso2(urlVF, record, 'comunicación');

        //SAC_LCMP_UpdateStatus.prorroga(record);
    }


    @AuraEnabled
    public static void envioCartaProrroga(Id record){
        SAC_DocumentoEnvio__c carta = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:record  AND SAC_Documento__c = null AND SAC_TipoDocumento__c = 'comunicación' LIMIT 1]; 

        /*
        Ya no se utiliza, ahora sacamos la URL de visualforce directamente con la nueva clase DomainCreator
        String hostname = System.Url.getSalesforceBaseUrl().getHost();
        String myDomain = hostname.split('\\.')[0];
        */

        String vfHostname = DomainCreator.getVisualforceHostname(null);
        String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=' + carta.Id;
        SAC_GeneracionCartas.adjuntarPDFaCaso2(urlVF, record, 'comunicación');

        SAC_LCMP_UpdateStatus.prorroga(record);
    }
}