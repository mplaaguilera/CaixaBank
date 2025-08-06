public with sharing class CC_WS_PushSMS {
    public class CC_WS_PushSMS_Mensaje {
        public Id sObjectId {get;set;}
        public String destinatario {get;set;} //numPerso del account
        public String texto {get;set;}
        public Id idPlantilla {get;set;}
        public String tipoTarea {get;set;}
        public String asuntoTarea {get;set;}
        public String tipologia {get;set;} //0000001 0000002 0000003 0000004 0000005 0000006
        public String idioma {get;set;} //es (español) ca (catalan) eu (euskera) ga (Gallego) va (Valenciano) en (Ingles)
        public String entidad {get;set;} //CaixaBank o Imagin. El campo AV_IndicadoresClientes__c del Account nos indica si es cliente caixaBank o imagin. Si contiene 28 es Imagin. De lo contrario, CaixaBank.
    }

    @AuraEnabled
    public static String enviarNotificacionPush(Id sObjectId, String destinatario, String tipologia, String idioma, String entidad) {
        //Envío de notificación con los parámetros indicados
        CC_WS_PushSMS.CC_WS_PushSMS_Mensaje mensaje = new CC_WS_PushSMS.CC_WS_PushSMS_Mensaje();
        mensaje.sObjectId = sObjectId;
        mensaje.destinatario = destinatario;
        mensaje.tipologia = tipologia;
        mensaje.idioma = idioma;
        mensaje.entidad = entidad.contains('28') ? 'Imagin' : 'CaixaBank';
        return enviarNotificacionPush(mensaje);
    }

    public static String enviarNotificacionPush(CC_WS_PushSMS_Mensaje mensaje) {
        //Envío de la notificación indicada
        List<CC_WS_PushSMS.CC_WS_PushSMS_Mensaje> mensajes = new List<CC_WS_PushSMS.CC_WS_PushSMS_Mensaje>();
        mensajes.add(mensaje);
        List<String> resultados = enviarNotificacionPush(mensajes);
        return resultados[0];
    }

    public static List<String> enviarNotificacionPush(List<CC_WS_PushSMS.CC_WS_PushSMS_Mensaje> mensajes) {
        //Envío de las notificaciones indicadas
        List<String> resultados = new List<String>();

        //Busqueda plantillas CC_PlantillasNotificacionSetting__mdt
        Map<String, CC_PlantillasNotificacionSetting__mdt> mapaPNS = recuperarPlantillasMetadata(mensajes);
        
        //Recuperar email templates
        Map<String, String> mapaPlantillaId = recuperarEmailTemplates(mapaPNS);

        List<Task> tareasCasos = new List<Task>();

        for (CC_WS_PushSMS.CC_WS_PushSMS_Mensaje mensaje : mensajes) {
            //String cuerpo = cuerpoMensaje(mensaje);
            String cuerpo = 'holaaa';//cuerpoPlantilla(mensaje, mapaPNS, mapaPlantillaId);

            String idUnicoPeticion = '050' + ('SFDC_Push_' + System.now().format('yyyyMMddHHmmss') + mensaje.destinatario).rightPad(50, ' ');

            //Los datos de la solicitud viajan en el tag <daveve> con el siguiente formato
            // Inicio tag <dadeve>  Destinatario        Cuerpo del mensaje             Id solicitante Identificador solicitud                                     Fin tag <dadeve>"
            //"CAN00001010X         TLF00001009638877746TXT00001020PRUEBA DEL MARTES 20IDI00001003002CLAU0O01050MCDW5150H8I20092011083347153649774313             99999999000"
            
            //NUEVO
            Decimal numperDecimal = Decimal.valueOf(mensaje.destinatario);
            String numPerStringConverted = CC_MetodosUtiles.decimalToHex(numperDecimal).toUpperCase();

            String valorTagDadeve = 'CAN00001010X         '; //???????
            //valorTagDadeve += 'TLF00001009' + '699148831';//mensaje.destinatario.right(9); //Este es el numperso
            valorTagDadeve += 'PER00002008' + numPerStringConverted.leftPad(8,'0'); //Comprobar que siempre tenga 8
            //valorTagDadeve += 'TXT00001' + String.valueOf(cuerpo.length()).leftPad(3, '0') + cuerpo; //???????
            valorTagDadeve += 'IDI00001003' + mapaPNS.get(mensaje.tipologia + mensaje.idioma + mensaje.entidad).CC_CodigoIdioma__c; //Idioma V
            valorTagDadeve += 'CODTIP010080' + mensaje.tipologia; //Codigo de plantilla V
            valorTagDadeve += 'CLAU0O01' + idUnicoPeticion; //????????
            valorTagDadeve += '99999999000';
            //FINNUEVO

            
            // String valorTagDadeve = 'CAN00001010X         ';
            // valorTagDadeve += 'TLF00001009' + mensaje.destinatario.right(9);
            // valorTagDadeve += 'TXT00001' + String.valueOf(cuerpo.length()).leftPad(3, '0') + cuerpo;
            // valorTagDadeve += 'IDI00001003002';
            // valorTagDadeve += 'CLAU0O01' + idUnicoPeticion;
            // valorTagDadeve += '99999999000';
            
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

            //String body = '{"event":"00CCSP001                                                     CBCC00000338000..' + valorTagDadeve + '"}';
            String body = '{"event":"00CCSP001                                                     CBCC00000757000..' + valorTagDadeve + '"}';
            //String body = '{"event":"00CCSP001                                                     '+ mapaPNS.get(mensaje.tipologia + mensaje.idioma + mensaje.entidad).CC_CodigoEnvio__c + '..' + valorTagDadeve + '"}';

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
                }
            }
        }

        CBK_HttpServiceIntegration.registroTrazaIntegracion();
        
        if (!tareasCasos.isEmpty()) {
            CC_Activity.crearActividades(tareasCasos);
        }
        
        return resultados;
    }

    // private static String cuerpoMensaje(CC_WS_PushSMS_Mensaje mensaje) {
    //     String cuerpoMensaje;
    //     if (String.isNotBlank(mensaje.sObjectId) && String.isNotBlank(mensaje.idPlantilla)) {
    //         cuerpoMensaje = Messaging.renderStoredEmailTemplate(mensaje.idPlantilla, UserInfo.getUserId(), mensaje.sObjectId).getHtmlBody();
    //     }
    //     if (String.isBlank(cuerpoMensaje)) {
    //         cuerpoMensaje = mensaje.texto;
    //     }
    //     return cuerpoMensaje.stripHtmlTags().left(160);
    // }

    private static Map<String, CC_PlantillasNotificacionSetting__mdt> recuperarPlantillasMetadata(List<CC_WS_PushSMS.CC_WS_PushSMS_Mensaje> mensajes) {
        Map<String, CC_PlantillasNotificacionSetting__mdt> mapaPNS = new Map<String, CC_PlantillasNotificacionSetting__mdt>();
        Set<String> setTipologia = new Set<String>();
        Set<String> setIdioma = new Set<String>();

        for (CC_WS_PushSMS.CC_WS_PushSMS_Mensaje mensaje : mensajes) {
            setTipologia.add(mensaje.tipologia);
            setIdioma.add(mensaje.idioma);
        }

        List<CC_PlantillasNotificacionSetting__mdt> listaPNS = [SELECT CC_CodigoEnvio__c, CC_CodigoIdioma__c, CC_Entidad__c, CC_Idioma__c, CC_Plantilla__c, CC_Tipologia__c
                                                                FROM CC_PlantillasNotificacionSetting__mdt];

        if (!listaPNS.isEmpty()) {
            for (CC_PlantillasNotificacionSetting__mdt pns : listaPNS) {
                mapaPNS.put(pns.CC_Tipologia__c + pns.CC_Idioma__c + pns.CC_Entidad__c, pns);
            }
        }

        return mapaPNS;
    }

    private static Map<String, String> recuperarEmailTemplates(Map<String, CC_PlantillasNotificacionSetting__mdt> mapaPNS) {
        Set<String> setEmailTemplates = new Set<String>();
        List<EmailTemplate> listaEmailTemplates = new List<EmailTemplate>();
        Map<String, String> mapaPlantillaId = new Map<String, String>();

        for (CC_PlantillasNotificacionSetting__mdt pns : mapaPNS.values()) {
            setEmailTemplates.add(pns.CC_Plantilla__c);
        }

        listaEmailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :setEmailTemplates];

        if (!listaEmailTemplates.isEmpty()) {
            for (EmailTemplate plantilla : listaEmailTemplates) {
                mapaPlantillaId.put(plantilla.DeveloperName, plantilla.Id);
            }   
        }

        return mapaPlantillaId;
    }

    private static String cuerpoPlantilla(CC_WS_PushSMS.CC_WS_PushSMS_Mensaje mensaje, Map<String, CC_PlantillasNotificacionSetting__mdt> mapaPNS, Map<String, String> mapaPlantillaId) {
        String cuerpo = '';
        if (String.isNotBlank(mensaje.sObjectId) && mapaPNS.containsKey(mensaje.tipologia + mensaje.idioma + mensaje.entidad)
            && mapaPlantillaId.containsKey(mapaPNS.get(mensaje.tipologia + mensaje.idioma + mensaje.entidad).CC_Plantilla__c)
            && String.isNotBlank(mapaPlantillaId.get(mapaPNS.get(mensaje.tipologia + mensaje.idioma + mensaje.entidad).CC_Plantilla__c))) {
            cuerpo = Messaging.renderStoredEmailTemplate(mapaPlantillaId.get(mapaPNS.get(mensaje.tipologia + mensaje.idioma + mensaje.entidad).CC_Plantilla__c), UserInfo.getUserId(), mensaje.sObjectId).getHtmlBody();
        }

        return String.isNotBlank(cuerpo) ? cuerpo.stripHtmlTags().left(160) : '';
    }
}