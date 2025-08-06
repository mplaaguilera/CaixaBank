public with sharing class SEG_ValijaStatusFicherosEnviados {

    /**
     * @description Gestión del estado para la operacion FICHEROS_ENVIADOS que se informa desde Valija.
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
            Map<String,String> resultadoActualizacion = actualizarCaso (datosEntrada, datosValidacionEntrada);
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

        if (datosEntrada ==  null || String.isBlank(datosEntrada.caseId) || String.isBlank(datosEntrada.valijaId) || String.isBlank(datosEntrada.status) ||
        datosEntrada.fileList == null || datosEntrada.fileList.isEmpty())
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje','No se han informado los datos obligatorios para la actualización del estado de la petición.');
            return resultadoValidacion;
        }

        Case datosCaso = SEG_wsValijaCasosComunes.recuperarInformacionCaso (datosEntrada.caseId);
        resultadoValidacion.put('creacionPAK', String.valueOf(datosCaso.SEG_creacionPAK__c));
        if (datosCaso == null)
        {
            // El caso informado no existe.
            resultadoValidacion.put('codigo','0001');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha encontrado el caso indicado en la petición.');
            return resultadoValidacion;
        }

        if (datosEntrada.valijaId != datosCaso.OS_Referencia_Valija__c)
        {
            resultadoValidacion.put('codigo','0002');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'La referencia de Valija no es válida.');
            return resultadoValidacion;
        }

        if (datosCaso.SEG_RecepcionFicherosPaqueteria__c)
        {
            resultadoValidacion.put('codigo','0005');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'Ya se ha procesado la entrada del caso indicado.');
            return resultadoValidacion;
        }

        if (datosEntrada.status != 'OK' && datosEntrada.status != 'NOK' && datosEntrada.status != 'PAK')
        {
            resultadoValidacion.put('codigo','0003');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha informado un estado válido.');
            return resultadoValidacion;
        }

        /* FIX. No validamos la entrada del fichero por temas de concurrencia.
        if (datosEntrada.status == 'OK')
        {
            Map<String,String> validacionFicheros = SEG_wsValijaCasosComunes.validarFicherosValija (datosEntrada.caseId, 0, datosEntrada.valijaId, datosEntrada.fileList);
            if (validacionFicheros.get('error') != '0')
            {
                resultadoValidacion.put('codigo','0004');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', validacionFicheros.get('detalle'));
                return resultadoValidacion;  
            }
        }*/

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
    public static Map<String,String> actualizarCaso (SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput datosEntrada, Map<String,String> datosValidados)
    {
        Map<String,String> resultadoProceso = new Map<String,String>();
        String sError = 'OK';
        String sDescError = '';
        List<FeedItem> listadoFeeds = new List<FeedItem>();

        try {

            Boolean creacionConPAK = (String.isNotBlank(datosValidados.get('creacionPAK'))) ? Boolean.valueOf(datosValidados.get('creacionPAK')) : false;

            // Preparar la actualización del caso.
            Case updateCase = new Case();
            updateCase.Id = datosEntrada.caseId;
            updateCase.SEG_RecepcionFicherosPaqueteria__c = true;

            // Si el estado recibido de Valija no es OK, el caso se descartará / rechazado.
            updateCase.Status = (datosEntrada.status != 'OK') ? 'Descartado' : 'Activo';
            updateCase.SEG_Subestado__c = (datosEntrada.status != 'OK') ? 'Rechazada' : null;
            updateCase.SEG_N_operaciones_CSO__c = datosEntrada.numeroOperacionesCSO;

            // Actualizar los datos del caso, donde aligeramos la ejecución del trigger.
            SEG_Case_BU_TRHan.procesado = true;
            SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
            SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');

            SEG_wsValijaCasosComunesNoSharing.actualizarCaseQueueable(updateCase);

            // Registrar tarea y chatter antes de autoasignar, para mantener la cronología de los mensajes.

            // Crear tarea.
            String descripcionPaqueteria = 'Identificador: ' + datosEntrada.valijaId + '. Estado recepción ficheros: ' + datosEntrada.status;
            descripcionPaqueteria = (String.isNotBlank(datosEntrada.detalleProceso)) ? descripcionPaqueteria + '. Detalle: ' + datosEntrada.detalleProceso : descripcionPaqueteria;

            /* FIX. Comentado. Aligerar la transacción.
            Task createTask = new Task(
                RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                ,Type = 'Recibido de paquetería - Ficheros'
                ,TaskSubtype = 'Task'
                ,Subject = 'Recibido de paquetería' 
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
            SEG_Case_Operativas_Controller.postOnChatterObject (datosEntrada.caseId, descripcionPaqueteria, 'Recibido de paquetería', null, listadoFeeds);

            // Restauramos los modificadores para iniciar el proceso de autoasignación.
            SEG_Case_BU_TRHan.procesado = false;
            SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_AU_TRHan: bypass');

            // Una vez actualizado el caso, procederemos a autoasignarlo y el cálculo de excepciones.
            Boolean bAsignacion = false;
            if (datosEntrada.status == 'OK')
            {
                try{
                    Map<String,String> resultadoAsignacion = SEG_Case_Operativas_Controller.autoAsignarGrupoPaqueteria (datosEntrada.caseId, creacionConPAK);
                    if (resultadoAsignacion.get('asignado') == 'Y')
                    {
                        bAsignacion = true;
                    }
                }catch(Exception e){
                    // Registramos error, pero dejamos seguir con el caso.
                    CBK_Log.error(e);
                    SEG_Case_Operativas_Controller.postOnChatterObject (datosEntrada.caseId, 'Error al autoasignar el caso procedente de Valija (Paquetería). Detalle: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')', 'Recibido Paquetería - Error autoasignar caso', null, listadoFeeds);
                }
            }

            //SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');

            // Como paso final, se comprueba que el owner sea SEG_BO. Si no lo es, ha fallado algo en la autoasignación.
            // En caso de error, se va a proceder a asignar al SEG_BO de forma manual. En este punto, el usuario asignado es SEG_Valija de las integraciones y podrá transferir el caso.
            if (!bAsignacion || Test.isRunningTest())
            {
                SEG_Case_BU_TRHan.procesado = true;
                SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
                SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');

                // Recuperar el grupo BO.
                Id grupoBO = SEG_MetodosComunes.recuperarGrupoBO();

                Case cambioOwner = new Case();
                cambioOwner.Id = datosEntrada.caseId;
                cambioOwner.OwnerId = grupoBO;
                Database.SaveResult resultCambioOwner = Database.update(cambioOwner, false);
            }

            // Insertar los chatters en el caso.
            if (!listadoFeeds.isEmpty())
            {
                insert listadoFeeds;
            }

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