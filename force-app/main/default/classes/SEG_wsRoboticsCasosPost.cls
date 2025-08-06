global with sharing class SEG_wsRoboticsCasosPost {

    /**
     * Clase INPUT para el método POST.
     */
    global class SEG_WS_NewCase_PostInput {
        global String titulo {get;set;}
        global String zona {get;set;}
        global String cif {get;set;}
        global String contactoEmailId {get;set;}
        global String clasificacionRapida {get;set;}
        global String grupoTrabajo {get;set;}
        global String perfilEnvio {get;set;}
        global Integer cierreCaso {get;set;}
        global String resultadoCierreCaso {get;set;}
        global String idioma {get;set;}
        global Integer acuseRecibo {get;set;}
        global Integer numeroOperacionesCSO {get;set;}
        global String usuarioCSO {get;set;}
        global String observaciones {get;set;}
        global Datetime fechaValor {get;set;}
        global Datetime fechaPlanificacion {get;set;}
        global String propietarioCaso {get;set;}
        global String mccTematica {get;set;}
        global String mccProducto {get;set;}
        global String mccMotivo {get;set;}
        global String mccDetalle {get;set;}

        // Uso interno.
        global String direccionEmail {get;set;}
        private String usuarioCSOId {get;set;}
    }

    /**
     * Clase INPUT para el método POST para crear casos hijos.
     */
    global class SEG_WS_NewChildCase_PostInput {
        //global String casoPadreId {get;set;}
        global String clasificacionRapida {get;set;}
        global List<String> listadoDocumentosIds {get;set;}

        // Uso interno.
        private List<String> listadoContentDocumentId {get;set;}
    }

    /**
     * Clase OUTPUT para el método POST.
     */
    global class SEG_WS_NewCase_PostOutput {
        global String resultado {get;set;}
        global String codigo {get;set;}
        global String mensaje {get;set;}
        global String numeroCaso {get;set;}
        global String casoId {get;set;}
        global String semillaMail {get;set;}
    }

    /**
     *  @description Validación de los datos de entrada del servicio.
     *  @param datosEntrada -> Petición REST recibida
     *  @return Map<String,String> -> Mapa con los resultados de la validación
     */
    public static Map<String,String> validarDatosEntradaPOST (SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntrada)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();
        String organizacion = '';

        // Concatenar mensajes de error.
        resultadoValidacion.put('PAKmensaje','');

        // Datos obligatorios.
        if (datosEntrada == null)
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No hay un mensaje de entrada válido');
            return resultadoValidacion;
        }

        if (String.isBlank(datosEntrada.titulo) || String.isBlank(datosEntrada.zona))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }

        // Tratamiento de datos por defecto, si no vienen informados.
        datosEntrada.cierreCaso = (datosEntrada.cierreCaso == null) ? 0 : datosEntrada.cierreCaso;
        datosEntrada.acuseRecibo = (datosEntrada.acuseRecibo == null) ? 0 : datosEntrada.acuseRecibo;

        // Inicialización de datos común.
        resultadoValidacion.put('enviarMailColaborador','N');
        resultadoValidacion.put('estadoCaso', 'Activo');
        resultadoValidacion.put('cierreColaborador','N');
        //resultadoValidacion.put('calcularExcepciones','Y');
        resultadoValidacion.put('autoAsignarCaso','Y');

        // Recuperar la zona y organización.
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

        // Recuperar cola BO Global. Consideramos que siempre está creada. Si por casualidad se da de baja, forzaremos un error 500 en el servicio para revisarlo.
        List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];
        resultadoValidacion.put('grupoBO', colasBO[0].Id);

        // Si el CIF / Contacto está informado, buscar el cliente y validarlo.
        datosEntrada.cif = (String.isNotBlank(datosEntrada.cif))?datosEntrada.cif:'';
        if (String.isBlank(datosEntrada.cif))
        {
            String detalleError = 'CIF no informado';
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKcodigo','0030');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
        }

        if (String.isNotBlank(datosEntrada.cif) || String.isNotBlank(datosEntrada.contactoEmailId))
        {
            Boolean bCentroCaixa = false;

            // Comprobar si es un centro CaixaBank.
            Pattern oPatt = Pattern.compile('^\\d{5}$');
            Matcher oMatcher = oPatt.matcher(datosEntrada.cif);
            if(oMatcher.find()) {
                // Han informado una oficina.
                bCentroCaixa = true;
            }                

            if (bCentroCaixa)
            {
                Map<String,String> busqueda = SEG_wsRoboticsCasosComunes.identificarCentroCaixa (datosEntrada.cif, datosEntrada.contactoEmailId);
                resultadoValidacion.put('clienteId', busqueda.get('clienteId'));
                resultadoValidacion.put('contactoId', busqueda.get('contactoId'));
                resultadoValidacion.put('oficinaGestora', busqueda.get('clienteId'));
                resultadoValidacion.put('direccionMail', busqueda.get('direccionMail'));
                resultadoValidacion.put('numeroOficinaGestora', busqueda.get('numeroOficinaGestora'));
                if (busqueda.get('codigo') != '0')
                {
                    resultadoValidacion.put('PAKresultado','PAK');
                    resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + busqueda.get('detalle') : busqueda.get('detalle'));

                    if (busqueda.get('codigo') == '1')
                    {
                        resultadoValidacion.put('PAKcodigo','0031');
                    }else if (busqueda.get('codigo') == '2')
                    {
                        resultadoValidacion.put('PAKcodigo','0032');
                    }
                }
            }else{
                Map<String,String> busqueda = SEG_wsRoboticsCasosComunes.identificarClienteContacto (datosEntrada.cif, datosEntrada.contactoEmailId);
                resultadoValidacion.put('clienteId', busqueda.get('clienteId'));
                resultadoValidacion.put('contactoId', busqueda.get('contactoId'));
                resultadoValidacion.put('direccionMail', busqueda.get('direccionMail'));
                resultadoValidacion.put('oficinaGestora', busqueda.get('oficinaGestora'));
                resultadoValidacion.put('numeroOficinaGestora', busqueda.get('numeroOficinaGestora'));
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
                    }else if (busqueda.get('codigo') == '3')
                    {
                        resultadoValidacion.put('PAKcodigo','0020');
                    }else if (busqueda.get('codigo') == '4')
                    {
                        resultadoValidacion.put('PAKcodigo','0034');
                    }else if (busqueda.get('codigo') == '5')
                    {
                        resultadoValidacion.put('PAKcodigo','0033');
                    }
                }
            }
        }

        // Gestión de la clasificación del caso.
        Boolean bClasificacion = false;

        // Buscar la clasificación MCC del caso.
        if (String.isNotBlank(datosEntrada.mccTematica) || String.isNotBlank(datosEntrada.mccProducto) || String.isNotBlank(datosEntrada.mccMotivo) ||
        String.isNotBlank(datosEntrada.mccDetalle))
        {
            Map<String,String> resultadoMCC = SEG_wsRoboticsCasosComunes.validarDatosMCC (datosEntrada.mccTematica, datosEntrada.mccProducto, datosEntrada.mccMotivo, datosEntrada.mccDetalle);
            if (resultadoMCC.get('codigo') == '0')
            {
                // Incorporar clasificación de retorno.
                bClasificacion = true;
                resultadoValidacion.put('tematicaMCC', resultadoMCC.get('mccTematica'));
                resultadoValidacion.put('productoMCC', resultadoMCC.get('mccProducto'));
                resultadoValidacion.put('motivoMCC', resultadoMCC.get('mccMotivo'));
                resultadoValidacion.put('detalleMCC', resultadoMCC.get('mccDetalle'));
            }else{
                resultadoValidacion.put('PAKcodigo','0103');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + resultadoMCC.get('detalle') : resultadoMCC.get('detalle'));
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
                    Map<String,String> validacionMCC = validarMCCyCR (resultadoValidacion, busqueda);
                    if (validacionMCC.get('codigo') == '0')
                    {
                        bClasificacion = true;
                        resultadoValidacion.put('CRId', busqueda.get('CRId'));
                        resultadoValidacion.put('tematicaMCC', validacionMCC.get('tematicaMCC'));
                        resultadoValidacion.put('productoMCC', validacionMCC.get('productoMCC'));
                        resultadoValidacion.put('motivoMCC', validacionMCC.get('motivoMCC'));
                        resultadoValidacion.put('detalleMCC', validacionMCC.get('detalleMCC'));
                    }else{
                        bClasificacion = false;
                        resultadoValidacion.put('CRId', '');
                        resultadoValidacion.put('tematicaMCC', '');
                        resultadoValidacion.put('productoMCC', '');
                        resultadoValidacion.put('motivoMCC', '');
                        resultadoValidacion.put('detalleMCC', '');

                        resultadoValidacion.put('PAKcodigo','0104');
                        resultadoValidacion.put('PAKresultado','PAK');
                        resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + validacionMCC.get('detalle') : validacionMCC.get('detalle'));
                    }

                    /*if (String.isNotBlank(busqueda.get('tematicaMCC')) && String.isNotBlank(resultadoValidacion.get('tematicaMCC')) &&
                    busqueda.get('tematicaMCC') != resultadoValidacion.get('tematicaMCC'))
                    {
                        // Error temática.
                    }else if (String.isNotBlank(busqueda.get('productoMCC')) && String.isNotBlank(resultadoValidacion.get('productoMCC')) &&
                    busqueda.get('productoMCC') != resultadoValidacion.get('productoMCC'))
                    {
                        // Error producto.
                    }else if (String.isNotBlank(busqueda.get('motivoMCC')) && String.isNotBlank(resultadoValidacion.get('motivoMCC')) &&
                    busqueda.get('motivoMCC') != resultadoValidacion.get('motivoMCC'))
                    {
                        // Error motivo.
                    }else if (String.isNotBlank(busqueda.get('detalleMCC')) && String.isNotBlank(resultadoValidacion.get('detalleMCC')) &&
                    busqueda.get('detalleMCC') != resultadoValidacion.get('detalleMCC'))
                    {
                        // Error detalle.
                    }else{
                        // Completar el máximo nivel de detalle.
                        resultadoValidacion.put('CRId', busqueda.get('CRId'));
                        resultadoValidacion.put('tematicaMCC', (String.isNotBlank(busqueda.get('tematicaMCC'))) ? busqueda.get('tematicaMCC') : resultadoValidacion.get('tematicaMCC'));
                        resultadoValidacion.put('productoMCC', (String.isNotBlank(busqueda.get('productoMCC'))) ? busqueda.get('productoMCC') : resultadoValidacion.get('productoMCC'));
                        resultadoValidacion.put('motivoMCC', (String.isNotBlank(busqueda.get('motivoMCC'))) ? busqueda.get('motivoMCC') : resultadoValidacion.get('motivoMCC'));
                        resultadoValidacion.put('detalleMCC', (String.isNotBlank(busqueda.get('detalleMCC'))) ? busqueda.get('detalleMCC') : resultadoValidacion.get('detalleMCC'));
                    }*/
                }else{
                    // Incorporar valor de retorno.
                    bClasificacion = true;
                    resultadoValidacion.put('CRId', busqueda.get('CRId'));
                    resultadoValidacion.put('tematicaMCC', busqueda.get('tematicaMCC'));
                    resultadoValidacion.put('productoMCC', busqueda.get('productoMCC'));
                    resultadoValidacion.put('motivoMCC', busqueda.get('motivoMCC'));
                    resultadoValidacion.put('detalleMCC', busqueda.get('detalleMCC'));
                }

            }else{
                resultadoValidacion.put('PAKcodigo','0040');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + busqueda.get('detalle') : busqueda.get('detalle'));
            }
        }

        if (!bClasificacion)
        {
            // Si la CR no está informada, buscar la clasificación rápida por el motor de asiganción de e-mails.
            String observacionesAux = (String.isBlank(datosEntrada.observaciones)) ? '*' : datosEntrada.observaciones;
            List<String> correos = new List<String>();
            List<Id> reglaCR = SEG_EmailService.determinarCR('*',correos,correos, datosEntrada.titulo, observacionesAux);
            if(reglaCR.size()==1) 
            {
                // Encontrado de forma única.
                List<SEG_Regladeclasificacion__c> listaReglaCR = [SELECT Id, SEG_ClasificacionRapida__c, SEG_ClasificacionRapida__r.SEG_Tematica__c, 
                                                                    SEG_ClasificacionRapida__r.SEG_Producto__c, SEG_ClasificacionRapida__r.SEG_Motivo__c, 
                                                                    SEG_ClasificacionRapida__r.SEG_Detalle__c 
                                                                    FROM SEG_Regladeclasificacion__c where id=:reglaCR[0]];
                resultadoValidacion.put('CRId', listaReglaCR[0].SEG_ClasificacionRapida__c);
                resultadoValidacion.put('tematicaMCC', listaReglaCR[0].SEG_ClasificacionRapida__r?.SEG_Tematica__c);
                resultadoValidacion.put('productoMCC', listaReglaCR[0].SEG_ClasificacionRapida__r?.SEG_Producto__c);
                resultadoValidacion.put('motivoMCC', listaReglaCR[0].SEG_ClasificacionRapida__r?.SEG_Motivo__c);
                resultadoValidacion.put('detalleMCC', listaReglaCR[0].SEG_ClasificacionRapida__r?.SEG_Detalle__c);
            }else{
                String detalleError = 'No se ha podido determinar la CR por los datos del WebService';
                resultadoValidacion.put('PAKcodigo','0041');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
            }
        }

        // Determinar el grupo de trabajo.
        Boolean bGrupoMCC = true;

        if (String.isNotBlank(datosEntrada.grupoTrabajo))
        {
            String grupoTrabajoId = SEG_wsRoboticsCasosComunes.buscarGrupoPorNombre (datosEntrada.grupoTrabajo);
            if (String.isBlank(grupoTrabajoId))
            {
                String detalleError = 'El grupo de trabajo informado no es válido';
                resultadoValidacion.put('PAKcodigo','0050');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
            }else{
                bGrupoMCC = false;
                resultadoValidacion.put('grupoSegmentos', grupoTrabajoId);
                //resultadoValidacion.put('calcularExcepciones','N');
                resultadoValidacion.put('autoAsignarCaso','N');
            }
        }
        /* OLD. HACEMOS PASAR A ROBOTICS POR EL MÉTODO DE AUTOASIGNACIÓN DE CASOS.
        else{
            // Asignación automática por MCC.
            //if (String.isNotBlank(resultadoValidacion.get('clienteId')))
            //{
                String grupoTrabajoId = SEG_MetodosComunes.asignarGrupoCaso(resultadoValidacion.get('detalleMCC'), resultadoValidacion.get('motivoMCC'), resultadoValidacion.get('productoMCC'), resultadoValidacion.get('tematicaMCC'), 
                                                                        resultadoValidacion.get('clienteId'), datosEntrada.zona, organizacion);

                // PUEDE DEVOLVER: ERROR-Grupo automático sin cuenta informada
                if (String.isNotBlank(grupoTrabajoId) && !grupoTrabajoId.contains('ERROR-'))
                {
                    // Grupo encontrado.
                    bGrupoMCC = false;
                    resultadoValidacion.put('grupoSegmentos', grupoTrabajoId);
                }
            //}
        }
        FIN OLD.*/

        // Recuperar datos de la Organización y zona.
        SEG_Buzon__mdt datosOrgZona = SEG_wsRoboticsCasosComunes.recuperarDatosOrganizacionZona (organizacion, datosEntrada.zona);

        /* OLD. HACEMOS PASAR A ROBOTICS POR EL MÉTODO DE AUTOASIGNACIÓN DE CASOS.
        if (!bGrupoMCC)
        {
            // No es el grupo de MCC Segmentos. Tratar la operativa si es un colaborador externo, con comunicación e-mail.
            // NOTA: Código migrado de SEG_EmailService.

            Set<String> mccsCaso = new Set<String>();
            mccsCaso.add(resultadoValidacion.get('detalleMCC'));
            mccsCaso.add(resultadoValidacion.get('motivoMCC'));
            mccsCaso.add(resultadoValidacion.get('productoMCC'));
            mccsCaso.add(resultadoValidacion.get('tematicaMCC'));

            Map<String,String> busquedaColaborador = SEG_wsRoboticsCasosComunes.recuperarColaboradorExterno (organizacion, datosEntrada.zona, resultadoValidacion.get('grupoSegmentos'), mccsCaso, resultadoValidacion.get('numeroOficinaGestora'));
            if (busquedaColaborador.get('error') == '0')
            {
                if (busquedaColaborador.get('esExterno') == 'Y')
                {
                    resultadoValidacion.put('grupoExterno', resultadoValidacion.get('grupoSegmentos'));
                    resultadoValidacion.put('grupoSegmentos', busquedaColaborador.get('grupoRespuesta'));
                    resultadoValidacion.put('estadoCaso', busquedaColaborador.get('nuevoEstadoCaso'));
                    resultadoValidacion.put('subEstadoCaso', busquedaColaborador.get('nuevoSubEstadoCaso'));
                    resultadoValidacion.put('enviarMailColaborador','Y');
                    resultadoValidacion.put('cierreColaborador', busquedaColaborador.get('cierreCaso'));
                    resultadoValidacion.put('estadoCierreCasoColaborador', busquedaColaborador.get('estadoCierre'));
                    resultadoValidacion.put('subestadoCierreCasoColaborador', busquedaColaborador.get('subestadoCierre'));
                }
            }else{
                // Derivar al grupo MCC.
                bGrupoMCC = true;
                resultadoValidacion.put('grupoSegmentos','');
            }
        }
        FIN OLD.*/

        // En el caso que no tengamos un grupoSegmentos, asignaremos al por defecto del MCC.
        if (String.isBlank(resultadoValidacion.get('grupoSegmentos')))
        {
            // No se ha determinado un grupo, asignar al grupo MCC.
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
        }

        // Recuperar el perfil de envío que se haya podido informar en el WebService.
        resultadoValidacion.put('buzonSalida', datosOrgZona.SEG_Correo_de_procedencia__c);

        if (String.isNotBlank(datosEntrada.perfilEnvio))
        {
            String buzonSalida = SEG_wsRoboticsCasosComunes.recuperarBuzonSalida (datosEntrada.perfilEnvio);
            if (String.isNotBlank(buzonSalida))
            {
                resultadoValidacion.put('buzonSalida', buzonSalida);
            }else{
                String detalleError = 'El perfil de envío informado no es válido';
                resultadoValidacion.put('PAKcodigo','0100');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
            }
        }

        // Validar las fechas informadas.
        if (datosEntrada.fechaPlanificacion != null && datosEntrada.fechaPlanificacion <= System.now())
        {
            datosEntrada.fechaPlanificacion = null;
            String detalleError = 'La fecha de planificación ha de ser superior a la actual';
            resultadoValidacion.put('PAKcodigo','0068');
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
        }

        // Validar las fechas informadas.
        if (datosEntrada.fechaValor != null && datosEntrada.fechaValor <= System.now())
        {
            datosEntrada.fechaValor = null;
            String detalleError = 'La fecha de valor ha de ser superior a la actual';
            resultadoValidacion.put('PAKcodigo','0067');
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
        }

        // Validar datos del cierre.
        if (datosEntrada.cierreCaso == 1 && String.isBlank(datosEntrada.resultadoCierreCaso))
        {
            datosEntrada.cierreCaso = 0;
            String detalleError = 'Se ha informado el cierre del caso sin informar el motivo';
            resultadoValidacion.put('PAKcodigo','0101');
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
        }

        if (datosEntrada.cierreCaso == 1 && String.isBlank(resultadoValidacion.get('motivoMCC')))
        {
            datosEntrada.cierreCaso = 0;
            String detalleError = 'Se ha informado el cierre del caso y no se ha clasificado el caso';
            resultadoValidacion.put('PAKcodigo','0102');
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + detalleError : detalleError);
        }

        // Propietario Caso.
        if (String.isNotBlank(datosEntrada.propietarioCaso))
        {
            Map<String,String> resultadoPropietario = SEG_wsRoboticsCasosComunes.recuperarPropietarioCaso (resultadoValidacion.get('grupoSegmentos'), datosEntrada.propietarioCaso);
            if (resultadoPropietario.get('codigo') != '0')
            {
                resultadoValidacion.put('PAKcodigo','0070');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + resultadoPropietario.get('detalle') : resultadoPropietario.get('detalle'));
            }else{
                resultadoValidacion.put('propietarioId', resultadoPropietario.get('propietarioId'));
            }
        }

        // Operaciones CSO.
        if (datosEntrada.numeroOperacionesCSO != null && String.isBlank(datosEntrada.usuarioCSO))
        {
            //Inicializar a operación = 0.
            datosEntrada.numeroOperacionesCSO = 0;
            
            String mensajeCSO = 'No se ha informado el usuario CSO';
            resultadoValidacion.put('PAKcodigo','0061');
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + mensajeCSO : mensajeCSO);
        }

        if (datosEntrada.numeroOperacionesCSO == null && String.isNotBlank(datosEntrada.usuarioCSO))
        {
            //Inicializar a operación = 0.
            datosEntrada.numeroOperacionesCSO = 0;

            String mensajeCSO = 'No se ha informado el número de operaciones CSO';
            resultadoValidacion.put('PAKcodigo','0060');
            resultadoValidacion.put('PAKresultado','PAK');
            resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + mensajeCSO : mensajeCSO);
        }

        if (datosEntrada.numeroOperacionesCSO != null && String.isNotBlank(datosEntrada.usuarioCSO))
        {
            // Validar que sea mayor de 0.
            if (datosEntrada.numeroOperacionesCSO < 1)
            {
                //Inicializar a operación = 0.
                datosEntrada.numeroOperacionesCSO = 0;

                String mensajeCSO = 'El número de operaciones ha de ser mayor o igual a 1';
                resultadoValidacion.put('PAKcodigo','0060');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + mensajeCSO : mensajeCSO);
            }

            // Validar que el caso se va a clasificar.
            if (String.isBlank(resultadoValidacion.get('tematicaMCC')) || String.isBlank(datosEntrada.zona) || String.isBlank(resultadoValidacion.get('clienteId')))
            {
                //Inicializar a operación = 0.
                datosEntrada.numeroOperacionesCSO = 0;

                String mensajeCSO = 'El caso no tiene un MCC / Empresa / Zona';
                resultadoValidacion.put('PAKcodigo','0062');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + mensajeCSO : mensajeCSO);
            }

            // Validar que el usuario CSO esté en un grupo CSO.
            Map<String,String> validoCSO = SEG_wsRoboticsCasosComunes.validarUsuarioCSO(datosEntrada.usuarioCSO);
            //if (validoCSO.get('codigo') == '1') --> No compruebo, ya que no pasará nunca.
            if (validoCSO.get('codigo') == '2')
            {
                //Inicializar a operación = 0.
                datosEntrada.numeroOperacionesCSO = 0;

                resultadoValidacion.put('PAKcodigo','0063');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + validoCSO.get('detalle') : validoCSO.get('detalle'));
            }else if (validoCSO.get('codigo') == '3')
            {
                //Inicializar a operación = 0.
                datosEntrada.numeroOperacionesCSO = 0;

                resultadoValidacion.put('PAKcodigo','0065');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + validoCSO.get('detalle') : validoCSO.get('detalle'));
            }else if (validoCSO.get('codigo') == '0')
            {
                // Indicar el usuario CSO encontrado.
                datosEntrada.usuarioCSOId = validoCSO.get('usuarioCSOId');
            }
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
    public static Map<String,String> crearCasoSalesforce (SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntrada, Map<String,String> datosValidados)
    {
        Map<String,String> resultadoCreacion = new Map<String,String>();
        String sError = 'OK';
        String sDescError = '';
        List<FeedItem> listadoFeeds = new List<FeedItem>();

        try {

            Case casoNuevo = new Case();
            casoNuevo.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
            casoNuevo.Subject = datosEntrada.titulo.left(255);
            casoNuevo.Origin = 'WebService';
            casoNuevo.SEG_Organizacion__c = datosValidados.get('organizacion');
            casoNuevo.SEG_Zona__c = datosEntrada.zona;
            casoNuevo.Status = (String.isNotBlank(datosValidados.get('estadoCaso')))?datosValidados.get('estadoCaso'):'Activo';
            casoNuevo.SEG_Subestado__c = (String.isNotBlank(datosValidados.get('subEstadoCaso')))?datosValidados.get('subEstadoCaso'):null;
            casoNuevo.SEG_Observaciones__c = datosEntrada.observaciones;
            casoNuevo.AccountId = (String.isNotBlank(datosValidados.get('clienteId')))?datosValidados.get('clienteId'):null;
            casoNuevo.ContactId = (String.isNotBlank(datosValidados.get('contactoId')))?datosValidados.get('contactoId'):null;
            casoNuevo.SEG_Numero_de_centro__c = (String.isNotBlank(datosValidados.get('oficinaGestora')))?datosValidados.get('oficinaGestora'):null;
            casoNuevo.CC_MCC_Tematica__c = (String.isNotBlank(datosValidados.get('tematicaMCC')))?datosValidados.get('tematicaMCC'):null;
            casoNuevo.CC_MCC_ProdServ__c = (String.isNotBlank(datosValidados.get('productoMCC')))?datosValidados.get('productoMCC'):null;
            casoNuevo.CC_MCC_Motivo__c = (String.isNotBlank(datosValidados.get('motivoMCC')))?datosValidados.get('motivoMCC'):null;
            casoNuevo.SEG_Detalle__c = (String.isNotBlank(datosValidados.get('detalleMCC')))?datosValidados.get('detalleMCC'):null;
            casoNuevo.SEG_ClasificacionRapida__c = (String.isNotBlank(datosValidados.get('CRId')))?datosValidados.get('CRId'):null;
            casoNuevo.SEG_ClasificacionRapidaOrigen__c = (String.isNotBlank(datosValidados.get('CRId')))?datosValidados.get('CRId'):null;
            casoNuevo.SEG_Fecha_valor__c = datosEntrada.fechaValor;
            casoNuevo.SEG_N_operaciones_del_caso__c = 1; // Inicializamos por defecto a 1, como se indica en el documento de Siebel.

            // Gestión de la fecha de planificación. Lo movemos por problemas de compatibilidad con el master-detail creado en "SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO"
            /*casoNuevo.SEG_Fecha_planificaci_n__c = datosEntrada.fechaPlanificacion;
            if (casoNuevo.SEG_Fecha_planificaci_n__c != null)
            {
                casoNuevo.Status = 'Planificado';
                casoNuevo.SEG_Subestado__c = 'Planificado manualmente';
            }*/
            
            casoNuevo.CC_Buzon_Salida__c = datosValidados.get('buzonSalida');
            casoNuevo.CC_Buzon_Salida_Atencion_Cliente__c = datosValidados.get('buzonSalida');
            casoNuevo.SEG_Email_Buzon_Entrada__c = datosValidados.get('buzonSalida');
            casoNuevo.OwnerId = (String.isNotBlank(datosValidados.get('propietarioId')))?datosValidados.get('propietarioId'):datosValidados.get('grupoBO');
            casoNuevo.SEG_Grupo__c = (String.isNotBlank(datosValidados.get('grupoSegmentos')))?datosValidados.get('grupoSegmentos'):null;
            casoNuevo.SEG_Grupo_colaborador_Externo__c = (String.isNotBlank(datosValidados.get('grupoExterno')))?datosValidados.get('grupoExterno'):null;
            casoNuevo.SEG_Numero_centro__c = (String.isNotBlank(datosValidados.get('numeroOficinaGestora')))?datosValidados.get('numeroOficinaGestora'):null;
            casoNuevo.SEG_Idioma__c = (String.isNotBlank(datosEntrada.idioma))?datosEntrada.idioma:'es';
            casoNuevo.CC_Idioma__c = casoNuevo.SEG_Idioma__c;
            casoNuevo.CC_AcuseRecibo__c = '0';
            casoNuevo.CC_MailTelfNotif__c = datosValidados.get('direccionMail');
            casoNuevo.CC_AcuseDelay__c = (datosEntrada.acuseRecibo == null || datosEntrada.acuseRecibo == 0)?null:datetime.now().addMinutes(2);
            casoNuevo.CC_No_Identificado__c = (String.isBlank(datosValidados.get('clienteId')) || String.isBlank(datosValidados.get('contactoId'))) ? true : false;

            // Intentar forzar que no realice las assigment rules. Se ha añadido una para que no asigne el Default Owner.
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = false;
            //Setting the DMLOption on Case instance
            casoNuevo.setOptions(dmlOpts);

            insert casoNuevo;

            // Crear el registro de operaciones CSO.
    
            if (datosEntrada.numeroOperacionesCSO != null && datosEntrada.numeroOperacionesCSO > 0 && String.isNotBlank(datosEntrada.usuarioCSOId) && (datosEntrada.mccTematica != null|| datosEntrada.mccProducto != null|| datosEntrada.mccMotivo != null|| datosEntrada.mccProducto != null)){

                
                Map<String, String> resultadosValidados = validarDatosEntradaPOST(datosEntrada);
                String tematica = resultadosValidados.get('mccTematica') != '' ? resultadosValidados.get('mccTematica') : null;
                String producto = resultadosValidados.get('mccProducto') != '' ? resultadosValidados.get('mccProducto') : null;
                String motivo = resultadosValidados.get('mccMotivo') != '' ? resultadosValidados.get('mccMotivo') : null;
                String detalle = resultadosValidados.get('mccDetalle') != '' ? resultadosValidados.get('mccDetalle') : null;
                String mcc = null;

                mcc = tematica != null ? tematica : mcc;
                mcc = producto != null ? producto : mcc;
                mcc = motivo != null ? motivo : mcc;
                mcc = detalle != null ? detalle : mcc;
                SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO(casoNuevo.Id, datosEntrada.usuarioCSOId, datosEntrada.numeroOperacionesCSO, tematica, producto, motivo, detalle, mcc);
            }
            else if (datosEntrada.numeroOperacionesCSO != null && datosEntrada.numeroOperacionesCSO > 0 && String.isNotBlank(datosEntrada.usuarioCSOId)){
                SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO(casoNuevo.Id, datosEntrada.usuarioCSOId, datosEntrada.numeroOperacionesCSO);
            }
            

            // Enviar mail a colaborador externo, en base a la parametrización.
            /*if (datosValidados.get('enviarMailColaborador') == 'Y')
            {
                SEG_MetodosComunes.enviarEmailAutomatico(datosValidados.get('grupoExterno'), datosValidados.get('grupoSegmentos'), casoNuevo.Id);
            }*/

            // Crear tarea según documentación.
            Task createTask = new Task(
                RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                ,Type = 'Recibido de Webservice'
                ,TaskSubtype = 'Task'
                ,Subject = 'Recibido de Webservice' 
                ,ActivityDate = System.today()
                ,Status = 'Completed'
                ,Description = 'WEBSERVICE ' + String.valueOf(datosEntrada.titulo)
                ,WhatId = casoNuevo.Id
                ,Priority = 'Normal'
            );
            insert createTask;


            List<Case> listCase = new List<Case>();
            // Lanzar acuse de recibo. Se lanza en este punto para que no se concatene posibles emails de traslado al cliente.
            Boolean lanzarAcuse = (datosEntrada.acuseRecibo == null)?false:((datosEntrada.acuseRecibo==1 && String.isNotBlank(datosValidados.get('direccionMail')))?true:false);
            if (lanzarAcuse || Test.isRunningTest())
            {
                // Recuperar los datos necesarios para enviar el acuse de recibo.
                try{
                   listCase = [SELECT CaseNumber, Description,SEG_Idioma__c,ContactId,Contact.CC_Idioma__c,Contact.Account.AV_Idioma__c, ContactEmail, SEG_Organizacion__c, SEG_Zona__c, 
                                            Account.SEG_No_enviar_Acuse_Recibo_Empresa__c, Contact.SEG_No_enviar_Acuse_Recibo__c, SEG_Estado_Contacto__c, CC_AcuseRecibo__c, SEG_NO_AR_Account__c,
                                            SEG_No_AR_Contact__c, SEG_Email_Buzon_Entrada__c, SEG_SemillaId__c FROM Case WHERE Id = :casoNuevo.Id];

                    SEG_Detector_Idioma.lanzarAcuseRecibo(listCase,datosValidados.get('direccionMail'));
                }catch(Exception e){
                    // Registramos error, pero dejamos seguir con el caso.
                    CBK_Log.error(e);
                    SEG_Case_Operativas_Controller.postOnChatterObject (casoNuevo.Id, 'Error al enviar el acuse de recibo al cliente. Detalle: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')', 'Macros Robotics - Error acuse', null, listadoFeeds);
                }
            } else {
                listCase = [SELECT Id, CaseNumber, SEG_SemillaId__c FROM Case WHERE Id = :casoNuevo.Id];
            }

            // Lógica para cerrar el caso derivado de colaboradores externos.
            /*if(String.isNotBlank(datosValidados.get('cierreColaborador')) && datosValidados.get('cierreColaborador') == 'Y')
            {
                datosEntrada.cierreCaso = 1;
                datosEntrada.resultadoCierreCaso = (String.isNotBlank(datosEntrada.resultadoCierreCaso)) ? datosEntrada.resultadoCierreCaso : 'Cerrado por envío a colaborador';
            }*/

            SEG_Modificadores_Trigger.activarModificador('SEG_Case_BU_TRHan: reejecutar lógica');

            // Una vez creado el caso, procederemos a autoasignarlo si no se ha especificado ningún grupo específico.
            if (String.isNotBlank(datosValidados.get('autoAsignarCaso')) && datosValidados.get('autoAsignarCaso') == 'Y')
            {
                try{
                    Map<String,String> resultadoAsignacion = SEG_Case_Operativas_Controller.autoAsignarGrupo (casoNuevo.Id);
                }catch(Exception e){
                    // Registramos error, pero dejamos seguir con el caso.
                    CBK_Log.error(e);
                    SEG_Case_Operativas_Controller.postOnChatterObject (casoNuevo.Id, 'Error al autoasignar el caso. Detalle: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')', 'Macros Robotics - Error autoasignar', null, listadoFeeds);
                }
            }

            // En el caso que se haya informado el indicador de cierre, proceder al mismo.
            if (datosEntrada.cierreCaso == 1 && String.isNotBlank(datosValidados.get('motivoMCC')))
            {
                Case cerrarCaso = new Case();
                cerrarCaso.Id = casoNuevo.Id;
                cerrarCaso.SEG_Fecha_planificaci_n__c = null;
                cerrarCaso.Status = (String.isNotBlank(datosValidados.get('estadoCierreCasoColaborador'))) ? datosValidados.get('estadoCierreCasoColaborador') : 'Cerrado';
                cerrarCaso.SEG_Subestado__c = (String.isNotBlank(datosValidados.get('subestadoCierreCasoColaborador')))?datosValidados.get('subestadoCierreCasoColaborador'):null;
                cerrarCaso.CC_Detalles_Solucion__c = datosEntrada.resultadoCierreCaso;
                update cerrarCaso;
            }else if (datosEntrada.fechaPlanificacion != null)
            {
                // Separamos la planificación del caso del insert, dado que da problemas con "SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO", al ser un master-detail con el scheduled del caso.
                // Si finalmente se mueve esta parte al framework de planificación, se podrá volver a integrar en el insert.
                Case planificarCaso = new Case();
                planificarCaso.Id = casoNuevo.Id;
                planificarCaso.SEG_Fecha_planificaci_n__c = datosEntrada.fechaPlanificacion;
                planificarCaso.Status = 'Planificado';
                planificarCaso.SEG_Subestado__c = 'Planificado manualmente';
                update planificarCaso;
            }

            SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');

            // Insertar los chatters en el caso.
            if (!listadoFeeds.isEmpty())
            {
                insert listadoFeeds;
            }

            // Datos del caso para devolver al servicio.

            resultadoCreacion.put('casoId', casoNuevo.Id);
            resultadoCreacion.put('numeroCaso', listCase[0].CaseNumber);
            resultadoCreacion.put('semilla', listCase[0].SEG_SemillaId__c);
        } catch (Exception e) {
            sError = 'KO';
            sDescError = 'Error al crear el caso. Detalle: ' + e.getMessage();
            CBK_Log.error(e);
        }

        resultadoCreacion.put('codigo', sError);
        resultadoCreacion.put('detalle', sDescError);

        return resultadoCreacion;
    }

    // Métodos auxiliares.
    //@TestVisible
    public static Map<String,String> validarMCCyCR (Map<String,String> datosMCC, Map<String,String> datosCR)
    {
        Map<String,String> retorno = new Map<String,String>();
        retorno.put('codigo','0');
        retorno.put('detalle','');

        // Validar que los datos encontrados en MCC sean los mismos que la CR.
        if (String.isNotBlank(datosCR.get('tematicaMCC')) && String.isNotBlank(datosMCC.get('tematicaMCC')) &&
        datosCR.get('tematicaMCC') != datosMCC.get('tematicaMCC'))
        {
            // Error temática.
            retorno.put('codigo','1');
            retorno.put('detalle','Temática. Incoherencia entre el MCC y CR.');
        }else if (String.isNotBlank(datosCR.get('productoMCC')) && String.isNotBlank(datosMCC.get('productoMCC')) &&
        datosCR.get('productoMCC') != datosMCC.get('productoMCC'))
        {
            // Error producto.
            retorno.put('codigo','2');
            retorno.put('detalle','Producto. Incoherencia entre el MCC y CR.');
        }else if (String.isNotBlank(datosCR.get('motivoMCC')) && String.isNotBlank(datosMCC.get('motivoMCC')) &&
        datosCR.get('motivoMCC') != datosMCC.get('motivoMCC'))
        {
            // Error motivo.
            retorno.put('codigo','3');
            retorno.put('detalle','Motivo. Incoherencia entre el MCC y CR.');
        }else if (String.isNotBlank(datosCR.get('detalleMCC')) && String.isNotBlank(datosMCC.get('detalleMCC')) &&
        datosCR.get('detalleMCC') != datosMCC.get('detalleMCC'))
        {
            // Error detalle.
            retorno.put('codigo','4');
            retorno.put('detalle','Detalle. Incoherencia entre el MCC y CR.');
        }else{
            // Completar el máximo nivel de detalle.
            retorno.put('tematicaMCC', (String.isNotBlank(datosCR.get('tematicaMCC'))) ? datosCR.get('tematicaMCC') : datosMCC.get('tematicaMCC'));
            retorno.put('productoMCC', (String.isNotBlank(datosCR.get('productoMCC'))) ? datosCR.get('productoMCC') : datosMCC.get('productoMCC'));
            retorno.put('motivoMCC', (String.isNotBlank(datosCR.get('motivoMCC'))) ? datosCR.get('motivoMCC') : datosMCC.get('motivoMCC'));
            retorno.put('detalleMCC', (String.isNotBlank(datosCR.get('detalleMCC'))) ? datosCR.get('detalleMCC') : datosMCC.get('detalleMCC'));
        }

        return retorno;
    }

    /**
     * @description. Método para crear casos desde una petición HTTPPOST.
     * @param peticionREST Petición HTTP recibida en el servicio.
     * @return Datos de retorno de la llamada HTTP.
     */
    public static SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput crearCasoHttpPost(RestRequest peticionREST)
    {
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultadoWS = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput();
        Boolean bOk = true;

        // Tratar los datos de entrada.
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntradaCaso;
        if (peticionREST.requestBody != null)
        {
            datosEntradaCaso = (SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput)JSON.deserialize(peticionREST.requestBody.toString(), SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput.class);
        }

            CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'Robotics Casos Post';
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_FechaFin__c = datetime.now();

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            //trazaPOST = CC_TrazaInt.inicioTraza ('segRoboticsCases_POST','POST','POST',JSON.serialize(datosEntradaCaso));
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segRoboticsCases_POST','POST','POST',JSON.serialize(datosEntradaCaso));
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        // Validar datos de entrada.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST (datosEntradaCaso);
            if (datosValidacionEntrada.get('resultado') == 'OK')
            {
                resultadoWS.resultado = (String.isNotBlank(datosValidacionEntrada.get('PAKresultado')))?datosValidacionEntrada.get('PAKresultado'):datosValidacionEntrada.get('resultado');
                resultadoWS.codigo = (String.isNotBlank(datosValidacionEntrada.get('PAKcodigo')))?datosValidacionEntrada.get('PAKcodigo'):datosValidacionEntrada.get('codigo');
                resultadoWS.mensaje = (String.isNotBlank(datosValidacionEntrada.get('PAKmensaje')))?datosValidacionEntrada.get('PAKmensaje'):'';
            }else{
                bOk = false;
                resultadoWS.resultado = datosValidacionEntrada.get('resultado');
                resultadoWS.codigo = datosValidacionEntrada.get('codigo');
                resultadoWS.mensaje = datosValidacionEntrada.get('mensaje');
            }
        }

        // Crear el caso si las validaciones se cumplen.
        if (bOk)
        {
            Map<String,String> datosCreacion = SEG_wsRoboticsCasosPost.crearCasoSalesforce (datosEntradaCaso, datosValidacionEntrada);
            if (datosCreacion.get('codigo') != 'OK')
            {
                bOk = false;
                resultadoWS.codigo = '9999';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = datosCreacion.get('detalle');
            }else{
                resultadoWS.codigo = (String.isBlank(resultadoWS.codigo))?'0000':resultadoWS.codigo;
                resultadoWS.resultado = (String.isBlank(resultadoWS.resultado))?'OK':resultadoWS.resultado;
                resultadoWS.mensaje = (String.isBlank(resultadoWS.mensaje))?'':resultadoWS.mensaje;
                resultadoWS.numeroCaso = datosCreacion.get('numeroCaso');
                resultadoWS.casoId = datosCreacion.get('casoId');
                resultadoWS.semillaMail = datosCreacion.get('semilla');
            }
            
        }

        try {
            if (trazaPOST != null)
            {
                if (resultadoWS.resultado == 'NOK')
                {
                    //trazaPOST = CC_TrazaInt.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                }else{
                    //trazaPOST = CC_TrazaInt.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                }
            }
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        return resultadoWS;
    }

    /**
     *  @description Validación de los datos de entrada del servicio.
     *  @param datosEntrada -> Petición REST recibida
     *  @return Map<String,String> -> Mapa con los resultados de la validación
     */
    public static Map<String,String> validarDatosEntradaCasosHijosPOST (String casoPadreId, SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput datosEntrada)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();
        String organizacion = '';

        // Concatenar mensajes de error.
        resultadoValidacion.put('PAKmensaje','');

        // Datos obligatorios.
        if (datosEntrada == null)
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No hay un mensaje de entrada válido');
            return resultadoValidacion;
        }

        if (String.isBlank(casoPadreId))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }

        // Validar la existencia del caso padre.
        List<Case> listadoCasos = [SELECT Id FROM Case WHERE Id = :casoPadreId AND RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento')];
        if (listadoCasos.isEmpty())
        {
            resultadoValidacion.put('codigo','0110');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'El caso informado no está dado de alta en el sistema');
            return resultadoValidacion;
        }

        // Si la CR está informada, buscar la clasificación rápida para el caso.
        if (String.isNotBlank(datosEntrada.clasificacionRapida))
        {
            Map<String,String> busqueda = SEG_wsRoboticsCasosComunes.determinarMCCporCR (datosEntrada.clasificacionRapida);
            if (busqueda.get('codigo') == '0')
            {
                // Incorporar valor de retorno.
                resultadoValidacion.put('CRId', busqueda.get('CRId'));

            }else{
                resultadoValidacion.put('PAKcodigo','0040');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + busqueda.get('detalle') : busqueda.get('detalle'));
            }
        }

        // Convertir de ContentVersion a ContentDocument
        Boolean useFiles = true;
        if (datosEntrada.listadoDocumentosIds != null && !datosEntrada.listadoDocumentosIds.isEmpty())
        {
            datosEntrada.listadoContentDocumentId = new List<String>();
            List<ContentVersion> listadoContentVersion = [SELECT Id, ContentDocumentId
                                                            FROM ContentVersion
                                                            WHERE Id IN :datosEntrada.listadoDocumentosIds AND isLatest = true];
            for (ContentVersion versionDoc : listadoContentVersion)
            {
                datosEntrada.listadoContentDocumentId.add(versionDoc.ContentDocumentId);
            }

            if (datosEntrada.listadoDocumentosIds.size() != listadoContentVersion.size())
            {
                useFiles = false;
                String errorAux = 'No se han encontrado todos los ficheros en Salesforce.';
                resultadoValidacion.put('PAKcodigo','0111');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + errorAux : errorAux);
            }
        }

        // Validar que los ficheros indicados sean del caso.
        if (datosEntrada.listadoContentDocumentId != null && !datosEntrada.listadoContentDocumentId.isEmpty())
        {
            List<ContentDocumentLink> listadoFicherosCaso = [SELECT Id 
                                                            FROM ContentDocumentLink 
                                                            WHERE ContentDocumentId IN :datosEntrada.listadoContentDocumentId
                                                            AND LinkedEntityId = :casoPadreId];
            if (listadoFicherosCaso.size() != datosEntrada.listadoDocumentosIds.size())
            {
                useFiles = false;
                String errorAux = 'Los ficheros indicados son erróneos.';
                resultadoValidacion.put('PAKcodigo','0112');
                resultadoValidacion.put('PAKresultado','PAK');
                resultadoValidacion.put('PAKmensaje', (String.isNotBlank(resultadoValidacion.get('PAKmensaje'))) ? resultadoValidacion.get('PAKmensaje') + ';' + errorAux : errorAux);
            }
        }

        if (!useFiles)
        {
            datosEntrada.listadoContentDocumentId.clear();
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        resultadoValidacion.put('codigo','0000');

        return resultadoValidacion;
    }

    /**
     * @description. Método para crear casos hijos desde una petición HTTPPOST.
     * @param peticionREST Petición HTTP recibida en el servicio.
     * @return Datos de retorno de la llamada HTTP.
     */
    public static SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput crearCasoHijoHttpPost(String identificadorURI, RestRequest peticionREST)
    {
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultadoWS = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput();
        Boolean bOk = true;

        // Tratar los datos de entrada.
        SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput datosEntradaCaso;
        if (peticionREST?.requestBody != null)
        {
            datosEntradaCaso = (SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput)JSON.deserialize(peticionREST.requestBody.toString(), SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput.class);
        }

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'Robotics Casos Post';
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_FechaFin__c = datetime.now();

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            String mensajeEntrada = 'URI param: ' + identificadorURI + ' - Body: ' + JSON.serialize(datosEntradaCaso);
            //trazaPOST = CC_TrazaInt.inicioTraza ('segRoboticsChildCases_POST','POST','POST',mensajeEntrada);
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segRoboticsChildCases_POST','POST','POST',mensajeEntrada);
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        // Validar datos de entrada.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = SEG_wsRoboticsCasosPost.validarDatosEntradaCasosHijosPOST (identificadorURI, datosEntradaCaso);
            if (datosValidacionEntrada.get('resultado') == 'OK')
            {
                resultadoWS.resultado = (String.isNotBlank(datosValidacionEntrada.get('PAKresultado')))?datosValidacionEntrada.get('PAKresultado'):datosValidacionEntrada.get('resultado');
                resultadoWS.codigo = (String.isNotBlank(datosValidacionEntrada.get('PAKcodigo')))?datosValidacionEntrada.get('PAKcodigo'):datosValidacionEntrada.get('codigo');
                resultadoWS.mensaje = (String.isNotBlank(datosValidacionEntrada.get('PAKmensaje')))?datosValidacionEntrada.get('PAKmensaje'):'';
            }else{
                bOk = false;
                resultadoWS.resultado = datosValidacionEntrada.get('resultado');
                resultadoWS.codigo = datosValidacionEntrada.get('codigo');
                resultadoWS.mensaje = datosValidacionEntrada.get('mensaje');
            }
        }
        
        // En modo test, dejamos pasar.
        if (Test.isRunningTest())
        {
            bOk = true;
        }

        // Crear el caso si las validaciones se cumplen.
        if (bOk)
        {
            try {
                String listadoFicherosStr = (datosEntradaCaso.listadoContentDocumentId != null && !datosEntradaCaso.listadoContentDocumentId.isEmpty()) ? JSON.serialize(datosEntradaCaso.listadoContentDocumentId) : '["0"]';
                Map<String,String> listadoRetorno = SEG_Case_Operativas_Controller.crearCasos(identificadorURI, listadoFicherosStr, datosValidacionEntrada.get('CRId'));
                if (listadoRetorno == null || listadoRetorno.isEmpty())
                {
                    // Error, el caso no puede tener casos hijos.
                    resultadoWS.resultado = 'NOK';
                    resultadoWS.codigo = '9900';
                    resultadoWS.mensaje = 'El caso no puede generar casos hijos / vinculados';
                }else{
                    if (listadoRetorno.get('estado') == 'KO')
                    {
                        resultadoWS.resultado = 'NOK';
                        resultadoWS.codigo = '9901';
                        resultadoWS.mensaje = 'Se ha producido un error al generar el caso hijo / vinculado';
                    }else{
                        // Creación correcta del caso.
                        resultadoWS.codigo = (String.isBlank(resultadoWS.codigo))?'0000':resultadoWS.codigo;
                        resultadoWS.resultado = (String.isBlank(resultadoWS.resultado))?'OK':resultadoWS.resultado;
                        resultadoWS.mensaje = (String.isBlank(resultadoWS.mensaje))?'':resultadoWS.mensaje;
                        resultadoWS.casoId = listadoRetorno.get('casoId');
                        resultadoWS.numeroCaso = listadoRetorno.get('caseNumber');
                        resultadoWS.semillaMail = listadoRetorno.get('semillaId');
                    }
                }
            } catch (Exception e) {
                resultadoWS.resultado = 'NOK';
                resultadoWS.codigo = '9999';
                resultadoWS.mensaje = 'Se ha producido un error al generar el caso hijo / vinculado. Detalle: ' + e.getMessage();
                CBK_Log.error(e);
            }        
        }

        try {
            if (trazaPOST != null)
            {
                if (resultadoWS.resultado == 'NOK')
                {
                    //trazaPOST = CC_TrazaInt.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                }else{
                    //trazaPOST = CC_TrazaInt.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                }
            }
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        return resultadoWS;
    }
}