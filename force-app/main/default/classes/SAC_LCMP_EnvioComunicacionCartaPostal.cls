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

    private static Set<String> objetos = new Set<String>{'SAC_MaestroAccionesReclamacion__c', 'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPEMAESTROACCIONES = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SAC_MaestroAcciones').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();


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
    public static String envioCartaProrroga(Id record){
        SAC_DocumentoEnvio__c carta = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:record  AND SAC_Documento__c = null AND SAC_TipoDocumento__c = 'comunicación' LIMIT 1]; 

        /*
        Ya no se utiliza, ahora sacamos la URL de visualforce directamente con la nueva clase DomainCreator
        String hostname = System.Url.getSalesforceBaseUrl().getHost();
        String myDomain = hostname.split('\\.')[0];
        */
        Case caso = [SELECT Id, SAC_CasoEspecial__c, CC_Canal_Procedencia__c FROM Case WHERE Id =: record];
        string maestroTarea = '';

        String vfHostname = DomainCreator.getVisualforceHostname(null);
        String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=' + carta.Id;
        SAC_GeneracionCartas.adjuntarPDFaCaso2(urlVF, record, 'comunicación');

        SAC_LCMP_UpdateStatus.prorroga(record);

        if(caso.SAC_CasoEspecial__c == 'SAC_Presidencia'){
            maestroTarea = 'SAC_ImprimirCartasAD';
        }else if(caso.CC_Canal_Procedencia__c == 'Castilla la Mancha' || caso.CC_Canal_Procedencia__c == 'Junta Andalucia'){
            maestroTarea = 'SAC_ImprimirCartasJACM';
        }else{
            maestroTarea = 'SAC_ImprimirCartasOrdinario';
        }
        //US1101520 crear tarea al subsanar por carta postal
        SAC_MaestroAccionesReclamacion__c maestroTareaAutomatica = [SELECT Id, Name FROM SAC_MaestroAccionesReclamacion__c WHERE RecordTypeId = :RECTYPEMAESTROACCIONES AND SAC_Activo__c = true AND SAC_DeveloperName__c = :maestroTarea LIMIT 1];  

        SAC_Accion__c tarea = new SAC_Accion__c();

        tarea.SAC_MaestroAccionesReclamacion__c = maestroTareaAutomatica.Id;
        tarea.RecordTypeId = RECTYPEMAESTROTAREAS;
        tarea.SAC_Reclamacion__c = record;
        
        try {
            if (!Schema.sObjectType.SAC_Accion__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realizar esta accion.' ); }
            SAC_DatabaseDML.insertDML(tarea, true);
        } catch (Exception e) {
            CBK_log.error(e);
        }

        // FALLA POR List has more than 1 row for assignment to SObject ya que recupera la carta del acuse de recibo y la del envio de subsanacion
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: record order by CreatedDate DESC LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = tarea.Id;
        cdl.ShareType = 'I';

        SAC_DatabaseDML.insertDML(cdl, true);

        return tarea.Id;

    }
}