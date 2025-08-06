/**
 * @description. Clase para la gestión de alta de casos desde Valija.
 */
public with sharing class SEG_wsValijaAltaCaso {

    /**
     * @description Método HttpPost para dar de alta un caso de Segmentos.
     * @param datosEntradaCaso Mensaje de entrada recibido en el servicio REST.
     * @return Retorno del servicio REST.
     */
    public static OS_WS_AltaCasoValija.Output gestionPeticionSegmentos (OS_WS_AltaCasoValija.Input datosEntradaCaso)
    {
        Boolean bOk = true;
        OS_WS_AltaCasoValija.Output resultadoWS = new OS_WS_AltaCasoValija.Output();

        // Validaciones de entrada para Segmentos.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = SEG_wsValijaAltaCaso.validarDatosEntradaPOST (datosEntradaCaso);
            if (datosValidacionEntrada.get('resultado') == 'OK')
            {
                resultadoWS.resultado = (String.isNotBlank(datosValidacionEntrada.get('PAKresultado')))?datosValidacionEntrada.get('PAKresultado'):datosValidacionEntrada.get('resultado');
                resultadoWS.codigo = (String.isNotBlank(datosValidacionEntrada.get('PAKcodigo')))?datosValidacionEntrada.get('PAKcodigo'):datosValidacionEntrada.get('codigo');
                resultadoWS.error = (String.isNotBlank(datosValidacionEntrada.get('PAKmensaje')))?datosValidacionEntrada.get('PAKmensaje'):'';
            }else{
                bOk = false;
                resultadoWS.resultado = datosValidacionEntrada.get('resultado');
                resultadoWS.codigo = datosValidacionEntrada.get('codigo');
                resultadoWS.error = datosValidacionEntrada.get('mensaje');
            }
        }

        // Método para la creación del caso de Segmentos.
        if (bOk)
        {
            Map<String,String> datosCreacion = SEG_wsValijaAltaCaso.crearCasoSalesforce (datosEntradaCaso, datosValidacionEntrada);
            if (datosCreacion.get('codigo') != 'OK')
            {
                bOk = false;
                resultadoWS.codigo = '9999';
                resultadoWS.resultado = 'NOK';
                resultadoWS.error = datosCreacion.get('detalle');
            }else{
                resultadoWS.codigo = (String.isBlank(resultadoWS.codigo))?'0000':resultadoWS.codigo;
                resultadoWS.resultado = (String.isBlank(resultadoWS.resultado))?'OK':resultadoWS.resultado;
                resultadoWS.error = (String.isBlank(resultadoWS.error))?'':resultadoWS.error;
                resultadoWS.caseId = datosCreacion.get('casoId');
            }
        }

        return resultadoWS;
    }

    /**
     * @description Validación de los datos de entrada del servicio para la creación de casos de segmentos.
     * @param datosEntradaCaso Mensaje de entrada recibido en el servicio REST.
     * @return Estructura de tipo map con las validaciones realizadas.
     */
    public static Map<String,String> validarDatosEntradaPOST (OS_WS_AltaCasoValija.Input datosEntrada)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();
        String zona = '';
        String organizacion = '';

        // Inicializar para concatenar mensajes de error.
        resultadoValidacion.put('PAKmensaje','');

        // Datos obligatorios.
        if (datosEntrada == null)
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No hay un mensaje de entrada válido');
            return resultadoValidacion;
        }

        // FIX. Se descataloga la zona del servicio. Vendrá el officeNum para calcular la organización y zona del caso.
        if (String.isBlank(datosEntrada.titulo) || String.isBlank(datosEntrada.idValija) || String.isBlank(datosEntrada.tipoProceso) 
        || String.isBlank(datosEntrada.officeNum)) //|| String.isBlank(datosEntrada.zona))
        {
            resultadoValidacion.put('codigo','0001');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }

        // Inicialización de datos común.
        resultadoValidacion.put('estadoCaso', 'Abierto');

        // Comprobar si el identificador de valija ya está asignado a otro caso.
        Boolean referenciaValijaExistente = SEG_wsValijaCasosComunes.comprobarValijaIdExistente(datosEntrada.idValija);
        if (referenciaValijaExistente)
        {
            resultadoValidacion.put('codigo','0002');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'La referencia de valija ya está dada de alta');
            return resultadoValidacion;
        }

        // Validar que el formato del número de oficina es numérico.
        Pattern oPatt = Pattern.compile('^\\d{1,5}$');
        Matcher oMatcher = oPatt.matcher(datosEntrada.officeNum);
        if(oMatcher.find()) {
            // Han informado una oficina.
            datosEntrada.officeNum = datosEntrada.officeNum.leftPad(5, '0');
        }else{
            resultadoValidacion.put('codigo','0011');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha informado un código de oficina válido');
            return resultadoValidacion;
        }

        // Recuperar los datos de la oficina.
        Map<String,String> busquedaOficina = SEG_wsRoboticsCasosComunes.identificarCentroCaixa (datosEntrada.officeNum, null);
        resultadoValidacion.put('oficinaGestora', busquedaOficina.get('clienteId'));
        resultadoValidacion.put('numeroOficinaGestora', busquedaOficina.get('numeroOficinaGestora'));
        resultadoValidacion.put('organizacion', busquedaOficina.get('organizacion'));
        resultadoValidacion.put('zona', busquedaOficina.get('zona'));
        organizacion = busquedaOficina.get('organizacion');
        zona = busquedaOficina.get('zona');
        if (busquedaOficina.get('codigo') != '0')
        {
            resultadoValidacion.put('codigo','0012');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', busquedaOficina.get('detalle'));
            return resultadoValidacion;
        }

        // Validar que la organización y zona se ha podido calcular.
        if (String.isBlank(organizacion) || String.isBlank(zona))
        {
            resultadoValidacion.put('codigo','0010');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El valor de la organización / zona de la oficina no es válido');
            return resultadoValidacion;
        }

        /* DESCATALOGADO. Recuperar la zona y organización.
        Map<String,String> zonaYorganizacion = SEG_wsRoboticsCasosComunes.obtenerRelacionZonaOrganizacion (Account.SEG_Zona__c);
        if (zonaYorganizacion.get(datosEntrada.zona) != null)
        {
            organizacion = zonaYorganizacion.get(datosEntrada.zona);
            resultadoValidacion.put('organizacion',organizacion);
        }else{
            resultadoValidacion.put('codigo','0010');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El valor de la zona no es válido');
            return resultadoValidacion;
        }
        */

        // Recuperar datos de la Organización y zona.
        SEG_Buzon__mdt datosOrgZona = SEG_wsRoboticsCasosComunes.recuperarDatosOrganizacionZona (organizacion, zona);

        // Por defecto, asignaremos el caso al grupo MCC. Después de crear el caso, se realizará la autoasignación de grupo.
        String grupoTrabajoId = SEG_wsRoboticsCasosComunes.buscarGrupoPorNombre (datosOrgZona.SEG_Grupo_MCC__c);
        if (String.isBlank(grupoTrabajoId))
        {
            resultadoValidacion.put('codigo','9000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se ha encontrado un grupo MCC por defecto configurado en el sistema');
            return resultadoValidacion;
        }else{
            resultadoValidacion.put('grupoSegmentos', grupoTrabajoId);
        }

        // Recuperar el perfil de envío que se haya podido informar en el WebService.
        resultadoValidacion.put('buzonSalida', datosOrgZona.SEG_Correo_de_procedencia__c);

        // Recuperar cola BO Global. Consideramos que siempre está creada. Si por casualidad se da de baja, forzaremos un error 500 en el servicio para revisarlo.
        List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];
        resultadoValidacion.put('grupoBO', colasBO[0].Id);

        // Si el CIF / Contacto está informado, buscar el cliente y validarlo.
        datosEntrada.cif = (String.isNotBlank(datosEntrada.cif))?datosEntrada.cif:'';
        if (String.isNotBlank(datosEntrada.cif))
        {
            Map<String,String> busqueda = SEG_wsRoboticsCasosComunes.identificarClienteContacto (datosEntrada.cif, null);
            resultadoValidacion.put('clienteId', busqueda.get('clienteId'));
            resultadoValidacion.put('contactoId', busqueda.get('contactoId'));
            resultadoValidacion.put('direccionMail', busqueda.get('direccionMail'));
            // POR AHORA PREVALECE LA OFICINA DEL SERVICIO. A NO SER QUE SE HAGA UN CAMBIO DE CRITERIO. resultadoValidacion.put('oficinaGestora', busqueda.get('oficinaGestora'));
            // POR AHORA PREVALECE LA OFICINA DEL SERVICIO. A NO SER QUE SE HAGA UN CAMBIO DE CRITERIO. resultadoValidacion.put('numeroOficinaGestora', busqueda.get('numeroOficinaGestora'));
            resultadoValidacion.put('idiomaCaso', busqueda.get('idiomaCliente'));
            if (busqueda.get('codigo') != '0')
            {
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + busqueda.get('detalle') : busqueda.get('detalle'));
                if (busqueda.get('codigo') == '2')
                {
                    resultadoValidacion.put('PAKcodigo','0032');
                }else if (busqueda.get('codigo') == '1')
                {
                    resultadoValidacion.put('PAKcodigo','0031');
                }
            }
        }else{
            String detalleError = 'CIF no informado';
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKcodigo','0030');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
        }

        // Gestión de la clasificación del caso. Buscar la clasificación del caso por el nombre del proceso de Valija.
        Boolean bClasificacion = false;
        if (String.isNotBlank(datosEntrada.tipoProceso))
        {
            Map<String,String> busqueda = SEG_wsValijaCasosComunes.recuperarProcesoValija (datosEntrada.tipoProceso, organizacion, true);
            if (busqueda.get('codigo') == '0')
            {
                // Incorporar valor de retorno.
                bClasificacion = true;
                resultadoValidacion.put('CRId', busqueda.get('CRId'));
                resultadoValidacion.put('CRName', busqueda.get('CRName'));
                resultadoValidacion.put('tematicaMCC', busqueda.get('tematicaMCC'));
                resultadoValidacion.put('productoMCC', busqueda.get('productoMCC'));
                resultadoValidacion.put('motivoMCC', busqueda.get('motivoMCC'));
                resultadoValidacion.put('detalleMCC', busqueda.get('detalleMCC'));

                // FIX. Códificación de la descripción del proceso Valija no viene en UTF-8. Mientras se revisa, como Workarround, lo calculamos nosotros.
                datosEntrada.nombreProceso = busqueda.get('descripcionValija');
            }else{
                resultadoValidacion.put('codigo','0040');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', busqueda.get('detalle'));
                return resultadoValidacion;
            }
        }

        // Calcular el número de operaciones BO.
        resultadoValidacion.put('numeroOperacionesCaso','0');
        if (String.isNotBlank(datosEntrada.numOperaciones))
        {
            if (datosEntrada.numOperaciones.isNumeric())
            {
                resultadoValidacion.put('numeroOperacionesCaso',datosEntrada.numOperaciones);
            }else{
                String errorAux = 'No se ha introducido un número de operaciones válido';
                resultadoValidacion.put('PAKcodigo','0020');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + errorAux : errorAux);
            }
        }

        // Validar la fecha informada por Valija.
        Boolean bErrorFecha = false;
        if (String.isNotBlank(datosEntrada.idFaq))
        {
            //Prepararmos la fecha para conversión de DateTime de la fecha valor del caso.
            datosEntrada.idFaq = datosEntrada.idFaq + ' 00:00:00';

            bErrorFecha = (String.isBlank(datosEntrada.idFaq)) ? true : false;

            try{
                Date testFormatDate = Date.valueOf(datosEntrada.idFaq);
                resultadoValidacion.put('fechaCargo', datosEntrada.idFaq);

                bErrorFecha = (testFormatDate < System.today());
            }catch(Exception e){
                bErrorFecha = true;
            }
        }

        if (bErrorFecha)
        {
            // Convertimos el error de NOK a PAK.
            String detalleError = 'Se ha especificado una fecha valor / cargo inválido: no cumple con el formato esperado (YYYY-MM-DD) o es anterior a la fecha actual.';
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKcodigo','0025');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
            datosEntrada.idFaq = null;
            resultadoValidacion.put('fechaCargo', null);
        }

        // Validar los valores del tipo de cargo.
        if (String.isNotBlank(datosEntrada.tipoCargo))
        {
            if (datosEntrada.tipoCargo != '01' && datosEntrada.tipoCargo != '02' && datosEntrada.tipoCargo != '03')
            {
                resultadoValidacion.put('codigo','0021');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'El tipo de cargo informado no es válido.');
                return resultadoValidacion;
            }

            if (datosEntrada.tipoCargo == '03')
            {
                if (bErrorFecha || String.isBlank(datosEntrada.idFaq))
                {
                    // Convertimos el error de NOK a PAK.
                    String detalleError = 'Se ha especificado un tipo de cargo concreto, pero la fecha de cargo no se ha informado, no cumple con el formato esperado (YYYY-MM-DD) o es anterior a la fecha actual.';
                    resultadoValidacion.put('PAKresultado','PAK');
                    resultadoValidacion.put('PAKcodigo','0022');
                    resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
                }
            }
            /* FIX. No realizamos esta validación, dado que esta fecha será también la fecha valor del caso.
            else{
                // Blanquear la fecha de cargo.
                datosEntrada.idFaq = null;
                String detalleError = 'Se ha informado una fecha de cargo concreta para un tipo de cargo que no es requerido. No se utilizará dicha fecha.';
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKcodigo','0024');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
            }*/
        }

        // Validar el campo de pago agrupado.
        datosEntrada.pagoAgrupado = (String.isNotBlank(datosEntrada.pagoAgrupado)) ? datosEntrada.pagoAgrupado : 'No';
        if (datosEntrada.pagoAgrupado != 'No' && datosEntrada.pagoAgrupado != 'Si')
        {
            String errorAux = 'No se ha introducido dato válido en el pago agrupado';
            datosEntrada.pagoAgrupado = 'No';
            resultadoValidacion.put('PAKcodigo','0023');
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + errorAux : errorAux);
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        resultadoValidacion.put('codigo','0000');

        return resultadoValidacion;
    }

    /**
     *  @description Creación del caso con la información de entrada de la petición REST y que se ha validado.
     *  @param datosEntrada -> Petición REST recibida
     *  @param datosValidados -> Datos auxiliares y validados para la creación del caso.
     *  @return Map<String,String> -> Mapa con los resultados de la validación
     */
    public static Map<String,String> crearCasoSalesforce (OS_WS_AltaCasoValija.Input datosEntrada, Map<String,String> datosValidados)
    {
        Map<String,String> resultadoCreacion = new Map<String,String>();
        String sError = 'OK';
        String sDescError = '';
        List<FeedItem> listadoFeeds = new List<FeedItem>();

        try {
            Case casoNuevo = new Case();
            casoNuevo.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

            // Crear el asunto del caso.
            String asuntoCaso = (String.isNotBlank(datosEntrada.titulo)) ? datosEntrada.titulo : 'N/A asunto';
            asuntoCaso = (String.isNotBlank(datosValidados.get('CRName'))) ? asuntoCaso + ' - ' + datosValidados.get('CRName') : asuntoCaso;
            casoNuevo.Subject = asuntoCaso.left(255);

            casoNuevo.Origin = 'Paquetería';
            casoNuevo.SEG_Organizacion__c = datosValidados.get('organizacion');
            casoNuevo.SEG_Zona__c = datosValidados.get('zona');
            casoNuevo.Status = (String.isNotBlank(datosValidados.get('estadoCaso')))?datosValidados.get('estadoCaso'):'Abierto';
            casoNuevo.SEG_Subestado__c = null;
            casoNuevo.Description = datosEntrada.description;
            casoNuevo.CC_Buzon_Salida__c = datosValidados.get('buzonSalida');
            casoNuevo.CC_Buzon_Salida_Atencion_Cliente__c = datosValidados.get('buzonSalida');
            casoNuevo.SEG_Email_Buzon_Entrada__c = datosValidados.get('buzonSalida');

            // Asignación de cuenta y contacto que viene desde Valija.
            casoNuevo.AccountId = (String.isNotBlank(datosValidados.get('clienteId')))?datosValidados.get('clienteId'):null;
            casoNuevo.ContactId = (String.isNotBlank(datosValidados.get('contactoId')))?datosValidados.get('contactoId'):null;
            casoNuevo.CC_No_Identificado__c = (casoNuevo.AccountId == null || casoNuevo.ContactId == null) ? true : false;
            
            // Asignar los datos de la oficina.
            casoNuevo.SEG_Numero_de_centro__c = (String.isNotBlank(datosValidados.get('oficinaGestora')))?datosValidados.get('oficinaGestora'):null;
            casoNuevo.CC_Oficina__c = casoNuevo.SEG_Numero_de_centro__c;
            casoNuevo.CC_Oficina_Afectada_Lookup__c = casoNuevo.SEG_Numero_de_centro__c;
            casoNuevo.SEG_Numero_centro__c = (String.isNotBlank(datosValidados.get('numeroOficinaGestora')))?datosValidados.get('numeroOficinaGestora'):null;
            
            // Clasificación del caso calculada en base a la entrada de Valija.
            casoNuevo.CC_MCC_Tematica__c = (String.isNotBlank(datosValidados.get('tematicaMCC')))?datosValidados.get('tematicaMCC'):null;
            casoNuevo.CC_MCC_ProdServ__c = (String.isNotBlank(datosValidados.get('productoMCC')))?datosValidados.get('productoMCC'):null;
            casoNuevo.CC_MCC_Motivo__c = (String.isNotBlank(datosValidados.get('motivoMCC')))?datosValidados.get('motivoMCC'):null;
            casoNuevo.SEG_Detalle__c = (String.isNotBlank(datosValidados.get('detalleMCC')))?datosValidados.get('detalleMCC'):null;
            casoNuevo.SEG_ClasificacionRapida__c = (String.isNotBlank(datosValidados.get('CRId')))?datosValidados.get('CRId'):null;
            casoNuevo.SEG_ClasificacionRapidaOrigen__c = (String.isNotBlank(datosValidados.get('CRId')))?datosValidados.get('CRId'):null;

            // Otros datos necesarios para la gestión de casos.
            //casoNuevo.OwnerId = datosValidados.get('grupoBO');
            casoNuevo.SEG_Grupo__c = (String.isNotBlank(datosValidados.get('grupoSegmentos')))?datosValidados.get('grupoSegmentos'):null;
            casoNuevo.SEG_Grupo_colaborador_Externo__c = null;
            casoNuevo.SEG_Idioma__c = (String.isNotBlank(datosValidados.get('idiomaCaso')))?datosValidados.get('idiomaCaso'):'es';
            casoNuevo.CC_Idioma__c = casoNuevo.SEG_Idioma__c;
            
            // Inicializar la gestión de acuses de recibo de CC.
            casoNuevo.CC_AcuseRecibo__c = '0';
            casoNuevo.CC_AcuseDelay__c = null;
            
            // Asignar mail asociado al cliente.
            casoNuevo.CC_MailTelfNotif__c = datosValidados.get('direccionMail');

            // Asignar la fecha valor del caso con la informada por Valija.
            casoNuevo.SEG_Fecha_valor__c = (String.isNotBlank(datosValidados.get('fechaCargo'))) ? Datetime.valueOf(datosValidados.get('fechaCargo')) : null;

            // Datos adicionales de valija.
            casoNuevo.SEG_creacionPAK__c = (String.isNotBlank(datosValidados.get('PAKresultado'))) ? true : false;
            casoNuevo.SEG_TipoValija__c = (String.isNotBlank(datosEntrada.tipo)) ? datosEntrada.tipo.left(20) : null;
            casoNuevo.SEG_TipoProcesoValija__c = (String.isNotBlank(datosEntrada.tipoProceso)) ? datosEntrada.tipoProceso.left(10) : null;
            casoNuevo.OS_Nombre_Proceso_Valija__c = datosEntrada.nombreProceso;
            casoNuevo.OS_Referencia_Valija__c = datosEntrada.idValija;
            casoNuevo.SEG_CIFOrdenanteValija__c = (String.isNotBlank(datosEntrada.cifOrdenante)) ? datosEntrada.cifOrdenante : datosEntrada.cif;
            casoNuevo.SEG_N_operaciones_del_caso__c = (String.isNotBlank(datosValidados.get('numeroOperacionesCaso'))) ? Integer.valueOf(datosValidados.get('numeroOperacionesCaso')) : 0;
            casoNuevo.SEG_TipoCargo__c = (String.isNotBlank(datosEntrada.tipoCargo)) ? datosEntrada.tipoCargo : null;
            casoNuevo.SEG_FechaCargo__c = (String.isNotBlank(datosValidados.get('fechaCargo'))) ? Date.valueOf(datosValidados.get('fechaCargo')) : null;
            casoNuevo.SEG_PagoAgrupado__c = datosEntrada.pagoAgrupado;
            casoNuevo.SEG_ComunidadAutonoma__c = datosEntrada.comunidad;
            casoNuevo.SEG_ConceptoValija__c = (String.isNotBlank(datosEntrada.conceptoAsociado)) ? datosEntrada.conceptoAsociado : null;
            casoNuevo.SEG_DocumentosValija__c = (datosEntrada.numeroDocumentos != null) ? datosEntrada.numeroDocumentos : 0;

            // Intentar forzar que no realice las assigment rules. Se ha añadido una para que no asigne el Default Owner.
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = false;
            //Setting the DMLOption on Case instance
            casoNuevo.setOptions(dmlOpts);

            insert casoNuevo;

            String descripcionPaqueteria = 'PAQUETERÍA (VALIJA) - ' + String.valueOf(datosEntrada.nombreProceso);

            /* FIX. Comentado. Aligerar la transacción.
            Task createTask = new Task(
                RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                ,Type = 'Recibido de paquetería'
                ,TaskSubtype = 'Task'
                ,Subject = 'Recibido de paquetería' 
                ,ActivityDate = System.today()
                ,Status = 'Completed'
                ,Description = descripcionPaqueteria
                ,WhatId = casoNuevo.Id
                ,Priority = 'Normal'
                ,SEG_ReferenciaValija__c = datosEntrada.idValija
            );
            insert createTask;
            */

            // Crear mensaje de chatter.
            descripcionPaqueteria = descripcionPaqueteria + '. En espera de los documentos digitalizados.';
            //SEG_Case_Operativas_Controller.postOnChatter (casoNuevo.Id, descripcionPaqueteria, 'Recibido de paquetería', null);
            SEG_Case_Operativas_Controller.postOnChatterObject (casoNuevo.Id, descripcionPaqueteria, 'Recibido de paquetería', null, listadoFeeds);

            // Crear mensaje de chatter con el posible PAK producido.
            if (casoNuevo.SEG_creacionPAK__c)
            {
                descripcionPaqueteria = 'La petición de PAQUETERÍA no se asigna automáticamente debido a un problema con los datos de entrada que requieren revisión (PAK).';
                descripcionPaqueteria = descripcionPaqueteria + ((String.isNotBlank(datosValidados.get('PAKcodigo')))? ' Código PAK: ' + datosValidados.get('PAKcodigo'):'');
                descripcionPaqueteria = descripcionPaqueteria + ((String.isNotBlank(datosValidados.get('PAKmensaje')))? ' Detalle: ' + datosValidados.get('PAKmensaje'):'');
                //SEG_Case_Operativas_Controller.postOnChatter (casoNuevo.Id, descripcionPaqueteria, 'Recibido de paquetería (PAK)', null);
                SEG_Case_Operativas_Controller.postOnChatterObject (casoNuevo.Id, descripcionPaqueteria, 'Recibido de paquetería (PAK)', null, listadoFeeds);
            }

            resultadoCreacion.put('casoId', casoNuevo.Id);

            // Insertar los chatters en el caso.
            if (!listadoFeeds.isEmpty())
            {
                insert listadoFeeds;
            }
            
        } catch (Exception e) {
            sError = 'NOK';
            sDescError = 'Error al crear el caso. Detalle: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
            CBK_Log.error(e);
        }

        resultadoCreacion.put('codigo', sError);
        resultadoCreacion.put('detalle', sDescError);

        return resultadoCreacion;
    }
}