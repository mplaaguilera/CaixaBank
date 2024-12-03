/**
*   @description SEG_wsRoboticsCasos
*/
@RestResource(urlMapping='/v1/segRoboticsCases/*')
global with sharing class SEG_wsRoboticsCasos {

    /**
     * ***************************************************************
     * ***************************************************************
     * @description Método POST del servicio REST.
     * ***************************************************************
     * ***************************************************************
     */
    @HttpPost
    global static SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput crearCaso ()
    {
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultadoWS = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput();
        Boolean bOk = true;
        RestRequest peticionREST = RestContext.request;
        String operacionPOST = '';
        String identificadorURI = '';

        // Validar URI. Determinar la operación a realizar.
        if (bOk)
        {
            List<String> elemURI = peticionREST?.requestURI.split('/');
            if (elemURI.size() == 3)
            {
                // Creación normal de caso.
                operacionPOST = 'CREACION';
            }else if (elemURI.size() == 5 && elemURI[4] == 'createChildCase')
            {
                // Crear SRs Hijas.
                operacionPOST = 'CASO_VINCULADO';
                identificadorURI = elemURI[3];
            }else{
                bOk = false;
                resultadoWS.codigo = '9002';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = 'La URI del servicio no está bien formada';
            }
        }

        if (bOk && operacionPOST == 'CREACION')
        {
            resultadoWS = SEG_wsRoboticsCasosPost.crearCasoHttpPost(peticionREST);
        }else if (bOk && operacionPOST == 'CASO_VINCULADO')
        {
            resultadoWS = SEG_wsRoboticsCasosPost.crearCasoHijoHttpPost(identificadorURI, peticionREST);
        }else{
            // Error de operación. Generar traza.
            CC_TrazaInt__c trazaPOST;
            try {
                String mensajeEntrada = 'URI param: ' + identificadorURI + ' - Body: ' + JSON.serialize(peticionREST?.requestBody);
                trazaPOST = SEG_MetodosComunes.inicioTraza ('segRoboticsCases_POST','POST','POST',mensajeEntrada);
                trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
            } catch (Exception e) {
                trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(resultadoWS), e.getTypeName(), e.getMessage());
            }
        }

        return resultadoWS;
    }

    /* ORIGINAL.
    @HttpPost
    global static SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput crearCaso ()
    {
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultadoWS = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput();
        Boolean bOk = true;
        RestRequest peticionREST = RestContext.request;
        
        // Tratar los datos de entrada.
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntradaCaso;
        if (peticionREST.requestBody != null)
        {
            System.debug(peticionREST.requestBody);
            System.debug(peticionREST.requestBody.toString());
            datosEntradaCaso = (SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput)JSON.deserialize(peticionREST.requestBody.toString(), SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput.class);
        }

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            trazaPOST = CC_TrazaInt.inicioTraza ('segRoboticsCases_POST','POST','POST',JSON.serialize(datosEntradaCaso));
        } catch (Exception e) {}

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
                    trazaPOST = CC_TrazaInt.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                }else{
                    trazaPOST = CC_TrazaInt.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                }
            }
        } catch (Exception e) {}

        return resultadoWS;
    }*/

    /**
     * ***************************************************************
     * ***************************************************************
     * @description Método PUT del servicio REST.
     * ***************************************************************
     * ***************************************************************
     */
    @HttpPut
    global static SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutOutput actualizarCaso ()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutOutput resultadoWS = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutOutput();
        Boolean bOk = true;
        RestRequest peticionREST = RestContext.request;
        String identificadorCaso = '';
        
        // Tratar los datos de entrada.
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntradaCaso;
        if (peticionREST.requestBody != null)
        {
            datosEntradaCaso = (SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput)JSON.deserialize(peticionREST.requestBody.toString(), SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput.class);
        }

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            //trazaPOST = CC_TrazaInt.inicioTraza ('segRoboticsCases_PUT',identificadorCaso,identificadorCaso,JSON.serialize(datosEntradaCaso));
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segRoboticsCases_PUT',identificadorCaso,identificadorCaso,JSON.serialize(datosEntradaCaso));
        } catch (Exception e) {
           // trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(resultadoWS), 'KO', e.getMessage());
           trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, '', e.getTypeName(), e.getMessage());
        }

        // Validar URI.
        if (bOk)
        {
            List<String> elemURI = RestContext.request.requestURI.split('/');
            if (elemURI.size() != 4)
            {
                bOk = false;
                resultadoWS.codigo = '9002';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = 'La URI del servicio no está bien formada';
            }else{
                identificadorCaso = elemURI[3];
            }
        }

        // Validar datos de entrada.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT (datosEntradaCaso, identificadorCaso);
            if (datosValidacionEntrada.get('resultado') != 'OK')
            {
                bOk = false;
            }
            resultadoWS.resultado = datosValidacionEntrada.get('resultado');
            resultadoWS.codigo = datosValidacionEntrada.get('codigo');
            resultadoWS.mensaje = datosValidacionEntrada.get('mensaje');
        }

        // Actualizar el caso si las validaciones se cumplen.
        if (bOk)
        {
            Map<String,String> datosCreacion = SEG_wsRoboticsCasosPut_v2.actualizarCasoSalesforce (datosEntradaCaso, datosValidacionEntrada);
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
            trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(resultadoWS), e.getTypeName(), e.getMessage());
        }

        return resultadoWS;
    }

    /**
     * ***************************************************************
     * ***************************************************************
     * @description Método GET del servicio REST.
     * ***************************************************************
     * ***************************************************************
     */
    @HttpGet
    global static SEG_wsRoboticsCasosGet.SEG_WS_NewCase_GetOutput getCasoSalesforce ()
    {
        SEG_wsRoboticsCasosGet.SEG_WS_NewCase_GetOutput resultadoWS = new SEG_wsRoboticsCasosGet.SEG_WS_NewCase_GetOutput();
        Boolean bOk = true;
        RestRequest peticionREST = RestContext.request;
        String identificadorCaso = '';

        // Tratar los datos de entrada.
        String recuperarCorreo = peticionREST.params.get('correo');
        String recuperarFicheros = peticionREST.params.get('ficheros');
        String extensionesFicheros = peticionREST.params.get('extensiones');

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            //trazaPOST = CC_TrazaInt.inicioTraza ('segRoboticsCases_GET',identificadorCaso,identificadorCaso,JSON.serialize(peticionREST.params));
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segRoboticsCases_GET',identificadorCaso,identificadorCaso,JSON.serialize(peticionREST.params));
        } catch (Exception e) {
            trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, '', e.getTypeName(), e.getMessage());
        }

        // Validar URI.
        if (bOk)
        {
            List<String> elemURI = RestContext.request.requestURI.split('/');
            if (elemURI.size() != 4)
            {
                bOk = false;
                resultadoWS.codigo = '9002';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = 'La URI del servicio no está bien formada';
            }else{
                identificadorCaso = elemURI[3];
            }
        }

        // Validar datos de entrada.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = SEG_wsRoboticsCasosGet.validarDatosEntradaGET (identificadorCaso);
            if (datosValidacionEntrada.get('resultado') != 'OK')
            {
                bOk = false;
                resultadoWS.resultado = datosValidacionEntrada.get('resultado');
                resultadoWS.codigo = datosValidacionEntrada.get('codigo');
                resultadoWS.mensaje = datosValidacionEntrada.get('mensaje');
            }
        }

        // Actualizar el caso si las validaciones se cumplen.
        if (bOk)
        {
            resultadoWS = SEG_wsRoboticsCasosGet.recuperarDatosCaso (identificadorCaso, recuperarCorreo, recuperarFicheros, extensionesFicheros);            
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
            trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(resultadoWS), e.getTypeName(), e.getMessage());
        }
        return resultadoWS;
    }
}