/*****************************************************************
 * Name: SAC_LCMP_AlertaEmails
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase controlador del componente sac_AlertaEmails
 * Clase test: SAC_LCMP_AlertaEmails_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US555048         Carlos Solis   08/05/2023   Creación
*****************************************************************/
public without sharing class SAC_LCMP_AlertaEmails {

    private static Set<String> objetos = new Set<String>{'SAC_Alerta__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEALERTASSAC = mapRTsObjects.get('SAC_Alerta__c').get('SAC_Alerta').getRecordTypeId();
    private static final Id RECTYPEALERTASSPV = mapRTsObjects.get('SAC_Alerta__c').get('SPV_Alerta').getRecordTypeId();

    /**************************************************************************
     * Proposito: Método para recuperar los emailMessages de las alertas vinculadas al caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US555048         Carlos Solis   08/05/23     Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<EmailMessage> getEmailMessagesByAlertaId(String recordId) {
        List<EmailMessage> listaEmailMessages = new List<EmailMessage>();
        List<SAC_Alerta__c> listaAlertas = [SELECT Id FROM SAC_Alerta__c WHERE (RecordTypeId = :RECTYPEALERTASSAC OR RecordTypeId = :RECTYPEALERTASSPV) AND SAC_Reclamacion__c = :recordId];

        if (!listaAlertas.isEmpty()) {
            listaEmailMessages = [SELECT Id, ToAddress, CreatedDate, Subject FROM EmailMessage WHERE SAC_Alerta__c IN :listaAlertas ORDER BY CreatedDate ASC];
        }

        return listaEmailMessages;
    }
}