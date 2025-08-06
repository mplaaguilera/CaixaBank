@RestResource(urlMapping='/CC_Llamadas_HDT/*')
global with sharing class CC_WS_Llamadas_HDT extends CBK_HttpServiceIntegration_Abstract{
	/*  Clase para publicar un servicio Rest de consulta del detalle del Casos de una oficina.
		Clase para los parámetros de entrada. */
    private static final List<String> SERVICIOS_GENESYS = new List<String>{'INC_TEC_CAJEROS', 'INC_TEC_CORREO', 'INC_TEC_OTROS', 'INC_TEC_RECICLADORES','INC_TEC_RESTAURACION','INC_TEC_CONECTIVIDAD','INC_TEC_CLICK2CALL',
        													'INC_TEC_DISEXT','INC_TEC_FRAUDE','INC_TEC_HERRAMIENTAS','INC_TEC_TF', 'INC_TEC_WINDOWS', 'INC_TEL_SMARTPHONES', '2N_SMARTPHONES','CCO_VIRTUALIZ_PROV','CCO_PXP' };
    global class CC_WS_Llamadas_HDT_Input {
        global String tiempo {get;set;}
    }

    /* Clase para el detalle del caso de salida.*/
    global class CC_WS_Llamadas_HDT_Output {
        global String resultado {get;set;}
        global String descripcion {get;set;}
        global List<CC_Llamada__c> llamadasOutput {get;set;}
    }

    
    /* Método para validar los inputs obligatorios. */
    private static String validarDatosEntrada (CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input oDatos){
        if (oDatos != null){
            if (oDatos.tiempo == null){
                return 'KO';
            }else if (oDatos.tiempo.trim() == '') {
                return 'KO';
            }
        }
        return 'OK';
    }
    
    /* Método para preparar la búsqueda de llamadas con los criterios de entrada. */
    private static List<CC_Llamada__c> prepararListadoLlamadas (CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input oForm){
        List<CC_Llamada__c> oRes = new List<CC_Llamada__c>();
        
        try {
            
            if (oForm != null && oForm.tiempo != null){

                datetime intervalo = datetime.now().addMinutes(-(integer.valueof(oForm.tiempo)));
                // Busqueda base de los datos del objeto caso.
                 oRes = [SELECT Id,  OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
                 LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, CC_ANI__c,
                CC_Agente__c, CC_Asunto__c, CC_Atendida__c, CC_Case_Consulta__c, CC_Cognitivo__c, CC_Componente_Busqueda__c,
                CC_ConnId_Cognitivo__c, CC_ConnId__c, CC_Contacto__c, CC_Cuenta__c, CC_DNIS__c, CC_Datos_Genesys__c, 
                CC_Encuesta_Valor_1__c, CC_Encuesta_Valor_2__c, CC_Encuesta_Valor_3__c, CC_Extension__c, CC_Fecha_Fin__c, 
                CC_Fecha_Inicio__c, CC_Identificado_Manualmente__c, CC_Idioma__c, CC_Llamada_Padre__c, CC_No_Identificado__c,
                CC_NumPerso__c, CC_Servicio_Genesys__c, CC_Tipo_Cierre__c, CC_Tipo_Servicio__c, CC_Tipo__c, CC_ConnId_Consulta__c,
                CC_Canal_del_Empleado__c, CC_Id_Cognitivo__c, CC_IdentCliente__c, CC_Nombre_Empresa__c, CC_Fecha_Grabacion__c, 
                CC_Tipo_C2C__c, CC_Numero_Empleado__c, CC_URL_Grabacion__c, CC_Encuesta__c, CC_Auditoria_IZO__c, CC_Prioridad_IZO__c,
                CC_Valida_IZO__c, CC_Servicio__c, CC_Servicio_Llamada_Saliente__c,
                CBK_Ticket_OCP__c, CC_Campana_Genesys__c 
                    FROM CC_Llamada__c WHERE (/*RecordType.DeveloperName ='CC_Cliente' OR*/ RecordType.DeveloperName ='CC_Empleado') 
                    AND LastModifiedDate >= :intervalo
                    AND CC_Servicio_Genesys__r.CC_Codigo__c IN :SERVICIOS_GENESYS];
				
            }

        } catch (Exception e) {
            // Error tratando la llamada.
            oRes=null;
        }
        return oRes;
    }
     
    /* Método publicado para devolver el resultado de la busqueda de llamadas. */
    @HttpPost
    global static CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output searchDetailLlamada(CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input oDataIn){
        CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oRes = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output();
        Map<String,CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input> oMapForm = new Map<String,CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input>();

        // Lista de trazas a crear.
        String resultado;
        Datetime dtStart = Datetime.now();
        Datetime dtEnd;
        RestRequest req =  RestContext.request;
        //req.requestBody =  Blob.valueOf(oDataIn.tiempo);
        RestResponse res = RestContext.response;
        String sErrGen = '';      

        try {
            // Control de datos.
            if (oDataIn != null){
                    String sValido = validarDatosEntrada (oDataIn);
                    if (sValido == 'OK'){
                        // Validados los datos realizamos las acciones necesarias
                        oMapForm.put(oDataIn.tiempo, oDataIn);
                        req.requestBody =  Blob.valueOf(oDataIn.tiempo);
                    }else{
                    	// Error validación datos entrada.
                        resultado = '{"Result":"KO","Description":"Datos obligatorios no informados."}';
                        req.requestBody =  Blob.valueOf('vino vacio');
                        registrarTraza(req, res, dtStart, resultado, 412);                        
                        CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oAux = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output();
                        oAux.resultado = '412';
                        oAux.descripcion = 'Datos obligatorios no informados.';
                        oAux.llamadasOutput = null;
                        oRes = oAux;
                        
                    }
            }else{
                    	// Error validación datos entrada.
                        resultado = '{"Result":"KO","Description":"Datos obligatorios no informados."}';
                req.requestBody =  Blob.valueOf('vino vacio');
                        registrarTraza(req, res, dtStart, resultado, 412);                        
                        CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oAux = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output();
                        oAux.resultado = '412';
                        oAux.descripcion = 'Datos obligatorios no informados.';
                        oAux.llamadasOutput = null;
                        oRes = oAux;
                        req.requestBody =  Blob.valueOf(oDataIn.tiempo);
                    }
            // Preparar la busqueda de los casos.
            if (!oMapForm.isEmpty()){
                // Procesar los criterios de entrada.
            List<CC_Llamada__c> oResListCasos = prepararListadoLlamadas(oDataIn);
            
                if (!oResListCasos.isEmpty()){
                    resultado = '{"Result":"OK","Description":"Búsqueda realizada."}';
                    CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oAux = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output();
                    oAux.resultado = '200';
                    oAux.descripcion = 'Búsqueda realizada.';
                    oAux.llamadasOutput = oResListCasos;
                    oRes = oAux;
                    registrarTraza(req, res, dtStart, resultado, 200);
                    
                }else{
                    // Error al preparar el caso.
                    resultado = '{"Result":"OK","Description":"No hay datos para retornar."}';
                    registrarTraza(req, res, dtStart, resultado, 201);
                    
                    CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oAux = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output();
                    oAux.resultado = '201';
                    oAux.descripcion = 'No hay datos para retornar.';
                    oAux.llamadasOutput = null;
                    oRes = oAux;
                    
                }                   
            }
            
        } catch (Exception e) {
            // Trazar error.
            resultado = '{"Result":"KO","Description":"Error en la ejecución del proceso CC_WS_Llamadas_HDT. ' + e.getMessage()+'"}';
            
            registrarTraza(req, res, dtStart, resultado, 500);
            sErrGen = 'Error en la ejecución del proceso CC_WS_Casos_HDT. ' + e.getMessage();
            CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oAux = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output();
            oAux.resultado = '500';
            oAux.descripcion = 'Error en la ejecución del proceso CC_WS_Llamadas_HDT.';
            oAux.llamadasOutput = null;
            oRes = oAux;
        }
        return oRes;        
    }

    public static void registrarTraza(RestRequest req, RestResponse res, Datetime dtStart, String resultado, Integer error){
        res.statusCode=error;
        res.responseBody= Blob.valueOf(resultado);
        req.requestURI = '/CC_Llamadas_HDT/*';
        Datetime dtEnd = Datetime.now();
        register(req,res,dtStart,dtEnd,req.resourcePath,'CC_WS_Llamadas_HDT_DET');
    }
}