/**
*   @description SEG_wsRoboticsCasosPut_v2
*/
global with sharing class SEG_wsRoboticsCasosPut_v2 {

    /**
     * Clase INPUT para el método PUT.
     */
    global class SEG_WS_NewCase_PutInput {
        private String operacionCaso {get;set;}
        global String casoId {get;set;}

        // operacionCaso = 'numOperacionesCSO'
        global Integer numeroOperacionesCSO {get;set;}
        global String usuarioCSO {get;set;}
        private String usuarioCSOId {get;set;}

        // operacionCaso = 'estadoCaso'
        global String estado {get;set;}
        global String resultadoCierreCaso {get;set;}

        // operacionCaso = 'actividadCaso'
        global String asunto {get;set;}
        global String cuerpo {get;set;}

        // operacionCaso = 'grupoCaso' || 'propietarioCaso'
        global String grupoTrabajo {get;set;}
        global String propietarioCaso {get;set;}

        // operacionCaso = 'fechaValorCaso'
        global Datetime fechaValor {get;set;}

        // operacionCaso = 'fechaPlanificacionCaso'
        global Datetime fechaPlanificacion {get;set;}

        // operacionCaso = 'auditoria'
        global String estadoAuditoria {get;set;}
        global String motivoErrorAuditoria {get;set;}
        global String cifAuditoria {get;set;}
        //global Date fechaAuditoria {get;set;}
        global String fechaAuditoria {get;set;}
        private String auditoriaId {get;set;}

        // operacionCaso = 'cambioMCC'
        global String clasificacionRapida {get;set;}
        global String mccTematica {get;set;}
        global String mccProducto {get;set;}
        global String mccMotivo {get;set;}
        global String mccDetalle {get;set;}
        private String mccTematicaId {get;set;}
        private String mccProductoId {get;set;}
        private String mccMotivoId {get;set;}
        private String mccDetalleId {get;set;}
        private String crId {get;set;}

    }

    /**
     * Clase OUTPUT para el método PUT.
     */
    global class SEG_WS_NewCase_PutOutput {
        global String resultado {get;set;}
        global String codigo {get;set;}
        global String mensaje {get;set;}
    }

    /**
     *  @description Validación de los datos de entrada del servicio.
     *  @param datosEntrada -> Petición REST recibida
     *  @return Map<String,String> -> Mapa con los resultados de la validación
     */
    public static Map<String,String> validarDatosEntradaPUT (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso)
    {
        // Guardar las operaciones detectadas.
        // Clave: operaciones - Valor: operacion_1;operacion_2;...;operacion_n
        String operacionesDetectadas = '';
        Boolean bOk = true;

        Map<String,String> resultadoValidacion = new Map<String,String>();
        resultadoValidacion.put('resultado','OK');
        resultadoValidacion.put('codigo','0000');
        resultadoValidacion.put('enviarMailColaborador','N');

        // Datos obligatorios.
        if (datosEntrada == null)
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No hay un mensaje de entrada válido');
            return resultadoValidacion;
        }

        /*if (String.isBlank(datosEntrada.operacionCaso))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }*/

        // Recuperar datos del caso.
        Case datosCaso = SEG_wsRoboticsCasosComunes.recuperarInformacionCaso (identificadorCaso);
        if (datosCaso == null)
        {
            // El caso informado no existe.
            resultadoValidacion.put('codigo','0001');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha encontrado el caso indicado.');
            return resultadoValidacion;
        }

        // Asignar el valor del caso encontrado
        datosEntrada.casoId = datosCaso.Id;

        // Validaciones a realizar en base al mensaje de entrada.

        /**
         * Operación de cambio de estado.
         */
        if (bOk && String.isNotBlank(datosEntrada.estado))
        {
            operacionesDetectadas = operacionesDetectadas + ';estadoCaso';
            Map<String,String> resultadoValidacionAux = validacionesPutEstadoCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        /**
         * Operación de creación de actividad.
         */
        if (bOk && (String.isNotBlank(datosEntrada.asunto) || String.isNotBlank(datosEntrada.cuerpo)))
        {
            operacionesDetectadas = operacionesDetectadas + ';actividadCaso';
            Map<String,String> resultadoValidacionAux = validacionesPutActividadCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        /**
         * Operación de cambio de grupo.
         */
        if (bOk && String.isNotBlank(datosEntrada.grupoTrabajo))
        {
            operacionesDetectadas = operacionesDetectadas + ';grupoCaso';
            operacionesDetectadas = operacionesDetectadas + (String.isNotBlank(datosEntrada.propietarioCaso)?';propietarioCaso':'');
            Map<String,String> resultadoValidacionAux = validacionesPutGrupoCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        /**
         * Operación de cambio de propietario.
         */
        if (bOk && String.isBlank(datosEntrada.grupoTrabajo) && String.isNotBlank(datosEntrada.propietarioCaso))
        {
            operacionesDetectadas = operacionesDetectadas + ';propietarioCaso';
            Map<String,String> resultadoValidacionAux = validacionesPutPropietarioCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        /**
         * Operación de cambio de fecha valor.
         */
        if (bOk && datosEntrada.fechaValor != null)
        {
            operacionesDetectadas = operacionesDetectadas + ';fechaValorCaso';
            Map<String,String> resultadoValidacionAux = validacionesPutFechaValorCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        /**
         * Operación de cambio de fecha planificación.
         */
        if (bOk && datosEntrada.fechaPlanificacion != null)
        {
            operacionesDetectadas = operacionesDetectadas + ';fechaPlanificacionCaso';
            Map<String,String> resultadoValidacionAux = validacionesPutFechaPlanificacionCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        /**
         * Operación de auditoria.
         */
        if (bOk && String.isNotBlank(datosEntrada.cifAuditoria) && String.isNotBlank(datosEntrada.fechaAuditoria))//datosEntrada.fechaAuditoria != null)
        {
            operacionesDetectadas = operacionesDetectadas + ';auditoria';
            Map<String,String> resultadoValidacionAux = validacionesPutAuditoriaCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        /**
         * Operación de actualización de datos de operaciones CSO.
         */
        if (bOk && (datosEntrada.numeroOperacionesCSO != null || String.isNotBlank(datosEntrada.usuarioCSO)))
        {
            operacionesDetectadas = operacionesDetectadas + ';numOperacionesCSO';
            Map<String,String> resultadoValidacionAux = validacionesPutOperacionesCSOCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        /**
         * Operación de actualización de datos de MCC sobre el caso.
         */
        if (bOk && (String.isNotBlank(datosEntrada.mccTematica) || String.isNotBlank(datosEntrada.mccProducto) ||
        String.isNotBlank(datosEntrada.mccMotivo) || String.isNotBlank(datosEntrada.mccDetalle) ||
        String.isNotBlank(datosEntrada.clasificacionRapida)))
        {
            operacionesDetectadas = operacionesDetectadas + ';cambioMCC';
            Map<String,String> resultadoValidacionAux = validacionesPutMccCaso (datosEntrada, identificadorCaso, datosCaso);
            resultadoValidacion.putAll(resultadoValidacionAux);
            if (resultadoValidacionAux.get('resultado') != 'OK')
            {
                bOk = false;
            }
        }

        // Asignar las operaciones detectadas sobre la modificación del caso.
        datosEntrada.operacionCaso = operacionesDetectadas;

        // Controlar que si el caso ya se encuentra cerrado, no se puede realizar ninguna operación que no sea reapertura.
        Map<String,String> tipoEstadoCaso = SEG_wsRoboticsCasosComunes.recuperarConfiguracionNuevoEstado (datosCaso.Status);
        if (tipoEstadoCaso.get('encontrado') == 'N')
        {
            resultadoValidacion.put('codigo','9999');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'Estado del caso inconsistente.');
            return resultadoValidacion;
        }else{
            String operacionesAux = (String.isNotBlank(operacionesDetectadas)) ? operacionesDetectadas : '';
            operacionesAux = operacionesAux?.replaceAll('estadoCaso', '');
            operacionesAux = operacionesAux?.replaceAll(';', '');
            operacionesAux = operacionesAux?.trim();

            // Se está intentando hacer una operación con el caso cerrado.
            if (tipoEstadoCaso.get('cerrado') == 'Y' && operacionesAux?.length() > 0)
            {
                resultadoValidacion.put('codigo','0200');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El caso se encuentra cerrado. No se permite realizar ninguna operación que no sea la reactivación del caso.');
                return resultadoValidacion;
            }
        }

        return resultadoValidacion;
    }

    private static Map<String,String> validacionesPutMccCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Boolean bClasificacion = false;
        Map<String,String> resultadoValidacion = new Map<String,String>();

        // Clasificación MCC informada en el WS.
        if (String.isNotBlank(datosEntrada.mccTematica) || String.isNotBlank(datosEntrada.mccProducto) || String.isNotBlank(datosEntrada.mccMotivo) ||
        String.isNotBlank(datosEntrada.mccDetalle))
        {
            Map<String,String> resultadoMCC = SEG_wsRoboticsCasosComunes.validarDatosMCC (datosEntrada.mccTematica, datosEntrada.mccProducto, datosEntrada.mccMotivo, datosEntrada.mccDetalle);
            if (resultadoMCC.get('codigo') == '0')
            {
                // Incorporar clasificación de retorno.
                bClasificacion = true;
                datosEntrada.mccTematicaId = resultadoMCC.get('mccTematica');
                datosEntrada.mccProductoId = resultadoMCC.get('mccProducto');
                datosEntrada.mccMotivoId = resultadoMCC.get('mccMotivo');
                datosEntrada.mccDetalleId = resultadoMCC.get('mccDetalle');

                resultadoValidacion.put('tematicaMCC', datosEntrada.mccTematicaId);
                resultadoValidacion.put('productoMCC', datosEntrada.mccProductoId);
                resultadoValidacion.put('motivoMCC', datosEntrada.mccMotivoId);
                resultadoValidacion.put('detalleMCC', datosEntrada.mccDetalleId);
            }else{
                resultadoValidacion.put('codigo','0103');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', resultadoMCC.get('detalle'));
                return resultadoValidacion;
            }
        }

        // Si la CR está informada, buscar la clasificación rápida para el caso.
        if (String.isNotBlank(datosEntrada.clasificacionRapida))
        {
            Map<String,String> busqueda = SEG_wsRoboticsCasosComunes.determinarMCCporCR (datosEntrada.clasificacionRapida);
            if (busqueda.get('codigo') == '0')
            {
                if (bClasificacion)
                {
                    // Validar que los datos encontrados en MCC sean los mismos que la CR.
                    Map<String,String> validacionMCC = SEG_wsRoboticsCasosPost.validarMCCyCR (resultadoValidacion, busqueda);
                    if (validacionMCC.get('codigo') == '0')
                    {
                        bClasificacion = true;
                        datosEntrada.crId = busqueda.get('CRId');
                        datosEntrada.mccTematicaId = validacionMCC.get('tematicaMCC');
                        datosEntrada.mccProductoId = validacionMCC.get('productoMCC');
                        datosEntrada.mccMotivoId = validacionMCC.get('motivoMCC');
                        datosEntrada.mccDetalleId = validacionMCC.get('detalleMCC');
                    }else{
                        bClasificacion = false;
                        resultadoValidacion.put('codigo','0105');
                        resultadoValidacion.put('resultado','NOK');
                        resultadoValidacion.put('mensaje', validacionMCC.get('detalle'));
                        return resultadoValidacion;
                    }
                }else{
                    // Incorporar valor de retorno.
                    bClasificacion = true;
                    datosEntrada.crId = busqueda.get('CRId');
                    datosEntrada.mccTematicaId = busqueda.get('tematicaMCC');
                    datosEntrada.mccProductoId = busqueda.get('productoMCC');
                    datosEntrada.mccMotivoId = busqueda.get('motivoMCC');
                    datosEntrada.mccDetalleId = busqueda.get('detalleMCC');
                }

            }else{
                bClasificacion = false;
                resultadoValidacion.put('codigo','0104');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', busqueda.get('detalle'));
                return resultadoValidacion;
            }
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }

    private static Map<String,String> validacionesPutOperacionesCSOCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if (datosEntrada.numeroOperacionesCSO != null && String.isBlank(datosEntrada.usuarioCSO))
        { 
            resultadoValidacion.put('codigo','0031');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha informado el usuario CSO');
            return resultadoValidacion;
        }

        if (datosEntrada.numeroOperacionesCSO == null && String.isNotBlank(datosEntrada.usuarioCSO))
        {
            resultadoValidacion.put('codigo','0030');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha informado el número de operaciones CSO');
            return resultadoValidacion;
        }

        if (datosEntrada.numeroOperacionesCSO != null && String.isNotBlank(datosEntrada.usuarioCSO))
        {
            // Validar que sea mayor de 0.
            if (datosEntrada.numeroOperacionesCSO < 1)
            {
                resultadoValidacion.put('codigo','0034');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El número de operaciones ha de ser mayor o igual a 1');
                return resultadoValidacion;
            }

            // Validar que el caso se va a clasificar.
            if (datosCaso.CC_MCC_Tematica__c == null || datosCaso.CC_MCC_ProdServ__c == null || datosCaso.CC_MCC_Motivo__c == null || String.isBlank(datosCaso.SEG_Zona__c) || datosCaso.AccountId == null || String.isBlank(datosCaso.Origin))
            {
                resultadoValidacion.put('codigo','0032');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El caso no tiene un MCC / Empresa / Zona / Origen');
                return resultadoValidacion;
            }

            if ((datosEntrada.mccTematica != null && (datosEntrada.mccProducto == null || datosEntrada.mccMotivo == null)) || 
                (datosEntrada.mccProducto != null && (datosEntrada.mccTematica == null || datosEntrada.mccMotivo == null)) ||
                (datosEntrada.mccMotivo != null && (datosEntrada.mccProducto == null || datosEntrada.mccTematica == null)) )
            {
                resultadoValidacion.put('codigo','0045');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'No se ha indicado la jerarquía completa de MCCs');
                return resultadoValidacion;
            }

            // Validar que el caso no esté en un estado cerrado.
            if (datosCaso.IsClosed)
            {
                resultadoValidacion.put('codigo','0036');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El caso está en un estado cerrado / rechazado');
                return resultadoValidacion;
            }

            // Validar que el usuario CSO esté en un grupo CSO.
            Map<String,String> validoCSO = SEG_wsRoboticsCasosComunes.validarUsuarioCSO(datosEntrada.usuarioCSO);
            //if (validoCSO.get('codigo') == '1') --> No compruebo, ya que no pasará nƒunca.
            if (validoCSO.get('codigo') == '2')
            {
                resultadoValidacion.put('codigo','0035');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', validoCSO.get('detalle'));
                return resultadoValidacion;
            }else if (validoCSO.get('codigo') == '3')
            {
                resultadoValidacion.put('codigo','0033');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', validoCSO.get('detalle'));
                return resultadoValidacion;
            }else if (validoCSO.get('codigo') == '0')
            {
                // Indicar el usuario CSO encontrado.
                datosEntrada.usuarioCSOId = validoCSO.get('usuarioCSOId');
            }
        }

        resultadoValidacion.put('operacionesCSO', (datosCaso.SEG_N_operaciones_CSO__c == null) ? '0' : String.valueOf(datosCaso.SEG_N_operaciones_CSO__c));

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }

    private static Map<String,String> validacionesPutAuditoriaCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId();
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if ((datosEntrada.estadoAuditoria == 'NOK' || datosEntrada.estadoAuditoria == 'PAK') && String.isBlank(datosEntrada.motivoErrorAuditoria))
        {
            resultadoValidacion.put('codigo','0100');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No está informado el motivo del error de la auditoria');
            return resultadoValidacion;
        }
        
        // Validar que el cif es el mismo que el cliente del caso.
        // FIX. Se quita la validación, ya que no es requerida por el negocio y la operativa.
        /*
        if (datosCaso.Account.CC_Numero_Documento__c != datosEntrada.cifAuditoria)
        {
            resultadoValidacion.put('codigo','0102');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El cif informado en la auditoria no es el mismo que el cliente del caso');
            return resultadoValidacion;
            }*/
            
            // Buscar si la ficha de auditoria existe.
            
            // Preparar la clave de búsqueda.
            //String claveAuditoria = datosEntrada.cifAuditoria + String.valueOf(datosEntrada.fechaAuditoria.month()).leftPad(2,'0') + '/' + String.valueOf(datosEntrada.fechaAuditoria.year());
            String claveAuditoria = datosEntrada.cifAuditoria + datosEntrada.fechaAuditoria;
            
            List<SEG_Auditoria__c> listadoAuditorias = [SELECT Id, SEG_NIF__c, SEG_NumeroSR__c, SEG_FechaAuditoria__c
            FROM SEG_Auditoria__c
            WHERE NIF_FechaAuditoria__c = :claveAuditoria
            AND SEG_NumeroSR__c = :datosEntrada.casoId
            AND RecordTypeId = : recordTypeSEG];
            if (listadoAuditorias.size() > 1)
            {
                resultadoValidacion.put('codigo','0101');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'Existe más de un registro de auditoria para los datos informados');
                return resultadoValidacion;
            }else if (listadoAuditorias.size() == 1){
                datosEntrada.auditoriaId = listadoAuditorias[0].Id;
            }

            if (String.isBlank(datosEntrada.auditoriaId) || String.isEmpty(datosEntrada.auditoriaId))
            {
                resultadoValidacion.put('codigo','0300');
                resultadoValidacion.put('resultado','PAK');
                resultadoValidacion.put('mensaje', 'No se ha indicado un ID de Auditoría');
                return resultadoValidacion;
            }
            
            
        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }
    
    private static Map<String,String> validacionesPutPropietarioCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        // Datos obligatorios de esta operación.
        if (String.isBlank(datosEntrada.propietarioCaso))
        {
            resultadoValidacion.put('codigo','0090');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No está informado el propietario del caso');
            return resultadoValidacion;
        }

        if (datosCaso.SEG_Grupo__c == null)
        {
            resultadoValidacion.put('codigo','0093');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El caso no tiene asignado un grupo de trabajo');
            return resultadoValidacion;
        }

        // Propietario Caso.
        if (String.isNotBlank(datosEntrada.propietarioCaso))
        {
            Map<String,String> resultadoPropietario = SEG_wsRoboticsCasosComunes.recuperarPropietarioCaso (datosCaso.SEG_Grupo__c, datosEntrada.propietarioCaso);
            if (resultadoPropietario.get('codigo') != '0')
            {
                resultadoValidacion.put('codigo','0092');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El propietario del caso no pertenece al grupo indicado');
                return resultadoValidacion;
            }else{
                resultadoValidacion.put('propietarioId', resultadoPropietario.get('propietarioId'));
            }

            if (resultadoValidacion.get('propietarioId') == datosCaso.OwnerId)
            {
                resultadoValidacion.put('codigo','0091');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El propietario indicado ya está asignado al caso');
                return resultadoValidacion;
            }
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }

    private static Map<String,String> validacionesPutFechaPlanificacionCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if (datosEntrada.fechaPlanificacion == null)
        {
            resultadoValidacion.put('codigo','0060');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha informado una fecha de planificación');
            return resultadoValidacion;
        }

        // Validar las fechas informadas.
        if (datosEntrada.fechaPlanificacion != null && datosEntrada.fechaPlanificacion <= System.now())
        {
            resultadoValidacion.put('codigo','0061');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'La fecha planificación no puede ser inferior a la actual');
            return resultadoValidacion;
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }

    private static Map<String,String> validacionesPutFechaValorCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if (datosEntrada.fechaValor == null)
        {
            resultadoValidacion.put('codigo','0050');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha informado una fecha valor');
            return resultadoValidacion;
        }

        // Validar las fechas informadas.
        if (datosEntrada.fechaValor != null && datosEntrada.fechaValor <= System.now())
        {
            resultadoValidacion.put('codigo','0051');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'La fecha valor no puede ser inferior a la actual');
            return resultadoValidacion;
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }

    private static Map<String,String> validacionesPutGrupoCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        // Datos obligatorios de esta operación.
        if (String.isBlank(datosEntrada.grupoTrabajo))
        {
            resultadoValidacion.put('codigo','0070');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }

        if (String.isNotBlank(datosEntrada.grupoTrabajo))
        {
            String grupoTrabajoId = SEG_wsRoboticsCasosComunes.buscarGrupoPorNombre (datosEntrada.grupoTrabajo);
            if (String.isBlank(grupoTrabajoId))
            {
                resultadoValidacion.put('codigo','0072');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'No se ha encontrado el grupo indicado');
                return resultadoValidacion;
            }else{
                resultadoValidacion.put('grupoSegmentos', grupoTrabajoId);
            }

            /* NO APLICA. Solo se tratan grupos operativos de segmentos.

            // Tratar la operativa si es un colaborador externo, con comunicación e-mail.
            // NOTA: Código migrado de SEG_EmailService.

            Set<String> mccsCaso = new Set<String>();
            mccsCaso.add(datosCaso.SEG_Detalle__c);
            mccsCaso.add(datosCaso.CC_MCC_Motivo__c);
            mccsCaso.add(datosCaso.CC_MCC_ProdServ__c);
            mccsCaso.add(datosCaso.CC_MCC_Tematica__c);

            Map<String,String> busquedaColaborador = SEG_wsRoboticsCasosComunes.recuperarColaboradorExterno (datosCaso.SEG_Organizacion__c, datosCaso.SEG_Zona__c, resultadoValidacion.get('grupoSegmentos'), mccsCaso);
            if (busquedaColaborador.get('esExterno') == 'Y')
            {
                resultadoValidacion.put('grupoExterno', resultadoValidacion.get('grupoSegmentos'));
                resultadoValidacion.put('grupoSegmentos', busquedaColaborador.get('grupoRespuesta'));
                resultadoValidacion.put('estadoCaso', 'Pendiente');
                resultadoValidacion.put('subEstadoCaso', 'En colaborador');
                resultadoValidacion.put('enviarMailColaborador','Y');
            }
            */

            if (resultadoValidacion.get('grupoSegmentos') == datosCaso.SEG_Grupo__c)
            {
                resultadoValidacion.put('codigo','0071');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El grupo indicado ya está asignado al caso');
                return resultadoValidacion;
            }
        }

        // Propietario Caso.
        if (String.isNotBlank(datosEntrada.propietarioCaso))
        {
            Map<String,String> resultadoPropietario = SEG_wsRoboticsCasosComunes.recuperarPropietarioCaso (resultadoValidacion.get('grupoSegmentos'), datosEntrada.propietarioCaso);
            if (resultadoPropietario.get('codigo') != '0')
            {
                resultadoValidacion.put('codigo','0092');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El propietario del caso no pertenece al grupo indicado');
                return resultadoValidacion;
            }else{
                resultadoValidacion.put('propietarioId', resultadoPropietario.get('propietarioId'));
            }

            if (resultadoValidacion.get('propietarioId') == datosCaso.OwnerId)
            {
                resultadoValidacion.put('codigo','0091');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El propietario indicado ya está asignado al caso');
                return resultadoValidacion;
            }
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }

    private static Map<String,String> validacionesPutActividadCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if (String.isBlank(datosEntrada.asunto) || String.isBlank(datosEntrada.cuerpo))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }

    private static Map<String,String> validacionesPutEstadoCaso (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, String identificadorCaso, Case datosCaso)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        // Datos obligatorios de esta operación.
        if (String.isBlank(datosEntrada.estado))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }

        Map<String,String> busquedaEstado = SEG_wsRoboticsCasosComunes.recuperarConfiguracionNuevoEstado (datosEntrada.estado);
        if (busquedaEstado.get('encontrado') == 'N')
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }else{
            if (busquedaEstado.get('cerrado') == 'Y' && String.isBlank(datosEntrada.resultadoCierreCaso))
            {
                resultadoValidacion.put('codigo','0041');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El estado del caso es de cierre y no se ha informado el motivo');
                return resultadoValidacion;
            }
            resultadoValidacion.put('estadoCierre',busquedaEstado.get('cerrado'));
        }

        // El estado del caso ha de ser diferente al actual.
        if (datosCaso.Status == datosEntrada.estado)
        {
            resultadoValidacion.put('codigo','0040');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El caso ya se encuentra en ese estado');
            return resultadoValidacion;
        }

        // El caso no se puede cerrar al no estar clasificado.
        if (resultadoValidacion.get('estadoCierre') == 'Y' && datosCaso.CC_MCC_Motivo__c == null)
        {
            resultadoValidacion.put('codigo','0042');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El estado del caso es de cierre y no está clasificado');
            return resultadoValidacion;
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        return resultadoValidacion;
    }

    /**
     *  @description Actualización del caso con la información de entrada de la petición REST y que se ha validado.
     *  @param datosEntrada -> Petición REST recibida
     *  @param datosValidados -> Datos auxiliares y validados para la creación del caso.
     *  @return Map<String,String> -> Mapa con los resultados de la validación
     */
    public static Map<String,String> actualizarCasoSalesforce (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, Map<String,String> datosValidados)
    {
        Map<String,String> resultadoActualizacion = new Map<String,String>();
        String sError = 'OK';
        String sDescError = '';
        Boolean bRecalcularExcepciones = false;
        Boolean bRecalcularExcepcionesSinAsignacion = false;
        List<FeedItem> listadoFeeds = new List<FeedItem>();

        Savepoint transaccionBBDD = null;
        try {
            // Abrimos transacción BBDD.
            transaccionBBDD = Database.setSavepoint();

            // Recuperar datos del caso actual.
            List<Task> listadoTareasInsertar = new List<Task>();
            List<Case> listadoCasos = [SELECT Id, Status, AccountId, ContactId, 
            CC_MCC_Tematica__c,CC_MCC_ProdServ__c, CC_MCC_Motivo__c, SEG_Detalle__c, SEG_Subestado__c
                                        FROM Case
                                        WHERE Id = :datosEntrada.casoId];
        
            if (!listadoCasos.isEmpty())
            {
                Case casoExistente = listadoCasos[0];

                // Cambio de estado del caso.
                if (String.isNotBlank(datosEntrada.estado) && datosEntrada.operacionCaso.contains('estadoCaso'))
                {
                    
                    //casoExistente.Status = datosValidados.get('estadoCaso');
                    casoExistente.Status = datosEntrada.estado;
                }
                
                // Cambio fecha valor.
                if (datosEntrada.fechaValor != null && datosEntrada.operacionCaso.contains('fechaValorCaso'))
                {
                    
                    casoExistente.SEG_Fecha_valor__c = datosEntrada.fechaValor;
                }
                

                // Cambio fecha planificación.
                /* Gestión de la fecha de planificación. Lo movemos por problemas de compatibilidad con el master-detail creado en "SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO"
                if (datosEntrada.fechaPlanificacion != null && datosEntrada.operacionCaso.contains('fechaPlanificacionCaso'))
                {
                    casoExistente.SEG_Fecha_planificaci_n__c = datosEntrada.fechaPlanificacion;
                    casoExistente.Status = 'Planificado';
                    casoExistente.SEG_Subestado__c = 'Planificado manualmente';
                }
                */

                // Preparar la actualización de datos al informar un grupo que es un colaborador externo.
                /*if (datosValidados.get('enviarMailColaborador') == 'Y')
                {
                    casoExistente.Status = (String.isNotBlank(datosValidados.get('estadoCaso')))?datosValidados.get('estadoCaso'):casoExistente.Status;
                    casoExistente.SEG_Subestado__c = (String.isNotBlank(datosValidados.get('subEstadoCaso')))?datosValidados.get('subEstadoCaso'):casoExistente.SEG_Subestado__c;
                    casoExistente.SEG_Grupo__c = (String.isNotBlank(datosValidados.get('grupoSegmentos')))?datosValidados.get('grupoSegmentos'):null;
                    casoExistente.SEG_Grupo_colaborador_Externo__c = (String.isNotBlank(datosValidados.get('grupoExterno')))?datosValidados.get('grupoExterno'):null;
                }else*/
                if (String.isNotBlank(datosValidados.get('grupoSegmentos')))
                {
                    casoExistente.SEG_Grupo__c = (String.isNotBlank(datosValidados.get('grupoSegmentos')))?datosValidados.get('grupoSegmentos'):null;
                }

                if (datosValidados.get('estadoCierre') == 'Y' && casoExistente.CC_MCC_Motivo__c != null)
                {
                    casoExistente.SEG_Fecha_planificaci_n__c = null; // Desplanificamos al cerrar el caso.
                    casoExistente.CC_No_Identificado__c = (casoExistente.AccountId == null || casoExistente.ContactId == null) ? true : false;
                    casoExistente.CC_Detalles_Solucion__c = datosEntrada.resultadoCierreCaso;
                }

                // Cambio propietario.
                if (String.isNotBlank(datosValidados.get('propietarioId')))
                {
                    casoExistente.OwnerId = datosValidados.get('propietarioId');
                }

                // Cambio MCC.
                if (datosEntrada.operacionCaso.contains('cambioMCC'))
                {
                    casoExistente.SEG_ClasificacionRapida__c = (String.isNotBlank(datosEntrada.crId))?datosEntrada.crId:null;
                }

                update casoExistente;

                // Separar en dos updates para el MCC (si se blanquea la CR, se borra toda la clasificación).
                if (datosEntrada.operacionCaso.contains('cambioMCC'))
                {
                    Case casoUpdateMCC = new Case();
                    casoUpdateMCC.Id = casoExistente.Id;
                    casoUpdateMCC.CC_MCC_Tematica__c = (String.isNotBlank(datosEntrada.mccTematicaId))?datosEntrada.mccTematicaId:null;
                    casoUpdateMCC.CC_MCC_ProdServ__c = (String.isNotBlank(datosEntrada.mccProductoId))?datosEntrada.mccProductoId:null;
                    casoUpdateMCC.CC_MCC_Motivo__c = (String.isNotBlank(datosEntrada.mccMotivoId))?datosEntrada.mccMotivoId:null;
                    casoUpdateMCC.SEG_Detalle__c = (String.isNotBlank(datosEntrada.mccDetalleId))?datosEntrada.mccDetalleId:null;
                    update casoUpdateMCC;
                }


                // Operaciones CSO.
                if (datosEntrada.numeroOperacionesCSO != null && datosEntrada.operacionCaso.contains('numOperacionesCSO') && String.isNotBlank(datosEntrada.usuarioCSOId))
                {
                    //Integer operacionesActuales = (datosValidados.get('operacionesCSO') == null ? 0 : Integer.valueOf(datosValidados.get('operacionesCSO')));
                    //casoExistente.SEG_N_operaciones_CSO__c = operacionesActuales + datosEntrada.numeroOperacionesCSO;
                    String mcc;
                    if (datosEntrada.operacionCaso.contains('cambioMCC')) {
                        mcc = !String.IsBlank(datosEntrada.mccTematicaId) ? datosEntrada.mccTematicaId : mcc;
                        mcc = !String.IsBlank(datosEntrada.mccProductoId) ? datosEntrada.mccProductoId : mcc;
                        mcc = !String.IsBlank(datosEntrada.mccMotivoId) ? datosEntrada.mccMotivoId : mcc;
                        mcc = !String.IsBlank(datosEntrada.mccDetalleId) ? datosEntrada.mccDetalleId : mcc;
                        SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO(datosEntrada.casoId, datosEntrada.usuarioCSOId, datosEntrada.numeroOperacionesCSO, datosEntrada.mccTematicaId, datosEntrada.mccProductoId, datosEntrada.mccMotivoId, datosEntrada.mccDetalleId, mcc);
                    } else {
                        mcc = casoExistente.CC_MCC_Tematica__c != null ? casoExistente.CC_MCC_Tematica__c : mcc;
                        mcc = casoExistente.CC_MCC_ProdServ__c != null ? casoExistente.CC_MCC_ProdServ__c : mcc;
                        mcc = casoExistente.CC_MCC_Motivo__c != null ? casoExistente.CC_MCC_Motivo__c : mcc;
                        mcc = casoExistente.SEG_Detalle__c != null ? casoExistente.SEG_Detalle__c : mcc;
                        SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO(datosEntrada.casoId, datosEntrada.usuarioCSOId, datosEntrada.numeroOperacionesCSO, casoExistente.CC_MCC_Tematica__c, casoExistente.CC_MCC_ProdServ__c, casoExistente.CC_MCC_Motivo__c, casoExistente.SEG_Detalle__c, mcc);
                    }
                }

                // Separamos la planificación del caso del update general, dado que da problemas con "SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO", al ser un master-detail con el scheduled del caso.
                // Si finalmente se mueve esta parte al framework de planificación, se podrá volver a integrar en el insert.
                // Cambio fecha planificación.
                if (datosValidados.get('estadoCierre') != 'Y' && datosEntrada.fechaPlanificacion != null && datosEntrada.operacionCaso.contains('fechaPlanificacionCaso'))
                {
                    Case planificarCaso = new Case();
                    planificarCaso.Id = casoExistente.Id;
                    planificarCaso.SEG_Fecha_planificaci_n__c = datosEntrada.fechaPlanificacion;
                    planificarCaso.Status = 'Planificado';
                    planificarCaso.SEG_Subestado__c = 'Planificado manualmente';
                    update planificarCaso;
                }

                /**
                 * Gestionar la auditoría del caso.
                 */
                if (datosEntrada.operacionCaso.contains('auditoria'))
                {
                    gestionarFichaAuditoria (datosEntrada, listadoTareasInsertar);
                }

                /**
                 * Gestión de lógicas especiales en base a las operaciones detectadas.
                 * -> Creación de tareas, en base al tipo de operación.
                 */

                if (datosEntrada.operacionCaso.contains('estadoCaso'))
                {
                    String tipoTarea = '';
                    String asuntoTarea = '';
                    String textoTarea = '';

                    // Cierre de caso.
                    if (datosValidados.get('estadoCierre') == 'Y')
                    {
                        tipoTarea = 'Cerrado';
                        asuntoTarea = 'Actividad de cierre creada automáticamente por Webservice';
                        textoTarea = 'Estado actualizado por Webservice. Nuevo estado: ' + casoExistente.Status;
                    }else{
                        tipoTarea = 'Información';
                        asuntoTarea = 'Actualización de Estado por Webservice';
                        textoTarea = 'Estado actualizado por Webservice. Nuevo estado: ' + casoExistente.Status;
                    }

                    Task createTask = new Task(
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                        ,Type = tipoTarea
                        ,TaskSubtype = 'Task'
                        ,Subject = asuntoTarea
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = textoTarea
                        ,WhatId = casoExistente.Id
                        ,Priority = 'Normal'
                    );
                    listadoTareasInsertar.add(createTask);

                    SEG_Case_Operativas_Controller.postOnChatterObject (casoExistente.Id, textoTarea, 'Macros Robotics - Actualizar estado', null, listadoFeeds);
                }
                
                if (datosEntrada.operacionCaso.contains('actividadCaso'))
                {
                    // Crear tarea según documentación.
                    Task createTask = new Task(
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                        ,Type = 'Recibido de Webservice'
                        ,TaskSubtype = 'Task'
                        ,Subject = ('Tarea creada por Webservice - ' + datosEntrada.asunto).left(255)
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = datosEntrada.cuerpo
                        ,WhatId = casoExistente.Id
                        ,Priority = 'Normal'
                    );
                    listadoTareasInsertar.add(createTask);

                    SEG_Case_Operativas_Controller.postOnChatterObject (casoExistente.Id, datosEntrada.cuerpo, 'Macros Robotics - Tarea', null, listadoFeeds);
                }
                
                if (datosEntrada.operacionCaso.contains('fechaPlanificacionCaso'))
                {
                    Task createTask = new Task(
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                        ,Type = 'Información'
                        ,TaskSubtype = 'Task'
                        ,Subject = 'Actualización de Fecha Planificación por Webservice'
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = 'Fecha Planificación actualizada por Webservice. Nuevo valor: ' + datosEntrada.fechaPlanificacion
                        ,WhatId = casoExistente.Id
                        ,Priority = 'Normal'
                    );
                    listadoTareasInsertar.add(createTask);

                    SEG_Case_Operativas_Controller.postOnChatterObject (casoExistente.Id, 'Fecha Planificación actualizada por Webservice. Nuevo valor: ' + datosEntrada.fechaPlanificacion, 'Macros Robotics - Planificación', null, listadoFeeds);
                }

                if (datosEntrada.operacionCaso.contains('fechaValorCaso'))
                {
                    Task createTask = new Task(
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                        ,Type = 'Información'
                        ,TaskSubtype = 'Task'
                        ,Subject = 'Actualización de Fecha Valor por Webservice'
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = 'Fecha Valor actualizada por Webservice. Nuevo valor: ' + datosEntrada.fechaValor
                        ,WhatId = casoExistente.Id
                        ,Priority = 'Normal'
                    );
                    listadoTareasInsertar.add(createTask);

                    SEG_Case_Operativas_Controller.postOnChatterObject (casoExistente.Id, 'Fecha Valor actualizada por Webservice. Nuevo valor: ' + datosEntrada.fechaValor, 'Macros Robotics - Valor', null, listadoFeeds);
                }

                if (datosEntrada.operacionCaso.contains('grupoCaso'))
                {
                    bRecalcularExcepcionesSinAsignacion = true;
                    Task createTask = new Task(
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                        ,Type = 'Información'
                        ,TaskSubtype = 'Task'
                        ,Subject = 'Actualización del Grupo por Webservice'
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = 'Grupo actualizado por Webservice. Nuevo valor: ' + datosEntrada.grupoTrabajo
                        ,WhatId = casoExistente.Id
                        ,Priority = 'Normal'
                    );
                    listadoTareasInsertar.add(createTask);

                    SEG_Case_Operativas_Controller.postOnChatterObject (casoExistente.Id, 'Grupo actualizado por Webservice. Nuevo valor: ' + datosEntrada.grupoTrabajo, 'Macros Robotics - Grupo', null, listadoFeeds);
                }
                
                if (datosEntrada.operacionCaso.contains('propietarioCaso'))
                {
                    bRecalcularExcepcionesSinAsignacion = true;
                    // Crear tarea según documentación.
                    Task createTask = new Task(
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                        ,Type = 'Información'
                        ,TaskSubtype = 'Task'
                        ,Subject = 'Actualización de Propietario por Webservice'
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = 'Propietario actualizado por Webservice. Nuevo valor: ' + datosEntrada.propietarioCaso
                        ,WhatId = casoExistente.Id
                        ,Priority = 'Normal'
                    );
                    listadoTareasInsertar.add(createTask);

                    SEG_Case_Operativas_Controller.postOnChatterObject (casoExistente.Id, 'Propietario actualizado por Webservice. Nuevo valor: ' + datosEntrada.propietarioCaso, 'Macros Robotics - Propietario', null, listadoFeeds);
                }

                if (datosEntrada.operacionCaso.contains('numOperacionesCSO'))
                {
                    // Crear tarea según documentación.
                    Task createTask = new Task(
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                        ,Type = 'Información'
                        ,TaskSubtype = 'Task'
                        ,Subject = 'Actualización de Número Operaciones CSO por Webservice'
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = 'Número operaciones CSO actualizado por Webservice. Nuevo valor sumado: ' + String.valueOf(datosEntrada.numeroOperacionesCSO)
                        ,WhatId = casoExistente.Id
                        ,Priority = 'Normal'
                    );
                    listadoTareasInsertar.add(createTask);

                    SEG_Case_Operativas_Controller.postOnChatterObject (casoExistente.Id, 'Número operaciones CSO actualizado por Webservice. Nuevo valor sumado: ' + String.valueOf(datosEntrada.numeroOperacionesCSO), 'Macros Robotics - CSO', null, listadoFeeds);
                }

                if (datosEntrada.operacionCaso.contains('cambioMCC'))
                {
                    bRecalcularExcepciones = true;
                    String rutaMCC = 'CR: ' + datosEntrada.clasificacionRapida;
                    rutaMCC = rutaMCC = ', Temática: ' + datosEntrada.mccTematica;
                    rutaMCC = rutaMCC + ', Producto: ' + datosEntrada.mccProducto;
                    rutaMCC = rutaMCC + ', Motivo: ' + datosEntrada.mccMotivo;
                    rutaMCC = rutaMCC + ', Detalle: ' + datosEntrada.mccDetalle;

                    Task createTask = new Task(
                        RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                        ,Type = 'Información'
                        ,TaskSubtype = 'Task'
                        ,Subject = 'Actualización del MCC / CR por Webservice'
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = 'MCC / CR actualizado por Webservice. Nuevo valor: ' + rutaMCC
                        ,WhatId = casoExistente.Id
                        ,Priority = 'Normal'
                    );
                    listadoTareasInsertar.add(createTask);

                    SEG_Case_Operativas_Controller.postOnChatterObject (casoExistente.Id, 'MCC / CR actualizado por Webservice. Nuevo valor: ' + rutaMCC, 'Macros Robotics - MCC', null, listadoFeeds);
                }

                if (!listadoTareasInsertar.isEmpty())
                {
                    insert listadoTareasInsertar;
                }

                // Insertar los chatters en el caso.
                if (!listadoFeeds.isEmpty())
                {
                    insert listadoFeeds;
                }

                // COMENTADO. LO REALIZARÁ EL TRIGGER CASE_AU.

                /*
                // Gestión de excepciones a calcular.
                bRecalcularExcepciones = (bRecalcularExcepcionesSinAsignacion) ? false : bRecalcularExcepciones;

                // Gestión de excepciones con posible asignación. No se ha cambiado el propietario / grupo.
                if (bRecalcularExcepciones || Test.isRunningTest())
                {
                    SEG_wsRoboticsCasosComunes.calcularExcepcionesCasoFuture (casoExistente.Id);
                }

                // Gestión de excepciones sin asignación, dado que se ha modificado directamente.
                if (bRecalcularExcepcionesSinAsignacion || Test.isRunningTest())
                {
                    SEG_wsRoboticsCasosComunes.calcularExcepcionesNoAsignacionCasoFuture (casoExistente.Id);
                }
                */
            }
            
        } catch (Exception e) {
            // En caso de error, hacemos rollback de la BBDD.
            Database.rollback(transaccionBBDD);

            sError = 'KO';
            sDescError = 'Error al actualizar el caso. Detalle casos put: ' + e.getMessage() + '|| stack :' + e.getStackTraceString();
            CBK_Log.error(e);
        }

        resultadoActualizacion.put('codigo', sError);
        resultadoActualizacion.put('detalle', sDescError);

        return resultadoActualizacion;
    }

    public static void gestionarFichaAuditoria (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada, List<Task> listadoTareasInsertar)
    {
        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId();
        if (String.isBlank(datosEntrada.estadoAuditoria) && String.isBlank(datosEntrada.cifAuditoria) && String.isBlank(datosEntrada.fechaAuditoria))//datosEntrada.fechaAuditoria == null)
        {
            return;
        }

        // Calcular el campo fecha auditoria.
        List<String> datePart = datosEntrada.fechaAuditoria.split('/');
        Date fechaAuditoriaDate = Date.newInstance(Integer.valueOf(datePart[1]), Integer.valueOf(datePart[0]), 1);

        SEG_Auditoria__c auditoriaCaso = new SEG_Auditoria__c();
        auditoriaCaso.Id = (String.isNotBlank(datosEntrada.auditoriaId)) ? datosEntrada.auditoriaId : null;
        auditoriaCaso.SEG_NIF__c = datosEntrada.cifAuditoria;
        auditoriaCaso.SEG_NumeroSR__c = datosEntrada.casoId;
        auditoriaCaso.SEG_FechaAuditoria__c = fechaAuditoriaDate;
        auditoriaCaso.SEG_Resultado__c = datosEntrada.estadoAuditoria;
        auditoriaCaso.RecordTypeId = recordTypeSEG;

        if (!(String.isBlank(datosEntrada.auditoriaId)))
        {
            update auditoriaCaso;
            Boolean auditoriaOK = false;
            Boolean auditoriaNOK = false;
            Boolean auditoriaPAK = false;
            Boolean auditoriaOtros = false;
    
            for (AggregateResult aggregateResult : [SELECT SEG_NumeroSR__c, SEG_Resultado__c, COUNT(Id)
                                                    FROM SEG_Auditoria__c 
                                                    WHERE SEG_NumeroSR__c = :datosEntrada.casoId
                                                    AND RecordTypeId = : recordTypeSEG
                                                    GROUP BY SEG_NumeroSR__c, SEG_Resultado__c])
            {
                auditoriaOK = (String.valueOf(aggregateResult.get('SEG_Resultado__c')) == 'OK') ? true : auditoriaOK;
                auditoriaNOK = (String.valueOf(aggregateResult.get('SEG_Resultado__c')) == 'NOK') ? true : auditoriaNOK;
                auditoriaPAK = (String.valueOf(aggregateResult.get('SEG_Resultado__c')) == 'PAK') ? true : auditoriaPAK;
                auditoriaOtros = (String.valueOf(aggregateResult.get('SEG_Resultado__c')) != 'PAK' && String.valueOf(aggregateResult.get('SEG_Resultado__c')) != 'NOK' && String.valueOf(aggregateResult.get('SEG_Resultado__c')) != 'OK') ? true : auditoriaOtros;
            }
    
            /**
             * Si todas las auditorias son OK:
             *      - Crear actividad de cierre.
             *      - Crear nota en el caso.
             */
            if ((auditoriaOK == true && auditoriaNOK == false && auditoriaPAK == false && auditoriaOtros == false) || Test.isRunningTest())
            {
                String textoTarea = 'Cierre del caso a petición del Webservice de auditoría.';
    
                Task createTask = new Task(
                    RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                    ,Type = 'Cerrado'
                    ,TaskSubtype = 'Task'
                    ,Subject = 'Resultado de auditoria satisfactorio informado por Webservice'
                    ,ActivityDate = System.today()
                    ,Status = 'Completed'
                    ,Description = textoTarea
                    ,WhatId = datosEntrada.casoId
                    ,Priority = 'Normal'
                );
                listadoTareasInsertar.add(createTask);
    
                // Crear el comentario de chatter.
                SEG_Case_Operativas_Controller.postOnChatter (datosEntrada.casoId, textoTarea, 'Comunicación Macros', null);
            }
    
            /**
             * Si alguna de las auditorias es NOK o PAK:
             *      - Crear actividad informativa.
             *      - Crear nota en el caso.
             */
            if (auditoriaNOK == true || auditoriaPAK == true || Test.isRunningTest())
            {
                String textoTarea = 'Activación del caso a petición del Webservice de auditoría. Resultado auditoria: ' + ((auditoriaNOK == true) ? 'NOK' : 'PAK');
                textoTarea = textoTarea + '\nDetalle: ' + datosEntrada.motivoErrorAuditoria;
    
                Task createTask = new Task(
                    RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                    ,Type = 'Información'
                    ,TaskSubtype = 'Task'
                    ,Subject = 'Resultado de auditoria con errores informado por Webservice'
                    ,ActivityDate = System.today()
                    ,Status = 'Completed'
                    ,Description = textoTarea
                    ,WhatId = datosEntrada.casoId
                    ,Priority = 'Normal'
                );
                listadoTareasInsertar.add(createTask);
                
                // Crear el comentario de chatter.
                SEG_Case_Operativas_Controller.postOnChatter (datosEntrada.casoId, textoTarea, 'Comunicación Macros', null);
            }
    
            return;
        }
            /*
        }else{
        }
        */
        // Tratamiento de creación de actividades en base al estado de las auditorías.
    }
}