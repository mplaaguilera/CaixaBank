@RestResource(urlMapping='/Inicio_Hidden/*')
global with sharing class CC_WS_Inicio_Hidden {
/*
	//Clase para publicar un servicio Rest para la creación de casos de chat Hidden.

    //Clase para los parámetros de entrada.
    global class CC_WS_Inicio_Hidden_Input {

        global String Aplicacion {get;set;}
        global String id_Cognitive {get;set;}
        global String User_Agent {get;set;}
        global String Numperso {get;set;}
        global String Idioma {get;set;}
        global String Asunto {get;set;}
        //global String Area {get;set;}
        global String Espacio {get;set;}
        global String Categoria {get;set;}
        global String Origen {get;set;}
        global String CC_ClasificacionHidden {get;set;}
        global String CC_Origen {get;set;}
    }

    //Clase para los parámetros de salida.
    global class CC_WS_Inicio_Hidden_Output {
        global String sCodError {get;set;}
        global String sDetalleError {get;set;}
        global String sNumCaso {get;set;}
        global String sCaseId {get;set;}        
    }
    
    //Método para validar los inputs.
    private static String validarDatosEntrada (CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDatos){
        if (oDatos != null){
            //if (oDatos.TranscriptChatBot == null){
            //    return 'KO';
            //}else if (oDatos.TranscriptChatBot.trim() == '') {
            //    return 'KO';
            //}
            
            if (oDatos.id_Cognitive == null){
                return 'KO';
            }else if (oDatos.id_Cognitive.trim() == '') {
                return 'KO';
            }
            
            if (oDatos.User_Agent == null && oDatos.Numperso == null){
                return 'KO';
            }else if (oDatos.User_Agent.trim() == '' && oDatos.Numperso.trim() == '') {
                return 'KO';
            }
            
            if (oDatos.Idioma == null){
                return 'KO';
            }else if (oDatos.Idioma.trim() == '') {
                return 'KO';
            }
            
            if (oDatos.Asunto == null){
                return 'KO';
            }else if (oDatos.Asunto.trim() == '') {
                return 'KO';
            }
            
            if (oDatos.Origen == null){
                return 'KO';
            }else if (oDatos.Origen.trim() == '') {
                return 'KO';
            }

            if (oDatos.Aplicacion == null){
                return 'KO';
            }else if (oDatos.Aplicacion.trim() == '') {
                return 'KO';
            }

            // Validaciones y gestiones por aplicación.
            if (oDatos.Aplicacion == 'HIDDEN'){
                // VALIDACIONES PARA EL FORMULARIO WEB.
                if (oDatos.Espacio == null || oDatos.Categoria == null){ //oDatos.Area == null || 
                    return 'KO';
                }else if (oDatos.Espacio.trim() == '' || oDatos.Categoria.trim() == '') { //oDatos.Area.trim() == '' || 
                    return 'KO';
                }else{
                    // Rellenar los campos internos para el tratamiento de la tipificación.
                    oDatos.CC_Origen = 'CHT';

                    String sTipificacion = '';
                    sTipificacion = sTipificacion + oDatos.CC_Origen + '-';
                    //sTipificacion = sTipificacion + oDatos.Area.trim() + '-';
                    sTipificacion = sTipificacion + oDatos.Espacio.trim() + '-';
                    sTipificacion = sTipificacion + oDatos.Categoria.trim();
                    oDatos.CC_ClasificacionHidden = sTipificacion;
                }
            }
        }

        return 'OK';
    }
    
    //Recuperar el maestro de tipificaciones entre Cognitive Hidden y Salesforce.
    private static Map<String,Map<String,String>> getTipificacionesCaso (Set<String> oListaTip){
        Map<String,Map<String,String>> oData = new Map<String,Map<String,String>>();

        if (oListaTip != null){
            if (!oListaTip.isEmpty()){
                String sRecordType = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('Conversion_MCC_Chat').getRecordTypeId();
                List<CC_MCC__c> oMCC = [SELECT Id, CC_Equivalencia_Formulario__c, CC_WebMCCTematica__c, CC_WebMCCProducto__c, 
                                        CC_WebMCCMotivo__c, CC_WebTipoContacto__c 
                                        FROM CC_MCC__c WHERE CC_Equivalencia_Formulario__c IN :oListaTip AND CC_Activo__c = true
                                       AND RecordTypeId = :sRecordType];
                for (CC_MCC__c oAux : oMCC){
                    Map<String,String> oTipoSF = new Map<String,String>();
                    oTipoSF.put('Tematica', oAux.CC_WebMCCTematica__c);
                    oTipoSF.put('Producto', oAux.CC_WebMCCProducto__c);
                    oTipoSF.put('Motivo', oAux.CC_WebMCCMotivo__c);
                    oTipoSF.put('TipoContacto', oAux.CC_WebTipoContacto__c);

                    oData.put(oAux.CC_Equivalencia_Formulario__c, oTipoSF);
                }
            }
        }

        return oData;
    }
    
    //Recuperar datos configurados en los Metadatos para la cuenta origen. Prioridad, Estado, Canal acceso y tipo de cliente del caso.
    private static CC_Config_Caso_Hidden__mdt getConfigApp (String sApp){
        CC_Config_Caso_Hidden__mdt oAppCfg;

        if (sApp != ''){
            List<CC_Config_Caso_Hidden__mdt> oConfig = [SELECT Id, CC_CasoCanalEntrada__c, CC_CasoCanalOperativo__c, CC_CasoCanalProc__c, 
                                                        CC_CasoEstado__c, CC_CasoPrioridad__c, CC_ReglaAssigCaso__c
                                                        FROM CC_Config_Caso_Hidden__mdt WHERE CC_Aplicacion__c = :sApp];
            if (oConfig.size()==1){
                if (oConfig[0] != null)
                    oAppCfg = oConfig[0];
            }
        }

        return oAppCfg;
    }
    
    //Método para recuperar los datos de formularios a buscar su configuración.
    static private void getDatosFormularioConfigurados(Map<String,CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oMapForm, Set<String> oApp, Set<String> oTipificacionWeb, Map<String,Map<String,String>> oMapTipificacion){

        if (oMapForm == null || oApp == null || oTipificacionWeb == null)
            return;

        if (!oMapForm.isEmpty()){
            for (String sForm : oMapForm.keySet()){
                if (oMapForm.get(sForm) != null){
                    if (oMapForm.get(sForm).Aplicacion.trim().unescapeHtml4() != null){
                        oApp.add(oMapForm.get(sForm).Aplicacion.trim().unescapeHtml4());                            
                    }
                    
                    if (oMapForm.get(sForm).CC_ClasificacionHidden != null){
                        oTipificacionWeb.add(oMapForm.get(sForm).CC_ClasificacionHidden);
                    }

                    //if (oMapForm.get(sForm).Area != null)
                    //{
                    //    if (oMapForm.get(sForm).Area.trim().unescapeHtml4() != '')
                    //    {
                    //        oValTrad.add(oMapForm.get(sForm).Area.trim().unescapeHtml4());
                    //    }
                    //}
                }
            }

            // Recuperar conversiones MCC.
            if (!oTipificacionWeb.isEmpty()){
                oMapTipificacion = getTipificacionesCaso(oTipificacionWeb);
            }
        }
        
        return;
    }
    
    //Método para preparar la creación del caso.
    private static Map<String,Object> prepararCaso (CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oForm, Map<String, Object> oParamAux, Map<String,Map<String,String>> oMapTipificacion){
        Map<String,Object> oRes = new Map<String,Object>();

        try {
            
            if (oForm != null){

                // Configuración para el caso a partir del chat hidden.
                CC_Config_Caso_Hidden__mdt oConfig;ACCESOLOG
                
                // Crear objeto caso.
                ID sRTEmpleado = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
                Case oCaso = new Case();
                oCaso.CC_Admin__c = true;
                oCaso.RecordTypeId = sRTEmpleado;
                
                // Asignar Contacto y Account.
                if (oForm.User_Agent != null){
                   //TODO: ¿?
                }

                // Tratar los datos del chat hidden y volcar al caso.
                if (oForm.Aplicacion != null){
                    // Recuperar configuración.
                    oConfig = getConfigApp (oForm.Aplicacion.trim().unescapeHtml4());
                }
				
                if (oForm.Idioma != null){
                    oCaso.CC_Idioma__c = oForm.Idioma.trim().unescapeHtml4();
                }
                
                if (oForm.Asunto != null){
                    String sTextoHDD = oForm.Asunto.trim().unescapeHtml4();
                    String sTextoLargoHDD = sTextoHDD;

                    if (sTextoHDD != '')
                        if (sTextoHDD.length() > 80)
                            sTextoHDD = sTextoHDD.substring(0,80);

                    oCaso.Subject = sTextoHDD;
                    oCaso.Description = sTextoLargoHDD;
                }
                
                if (oForm.id_Cognitive != null){
                    oCaso.CC_Id_Cognitivo__c = oForm.id_Cognitive.trim().unescapeHtml4();
                }
                
                if (oForm.Numperso != null){
                    oCaso.CC_NumPerso__c = oForm.Numperso.trim().unescapeHtml4();
                }
                
                if (oForm.Origen != null){
                    oCaso.CC_Tipo_Cliente__c = oForm.Origen.trim().unescapeHtml4();
                }

                // Tipificar el caso.
                if (oMapTipificacion != null && oForm.CC_ClasificacionHidden != null){
                    if (oMapTipificacion.get(oForm.CC_ClasificacionHidden) != null){
                        oCaso.CC_MCC_Tematica__c = oMapTipificacion.get(oForm.CC_ClasificacionHidden).get('Tematica');
                        oCaso.CC_MCC_ProdServ__c = oMapTipificacion.get(oForm.CC_ClasificacionHidden).get('Producto');
                        oCaso.CC_MCC_Motivo__c = oMapTipificacion.get(oForm.CC_ClasificacionHidden).get('Motivo');
                        oCaso.CC_Tipo_Contacto__c = oMapTipificacion.get(oForm.CC_ClasificacionHidden).get('TipoContacto');
                    }
                }

                // Rellenar información preconfigurada.
                if (oConfig != null){
                    if (oConfig.CC_ReglaAssigCaso__c != null){
                        String sReglaId = '';

                        // Aplicar la regla de asignación del caso.
                        if (oParamAux != null){
                            if (!oParamAux.isEmpty()){
                                if (oParamAux.get('CC_ReglasAss') != null){
                                    Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ReglasAss');
                                    if (oMap.get(oConfig.CC_ReglaAssigCaso__c) != null){
                                        sReglaId = oMap.get(oConfig.CC_ReglaAssigCaso__c);
                                    }
                                }
                            }
                        }

                        if (sReglaId != ''){
                            Database.DMLOptions dmlOpts = new Database.DMLOptions();
                            dmlOpts.assignmentRuleHeader.assignmentRuleId = sReglaId;
                            oCaso.setOptions(dmlOpts);
                        }
                    }

               		if (oConfig.CC_CasoEstado__c != null)
                        oCaso.Status = oConfig.CC_CasoEstado__c;

                    if (oConfig.CC_CasoCanalEntrada__c != null)
                        oCaso.Origin = oConfig.CC_CasoCanalEntrada__c;

                    if (oConfig.CC_CasoPrioridad__c != null)
                        oCaso.Priority = oConfig.CC_CasoPrioridad__c;
                                                
                    if (oConfig.CC_CasoCanalOperativo__c != null)
                        oCaso.CC_Canal_Operativo__c = oConfig.CC_CasoCanalOperativo__c;

                    if (oConfig.CC_CasoCanalProc__c != null)
                        oCaso.CC_Canal_Procedencia__c = oConfig.CC_CasoCanalProc__c;
                }

                oRes.put('Estado', 'OK');
                oRes.put('Detalle', '');
                oRes.put('Caso', oCaso);

            }else{
                // Sin datos.
                oRes.put('Estado', 'KO');
                oRes.put('Detalle', 'No hay datos de chat Hidden.');
                oRes.put('Caso', null);    
            }

        } catch (Exception e) {
            // Error tratando el caso.
            oRes.put('Estado', 'KO');
            oRes.put('Detalle', 'Error procesado. ' + e.getMessage());
            oRes.put('Caso', null);  
        }

        return oRes;
    }
    
    //Método para crear la traza padre del proceso. Medir tiempos totales.
    private static CC_TrazaInt__c crearTrazaPadre (CC_InterfaceSettings__mdt oConfig, String sInterfaz, String sIdentificador, String sIdOrig, Object oEntrada){
        CC_TrazaInt__c oTraza;

        if (oConfig != null){
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = sInterfaz;
                oTraza.CC_Identificador__c = sIdentificador;
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_IdOrigen__c = sIdOrig;

                if (oConfig.CC_TrazaEntrada__c)
                    oTraza.CC_MensajeEntrada__c = String.valueOf(oEntrada);

                // Guardar en BBDD.
                insert oTraza;
            }
        }

        return oTraza;
    }
    
    //Método para cerrar la traza padre del proceso. Medir tiempos totales.
    private static CC_TrazaInt__c cerrarTrazaPadre (CC_InterfaceSettings__mdt oConfig, CC_TrazaInt__c oTraza, Object oSalida, Boolean bOk, String sTipoError, String sDetalleError){
        if (oConfig != null && oTraza != null){
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                if (oConfig.CC_TrazaSalida__c && oSalida != null)
                    oTraza.CC_MensajeSalida__c = String.valueOf(oSalida);

                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = bOk;
                oTraza.CC_TipoError__c = sTipoError;
                oTraza.CC_DetalleError__c = sDetalleError;

                // Guardar BBDD.
                update oTraza;
            }
        }

        return oTraza;
    }
    
    private static CC_TrazaInt__c crearTrazaDetalle (CC_InterfaceSettings__mdt oConfig, String sInterfaz, String sIdentificador, String sIdOrig, Object oEntrada, Object oSalida, Boolean bOk, String sTipoError, String sDetalleError){
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();

        if (oConfig != null){
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                oTraza.Name = sInterfaz;
                oTraza.CC_Identificador__c = sIdentificador;
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_IdOrigen__c = sIdOrig;

                if (oConfig.CC_TrazaEntrada__c)
                    oTraza.CC_MensajeEntrada__c = String.valueOf(oEntrada);

                if (oConfig.CC_TrazaSalida__c && oSalida != null)
                    oTraza.CC_MensajeSalida__c = String.valueOf(oSalida);

                oTraza.CC_FinOK__c = bOk;
                oTraza.CC_TipoError__c = sTipoError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }
        }

        return oTraza;
    }
    
    //Método publicado para crear actividad de ChatBot.
    private static Task createActivity(Id caseId, String idCognitivo) {
        Date todaysDate = system.today();
        Task task = new Task();
        task.ActivityDate = todaysDate;
        task.Subject = 'Conversación ChatBot - Hidden';
        task.Type = 'Automática'; //Pdte. si es un tipo especial para historico conversación
        task.Status = 'Open';
        task.Description = 'Conversación con ChatBot y Hidden. Acción realizada: ';
        //task.OwnerId = oChatNew.OwnerId;
        task.CC_Chat_Cognitivo_Id__c = idCognitivo;
        task.WhatId = caseId;
        //task.CC_LiveChatTranscript_Id__c = transcriptId;
        task.Priority = 'Normal';
        
        return task;
    }
    
    //Método publicado para crear casos.
    @HttpPost
    global static List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> createCase(List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oDataIn){
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oRes = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output>();
        Map<String,CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oMapForm = new Map<String,CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        List<Case> oNewCase = new List<Case>();
        List<Task> oNewTask = new List<Task>();
        Map<String,String> oMapRules = new Map<String,String>();
        Map<String,Map<String,String>> oMapTipificacion = new Map<String,Map<String,String>>();

        // Lista de trazas a crear.
        CC_TrazaInt__c oTrazaProc;
        List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();
        CC_InterfaceSettings__mdt oConfig;
        Boolean bTrazaOk = true;
        Boolean bNoDatos = false;
        String sErrGen = '';

        // Lista de contactos del formulario.
        Map<String,String> oContForm = new Map<String,String>();

        // Listas de valores y parámetros.
        Map<String, Object> oParamAux;
		
        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_WS_Inicio_Hidden');
        } catch (Exception e) {
            oTraza = null;
        }

        if (oConfig == null){
            // Interfaz no configurada o activa.
            CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output oAux = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output();
            oAux.sCodError = '9999';
            oAux.sDetalleError = 'Proceso inactivo en Salesforce.';
            oAux.sNumCaso = '';
            oRes.add(oAux);
            return oRes;
        }

        // Creamos la traza padre para medir tiempos totales.
        oTrazaProc = crearTrazaPadre (oConfig, 'CC_WS_Inicio_Hidden', 'CC_WS_Inicio_Hidden', '', oDataIn);
        String sTrazaOrig = '';
        if (oTrazaProc != null)
            sTrazaOrig = oTrazaProc.Id;

        try {
            // Control de datos.
            if (oDataIn != null){
                for (CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oForm : oDataIn){
                    String sValido = validarDatosEntrada (oForm);
                   
                    if (sValido == 'OK'){
                        // Registro para a crear datos.
                        oMapForm.put(oForm.id_Cognitive.trim().unescapeHtml4(), oForm);
                    }else{
                    	// Error validación datos entrada.
                        String sCodErr = '1';
                        String sDetErr = 'Datos obligatorios no informados.';
                        bTrazaOk = false;

                        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output oAux = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output();
                        oAux.sCodError = sCodErr;
                        oAux.sDetalleError = sDetErr;
                        oAux.sNumCaso = '';
                        oRes.add(oAux);
						
                        String sIdent = '';
                        sIdent = sTrazaOrig;

                        if (oTraza != null){
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Inicio_Hidden_DET', sIdent, sTrazaOrig, oForm, oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
            }else{
                // No hay datos de entrada.
                bTrazaOk = false;
                bNoDatos = true;
            }

            // Recuperar las aplicaciones configuradas, reglas de asignación, conversión MCC y LOVs.
            if (!oMapForm.isEmpty()){
                Set<String> oApp = new Set<String>();
                Set<String> oTipificacionWeb = new Set<String>();

                getDatosFormularioConfigurados(oMapForm, oApp, oTipificacionWeb, oMapTipificacion);

                // Recuperar conversiones MCC.
                if (!oTipificacionWeb.isEmpty()){
                    oMapTipificacion = getTipificacionesCaso(oTipificacionWeb);
                }
                oTipificacionWeb = null;
                oApp = null;

                // Añadir la configuración de reglas de asignación.
                if (!oMapRules.isEmpty()){
                    oParamAux.put('CC_ReglasAss', oMapRules);
                }
                oMapRules = null;
            }

            // Preparar creación de los casos.
            if (!oMapForm.isEmpty()){
                // Buscar contactos y crear los que no existan.
                if (!oContForm.isEmpty()){
                    //gestionContactosFormulario (oContForm, oMapForm, oParamAux);
                    //gestionCuentasContactosFormulario (oContForm, oMapForm, oParamAux);
                }
                oContForm = null;

                // Procesar los formularios.
                for (String sForm : oMapForm.keySet()){
                    if (oMapForm.get(sForm) != null){
                        String sEstado = '';
                        String sDetalle = '';
                        Case oCaso;

                        Map<String,Object> oResCaso = prepararCaso (oMapForm.get(sForm), oParamAux, oMapTipificacion);
                        for (String sRet : oResCaso.keySet()){
                            if (sRet == 'Estado'){
                                if (oResCaso.get(sRet) != null){
                                    sEstado = (String)oResCaso.get(sRet);
                                }
                            }

                            if (sRet == 'Detalle'){
                                if (oResCaso.get(sRet) != null){
                                    sDetalle = (String)oResCaso.get(sRet);
                                }
                            }

                            if (sRet == 'Caso'){
                                if (oResCaso.get(sRet) != null){
                                    oCaso = (Case)oResCaso.get(sRet);
                                }
                            }
                        }

                        if (sEstado == 'OK'){
                            if (oCaso != null){
                                oNewCase.add(oCaso);
                            }else{
                                // Error al preparar el caso.
                                String sCodErr = '2';
                                String sDetErr = 'Error al preparar el caso. ' + sDetalle;
                                bTrazaOk = false;

                                CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output oAux = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output();
                                oAux.sCodError = sCodErr;
                                oAux.sDetalleError = sDetErr;
                                oAux.sNumCaso = '';
                                oRes.add(oAux);

                                if (oTraza != null){
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Inicio_Hidden_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }
                            }
                        }else{
                            // Error al preparar el caso.
                            String sCodErr = '3';
                            String sDetErr = 'Error al preparar el caso. ' + sDetalle;
                            bTrazaOk = false;

                            CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output oAux = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output();
                            oAux.sCodError = sCodErr;
                            oAux.sDetalleError = sDetErr;
                            oAux.sNumCaso = '';
                            oRes.add(oAux);

                            if (oTraza != null){
                                CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Inicio_Hidden_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                oTraza.add(oTrazaDet);
                            }
                        }
                    }
                } 

                // Vaciar listas.
                oParamAux =  null;               
            }

            // Realizar la creación de los casos.
            List<String> oRefCasos = new List<String>();

            if (!oNewCase.isEmpty()){
                Schema.SObjectField oCampoSearch = Case.Fields.CC_Id_Cognitivo__c;
                Database.UpsertResult[] oResUp = Database.upsert(oNewCase, oCampoSearch, false);

                for (Integer i = 0, iSize = oResUp.size(); i < iSize; i++){
                    if (oResUp[i].isSuccess()){
                        // Inserción correcta.
                        oRefCasos.add(oNewCase[i].CC_Id_Cognitivo__c);
						//Creación Actividad Hidden
						Task oTask = createActivity(oNewCase[i].id, oNewCase[i].CC_Id_Cognitivo__c);
						oNewTask.add(oTask);
                    }else{
                        // Error. Trazar.
                        String sErrAux = '';
                        for(Database.Error err : oResUp[i].getErrors()) {
                            if (sErrAux != '')
                                sErrAux = sErrAux + '. ';
                            sErrAux = sErrAux + err.getMessage();
                        }

                        String sCodErr = '4';
                        String sDetErr = 'Error al crear el caso. ' + sErrAux;
                        bTrazaOk = false;

                        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output oAux = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output();
                        oAux.sCodError = sCodErr;
                        oAux.sDetalleError = sDetErr;
                        oAux.sNumCaso = '';
                        oRes.add(oAux);

                        if (oTraza != null){
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Inicio_Hidden_DET', oNewCase[i].CC_Id_Cognitivo__c, sTrazaOrig, oNewCase[i], oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
            }
            
            // Insertamos las actividades de Hidden
            if (!oNewTask.isEmpty()){
                Database.SaveResult[] oResTask = Database.insert(oNewTask, false);
            }
            
            // Buscar los registros insertados para devolver el número de caso.
            if (!oRefCasos.isEmpty()){
                List<ID> oCasosIdent = new List<ID>();
                List<Case> oCasosUp = [SELECT Id, CaseNumber, CC_Id_Cognitivo__c FROM Case WHERE CC_Id_Cognitivo__c IN :oRefCasos];
                for (Case oCasoAux : oCasosUp){
                    CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output oAux = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output();
                    oAux.sCodError = '0';
                    oAux.sDetalleError = '';
                    oAux.sNumCaso = oCasoAux.CaseNumber;
                    oAux.sCaseId = oCasoAux.Id;
                    oRes.add(oAux);

                    if (oTraza != null){
                        CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Inicio_Hidden_DET', oCasoAux.CC_Id_Cognitivo__c, sTrazaOrig, oCasoAux, oAux, true, '0', '');
                        oTraza.add(oTrazaDet);
                    }

                    // Asignar el caso para identificar el cliente.
                    oCasosIdent.add(oCasoAux.Id);
                }

                if (!oCasosIdent.isEmpty()){
                    // Identificación asíncrona y por lotes de los casos generados.
                    CC_IdentCliente_Future.identificarClientesAsync (oCasosIdent);
                }
            }
            
            // Actualizar trazas hijas.
            if (oTraza != null){
                if (!oTraza.isEmpty()){
                    Database.SaveResult[] oResUp = Database.insert(oTraza, false);
                }
            }
            
        } catch (Exception e) {

            // Trazar error.
            bTrazaOk = false;
            sErrGen = 'Error en la ejecución del proceso CC_WS_Inicio_Hidden. ' + e.getMessage();

            CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output oAux = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output();
            oAux.sCodError = '9999';
            oAux.sDetalleError = sErrGen;
            oAux.sNumCaso = '';
            oRes.add(oAux);
        }

        // Finalizar traza padre para obtener tiempos totales.
        String sErrProc = '';

        if (!bTrazaOk)
            sErrProc = 'Error procesando datos. Revisar detalle.';

        if (bNoDatos)
            sErrProc = 'No se han enviado datos para procesar.';

        oTrazaProc = cerrarTrazaPadre (oConfig, oTrazaProc, oRes, bTrazaOk, sErrProc, sErrGen);

        return oRes;        
    }
*/
}