public with sharing class CC_Push_SMS {

    public class CC_Push_SMS_Mensaje {
        public Id sObjectId {get;set;}
        public String destinatario {get;set;}
        public String texto {get;set;}
        public Id idPlantilla {get;set;}
        public String tipoTarea {get;set;}
        public String asuntoTarea {get;set;}
    }

    @AuraEnabled
    public static String enviarNotificacionPush(Id sObjectId, String destinatario, String texto) {
        //Envío de notificación con los parámetros indicados
        CC_Push_SMS.CC_Push_SMS_Mensaje mensaje = new CC_Push_SMS.CC_Push_SMS_Mensaje();
        mensaje.sObjectId = sObjectId;
        mensaje.destinatario = destinatario;
        mensaje.texto = texto;
        return enviarNotificacionPush(mensaje);
    }

    public static String enviarNotificacionPush(CC_Push_SMS_Mensaje mensaje) {
        //Envío de la notificación indicada
        List<CC_Push_SMS.CC_Push_SMS_Mensaje> mensajes = new List<CC_Push_SMS.CC_Push_SMS_Mensaje>();
        mensajes.add(mensaje);
        List<String> resultados = enviarNotificacionPush(mensajes);
        return resultados[0];
    }

    public static List<String> enviarNotificacionPush(List<CC_Push_SMS.CC_Push_SMS_Mensaje> mensajes) {
        //Envío de las notificaciones indicadas
        List<String> resultados = new List<String>();

        //Se recuperan los parámetros para la integración con la aplicación MCD según el entorno
        //CC_InterfaceSettings__mdt parametrosInterfaz = obtenerParametrosIntegracion('CC_MCD');

        List<Task> tareasCasos = new List<Task>();

        for (CC_Push_SMS.CC_Push_SMS_Mensaje mensaje : mensajes) {
            //Envío de la solicitud a la aplicación MCD
            // HttpRequest req = new HttpRequest();
            // req.setEndpoint(parametrosInterfaz.CC_EndPoint__c);
            // req.setClientCertificateName(parametrosInterfaz.CC_Certificado__c);
            // req.setMethod(parametrosInterfaz.CC_TipoPeticion__c);
            // req.setHeader('Content-Type', parametrosInterfaz.CC_ContentType__c);

            String cuerpo = cuerpoMensaje(mensaje);
            String idUnicoPeticion = '050' + ('SFDC_Push_' + System.now().format('yyyyMMddHHmmss') + mensaje.destinatario).rightPad(50, ' ');

            //Los datos de la solicitud viajan en el tag <daveve> con el siguiente formato
            // Inicio tag <dadeve>  Destinatario        Cuerpo del mensaje             Id solicitante Identificador solicitud                                     Fin tag <dadeve>"
            //"CAN00001010X         TLF00001009638877746TXT00001020PRUEBA DEL MARTES 20IDI00001003002CLAU0O01050MCDW5150H8I20092011083347153649774313             99999999000"
            String valorTagDadeve = 'CAN00001010X         ';
            valorTagDadeve += 'TLF00001009' + mensaje.destinatario.right(9);
            valorTagDadeve += 'TXT00001' + String.valueOf(cuerpo.length()).leftPad(3, '0') + cuerpo;
            valorTagDadeve += 'IDI00001003002';
            valorTagDadeve += 'CLAU0O01' + idUnicoPeticion;
            valorTagDadeve += '99999999000';
            // system.debug('valorTagDadeve --->' + valorTagDadeve);
            // String payload = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://servicioexternoenviosws.alertasfinancenvios.mca.si.absis.lacaixa.es/">';
            // payload += '<soapenv:Header></soapenv:Header>';
            // payload += '<soapenv:Body>';
            // payload += '<ser:ProcesarEvento>';
            // payload += '<externalInputTO>';
            // payload += '<codeve>CBCC00000338000</codeve>';
            // payload += '<dadeve>' + valorTagDadeve + '</dadeve>';
            // payload += '</externalInputTO>';
            // payload += '</ser:ProcesarEvento>';
            // payload += '</soapenv:Body>';
            // payload += '</soapenv:Envelope>';
            // req.setBody(payload);

            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

            String body = '{"event":"00CCSP001                                                     CBCC00000338000..' + valorTagDadeve + '"}';

            CBK_HttpServiceIntegration.RequestWapper integracion= new CBK_HttpServiceIntegration.RequestWapper();
            integracion.body=body;
            integracion.intSetting= 'CC_Envio_SMS';
            integracion.method = 'POST';
            integracion.mHeaders = mHeaders;
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);


            Boolean errorHttpSend = false;
            try {
                HTTPResponse respuesta = CBK_HttpServiceIntegration.multiCallHttpService(request, 'CC_Envio_SMS', 'CC_Envio_SMS');

                // List<String> errores = obtenerErrores(respuesta?.getBody());
                if (respuesta.getStatusCode() != 200) {
                    resultados.add('KO: ' + respuesta.getBody());
                } else {
                    resultados.add('OK');
                }
            } catch (Exception e) {
                errorHttpSend = true;
                CBK_Log.error(e);
                resultados.add('KO: ' + e.getMessage());
            }

            //Nueva actividad de tipo 'Notificación - Salida' hija del registro indicado en sObjectId
            if (mensaje.sObjectId != null) {
                String prefijoRT;
                if (mensaje.sObjectId.getSobjectType() == Schema.Case.getSObjectType()) {
                    //Tareas de casos (CC o COPS): el RT de las tareas se deduce del RT del caso
                    prefijoRT = [SELECT RecordType.DeveloperName FROM Case
                                    WHERE Id = :mensaje.sObjectId].RecordType.DeveloperName.substringBefore('_');
                    Task tarea = new Task();
                    tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', prefijoRT + '_Task');
                    tarea.WhatId = mensaje.sObjectId;
                    tarea.Type = 'Notificación - Salida';
                    tarea.ActivityDate = System.today();
                    tarea.Status = 'Completed';
                    tarea.Subject = 'Envío de notificación al número ' + mensaje.destinatario;
                    tarea.Description = cuerpo;
                    tareasCasos.add(tarea);
                } else if (mensaje.sObjectId.getSobjectType() == Schema.Opportunity.getSObjectType()) {
                    //Tareas de oportunidades (CSBD): el RT de las tareas de CSBD es el mismo que para CC
                    CSBD_Activity.crearActividad(
                        mensaje.sObjectId,
                        String.isNotBlank(mensaje.tipoTarea) ? mensaje.tipoTarea : 'Notificación - Salida',
                        'Completed',
                        String.isNotBlank(mensaje.asuntoTarea) ? mensaje.asuntoTarea : 'Envío de notificación al número ' + mensaje.destinatario,
                        mensaje.texto
                    );
                } else if (mensaje.sObjectId.getSobjectType() == Schema.CC_Llamada__c.getSObjectType()) {
                    prefijoRT = [SELECT RecordType.DeveloperName FROM CC_Llamada__c
                                    WHERE Id = :mensaje.sObjectId].RecordType.DeveloperName.substringBefore('_');
                    if (prefijoRT == 'OB') {
                        //Llamada Outbound
                        Map<String, Object> camposTarea = new Map<String, Object>();
                        camposTarea.put('Type', 'Envío de SMS');
                        camposTarea.put('Subject', 'Envío de SMS a ' + mensaje.destinatario);
                        camposTarea.put('Description', cuerpo);
                        camposTarea.put('Status', 'Completed');
                        OB_Activity.crearActividad(mensaje.sObjectId, camposTarea);
                    }
                }
            }
        }

        CBK_HttpServiceIntegration.registroTrazaIntegracion();
        
        if (!tareasCasos.isEmpty()) {
            CC_Activity.crearActividades(tareasCasos);
        }
        
        return resultados;
    }

    // @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts, PMD.CognitiveComplexity')
    // private static List<String> obtenerErrores(String respuesta) {
    //     if (String.isEmpty(respuesta)) {
    //         return new List<String>{'No ha sido posible recuperar el resultado del envío.'}; 
    //     } 

    //     List<String> errores = new List<String>();

    //     DOM.Document docXML = new DOM.Document();
    //     docXML.load(respuesta);
    //     DOM.XmlNode root = docXML.getRootElement();

    //     if (root.getNodeType() == DOM.XMLNodeType.ELEMENT) {
    //         for (DOM.XmlNode nodoRoot : root.getChildElements()) {
    //             if (nodoRoot.getName() == 'Body') {
    //                 for (DOM.XmlNode nodoBody : nodoRoot.getChildElements()) {
    //                     if (nodoBody.getName() == 'ProcesarEventoResponse') {
    //                         for (DOM.XmlNode nodoProcesarEventoResponse : nodoBody.getChildElements()) {
    //                             if (nodoProcesarEventoResponse.getName() == 'return') {
    //                                 for (DOM.XmlNode nodoReturn : nodoProcesarEventoResponse.getChildElements()) {
    //                                     if (nodoReturn.getName() == 'datosError') {
    //                                         //Es un error, se añade a la lista de salida
    //                                         String codigoError = '';
    //                                         String mensajeError = '';

    //                                         for (DOM.XmlNode atributoError : nodoReturn.getChildElements()) {
    //                                             if (atributoError.getName() == 'codigoError') {
    //                                                 codigoError = atributoError.getText();
    //                                             }

    //                                             if (atributoError.getName() == 'mensajeError') {
    //                                                 mensajeError = atributoError.getText();
    //                                             }
    //                                         }

    //                                         if (String.isNotBlank(codigoError) || String.isNotBlank(mensajeError)) {
    //                                             errores.add(codigoError + ' - ' + mensajeError);
    //                                         }
    //                                     }
    //                                 }
    //                             }
    //                         }
    //                         break;
    //                     }
    //                 }
    //                 break;
    //             }
    //         }
    //     }
    //     return errores;
    // }

    // private static CC_InterfaceSettings__mdt obtenerParametrosIntegracion(String interfazDevName) {
    //     List<CC_InterfaceSettings__mdt> parametrosInterfaz = [SELECT DeveloperName, CC_Certificado__c, CC_Endpoint__c, CC_TipoPeticion__c, CC_ContentType__c
    //                                                             FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :interfazDevName AND CC_Activa__c = true LIMIT 1];
    //     CC_InterfaceSettings__mdt resultado = null;
    //     if (!parametrosInterfaz.isEmpty()) {
    //         resultado = parametrosInterfaz[0];
    //     }
    //     return resultado;
    // }

    private static String cuerpoMensaje(CC_Push_SMS_Mensaje mensaje) {
        String cuerpoMensaje;
        if (String.isNotBlank(mensaje.sObjectId) && String.isNotBlank(mensaje.idPlantilla)) {
            cuerpoMensaje = Messaging.renderStoredEmailTemplate(mensaje.idPlantilla, UserInfo.getUserId(), mensaje.sObjectId).getHtmlBody();
        }
        if (String.isBlank(cuerpoMensaje)) {
            cuerpoMensaje = mensaje.texto;
        }
        return cuerpoMensaje.stripHtmlTags().left(160);
    }
}