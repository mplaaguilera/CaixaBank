@RestResource(urlMapping='/Fin_Hidden/*')
global with sharing class CC_WS_Fin_Hidden {
/*
	//Clase para publicar un servicio Rest para la el fin del chat Hidden.
    
    //Clase para los parámetros de entrada.
    global class CC_WS_Fin_Hidden_Input {

        global String id_Cognitive {get;set;}
        global String accionHidden {get;set;}
        global String Nickname {get;set;}
        //sessionId para LiveChatVisitor ¿?
        global String TranscriptConversation {get;set;}
    }

    //Clase para los parámetros de salida.
    global class CC_WS_Fin_Hidden_Output {
        global String sCodError {get;set;}
        global String sDetalleError {get;set;}
        global String sNumCaso {get;set;}
        global String sCaseId {get;set;}        
    }
    
    //Método para validar los inputs.
    private static String validarDatosEntrada (CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input oDatos){
        if (oDatos != null){
            //if (oDatos.TranscriptConversation == null){
            //    return 'KO';
            //}else if (oDatos.TranscriptConversation.trim() == '') {
            //    return 'KO';
            //}
            
            if (oDatos.id_Cognitive == null){
                return 'KO';
            }else if (oDatos.id_Cognitive.trim() == '') {
                return 'KO';
            }
            
            if (oDatos.accionHidden == null){
                return 'KO';
            }else if (oDatos.accionHidden.trim() == '') {
                return 'KO';
            }
            
            if (oDatos.Nickname == null){
                return 'KO';
            }else if (oDatos.Nickname.trim() == '') {
                return 'KO';
            }
            
        }

        return 'OK';
    }
    
    //Método para crear la traza padre del proceso. Medir tiempos totales.
    private static CC_TrazaInt__c crearTrazaPadre (CC_InterfaceSettings__mdt oConfig, String sInterfaz, String sIdentificador, String sIdOrig, Object oEntrada)
    {
        CC_TrazaInt__c oTraza;

        if (oConfig != null)
        {
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
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
    private static CC_TrazaInt__c cerrarTrazaPadre (CC_InterfaceSettings__mdt oConfig, CC_TrazaInt__c oTraza, Object oSalida, Boolean bOk, String sTipoError, String sDetalleError)
    {
        if (oConfig != null && oTraza != null)
        {
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
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

    private static CC_TrazaInt__c crearTrazaDetalle (CC_InterfaceSettings__mdt oConfig, String sInterfaz, String sIdentificador, String sIdOrig, Object oEntrada, Object oSalida, Boolean bOk, String sTipoError, String sDetalleError)
    {
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();

        if (oConfig != null)
        {
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
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
    
    //Método publicado para crear el LiveChatTranscript de la transcripción del Chat Hidden.
    private static LiveChatTranscript createLiveChatTranscript(Id caseId, String transcript, String idCognitive, String idioma, String accion, String nickname) {
    	ID sRTEmpleado = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript();
        liveChatTranscript.CC_Idioma__c = idioma;
        liveChatTranscript.RecordTypeId = sRTEmpleado;
        liveChatTranscript.CC_Subject__c = accion;
        liveChatTranscript.Status = 'Completed';
        liveChatTranscript.CC_Tipo__c = 'Chatbot';
        liveChatTranscript.CC_Cognitive_chat__c = transcript;
        liveChatTranscript.CC_Nickname__c  = nickname;
		liveChatTranscript.CC_Id_Cognitive__c= idCognitive;
        liveChatTranscript.CaseId = caseId;
        //Miramos si ya existe el LiveChatTranscript        
        List<LiveChatTranscript> oTranscriptExiste = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = :idCognitive];
        if (oTranscriptExiste.isEmpty()){
            //TODO: Provisional, ver solución final; Creamos LiveChatVisitor sin session key para crear el LiveChatTranscript
            LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
            insert liveChatVisitor;
            //En caso de no existir se informa el chatvisitorId
            liveChatTranscript.LiveChatVisitorId = liveChatVisitor.Id;
        }

        return liveChatTranscript;
    }
    
    //Método publicado para actualizar la actividad de Chat Hidden.
    private static Task updateActivity(String idCognitive, String Accion, Id chattranscriptId) {
        Task task = [SELECT Id, WhatId, CC_Chat_Cognitivo_Id__c, Status, Description, CC_LiveChatTranscript_Id__c 
                     FROM Task WHERE CC_Chat_Cognitivo_Id__c = :idCognitive AND Status = 'Open' 
                     AND Subject = 'Conversación ChatBot - Hidden' LIMIT 1];
        task.Status = 'Completed';
        task.Description = task.Description + ' ' + Accion;
        task.CC_LiveChatTranscript_Id__c = chattranscriptId;
        
        return task;
    }
    
    //Método publicado para actualizar la transcripción en formato HTML
    private static LiveChatTranscript updateTranscript(Id idChatTrans, String chatTranscript, String Id_Cognitive, String nickname) {
        CC_Cognitive_Chat_JSON json = CC_Cognitive_Chat_JSON.parse(chatTranscript);
        
        LiveChatTranscript oLchatTrans = new LiveChatTranscript();
        oLchatTrans.Id = idChatTrans;
        oLchatTrans.CC_Id_Cognitive__c = Id_Cognitive;
        oLchatTrans.Body = json.getChatHTML('['+nickname+']');
        
        return oLchatTrans;
    }
    
    //Método para preparar la actualización/cierre del caso.
    private static Map<String,Object> prepararCaso (CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input oForm){
        Map<String,Object> oRes = new Map<String,Object>();

        try {
            
            if (oForm != null){
				Case oCasoBusqueda = [SELECT Id, CC_Id_Cognitivo__c, CC_Idioma__c, Subject
                                     FROM Case WHERE CC_Id_Cognitivo__c = :oForm.id_Cognitive.trim().unescapeHtml4() LIMIT 1];
                
                LiveChatTranscript oTranscipt = createLiveChatTranscript(oCasoBusqueda.Id, oForm.TranscriptConversation, oCasoBusqueda.CC_Id_Cognitivo__c, oCasoBusqueda.CC_Idioma__c, oForm.accionHidden, oForm.Nickname);
                
                oRes.put('Estado', 'OK');
                oRes.put('Detalle', '');
                oRes.put('Transcript', oTranscipt);

            }else{
                // Sin datos.
                oRes.put('Estado', 'KO');
                oRes.put('Detalle', 'No hay datos de chat Hidden.');
                oRes.put('Transcript', null);
            }

        } catch (Exception e) {
            // Error tratando el caso.
            oRes.put('Estado', 'KO');
            oRes.put('Detalle', 'Error procesado. ' + e.getMessage());
            oRes.put('Transcript', null);
        }

        return oRes;
    }
    
    @HttpPost
    global static List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output> closeCase(List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input> oDataIn){
        List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output> oRes = new List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output>();
        Map<String,CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input> oMapForm = new Map<String,CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input>();
        List<LiveChatTranscript> oNewTranscript = new List<LiveChatTranscript>();
        List<LiveChatTranscript> oUpdateTrans = new List<LiveChatTranscript>();
        List<Task> oNewTask = new List<Task>();
        Map<String,String> oMapRules = new Map<String,String>();
               
        // Lista de trazas a crear.
        CC_TrazaInt__c oTrazaProc;
        List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();
        CC_InterfaceSettings__mdt oConfig;
        Boolean bTrazaOk = true;
        Boolean bNoDatos = false;
        String sErrGen = '';

        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_WS_Fin_Hidden');
        } catch (Exception e) {
            oTraza = null;
        }

        if (oConfig == null){
            // Interfaz no configurada o activa.
            CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output oAux = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output();
            oAux.sCodError = '9999';
            oAux.sDetalleError = 'Proceso inactivo en Salesforce.';
            oAux.sNumCaso = '';
            oRes.add(oAux);
            return oRes;
        }

        // Creamos la traza padre para medir tiempos totales.
        oTrazaProc = crearTrazaPadre (oConfig, 'CC_WS_Fin_Hidden', 'CC_WS_Fin_Hidden', '', oDataIn);
        String sTrazaOrig = '';
        if (oTrazaProc != null)
            sTrazaOrig = oTrazaProc.Id;

        try {

            // Control de datos.
            if (oDataIn != null){
                for (CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input oForm : oDataIn){
                    String sValido = validarDatosEntrada (oForm);
                    if (sValido == 'OK'){
                        // Registro para a crear datos.
                        oMapForm.put(oForm.id_Cognitive.trim().unescapeHtml4(), oForm);
                    }else{
                    	// Error validación datos entrada.
                        String sCodErr = '1';
                        String sDetErr = 'Datos obligatorios no informados.';
                        bTrazaOk = false;

                        CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output oAux = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output();
                        oAux.sCodError = sCodErr;
                        oAux.sDetalleError = sDetErr;
                        oAux.sNumCaso = '';
                        oRes.add(oAux);
						
                        String sIdent = '';
                        sIdent = sTrazaOrig;

                        if (oTraza != null){
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Fin_Hidden_DET', sIdent, sTrazaOrig, oForm, oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
            }else{
                // No hay datos de entrada.
                bTrazaOk = false;
                bNoDatos = true;
            }
			
            // Preparar creación LiveChatTranscript.
            if (!oMapForm.isEmpty()){
                for (String sForm : oMapForm.keySet()){
                    if (oMapForm.get(sForm) != null){
                        String sEstado = '';
                        String sDetalle = '';
                        LiveChatTranscript oTranscript;

                        Map<String,Object> oResTrans = prepararCaso (oMapForm.get(sForm));
                        for (String sRet : oResTrans.keySet()){
                            if (sRet == 'Estado'){
                                if (oResTrans.get(sRet) != null){
                                    sEstado = (String)oResTrans.get(sRet);
                                }
                            }

                            if (sRet == 'Detalle'){
                                if (oResTrans.get(sRet) != null){
                                    sDetalle = (String)oResTrans.get(sRet);
                                }
                            }
                            
                            if (sRet == 'Transcript'){
                                if (oResTrans.get(sRet) != null){
                                    oTranscript = (LiveChatTranscript)oResTrans.get(sRet);
                                }
                            }
                        }

                        if (sEstado == 'OK'){
                            if (oTranscript != null){
                                oNewTranscript.add(oTranscript);
                            } else {
                                // Error al preparar la transcripcion.
                                String sCodErr = '2';
                                String sDetErr = 'Error al preparar la transcripción. ' + sDetalle;
                                bTrazaOk = false;

                                CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output oAux = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output();
                                oAux.sCodError = sCodErr;
                                oAux.sDetalleError = sDetErr;
                                oAux.sNumCaso = '';
                                oRes.add(oAux);

                                if (oTraza != null){
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Fin_Hidden_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }
                            }
                        }else{
                            // Error al preparar la transcripcion.
                            String sCodErr = '3';
                            String sDetErr = 'Error al preparar la transcripción. ' + sDetalle;
                            bTrazaOk = false;

                            CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output oAux = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output();
                            oAux.sCodError = sCodErr;
                            oAux.sDetalleError = sDetErr;
                            oAux.sNumCaso = '';
                            oRes.add(oAux);

                            if (oTraza != null){
                                CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Fin_Hidden_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                oTraza.add(oTrazaDet);
                            }
                        }
                    }
                } 
            }
            
            // Realizar el upsert del LiveChatTranscript
            List<String> oRefTranscript = new List<String>();

            if (!oNewTranscript.isEmpty()){
                Schema.SObjectField oCampoSearch = LiveChatTranscript.Fields.CC_Id_Cognitive__c;
                Database.UpsertResult[] oResUp = Database.upsert(oNewTranscript, oCampoSearch, false);

                for (Integer i = 0, iSize = oResUp.size(); i < iSize; i++){
                    if (oResUp[i].isSuccess()){
                        // Inserción correcta.
                        oRefTranscript.add(oNewTranscript[i].CC_Id_Cognitive__c);
						//Update Actividad Hidden
						Task oTask = updateActivity(oNewTranscript[i].CC_Id_Cognitive__c, oNewTranscript[i].CC_Subject__c, oNewTranscript[i].Id);
						oNewTask.add(oTask);
                        //Parse del JSON y Update del Transcript
                        LiveChatTranscript LchatTrans = updateTranscript(oNewTranscript[i].Id, oNewTranscript[i].CC_Cognitive_chat__c, oNewTranscript[i].CC_Id_Cognitive__c, oNewTranscript[i].CC_Nickname__c);
                        oUpdateTrans.add(LchatTrans);
                    }else{
                        // Error. Trazar.
                        String sErrAux = '';
                        for(Database.Error err : oResUp[i].getErrors()) {
                            if (sErrAux != '')
                                sErrAux = sErrAux + '. ';
                            sErrAux = sErrAux + err.getMessage();
                        }

                        String sCodErr = '4';
                        String sDetErr = 'Error al crear la transcripción. ' + sErrAux;
                        bTrazaOk = false;

                        CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output oAux = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output();
                        oAux.sCodError = sCodErr;
                        oAux.sDetalleError = sDetErr;
                        oAux.sNumCaso = '';
                        oRes.add(oAux);

                        if (oTraza != null){
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Fin_Hidden_DET', oNewTranscript[i].CC_Id_Cognitive__c, sTrazaOrig, oNewTranscript[i], oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
            }
			
            // Actualizamos las actividades de Hidden
            if (!oNewTask.isEmpty()){
                Database.SaveResult[] oResTask = Database.update(oNewTask, false);
            }
            
            //Actualizamos el transcript con el body parseado
            if (!oUpdateTrans.isEmpty()){
                //Schema.SObjectField oTransSearch = LiveChatTranscript.Fields.CC_Id_Cognitive__c;
                Database.SaveResult[] oResUpdateParse = Database.update(oUpdateTrans, false);
            }
            
            // Buscar los registros insertados para devolver el número de caso.
            if (!oRefTranscript.isEmpty()){
                List<LiveChatTranscript> oTransUp = [SELECT Id, CaseId, Case.CaseNumber, CC_Id_Cognitive__c 
                                                     FROM LiveChatTranscript WHERE CC_Id_Cognitive__c IN :oRefTranscript];
                for (LiveChatTranscript oTransAux : oTransUp){
                    CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output oAux = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output();
                    oAux.sCodError = '0';
                    oAux.sDetalleError = '';
                    oAux.sNumCaso = oTransAux.Case.CaseNumber;
                    oAux.sCaseId = oTransAux.CaseId;
                    oRes.add(oAux);

                    if (oTraza != null){
                        CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_CreaCasos_Hidden_DET', oTransAux.CC_Id_Cognitive__c, sTrazaOrig, oTransAux, oAux, true, '0', '');
                        oTraza.add(oTrazaDet);
                    }
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
            sErrGen = 'Error en la ejecución del proceso CC_WS_Fin_Hidden. ' + e.getMessage();

            CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output oAux = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output();
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