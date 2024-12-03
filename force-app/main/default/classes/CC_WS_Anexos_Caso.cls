@RestResource(urlMapping='/oacoficinaLisDig/*')
global with sharing class CC_WS_Anexos_Caso {
	/*
        Clase para publicar un servicio Rest de consulta de Anexos de un Casos para OAC.
    */

    /*
        Clase para los parámetros de entrada.
    */
    global class CC_WS_Anexos_Caso_Input {
        global String NumSR {get;set;}
    }

    /*
        Clase para el listado de anexos del caso.
    */
    global class CC_WS_Anexos_Output {
        global String id {get;set;}
        global String tipo {get;set;}
        global String nombre {get;set;}
        global String url {get;set;}
    }
    
    /*
        Clase genérica para los parámetros de salida.
    */
    global class CC_WS_Anexos_Caso_Output {
        global String resultado {get;set;}
        global String descripcion {get;set;}
        global List<CC_WS_Anexos_Output> ListaAnexos {get;set;}
    }
    
    /*
        Método para validar los inputs obligatorios.
    */
    private static String validarDatosEntrada (CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Input oDatos){
        if (oDatos != null){
            if (oDatos.NumSR == null){
                return 'KO';
            }else if (oDatos.NumSR.trim() == '') {
                return 'KO';
            }
        }

        return 'OK';
    }
    
    /*
        Método para preparar la búsqueda de los anexos del caso con los criterios de entrada.
    */
    private static Map<String,Object> prepararCaso (CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Input oForm){
        Map<String,Object> oRes = new Map<String,Object>();
        List<ContentDocument> oListDoc = new List<ContentDocument>();
        List<Id> oListCaseId = new List<Id>();
        List<Id> oListLinkId = new List<Id>();

        try {
            
            if (oForm != null){
                // Busqueda base de los datos del objeto caso.              
                List<Case> oListCaso = [SELECT Id FROM CASE WHERE CaseNumber = :oForm.numSR];
                if (!oListCaso.isEmpty()){
					for (Case oIdCasos : oListCaso){
						oListCaseId.add(oIdCasos.Id);
					}
                    // Sacar los ContentDocumentLink de los anexos a partir del id del caso
               		List<ContentDocumentLink> oListDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                              FROM ContentDocumentLink WHERE LinkedEntityId IN: oListCaseId];

                    if (!oListDocLink.isEmpty()){
                        for (ContentDocumentLink oIdLink : oListDocLink){
                            oListLinkId.add(oIdLink.ContentDocumentId);
                        }
                        // Sacar información de los anexos a partir de los Ids del contentdocumentlink
                        oListDoc = [SELECT Id, OwnerId, Title, Description, ContentSize, FileType, FileExtension, ContentAssetId 
                                    FROM ContentDocument WHERE Id IN :oListLinkId];
                    }
                }

				// Pasamos los datos de los anexos del caso
                if (!oListDoc.isEmpty()){
					oRes.put('Estado', 'OK');
                    oRes.put('Detalle', '');
                    oRes.put('Anexos', oListDoc); 
                } else {
					oRes.put('Estado', 'KO');
                	oRes.put('Detalle', 'No hay anexos para la búsqueda especificada.');
                	oRes.put('Anexos', null);
                }
            }else{
                // Sin datos.
                oRes.put('Estado', 'KO');
                oRes.put('Detalle', 'No hay datos para realizar la búsqueda.');
                oRes.put('Anexos', null);    
            }

        } catch (Exception e) {
            // Error tratando el caso.
            oRes.put('Estado', 'KO');
            oRes.put('Detalle', 'Error procesado. ' + e.getMessage());
            oRes.put('Anexos', null);  
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
        Método publicado para devolver el resultado de la busqueda de anexos del casos.
    */
    @HttpPost
    global static CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output searchAttach(List<CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Input> oDataIn){
        CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output oRes = new CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output();
        Map<String,CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Input> oMapForm = new Map<String,CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Input>();
        List<ContentDocument> oListAnexo = new List<ContentDocument>();
		List<CC_WS_Anexos_Output> oListAttCase = new List<CC_WS_Anexos_Output>();
        
        // Lista de trazas a crear.
        CC_TrazaInt__c oTrazaProc;
        List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();
        CC_InterfaceSettings__mdt oConfig;
        Boolean bTrazaOk = true;
        Boolean bNoDatos = false;
        String sErrGen = '';

        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_WS_Anexos_Caso');
        } catch (Exception e) {
            oTraza = null;
        }

        if (oConfig == null){
            // Interfaz no configurada o activa.
            CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output oAux = new CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output();
            oAux.resultado = '9999';
            oAux.descripcion = 'Proceso inactivo en Salesforce.';
            oAux.ListaAnexos = null;
            oRes = oAux;
            return oRes;
        }

        // Creamos la traza padre para medir tiempos totales.
        oTrazaProc = crearTrazaPadre (oConfig, 'CC_WS_Anexos_Caso', 'CC_WS_Anexos_Caso', '', oDataIn);
        String sTrazaOrig = '';
        if (oTrazaProc != null)
            sTrazaOrig = oTrazaProc.Id;

        try {
            // Control de datos.
            if (oDataIn != null){
                for (CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Input oForm : oDataIn){
                    String sValido = validarDatosEntrada (oForm);
                    if (sValido == 'OK'){
                        // Validados los datos realizamos las acciones necesarias
                        oMapForm.put(oForm.NumSR, oForm);
                    }else{
                    	// Error validación datos entrada.
                        String sCodErr = '1';
                        String sDetErr = 'Datos obligatorios no informados.';
                        bTrazaOk = false;

                        CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output oAux = new CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output();
                        oAux.resultado = sCodErr;
                        oAux.descripcion = sDetErr;
                        oAux.ListaAnexos = null;
                        oRes = oAux;
						
                        String sIdent = '';
                        sIdent = sTrazaOrig;

                        if (oTraza != null){
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Anexos_Caso_DET', sIdent, sTrazaOrig, oForm, oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
            }else{
                // No hay datos de entrada.
                bTrazaOk = false;
                bNoDatos = true;
            }

            // Preparar la busqueda de los anexos del caso.
            if (!oMapForm.isEmpty()){
                // Procesar los criterios de entrada.
                for (String sForm : oMapForm.keySet()){
                    if (oMapForm.get(sForm) != null){
                        String sEstado = '';
                        String sDetalle = '';

                        Map<String,Object> oResCaso = prepararCaso (oMapForm.get(sForm));
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

                            if (sRet == 'Anexos'){
                                if (oResCaso.get(sRet) != null){
                                    oListAnexo = (List<ContentDocument>)oResCaso.get(sRet);
                                }
                            }
                        }

                        if (sEstado == 'OK'){
                            if (oListAnexo != null){
                                for(ContentDocument oBusAnexos : oListAnexo){
                                    CC_WS_Anexos_Output oAttachOAC = new CC_WS_Anexos_Output();
                                    String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + oBusAnexos.id;
                                    oAttachOAC.id = String.valueOf(oBusAnexos.Id);
                                    oAttachOAC.tipo = oBusAnexos.FileType;
                                    oAttachOAC.nombre = oBusAnexos.Title;
                                    oAttachOAC.url = fullFileURL;
                                    oListAttCase.add(oAttachOAC);
                                }
                            }else{
                                // Error al preparar el caso.
                                String sCodErr = '2';
                                String sDetErr = 'Error al preparar los datos. ' + sDetalle;
                                bTrazaOk = false;

                                CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output oAux = new CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output();
                                oAux.resultado = sCodErr;
                                oAux.descripcion = sDetErr;
                                oAux.ListaAnexos = null;
                                oRes = oAux;

                                if (oTraza != null){
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Anexos_Caso_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }
                            }
                        }else{
                            // Error al preparar el caso.
                            String sCodErr = '3';
                            String sDetErr = 'Error al preparar los datos. ' + sDetalle;
                            bTrazaOk = false;

                            CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output oAux = new CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output();
                            oAux.resultado = sCodErr;
                            oAux.descripcion = sDetErr;
                            oAux.ListaAnexos = null;
                            oRes = oAux;

                            if (oTraza != null){
                                CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Anexos_Caso_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                oTraza.add(oTrazaDet);
                            }
                        }
                    }
                }              
            }
            
            // Return de los anexos del casos encontrados.
            if (!oListAttCase.isEmpty()){
                CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output oAux = new CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output();
                oAux.resultado = 'OK';
                oAux.descripcion = 'Búsqueda realizada.';
                oAux.ListaAnexos = oListAttCase;
                oRes = oAux;
                
                if (oTraza != null){
                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Anexos_Caso_DET', null, sTrazaOrig, oListAttCase, oAux, true, '0', '');
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
            sErrGen = 'Error en la ejecución del proceso CC_WS_Anexos_Caso. ' + e.getMessage();

            CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output oAux = new CC_WS_Anexos_Caso.CC_WS_Anexos_Caso_Output();
            oAux.resultado = '9999';
            oAux.descripcion = sErrGen;
            oAux.ListaAnexos = null; 
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