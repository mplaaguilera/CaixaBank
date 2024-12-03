/**
*   @description SEG_wsValijaStatusFiles
*/
@RestResource(urlMapping='/v1/valijaStatus/*')
global with sharing class SEG_wsValijaStatusFiles {

    global class SEG_WS_StatusFile_PostInput {
        global String operation {get;set;}
        global String caseId {get;set;}
        global String valijaId {get;set;}
        global String status {get;set;}
        global String detalleProceso {get;set;}
        global String requiereJustificantes {get;set;}
        global Integer numeroOperaciones {get;set;}
        global Integer numeroOperacionesCSO {get;set;}
        global String fechaValorSLA {get;set;}
        global List<String> fileList {get;set;}
        global List<String> emails {get;set;}
    }

    global class SEG_WS_StatusFile_PostOutput {
        global String resultado {get;set;}
        global String mensaje {get;set;}
        global String codigo {get;set;}
    }

    /**
     * ***************************************************************
     * ***************************************************************
     * @description Método POST del servicio REST.
     * ***************************************************************
     * ***************************************************************
     */
    @HttpPost
    global static SEG_WS_StatusFile_PostOutput informarEstado ()
    {
        SEG_WS_StatusFile_PostOutput resultadoWS = new SEG_WS_StatusFile_PostOutput();
        Boolean bOk = true;
        RestRequest peticionREST = RestContext.request;
        
        // Tratar los datos de entrada.
        SEG_WS_StatusFile_PostInput datosEntradaStatus;
        if (peticionREST.requestBody != null)
        {
            datosEntradaStatus = (SEG_WS_StatusFile_PostInput)JSON.deserializeStrict(peticionREST.requestBody.toString(), SEG_WS_StatusFile_PostInput.class);
        }
        
        	CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'Robotics Valija Status';
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_FechaFin__c = datetime.now();

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segValijaStatus_POST','POST','POST',JSON.serialize(datosEntradaStatus));
           	insert trazaPOST;
        } catch (Exception e) {
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = 'Error en la trazabilidad';
            oTraza.CC_DetalleError__c = e.getMessage();
            insert oTraza;
        }

        // Validar URI.
        if (bOk)
        {
            List<String> elemURI = RestContext.request.requestURI.split('/');
            if (elemURI.size() != 3)
            {
                bOk = false;
                resultadoWS.codigo = '9002';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = 'La URI del servicio no está bien formada';
            }
        }

        if (datosEntradaStatus.operation == 'FICHEROS_ENVIADOS')
        {
            // Recepción del estado de ficheros subidos para las entradas de paquetería.
            resultadoWS = SEG_ValijaStatusFicherosEnviados.informarEstado(datosEntradaStatus);

        }else if (datosEntradaStatus.operation == 'FICHEROS_RECIBIDOS'){
            // Recepción de la confirmación de Valija que ha descargado todos los ficheros enviados en la petición derivada desde Salesforce.
            resultadoWS = SEG_ValijaStatusFicherosRecibidos.informarEstado(datosEntradaStatus);

        }else if (datosEntradaStatus.operation == 'FICHEROS_PROCESADOS'){
            // Recepción del estado de Ficheros procesados y operaciones realizadas de la petición derivada a Valija.
            resultadoWS = SEG_ValijaStatusFicherosProcesados.informarEstado(datosEntradaStatus);

        }else if (datosEntradaStatus.operation == 'JUSTIFICANTES'){
            // Recepción del estado de Justificantes cargados en Salesforce.
            resultadoWS = SEG_ValijaStatusJustificantes.informarEstado(datosEntradaStatus);
        }else{
            // Error, operación no válida.
            bOk = false;
            resultadoWS.codigo = '9000';
            resultadoWS.resultado = 'NOK';
            resultadoWS.mensaje = 'El código de operación informado no es válido.';
        }       
        try {
            if (trazaPOST != null)
            {
                if (resultadoWS.resultado == 'NOK')
                {
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                }else{
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                }
            oTraza.CC_FinOK__c = true;
            insert oTraza;
            }
        } catch (Exception e) {
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = 'Error en la trazabilidad';
            oTraza.CC_DetalleError__c = e.getMessage();
            insert oTraza;
        }

        return resultadoWS;
    }
}