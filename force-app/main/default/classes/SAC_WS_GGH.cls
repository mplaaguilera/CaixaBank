/*****************************************************************
 * Name: SAC_WS_GGH
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Webservice para la comunicación con el sistema de Gastos Hipotecarios (GGH)
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             --             Nicolás García  06/04/22     Creación
*****************************************************************/
@RestResource(urlMapping='/SAC_GGH/*')
global without sharing class SAC_WS_GGH {
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPEMAESTRO = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();

    /*****************************************************************
     * Proposito: Definición de Wrapper para los parámetros de entrada
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    global class SAC_WS_GGH_Input {
        global String idPretension {get;set;}
        global String idTarea {get;set;}
        global String numContrato {get;set;}
        global String cuentaAbono {get;set;}
        global Decimal impAbonRegistro {get;set;}
        global Decimal impAbonNotaria {get;set;}
        global Decimal impAbonGestoria {get;set;}
        global Decimal impAbonTasacion {get;set;}
        global String estadoRegistro {get;set;}
        global String estadoNotaria {get;set;}
        global String estadoGestoria {get;set;}
        global String estadoTasacion {get;set;}
        global String fechaAbono {get;set;}
        global String observaciones {get;set;}
    }

    /*****************************************************************
     * Proposito: Definición de Wrapper para los parámetros de salida
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    global class SAC_WS_GGH_Output {
        global String sCodError {get;set;}
        global String sDetalleError {get;set;}
        global Boolean bResultadoOk {get;set;}
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
        SAC_WS_GGH.SAC_WS_GGH_Input oEntradaConvertido = (SAC_WS_GGH.SAC_WS_GGH_Input)oEntrada;

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

                // Guardar en BBDD.
                insert oTraza;
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
    private static CC_TrazaInt__c cerrarTrazaPadre (CC_InterfaceSettings__mdt oConfig, CC_TrazaInt__c oTraza, Object oSalida, Boolean bOk, String sTipoError, String sDetalleError)
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
                update oTraza;
            }
        }

        return oTraza;
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
     * Proposito: Método principal para la comprobación de los importes
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  28/07/21     Creación
    *****************************************************************/
    @HttpPost
    global static SAC_WS_GGH.SAC_WS_GGH_Output comprobarImportes(SAC_WS_GGH.SAC_WS_GGH_Input iData)
    {
        SAC_WS_GGH.SAC_WS_GGH_Output oResponse = new SAC_WS_GGH.SAC_WS_GGH_Output();

        // Lista de trazas a crear.
        CC_TrazaInt__c oTrazaProc;
        List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();
        CC_InterfaceSettings__mdt oConfig;
        Boolean bTrazaOk = true;
        Boolean bNoDatos = false;
        String sErrGen = '';

        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody('SAC_WS_GGH');
        } catch (Exception e) {
            oTraza = null;
        }

        if (oConfig == null)
        {
            // Interfaz no configurada o activa.
            SAC_WS_GGH.SAC_WS_GGH_Output oAux = new SAC_WS_GGH.SAC_WS_GGH_Output();
            oAux.sCodError = '9999';
            oAux.sDetalleError = 'Proceso inactivo en Salesforce.';
            oAux.bResultadoOk = false;
            return oAux;
        }

        // Creamos la traza padre para medir tiempos totales.
        oTrazaProc = crearTrazaPadre (oConfig, 'SAC_WS_GGH', 'SAC_WS_GGH', '', iData);
        String sTrazaOrig = '';
        if (oTrazaProc != null){
            sTrazaOrig = oTrazaProc.Id;
        }

        try {
            //Lista para lanzar la alerta una vez hemos tenido respuesta
            List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
            List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
            // Control de datos.
            if (iData != null){
                if (String.isBlank(iData.idPretension) || String.isBlank(iData.idTarea)) {
                    String sCodErr = '4';
                    String sDetalleError = 'Los campos idPretension, idTarea deben estar rellenos.';
                    bTrazaOk = false;
                    Boolean bResultadoOk = false;

                    oResponse.sCodError = sCodErr;
                    oResponse.sDetalleError = sDetalleError;
                    oResponse.bResultadoOk = bResultadoOk;

                    if (oTraza != null){
                        CC_TrazaInt__c oTrazaDet = crearTrazaDetalle (oConfig, 'SAC_WS_GGH_DET', 'SAC_WS_GGH_DET', sTrazaOrig, iData, oResponse, false, sCodErr, sDetalleError);
                        oTraza.add(oTrazaDet);
                    } 
                }else{
                    List<Case> pretensiones = [SELECT Id, SAC_Reclamacion__r.OwnerId, OwnerId, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c, SAC_ImpAbonadoGestoria__c, SAC_ImpAbonadoNotaria__c,
                                                SAC_ImpAbonadoRegistros__c, SAC_ImpAbonadoTasacion__c
                                                FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND Id =: iData.idPretension];
                    List<SAC_Accion__c> tareas = [SELECT Id, SAC_ImporteGestoriaAbonar__c, SAC_ImporteNotariaAbonar__c, SAC_ImporteRegistroAbonar__c,
                                                    SAC_ImporteTasacionAbonar__c,SAC_Estado__c, SAC_ImporteResueltoGGH__c, SAC_Reclamacion__c, SAC_Pretension__c,
                                                    OwnerId, Name
                                                    FROM SAC_Accion__c 
                                                    WHERE RecordTypeId =: RECTYPEMAESTRO AND Id =: iData.idTarea];
                    
                    if(pretensiones.isEmpty()){
                        String sCodErr = '5';
                        String sDetalleError = 'El Id de la pretensión no coincide con ningún registro en Salesforce.';
                        bTrazaOk = false;
                        Boolean bResultadoOk = false;
    
                        oResponse.sCodError = sCodErr;
                        oResponse.sDetalleError = sDetalleError;
                        oResponse.bResultadoOk = bResultadoOk;
                    }
                    else if(tareas.isEmpty()){
                        String sCodErr = '6';
                        String sDetalleError = 'El Id de la tarea no coincide con ningún registro en Salesforce.';
                        bTrazaOk = false;
                        Boolean bResultadoOk = false;
    
                        oResponse.sCodError = sCodErr;
                        oResponse.sDetalleError = sDetalleError;
                        oResponse.bResultadoOk = bResultadoOk;
                    }
                    else{
                        //ESTE ES EL CAMINO BUENO, HABRÁ QUE INTRODUCIR AQUÍ LAS TRAZAS Y HACER LA EJECUCIÓN DE LA CLASE.
                        Case pretension = pretensiones[0];
                        SAC_Accion__c tarea = tareas[0];

                        if(tarea.SAC_Estado__c == 'SAC_PendienteAsignar' || tarea.SAC_Estado__c == 'SAC_PendienteRevision'){
                            oResponse.sCodError = 'La ejecución ha sido OK.';
                            oResponse.sDetalleError = 'La ejecución ha sido OK. ';
                            oResponse.bResultadoOk = true;
                            String estado = '';
                            Integer estadoAuxiliarTarea = 0;
                            switch on iData.estadoRegistro {
                                when '0' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_001';
        
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro sin respuesta. '; 
                                }
                                
                                when '02' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_002';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro sin respuesta. ';
                                }

                                when '24' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_003';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro sin respuesta. ';
                                }

                                when '52' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_004';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro sin respuesta. ';
                                }

                                when '53' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_005';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro con respuesta. ';
                                }

                                when '54' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_006';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro con respuesta. ';
                                }

                                when '57' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_007';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro con respuesta. ';
                                }

                                when '80' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_008';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro con respuesta. ';
                                }

                                when '81' {
                                    tarea.SAC_EstadoRegistro__c = 'SAC_009';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Registro sin respuesta. ';
                                }
                            }

                            switch on iData.estadoNotaria {
                                when '0' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_001';
        
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria sin respuesta. '; 
                                }
                                
                                when '02' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_002';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria sin respuesta. ';
                                }

                                when '24' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_003';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria sin respuesta. ';
                                }

                                when '52' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_004';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria sin respuesta. ';
                                }

                                when '53' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_005';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria con respuesta. ';
                                }

                                when '54' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_006';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria con respuesta. ';
                                }

                                when '57' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_007';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria con respuesta. ';
                                }

                                when '80' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_008';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria con respuesta. ';
                                }

                                when '81' {
                                    tarea.SAC_EstadoNotaria__c = 'SAC_009';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Notaria sin respuesta. ';
                                }                               
                            }

                            switch on iData.estadoGestoria {
                                when '0' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_001';
        
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria sin respuesta. '; 
                                }
                                
                                when '02' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_002';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria sin respuesta. ';
                                }

                                when '24' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_003';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria sin respuesta. ';
                                }

                                when '52' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_004';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria sin respuesta. ';
                                }

                                when '53' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_005';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria con respuesta. ';
                                }

                                when '54' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_006';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria con respuesta. ';
                                }

                                when '57' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_007';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria con respuesta. ';
                                }

                                when '80' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_008';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria con respuesta. ';
                                }

                                when '81' {
                                    tarea.SAC_EstadoGestoria__c = 'SAC_009';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Gestoria sin respuesta. ';
                                }                                
                            }

                            switch on iData.estadoTasacion {
                                when '0' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_001';
        
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion sin respuesta. '; 
                                }
                                
                                when '02' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_002';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion sin respuesta. ';
                                }

                                when '24' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_003';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion sin respuesta. ';
                                }

                                when '52' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_004';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion sin respuesta. ';
                                }

                                when '53' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_005';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion con respuesta. ';
                                }

                                when '54' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_006';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion con respuesta. ';
                                }

                                when '57' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_007';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion con respuesta. ';
                                }

                                when '80' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_008';
                                    estadoAuxiliarTarea ++;
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion con respuesta. ';
                                }

                                when '81' {
                                    tarea.SAC_EstadoTasacion__c = 'SAC_009';
                                
                                    oResponse.sDetalleError = oResponse.sDetalleError + 'Estado Tasacion sin respuesta. ';
                                }
                            }

                            if(estadoAuxiliarTarea > 0){
                                tarea.SAC_Estado__c = 'SAC_PteReenvio';
                                //Preparación de la alerta
                                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                                                    'SAC_021',
                                                                                    'La tarea ' + tarea.Name + ' ha sido respondida por GGH y requiere de su reenvío o finalización. Por favor revísela.',
                                                                                    tarea.OwnerId,
                                                                                    tarea.SAC_Pretension__c,
                                                                                    tarea.Id,
                                                                                    '');
                                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                                //Añadirla a la lista para posteriormente llamar al método
                                listaWrapperAlerta.add(wrapAlerta);
                            }
                            else{
                                tarea.SAC_Estado__c = 'SAC_Finalizada';
                            }
                            //System.debug('importes: ' + iData.impAbonGestoria + ' - ' + iData.impAbonNotaria + ' - ' + iData.impAbonRegistro + ' - ' + iData.impAbonTasacion);

                            Decimal totalImportesAbonados = 0;
                            if(iData.impAbonGestoria != null){
                                tarea.SAC_ImporteGestoriaAbonar__c = iData.impAbonGestoria;
                                //DE80978 31/07/23
                                pretension.SAC_ImpAbonadoGestoria__c = iData.impAbonGestoria;
                                totalImportesAbonados = totalImportesAbonados + iData.impAbonGestoria;
                            }
                            if(iData.impAbonNotaria != null){
                                tarea.SAC_ImporteNotariaAbonar__c = iData.impAbonNotaria;
                                //DE80978 31/07/23
                                pretension.SAC_ImpAbonadoNotaria__c = iData.impAbonNotaria;
                                totalImportesAbonados = totalImportesAbonados + iData.impAbonNotaria;
                            }
                            if(iData.impAbonRegistro != null){
                                tarea.SAC_ImporteRegistroAbonar__c = iData.impAbonRegistro;
                                //DE80978 31/07/23
                                pretension.SAC_ImpAbonadoRegistros__c = iData.impAbonRegistro;
                                totalImportesAbonados = totalImportesAbonados + iData.impAbonRegistro;
                            }
                            if(iData.impAbonTasacion != null){
                                tarea.SAC_ImporteTasacionAbonar__c = iData.impAbonTasacion;
                                //DE80978 31/07/23
                                pretension.SAC_ImpAbonadoTasacion__c = iData.impAbonTasacion;
                                totalImportesAbonados = totalImportesAbonados + iData.impAbonTasacion;
                            }
                            tarea.OwnerId = pretension.OwnerId;
                            Database.SaveResult srList = Database.update(tarea, false);
                            //System.debug(srList);
                            
                            //DE80978 31/07/23
                            listaAcciones = [SELECT Id, SAC_ImporteAbonar__c
                                            FROM SAC_Accion__c 
                                            WHERE SAC_Pretension__c = :pretension.Id AND SAC_ImporteAbonar__c <> null];
                            if (!listaAcciones.isEmpty()) {
                                for (SAC_Accion__c accion : listaAcciones) {
                                    totalImportesAbonados = totalImportesAbonados + accion.SAC_ImporteAbonar__c;
                                }
                            }
                            pretension.CC_Importe_Abonado__c = totalImportesAbonados;
                            Database.SaveResult srPretension = Database.update(pretension, false);
                        }
                        else{
                            oResponse.sCodError = 'El estado del registro no es "En Gestión" o en "Pendiente revisión".';
                            oResponse.sDetalleError = 'La ejecución ha fallado';
                            oResponse.bResultadoOk = false;
                        }
                        //Si se han creado alertas, las insertamos
                        if (!listaWrapperAlerta.isEmpty()) {
                            SAC_Alertas.generarAlertas(listaWrapperAlerta);
                        }
                    }
                }
            }else{
                // No hay datos de entrada.
                bTrazaOk = false;
                bNoDatos = true;
            }
            // Actualizar trazas hijas.
            if (oTraza != null && !oTraza.isEmpty())
            {
                Database.SaveResult[] oResUp = Database.insert(oTraza, false);
            }


        } catch (Exception e) {

            // Trazar error.
            bTrazaOk = false;
            sErrGen = 'Error en la ejecución del proceso SAC_WS_GGH. ' + e.getMessage();

            // Interfaz no configurada o activa.
            SAC_WS_GGH.SAC_WS_GGH_Output oAux = new SAC_WS_GGH.SAC_WS_GGH_Output();
            oAux.sCodError = '9999';
            oAux.sDetalleError = sErrGen;
            oAux.bResultadoOk = bTrazaOk;
            return oAux;
        }

        // Finalizar traza padre para obtener tiempos totales.
        String sErrProc = '';

        if (!bTrazaOk){
            sErrProc = 'Error procesando datos. Revisar detalle.';
        }

        if (bNoDatos){
            sErrProc = 'No se han enviado datos para procesar.';
        }

        oTrazaProc = cerrarTrazaPadre (oConfig, oTrazaProc, oResponse, bTrazaOk, sErrProc, sErrGen);

        return oResponse;
    }
}