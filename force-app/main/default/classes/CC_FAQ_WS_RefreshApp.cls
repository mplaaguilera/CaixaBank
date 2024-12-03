@RestResource(urlMapping='/CC_RefreshApp/*')
global with sharing class CC_FAQ_WS_RefreshApp {

    /*
        Clase para publicar un servicio Rest para el refresco de una aplicación de chat.
    */

    /*
        Clase para los parámetros de entrada.
    */
    global class CC_WS_Input {

        global String Aplicacion {get;set;}
    }

    /*
        Clase para los parámetros de salida.
    */
    global class CC_WS_Output {

        global String CodError {get;set;}
        global String DetalleError {get;set;}
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
                insert oTraza;
            }
        }

        return oTraza;
    }

    /*
        Método publicado para actualizar la aplicación.
    */
    @HttpPost
    global static CC_FAQ_WS_RefreshApp.CC_WS_Output refrescarApp (CC_FAQ_WS_RefreshApp.CC_WS_Input oDataIn)
    {
        CC_FAQ_WS_RefreshApp.CC_WS_Output oRes = new CC_FAQ_WS_RefreshApp.CC_WS_Output();

        // Lista de trazas a crear.
        CC_TrazaInt__c oTrazaProc;
        CC_InterfaceSettings__mdt oConfig;
        Boolean bTrazaOk = true;
        Boolean bNoDatos = false;
        String sErrGen = '';

        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_WS_RefreshApp');
        } catch (Exception e) {
            oConfig = null;
        }

        if (oConfig == null)
        {
            // Interfaz no configurada o activa.
            oRes.CodError = '9999';
            oRes.DetalleError = 'Proceso inactivo en Salesforce.';
            return oRes;
        }

        String sInputData = '';
        if (oDataIn != null)
        {
            sInputData = oDataIn.Aplicacion;
        }

        // Creamos la traza padre para medir tiempos totales.
        oTrazaProc = crearTrazaPadre (oConfig, 'CC_WS_RefreshApp', sInputData, '', oDataIn);

        try {

            if (oDataIn != null)
            {
                if (!String.isBlank(oDataIn.Aplicacion))
                {
                    CC_FAQ.refrescarApps (oDataIn.Aplicacion);

                    oRes.CodError = '0';
                    oRes.DetalleError = '';
                }else{
                    bTrazaOk = false;
                    oRes.CodError = '2';
                    oRes.DetalleError = 'No se ha informado una aplicación para actualizar.';
                }
            }else{
                bTrazaOk = false;
                oRes.CodError = '1';
                oRes.DetalleError = 'No hay un mensaje de entrada a procesar.';
            }


        } catch (Exception e) {

            // Trazar error.
            bTrazaOk = false;
            sErrGen = 'Error en la ejecución del proceso CC_FAQ_WS_RefreshApp. ' + e.getMessage();

            oRes.CodError = '9999';
            oRes.DetalleError = sErrGen;
        }

        // Finalizar traza padre para obtener tiempos totales.
        String sErrProc = '';
        if (!bTrazaOk)
            sErrProc = 'Error procesando datos. Revisar detalle.';

        oTrazaProc = cerrarTrazaPadre (oConfig, oTrazaProc, oRes, bTrazaOk, sErrProc, sErrGen);

        return oRes;        
    }
}