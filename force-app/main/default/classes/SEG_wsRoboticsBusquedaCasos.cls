/**
*   @description SEG_wsRoboticsBusquedaCasos
*/
@RestResource(urlMapping='/v1/segRoboticsSearchCases/*')
global with sharing class SEG_wsRoboticsBusquedaCasos {

    global class SEG_WS_SearchCase_PostIntput{
        global Integer recuperarCorreo {get;set;}
        global Map<String,String> filtros {get;set;}
        private String propietarioId;
        private String limitQuery;
    }

    global class SEG_WS_SearchCase_PostOutput {
        global String resultado {get;set;}
        global String mensaje {get;set;}
        global String codigo {get;set;}
        List<SEG_Caso> listadoCasos {get;set;}
    }

    global class SEG_Caso {
        global String casoId {get;set;}
        global String numeroCaso {get;set;}
        global String cuerpoMail {get;set;}
    }

    /**
     * ***************************************************************
     * ***************************************************************
     * @description Método POST del servicio REST.
     * ***************************************************************
     * ***************************************************************
     */
    @HttpPost
    global static SEG_WS_SearchCase_PostOutput buscarCasos ()
    {
        SEG_WS_SearchCase_PostOutput resultadoWS = new SEG_WS_SearchCase_PostOutput();
        Boolean bOk = true;
        RestRequest peticionREST = RestContext.request;
        
        // Tratar los datos de entrada.
        SEG_WS_SearchCase_PostIntput datosEntradaCaso;
        if (peticionREST.requestBody != null)
        {
            datosEntradaCaso = (SEG_WS_SearchCase_PostIntput)JSON.deserialize(peticionREST.requestBody.toString(), SEG_WS_SearchCase_PostIntput.class);
        }

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            //trazaPOST = CC_TrazaInt.inicioTraza ('segRoboticsSearchCases_POST','POST','POST',JSON.serialize(datosEntradaCaso));
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segRoboticsSearchCases_POST','POST','POST',JSON.serialize(datosEntradaCaso));
        } catch (Exception e) {
            trazaPOST =SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(datosEntradaCaso), e.getTypeName(), e.getMessage());
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

        // Validar datos de entrada.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = validarDatosEntradaPOST (datosEntradaCaso);
            if (datosValidacionEntrada.get('resultado') != 'OK')
            {
                bOk = false;
            }
            resultadoWS.resultado = datosValidacionEntrada.get('resultado');
            resultadoWS.codigo = datosValidacionEntrada.get('codigo');
            resultadoWS.mensaje = datosValidacionEntrada.get('mensaje');
        }

        // Crear el caso si las validaciones se cumplen.
        if (bOk)
        {
            resultadoWS = buscarCasosSalesforce (datosEntradaCaso);            
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
            trazaPOST =SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(resultadoWS), e.getTypeName(), e.getMessage());
        }

        return resultadoWS;
    }

    public static Map<String,String> validarDatosEntradaPOST (SEG_WS_SearchCase_PostIntput datosEntrada)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if (datosEntrada ==  null || datosEntrada.filtros == null || datosEntrada.filtros.isEmpty())
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje','No se han informado los datos obligatorios para la consulta');
            return resultadoValidacion;
        }

        if (String.isNotBlank(datosEntrada.filtros.get('Propietario')))
        {
            String valorEscapado = String.escapeSingleQuotes(datosEntrada.filtros.get('Propietario'));
            List<User> usuario = [SELECT Id FROM User WHERE EmployeeNumber = :valorEscapado];
            if (usuario.isEmpty())
            {
                resultadoValidacion.put('codigo','0001');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje','No se han informado los datos obligatorios para la consulta');
                return resultadoValidacion;
            }else{
                datosEntrada.propietarioId = usuario[0].Id;
            }
        }

        // Recuperar el valor configurado del límite de casos.
        String valorLimite = SEG_MetodosComunes.recuperarParametrosValor('SEG_wsRoboticsBusquedaCasosLimit');
        valorLimite = (String.isNotBlank(valorLimite)) ? valorLimite : '200';
        datosEntrada.limitQuery = valorLimite;

        // Si llegamos hasta aquí, la validación es correcta para realizar la consulta.
        resultadoValidacion.put('resultado','OK');
        resultadoValidacion.put('codigo','0000');

        return resultadoValidacion;
    }

    public static SEG_WS_SearchCase_PostOutput buscarCasosSalesforce (SEG_WS_SearchCase_PostIntput datosEntrada)
    {       
        SEG_WS_SearchCase_PostOutput retornoWS = new SEG_WS_SearchCase_PostOutput();
        retornoWS.codigo = '0000';
        retornoWS.resultado = 'OK';
        retornoWS.mensaje = '';

        try {

            String filtrosSOQL = '';
            Map<String,String> filtros = new Map<String,String>();
            if (datosEntrada.filtros != null)
            {
                List<String> listaFiltros = new List<String>();
                
                // Añadir los recordType de Segmentos.
                listaFiltros.add('RecordType.DeveloperName IN (\'SEG_Cliente\', \'SEG_Seguimiento\')');

                for (String clave : datosEntrada.filtros.keySet())
                {
                    String condicion = '';
                    String valorEscapado = String.escapeSingleQuotes(datosEntrada.filtros.get(clave));
                    if (clave == 'Grupo' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'SEG_Grupo__r.Name = \'' + valorEscapado + '\'';
                    }else if (clave == 'Grupo Contiene' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'SEG_Grupo__r.Name LIKE \'%' + valorEscapado + '%\'';
                    }else if (clave == 'Grupo Distinto' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'SEG_Grupo__r.Name <> \'' + valorEscapado + '\'';
                    }else if (clave == 'Grupo No Contiene' && String.isNotBlank(valorEscapado))
                    {
                        condicion = '(NOT SEG_Grupo__r.Name LIKE \'%' + valorEscapado + '%\')';
                    }else if (clave == 'Zona' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'SEG_Zona__c = \'' + valorEscapado + '\'';
                    }else if (clave == 'CIF' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'Account.CC_Numero_Documento__c = \'' + valorEscapado + '\'';
                    }else if (clave == 'Estado' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'Status = \'' + valorEscapado + '\''; 
                    }else if (clave == 'Subestado' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'SEG_Subestado__c = \'' + valorEscapado + '\'';
                    }else if (clave == 'CR' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'SEG_ClasificacionRapida__r.Name = \'' + valorEscapado + '\'';
                    }else if (clave == 'Propietario' && String.isNotBlank(datosEntrada.propietarioId))
                    {
                        // Buscar el propietario antes de hacer la query.
                        /*List<User> usuario = [SELECT Id FROM User WHERE EmployeeNumber = :datosEntrada.filtros.get(clave)];
                        if (!usuario.isEmpty())
                        {
                            condicion = 'OwnerId = \'' + usuario[0].Id + '\'';
                        }*/
                        condicion = 'OwnerId = \'' + datosEntrada.propietarioId + '\'';
                    }else if (clave == 'Fecha Apertura Desde' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'CreatedDate >= ' + valorEscapado + 'T00:00:00Z';
                    }else if (clave == 'Fecha Apertura Hasta' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'CreatedDate <= ' + valorEscapado + 'T00:00:00Z';
                    }else if (clave == 'Fecha Cierre Desde' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'ClosedDate >= ' + valorEscapado + 'T00:00:00Z';
                    }else if (clave == 'Fecha Cierre Hasta' && String.isNotBlank(valorEscapado))
                    {
                        condicion = 'ClosedDate <= ' + valorEscapado + 'T00:00:00Z';
                    }

                    // Solo añadimos el filtro si el valor está informado.
                    if (String.isNotBlank(condicion))
                    {
                        listaFiltros.add(condicion);
                    }
                }

                // Preparar filtro.
                if (!listaFiltros.isEmpty())
                {
                    filtrosSOQL = ' WHERE ' + String.join(listaFiltros, ' AND ');
                }else{
                    // Sin filtros, cancelar query.
                    retornoWS.codigo = '0000';
                    retornoWS.resultado = 'NOK';
                    retornoWS.mensaje = 'No se han informado los datos obligatorios para la consulta';
                    return retornoWS;
                }

                // Preparar límite query.
                String limiteQuery = ' LIMIT ' + ((String.isNotBlank(datosEntrada.limitQuery)?datosEntrada.limitQuery:'200'));

                // Preparar Query.
                //List<SEG_Caso> listaCasosReturn = new List<SEG_Caso>();
                Map<ID,SEG_Caso> mapaCasosReturn = new Map<ID,SEG_Caso>();
                String queryCasos = 'SELECT Id, CaseNumber, RecordType.DeveloperName FROM Case ' + filtrosSOQL + ' ORDER BY Id ' + limiteQuery;
                List<Case> listadoCasos = Database.query(queryCasos);
                for (Case caso : listadoCasos)
                {
                    SEG_Caso casoReturn = new SEG_Caso();
                    casoReturn.casoId = caso.Id;
                    casoReturn.numeroCaso = caso.CaseNumber;
                    casoReturn.cuerpoMail = '';
                    //listaCasosReturn.add(casoReturn);
                    mapaCasosReturn.put(caso.Id, casoReturn);
                }

                // Buscar el primer correo entrante de los casos encontrados.
                if (datosEntrada.recuperarCorreo != null && datosEntrada.recuperarCorreo == 1 && !mapaCasosReturn.isEmpty())
                {
                    for (EmailMessage mensaje : [SELECT Id, TextBody, MessageDate, Incoming, ParentId
                                                        FROM EmailMessage
                                                        WHERE Incoming = true
                                                        AND ParentId IN :mapaCasosReturn.keySet()
                                                        ORDER BY MessageDate ASC])
                    {
                        if (mapaCasosReturn.get(mensaje.ParentId) != null && String.isBlank(mapaCasosReturn.get(mensaje.ParentId).cuerpoMail))
                        {
                            mapaCasosReturn.get(mensaje.ParentId).cuerpoMail = mensaje.TextBody;
                        }
                    }
                }

                // Añadir listado al retorno.
                //retornoWS.listadoCasos = listaCasosReturn;
                retornoWS.listadoCasos = mapaCasosReturn.values();
            }

        } catch (Exception e) {
            retornoWS.codigo = '9999';
            retornoWS.resultado = 'NOK';
            retornoWS.mensaje = 'Error al recuperar los datos. Detalle: ' + e.getMessage();
            CBK_Log.error(e);
        }

        return retornoWS;
    }
}