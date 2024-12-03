/***************************************************************************
 * @description Name: SAC_NotificacionesProrrogaAutomatica
 * Copyright © 2021  CaixaBank
 * =========================================================================
 * Proposito: Lanzar las notificaciones (campanita) de 
 * las prorrogas
 * =========================================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0            US254503         Esteve Llaó      23/08/2021   Creación
***************************************************************************/
public with sharing class SAC_NotificacionProrrogaAutomatica {
    /***************************************************************************  
     * @description Proposito: Mandar notificaciones a los letrados(pretensión) 
     * de la reclamación padre en la que se encuentra el escalado
     * =========================================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US254503         Esteve Llaó    23/08/2021   Creación
    ***************************************************************************/
    public static void notificacionProrrogaAutomatica(List<Case> listNew, Map<Id, Case> mapOld) {

        Map<id, set<String>> mapaCasos = new map <id, set <String>>();
        List <Case> misPretensiones = new List<Case>();

        for (case pretensiones : listNew) {
            if (mapOld.containsKey(pretensiones.Id) 
                && pretensiones.OS_Alerta_Descripcion__c != mapOld.get(pretensiones.Id).OS_Alerta_Descripcion__c 
                && pretensiones.OS_Alerta_Descripcion__c == 'Prorrogado') {

                misPretensiones.add(pretensiones);
            }                   
        }

        for (case pretension : misPretensiones){
            if (mapaCasos.containsKey(pretension.OwnerId)){
                set<string> auxiliarList = mapaCasos.get(pretension.OwnerId);
                auxiliarList.add(pretension.SAC_Reclamacion__c);
                mapaCasos.put(pretension.OwnerId, auxiliarList);              
            }
            else{
                set<string> auxiliarList = new set<string>();
                auxiliarList.add(pretension.SAC_Reclamacion__c);
                mapaCasos.put(pretension.OwnerId, auxiliarList);  
            }
        }
        enviarNotificaciones(mapaCasos);
    }

    /******************************************************************************
     * @description Proposito: Mandar notificaciones a los propietarios de las pretensiones
     * prorrogadas
     * ============================================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US254503         Esteve Llaó    23/08/2021   Creación
    ******************************************************************************/
    public static void enviarNotificaciones(Map<Id, set<String>> data) {
        CustomNotificationType notificationType = new CustomNotificationType();
        if(Schema.sObjectType.CustomNotificationType.isAccessible()) {
            notificationType = [SELECT Id, DeveloperName 
                                                    FROM CustomNotificationType 
                                                    WHERE DeveloperName='SAC_NotificacionProrrogaAutomatica'];  
        }
        

        for(Id key : data.keySet()){ 
            set<String> casos = data.get(key);
            set<String> setIds = new set<String>();
            setIds.add(key);
             
            for(String reclamacion : casos){ 
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                
                notification.setTitle('El caso ha sido prorrogado');
                notification.setBody('El caso ' + reclamacion + ' ha sido prorrogado. Ya puede revisarlo.');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(reclamacion);

                try {
                    notification.send(setIds);
                }
                catch (Exception e) {
                    List<Object> detalle = new List<Object>();
                    detalle.add((Object)notification);
                    CBK_Log.error(e, detalle);
                }

            }
        }

    }            
}