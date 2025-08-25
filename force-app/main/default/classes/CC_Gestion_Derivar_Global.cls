public with sharing class CC_Gestion_Derivar_Global {
    public static Case obtenerCaso(Id recordId) {
        return [ 
            SELECT 
                Origin,
                AssetId, 
                OwnerId,
                ContactId,             
                CC_Derivar__c, 
                CC_Canal_Operativo__c,
                CC_Detalles_Consulta__c, 
                CC_Status_Autorizacion__c, 
                CC_OTP_Nivel__c, 
                CC_OTP_Valido__c,
                CC_Oportunidad_Creada__c, //Check Documentacion
                CC_Resolucion__c, 
                CC_DevolucionCSBD__c, 
                SAC_EnvioParcial__c,
                CC_Canal_Procedencia__c,
                CC_En_Segundo_Nivel__c,
                CC_En_Tercer_Nivel__c,
                ParentId,
                Subject,
                CC_Idioma__c,
                Description,
                AccountId,
                CreatedDate,
                RecordTypeId,
                CC_No_Identificado__c,
                //MOTIVO
                CC_MCC_Motivo__c, 
                CC_MCC_Motivo__r.CC_Alerta_Caixa__c,
                CC_MCC_Motivo__r.CC_Alerta_Imagin__c, 
                CC_MCC_Motivo__r.Name, 
                CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, 
                CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c,
                //SOLUCION
                CC_MCC_Solucion__r.Name, 
                CC_MCC_Solucion__r.CC_AmbitoTareas__c,
                //TEMATICA
                CC_MCC_Tematica__c,  
                CC_MCC_Tematica__r.Name, 
                //PRODUCTO SERVICIO
                CC_MCC_ProdServ__r.Name,
                //ACCOUNT
                Account.Name,      
                Account.LastName,        
                Account.FirstName, 
                Account.CC_Numero_Documento__c, 
                Account.CC_Tipo_Persona__c, 
                Account.PersonMobilePhone,
                Account.Recordtype.Developername,  
                Account.AV_Cliente__c,     
                Account.AV_Confidencial__c, 
                Account.AV_NumPerso__c,              
                Account.AV_IndicadoresClientes__c, 
                Account.AV_EAPGestor__c, 
                Account.AV_EAPGestor__r.AccountId, 
                Account.AV_EAPGestor__r.Name,                
                Account.AV_EAPGestor__r.AV_Pool__c, 
                Account.CC_EsIntouch__c,
                Account.AV_EAPGestor__r.CC_Numero_Oficina__c,                
                Account.AV_EAPGestor__r.CC_Matricula__c,     
                Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c,   
                Account.AV_OficinaPrincipal__r.Parent.CC_Derivacion_CSBD__c,         
                Account.AV_OficinaPrincipal__r.Name,                 
                Account.AV_OficinaPrincipal__c, 
                Account.AV_Segmento__c,
                Account.CC_NumPerso__c,
                //CONTACT
                Contact.RecordType.DeveloperName,
                Contact.CIBE_NumPerso__c,
                Contact.AV_NumPerso__c,
                Contact.CC_NumPerso__c,
                Contact.AccountId,
                //REPRESENTANTE
                CC_Representante__c,
                CC_Representante__r.CC_Representante__c,
                CC_Representante__r.CC_Representante__r.CC_NumPerso__c,
                CC_Representante__r.CC_Representante__r.AV_NumPerso__c,
                //CASE EXTENSION
                CBK_Case_Extension_Id__c, 
                CBK_Case_Extension_Id__r.CC_Documentacion__c,
                CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c,
                CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__r.CSBD_Resolucion__c,
                CBK_Case_Extension_Id__r.CC_EmpresaONB__c,
                CBK_Case_Extension_Id__r.CC_EstadoONB__c,
                CBK_Case_Extension_Id__r.CC_FechaEstadoONB__c,
                CBK_Case_Extension_Id__r.CC_MotivoCierreONB__c,
                CBK_Case_Extension_Id__r.CC_SubestadoONB__c,
                CBK_Case_Extension_Id__r.CC_NumSR__c,
                CBK_Case_Extension_Id__r.CC_CodigoONB__c,
                CBK_Case_Extension_Id__r.CC_DerivadoBPO__c,
                CBK_Case_Extension_Id__r.CC_MecanismoFirma__c,
                //CASO RELACIONADO
                CC_CasoRelacionado__r.RecordTypeId
            FROM Case 
            WHERE Id = :recordId 
            LIMIT 1
        ];
    }

    public static List<CC_MCC_Grupo_Colaborador__c> obtenerListaGrupoColaborador(Case caso) {
        return [SELECT Id, Name, CC_Grupo_Colaborador__r.CC_Tipo__c FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c in (:caso.CC_MCC_Motivo__c, :caso.CC_MCC_ProdServ__C) AND (CC_Grupo_Colaborador__r.CC_Tipo__c = 'Traslados' OR CC_Grupo_Colaborador__r.CC_Tipo__c = 'Traslados y Remitidos') LIMIT 1];
    }

     
    public static void inicializarVariables(Case caso, Boolean otpDerivar, Map<String, Object> retorno, Map<String, Object> textosMap, CC_Settings__c consultarGestorPool) {
        Boolean ambitoVentas = false;
        Boolean ambitoCSBD = false;
        Boolean imagin = false;
        Boolean ambitoFraude = false;
        Boolean ambitoCBP = false;//CBP
        Boolean preguntaTrasladarDocumentacion = true;
        String ambitoMotivo;

        if(caso?.Account?.AV_IndicadoresClientes__c != null && caso?.Account?.AV_IndicadoresClientes__c?.contains('28')) {
            imagin = true;
            ambitoMotivo = caso.CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c;
        } else {
            ambitoMotivo = caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c;
        }

        if(caso.Account.AV_Confidencial__c && !caso.CC_En_Segundo_Nivel__c && !caso.CC_En_Tercer_Nivel__c){
            retorno.put('3NClienteConfidencial', CC_Settings__c.getValues('CC_3NClienteConfidencial').CC_Activa__c);
        }

        CC_Settings__c listaMotivosNoTrasladar =  CC_Settings__c.getValues('CC_OcultarModalTrasladarAmbitos');
        String jsonString = JSON.serialize(listaMotivosNoTrasladar);
        Map<String, Object> comoMapa = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        for(String campo : comoMapa.keySet()){
            if(comoMapa.get(campo) == ambitoMotivo) {
                retorno.put('ocultarModalTrasladar', true);
                break;
            }
        }
        if(retorno.get('ocultarModalTrasladar') == null){
            retorno.put('ocultarModalTrasladar', false);
        }

        if(otpDerivar == true) {
            ambitoMotivo = '';      
        }

        if(!Boolean.valueOf(consultarGestorPool.CC_Configuracion_3__c) && (ambitoMotivo == 'Hub Imagin' || ambitoMotivo == 'Oficina física')) {
            ambitoMotivo = null;
        }

        if(ambitoMotivo == 'CSBD 3N' || ambitoMotivo == 'CSBD Contratar' || ambitoMotivo == 'CSBD No Contratar') {
            ambitoCSBD = true;
            Boolean telefonoCSBD = CC_MetodosUtiles.getCustomSetting('CC_TelefonoActivoCSBD').CC_Configuracion_1__c == 'true' ? true : false;
            if(!caso.Account.AV_OficinaPrincipal__r.Parent.CC_Derivacion_CSBD__c || telefonoCSBD) {
               ambitoVentas = true;
            }
        }

        //devolucion desde CSBD a CC
        if(caso.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c != null && caso.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__r.CSBD_Resolucion__c == 'Devolución a contact') {
            ambitoMotivo = null;
            ambitoCSBD = false;
            ambitoVentas = true;
        }

        if(ambitoMotivo == '' || ambitoMotivo == null) {
            if(imagin && Boolean.valueOf(consultarGestorPool.CC_Configuracion_3__c)) {
                ambitoVentas = true;
            } else {
                ambitoVentas = true;
            }
        }

        if(ambitoMotivo == 'Ventas' || ambitoMotivo == 'Oficina') {
                 ambitoVentas = true; 
        }

        if(ambitoMotivo == 'Hub Imagin' || ambitoMotivo == 'Argos Xpays' || ambitoMotivo == 'Argos General') {
            ambitoVentas = true;
        } 

        if(ambitoMotivo == 'Oficina física') {
            if(!caso.Account.CC_EsIntouch__c) {
                ambitoVentas = true;
            }             
        }

        if(ambitoMotivo == 'Mecanismo de firma') {
            ambitoVentas = true;
        }

        if(ambitoMotivo == 'CBP') { //CBP
            ambitoCBP = true;
            if(!caso.Account.CC_EsIntouch__c) {
                ambitoVentas = true;
            } 

        }

        if(ambitoMotivo == 'Documentación') {
            preguntaTrasladarDocumentacion = false;
            if(caso.Origin == 'Phone'){
                if(caso.CC_DevolucionCSBD__c && !caso.CBK_Case_Extension_Id__r.CC_Documentacion__c) {
                    ambitoVentas = true;
                } else {
                    if(textosMap.get('Documentacion certificado caixa') != 'CSBD' && !caso.CBK_Case_Extension_Id__r.CC_Documentacion__c) {  
                        ambitoVentas = true;                 
                    } 
                } 
            }else{
                ambitoVentas = true;
            }
        }
        
        if(caso.CC_MCC_Solucion__r.CC_AmbitoTareas__c == 'Fraude' && otpDerivar == null) {
            ambitoFraude = true;
        } 
        if(ambitoMotivo == 'Bizum Fraude'){
            ambitoFraude = true;
        } else if(ambitoMotivo == 'Caso a fraude'){
            ambitoFraude = true;
            ambitoVentas = true;
        }
                    
        if(CC_Gestion_Derivar_Global.casoFraudeRechazado(caso)){
            ambitoMotivo = '';
            ambitoVentas = true;
            ambitoFraude = false;
        }

        retorno.put('ambitoMotivo', ambitoMotivo);
        retorno.put('ambitoCSBD', ambitoCSBD);
        retorno.put('imagin', imagin);
        retorno.put('ambitoVentas', ambitoVentas);
        retorno.put('ambitoFraude', ambitoFraude);
        retorno.put('ambitoCBP', ambitoCBP);//CBP
        retorno.put('preguntaTrasladarDocumentacion', preguntaTrasladarDocumentacion);
    }

    public static void rellenarAlerta(Case caso, Map<String, Object> retorno, Boolean otpDerivar){
        Boolean imagin = (Boolean)retorno.get('imagin');
        if(imagin) {       
            retorno.put('alerta', caso.CC_MCC_Motivo__r.CC_Alerta_Imagin__c);
        } else {
            retorno.put('alerta', caso.CC_MCC_Motivo__r.CC_Alerta_Caixa__c);
        }

        if(otpDerivar != null) {         
            retorno.put('alerta', null);            
        }
    }

    public static void rellenarDatosFraudeSolucion(Map<String, Object> retorno, Map<String, Object> textosMap) {
        retorno.put('preguntaSenalAntigua', textosMap.get('Pregunta señal Antigua'));
        retorno.put('preguntaRealizarRemitido', textosMap.get('Pregunta realizar remitido'));
        retorno.put('toastRemitir', textosMap.get('Toast remitir'));
        retorno.put('fraudeANivelDeMotivo', false);
    }

    public static void rellenarDatosFraude(/*Case caso,*/ Map<String, Object> retorno, Map<String, Object> textosMap){
        String ambitoMotivo = (String) retorno.get('ambitoMotivo');
        retorno.put('fraudeANivelDeMotivo', true);

        if(ambitoMotivo == 'Caso a Fraude'){
            
            /*
            List<Task> tareaIntentoTransferencia = [SELECT Id, Subject FROM Task WHERE WhatId = :caso.Id AND Type = 'Intento de transferencia' LIMIT 1];
            
            if (caso.Origin != 'Teléfono' || !tareaIntentoTransferencia.isEmpty()) {
                retorno.put('intentoTranseferenciaLlamadaFraude', true);
            }else if(caso.Origin == 'Teléfono' && tareaIntentoTransferencia.isEmpty()) {
                retorno.put('intentoTranseferenciaLlamadaFraude', false);
            }*/

            retorno.put('preguntaSenal', textosMap.get('Pregunta señal'));
            retorno.put('preguntaMotivoFraude', textosMap.get('Pregunta motivo fraude'));
            retorno.put('toastRemitir', textosMap.get('Toast remitir'));
            /*
            retorno.put('preguntaTransLlamFra', (String) textosMap.get('Pregunta transferencia llamada fraude'));
            retorno.put('modalTransLlamFra', (String) textosMap.get('Modal transferencia llamada fraude'));
            retorno.put('mensajeTransLlamFra', (String) textosMap.get('Mensaje transferencia llamada fraude'));*/
        } else if (ambitoMotivo == 'Bizum Fraude'){
            retorno.put('motivoDevolucionTemaFraude', textosMap.get('Pregunta motivo devolucion tema fraude'));
            CC_Settings__c configuracion = CC_Settings__c.getValues('CC_GruposColaboradoresFraude');
            retorno.put('grupoColaboradorFraudeSI', configuracion.CC_Configuracion_1__c);
            retorno.put('grupoColaboradorFraudeNO', configuracion.CC_Configuracion_2__c);
        }

    }
    public static void rellenarDatosGrupoColaborador(List<CC_MCC_Grupo_Colaborador__c> listaGrupoColaborador, Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('preguntaGrupoColaborador', textosMap.get('Pregunta traslado colaborador'));
        retorno.put('toastTrasladarDesdeDerivar', textosMap.get('Toast trasladar desde guardar'));

        Boolean preguntaTrasladarDocumentacion = (Boolean) retorno.get('preguntaTrasladarDocumentacion');
        if (preguntaTrasladarDocumentacion) {
            retorno.put('grupoColaborador', listaGrupoColaborador[0]);
        }
    }

    public static void rellenarDatosCliente(Map<String, Object> retorno){
        retorno.put('cambioOficina', true);
        retorno.put('mostrarModalCreacionTarea', true);
        retorno.put('ambitoCSBD', false);
        retorno.put('ambitoFraude', false);
    }


    public static void rellenarDatosOficinaNull(Map<String, Object> retorno, CC_Settings__c consultarGestorPool){
        Boolean imagin = (Boolean) retorno.get('imagin');
        if(imagin && !Boolean.valueOf(consultarGestorPool.CC_Configuracion_3__c)) {
            retorno.put('mostrarModalCreacionTarea', true);
        } 
    }

    public static void rellenarDatosVentaOficina(Map<String, Object> retorno){
        Boolean imagin = (Boolean) retorno.get('imagin');
        if(imagin) {
            retorno.put('mostrarModalCreacionTarea', true);
        } 
    }

    public static void rellenarDatosCambioOficina(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap){
        if(caso.Account.CC_Numero_Documento__c == null || caso.Account.AV_OficinaPrincipal__c == null) {
            throw new AuraHandledException('El cliente debe tener número de documento y oficina principal asignada');
        } else {
            String comentarioCambioOficina = (String) textosMap.get('Comentario cambio oficina');
            comentarioCambioOficina = comentarioCambioOficina.replace('[dni]', caso.Account.CC_Numero_Documento__c);
            comentarioCambioOficina = comentarioCambioOficina.replace('[oficina origen]', caso.Account.AV_OficinaPrincipal__r.Name);
            if (caso.Account.Recordtype.Developername == 'CC_Cliente' && caso.Account.Name != null) {
                comentarioCambioOficina = comentarioCambioOficina.replace('[nombre], [apellidos]', caso.Account.Name);
            } else if(caso.Account.Recordtype.Developername == 'CC_ClientePA') {
                if(caso.Account.FirstName != null) {
                    comentarioCambioOficina = comentarioCambioOficina.replace('[nombre]', caso.Account.FirstName);
                }
                if(caso.Account.LastName != null) {
                    comentarioCambioOficina = comentarioCambioOficina.replace('[apellidos]', caso.Account.LastName);
                }
            }
            retorno.put('comentarioCambioOficina', comentarioCambioOficina);
            retorno.put('mostrarModalCreacionTarea', true);
            retorno.put('cambioOficina', true);
        }
    }

    public static void rellenarDatosCambioGestor(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap){
        if(caso.Account.CC_Numero_Documento__c == null) {
            throw new AuraHandledException('El cliente debe tener número de documento y oficina principal asignada');
        } else {
            String comentarioCambioGestor = (String) textosMap.get('Comentario cambio gestor');
            comentarioCambioGestor = comentarioCambioGestor.replace('[dni]', caso.Account.CC_Numero_Documento__c);
            if(caso.Account.Recordtype.Developername == 'CC_Cliente' && caso.Account.Name != null) {
                comentarioCambioGestor = comentarioCambioGestor.replace('[nombre], [apellidos]', caso.Account.Name);
            } else if(caso.Account.Recordtype.Developername == 'CC_ClientePA') {
                if(caso.Account.FirstName != null) {
                    comentarioCambioGestor = comentarioCambioGestor.replace('[nombre]', caso.Account.FirstName);
                }
                if(caso.Account.LastName != null) {
                    comentarioCambioGestor = comentarioCambioGestor.replace('[apellidos]', caso.Account.LastName);
                }
            }
            retorno.put('comentarioCambioGestor', comentarioCambioGestor);
            retorno.put('mostrarModalCreacionTarea', true);
            retorno.put('cambioGestor', true);
        }
    }

    public static void rellenarDatosCajeros(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('preguntaCajeros', textosMap.get('Pregunta cajeros'));
        retorno.put('preguntaCajerosExternos', textosMap.get('Pregunta cajero externalizado'));
        retorno.put('toastCajerosExternos', textosMap.get('Toast cajero externalizado'));
        retorno.put('urlCajeros', textosMap.get('Url cajeros'));
    }

    public static void rellenarDatosCajerosIncidencias(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap){
        if(caso.AssetId == null) {
            retorno.put('toastCajerosIncidencias', textosMap.get('Error Incidencias Cajeros'));
            retorno.put('tituloCajerosIncidencias', textosMap.get('Titulo Error Incidencias Cajeros'));
        } else {
            retorno.put('flowDerivar', true);
        }
    }

    public static void rellenarDatosTestamentaria(Map<String, Object> retorno, Map<String, Object> textosMap){      
        retorno.put('mostrarModalDNITestamentaria', true);
        retorno.put('textoTestamentariaDocumentacion', textosMap.get('Texto testamentaria documentacion'));
    }

    //Accionistas
    public static void rellenarDatosAmbitoAccionistas(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('mensajeDerivarAccionistas', textosMap.get('Mensaje derivar accionistas'));
        if(!caso.Account.AV_Cliente__c){
            rellenarDatosNoCliente(retorno, textosMap);
        } else {
            retorno.put('ambitoVentas', true);
        }
    }
    //Accionistas

    public static void rellenarDatosNoCliente(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('toastNoCliente', textosMap.get('Mensaje derivar no clientes'));
        retorno.put('cambioOficina', true);
        retorno.put('mostrarModalCreacionTarea', true);
    }

    public static void rellenarDatosClienteConfidencial(Map<String, Object> retorno, Map<String, Object> textosMap, Case caso, String gestorGenericoName, CC_Settings__c consultarGestorPool){
        if(retorno.get('3NClienteConfidencial') == true){
            retorno.put('toastTrasladar3N', textosMap.get('Toast traslado 3N confidencial'));
        } else if (retorno.get('3NClienteConfidencial') == false) {
            if(caso.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c != null && caso.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__r.CSBD_Resolucion__c == 'Devolución a contact') {
                retorno.put('ambitoMotivo', null);
                retorno.put('ambitoCSBD', false);
                retorno.put('ambitoVentas', true);
                rellenarDatosAmbitoVentas(caso, retorno, gestorGenericoName, consultarGestorPool, textosMap);
            } else {
                retorno.put('ambitoCSBD', true);
                retorno.put('oportunidadCreada', caso.CC_Oportunidad_Creada__c);
                retorno.put('toastCSBDNoContratar', textosMap.get('Toast CSBD No Contratar cliente confidencial'));
                retorno.put('textoOportunidadExistente', textosMap.get('Texto Oportunidad Existente'));
                retorno.put('textoMotivoCSBDNoContratar', textosMap.get('Texto motivo CSBD No Contratar cliente confidencial'));
                retorno.put('CSBDConfidencial', true);
            }
        }
    }

    public static void rellenarDatosHubImagin(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('hubImagin', true);
    }

    public static void rellenarDatosOficinaFisica(Case caso, Map<String, Object> retorno){
        Boolean imagin = (Boolean) retorno.get('imagin');
        if(caso.Account.CC_EsIntouch__c || imagin) {
            retorno.put('oficinaFisica', true);
            retorno.put('mostrarModalCreacionTarea', true);
        } 
    }

    public static void rellenarDatosDocumentacion(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap){
        Boolean imagin = (Boolean) retorno.get('imagin');
        if(caso.CC_DevolucionCSBD__c || caso.Origin != 'Phone') { // Este campo ahora indica el flag de documentación
            retorno.put('preguntaInformacionCompletaDocumentacion', textosMap.get('Pregunta información completa documentación'));                     
        } else {
            if (caso.CBK_Case_Extension_Id__r.CC_Documentacion__c) {
                retorno.put('documentacionCaseExtension', caso.CBK_Case_Extension_Id__r.CC_Documentacion__c);
                retorno.put('toastDocumentacionCasoYaCreado', textosMap.get('Toast documentación caso ya creado'));
            } else {
                retorno.put('textoDocumentacionCertificado', textosMap.get('Texto documentacion certificado'));
                retorno.put('documentacionDecisionCaixa', textosMap.get('Documentacion certificado caixa'));
                retorno.put('toastDocumentacionCasoCreado', textosMap.get('Toast documentación caso creado'));
                retorno.put('modalDocumentacionCasoCreado', textosMap.get('Modal documentación caso creado'));
                retorno.put('preguntaInformacionRequeridaDocumentacion', textosMap.get('Pregunta información requerida documentación'));
                if(!imagin) {
                    if(textosMap.get('Documentacion certificado caixa') == 'CSBD') {     
                        retorno.put('oportunidadCreada', caso.CC_Oportunidad_creada__c);
                        retorno.put('toastCSBDNoContratar', textosMap.get('Toast CSBD No Contratar'));
                        retorno.put('textoOportunidadExistente', textosMap.get('Texto Oportunidad Existente'));
                        retorno.put('textoMotivoCSBDNoContratar', textosMap.get('Texto motivo CSBD No Contratar'));
                    }
                } else {
                    retorno.put('hubGestion', true);
                }
            }
        }
    }
    public static void rellenarDatosAmbitoCSBD(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap) {
        Boolean ambitoVentas = (Boolean) retorno.get('ambitoVentas');
        String ambitoMotivo = (String) retorno.get('ambitoMotivo');
        Boolean ambitoCSBD = (Boolean) retorno.get('ambitoCSBD');
        Boolean imagin = (Boolean) retorno.get('imagin');
        List<String> valoresParametrizacionCSBD = String.valueOf(CC_MetodosUtiles.getCustomSetting('CC_ParametrizacionesCSBD').CC_Configuracion_1__c).split(';');
        Boolean condicionClienteDigital = Boolean.valueOf(valoresParametrizacionCSBD[0]);
        Boolean condicionTipoPersona = Boolean.valueOf(valoresParametrizacionCSBD[1]);
        Boolean condicionOTP = Boolean.valueOf(valoresParametrizacionCSBD[2]);
        if(caso.Account.AV_OficinaPrincipal__r.Parent.CC_Derivacion_CSBD__c) {
            String numPerso = CC_OTP.recuperarNumperso(caso);
            Map<String, String> retornoAutenticacionSAU = CC_WS_Autenticacion_SAU.ccWsEnvioAutenticacion(imagin, numPerso,false, caso);//MBO
            String clienteDigital = retornoAutenticacionSAU.get('resultado');
            retorno.put('reqAutenticacionSAU', retornoAutenticacionSAU.get('allReq'));
            retorno.put('resAutenticacionSAU', retornoAutenticacionSAU.get('allRes'));
            retorno.put('nombreTraza', retornoAutenticacionSAU.get('nombreTraza'));
            retorno.put('autenticacionSAU', true);
            if((clienteDigital == 'exist_contract' || !condicionClienteDigital) && (caso.Account.CC_Tipo_Persona__c == 'F' || !condicionTipoPersona)) {
                if((caso.CC_OTP_Nivel__c != null && caso.CC_Status_Autorizacion__c != 'APPROVED' && caso.CC_OTP_Valido__c == false) && condicionOTP) {
                    ambitoCSBD = false;
                    ambitoVentas = true;
                } else {
                    Boolean telefonoCSBD = CC_MetodosUtiles.getCustomSetting('CC_TelefonoActivoCSBD').CC_Configuracion_1__c == 'true' ? true : false;
                    String preguntaTelefonoCSBD = textosMap.get('Pregunta Telefono CSBD').toString();
                    if(telefonoCSBD) {
                        preguntaTelefonoCSBD = preguntaTelefonoCSBD.replace('[telefono]', caso.Account.PersonMobilePhone != null ? caso.Account.PersonMobilePhone : 'no definido');
                        retorno.put('preguntaTelefonoCSBD', preguntaTelefonoCSBD);
                        retorno.put('preguntaTelefonoCSBDNoEncontrado', textosMap.get('Pregunta Telefono CSBD No Encontrado'));
                    }
                    if(ambitoMotivo == 'CSBD 3N') {
                        retorno.put('toastTrasladar3N', textosMap.get('Toast trasladar 3N'));
                    } else if(ambitoMotivo == 'CSBD No Contratar') {
                        if (CC_MetodosUtiles.getCustomSetting('CC_ParametrizacionesCSBD').CC_Configuracion_2__c == 'true' ? true : false) {
                            retorno.put('modalParametrizableCSBD', textosMap.get('Modal CSBD No Contratar parametrizable'));
                        }
                        retorno.put('oportunidadCreada', caso.CC_Oportunidad_Creada__c);
                        retorno.put('toastCSBDNoContratar', textosMap.get('Toast CSBD No Contratar'));
                        retorno.put('textoOportunidadExistente', textosMap.get('Texto Oportunidad Existente'));
                        retorno.put('textoMotivoCSBDNoContratar', textosMap.get('Texto motivo CSBD No Contratar'));
                        ambitoVentas = true;
                    } else if(ambitoMotivo == 'CSBD Contratar') {
                        retorno.put('urlTF', textosMap.get('URL TF'));
                        retorno.put('oportunidadCreada', caso.CC_Oportunidad_Creada__c);
                        retorno.put('preguntaCSBDContratar', textosMap.get('Pregunta CSBD Contratar'));
                        retorno.put('toastCrearOportunidad', textosMap.get('Toast crear oportunidad'));
                        retorno.put('preguntaCSBDContratar2', textosMap.get('Pregunta CSBD Contratar 2'));
                        retorno.put('textoOportunidadExistente', textosMap.get('Texto Oportunidad Existente'));
                        ambitoVentas = true;
                    }
                }
            } else {
                ambitoVentas = true;
                ambitoCSBD = false;
            }
        } else {
            ambitoVentas = true;
            ambitoCSBD = false;
        }
        retorno.put('ambitoCSBD', ambitoCSBD);
        retorno.put('ambitoVentas', ambitoVentas);
    }

    public static void rellenarDatosAmbitoVentas(Case caso, Map<String, Object> retorno, String gestorGenericoName, CC_Settings__c consultarGestorPool,Map<String, Object> textosMap){
        String ambitoMotivo = (String) retorno.get('ambitoMotivo');
        Boolean ambitoCSBD = (Boolean) retorno.get('ambitoCSBD');
        Boolean imagin = (Boolean) retorno.get('imagin');
        if(
            ambitoMotivo == 'Ventas' ||
			ambitoMotivo == 'Oficina física' ||
            ambitoMotivo == 'CSBD Contratar' ||
            ambitoMotivo == 'CSBD 3N' ||
            ambitoMotivo == 'CSBD No Contratar' ||  
            ambitoMotivo == 'Documentación' || 
            ambitoMotivo == 'Caso a fraude' ||
            ambitoMotivo == 'Argos General' ||
            ambitoMotivo == 'Argos Xpays' ||
            ambitoMotivo == 'Mecanismo de firma' ||
            ambitoMotivo == 'Onboarding' ||
            (ambitoMotivo == 'Accionistas' && caso.Account.AV_Cliente__c) ||
            (ambitoMotivo == 'Oficina') || 
            ((ambitoMotivo == '' || ambitoMotivo == null || ambitoCSBD))
        ) {
            if(Boolean.valueOf(consultarGestorPool.CC_Configuracion_3__c)) {
                if(caso.Account.AV_EAPGestor__c != null && caso.Account.AV_EAPGestor__r.AV_Pool__c) {
                    retorno.put('mostrarModalGestionGestorGenerico', true);
                    retorno.put('citaRapida', true);
                    retorno.put('opcionesCitaRapida', CC_Disponibilidad_Cita_Setting.getOptionsCitaRapida());
                    retorno.put('textoOperativaDerivarOficina', textosMap.get('Texto ambito nulo oficina'));               
                } else if (gestorGenericoName == caso.Account.AV_EAPGestor__r.Name || caso.Account.AV_EAPGestor__c == null) {
                    retorno.put('mostrarModalGestionGestorGenerico', true);
                    retorno.put('textoOperativaDerivarOficina', textosMap.get('Texto ambito nulo oficina'));
                } else {
                    retorno.put('mostrarModalGestionGestorAsignado', true);
                    retorno.put('textoOperativaDerivarGestor', textosMap.get('Texto ambito nulo gestor'));
                }
            } else {
                if(gestorGenericoName == caso.Account.AV_EAPGestor__r.Name || caso.Account.AV_EAPGestor__c == null) {
                    retorno.put('mostrarModalGestionGestorGenerico', true);
                    retorno.put('citaRapida', false); 
                    retorno.put('textoOperativaDerivarOficina', textosMap.get('Texto ambito nulo oficina'));                
                } else {
                    retorno.put('mostrarModalGestionGestorAsignado', true);
                    retorno.put('textoOperativaDerivarGestor', textosMap.get('Texto ambito nulo gestor'));
                }
            }
        } else {
            retorno.put('mostrarModalCreacionTarea', true);
        }
    }

    public static void rellenarNumeroOficina(Case caso, Map<String, Object> retorno){
        if(retorno.containsKey('citaRapida')){
            List <AV_BookMember__c> bookmember = [Select Id, AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c FROM AV_BookMember__c WHERE AV_Cliente__c = :caso.AccountId and AV_Cartera__r.AV_TipoCartera__c = 'BPA' and AV_Cartera__r.AV_Activa__c = 'S'];
            if(!bookmember.isEmpty()){
                retorno.put('numOficina', bookmember[0].AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c);
            } else {
                retorno.put('numOficina', 'carteraVacia');
            }
        } else {
            retorno.put('numOficina', caso.Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c);
        }     
    }

    public static void rellenarDatosGenerales(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap, String gestorGenericoName){ 
        retorno.put('citaRapidaPresencialToast', textosMap.get('Toast cita rapida presencial'));
        retorno.put('gestorGenericoName' , gestorGenericoName);
        retorno.put('detallesConsulta', caso.CC_Detalles_Consulta__c);
        retorno.put('numperso' , caso.Account.AV_NumPerso__c);
        retorno.put('nif' , caso.Account.CC_Numero_Documento__c);
        retorno.put('derivar', caso.CC_Derivar__c);
        retorno.put('gestor', caso.Account.AV_EAPGestor__c);
        retorno.put('oficinaPrincipal', caso.Account.AV_OficinaPrincipal__c);
        retorno.put('gestores', CC_MetodosUtiles.buscarGestores(caso.Account.AV_OficinaPrincipal__c));
        retorno.put('preguntaRealizarRemitido', textosMap.get('Pregunta realizar remitido'));
        retorno.put('toastTrasladarDesdeDerivar', textosMap.get('Toast trasladar desde guardar'));
        retorno.put('toastRemitirDesdeDerivar', textosMap.get('Toast remitir desde guardar'));
        retorno.put('mensajeSinDisponibilidadGestor', textosMap.get('Mensaje sin disponibilidad gestor'));
    }   

    public static void rellenarDatosOnboarding(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap){
        String ambitoMotivo = (String) retorno.get('ambitoMotivo');
        if (caso.CC_Status_Autorizacion__c == 'APPROVED') {
            if (caso.CBK_Case_Extension_Id__r.CC_EmpresaONB__c == null && caso.CBK_Case_Extension_Id__r.CC_EstadoONB__c == null && caso.CBK_Case_Extension_Id__r.CC_FechaEstadoONB__c == null && caso.CBK_Case_Extension_Id__r.CC_MotivoCierreONB__c == null && caso.CBK_Case_Extension_Id__r.CC_SubestadoONB__c == null && caso.CBK_Case_Extension_Id__r.CC_NumSR__c == null) {
                retorno.put('ambitoVentas', true);
            } else {
                
                //Textos
        if (caso.CBK_Case_Extension_Id__r.CC_DerivadoBPO__c) {
            retorno.put('derivadoBPO', textosMap.get('Texto modal Onboarding ya derivado'));
        } else {
            String settingCodigos = CC_Settings__c.getValues('CC_CodigosOnboarding')?.CC_Configuracion_2__c;
            List<String> codigos = settingCodigos.split(';');
                    if (ambitoMotivo == 'Onboarding') {
                        if (codigos.contains(caso.CBK_Case_Extension_Id__r.CC_CodigoONB__c)) {
                retorno.put('textoModalOnboarding', textosMap.get('Texto modal Onboarding'));
                        } else {
                            // Campos a mostrar en el modal de Onboarding
                            retorno.put('empresaONB', caso.CBK_Case_Extension_Id__r.CC_EmpresaONB__c);
                            retorno.put('estadoONB', caso.CBK_Case_Extension_Id__r.CC_EstadoONB__c);
                            retorno.put('subestadoONB', caso.CBK_Case_Extension_Id__r.CC_SubestadoONB__c);
                            retorno.put('fechaEstadoONB', caso.CBK_Case_Extension_Id__r.CC_FechaEstadoONB__c);
                            retorno.put('motivoCierreONB', caso.CBK_Case_Extension_Id__r.CC_MotivoCierreONB__c);
                            retorno.put('numSR', caso.CBK_Case_Extension_Id__r.CC_NumSR__c);

                            retorno.put('textoModalOnboardingCodigos', textosMap.get('Texto modal Onboarding respuesta codigos'));
                        }
            } else if (ambitoMotivo == 'Desistir') {
                retorno.put('textoModalOnboarding', textosMap.get('Texto modal Desistir'));
            }
            retorno.put('textoCorreoEnviado', textosMap.get('Texto modal correo enviado'));
        }
            }
        } else {
            retorno.put('ambitoVentas', true);
        }
    }

    public static Boolean casoFraudeRechazado(Case caso){
        List<Task> tareaFraude = [SELECT Id, Subject FROM Task WHERE WhatId = :caso.Id AND Type = 'Caso Rechazado en Fraude' LIMIT 1];
        return !tareaFraude.isEmpty();
    }

    //Datos para la operativa de ArgosXPays
    public static void rellenarDatosArgosXpays(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('operacionMFAArgos', textosMap.get('Pregunta Operacion MFA Argos'));
    }

    public static void rellenarDatosArgosGeneral(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('diarioMFAArgos', textosMap.get('Pregunta Diario MFA Argos'));
        retorno.put('cabeceraPreguntasMFAArgos', textosMap.get('Cabecera Preguntas MFA Argos'));
        List<String> preguntasArgos = new List<String>{
            textosMap.get('Pregunta Inversion Argos').toString(),
            textosMap.get('Pregunta WhatsApp Emergencia Argos').toString(),
            textosMap.get('Pregunta Contacto Gestor Argos').toString(),
            textosMap.get('Pregunta Factura Argos').toString(),
            textosMap.get('Pregunta CompraVenta Argos').toString()
        };
        retorno.put('preguntasArgos', preguntasArgos);
        retorno.put('preguntaConfirmacionArgos', textosMap.get('Pregunta Confirmacion Argos'));
        CC_Settings__c configuracion = CC_Settings__c.getValues('CC_GruposColaboradoresFraude');
        retorno.put('cyberfraude', configuracion.CC_Configuracion_3__c);
        retorno.put('cybersoc', configuracion.CC_Configuracion_4__c);
        retorno.put('preguntaIdBancaDigital', textosMap.get('Pregunta Identificador Banca Digital'));
    }

    @AuraEnabled
    public static void rellenarPreguntasArgos(Id recordId, String preguntasArgos){
        Case caso = [SELECT Id, SAC_Redaccion__c FROM Case WHERE Id = :recordId LIMIT 1];
        List<Map<String, String>> preguntasList = (List<Map<String, String>>) JSON.deserialize(preguntasArgos, List<Map<String, String>>.class);
        String preguntasConcatenadas = '';
        for (Map<String, String> pregunta : preguntasList) {
            String key = pregunta.get('key');
            String value = pregunta.get('value');
            if (String.isNotEmpty(key) && String.isNotEmpty(value)) {
                if (!String.isEmpty(preguntasConcatenadas)) {
                    preguntasConcatenadas += '\n';
                }
                preguntasConcatenadas += key + ': ' + value;
            }
        }
        caso.SAC_Redaccion__c = preguntasConcatenadas;
        update caso;
    }
    

    //MGT
    public static void rellenarDatosPhisingSmishingMalware(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('PhisingSmishingMalware1', textosMap.get('Phising/Smishing/Malware 1'));
        retorno.put('PhisingSmishingMalware2', textosMap.get('Phising/Smishing/Malware 2'));
        retorno.put('PhisingSmishingMalware3', textosMap.get('Phising/Smishing/Malware 3'));
        retorno.put('toastRemitir', textosMap.get('Toast remitir'));
        retorno.put('PhisingSmishingMalware5', textosMap.get('Phising/Smishing/Malware 5'));
        retorno.put('PhisingSmishingMalware6', textosMap.get('Phising/Smishing/Malware 6'));
    }
    //MGT
    public static void rellenarDatosMecanismoFirma(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap){
        //Obtener el custom setting con los circuitos
		CC_Settings__c configuracion = CC_Settings__c.getValues('CC_MecanismoFirmaCircuitoCaso');
		Boolean circuitoEncendido = configuracion.CC_Activa__c;

        Boolean mecanismoFirma = [SELECT CBK_Case_Extension_Id__r.CC_MecanismoFirma__c FROM Case WHERE Id = :caso.Id LIMIT 1].CBK_Case_Extension_Id__r.CC_MecanismoFirma__c; 
        List<Task> tareaIdentoficadorBloqueado = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type ='Identificador bloqueado' LIMIT 1]; 

        if(!mecanismoFirma){
            if(!tareaIdentoficadorBloqueado.isEmpty()){
                retorno.put('preguntaIdentificadorSigueBloqueado', textosMap.get('Pregunta identificador sigue bloqueado'));
            } else {
                // Obtener el string original de textosMap
                String mecanismoFirmaDatosValores = textosMap.get('Pregunta mecanismo firma datos preguntas').toString();
                
                // Dividir el string en una lista utilizando una coma como delimitador
                List<String> mecanismoFirmaDatosValoresLista = mecanismoFirmaDatosValores.split(',');
                retorno.put('preguntaMecanismoFirma', textosMap.get('Pregunta mecanismo firma'));
                retorno.put('preguntaMecanismoFirmaDatos', textosMap.get('Pregunta mecanismo firma datos'));
                retorno.put('preguntaMecanismoFirmaDatosValores', mecanismoFirmaDatosValoresLista);
                retorno.put('preguntaMecanismoFirmaIdentificador', textosMap.get('Pregunta mecanismo firma identificador'));
                retorno.put('toastMecanismoFirmaIdentificadorBloqueado', textosMap.get('Toast mecanismo firma identificador bloqueado'));
                retorno.put('toastMecanismoFirmaArgosCorrecto', textosMap.get('Toast  mecanismo firma argos correcto'));
                retorno.put('toastMecanismoFirmaDatosIncompletos', textosMap.get('Toast mecanismo firma datos incompletos'));
                retorno.put('toastMecanismoFirmaCasoCreado', textosMap.get('Toast mecanismo firma caso creado'));

            }
           
            if (circuitoEncendido) {
                retorno.put('toastMecanismoFirmaIdentificadorSinBloquear', textosMap.get('Toast mecanismo firma identificador no bloqueado'));
            }else{
                retorno.put('toastMecanismoFirmaIdentificadorSinBloquear', textosMap.get('Toast mecanismo firma identificador no bloqueado circuito apagado'));
            }
           
            retorno.put('ambitoVentas', true);

        }else{
            //Obtener el custom setting con los circuitos
            CC_Settings__c configuracion2 = CC_Settings__c.getValues('CC_GruposColaboradoresMecanismoFirma');
            retorno.put('cybersocMF', configuracion2.CC_Configuracion_1__c);

            retorno.put('preguntaMecanismoFirmaClienteAutenticado', textosMap.get('Pregunta mecanismo firma cliente autenticado'));
            retorno.put('toastMecanismoFirmaAsuntoEnvioCodigo', textosMap.get('Toast mecanismo firma asunto envio codigo'));
        }
    }
    
    public static void rellenarDatosOficinaSinTarea(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('mensajeOficinaSinTarea', textosMap.get('Mensaje oficina sin tarea'));
        //retorno.put('mostrarModalToast', true);
    }

    //Amenazas
    public static void rellenarDatosAmenazas(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap){
        //Comunes
        retorno.put('mensajeDerivacionAmenazasTipo', textosMap.get('Mensaje derivacion amenazas tipo'));
        retorno.put('nameOWA', CC_Settings__c.getValues('CC_OWA_Por_Defecto_Email_Automatico').CC_Configuracion_1__c);
        //Amenazas suicidios
        retorno.put('mensajeSolicitudDatosAmenazasSuicidios', textosMap.get('Mensaje solicitud datos amenazas suicidios'));
        retorno.put('emailSuccess', textosMap.get('Mensaje email enviado OK'));
        retorno.put('nombrePlantilla', textosMap.get('Nombre Plantilla Amenazas Suicidios'));
        retorno.put('grupoColClientesAmenazas', CC_Settings__c.getValues('CC_GruposColaboradoresParamDerivar').CC_Configuracion_2__c);
        //Amenazas empleados
        retorno.put('mensajeSolicitudDatosAmenazasEmpleados', textosMap.get('Mensaje solicitud datos amenazas empleados'));
        retorno.put('cambioOficina', true);
        retorno.put('nombrePlantillaAmenazasEmpleados', textosMap.get('Nombre Plantilla Amenazas Empleados'));
        retorno.put('emailSuccess', textosMap.get('Mensaje email enviado OK'));
        retorno.put('grupoColEmpleadosAmenazas', CC_Settings__c.getValues('CC_GruposColaboradoresParamDerivar').CC_Configuracion_1__c);
    }
    
    // CBP

    public static void rellenarDatosCBP(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap) {
        Boolean esIntouch = caso.Account.CC_EsIntouch__c;
        retorno.put('nameOWA', CC_Settings__c.getValues('CC_OWA_Por_Defecto_Email_Automatico').CC_Configuracion_2__c);
        retorno.put('mostrarModalCBP', true);
        retorno.put('RefinanciacionDeudas1', textosMap.get('Pregunta números de contrato'));
        retorno.put('esIntouch', esIntouch);
        retorno.put('preguntaCBP', textosMap.get('Pregunta CBP')); 
        retorno.put('nombrePlantilla', 'Plantilla CBP');
        retorno.put('grupoCol', CC_Settings__c.getValues('CC_GruposColaboradoresCBP').CC_Configuracion_1__c);
    }

    public static void rellenarDatosSAC(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap) {
        Boolean mostrarDerivarSAC = false;
        Boolean mostrarDevolverSAC = false;
        Boolean mostrarCanalProcedenciaErroneo = false;
        Boolean customSettingDerivarActivo = false;
        Boolean customSettingDevolverActivo = false;

        //Recorrer Custom Settings para comprobar si esta habilitada la opcion de derivar y devolver al SAC
        for (CC_DevolverDerivarSAC__c opcion : CC_DevolverDerivarSAC__c.getAll().values()) {
            if (opcion.Name == 'CC_Derivar') {
                customSettingDerivarActivo = opcion.CC_Activo__c;
            } else if (opcion.Name == 'CC_Devolver') {
                customSettingDevolverActivo = opcion.CC_Activo__c;
            }
        }

        if (caso.CC_Canal_Procedencia__c == 'Formulario web' && customSettingDerivarActivo) {
            //Si canal de procedencia es "Formulario web" se deriva el caso al SAC
            retorno.put('mensajeDerivarAlSAC', textosMap.get('Derivar al SAC'));
            retorno.put('mensajeDerivarAlSACSuccess', textosMap.get('Derivar al SAC success'));
            mostrarDerivarSAC = true;
        } else if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente' && caso.Origin == 'Email' && customSettingDevolverActivo && caso.ParentId != null && CC_Revincular_Caso_Controller.getParentIdRecordTypeDeveloperName(caso) == 'SAC_Reclamacion') {
            //Si canal de procedencia es "Atención al cliente" y el canal de entrada es "Email" se debe devolver el caso al SAC
            retorno.put('mensajeDevolverAlSAC', textosMap.get('Devolver al SAC'));
            retorno.put('mensajeDevolverAlSACSuccess', textosMap.get('Devolver al SAC success'));
            mostrarDevolverSAC = true;
        } else {
            retorno.put('mensajeCanalProcedenciaErroneo', textosMap.get('Derivar al SAC canal procedencia erroneo'));
            mostrarCanalProcedenciaErroneo = true;
        }

        retorno.put('mostrarDerivarSAC', mostrarDerivarSAC);
        retorno.put('mostrarDevolverSAC', mostrarDevolverSAC);
        retorno.put('mostrarCanalProcedenciaErroneo', mostrarCanalProcedenciaErroneo);
    }


    //Comunidades de vecinos
    @AuraEnabled
    public static void rellenarDatosComunidadesVecinos(Case caso, Map<String, Object> retorno, Map<String, Object> textosMap) {
        retorno.put('mensajeMostrarModalToast', textosMap.get('Toast comunidades vecinos'));
        retorno.put('mostrarModalToast', true);
    }



    
    // Colectivos vulnerables
    @AuraEnabled
    public static void rellenarDatosColectivosVulnerables(Map<String, Object> retorno, Map<String, Object> textosMap) {
        retorno.put('mensajeColectivosVulnerables', textosMap.get('Texto para oficina gestora'));
        retorno.put('preguntaColectivosVulnerables', textosMap.get('Pregunta colectivo vulnerable'));  
        retorno.put('nameOWA', CC_Settings__c.getValues('CC_OWA_Por_Defecto_Email_Automatico').CC_Configuracion_3__c);
        retorno.put('nombrePlantilla', CC_Settings__c.getValues('CC_GruposColaboradoresColVulnerable').CC_Configuracion_2__c);
        retorno.put('grupoCol', CC_Settings__c.getValues('CC_GruposColaboradoresColVulnerable').CC_Configuracion_1__c);      
    }
    
    public static void rellenarDatosCashBack(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('CashBack1', textosMap.get('CashBack 1'));
        retorno.put('CashBack2', textosMap.get('CashBack descripción ID Cliente'));
        retorno.put('CashBack3', textosMap.get('CashBack descripción Nombre comercio'));
        retorno.put('CashBack4', textosMap.get('CashBack descripción Fecha de compra'));
        retorno.put('CashBack5', textosMap.get('CashBack Descripción de la reclamación'));
    }

    public static void rellenarDatosRefinanciacionDeudas(Map<String, Object> retorno, Map<String, Object> textosMap){
        retorno.put('RefinanciacionDeudas1', textosMap.get('Pregunta números de contrato'));
        retorno.put('RefinanciacionDeudas2', textosMap.get('Texto tarea AV Pool = False'));
        retorno.put('RefinanciacionDeudas3', textosMap.get('Texto tarea AV Pool = True'));
        retorno.put('RefinanciacionDeudas4', textosMap.get('Final Operativa'));
    }


    
    @AuraEnabled
    public static Boolean recuperarArgos(String recordId) {
        List<Task> tareasArgos = [SELECT Id, CC_Detalles_Solucion__c FROM Task WHERE Type = 'Argos' AND WhatId= :recordId ORDER BY CreatedDate DESC LIMIT 1];
        Case caso = [SELECT Id, AccountId, ContactId FROM Case WHERE Id = :recordId LIMIT 1];

        Boolean restricted = recuperarArgosRestricted(recordId);
        Boolean denied = recuperarArgosDenied(recordId);
        Boolean retorno = false;
        Boolean argos = denied || restricted;

        // Extraer AccountId y ContactId de CC_Detalles_Solucion__c
        String detallesSolucion = tareasArgos[0].CC_Detalles_Solucion__c;
        Boolean idsCoinciden = false;
        if (String.isNotBlank(detallesSolucion) && detallesSolucion.contains('-')) {
            List<String> partes = detallesSolucion.split('-');
            if (partes.size() == 2) {
                String accountIdDetalle = partes[0].trim();
                String contactIdDetalle = partes[1].trim();
                if (accountIdDetalle == caso.AccountId.toString() && contactIdDetalle == caso.ContactId.toString() ) {
                    idsCoinciden = true;
                }
            }
        }

        retorno = argos && idsCoinciden;
        
        return retorno;
    }

    @AuraEnabled
    public static Boolean recuperarArgosRestricted(String recordId){
        List<CBK_Case_Extension__c> extensiones = [SELECT Id, CC_Risk_Restricted__c FROM CBK_Case_Extension__c WHERE Case_Id__c = :recordId LIMIT 1];
        Boolean restricted = false;

        if (!extensiones.isEmpty()) {
            restricted = extensiones[0].CC_Risk_Restricted__c;
        }
        
        return restricted;
    }

    @AuraEnabled
    public static Boolean recuperarArgosDenied(String recordId){
        List<CBK_Case_Extension__c> extensiones = [SELECT Id, CC_Risk_Denied__c FROM CBK_Case_Extension__c WHERE Case_Id__c = :recordId LIMIT 1];
        Boolean denied = false;

        if (!extensiones.isEmpty()) {
            denied = extensiones[0].CC_Risk_Denied__c;
        }
        
        return denied;
    }

    @AuraEnabled
    public static void actualizarDetallesSolucionArgos(Id recordId, String detallesSolucion) {
        Case caso = [SELECT Id FROM Case WHERE Id = :recordId LIMIT 1];
        caso.CC_Detalles_Solucion__c = detallesSolucion;
        update caso;
    }
}