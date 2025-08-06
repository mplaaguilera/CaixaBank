public with sharing class OB_Llamada {

    public class DefaultException extends Exception {}

    public static CC_Llamada__c crearLlamada(String recordTypeDeveloperName, Map<String, Object> campos) {
        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', recordTypeDeveloperName);
        if (campos != null) {
            for (String campo : campos.keySet()) {
                llamada.put(campo, campos.get(campo));
            }
        }
        insert llamada;
        return llamada;
    }

    public static void accionesCambioPropietario(List<Id> idLlamadas) {
        List<Task> tareasCambioPropietario = new List<Task>();
        for (CC_Llamada__c llamada : [SELECT Owner.Name FROM CC_Llamada__c WHERE Id IN :idLlamadas]) {
            Map<String, Object> camposTarea = new Map<String, Object>();
            camposTarea.put('Type', 'Cambio de propietario');
            camposTarea.put('Subject', 'Reasignada a ' + llamada.Owner.Name);
            camposTarea.put('Status', 'Completed');
            tareasCambioPropietario.add(OB_Activity.crearActividad(llamada.Id, camposTarea, false));
        }
        insert tareasCambioPropietario;
    }

    public static void accionesValidar(List<Id> idLlamadas) {
        List<Task> tareasValidar = new List<Task>();
        for (Id idLlamada : idLlamadas) {
            Map<String, Object> camposTarea = new Map<String, Object>();
            camposTarea.put('Type', 'Validada');
            camposTarea.put('Subject', 'Validada');
            camposTarea.put('Status', 'Completed');
            tareasValidar.add(OB_Activity.crearActividad(idLlamada, camposTarea, false));
        }
        insert tareasValidar;
    }

    public static void accionesRechazar(List<Id> idLlamadas) {
        List<Task> tareasRechazar = new List<Task>();
        for (CC_Llamada__c llamada : [SELECT OB_Motivo_Rechazo__c FROM CC_Llamada__c WHERE Id IN :idLlamadas]) {
            Map<String, Object> camposTarea = new Map<String, Object>();
            camposTarea.put('Type', 'Rechazada');
            camposTarea.put('Subject', 'Rechazada');
            camposTarea.put('Description', 'Motivo del rechazo: ' + llamada.OB_Motivo_Rechazo__c);
            camposTarea.put('Status', 'Completed');
            tareasRechazar.add(OB_Activity.crearActividad(llamada.Id, camposTarea, false));
        }
        insert tareasRechazar;
    }

    @AuraEnabled
    public static void envioGdd(List<Id> idLlamadas) {
        List<OB_Parametrizacion__c> relacionesCampanyaProducto = [SELECT OB_Parametrizacion_Padre__c, OB_Parametrizacion_Relacionada__c
                                                                    FROM OB_Parametrizacion__c
                                                                    WHERE RecordType.DeveloperName = 'OB_Relacion_Campanya_Producto'
                                                                    AND OB_Envio_GDD__c = TRUE];

        List<CC_Llamada__c> llamadas = [SELECT OB_Campanya_Id__c, OB_Producto_Id__c, OB_No_Quiere_Telemarketing__c
                                        FROM CC_Llamada__c WHERE Id IN :idLlamadas];
        List<Task> tareasEnvioGdd = new List<Task>();

        for (CC_Llamada__c llamada : llamadas) {
            Boolean enviarLlamadaGdd = false;

            if (llamada.OB_No_Quiere_Telemarketing__c) {
                enviarLlamadaGdd = true;
            } else {
                for (OB_Parametrizacion__c relacionCampanyaProducto : relacionesCampanyaProducto) {
                    if (relacionCampanyaProducto.OB_Parametrizacion_Padre__c == llamada.OB_Campanya_Id__c
                    && relacionCampanyaProducto.OB_Parametrizacion_Relacionada__c == llamada.OB_Producto_Id__c) {
                        enviarLlamadaGdd = true;
                        break;
                    }
                }
            }

            if (enviarLlamadaGdd) {
                llamada.OB_Marca_Envio_Gdd__c = System.today();
                Map<String, Object> camposTarea = new Map<String, Object>();
                camposTarea.put('Type', 'Envío a GDD');
                camposTarea.put('Subject', 'Envío a GDD');
                camposTarea.put('Status', 'Completed');
                tareasEnvioGdd.add(OB_Activity.crearActividad(llamada.Id, camposTarea, false));
            }
        }
        update llamadas;
        insert tareasEnvioGdd;
    }

    @future
    public static void enviarCorreo(List<Id> idLlamadas, String nombrePlantilla) {
        if (String.isNotBlank(nombrePlantilla)) {
            Id idBuzonOutboundSalida = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Outbound - Salida'].Id;
            Id idPlantilla;
            if (!Test.isRunningTest()) {
                idPlantilla = [SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = 'OB_Plantillas' AND Name = :nombrePlantilla LIMIT 1].Id;
            } else {
                idPlantilla = [SELECT Id FROM EmailTemplate WHERE Name = :nombrePlantilla LIMIT 1].Id;
            }
            List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();
            for (CC_Llamada__c llamada : [SELECT OB_Direccion_Correo__c FROM CC_Llamada__c WHERE Id IN :idLlamadas]) {
                if (String.isNotBlank(llamada.OB_Direccion_Correo__c)) {
                    Messaging.SingleEmailMessage correo = Messaging.renderStoredEmailTemplate(idPlantilla, null, llamada.Id);
                    correo.setWhatId(llamada.Id);
                    correo.setOrgWideEmailAddressId(idBuzonOutboundSalida);
                    correo.setTemplateId(idPlantilla);
                    correo.setToAddresses(new List<String>{llamada.OB_Direccion_Correo__c});
                    correos.add(correo);
                }
            }
            Messaging.sendEmail(correos);
        }
    }

    @future(callout=true)
    public static void enviarSms(List<Id> idLlamadas, String nombrePlantilla) {
        EmailTemplate textoSms;
        if (!Test.isRunningTest()) {
            textoSms = [SELECT HtmlValue FROM EmailTemplate
                        WHERE Folder.DeveloperName = 'OB_Plantillas' AND Name = :nombrePlantilla];
        }

        List<CC_Push_SMS.CC_Push_SMS_Mensaje> mensajesSms = new List<CC_Push_SMS.CC_Push_SMS_Mensaje>();
        for (CC_Llamada__c llamada : [SELECT OB_Telefono__c FROM CC_Llamada__c WHERE Id IN :idLlamadas]) {
            CC_Push_SMS.CC_Push_SMS_Mensaje mensajeSms = new CC_Push_SMS.CC_Push_SMS_Mensaje();
            mensajeSms.sObjectId = llamada.Id;
            mensajeSms.destinatario = llamada.OB_Telefono__c;
            if (!Test.isRunningTest()) {
                mensajeSms.idPlantilla = textoSms.Id;
            } else {
                mensajeSms.texto = 'cuerpo de la plantilla';
            }
            mensajesSms.add(mensajeSms);
        }
        CC_Push_SMS.enviarNotificacionPush(mensajesSms);
    }

    /* @AuraEnabled
    public static String urlGrabacion(Id idLlamada) {
        String ticketOcp = [SELECT CBK_Ticket_OCP__c FROM CC_Llamada__c WHERE Id = :idLlamada].CBK_Ticket_OCP__c;

        CC_InterfaceSettings__mdt cfg = [SELECT CC_EndPoint__c, CC_OCP_Aplicacion__c, CC_OCP_Usuario__c, CC_OCP_Canal__c
                                            FROM CC_InterfaceSettings__mdt WHERE DeveloperName = 'CC_Int_OCP' AND CC_Activa__c = TRUE];

        String url = cfg.CC_EndPoint__c + ticketOcp;

        system.debug(base64(cfg.CC_OCP_Aplicacion__c + ':' + cfg.CC_OCP_Usuario__c + ':' + cfg.CC_OCP_Canal__c));
        url += '/?auth=' + base64(cfg.CC_OCP_Aplicacion__c + ':' + cfg.CC_OCP_Usuario__c + ':' + cfg.CC_OCP_Canal__c);
        url += '&validacion=' + base64(
            'idDoc:' + ticketOcp + ';appId:' + cfg.CC_OCP_Aplicacion__c + ';username:' + cfg.CC_OCP_Usuario__c + ';timestamp:' + (System.now().getTime() / 1000).intValue()
        );
        return url;
    } */

    @AuraEnabled
    public static Map<String, String> datosUrlGrabacion(Id idLlamada) {

        String ticketOcp = [SELECT CBK_Ticket_OCP__c FROM CC_Llamada__c WHERE Id = :idLlamada].CBK_Ticket_OCP__c;

        CC_InterfaceSettings__mdt cfg = [SELECT CC_EndPoint__c, CC_OCP_Aplicacion__c, CC_OCP_Usuario__c, CC_OCP_Canal__c,CC_Body__c
                                            FROM CC_InterfaceSettings__mdt WHERE DeveloperName = 'CC_Int_OCP' AND CC_Activa__c = TRUE];

        Map<String, String> datosMap = new Map<String, String>();
        datosMap.put('tiquet', ticketOcp);
        datosMap.put('appid', cfg.CC_OCP_Aplicacion__c);
        datosMap.put('username', cfg.CC_OCP_Usuario__c);
        datosMap.put('canal', cfg.CC_OCP_Canal__c);
        datosMap.put('publicKey', cfg.CC_Body__c);
        datosMap.put('baseUrl', cfg.CC_EndPoint__c + ticketOcp);
        datosMap.put('timestamp', System.now().format('yyyyMMddHHmmss'));
        return datosMap;
    }

    private static String base64(String texto) {
        return EncodingUtil.base64Encode(Blob.valueOf(texto));
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, Map<String, Object>> erroresLlamada(Id idLlamada) {
        Map<Id, Map<String, Object>> retorno = new Map<Id, Map<String, Object>>();
        for (Task tarea : [SELECT CreatedDate, Subject, Description FROM Task WHERE WhatId = :idLlamada AND Type = 'Error' ORDER BY CreatedDate ASC]) {
            retorno.put(tarea.Id, new Map<String, Object>{
                'Id' => tarea.Id,
                'CreatedDate' => tarea.CreatedDate.format(),
                'Subject' => tarea.Subject,
                'errores' => tarea.Description.split('\n')
            });
        }
        return retorno;
    }
}