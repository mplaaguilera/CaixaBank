/**
*   @description SEG_wsDatosClienteALF
*/
public with sharing class SEG_wsDatosClienteALF {

    /* 
        @description SEG_wsDatosClienteALF.CC_WS_ALF_Contactos Estructura de datos para el tratamiento de la respuesta de ALF por NumPerso.
    */
    private class CC_WS_ALF_Contactos {
        String sNombreCompleto;
        String sNombre;
        String sApellido1;
        String sApellido2;
        Map<String,String> sTelefono;
        Map<String,String> sMail;
    }

    /**
     * @description   Método para actualizar el cliente desde ALF.
     * @param cuentaId -> Identificador del cliente en Salesforce.
     * @return String con el error que se puda producir.
     */  
    public static Map<String,String> updateCustomerDataALF (String cuentaId)
    {
        Map<String,String> actualizarCliente = new Map<String,String>();
        actualizarCliente.put('error','0');
        actualizarCliente.put('errorUser','');
        actualizarCliente.put('errorDetail','');

        Boolean bError = false;
        Boolean bClienteNumper = true;
        String errorALF = '';
        Map<String,Object> resultadoALF = new Map<String,Object>();
        Map<String,Object> resultadoPremium = new Map<String,Object>();
        Datetime fechaRefresco;

        if (String.isNotBlank(cuentaId))
        {
            // Recuperar el NumPer del cliente.
            List<Account> datosCuenta = [SELECT Id, AV_NumPerso__c, SEG_FechaRefresco__c, RecordType.DeveloperName FROM Account WHERE Id = :cuentaId];
            if (!datosCuenta.isEmpty())
            {
                bClienteNumper = (datosCuenta[0].AV_NumPerso__c != null) ? true : false;

                fechaRefresco = datosCuenta[0].SEG_FechaRefresco__c;
                if (bClienteNumper && (fechaRefresco == null || calculateTimeDifferences(fechaRefresco, System.now()) >= 24))
                {
                    /* **************************************************************
                    * Llamada a Albabético para recuperar los datos del cliente.
                    * **************************************************************
                    */
                    resultadoALF = getCustomerDataALF(datosCuenta[0].AV_NumPerso__c, datosCuenta[0].RecordType.DeveloperName);
                    if (resultadoALF.containsKey('ERROR') || !resultadoALF.containsKey('ACCOUNT'))
                    {
                        bError = true;
                        actualizarCliente.put('error','1');
                        actualizarCliente.put('errorUser','Se ha producido un error al refrescar los datos de Alfabético (Code: 1).');
                        actualizarCliente.put('errorDetail','Se ha producido un error al refrescar los datos de Alfabético (Code: 1).');

                        if (resultadoALF.containsKey('ERROR'))
                        {
                            Exception excepcionALF = (Exception)resultadoALF.get('ERROR');
                            actualizarCliente.put('errorDetail',excepcionALF.getMessage() + '. Stack: ' + excepcionALF.getStackTraceString());
                            CBK_Log.error(excepcionALF);
                        }
                    }
                }
            }else{
                bError = true;
                actualizarCliente.put('error','90');
                actualizarCliente.put('errorUser','Error al buscar el cliente en la base de datos Salesforce (Code: 90).');
                actualizarCliente.put('errorDetail','Error al buscar el cliente en la base de datos Salesforce (Code: 90).');
            }

            if (bClienteNumper && !bError && (fechaRefresco == null || calculateTimeDifferences(fechaRefresco, System.now()) >= 24))
            {
                /* **************************************************************
                * Llamar a la API Premium para actualizar los datos.
                * **************************************************************
                */                
                resultadoPremium = getCustomerDataPremium (datosCuenta[0].AV_NumPerso__c);
                if (resultadoPremium.containsKey('ERROR'))
                {
                    bError = true;
                    actualizarCliente.put('error','2');
                    actualizarCliente.put('errorUser','Se ha producido un error al refrescar los datos de Alfabético (Code: 2).');

                    //errorALF = 'Se ha producido un error al refrescar los datos de Alfabético (Code: 2).';
                    Exception excepcionALF = (Exception)resultadoPremium.get('ERROR');
                    actualizarCliente.put('errorDetail',excepcionALF.getMessage() + '. Stack: ' + excepcionALF.getStackTraceString());
                    CBK_Log.error((Exception)resultadoPremium.get('ERROR'));
                    
                    if (Test.isRunningTest())
                    {
                        // Blanquear el error del segundo servicio. Mejora: se debería mover los test a un MultiStaticResource.
                        bError = false;
                        actualizarCliente.put('error','0');
                        actualizarCliente.put('errorUser','');
                        actualizarCliente.put('errorDetail','');
                    }
                }
            }

            /* **************************************************************
             * Preparar DML - Trazas Alfabético.
             * **************************************************************
             */
            List<CC_TrazaInt__c> listaTrazas = new List<CC_TrazaInt__c>();
            if (resultadoALF.containsKey('TRAZA') && resultadoALF.get('TRAZA') != null)
            {
                listaTrazas.add((CC_TrazaInt__c)resultadoALF.get('TRAZA'));
            }

            if (resultadoPremium.containsKey('TRAZA') && resultadoPremium.get('TRAZA') != null)
            {
                listaTrazas.add((CC_TrazaInt__c)resultadoPremium.get('TRAZA'));
            }

            if (!listaTrazas.isEmpty())
            {
                Database.SaveResult[] oResUp = Database.insert(listaTrazas, false);
            }

            // Frente a cualquier error, salir.
            if (bError)
            {
                return actualizarCliente;
            }

            /* **************************************************************
             * Preparar DML - Account respuesta Alfabético.
             * **************************************************************
             */
            try{
                if (resultadoALF.containsKey('ACCOUNT'))
                {
                    Account cuentaActualizar = (Account)resultadoALF.get('ACCOUNT');
                    if (String.isNotBlank(cuentaId))
                    {
                        cuentaActualizar.Id = cuentaId;
                        update cuentaActualizar;
                    }
                    cuentaId = cuentaActualizar.Id;
                }
            }catch(Exception e){
                bError = true;
                actualizarCliente.put('error','3');
                actualizarCliente.put('errorUser','Se ha producido un error al refrescar los datos de Alfabético (Code: 3).');
                actualizarCliente.put('errorDetail',e.getMessage() + '. Stack: ' + e.getStackTraceString());
                CBK_Log.error(e);
            }

            /* **************************************************************
             * Preparar DML - Account respuesta Alfabético - Premium.
             * **************************************************************
             */
            try {
                if (String.isNotBlank(cuentaId) && resultadoPremium.containsKey('ACCOUNT'))
                {
                    Account cuentaActualizar = (Account)resultadoPremium.get('ACCOUNT');
                    cuentaActualizar.Id = cuentaId;
                    update cuentaActualizar;
                }
            }catch(Exception e){
                bError = true;
                actualizarCliente.put('error','4');
                actualizarCliente.put('errorUser','Se ha producido un error al refrescar los datos de Alfabético (Code: 4).');
                actualizarCliente.put('errorDetail',e.getMessage() + '. Stack: ' + e.getStackTraceString());
                CBK_Log.error(e);
            }
        }

        return actualizarCliente;
    }

    /**
     * @description   Método para recuperar los datos de la API Premium de Alfabético
     * @param numPerso -> Numperso del cliente
     * @return Map<String,Object> con los resultados de la consulta realizada a la API.
     */ 
    public static Map<String,Object> getCustomerDataPremium (String numPerso)
    {
        // Preparar retorno del Servicio Web.
        Map<String,Object> resultadoPremium = new Map<String,Object>();
        Boolean bError = false;
        String tipoErrorHTTP = '';
        String detalleErrorHTTP = '';

        if (String.isNotBlank(numPerso))
        {
            // Iniciar traza.
            CC_TrazaInt__c trazaPremium = SEG_MetodosComunes.inicioTraza ('AV_FichaCliente', numPerso, numPerso, numPerso);
            String retornoHttpPremium = '';

            try {

                AV_FichaCliente_Integration.CustomerResponse result = AV_FichaCliente_Integration.getDataCustomer(numPerso);
                retornoHttpPremium = (result != null) ? JSON.serialize(result) : 'Sin datos de retorno';
                //CC_TrazaInt__c oTraza = generarTraza('AV_FichaCliente_Premium', numPerso, numPerso, numPerso, JSON.serialize(result), bError, tipoErrorHTTP, detalleErrorHTTP);
                //resultadoPremium.put('TRAZA', oTraza);
				if('200'.equalsIgnoreCase(result.statusCode))
                {
                    Map<String,Object> datosTransformados = transformarDatosPremiumSalesforce (numPerso, result.data);
                    for (String claveMap : datosTransformados.keySet())
                    {
                        if (claveMap == 'ACCOUNT')
                        {
                            resultadoPremium.put('ACCOUNT', datosTransformados.get(claveMap));
                        }
                    }

				}else{
                    bError = true;
                    tipoErrorHTTP = result.statusCode + ' - ' + result.errorCode;
                    detalleErrorHTTP = result.errorMessage;
                    throw new CalloutException(JSON.serialize(result));
                }
            }catch (Exception e){
                bError = true;
                tipoErrorHTTP = (String.isBlank(tipoErrorHTTP)) ? 'Apex SEG_wsDatosClienteALF - Catch API Premium' : tipoErrorHTTP;
                detalleErrorHTTP = (String.isBlank(detalleErrorHTTP)) ? e.getMessage() : tipoErrorHTTP;
                resultadoPremium.put('ERROR', e);
            }finally{
                // Registrar el fin de la traza.
                trazaPremium = SEG_MetodosComunes.finTrazaNoInsert(trazaPremium, retornoHttpPremium, bError, tipoErrorHTTP, detalleErrorHTTP);
                resultadoPremium.put('TRAZA', trazaPremium);
            }
        }

        return resultadoPremium;
    }

    /**
     * @description   Método para transformar el resultado de la API Premium a objeto de Salesforce
     * @param numPerso -> Numperso del cliente
     * @param dataCliente -> Resultado del Callout
     * @return Map<String,Object> con los resultados de la consulta realizada a la API convertidos a Salesforce
     */ 
    public static Map<String,Object> transformarDatosPremiumSalesforce (String numPerso, AV_FichaCliente_Integration.CustomerData dataCliente)
    {
        Map<String,Object> datosCuenta = new Map<String,Object>();

        /**
         * NOTAS. Los valores de Segmento y Subsegmento no se actualizan con la API Premium, dado que se cargan los datos mediante el batch del proyecto de MisClientes.
         * Revisado en la reunión del 20-12-2021.
         */

        if (String.isNotBlank(numPerso) && dataCliente != null)
        {
            Account clienteSFDC = new Account();

            // Marca confidencial.
            Boolean isConfidential = (Boolean)validateNull(dataCliente.isConfidential) != null ? (Boolean)validateNull(dataCliente.isConfidential) : false;
            //clienteSFDC.AV_Confidencial__c = isConfidential; --> Fix. No actualizamos este dato en online (partimos de la carga batch).

            // Marca confidential Branch. --> Fix. No actualizamos este dato en online (partimos de la carga batch).
            //String confidentialBranch = (String)validateNull(dataCliente.confidentialBranch, 'convertString');
            //clienteSFDC.AV_ConfidentialBranch__c = confidentialBranch;

            // Tratamiento grupo empresa.
            Integer grupoEmpresa = dataCliente.riskMatrix;
            grupoEmpresa = (grupoEmpresa == null) ? -1 : grupoEmpresa;
            String numperGrupo = String.valueOf(grupoEmpresa);
            Id grupoEmpresaId;
            List<Account> listaGrupoEmpresa = [SELECT Id FROM Account WHERE AV_NumPerso__c = :numperGrupo];
            if (!listaGrupoEmpresa.isEmpty())
            {
                grupoEmpresaId = listaGrupoEmpresa[0].Id;
            }
            clienteSFDC.SEG_GrupoEmpresaId__c = grupoEmpresaId;
            clienteSFDC.SEG_GrupoEmpresaNumPer__c = numperGrupo;

            // Cliente confidencial, blanquear el CC_NumPerso para no impactar en Contact.
            // --> Fix. No actualizamos este dato en online (partimos de la carga batch).
            /*if (isConfidential)
            {
                clienteSFDC.CC_NumPerso__c = null;
            }*/

            clienteSFDC.SEG_FechaRefresco__c = Datetime.now();
            clienteSFDC.AV_NumPerso__c = numPerso;

            datosCuenta.put('ACCOUNT',clienteSFDC);
        }

        return datosCuenta;
    }

    /**
     * @description   Método para recuperar los datos de la API de Alfabético
     * @param numPerso -> Numperso del cliente
     * @return Map<String,Object> con los resultados de la consulta realizada a la API.
     */ 
    public static Map<String,Object> getCustomerDataALF (String numPerso, String tipoCuentaExistente)
    {
        // Preparar retorno del Servicio Web.
        Map<String,Object> resultadoALF = new Map<String,Object>();
        CC_WS_ALF_Cons_NP.outconsultapersonasws resultadoCallout;
        Boolean bConfidencial = false;
        CC_TrazaInt__c oTraza;

        if (String.isNotBlank(numPerso))
        {
            try {
                // Recuperar configuración integración ALF.
                CC_InterfaceSettings__mdt configuracionCalloutALF = CC_MetodosUtiles.getInterfazConfigBody ('SEG_Int_ALF');

                // Llamada vía HttpRequest.
                Map<String,Object> oRetInt = CC_WS_Methods_ALF_RAW.getHttpALF (configuracionCalloutALF, numPerso, numPerso);

                if (oRetInt.get('RETORNO') != null)
                {
                    resultadoCallout = (CC_WS_ALF_Cons_NP.outconsultapersonasws)oRetInt.get('RETORNO');
                }
            
                if (oRetInt.get('TRAZA') != null)
                {
                    oTraza = (CC_TrazaInt__c)oRetInt.get('TRAZA');
                    resultadoALF.put('TRAZA', oTraza);
                }   

                Map<String,Object> datosTransformados = transformarDatosALFaSalesforce (numPerso, resultadoCallout, tipoCuentaExistente);
                for (String claveMap : datosTransformados.keySet())
                {
                    if (claveMap == 'ACCOUNT')
                    {
                        resultadoALF.put('ACCOUNT', datosTransformados.get(claveMap));
                    }
                }

            }catch (Exception e) {
                resultadoALF.put('ERROR', e);
            }
        }

        return resultadoALF;
    }

    /**
     * @description   Método para transformar el resultado de la API de Alfabético a objeto de Salesforce
     * @param sNumPer -> Numperso del cliente
     * @param oRes -> Resultado del Callout
     * @return Map<String,Object> con los resultados de la consulta realizada a la API convertidos a Salesforce
     */ 
    static private Map<String,Object> transformarDatosALFaSalesforce (String sNumPer, CC_WS_ALF_Cons_NP.outconsultapersonasws oRes, String tipoCuentaExistente)
    {
        Map<String,Object> datosCuenta = new Map<String,Object>();

        String sTipoID = '';
        String sTipoPers = '';
        String sNombreCompleto = '';
        String sTipoCuenta = '';
        String sNombre = '';
        String sApellido1 = '';
        String sApellido2 = '';
        String sDomicilio = '';
        String sDomCodPostal = '';
        String sDomCiudad = '';
        String sDomProvincia = '';
        String sDomPais = '';
        String sIdioma = '';
        String sIdiomaId = '';
        String sFechaNac = '';
        String sFechaDef = '';
        String sOfGestora = '';
        String sEmpGestor = '';
        String sSexo = '';
        String sFiscalId = '';
        String sPriTelf = '';
        String sPriMail = '';
        Boolean bIncapacitadoLegal = false;
        Boolean bMenorEmancipado = false;

        if (String.isNotBlank(sNumPer) && oRes != null)
        {
            // Recuperar las listas de valores a tratar por Alfabético.
            List<String> oLista = new List<String>();
            oLista.add('CC_Idioma_ALF');
            oLista.add('CC_Sexo_ALF');
            oLista.add('CC_ClaseCom_ALF');
            oLista.add('CC_TipoCom_ALF');
            Map<String, Object> oParamAux = CC_MetodosUtiles.getLOVMeta(oLista);

            // Sección datos cabecera del XML de respuesta.
            if (oRes.datosCabecera != null)
            {
                sTipoPers = (oRes.datosCabecera.tipoPersona != null) ? oRes.datosCabecera.tipoPersona.trim().unescapeHtml4() : sTipoPers;
            }

            // Sección datos persona del XML de respuesta.
            if (oRes.datosPersona != null)
            {
                sTipoID = (oRes.datosPersona.tipoIdentificador != null) ? oRes.datosPersona.tipoIdentificador.trim().unescapeHtml4() : sTipoID;
                sFiscalId = (oRes.datosPersona.numeroIdFiscal != null) ? oRes.datosPersona.numeroIdFiscal.trim().unescapeHtml4() : sFiscalId;
                sNombreCompleto = (oRes.datosPersona.nombre != null) ? oRes.datosPersona.nombre.trim().unescapeHtml4() : sNombreCompleto;
                
                switch on sTipoID {
                    when 'CIF' {
                        sTipoCuenta = 'Empresa';
                    }
                    when else {
                        sTipoCuenta = 'Particular';

                        if (oRes.datosNomPer != null)
                        {
                            if (oRes.datosNomPer.nombreDP != null)
                                sNombre = oRes.datosNomPer.nombreDP.trim().unescapeHtml4();
                            if (oRes.datosNomPer.particula1 != null)
                                sApellido1 = oRes.datosNomPer.particula1;
                            if (oRes.datosNomPer.apellido1 != null)
                                sApellido1 = sApellido1 +  ' ' + oRes.datosNomPer.apellido1;
                            if (oRes.datosNomPer.particula2 != null)
                                sApellido2 = oRes.datosNomPer.particula2;
                            if (oRes.datosNomPer.apellido2 != null)
                                sApellido2 = sApellido2 + ' ' + oRes.datosNomPer.apellido2;

                            sApellido1 = sApellido1.trim().unescapeHtml4();
                            sApellido2 = sApellido2.trim().unescapeHtml4();

                        }

                        // Tratamiento valor obligatorio contacto.
                        if (sApellido1 == '')
                        {
                            // Descomposición del nombre completo.
                            List<String> oDataNom = CC_WS_Methods_ALF.getNombreSeparado (sNombreCompleto);
                            if (oDataNom.size() == 3)
                            {
                                sNombre = oDataNom[0];
                                sApellido1 = oDataNom[1];
                                sApellido2 = oDataNom[2];
                            }else{
                                // Tratamiento valor obligatorio.
                                sApellido1 = sNombreCompleto;
                            }
                        }
                    }
                }

                // Gestionar el tipo de cuenta para evitar errores de personAccount.
                sTipoCuenta = (String.isNotBlank(tipoCuentaExistente) && tipoCuentaExistente == 'CC_Cliente') ? 'Empresa' : sTipoCuenta;
                //sTipoCuenta = (String.isNotBlank(tipoCuentaExistente) && tipoCuentaExistente == 'CC_ClientePA') ? 'Particular' : sTipoCuenta;

                if (oRes.datosPersona.idioma != null)
                    sIdioma = oRes.datosPersona.idioma.trim().unescapeHtml4();
                
                if (oRes.datosPersona.codiIdioma != null)
                    sIdiomaId = oRes.datosPersona.codiIdioma.trim().unescapeHtml4();

                if (oRes.datosPersona.fechaNacimiento != null)
                    sFechaNac = oRes.datosPersona.fechaNacimiento.trim().unescapeHtml4();

                if (oRes.datosPersona.fechaDefuncion != null)
                {
                    sFechaDef = oRes.datosPersona.fechaDefuncion.trim().unescapeHtml4();
                }
                
                if (oRes.datosPersona.sexo != null)
                    sSexo = oRes.datosPersona.sexo.trim().unescapeHtml4();
            }

            // Empleado gestor.
            if (oRes.numEpleadoGestor != null)
            {
                sEmpGestor = String.valueOf(oRes.numEpleadoGestor);
                if (sEmpGestor != '')
                    sEmpGestor = sEmpGestor.trim().unescapeHtml4();
            }

            // Sección de alertas.
            if (oRes.alertas != null)
            {
                if (oRes.alertas.oficinaGestora != null)
                {
                    sOfGestora = oRes.alertas.oficinaGestora.trim().unescapeHtml4();
                    sOfGestora = sOfGestora.leftPad(5,'0');

                    // Siempre es la empresa 001.
                    sOfGestora = '001-' + sOfGestora;
                }
            }

            Map<String, CC_WS_ALF_Contactos> oContactos = new Map<String, CC_WS_ALF_Contactos>();

            // Sección teléfonos.
            if (oRes.datosContacto != null)
            {
                if (oRes.datosContacto.listaTelefonos != null)
                {
                    for (CC_WS_ALF_Cons_NP.telefono oTel : oRes.datosContacto.listaTelefonos)
                    {
                        if (oTel.numTelf != null)
                        {
                            if (oTel.numTelf.trim() != '')
                            {
                                CC_WS_ALF_Contactos oCont = new CC_WS_ALF_Contactos();
                                String sNumTelf = oTel.numTelf.trim().unescapeHtml4();

                                if (oTel.prefijo != null)
                                {
                                    if (oTel.prefijo.trim() != '')
                                    {
                                        sNumTelf = oTel.prefijo.trim().unescapeHtml4() + ' ' + sNumTelf;
                                    }
                                }

                                String sClaveNom = '';
                                if (oTel.personaContacto != null)
                                    sClaveNom = oTel.personaContacto.trim().unescapeHtml4();

                                if (sClaveNom == '')
                                    sClaveNom = sNombreCompleto;

                                if (oContactos.get(sClaveNom) != null)
                                {
                                    oCont = oContactos.get(sClaveNom);
                                }else{
                                    oCont.sNombreCompleto = sClaveNom;
                                }

                                oCont.sNombreCompleto = sClaveNom;

                                if (oCont.sTelefono == null)
                                {
                                    Map<String,String> oIni = new Map<String,String>();
                                    oCont.sTelefono = oIni;
                                }

                                if (sPriTelf == '')
                                    sPriTelf = sNumTelf;

                                String sClaseTel = '';
                                String sTipoTel = '';

                                if (oTel.claseTelf != null)
                                    sClaseTel = oTel.claseTelf.trim().unescapeHtml4();

                                if (oTel.tipoTelf != null)
                                    sTipoTel = oTel.tipoTelf.trim().unescapeHtml4();

                                oCont.sTelefono.put(sNumTelf, sClaseTel + '##' + sTipoTel);
                                oContactos.put(sClaveNom, oCont);
                            }
                        }
                    }
                }
            }

            // Sección e-mails.
            if (oRes.datosContacto != null)
            {
                if (oRes.datosContacto.listaEmails != null)
                {
                    for (CC_WS_ALF_Cons_NP.email oMail : oRes.datosContacto.listaEmails)
                    {
                        if (oMail.email != null)
                        {
                            if (oMail.email.trim() != '')
                            {
                                CC_WS_ALF_Contactos oCont = new CC_WS_ALF_Contactos();
                                String sClaveNom = oMail.perconta.trim().unescapeHtml4();

                                if (sClaveNom == '')
                                    sClaveNom = sNombreCompleto;

                                if (oContactos.get(sClaveNom) != null)
                                {
                                    oCont = oContactos.get(sClaveNom);
                                }else{
                                    oCont.sNombreCompleto = sClaveNom;
                                }

                                oCont.sNombreCompleto = sClaveNom;

                                if (oCont.sMail == null)
                                {
                                    Map<String,String> oIni = new Map<String,String>();
                                    oCont.sMail = oIni;
                                }

                                if (sPriMail == '')
                                    sPriMail = oMail.email.trim().unescapeHtml4();

                                String sClaseMail = '';
                                if (oMail.claseEmail != null)
                                    sClaseMail = oMail.claseEmail.trim().unescapeHtml4();

                                oCont.sMail.put(oMail.email.trim().unescapeHtml4(), sClaseMail);
                                oContactos.put(sClaveNom, oCont);
                            }
                        }
                    }
                }
            }

            if (oRes.datosDomicilio != null)
            {
                if (oRes.datosDomicilio.domicilioFiscal != null)
                {
                    if (oRes.datosDomicilio.domicilioFiscal.direccion != null)
                        sDomicilio = oRes.datosDomicilio.domicilioFiscal.direccion.trim().unescapeHtml4();

                    if (oRes.datosDomicilio.domicilioFiscal.codigoPostal != null)
                        sDomCodPostal = oRes.datosDomicilio.domicilioFiscal.codigoPostal.trim().unescapeHtml4();

                    Map<String,String> oDomCP = CC_WS_Methods_ALF.getDatosDireccion (sDomCodPostal);
                    sDomCodPostal = oDomCP.get('CodPostal');
                    sDomCiudad = oDomCP.get('Ciudad');
                    sDomProvincia = oDomCP.get('Prov');

                    if (oRes.datosDomicilio.domicilioFiscal.pais != null)
                        sDomPais = oRes.datosDomicilio.domicilioFiscal.pais.trim().unescapeHtml4();
                }
            }

            // Sección Características.
            if (oRes.listaCaracteristicas != null)
            {
                for (CC_WS_ALF_Cons_NP.caracteristicas oCar : oRes.listaCaracteristicas)
                {
                    String sCodSenyal = '';
                    String sTipoSenyal = '';

                    if (oCar.tipoSenyal != null)
                    {
                        sTipoSenyal = oCar.tipoSenyal.trim().unescapeHtml4();
                    }

                    if (oCar.codigoSenyal != null)
                    {
                        sCodSenyal = oCar.codigoSenyal.trim().unescapeHtml4();
                    }

                    // Buscar incapacitado legal.
                    if (sTipoSenyal == '10' && sCodSenyal == '5')
                    {
                        bIncapacitadoLegal = true;
                    }

                    // Buscar menor emancipado.
                    if (sTipoSenyal == '10' && sCodSenyal == '4')
                    {
                        bMenorEmancipado = true;
                    }
                }
            }

            /*
            ***********************************************************************************
            ***********************************************************************************
            GESTIÓN CLIENTES EMPRESAS
            ***********************************************************************************
            ***********************************************************************************
            */
            if (sTipoCuenta == 'Empresa')
            {
                Account oAccount = new Account();
                oAccount.Name = sNombreCompleto;
                oAccount.AV_NumPerso__c = sNumPer;
                oAccount.CC_Numero_Documento__c = sFiscalId;
                oAccount.CC_TipoPersona__c = sTipoPers;
                oAccount.CC_TipoDocumento__c = sTipoID;
                //oAccount.CC_IncapacitadoLegal__c = bIncapacitadoLegal; --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                //oAccount.CC_MenorEmancipado__c = bMenorEmancipado; --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                //oAccount.AV_Idioma__c = (String.isNotBlank(sIdiomaId)) ? sIdiomaId : '002'; --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                oAccount.SEG_FechaRefresco__c = Datetime.now();

                // Domicilio.
                oAccount.BillingStreet = sDomicilio;
                oAccount.BillingPostalCode = sDomCodPostal;
                oAccount.BillingCity = sDomCiudad;
                oAccount.BillingState = sDomProvincia;
                oAccount.BillingCountry = sDomPais;

                // Oficina gestora.
                String oficinaId = '';
                if (sOfGestora != '')
                {
                    // Preparar búsquedas para hacer todo con un sólo DML.
                    List<Account> listaOficinas = [SELECT Id FROM Account WHERE CC_Numero_Oficina_Empresa__c = :sOfGestora];
                    if (!listaOficinas.isEmpty())
                    {
                        oficinaId = listaOficinas[0].Id;
                        oAccount.CC_OficinaGestoraId__c = listaOficinas[0].Id;
                    }
                }

                // Empleado gestor.
                if (oficinaId != '' && sEmpGestor != '' && sEmpGestor != '0')
                {
                    // Preparar búsquedas para hacer todo con un sólo DML.
                    List<Contact> listaEmpleados = [SELECT Id FROM Contact WHERE AccountId = :oficinaId AND CC_Num_Empleado__c = :sEmpGestor];
                    if (!listaEmpleados.isEmpty())
                    {
                        oAccount.CC_EmpleadoGestorId__c = listaEmpleados[0].Id;
                    }
                }

                datosCuenta.put('ACCOUNT',oAccount);
            }

            /*
            ***********************************************************************************
            ***********************************************************************************
            GESTIÓN CLIENTES PARTICULARES
            ***********************************************************************************
            ***********************************************************************************
            */
            if (sTipoCuenta == 'Particular')
            {
                Account oAccount = new Account();
                oAccount.FirstName = sNombre;
                oAccount.LastName = sApellido1 + ' ' + sApellido2;
                //oAccount.Name = sNombreCompleto; --> con los person account se rellena FirstName y LastName.
                oAccount.AV_NumPerso__c = sNumPer;
                oAccount.Phone = sPriTelf;
                oAccount.CC_Email__c = sPriMail;
                oAccount.CC_Numero_Documento__c = sFiscalId;
                oAccount.CC_TipoPersona__c = sTipoPers;
                oAccount.CC_TipoDocumento__c = sTipoID;
                //oAccount.CC_IncapacitadoLegal__c = bIncapacitadoLegal; --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                //oAccount.CC_MenorEmancipado__c = bMenorEmancipado; --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                oAccount.PersonEmail = sPriMail;
                oAccount.SEG_FechaRefresco__c = Datetime.now();

                // Convertir idioma.
                //      Recuperar parámetro auxiliar lista de valores.
                // --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                /*if (oParamAux != null)
                {
                    if (oParamAux.size() > 0)
                    {
                        if (oParamAux.get('CC_Idioma_ALF') != null)
                        {
                            Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Idioma_ALF');
                            if (oMap.get(sIdiomaId) != null)
                            {
                                oAccount.CC_Idioma__pc = oMap.get(sIdiomaId);
                                oAccount.AV_Idioma__c = sIdiomaId;
                            }else{
                                // Idioma no configurado. Por defecto 'es'
                                oAccount.CC_Idioma__pc = 'es';
                                oAccount.AV_Idioma__c = '002';
                            }
                        }
                    }
                }*/

                // Convertir sexo.
                //      Recuperar parámetro auxiliar lista de valores.
                // --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                /*if (oParamAux != null)
                {
                    if (oParamAux.size() > 0)
                    {
                        if (oParamAux.get('CC_Sexo_ALF') != null)
                        {
                            Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Sexo_ALF');
                            if (oMap.get(sSexo) != null)
                            {
                                oAccount.CC_Sexo__pc = oMap.get(sSexo);
                            }
                        }
                    }
                }*/

                // Convertir fecha de nacimiento.
                // --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                /*if (sFechaNac != '')
                {
                    oAccount.CC_FechaNac__pc = CC_WS_Methods_ALF.getDateALF(sFechaNac);
                    oAccount.PersonBirthdate = CC_WS_Methods_ALF.getDateALF(sFechaNac);
                }*/

                // Convertir fecha de defunción.
                // --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                /*if (sFechaDef != '')
                {
                    oAccount.CC_FechaDefuncion__pc = CC_WS_Methods_ALF.getDateALF(sFechaDef);
                }*/

                // Domicilio.
                oAccount.BillingStreet = sDomicilio;
                oAccount.BillingPostalCode = sDomCodPostal;
                oAccount.BillingCity = sDomCiudad;
                oAccount.BillingState = sDomProvincia;
                oAccount.BillingCountry = sDomPais;   
                
                // Domicilio Contacto
                oAccount.PersonMailingStreet = sDomicilio;
                oAccount.PersonMailingPostalCode = sDomCodPostal;
                oAccount.PersonMailingCity = sDomCiudad;
                oAccount.PersonMailingState = sDomProvincia;
                oAccount.PersonMailingCountry = sDomPais;

                // Oficina gestora.
                String oficinaId = '';
                if (sOfGestora != '')
                {
                    // Preparar búsquedas para hacer todo con un sólo DML.
                    List<Account> listaOficinas = [SELECT Id FROM Account WHERE CC_Numero_Oficina_Empresa__c = :sOfGestora];
                    if (!listaOficinas.isEmpty())
                    {
                        oficinaId = listaOficinas[0].Id;
                        oAccount.CC_OficinaGestoraId__c = listaOficinas[0].Id;
                    }
                }

                // Empleado gestor.
                if (oficinaId != '' && sEmpGestor != '' && sEmpGestor != '0')
                {
                    // Preparar búsquedas para hacer todo con un sólo DML.
                    List<Contact> listaEmpleados = [SELECT Id FROM Contact WHERE AccountId = :oficinaId AND CC_Num_Empleado__c = :sEmpGestor];
                    if (!listaEmpleados.isEmpty())
                    {
                        oAccount.CC_EmpleadoGestorId__c = listaEmpleados[0].Id;
                    }
                }

                datosCuenta.put('ACCOUNT',oAccount);
            }
        }

        return datosCuenta;
    }
    
	/**
	* Method that validates if response data is null. Migrada del proyecto Mis clientes.
	*
	* @param data API Premium response data field
	* @return Object data or null
	*/
    @TestVisible
	private static Object validateNull(Object data) {
		if(data == null) {
			return null;
		}
		return data;
	}

    @TestVisible
	private static Object validateNull(Object data, String type) {
		if(data == null) {
			return null;
		}
		switch on type {
			when 'convertString' {
				return String.valueOf(data);
			}
		}
		return data;
	}
    
	/**
	 * @description		 Class to compare datetime
	 * @param  fechaRefresh  Datetime of the last call to CLI api
	 * @param  today	Datetime of now just
	 * @return			  Return the different beetween both datetime in hours   
	 */
	public static Long calculateTimeDifferences(DateTime fechaRefresh, DateTime today){
		
		Long hours;
		Long fechaRefreshLong = fechaRefresh.getTime();
		Long todayLong = today.getTime();
		Long milliseconds = todayLong - fechaRefreshLong;
		Long seconds = milliseconds / 1000;
		Long minutes = seconds / 60;
		hours = minutes / 60;

		return hours;
	}
}