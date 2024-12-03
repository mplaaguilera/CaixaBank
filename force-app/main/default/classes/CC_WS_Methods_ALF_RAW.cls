public with sharing class CC_WS_Methods_ALF_RAW {
    
    /*
        Parsear respuesta vía HTTP Request.
    */
    
    //static public CC_WS_ALF_Cons_NP.outconsultapersonasws convertirRespuesta (String sXMLData)
    static public Map<String,Object> convertirRespuesta (String sXMLData)
    {        
        // Retorno método.
        Map<String,Object> oDataRes = new Map<String,Object>();

        // Cargar el XML.
        DOM.Document oDoc = new DOM.Document();
        oDoc.load(sXMLData);
        DOM.XmlNode oRoot = oDoc.getRootElement();        
        DOM.XmlNode oCuerpo;

        // Control de errores.
        Integer iError = 99;
        Boolean bFault = false;
        
        // Localizar el cuerpo de la respuesta tanto OK como KO.
        
        if (oRoot.getNodeType() == DOM.XMLNodeType.ELEMENT) 
        {
            if (oRoot.getName() == 'Envelope')  
            {               
                for (Dom.XMLNode oChild: oRoot.getChildElements()) 
                {
                    if (oChild.getNodeType() == DOM.XMLNodeType.ELEMENT) 
                    {
                            if (oChild.getName() == 'Body')
                            {
                                for (Dom.XMLNode oChild2: oChild.getChildElements())
                                {
                                    if (oChild2.getName()=='ConsultaPersonasResponse')
                                    {
                                        for (Dom.XMLNode ooChild: oChild2.getChildElements())
                                        {
                                            if (ooChild.getName()=='return')
                                            {
                                                // Encontramos body de respuesta ALF.
                                                iError = 0;
                                                oCuerpo = ooChild;

                                                // Indicar retorno OK.
                                                oDataRes.put('ESTADO','OK');
                                            }
                                        }
                                    }

                                    if (oChild2.getName() == 'Fault')
                                    {
                                        // Realizar gestión de error.
                                        bFault = true;

                                        // Tratar el string del XML para buscar el tipo de error FAULT.
                                        Integer iInicio = sXMLData.indexOf('<message>');
                                        Integer iFin = sXMLData.indexOf('</message>');
                                        String sEstado = sXMLData.substring(iInicio+9, iFin);

                                        oDataRes.put('ESTADO',sEstado);

                                        return oDataRes;
                                    }
                                }
                            }
                    }
                }
            }
        }

        // Control de error - Lanzar excepción custom.
        if (iError != 0)
        {
            oDataRes.put('ESTADO','Error no reconocido.');
            return oDataRes;
        }

        // Preparar estructura de datos de salida.
        CC_WS_ALF_Cons_NP.outconsultapersonasws oResp = new CC_WS_ALF_Cons_NP.outconsultapersonasws();
        CC_WS_ALF_Cons_NP.datosCabecera oDatosCabecera = new CC_WS_ALF_Cons_NP.datosCabecera();
        CC_WS_ALF_Cons_NP.datosPersona oDatosPersona = new CC_WS_ALF_Cons_NP.datosPersona();
        CC_WS_ALF_Cons_NP.datosNomPer oDatosNomPer = new CC_WS_ALF_Cons_NP.datosNomPer();
        CC_WS_ALF_Cons_NP.datosContacto oDatosCont = new CC_WS_ALF_Cons_NP.datosContacto();
        List<CC_WS_ALF_Cons_NP.email> oEmail = new List<CC_WS_ALF_Cons_NP.email>();
        List<CC_WS_ALF_Cons_NP.telefono> oTel = new List<CC_WS_ALF_Cons_NP.telefono>();
        CC_WS_ALF_Cons_NP.datosDomicilio oDatosDom = new CC_WS_ALF_Cons_NP.datosDomicilio();
        CC_WS_ALF_Cons_NP.domicilioFiscal oDatosDomFiscal = new CC_WS_ALF_Cons_NP.domicilioFiscal();
        CC_WS_ALF_Cons_NP.alertas oAlerta = new CC_WS_ALF_Cons_NP.alertas();
        Decimal dEmpGestor;
        List<CC_WS_ALF_Cons_NP.caracteristicas> oListaCaracteristicas = new List<CC_WS_ALF_Cons_NP.caracteristicas>();
        
        if (oCuerpo != null && iError == 0 && bFault == false)
        {
            for (Dom.XMLNode oChild: oCuerpo.getChildElements())
            {
                if (oChild.getNodeType() == DOM.XMLNodeType.ELEMENT)
                {
                    String sNodoName = oChild.getName();

                    if (sNodoName == 'datosCabecera')
                    {
                        for (Dom.XMLNode oChild2: oChild.getChildElements())
                        {
                            if (oChild2.getNodeType() == DOM.XMLNodeType.ELEMENT)
                            {                                
                                if (oChild2.getName() == 'tipoPersona')
                                {
                                    oDatosCabecera.tipoPersona = oChild2.getText();
                                }
                            }
                        }
                    }

                    if (sNodoName == 'datosPersona')
                    {
                        for (Dom.XMLNode oChild2: oChild.getChildElements())
                        {
                            if (oChild2.getNodeType() == DOM.XMLNodeType.ELEMENT)
                            {                                
                                if (oChild2.getName() == 'nombre')
                                {
                                    oDatosPersona.nombre = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'tipoIdentificador')
                                {
                                    oDatosPersona.tipoIdentificador = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'numeroIdFiscal')
                                {
                                    oDatosPersona.numeroIdFiscal = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'idioma')
                                {
                                    oDatosPersona.idioma = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'codiIdioma')
                                {
                                    oDatosPersona.codiIdioma = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'fechaNacimiento')
                                {
                                    oDatosPersona.fechaNacimiento = oChild2.getText();
                                }

                                if (oChild2.getName() == 'fechaDefuncion')
                                {
                                    oDatosPersona.fechaDefuncion = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'sexo')
                                {
                                    oDatosPersona.sexo = oChild2.getText();
                                }
                            }
                        }
                    }
                    
                    if (sNodoName == 'datosNomPer')
                    {
                        for (Dom.XMLNode oChild2: oChild.getChildElements())
                        {
                            if (oChild2.getNodeType() == DOM.XMLNodeType.ELEMENT)
                            {                                
                                if (oChild2.getName() == 'nombreDP')
                                {
                                    oDatosNomPer.nombreDP = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'particula1')
                                {
                                    oDatosNomPer.particula1 = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'apellido1')
                                {
                                    oDatosNomPer.apellido1 = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'particula2')
                                {
                                    oDatosNomPer.particula2 = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'apellido2')
                                {
                                    oDatosNomPer.apellido2 = oChild2.getText();
                                }
                            }
                        }
                    }
                    
                    if (sNodoName == 'datosDomicilio')
                    {
                        for (Dom.XMLNode oChild2: oChild.getChildElements())
                        {
                            if (oChild2.getNodeType() == DOM.XMLNodeType.ELEMENT)
                            {                                
                                if (oChild2.getName() == 'domicilioFiscal')
                                {
                                    for (Dom.XMLNode oChild3: oChild2.getChildElements())
                                    {
                                        if (oChild3.getNodeType() == DOM.XMLNodeType.ELEMENT)
                                        {                                            
                                            if (oChild3.getName() == 'codigoPostal')
                                            {
                                                oDatosDomFiscal.codigoPostal = oChild3.getText();
                                            }
                                            
                                            if (oChild3.getName() == 'direccion')
                                            {
                                                oDatosDomFiscal.direccion = oChild3.getText();
                                            }
                                            
                                            if (oChild3.getName() == 'pais')
                                            {
                                                oDatosDomFiscal.pais = oChild3.getText();
                                            }
                                        }
                                    }
                                    
                                    oDatosDom.domicilioFiscal = oDatosDomFiscal;
                                }
                            }
                        }
                    }
                    
                    if (sNodoName == 'alertas')
                    {
                        for (Dom.XMLNode oChild2: oChild.getChildElements())
                        {
                            if (oChild2.getNodeType() == DOM.XMLNodeType.ELEMENT)
                            {                                
                                if (oChild2.getName() == 'oficinaGestora')
                                {
                                    oAlerta.oficinaGestora = oChild2.getText();
                                }
                            }
                        }
                    }
                    
                    if (sNodoName == 'numEpleadoGestor')
                    {
                        dEmpGestor = Decimal.valueOf(oChild.getText());
                    }
                    
                    if (sNodoName == 'datosContacto')
                    {
                        for (Dom.XMLNode oChild2: oChild.getChildElements())
                        {
                            if (oChild2.getNodeType() == DOM.XMLNodeType.ELEMENT)
                            {                                
                                if (oChild2.getName() == 'listaTelefonos')
                                {
                                    CC_WS_ALF_Cons_NP.telefono oTel1 = new CC_WS_ALF_Cons_NP.telefono();
                                    
                                    for (Dom.XMLNode oChild3: oChild2.getChildElements())
                                    {
                                        if (oChild3.getNodeType() == DOM.XMLNodeType.ELEMENT)
                                        {                                            
                                            if (oChild3.getName() == 'numTelf')
                                            {
                                                oTel1.numTelf = oChild3.getText();
                                            }
                                            
                                            if (oChild3.getName() == 'personaContacto')
                                            {
                                                oTel1.personaContacto = oChild3.getText();
                                            }
                                            
                                            if (oChild3.getName() == 'claseTelf')
                                            {
                                                oTel1.claseTelf = oChild3.getText();
                                            }
                                            
                                            if (oChild3.getName() == 'tipoTelf')
                                            {
                                                oTel1.tipoTelf = oChild3.getText();
                                            }
                                            
                                            if (oChild3.getName() == 'prefijo')
                                            {
                                                oTel1.prefijo = oChild3.getText();
                                            }
                                        }
                                    }
                                    
                                    oTel.add(oTel1);
                                }
                                
                                if (oChild2.getName() == 'listaEmails')
                                {
                                    CC_WS_ALF_Cons_NP.email oMail1 = new CC_WS_ALF_Cons_NP.email();
                                    
                                    for (Dom.XMLNode oChild3: oChild2.getChildElements())
                                    {
                                        if (oChild3.getNodeType() == DOM.XMLNodeType.ELEMENT)
                                        {                                            
                                            if (oChild3.getName() == 'claseEmail')
                                            {
                                                oMail1.claseEmail = oChild3.getText();
                                            }
                                            
                                            if (oChild3.getName() == 'email')
                                            {
                                                oMail1.email = oChild3.getText(); 
                                            }
                                            
                                            if (oChild3.getName() == 'perconta')
                                            {
                                                oMail1.perconta = oChild3.getText();
                                            }
                                        }
                                    }
                                    
                                    oEmail.add(oMail1);
                                }
                            }
                        }
                    }

                    if (sNodoName == 'listaCaracteristicas')
                    {
                        // Viene una característica informada.

                        CC_WS_ALF_Cons_NP.caracteristicas oCaracteristica = new CC_WS_ALF_Cons_NP.caracteristicas();

                        for (Dom.XMLNode oChild2: oChild.getChildElements())
                        {
                            if (oChild2.getNodeType() == DOM.XMLNodeType.ELEMENT)
                            {                                
                                if (oChild2.getName() == 'codigoSenyal')
                                {
                                    oCaracteristica.codigoSenyal = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'descripcion')
                                {
                                    oCaracteristica.descripcion = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'idSenyal')
                                {
                                    oCaracteristica.idSenyal = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'motiu')
                                {
                                    oCaracteristica.motiu = oChild2.getText();
                                }
                                
                                if (oChild2.getName() == 'tipoSenyal')
                                {
                                    oCaracteristica.tipoSenyal = oChild2.getText();
                                }
                            }
                        }

                        oListaCaracteristicas.add(oCaracteristica);
                    }
                }
            }
            
            oResp.datosCabecera = oDatosCabecera;
            oResp.datosPersona = oDatosPersona;
            oResp.datosNomPer = oDatosNomPer;
            oDatosCont.listaEmails = oEmail;
            oDatosCont.listaTelefonos = oTel;
            oResp.datosContacto = oDatosCont;
            oResp.datosDomicilio = oDatosDom;
            oResp.alertas = oAlerta;
            oResp.numEpleadoGestor = dEmpGestor;
            oResp.listaCaracteristicas = oListaCaracteristicas;

            // Incorporar retorno.
            oDataRes.put('RETORNO', oResp);
        }

        return oDataRes;
    }

    /*
        Llamada HTTP a Alfabético.
    */
    static public Map<String,Object> getHttpALF (CC_InterfaceSettings__mdt oConfig, String sNumPerso, String sIdOrig)
    {
        Map<String,Object> oMap = new Map<String,Object>();
        Map<String,Object> oDataRes = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        String sXMLEntrada = oConfig.CC_Body__c;
        CC_WS_ALF_Cons_NP.outconsultapersonasws oRetorno;
        Boolean bConfidencial = false;
        
        sXMLEntrada = sXMLEntrada.replace('##NumPer##', sNumPerso);

        // Gestión trazas.
        if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
        {
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'ALFABETICO_HTTP';
            oTraza.CC_Identificador__c = sNumPerso;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = sIdOrig;

            if (oConfig.CC_TrazaEntrada__c)
                oTraza.CC_MensajeEntrada__c = sXMLEntrada;
        }

        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HTTPResponse res;
        String sSalida = '';
        String sRetPet = '';

        try {
            request.setTimeOut(Integer.valueOf(oConfig.CC_TimeOut__c));   
            request.setMethod(oConfig.CC_TipoPeticion__c);   
            request.setHeader('Content-Type', oConfig.CC_ContentType__c);
            request.setHeader('Content-Length',''+sXMLEntrada.length());
            if (!Test.isRunningTest())
            	request.setClientCertificateName(oConfig.CC_Certificado__c);
            request.setEndpoint(oConfig.CC_EndPoint__c);
            request.setbody(sXMLEntrada);
            res = http.send(request);

            sSalida = res.getBody();
            sRetPet = res.getStatus() + ' (' + res.getStatusCode() + ').';

 /*           if (res.getStatusCode() != 200) {
                sDescError = 'Error petición.';
                sDetalleError = res.getStatus() + ' (' + res.getStatusCode() + ')';

                // Gestionar el error para los clientes confidenciales.
                if (oConfig.CC_CliConfiErr__c)
                {
                // Cualquier error marca el cliente como confidencial.
                    bConfidencial = true;
                }

            }else{
                sSalida = res.getBody();
            }
*/
        }catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();

            // Gestionar el error para los clientes confidenciales.
            if (oConfig.CC_CliConfiErr__c)
            {
                // Cualquier error marca el cliente como confidencial.
                bConfidencial = true;
            }
        }

        // Convertir respuesta.
        try {
            if (sDescError == '')
            {
                //oRetorno = convertirRespuesta (sSalida);
                oDataRes = convertirRespuesta (sSalida);

                String sEstado = (String)oDataRes.get('ESTADO');
                if (sEstado == 'OK')
                {
                    oRetorno = (CC_WS_ALF_Cons_NP.outconsultapersonasws)oDataRes.get('RETORNO');
                }else{

                    // Error al tratar la respuesta.
                    sDescError = 'Respuesta con error (SOAP:FAULT)';
                    sDetalleError = (String)oDataRes.get('ESTADO');

                    // Gestionar el error para los clientes confidenciales.
                    if (oConfig.CC_CliConfiErr__c)
                    {
                        // Cualquier error marca el cliente como confidencial.
                        bConfidencial = true;
                    }else{

                        // Buscar si el error se ha de tratar como confidencial.
                        if (oConfig.CC_ALF_CliConf__c != null)
                        {
                            if (oConfig.CC_ALF_CliConf__c.contains(sDetalleError))
                            {
                                bConfidencial = true;
                            }
                        }
                    }

                    sDetalleError = sRetPet + ' ' + sDetalleError;
                }

            }
        } catch (Exception e) {

            // Gestionar el error para los clientes confidenciales.
            if (oConfig.CC_CliConfiErr__c)
            {
                // Cualquier error marca el cliente como confidencial.
                bConfidencial = true;
            }

            // Error tratamiento respuesta.
            sDescError = 'Respuesta inválida';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if ((oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
        {
            oTraza.CC_FechaFin__c = datetime.now();

            if ((oConfig.CC_TrazaSalida__c || Test.isRunningTest()) && sSalida != '')
                oTraza.CC_MensajeSalida__c = sSalida;

            if (sDescError != '')
            {
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }
        }

        // Preparar retorno.
        if (oTraza != null)
            oMap.put('TRAZA', oTraza);

        oMap.put('RETORNO', oRetorno);
        oMap.put('CONFIDENCIAL', bConfidencial);

       

        return oMap;
    }

   /*
        Llamada WSDL a Alfabético.
    */
    static public Map<String,Object> getAP2WSDLALF (CC_InterfaceSettings__mdt oConfig, String sNumPerso, String sIdOrig)
    {
        Map<String,Object> oMap = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        CC_WS_ALF_Cons_NP.outconsultapersonasws oRetorno;
        Boolean bConfidencial = false;

        CC_WS_ALF_Cons_NP.inconsultapersonasws oIn = new CC_WS_ALF_Cons_NP.inconsultapersonasws();
        oIn.numeroPersona = sNumPerso;

        // Gestión trazas.
        if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
        {
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'ALFABETICO_AP2WSDL';
            oTraza.CC_Identificador__c = sNumPerso;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = sIdOrig;

            if (oConfig.CC_TrazaEntrada__c)
                oTraza.CC_MensajeEntrada__c = String.valueOf(oIn);
        }


        try {
            CC_WS_ALF_Cons_NP.AlfabeticPersonaWsPortTypePort oWS = new CC_WS_ALF_Cons_NP.AlfabeticPersonaWsPortTypePort();

            if (!Test.isRunningTest())
                oWS.clientCertName_x = oConfig.CC_Certificado__c;

            oWS.timeout_x = Integer.valueOf(oConfig.CC_TimeOut__c);
            oWS.endpoint_x = oConfig.CC_EndPoint__c;

            oRetorno = oWS.ConsultaPersonas(oIn);
        }catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();

            // Tratar confidencial. No sabemos el tipo de error con el Apex2WSDL
            bConfidencial = true;
        }

        // Finalizar traza.
        if ( (oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
        {
            oTraza.CC_FechaFin__c = datetime.now();

            if ((oConfig.CC_TrazaSalida__c || Test.isRunningTest()) && oRetorno != null)
                oTraza.CC_MensajeSalida__c = String.valueOf(oRetorno);

            if (sDescError != '')
            {
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }
        }

        // Preparar retorno.
        if (oTraza != null)
            oMap.put('TRAZA', oTraza);

        oMap.put('RETORNO', oRetorno);
        oMap.put('CONFIDENCIAL', bConfidencial);

        return oMap;
    }

   /*
        Llamada WSDL a Alfabético por identificador de RRSS.
    */
    static public Map<String,Object> getAP2WSDL_ALF_RRSS (CC_InterfaceSettings__mdt oConfig, String sRRSSId, String sIdOrig, String sCanalRRSS)
    {
        Map<String,Object> oMap = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        CC_WS_ALF_RRSS.toredsocialsalidasi oRetorno;

        // Preparar consulta por RRSS.
        CC_WS_ALF_RRSS.continuacio oCont = new CC_WS_ALF_RRSS.continuacio();
        oCont.numPerCon = 0;
        oCont.prioriCo = 0;

        CC_WS_ALF_RRSS.dadCons oCons = new CC_WS_ALF_RRSS.dadCons();
        oCons.idEntra = sRRSSId;
        oCons.priorIdent = 0;
        oCons.nuMaxRet = 10;
        oCons.continuacio = oCont;

        List<CC_WS_ALF_RRSS.datXarxesItem> oListXar = new List<CC_WS_ALF_RRSS.datXarxesItem>();
        CC_WS_ALF_RRSS.datXarxesItem oXar = new CC_WS_ALF_RRSS.datXarxesItem();
        oXar.estat = 0;
        oXar.perCont = '0';
        oXar.priorida = 0;
        //oXar.tipRed = 12; --> No indicamos que tipo de RRSS por ahora. Preguntar valores.
        oListXar.add(oXar);

        CC_WS_ALF_RRSS.dadModi oMod = new CC_WS_ALF_RRSS.dadModi();
        oMod.numEle = 0;
        oMod.datXarxes = oListXar;

        CC_WS_ALF_RRSS.toredsocialentradasi oIn = new CC_WS_ALF_RRSS.toredsocialentradasi();
        oIn.codAccio = 'C';
        oIn.empresa = 1;
        oIn.numPerso = 0;
        oIn.dadCons = oCons;
        oIn.dadModi = oMod;

        // Gestión trazas.
        if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
        {
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'ALFABETICO_RRSS_AP2WSDL';
            oTraza.CC_Identificador__c = sRRSSId + '##' + sCanalRRSS;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = sIdOrig;

            if (oConfig.CC_TrazaEntrada__c)
                oTraza.CC_MensajeEntrada__c = String.valueOf(oIn);
        }


        try {
            CC_WS_ALF_RRSS.RedesSocialesPortTypePort oWS = new CC_WS_ALF_RRSS.RedesSocialesPortTypePort();

            if (!Test.isRunningTest())
                oWS.clientCertName_x = oConfig.CC_Certificado__c;

            oWS.timeout_x = Integer.valueOf(oConfig.CC_TimeOut__c);
            oWS.endpoint_x = oConfig.CC_EndPoint__c;

            oRetorno = oWS.GestionRedSocial(oIn);

            // RETORNAR LA INFORMACIÓN DE NUMPERSO ENCONTRADA.

        }catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if ( (oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
        {
            oTraza.CC_FechaFin__c = datetime.now();

            if ((oConfig.CC_TrazaSalida__c || Test.isRunningTest()) && oRetorno != null)
                oTraza.CC_MensajeSalida__c = String.valueOf(oRetorno);

            if (sDescError != '')
            {
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }
        }

        // Preparar retorno.
        if (oTraza != null)
            oMap.put('TRAZA', oTraza);

        oMap.put('RETORNO', oRetorno);

        return oMap;
    }

   /*
        Llamada WSDL a Alfabético por identificador de RRSS.
    */
    static public Map<String,Object> getAP2WSDL_ALF_DOC (CC_InterfaceSettings__mdt oConfig, String sDocId, String sTipoReg, String sIdOrig)
    {
        Map<String,Object> oMap = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';

        CC_WS_ALF_SearchDP.outbuspersonadatospersonalesws oRetorno;

        // Preparar consulta por Documento de identidad.
        CC_WS_ALF_SearchDP.inbuspersonadatospersonalesws oIn = new CC_WS_ALF_SearchDP.inbuspersonadatospersonalesws();

        if (sTipoReg == 'DATADOC')
        {
            oIn.nif = sDocId;
        }else if (sTipoReg == 'DATATEL') {
            oIn.telefono = sDocId;
        }

        // Gestión trazas.
        if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
        {
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'ALFABETICO_DOC_AP2WSDL';
            oTraza.CC_Identificador__c = sDocId;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = sIdOrig;

            if (oConfig.CC_TrazaEntrada__c)
                oTraza.CC_MensajeEntrada__c = String.valueOf(oIn);
        }

        try {
            CC_WS_ALF_SearchDP.BuscadorPersonaWsPortTypePort oWS = new CC_WS_ALF_SearchDP.BuscadorPersonaWsPortTypePort();

            if (!Test.isRunningTest())
                oWS.clientCertName_x = oConfig.CC_Certificado__c;

            oWS.timeout_x = Integer.valueOf(oConfig.CC_TimeOut__c);
            oWS.endpoint_x = oConfig.CC_EndPoint__c;

            oRetorno = oWS.BusquPersPorDP(oIn);

            // RETORNAR LA INFORMACIÓN DE NUMPERSO ENCONTRADA.

        }catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if ( (oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
        {
            oTraza.CC_FechaFin__c = datetime.now();

            if ((oConfig.CC_TrazaSalida__c || Test.isRunningTest()) && oRetorno != null)
                oTraza.CC_MensajeSalida__c = String.valueOf(oRetorno);

            if (sDescError != '')
            {
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }
        }

        // Preparar retorno.
        if (oTraza != null)
            oMap.put('TRAZA', oTraza);

        oMap.put('RETORNO', oRetorno);

        return oMap;
    }

   /*
        Llamada WSDL a Alfabético para obtener los representantes de personas jurídicas.
    */
    static public Map<String,Object> getAP2WSDL_ALF_Representantes_Juridico (CC_InterfaceSettings__mdt oConfig, String sIdCliente, String sIdOrig)
    {
        Map<String,Object> oMap = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';

        CC_GestionBastanteoALF.outextconslistarepre oRetorno;

        // Preparar consulta de representantes.
        CC_GestionBastanteoALF.inextconslistarepre oIn = new CC_GestionBastanteoALF.inextconslistarepre();
        oIn.empresa = 1;
        oIn.invocadoPor = 'EPC';
        oIn.numperso = Decimal.valueOf(sIdCliente);
        oIn.opcionAut = 'LI';

        // Gestión trazas.
        if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
        {
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'ALF_REP_JURIDICO_AP2WSDL';
            oTraza.CC_Identificador__c = sIdCliente;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = sIdOrig;

            if (oConfig.CC_TrazaEntrada__c)
                oTraza.CC_MensajeEntrada__c = String.valueOf(oIn);
        }

        try {
            CC_GestionBastanteoALF.BastanteoPortTypePort oWS = new CC_GestionBastanteoALF.BastanteoPortTypePort();

            if (!Test.isRunningTest())
                oWS.clientCertName_x = oConfig.CC_Certificado__c;

            oWS.timeout_x = Integer.valueOf(oConfig.CC_TimeOut__c);
            oWS.endpoint_x = oConfig.CC_EndPoint__c;

            oRetorno = oWS.ConsListaRepre(oIn);

            // RETORNAR LA INFORMACIÓN DE NUMPERSO ENCONTRADA.

        }catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if ( (oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
        {
            oTraza.CC_FechaFin__c = datetime.now();

            if ((oConfig.CC_TrazaSalida__c || Test.isRunningTest()) && oRetorno != null)
                oTraza.CC_MensajeSalida__c = String.valueOf(oRetorno);

            if (sDescError != '')
            {
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }
        }

        // Preparar retorno.
        if (oTraza != null)
            oMap.put('TRAZA', oTraza);

        oMap.put('RETORNO', oRetorno);

        return oMap;
    }

   /*
        Llamada WSDL a Alfabético para obtener los representantes de personas físicas.
    */
/*
    static public Map<String,Object> getAP2WSDL_ALF_Representantes_Fisicas (CC_InterfaceSettings__mdt oConfig, String sEmpresa, String sArea, String sOficina, String sContrato, String sNumPer, String sIdOrig)
    {
        Map<String,Object> oMap = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';

        CC_GestionPersRelacionadas.outextconsultapers oRetorno;

        // Preparar consulta de representantes.
        CC_GestionPersRelacionadas.inextconsultapers oIn = new CC_GestionPersRelacionadas.inextconsultapers();
        CC_GestionPersRelacionadas.dadesComuns oDadesComuns = new CC_GestionPersRelacionadas.dadesComuns();
        CC_GestionPersRelacionadas.filtres oFiltres = new CC_GestionPersRelacionadas.filtres();
        CC_GestionPersRelacionadas.tipoRelacion oTipoRel = new CC_GestionPersRelacionadas.tipoRelacion();
        List<CC_GestionPersRelacionadas.tipoRel> oMatrizTipoRel = new List<CC_GestionPersRelacionadas.tipoRel>();

        // Sección datos comunes petición.
        oDadesComuns.empresa = Decimal.valueOf(sEmpresa);
        oDadesComuns.alfarea = Decimal.valueOf(sArea);
        oDadesComuns.oficina = Decimal.valueOf(sOficina);
        oDadesComuns.contrato = Decimal.valueOf(sContrato);
        oDadesComuns.modalit = 2;
        oDadesComuns.submoda = 0;

        // Sección datos filtros petición.
        CC_GestionPersRelacionadas.tipoRel oMatrizDatos = new CC_GestionPersRelacionadas.tipoRel();
        oMatrizDatos.tiprel = 12;
        oMatrizTipoRel.add(oMatrizDatos);

        oTipoRel.numtiprel = 1;
        oTipoRel.matriuTipoRel = oMatrizTipoRel;

        oFiltres.numrelac = 0;
        oFiltres.ordrel = 0;
        oFiltres.tipoRelacion = oTipoRel;

        oIn.dadesComuns = oDadesComuns;
        oIn.filtres = oFiltres;

        // Gestión trazas.
        if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
        {
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'ALF_REP_FISICA_AP2WSDL';
            oTraza.CC_Identificador__c = sNumPer + '_' + sContrato;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = sIdOrig;

            if (oConfig.CC_TrazaEntrada__c)
                oTraza.CC_MensajeEntrada__c = String.valueOf(oIn);
        }

        try {
            CC_GestionPersRelacionadas.ConsultaPersPortTypePort oWS = new CC_GestionPersRelacionadas.ConsultaPersPortTypePort();

            if (!Test.isRunningTest())
                oWS.clientCertName_x = oConfig.CC_Certificado__c;

            oWS.timeout_x = Integer.valueOf(oConfig.CC_TimeOut__c);
            oWS.endpoint_x = oConfig.CC_EndPoint__c;

            oRetorno = oWS.ConsultaPersRel(oIn);

            // RETORNAR LA INFORMACIÓN DE NUMPERSO ENCONTRADA.

        }catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if ( (oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
        {
            oTraza.CC_FechaFin__c = datetime.now();

            if ((oConfig.CC_TrazaSalida__c || Test.isRunningTest()) && oRetorno != null)
                oTraza.CC_MensajeSalida__c = String.valueOf(oRetorno);

            if (sDescError != '')
            {
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }
        }

        // Preparar retorno.
        if (oTraza != null)
            oMap.put('TRAZA', oTraza);

        oMap.put('RETORNO', oRetorno);

        return oMap;
    }
*/    
}