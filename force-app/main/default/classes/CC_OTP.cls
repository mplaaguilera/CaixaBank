public with sharing class CC_OTP {
     
    public class OTPWrapper
    {
        @AuraEnabled
        public String estado{get;set;}
        @AuraEnabled
        public Datetime fechaEnvio{get;set;}
        @AuraEnabled
        public Datetime fechaValidacion{get;set;}
        @AuraEnabled
        public Double intentosValidacion {get;set;}
        @AuraEnabled
        public String numeroCaso{get;set;}
		@AuraEnabled
        public String codigoOTP{get;set;}
        @AuraEnabled
        public String resultado{get;set;}
        @AuraEnabled
        public String codigoError{get;set;}
        @AuraEnabled
        public String recordId {get;set;}
        @AuraEnabled
        public String nombreBoton {get;set;} 
        @AuraEnabled
        public String nivel {get;set;}
    }
    
    // @AuraEnabled
    // public static List<Case> datosCaso(String recordId) {
    //     List<Case> caso = [SELECT CC_Canal_Procedencia__c, Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, AccountId, ContactId, CC_Tipo_Cliente__c FROM Case WHERE Id =:recordId LIMIT 1];
    //     return caso;
    // }
    
    // @AuraEnabled
    // public static Boolean existeOTPCaso(Id recordId) {
    //     Boolean resultado = true; 
        
    //     Integer numComunicaciones = [SELECT Count() FROM CC_Comunicaciones__c WHERE CC_Case__c =: recordId AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS')];
        
    //     if(numComunicaciones != null && numComunicaciones <= 1){
    //     	resultado = false;
    //     } 
    //     return resultado;
    // }
    
    @AuraEnabled
    public static Map<String,Object> existeBloqueoNuevo(Id recordId) {
        Map<String,Object> oRes = new Map<String,Object>();
        Boolean resultado = false;        
        List<Task> comprobarLlamadas = comprobarSiHayLlamada(recordId);
        Boolean tienePSAutenticacion = getPSAutenticacion();
        List<Case> casos = [
                SELECT CC_Status_Autorizacion__c,
                    CC_OTP_Intentos__c, 
                    AccountId,
                    ContactId, 
                    CC_Idioma__c, 
                    OwnerId, 
                    CC_Tipo_Cliente__c, 
                    CC_Representante__c, 
                    Account.AV_Age__c, 
                    Account.CC_MenorEmancipado__c, 
                    CC_MCC_Motivo__r.CC_ImpedirNivel2__c, 
                    CC_MCC_Motivo__r.CC_ImpedirClienteDigital__c, 
                    CC_Oportunidad_Creada__c,
                    CC_Representante__r.CC_Representante__r.AV_Age__c,
                    Account.RecordType.DeveloperName,
                    Contact.RecordType.DeveloperName,
                    Contact.CC_Edad__c
                FROM Case 
                WHERE Id =:recordId 
                LIMIT 1
            ];
        String comprobarIntento;
        if(!casos.isEmpty()){
            comprobarIntento = comprobarIntentos(recordId, casos[0].AccountId);
        }
        
        Boolean comprobarIntentos = false;
        Boolean tieneLlamadas = true;

        if(!String.isEmpty(comprobarIntento) && comprobarIntento == 'Cliente Bloqueado'){
            comprobarIntentos = true;
            resultado = false;
        } 
        if(comprobarLlamadas.isEmpty() && !tienePSAutenticacion){
            tieneLlamadas = false;
        }

            if(!casos.isEmpty()){
            oRes.put('Llamadas', tieneLlamadas);
            oRes.put('Cliente Bloqueado', comprobarIntentos);
            oRes.put('Idioma', casos.get(0).CC_Idioma__c);
            oRes.put('AccountId', casos.get(0).AccountId);
            oRes.put('ContactId', casos.get(0).ContactId);
            oRes.put('OTPIntentos', casos.get(0).CC_OTP_Intentos__c);
            oRes.put('EstadoAut', casos.get(0).CC_Status_Autorizacion__c);
            oRes.put('OwnerId', casos.get(0).OwnerId);
            oRes.put('TipoCliente', casos.get(0).CC_Tipo_Cliente__c);
            oRes.put('ClienteMenor', (casos.get(0).Account.AV_Age__c  < 18 && casos.get(0).Account.AV_Age__c != null && !casos.get(0).Account.CC_MenorEmancipado__c));
            oRes.put('Representante', (casos.get(0).CC_Representante__c != null));
            oRes.put('ImpedirNivelDos', casos.get(0).CC_MCC_Motivo__r.CC_ImpedirNivel2__c);
            oRes.put('ImpedirClienteDigital', casos.get(0).CC_MCC_Motivo__r.CC_ImpedirClienteDigital__c);
            oRes.put('OportunidadCreada', casos.get(0).CC_Oportunidad_Creada__c);
            oRes.put('EdadCliente', casos.get(0).Account.AV_Age__c);
                if(casos.get(0).CC_Status_Autorizacion__c != null && casos.get(0).CC_Status_Autorizacion__c != '' && casos.get(0).CC_Status_Autorizacion__c != 'ERROR' && casos.get(0).CC_Status_Autorizacion__c != 'UNAUTHORIZED' && casos.get(0).CC_Status_Autorizacion__c != 'TIMEOUT' && casos.get(0).CC_Status_Autorizacion__c != 'ABORTED'&& casos.get(0).CC_Status_Autorizacion__c != 'EXPIRED' && casos.get(0).CC_Status_Autorizacion__c != 'NOT_IDENTIFIED' && casos.get(0).CC_Status_Autorizacion__c != 'IS_MINOR'&& casos.get(0).CC_Status_Autorizacion__c != 'IS_A_COMPANY'&& casos.get(0).CC_Status_Autorizacion__c != 'NOTIFICATIONS_OFF' && casos.get(0).CC_Status_Autorizacion__c != 'SIN ESTADO'){
                    resultado = true;
                    //PERMITIR lanzar autenticación (sólo 1 vez más)
                    if(casos.get(0).CC_Status_Autorizacion__c == 'REJECTED' && (casos.get(0).CC_OTP_Intentos__c == null ||  casos.get(0).CC_OTP_Intentos__c == 0)){
                        resultado = false;  
                    }
                }
        }
        List <CC_Settings__c> botonEmergencia = [SELECT CC_Activa__c FROM CC_Settings__c WHERE Name = 'CC_VisibilidadBotonEmergenciaAut' LIMIT 1];
        oRes.put('MostrarBotonEmergencia', botonEmergencia != null && !botonEmergencia.isEmpty() ? botonEmergencia[0].CC_Activa__c : false);
        Boolean circuitoAutenticacion = [SELECT CC_Activa__c FROM CC_Settings__c WHERE Name = 'CC_CircuitoAutenticacion' LIMIT 1].CC_Activa__c;
        oRes.put('circuitoAutenticacion', circuitoAutenticacion);

        //Comprobar la edad del cliente, representante o apoderado
        if (casos.get(0).CC_Representante__c != null) {
            if (casos.get(0).CC_Representante__r.CC_Representante__r.AV_Age__c != null) {
                oRes.put('EdadCliente', casos.get(0).CC_Representante__r.CC_Representante__r.AV_Age__c);
            }
        //Cuenta fisica
        } else if (casos.get(0).Account.RecordType.DeveloperName != 'CC_Cliente' && casos.get(0).Contact.RecordType.DeveloperName != 'CIBE_Apoderado') {
            if (casos.get(0).Account.AV_Age__c != null) {
                oRes.put('EdadCliente', casos.get(0).Account.AV_Age__c);
            }
        }

        oRes.put('Resultado', resultado);
        return oRes;
    }    

    @AuraEnabled
    public static List<OTPWrapper> obtenerHistoricoOTPCliente(Id recordId, String idCliente) {
        
        List<OTPWrapper> otpWrapperList = new List<OTPWrapper>();
        if (idCliente != null) {
            
            Id recordTypeIdOTP = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');
            List<CC_Comunicaciones__c> otpsList = [SELECT Id, CC_Estado__c, CC_Fecha_Envio__c,CC_Fecha_Validacion__c, CC_Intentos_Validacion_OTP__c, CC_Codigo_OTPSMS__c,CC_Resultado_Validacion__c, CC_Mensaje_Error__c, CC_Case__c, CC_Case__r.CaseNumber, CC_Nivel__c
                                                   FROM CC_Comunicaciones__c
                                                   WHERE CC_Cliente__c = :idCliente
                                                   AND RecordTypeId = :recordTypeIdOTP 
                                                   ORDER BY CreatedDate DESC LIMIT 10];
            for (CC_Comunicaciones__c otp : otpsList) {
                OTPWrapper otpWrapper = new OTPWrapper();
                otpWrapper.nivel = otp.CC_Nivel__c;
                otpWrapper.numeroCaso = otp.CC_Case__r.CaseNumber;
                otpWrapper.estado = otp.CC_Estado__c;
                otpWrapper.fechaEnvio = otp.CC_Fecha_Envio__c;
                otpWrapper.fechaValidacion = otp.CC_Fecha_Validacion__c;
                otpWrapper.intentosValidacion = otp.CC_Intentos_Validacion_OTP__c;
                otpWrapper.codigoOTP = otp.CC_Codigo_OTPSMS__c;
                otpWrapper.resultado = otp.CC_Resultado_Validacion__c;
                otpWrapper.codigoError = otp.CC_Mensaje_Error__c;
                    if (otp.CC_Nivel__c == 'Nivel 2'){
                        otpWrapper.nombreBoton = otp.CC_Estado__c == 'Pdte. Envío' ? 'Enviar' : 'Validar';
                    }else{
                        otpWrapper.nombreBoton = 'Cancelar';
                    }
                otpWrapperList.add(otpWrapper);
            }
        }
        return otpWrapperList;
    }
    
    @AuraEnabled
    public static List<OTPWrapper> obtenerOTPCliente(Id recordId, String idCliente) {
        List<OTPWrapper> otpWrapperList = new List<OTPWrapper>();
        if (idCliente != null)
        {
            Id recordTypeIdOTP = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');
            
            List<CC_Comunicaciones__c> otpsList = [SELECT Id, CC_Nivel__c, CC_Estado__c, CC_Fecha_Envio__c,CC_Fecha_Validacion__c, CC_Intentos_Validacion_OTP__c, CC_Codigo_OTPSMS__c,CC_Resultado_Validacion__c, CC_Mensaje_Error__c, CC_Case__c, CC_Case__r.CaseNumber
                                                   FROM CC_Comunicaciones__c
                                                   WHERE CC_Cliente__c = :idCliente
                                                   AND CC_Case__c = :recordId
                                                   AND (CC_Estado__c != 'Rechazado' AND CC_Estado__c != 'Error' AND CC_Estado__c != 'Cerrado' AND CC_Estado__c != 'Expirado' AND CC_Estado__c != 'Denegado' AND CC_Estado__c != 'Aprobado' AND CC_Estado__c != 'No autorizado'  AND CC_Estado__c != 'Cancelada por agente') 
												   AND RecordTypeId = :recordTypeIdOTP
                                                   ORDER BY CreatedDate DESC];
            
            for (CC_Comunicaciones__c otp : otpsList) {
                OTPWrapper otpWrapper = new OTPWrapper();
                otpWrapper.nivel = otp.CC_Nivel__c;
                otpWrapper.recordId = otp.Id;
                otpWrapper.numeroCaso = otp.CC_Case__r.CaseNumber;
                otpWrapper.estado = otp.CC_Estado__c;
                otpWrapper.fechaEnvio = otp.CC_Fecha_Envio__c;
                otpWrapper.fechaValidacion = otp.CC_Fecha_Validacion__c;
                otpWrapper.intentosValidacion = otp.CC_Intentos_Validacion_OTP__c;
                otpWrapper.codigoOTP = otp.CC_Codigo_OTPSMS__c;
                otpWrapper.resultado = otp.CC_Resultado_Validacion__c;
                otpWrapper.codigoError = otp.CC_Mensaje_Error__c;
                    if (otp.CC_Nivel__c == 'Nivel 2'){
                        otpWrapper.nombreBoton = otp.CC_Estado__c == 'Pdte. Envío' ? 'Enviar' : 'Validar';
                    }else{
                        otpWrapper.nombreBoton = 'Cancelar';
                    }
                
                otpWrapperList.add(otpWrapper);
            }
        }
        return otpWrapperList;
    }
    //SMS
    @AuraEnabled
    public static void enviarRegistro (Id recordId){
        Set<Id> idsOTP = new Set<Id>();
        if (String.valueOf(Id.valueOf(recordId)?.getSObjectType()) == 'Case'){
        	Id otp = getOTP(recordId, 'Nivel 2', 'Pdte. Envío');    
            if(otp != null){
            	idsOTP.add(otp);    
            }
        }else{
            idsOTP.add(recordId);
        }
        if(!idsOTP.isEmpty()){
            CC_WS_Envio_OTP.CC_WS_Envio_OTP(idsOTP);          
        }     
    }
    
    @AuraEnabled
    public static List<CC_Lista_Valores__c> preguntasOTP(String lista){
        List<CC_Lista_Valores__c> listaPreguntas = CC_Listas_Valores.LookupValues(lista, null);
    	
    	return listaPreguntas;
    
    }

    @AuraEnabled
    public static string comprobarDatos2Nivel(Id recordId) {
        string respuesta = 'OK';
        Case caso = [SELECT Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone, CC_Representante__c, CC_Representante__r.CC_Representante__r.PersonMobilePhone, CC_Representante__r.CC_Representante__r.AV_Age__c, Contact.RecordType.DeveloperName, Contact.CIBE_Telefono1__c FROM Case WHERE Id = :recordId LIMIT 1];
        System.debug('::: caso: ' + caso);
        List<CC_Lista_Valores__c> listaPreguntas = [SELECT CC_Valor__c, CC_Orden__c, CC_Servicio__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE RecordType.Name = 'Valor' AND CC_Lista__r.Name = 'Preguntas OTPSMS 2 Nivel'];
        Id recordTypeIdTask = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        List<Task> task = [SELECT Id, CC_Llamada_Id__r.CC_Tipo__c FROM Task WHERE WhatId = :caso.Id AND RecordTypeId = :recordTypeIdTask AND CreatedDate = TODAY AND (Status = 'Open' OR Type = 'Llamada transferida' OR Type = 'Consulta') ORDER BY  CreatedDate DESC LIMIT 1];
        Boolean tienePSAutenticacion = getPSAutenticacion();
        String comprobarIntento;
        if(caso != null){
            comprobarIntento = comprobarIntentos( recordId, caso.AccountId);
        }
        
        if(!String.isEmpty(comprobarIntento) && comprobarIntento == 'Cliente Bloqueado'){
            respuesta = 'CLIENTE BLOQUEADO';

        }else if(task.isEmpty() && !tienePSAutenticacion){
            respuesta = 'SIN LLAMADAS';
        } else {
            if (caso.CC_Representante__c != null) {
                if (caso.CC_Representante__r.CC_Representante__r.AV_Age__c == null && caso.CC_Representante__r.CC_Representante__r.PersonMobilePhone == null) {
                    respuesta = 'SIN DATOS';
                }
            //Cuenta juridica con apoderado
            } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
                if (caso.Contact.CIBE_Telefono1__c == null) {
                    respuesta = 'SIN DATOS';
                }
                for (CC_Lista_Valores__c valor : listaPreguntas) {
                    if ((valor.CC_Valor__c.toLowerCase().contains('teléfono') && valor.CC_Activa__c == false) || (valor.CC_Valor__c.toLowerCase().contains('cuenta') && valor.CC_Activa__c == false)) {
                        respuesta = 'SIN DATOS';
                    }
                }
            //Cuenta fisica
            } else {
                if (caso.Account.AV_Age__c == null && caso.Account.PersonMobilePhone == null) {
                    respuesta = 'SIN DATOS';
                }
            }
        }
    	return respuesta;
    
    }

    @AuraEnabled
    public static Map<String,String> preguntasOTP2Nivel(String lista, Id recordId) {
        Case caso = [SELECT Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone, CC_Representante__c, CC_Representante__r.CC_Representante__r.PersonMobilePhone, CC_Representante__r.CC_Representante__r.AV_Age__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_Telefono1__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, CC_MCC_Causa__r.CC_Omitir_preguntas_Nivel_2__c FROM Case WHERE Id = :recordId LIMIT 1];
        List<CC_Lista_Valores__c> listaPreguntas = [SELECT CC_Valor__c, CC_Orden__c, CC_Servicio__c, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE RecordType.Name = 'Valor' AND CC_Activa__c = true AND CC_Lista__r.Name = :lista];
        Map<String,String> preguntas = new Map<String,String>();
        List<String> preguntas1 = new List<String>();
        List<String> preguntas2 = new List<String>();
        String error;
        String preguntaForzada;
        //Comprobacion de los datos si estan vacios
        //Cuenta representante
        if(caso.CC_MCC_Causa__r.CC_Omitir_preguntas_Nivel_2__c){
            preguntas.put('OmitirPreguntas', 'true');
        }else{
        if(!listaPreguntas.isEmpty()){
        if (caso.CC_Representante__c != null) {
            if (caso.CC_Representante__r.CC_Representante__r.AV_Age__c == null && caso.CC_Representante__r.CC_Representante__r.PersonMobilePhone == null) {
                error = 'true';
            } else if (caso.CC_Representante__r.CC_Representante__r.AV_Age__c == null) {
                preguntaForzada = 'telefono';
            } else if (caso.CC_Representante__r.CC_Representante__r.PersonMobilePhone == null) {
                preguntaForzada = 'edad';
            }
        //Cuenta juridica con apoderado
        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
            if (caso.Contact.CIBE_Telefono1__c == null) {
                error = 'true';
            }
        //Cuenta fisica
        } else {
            if (caso.Account.AV_Age__c == null && caso.Account.PersonMobilePhone == null) {
                error = 'true';
            } else if (caso.Account.AV_Age__c == null) {
                preguntaForzada = 'telefono';
            } else if (caso.Account.PersonMobilePhone == null) {
                preguntaForzada = 'edad';
            }
        }
            for (CC_Lista_Valores__c listaPregunta :  listaPreguntas) {
                if (listaPregunta.CC_Servicio__c == 'Pregunta 1') {
                    for (Integer i = 0 ; i < listaPregunta.CC_Orden__c ; i++) {
                        preguntas1.add(listaPregunta.CC_Valor__c);
                    }
                } else if (listaPregunta.CC_Servicio__c == 'Pregunta 2') {
                    for (Integer i = 0 ; i < listaPregunta.CC_Orden__c ; i++) {
                        preguntas2.add(listaPregunta.CC_Valor__c);
                    }
                }
            }
            }
        }
        if (!preguntas1.isEmpty()) {
            Integer preguntaRandom1 = Integer.valueof((Math.random() * preguntas1.size()));
            if (preguntas1.get(preguntaRandom1).toLowerCase().contains('cuenta')) {
                preguntas.put('Pregunta1',preguntas1.get(preguntaRandom1));
                for (CC_Lista_Valores__c valor : listaPreguntas) {
                    if (valor.CC_Valor__c == preguntas1.get(preguntaRandom1) && valor.CC_Servicio__c == 'Pregunta 1') {
                        preguntas.put('TextoAyudaPregunta1', valor.CC_Mensajes_Mostrar__c);
                        break;
                    }
                }
            } else {
                //Si el caso tiene apoderado forzamos la pregunta de telefono
                if ((caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') || preguntaForzada == 'telefono') {
                    for (CC_Lista_Valores__c valor : listaPreguntas) {
                        if (valor.CC_Valor__c.toLowerCase().contains('teléfono') && valor.CC_Servicio__c == 'Pregunta 1') {
                            preguntas.put('Pregunta1',valor.CC_Valor__c);
                            preguntas.put('TextoAyudaPregunta1', valor.CC_Mensajes_Mostrar__c);
                        }
                    }
                } else if (preguntaForzada == 'edad') {
                    for (CC_Lista_Valores__c valor : listaPreguntas) {
                        if (valor.CC_Valor__c.toLowerCase().contains('edad') && valor.CC_Servicio__c == 'Pregunta 1') {
                            preguntas.put('Pregunta1',valor.CC_Valor__c);
                            preguntas.put('TextoAyudaPregunta1', valor.CC_Mensajes_Mostrar__c);
                        }
                    }
                } else if ((!(caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado')) || (!String.isEmpty(preguntaForzada))){
                    preguntas.put('Pregunta1',preguntas1.get(preguntaRandom1));
                    for (CC_Lista_Valores__c valor : listaPreguntas) {
                        if (valor.CC_Valor__c == preguntas1.get(preguntaRandom1) && valor.CC_Servicio__c == 'Pregunta 1') {
                            preguntas.put('TextoAyudaPregunta1', valor.CC_Mensajes_Mostrar__c);
                            break;
                        }
                    }
                }
            }
            
        }

        if (!preguntas2.isEmpty()) {
            Integer preguntaRandom2 = Integer.valueof((Math.random() * preguntas2.size()));
            if (preguntas2.get(preguntaRandom2).toLowerCase().contains('cuenta')) {
                preguntas.put('Pregunta2',preguntas2.get(preguntaRandom2));
                for (CC_Lista_Valores__c valor : listaPreguntas) {
                    if (valor.CC_Valor__c == preguntas2.get(preguntaRandom2) && valor.CC_Servicio__c == 'Pregunta 2') {
                        preguntas.put('TextoAyudaPregunta2', valor.CC_Mensajes_Mostrar__c);
                        break;
                    }
                }
            } else {
                //Si el caso tiene apoderado forzamos la pregunta de telefono
                if ((caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') || preguntaForzada == 'telefono') {
                    for (CC_Lista_Valores__c valor : listaPreguntas) {
                        if (valor.CC_Valor__c.toLowerCase().contains('teléfono') && valor.CC_Servicio__c == 'Pregunta 2') {
                            preguntas.put('Pregunta2',valor.CC_Valor__c); 
                            preguntas.put('TextoAyudaPregunta2', valor.CC_Mensajes_Mostrar__c);
                        }
                    }
                } else if (preguntaForzada == 'edad') {
                    for (CC_Lista_Valores__c valor : listaPreguntas) {
                        if (valor.CC_Valor__c.toLowerCase().contains('edad') && valor.CC_Servicio__c == 'Pregunta 2') {
                            preguntas.put('Pregunta2',valor.CC_Valor__c);
                            preguntas.put('TextoAyudaPregunta2', valor.CC_Mensajes_Mostrar__c);
                        }
                    }
                } else if ((!(caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado')) || (!String.isEmpty(preguntaForzada))){
                    preguntas.put('Pregunta2',preguntas2.get(preguntaRandom2));
                    for (CC_Lista_Valores__c valor : listaPreguntas) {
                        if (valor.CC_Valor__c == preguntas2.get(preguntaRandom2) && valor.CC_Servicio__c == 'Pregunta 2') {
                            preguntas.put('TextoAyudaPregunta2', valor.CC_Mensajes_Mostrar__c);
                            break;
                        }
                    }
                }
            }
        }
        //Comentario para git
        if (error == 'true') {
            preguntas.put('error',error);
        }
    	return preguntas;
        
    }

    @AuraEnabled
    public static List<Boolean> validacionPreguntas(Id recordId, String pregunta1, String pregunta2, String respuesta1, String respuesta2) {
        List<Boolean> validaciones = new List<Boolean>();
    
        // Limpiar respuestas
        respuesta1 = limpiarRespuesta(respuesta1);
        respuesta2 = limpiarRespuesta(respuesta2);
    
        // Obtener datos del caso
        Case caso = [SELECT Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone, Account.PersonBirthdate, CC_Representante__c, 
                     CC_Representante__r.CC_Representante__r.PersonMobilePhone, CC_Representante__r.CC_Representante__r.PersonBirthdate,
                     CC_Representante__r.CC_Representante__r.AV_Age__c, 
                     CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, 
                     Contact.CIBE_Telefono1__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c 
                     FROM Case WHERE Id = :recordId LIMIT 1];
    
        String numPerso = recuperarNumperso(caso);
    
        // Validar preguntas
        validaciones.add(validarPregunta(caso, pregunta1, respuesta1, numPerso));
        validaciones.add(validarPregunta(caso, pregunta2, respuesta2, numPerso));
        validaciones.add(validarPregunta(caso, 'enviarSMS', '', numPerso));
        return validaciones;
    }
    
    public static String recuperarNumperso(Case caso){
        String numPerso;
        if (caso.CC_Representante__c != null) {
            numPerso = caso.CC_Representante__r.CC_Representante__r.AV_NumPerso__c != null ? caso.CC_Representante__r.CC_Representante__r.AV_NumPerso__c : caso.CC_Representante__r.CC_Representante__r.CC_NumPerso__c != null ? caso.CC_Representante__r.CC_Representante__r.CC_NumPerso__c : '';
        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
            numPerso = caso.Contact.AV_NumPerso__c != null ? caso.Contact.AV_NumPerso__c : caso.Contact.CC_NumPerso__c != null ? caso.Contact.CC_NumPerso__c : '';
        } else {
            numPerso = caso.Account.AV_NumPerso__c != null ? caso.Account.AV_NumPerso__c : caso.Account.CC_NumPerso__c != null ? caso.Account.CC_NumPerso__c : '';
        }
        return numperso;
    }

    public static String limpiarRespuesta(String respuesta) {
        if (!String.isEmpty(respuesta)) {
            respuesta = respuesta.replace('+34 ', '').replace('+3400', '').replace('+34', '').replace(' ', '');
        }
        return respuesta;
    }
    
    private static Boolean validarPregunta(Case caso, String pregunta, String respuesta, String numPerso) {
        if (String.isEmpty(pregunta)) {
            return false;
        }
        pregunta = pregunta.toLowerCase();
        if (pregunta.contains('edad')) {
            return validarEdad(caso, respuesta);
        }else if (pregunta.contains('año')){
            return validarNacimiento(caso, respuesta);
        }else if (pregunta.contains('teléfono')) {
            return validarTelefono(caso, respuesta);
        } else if (pregunta.contains('cuenta')) {
            return validarCuenta(numPerso, respuesta);
        } else if (pregunta.contains('tarjeta')) {
            return validarTarjeta(numPerso, respuesta);
        } else if (pregunta.contains('enviarsms')){
            return validarEnvioSMS(caso);
        }
    
        return false;
    }

    private static Boolean validarNacimiento(Case caso, String respuesta){
        if (caso.CC_Representante__c != null) {
            List <String> fecha = caso.CC_Representante__r.CC_Representante__r.PersonBirthdate.toString().split('-');
            return fecha[0].toString() == respuesta;
        } else {
            List <String> fecha = caso.Account.PersonBirthdate.toString().split('-');
            return fecha[0].toString() == respuesta;
        }
    }

    private static Boolean validarEnvioSMS(Case caso){
        Boolean tienePSAutenticacion = getPSAutenticacion();
        List<Task> lisTareas = comprobarSiHayLlamada(caso.Id);
        if(!lisTareas.isEmpty()){
            if(lisTareas[0].CC_Llamada_Id__r.CC_Tipo__c == 'Saliente'){
                String telefonoLlamada = limpiarRespuesta(lisTareas[0].CC_Llamada_Id__r.CC_DNIS__c);
                if (caso.CC_Representante__c != null) {
                    String tlf = caso.CC_Representante__r.CC_Representante__r.PersonMobilePhone;
                    if (tlf != null && tlf.startsWith('+34 ')) {
                        tlf = tlf.replace(' ', '').right(9);
                    }
                    return tlf == telefonoLlamada || caso.CC_Representante__r.CC_Representante__r.PersonMobilePhone == telefonoLlamada;
                } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
                    return caso.Contact.CIBE_Telefono1__c == telefonoLlamada;
                }else if (caso.CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c == true) {
                    return true;
                }else{
                    String tlf = caso.Account.PersonMobilePhone;
                    if (tlf != null && tlf.startsWith('+34 ')) {
                        tlf = tlf.replace(' ', '').right(9);
                    }
                    return tlf == telefonoLlamada || caso.Account.PersonMobilePhone == telefonoLlamada;
                }
            }else {
                if (caso.CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c == true) {
                  return true;
                }else{
                    return false;
                }
            }
        }else if (tienePSAutenticacion){
            if (caso.CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c == true) {
                return true;
              }else{
                  return false;
            }
        }
            return false;
    }
    
    private static Boolean validarEdad(Case caso, String respuesta) {
        if (caso.CC_Representante__c != null) {
            return String.valueOf(caso.CC_Representante__r.CC_Representante__r.AV_Age__c) == respuesta;
        } else {
            return String.valueOf(caso.Account.AV_Age__c) == respuesta;
        }
    }
    
    private static Boolean validarTelefono(Case caso, String respuesta) {
        if (caso.CC_Representante__c != null) {
            String tlf = caso.CC_Representante__r.CC_Representante__r.PersonMobilePhone;
            if (tlf != null && tlf.startsWith('+34 ')) {
                tlf = tlf.replace(' ', '').right(9);
            }
            return tlf == respuesta || caso.CC_Representante__r.CC_Representante__r.PersonMobilePhone == respuesta;
        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
            return caso.Contact.CIBE_Telefono1__c == respuesta;
        } else {
            String tlf = caso.Account.PersonMobilePhone;
            if (tlf != null && tlf.startsWith('+34 ')) {
                tlf = tlf.replace(' ', '').right(9);
            }
            return tlf == respuesta || caso.Account.PersonMobilePhone == respuesta;
        }
    }
    
    private static Boolean validarCuenta(String numPerso, String respuesta) {
        System.debug('::: numPerso: ' + numPerso);
        System.debug('::: respuesta: ' + respuesta);
        if (String.isEmpty(numPerso)) {
            return false;
        }
        List<String> cuentas = CC_WS_Autenticacion_CuentaCliente.validacionCuenta(numPerso);
        System.debug('::: cuentas: ' + cuentas);
        if(!cuentas.isEmpty()){
            for (String cuenta : cuentas) {
                if (cuenta.right(4) == respuesta) {
                    return true;
                }
            }
        }
        return false;
    }
    
    private static Boolean validarTarjeta(String numPerso, String respuesta) {
        if (String.isEmpty(numPerso)) {
            return false;
        }
        List<String> tarjetas = CC_WS_Recuperar_Tarjetas.recuperarTarjetasPorCliente(numPerso);
        if(!tarjetas.isEmpty()){
        for (String tarjeta : tarjetas) {
            if (tarjeta.right(4) == respuesta) {
                return true;
            }
        }
    }
        return false;
    }
   
    @AuraEnabled
    public static String validarRegistro(Id casoId, Id otpId, String codigoOTP) {
        Decimal numIntentos = [SELECT CC_OTP_Intentos__c FROM Case WHERE Id = :casoId LIMIT 1].CC_OTP_Intentos__c;
        if(numIntentos == null) {
            numIntentos = 0;
        }
        
        Set<Id> idsOTP = new Set<Id>();
        if(otpId == null) {
        	Id otp = getOTP(casoId, 'Nivel 2', 'Pdte. Validar');    
            if(otp != null){
            	idsOTP.add(otp);    
            }
        } else {
            idsOTP.add(otpId);
        }
        DateTime fechaValidacion;
        String resultado = 'OTP errónea';
        String codError = '';

        //Se valida el OTP
        List<CC_Comunicaciones__c> otps = CC_WS_Validacion_OTP.CC_WS_Validacion_OTP(idsOTP, codigoOTP);
        if(!otps.isEmpty()) {
            CC_Comunicaciones__c otp = otps.get(0);
            fechaValidacion = otp.CC_Fecha_Validacion__c;
            resultado = otp.CC_Resultado_Validacion__c;
            codError = otp.CC_Codigo_Error__c;
        }
        fechaValidacion = dateTime.now();
        Case  caso = new Case(Id = casoId);
        if(resultado == 'OTP errónea' || resultado == 'OTP no recibida') {
            caso.CC_OTP_Intentos__c = numIntentos + 1;
            caso.CC_Status_Autorizacion__c = 'ERROR';
        	caso.CC_OTP_Valido__c = false;
            caso.CC_OTP_Fecha_Ultima_Validacion__c = fechaValidacion;
        }
        else if(resultado == 'OTP validada correctamente') {
            caso.CC_OTP_Intentos__c = numIntentos + 1;
            caso.CC_OTP_Valido__c = true;
            caso.CC_OTP_Fecha_Ultima_Validacion__c = fechaValidacion;
            caso.CC_Status_Autorizacion__c = 'APPROVED';
            resultado = 'OK';
        }
		        
      	update caso;
        return resultado;
    }

    //Se utiliza para emergencia
    @AuraEnabled
    public static String gestionesSegunNivel (String casoId, Boolean valido, String nivel){
        String resultado;
        String resultadoValidacion = '';
        
        Id recordTypeIdOTP = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');
        String mailNotif = '';
        String idioma = '';
        String contactId = '';
        String telefonoDelContacto = '';
        String procedencia = '';
        Id idCliente; 
        
        List<Case> casos = [SELECT AccountId, CC_Idioma__c,CC_MailTelfNotif__c, ContactId, Contact.Phone, CC_Canal_Procedencia__c FROM Case WHERE Id = :casoId LIMIT 1];
        
        if(!casos.isEmpty()){
            Case caso = casos.get(0);
            idCliente = caso.AccountId;
            mailNotif = caso.CC_MailTelfNotif__c;
            idioma = caso.CC_Idioma__c;
            contactId = caso.ContactId;
            telefonoDelContacto = caso.Contact.Phone;
            procedencia = caso.CC_Canal_Procedencia__c;
        }
        
        if(valido && mailNotif !=null && mailNotif !='' ){
            if(nivel == 'Nivel 1'){
                resultadoValidacion = 'Identificación manual';
            }
            else if(nivel == 'Emergencia'){
                resultadoValidacion = 'Identificación emergencia';
            }
            //Generamos el email a enviar. Debe mantener el cuerpo del email anterior y agregar el cuerpo de la plantilla recuperada
        	//También debe mantener el asunto del email anterior junto con el nuevo asunto
        
            List<CC_ConfigNotifCliente__mdt> mdts = new  List<CC_ConfigNotifCliente__mdt>();
            
            //Recuperamos los metadata de notificaciones OTP
            if (procedencia == 'ImaginBank'){
                mdts = [SELECT Id, CC_Idioma__c, CC_Cuerpo__c, CC_EtiRemitente__c, CC_Remitente__c, CC_Plantilla__c, CC_PlantillaBase__c, CC_Carpeta__c, CC_Proceso__c, CC_TaskOrigenProc__c, CC_TiposTareaCaso__c, CC_CaseOrigenProc__c, CC_EntidadOrigen__c, CC_EstadoTarea__c
                        FROM CC_ConfigNotifCliente__mdt
                        WHERE CC_Proceso__c = 'Notificacion OTP Imagin OK'
                        AND CC_Canal__c = 'Email'
                        AND CC_Idioma__c = :idioma
                        AND CC_Activa__c = true LIMIT 1];
            } else {
                mdts = [SELECT Id, CC_Idioma__c, CC_Cuerpo__c, CC_EtiRemitente__c, CC_Remitente__c, CC_Plantilla__c, CC_PlantillaBase__c, CC_Carpeta__c, CC_Proceso__c, CC_TaskOrigenProc__c, CC_TiposTareaCaso__c, CC_CaseOrigenProc__c, CC_EntidadOrigen__c, CC_EstadoTarea__c
                        FROM CC_ConfigNotifCliente__mdt
                        WHERE CC_Proceso__c = 'Notificacion OTP OK'
                        AND CC_Canal__c = 'Email'
                        AND CC_Idioma__c = :idioma
                        AND CC_Activa__c = true LIMIT 1];
            }
            
            if(!mdts.isEmpty()){
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                CC_ConfigNotifCliente__mdt mdt = mdts.get(0);
                Id plantillaId = [SELECT Id FROM EmailTemplate WHERE Name = : mdt.CC_Plantilla__c LIMIT 1].Id;
                Id remitenteId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :mdt.CC_Remitente__c LIMIT 1].Id;
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(plantillaId);
                mail.setSaveAsActivity(true);
                mail.setWhatId(casoId);
                mail.setTargetObjectId(contactId);
                String[] toAddresses = new String[] {mailNotif};
                    mail.setToAddresses(toAddresses);
                mail.setOrgWideEmailAddressId(remitenteId);
                allmsg.add(mail);
                
                if (!allmsg.isEmpty()){
                    //Enviamos el email
                    Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);
                }
                resultado = 'Email';
            }
            
        }else{
            if ((mailNotif == null || mailNotif == '') && telefonoDelContacto == null) {
                resultado = 'Email no informado';
                resultadoValidacion = '';
            } else if ((mailNotif == null || mailNotif == '') && telefonoDelContacto != null) {
                if(nivel == 'Nivel 1'){
                    resultado = 'OK';
                    resultadoValidacion = 'Identificación manual';
                }
                else if(nivel == 'Emergencia') {
                    resultado = 'OK';
                    resultadoValidacion = 'Identificación emergencia';
                }
            } else {
                resultadoValidacion = 'Identificación NOK';
                //aquí poner la recuperación del mensaje
                String textoPlantilla = '';
                List<CC_ConfigNotifCliente__mdt> mdtsKO = new  List<CC_ConfigNotifCliente__mdt>();
                if (procedencia == 'ImaginBank'){
                    mdtsKO = [SELECT CC_Texto_Plantilla__c
                              FROM CC_ConfigNotifCliente__mdt
                              WHERE CC_Proceso__c = 'Notificacion OTP Imagin KO'
                              AND CC_Canal__c = 'Email'
                              AND CC_Idioma__c = :idioma
                              AND CC_Activa__c = true LIMIT 1];
                } else {
                    mdtsKO = [SELECT CC_Texto_Plantilla__c
                              FROM CC_ConfigNotifCliente__mdt
                              WHERE CC_Proceso__c = 'Notificacion OTP KO'
                              AND CC_Canal__c = 'Email'
                              AND CC_Idioma__c = :idioma
                              AND CC_Activa__c = true LIMIT 1];
                }
                
                if(!mdtsKO.isEmpty()){
                    CC_ConfigNotifCliente__mdt mdtKO = mdtsKO.get(0);
                    resultado = mdtKO.CC_Texto_Plantilla__c;
                }
            }
        }
        
        if(resultadoValidacion != null && resultadoValidacion != ''){
            CC_Comunicaciones__c otp = new CC_Comunicaciones__c();
            otp.CC_Case__c = casoId;
            otp.CC_Resultado_Validacion__c = resultadoValidacion;
            otp.CC_Cliente__c = idCliente;
            otp.RecordTypeId = recordTypeIdOTP;
            otp.CC_Estado__c = 'Cerrado';
            otp.CC_Nivel__c = nivel;
            otp.CC_Fecha_Validacion__c = dateTime.now();
            //otp.CC_Fecha_Envio__c = datetime.now();
            
            if(otp != null)
            {
                insert otp;
            }
            
            Case casoUpdt = new Case(Id = casoId);
            casoUpdt.CC_OTP_Valido__c = valido;
            casoUpdt.CC_OTP_Nivel__c = nivel;
            casoUpdt.CC_OTP_Intentos__c = 0;
            casoUpdt.CC_OTP_Fecha_Ultima_Validacion__c = dateTime.now();
            
            update casoUpdt;
        }
        return resultado;
    }
//Desglce de métodos
    public static List<Task> comprobarSiHayLlamada(Id casoId){
       return [SELECT Id, CC_Llamada_Id__r.CC_Tipo__c, CC_Llamada_Id__r.CC_DNIS__c FROM Task WHERE WhatId = :casoId AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task') AND CreatedDate = TODAY AND (Status = 'Open' OR Type = 'Llamada transferida' OR Type = 'Consulta') AND CC_Llamada_Id__c != null ORDER BY  CreatedDate DESC LIMIT 1];
      
    }

    private static String completarPerfilAgente(){
        String perfil;

        String profile = [Select Name from Profile where Id=:UserInfo.getProfileId()].Name;
        CC_Settings__c configuracion = CC_Settings__c.getValues('CC_PerfilesAutentication');
        if(configuracion != null) {
            Map<String, Object> pf = configuracion.getPopulatedFieldsAsMap();
            for(string b : pf.KeySet()){         
                if(b.contains('Configuracion') && pf.get(b) != null){
                    if((profile).contains(pf.get(b).toString())){          
                       perfil = pf.get(b).toString();
                        break;
                    } 
                }
            }
        }
        return perfil;
    }


    private static CC_Comunicaciones__c crearComunicacionBasica(String casoId, String nivel, String idCliente, List<Task> tareas){
        CC_Comunicaciones__c otp = new CC_Comunicaciones__c();
        otp.CC_Case__c = casoId;
        otp.CC_Cliente__c = idCliente;
        otp.CC_Nivel__c = nivel;
        otp.CC_Estado__c = 'Pdte. Envío';
        otp.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');
        if(nivel != 'Emergencia'){     
            otp.CC_Perfil_empleado__c = completarPerfilAgente();
            if(!tareas.isEmpty()){
                if(tareas[0].CC_Llamada_Id__r.CC_Tipo__c != null){
                    otp.CC_Tipo_Llamada__c = tareas[0].CC_Llamada_Id__r.CC_Tipo__c;
                }
            }
        }
        insert otp;

        return otp;
    }


    @AuraEnabled
    public static String clienteDigital(String casoId, String idCliente, String ownerId){
        String resultado = 'OK';
        List<Task> comprobarLlamadasAbiertas = comprobarSiHayLlamada(casoId);
        Boolean tienePSAutenticacion = getPSAutenticacion();
        String comprobarIntento = comprobarIntentos(casoId, idCliente);
        
        if(!String.isEmpty(comprobarIntento) && comprobarIntento == 'Cliente Bloqueado'){
           resultado = 'Cliente Bloqueado';
        } else if(comprobarLlamadasAbiertas.isEmpty() && !tienePSAutenticacion){
            resultado = 'NOK';
        } else {
            Id recordTypeIdOTP = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');
            //Crear registro
            CC_Comunicaciones__c otp = crearComunicacionBasica(casoId, 'Cliente Digital', idCliente, comprobarLlamadasAbiertas);

            Case casoUpdt = new Case(Id = casoId);
            casoUpdt.CC_OTP_Nivel__c = 'Cliente Digital';
            casoUpdt.CC_Status_Autorizacion__c  = 'INPROGRESS';

            update casoUpdt;
        }
        return resultado;            
    }
    

    
    @AuraEnabled
    public static Map<String,String> segundoNivel(String casoId, Boolean valido, String nivel, String pregunta1, String pregunta2, String respuesta1, String respuesta2, String validacion1, String validacion2, Boolean enviarSMS, Boolean enviarPreguntas, Boolean cancelada){
        Map<String,String> retorno = new Map<String,String>();
        String resultado = 'OK';  
        Boolean preguntaRespuestaVacia1 = false;
        Boolean preguntaRespuestaVacia2 = false;
        Case casoUpdt = [SELECT AccountId, Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone, CC_Representante__c, CC_Representante__r.CC_Representante__r.PersonMobilePhone, CC_Representante__r.CC_Representante__r.AV_Age__c, CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_Telefono1__c, Account.AV_NumPerso__c, Contact.AV_NumPerso__c, Account.CC_NumPerso__c, Contact.CC_NumPerso__c, CC_Idioma__c FROM Case WHERE Id =:casoId LIMIT 1];
        List<Task> tareas = comprobarSiHayLlamada(casoId);
        //Crear registro
        CC_Comunicaciones__c otp = new CC_Comunicaciones__c();
        otp.CC_Case__c = casoId;
        otp.CC_Cliente__c = casoUpdt.AccountId;
        otp.CC_Nivel__c = nivel;
        otp.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');
        if (String.isEmpty(pregunta1) || String.isEmpty(respuesta1)) {
            preguntaRespuestaVacia1 = true;
        }
        if (String.isEmpty(pregunta2) || String.isEmpty(respuesta2)) {
            preguntaRespuestaVacia2 = true;
        }

        otp.CC_Pregunta_1__c = pregunta1;
        otp.CC_Respuesta_1__c = respuesta1;
        otp.CC_Pregunta_2__c = pregunta2;
        otp.CC_Respuesta_2__c = respuesta2;
        if(!enviarPreguntas){
            if (!preguntaRespuestaVacia1) {
                otp.CC_Validacion_1__c = (!String.isEmpty(validacion1) && validacion1 == 'true') ?  'OK' : 'NOK';
            }
            if (!preguntaRespuestaVacia2) {
                otp.CC_Validacion_2__c = (!String.isEmpty(validacion2) && validacion2 == 'true') ?  'OK' : 'NOK';
            }
        }
        if(nivel != 'Emergencia'){     
            otp.CC_Perfil_empleado__c = completarPerfilAgente();
            if(!tareas.isEmpty()){
                if(tareas[0].CC_Llamada_Id__r.CC_Tipo__c != null){
                    otp.CC_Tipo_Llamada__c = tareas[0].CC_Llamada_Id__r.CC_Tipo__c;
                }
            }
        }
        
        if (cancelada) {
            otp.CC_Estado__c = 'Cancelada por agente';
        } else if((valido || enviarPreguntas) && !enviarSMS){
            otp.CC_Estado__c = 'Pdte. Envío';
        }else if(enviarSMS && (valido || enviarPreguntas)){
            otp.CC_Estado__c = 'Aprobado';
            casoUpdt.CC_Status_Autorizacion__c  = 'APPROVED';
        }else{
            otp.CC_Estado__c = 'Cerrado';
            otp.CC_Fecha_Validacion__c = dateTime.now();
            otp.CC_Resultado_Validacion__c = 'Identificación NOK';
            //aquí poner la recuperación del mensaje
            String textoPlantilla = '';
            List<CC_ConfigNotifCliente__mdt> mdtsKO = [SELECT CC_Texto_Plantilla__c
                                                       FROM CC_ConfigNotifCliente__mdt
                                                       WHERE CC_Proceso__c = 'Notificacion OTP KO'
                                                       AND CC_Canal__c = 'Email'
                                                       AND CC_Idioma__c = :casoUpdt.CC_Idioma__c
                                                       AND CC_Activa__c = true LIMIT 1];
            
            if(!mdtsKO.isEmpty()){
                CC_ConfigNotifCliente__mdt mdtKO = mdtsKO.get(0);
                resultado = mdtKO.CC_Texto_Plantilla__c;
            }
        }           

        
        if(otp != null)
        {
            insert otp;
        }
        
        casoUpdt.CC_OTP_Nivel__c = nivel;

        if(!valido){
            casoUpdt.CC_OTP_Valido__c = valido;
            casoUpdt.CC_OTP_Intentos__c = 0;
            casoUpdt.CC_OTP_Fecha_Ultima_Validacion__c = dateTime.now();
        }
        
        update casoUpdt;

        retorno.put('Resultado', resultado);
        retorno.put('Id', String.valueOf(otp.Id));

        return retorno;
    }
    
    @AuraEnabled
    public static String comprobarIntentos(String casoId, String idCliente) {
        String resultado;         
        CC_Settings__c valoresCS = [SELECT CC_Configuracion_1__c, CC_Configuracion_2__c FROM CC_Settings__c WHERE Name = 'CC_Autenticacion_Bloqueos' AND CC_Activa__c = true LIMIT 1];
        Integer contador = 0;
        Integer tiempoBloqueo = Integer.valueOf(valoresCS.CC_Configuracion_2__c);
        Integer cantidadIntentos = Integer.valueOf(valoresCS.CC_Configuracion_1__c);

        Datetime horasBloqueo = Datetime.now().addHours(-tiempoBloqueo);
        Datetime ahora = Datetime.now();
        if(!String.isEmpty(idCliente)){
            List<CC_Comunicaciones__c> comunicacionesCliente = [SELECT Id, CC_Cliente__r.name, CC_Estado__c, CC_Nivel__c,CC_Codigo_Error__c, CC_Resultado_Validacion__c FROM CC_Comunicaciones__c WHERE CC_Cliente__c = :idCliente AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS') AND CreatedDate > :horasBloqueo AND CreatedDate <= :ahora  ORDER BY CreatedDate DESC];
    
            List<String> valoresPermitidos = new List<String>{'Cancelada por agente','Error', 'Pendiente', 'En progreso', 'Pdte. Envío', 'Pdte. Validar'};
           if(comunicacionesCliente.isEmpty() || comunicacionesCliente[0].CC_Estado__c == 'Aprobado'){
                resultado = 'OK';
           }else{
                for(CC_Comunicaciones__c c :comunicacionesCliente){
                    if(c.CC_Estado__c == 'Denegado'){
                        resultado = 'Cliente Bloqueado';
                        break;
                    }else if(c.CC_Estado__c == 'Aprobado'){
                        resultado = 'OK';
                        break;
                    }else {
                        if(c.CC_Nivel__c == 'Cliente Digital' && !valoresPermitidos.contains(c.CC_Estado__c)){
                            contador = contador + 1;
                        }else if(c.CC_Nivel__c == 'Nivel 2' && ((c.CC_Estado__c == 'Rechazado' && (c.CC_Codigo_Error__c == '00008' || c.CC_Codigo_Error__c == '00005')) ||(c.CC_Estado__c == 'Cerrado' && c.CC_Resultado_Validacion__c == 'Identificación NOK') )){
                            contador = contador + 1;
                        }
                    }
                }
           }
            if (resultado != 'Cliente Bloqueado') {
                if(contador >= cantidadIntentos){
                    resultado = 'Cliente Bloqueado';
                }else{
                    resultado = 'OK';
                }
            }
                

        }

        // List<Case> casos = [SELECT Id FROM Case
        //                     WHERE AccountId = :idCliente
        //                     AND CC_OTP_Bloqueo__c = true LIMIT 1];
            
    	// if(!casos.isEmpty()){
        // 	resultado = 'KO';
        // }else{
        //     resultado = 'OK';
        // }
        
        return resultado;
    }

    @AuraEnabled
    public static Id getOTP(String casoId, String nivel, String status){
        return [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Case__c =:casoId AND CC_Estado__c = :status AND CC_Nivel__c = :nivel AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS') ORDER BY CreatedDate DESC LIMIT 1].Id;
    }

    @AuraEnabled
    public static void autenticacionCancelada(Id recordId, String casoId) {
        Case casoUpdt = [SELECT CC_Status_Autorizacion__c FROM Case WHERE Id = :casoId];
        CC_Comunicaciones__c otp = new CC_Comunicaciones__c();
        otp.Id = recordId;
        otp.CC_Estado__c = 'Cancelada por agente';
        update otp;
        
        // Case casoUpdt = new Case();
        // casoUpdt.Id = casoId;
        if (casoUpdt.CC_Status_Autorizacion__c != 'APPROVED') {
            casoUpdt.CC_Status_Autorizacion__c = 'UNAUTHORIZED';
        }
        update casoUpdt;
    }
    
    @AuraEnabled
    public static void mensajeNoRecibido(Id recordId, String casoId){
        CC_Comunicaciones__c com = [SELECT CC_Nivel__c FROM CC_Comunicaciones__c WHERE Id =:recordId AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS')];
        Case casoUpdt = new Case(Id = casoId);

        if (com.CC_Nivel__c == 'Cliente Digital'){
            com.CC_Estado__c = 'Error';
            casoUpdt.CC_Status_Autorizacion__c = 'ERROR';
        }else{
            com.CC_Estado__c = 'OTP No recibida	';
            casoUpdt.CC_Status_Autorizacion__c = 'SIN ESTADO';
        }
        
        update com;
        update casoUpdt;
    }
    
    @AuraEnabled
    public static String enviarAutorizacion(Id recordId, Id casoId){
       return CC_WS_Autenticacion.CC_WS_Envio_Autenticacion(recordId, casoId);        
    }
    
    @AuraEnabled
    public static String validarAutorizacion(Id recordId, Id casoId){ 
        String resultado = CC_WS_Autenticacion.CC_WS_Validacion_Autenticacion(recordId, casoId);        
        return resultado;
    }


    @AuraEnabled
    public static Boolean validarCanalAutenticacion(Id recordId) {
        List<CC_Lista_Valores__c> listaCanalesAutenticacion = [SELECT CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_Autenticacion_Cliente'];
        Set<String> valoresCanales = new Set<String>();
        for (CC_Lista_Valores__c canal : listaCanalesAutenticacion) {
            if(canal.CC_Activa__c){
                valoresCanales.add(canal.CC_Valor__c);
            }
        }
        List<Case> casos = [SELECT toLabel(Origin) FROM Case WHERE Id = :recordId AND toLabel(Origin) IN :valoresCanales];
		return casos.isEmpty() ? false : true;
    }

    @AuraEnabled
    public static CC_Lista_Valores__c mensajeValidacionPreguntas(String validacion) {
        CC_Lista_Valores__c valorValidacion = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Validaciones preguntas 2 Nivel' AND CC_Valor2__c = :validacion LIMIT 1];
		return valorValidacion;
    }

    @AuraEnabled
    public static Boolean getPSAutenticacion() {
        List<PermissionSetAssignment> permisoAutenticacion = [SELECT Id FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId() AND PermissionSet.Name = 'CC_Autenticacion' LIMIT 1];
        return (!permisoAutenticacion.isEmpty()) ? true : false;
    }

    @AuraEnabled
    public static String validarContratoSAU(Id recordId) {
        Case caso = [SELECT Account.CC_NumPerso__c, Account.AV_NumPerso__c, Account.AV_IndicadoresClientes__c FROM Case WHERE Id = :recordId LIMIT 1];

        Boolean clienteImagin = caso.Account.AV_IndicadoresClientes__c != null && caso.Account.AV_IndicadoresClientes__c.contains('28');
        String numPerso = !String.isBlank(caso.Account.CC_NumPerso__c) ? caso.Account.CC_NumPerso__c : caso.Account.AV_NumPerso__c;
        
        return CC_WS_Autenticacion_SAU.ccWsEnvioAutenticacion(clienteImagin, numPerso, true);
    }

    @AuraEnabled
    public static String comprobarImpedirAutenticacion(Id recordId) {
        String resultado;
        Case caso = [SELECT CC_MCC_Motivo__r.CC_ImpedirClienteDigital__c, CC_MCC_Motivo__r.CC_ImpedirNivel2__c FROM Case WHERE Id = :recordId LIMIT 1];

        if (caso.CC_MCC_Motivo__r.CC_ImpedirNivel2__c) {
            resultado = 'impedirNivel2';
        } else if (caso.CC_MCC_Motivo__r.CC_ImpedirNivel2__c) {
            resultado = 'impedirClienteDigital';
        } else {
            resultado = 'noImpedir';
        }
        
        return resultado;
    }

    @AuraEnabled
    public static void reiniciarDerivar(String recordId) {
        CC_EmailSendController.reiniciarDerivar(recordId);
    }

    @AuraEnabled
    public static String comprobarCaracteristicasCliente(Id recordId) {
        Set<Id> idsCaracteristicas = new Set<Id>();
        String resultado;
        String idCuenta;
        String idContacto;
        Case caso = [SELECT AccountId, ContactId, CC_Representante__c, CC_Representante__r.CC_Representante__c, CC_MCC_Motivo__c FROM Case WHERE Id = :recordId LIMIT 1];

        if (caso.CC_Representante__c != null) { //Cuenta menor con representante
            idCuenta = caso.CC_Representante__r.CC_Representante__c;
            // idContacto = String.valueOf([SELECT PersonContactId FROM Account WHERE Id = :caso.CC_Representante__r.CC_Representante__c LIMIT 1].PersonContactId);
            idContacto = caso.ContactId;
        } else {
            idCuenta = caso.AccountId;
            idContacto = caso.ContactId;
        }
        
        List<CC_Caracteristica_Detalle__c> caracteristicas = [SELECT CC_Caracteristica__c, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_RestriccionTotal__c FROM CC_Caracteristica_Detalle__c WHERE (CC_Cuenta__c = :idCuenta OR CC_Cliente__c = :idContacto) AND CC_Caracteristica__r.OS_Negocio__c = 'FRA'];
        if (caracteristicas != null) {
            for (CC_Caracteristica_Detalle__c caracteristica : caracteristicas) {
                resultado = caracteristica.CC_Caracteristica__r.CC_RestriccionTotal__c ? 'restriccion_total' : resultado;
                idsCaracteristicas.add(caracteristica.CC_Caracteristica__c);
            }
            if (resultado != 'restriccion_total') {
                if (idsCaracteristicas != null) {
                    List<CC_MCC_Caracteristica__c> mccCaracteristicas = [SELECT Id FROM CC_MCC_Caracteristica__c WHERE CC_MCC__c = :caso.CC_MCC_Motivo__c AND CC_Caracteristica__c IN :idsCaracteristicas];
                    resultado = (mccCaracteristicas != null && !mccCaracteristicas.isEmpty()) ? 'restriccion_parcial' : 'autenticar';
                }
            }
        } else {
            resultado = 'autenticar';
        }
        return resultado;
    }
}