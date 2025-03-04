/*****************************************************************
 * Name: SAC_WS_FormularioCasos
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Creación de Casos mediante WebService desde formulario externo mediante un servicio Rest
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             --             Nicolás García   28/07/21     Creación
*****************************************************************/
@RestResource(urlMapping='/SAC_FormularioCasos/*')
global with sharing class SAC_WS_FormularioCasos extends CBK_HttpServiceIntegration_Abstract{

    private static Set<String> objetos = new Set<String>{'Account', 'Contact', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPECLIENTEPA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
    private static final Id RECTYPENOCLIENTEPA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId();
    private static final Id RECTYPECLIENTE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
    private static final Id RECTYPENOCLIENTE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente').getRecordTypeId();
    private static final Id RECTYPECENTRO= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

    private static final Id RECTYPECLIENTECONTACT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
    private static final Id RECTYPEEMPLEADO = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
    private static final Id RECTYPECOLABOLADOR = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();

    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

    private static final Id RECTYPEFORMGGH = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SAC_Formulario_GGH').getRecordTypeId();
    private static final Id RECTYPEFORMFRAUDE = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SAC_Formulario_Fraude').getRecordTypeId();

    /*****************************************************************
     * Proposito: Definición de Wrapper para los parámetros de entrada
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    global class SAC_WS_FormularioCasos_Input {

        global String aplicacion {get;set;} // "FORMWEB" o "FORMGGH" o "FORMFRAUDE"
        global String id {get;set;}
        global String entidad {get;set;}
        global String nombre {get;set;}
        global String apellido1 {get;set;}
        global String apellido2 {get;set;}
        global String email {get;set;}
        global String telefono {get;set;}
        global String nif {get;set;}
        global String cliente {get;set;}
        global String numOf {get;set;}
        global String clienteLOE {get;set;}
        global String codiusu {get;set;}
        global String producto {get;set;}
        global String ambito {get;set;}
        global String motivo {get;set;}
        global String idioma {get;set;}
        global String texto {get;set;}
        global String certificadoDigital {get;set;}
        global String origen {get;set;}
        global String referer {get;set;}
        global String userAgent {get;set;}
        global String ip {get;set;}
        global String refusuario {get;set;}
        global String tipo {get;set;}
        global String web {get;set;}
        global String servicio {get;set;}
        global List<WrapperAdjunto> ficherosAdjuntos {get;set;}
        global String ccOrigen {get;set;}
        global String ccClasificacionWeb {get;set;}
        global String ccContactId {get;set;}
        global String ccAccountId {get;set;}
        // Campos Nuevos
        global String tipoDoc {get;set;} // Tipo de documento
        global String provincia {get;set;} // Provincia del reclamante
        global Boolean repLegal {get;set;} // Representante legal (true/false)
        global Decimal totalReclamado {get;set;} // Total reclamado (Fraude)
        // Objetos nuevos
        global RepresentanteLegal representanteLegal {get;set;} // Objeto representante legal
        global List<GastosReclamados> gastosReclamados {get;set;} // Objeto gastos reclamados
        global List<OpReclamadas> opReclamadas {get;set;} // Objeto operaciones reclamadas
    }
    // GGH Y FRAUDE
    global class RepresentanteLegal {
        global String repTipoDoc {get;set;} // Tipo de documento del representante
        global String repLegalDoc {get;set;} // Documento del representante
        global String repLegalRazon {get;set;} // Nombre o razón del representante
    }
    // GGH
    global class GastosReclamados {
        global String numPrestamo {get;set;} // Número de préstamo
        global Decimal gastosGestoria {get;set;} // Gastos de gestoría
        global Decimal gastosRegistro {get;set;} // Gastos de registro
        global Decimal gastosNotaria {get;set;} // Gastos de notaría
        global Decimal gastosOtros {get;set;} // Otros gastos
        global Decimal totalReclamado {get;set;} // Total reclamado (GGH)
    }
    // FRAUDE
    global class OpReclamadas {
        global String fechas {get;set;} 
        global Decimal importe {get;set;}
        global String producto {get;set;}
    }
    /*****************************************************************
     * Proposito: Definición de Wrapper para los parámetros de salida
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    global class SAC_WS_FormularioCasos_Output {
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

    /*****************************************************************
     * Proposito: Definición de Wrapper para los parámetros de salida
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    global class WrapperAdjunto {
        global String nombreFichero {get;set;}
        global String base64 {get;set;}
        global String extension {get;set;}
    }

    /*****************************************************************
     * Proposito: Método para validar los inputs del formulario
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    private static String validarDatosEntrada (SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oDatos)
    {
        if (oDatos != null)
        {
            if (oDatos.refusuario == null)
            {
                return 'KO';
            }else if (oDatos.refusuario.trim() == '') {
                return 'KO';
            }

            if (oDatos.nif == null)
            {
                return 'KO';
            }else if (oDatos.nif.trim() == '') {
                return 'KO';
            }

            if (oDatos.texto == null)
            {
                return 'KO';
            }else if (oDatos.texto.trim() == '') {
                return 'KO';
            }

            if (oDatos.aplicacion == null)
            {
                return 'KO';
            }else if (oDatos.aplicacion.trim() == '') {
                return 'KO';
            }

            // Validaciones y gestiones por aplicación.
            if (oDatos.aplicacion == 'FORMWEB' || oDatos.aplicacion == 'MICROBANK')
            {
                // VALIDACIONES PARA EL FORMULARIO WEB.
                if (oDatos.producto == null || oDatos.ambito == null || oDatos.motivo == null)
                {
                    return 'KO';
                }else if (oDatos.producto.trim() == '' || oDatos.ambito.trim() == '' || oDatos.motivo.trim() == '') {
                    return 'KO';
                }else{
                    // Rellenar los campos internos para el tratamiento de la tipificación.
                    oDatos.ccOrigen = 'MC';

                    String sTipificacion = '';
                    sTipificacion = sTipificacion + oDatos.ccOrigen + '-';
                    sTipificacion = sTipificacion + oDatos.motivo.trim() + '-';
                    sTipificacion = sTipificacion + oDatos.producto.trim() + '-';
                    sTipificacion = sTipificacion + oDatos.ambito.trim();
                    oDatos.ccClasificacionWeb = sTipificacion;
                }
            }
        }

        // Unificar datos para tratamiento.
        oDatos.nif = oDatos.nif.toUpperCase();
        oDatos.email = oDatos.email.toLowerCase();

        return 'OK';
    }

    /*****************************************************************
     * Propósito: Creación de Formularios GGH
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --              Iria ANPC     01/10/24        Creación
    *****************************************************************/
    public static void createFormularioGGH(List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oDatosList, String caseId){
        Pattern nonNumericPattern = Pattern.compile('[^0-9]');
        String prodServRecordType = 'CC_Producto_Servicio';
        String detalleRecordType = 'SAC_Detalle';
        List<Case> reclamacion = [SELECT Id, AccountId, ContactId, CC_SuppliedNIF__c, Status, SAC_StatusAuxiliar__c, Origin, SAC_CasoEspecial__c, CC_Canal_Procedencia__c FROM Case WHERE Id =: caseId LIMIT 1];
        Map<String, SAC_ProductCase__c> mapNumPersoProducto = new Map<String, SAC_ProductCase__c>();
        List<SPV_Formulario__c> formularios = new List<SPV_Formulario__c>();
        List<Case> pretensiones = new List<Case>();
        List<SAC_ProductCase__c> products = new List<SAC_ProductCase__c>();
        Map<String, CC_MCC__c> mccMap = new Map<String, CC_MCC__c>();
        List<String> mccIds = new List<String>();
        // Get MCC
        List<SAC_MCC_Formularios__c> mccSetting = [SELECT Id, SAC_Tematica__c, SAC_ProductoServicio__c, SAC_Motivo__c, SAC_Detalle__c FROM SAC_MCC_Formularios__c WHERE Name = 'Pretension' LIMIT 1];
        for(SAC_MCC_Formularios__c mccSet: mccSetting){
            mccIds.add(mccSet.SAC_ProductoServicio__c);
            mccIds.add(mccSet.SAC_Detalle__c);
        }
        // ProdServ and Detalle MCC Map
        for(CC_MCC__c mcc :[SELECT Id, Name, RecordType.DeveloperName, SAC_EntidadAfectada__c, SAC_EntidadProductora__c, SAC_EsPsd2__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c FROM CC_MCC__c WHERE Id IN: mccIds]){
            mccMap.put(mcc.RecordType.DeveloperName, mcc);
        }
        for(SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oDatos: oDatosList){
            if(oDatos.aplicacion == 'FORMGGH'){
                SPV_Formulario__c fGGH = new SPV_Formulario__c();
                fGGH.RecordTypeId = RECTYPEFORMGGH;
                fGGH.SPV_Caso__c = caseId;
                fGGH.SAC_Tipo_Documento__c = oDatos.tipoDoc;
                fGGH.SAC_Provincia__c = oDatos.provincia;
                fGGH.SAC_Representante_Legal__c = oDatos.repLegal;
                if(oDatos.gastosReclamados != null){
                    for(GastosReclamados gasto: oDatos.gastosReclamados){
                        // Create pretensión
                        Case pretension = new Case();
                        pretension.AccountId = reclamacion[0].AccountId;
                        pretension.CC_SuppliedNIF__c = reclamacion[0].CC_SuppliedNIF__c;
                        pretension.ContactId = reclamacion[0].ContactId;
                        pretension.SAC_Reclamacion__c = caseId;
                        pretension.RecordTypeId = RECTYPEPRETENSION;
                        pretension.SAC_ImpReclamadoGestoria__c = gasto.gastosGestoria;
                        pretension.SAC_ImpReclamadoNotaria__c = gasto.gastosNotaria;
                        pretension.SAC_ImpReclamadoRegistros__c = gasto.gastosRegistro;
                        pretension.SAC_Otros_gastos__c = gasto.gastosOtros;
                        pretension.CC_Importe_Reclamado__c = gasto.totalReclamado;
                        pretension.SAC_Prestamo_seleccionado__c = gasto.numPrestamo;
                        pretension.Status = reclamacion[0].Status;
                        pretension.SAC_StatusAuxiliar__c = reclamacion[0].SAC_StatusAuxiliar__c;
                        pretension.Origin = reclamacion[0].Origin;
                        pretension.SAC_TiempoSLARegulatorio__c = 30;
                        pretension.SAC_TiempoSLALetradoAlta__c = 30;
                        pretension.CC_No_Identificado__c  = true;
                        pretension.CC_IdentCliente__c = '0';
                        pretension.SAC_CasoEspecial__c = reclamacion[0].SAC_CasoEspecial__c;
                        if(!String.isBlank(reclamacion[0].CC_Canal_Procedencia__c)){
                            pretension.CC_Canal_Procedencia__c = reclamacion[0].CC_Canal_Procedencia__c;
                        } 
                        if(!String.isBlank(reclamacion[0].AccountId)){
                            pretension.AccountId = reclamacion[0].AccountId;
                        } 
                        if(!String.isBlank(reclamacion[0].ContactId)){
                            pretension.ContactId = reclamacion[0].ContactId;
                        } 
                        if(!mccSetting.isEmpty()){
                            pretension.CC_MCC_Tematica__c = mccSetting[0].SAC_Tematica__c;
                            pretension.CC_MCC_ProdServ__c = mccSetting[0].SAC_ProductoServicio__c;
                            pretension.CC_MCC_Motivo__c = mccSetting[0].SAC_Motivo__c;
                            pretension.SEG_Detalle__c = mccSetting[0].SAC_Detalle__c;
                            // ProdServ and Detalle
                            if(mccMap.containsKey(prodServRecordType) && mccMap.containsKey(detalleRecordType)){
                                CC_MCC__c prodServ = mccMap.get(prodServRecordType);
                                CC_MCC__c detalle = mccMap.get(detalleRecordType);
                                pretension.SAC_Entidad_Afectada__c = detalle.SAC_EntidadAfectada__c;
                                pretension.SAC_EntidadProductora__c = detalle.SAC_EntidadProductora__c;
                                pretension.SAC_CASE_esPSD2__c = detalle.SAC_EsPsd2__c;
                                pretension.CC_Codigo_Externo_Tematica__c = detalle.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c;
                                pretension.Subject = prodServ.Name + ' - ' + detalle.Name;
                            }
                        }
                        pretensiones.add(pretension);
                        // Create Producto
                        if(!nonNumericPattern.matcher(gasto.numPrestamo).find()){
                            SAC_ProductCase__c prod = new SAC_ProductCase__c();
                            prod.SAC_Descripcion__c = 'Producto generado automáticamente con el Formulario GGH';
                            prod.SAC_Tipo__c = 'Préstamo';
                            prod.N_Contrato__c = gasto.numPrestamo;
                            prod.SAC_Pretension__c = pretension.Id;
                            mapNumPersoProducto.put(gasto.numPrestamo, prod);
                        }
                    }
                }
                formularios.add(fGGH);
            }
        }
        if(!formularios.isEmpty()){
            insert formularios;
        }
        if(!pretensiones.isEmpty()){
            insert pretensiones;
        }
        for(Case pretension :[SELECT Id, SAC_Prestamo_seleccionado__c  FROM Case WHERE Id IN: pretensiones]){
            if(mapNumPersoProducto.containsKey(pretension.SAC_Prestamo_seleccionado__c )){
                SAC_ProductCase__c prod = mapNumPersoProducto.get(pretension.SAC_Prestamo_seleccionado__c );
                prod.SAC_Pretension__c = pretension.Id;
				products.add(prod);
            }
        }
        if(!products.isEmpty()){
            insert products;
        }
    }
    /*****************************************************************
     * Propósito: Creación de Formularios FRAUDE
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --              Iria ANPC     01/10/24        Creación
    *****************************************************************/
    public static void createFormularioFraude(List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oDatosList, String caseId){
        List<SPV_Formulario__c> formularios = new List<SPV_Formulario__c>();
        for(SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oDatos: oDatosList){
            if(oDatos.aplicacion == 'FORMFRAUDE'){
                SPV_Formulario__c fFraude = new SPV_Formulario__c();
                fFraude.RecordTypeId = RECTYPEFORMFRAUDE;
                fFraude.SPV_Caso__c = caseId;
                fFraude.SAC_Tipo_Documento__c = oDatos.tipoDoc;
                fFraude.SAC_Provincia__c = oDatos.provincia;
                fFraude.SAC_Representante_Legal__c = oDatos.repLegal;
                if(oDatos.opReclamadas != null){
                    for(OpReclamadas op: oDatos.opReclamadas){
                        if(fFraude.SAC_Fechas__c == null){
							fFraude.SAC_Fechas__c = op.fechas + ';' + op.importe + ';' + op.producto + ':';                            
                        }else{
                            fFraude.SAC_Fechas__c += op.fechas + ';' + op.importe + ';' + op.producto + ':';
                        }
                    }
                } 
                formularios.add(fFraude);
            }
        }
        if(!formularios.isEmpty()){
            insert formularios;
        }
    }
    /*****************************************************************
     * Proposito: Recuperar el maestro de tipificaciones entre Web y Salesforce.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
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

    /*****************************************************************
     * Proposito:   Recuperar datos configurados en los Metadatos para la cuenta origen.
                    Prioridad, Estado, Canal acceso y tipo de cliente del caso.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    private static List <SAC_Config_FormWeb__mdt> getConfigApp (String sApp)
    {
        List<SAC_Config_FormWeb__mdt> oConfig;

        if (sApp != '')
        {
            oConfig = [SELECT Id, CC_CasoCanalEntrada__c, CC_CasoCanalOperativo__c, CC_CasoCanalProc__c, CC_CasoEstado__c, CC_CasoPrioridad__c, CC_ReglaAssigCaso__c, CC_CasoTipoCliente__c, CC_MotivosExcl__c FROM SAC_Config_FormWeb__mdt WHERE CC_Aplicacion__c = :sApp];    
        }

        return oConfig;
    }

    /*****************************************************************
     * Proposito: Método para preparar la creación del caso.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    private static Map<String,Object> prepararCaso (SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oForm, Map<String, Object> oParamAux, Map<String,Map<String,String>> oMapTipificacion, Map<String, Case> casosDuplicadosMap, String sTipoNif)
    {
        Map<String,Object> oRes = new Map<String,Object>();

        try {
            if (oForm != null)
            {
                // Configuración para el caso a partir de formularios web.
                SAC_Config_FormWeb__mdt oConfig;
                List <SAC_Config_FormWeb__mdt> oConfigList = new List <SAC_Config_FormWeb__mdt>();
                // Configuración para el caso duplicado a partir de formularios web.
                SAC_Config_FormWeb__mdt oConfigDuplicado;

                // Crear objeto caso.
                Case oCaso = new Case();

                //Lista adjuntos
                List<ContentVersion> contents = new List<ContentVersion>();
				// Nuevos Formularios: GGH Y FRAUDE
                if(oForm.aplicacion == 'FORMGGH' || oForm.aplicacion == 'FORMFRAUDE'){
                    if(oForm.repLegal == true && oForm.representanteLegal != null){
                        //Campo rep legal
                        oCaso.SAC_Tipo_Doc_Rep_Legal__c  = oForm.representanteLegal.repTipoDoc;
                        if(oForm.representanteLegal.repTipoDoc == 'DNI' ||  oForm.representanteLegal.repTipoDoc == 'CIF'){
                            oCaso.SAC_TipoDeDocumento__c = oForm.representanteLegal.repTipoDoc; 
                        }
                        oCaso.SAC_NumeroDelDocumento__c  = oForm.representanteLegal.repLegalDoc;
                        oCaso.SAC_NombreRepresentante__c = oForm.representanteLegal.repLegalRazon;
                    }    
                    if(oForm.aplicacion == 'FORMFRAUDE'){
                        oCaso.CC_Importe_Reclamado__c = oForm.totalReclamado;
                    }                    
                }
                // Asignar Contacto y Account.
                if (oForm.ccAccountId != null)
                {
                    oCaso.AccountId = oForm.ccAccountId;
                }

                if (oForm.ccContactId != null)
                {
                    oCaso.ContactId = oForm.ccContactId;
                }
                // Tratar los datos del formulario y volcar al caso.

                if (oForm.refusuario != null)
                {
                    oCaso.CC_RefExterna__c = oForm.refusuario.trim().unescapeHtml4();
                }

                if (oForm.Aplicacion != null)
                {
                    String aplicacionReal = oForm.Aplicacion.trim().unescapeHtml4();
                    if (aplicacionReal == 'FORMWEB'){
                        String ambitoMicrobank = [SELECT Valor_Texto__c FROM CC_Parametros__mdt WHERE Nombre__c = 'Producto_Aplicacion_Microbank'].Valor_Texto__c;
                        if (oForm.Ambito == ambitoMicrobank){
                        	aplicacionReal = 'MICROBANK';
                        }
                    }

                    oCaso.CC_SuppliedApp__c = aplicacionReal;
                    oConfigList = getConfigApp (aplicacionReal);
                    for(SAC_Config_FormWeb__mdt mdt : oConfigList) {
                        if(mdt.label.contains('_DUP')) {
                            oConfigDuplicado = mdt;
                        } else {
                            oConfig = mdt;
                        }
                    }                    
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

                    if (oParamAux != null && !oParamAux.isEmpty() && oParamAux.get('CC_ProductoWeb') != null){
                        Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ProductoWeb');
                        if (oMap.get(oForm.Producto.trim().unescapeHtml4()) != null){
                            oCaso.CC_SuppliedProductoDesc__c = oMap.get(oForm.Producto.trim().unescapeHtml4());
                        }
                        else{
                            oCaso.CC_SuppliedProductoDesc__c = oForm.Producto.trim().unescapeHtml4();
                        }
                    }
                }

                if (oForm.Ambito != null)
                {
                    oCaso.CC_SuppliedAmbito__c = oForm.Ambito.trim().unescapeHtml4();

                    if (oParamAux != null && !oParamAux.isEmpty() && oParamAux.get('CC_AmbitoWeb') != null)
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

                if (oForm.Motivo != null)
                {

                    oCaso.CC_SuppliedMotivo__c = oForm.Motivo.trim().unescapeHtml4();

                    if (oParamAux != null && !oParamAux.isEmpty() && oParamAux.get('CC_MotivoWeb') != null)
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

                if (oForm.Idioma != null)
                {
                    oCaso.CC_SuppliedIdioma__c = oForm.Idioma.trim().unescapeHtml4();

                    // Asignar el idioma del caso.
                    if (oParamAux != null && !oParamAux.isEmpty() && oParamAux.get('CC_Idioma_FORMWEB') != null)
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

                if (oForm.Texto != null)
                {
                    String sTextoFW = oForm.Texto.trim().unescapeHtml4();
                    String sTextoLargoFW = sTextoFW;

                    if (sTextoFW != '' && sTextoFW.length() > 80){
                        sTextoFW = sTextoFW.substring(0,80);
                    }

                    oCaso.Subject = sTextoFW;
                    oCaso.Description = sTextoLargoFW;
                }

                if (oForm.CertificadoDigital != null)
                {
                    oCaso.CC_SuppliedCertificado__c = oForm.CertificadoDigital.trim().unescapeHtml4();
                }

                if (oForm.Origen != null)
                {
                    oCaso.Origin = 'SAC_Formulario';
                }

                if (oForm.Referer != null)
                {
                    oCaso.CC_SuppliedURL__c = oForm.Referer.trim().unescapeHtml4();
                }

                if (oForm.userAgent != null)
                {
                    oCaso.CC_SuppliedConexion__c = oForm.userAgent.trim().unescapeHtml4();
                }

                if (oForm.IP != null)
                {
                    oCaso.CC_SuppliedIP__c = oForm.IP.trim().unescapeHtml4();
                }

                if (oForm.FicherosAdjuntos != null && !oForm.ficherosAdjuntos.isEmpty())
                {
                    //oCaso.CC_SuppliedFiles__c = false;
                    if(oForm.ficherosAdjuntos.size() > 0){
                        //oCaso.CC_SuppliedFiles__c = true;
                        oCaso.SAC_UltimaModificacionFichero__c = System.now();
                        for(WrapperAdjunto adjunto : oForm.ficherosAdjuntos){
                            
                            ContentVersion conVer = new ContentVersion();
                            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                            conVer.PathOnClient = adjunto.nombreFichero; // The files name, extension is very important here which will help the file in preview.
                            conVer.Title = adjunto.nombreFichero; // Display name of the files
                            conVer.VersionData = EncodingUtil.base64Decode(adjunto.base64); // converting your binary string to Blob
                            //insert conVer;    //Insert ContentVersion
                            contents.add(conVer);

                        }
                    }
                }

                // Tipificar el caso.
                if (oMapTipificacion != null && oForm.ccClasificacionWeb != null)
                {
                    if (oMapTipificacion.get(oForm.ccClasificacionWeb) != null)
                    {
                        oCaso.CC_MCC_Tematica__c = oMapTipificacion.get(oForm.ccClasificacionWeb).get('Tematica');
                        oCaso.CC_MCC_ProdServ__c = oMapTipificacion.get(oForm.ccClasificacionWeb).get('Producto');
                        oCaso.CC_MCC_Motivo__c = oMapTipificacion.get(oForm.ccClasificacionWeb).get('Motivo');
                        oCaso.CC_Tipo_Contacto__c = oMapTipificacion.get(oForm.ccClasificacionWeb).get('TipoContacto');
                    }
                }

                // Rellenar información preconfigurada.
                if (oConfig != null)
                {
                    if (oConfig.CC_ReglaAssigCaso__c != null)
                    {
                        String sReglaId = '';

                        // Aplicar la regla de asignación del caso.
                        if (oParamAux != null && !oParamAux.isEmpty() && oParamAux.get('CC_ReglasAss') != null)
                        {
                            Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ReglasAss');
                            if (oMap.get(oConfig.CC_ReglaAssigCaso__c) != null)
                            {
                                sReglaId = oMap.get(oConfig.CC_ReglaAssigCaso__c);
                            }
                        }

                        if (sReglaId != '')
                        {
                            Database.DMLOptions dmlOpts = new Database.DMLOptions();
                            dmlOpts.assignmentRuleHeader.assignmentRuleId = sReglaId;
                            oCaso.setOptions(dmlOpts);
                        }
                    }

                    oCaso.Status = 'SAC_001';
                    oCaso.SAC_StatusAuxiliar__c = 'SAC_001';
                    /*
                    // Si el nuevo caso se considera duplicado, se le caso asigna el estado "Pendiente Revisión"
                    Case casoDuplicado = casosDuplicadosMap.get(oForm.NIF.trim().unescapeHtml4());
                    if (oConfigDuplicado != null && oConfigDuplicado.CC_CasoEstado__c != null && casoDuplicado != null && casoDuplicado.CC_MailTelfNotif__c == oForm.EMAIL.trim().unescapeHtml4() && casoDuplicado.CC_SuppliedProducto__c == oForm.Producto.trim().unescapeHtml4()){
                        oCaso.Status = oConfigDuplicado.CC_CasoEstado__c;
                    }
                    else if (oConfig.CC_CasoEstado__c != null){
                        oCaso.Status = oConfig.CC_CasoEstado__c;
                    }*/

                }

                // Preparar el acuse de recibo.
                /*if (oForm.EMAIL != null)
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

                    }
                    if (!oConfigAcuse.isEmpty() && oConfigAcuse[0].CC_DelayMinAcuse__c != null)
                    {
                        iDelay = Integer.valueOf(oConfigAcuse[0].CC_DelayMinAcuse__c);
                    }

                    datetime oDelay = datetime.now();
                    oDelay = oDelay.addMinutes(iDelay);

                    oCaso.CC_AcuseDelay__c = oDelay;
                }*/

                if (oForm.EMAIL != null){
                    oCaso.CC_MailTelfNotif__c = oForm.EMAIL.trim().unescapeHtml4();
                }

                //list<string> colaSpliteada = SAC_GenialUtils.randomizador().split(';');
                list<string> colaSpliteada = SAC_GenialUtils.randomizador('SAC_Formulario').split(';');
                string nombreCola = colaSpliteada[0];
                // string nombreCola = SAC_GenialUtils.randomizador();
                //List<QueueSobject> colas = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = 'SAC_PendienteAsignar' AND SobjectType = 'Case' LIMIT 1];
                List<QueueSobject> colas = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = : nombreCola AND SobjectType = 'Case' LIMIT 1];

                if(!colas.isEmpty()){
                    oCaso.OwnerId = colas[0].QueueId;
                    if(colaSpliteada.size() == 2){
                        oCaso.SAC_GenialEstado__c = 'SAC_005';
                    }
                }
                
                oCaso.RecordTypeId = RECTYPERECLAMACION;

                oRes.put('Estado', 'OK');
                oRes.put('Detalle', '');
                oRes.put('Caso', oCaso);
                oRes.put('Adjuntos', contents);

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

    /*****************************************************************
     * Proposito: Método que crea la traza de la llamada del Webservice
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    private static CC_TrazaInt__c crearTrazaPadre (CC_InterfaceSettings__mdt oConfig, String sInterfaz, String sIdentificador, String sIdOrig, Object oEntrada)
    {
        CC_TrazaInt__c oTraza;
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntradaConvertido = (List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>)oEntrada;
        /*for(SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input iter : oEntradaConvertido){
            //iter.ficherosAdjuntos = null;
        }*/

        if (oConfig != null)
        {
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = sInterfaz;
                oTraza.CC_Identificador__c = sIdentificador;
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_IdOrigen__c = sIdOrig;

                String mensaje = String.valueOf(oEntradaConvertido);
                if (oConfig.CC_TrazaEntrada__c){
                    if(mensaje.length() > 32760){
                        mensaje = mensaje.substring(0, 32760);
                    }
                    oTraza.CC_MensajeEntrada__c = mensaje;
                }
            }
        }

        return oTraza;
    }

    /*****************************************************************
     * Proposito: Método para cerrar la traza padre del proceso. Medir tiempos totales.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    private static void cerrarTrazaPadre (CC_InterfaceSettings__mdt oConfig, CC_TrazaInt__c oTraza, Object oSalida, Boolean bOk, String sTipoError, String sDetalleError)
    {
        if (oConfig != null && oTraza != null)
        {
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
                if (oConfig.CC_TrazaSalida__c && oSalida != null){
                    oTraza.CC_MensajeSalida__c = String.valueOf(oSalida);
                }

                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = bOk;
                oTraza.CC_TipoError__c = sTipoError;
                oTraza.CC_DetalleError__c = sDetalleError;

                // Guardar BBDD.
                List<CC_TrazaInt__c> lstTrazas = new List<CC_TrazaInt__c>();
                lstTrazas.add(oTraza);
                String jsonTrazas = JSON.serialize(lstTrazas);
                SAC_Utils.insertTrazas(jsonTrazas);
            }
        }
    }

    /*****************************************************************
     * Proposito: Método que almacena traza de la ejecución realizada y si ha habido error en la misma
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
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

                if (oConfig.CC_TrazaEntrada__c){
                    oTraza.CC_MensajeEntrada__c = String.valueOf(oEntrada);
                }

                if (oConfig.CC_TrazaSalida__c && oSalida != null){
                    oTraza.CC_MensajeSalida__c = String.valueOf(oSalida);
                }

                oTraza.CC_FinOK__c = bOk;
                oTraza.CC_TipoError__c = sTipoError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }
        }

        return oTraza;
    }

    /*****************************************************************
     * Proposito: Método para gestionar los contactos de la entrada de formularios web.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    private static void gestionCuentasContactosFormulario (Map<String,String> oContactos, Map<String,SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oForms, Map<String, Object> oParamAux, String sTipoNif)
    {
        if (oContactos == null || oContactos.isEmpty()){
            return;
        }

        // Buscar cuentas existentes con NumPer en Salesforce.
        Map<String,String> oCuentas = new Map<String,String>();
        Map<String,String> oCuentasId = new Map<String,String>();
        Map<String,String> oCuentasDup = new Map<String,String>();
        Map<String,String> oCuentasDupId = new Map<String,String>();
        List<Account> oContAux = new List<Account>();
        List<Account> oContAuxNoAFL = new List<Account>();

        Boolean bConfidencial = false;
		
        //List<Account> oAccounts = [SELECT Id, CC_Numero_Documento__c, CC_NumPerso__c FROM Account WHERE RecordTypeId IN (:RECTYPECLIENTEPA, :RECTYPENOCLIENTEPA, :RECTYPECLIENTE, :RECTYPENOCLIENTE, :RECTYPECENTRO) AND CC_Numero_Documento__c IN :oContactos.keySet() ORDER BY CreatedDate ASC];
		
        Boolean esConfidencial = false;
        List<Account> oAccounts = new List<Account>();
        Map<String, Account> oAccountsMap = new Map<String, Account>();
        List<Account> confidencialAccounts = new List<Account>();
        List<Account> blankAccountsToInsert = new List<Account>();
        List<Contact> blankContactToInsert = new List<Contact>();
        // Obtener todas las accounts (incluyendo AV_Confidencial__c = true)
        List<Account> allAccounts = SAC_MetodosSinSharing.listaDeClientesPorDoc(oContactos.keySet());
        for(Account acc: allAccounts){
            if(acc.AV_Confidencial__c){
                // La cuenta es confidencial
                confidencialAccounts.add(acc);
                esConfidencial = true;
            }else{
                // La cuenta no es confidencial
                // Si ambas listas están informadas significa que existe la cuenta AV_Confidencial__c = true y la cuenta Name = 'CONFIDENCIAL'
                oAccounts.add(acc);
                oAccountsMap.put(acc.CC_Numero_Documento__c, acc);
            }
        }
        for(Account acc :confidencialAccounts){
            // Si es AV_Confidencial__c pero no existe en el mapa, significa que Name = 'CONFIDENCIAL' todavía no está creada
            if(!oAccountsMap.containsKey(acc.CC_Numero_Documento__c)){
                Account confAccount = new Account();
                confAccount.recordTypeId = RECTYPECLIENTE;
                confAccount.Name = 'CONFIDENCIAL';
                confAccount.CC_NumPerso__c = acc.AV_NumPerso__c;
                confAccount.CC_Confidencial__c = true; // Identificar que es cuenta artificial
                confAccount.CC_Numero_Documento__c = acc.CC_Numero_Documento__c;
                blankAccountsToInsert.add(confAccount);
            }
        }
        // Insertar cuenta Name = 'CONFIDENCIAL'
        if(!blankAccountsToInsert.isEmpty()){
            insert blankAccountsToInsert;
        }
        // Crear contacto relacionado con cuenta Name = 'CONFIDENCIAL'
        for(Account acc: blankAccountsToInsert){
            oAccounts.add(acc);
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.LastName = 'CONFIDENCIAL';
            con.CC_Numero_Documento__c = acc.CC_Numero_Documento__c;
            blankContactToInsert.add(con);
        }
        // Insertar contacto relacionado con cuenta Name = 'CONFIDENCIAL'
        if(!blankContactToInsert.isEmpty()){
            insert blankContactToInsert;
        }
        
        for(Account cliente : oAccounts){
            if(cliente.CC_NumPerso__c != '' || cliente.CC_NumPerso__c <> NULL){
                oContAux.add(cliente);
            }else{
                //Duplicados de cuentas no ALF
                oContAuxNoAFL.add(cliente);   
            }
        }

        //Duplicados de cuentas ALF
        for (Account oAux : oContAux)
        {
            if (oCuentas.get(oAux.CC_Numero_Documento__c) == null)
            {
                oCuentas.put(oAux.CC_Numero_Documento__c, oAux.Id);
                oCuentasId.put(oAux.Id, oAux.CC_Numero_Documento__c);
            }else{
                // Documento duplicado en ALF. Buscar / crear un contacto no ALF.
                oCuentasDup.put(oAux.CC_Numero_Documento__c, oAux.Id);
                oCuentasDupId.put(oAux.Id, oAux.CC_Numero_Documento__c);
            }
        }


        if(!oContAuxNoAFL.isEmpty()){
            for (Account noAFL : oContAuxNoAFL)
            {
                if (oCuentas.get(noAFL.CC_Numero_Documento__c) == null)
                {
                    oCuentas.put(noAFL.CC_Numero_Documento__c, noAFL.Id);
                    oCuentasId.put(noAFL.Id, noAFL.CC_Numero_Documento__c);
                }
            }
        }

        oContAux = null;

        // Aquellas cuentas duplicadas de ALF, se busca si existe una cuenta con NIF y sin NumPer.
        if (!oCuentasDup.isEmpty())
        {
            oContAux = [SELECT Id, CC_Numero_Documento__c, CC_NumPerso__c FROM Account 
            WHERE CC_Numero_Documento__c IN :oCuentasDup.keySet() 
            AND (CC_NumPerso__c = '' 
            OR CC_NumPerso__c = NULL) 
            ORDER BY CreatedDate ASC];

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
            if ((oCuentas.get(sDoc) == null && oCuentasDup.get(sDoc) == null) || esConfidencial)
            {
                // Crear cuenta + contacto.
                bCrear = true;
            }

            if (bCrear)
            {
                Account oNew = new Account();
                List <Account> oExist = new List <Account>();
                String oFormsNIF = oForms.get(sClave).NIF.trim().unescapeHtml4();
                Map<String, Object> respuesta = CC_IdentCliente_Future.IdentificarPersALFSync('DOC', oFormsNIF);
                for (String sRet : respuesta.keySet()) {
                    if (sRet == 'CUENTAS' && respuesta.get(sRet) != null){
                        oExist = (List <Account>)respuesta.get(sRet);
                    }
                }

                for(Account cuentas : oExist) {
                    if(cuentas.Name == 'CONFIDENCIAL') {
                        bConfidencial = true;
                        oCuentasDup.put(oFormsNIF, cuentas.Id);
                        oCuentasDupId.put(cuentas.Id, oFormsNIF);
                    }
                }
            
                if(!bConfidencial) {
                    String sNom = '';
                    String sApe1 = '';
                    String sApe2 = '';
                    String sDniC = '';

                    if (oForms.get(sClave).Nombre != null){
                        sNom = oForms.get(sClave).Nombre.trim().unescapeHtml4();
                    }

                    if (oForms.get(sClave).Apellido1 != null){
                        sApe1 = oForms.get(sClave).Apellido1.trim().unescapeHtml4();
                    }

                    if (oForms.get(sClave).Apellido2 != null){
                        sApe2 = oForms.get(sClave).Apellido2.trim().unescapeHtml4();
                    }

                    if (oForms.get(sClave).NIF != null){
                        sDniC = oForms.get(sClave).NIF.trim().unescapeHtml4();
                    }

                    sNom = (sNom + ' ' + sApe1 + ' ' + sApe2).trim();
                    if (sNom.length() > 255){
                        sNom = sNom.substring(0,255);
                    }

                    if (sNom != '' && sDniC != '')
                    {
                        // Nuevo tratamiento PersonAccount y BusinessAccount.
                        if (sTipoNif == 'CIF') {
                            oNew.RecordTypeId = RECTYPECLIENTE;
                            oNew.Name = sNom;
                        } else {
                            oNew.RecordTypeId = RECTYPENOCLIENTEPA;
                            if (oForms.get(sClave).Nombre != null){
                                oNew.FirstName = oForms.get(sClave).Nombre.trim().unescapeHtml4();
                            }

                            if (oForms.get(sClave).Apellido1 != null) {
                                oNew.LastName = oForms.get(sClave).Apellido1.trim().unescapeHtml4();
                                if (oForms.get(sClave).Apellido2 != null) {
                                    oNew.LastName += ' ' + oForms.get(sClave).Apellido2.trim().unescapeHtml4();
                                }
                            }

                            if (oForms.get(sClave).EMAIL != null){
                                oNew.PersonEmail = oForms.get(sClave).EMAIL.trim().unescapeHtml4();
                            }

                            if (oForms.get(sClave).Idioma != null){
                                oNew.CC_Idioma__pc = oForms.get(sClave).Idioma.trim().unescapeHtml4();
                            }
                            else{
                                oNew.CC_Idioma__pc = 'es';
                            }

                            if (oForms.get(sClave).NIF != null){
                                oNew.CC_Numero_Documento__pc = oForms.get(sClave).NIF.trim().unescapeHtml4();
                            }
                        }
                        oNew.CC_Numero_Documento__c = sDniC;
                        if (oForms.get(sClave).Telefono != null){
                            oNew.Phone = oForms.get(sClave).Telefono.trim().unescapeHtml4();
                        }

                        if (oForms.get(sClave).EMAIL != null){
                            oNew.CC_Email__c = oForms.get(sClave).EMAIL.trim().unescapeHtml4();
                        }
                        if(!esConfidencial){
                            oNewAcc.add(oNew);
                        }
                    }
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
        if (!oCuentasId.isEmpty()){
            oSearch.addAll(oCuentasId.keySet());
        }
        if (!oCuentasDupId.isEmpty()){
            oSearch.addAll(oCuentasDupId.keySet());
        }
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

            if (oForms.get(sClave).Nombre != null){
                sNom = oForms.get(sClave).Nombre.trim().unescapeHtml4();
            }

            if (oForms.get(sClave).Apellido1 != null){
                sApe1 = oForms.get(sClave).Apellido1.trim().unescapeHtml4();
            }

            if (oForms.get(sClave).Apellido2 != null){
                sApe2 = oForms.get(sClave).Apellido2.trim().unescapeHtml4();
            }

            if (oForms.get(sClave).NIF != null){
                sDniC = oForms.get(sClave).NIF.trim().unescapeHtml4();
            }

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

                if (!bEncontrado){
                    bCrear = true;
                }
            }

            // Para clientes de tipo PersonAccount no generamos contacto, ya lo hace el PA.
            if (sTipoNif != 'CIF') {

                bCrear = false;
            }

            if (bCrear)
            {
                Contact oNew = new Contact();
                if(!bConfidencial) {
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

                        oNew.RecordTypeId = RECTYPECLIENTECONTACT;

                        oNew.FirstName = sNom;
                        oNew.LastName = (sApe1 + ' ' + sApe2).trim();
                        oNew.AccountId = sAccId;

                        if (sDniC != null){
                            oNew.CC_Numero_Documento__c = sDniC;
                        }

                        if (oForms.get(sClave).Telefono != null){
                            oNew.Phone = oForms.get(sClave).Telefono.trim().unescapeHtml4();
                        }

                        if (oForms.get(sClave).EMAIL != null){
                            oNew.Email = oForms.get(sClave).EMAIL.trim().unescapeHtml4();
                        }

                        // Asignar el idioma del caso.
                        if (oParamAux != null && !oParamAux.isEmpty() && oParamAux.get('CC_Idioma_FORMWEB') != null)
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

                        oContactNew.add(oNew);
                    }
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

                    if (oContactos.get(sDocIn) != null && oContactos.get(sDocIn) == sDocIn)
                    {
                        // Asignar ID.
                        oContactos.put(sDocIn, oResIn[i].getId());
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
                    oForms.get(sClave).ccContactId = oContactos.get(sDoc);

                    // Actualizar el AccountId.
                    if (oCuentas.get(sDoc) != null){
                        oForms.get(sClave).ccAccountId = oCuentas.get(sDoc);
                    }

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

        DateTime dt = DateTime.now();
        Long dateInMilliseconds = dt.getTime();
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
        ID jobID;
        try {
            jobID = System.enqueueJob(new SAC_QueueableCrearCanalesComunicacion('EMAIL', oContMailAct, oMailCont, oDatosCont), options);    
        } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
        oMailCont =  null;
        oDatosCont = null;

        DateTime dt2 = DateTime.now();
        Long dateInMilliseconds2 = dt2.getTime();
        AsyncOptions options2 = new AsyncOptions();
        options2.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds2)).build();
        ID jobID2;
        try {
            jobID2 = System.enqueueJob(new SAC_QueueableCrearCanalesComunicacion('TELEFONO', oContMailAct, oTelCont, oDatosContTel), options2);    
        } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
        oTelCont = null;
        oDatosContTel = null;

        return;
    }

    /*****************************************************************
     * Proposito: Método para recuperar los datos de formularios a buscar su configuración.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    static private void getDatosFormularioConfigurados(Map<String,SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oMapForm, Set<String> oApp, Set<String> oTipificacionWeb, Set<String> oValTrad, Map<String,Map<String,String>> oMapTipificacion)
    {

        if (oMapForm == null || oApp == null || oTipificacionWeb == null || oValTrad == null){
            return;
        }

        if (!oMapForm.isEmpty()){
            for (String sForm : oMapForm.keySet()){
                if (oMapForm.get(sForm) != null){
                    if (oMapForm.get(sForm).Aplicacion.trim().unescapeHtml4() != null){
                        oApp.add(oMapForm.get(sForm).Aplicacion.trim().unescapeHtml4());
                    }

                    if (oMapForm.get(sForm).ccClasificacionWeb != null){
                        oTipificacionWeb.add(oMapForm.get(sForm).ccClasificacionWeb);
                    }

                    if (oMapForm.get(sForm).Motivo != null && oMapForm.get(sForm).Motivo.trim().unescapeHtml4() != '')
                    {
                        oValTrad.add(oMapForm.get(sForm).Motivo.trim().unescapeHtml4());
                    }

                    if (oMapForm.get(sForm).Producto != null && oMapForm.get(sForm).Producto.trim().unescapeHtml4() != '')
                    {
                        oValTrad.add(oMapForm.get(sForm).Producto.trim().unescapeHtml4());
                    }

                    if (oMapForm.get(sForm).Ambito != null && oMapForm.get(sForm).Ambito.trim().unescapeHtml4() != '')
                    {
                        oValTrad.add(oMapForm.get(sForm).Ambito.trim().unescapeHtml4());
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

    /*****************************************************************
     * Proposito: Método para recuperar la configuración de reglas de asignación y motivos excluidos del portal.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    static private void getConfigAppFormulario(Set<String> oApp, Map<String,String> oMapRules, Map<String,String> oMotivosExcl)
    {

        if (oApp == null || oMapRules == null || oMotivosExcl == null){
            return;
        }

        Set<String> oRule = new Set<String>();

        if (!oApp.isEmpty()){
            // Recorrer las aplicaciones para obtener las reglas.
            for (String sApp : oApp){
                if (sApp != ''){
                    List<SAC_Config_FormWeb__mdt> oConfig= getConfigApp (sApp);
                    for(SAC_Config_FormWeb__mdt oConfigApp : oConfig) {
                        if (oConfigApp != null){
                            if (oConfigApp.CC_ReglaAssigCaso__c != null && oConfigApp.CC_ReglaAssigCaso__c != ''){
                                oRule.add(oConfigApp.CC_ReglaAssigCaso__c);
                            }
    
                            /*if (oConfigApp.CC_MotivosExcl__c != null && oConfigApp.CC_MotivosExcl__c != ''){
                                oMotivosExcl.put(sApp,oConfigApp.CC_MotivosExcl__c);
                            }*/
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

    /*****************************************************************
     * Proposito: Método para excluir formularios no compatibles con el Web Service.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    static private Boolean excluirFormulariosNoCompatibles (Map<String,SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oMapForm, Map<String,String> oMotivosExcl, List<CC_TrazaInt__c> oTraza, List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes, CC_InterfaceSettings__mdt oConfig)
    {

        Boolean bTrazaOk = true;

        if (oMapForm == null || oMotivosExcl == null){
            return true;
        }

        // Controlar motivos excluidos.
        if (!oMapForm.isEmpty() && !oMotivosExcl.isEmpty()){
            for (String sForm : oMapForm.keySet()){
                if (oMapForm.get(sForm) != null){
                    String sApp = '';
                    String sMotivo = '';

                    if (oMapForm.get(sForm).Aplicacion != null && oMapForm.get(sForm).Aplicacion != ''){
                        sApp = oMapForm.get(sForm).Aplicacion.trim().unescapeHtml4();
                    }

                    if (oMapForm.get(sForm).Motivo != null && oMapForm.get(sForm).Motivo != ''){
                        sMotivo = oMapForm.get(sForm).Motivo.trim().unescapeHtml4();
                    }
                    if (sApp != '' && sMotivo != '' && oMotivosExcl.get(sApp) != '' && oMotivosExcl.get(sApp).contains(sMotivo)){
                        // Error validación datos entrada.
                        String sCodErr = '3';
                        String sDetErr = 'Error al preparar el caso. Motivo no permitido.';
                        bTrazaOk = false;

                        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
                        oAux.sCodError = sCodErr;
                        oAux.sDetalleError = sDetErr;
                        oAux.sNumCaso = '';
                        oAux.sRefUser = oMapForm.get(sForm).REFUSUARIO;
                        oAux.sNIF = oMapForm.get(sForm).NIF;
                        oAux.sTexto = oMapForm.get(sForm).Texto;
                        oRes.add(oAux);

                        String sIdent = '';
                        if (oMapForm.get(sForm).REFUSUARIO != null){
                            sIdent = oMapForm.get(sForm).REFUSUARIO;
                        }
                        else{
                            sIdent = oMapForm.get(sForm).NIF;
                        }

                        if (oTraza != null)
                        {
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'SAC_WS_FormularioCasos_DET', sIdent, oAux.sNIF, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }

                        // Quitar el formulario.
                        oMapForm.remove(sForm);
                    }
                }
            }
        }

        return bTrazaOk;
    }

    /*****************************************************************
     * Proposito: Método principal publicado para la creación de Casos
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    @HttpPost
    global static List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> createCase(List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oDataIn)
    {	
        String sTipoNif = '';
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output>();
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oResPortal = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output>();

        Map<String,SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oMapForm = new Map<String,SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        List<Case> oNewCase = new List<Case>();
        Map<String, List<ContentVersion>> mapAdjuntos = new Map<String, List<ContentVersion>>();
        Map<String,String> oMapRules = new Map<String,String>();
        Map<String,Map<String,String>> oMapTipificacion = new Map<String,Map<String,String>>();
        Map<String,Object> oParamLOV = new Map<String, Object>();
        Map<String,String> oMotivosExcl = new Map<String,String>();
        /** Añadimos el Robot de portal */
        for (SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oForm : oDataIn){
            if(oForm.nombre == 'Robot' && oForm.apellido1 == 'Portal' && oForm.email == 'portal@silk.es' && oForm.telefono == '0034666666666' && 
            oForm.nif == '00000004G' && oForm.cliente == 'No' && oForm.clienteLOE == 'No'){
                SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oResRobot = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
                oResRobot.sCodError = '0';
                oResRobot.sDetalleError = 'Llamada con el robot de portal';
                oResPortal.add(oResRobot);
            }
            if(!oResPortal.isEmpty()){
                return oResPortal;
            }
            
        }
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
            oConfig = CC_MetodosUtiles.getInterfazConfigBody('SAC_WS_FormularioCasos');
        } catch (Exception e) {
            oTraza = null;
        }

        if (oConfig == null)
        {
            // Interfaz no configurada o activa.
            SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
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
        oTrazaProc = crearTrazaPadre (oConfig, 'SAC_WS_FormularioCasos', 'SAC_WS_FormularioCasos', '', oDataIn);
        try {
            // Control de datos.
            if (oDataIn != null)
            {
                // Obtenemos la blacklist de NIF para descartar las peticiones provenientes del robot de comprobación
                List<String> blacklistNif = new List<String>();
                for (CC_Valores__mdt valor : [SELECT CC_Valor__c FROM CC_Valores__mdt WHERE CC_Lista__c = 'CC_MailCenter_Blacklist_NIF']) {
                    blacklistNif.add(valor.CC_Valor__c);
                }
                for (SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oForm : oDataIn)
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
                                SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
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
                                    sIdent = oForm.NIF;
                                if (oTraza != null)
                                {
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'SAC_WS_FormularioCasos_DET', sIdent, oAux.sNIF, oForm, oAux, false, sCodErr, sDetErr);
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
                        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
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
                        if (oForm.REFUSUARIO != null){
                            sIdent = oForm.REFUSUARIO;
                        }
                        else{
                            sIdent = oForm.NIF;
                        }

                        if (oTraza != null)
                        {
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'SAC_WS_FormularioCasos_DET', sIdent, oAux.sNIF, oForm, oAux, false, sCodErr, sDetErr);
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
                Boolean bAux = excluirFormulariosNoCompatibles (oMapForm, oMotivosExcl, oTraza, oRes, oConfig);
                if (!bAux){
                    bTrazaOk = false;
                }

                oApp = null;
                oMotivosExcl = null;

                // Inicializar el objeto de listas de valores y parámetros.
                List<String> oLista = new List<String>();
                oLista.add('CC_Idioma_FORMWEB');
                oParamAux = CC_MetodosUtiles.getLOVMeta(oLista);
                oLista = null;

                // Añadir la configuración de reglas de asignación.
                if (!oMapRules.isEmpty()){
                    oParamAux.put('CC_ReglasAss', oMapRules);
                }
                oMapRules = null;

                // Añadir las LOV a los parámetros.
                if (!oParamLOV.isEmpty()){
                    oParamAux.putAll(oParamLOV);
                }
                oParamLOV = null;
            }

            // Preparar creación de los casos.
            if (!oMapForm.isEmpty()){
                // Buscar contactos y crear los que no existan.
                if (!oContForm.isEmpty()){                    
                    gestionCuentasContactosFormulario (oContForm, oMapForm, oParamAux, sTipoNif);
                }
                oContForm = null;
				// Búsqueda de casos potencialmente duplicados.
                Decimal tiempoDuplicidadDecimal = [SELECT CC_Tiempo_Duplicidad__c FROM CC_Config_FormWeb_Duplicado__mdt WHERE CC_Aplicacion__c = 'FORMWEB' LIMIT 1].CC_Tiempo_Duplicidad__c;
                Integer tiempoDuplicidad = tiempoDuplicidadDecimal != null ? tiempoDuplicidadDecimal.intValue() : 0;
				for (Case oCasoDuplicado : [SELECT Id, CC_Numero_Documento__c, CC_MailTelfNotif__c, CC_SuppliedProducto__c, CC_RefExterna__c, CreatedDate 
                FROM Case WHERE CC_Numero_Documento__c in :nifList AND CreatedDate >= :Datetime.now().addMinutes(-tiempoDuplicidad) ORDER BY CreatedDate ASC]) {
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
                        List<ContentVersion> contents = new List<ContentVersion>();

                        Map<String,Object> oResCaso = prepararCaso (oMapForm.get(sForm), oParamAux, oMapTipificacion, casosDuplicadosMap, sTipoNif);
                        for (String sRet : oResCaso.keySet())
                        {
                            if (sRet == 'Estado' && oResCaso.get(sRet) != null){
                                sEstado = (String)oResCaso.get(sRet);
                            }

                            if (sRet == 'Detalle' && oResCaso.get(sRet) != null){
                                sDetalle = (String)oResCaso.get(sRet);
                            }

                            if (sRet == 'Caso' && oResCaso.get(sRet) != null){
                                oCaso = (Case)oResCaso.get(sRet);
                            }

                            if(sRet == 'Adjuntos' && oResCaso.get(sRet) != null){
                                contents = (List<ContentVersion>)oResCaso.get(sRet);
                            }
                        }
                        if (sEstado == 'OK')
                        {	
                            if (oCaso != null)
                            {
                                oNewCase.add(oCaso);
                                if(!contents.isEmpty()){
                                    mapAdjuntos.put(oCaso.CC_RefExterna__c, contents);
                                }
                            }else{
                                // Error al preparar el caso.
                                String sCodErr = '2';
                                String sDetErr = 'Error al preparar el caso. ' + sDetalle;
                                bTrazaOk = false;

                                SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
                                oAux.sCodError = sCodErr;   oAux.sDetalleError = sDetErr;   oAux.sNumCaso = ''; oAux.sRefUser = sForm;  oAux.sNIF = oMapForm.get(sForm).NIF;    oAux.sTexto = oMapForm.get(sForm).Texto;
                                oRes.add(oAux);

                                if (oTraza != null)
                                {
                                    CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'SAC_WS_FormularioCasos_DET', sForm, oAux.sNIF, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
                                    oTraza.add(oTrazaDet);
                                }
                            }
                        }else{
                            // Error al preparar el caso.
                            String sCodErr = '3';
                            String sDetErr = 'Error al preparar el caso. ' + sDetalle;
                            bTrazaOk = false;

                            SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
                            oAux.sCodError = sCodErr;   oAux.sDetalleError = sDetErr;  oAux.sNumCaso = '';     oAux.sRefUser = sForm;   oAux.sNIF = oMapForm.get(sForm).NIF;    oAux.sTexto = oMapForm.get(sForm).Texto;
                            oRes.add(oAux);

                            if (oTraza != null)
                            {
                                CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'SAC_WS_FormularioCasos_DET', sForm, oAux.sNIF, oMapForm.get(sForm), oAux, false, sCodErr, sDetErr);
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
				/* *****************************
                * ********GGH Y FRAUDE*********
                * *****************************/
                createFormularioGGH(oDataIn, oResUp[0].Id);
                createFormularioFraude(oDataIn, oResUp[0].Id);
                
                List<Id> idsContents = new List<Id>();

                if(!mapAdjuntos.isEmpty()){
                    List<ContentVersion> contents = new List<ContentVersion>();
                    for(String refExterna : mapAdjuntos.keySet()){
                        contents.addAll(mapAdjuntos.get(refExterna));
                    }

                    insert contents;

                    for(ContentVersion cv : contents){
                        idsContents.add(cv.Id);
                    }
                }

                // First get the Content Document Id from ContentVersion Object
                List<ContentVersion> conDocs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :idsContents];
                //create ContentDocumentLink  records
                List<ContentDocumentLink> contentDocuments = new List<ContentDocumentLink>();
                for(ContentVersion conDoc : conDocs){
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = oResUp[0].Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                    conDocLink.ContentDocumentId = conDoc.ContentDocumentId;  //ContentDocumentId Id from ContentVersion
                    conDocLink.shareType = 'V';
                    contentDocuments.add(conDocLink);
                }

                insert contentDocuments;

               /* if(String.isNotBlank(oNewCase[0].AccountId)){
                    SAC_CaseReclamante__c reclamante = new SAC_CaseReclamante__c(SAC_Account__c = oNewCase[0].AccountId,
					                                                             SAC_Contact__c = oNewCase[0].ContactId,
					                                                             SAC_Case__c = oResUp[0].Id,
					                                                             SAC_ReclamantePrincipal__c = true);
                    insert reclamante;
                }*/
                Integer iSize = oResUp.size();

                for (Integer i = 0; i < iSize; i++){
                    if (oResUp[i].isSuccess())
                    {
                        // Inserción correcta.
                        oRefCasos.add(oNewCase[i].CC_RefExterna__c);

                    }else{
                        // Error. Trazar.
                        String sErrAux = '';
                        for(Database.Error err : oResUp[i].getErrors()) {
                            if (sErrAux != ''){
                                sErrAux = sErrAux + '. ';
                            }
                            sErrAux = sErrAux + err.getMessage();
                        }

                        String sCodErr = '4';
                        String sDetErr = 'Error al crear el caso. ' + sErrAux;
                        bTrazaOk = false;

                        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
                        oAux.sCodError = sCodErr;
                        oAux.sDetalleError = sDetErr;
                        oAux.sNumCaso = '';
                        oAux.sRefUser = oNewCase[i].CC_RefExterna__c;
                        oAux.sNIF = oMapForm.get(oNewCase[i].CC_RefExterna__c).NIF;
                        oAux.sTexto = oMapForm.get(oNewCase[i].CC_RefExterna__c).Texto;
                        oRes.add(oAux);

                        if (oTraza != null)
                        {
                            CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'SAC_WS_FormularioCasos_DET', oNewCase[i].CC_RefExterna__c, oAux.sNIF, oNewCase[i], oAux, false, sCodErr, sDetErr);
                            oTraza.add(oTrazaDet);
                        }
                    }
                }
                //si la reclamacion esta en database correctamente enviar a IA
                List<String> idReclamacionesIA = new List<String>();
                for (Database.UpsertResult resultado : oResUp){
                    if (resultado.isSuccess() && resultado.isCreated()){
                        idReclamacionesIA.add(resultado.getId());
                    }
                }
                List<Case> reclamacionesIA = [SELECT Id, ownerId, Description, SAC_GenialEstado__c FROM Case WHERE Id IN :idReclamacionesIA];
                String nombreCola = 'SAC_GenialPdteIA';
                QueueSobject colaIA = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = : nombreCola AND SobjectType = 'Case' LIMIT 1];
                for (Case recResult : reclamacionesIA){
                    if (recResult.OwnerId == colaIA.QueueId || recResult.SAC_GenialEstado__c == 'SAC_005'){
                        //SAC_GenialSendAzure.sendToIA(recResult.Id, recResult.Description);
                        SAC_GenialUtils.balanceador(recResult.Id, 'SAC_Formulario', recResult.Description);
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
                    SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
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
                        CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'SAC_WS_FormularioCasos_DET', oCasoAux.CC_RefExterna__c, oAux.sNIF, oCasoAux, oAux, true, '0', '');
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
            sErrGen = 'Error en la ejecución del proceso SAC_WS_FormularioCasos. ' + e.getMessage();
            SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output oAux = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output();
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

        if (!bTrazaOk){
            sErrProc = 'Error procesando datos. Revisar detalle.';
        }

        if (bNoDatos){
            sErrProc = 'No se han enviado datos para procesar.';
        }

        cerrarTrazaPadre (oConfig, oTrazaProc, oRes, bTrazaOk, sErrProc, sErrGen);

        return oRes;
    }

}