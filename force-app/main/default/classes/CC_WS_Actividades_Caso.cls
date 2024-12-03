@RestResource(urlMapping='/oacoficinaLisAct/*')
global with sharing class CC_WS_Actividades_Caso {
	/*
        Clase para publicar un servicio Rest de consulta de Actividades de un Caso para OAC.
    */

    /*
        Clase para los parámetros de entrada.
    */
    global class CC_WS_Actividades_Caso_Input {
        global String numSR {get;set;}
    }

    /*
        Clase para el listado de actividades del caso.
    */
    global class CC_WS_Actividades_Output {
        global String fechaApertura {get;set;}
        global String tipo {get;set;}
        global String emailBody {get;set;}
    }
    
    /*
        Clase genérica para los parámetros de salida.
    */
    global class CC_WS_Actividades_Caso_Output {
        global String resultado {get;set;}
        global String descripcion {get;set;}
        global List<CC_WS_Actividades_Output> ListaActividades {get;set;}
    }
    
    /*
        Método para validar los inputs obligatorios.
    */
    private static String validarDatosEntrada (CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Input oDatos){
        if (oDatos != null){
            if (oDatos.numSR == null){
                return 'KO';
            }else if (oDatos.numSR.trim() == '') {
                return 'KO';
            }
        }

        return 'OK';
    }
    
    /*
        Método para preparar la búsqueda de casos con los criterios de entrada.
    */
    private static Map<String,Object> prepararCaso (CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Input oForm){
        Map<String,Object> oRes = new Map<String,Object>();
		List<Task> oListAct = new List<Task>();
		Id idcaso = null;
        
        try {
            
            if (oForm != null){
                // Busqueda base de los datos del objeto caso.
                List<Case> oCaso = [SELECT Id FROM Case WHERE CaseNumber = :oForm.numSR LIMIT 1];
				// Busqueda de Actividades del caso "Task"
                if (!oCaso.isEmpty()){
                    for (Case oCasoAct : oCaso){
                        idcaso = oCasoAct.Id;
                    }
                	oListAct = [SELECT Id, CreatedDate, Type, Description FROM Task WHERE WhatId = :idcaso];    
                }
								
                if (!oListAct.isEmpty()){
					oRes.put('Estado', 'OK');
                    oRes.put('Detalle', '');
                    oRes.put('Actividad', oListAct); 
                } else {
					oRes.put('Estado', 'KO');
                	oRes.put('Detalle', 'No hay actividades para la búsqueda especificada.');
                	oRes.put('Actividad', null);
                }
                

            }else{
                // Sin datos.
                oRes.put('Estado', 'KO');
                oRes.put('Detalle', 'No hay datos para realizar la búsqueda.');
                oRes.put('Actividad', null);    
            }

        } catch (Exception e) {
            // Error tratando el caso.
            oRes.put('Estado', 'KO');
            oRes.put('Detalle', 'Error procesado. ' + e.getMessage());
            oRes.put('Actividad', null);  
        }

        return oRes;
    }
    
    /*
        Método para crear la traza padre del proceso. Medir tiempos totales.
    */
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
    
    /*
        Método para cerrar la traza padre del proceso. Medir tiempos totales.
    */
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
    
    /*
        Método publicado para devolver el resultado de la busqueda de casos.
    */
    @HttpPost
    global static CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output searchActivity(List<CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Input> oDataIn){
        CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output oRes = new CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output();
        Map<String,CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Input> oMapForm = new Map<String,CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Input>();
        List<Task> oListTask = new List<Task>();
        List<CC_WS_Actividades_Output> oListActividades = new List<CC_WS_Actividades_Output>();

        // Lista de trazas a crear.
        CC_TrazaInt__c oTrazaProc;
        List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();
        CC_InterfaceSettings__mdt oConfig;
        Boolean bTrazaOk = true;
        Boolean bNoDatos = false;
        String sErrGen = '';

        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_WS_Actividades_Caso');
        } catch (Exception e) {
            oTraza = null;
        }

        if (oConfig == null){
            // Interfaz no configurada o activa.
            CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output oAux = new CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output();
            oAux.resultado = '9999';
            oAux.descripcion = 'Proceso inactivo en Salesforce.';
            oAux.ListaActividades = null;
            oRes = oAux;
            return oRes;
        }

        // Creamos la traza padre para medir tiempos totales.
        oTrazaProc = crearTrazaPadre (oConfig, 'CC_WS_Actividades_Caso', 'CC_WS_Actividades_Caso', '', oDataIn);
        String sTrazaOrig = '';
        if (oTrazaProc != null)
            sTrazaOrig = oTrazaProc.Id;

        try {
            // Control de datos.
            if (oDataIn != null){
                for (CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Input oForm : oDataIn){
                    String sValido = validarDatosEntrada (oForm);
                    if (sValido == 'OK'){
                        // Validados los datos realizamos las acciones necesarias
                        oMapForm.put(oForm.numSR, oForm);
                    }else{
                    	// Error validación datos entrada.
                        String sCodErr = '1';
                        String sDetErr = 'Datos obligatorios no informados.';
                        bTrazaOk = false;

                        CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output oAux = new CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output();
                        oAux.resultado = sCodErr;
                        oAux.descripcion = sDetErr;
                        oAux.ListaActividades = null;
                        oRes = oAux;
						
                        String sIdent = '';
                        sIdent = sTrazaOrig;

                        if (oTraza != null){
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Actividades_Caso_DET', sIdent, sTrazaOrig, oForm, oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
            }else{
                // No hay datos de entrada.
                bTrazaOk = false;
                bNoDatos = true;
            }

            // Preparar la busqueda de las actividades del caso.
            if (!oMapForm.isEmpty()){
                // Procesar los criterios de entrada.
                for (String sForm : oMapForm.keySet()){
                    if (oMapForm.get(sForm) != null){
                        String sEstado = '';
                        String sDetalle = '';

                        Map<String,Object> oResTask = prepararCaso (oMapForm.get(sForm));
                        for (String sRet : oResTask.keySet()){
                            if (sRet == 'Estado'){
                                if (oResTask.get(sRet) != null){
                                    sEstado = (String)oResTask.get(sRet);
                                }
                            }

                            if (sRet == 'Detalle'){
                                if (oResTask.get(sRet) != null){
                                    sDetalle = (String)oResTask.get(sRet);
                                }
                            }

                            if (sRet == 'Actividad'){
                                if (oResTask.get(sRet) != null){
                                    oListTask = (List<Task>)oResTask.get(sRet);
                                }
                            }
                        }

                        if (sEstado == 'OK'){
                            if (oListTask != null){
                                for(Task oBusActOAC : oListTask){
                                    CC_WS_Actividades_Output oActOAC = new CC_WS_Actividades_Output();
                                    oActOAC.fechaApertura = String.valueOf(oBusActOAC.CreatedDate);
                                    oActOAC.tipo = oBusActOAC.Type;
                                    oActOAC.emailBody = oBusActOAC.Description;
                                    oListActividades.add(oActOAC);
                                }
                            }else{
                                // Error al preparar el caso.
                                String sCodErr = '2';
                                String sDetErr = 'Error al preparar los datos. ' + sDetalle;
                                bTrazaOk = false;

                                CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output oAux = new CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output();
                                oAux.resultado = sCodErr;
                                oAux.descripcion = sDetErr;
                                oAux.ListaActividades = null;
                                oRes = oAux;

                                if (oTraza != null){
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Actividades_Caso_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }
                            }
                        }else{
                            // Error al preparar el caso.
                            String sCodErr = '3';
                            String sDetErr = 'Error al preparar los datos. ' + sDetalle;
                            bTrazaOk = false;

                            CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output oAux = new CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output();
                            oAux.resultado = sCodErr;
                            oAux.descripcion = sDetErr;
                            oAux.ListaActividades = null;
                            oRes = oAux;

                            if (oTraza != null){
                                CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Actividades_Caso_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                oTraza.add(oTrazaDet);
                            }
                        }
                    }
                }              
            }
            
            // Return de los casos encontrados.
            if (!oListActividades.isEmpty()){
                CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output oAux = new CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output();
                oAux.resultado = 'OK';
                oAux.descripcion = 'Búsqueda realizada.';
                oAux.ListaActividades = oListActividades;
                oRes = oAux;
                
                if (oTraza != null){
                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Actividades_Caso_DET', null, sTrazaOrig, oListActividades, oAux, true, '0', '');
                    oTraza.add(oTrazaDet);
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
            sErrGen = 'Error en la ejecución del proceso CC_WS_Actividades_Caso. ' + e.getMessage();

            CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output oAux = new CC_WS_Actividades_Caso.CC_WS_Actividades_Caso_Output();
            oAux.resultado = '9999';
            oAux.descripcion = sErrGen;
            oAux.ListaActividades = null;
            oRes = oAux;
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
}