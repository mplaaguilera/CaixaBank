/*****************************************************************
 * Name: SAC_NotificacionesInteraccion
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Lanzar las notificaciones (campanita) del objeto SAC_Interaccion__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0            US219272         Carlos Solis     20/07/21     Creación
*****************************************************************/
public without sharing class SAC_NotificacionesInteraccion {
    /*****************************************************************
     * Proposito: Mandar notificaciones a los letrados(pretensión) de la reclamación padre en la que se encuentra el escalado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   20/07/21     Creación
    *****************************************************************/
    public static void notitifacionLetrados(List<SAC_Interaccion__c> listNew, Map<Id, SAC_Interaccion__c> mapOld) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Set<String> idsPretensiones = new Set<String>();
        Set<String> idsReclamaciones = new Set<String>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        List<Id> listaIds = new List<Id>();
        for (SAC_Interaccion__c escalado : listNew) {
            if (mapOld.containsKey(escalado.Id) && escalado.SAC_Estado__c != mapOld.get(escalado.Id).SAC_Estado__c && escalado.SAC_Estado__c == 'SAC_Atendida') {
                listaEscalados.add(escalado);
                listaIds.add(escalado.SAC_CasoEscalado__c);

                idsReclamaciones.add(escalado.SAC_CasoEscalado__c);
            }
        }

        if (!idsReclamaciones.isEmpty()) {
            Map<Id, Case> mapaReclamaciones = new Map<Id, Case>([SELECT Id, OwnerId, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.OwnerId FROM Case WHERE RecordTypeId = :recTypeReclamacion
                                                                AND SAC_Reclamacion__c IN :idsReclamaciones]);

            for (SAC_Interaccion__c escalado : listaEscalados) {
                if (mapaReclamaciones.containsKey(escalado.SAC_CasoEscalado__c)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(escalado.SAC_CasoEscalado__c,'SAC_EscaladoAtendido','El escalado ' + escalado.Name + ' ha sido atendido. Ya puede revisarlo',mapaReclamaciones.get(escalado.SAC_CasoEscalado__c).SAC_PretensionPrincipal__r.OwnerId,'','',escalado.Id);
                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
            }

            //Si tenemos alertas que enviar, se llama al método que las envía
            if (!listaWrapperAlerta.isEmpty()) {
                SAC_Alertas.generarAlertas(listaWrapperAlerta);
            }
        }
        

        

        /*List<Case> listaPretensionesInteracciones = [SELECT Id, SAC_Reclamacion__c, OwnerId FROM Case WHERE RecordTypeId = :recTypePretension
                                                    AND SAC_Reclamacion__c IN :listaIds];
        
        if (!listaPretensionesInteracciones.isEmpty()) {
            Map<Id, List<Case>> mapaPretensiones = new Map<Id, List<Case>>();
            for (Case pret : listaPretensionesInteracciones) {
                if (mapaPretensiones.containsKey(pret.SAC_Reclamacion__c)) {
                    mapaPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
                } else {
                    List<Case> listaprets = new List<Case>();
                    listaprets.add(pret);
                    mapaPretensiones.put(pret.SAC_Reclamacion__c, listaprets);
                }
            }

            for (SAC_Interaccion__c escalados : listaEscalados) {
                if (mapaPretensiones.containsKey(escalados.SAC_CasoEscalado__c)) {
                    for (Case pretension : mapaPretensiones.get(escalados.SAC_CasoEscalado__c)) {
                        idsPretensiones.add(pretension.OwnerId);
                    }
                }
            }
            
            if (!idsPretensiones.isEmpty()) {
                enviarNotificaciones(idsPretensiones, listaEscalados[0].SAC_CasoEscalado__c, listaEscalados[0].Name);
            }
        }*/
    }

    /*****************************************************************
     * Proposito: Mandar notificaciones a los usuarios introducidos por parámetro.
     * La notificación será de tipo SAC_EscaladoAtendido.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   20/07/21     Creación
    *****************************************************************/
    /*public static void enviarNotificaciones(Set<String> recipientsIds, String targetId, String nombreReclamacion) {
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                    FROM CustomNotificationType 
                                                    WHERE DeveloperName='SAC_EscaladoAtendido'];  

        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle('Escalado atendido!');
        notification.setBody('El escalado ' + nombreReclamacion + ' ha sido atendido. Ya puede revisarlo.');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);

        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            
        }
    }*/
               
}