public with sharing class CC_NotifSegInc {

    //Método para tratar la notificación de resolución de incidencias
    @InvocableMethod(label='Notificar cierre incidencia' description='Notificación del cierre de una incidencia')
    public static void gestionarCierreIncidencia(List<Id> listaIdTareas) {
        listaIdTareas = gestionarNotificacionesSMS(listaIdTareas);
        CC_NotifSegCaso.gestionarBatchNotificacionCliente(listaIdTareas, 'CC_NotIncidencia');
    }

    public static List<Id> gestionarNotificacionesSMS(List<Id> idsTareasIncidencia) {
        //Los casos con canal de notificación de cierre de incidencia = SMS se gestionan en este método
        List<Id> idsCasosSMS = new List<Id>();
        List<Id> idsTareasIncidenciaNoSMS = new List<Id>(idsTareasIncidencia);

        Map<Id, Id> relacionTareasCasos = new Map<Id, Id>(); //<idCaso, idTarea>>

        for (Task tarea : [SELECT WhatId FROM Task WHERE Id IN :idsTareasIncidencia]) {
            relacionTareasCasos.put(tarea.WhatId, tarea.Id);

        }

        for (Case caso : [SELECT Id FROM Case WHERE Id IN :relacionTareasCasos.keySet() AND CC_Agrupador_Id__r.CC_Notificar_Clientes__c = true AND CC_CanalNotifCli__c = 'SMS']) {
            
            //Se quita el Id de la tarea con canal SMS de la lista para que no se vuelva a gestionar fuera de este método
            idsCasosSMS.add(caso.Id);
            idsTareasIncidenciaNoSMS = quitarItemLista(idsTareasIncidenciaNoSMS, relacionTareasCasos.get(caso.Id));
        }
        enviarNotificacionesSMS(idsCasosSMS);
        return idsTareasIncidenciaNoSMS;
    }

    private static List<Id> quitarItemLista(List<Id> lista, Id item) {
        List<Id> nuevaLista = new List<Id>();
        for (Id elemento : lista) {
            if (elemento != item) {
                nuevaLista.add(elemento);
            }
        }
        return nuevaLista;
    }

    //Solo acepta listas de Ids como input
    public static void enviarNotificacionesSMS(List<Id> idsCasos) {
        
        List<Case> casos = [SELECT CC_Agrupador_Id__c, CC_MailTelfNotif__c, CC_Idioma__c FROM Case WHERE Id IN :idsCasos];
        
        List<Id> idsAgrupadores = new List<Id>();
        for (Case caso : casos) {
            idsAgrupadores.add(caso.CC_Agrupador_Id__c);
        }

        Map<Id, Map<String, String>> mapaAgrupadorPlantillas = new Map<Id, Map<String, String>>(); //<idAgrupador, <idioma, idPlantilla>>
        for (CC_PlantillaAsociada__c junctionAgrupadorPlantilla : [SELECT CC_Agrupador__c, CC_Idioma__c, CC_CuerpoNotificacion__c FROM CC_PlantillaAsociada__c WHERE CC_Agrupador__c IN :idsAgrupadores AND CC_Canal__c = 'SMS']) {
            Map<String, String> mapaIdiomaCuerpo = mapaAgrupadorPlantillas.get(junctionAgrupadorPlantilla.CC_Agrupador__c);
            if (mapaIdiomaCuerpo == null) mapaIdiomaCuerpo = new Map<String, String>();
            mapaIdiomaCuerpo.put(junctionAgrupadorPlantilla.CC_Idioma__c, junctionAgrupadorPlantilla.CC_CuerpoNotificacion__c);
            mapaAgrupadorPlantillas.put(junctionAgrupadorPlantilla.CC_Agrupador__c, mapaIdiomaCuerpo);
        }

        //Enviar notificaciones
        List<CC_Push_SMS.CC_Push_SMS_Mensaje> mensajes = new List<CC_Push_SMS.CC_Push_SMS_Mensaje>();
        for (Case caso : casos) {
            String texto = mapaAgrupadorPlantillas.get(caso.CC_Agrupador_Id__c).get(caso.CC_Idioma__c);
            if(string.isNotBlank(texto)){
                CC_Push_SMS.CC_Push_SMS_Mensaje mensaje = new CC_Push_SMS.CC_Push_SMS_Mensaje();
                mensaje.sObjectId = caso.Id;
                mensaje.destinatario = caso.CC_MailTelfNotif__c;
                mensaje.texto = texto;
                mensajes.add(mensaje);    
            }
            
        }
        CC_Push_SMS.enviarNotificacionPush(mensajes);
    }
}