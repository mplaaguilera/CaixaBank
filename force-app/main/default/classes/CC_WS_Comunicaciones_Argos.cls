public with sharing class CC_WS_Comunicaciones_Argos {
    //esta clase se invoca desde CC_Clasificacion_Casos_Controller.validarGuardarCerrar (cuando se cuarda o se guarda y se cierra un caso y cambio el MCC o la cuenta y el contacto) 
    //utilizamos 4 parametros de entrada:
    // - caso: el caso al que queremos guardar o cerrar
    // - cerrar: booleano que indica si queremos cerrar el caso o guardarlo (lo utilizamos cuando NO es multicall)
    // - multicall: booleano que indica si debemos hacer una llamada o si debemos hacer primero la llamada a guardar y luego a cerrar (por lo general se utiliza cuando cambia el MCC del caso, ya que primero se guarda el caso con el nuevo MCC y luego se cierra el caso)
    // - nuevosValores: mapa con los nuevos valores del MCC ( viene relleno cuando se rellena por primera vez el MCC del caso o cuando se cambia el MCC del caso)
    public static Boolean process(Case caso, Boolean cerrar, Boolean multicall, Map<String, String> nuevosValores) {
        //este valor se utiliza en la clase CC_Clasificacion_Casos_Controller.validarGuardarCerrar para pasarle al Aura si tiene que cambiar o no el campo del caso CC_Status_Autorizacion__c 
         Boolean cambiarStatusAuto = false;
            if(caso != null) {
                //creamos una lista de tareas para guardar las tareas que se vayan creando al llamar al servicio de Argos(ya sea una sola o varias) Siempre creamos tatea, ya sea por que da OK el servicio o porque algo falla.
                List<Task> listaTareas = new List<Task>();
                Task tareaArgos;
                try {
                    //recuperamos el body dependiendo de si vamos a verrar el caso o si solo vamos a guardar (ya que son distintos)
                    Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json;charset=UTF-8'};
                    //Añadimos al header valores solo para cuando es TST
                    if ([SELECT IsSandbox FROM Organization].IsSandbox) {
                        for (CC_Lista_Valores__c lov : [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
                                                        WHERE CC_Lista__r.Name = 'Request headers específicos del sandbox'
                                                        AND CC_Lista__r.CC_Activa__c = TRUE AND CC_Activa__c = TRUE]) {
                            headers.put(lov.Name, lov.CC_Valor__c);
                        }
                    }
                    //headers.put('HTTP-HEADER-ACTOR', 'CBCCSF'); //SOLO TST
                    CC_Settings__c configuracionesGenerales = CC_Settings__c.getValues('CC_Parametrizacion_WS_Argos');
                    Map<String,String> datos = recupararDatos(caso, configuracionesGenerales);
                    if(nuevosValores != null && !nuevosValores.isEmpty()){
                        //si hay nuevos valores, los añadimos al mapa de datos
                        datos.putAll(nuevosValores);
                    }
                    //cuando cerrar esta en true, llamamos a cerrar, cuando esta en false llamamos a guardar y si el parametro de multicall esta en true, llamamos a ambos por eso recuperamos siemre ambos bodys.  
                    String bodyGuardar = getRequestBodyGuardar(caso, configuracionesGenerales, datos);

                    String bodyCerrar = getRequestBodyCerrar(caso, configuracionesGenerales, datos); 

                    //Invocacmos al servicio
                    HttpResponse response;
                    if(!multicall){
                        String body = cerrar ? bodyCerrar : bodyGuardar;
                        response = invocacionServicio(body, 'CC_Argos', headers);
                        //response forzado para mfa = 2 
                        //response.setBody('{"operationFraudId":"bde219ac-2cf4-5649-9ab7-2c8ef8f56cfe","multiFactorAuthentication":"2","message":"Known user and device","device":{},"extradata":{"risk":[{"e":"","ope":"ContactCenter","payee":"","first_try":"2025-05-23 08:00:28","last_try":"2025-05-23 08:00:28","usuclo":"","operationId":"b23106c2-1bce-5525-a0e5-a80cff605b99","restricted":false,"denied":false}]},"reason":"","operationNowId":"500KN000001xTszYAE"}	');
                       
                        if (response.getStatusCode() != 200) {
                            CBK_Log.debug('::: Error Status Code: ' + response.getStatusCode());
                            tareaArgos = crearTarea(caso, response);
                            listaTareas.add(tareaArgos);
                            
                        } else {
                            tareaArgos = crearTarea(caso, response);
                            listaTareas.add(tareaArgos);

                            if(tareaArgos.CC_Consulta__c == '2'){
                                crearComunicacion(caso);
                                cambiarStatusAuto = true;
                            }
        
                        }
                    } else{
                        response = invocacionServicio(bodyGuardar, 'CC_Argos', headers);
                        if (response.getStatusCode() != 200) {
                            CBK_Log.debug('::: Error Status Code: ' + response.getStatusCode());

                            tareaArgos = crearTarea(caso, response);
                            listaTareas.add(tareaArgos);
                            
                        } else {
                            tareaArgos = crearTarea(caso, response);
                            listaTareas.add(tareaArgos);

                            if(tareaArgos.CC_Consulta__c == '2'){
                                crearComunicacion(caso);
                                cambiarStatusAuto = true;
                            }
        
                        }
                        //multicall, hacemos el cerrar por mas que el guardar haya fallado. 
                        response = invocacionServicio(bodyCerrar, 'CC_Argos', headers);
                    if (response.getStatusCode() != 200) {
                        CBK_Log.debug('::: Error Status Code: ' + response.getStatusCode());

                            tareaArgos = crearTarea(caso, response);
                            listaTareas.add(tareaArgos);
                        
                    } else {
                            tareaArgos = crearTarea(caso, response);
                            listaTareas.add(tareaArgos);

                        if(tareaArgos.CC_Consulta__c == '2'){
                            crearComunicacion(caso);
                            cambiarStatusAuto = true;
                        }
    
                    }
                        
                    }
                    
                                   
                } catch (Exception e) {
                    CBK_Log.error(e); 
                tareaArgos = crearTarea(caso, null);
                //suele dar null pointer exception cuando falla la llamada al servicio, por lo que no tenemos respuesta, por lo que no podemos rellenar el campo de consulta.
                tareaArgos.Description = 'Error al invocar argos' + ' ------ Exception: ' + e.getMessage();
                listaTareas.add(tareaArgos);
                }
                CBK_HttpServiceIntegration.registroTrazaIntegracion();
                insert listaTareas;

                
            }
            return cambiarStatusAuto;
    }
    //Invocamos al servicio de Argos, pasandole el body y los headers necesarios.
    private static HttpResponse invocacionServicio(String httpRequestBody, String integracionElegida, Map<String, String> mHeaders) {
        HttpResponse response;
        try {
            CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
            integracion.body = httpRequestBody;
            integracion.intSetting = integracionElegida;
            integracion.mHeaders = mHeaders;
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
            response =  CBK_HttpServiceIntegration.multiCallHttpService(request, null, integracionElegida);            
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        return response;

    }
    //Creamos la tarea asociada al caso, con los datos que nos devuelve el endpoint de Argos.
    private static Task crearTarea(Case caso, HttpResponse response){
            String keyAccCont = '';
            String keyMcc = '';
            if(caso.AccountId != null && caso.ContactId != null) {
                keyAccCont = caso.AccountId + ' - ' + caso.ContactId;
            }
            if(caso.CC_MCC_Tematica__c != null && caso.CC_MCC_ProdServ__c != null && caso.CC_MCC_Motivo__c != null) {
                //si tenemos los 3 campos, los concatenamos
            keyMcc = caso.CC_MCC_Tematica__c + ' - ' + caso.CC_MCC_ProdServ__c + ' - ' + caso.CC_MCC_Motivo__c;

            }

            Task tareaArgos = new Task();
            tareaArgos.Type = 'Argos';
            tareaArgos.Subject = 'Tarea creada al llamar a Argos';
            tareaArgos.WhatId = caso.Id;
            tareaArgos.Status = 'Completed';
            tareaArgos.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            
            tareaargos.CC_Detalles_Solucion__c = keyAccCont.left(255);
            if(response != null){
                tareaArgos.CC_Categoria__c =!String.isEmpty(String.valueOf(response.getStatusCode())) ? String.valueOf(response.getStatusCode()) : '';
                if(!String.isEmpty(response.getBody())){
                tareaArgos.Description = !String.isEmpty(response.getBody()) ? response.getBody().left(32000) : '';
                    JsonResponse responseTransformado = (JsonResponse) System.JSON.deserialize(response.getBody(),  JsonResponse.class);
                    try {
                        rellenarCaseExtension(caso, responseTransformado);

                    } catch (Exception e) {
                        rellenarCaseExtensionFallo(caso);
                    }

                    //tareaArgos.Description = 'Cerrar: ' + cerrar + ' ------ Response: ' + response.getBody().left(32000);
                    tareaArgos.CC_Consulta__c = responseTransformado?.multiFactorAuthentication?.left(50);
                    tareaArgos.CC_Correo_Asociado_Id__c = String.valueOf(responseTransformado?.operationNowId)?.left(255);
                    // tareaArgos.CC_Actividad_Relacionada_Id__c = String.valueOf(responseTransformado?.message).left(18);
                    tareaArgos.CC_Detalles_Consulta__c = String.valueOf(responseTransformado?.message)?.left(255);
                    tareaArgos.CC_Espacio__c = String.valueOf(responseTransformado?.operationFraudId)?.left(50);
                    
                    if(responseTransformado?.extraData != null) {
                        if(responseTransformado?.extraData?.risk != null) {
                            tareaArgos.AV_Valor1__c = !String.isEmpty(responseTransformado?.extraData?.risk[0]?.e) ? String.valueOf(responseTransformado?.extraData?.risk[0]?.e).left(255) : '';
                            tareaArgos.AV_Valor2__c = !String.isEmpty(responseTransformado?.extraData?.risk[0]?.operation_id) ? String.valueOf(responseTransformado?.extraData?.risk[0]?.operation_id).left(255) : '';
                            tareaArgos.AV_Valor3__c = !String.isEmpty(responseTransformado?.extraData?.risk[0]?.ope ) ? String.valueOf(responseTransformado?.extraData?.risk[0]?.ope).left(255) : '';
                            tareaArgos.AV_Valor4__c = !String.isEmpty(responseTransformado?.extraData?.risk[0]?.payee) ? String.valueOf(responseTransformado?.extraData?.risk[0]?.payee).left(255) : '';
                            tareaArgos.AV_Valor5__c = !String.isEmpty(responseTransformado?.extraData?.risk[0]?.usuclo) ? String.valueOf(responseTransformado?.extraData?.risk[0]?.usuclo).left(255) : '';
                            
                            tareaArgos.CC_Fecha_Inicio__c = !String.isEmpty(responseTransformado?.extraData?.risk[0]?.first_try) ?  Datetime.valueOf(responseTransformado?.extraData?.risk[0]?.first_try) : null; 
                            tareaArgos.CC_Fecha_Fin__c = !String.isEmpty(responseTransformado?.extraData?.risk[0]?.last_try) ?  Datetime.valueOf(responseTransformado?.extraData?.risk[0]?.last_try) : null;

                            
                            tareaArgos.CC_Solicitud_Informacion__c = responseTransformado?.extraData?.risk[0]?.restricted;
                            tareaArgos.CC_validacion_tarea_manual__c = responseTransformado?.extraData?.risk[0]?.denied;
                        }
                    }
                }   
            }
            return tareaArgos;
    }

    
    private static void rellenarCaseExtension(Case caso, JsonResponse responseTransformado){
        Boolean restricted = false;
        Boolean denied = false;
        List<CBK_Case_Extension__c> listaExt = [
            SELECT Id, CC_Risk_Restricted__c, CC_Risk_Denied__c
            FROM   CBK_Case_Extension__c
            WHERE  Case_Id__c = :caso.Id
            LIMIT  1
        ];

        if(responseTransformado?.extraData != null) {
            restricted = responseTransformado?.extraData?.risk[0]?.restricted;
            denied = responseTransformado?.extraData?.risk[0]?.denied;
        }

        if (!listaExt.isEmpty()) {
            listaExt[0].CC_Risk_Restricted__c = restricted;
            listaExt[0].CC_Risk_Denied__c = denied;
            update listaExt[0];

        } else {
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                CC_Risk_Restricted__c = restricted,
                CC_Risk_Denied__c = denied,
                Case_Id__c = caso.Id
            );
            insert extension;

            caso.CBK_Case_Extension_Id__c = extension.Id;
            update caso;

        }
    }

    private static void rellenarCaseExtensionFallo(Case caso ){
        Boolean restricted = false;
        Boolean denied = false;
        List<CBK_Case_Extension__c> listaExt = [
            SELECT Id, CC_Risk_Restricted__c, CC_Risk_Denied__c
            FROM   CBK_Case_Extension__c
            WHERE  Case_Id__c = :caso.Id
            LIMIT  1
        ];

        if (!listaExt.isEmpty()) {
            listaExt[0].CC_Risk_Restricted__c = restricted;
            listaExt[0].CC_Risk_Denied__c = denied;

            update listaExt[0];

        } else {
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                CC_Risk_Restricted__c = restricted,
                CC_Risk_Denied__c = denied,
                Case_Id__c = caso.Id
            );
            insert extension;

            caso.CBK_Case_Extension_Id__c = extension.Id;
            update caso;

        }
    }
    //Creamos el body de la petición a Argos para guardar el caso.
    public static String getRequestBodyGuardar(Case caso, CC_Settings__c configuracionesGenerales,  Map<String,String> datos) {
        
        CC_Configuracion_Argos__mdt  result = CC_Configuracion_Argos__mdt.getInstance('CC_Integracion_Argos_Guardar');
        String tematicaName, tematicaId, prodServId, prodServName, motivoId, motivoName;
        String esImagin = Boolean.valueOf(datos.get('imagin')) ? configuracionesGenerales.CC_Configuracion_4__c : configuracionesGenerales.CC_Configuracion_6__c;
         Set<Id> idsMCC = new Set<Id>();

         tematicaId = datos.get('tematicaId') != null ? datos.get('tematicaId') : (caso.CC_MCC_Tematica__c != null ? caso.CC_MCC_Tematica__c : '');
         prodServId = datos.get('prodServId') != null ? datos.get('prodServId') : (caso.CC_MCC_ProdServ__c != null ? caso.CC_MCC_ProdServ__c : '');
         motivoId = datos.get('motivoId') != null ? datos.get('motivoId') : (caso.CC_MCC_Motivo__c != null ? caso.CC_MCC_Motivo__c : '');
           
        if (datos.get('tematicaId') != null) idsMCC.add(datos.get('tematicaId'));
        if (datos.get('prodServId') != null) idsMCC.add(datos.get('prodServId'));
        if (datos.get('motivoId') != null) idsMCC.add(datos.get('motivoId'));
            

        // Agrega Name a la query
        Map<Id, CC_MCC__c> mapaMCC = new Map<Id, CC_MCC__c>(
            [SELECT Id, Name, RecordType.DeveloperName FROM CC_MCC__c WHERE Id IN :idsMCC AND CC_Activo__c = true]
        );

            tematicaName = mapaMCC.get(datos.get('tematicaId'))?.Name != null ? mapaMCC.get(datos.get('tematicaId'))?.Name : (caso.CC_MCC_Tematica__r != null ? caso.CC_MCC_Tematica__r.Name : '');
            prodServName = mapaMCC.get(datos.get('prodServId'))?.Name != null ? mapaMCC.get(datos.get('prodServId'))?.Name : (caso.CC_MCC_ProdServ__r != null ? caso.CC_MCC_ProdServ__r.Name : '');
            motivoName = mapaMCC.get(datos.get('motivoId'))?.Name != null ? mapaMCC.get(datos.get('motivoId'))?.Name : (caso.CC_MCC_Motivo__r != null ? caso.CC_MCC_Motivo__r.Name : '');

            String body = '{' +
            '  "argosToken": "' + result.CC_Token__c +'",' +
            '  "userAgent": "' + result.CC_Tipo_Navegador__c +'",' +
            '  "operation": {' +
            '    "pre_auth": true,' +
            '    "case_id": "'+ caso.Id +'",' +
            '    "apptime": "'+  datos.get('fecha') +'",' +
            '    "phone": "' + datos.get('numero') + '",' +
            '    "entry_channel": "'+ caso.Origin +'",' +
            '    "cognitive_id": "'+ datos.get('connIdCognitive') +'",' +
            '    "email": "'+ datos.get('fromEmail') +'",' +
            '    "prefix": "' + datos.get('prefijo') + '",' +
            '    "topic_id": "'+ tematicaId +'",' +
            '    "topic": "'+ tematicaName +'",' +
            '    "service_id": "'+ prodServId +'",' +
            '    "service": "'+ prodServName +'",' +
            '    "reason_id": "'+ motivoId +'",' +
            '    "reason": "'+ motivoName +'",' 
                + datos.get('listaFraude') +
            '    "call": "'+ datos.get('tipoLlamada') +'"' +
            '  },' +
            '  "operationDescription": "' + configuracionesGenerales.CC_Configuracion_7__c + '",' +
            '  "enterprise": "'+ esImagin +'",' +
            '  "aliases": {' + datos.get('aliases') + 
            '  }' +
            '}';
        
            return body;
    }

    //Creamos el body de la petición a Argos para cerrar el caso. (feedback)
    public static String getRequestBodyCerrar(Case caso, CC_Settings__c configuracionesGenerales,  Map<String,String> datos) {

        CC_Configuracion_Argos__mdt  result = CC_Configuracion_Argos__mdt.getInstance('CC_Integracion_Argos_Cerrar');

        String esImagin = Boolean.valueOf(datos.get('imagin')) ? configuracionesGenerales.CC_Configuracion_4__c : configuracionesGenerales.CC_Configuracion_6__c;    
       
           String body = '{' +
        '  "argosToken": "' + result.CC_Token__c +'",' +
        '  "userAgent": "' + result.CC_Tipo_Navegador__c +'",' +
        '  "operation": {' +
        '    "pre_auth": false,' +
        '    "case_id": "'+ caso.Id +'",' +
        '    "apptime": "'+  datos.get('fecha') +'",' +
        '    "entry_channel": "'+ caso.Origin +'",' +
        '    "cognitive_id": "'+ datos.get('connIdCognitive') +'",' +
        '    "email": "'+ datos.get('fromEmail') +'",' +
        '    "result": "' + (!String.isEmpty(caso.CC_Motivo_Derivacion__c) ? caso.CC_Motivo_Derivacion__c : '') + '",' +
            + datos.get('listaFraude') +
        '    "call": "'+ datos.get('tipoLlamada') +'",' +
        '    "tf9_activated":"' +  datos.get('tieneTareasTF')+'",'+
        '    "fraud_check": "'+ datos.get('tipoRestriccion') +'"' +
        '  },' +
        '   "operationDescription": "' + configuracionesGenerales.CC_Configuracion_7__c + '",' +
        '   "enterprise": "'+ esImagin +'",' +
        '   "authorizationMethod":"' + (!String.isEmpty(caso.CC_OTP_Nivel__c) ? caso.CC_OTP_Nivel__c : '') + '",' +
        '   "isAuthorizationSuccessful":' + ((!String.isEmpty(caso.CC_Status_Autorizacion__c) && caso.CC_Status_Autorizacion__c == 'APPROVED') ? 'true' : 'false') + ','+
        '   "op_result":"' + (!String.isEmpty(caso.CC_Motivo_Derivacion__c) ? caso.CC_Motivo_Derivacion__c : '') + /*'"' +*/
        //no es seguro que haya que enviarlo
        '",' + '   "aliases": {' + datos.get('aliases') + 
        '  }' +
        //aliases end
        '}';
    
        return body;
    }

    //Recuperamos y formateamos los datos del caso, devolviendo un mapa con los datos necesarios para los body de la petición a Argos.  
    public static Map<String,String> recupararDatos(Case caso, CC_Settings__c configuracionesGenerales) {
        Map<String,String> retorno = new Map<String,String>();
        Boolean imagin = false;
        String numPerso, numDoc, numDocRepresentante, tipoPersona, numPerRepresentante, tipoLlamada, tipoRestriccion, aliases, tieneTareasTF = '';
 
            if (caso.CC_Representante__c != null) {
                //Numper y doc del menor
                numPerso = caso.Account?.AV_NumPerso__c != null ? caso.Account?.AV_NumPerso__c : caso.Account?.CC_NumPerso__c != null ? caso.Account?.CC_NumPerso__c : '';
                
                numDoc = caso.Account?.CC_Numero_Documento__c;
                //Numper y doc del representante del menor
                numPerRepresentante = caso.CC_Representante__r?.CC_Representante__r.AV_NumPerso__c != null ? caso.CC_Representante__r?.CC_Representante__r.AV_NumPerso__c : caso.CC_Representante__r?.CC_Representante__r.CC_NumPerso__c != null ? caso.CC_Representante__r?.CC_Representante__r.CC_NumPerso__c : '';
                
                numDocRepresentante =  caso.CC_Representante__r?.CC_Representante__r?.CC_Numero_Documento__c;
                
                tipoPersona = configuracionesGenerales.CC_Configuracion_1__c;

                aliases = '"type": "'+ tipoPersona +'", "dni": "'+ numDoc +'", "representative_dni" : "'+ numDocRepresentante +'", "representative_numperso": "'+ numPerRepresentante +'", "numperso": "'+ numPerso +'"'; 

            } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
                //numper de la cuenta y nif
                numPerso = caso.Account?.AV_NumPerso__c != null ? caso.Account?.AV_NumPerso__c : caso.Account?.CC_NumPerso__c != null ? caso.Account?.CC_NumPerso__c : '';
                
                numDoc = caso.Account?.CC_Numero_Documento__c;
                //numper y doc del apoderado
                numPerRepresentante = !String.isEmpty(caso.Contact?.CIBE_NumPerso__c) ? caso.Contact?.CIBE_NumPerso__c : !String.isEmpty(caso.Contact?.AV_NumPerso__c) ? caso.Contact?.AV_NumPerso__c : !String.isEmpty(caso.Contact?.CC_NumPerso__c) ? caso.Contact?.CC_NumPerso__c : '';
                
                numDocRepresentante = caso.Contact?.CC_Numero_Documento__c;
                tipoPersona = configuracionesGenerales.CC_Configuracion_2__c;

                aliases = '"type": "'+ tipoPersona +'", "cif": "'+ numDoc +'", "representative_dni" : "'+ numDocRepresentante +'", "representative_numperso": "'+ numPerRepresentante + '", "numperso": "'+  numPerso +'"'; 
                
            } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CC_Cliente' && caso.Account.AV_Segmento__c == 'RPF') {
                // Si el segmento es RPF, se toma el AV_NumPerso de la cuenta
                numPerso = !String.isEmpty(caso.Account?.AV_NumPerso__c) ? caso.Account?.AV_NumPerso__c : !String.isEmpty(caso.Account?.CC_NumPerso__c) ? caso.Account?.CC_NumPerso__c  : '';
                numDoc = caso.Account?.CC_Numero_Documento__c;
                tipoPersona = configuracionesGenerales.CC_Configuracion_10__c;

                aliases = '"type": "'+ tipoPersona +'", "dni": "'+ numDoc +'", "numperso": "'+ numPerso +'"'; 

            } else {
                numPerso = caso.Account?.AV_NumPerso__c != null ? caso.Account?.AV_NumPerso__c : caso.Account?.CC_NumPerso__c != null ? caso.Account?.CC_NumPerso__c : '';

                numDoc = caso.Account?.CC_Numero_Documento__c;

                tipoPersona = configuracionesGenerales.CC_Configuracion_3__c;
           
                aliases = '"type": "'+ tipoPersona +'", "dni": "'+ numDoc +'", "numperso": "'+ numPerso +'"'; 

            }
            
            Map<String,String> telefono = recuperarTelefono(caso.CC_Telefono_Contacto__c);
            
            Map<String, String> tareas = tareasDelCaso(caso.Id);

             tipoLlamada = tareas.get('tipoLlamada') == 'Saliente' ? configuracionesGenerales.CC_Configuracion_8__c : configuracionesGenerales.CC_Configuracion_9__c;

             tieneTareasTF = tareas.get('tieneTareaTF');
    

             tipoRestriccion = tipoRestriccion(caso);


        if (caso.CC_Representante__c != null) {
            imagin =  (caso.CC_Representante__r?.CC_Representante__r.AV_IndicadoresClientes__c != null && caso.CC_Representante__r?.CC_Representante__r.AV_IndicadoresClientes__c.contains('28')) ? true : false;
        }else{
            imagin = (caso.Account?.AV_IndicadoresClientes__c != null && caso.Account?.AV_IndicadoresClientes__c.contains('28')) ? true : false;
        }

        List<String> listaFraude = recuperarCaracteristicas(caso);
        String listaFraudeString = '    "fraud_indicators": [';
        if (listaFraude != null && !listaFraude.isEmpty()) {
            listaFraudeString += '"' + String.join(listaFraude, '","') + '"';
        }
        listaFraudeString += '],';

        String connIdCognitive = '';
        if(caso.Origin == 'Phone'){
            List<Task> lstTask = [SELECT Id, CC_Llamada_Id__c, CC_Llamada_Id__r.CC_ConnId_Cognitivo__c 
                                            FROM Task 
                                            WHERE Type = 'Llamada entrante' AND CC_Llamada_Id__c != null AND WhatId = :caso.Id
                                            ORDER BY CreatedDate DESC LIMIT 1];
            if(!lstTask.isEmpty() && lstTask[0].CC_Llamada_Id__c != null) {
                connIdCognitive = lstTask[0].CC_Llamada_Id__r.CC_ConnId_Cognitivo__c;
            }
        }

        String fromEmail = '';
        if(caso.Origin == 'Email'){
            List<EmailMessage> lstEmails= [SELECT Id, FromAddress 
                                    FROM EmailMessage 
                                    WHERE ParentId = :caso.Id 
                                    ORDER BY CreatedDate ASC LIMIT 1];
            if(!lstEmails.isEmpty() && lstEmails[0].FromAddress != null){
                fromEmail = lstEmails[0].FromAddress;
            }
        }

        
        Datetime nowUtc = CBK_UtilsDate.nowSYS();
        String formattedDate = nowUtc.format('yyyy-MM-dd HH:mm:ss', 'UTC');

        retorno.put('fecha', formattedDate);
        retorno.put('aliases', aliases);
        retorno.put('imagin', String.valueOf(imagin));
        retorno.put('tipoLlamada', tipoLlamada);
        retorno.put('prefijo', telefono.get('prefijo'));
        retorno.put('numero', telefono.get('numero'));
        retorno.put('tipoRestriccion', tipoRestriccion);
        retorno.put('tieneTareasTF', tieneTareasTF);
        retorno.put('listaFraude', listaFraudeString);

        retorno.put('connIdCognitive', connIdCognitive);
        retorno.put('fromEmail', fromEmail);

        
        return retorno;
    }

    //Recuperamos y formateamos el numero de teléfono, separando el prefijo y el número. (ya que deben viajar por separado en el body)
    public static Map<String, String> recuperarTelefono(String telefono) {
        Map<String, String> retorno = new Map<String, String>{ 'prefijo' => '', 'numero' => '' };
    
        if (!String.isBlank(telefono)) {
            telefono = telefono.trim();
    
            if (telefono.startsWith('+')) {
                if (telefono.contains(' ')) {
                    List<String> partes = telefono.split(' ', 2);
                    retorno.put('prefijo', partes[0]);
                    retorno.put('numero', partes[1]);
                } else if (telefono.length() > 3) {
                    retorno.put('prefijo', telefono.substring(0, 3));
                    retorno.put('numero', telefono.substring(3));
                }
            } else {
                retorno.put('prefijo', '+34');
                retorno.put('numero', telefono);
            }
        }
    
        return retorno;
    }
    
    //Recuperamos las caracteristicas del cliente, devolviendo una lista de Ids de las caracteristicas.
    public static List<String> recuperarCaracteristicas(Case caso) {
        List<String> resultado = new List<String>();
        for (CC_Caracteristica_Detalle__c c : obtenerCaracteristicas(caso)) {
            resultado.add(String.valueOf(c.CC_Caracteristica__r?.Id));
        }
        return resultado;
    }
    
    private static List<CC_Caracteristica_Detalle__c> obtenerCaracteristicas(Case caso) {
         List<CC_Caracteristica_Detalle__c> retorno = new List<CC_Caracteristica_Detalle__c>();
         String cuentaId;
         String contactoId;
 
         if (caso.CC_Representante__c != null) { 
             cuentaId = caso.CC_Representante__r?.CC_Representante__c;
             contactoId = caso.ContactId;
         } else {
             cuentaId = caso.AccountId;
             contactoId = caso.ContactId;
         }
     
         retorno = [SELECT CC_Caracteristica__c, CC_Caracteristica__r.Id, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_RestriccionTotal__c FROM CC_Caracteristica_Detalle__c WHERE (CC_Cuenta__c = :cuentaId OR CC_Cliente__c = :contactoId) AND CC_Caracteristica__r.OS_Negocio__c = 'FRA'];
 
         return retorno;
    }

    //Recuperamso el tipo de restricción del caso, devolviendo 'none', 'restriccion_parcial' o 'restriccion_total'.
    public static String tipoRestriccion(Case caso) {
        String resultado = 'none';
        Set<Id> idsCaracteristicas = new Set<Id>();


        for (CC_Caracteristica_Detalle__c c : obtenerCaracteristicas(caso)) {
            if (c.CC_Caracteristica__r?.CC_RestriccionTotal__c == true) {
                return 'restriccion_total';
            }
            idsCaracteristicas.add(c.CC_Caracteristica__c);
        }

        if (!idsCaracteristicas.isEmpty()) {
            List<CC_MCC_Caracteristica__c> mccCaracteristicas = [
                SELECT Id FROM CC_MCC_Caracteristica__c
                WHERE CC_MCC__c = :caso.CC_MCC_Motivo__c AND CC_Caracteristica__c IN :idsCaracteristicas
            ];
            resultado = (!mccCaracteristicas.isEmpty()) ? 'restriccion_parcial' : 'none';
        }

        return resultado;
    }

    //Recuperamos las tareas del caso, devolviendo un mapa con el tipo de llamada y si tiene tarea TF (la tarea de TF se crea dandole al boton de "TF" que esta al lado de Guardar / Guardar y Cerrar).
    public static Map<String, String> tareasDelCaso(Id casoId){
        Map<String, String> tareasEspecificas = new Map<String, String>{
            'tipoLlamada' => 'Entrante',
            'tieneTareaTF' => 'no'
        };
        String tipoLlamada = '';
        List<Task> tareas = new List<Task>();

            if(casoId == null) {
                return tareasEspecificas;
            }else {
                tareas = [SELECT Id, Type, Status,CC_Llamada_Id__r.CC_Tipo__c, CC_Llamada_Id__r.CC_DNIS__c FROM Task WHERE WhatId = :casoId AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task') ORDER BY  CreatedDate DESC];

                if(!tareas.isEmpty()){
                    for(Task tarea : tareas){
                        if(tarea.CC_Llamada_Id__r != null && (tarea.Status == 'Open' || tarea.Type == 'Consulta' || tarea.Type == 'Llamada transferida') && string.isEmpty(tipoLlamada)){
                        tareasEspecificas.put('tipoLlamada', tarea.CC_Llamada_Id__r?.CC_Tipo__c);
                        tipoLlamada = tarea.CC_Llamada_Id__r?.CC_Tipo__c;
                        } else if(tarea.Type == 'TF'){
                            tareasEspecificas.put('tieneTareaTF', 'si');
                    }
                }
            }
         return tareasEspecificas;
     }
    }

    //Creamos una comunicacion asociada al caso y al cliente en caso que el endpoint nos devuelva un "2" 
    private static void crearComunicacion(Case caso){
        CC_Comunicaciones__c comunicacion = new CC_Comunicaciones__c(
            CC_Case__c = caso.Id,
            CC_Cliente__c = caso.AccountId,
            CC_Estado__c = 'Denegado',
            CC_Nivel__c = 'Cliente Digital',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS'),
            CC_Origen__c = 'Argos'
        );
        insert comunicacion;
	
	}

    //Formateamos el json de respuesta que nos devuelve el endpoint de Argos.
    // ejemplo de body {"operationFraudId":"","multiFactorAuthentication":"0","message":"Known user and device","device":{},"extradata":{"risk":{"ope":"ContactCenter","first_try":"2025-05-14 09:33:09","last_try":"2025-05-14 09:33:09"}},"reason":"","operationNowId":"b23106c2-1bce-5525-a0e5-a80cff605b88"}
    public class JsonResponse {
        public ExtraData extraData;
        public String multiFactorAuthentication;
        public String operationNowId;
        public String message;
        public String operationFraudId;
    }

    public class ExtraData {
        public List<Risk> risk;
    }

    public class Risk {
        public String ope;
        public String first_try;
        public String last_try;
        public Boolean denied;
        public Boolean restricted;
        public String e;
        public String payee;
        public String usuclo;
        public String operation_id;
    }

}