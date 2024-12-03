/*****************************************************************
 * Name: SAC_NotificacionesBatch
 * Copyright © 2021  CaixaBank
 * ============================================================
 * Proposito: Lanzar un batch que compruebe si hay alguna reclamación que lleva 3 o 7 dias en estado negociación.
 *            De ser así, lanza una notificación a los owners de las pretensiones hijas de la reclamación avisandoles.
 *            (Si los owners de las pretensiones hermanas son distintos, también los notifica)
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US271705         Carlos Solis   20/10/21     Creación
*****************************************************************/
public with sharing class SAC_NotificacionesBatch implements Database.batchable<sObject>{

    Id recordTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    Id recordTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

    /*****************************************************************
     * Proposito: Método que se implementa de Database.batchable<sObject>.
     *            Hace una query para traer los TME que pertenezcan a reclamaciones en negociación y que están abiertas
     * ============================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271705         Carlos Solis   20/10/21     Creación
    *****************************************************************/
    public Database.QueryLocator start(Database.BatchableContext dbc) {
        return Database.getQueryLocator([SELECT Id, SAC_Caso__c, SAC_FechaInicio__c FROM SAC_TMECaso__c WHERE SAC_Caso__r.RecordTypeId = :recordTypeReclamacion
                                        AND SAC_Caso__r.Status = 'SAC_007'
                                        AND SAC_Caso__r.isClosed = false
                                        AND SAC_FechaInicio__c != null]);
    }

    /*****************************************************************
     * Proposito: Método que se implementa de Database.batchable<sObject>.
     *            Si los TME del método anterior llevan 3 o 7 dias en negociación, manda notificaciones a los owners de las pretensiones hijas de las
     *            reclamaciones a las que pertenecen dichos TME.
     * ============================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271705         Carlos Solis   20/10/21     Creación
    *****************************************************************/
    public void execute(Database.BatchableContext dbc, List<SAC_TMECaso__c> listaTMECaso){
        List<Id> listaRecTMEDias = new List<Id>();
        Map<Id, SAC_TMECaso__c> mapaRecTME3Dias = new Map<Id, SAC_TMECaso__c>();
        Map<Id, SAC_TMECaso__c> mapaRecTME7Dias = new Map<Id, SAC_TMECaso__c>();
        List<Case> listaPretensiones = new List<Case>();
        Map<Id, Map<Id, Id>> mapaReclamacionOwners = new Map<Id, Map<Id, Id>>();

        if (!listaTMECaso.isEmpty()) {
            for (SAC_TMECaso__c tme : listaTMECaso) {
                if (tme.SAC_FechaInicio__c.date().daysBetween(system.today()) == 3) {
                    listaRecTMEDias.add(tme.SAC_Caso__c);
                    mapaRecTME3Dias.put(tme.SAC_Caso__c, tme);
                } else if(tme.SAC_FechaInicio__c.date().daysBetween(system.today()) == 7) {
                    listaRecTMEDias.add(tme.SAC_Caso__c);
                    mapaRecTME7Dias.put(tme.SAC_Caso__c, tme);
                }
            }
        
            listaPretensiones = [SELECT Id, OwnerId, SAC_Reclamacion__c, SAC_Reclamacion__r.CaseNumber FROM Case
                                WHERE RecordTypeId = :recordTypePretension
                                AND SAC_Reclamacion__c IN :listaRecTMEDias];
        }

        if (!listaPretensiones.isEmpty()) {
            //Recorro lista para llenar el mapa con las reclamaciones padre y de valor otro mapa con los owners de cada pretension hija
            for (Case caso : listaPretensiones) {
                if (!mapaReclamacionOwners.containsKey(caso.SAC_Reclamacion__c)) {
                    Map<Id, Id> mapaOwners = new Map<Id, Id>();
                    mapaReclamacionOwners.put(caso.SAC_Reclamacion__c, mapaOwners);
                }
            }

            //Recoro lista de pretensiones para ir mandando las notificaciones siempre que no se haya notificado al owner de esa reclamación o pretensión (dentro de la misma familia)
            for (Case caso : listaPretensiones) {
                if (mapaRecTME3Dias.containsKey(caso.SAC_Reclamacion__c) && mapaReclamacionOwners.containsKey(caso.SAC_Reclamacion__c) && !mapaReclamacionOwners.get(caso.SAC_Reclamacion__c).containsKey(caso.OwnerId)) {
                    SAC_Notificacion.enviarNotificacion(caso.OwnerId,
                                                        caso.SAC_Reclamacion__c, 
                                                        'Negociación inactiva', 
                                                        'La reclamación ' + caso.SAC_Reclamacion__r.CaseNumber + ', que está en Negociación, lleva 3 días sin evidencia de contacto exitoso con el reclamante.');
                    mapaReclamacionOwners.get(caso.SAC_Reclamacion__c).put(caso.OwnerId, caso.OwnerId);
                } else if (mapaRecTME7Dias.containsKey(caso.SAC_Reclamacion__c) && mapaReclamacionOwners.containsKey(caso.SAC_Reclamacion__c) && !mapaReclamacionOwners.get(caso.SAC_Reclamacion__c).containsKey(caso.OwnerId)) {
                    SAC_Notificacion.enviarNotificacion(caso.OwnerId,
                                                        caso.SAC_Reclamacion__c, 
                                                        'Negociación inactiva (Recordatorio)', 
                                                        'La reclamación ' + caso.SAC_Reclamacion__r.CaseNumber + ', que está en Negociación, lleva 7 días sin evidencia de contacto exitoso con el reclamante. Valore el cierre del proceso de negociación o resolución de la reclamación para no incumplir con el SLA regulatorio.');
                    mapaReclamacionOwners.get(caso.SAC_Reclamacion__c).put(caso.OwnerId, caso.OwnerId);
                }
            }    
        }
    }

    public void finish(Database.BatchableContext dbc){
        System.debug('Done');
     }
}