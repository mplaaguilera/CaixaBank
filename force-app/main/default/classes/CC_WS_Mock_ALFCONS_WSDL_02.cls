@isTest
global class CC_WS_Mock_ALFCONS_WSDL_02 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {

            List<CC_WS_ALF_SearchDP.datosCliente> oListDosCli = new List<CC_WS_ALF_SearchDP.datosCliente>();

            CC_WS_ALF_SearchDP.datosCliente oCli = new CC_WS_ALF_SearchDP.datosCliente();

            oCli.domicilio = 'x';
            oCli.edad = 'x';
            oCli.empresa = 'x';
            oCli.fechaCancelacion = 'x';
            oCli.fechaDefuncion = 'x';
            oCli.fechaNacimiento = 'x';
            oCli.horaCancelacion = 'x';
            oCli.idCliente = 'x';
            oCli.idioma = 'x';
            oCli.indicadorCim = 'x';
            oCli.indicadorContratosCancelados = 'x';
            oCli.indicadorFirmaDigitalizada = 'x';
            oCli.indicadorOficinaConfidencial = 'x';
            oCli.indicadorRelacionCancelada = 'x';
            oCli.nombre = 'x';
            oCli.numper = '999910559714';
            oCli.numpers = '999910559714';
            oCli.oficinaConfidencial = 'x';
            oCli.oficinaGestora = 'x';
            oCli.ordenRelacion = 'x';
            oCli.personaConfidencial = 'x';
            oCli.poblacion = 'x';
            oCli.telefono1 = 'x';
            oCli.telefono2 = 'x';
            oCli.tipoDocumento = 'x';
            oCli.tipoPersona = 'x';
            oCli.tipoRelacion = 'x';
            oCli.tipoTelefono1 = 'x';
            oCli.tipoTelefono2 = 'x';

            oListDosCli.add(oCli);

            CC_WS_ALF_SearchDP.outbuspersonadatospersonalesws oResp = new CC_WS_ALF_SearchDP.outbuspersonadatospersonalesws();
            oResp.cliente = 'x';
            oResp.codigoError = '0';
            oResp.contrato = null;
            oResp.contratoAhorroVinculado = 'x';
            oResp.contratoBuscado = 'x';
            oResp.datosContinuacion = null;
            oResp.datosEnvioFicha = 'x';
            oResp.descripcion = 'x';
            oResp.hayDatos = 'x';
            oResp.indicadorContinuacion = 'x';
            oResp.isInicio = 'x';
            oResp.nif = 'x';
            oResp.noCliente = 'x';
            oResp.numeroPersonas = 'x';
            oResp.numper = 'x';
            oResp.parametrosPag = 'x';
            oResp.volver = 'x';
            oResp.datosClientes = oListDosCli;
                   
            CC_WS_ALF_SearchDP.BusquPersPorDPResponse response_x = new CC_WS_ALF_SearchDP.BusquPersPorDPResponse();
            response_x.return_x = oResp;
            response.put('response_x', response_x);
                   
			
       }
    }