@RestResource(urlMapping='/CC_Casos_HDT/*')
global with sharing class CC_WS_Casos_HDT extends CBK_HttpServiceIntegration_Abstract{
	/*  Clase para publicar un servicio Rest de consulta del detalle del Casos de una oficina.
        Clase para los parámetros de entrada. */
    private static final List<String> CANAL_PROCEDENCIA = new List<String>{'Incidencias Técnicas', 'Servicios Centrales', 'SmartPhones', 'Virtualización de Proveedores'}; 
    global class CC_WS_Casos_HDT_Input {
        global String tiempo {get;set;}
    }

    /* Clase para el detalle del caso de salida. */
    global class CC_WS_Casos_HDT_Output {
        global String resultado {get;set;}
        global String descripcion {get;set;}
        global List<Case> casosOutput {get;set;}
    }

    
    /* Método para validar los inputs obligatorios.*/
    private static String validarDatosEntrada (CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDatos){
        if (oDatos != null){
            if (oDatos.tiempo == null){
                return 'KO';
            }else if (oDatos.tiempo.trim() == '') {
                return 'KO';
            }
        }

        return 'OK';
    }
    
    /* Método para preparar la búsqueda de casos con los criterios de entrada. */
    private static List<Case> prepararListadoCasos (CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oForm){
        List<Case> oRes = new List<Case>();
        
        try {
            
            if (oForm != null && oForm.tiempo != null){
                
                datetime intervalo = datetime.now().addMinutes(-(integer.valueof(oForm.tiempo)));
                // Busqueda base de los datos del objeto caso.
                 oRes = [SELECT Id,  IsDeleted, MasterRecordId, CaseNumber, ContactId, AccountId, AssetId,
                    ProductId, EntitlementId, SourceId, BusinessHoursId, ParentId, SuppliedName, SuppliedEmail,
                    SuppliedPhone, SuppliedCompany, Type, RecordTypeId, Status, Reason, Origin, Language,
                    Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, OwnerId, IsClosedOnCreate,
                    SlaStartDate, SlaExitDate, IsStopped, StopStartDate, CreatedDate, CreatedById, 
                    LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile,
                    ContactEmail, ContactFax, Comments, LastViewedDate, LastReferencedDate, ServiceContractId,
                    MilestoneStatus, CC_Cambio_Estado_Pendiente_Externo__c, CC_Canal_Contacto__c, 
                    CC_Canal_Procedencia__c, CC_Id_Cognitivo__c, CC_Idioma__c, CC_Owner_Anterior__c,
                    CC_Resolucion__c, CC_Telefono_Contacto__c, CC_Trasladado_Tercer_Nivel__c, 
                    CC_Agrupador_Id__c, CC_Agrupador_Padre_Id_Formula__c, CC_Tipo_Cliente__c, 
                    CC_CanalNotifCli__c, App_Reviews__c, App__c, CC_AcuseDelay__c, CC_AcuseRecibo__c, 
                    CC_Admin__c, CC_Aqumetrix__c, CC_Autoasignado_Coordinador__c, CC_Buzon_Salida_Atencion_Cliente__c,
                    CC_Cambio_Estado_Pendiente__c, CC_Canal_Operativo__c, CC_Canal_Respuesta_Modificar__c,
                    CC_Canal_Respuesta__c, CC_CasoRelacionado__c, CC_Causa__c, CC_Cerrado_Operativa__c,
                    CC_Cierre_Automatico__c, CC_Cola_Procedencia__c, CC_ContactoRelacionado__c, CC_Control_ComApps__c,
                    CC_Conversacion__c, CC_CuentaRRSS_CBK__c, CC_CuentaRRSS_CLI__c, FinServ__FinancialAccount__c,
                    CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, CC_Email_Cabecera__c,
                    CC_Email_Pie__c, CC_En_Tercer_Nivel__c, CC_Fecha_1a_Respuesta_Twitter__c,
                    CC_Fecha_Activo_Formulario__c, CC_Fecha_Cierre_SolInf__c, CC_Fecha_Reapertura__c,
                    CC_Fecha_Respuesta_Colaborador__c, CC_Fecha_Respuesta_Stores__c,
                    CC_Fecha_Solicitud_Informacion__c, CC_Fecha_Traslado_3N__c, CC_Fecha_Traslado_Colaborador__c,
                    CC_Fecha_Twitter_Entrante__c, CC_Fecha_Ultima_Interaccion__c, 
                    CC_Fecha_Ultima_Reclamacion__c, CC_Flag_Prioridad_Formulario__c, CC_Franja_Horaria_Aux__c,
                    CC_Franja_Horaria__c, CC_GMT_Data__c, CC_Grupo_3N__c, CC_Grupo_Colaborador__c,
                    CC_IdentCliente__c, CC_Imaginbank__c, CC_ListFicherosAdjuntos__c, CC_MCC_Causa__c,
                    CC_MCC_Motivo__c, CC_MCC_Plantilla__c, CC_MCC_ProdServ__c, CC_MCC_Solucion__c, 
                    CC_MCC_Tematica__c, CC_MailTelfNotif__c, CC_Mostrar_Componentes__c,
                    CC_Franja_SLA_AC_Preventiva__c, CC_Motivo_Reactivacion__c, CC_Motivo__c, CC_Nivel_Flag__c,
                    CC_NotIncidenciaCuerpo__c, CC_NotIncidencia__c, CC_NumPerso__c, CC_Numero_Documento__c,
                    CC_Primer_DM_Enviado__c, CC_Cliente_Afectado_Lookup__c, CC_Producto_Servicio__c,
                    CC_Rating__c, CC_Reactivado_Operativa__c, CC_Rechazar_Reabrir_Caso__c,
                    CC_Recipient_Mail__c, CC_Recipient_Name__c, CC_Recipient_Phone__c, CC_RefExterna__c,
                    CC_Referencia_Correo_Saliente__c, CC_SLA_Atender_Twitter__c,
                    CC_SLA_Formulario_1__c, CC_SLA_Formulario_2__c, CC_SLA_Formulario_3__c,
                    CC_SLA_Formulario_4__c, CC_SLA_Formulario_5__c, CC_SLA_Formulario_6__c,
                    CC_SLA_Formulario_7__c, CC_Saludo_Horario__c, CC_SegOperativa__c, CC_Social_Persona__c,
                    CC_Solucion__c, CC_SuppliedAmbitoDesc__c, CC_SuppliedAmbito__c, CC_SuppliedApellido1__c,
                    CC_SuppliedApellido2__c, CC_SuppliedApp__c, CC_SuppliedCertificado__c, CC_SuppliedConexion__c,
                    CC_SuppliedEntidad__c, CC_SuppliedFiles__c, CC_SuppliedID__c, CC_SuppliedIP__c,
                    CC_SuppliedIdioma__c, CC_SuppliedIndCliente__c, CC_SuppliedIndLOE__c, CC_SuppliedMotivoDesc__c,
                    CC_SuppliedMotivo__c, CC_SuppliedNIF__c, CC_SuppliedOficina__c, CC_SuppliedOrigen__c,
                    CC_SuppliedProductoDesc__c, CC_SuppliedProducto__c, CC_SuppliedServicio__c, CC_SuppliedTipo__c,
                    CC_SuppliedURL__c, CC_SuppliedUser__c, CC_SuppliedWeb__c, CC_Tematica__c,
                    CC_Tiempo_Cerrado_FormWeb__c, CC_Tiempo_Estado_Pendiente__c, CC_Tiempo_Respuesta_Twitter__c,
                    CC_Tipo_Cliente_Formula__c, CC_Tipo_Contacto__c, CC_Ultima_Interaccion__c, Flag__c,
                    Procedencia__c, Versi_n_App__c, Tipo_Post__c, CC_Agrupador_Identificador_Maximo__c,
                    CC_Buzon_Salida__c, CC_Campana__c, CC_Canal_Resolucion__c, CC_Comunicacion_Informativa_Campana__c,
                    CC_Comunicacion_Informativa__c, CC_Cont_Interm_Delay__c, CC_Contacto_Intermedio__c,
                    CC_GrupoOficina__c, CC_Importe_Abonado__c, CC_Importe_Reclamado__c,
                    CC_Mostrar_Componente_Contacto__c, CC_Mostrar_Componente_Representante__c,
                    CC_No_Identificado__c, CC_Notif_Cont_Inter__c, CC_Numero_Reclamaciones_Cliente__c,
                    CC_Numero_Reclamaciones_Tras_Colab__c, CC_OTP_Bloqueo__c, CC_OTP_Fecha_Ultima_Validacion__c,
                    CC_OTP_Intentos__c, CC_OTP_Nivel__c, CC_OTP_Valido__c, CC_Oficina_afectada__c,
                    CC_Representante__c, CC_Respuesta_Personalizada__c, CC_SuppliedInterlocutor__c, CC_Numero_Empleado__c,
                    CC_Tipo_Gestion_3N_Demanda__c, CC_Tipo_gesti_n_demanda__c, CC_Ultima_Operativa_Correo__c,
                    CC_Acepta_Condiciones_Contractuales__c, CC_Activacion_OK__c, CC_Cancelar_SmartScript__c,
                    CC_Created_1r_SocialPost__c, CC_DigitosTarjeta_Encriptado__c, CC_Digitos_Tarjeta__c,
                    CC_Motivo_Llamada_Smart_Script__c, CC_Motivo_NOK_Tarjetas__c, CC_NotifCli__c, CC_NotifClienteEnv__c,
                    CC_Numero_Contrato__c, CC_PAN_Encriptado__c, CC_PAN__c, CC_Politica_Seguridad_OK__c, 
                    CC_Primer_SocialPost_Id__c, CC_Resultado_Operativa_Tarjetas__c, CC_Error_TF7__c, CC_Motivo_NOK__c, 
                    CC_Tipo_Gestion__c, CC_Direccion_Territorial__c, CC_Fecha_Limite_Resolucion_Naranja__c,
                    CC_Fecha_Limite_Resolucion_Verde__c, CC_Fecha_Limite_Resolucion__c, CC_Nombre_Empresa__c, 
                    CC_Oficina__c, CC_Recipient_BillingAddress__c, CC_Recipient_Id_Maximo_Agrupador__c,
                    CC_Recipient_Modelo_Maquina__c, CC_Recipient_Numero_Empleado__c, CC_Recipient_Numero_Maquina__c, 
                    CC_Recipient_Numero_Serie__c, CC_SLA_Fecha_Limite_Resolucion__c, CC_Tipo_ChatTranscript__c, 
                    Canal_del_Empleado__c, CC_Numero_Pedido__c, CC_Oficina_Afectada_Lookup__c, CC_Recipient_Oficina_Gestora__c, 
                    CC_Detalle_Solucion_Confidencial__c, CC_Estado_Reversion__c, CC_Fecha_Hora_Procesado__c, 
                    CC_Gestor_Documental__c, CC_NIF__c, CC_Numero_Caso__c, CC_Plantilla_Motivo__c, CC_Provincia_Gestor__c, 
                    CC_Situacion_Caso__c, CC_Tarjeta_Activada__c, CC_Tarjeta_Anterior_Activada__c, CC_TipoCuentaCaso__c, 
                    CC_Tramo_TRZ__c, CC_URL_Encuesta_3N__c,CC_Info_Denegacion__c 
                        FROM CASE WHERE (RecordType.DeveloperName ='CC_Empleado' OR RecordType.DeveloperName ='HDT_Empleado') 
                         AND LastModifiedDate >= :intervalo
                        AND CC_Canal_Procedencia__c IN :CANAL_PROCEDENCIA];
				
                
            }

        } catch (Exception e) {
            // Error tratando el caso.
            oRes=null;
        }

        return oRes;
    }
   
    /* Método publicado para devolver el resultado de la busqueda de casos. */
    @HttpPost
    global static CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output searchDetailCase(CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn){
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oRes = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
        Map<String,CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oMapForm = new Map<String,CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        List<Case> oListCasos = new List<Case>();

        // Lista de trazas a crear.
        String resultado;
        Datetime dtStart = Datetime.now();
        Datetime dtEnd;
        RestRequest req =  RestContext.request;

        //req.requestBody =  Blob.valueOf(oDataIn.tiempo);
        
        String test = String.valueOf(req.requestBody);
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
                        
                        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
                        oAux.resultado = '412';
                        oAux.descripcion = 'Datos obligatorios no informados.';
                        oAux.casosOutput = null;
                        oRes = oAux;
                    }
                
            }else{
                    	// Error validación datos entrada.
                        resultado = '{"Result":"KO","Description":"Datos obligatorios no informados."}';
                		req.requestBody =  Blob.valueOf('vino vacio');
                        registrarTraza(req, res, dtStart, resultado, 412);
                        
                        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
                        oAux.resultado = '412';
                        oAux.descripcion = 'Datos obligatorios no informados.';
                        oAux.casosOutput = null;
                        oRes = oAux;
                    }

            // Preparar la busqueda de los casos.
            if (!oMapForm.isEmpty()){
                // Procesar los criterios de entrada.
            
            List<Case> oResListCasos = prepararListadoCasos(oDataIn);
            
                if (!oResListCasos.isEmpty()){
                    resultado = '{"Result":"OK","Description":"Búsqueda realizada."}';
                    CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
                    oAux.resultado = '200';
                    oAux.descripcion = 'Búsqueda realizada.';
                    oAux.casosOutput = oResListCasos;
                    oRes = oAux;
                    registrarTraza(req, res, dtStart, resultado, 200);
                }else{
                    // Error al preparar el caso.
                    resultado = '{"Result":"OK","Description":"No hay datos para retornar."}';
                    registrarTraza(req, res, dtStart, resultado, 201);
                    
                    CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
                    oAux.resultado = '201';
                	oAux.descripcion = 'No hay datos para retornar.';
                    oAux.casosOutput = null;
                    oRes = oAux;
                }                   
            }
            
        } catch (Exception e) {
            // Trazar error.
            resultado = '{"Result":"KO","Description":"Error en la ejecución del proceso CC_WS_Casos_HDT. ' + e.getMessage()+'"}';
            registrarTraza(req, res, dtStart, resultado, 500);
            sErrGen = 'Error en la ejecución del proceso CC_WS_Casos_HDT. ' + e.getMessage();

            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
            oAux.resultado = '500';
            oAux.descripcion = sErrGen;
            oAux.casosOutput = null;
            oRes = oAux;
        }

        return oRes;        
    }

    public static void registrarTraza(RestRequest req, RestResponse res, Datetime dtStart, String resultado, Integer error){
        res.statusCode=error;
        res.responseBody= Blob.valueOf(resultado);
        req.requestURI = '/CC_Casos_HDT/*';
        Datetime dtEnd = Datetime.now();
        register(req,res,dtStart,dtEnd,'CC_WS_Casos_HDT_DET','CC_WS_Casos_HDT_DET');
    }
}