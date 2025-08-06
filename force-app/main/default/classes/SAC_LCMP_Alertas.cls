/*****************************************************************
 * Name: SAC_LCMP_Alertas
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase controlador del componente sac_Alertas
 * Clase test: SAC_LCMP_Alertas_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US687443         Jose Carlos Blanco   04/08/2023   Creación
*****************************************************************/
public with sharing class SAC_LCMP_Alertas {

    private static Set<String> objetos = new Set<String>{'SAC_Alerta__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEALERTASSAC = mapRTsObjects.get('SAC_Alerta__c').get('SAC_Alerta').getRecordTypeId();
    private static final Id RECTYPEALERTASSPV = mapRTsObjects.get('SAC_Alerta__c').get('SPV_Alerta').getRecordTypeId();

    //private static final Id RECTYPEALERTASSAC = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SAC_Alerta').getRecordTypeId();

    /**************************************************************************
     * Proposito: Método para recuperar las alertas vinculadas al caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR               DATE         Description
     * 1.0            US687443         Jose Carlos Blanco   04/08/2023   Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<SAC_Alerta__c> getAlertasByCaseId(String recordId) {
    
        List<SAC_Alerta__c> listaAlertas = [SELECT Id, CreatedDate, Name, SAC_Leido__c, SAC_FechaLectura__c, SAC_LeidoPorNombre__c 
                                            FROM SAC_Alerta__c 
                                            WHERE (RecordTypeId = :RECTYPEALERTASSAC OR RecordTypeId = :RECTYPEALERTASSPV)
                                            AND SAC_Reclamacion__c = :recordId ORDER BY CreatedDate ASC];

        return listaAlertas;
    }
}