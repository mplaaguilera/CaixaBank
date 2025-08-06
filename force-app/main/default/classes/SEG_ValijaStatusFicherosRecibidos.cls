public with sharing class SEG_ValijaStatusFicherosRecibidos {

    /**
     * @description Gestión del estado para la operacion FICHEROS_RECIBIDOS que se informa desde Valija.
     */
    public static SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput informarEstado (SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput datosEntrada)
    {
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultadoWS = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput();
        Boolean bOk = true;

        // Validar datos de entrada.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = validarDatosEntradaPOST (datosEntrada);
            if (datosValidacionEntrada.get('resultado') != 'OK')
            {
                bOk = false;
            }
            resultadoWS.resultado = datosValidacionEntrada.get('resultado');
            resultadoWS.codigo = datosValidacionEntrada.get('codigo');
            resultadoWS.mensaje = datosValidacionEntrada.get('mensaje');
        }

        // Proceder a realizar las operaciones sobre el caso.
        if (bOk)
        {
            Map<String,String> resultadoActualizacion = actualizarCaso (datosEntrada);
            if (resultadoActualizacion.get('codigo') != 'OK')
            {
                bOk = false;
                resultadoWS.codigo = '9999';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = resultadoActualizacion.get('detalle');
            }else{
                resultadoWS.codigo = (String.isBlank(resultadoWS.codigo))?'0000':resultadoWS.codigo;
                resultadoWS.resultado = (String.isBlank(resultadoWS.resultado))?'OK':resultadoWS.resultado;
                resultadoWS.mensaje = (String.isBlank(resultadoWS.mensaje))?'':resultadoWS.mensaje;
            }
        }

        return resultadoWS;
    }

    /**
     * @description Validaciones a realizar para el servicio cuya operación es FICHEROS_ENVIADOS.
     * @param datosEntrada Datos de entrada del servicio REST.
     * @return Resultado de la validación.
     */
    public static Map<String,String> validarDatosEntradaPOST (SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput datosEntrada)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if (datosEntrada ==  null || String.isBlank(datosEntrada.caseId) || String.isBlank(datosEntrada.valijaId) || String.isBlank(datosEntrada.status))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje','No se han informado los datos obligatorios para la actualización del estado de la petición.');
            return resultadoValidacion;
        }

        Case datosCaso = SEG_wsValijaCasosComunes.recuperarInformacionCaso (datosEntrada.caseId);
        if (datosCaso == null)
        {
            // El caso informado no existe.
            resultadoValidacion.put('codigo','0001');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha encontrado el caso indicado en la petición.');
            return resultadoValidacion;
        }

        /* FIX. No comprobamos el estado iniciado, para evitar que la actualización del caso en el traslado acabe más tarde que la recepción del OK
        if (datosCaso.SEG_EstadoTrasladoValija__c != 'Iniciado')
        {
            resultadoValidacion.put('codigo','0006');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El caso no se ha enviado a Valija o está en un estado posterior.');
            return resultadoValidacion;
        }
        */

        // Validaciones del identificador de Valija. Acuerdo con el equipo de Valija.
        //  -> Caso con origen paquetería -> Nos enviarán en valijaId el identificador de paquetería original, validamos contra la referencia de paquetería.
        //  -> Caso con origen <> paquetería -> Nos enviarán en valijaId el identificador devuelto por la integración de traslado, validamos contra la referencia saliente.
        if (datosCaso.Origin == 'Paquetería' && String.isNotBlank(datosCaso.OS_Referencia_Valija__c) && datosEntrada.valijaId != datosCaso.OS_Referencia_Valija__c)
        {
            resultadoValidacion.put('codigo','0002');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'La referencia de Valija no es válida (paquetería).');
            return resultadoValidacion;
        }

        String valijaIdActual = (String.isNotBlank(datosCaso.SEG_RefSalienteValija__c)) ? datosCaso.SEG_RefSalienteValija__c : '';
        if (datosCaso.Origin != 'Paquetería' && String.isNotBlank(valijaIdActual) && datosEntrada.valijaId != valijaIdActual && !valijaIdActual.containsIgnoreCase('UNKNOWN'))
        {
            resultadoValidacion.put('codigo','0002');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'La referencia de Valija no es válida.');
            return resultadoValidacion;
        }

        if (datosEntrada.status != 'OK' && datosEntrada.status != 'NOK' && datosEntrada.status != 'PAK')
        {
            resultadoValidacion.put('codigo','0003');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha informado un estado válido.');
            return resultadoValidacion;
        }

        if (datosEntrada.status == 'OK' && datosEntrada.fileList != null && !datosEntrada.fileList.isEmpty())
        {
            Map<String,String> validacionFicheros = SEG_wsValijaCasosComunes.validarFicherosValija (datosEntrada.caseId, 2, datosEntrada.valijaId, datosEntrada.fileList);
            if (validacionFicheros.get('error') != '0')
            {
                resultadoValidacion.put('codigo','0004');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', validacionFicheros.get('detalle'));
                return resultadoValidacion;  
            }
        }

        // Si llegamos hasta aquí, la validación es correcta para realizar la consulta.
        resultadoValidacion.put('resultado','OK');
        resultadoValidacion.put('codigo','0000');

        return resultadoValidacion;
    }

    /**
     * @description Acciones a realizar sobre el caso con la operación = FICHEROS_ENVIADOS.
     * @param datosEntrada Datos de entrada del servicio REST.
     * @return Resultado del proceso.
     */
    public static Map<String,String> actualizarCaso (SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput datosEntrada)
    {
        Map<String,String> resultadoProceso = new Map<String,String>();
        String sError = 'OK';
        String sDescError = '';

        try {
            String bloqueoStr = SEG_MetodosComunes.recuperarParametrosValor('SEG_ValijaLockCase');
            Boolean lockCase = (String.isNotBlank(bloqueoStr) && bloqueoStr == 'Y') ? true : false;

            // Recuperar los datos del caso necesarios para el proceso.
            //Case datosCaso = SEG_wsValijaCasosComunes.recuperarInformacionCaso (datosEntrada.caseId);
            Case datosCaso = SEG_wsValijaCasosComunesNoSharing.recuperarInformacionCaso(datosEntrada.caseId, lockCase);

            // Actualizar el caso en base al estado recibido de Valija.
            Case updateCase = new Case();
            updateCase.Id = datosEntrada.caseId;

            // Actualizar el identificador de Valija si la referencia estaba en espera.
            String nuevoValijaId = (String.isNotBlank(datosCaso.SEG_RefSalienteValija__c) && datosCaso.SEG_RefSalienteValija__c.containsIgnoreCase('UNKNOWN')) ? datosEntrada.valijaId : datosCaso.SEG_RefSalienteValija__c;
            nuevoValijaId = (String.isBlank(nuevoValijaId)) ? datosEntrada.valijaId : nuevoValijaId; // Control por si la actualización de datos no ha acabado en el traslado.
            Boolean valijaIdActualizado = (nuevoValijaId != datosCaso.SEG_RefSalienteValija__c) ? true : false;
            updateCase.SEG_RefSalienteValija__c = nuevoValijaId;
            
            // Si Valija nos informa de un error en la descarga de ficheros, activamos el caso en el grupo destino.
            if (datosEntrada.status != 'OK')
            {
                // Activar el caso en el grupo respuesta.
                updateCase.Status = 'Activo';
                updateCase.SEG_Subestado__c = 'Incidencia Valija';
            }else{
                updateCase.SEG_EstadoTrasladoValija__c = 'Ficheros descargados';
            }

            // Transacción del caso ligera para actualizar los datos.
            SEG_Case_BU_TRHan.procesado = true;
            SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
            SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');
            
            SEG_wsValijaCasosComunesNoSharing.actualizarCaseQueueable(updateCase);

            if ((Test.isRunningTest() || valijaIdActualizado) && datosEntrada.fileList != null && !datosEntrada.fileList.isEmpty())
            {
                List<ContentVersion> listadoFicherosUpdate = new List<ContentVersion>();
                for (String ficheroId : datosEntrada.fileList)
                {
                    ContentVersion ficheroUpdate = new ContentVersion();
                    ficheroUpdate.Id = ficheroId;
                    ficheroUpdate.SEG_ValijaSalienteId__c = nuevoValijaId;
                    listadoFicherosUpdate.add(ficheroUpdate);
                }
    
                if (!listadoFicherosUpdate.isEmpty())
                {
                    SEG_wsValijaCasosComunesNoSharing.actualizarFilesQueueable(listadoFicherosUpdate);
                }
            }

            // Crear tarea.
            String descripcionPaqueteria = 'Identificador: ' + datosEntrada.valijaId + '. Estado descarga ficheros Valija: ' + datosEntrada.status;
            descripcionPaqueteria = (String.isNotBlank(datosEntrada.detalleProceso)) ? descripcionPaqueteria + '. Detalle: ' + datosEntrada.detalleProceso : descripcionPaqueteria;

            /* FIX. Comentado. Aligerar la transacción.
            Task createTask = new Task(
                RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                ,Type = 'Envío a Valija - Ficheros descargados'
                ,TaskSubtype = 'Task'
                ,Subject = 'Envío a Valija - Ficheros descargados' 
                ,ActivityDate = System.today()
                ,Status = 'Completed'
                ,Description = descripcionPaqueteria
                ,WhatId = datosEntrada.caseId
                ,Priority = 'Normal'
                ,SEG_ReferenciaValija__c = datosEntrada.valijaId
            );
            insert createTask;
            */

            // Crear mensaje de chatter.
            SEG_Case_Operativas_Controller.postOnChatter (datosEntrada.caseId, descripcionPaqueteria, 'Envío a Valija', null);

        } catch (Exception e) {
            sError = 'NOK';
            sDescError = 'Error al actualizar el caso. Detalle: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
            CBK_Log.error(e);
        }

        resultadoProceso.put('codigo', sError);
        resultadoProceso.put('detalle', sDescError);

        return resultadoProceso;
    }
}