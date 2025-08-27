public with sharing class CC_OTP {

    public class OTPWrapper {
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

    public class HistoricoOTPResponse {
        @AuraEnabled public List<OTPWrapper> autenticacionesRecientes;
        @AuraEnabled public List<OTPWrapper> historicoAutenticaciones;

        public HistoricoOTPResponse() {
            autenticacionesRecientes = new List<OTPWrapper>();
            historicoAutenticaciones = new List<OTPWrapper>();
        }
    }

    @AuraEnabled
    public static Map<String,Object> existeBloqueoNuevo(Id recordId) {
        Map<String,Object> oRes = new Map<String,Object>();
        Boolean resultado = false;
        List<Task> comprobarLlamadas = comprobarSiHayLlamada(recordId);
        Boolean tienePSAutenticacion = getPSAutenticacion();
        Boolean mccVacio = true;
        List<Case> casos = [SELECT CC_Status_Autorizacion__c, CC_OTP_Intentos__c, AccountId, ContactId, CC_Idioma__c, OwnerId, CC_Tipo_Cliente__c, CC_Representante__c, Account.AV_Age__c, Account.AV_Segmento__c, Account.CC_MenorEmancipado__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c, CC_MCC_Motivo__r.CC_ImpedirNivel2__c, CC_MCC_Motivo__r.CC_ImpedirClienteDigital__c, CC_Oportunidad_Creada__c, CC_Representante__r.CC_Representante__r.AV_Age__c, Account.RecordType.DeveloperName, Contact.RecordType.DeveloperName, Contact.CC_Edad__c, CC_MCC_Motivo__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Causa__c FROM Case WHERE Id =:recordId LIMIT 1];
        String comprobarIntento;
        if(!casos.isEmpty()){
            comprobarIntento = comprobarIntentos(recordId, casos[0].AccountId);
            if(casos[0].CC_MCC_Tematica__c != null && casos[0].CC_MCC_ProdServ__c != null && casos[0].CC_MCC_Motivo__c != null && casos[0].CC_MCC_Causa__c != null){
                mccVacio = false;
            }
        }

        Boolean comprobarIntentos = false;
        String tipoBloqueoCliente = null;
        Boolean tieneLlamadas = true;

        if(!String.isEmpty(comprobarIntento)) {
            if(comprobarIntento == 'CLIENTE_BLOQUEADO_REJECTED' || 
               comprobarIntento == 'CLIENTE_BLOQUEADO_DENIED' || 
               comprobarIntento == 'CLIENTE_BLOQUEADO_INTENTOS_FALLIDOS') {
                comprobarIntentos = true;
                tipoBloqueoCliente = comprobarIntento;
                resultado = false;
            } else if(comprobarIntento == 'Cliente Bloqueado') {
                
            comprobarIntentos = true;
            resultado = false;
            }
        }
        if(comprobarLlamadas.isEmpty() && !tienePSAutenticacion){
            tieneLlamadas = false;
        }

            if(!casos.isEmpty()){
            oRes.put('Llamadas', tieneLlamadas);
            oRes.put('mccVacio', mccVacio);
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
            oRes.put('EdadCliente', (casos.get(0).Account.RecordType.DeveloperName == 'CC_Cliente' && casos.get(0).Account.AV_Segmento__c == 'RPF') ? casos.get(0).Contact.CC_Edad__c : casos.get(0).Account.AV_Age__c);
            // oRes.put('EdadCliente', casos.get(0).Account.AV_Age__c);
            oRes.put('AmbitoMotivoCaixa', casos.get(0).CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c);
            oRes.put('AmbitoMotivoImagin', casos.get(0).CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c);
                if(casos.get(0).CC_Status_Autorizacion__c != null && casos.get(0).CC_Status_Autorizacion__c != '' && casos.get(0).CC_Status_Autorizacion__c != 'ERROR' && casos.get(0).CC_Status_Autorizacion__c != 'UNAUTHORIZED' && casos.get(0).CC_Status_Autorizacion__c != 'TIMEOUT' && casos.get(0).CC_Status_Autorizacion__c != 'ABORTED'&& casos.get(0).CC_Status_Autorizacion__c != 'EXPIRED' && casos.get(0).CC_Status_Autorizacion__c != 'NOT_IDENTIFIED' && casos.get(0).CC_Status_Autorizacion__c != 'IS_MINOR'&& casos.get(0).CC_Status_Autorizacion__c != 'IS_A_COMPANY'&& casos.get(0).CC_Status_Autorizacion__c != 'NOTIFICATIONS_OFF' && casos.get(0).CC_Status_Autorizacion__c != 'SIN ESTADO'){
                resultado = true;
                //PERMITIR lanzar autenticación (sólo 1 vez más)
                if(casos.get(0).CC_Status_Autorizacion__c == 'REJECTED' && (casos.get(0).CC_OTP_Intentos__c == null ||  casos.get(0).CC_OTP_Intentos__c == 0)){
                    resultado = false;
                }
            }
        }
        oRes.put('MostrarBotonEmergencia', (CC_Settings__c.getValues('CC_VisibilidadBotonEmergenciaAut')?.CC_Activa__c ? CC_Settings__c.getValues('CC_VisibilidadBotonEmergenciaAut')?.CC_Activa__c : false));
        oRes.put('circuitoAutenticacion', (CC_Settings__c.getValues('CC_CircuitoAutenticacion')?.CC_Activa__c ? CC_Settings__c.getValues('CC_CircuitoAutenticacion')?.CC_Activa__c : false));
        oRes.put('menorDe65', (CC_Settings__c.getValues('CC_PreguntaMenores65')?.CC_Activa__c ? CC_Settings__c.getValues('CC_PreguntaMenores65').CC_Activa__c : false)); //corregir
        //US1173279 - Autenticación - Rango edades clientes senior parametrizable
        if(CC_Settings__c.getValues('CC_EdadAutenticacion')?.CC_Activa__c && CC_Settings__c.getValues('CC_EdadAutenticacion')?.CC_Configuracion_1__c  != null){
            oRes.put('edadLimite', Integer.valueOf(CC_Settings__c.getValues('CC_EdadAutenticacion').CC_Configuracion_1__c));
        }

            //Comprobar la edad del cliente, representante o apoderado
            if (casos.get(0).CC_Representante__c != null) {
                if (casos.get(0).CC_Representante__r?.CC_Representante__r?.AV_Age__c != null) {
                    oRes.put('EdadCliente', casos.get(0).CC_Representante__r?.CC_Representante__r?.AV_Age__c);
                }
            //Cuenta fisica
            } else if (casos.get(0).Account.RecordType.DeveloperName != 'CC_Cliente' && casos.get(0).Contact.RecordType.DeveloperName != 'CIBE_Apoderado') {
                if (casos.get(0).Account.AV_Age__c != null) {
                    oRes.put('EdadCliente', casos.get(0).Account.AV_Age__c);
                }
            }

        if(tipoBloqueoCliente != null) {
            oRes.put('TipoBloqueoCliente', tipoBloqueoCliente);//sin espacios
        }
        oRes.put('Resultado', resultado);
        return oRes;
    }

    @AuraEnabled
    public static HistoricoOTPResponse obtenerHistoricoOTPClienteDividido(Id recordId, String idCliente) {
        HistoricoOTPResponse response = new HistoricoOTPResponse();

        if (idCliente != null) {
            
            CC_Settings__c valoresCS = CC_Settings__c.getValues('CC_Autenticacion_Bloqueos');
            Integer horasRecientes = Integer.valueOf(valoresCS.CC_Configuracion_2__c);
            Datetime fechaLimiteRecientes = DateTime.now().addHours(-horasRecientes);

            Id recordTypeIdOTP = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');

                // --- CONSULTA PARA AUTENTICACIONES RECIENTES ---
            List<CC_Comunicaciones__c> recientesList = [
                SELECT Id, CC_Estado__c, CC_Fecha_Envio__c, CC_Fecha_Validacion__c, CC_Intentos_Validacion_OTP__c,
                    CC_Codigo_OTPSMS__c, CC_Resultado_Validacion__c, CC_Mensaje_Error__c, CC_Case__c,
                    CC_Case__r.CaseNumber, CC_Nivel__c
                FROM CC_Comunicaciones__c
                WHERE CC_Cliente__c = :idCliente AND RecordTypeId = :recordTypeIdOTP
                AND CC_Fecha_Envio__c >= :fechaLimiteRecientes // Filtra solo los recientes
                AND (CC_Nivel__c = 'Nivel 2' OR CC_Nivel__c = 'Cliente Digital')
                ORDER BY CreatedDate DESC
            ];

              // --- CONSULTA OPTIMIZADA PARA EL HISTÓRICO ---
            List<CC_Comunicaciones__c> historicoList = [
                SELECT Id, CC_Estado__c, CC_Fecha_Envio__c, CC_Fecha_Validacion__c, CC_Intentos_Validacion_OTP__c,
                    CC_Codigo_OTPSMS__c, CC_Resultado_Validacion__c, CC_Mensaje_Error__c, CC_Case__c,
                    CC_Case__r.CaseNumber, CC_Nivel__c
                FROM CC_Comunicaciones__c
                WHERE CC_Cliente__c = :idCliente
                AND RecordTypeId = :recordTypeIdOTP
                AND CC_Fecha_Envio__c < :fechaLimiteRecientes // Filtra solo los antiguos
                AND (CC_Nivel__c = 'Nivel 2' OR CC_Nivel__c = 'Cliente Digital')
                ORDER BY CreatedDate DESC
                LIMIT 5 
            ];


           // Mapear autenticaciones recientes
        for (CC_Comunicaciones__c otp : recientesList) {
            OTPWrapper otpWrapper = new OTPWrapper();
            otpWrapper.recordId = otp.Id; 
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
            response.autenticacionesRecientes.add(otpWrapper);
        }


        // Mapear histórico de autenticaciones (el bucle es más simple ahora)
        for (CC_Comunicaciones__c otp : historicoList) {
            OTPWrapper otpWrapper = new OTPWrapper();
            otpWrapper.recordId = otp.Id;
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
            response.historicoAutenticaciones.add(otpWrapper);
        }

        }
        return response;
    }


    @AuraEnabled
    public static List<OTPWrapper> obtenerOTPCliente(Id recordId, String idCliente) {
        List<OTPWrapper> otpWrapperList = new List<OTPWrapper>();
        if (idCliente != null)
        {
            Id recordTypeIdOTP = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');

            List<CC_Comunicaciones__c> otpsList = [SELECT Id, CC_Nivel__c, CC_Estado__c, CC_Fecha_Envio__c, CC_Fecha_Validacion__c, CC_Intentos_Validacion_OTP__c, CC_Codigo_OTPSMS__c, CC_Resultado_Validacion__c, CC_Mensaje_Error__c, CC_Case__c, CC_Case__r.CaseNumber FROM CC_Comunicaciones__c WHERE CC_Cliente__c = :idCliente AND CC_Case__c = :recordId AND (CC_Estado__c != 'Rechazado' AND CC_Estado__c != 'Error' AND CC_Estado__c != 'Cerrado' AND CC_Estado__c != 'Expirado' AND CC_Estado__c != 'Denegado' AND CC_Estado__c != 'Aprobado' AND CC_Estado__c != 'No autorizado' AND CC_Estado__c != 'Cancelada por agente') AND RecordTypeId = :recordTypeIdOTP ORDER BY CreatedDate DESC];

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
    //preguntas emergencia
    @AuraEnabled
    public static List<CC_Lista_Valores__c> preguntasOTP(String lista){
        List<CC_Lista_Valores__c> listaPreguntas = CC_Listas_Valores.LookupValues(lista, null);

    	return listaPreguntas;

    }

    @AuraEnabled
    public static Map<String,String> comprobarDatos2Nivel(Id recordId, String nombreLista) {
        Map<String,String> respuesta = new Map<String, String>{'error' => 'OK'};
        Case caso = [SELECT Account.RecordType.DeveloperName,Account.PersonBirthdate, Account.AV_Age__c,Account.PersonMobilePhone,CC_Representante__c,CC_Representante__r.CC_Representante__r.PersonMobilePhone,CC_Representante__r.CC_Representante__r.AV_Age__c, CC_Representante__r.CC_Representante__r.PersonBirthdate, CC_Representante__r.CC_Representante__r.AV_NumPerso__c,CC_Representante__r.CC_Representante__r.CC_NumPerso__c,Contact.RecordType.DeveloperName,Contact.CIBE_Telefono1__c,Contact.AV_NumPerso__c,Contact.CIBE_NumPerso__c, Contact.CC_NumPerso__c, Account.AV_NumPerso__c,Account.CC_NumPerso__c,CC_MCC_Causa__r.CC_Omitir_preguntas_Nivel_2__c, CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c, Account.AV_Segmento__c, CC_MCC_Causa__c, Contact.Phone, Contact.CC_Edad__c, Contact.Birthdate FROM Case WHERE Id = :recordId LIMIT 1];
        List<CC_Lista_Valores__c> listaPreguntas = [SELECT CC_Valor__c, CC_Orden__c, CC_Servicio__c, CC_Activa__c, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE RecordType.Name = 'Valor' AND CC_Lista__r.Name = :nombreLista AND CC_Activa__c = true];
        Integer task = [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task') AND CreatedDate = TODAY AND (Status = 'Open' OR Type = 'Llamada transferida' OR Type = 'Consulta')];
        Boolean tienePSAutenticacion = getPSAutenticacion();

        String comprobarIntento =(caso != null) ? comprobarIntentos(recordId, caso.AccountId) : null;

        if(!String.isEmpty(comprobarIntento) && comprobarIntento == 'Cliente Bloqueado'){
            return new Map<String, String>{'error' => 'CLIENTE BLOQUEADO'};
        }else if(caso.CC_MCC_Causa__c != null && caso.CC_MCC_Causa__r?.CC_Omitir_preguntas_Nivel_2__c){
            respuesta.put('OmitirPreguntas', 'true');
            return respuesta;
        }else if(task == 0 && !tienePSAutenticacion){
            return new Map<String, String>{'error' => 'SIN LLAMADAS'};
        } else {
            if (caso.CC_Representante__c != null) {
                if (caso.CC_Representante__r?.CC_Representante__r?.AV_Age__c == null && caso.CC_Representante__r?.CC_Representante__r?.PersonMobilePhone == null) {
                    respuesta.put('error', 'SIN DATOS');
                    return respuesta;
                }
            //Cuenta juridica con apoderado
            } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
                if (caso.Contact.CIBE_Telefono1__c == null) {
                    respuesta.put('error', 'SIN DATOS');
                    return respuesta;
                }
                for (CC_Lista_Valores__c valor : listaPreguntas) {
                    if ((valor.CC_Valor__c.toLowerCase().contains('teléfono') && valor.CC_Activa__c == false) || (valor.CC_Valor__c.toLowerCase().contains('cuenta') && valor.CC_Activa__c == false)) {
                        respuesta.put('error', 'SIN DATOS');
                        return respuesta;
                    }
                }
            //Cuenta fisica
            } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Account.AV_Segmento__c == 'RPF') {
                if (caso.Contact.CC_Edad__c == null && caso.Contact.Birthdate == null && caso.Contact.Phone == null) {
                    respuesta.put('error', 'SIN DATOS');
                    return respuesta;
                }
            } else {
                if (caso.Account.AV_Age__c == null && caso.Account.PersonMobilePhone == null) {
                    respuesta.put('error', 'SIN DATOS');
                    return respuesta;
                }
            }
        }
        Map<String, String> preguntasAnteriores = comprobarPreguntasAnteriores(recordId);
        Boolean onboarding = nombreLista.contains('Onboarding');
        if (listaPreguntas.isEmpty() || caso == null) {
            respuesta.put('error', 'true');
            return respuesta;
        } else if(!listaPreguntas.isEmpty() && caso != null){
            respuesta.putAll(preguntasOTP2Nivel(listaPreguntas, caso, onboarding));
            if (preguntasAnteriores.get('Pregunta 1') != null && preguntasAnteriores.get('Pregunta 2') != null) {
                respuesta.put('Pregunta1', preguntasAnteriores.get('Pregunta 1'));
                respuesta.put('Pregunta2', preguntasAnteriores.get('Pregunta 2'));
            }
        }

    	return respuesta;
    }

    @AuraEnabled
    public static Map<String,String> preguntasOTP2Nivel(List<CC_Lista_Valores__c> listaPreguntas, Case caso, Boolean onboarding) {
        Map<String,String> preguntas = new Map<String,String>();

        List<String> lstPreguntas1 = new List<String>();
        List<String> lstPreguntas2 = new List<String>();
        List<Integer> pesoPreguntas1 = new List<Integer>();
        List<Integer> pesoPreguntas2 = new List<Integer>();

        Map<String,string> preguntas1 = new Map<String,string>();
        Map<String,string> preguntas2 = new Map<String,string>();

        String preguntaForzada;
        String preguntaForzadaApi;
        String numPerso = recuperarNumperso(caso);
        List<String> cuentasList = new List<String>();
        List<String> tarjetasList = new List<String>();
        Boolean representanteJuridico = (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') ? true : false;
        Boolean juridicoRPF = (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Account.AV_Segmento__c == 'RPF') ? true : false;


        if(!onboarding) {
            cuentasList = !String.isEmpty(numPerso) ? CC_WS_Autenticacion_CuentaCliente.validacionCuenta(numPerso) : new List<String>();
            tarjetasList =!String.isEmpty(numPerso) ? CC_WS_Recuperar_Tarjetas.recuperarTarjetasPorCliente(numPerso) : new List<String>();
            CBK_HttpServiceIntegration.registroTrazaIntegracion();
        }
        if(String.isEmpty(numPerso) && !onboarding){
            preguntas.put('error','SIN DATOS');
            return preguntas;
        	}else if (!representanteJuridico && !juridicoRPF && caso.Account.AV_Age__c == null && caso.Account.PersonMobilePhone == null) {
            preguntas.put('error','SIN DATOS');
            return preguntas;
            } else if (representanteJuridico && !juridicoRPF && caso.Account.AV_Age__c == null) {
                preguntaForzada = 'teléfono';
            } else if (!juridicoRPF && caso.Account.PersonMobilePhone == null) {
                preguntaForzada = 'edad';
            }

        if(!cuentasList.isEmpty() && !tarjetasList.isEmpty()){
            preguntaForzadaApi = 'ambas';
            preguntas.put('listaCuentas', JSON.serialize(cuentasList));
            preguntas.put('listaTarjetas', JSON.serialize(tarjetasList));
        } else if(!cuentasList.isEmpty() && tarjetasList.isEmpty()){
            preguntaForzadaApi = 'cuenta';
            preguntas.put('listaCuentas', JSON.serialize(cuentasList));
        } else if(!tarjetasList.isEmpty() && cuentasList.isEmpty()){
            preguntaForzadaApi = 'tarjeta';
            preguntas.put('listaTarjetas', JSON.serialize(tarjetasList));
        }
        for (CC_Lista_Valores__c pregunta : listaPreguntas) {
            if (pregunta.CC_Servicio__c == 'Pregunta 1') {
                lstPreguntas1.add(pregunta.CC_Valor__c);
                pesoPreguntas1.add(Integer.valueOf(pregunta.CC_Orden__c));
            } else if (pregunta.CC_Servicio__c == 'Pregunta 2') {
                lstPreguntas2.add(pregunta.CC_Valor__c);
                pesoPreguntas2.add(Integer.valueOf(pregunta.CC_Orden__c));
            }
        }

        List<Integer> pesoCumulativo1 = calcularPesoCumulativo(pesoPreguntas1);
        List<Integer> pesoCumulativo2 = calcularPesoCumulativo(pesoPreguntas2);

        String pregunta1 = buscarPregunta('Pregunta1', lstPreguntas1, pesoCumulativo1, preguntaForzada, preguntaForzadaApi);
        String pregunta2 = buscarPregunta('Pregunta2', lstPreguntas2, pesoCumulativo2, preguntaForzada, preguntaForzadaApi);

        for (CC_Lista_Valores__c pregunta : listaPreguntas) {
            if (pregunta.CC_Valor__c == pregunta1) {
                preguntas1.put(pregunta.CC_Valor__c, pregunta.CC_Mensajes_Mostrar__c);
            } else if (pregunta.CC_Valor__c == pregunta2) {
                preguntas2.put(pregunta.CC_Valor__c, pregunta.CC_Mensajes_Mostrar__c);
            }
        }

        asignarPregunta(preguntas, 'Pregunta1', preguntas1, caso, preguntaForzada, preguntaForzadaApi);
        asignarPregunta(preguntas, 'Pregunta2', preguntas2, caso, preguntaForzada, preguntaForzadaApi);

        if(string.isEmpty(preguntas.get('Pregunta1')) || string.isEmpty(preguntas.get('Pregunta2'))){
            preguntas.put('error', 'SIN DATOS');
    	    return preguntas;
        } else {
            if((preguntas.get('Pregunta1').contains('cuenta') || preguntas.get('Pregunta2').contains('cuenta'))  && cuentasList.isEmpty()){
                preguntas.put('error', 'SIN DATOS API');
                return preguntas;
            }else if((preguntas.get('Pregunta1').contains('tarjeta') || preguntas.get('Pregunta2').contains('tarjeta'))  && tarjetasList.isEmpty()){
                preguntas.put('error', 'SIN DATOS API');
                return preguntas;
            }
        }
        return preguntas;
    }

    public static List<Integer> calcularPesoCumulativo(List<Integer> lstPesosPreguntas) {
        List<Integer> pesoCumulativo = new List<Integer>();
        Integer total = 0;

        for (Integer i = 0; i < lstPesosPreguntas.size(); i++) {
            total += lstPesosPreguntas[i];
            pesoCumulativo.add(total);
        }
        return pesoCumulativo;
    }

    public static String buscarPregunta(String bloquePregunta, List<String> lstPreguntas, List<Integer> pesoCumulativo, String preguntaForzada, String preguntaForzadaApi) {
        String pregunta = '';
        if (bloquePregunta == 'Pregunta1' && preguntaForzada != null) {
            for (Integer i = 0; i < lstPreguntas.size(); i++) {
                if (lstPreguntas[i].toLowerCase().contains(preguntaForzada)) {
                    pregunta = lstPreguntas[i];
                    break;
                }
            }
            
        } else {
            Integer indexAleatorio = Integer.valueOf(Math.random() * (!pesoCumulativo.isEmpty() ? pesoCumulativo[pesoCumulativo.size() - 1] : 1));
            for (Integer i = 0; i < lstPreguntas.size(); i++) {
                if (pesoCumulativo[i] >= indexAleatorio) {
                    pregunta = lstPreguntas[i];
                    break;
                }
            }
        }
        return pregunta;
    }

    // Método para asignar preguntas según condiciones específicas
    public static void asignarPregunta(Map<String, String> preguntas, String clavePregunta,
                                       Map<String, String> listaPreguntas, Case caso,
                                       String preguntaForzada, String preguntaForzadaApi) {
        if (listaPreguntas.isEmpty()) return;
        Boolean representanteJuridico = (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') ? true : false;
        Boolean juridicoRPF = (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Account.AV_Segmento__c == 'RPF') ? true : false;
        List<String> keys = new List<String>(listaPreguntas.keySet());
        Integer indexAleatorio = Integer.valueOf(Math.random() * keys.size());
        String preguntaSeleccionada = keys[indexAleatorio];  // NO convertir a lowercase aún
        preguntaSeleccionada = preguntaSeleccionada.replaceAll('_\\d+$', '');

        if (preguntaSeleccionada.toLowerCase().contains('cuenta') && preguntaForzadaApi == 'cuenta') {
            preguntas.put(clavePregunta, preguntaSeleccionada);
            preguntas.put('TextoAyuda' + clavePregunta, listaPreguntas.get(keys[indexAleatorio]));
            return;
        } else if (representanteJuridico || juridicoRPF || preguntaForzada != null) {
            for (String key : listaPreguntas.keySet()) {
                String keySinSufijo = key.replaceAll('_\\d+$', ''); //limpiar aquí

                if ((representanteJuridico || juridicoRPF || preguntaForzada == 'telefono') && keySinSufijo.toLowerCase().contains('teléfono')) {
                    preguntas.put(clavePregunta, keySinSufijo);
                    preguntas.put('TextoAyuda' + clavePregunta, listaPreguntas.get(key));
                    return;
                } else if (preguntaForzada == 'edad' && keySinSufijo.toLowerCase().contains('edad')) {
                    preguntas.put(clavePregunta, keySinSufijo);
                    preguntas.put('TextoAyuda' + clavePregunta, listaPreguntas.get(key));
                    return;
                }
            }
        }

        if (preguntaForzadaApi == 'tarjeta') {
            for (String key : listaPreguntas.keySet()) {
                String keySinSufijo = key.replaceAll('_\\d+$', '');
                if (keySinSufijo.toLowerCase().contains('tarjeta')) {
                    preguntas.put(clavePregunta, keySinSufijo);
                    preguntas.put('TextoAyuda' + clavePregunta, listaPreguntas.get(key));
                    return;
                }
            }
        } else if (preguntaForzadaApi == 'cuenta') {
            for (String key : listaPreguntas.keySet()) {
                String keySinSufijo = key.replaceAll('_\\d+$', '');
                if (keySinSufijo.toLowerCase().contains('cuenta')) {
                    preguntas.put(clavePregunta, keySinSufijo);
                    preguntas.put('TextoAyuda' + clavePregunta, listaPreguntas.get(key));
                    return;
                }
            }
        }
        // Si no se forzó ninguna pregunta, se asigna una aleatoria
        preguntas.put(clavePregunta, preguntaSeleccionada);
        preguntas.put('TextoAyuda' + clavePregunta, listaPreguntas.get(keys[indexAleatorio]));
    }

    @AuraEnabled
    public static List<Boolean> validacionPreguntas(Id recordId, String pregunta1, String pregunta2, String respuesta1, String respuesta2, String listaCuentas, String listaTarjetas) {
        List<Boolean> validaciones = new List<Boolean>();

        // Limpiar respuestas
        respuesta1 = limpiarRespuesta(respuesta1);
        respuesta2 = limpiarRespuesta(respuesta2);

        // Obtener datos del caso
        Case caso = [SELECT Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone, Account.PersonBirthdate, CC_Representante__c, CC_Representante__r.CC_Representante__r.PersonMobilePhone, CC_Representante__r.CC_Representante__r.PersonBirthdate, CC_Representante__r.CC_Representante__r.AV_Age__c, CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_Telefono1__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Contact.AV_NumPerso__c,Contact.CIBE_NumPerso__c, Contact.CC_NumPerso__c, Contact.Birthdate, Contact.MobilePhone, Contact.Phone, Contact.CC_Edad__c, CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c, Account.AV_Segmento__c FROM Case WHERE Id = :recordId LIMIT 1];

        String numPerso = recuperarNumperso(caso);

        // Validar preguntas
        validaciones.add(validarPregunta(caso, pregunta1, respuesta1, numPerso, listaCuentas, listaTarjetas));
        validaciones.add(validarPregunta(caso, pregunta2, respuesta2, numPerso, listaCuentas, listaTarjetas));
        validaciones.add(validarPregunta(caso, 'enviarSMS', '', numPerso, null, null));
        return validaciones;
    }

    public static String recuperarNumperso(Case caso) {
        String numPerso;
        if (caso.CC_Representante__c != null) {
            // Si hay representante, se toma el NumPerso del representante Menosres de edad
            numPerso = !String.isEmpty(caso.CC_Representante__r?.CC_Representante__r.AV_NumPerso__c)
                ? caso.CC_Representante__r?.CC_Representante__r.AV_NumPerso__c
                : !String.isEmpty(caso.CC_Representante__r?.CC_Representante__r.CC_NumPerso__c)
                    ? caso.CC_Representante__r?.CC_Representante__r.CC_NumPerso__c
                    : '';
        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
            // Si es cliente jurídico con apoderado
           numPerso = !String.isEmpty(caso.Contact?.CIBE_NumPerso__c) ? caso.Contact?.CIBE_NumPerso__c : !String.isEmpty(caso.Contact?.AV_NumPerso__c) ? caso.Contact?.AV_NumPerso__c : !String.isEmpty(caso.Contact?.CC_NumPerso__c) ? caso.Contact?.CC_NumPerso__c : '';

        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CC_Cliente' && caso.Account.AV_Segmento__c == 'RPF') {
            // Si el segmento es RPF, se toma el AV_NumPerso de la cuenta
            numPerso = !String.isEmpty(caso.Account?.AV_NumPerso__c) ? caso.Account?.AV_NumPerso__c : !String.isEmpty(caso.Account?.CC_NumPerso__c) ? caso.Account?.CC_NumPerso__c  : '';
        } else {
            // Para otros casos, se toma el NumPerso de la cuenta
            numPerso = !String.isEmpty(caso.Account?.AV_NumPerso__c) ? caso.Account?.AV_NumPerso__c : !String.isEmpty(caso.Account?.CC_NumPerso__c) ? caso.Account?.CC_NumPerso__c  : '';
        }

        return numPerso;
    }

    public static String limpiarRespuesta(String respuesta) {
        if (!String.isEmpty(respuesta)) {
            respuesta = respuesta.replace('+34 ', '').replace('+3400', '').replace('+34', '').replace(' ', '');
        }
        return respuesta;
    }

    private static Boolean validarPregunta(Case caso, String pregunta, String respuesta, String numPerso, String listaCuentas, String listaTarjetas) {
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
            return validarCuenta(numPerso, respuesta, listaCuentas);
        } else if (pregunta.contains('tarjeta')) {
            return validarTarjeta(numPerso, respuesta, listaTarjetas);
        } else if (pregunta.contains('enviarsms')){
            return validarEnvioSMS(caso);
        }

        return false;
    }

    private static Boolean validarNacimiento(Case caso, String respuesta){
        if (caso.CC_Representante__c != null) {
            List <String> fecha = caso.CC_Representante__r?.CC_Representante__r?.PersonBirthdate.toString().split('-');
            return fecha[0].toString() == respuesta;
        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Account.AV_Segmento__c == 'RPF') {
            List <String> fecha = caso.Contact.Birthdate.toString().split('-');
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
                    String tlf = caso.CC_Representante__r?.CC_Representante__r?.PersonMobilePhone;
                    if (tlf != null && tlf.startsWith('+34 ')) {
                        tlf = tlf.replace(' ', '').right(9);
                    }
                    return tlf == telefonoLlamada || caso.CC_Representante__r?.CC_Representante__r?.PersonMobilePhone == telefonoLlamada;
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
            return String.valueOf(caso.CC_Representante__r?.CC_Representante__r?.AV_Age__c) == respuesta;
        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Account.AV_Segmento__c == 'RPF') {
            return String.valueOf(caso.Contact?.CC_Edad__c) == respuesta;
        } else {
            return String.valueOf(caso.Account.AV_Age__c) == respuesta;
        }
    }

    private static Boolean validarTelefono(Case caso, String respuesta) {
        if (caso.CC_Representante__c != null) {
            String tlf = limpiarRespuesta(caso.CC_Representante__r?.CC_Representante__r?.PersonMobilePhone);
            if (tlf != null && tlf.startsWith('+34 ')) {
                tlf = tlf.replace(' ', '').right(9);
            }
            return tlf == respuesta || caso.CC_Representante__r?.CC_Representante__r?.PersonMobilePhone == respuesta;
        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
            String tlf = limpiarRespuesta(caso.Contact.CIBE_Telefono1__c);
            return tlf == respuesta;
        } else if (caso.Account.RecordType.DeveloperName == 'CC_Cliente' && caso.Account.AV_Segmento__c == 'RPF') {
            return String.valueOf(caso.Contact?.Phone) == respuesta;
        } else {
            String tlf = limpiarRespuesta(caso.Account.PersonMobilePhone);
            if (tlf != null && tlf.startsWith('+34 ')) {
                tlf = tlf.replace(' ', '').right(9);
            }
            return tlf == respuesta || caso.Account.PersonMobilePhone == respuesta;
        }
    }

    private static Boolean validarCuenta(String numPerso, String respuesta, String listaCuentas) {
        Boolean resultado = false;
        if (String.isEmpty(numPerso)) {
            resultado = false;
        }
        List<String> cuentas = listaCuentas.replace('[', '').replace(']', '').replace('"', '').split(',');
        if(!cuentas.isEmpty()){
            for (String cuenta : cuentas) {
                if (cuenta.right(4) == respuesta) {
                    resultado = true;
                }
            }
        }
        return resultado;
    }

    private static Boolean validarTarjeta(String numPerso, String respuesta, String listaTarjetas) {
        Boolean resultado = false;
        if (String.isEmpty(numPerso)) {
            resultado = false;
        }
        List<String> tarjetas = listaTarjetas.replace('[', '').replace(']', '').replace('"', '').split(',');
        if(!tarjetas.isEmpty()){
            for (String tarjeta : tarjetas) {
                if (tarjeta.right(4) == respuesta) {
                    resultado = true;
                }
            }
        }
        return resultado;
    }

    @AuraEnabled
    public static String validarRegistro(Id casoId, Id otpId, String codigoOTP) {
        // Decimal numIntentos = [SELECT CC_OTP_Intentos__c FROM Case WHERE Id = :casoId LIMIT 1].CC_OTP_Intentos__c;
        Case caso = [SELECT CC_OTP_Intentos__c, CBK_Case_Extension_Id__r.CC_EstadoONB__c, CBK_Case_Extension_Id__r.CC_SubestadoONB__c, CBK_Case_Extension_Id__r.CC_MotivoCierreONB__c FROM Case WHERE Id = :casoId LIMIT 1];
        Decimal numIntentos = caso.CC_OTP_Intentos__c;
        String estadoONB = caso.CBK_Case_Extension_Id__r.CC_EstadoONB__c;
        String subestadoONB = caso.CBK_Case_Extension_Id__r.CC_SubestadoONB__c;
        String motivoCierreONB = caso.CBK_Case_Extension_Id__r.CC_MotivoCierreONB__c;
        CC_Settings__c fallosIntegracion = CC_Settings__c.getValues('CC_WS_Validacion_OTP_Fallo');
        List<String> codigosFallos = new List<String>();
        if (fallosIntegracion != null) {
            for (Integer i = 1; i <= 20; i++) {
                String fieldName = 'CC_Configuracion_' + i + '__c';
                String valor = (String)fallosIntegracion.get(fieldName);
                if (valor != null) {
                    codigosFallos.add(valor);
                }
            }
        }

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
        String mensajeError ='';

        //Se valida el OTP
        List<CC_Comunicaciones__c> otps = CC_WS_Validacion_OTP.CC_WS_Validacion_OTP(idsOTP, codigoOTP);

        if(!otps.isEmpty()) {
            CC_Comunicaciones__c otp = otps.get(0);
            fechaValidacion = otp.CC_Fecha_Validacion__c;
            resultado = otp.CC_Resultado_Validacion__c;
            codError = otp.CC_Codigo_Error__c;
            mensajeError = otp.CC_Mensaje_Error__c;
        }
        fechaValidacion = dateTime.now();
        // Case caso = new Case(Id = casoId);

        if (codigosFallos.contains(codError)) {
            resultado = 'OTP fallo en la integración';
            caso.CC_Status_Autorizacion__c = 'ERROR';
            caso.CC_OTP_Valido__c = false;
            caso.CC_OTP_Fecha_Ultima_Validacion__c = fechaValidacion;
        }

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
            caso.CC_Detalles_Solucion__c = CC_WS_Onboarding.matrizOnboarding(estadoONB, subestadoONB, motivoCierreONB);
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
                mdts = [SELECT Id, CC_Idioma__c, CC_Cuerpo__c, CC_EtiRemitente__c, CC_Remitente__c, CC_Plantilla__c, CC_PlantillaBase__c, CC_Carpeta__c, CC_Proceso__c, CC_TaskOrigenProc__c, CC_TiposTareaCaso__c, CC_CaseOrigenProc__c, CC_EntidadOrigen__c, CC_EstadoTarea__c FROM CC_ConfigNotifCliente__mdt WHERE CC_Proceso__c = 'Notificacion OTP Imagin OK' AND CC_Canal__c = 'Email' AND CC_Idioma__c = :idioma AND CC_Activa__c = true LIMIT 1];
            } else {
                mdts = [SELECT Id, CC_Idioma__c, CC_Cuerpo__c, CC_EtiRemitente__c, CC_Remitente__c, CC_Plantilla__c, CC_PlantillaBase__c, CC_Carpeta__c, CC_Proceso__c, CC_TaskOrigenProc__c, CC_TiposTareaCaso__c, CC_CaseOrigenProc__c, CC_EntidadOrigen__c, CC_EstadoTarea__c FROM CC_ConfigNotifCliente__mdt WHERE CC_Proceso__c = 'Notificacion OTP OK' AND CC_Canal__c = 'Email' AND CC_Idioma__c = :idioma AND CC_Activa__c = true LIMIT 1];
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
               /* if(nivel == 'Nivel 1'){
                    resultado = 'OK';
                    resultadoValidacion = 'Identificación manual';
                }
                else*/ if(nivel == 'Emergencia') {
                    resultado = 'OK';
                    resultadoValidacion = 'Identificación emergencia';
                }
            } else {
                resultadoValidacion = 'Identificación NOK';
                //aquí poner la recuperación del mensaje
                String textoPlantilla = '';
                List<CC_ConfigNotifCliente__mdt> mdtsKO = new  List<CC_ConfigNotifCliente__mdt>();
                if (procedencia == 'ImaginBank'){
                    mdtsKO = [SELECT CC_Texto_Plantilla__c FROM CC_ConfigNotifCliente__mdt WHERE CC_Proceso__c = 'Notificacion OTP Imagin KO' AND CC_Canal__c = 'Email' AND CC_Idioma__c = :idioma AND CC_Activa__c = true LIMIT 1];
                } else {
                    mdtsKO = [SELECT CC_Texto_Plantilla__c FROM CC_ConfigNotifCliente__mdt WHERE CC_Proceso__c = 'Notificacion OTP KO' AND CC_Canal__c = 'Email' AND CC_Idioma__c = :idioma AND CC_Activa__c = true LIMIT 1];
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


    private static CC_Comunicaciones__c crearComunicacionBasica(String casoId, String nivel, String estado, String idCliente, List<Task> tareas, Id recordTypeIdOTP){
        CC_Comunicaciones__c otp = new CC_Comunicaciones__c();
        otp.CC_Case__c = casoId;
        otp.CC_Cliente__c = idCliente;
        otp.CC_Nivel__c = nivel;
        otp.CC_Estado__c = estado;
        otp.RecordTypeId = recordTypeIdOTP;
        if(nivel != 'Emergencia'){
            otp.CC_Perfil_empleado__c = completarPerfilAgente();
            if(tareas != null && !tareas.isEmpty()){
                if(tareas[0].CC_Llamada_Id__r.CC_Tipo__c != null){
                    otp.CC_Tipo_Llamada__c = tareas[0].CC_Llamada_Id__r.CC_Tipo__c;
                }
            }
        }
        //insert otp;

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
            CC_Comunicaciones__c com = crearComunicacionBasica(casoId, 'Cliente Digital', 'Pdte. Envío', idCliente, comprobarLlamadasAbiertas,recordTypeIdOTP );

            if(com != null){
               insert com;
            }

            Case casoUpdt = new Case(Id = casoId);
            casoUpdt.CC_OTP_Nivel__c = 'Cliente Digital';
            casoUpdt.CC_Status_Autorizacion__c  = 'INPROGRESS';

            update casoUpdt;
        }
        return resultado;
    }



    @AuraEnabled
    public static Map<String,String> segundoNivel(String casoId, Boolean valido, String nivel, String pregunta1, String pregunta2, String respuesta1, String respuesta2, String validacion1, String validacion2, Boolean enviarSMS, Boolean enviarPreguntas, Boolean cancelada) {
        Map<String,String> retorno = new Map<String,String>();
        String resultado = 'OK';
        Boolean preguntaRespuestaVacia1 = false;
        Boolean preguntaRespuestaVacia2 = false;
        Case casoUpdt = [SELECT AccountId, Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone, CC_Representante__c, CC_Representante__r.CC_Representante__r.PersonMobilePhone, CC_Representante__r.CC_Representante__r.AV_Age__c, CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_Telefono1__c, Account.AV_NumPerso__c, Contact.AV_NumPerso__c, Account.CC_NumPerso__c, Contact.CC_NumPerso__c, CC_Idioma__c, CBK_Case_Extension_Id__r.CC_EstadoONB__c, CBK_Case_Extension_Id__r.CC_SubestadoONB__c, CBK_Case_Extension_Id__r.CC_MotivoCierreONB__c FROM Case WHERE Id =:casoId LIMIT 1];
        String estadoONB = casoUpdt.CBK_Case_Extension_Id__r.CC_EstadoONB__c;
        String subestadoONB = casoUpdt.CBK_Case_Extension_Id__r.CC_SubestadoONB__c;
        String motivoCierreONB = casoUpdt.CBK_Case_Extension_Id__r.CC_MotivoCierreONB__c;
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
            if (!preguntaRespuestaVacia1 && !String.isEmpty(validacion1)) {
                otp.CC_Validacion_1__c = (!String.isEmpty(validacion1) && validacion1 == 'true') ?  'OK' : 'NOK';
            }
            if (!preguntaRespuestaVacia2 && !String.isEmpty(validacion2)) {
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
            casoUpdt.CC_Detalles_Solucion__c = CC_WS_Onboarding.matrizOnboarding(estadoONB, subestadoONB, motivoCierreONB);
        }else{
            otp.CC_Estado__c = 'Cerrado';
            otp.CC_Fecha_Validacion__c = dateTime.now();
            otp.CC_Resultado_Validacion__c = 'Identificación NOK';
            //aquí poner la recuperación del mensaje
            String textoPlantilla = '';
            List<CC_ConfigNotifCliente__mdt> mdtsKO = [SELECT CC_Texto_Plantilla__c FROM CC_ConfigNotifCliente__mdt WHERE CC_Proceso__c = 'Notificacion OTP KO' AND CC_Canal__c = 'Email' AND CC_Idioma__c = :casoUpdt.CC_Idioma__c AND CC_Activa__c = true LIMIT 1];

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
        CC_Settings__c valoresCS = CC_Settings__c.getValues('CC_Autenticacion_Bloqueos');
        Integer contador = 0;
        Integer tiempoBloqueo = Integer.valueOf(valoresCS.CC_Configuracion_2__c);
        Integer cantidadIntentos = Integer.valueOf(valoresCS.CC_Configuracion_1__c);
        Datetime horasBloqueo = Datetime.now().addHours(-tiempoBloqueo);
        Datetime ahora = Datetime.now();
        Id recordTypeIdBloqueo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_Bloqueo');
        Id recordTypeIdOTPSMS = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS');
        Set<Id> recordTypeIds = new Set<Id>{recordTypeIdOTPSMS, recordTypeIdBloqueo};
        Boolean recordTypeExists = false;

        if (!String.isEmpty(idCliente)) {
            Map<Id, CC_Comunicaciones__c> comunicacionesCliente = new Map<Id, CC_Comunicaciones__c>();

            for (CC_Comunicaciones__c c : [SELECT Id, CC_Cliente__r.name, CC_Estado__c, CC_Nivel__c, CC_Codigo_Error__c, CC_Resultado_Validacion__c, RecordTypeId FROM CC_Comunicaciones__c WHERE CC_Cliente__c = :idCliente AND RecordTypeId IN :recordTypeIds AND CreatedDate > :horasBloqueo AND CreatedDate <= :ahora ORDER BY CreatedDate DESC ]) {
                comunicacionesCliente.put(c.Id, c);
                    if (c.RecordTypeId == recordTypeIdBloqueo) {
                        recordTypeExists = true;
                    }
            }

            List<String> valoresPermitidos = new List<String>{'Cancelada por agente','Error', 'Pendiente', 'En progreso', 'Pdte. Envío', 'Pdte. Validar'};

            if (comunicacionesCliente.isEmpty() || comunicacionesCliente.values()[0].CC_Estado__c == 'Aprobado') {
                resultado = 'OK';
            } else {
                for (CC_Comunicaciones__c c : comunicacionesCliente.values()) {
                    if (c.CC_Estado__c == 'Denegado') {
                        resultado = 'CLIENTE_BLOQUEADO_DENIED';
                        break;
                    } else if (c.CC_Estado__c == 'Rechazado') {
                        resultado = 'CLIENTE_BLOQUEADO_REJECTED';
                        break;
                    } else if (c.CC_Estado__c == 'Aprobado') {
                        resultado = 'OK';
                        break;
                    } else {
                        if (c.CC_Nivel__c == 'Cliente Digital' && !valoresPermitidos.contains(c.CC_Estado__c)) {
                            contador = contador + 1;
                        } else if (c.CC_Nivel__c == 'Nivel 2' &&
                                   ((c.CC_Estado__c == 'Rechazado' && (c.CC_Codigo_Error__c == '00008' || c.CC_Codigo_Error__c == '00005')) ||
                                   (c.CC_Estado__c == 'Cerrado' && c.CC_Resultado_Validacion__c == 'Identificación NOK'))) {
                            contador = contador + 1;
                        }
                    }
                }
            }

            if (resultado != 'CLIENTE_BLOQUEADO_DENIED' && resultado != 'CLIENTE_BLOQUEADO_REJECTED') {
                if (contador >= cantidadIntentos) {
                    resultado = 'CLIENTE_BLOQUEADO_INTENTOS_FALLIDOS';
                } else {
                    resultado = 'OK';
                }
            }


            if ((resultado == 'CLIENTE_BLOQUEADO_REJECTED' || resultado == 'CLIENTE_BLOQUEADO_DENIED' || resultado == 'CLIENTE_BLOQUEADO_INTENTOS_FALLIDOS') && !recordTypeExists) {
                CC_Comunicaciones__c primeraComunicacion = comunicacionesCliente.isEmpty() ? null : comunicacionesCliente.values()[0];
                if (primeraComunicacion != null) {
                    String nivel = primeraComunicacion.CC_Nivel__c;
                    CC_Comunicaciones__c com = crearComunicacionBasica(null, nivel, 'Cerrado', idCliente, null , recordTypeIdBloqueo);
                    if (com != null) {
                        com.CC_Detalle__c = resultado;
                        com.CC_Intentos_Validacion_OTP__c = contador;
                        com.CC_Pregunta_1__c = String.valueOf(horasBloqueo);
                        com.CC_Pregunta_2__c = String.valueOf(ahora);
                        insert com;
                    }
                }
            }
        }

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
        Case caso = [SELECT Account.RecordType.DeveloperName,Account.AV_IndicadoresClientes__c, Account.AV_Age__c, Account.PersonMobilePhone, Account.PersonBirthdate, CC_Representante__c, CC_Representante__r.CC_Representante__r.PersonMobilePhone, CC_Representante__r.CC_Representante__r.PersonBirthdate,CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c, CC_Representante__r.CC_Representante__r.AV_Age__c, CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_Telefono1__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c ,Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c, Account.AV_Segmento__c FROM Case WHERE Id = :recordId LIMIT 1];

        String numPerso = recuperarNumperso(caso);
        Boolean clienteImagin = recuperarImagin(caso);

        return CC_WS_Autenticacion_SAU.ccWsEnvioAutenticacion(clienteImagin, numPerso, true);
    }

    public static Boolean recuperarImagin(Case caso){
        Boolean imagin = false;
        if (caso.CC_Representante__c != null) {
            imagin =  (caso.CC_Representante__r?.CC_Representante__r.AV_IndicadoresClientes__c != null && caso.CC_Representante__r?.CC_Representante__r.AV_IndicadoresClientes__c.contains('28')) ? true : false;
        }else{
            imagin = (caso.Account?.AV_IndicadoresClientes__c != null && caso.Account?.AV_IndicadoresClientes__c.contains('28')) ? true : false;
        }
        return imagin;
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

        if (caso.CC_Representante__c != null) {
            idCuenta = caso.CC_Representante__r?.CC_Representante__c;
            idContacto = caso.ContactId;
        } else {
            idCuenta = caso.AccountId;
            idContacto = caso.ContactId;
        }

        List<CC_Caracteristica_Detalle__c> caracteristicas = [SELECT CC_Caracteristica__c, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_RestriccionTotal__c FROM CC_Caracteristica_Detalle__c WHERE (CC_Cuenta__c = :idCuenta OR CC_Cliente__c = :idContacto) AND CC_Caracteristica__r.OS_Negocio__c = 'FRA'];
        if (caracteristicas != null) {
            for (CC_Caracteristica_Detalle__c caracteristica : caracteristicas) {
                resultado = caracteristica.CC_Caracteristica__r?.CC_RestriccionTotal__c ? 'restriccion_total' : resultado;
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

    public static Map<String, String> comprobarPreguntasAnteriores(Id recordId) {
        Map<String, String> preguntasAnteriores = new Map<String, String>();
        List<CC_Comunicaciones__c> coms = [SELECT CC_Pregunta_1__c, CC_Pregunta_2__c FROM CC_Comunicaciones__c WHERE CC_Case__c = :recordId AND CC_Nivel__c = 'Nivel 2' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS') ORDER BY CreatedDate DESC LIMIT 1];
        if (!coms.isEmpty()) {
            CC_Comunicaciones__c com = coms.get(0);
            if (com.CC_Pregunta_1__c != null && com.CC_Pregunta_2__c != null) {
                preguntasAnteriores.put('Pregunta 1', com.CC_Pregunta_1__c);
                preguntasAnteriores.put('Pregunta 2', com.CC_Pregunta_2__c);
            }
        }
        return preguntasAnteriores;
    }
}