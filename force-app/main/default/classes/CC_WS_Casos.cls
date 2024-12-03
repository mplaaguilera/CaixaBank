@RestResource(urlMapping='/CC_Cases/*')
global with sharing class CC_WS_Casos {

    /*
        Clase para publicar un servicio Rest para la creación de casos.
    */

    /*
        Clase para los parámetros de entrada.
    */
    global class CC_WS_Casos_Input {

        global String Aplicacion {get;set;}
        global String id {get;set;}
        global String entidad {get;set;}
        global String Nombre {get;set;}
        global String Apellido1 {get;set;}
        global String Apellido2 {get;set;}
        global String EMAIL {get;set;}
        global String Telefono {get;set;}
        global String NIF {get;set;}
        global String Cliente {get;set;}
        global String NumOf {get;set;}
        global String ClienteLOE {get;set;}
        global String Codiusu {get;set;}
        global String Producto {get;set;}
        global String Ambito {get;set;}
        global String Motivo {get;set;}
        global String Idioma {get;set;}
        global String Texto {get;set;}
        global String CertificadoDigital {get;set;}
        global String Origen {get;set;}
        global String Referer {get;set;}
        global String User_Agent {get;set;}
        global String IP {get;set;}
        global String REFUSUARIO {get;set;}
        global String Tipo {get;set;}
        global String Web {get;set;}
        global String Servicio {get;set;}
        global String FicherosAdjuntos {get;set;}
        global String CC_Origen {get;set;}
        global String CC_ClasificacionWeb {get;set;}
        global String CC_ContactId {get;set;}
        global String CC_AccountId {get;set;}
    }

    /*
        Clase para los parámetros de salida.
    */
    global class CC_WS_Casos_Output {
        global String sCodError {get;set;}
        global String sDetalleError {get;set;}
        global String sNumCaso {get;set;}
        global String sRefUser {get;set;}
        global String sNIF {get;set;}
        global String sTexto {get;set;}
        global String sCaseId {get;set;}
        global String sContactId {get;set;}
        global String sAccountId {get;set;}
    }

    /*
        Método para validar los inputs.
    */
    private static String validarDatosEntrada (CC_WS_Casos.CC_WS_Casos_Input oDatos)
    {
        if (oDatos != null)
        {
            if (oDatos.REFUSUARIO == null)
            {
                return 'KO';
            }else if (oDatos.REFUSUARIO.trim() == '') {
                return 'KO';
            }

            if (oDatos.NIF == null)
            {
                return 'KO';
            }else if (oDatos.NIF.trim() == '') {
                return 'KO';
            }

            if (oDatos.Texto == null)
            {
                return 'KO';
            }else if (oDatos.Texto.trim() == '') {
                return 'KO';
            }

            if (oDatos.Aplicacion == null)
            {
                return 'KO';
            }else if (oDatos.Aplicacion.trim() == '') {
                return 'KO';
            }

            // Validaciones y gestiones por aplicación.
            if (oDatos.Aplicacion == 'FORMWEB' || oDatos.Aplicacion == 'MICROBANK')
            {
                // VALIDACIONES PARA EL FORMULARIO WEB.
                if (oDatos.Producto == null || oDatos.Ambito == null || oDatos.Motivo == null)
                {
                    return 'KO';
                }else if (oDatos.Producto.trim() == '' || oDatos.Ambito.trim() == '' || oDatos.Motivo.trim() == '') {
                    return 'KO';
                }else{
                    // Rellenar los campos internos para el tratamiento de la tipificación.
                    oDatos.CC_Origen = 'MC';

                    String sTipificacion = '';
                    sTipificacion = sTipificacion + oDatos.CC_Origen + '-';
                    sTipificacion = sTipificacion + oDatos.Motivo.trim() + '-';
                    sTipificacion = sTipificacion + oDatos.Producto.trim() + '-';
                    sTipificacion = sTipificacion + oDatos.Ambito.trim();
                    oDatos.CC_ClasificacionWeb = sTipificacion;
                }
            }
        }

        // Unificar datos para tratamiento.
        oDatos.NIF = oDatos.NIF.toUpperCase();
        oDatos.EMAIL = oDatos.EMAIL.toLowerCase();

        return 'OK';
    }

    /*
        Recuperar el maestro de tipificaciones entre Web y Salesforce.
    */
    private static Map<String,Map<String,String>> getTipificacionesCaso (Set<String> oListaTip)
    {
        Map<String,Map<String,String>> oData = new Map<String,Map<String,String>>();

        if (oListaTip != null)
        {
            if (!oListaTip.isEmpty())
            {
                List<CC_MCC__c> oMCC = [SELECT Id, CC_Equivalencia_Formulario__c, CC_WebMCCTematica__c, CC_WebMCCProducto__c, CC_WebMCCMotivo__c, CC_WebTipoContacto__c FROM CC_MCC__c WHERE CC_Equivalencia_Formulario__c IN :oListaTip AND CC_Activo__c = true];
                for (CC_MCC__c oAux : oMCC)
                {
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

    /*
        Recuperar datos configurados en los Metadatos para la cuenta origen.
            Prioridad, Estado, Canal acceso y tipo de cliente del caso.
    */
    private static CC_Config_FormWeb__mdt getConfigApp (String sApp)
    {
        CC_Config_FormWeb__mdt oAppCfg;

        if (sApp != '')
        {
            List<CC_Config_FormWeb__mdt> oConfig = [SELECT Id, CC_CasoCanalEntrada__c, CC_CasoCanalOperativo__c, CC_CasoCanalProc__c, CC_CasoEstado__c, CC_CasoPrioridad__c, CC_ReglaAssigCaso__c, CC_CasoTipoCliente__c, CC_MotivosExcl__c FROM CC_Config_FormWeb__mdt WHERE CC_Aplicacion__c = :sApp];
            if (oConfig.size()==1)
            {
                if (oConfig[0] != null)
                    oAppCfg = oConfig[0];
            }
        }

        return oAppCfg;
    }

    /*
        Recuperar datos configurados en los Metadatos para la cuenta origen.
            Estado del caso duplicado.
    */
    private static CC_Config_FormWeb_Duplicado__mdt	getConfigAppDuplicado (String sApp)
    {
        CC_Config_FormWeb_Duplicado__mdt oAppCfg;

        if (sApp != '')
        {
            List<CC_Config_FormWeb_Duplicado__mdt> oConfig = [SELECT Id, CC_CasoEstado__c, CC_Tiempo_Duplicidad__c FROM CC_Config_FormWeb_Duplicado__mdt WHERE CC_Aplicacion__c = :sApp];
            if (oConfig.size()==1)
            {
                if (oConfig[0] != null)
                    oAppCfg = oConfig[0];
            }
        }

        return oAppCfg;
    }

    /*
        Método para preparar la creación del caso.

        to_do. llegar la conversión de idiomas.
    */
    private static Map<String,Object> prepararCaso (CC_WS_Casos.CC_WS_Casos_Input oForm, Map<String, Object> oParamAux, Map<String,Map<String,String>> oMapTipificacion, Map<String, Case> casosDuplicadosMap, String sTipoNif)
    {
        Map<String,Object> oRes = new Map<String,Object>();

        try {
            if (oForm != null)
            {
                // Configuración para el caso a partir de formularios web.
                CC_Config_FormWeb__mdt oConfig;
                // Configuración para el caso duplicado a partir de formularios web.
                CC_Config_FormWeb_Duplicado__mdt oConfigDuplicado;

                // Crear objeto caso.
                Case oCaso = new Case();

                // Asignar Contacto y Account.
                if (oForm.CC_AccountId != null)
                {
                    oCaso.AccountId = oForm.CC_AccountId;
                }

                if (oForm.CC_ContactId != null)
                {
                    oCaso.ContactId = oForm.CC_ContactId;
                }

                // Tratar los datos del formulario y volcar al caso.

                if (oForm.REFUSUARIO != null)
                {
                    oCaso.CC_RefExterna__c = oForm.REFUSUARIO.trim().unescapeHtml4();
                }

                if (oForm.Aplicacion != null)
                {
                    String aplicacionReal = oForm.Aplicacion.trim().unescapeHtml4();
                    if (aplicacionReal == 'FORMWEB')
                    {
                        String ambitoMicrobank = [SELECT Valor_Texto__c FROM CC_Parametros__mdt WHERE Nombre__c = 'Producto_Aplicacion_Microbank'].Valor_Texto__c;
                        if (oForm.Ambito == ambitoMicrobank)
                        {
                        	aplicacionReal = 'MICROBANK';
                        }
                    }

                    oCaso.CC_SuppliedApp__c = aplicacionReal;
                    // Recuperar configuración.
                    oConfig = getConfigApp (aplicacionReal);
                    // Recuperar configuración caso duplicado.
                    oConfigDuplicado = getConfigAppDuplicado (aplicacionReal);
                }

                if (oForm.id != null)
                {
                    oCaso.CC_SuppliedID__c = oForm.id.trim().unescapeHtml4();
                }

                if (oForm.entidad != null)
                {
                    oCaso.CC_SuppliedEntidad__c = oForm.entidad.trim().unescapeHtml4();
                }

                if (oForm.Nombre != null)
                {
                    oCaso.SuppliedName = oForm.Nombre.trim().unescapeHtml4();
                }

                if (oForm.Apellido1 != null)
                {
                    oCaso.CC_SuppliedApellido1__c = oForm.Apellido1.trim().unescapeHtml4();
                }

                if (oForm.Apellido2 != null)
                {
                    oCaso.CC_SuppliedApellido2__c = oForm.Apellido2.trim().unescapeHtml4();
                }

                if (oForm.EMAIL != null)
                {
                    oCaso.SuppliedEmail = oForm.EMAIL.trim().unescapeHtml4();
                }

                if (oForm.Telefono != null)
                {
                    oCaso.SuppliedPhone = oForm.Telefono.trim().unescapeHtml4();
                }

                if (oForm.NIF != null)
                {
                    oCaso.CC_SuppliedNIF__c = oForm.NIF.trim().unescapeHtml4();

                    // Dato para identificar al cliente.
                    oCaso.CC_Numero_Documento__c = oForm.NIF.trim().unescapeHtml4();
                }

                if (oForm.Cliente != null)
                {
                    oCaso.CC_SuppliedIndCliente__c = oForm.Cliente.trim().unescapeHtml4();
                }

                if (oForm.NumOf != null)
                {
                    oCaso.CC_SuppliedOficina__c = oForm.NumOf.trim().unescapeHtml4();
                }

                if (oForm.ClienteLOE != null)
                {
                    oCaso.CC_SuppliedIndLOE__c = oForm.ClienteLOE.trim().unescapeHtml4();
                }

                if (oForm.Codiusu != null)
                {
                    oCaso.CC_SuppliedUser__c = oForm.Codiusu.trim().unescapeHtml4();
                }

                if (oForm.Producto != null)
                {
                    oCaso.CC_SuppliedProducto__c = oForm.Producto.trim().unescapeHtml4();

                    if (oParamAux != null)
                    {
                        if (!oParamAux.isEmpty())
                        {
                            if (oParamAux.get('CC_ProductoWeb') != null)
                            {
                                Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ProductoWeb');
                                if (oMap.get(oForm.Producto.trim().unescapeHtml4()) != null)
                                {
                                    oCaso.CC_SuppliedProductoDesc__c = oMap.get(oForm.Producto.trim().unescapeHtml4());
                                }else{
                                    oCaso.CC_SuppliedProductoDesc__c = oForm.Producto.trim().unescapeHtml4();
                                }
                            }
                        }
                    }
                }

                if (oForm.Ambito != null)
                {
                    oCaso.CC_SuppliedAmbito__c = oForm.Ambito.trim().unescapeHtml4();

                    if (oParamAux != null)
                    {
                        if (!oParamAux.isEmpty())
                        {
                            if (oParamAux.get('CC_AmbitoWeb') != null)
                            {
                                Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_AmbitoWeb');
                                if (oMap.get(oForm.Ambito.trim().unescapeHtml4()) != null)
                                {
                                    oCaso.CC_SuppliedAmbitoDesc__c = oMap.get(oForm.Ambito.trim().unescapeHtml4());
                                }else{
                                    oCaso.CC_SuppliedAmbitoDesc__c = oForm.Ambito.trim().unescapeHtml4();
                                }
                            }
                        }
                    }
                }

                if (oForm.Motivo != null)
                {
                   // String sDato = oForm.Motivo.trim().unescapeHtml4();

                    oCaso.CC_SuppliedMotivo__c = oForm.Motivo.trim().unescapeHtml4();

 /*                   if (oConfig != null)
                    {
                        if (oConfig.CC_MotivosExcl__c != '' && sDato != '')
                        {
                            if (oConfig.CC_MotivosExcl__c.contains(sDato))
                            {
                                oRes.put('Estado', 'KO');
                                oRes.put('Detalle', 'Motivo no permitido.');
                                oRes.put('Caso', null);

                                return oRes;
                            }
                        }
                    }*/

                    if (oParamAux != null)
                    {
                        if (!oParamAux.isEmpty())
                        {
                            if (oParamAux.get('CC_MotivoWeb') != null)
                            {
                                Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_MotivoWeb');
                                if (oMap.get(oForm.Motivo.trim().unescapeHtml4()) != null)
                                {
                                    oCaso.CC_SuppliedMotivoDesc__c = oMap.get(oForm.Motivo.trim().unescapeHtml4());
                                }else{
                                    oCaso.CC_SuppliedMotivoDesc__c = oForm.Motivo.trim().unescapeHtml4();
                                }
                            }
                        }
                    }
                }

                if (oForm.Idioma != null)
                {
                    oCaso.CC_SuppliedIdioma__c = oForm.Idioma.trim().unescapeHtml4();

                    // Asignar el idioma del caso.
                    if (oParamAux != null)
                    {
                        if (!oParamAux.isEmpty())
                        {
                            if (oParamAux.get('CC_Idioma_FORMWEB') != null)
                            {
                                Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Idioma_FORMWEB');
                                if (oMap.get(oForm.Idioma.trim().unescapeHtml4()) != null)
                                {
                                    oCaso.CC_Idioma__c = oMap.get(oForm.Idioma.trim().unescapeHtml4());
                                }else{
                                    // Idioma no configurado. Por defecto 'es'
                                    oCaso.CC_Idioma__c = 'es';
                                }
                            }
                        }
                    }
                }

                if (oForm.Texto != null)
                {
                    String sTextoFW = oForm.Texto.trim().unescapeHtml4();
                    String sTextoLargoFW = sTextoFW;

                    if (sTextoFW != '')
                        if (sTextoFW.length() > 80)
                            sTextoFW = sTextoFW.substring(0,80);

                    oCaso.Subject = sTextoFW;
                    oCaso.Description = sTextoLargoFW;
                }

                if (oForm.CertificadoDigital != null)
                {
                    oCaso.CC_SuppliedCertificado__c = oForm.CertificadoDigital.trim().unescapeHtml4();
                }

                if (oForm.Origen != null)
                {
                    oCaso.CC_SuppliedOrigen__c = oForm.Origen.trim().unescapeHtml4();
                }

                if (oForm.Referer != null)
                {
                    oCaso.CC_SuppliedURL__c = oForm.Referer.trim().unescapeHtml4();
                }

                if (oForm.User_Agent != null)
                {
                    oCaso.CC_SuppliedConexion__c = oForm.User_Agent.trim().unescapeHtml4();
                }

                if (oForm.IP != null)
                {
                    oCaso.CC_SuppliedIP__c = oForm.IP.trim().unescapeHtml4();
                }

                if (oForm.Tipo != null)
                {
                    oCaso.CC_SuppliedTipo__c = oForm.Tipo.trim().unescapeHtml4();
                }

                if (oForm.Web != null)
                {
                    oCaso.CC_SuppliedWeb__c = oForm.Web.trim().unescapeHtml4();
                }

                if (oForm.Servicio != null)
                {
                    oCaso.CC_SuppliedServicio__c = oForm.Servicio.trim().unescapeHtml4();
                }

                if (oForm.FicherosAdjuntos != null)
                {
                    if (oForm.FicherosAdjuntos.trim().unescapeHtml4() != '')
                    {
                        oCaso.CC_SuppliedFiles__c = true;
                        oCaso.CC_ListFicherosAdjuntos__c = oForm.FicherosAdjuntos.trim().unescapeHtml4();
                    }else
                        oCaso.CC_SuppliedFiles__c = false;
                }

                // Tipificar el caso.
                if (oMapTipificacion != null && oForm.CC_ClasificacionWeb != null)
                {
                    if (oMapTipificacion.get(oForm.CC_ClasificacionWeb) != null)
                    {
                        oCaso.CC_MCC_Tematica__c = oMapTipificacion.get(oForm.CC_ClasificacionWeb).get('Tematica');
                        oCaso.CC_MCC_ProdServ__c = oMapTipificacion.get(oForm.CC_ClasificacionWeb).get('Producto');
                        oCaso.CC_MCC_Motivo__c = oMapTipificacion.get(oForm.CC_ClasificacionWeb).get('Motivo');
                        oCaso.CC_Tipo_Contacto__c = oMapTipificacion.get(oForm.CC_ClasificacionWeb).get('TipoContacto');
                    }
                }

                // Rellenar información preconfigurada.
                if (oConfig != null)
                {
                    if (oConfig.CC_ReglaAssigCaso__c != null)
                    {
                        String sReglaId = '';

                        // Aplicar la regla de asignación del caso.
                        if (oParamAux != null)
                        {
                            if (!oParamAux.isEmpty())
                            {
                                if (oParamAux.get('CC_ReglasAss') != null)
                                {
                                    Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ReglasAss');
                                    if (oMap.get(oConfig.CC_ReglaAssigCaso__c) != null)
                                    {
                                        sReglaId = oMap.get(oConfig.CC_ReglaAssigCaso__c);
                                    }
                                }
                            }
                        }

                        if (sReglaId != '')
                        {
                            Database.DMLOptions dmlOpts = new Database.DMLOptions();
                            dmlOpts.assignmentRuleHeader.assignmentRuleId = sReglaId;
                            oCaso.setOptions(dmlOpts);
                        }
                    }

                    // Si el nuevo caso se considera duplicado, se le caso asigna el estado "Pendiente Revisión"
                    Case casoDuplicado = casosDuplicadosMap.get(oForm.NIF.trim().unescapeHtml4());
                    if (oConfigDuplicado != null && oConfigDuplicado.CC_CasoEstado__c != null && casoDuplicado != null && casoDuplicado.CC_MailTelfNotif__c == oForm.EMAIL.trim().unescapeHtml4() && casoDuplicado.CC_SuppliedProducto__c == oForm.Producto.trim().unescapeHtml4())
                        oCaso.Status = oConfigDuplicado.CC_CasoEstado__c;
                    else if (oConfig.CC_CasoEstado__c != null)
                        oCaso.Status = oConfig.CC_CasoEstado__c;

                    if (oConfig.CC_CasoCanalEntrada__c != null)
                        oCaso.Origin = oConfig.CC_CasoCanalEntrada__c;

                    if (oConfig.CC_CasoPrioridad__c != null)
                        oCaso.Priority = oConfig.CC_CasoPrioridad__c;

                    if (oConfig.CC_CasoTipoCliente__c != null)
                        oCaso.CC_Tipo_Cliente__c = oConfig.CC_CasoTipoCliente__c;

                    if (oConfig.CC_CasoCanalOperativo__c != null)
                        oCaso.CC_Canal_Operativo__c = oConfig.CC_CasoCanalOperativo__c;

                    if (oConfig.CC_CasoCanalProc__c != null)
                        oCaso.CC_Canal_Procedencia__c = oConfig.CC_CasoCanalProc__c;
                }

                // Preparar el acuse de recibo.
                if (oForm.EMAIL != null)
                {
                    oCaso.CC_AcuseRecibo__c = '1';
                    oCaso.CC_MailTelfNotif__c = oForm.EMAIL.trim().unescapeHtml4();

                    Integer iDelay = 1;
                    List<CC_ConfigNotifCliente__mdt> oConfigAcuse;
                    if (!Test.isRunningTest())
                    {
                        oConfigAcuse = [SELECT Id, CC_DelayMinAcuse__c FROM CC_ConfigNotifCliente__mdt WHERE DeveloperName = 'CC_AcuseRecibo' AND CC_Proceso__c = 'CC_AcuseRecibo' AND CC_Activa__c = true];
                    }else{

                        CC_ConfigNotifCliente__mdt oAux = new CC_ConfigNotifCliente__mdt();
                        oAux.CC_DelayMinAcuse__c = 0;
                        oConfigAcuse = new List<CC_ConfigNotifCliente__mdt>();
                        oConfigAcuse.add(oAux);

                        //oConfigAcuse = [SELECT Id, CC_DelayMinAcuse__c FROM CC_ConfigNotifCliente__mdt WHERE DeveloperName = 'CC_AcuseRecibo' AND CC_Proceso__c = 'CC_AcuseRecibo'];
                    }
                    if (!oConfigAcuse.isEmpty())
                    {
                        if (oConfigAcuse[0].CC_DelayMinAcuse__c != null)
                        {
                            iDelay = Integer.valueOf(oConfigAcuse[0].CC_DelayMinAcuse__c);
                        }
                    }

                    datetime oDelay = datetime.now();
                    oDelay = oDelay.addMinutes(iDelay);

                    oCaso.CC_AcuseDelay__c = oDelay;
                }

                oRes.put('Estado', 'OK');
                oRes.put('Detalle', '');
                oRes.put('Caso', oCaso);

            }else{
                // Sin datos.
                oRes.put('Estado', 'KO');
                oRes.put('Detalle', 'No hay datos de formulario.');
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

    /*
        Método para cerrar la traza padre del proceso. Medir tiempos totales.
    */
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

    /*
        Método para gestionar los contactos de la entrada de formularios web. POR AHORA NO SE UTILIZA.
    */
/*    private static void gestionContactosFormulario (Map<String,String> oContactos, Map<String,CC_WS_Casos.CC_WS_Casos_Input> oForms, Map<String, Object> oParamAux)
    {

        if (oContactos == null)
            return;

        if (oContactos.isEmpty())
            return;

        Map<String,String> oDuplicado = new Map<String,String>();
        Map<String,String> oAuxTrat = new Map<String,String>();
        Map<String,String> oCuentas = new Map<String,String>();
        List<Contact> oContAux = [SELECT Id, CC_Numero_Documento__c, AccountId FROM Contact WHERE CC_Numero_Documento__c IN :oContactos.keySet()];
        for (Contact oAux : oContAux)
        {
            if (oAuxTrat.get(oAux.CC_Numero_Documento__c) == null)
            {
                oAuxTrat.put(oAux.CC_Numero_Documento__c, oAux.Id);
                oCuentas.put(oAux.CC_Numero_Documento__c, oAux.AccountId);
            }else{
                // Documento duplicado. No tratar para realizar creación de uno nuevo.
                oDuplicado.put(oAux.CC_Numero_Documento__c, oAux.Id);
                //oAuxTrat.remove(oAux.CC_Numero_Documento__c);
                //oCuentas.remove(oAux.CC_Numero_Documento__c);
            }
        }
        oContAux = null;

        // Control de duplicados.

        // Borrar duplicados.
        for (String sDup : oDuplicado.keySet())
        {
            oAuxTrat.remove(sDup);
            oCuentas.remove(sDup);
        }

        // Actualizar los ID existentes.
        for (String sDoc : oAuxTrat.keySet())
        {
            if (oContactos.get(sDoc) != null)
            {
                oContactos.put(sDoc, oAuxTrat.get(sDoc));
            }
        }
        oAuxTrat = null;


        // Crear los contactos nuevos.
        List<Contact> oContactNew = new List<Contact>();

        for (String sClave : oForms.keySet())
        {
            Boolean bCrear = false;

            // Comprobar si el contacto ya existe.
            String sDoc = oForms.get(sClave).NIF;
            if (oContactos.get(sDoc) != null)
            {
                if (sDoc == oContactos.get(sDoc))
                {
                    // Crear contacto. No tiene un ID asignado.
                    bCrear = true;
                }
            }else{
                // Crear contacto.
                bCrear = true;
            }

            if (bCrear)
            {
                Contact oNew = new Contact();

                String sNom = '';
                String sApe1 = '';
                String sApe2 = '';
                String sDniC = '';

                if (oForms.get(sClave).Nombre != null)
                    sNom = oForms.get(sClave).Nombre.trim().unescapeHtml4();

                if (oForms.get(sClave).Apellido1 != null)
                    sApe1 = oForms.get(sClave).Apellido1.trim().unescapeHtml4();

                if (oForms.get(sClave).Apellido2 != null)
                    sApe2 = oForms.get(sClave).Apellido2.trim().unescapeHtml4();

                if (oForms.get(sClave).NIF != null)
                    sDniC = oForms.get(sClave).NIF.trim().unescapeHtml4();

                if (sNom != '' || sApe1 != '' || sApe2 != '' || sDniC != '')
                {
                    if (sNom != '')
                    {
                         if (sApe1 == '' && sApe2 == '')
                         {
                            // Sólo nombre.
                            sApe1 = sNom;
                            sNom = '';
                         }
                    }else{
                        if (sApe1 == '' && sApe2 == '')
                        {
                            // Sin nombre ni apellidos.
                            sApe1 = sDniC;
                        }
                    }

                    oNew.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

                    oNew.FirstName = sNom;
                    oNew.LastName = (sApe1 + ' ' + sApe2).trim();

                    if (sDniC != null)
                        oNew.CC_Numero_Documento__c = sDniC;

                    if (oForms.get(sClave).Telefono != null)
                        oNew.Phone = oForms.get(sClave).Telefono.trim().unescapeHtml4();

                    if (oForms.get(sClave).EMAIL != null)
                        oNew.Email = oForms.get(sClave).EMAIL.trim().unescapeHtml4();

                    // Asignar el idioma del caso.
                    if (oParamAux != null)
                    {
                        if (!oParamAux.isEmpty())
                        {
                            if (oParamAux.get('CC_Idioma_FORMWEB') != null)
                            {
                                Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Idioma_FORMWEB');
                                if (oMap.get(oForms.get(sClave).Idioma.trim().unescapeHtml4()) != null)
                                {
                                    oNew.CC_Idioma__c = oMap.get(oForms.get(sClave).Idioma.trim().unescapeHtml4());
                                }else{
                                    // Idioma no configurado. Por defecto 'es'
                                    oNew.CC_Idioma__c = 'es';
                                }
                            }
                        }
                    }

                    oContactNew.add(oNew);
                }
            }
        }

        // Insertar los contactos.
        if (!oContactNew.isEmpty())
        {
            Database.SaveResult[] oResIn = Database.insert(oContactNew, false);
            for (Integer i = 0; i < oResIn.size(); i++)
            {
                if (oResIn[i].isSuccess())
                {
                    // Contacto creado. Asignar a la lista de contactos para actualizar.
                    String sDocIn = oContactNew[i].CC_Numero_Documento__c;

                    if (oContactos.get(sDocIn) != null)
                    {
                        if (oContactos.get(sDocIn) == sDocIn)
                        {
                            // Asignar ID.
                            oContactos.put(sDocIn, oResIn[i].getId());
                        }
                    }
                }
            }
        }
        oContactNew = null;

        // Crear el canal de comunicación de los formularios tratados y que no exista en Salesforce.
        List<String> oContMailAct = new List<String>();
        Map<String,String> oMailCont = new Map<String,String>();
        Map<String,String> oTelCont = new Map<String,String>();
        Map<String,Map<String,String>> oDatosCont = new Map<String,Map<String,String>>();
        Map<String,Map<String,String>> oDatosContTel = new Map<String,Map<String,String>>();

        // Limpiar contactos sin ID y preparar estructura para generar los canales de comunicación.
        for (String sClave : oContactos.keySet())
        {
            if (sClave == oContactos.get(sClave))
            {
                oContactos.remove(sClave);
            }else{
                oContMailAct.add(oContactos.get(sClave));
            }
        }


        for (String sClave : oForms.keySet())
        {
            String sDoc = oForms.get(sClave).NIF;
            if (sDoc != null)
            {
                if (oContactos.get(sDoc) != null)
                {
                    // Actualizar el ContactId.
                    oForms.get(sClave).CC_ContactId = oContactos.get(sDoc);

                    // Actualizar el AccountId.
                    if (oCuentas.get(sDoc) != null)
                        oForms.get(sClave).CC_AccountId = oCuentas.get(sDoc);

                    if (oForms.get(sClave).EMAIL != null)
                    {
                        Map<String,String> oDataInt = new Map<String,String>();
                        oDataInt.put('ContactId', oContactos.get(sDoc));
                        // SE VA A DESCATALOGAR EL ACCOUNTID. POR AHORA NO SE INFORMA EN LOS CANALES DE COMUNICACIÓN.
                        oDataInt.put('MailTelfCaso', oForms.get(sClave).EMAIL);
                        oDatosCont.put(sDoc, oDataInt);
                        oMailCont.put(oContactos.get(sDoc) + '##' + oForms.get(sClave).EMAIL, sDoc);
                    }

                    if (oForms.get(sClave).Telefono != null)
                    {
                        Map<String,String> oDataInt = new Map<String,String>();
                        oDataInt.put('ContactId', oContactos.get(sDoc));
                        // SE VA A DESCATALOGAR EL ACCOUNTID. POR AHORA NO SE INFORMA EN LOS CANALES DE COMUNICACIÓN.
                        oDataInt.put('MailTelfCaso', oForms.get(sClave).Telefono);
                        oDatosContTel.put(sDoc, oDataInt);
                        oTelCont.put(oContactos.get(sDoc) + '##' + oForms.get(sClave).Telefono, sDoc);
                    }
                }
            }
        }


        CC_NotifSegCaso.crearCanalesComunicacion ('EMAIL', oContMailAct, oMailCont, oDatosCont);
        oMailCont =  null;
        oDatosCont = null;

        CC_NotifSegCaso.crearCanalesComunicacion ('TELEFONO', oContMailAct, oTelCont, oDatosContTel);
        oTelCont = null;
        oDatosContTel = null;

        return;
    }
*/
    /*
        Método para gestionar los contactos de la entrada de formularios web.
    */
    private static void gestionCuentasContactosFormulario (Map<String,String> oContactos, Map<String,CC_WS_Casos.CC_WS_Casos_Input> oForms, Map<String, Object> oParamAux, String sTipoNif)
    {

        if (oContactos == null)
            return;

        if (oContactos.isEmpty())
            return;

        // Buscar cuentas existentes con NumPer en Salesforce.
        Map<String,String> oCuentas = new Map<String,String>();
        Map<String,String> oCuentasId = new Map<String,String>();
        Map<String,String> oCuentasDup = new Map<String,String>();
        Map<String,String> oCuentasDupId = new Map<String,String>();

        List<Account> oContAux = [SELECT Id, CC_Numero_Documento__c, CC_NumPerso__c FROM Account WHERE CC_Numero_Documento__c IN :oContactos.keySet() AND CC_NumPerso__c <> '' AND CC_NumPerso__c <> NULL];
        for (Account oAux : oContAux)
        {
            if (oCuentas.get(oAux.CC_Numero_Documento__c) == null)
            {
                oCuentas.put(oAux.CC_Numero_Documento__c, oAux.Id);
                oCuentasId.put(oAux.Id, oAux.CC_Numero_Documento__c);
            }else{
                // Documento duplicado en ALF. Buscar / crear un contacto no ALF.
                oCuentasDup.put(oAux.CC_Numero_Documento__c, oAux.Id);
            }
        }
        oContAux = null;

        // Aquellas cuentas duplicadas de ALF, se busca si existe una cuenta con NIF y sin NumPer.
        if (!oCuentasDup.isEmpty())
        {
            oContAux = [SELECT Id, CC_Numero_Documento__c, CC_NumPerso__c FROM Account WHERE CC_Numero_Documento__c IN :oCuentasDup.keySet() AND (CC_NumPerso__c = '' OR CC_NumPerso__c = NULL) ORDER BY CreatedDate ASC];
            oCuentasDup.clear();
            for (Account oAux : oContAux)
            {
                if (oCuentas.get(oAux.CC_Numero_Documento__c) == null)
                {
                    oCuentas.put(oAux.CC_Numero_Documento__c, oAux.Id);
                    oCuentasId.put(oAux.Id, oAux.CC_Numero_Documento__c);
                }else{
                    // Documento duplicado en Salesforce, nos quedamos el primero.
                    oCuentasDup.put(oAux.CC_Numero_Documento__c, oAux.Id);
                    oCuentasDupId.put(oAux.Id, oAux.CC_Numero_Documento__c);
                }
            }
            oContAux = null;
        }

        /*
            oCuentas
                -> Cuentas encontradas por NIF y con NumPer único en Salesforce.
                -> Cuentas encontradas por NIF y sin NumPer único en Salesforce.
            oCuentasDup
                -> Cuentas encontradas por NIF y sin NumPer (existen duplicados). Nos quedamos con el último creado.
        */

        // Crear los nuevos clientes no encontrados (Cuenta + Contacto).
        List<Account> oNewAcc = new List<Account>();
        for (String sClave : oForms.keySet())
        {
            Boolean bCrear = false;
			//Validacion CIF/NIF y logica de creación Acc, Cont, Pers Acc.
            if (oForms.get(sClave).NIF.trim().unescapeHtml4()!=''){
                sTipoNif = CC_MetodosUtiles.validarCIFNIF(oForms.get(sClave).NIF.trim().unescapeHtml4());
            }
            // Comprobar que hay que crear Cuenta y Contacto. Datos no encontrados.
            String sDoc = oForms.get(sClave).NIF;
            if (oCuentas.get(sDoc) == null && oCuentasDup.get(sDoc) == null)
            {
                // Crear cuenta + contacto.
                bCrear = true;
            }

            if (bCrear)
            {
                Account oNew = new Account();

                String sNom = '';
                String sApe1 = '';
                String sApe2 = '';
                String sDniC = '';

                if (oForms.get(sClave).Nombre != null)
                    sNom = oForms.get(sClave).Nombre.trim().unescapeHtml4();

                if (oForms.get(sClave).Apellido1 != null)
                    sApe1 = oForms.get(sClave).Apellido1.trim().unescapeHtml4();

                if (oForms.get(sClave).Apellido2 != null)
                    sApe2 = oForms.get(sClave).Apellido2.trim().unescapeHtml4();

                if (oForms.get(sClave).NIF != null)
                    sDniC = oForms.get(sClave).NIF.trim().unescapeHtml4();

                sNom = (sNom + ' ' + sApe1 + ' ' + sApe2).trim();
                if (sNom.length() > 255)
                    sNom = sNom.substring(0,255);

                if (sNom != '' && sDniC != '')
                {
                    // Nuevo tratamiento PersonAccount y BusinessAccount.
                    if (sTipoNif == 'CIF') {
                    	oNew.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                    	oNew.Name = sNom;
                    } else {
                        oNew.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                        if (oForms.get(sClave).Nombre != null)
                            oNew.FirstName = oForms.get(sClave).Nombre.trim().unescapeHtml4();

                        if (oForms.get(sClave).Apellido1 != null) {
                            oNew.LastName = oForms.get(sClave).Apellido1.trim().unescapeHtml4();
                            if (oForms.get(sClave).Apellido2 != null) {
                                oNew.LastName += ' ' + oForms.get(sClave).Apellido2.trim().unescapeHtml4();
                            }
                        }

                        if (oForms.get(sClave).EMAIL != null)
                            oNew.PersonEmail = oForms.get(sClave).EMAIL.trim().unescapeHtml4();

                        if (oForms.get(sClave).Idioma != null)
                            oNew.CC_Idioma__pc = oForms.get(sClave).Idioma.trim().unescapeHtml4();
                        else
                            oNew.CC_Idioma__pc = 'es';

                        if (oForms.get(sClave).NIF != null)
                            oNew.CC_Numero_Documento__pc = oForms.get(sClave).NIF.trim().unescapeHtml4();
                    }
                    oNew.CC_Numero_Documento__c = sDniC;
                    if (oForms.get(sClave).Telefono != null)
                        oNew.Phone = oForms.get(sClave).Telefono.trim().unescapeHtml4();

                    if (oForms.get(sClave).EMAIL != null)
                        oNew.CC_Email__c = oForms.get(sClave).EMAIL.trim().unescapeHtml4();

                    oNewAcc.add(oNew);
                }
            }
        }

        /* Crear los nuevos clientes y actualizar datos de IDs creados en la estructura siguiente:
            oCuentas
                -> Cuentas encontradas por NIF y con NumPer único en Salesforce.
                -> Cuentas encontradas por NIF y sin NumPer único en Salesforce.
            oCuentasDup
                -> Cuentas encontradas por NIF y sin NumPer (existen duplicados). Nos quedamos con el último creado.
        */
        if (!oNewAcc.isEmpty())
        {
            Database.SaveResult[] oResIn = Database.insert(oNewAcc, false);
            for (Integer i = 0; i < oResIn.size(); i++)
            {
                if (oResIn[i].isSuccess())
                {
                    // Contacto creado. Asignar a la lista de contactos para actualizar.
                    String sDocIn = oNewAcc[i].CC_Numero_Documento__c;
                    String sIdIn = oResIn[i].getId();

                    oCuentasDup.put(sDocIn, sIdIn);
                    oCuentasDupId.put(sIdIn, sDocIn);
                }
            }
        }
        oNewAcc = null;

        // Buscar los contactos de esas cuentas.
        Set<String> oSearch = new Set<String>();
        if (!oCuentasId.isEmpty())
            oSearch.addAll(oCuentasId.keySet());
        if (!oCuentasDupId.isEmpty())
            oSearch.addAll(oCuentasDupId.keySet());

        Map<String, List<Contact>> oAccContacts = new Map<String, List<Contact>>();

        if (!oSearch.isEmpty())
        {
            List<Contact> oContAcc = [SELECT Id, Name, CC_Numero_Documento__c, CC_NumPerso__c, AccountId FROM Contact WHERE AccountId IN :oSearch];
            for (Contact oCAux : oContAcc)
            {
                if (oAccContacts.get(oCAux.AccountId) != null)
                {
                    // Asignar contacto a la lista.
                    List<Contact> oNew = oAccContacts.get(oCAux.AccountId);
                    oNew.add(oCAux);
                    oAccContacts.put(oCAux.AccountId, oNew);
                }else{
                    // Crear lista y asignarla.
                    List<Contact> oNew = new List<Contact>();
                    oNew.add(oCAux);
                    oAccContacts.put(oCAux.AccountId, oNew);
                }
            }
        }
        oSearch = null;
        oCuentasId = null;
        oCuentasDupId = null;

        // Crear los contactos nuevos.
        List<Contact> oContactNew = new List<Contact>();
        for (String sClave : oForms.keySet())
        {
            Boolean bCrear = false;
			//Validacion CIF/NIF y logica de creación Acc, Cont, Pers Acc.
            if (oForms.get(sClave).NIF.trim().unescapeHtml4()!=''){
                sTipoNif = CC_MetodosUtiles.validarCIFNIF(oForms.get(sClave).NIF.trim().unescapeHtml4());
            }
            // Comprobaciones para crear el contacto.
            String sDoc = oForms.get(sClave).NIF;
            String sAccId = '';
            String sNom = '';
            String sApe1 = '';
            String sApe2 = '';
            String sDniC = '';

            if (oForms.get(sClave).Nombre != null)
                sNom = oForms.get(sClave).Nombre.trim().unescapeHtml4();

            if (oForms.get(sClave).Apellido1 != null)
                sApe1 = oForms.get(sClave).Apellido1.trim().unescapeHtml4();

            if (oForms.get(sClave).Apellido2 != null)
                sApe2 = oForms.get(sClave).Apellido2.trim().unescapeHtml4();

            if (oForms.get(sClave).NIF != null)
                sDniC = oForms.get(sClave).NIF.trim().unescapeHtml4();

            if (oCuentasDup.get(sDoc) != null)
            {
                sAccId = oCuentasDup.get(sDoc);
            }else if (oCuentas.get(sDoc) != null) {
                sAccId = oCuentas.get(sDoc);
            }

            if (oAccContacts.get(sAccId) == null)
            {
                bCrear = true;
            }else{

                Boolean bEncontrado = false;
                String sFullName = sNom + ' ' + sApe1 + ' ' + sApe2;
                sFullName = sFullName.trim();

                // Recorrer los contactos del cliente y comprobar si existe creado de forma potencial.
                List<Contact> oDataC = oAccContacts.get(sAccId);
                for (Contact oConUn : oDataC)
                {
                    if (sDniC == oConUn.CC_Numero_Documento__c)
                    {
                        // Contacto existente.
                        oContactos.put(sDoc, oConUn.Id);
                        bEncontrado = true;
                        break;
                    }

                    if (sFullName == oConUn.Name)
                    {
                        // Contacto existente con el mismo nombre.
                        oContactos.put(sDoc, oConUn.Id);
                        bEncontrado = true;
                        break;
                    }
                }

                if (!bEncontrado)
                    bCrear = true;
            }

            // Para clientes de tipo PersonAccount no generamos contacto, ya lo hace el PA.
            if (sTipoNif != 'CIF') {
                bCrear = false;
            }

            if (bCrear)
            {
                Contact oNew = new Contact();

                if (sNom != '' || sApe1 != '' || sApe2 != '' || sDniC != '')
                {
                    if (sNom != '')
                    {
                         if (sApe1 == '' && sApe2 == '')
                         {
                            // Sólo nombre.
                            sApe1 = sNom;
                            sNom = '';
                         }
                    }else{
                        if (sApe1 == '' && sApe2 == '')
                        {
                            // Sin nombre ni apellidos.
                            sApe1 = sDniC;
                        }
                    }

                    oNew.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

                    oNew.FirstName = sNom;
                    oNew.LastName = (sApe1 + ' ' + sApe2).trim();
                    oNew.AccountId = sAccId;

                    if (sDniC != null)
                        oNew.CC_Numero_Documento__c = sDniC;

                    if (oForms.get(sClave).Telefono != null)
                        oNew.Phone = oForms.get(sClave).Telefono.trim().unescapeHtml4();

                    if (oForms.get(sClave).EMAIL != null)
                        oNew.Email = oForms.get(sClave).EMAIL.trim().unescapeHtml4();

                    // Asignar el idioma del caso.
                    if (oParamAux != null)
                    {
                        if (!oParamAux.isEmpty())
                        {
                            if (oParamAux.get('CC_Idioma_FORMWEB') != null)
                            {
                                Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Idioma_FORMWEB');
                                if (oMap.get(oForms.get(sClave).Idioma.trim().unescapeHtml4()) != null)
                                {
                                    oNew.CC_Idioma__c = oMap.get(oForms.get(sClave).Idioma.trim().unescapeHtml4());
                                }else{
                                    // Idioma no configurado. Por defecto 'es'
                                    oNew.CC_Idioma__c = 'es';
                                }
                            }
                        }
                    }

                    oContactNew.add(oNew);
                }
            }
        }
        oAccContacts = null;

        // Insertar los contactos.
        if (!oContactNew.isEmpty())
        {
            Database.SaveResult[] oResIn = Database.insert(oContactNew, false);
            for (Integer i = 0; i < oResIn.size(); i++)
            {
                if (oResIn[i].isSuccess())
                {
                    // Contacto creado. Asignar a la lista de contactos para actualizar.
                    String sDocIn = oContactNew[i].CC_Numero_Documento__c;

                    if (oContactos.get(sDocIn) != null)
                    {
                        if (oContactos.get(sDocIn) == sDocIn)
                        {
                            // Asignar ID.
                            oContactos.put(sDocIn, oResIn[i].getId());
                        }
                    }
                }
            }
        }
        oContactNew = null;

        // Crear el canal de comunicación de los formularios tratados y que no exista en Salesforce.
        List<String> oContMailAct = new List<String>();
        Map<String,String> oMailCont = new Map<String,String>();
        Map<String,String> oTelCont = new Map<String,String>();
        Map<String,Map<String,String>> oDatosCont = new Map<String,Map<String,String>>();
        Map<String,Map<String,String>> oDatosContTel = new Map<String,Map<String,String>>();

        // Limpiar contactos sin ID y preparar estructura para generar los canales de comunicación.
        for (String sClave : oContactos.keySet())
        {
            if (sClave == oContactos.get(sClave))
            {
                oContactos.remove(sClave);
            }else{
                oContMailAct.add(oContactos.get(sClave));
            }
        }

        for (String sClave : oForms.keySet())
        {
            String sDoc = oForms.get(sClave).NIF;
            if (sDoc != null)
            {
                // Actualizar el AccountId.
                /*if (oCuentas.get(sDoc) != null) {
                    oForms.get(sClave).CC_AccountId = oCuentas.get(sDoc);
                }
                else if (oCuentasDup.get(sDoc) != null){
                    oForms.get(sClave).CC_AccountId = oCuentasDup.get(sDoc);
                }*/
                if (oContactos.get(sDoc) != null)
                {
                    // Actualizar el ContactId.
                    oForms.get(sClave).CC_ContactId = oContactos.get(sDoc);

                    // Actualizar el AccountId.
                    if (oCuentas.get(sDoc) != null)
                        oForms.get(sClave).CC_AccountId = oCuentas.get(sDoc);

                    if (oForms.get(sClave).EMAIL != null)
                    {
                        Map<String,String> oDataInt = new Map<String,String>();
                        oDataInt.put('ContactId', oContactos.get(sDoc));
                        // SE VA A DESCATALOGAR EL ACCOUNTID. POR AHORA NO SE INFORMA EN LOS CANALES DE COMUNICACIÓN.
                        oDataInt.put('MailTelfCaso', oForms.get(sClave).EMAIL);
                        oDatosCont.put(sDoc, oDataInt);
                        oMailCont.put(oContactos.get(sDoc) + '##' + oForms.get(sClave).EMAIL, sDoc);
                    }

                    if (oForms.get(sClave).Telefono != null)
                    {
                        Map<String,String> oDataInt = new Map<String,String>();
                        oDataInt.put('ContactId', oContactos.get(sDoc));
                        // SE VA A DESCATALOGAR EL ACCOUNTID. POR AHORA NO SE INFORMA EN LOS CANALES DE COMUNICACIÓN.
                        oDataInt.put('MailTelfCaso', oForms.get(sClave).Telefono);
                        oDatosContTel.put(sDoc, oDataInt);
                        oTelCont.put(oContactos.get(sDoc) + '##' + oForms.get(sClave).Telefono, sDoc);
                    }
                }
            }
        }

        CC_NotifSegCaso.crearCanalesComunicacion ('EMAIL', oContMailAct, oMailCont, oDatosCont);
        oMailCont =  null;
        oDatosCont = null;

        CC_NotifSegCaso.crearCanalesComunicacion ('TELEFONO', oContMailAct, oTelCont, oDatosContTel);
        oTelCont = null;
        oDatosContTel = null;

        return;
    }

    /*
        Método para recuperar los datos de formularios a buscar su configuración.
    */
    static private void getDatosFormularioConfigurados(Map<String,CC_WS_Casos.CC_WS_Casos_Input> oMapForm, Set<String> oApp, Set<String> oTipificacionWeb, Set<String> oValTrad, Map<String,Map<String,String>> oMapTipificacion)
    {

        if (oMapForm == null || oApp == null || oTipificacionWeb == null || oValTrad == null)
            return;

        if (!oMapForm.isEmpty())
        {
            for (String sForm : oMapForm.keySet())
            {
                if (oMapForm.get(sForm) != null)
                {
                    if (oMapForm.get(sForm).Aplicacion.trim().unescapeHtml4() != null)
                    {
                        oApp.add(oMapForm.get(sForm).Aplicacion.trim().unescapeHtml4());
                    }

                    if (oMapForm.get(sForm).CC_ClasificacionWeb != null)
                    {
                        oTipificacionWeb.add(oMapForm.get(sForm).CC_ClasificacionWeb);
                    }

                    if (oMapForm.get(sForm).Motivo != null)
                    {
                        if (oMapForm.get(sForm).Motivo.trim().unescapeHtml4() != '')
                        {
                            //oMotivoWeb.add(oMapForm.get(sForm).Motivo.trim().unescapeHtml4());
                            oValTrad.add(oMapForm.get(sForm).Motivo.trim().unescapeHtml4());
                        }
                    }

                    if (oMapForm.get(sForm).Producto != null)
                    {
                        if (oMapForm.get(sForm).Producto.trim().unescapeHtml4() != '')
                        {
                            //oProductoWeb.add(oMapForm.get(sForm).Producto.trim().unescapeHtml4());
                            oValTrad.add(oMapForm.get(sForm).Producto.trim().unescapeHtml4());
                        }
                    }

                    if (oMapForm.get(sForm).Ambito != null)
                    {
                        if (oMapForm.get(sForm).Ambito.trim().unescapeHtml4() != '')
                        {
                            //oAmbitoWeb.add(oMapForm.get(sForm).Ambito.trim().unescapeHtml4());
                            oValTrad.add(oMapForm.get(sForm).Ambito.trim().unescapeHtml4());
                        }
                    }
                }
            }

            // Recuperar conversiones MCC.
            if (!oTipificacionWeb.isEmpty())
            {
                oMapTipificacion = getTipificacionesCaso(oTipificacionWeb);
            }
        }


        return;
    }

    /*
        Método para recuperar la configuración de reglas de asignación y motivos excluidos del portal.
    */
    static private void getConfigAppFormulario(Set<String> oApp, Map<String,String> oMapRules, Map<String,String> oMotivosExcl)
    {

        if (oApp == null || oMapRules == null || oMotivosExcl == null)
            return;

        Set<String> oRule = new Set<String>();

        if (!oApp.isEmpty())
        {
            // Recorrer las aplicaciones para obtener las reglas.
            for (String sApp : oApp)
            {
                if (sApp != '')
                {
                    CC_Config_FormWeb__mdt oConfigApp = getConfigApp (sApp);
                    if (oConfigApp != null)
                    {
                        if (oConfigApp.CC_ReglaAssigCaso__c != null)
                        {
                            if (oConfigApp.CC_ReglaAssigCaso__c != '')
                            {
                                oRule.add(oConfigApp.CC_ReglaAssigCaso__c);
                            }
                        }

                        if (oConfigApp.CC_MotivosExcl__c != null)
                        {
                            if (oConfigApp.CC_MotivosExcl__c != '')
                            {
                                oMotivosExcl.put(sApp,oConfigApp.CC_MotivosExcl__c);
                            }
                        }
                    }
                }
            }

            // Recuperar la configuración de las reglas de asignación de casos.
            if (!oRule.isEmpty())
            {
                List<AssignmentRule> oReglasAss = [select id, Name from AssignmentRule where SobjectType = 'Case' AND Name = :oRule];
                for (AssignmentRule oAux : oReglasAss)
                {
                    oMapRules.put(oAux.Name, oAux.Id);
                }
            }

            oRule = null;
        }


        return;
    }

    /*
        Método para excluir formularios no compatibles con el Web Service.
    */
    static private Boolean excluirFormulariosNoCompatibles (Map<String,CC_WS_Casos.CC_WS_Casos_Input> oMapForm, Map<String,String> oMotivosExcl, List<CC_TrazaInt__c> oTraza, List<CC_WS_Casos.CC_WS_Casos_Output> oRes, String sTrazaOrig, CC_InterfaceSettings__mdt oConfig)
    {

        Boolean bTrazaOk = true;

        if (oMapForm == null || oMotivosExcl == null)
            return true;

        // Controlar motivos excluidos.
        if (!oMapForm.isEmpty() && !oMotivosExcl.isEmpty())
        {
            for (String sForm : oMapForm.keySet())
            {
                if (oMapForm.get(sForm) != null)
                {
                    String sApp = '';
                    String sMotivo = '';

                    if (oMapForm.get(sForm).Aplicacion != null)
                        if (oMapForm.get(sForm).Aplicacion != '')
                            sApp = oMapForm.get(sForm).Aplicacion.trim().unescapeHtml4();

                    if (oMapForm.get(sForm).Motivo != null)
                        if (oMapForm.get(sForm).Motivo != '')
                            sMotivo = oMapForm.get(sForm).Motivo.trim().unescapeHtml4();

                    if (sApp != '' && sMotivo != '')
                    {
                        if (oMotivosExcl.get(sApp) != '')
                        {
                            if (oMotivosExcl.get(sApp).contains(sMotivo))
                            {
                                // Error validación datos entrada.
                                String sCodErr = '3';
                                String sDetErr = 'Error al preparar el caso. Motivo no permitido.';
                                bTrazaOk = false;

                                CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
                                oAux.sCodError = sCodErr;
                                oAux.sDetalleError = sDetErr;
                                oAux.sNumCaso = '';
                                oAux.sRefUser = oMapForm.get(sForm).REFUSUARIO;
                                oAux.sNIF = oMapForm.get(sForm).NIF;
                                oAux.sTexto = oMapForm.get(sForm).Texto;
                                oRes.add(oAux);

                                String sIdent = '';
                                if (oMapForm.get(sForm).REFUSUARIO != null)
                                    sIdent = oMapForm.get(sForm).REFUSUARIO;
                                else
                                    sIdent = sTrazaOrig;

                                if (oTraza != null)
                                {
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Casos_DET', sIdent, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }

                                // Quitar el formulario.
                                oMapForm.remove(sForm);
                            }
                        }
                    }
                }
            }
        }


        return bTrazaOk;
    }

    /*
        Método publicado para crear casos.
    */
    @HttpPost
    global static List<CC_WS_Casos.CC_WS_Casos_Output> createCase(List<CC_WS_Casos.CC_WS_Casos_Input> oDataIn)
    {
        String sTipoNif = '';
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = new List<CC_WS_Casos.CC_WS_Casos_Output>();
        Map<String,CC_WS_Casos.CC_WS_Casos_Input> oMapForm = new Map<String,CC_WS_Casos.CC_WS_Casos_Input>();
        List<Case> oNewCase = new List<Case>();
        Map<String,String> oMapRules = new Map<String,String>();
        Map<String,Map<String,String>> oMapTipificacion = new Map<String,Map<String,String>>();
        Map<String,Object> oParamLOV = new Map<String, Object>();
        Map<String,String> oMotivosExcl = new Map<String,String>();

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

        // Lista de NIFs de los formularios.
		List<String> nifList = new List<String>();

		// Casos potencialmente duplicados.
		Map<String, Case> casosDuplicadosMap = new Map<String, Case>();

        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_WS_Casos');
        } catch (Exception e) {
            oTraza = null;
        }

        if (oConfig == null)
        {
            // Interfaz no configurada o activa.
            CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
            oAux.sCodError = '9999';
            oAux.sDetalleError = 'Proceso inactivo en Salesforce.';
            oAux.sNumCaso = '';
            oAux.sRefUser = '';
            oAux.sNIF = '';
            oAux.sTexto = '';
            oRes.add(oAux);
            return oRes;
        }

        // Creamos la traza padre para medir tiempos totales.
        oTrazaProc = crearTrazaPadre (oConfig, 'CC_WS_Casos', 'CC_WS_Casos', '', oDataIn);
        String sTrazaOrig = '';
        if (oTrazaProc != null)
            sTrazaOrig = oTrazaProc.Id;

        try {

            // OLD. FORMA DE RECUPERAR DATOS SIN INPUT.
            // Recuperar parámetros de entrada.
            //RestRequest req = RestContext.request;
            //Blob body = req.requestBody;
            //String requestString = body.toString();

            //CC_WS_Casos_Input rw = (CC_WS_Casos_Input)JSON.deserialize(requestString,CC_WS_Casos_Input.class);

            // Control de datos.
            if (oDataIn != null)
            {
                // Obtenemos la blacklist de NIF para descartar las peticiones provenientes del robot de comprobación
                List<String> blacklistNif = new List<String>();
                for (CC_Valores__mdt valor : [SELECT CC_Valor__c FROM CC_Valores__mdt WHERE CC_Lista__c = 'CC_MailCenter_Blacklist_NIF']) {
                    blacklistNif.add(valor.CC_Valor__c);
                }

                for (CC_WS_Casos.CC_WS_Casos_Input oForm : oDataIn)
                {
                    sTipoNif = CC_MetodosUtiles.validarCIFNIF(oForm.NIF.trim().unescapeHtml4());
                    String sValido = validarDatosEntrada (oForm);
                    if (sValido == 'OK')
                    {
                        if (oForm.NIF != null && oForm.NIF.trim().unescapeHtml4() != '') {
                            // Si el NIF está incluido en la blacklist de NIFs, significa que la petición proviene del robot de comprobación y se descarta.
                            if (blacklistNif.contains(oForm.NIF.trim().unescapeHtml4())) {
                                String sCodErr = '4';
                                String sDetErr = 'NIF incluido en la lista CC_MailCenter_Blacklist_NIF. Petición proveniente del robot de comprobación.';
                                bTrazaOk = false;

                                CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
                                oAux.sCodError = sCodErr;
                                oAux.sDetalleError = sDetErr;
                                oAux.sNumCaso = '';
                                oAux.sRefUser = oForm.REFUSUARIO;
                                oAux.sNIF = oForm.NIF;
                                oAux.sTexto = oForm.Texto;
                                oAux.sAccountId = '';
                                oAux.sContactId = '';
                                oRes.add(oAux);

                                String sIdent = '';
                                if (oForm.REFUSUARIO != null)
                                    sIdent = oForm.REFUSUARIO;
                                else
                                    sIdent = sTrazaOrig;

                                if (oTraza != null)
                                {
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Casos_DET', sIdent, sTrazaOrig, oForm, oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }
                            }
                            else {
                                // Registro para a crear datos.
                                oMapForm.put(oForm.REFUSUARIO.trim().unescapeHtml4(), oForm);
                                // Preparar los contactos a crear / utilizar.
                                oContForm.put(oForm.NIF.trim().unescapeHtml4(),oForm.NIF.trim().unescapeHtml4());
                                // Recopilar los NIF de los formularios para la posterior comprobación de casos duplicados.
                                nifList.add(oForm.NIF.trim().unescapeHtml4());
                            }
                        }
                    } else {
                        // Error validación datos entrada.
                        String sCodErr = '1';
                        String sDetErr = 'Datos obligatorios no informados.';
                        bTrazaOk = false;

                        CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
                        oAux.sCodError = sCodErr;
                        oAux.sDetalleError = sDetErr;
                        oAux.sNumCaso = '';
                        oAux.sRefUser = oForm.REFUSUARIO;
                        oAux.sNIF = oForm.NIF;
                        oAux.sTexto = oForm.Texto;
						oAux.sAccountId = '';
                        oAux.sContactId = '';
                        oRes.add(oAux);

                        String sIdent = '';
                        if (oForm.REFUSUARIO != null)
                            sIdent = oForm.REFUSUARIO;
                        else
                            sIdent = sTrazaOrig;

                        if (oTraza != null)
                        {
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Casos_DET', sIdent, sTrazaOrig, oForm, oAux, false, sCodErr, sDetErr);
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
            if (!oMapForm.isEmpty())
            {
                Set<String> oApp = new Set<String>();
                Set<String> oTipificacionWeb = new Set<String>();
                Set<String> oValTrad = new Set<String>();

                getDatosFormularioConfigurados(oMapForm, oApp, oTipificacionWeb, oValTrad, oMapTipificacion);

                // Recuperar conversiones MCC.
                if (!oTipificacionWeb.isEmpty())
                {
                    oMapTipificacion = getTipificacionesCaso(oTipificacionWeb);
                }
                oTipificacionWeb = null;


                // Recuperar listas de valores.
                if (!oValTrad.isEmpty())
                {
                    Set<String> oLOV = new Set<String>();
                    oLOV.add('CC_MotivoWeb');
                    oLOV.add('CC_ProductoWeb');
                    oLOV.add('CC_AmbitoWeb');
                    oParamLOV = CC_MetodosUtiles.getLOVWithVal(oLOV, oValTrad);
                }
                oValTrad = null;

                // Recuperar reglas de asignación y motivos excluidos.
                getConfigAppFormulario(oApp, oMapRules, oMotivosExcl);

                // Excluir formularios no compatibles con esta entrada.
                Boolean bAux = excluirFormulariosNoCompatibles (oMapForm, oMotivosExcl, oTraza, oRes, sTrazaOrig, oConfig);
                if (!bAux)
                    bTrazaOk = false;

                oApp = null;
                oMotivosExcl = null;

                // Inicializar el objeto de listas de valores y parámetros.
                List<String> oLista = new List<String>();
                oLista.add('CC_Idioma_FORMWEB');
                oParamAux = CC_MetodosUtiles.getLOVMeta(oLista);
                oLista = null;

                // Añadir la configuración de reglas de asignación.
                if (!oMapRules.isEmpty())
                {
                    oParamAux.put('CC_ReglasAss', oMapRules);
                }
                oMapRules = null;

                // Añadir las LOV a los parámetros.
                if (!oParamLOV.isEmpty())
                {
                    oParamAux.putAll(oParamLOV);
                }
                oParamLOV = null;
            }

            // Preparar creación de los casos.
            if (!oMapForm.isEmpty())
            {
                // Buscar contactos y crear los que no existan.
                if (!oContForm.isEmpty())
                {
                    //gestionContactosFormulario (oContForm, oMapForm, oParamAux);
                    gestionCuentasContactosFormulario (oContForm, oMapForm, oParamAux, sTipoNif);
                }
                oContForm = null;

				// Búsqueda de casos potencialmente duplicados.
                Decimal tiempoDuplicidadDecimal = [SELECT CC_Tiempo_Duplicidad__c FROM CC_Config_FormWeb_Duplicado__mdt WHERE CC_Aplicacion__c = 'FORMWEB' LIMIT 1].CC_Tiempo_Duplicidad__c;
                Integer tiempoDuplicidad = tiempoDuplicidadDecimal != null ? tiempoDuplicidadDecimal.intValue() : 0;
				for (Case oCasoDuplicado : [SELECT Id, CC_Numero_Documento__c, CC_MailTelfNotif__c, CC_SuppliedProducto__c, CC_RefExterna__c, CreatedDate FROM Case WHERE CC_Numero_Documento__c in :nifList AND CreatedDate >= :Datetime.now().addMinutes(-tiempoDuplicidad) ORDER BY CreatedDate ASC]) {
					casosDuplicadosMap.put(oCasoDuplicado.CC_Numero_Documento__c, oCasoDuplicado);
				}

                // Procesar los formularios.
                for (String sForm : oMapForm.keySet())
                {
                    if (oMapForm.get(sForm) != null)
                    {
                        String sEstado = '';
                        String sDetalle = '';
                        Case oCaso;

                        Map<String,Object> oResCaso = prepararCaso (oMapForm.get(sForm), oParamAux, oMapTipificacion, casosDuplicadosMap, sTipoNif);
                        for (String sRet : oResCaso.keySet())
                        {
                            if (sRet == 'Estado')
                            {
                                if (oResCaso.get(sRet) != null)
                                {
                                    sEstado = (String)oResCaso.get(sRet);
                                }
                            }

                            if (sRet == 'Detalle')
                            {
                                if (oResCaso.get(sRet) != null)
                                {
                                    sDetalle = (String)oResCaso.get(sRet);
                                }
                            }

                            if (sRet == 'Caso')
                            {
                                if (oResCaso.get(sRet) != null)
                                {
                                    oCaso = (Case)oResCaso.get(sRet);
                                }
                            }
                        }

                        if (sEstado == 'OK')
                        {
                            if (oCaso != null)
                            {
                                oNewCase.add(oCaso);
                            }else{
                                // Error al preparar el caso.
                                String sCodErr = '2';
                                String sDetErr = 'Error al preparar el caso. ' + sDetalle;
                                bTrazaOk = false;

                                CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
                                oAux.sCodError = sCodErr;
                                oAux.sDetalleError = sDetErr;
                                oAux.sNumCaso = '';
                                oAux.sRefUser = sForm;
                                oAux.sNIF = oMapForm.get(sForm).NIF;
                                oAux.sTexto = oMapForm.get(sForm).Texto;
                                oRes.add(oAux);

                                if (oTraza != null)
                                {
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Casos_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }
                            }
                        }else{
                            // Error al preparar el caso.
                            String sCodErr = '3';
                            String sDetErr = 'Error al preparar el caso. ' + sDetalle;
                            bTrazaOk = false;

                            CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
                            oAux.sCodError = sCodErr;
                            oAux.sDetalleError = sDetErr;
                            oAux.sNumCaso = '';
                            oAux.sRefUser = sForm;
                            oAux.sNIF = oMapForm.get(sForm).NIF;
                            oAux.sTexto = oMapForm.get(sForm).Texto;
                            oRes.add(oAux);

                            if (oTraza != null)
                            {
                                CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Casos_DET', sForm, sTrazaOrig, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
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

            if (!oNewCase.isEmpty())
            {
                Schema.SObjectField oCampoSearch = Case.Fields.CC_RefExterna__c;
                Database.UpsertResult[] oResUp = Database.upsert(oNewCase, oCampoSearch, false);

                for (Integer i = 0, iSize = oResUp.size(); i < iSize; i++)
                {
                    if (oResUp[i].isSuccess())
                    {
                        // Inserción correcta.
                        oRefCasos.add(oNewCase[i].CC_RefExterna__c);

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

                        CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
                        oAux.sCodError = sCodErr;
                        oAux.sDetalleError = sDetErr;
                        oAux.sNumCaso = '';
                        oAux.sRefUser = oNewCase[i].CC_RefExterna__c;
                        oAux.sNIF = oMapForm.get(oNewCase[i].CC_RefExterna__c).NIF;
                        oAux.sTexto = oMapForm.get(oNewCase[i].CC_RefExterna__c).Texto;
                        oRes.add(oAux);

                        if (oTraza != null)
                        {
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Casos_DET', oNewCase[i].CC_RefExterna__c, sTrazaOrig, oNewCase[i], oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
            }

            // Buscar los registros insertados para devolver el número de caso.
            if (!oRefCasos.isEmpty())
            {
                List<ID> oCasosIdent = new List<ID>();
                List<Case> oCasosUp = [SELECT Id, CaseNumber, CC_RefExterna__c, AccountId, ContactId FROM Case WHERE CC_RefExterna__c IN :oRefCasos];
                for (Case oCasoAux : oCasosUp)
                {
                    CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
                    oAux.sCodError = '0';
                    oAux.sDetalleError = '';
                    oAux.sNumCaso = oCasoAux.CaseNumber;
                    oAux.sRefUser = oCasoAux.CC_RefExterna__c;
                    oAux.sNIF = oMapForm.get(oCasoAux.CC_RefExterna__c).NIF;
                    oAux.sTexto = oMapForm.get(oCasoAux.CC_RefExterna__c).Texto;
                    oAux.sCaseId = oCasoAux.Id;
                    oAux.sAccountId = oCasoAux.AccountId;
                    oAux.sContactId = oCasoAux.ContactId;
                    oRes.add(oAux);

                    if (oTraza != null)
                    {
                        CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'CC_WS_Casos_DET', oCasoAux.CC_RefExterna__c, sTrazaOrig, oCasoAux, oAux, true, '0', '');
                        oTraza.add(oTrazaDet);
                    }

                    // Asignar el caso para identificar el cliente.
                    oCasosIdent.add(oCasoAux.Id);
                }

                if (!oCasosIdent.isEmpty())
                {
                    // Identificación asíncrona y por lotes de los casos generados.
                    CC_IdentCliente_Future.identificarClientesAsync (oCasosIdent);

                    // Envío del acuse de recibo de forma asíncrona y por lotes de los casos generados.
                    //CC_NotifSegCaso.gestionarAcuseReciboCaso(oCasosIdent);
                }
            }

            // Actualizar trazas hijas.
            if (oTraza != null)
            {
                if (!oTraza.isEmpty())
                {
                    Database.SaveResult[] oResUp = Database.insert(oTraza, false);
                }
            }


        } catch (Exception e) {

            // Trazar error.
            bTrazaOk = false;
            sErrGen = 'Error en la ejecución del proceso CC_WS_Casos. ' + e.getMessage();

            CC_WS_Casos.CC_WS_Casos_Output oAux = new CC_WS_Casos.CC_WS_Casos_Output();
            oAux.sCodError = '9999';
            oAux.sDetalleError = sErrGen;
            oAux.sNumCaso = '';
            oAux.sRefUser = '';
            oAux.sNIF = '';
            oAux.sTexto = '';
            oAux.sAccountId='';
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

/* ESQUELETO PARA USO FUTURO.
    @HttpGet
    global static Case getCaseByCaseNumber() {
        RestRequest request = RestContext.request;
        // grab the caseId from the end of the URL
        String CaseNumber = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);
        Case result =  [SELECT CaseNumber,Subject,Status,Origin,Priority
                        FROM Case
                        WHERE CaseNumber = :CaseNumber];
        return result;
    }
*/

/* ESQUELETO PARA USO FUTURO.
    @HttpPut
    global static ID upsertCase(String subject, String status,
        String origin, String priority, String id) {
        Case thisCase = new Case(
                Id=id,
                Subject=subject,
                Status=status,
                Origin=origin,
                Priority=priority);
        // Match case by Id, if present.
        // Otherwise, create new case.
        upsert thisCase;
        // Return the case ID.
        return thisCase.Id;
    }
*/

/* ESQUELETO PARA USO FUTURO.
    @HttpPatch
    global static ID updateCaseFields() {
        RestRequest request = RestContext.request;
        String caseId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Case thisCase = [SELECT Id FROM Case WHERE Id = :caseId];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
            // Set the field and value on the Case sObject
            thisCase.put(fieldName, params.get(fieldName));
        }
        update thisCase;
        return thisCase.Id;
    }
*/

}