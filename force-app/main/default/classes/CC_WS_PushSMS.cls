public with sharing class CC_WS_PushSMS {
    public class CC_WS_PushSMS_Mensaje {
        public Id sObjectId {get;set;}
        public String numPerso {get;set;} //numPerso del account
        public String telefono {get;set;} //telefono del account
        public String tipologiaName {get;set;} //Label del metadata CC_PlantillasNotificacionSetting__mdt que nos indica la plantilla y la tipologia. Cada operativa debe tener definida una tipologia para saber que codigos deben enviarse.
        public String idioma {get;set;} //es (español) ca (catalan) eu (euskera) ga (Gallego) va (Valenciano) en (Ingles).
        public String entidad {get;set;} //CaixaBank o Imagin. El campo AV_IndicadoresClientes__c del Account nos indica si es cliente caixaBank o imagin. Si contiene 28 es Imagin. De lo contrario, CaixaBank.
    }

    private static Map<String, CC_PlantillasNotificacionSetting__mdt> mapaPNS = new Map<String, CC_PlantillasNotificacionSetting__mdt>();

    @AuraEnabled
    public static String enviarNotificacionPush(Id sObjectId, String plantillaDevName, String idioma, String entidad) {
        //Buscar metadata de la plantilla, idioma y entidad seleccionada.
        List<CC_PlantillasNotificacionSetting__mdt> listaPNS = recuperarPlantillasMetadata(plantillaDevName, idioma, entidad);
        if (!listaPNS.isEmpty()) {
            for (CC_PlantillasNotificacionSetting__mdt pns : listaPNS) {
                mapaPNS.put(pns.label + pns.CC_Idioma__c + pns.CC_Entidad__c, pns);
            }
        }

        CC_WS_PushSMS.CC_WS_PushSMS_Mensaje mensaje = new CC_WS_PushSMS.CC_WS_PushSMS_Mensaje();
        Case caso = [SELECT Id, Account.AV_NumPerso__c, CC_Idioma__c, Account.AV_IndicadoresClientes__c, Account.PersonMobilePhone, CC_Representante__r.CC_Representante__r.AV_NumPerso__c,
                    CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.PersonMobilePhone, Contact.CIBE_NumPerso__c,
                    Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CIBE_Telefono1__c, Account.CC_NumPerso__c, Account.RecordType.DeveloperName,
                    Contact.RecordType.DeveloperName
                    FROM Case WHERE Id = :sObjectId];
        
        Map<String, String> mapaValores = CC_MetodosUtiles.getValoresCliente(caso);
        mensaje.sObjectId = sObjectId;
        mensaje.numPerso = mapaValores.get('numPerso');
        mensaje.telefono = mapaValores.get('numTelefono');
        mensaje.idioma = idioma;
        mensaje.entidad = entidad.contains('28') ? 'Imagin' : 'CaixaBank';
        mensaje.tipologiaName = listaPNS[0].label;
        return enviarNotificacionPush(mensaje);
    }

    public static String enviarNotificacionPush(Id sObjectId, String tipologiaName) {
        //Envío de notificación con los parámetros indicados
        CC_WS_PushSMS.CC_WS_PushSMS_Mensaje mensaje = new CC_WS_PushSMS.CC_WS_PushSMS_Mensaje();
        Case caso = [SELECT Id, Account.AV_NumPerso__c, CC_Idioma__c, Account.AV_IndicadoresClientes__c, Account.PersonMobilePhone, CC_Representante__r.CC_Representante__r.AV_NumPerso__c,
                    CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.PersonMobilePhone, Contact.CIBE_NumPerso__c,
                    Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CIBE_Telefono1__c, Account.CC_NumPerso__c, Account.RecordType.DeveloperName,
                    Contact.RecordType.DeveloperName
                    FROM Case WHERE Id = :sObjectId];

        Map<String, String> mapaValores = CC_MetodosUtiles.getValoresCliente(caso);
        mensaje.sObjectId = sObjectId;
        mensaje.numPerso = mapaValores.get('numPerso');
        mensaje.telefono = mapaValores.get('numTelefono');
        mensaje.tipologiaName = tipologiaName;
        mensaje.idioma = caso.CC_Idioma__c;
        mensaje.entidad = caso.Account.AV_IndicadoresClientes__c.contains('28') ? 'Imagin' : 'CaixaBank';
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
        if (mapaPNS.isEmpty()) {
            mapaPNS = recuperarPlantillasMetadata(mensajes);
        }
        
        //Recuperar email templates
        Map<String, String> mapaPlantillaId = recuperarEmailTemplates(mapaPNS);

        List<Task> tareasCasos = new List<Task>();

        //Extraer los casos de los mensajes. 
        List<Id> caseIds = new List<Id>();
        Map<Id, Case> mapaCasos = new Map<Id, Case>();
        for (CC_WS_PushSMS.CC_WS_PushSMS_Mensaje mensaje : mensajes) {
            if (mensaje.sObjectId != null) {
                if (mensaje.sObjectId.getSobjectType() == Schema.Case.getSObjectType()) {
                    caseIds.add(mensaje.sObjectId);
                }
            }
        }
        //Recuperar los casos para obtener el idioma y la entidad Imagin o CaixaBank. 
        if (!caseIds.isEmpty()) {
            mapaCasos = new Map<Id, Case>([SELECT Id, CC_Idioma__c, Account.AV_IndicadoresClientes__c FROM Case WHERE Id IN :caseIds]);
        }

        for (CC_WS_PushSMS.CC_WS_PushSMS_Mensaje mensaje : mensajes) {
            String cuerpo = cuerpoPlantilla(mensaje, mapaPNS, mapaPlantillaId);
            DateTime fechaActual = CBK_UtilsDate.nowDT();
            String idUnicoPeticion = '050' + ('SFDC_Push_' + fechaActual.format('yyyyMMddHHmmss') + mensaje.numPerso).rightPad(50, ' ');
            
            //Pasar numPerson a hexadecimal
            Decimal numperDecimal = Decimal.valueOf(mensaje.numPerso);
            String numPerStringConverted = CC_MetodosUtiles.decimalToHex(numperDecimal).toUpperCase();

            if(!mapaCasos.containsKey(mensaje.sObjectId)){
                continue; //Si no existe el caso, se salta el mensaje. 
            }
            Case caso = mapaCasos.get(mensaje.sObjectId);
            String idiomaCaso = caso.CC_Idioma__c != null ? caso.CC_Idioma__c : 'es';
            String entidadCaso = caso.Account?.AV_IndicadoresClientes__c != null && caso.Account.AV_IndicadoresClientes__c.contains('28') ? 'Imagin' : 'CaixaBank';

            //Montar Dadeve
            String valorTagDadeve = 'CAN00001010X         '; //Se mantiene
            valorTagDadeve += 'TLF00001009' + mensaje.telefono.right(9); //Telefono
            valorTagDadeve += 'PER00002008' + numPerStringConverted.leftPad(8,'0'); //Numperso en hexadecimal. Siempre con 8 caracteres y rellenando con 0 a la izquierda
            //valorTagDadeve += 'TXT00001' + String.valueOf(cuerpo.length()).leftPad(3, '0') + cuerpo; //Ya no se utiliza, ya que el texto se informa con el codigo de la plantilla
            valorTagDadeve += 'IDI00001003' + mapaPNS.get(mensaje.tipologiaName + idiomaCaso + entidadCaso).CC_CodigoIdioma__c; //Idioma
            valorTagDadeve += 'CODTIP01008' + mapaPNS.get(mensaje.tipologiaName + idiomaCaso + entidadCaso).CC_Tipologia__c; //Codigo de plantilla
            valorTagDadeve += 'CLAU0O01' + idUnicoPeticion; //id unico
            valorTagDadeve += '99999999000'; //Siempre debe ser el ultimo parametro

            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

            String body = '{"event":"00CCSP001                                                     '+ mapaPNS.get(mensaje.tipologiaName + idiomaCaso + entidadCaso).CC_CodigoEnvio__c + '..' + valorTagDadeve + '"}';

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
                if (respuesta.getStatusCode() != 200) {resultados.add('KO: ' + respuesta.getBody());} 
                else {
                    resultados.add('OK');
                }
            } catch (Exception e) {errorHttpSend = true;CBK_Log.error(e);resultados.add('KO: ' + e.getMessage());}

            //Nueva actividad de tipo 'Notificación - Salida' hija del registro indicado en sObjectId
            if (mensaje.sObjectId != null) {
                if (mensaje.sObjectId.getSobjectType() == Schema.Case.getSObjectType()) {
                    Task tarea = new Task();
                    tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
                    tarea.WhatId = mensaje.sObjectId;
                    tarea.Type = 'Notificación - Salida';
                    tarea.ActivityDate = CBK_UtilsDate.todayDT();
                    tarea.Status = 'Completed';
                    tarea.Subject = 'Envío de notificación al número ' + mensaje.telefono;
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

    private static Map<String, CC_PlantillasNotificacionSetting__mdt> recuperarPlantillasMetadata(List<CC_WS_PushSMS.CC_WS_PushSMS_Mensaje> mensajes) {
        Map<String, CC_PlantillasNotificacionSetting__mdt> mapaPNS = new Map<String, CC_PlantillasNotificacionSetting__mdt>();

        List<CC_PlantillasNotificacionSetting__mdt> listaPNS = [SELECT label, CC_CodigoEnvio__c, CC_CodigoIdioma__c, CC_Entidad__c, CC_Idioma__c, CC_Plantilla__c, CC_Tipologia__c
                                                                FROM CC_PlantillasNotificacionSetting__mdt];

        if (!listaPNS.isEmpty()) {
            for (CC_PlantillasNotificacionSetting__mdt pns : listaPNS) {
                mapaPNS.put(pns.label + pns.CC_Idioma__c + pns.CC_Entidad__c, pns);
            }
        }

        return mapaPNS;
    }

    private static List<CC_PlantillasNotificacionSetting__mdt> recuperarPlantillasMetadata(String plantillaDevName, String idioma, String entidad) {
        String entidadBuscar = entidad.contains('28') ? 'Imagin' : 'CaixaBank';

        List<CC_PlantillasNotificacionSetting__mdt> listaPNS = [SELECT label, CC_CodigoEnvio__c, CC_CodigoIdioma__c, CC_Entidad__c, CC_Idioma__c, CC_Plantilla__c, CC_Tipologia__c
                                                                FROM CC_PlantillasNotificacionSetting__mdt
                                                                WHERE CC_Plantilla__c = :plantillaDevName AND CC_Idioma__c = : idioma AND CC_Entidad__c = :entidadBuscar];

        return listaPNS;
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
        if (String.isNotBlank(mensaje.sObjectId) && mapaPNS.containsKey(mensaje.tipologiaName + mensaje.idioma + mensaje.entidad)
            && mapaPlantillaId.containsKey(mapaPNS.get(mensaje.tipologiaName + mensaje.idioma + mensaje.entidad).CC_Plantilla__c)
            && String.isNotBlank(mapaPlantillaId.get(mapaPNS.get(mensaje.tipologiaName + mensaje.idioma + mensaje.entidad).CC_Plantilla__c))) {
            cuerpo = Messaging.renderStoredEmailTemplate(mapaPlantillaId.get(mapaPNS.get(mensaje.tipologiaName + mensaje.idioma + mensaje.entidad).CC_Plantilla__c), UserInfo.getUserId(), mensaje.sObjectId).getHtmlBody();
        }

        return String.isNotBlank(cuerpo) ? cuerpo.stripHtmlTags().left(160) : '';
    }
}