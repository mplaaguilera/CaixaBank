public with sharing class SEG_ValijaStatusJustificantes {

    /**
     * @description Gestión del estado para la operacion JUSTIFICANTES que se informa desde Valija.
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

        // Se permiten varios estados previos de sincronización con Valija:
        //  Ficheros procesados -> Se han realizado las operaciones correctamente desde Valija.
        //  Ficheros descargados -> Por temas asíncronos de Valija, llega la gestión de justificantes antes que la notificación de las operaciones.
        //  Ficheros procesados PAK -> Se ha obtenido un procesado de operaciones con resultado PAK, permitimos avanzar la petición.
        if (datosCaso.SEG_EstadoTrasladoValija__c != 'Ficheros procesados' && datosCaso.SEG_EstadoTrasladoValija__c != 'Ficheros descargados' && datosCaso.SEG_EstadoTrasladoValija__c != 'Ficheros procesados PAK')
        {
            resultadoValidacion.put('codigo','0006');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El caso no se ha enviado a Valija o ya se ha recibido el OK a la recepción de justificantes.');
            return resultadoValidacion;
        }

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

        if (String.isNotBlank(datosEntrada.requiereJustificantes) && datosEntrada.requiereJustificantes != 'Si' && datosEntrada.requiereJustificantes != 'No')
        {
            resultadoValidacion.put('codigo','007');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha informado un estado válido para la gestión de justificantes.');
            return resultadoValidacion;
        }

        /* FIX. Se acuerda que la fecha valor no se actualiza en el proceso de justificantes, solo en el estado de operaciones procesadas.
        if (String.isNotBlank(datosEntrada.fechaValorSLA))
        {
            Boolean bErrorFecha = false;
            try{
                // Se acuerda que para evitar decalajes entre las fechas de los servidores, la validación de Salesforce de un margen de 10 minutos respecto a la fecha actual.
                // La fecha que envía Valija es la fecha de la operación, siendo la fecha / hora actual de su sistema cuando realiza el envío.

                Datetime testFormatDate = Datetime.valueOf(datosEntrada.fechaValorSLA);
                resultadoValidacion.put('fechaSLA', datosEntrada.fechaValorSLA);

                bErrorFecha = (testFormatDate < System.now().addMinutes(-10));
            }catch(Exception e){
                bErrorFecha = true;
            }

            if (bErrorFecha)
            {
                resultadoValidacion.put('codigo','008');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'La fecha valor NO cumple con el formato esperado (YYYY-MM-DD HH24:mm:ss) o es anterior a la fecha/hora actual.');
                return resultadoValidacion;
            }
        }
        */

        if (datosEntrada.status == 'OK')
        {
            Map<String,String> validacionFicheros = SEG_wsValijaCasosComunes.validarFicherosValija (datosEntrada.caseId, 1, datosEntrada.valijaId, datosEntrada.fileList);
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
    public static Map<String,String> actualizarCaso (SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput datosEntrada, Map<String,String> datosValidados)
    {
        Map<String,String> resultadoProceso = new Map<String,String>();
        String sError = 'OK';
        String sDescError = '';
        List<FeedItem> listadoFeeds = new List<FeedItem>();

        try {
            // Recuperar el SEG_BO para activar el caso por posible incidencia.
            Id grupoBO = SEG_MetodosComunes.recuperarGrupoBO();

            // Recuperar el parámetro de bloqueo de registro.
            String bloqueoStr = SEG_MetodosComunes.recuperarParametrosValor('SEG_ValijaLockCase');
            Boolean lockCase = (String.isNotBlank(bloqueoStr) && bloqueoStr == 'Y') ? true : false;

            // Recuperar los datos del caso necesarios para el proceso.
            Case datosCaso = SEG_wsValijaCasosComunesNoSharing.recuperarInformacionCaso(datosEntrada.caseId, lockCase);

            // CAMBIO NEGOCIO. Reworking.
            // Caso 1: llega en orden Operaciones (antes de justificantes). Se realiza el recálculo de estados de Valija + envío correo.
            // Caso 2: llega primero Justificantes (antes de operaciones). Se realiza el recálcuo de estados de Valija + envío correo.

            // ----------------------------------
            // Calcular el resultado del caso.
            // ----------------------------------
            String resultadoCaso = (datosEntrada.status == 'OK') ? 'Enviado justificantes al cliente' : datosCaso.SEG_Resultado__c;

            // ----------------------------------
            // Calcular el nuevo estado de traslado interno del caso.
            // ----------------------------------
            String nuevoEstadoTraslado = (datosEntrada.status == 'OK') ? 'Justificantes emitidos' : datosCaso.SEG_EstadoTrasladoValija__c;

            // ----------------------------------
            // Calcular el estado final del caso.
            // ----------------------------------
            String nuevoEstadoCaso = (datosEntrada.status == 'OK') ? 'Cerrado' : 'Activo';
            String nuevoSubEstadoCaso = (datosEntrada.status == 'OK') ? 'Envío cierre Colaborador WS' : 'Incidencia Valija';

            // Interceptar un cierre de caso sin los datos obligatorios mínimos informados.
            Boolean cierreCasoInvalido = (nuevoEstadoCaso == 'Cerrado' && (String.isBlank(datosCaso.CC_MCC_Motivo__c) || datosCaso.SEG_N_operaciones_del_caso__c == null)) ? true : false;
            nuevoEstadoCaso = (cierreCasoInvalido == true) ? 'Activo' : nuevoEstadoCaso;
            nuevoSubEstadoCaso = (cierreCasoInvalido == true) ? 'Incidencia Valija' : nuevoSubEstadoCaso;

            // ----------------------------------
            // Actualizar el identificador de Valija si la referencia estaba en espera.
            // ----------------------------------
            String nuevoValijaId = (String.isNotBlank(datosCaso.SEG_RefSalienteValija__c) && datosCaso.SEG_RefSalienteValija__c.containsIgnoreCase('UNKNOWN')) ? datosEntrada.valijaId : datosCaso.SEG_RefSalienteValija__c;
            nuevoValijaId = (String.isBlank(nuevoValijaId)) ? datosEntrada.valijaId : nuevoValijaId; // Control por si la actualización de datos no ha acabado en el traslado.

            // ----------------------------------
            // Preparar la actualización del caso.
            // ----------------------------------
            Case updateCase = new Case();
            updateCase.Id = datosEntrada.caseId;
            updateCase.SEG_RefSalienteValija__c = nuevoValijaId;
            updateCase.SEG_Resultado__c = resultadoCaso;
            updateCase.SEG_Fecha_valor__c = (datosEntrada.status == 'OK' && String.isNotBlank(datosValidados.get('fechaSLA'))) ? Datetime.valueOf(datosValidados.get('fechaSLA')) : datosCaso.SEG_Fecha_valor__c;
            updateCase.SEG_EstadoTrasladoValija__c = nuevoEstadoTraslado;
            updateCase.Status = nuevoEstadoCaso;
            updateCase.SEG_Subestado__c = nuevoSubEstadoCaso;

            // Si el caso no se está cerrando, transacción rápida de actualización sin lanzar los triggers del caso.
            if (updateCase.Status != 'Cerrado')
            {
                SEG_Case_BU_TRHan.procesado = true;
                SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
                SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');
            }

            // Si el caso se activa con incidencia Valija, asignar el grupo BO.
            if (updateCase.SEG_Subestado__c == 'Incidencia Valija')
            {
                updateCase.OwnerId = grupoBO;
            }

            Boolean errorUpdateCaso = false;
            try{
                SEG_wsValijaCasosComunesNoSharing.actualizarCaseQueueable(updateCase);
            }catch(Exception e){
                errorUpdateCaso = true;
                CBK_Log.error(e);
                activarIncidenciaCaso (datosEntrada.caseId, grupoBO);
                SEG_Case_Operativas_Controller.postOnChatterObject (datosEntrada.caseId, 'Error al actualizar el caso en la recepción de justificantes del caso. Detalle: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')', 'Justificantes Valija - Error actualizando caso', null, listadoFeeds);
            }

            // Crear tarea.
            String descripcionPaqueteria = 'Identificador: ' + datosEntrada.valijaId + '. Resultado Justificantes Valija: ' + datosEntrada.status;
            descripcionPaqueteria = (String.isNotBlank(datosEntrada.detalleProceso)) ? descripcionPaqueteria + '. Detalle: ' + datosEntrada.detalleProceso : descripcionPaqueteria;
            descripcionPaqueteria = (String.isNotBlank(datosEntrada.requiereJustificantes)) ? descripcionPaqueteria + '. Requiere Justificantes: ' + datosEntrada.requiereJustificantes : descripcionPaqueteria;
            descripcionPaqueteria = (String.isNotBlank(datosEntrada.fechaValorSLA)) ? descripcionPaqueteria + '. Fecha Valor: ' + datosEntrada.fechaValorSLA : descripcionPaqueteria;
            descripcionPaqueteria = (datosEntrada.numeroOperaciones != null) ? descripcionPaqueteria + '. Número de operaciones: ' + String.valueOf(datosEntrada.numeroOperaciones) : descripcionPaqueteria;
            descripcionPaqueteria = (datosEntrada.emails != null && !datosEntrada.emails.isEmpty()) ? descripcionPaqueteria + '. Emails Valija: ' + String.join(datosEntrada.emails,';') : descripcionPaqueteria;

            // Crear mensaje de chatter.
            SEG_Case_Operativas_Controller.postOnChatterObject (datosEntrada.caseId, descripcionPaqueteria, 'Justificantes Valija', null, listadoFeeds);

            // Informar que no se puede cerrar el caso.
            if (cierreCasoInvalido)
            {
                SEG_Case_Operativas_Controller.postOnChatterObject (datosEntrada.caseId, 'No se ha podido cerrar el caso debido a que no está clasificado o no tiene el número de operaciones informado.', 'Justificantes Valija - No se puede cerrar el caso', null, listadoFeeds);
            }

            // Realizar el envío del correo al cliente si los justificantes son OK.
            if (!errorUpdateCaso && datosEntrada.status == 'OK' || Test.isRunningTest())
            {
                Map<String,String> mapaDatosCaso = new Map<String,String>();
                mapaDatosCaso.put('caseId', datosEntrada.caseId);
                mapaDatosCaso.put('accountId', datosCaso?.AccountId);
                mapaDatosCaso.put('contactId', datosCaso?.ContactId);
                mapaDatosCaso.put('organizacion', datosCaso?.SEG_Organizacion__c);
                mapaDatosCaso.put('zona', datosCaso?.SEG_Zona__c);
                mapaDatosCaso.put('idiomaCaso', datosCaso?.CC_Idioma__c);

                Map<String,String> configuracion = new Map<String,String>();
                configuracion.put('operativa','Valija');
                configuracion.put('resultadoCaso',resultadoCaso);
                configuracion.put('primerCorreo','1');

                Map<String,String> retorno = SEG_Case_Operativas_Controller.enviarCorreoAutoOperativa(mapaDatosCaso, configuracion, datosEntrada.emails, datosEntrada.fileList);
                if (retorno.get('codigo') != '0' || Test.isRunningTest())
                {
                    // Crear mensaje de chatter.
                    String errorEnvioCorreo = 'No se ha podido enviar el correo con los justificantes al cliente. Código: ' + retorno.get('codigo') + '. Más información: ' + retorno.get('detalle');
                    SEG_Case_Operativas_Controller.postOnChatterObject (datosEntrada.caseId, errorEnvioCorreo, 'Justificantes Valija - Error correo', null, listadoFeeds);
                }

                // En los casos que no son de origen paquetería, el error de envío de correo activará el caso en el grupo destino.
                if (datosCaso.Origin != 'Paquetería' && retorno.get('codigo') != '0' || Test.isRunningTest())
                {
                    activarIncidenciaCaso (datosEntrada.caseId, grupoBO);
                }
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

    /**
     * @description Método para activar un caso con incidencia en algún proceso de Valija.
     * @param caseId Identificador del caso.
     * @param motivoChatter Descripción a incorporar en el chatter del caso.
     */
    public static void activarIncidenciaCaso (String caseId, Id grupoBOId)
    {
        try{
            // Actualización rápida del caso sin ejecutar la lógica de triggers.
            SEG_Case_BU_TRHan.procesado = true;
            SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
            SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');

            Case activarCaso = new Case();
            activarCaso.Id = caseId;
            activarCaso.OwnerId = grupoBOId;
            activarCaso.Status = 'Activo';
            activarCaso.SEG_Subestado__c = 'Incidencia Valija';
            SEG_wsValijaCasosComunesNoSharing.actualizarCaseQueueable(activarCaso);
        }catch (Exception e){CBK_Log.error(e);}
    }
}