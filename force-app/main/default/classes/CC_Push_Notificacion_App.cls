public with sharing class CC_Push_Notificacion_App {
    
    public class CC_Push_Notificacion_App_Mssg {
        public Id sObjectId {get;set;}
        public String app {get;set;}
        public String numPer {get;set;}
        public String textoPublico {get;set;}
        public String textoPrivado {get;set;}
        public String asunto {get;set;}
        public String deeplink {get;set;}
        public String idioma {get;set;}
        public String titulo {get;set;}
        public String sobreTitulo {get;set;}
        public String textoBoton {get;set;}
    }

    public static String enviarNotificacionPushApp (String sObjectId, String app, String numPer, String textoPublico, String textoPrivado, String asunto, String deeplink, String idioma, String titulo, String sobreTitulo, String textoBoton, String segundoParametro) {
        //PENDIENTE: Cambiar parámetros de entrada por el objeto con todos los datos de la petición que esté relacionado con el MCC

        // Comprobar enrollment PUSH en las apps
        // PENDIENTE

        CC_Push_Notificacion_App.CC_Push_Notificacion_App_Mssg mensaje = new CC_Push_Notificacion_App.CC_Push_Notificacion_App_Mssg();
        mensaje.sObjectId = Id.valueOf(sObjectId);
        mensaje.app = app; 
        mensaje.numPer = numPer;
        mensaje.textoPublico = textoPublico;
        mensaje.textoPrivado = textoPrivado;
        mensaje.asunto = asunto;
        if (String.isNotBlank(segundoParametro)) {
            mensaje.deeplink = deeplink + segundoParametro;
        } else {
            mensaje.deeplink = deeplink;
        }
        mensaje.idioma = idioma;
        mensaje.textoBoton = textoBoton;
        mensaje.titulo = titulo;
        mensaje.sobreTitulo= sobreTitulo;

        // Envío de notificación PUSH a app
        List<String> resultadoLst = enviarNotificacionPUSH(new List<CC_Push_Notificacion_App.CC_Push_Notificacion_App_Mssg>{mensaje});
        
        String resultado;
        if (!resultadoLst.isEmpty()) {
            resultado = resultadoLst[0];
        }
        return resultado;
    }

    public static List<String> enviarNotificacionPUSH(List<CC_Push_Notificacion_App.CC_Push_Notificacion_App_Mssg> mensajes) {
        //Envío de las notificaciones indicadas
        List<String> resultados = new List<String>();

        List<Task> tareasCasos = new List<Task>();

        for (CC_Push_Notificacion_App.CC_Push_Notificacion_App_Mssg mensaje : mensajes) {
            
            if (mensaje.textoPublico.length() > 126) { // Longitud máxima texto público
                mensaje.textoPublico = mensaje.textoPublico.left(126);
            }
            if (mensaje.textoPrivado.length() > 500) { // Longitud máxima texto privado
                mensaje.textoPrivado = mensaje.textoPrivado.left(500);
            }
            if (mensaje.asunto.length() > 250) { // Longitud máxima asunto
                mensaje.asunto = mensaje.asunto.left(250);
            }
            
            String idUnicoPeticion = '050' + ('DIP' + System.now().format('yyyyMMddHHmmss') + mensaje.numPer).rightPad(50, ' ');

            // Los datos de la solicitud se envían en el tag <dadeve>
            // El DADEVE se construye de la siguiente manera:
            // - Código de bloque: String longitud 8 que identifica el tipo de dato, su longitud máxima y el formato en el que llega.
            // - Longitud del dato: String longitud 3, en formato NNN. Indica la longitud del dato que se envía.
            // - Dato: El dato propiamente dicho. Es un string de la longitud indicada en la "longitud del dato".

            // Los datos de la solicitud viajan en el tag <daveve> con el siguiente formato
            // Inicio tag <dadeve>  Destinatario        Cuerpo del mensaje             Id solicitante Identificador solicitud                                     Fin tag <dadeve>"
            //"CAN00001010X         TLF00001009638877746 TXT00001020PRUEBA DEL MARTES 20IDI00001003002 CLAU0O01 050 MCDW5150H8I20092011083347153649774313             99999999000"
            String valorTagDadeve = '<![CDATA[CAN00001' + '010' + '  X       '; // La posición de la X indica que es una invocación para PUSH
            // PER00002: Es obligatorio enviar el bloque del numper de la persona a la que queremos notificar el PUSH, en hexadecimal
            //Decimal dc = 15482499;
            String persMayusHex = '';
            if(mensaje.numPer.isNumeric()){
                Decimal numPersDec = Decimal.valueOf(mensaje.numPer);
                persMayusHex = CC_MetodosUtiles.decimalToHex(numPersDec).toUpperCase();
            }
            //persMayusHex = '0014A410';
            String ceroIzquierda = '0';
            Integer longitudNumPerso = persMayusHex.length();
            system.debug('longitud numperso ' + longitudNumPerso);
            if(longitudNumPerso != 8){
                Integer huecosPorRellenar = 8 - longitudNumPerso;
                system.debug('huecosPorRellenar ' + huecosPorRellenar);
                for(Integer i = 0; i < huecosPorRellenar; i++){
                    system.debug('dentro for iteracion ' + i);
                    ceroIzquierda = '0';
                    ceroIzquierda += persMayusHex;
                    persMayusHex = ceroIzquierda;
                    system.debug('dentro for ' + persMayusHex);
                }
                
                system.debug('numperso final ' + persMayusHex);
            }
            system.debug('numPers to HEX ' + persMayusHex);
            valorTagDadeve += 'PER00002' + '008' + persMayusHex;
            system.debug('dadeve numperso ' + valorTagDadeve);
            
             // Longitud 8
            //valorTagDadeve += 'TLF00001009' + mensaje.destinatario.right(9); > El teléfono se indicaría si se quisiera que se enviara la notificación por SMS si no se puede enviar la notificación PUSH a la app
            // Texto privado
            system.debug('mensaje.textoPrivado: ' + mensaje.textoPrivado);
            if (!String.isBlank(mensaje.textoPrivado)) {
                valorTagDadeve += 'TXT00005' + String.valueOf(mensaje.textoPrivado.length()).leftPad(3, '0') + mensaje.textoPrivado;
            }
            system.debug('valorTagDadeve: ' + valorTagDadeve);
            
            // Texto privado avanzado ??
        /*    if (!String.isBlank(mensaje.textoPrivadoAvanzado)) {
                valorTagDadeve += 'TXT00005' + String.valueOf(mensaje.textoPrivadoAvanzado.length()).leftPad(3, '0') + mensaje.textoPrivadoAvanzado;
            }
        */    // Texto público
            if (!String.isBlank(mensaje.textoPublico)) {
                valorTagDadeve += 'TEXPUB01' + String.valueOf(mensaje.textoPublico.length()).leftPad(3, '0') + mensaje.textoPublico;
            }
            if (!String.isBlank(mensaje.sobreTitulo) || !String.isBlank(mensaje.titulo) || !String.isBlank(mensaje.textoPrivado) || !String.isBlank(mensaje.textoBoton) || !String.isBlank(mensaje.deeplink)) {
            String txtaPrivAva = '{"v":"1.0","s":"AtencionCliente","mc":{"h":"'+ mensaje.sobreTitulo +'","t":"'+ mensaje.titulo +'","ds":"'+mensaje.textoPrivado+'","mac":{"l":"'+ mensaje.textoBoton +'","u":"'+ mensaje.deeplink +'"}}}';
            valorTagDadeve += 'TXTAVA01'+String.valueOf(txtaPrivAva.length()).leftPad(3, '0')+ txtaPrivAva;
            system.debug('txtaPrivAva: ' + txtaPrivAva);
            system.debug('valorTagDadeve: ' + valorTagDadeve);
            }
            // Asunto
            if (!String.isBlank(mensaje.asunto)) {
                valorTagDadeve += 'ASUNTO01' + String.valueOf(mensaje.asunto.length()).leftPad(3, '0') + mensaje.asunto;
            }
            // Deeplink ???? PENDIENTE
            // ------------------------------------
            if (!String.isBlank(mensaje.deeplink)) {
                valorTagDadeve += 'TXTURL01' + String.valueOf(mensaje.deeplink.length()).leftPad(3, '0') + mensaje.deeplink;
            }
            
            // Idioma ???? SI ES CAS 002 SI ES CAT 001 (mensaje.idioma)
            if(mensaje.idioma == 'es'){
                valorTagDadeve += 'IDI00001' + '003' + '002';
            }
            else if(mensaje.idioma == 'ca'){
                valorTagDadeve += 'IDI00001' + '003' + '001';
            }
            else if(mensaje.idioma == 'en'){
                valorTagDadeve += 'IDI00001' + '003' + '003';
            }

            valorTagDadeve += 'CLAU0O01' + idUnicoPeticion; //a sustituir por el valor correcto de
            if(mensaje.app == 'IMAGIN'){
                valorTagDadeve += 'CODTIP01' + '008' + '00000002'; //a sustituir por el valor correcto de
            }
            else if(mensaje.app == 'laCaixa'){
                valorTagDadeve += 'CODTIP01' + '008' + '00000001';
            }
            valorTagDadeve += 'CODTIP01' + '008' + '00000001'; //a sustituir por el valor correcto de
            valorTagDadeve += '99999999000';

            String cuerpo = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://servicioexternoenviosws.alertasfinancenvios.mca.si.absis.lacaixa.es/">';
            cuerpo += '<soapenv:Header></soapenv:Header>';
            cuerpo += '<soapenv:Body>';
            cuerpo += '<ser:ProcesarEvento>';
            cuerpo += '<externalInputTO>';
            cuerpo += '<codeve>SLFC00000521000</codeve>'; // PENDIENTE: MODIFICAR CODEVE CON LA NUEVA ALERTA
            cuerpo += '<dadeve>' + valorTagDadeve + ']]></dadeve>';
            cuerpo += '</externalInputTO>';
            cuerpo += '</ser:ProcesarEvento>';
            cuerpo += '</soapenv:Body>';
            cuerpo += '</soapenv:Envelope>';
            //req.setBody(cuerpo);
            system.debug('body ' + cuerpo);
            // Framework de integración CBK
            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('Content-Type', 'text/xml');

            CBK_HttpServiceIntegration.RequestWapper integracion= new CBK_HttpServiceIntegration.RequestWapper();
               integracion.body=cuerpo;
               integracion.intSetting= 'CC_MCD_Envio_PUSH';
               integracion.method = 'POST';
               integracion.mHeaders = mHeaders;
               HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
            // HttpRequest request = CBK_HttpServiceIntegration.getRequest(cuerpo, 'CC_MCD_Envio_PUSH', 'POST', mHeaders);
            // request.setHeader('HTTP-HEADER-ACTOR', 'CBCCSF'); //solo para tst
            //request.setClientCertificateName('cc_camaleon');
            system.debug(request.getBody());

            Boolean errorHttpSend = false;
            try {
                HttpResponse respuesta = CBK_HttpServiceIntegration.callHttpService(request, null, 'CC_MCD_Envio_PUSH');
                system.debug(respuesta.getBody());
                system.debug(respuesta.getStatusCode());
                if(String.isNotBlank(respuesta.getBody()) && respuesta.getStatusCode() == 200){
                    resultados.add(respuesta.getBody());

            // Nueva actividad en el case para registrar el envío de la notificación PUSH
            if (mensaje.sObjectId != null) {
                if (mensaje.sObjectId.getSobjectType() == Schema.Case.getSObjectType()) {
                    //Tareas de casos (CC o COPS): el RT de las tareas se deduce del RT del caso
                    String prefijoRT = [SELECT RecordType.DeveloperName FROM Case
                                    WHERE Id = :mensaje.sObjectId].RecordType.DeveloperName.substringBefore('_');
                    Task tarea = new Task();
                    tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', prefijoRT + '_Task');
                    tarea.WhatId = mensaje.sObjectId;
                    //tarea.Type = 'Notificación - Salida'; > Valor no activo
                    tarea.Type = 'Otros';
                    tarea.ActivityDate = System.today();
                    tarea.Status = 'Completed';
                    tarea.Subject = 'Envío de notificación PUSH al cliente ' + mensaje.numPer;
                    tarea.Description = mensaje.textoPublico;
                    tareasCasos.add(tarea);
                }
            }
                    
                }
                else{
                    String empty = '';
                    resultados.add(empty);
                }
                /*List<String> errores = obtenerErrores(respuesta?.getBody());
                if (errores.isEmpty()) {
                    resultados.add('OK');
                } else {
                    resultados.add('KO: ' + errores[0]);
                }*/
            } catch (Exception e) {
                errorHttpSend = true;
                CBK_Log.error(e);
                resultados.add('KO: ' + e.getMessage());
            }
        }
        
        if (!tareasCasos.isEmpty()) {
            CC_Activity.crearActividades(tareasCasos);
        }
        
        return resultados;
    }
    // Se valida el enrollment PUSH del cliente
    //public static List<String> validarEnrollmentPUSH(List<CC_Push_Notificacion_App.CC_Push_Notificacion_App_Mssg> mensajes) {
    public static Map<String, Boolean> validarEnrollmentPUSH(String numPer) {
        // system.debug('Luis dentro validar enrollment PUSH ' + numPer);
        Http http = new Http();
        Map<String, Boolean> resMap = new Map<String, Boolean>();
        List<String> res = new List<String>();
        String persMayusHex = '';
        if(numPer.isNumeric()){
            Decimal numPersDec = Decimal.valueOf(numPer);
            persMayusHex = CC_MetodosUtiles.decimalToHex(numPersDec).toUpperCase();
        }
        // system.debug('perso to HEX ' + persMayusHex);

        // Framework de integración CBK
        Map<String, String> mHeaders = new Map<String, String>();
        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
        //mHeaders.put('HTTP-HEADER-ACTOR', 'CBCCSF'); //solo para TST
        mHeaders.put('x-absis-customerInternalId', persMayusHex);
        //mHeaders.put('x-absis-profile', numPer); // PENDIENTE > CONVERTIR EN HEX
        CBK_HttpServiceIntegration.RequestWapper integracion= new CBK_HttpServiceIntegration.RequestWapper();
               integracion.body=null;
               integracion.intSetting= 'CC_MCD_Gestion_PUSH_uuIds';
               integracion.method = 'GET';
               integracion.mHeaders = mHeaders;
        HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
        //HttpRequest request = CBK_HttpServiceIntegration.getRequest(null, 'CC_MCD_Gestion_PUSH_uuIds', 'GET', mHeaders);
        

        String httpRequestEndpoint = request.getEndpoint();
        httpRequestEndpoint += '?customerType=C&appId=';

        // Se añaden los parámetros al endpoint de la HTTP Request PRIMERA LLAMADA será laCaixa segunda IMAGIN
        String appIdCaixa = 'lacaixa';
        String appIdImagin = 'IMAGIN';
        

        String httpRequestEndpointlaCaixa = httpRequestEndpoint + appIdCaixa;
        String httpRequestEndpointImagin = httpRequestEndpoint + appIdImagin;

        // system.debug('test endpoint caixa' + httpRequestEndpointlaCaixa);
        request.setEndpoint(httpRequestEndpointlaCaixa);
        // system.debug('request caixa' + request);
        List<CC_TrazaInt__c> registroTrazas = new List<CC_TrazaInt__c>();
        Boolean errorHttpSend = false;
        try {
            
            Datetime dtStart = Datetime.now();
            //HttpResponse respuesta = http.send(request);
            HttpResponse respuesta = CBK_HttpServiceIntegration.multiCallHttpService(request, null, 'CC_MCD_Gestion_PUSH_uuIds');
            DateTime dtStop = Datetime.now();
            
            CC_TrazaInt__c registroIntegracion = new CC_TrazaInt__c ();
			registroIntegracion.Name = 'CC_MCD_Gestion_PUSH_uuIds';
			registroIntegracion.CC_Identificador__c = 'callout:API_GWT_TST_CC/distribution/messagePush/applicationAlerts/uuids';
			registroIntegracion.CC_FechaInicio__c = dtStart;
			registroIntegracion.CC_FechaFin__c = dtStop;
			registroIntegracion.CC_MensajeEntrada__c = request.toString();
			if ((respuesta.getStatusCode() == CBK_ServiceRestManager.CORRECT_STATUS_CODE)){
				registroIntegracion.CC_FinOK__c = true;
				registroIntegracion.CC_MensajeSalida__c = respuesta.getBody();
			}else{
				registroIntegracion.CC_FinOK__c = false;
				registroIntegracion.CC_DetalleError__c = respuesta.getBody();
			}
            registroTrazas.add(registroIntegracion);



            // system.debug('response body ' + respuesta.getBody());
			// system.debug('response ' + respuesta);
			// system.debug('response status ' + respuesta.getStatus());
			// system.debug('response status code ' + respuesta.getStatusCode());
            
            if(String.isNotBlank(respuesta.getBody()) && respuesta.getStatusCode() == 200){
                res.add(respuesta.getBody());
                resMap.put('CaixaBank', true);
            }
            else {
                resMap.put('CaixaBank', false);
            }
            // system.debug('cantidad de elementos ' + res.size());
            // system.debug('lista ' + res);
            // system.debug('mapaRes ' + resMap);
            /*List<String> errores = obtenerErrores(respuesta.getBody());
            system.debug('errores ' + errores.size());
            if (errores.isEmpty()) {
                resultados.add('OK');
            } else {
                resultados.add('KO: ' + errores[0]);
            }*/
            
        } catch (Exception e) {
            errorHttpSend = true;
            // system.debug('error catch ' + e.getMessage());
            CBK_Log.error(e);
            res.add('KO: ' + e.getMessage());
            resMap.put('CaixaBank', false);
            // system.debug('mapaRes ' + resMap);
        }

        request.setEndpoint(httpRequestEndpointImagin);
        // system.debug('request Imagin' + request);

        try {
            Datetime dtStart = Datetime.now();
            //HttpResponse respuesta = http.send(request);
            HttpResponse respuesta2 = CBK_HttpServiceIntegration.multiCallHttpService(request, null, 'CC_MCD_Gestion_PUSH_uuIds');
            Datetime dtStop = Datetime.now();

            CC_TrazaInt__c registroIntegracion = new CC_TrazaInt__c ();
			registroIntegracion.Name = 'CC_MCD_Gestion_PUSH_uuIds';
			registroIntegracion.CC_Identificador__c = 'callout:API_GWT_TST_CC/distribution/messagePush/applicationAlerts/uuids';
			registroIntegracion.CC_FechaInicio__c = dtStart;
			registroIntegracion.CC_FechaFin__c = dtStop;
			registroIntegracion.CC_MensajeEntrada__c = request.toString();
			if ((respuesta2.getStatusCode() == CBK_ServiceRestManager.CORRECT_STATUS_CODE)){
				registroIntegracion.CC_FinOK__c = true;
				registroIntegracion.CC_MensajeSalida__c = respuesta2.getBody();
			}else{
				registroIntegracion.CC_FinOK__c = false;
				registroIntegracion.CC_DetalleError__c = respuesta2.getBody();
			}
            registroTrazas.add(registroIntegracion);

            // system.debug('response body ' + respuesta2.getBody());
			// system.debug('response ' + respuesta2);
			// system.debug('response status ' + respuesta2.getStatus());
			// system.debug('response status code ' + respuesta2.getStatusCode());
            
            if(String.isNotBlank(respuesta2.getBody()) && respuesta2.getStatusCode() == 200){
                res.add(respuesta2.getBody());
                resMap.put('IMAGIN', true);
            }
            else {
                resMap.put('IMAGIN', false);
            }
            // system.debug('cantidad de elementos ' + res.size());
            // system.debug('lista ' + res);
            // system.debug('mapaRes ' + resMap);
        } catch (Exception e) {
            errorHttpSend = true;
            // system.debug('error catch ' + e.getMessage());
            CBK_Log.error(e);
            res.add('KO: ' + e.getMessage());
            resMap.put('IMAGIN', false);
            // system.debug('mapaRes ' + resMap);
        }

        if(!registroTrazas.isEmpty()){
            insert registroTrazas;
        }

        return resMap;
        //return res;
    }

}