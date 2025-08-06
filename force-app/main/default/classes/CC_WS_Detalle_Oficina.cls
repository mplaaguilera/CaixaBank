@RestResource(urlMapping='/oacoficinaDetall/*')
global with sharing class CC_WS_Detalle_Oficina {
	/*
        Clase para publicar un servicio Rest de consulta del detalle del Casos de una oficina.
    */

    /*
        Clase para los parámetros de entrada.
    */
    global class CC_WS_Detalle_Oficina_Input {
        global String numSR {get;set;}
    }

    /*
        Clase para el detalle del caso de salida.
    */
    global class CC_WS_DetalleCaso_Output {
        global String numeroSR {get;set;}
        global String estadoSR {get;set;}
        global String descripcion {get;set;}
		global String nifCuenta {get;set;}
        global String nombreCuenta {get;set;}
        global String nifCliente {get;set;}
        global String nombreCliente {get;set;}
        global String apellido1Cliente {get;set;}
        global String apellido2Cliente {get;set;}
        global String telefono {get;set;}
        global String email {get;set;}
        global String tematica {get;set;}
        global String servicioProducto {get;set;}
        global String motivo {get;set;}
        global String canalEntrada {get;set;}
        global String procedencia {get;set;}
        global String oficinaGestora {get;set;}
        global String oficinaSR {get;set;}
        global String diagnostico {get;set;}
        global String tipoResolucion {get;set;}
        global String fecha {get;set;}
        global String tipoSolicitud {get;set;}
        global String fechaEntrada {get;set;}
        global String dan {get;set;}
        global String dt {get;set;}
        global String importeSolicitud {get;set;}
        global String importeAbonado {get;set;}
        global String detalleResolucion {get;set;}
    }
    
    /*
        Clase genérica para los parámetros de salida.
    */
    global class CC_WS_Detalle_Oficina_Output {
        global String resultado {get;set;}
        global String descripcion {get;set;}
        global CC_WS_DetalleCaso_Output DetalleCaso {get;set;}
    }
    
    /*
        Método para validar los inputs obligatorios.
    */
    private static String validarDatosEntrada (CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input oDatos){
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
    private static Map<String,Object> prepararCaso (CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input oForm){
        Map<String,Object> oRes = new Map<String,Object>();
		String Ofi1N;
        String Ofi2N;
        String OfiDT1N;
        String OfiDT2N;
		String sDAN;
        String sDT;
        List<Account> oListCentroSup = new List<Account>();
        List<Account> oListCentroSupDT = new List<Account>();
        
        try {
            
            if (oForm != null){
                // Busqueda base de los datos del objeto caso.
                List<Case> oListCaso = [SELECT Id, CaseNumber, Status, Description, Account.CC_Numero_Documento__c, Account.Name, CC_Importe_Abonado__c,
                    					Contact.CC_Numero_Documento__c, Contact.FirstName, Contact.LastName, Account.Phone, Account.CC_Email__c,
                    					CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, Origin, CC_Canal_Procedencia__c,
                    					Account.CC_Numero_Oficina__c, CC_Oficina_Afectada_Lookup__r.CC_Numero_Oficina__c, CC_Detalles_Solucion__c, CC_Tipo_Contacto__c, 
                    					CreatedDate, CC_Detalles_Consulta__c, Contact.CC_OficinaGestoraId__r.CC_Numero_Oficina__c, CC_Importe_Reclamado__c 
                                        FROM CASE WHERE CaseNumber = :oForm.numSR LIMIT 1];
				
                //Buscamos la DAN y DT del caso que se quiere devolver datos
                if (!oListCaso.isEmpty()){
                    // Busqueda base de los datos del objeto caso.
                    String oficina;
                    for (Case oCasoOfi : oListCaso){
                        oficina = oCasoOfi.CC_Oficina_Afectada_Lookup__r.CC_Numero_Oficina__c;
                    }
                    // Realizar busqueda por oficina en Account para sacar su DAN y su DT.
                    List<Account> oAccOficina = [SELECT Id, CC_Tipo_Centro__c, CC_NumCentroSup_1Niv__c, CC_NumCentroSup_2Niv__c 
                                           FROM Account WHERE CC_Numero_Oficina__c =: oficina and CC_Tipo_Centro__c =: 'OF'];
                    if (!oAccOficina.isEmpty()){
                        for(Account oAccOf : oAccOficina){
                            Ofi1N = oAccOf.CC_NumCentroSup_1Niv__c;
                            Ofi2N = oAccOf.CC_NumCentroSup_2Niv__c;
                        }
                        //Miramos que se informen los diferentes niveles de oficina superior
                        if (Ofi1N != null){
                            if (Ofi2N != null){
                                oListCentroSup = [SELECT Id, CC_Tipo_Centro__c, CC_NumCentroSup_1Niv__c, CC_NumCentroSup_2Niv__c, CC_Numero_Oficina__c 
                                                  FROM Account WHERE CC_Numero_Empresa__c = :'001'
                                                  AND (CC_Numero_Oficina__c = :Ofi1N OR CC_Numero_Oficina__c = :Ofi2N)];
                            } else{
                                oListCentroSup = [SELECT Id, CC_Tipo_Centro__c, CC_NumCentroSup_1Niv__c, CC_NumCentroSup_2Niv__c, CC_Numero_Oficina__c 
                                                  FROM Account WHERE CC_Numero_Empresa__c = :'001'
                                                  AND CC_Numero_Oficina__c = :Ofi1N];
                            }	
                        } else {
                            if (Ofi2N != null){
                                oListCentroSup = [SELECT Id, CC_Tipo_Centro__c, CC_NumCentroSup_1Niv__c, CC_NumCentroSup_2Niv__c, CC_Numero_Oficina__c 
                                                  FROM Account WHERE CC_Numero_Empresa__c = :'001'
                                                  AND CC_Numero_Oficina__c = :Ofi2N];
                            }
                        }
    
                        if (!oListCentroSup.isEmpty()){
                            for(Account oAcc : oListCentroSup){
                                if (oAcc.CC_Tipo_Centro__c == 'GC'){
                                    sDAN = oAcc.CC_Numero_Oficina__c;
                                } else if (oAcc.CC_Tipo_Centro__c == 'DT'){
                                    sDT = oAcc.CC_Numero_Oficina__c;
                                } else {
                                    OfiDT1N = oAcc.CC_NumCentroSup_1Niv__c;
                                    OfiDT2N = oAcc.CC_NumCentroSup_2Niv__c;
                                }
                            }
                        }
                    }
                    //Si no tenemos DAN ni DT buscamos otro nivel más para encontrarlo
                    if (OfiDT1N != null){
                        if (OfiDT2N != null){
                            oListCentroSupDT = [SELECT Id, CC_Tipo_Centro__c, CC_NumCentroSup_1Niv__c, CC_NumCentroSup_2Niv__c, CC_Numero_Oficina__c 
                                              FROM Account WHERE CC_Numero_Empresa__c = :'001'
                                              AND (CC_Numero_Oficina__c = :OfiDT1N OR CC_Numero_Oficina__c = :OfiDT2N)];
                        } else{
                            oListCentroSupDT = [SELECT Id, CC_Tipo_Centro__c, CC_NumCentroSup_1Niv__c, CC_NumCentroSup_2Niv__c, CC_Numero_Oficina__c 
                                              FROM Account WHERE CC_Numero_Empresa__c = :'001'
                                              AND CC_Numero_Oficina__c = :OfiDT1N];
                        }	
                    } else {
                        if (OfiDT2N != null){
                            oListCentroSupDT = [SELECT Id, CC_Tipo_Centro__c, CC_NumCentroSup_1Niv__c, CC_NumCentroSup_2Niv__c, CC_Numero_Oficina__c 
                                              FROM Account WHERE CC_Numero_Empresa__c = :'001'
                                              AND CC_Numero_Oficina__c = :OfiDT2N];
                        }
                    }
                    
                    if (!oListCentroSupDT.isEmpty()){
                        for(Account oAccDT : oListCentroSupDT){
                            if (oAccDT.CC_Tipo_Centro__c == 'GC'){
                                sDAN = oAccDT.CC_Numero_Oficina__c;
                            } else if (oAccDT.CC_Tipo_Centro__c == 'DT'){
                                sDT = oAccDT.CC_Numero_Oficina__c;
                            }
                        }
                    }
                }
                
                if (!oListCaso.isEmpty()){
					oRes.put('Estado', 'OK');
                    oRes.put('Detalle', '');
					oRes.put('DAN', sDAN);
                    oRes.put('DT', sDT);
                    oRes.put('Caso', oListCaso); 
                } else {
					oRes.put('Estado', 'KO');
                	oRes.put('Detalle', 'No hay casos para la búsqueda especificada.');
                	oRes.put('Caso', null);
                }
            }else{
                // Sin datos.
                oRes.put('Estado', 'KO');
                oRes.put('Detalle', 'No hay datos para realizar la búsqueda.');
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
    global static CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output searchDetailCase(List<CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input> oDataIn){
        CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oRes = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output();
        Map<String,CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input> oMapForm = new Map<String,CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input>();
        List<Case> oListCasos = new List<Case>();
        CC_WS_DetalleCaso_Output oDetalleCasosOAC = new CC_WS_DetalleCaso_Output();

        // Lista de trazas a crear.
        CC_TrazaInt__c oTrazaProc;
        List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();
        CC_InterfaceSettings__mdt oConfig;
        Boolean bTrazaOk = true;
        Boolean bNoDatos = false;
        String sErrGen = '';

        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_WS_Detalle_Oficina');
        } catch (Exception e) {
            oTraza = null;
        }

        if (oConfig == null){
            // Interfaz no configurada o activa.
            CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oAux = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output();
            oAux.resultado = '9999';
            oAux.descripcion = 'Proceso inactivo en Salesforce.';
            oAux.DetalleCaso = null;
            oRes = oAux;
            return oRes;
        }

        // Creamos la traza padre para medir tiempos totales.
        oTrazaProc = crearTrazaPadre (oConfig, 'CC_WS_Detalle_Oficina', 'CC_WS_Detalle_Oficina', '', oDataIn);
        String sTrazaOrig = '';
        if (oTrazaProc != null)
            sTrazaOrig = oTrazaProc.Id;

        try {
            // Control de datos.
            if (oDataIn != null){
                for (CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input oForm : oDataIn){
                    String sValido = validarDatosEntrada (oForm);
                    if (sValido == 'OK'){
                        // Validados los datos realizamos las acciones necesarias
                        oMapForm.put(oForm.numSR, oForm);
                    }else{
                    	// Error validación datos entrada.
                        String sCodErr = '1';
                        String sDetErr = 'Datos obligatorios no informados.';
                        bTrazaOk = false;

                        CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oAux = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output();
                        oAux.resultado = sCodErr;
                        oAux.descripcion = sDetErr;
                        oAux.DetalleCaso = null;
                        oRes = oAux;
						
                        String sIdent = '';
                        sIdent = sTrazaOrig;

                        if (oTraza != null){
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Detalle_Oficina_DET', sIdent, sTrazaOrig, oForm, oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
            }else{
                // No hay datos de entrada.
                bTrazaOk = false;
                bNoDatos = true;
            }

            // Preparar la busqueda de los casos.
            if (!oMapForm.isEmpty()){
                // Procesar los criterios de entrada.
                for (String sForm : oMapForm.keySet()){
                    if (oMapForm.get(sForm) != null){
                        String sEstado = '';
                        String sDetalle = '';
                        String sDAN = '';
                        String sDT = '';

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
                            
                            if (sRet == 'DAN'){
                                if (oResCaso.get(sRet) != null){
                                    sDAN = (String)oResCaso.get(sRet);
                                }
                            }
                            
                            if (sRet == 'DT'){
                                if (oResCaso.get(sRet) != null){
                                    sDT = (String)oResCaso.get(sRet);
                                }
                            }

                            if (sRet == 'Caso'){
                                if (oResCaso.get(sRet) != null){
                                    oListCasos = (List<Case>)oResCaso.get(sRet);
                                }
                            }
                        }

                        if (sEstado == 'OK'){
                            if (oListCasos != null){
                                for (Case oBusCasoOAC : oListCasos){
                                    oDetalleCasosOAC.numeroSR = oBusCasoOAC.CaseNumber;
                                    oDetalleCasosOAC.estadoSR = oBusCasoOAC.Status;
                                    oDetalleCasosOAC.descripcion = oBusCasoOAC.Description;
                                    oDetalleCasosOAC.nifCuenta = oBusCasoOAC.Account.CC_Numero_Documento__c;
                                    oDetalleCasosOAC.nombreCuenta = oBusCasoOAC.Account.Name;
                                    oDetalleCasosOAC.nifCliente = oBusCasoOAC.Contact.CC_Numero_Documento__c;
                                    oDetalleCasosOAC.nombreCliente = oBusCasoOAC.Contact.FirstName;
                                    if(oBusCasoOAC.Contact.LastName != null){
                                        oDetalleCasosOAC.apellido1Cliente = oBusCasoOAC.Contact.LastName.SubStringBefore(' ');
                                    	oDetalleCasosOAC.apellido2Cliente = oBusCasoOAC.Contact.LastName.SubStringAfter(' ');
                                    } else {
                                        oDetalleCasosOAC.apellido1Cliente = oBusCasoOAC.Contact.LastName;
                                    	oDetalleCasosOAC.apellido2Cliente = oBusCasoOAC.Contact.LastName;
                                    }
                                    oDetalleCasosOAC.telefono = oBusCasoOAC.Account.Phone;
                                    oDetalleCasosOAC.email = oBusCasoOAC.Account.CC_Email__c;
                                    oDetalleCasosOAC.tematica = oBusCasoOAC.CC_MCC_Tematica__r.Name;
                                    oDetalleCasosOAC.servicioProducto = oBusCasoOAC.CC_MCC_ProdServ__r.Name;
                                    oDetalleCasosOAC.motivo = oBusCasoOAC.CC_MCC_Motivo__r.Name;
                                    oDetalleCasosOAC.canalEntrada = oBusCasoOAC.Origin;
                                    oDetalleCasosOAC.procedencia = oBusCasoOAC.CC_Canal_Procedencia__c;
                                    oDetalleCasosOAC.oficinaGestora = oBusCasoOAC.Contact.CC_OficinaGestoraId__r.CC_Numero_Oficina__c;
                                    oDetalleCasosOAC.oficinaSR = oBusCasoOAC.CC_Oficina_Afectada_Lookup__r.CC_Numero_Oficina__c;
                                    oDetalleCasosOAC.diagnostico = oBusCasoOAC.CC_Detalles_Consulta__c;
                                    oDetalleCasosOAC.tipoResolucion = '';
                                    oDetalleCasosOAC.fecha = String.valueOf(oBusCasoOAC.CreatedDate);
                                    oDetalleCasosOAC.tipoSolicitud = oBusCasoOAC.CC_Tipo_Contacto__c;
                                    oDetalleCasosOAC.fechaEntrada = String.valueOf(oBusCasoOAC.CreatedDate);
                                    oDetalleCasosOAC.dan = sDAN;
                                    oDetalleCasosOAC.dt = sDT;
                                    oDetalleCasosOAC.importeSolicitud = String.valueOf(oBusCasoOAC.CC_Importe_Reclamado__c);
                                    oDetalleCasosOAC.importeAbonado = String.valueOf(oBusCasoOAC.CC_Importe_Abonado__c);
                                    oDetalleCasosOAC.detalleResolucion = oBusCasoOAC.CC_Detalles_Solucion__c;
                                }
                            }else{
                                // Error al preparar el caso.
                                String sCodErr = '2';
                                String sDetErr = 'Error al preparar los datos. ' + sDetalle;
                                bTrazaOk = false;

                                CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oAux = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output();
                                oAux.resultado = sCodErr;
                                oAux.descripcion = sDetErr;
                                oAux.DetalleCaso = null;
                                oRes = oAux;

                                if (oTraza != null){
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Detalle_Oficina_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }
                            }
                        }else{
                            // Error al preparar el caso.
                            String sCodErr = '3';
                            String sDetErr = 'Error al preparar los datos. ' + sDetalle;
                            bTrazaOk = false;

                            CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oAux = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output();
                            oAux.resultado = sCodErr;
                            oAux.descripcion = sDetErr;
                            oAux.DetalleCaso = null;
                            oRes = oAux;

                            if (oTraza != null){
                                CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Detalle_Oficina_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                oTraza.add(oTrazaDet);
                            }
                        }
                    }
                }              
            }
            
            // Return de los casos encontrados.
            if (!oListCasos.isEmpty()){
                for (Case oCasoAux : oListCasos){
                    CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oAux = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output();
                    oAux.resultado = 'OK';
                    oAux.descripcion = 'Búsqueda realizada.';
                    oAux.DetalleCaso = oDetalleCasosOAC;
                    oRes = oAux;

                    if (oTraza != null){
                        CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Detalle_Oficina_DET', oCasoAux.Id, sTrazaOrig, oCasoAux, oAux, true, '0', '');
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
            sErrGen = 'Error en la ejecución del proceso CC_WS_Detalle_Oficina. ' + e.getMessage();

            CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oAux = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output();
            oAux.resultado = '9999';
            oAux.descripcion = sErrGen;
            oAux.DetalleCaso = null;
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