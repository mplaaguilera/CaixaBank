public with sharing class CC_WS_Methods_ALF {

    /* 
        Clase para identificación de clientes / contactos vía Alfabético.
    */

    /* 
        Estructura de datos para el tratamiento de la respuesta de ALF por NumPerso 
    */
    private class CC_WS_ALF_Contactos {
        String sNombreCompleto;
        String sNombre;
        String sApellido1;
        String sApellido2;
        Map<String,String> sTelefono;
        Map<String,String> sMail;
    }

    /*
        Método de conversión de fechas.
        Ejemplo formato entrada: Fri Mar 17 00:00:00 CET 2000
    */
    static public Date getDateALF (String sFecha)
    {
        Date oDate;

        if (sFecha != '')
        {            
            try
            {
                Map<String,Integer> oMap = new Map<String,Integer>();
                oMap.put('Jan',1);
                oMap.put('Feb',2);
                oMap.put('Mar',3);
                oMap.put('Apr',4);
                oMap.put('May',5);
                oMap.put('Jun',6);
                oMap.put('Jul',7);
                oMap.put('Aug',8);
                oMap.put('Sep',9);
                oMap.put('Oct',10);
                oMap.put('Nov',11);
                oMap.put('Dec',12);

                List<String> oParts = sFecha.split(' ');
                if (oParts.size()==6)
                {
                    Integer iDia = Integer.valueOf(oParts[2]);
                    Integer iMes = oMap.get(oParts[1]);
                    Integer iAno = Integer.valueOf(oParts[5]);

                    oDate = Date.newInstance(iAno, iMes, iDia);
                }

            }catch (Exception e) {
                // No tratamos error.
                oDate = null;
            }
        }

        return oDate;
    }

    /*
        Método de división del código postal.
    */
    static public Map<String,String> getDatosDireccion (String sData)
    {
        Map<String,String> oDatos = new Map<String, String>();
        String sCodPostal = '';
        String sCiudad = '';
        String sProv = '';

        if (sData.length()>6)
        {
            sCodPostal = sData.substring(0,5);
            sData = sData.substring(5).trim();
            if (sData.indexOf('(') == -1)
            {
                sCiudad = sData;
                sProv = sData;
            }else{
                sCiudad = sData.substring(0, sData.indexOf('(')-1).trim();
                sProv = sData.substring(sData.indexOf('(')+1, sData.length()-1).trim();
            }

        }else{
            sCodPostal = sData;
        }

        oDatos.put('CodPostal', sCodPostal);
        oDatos.put('Ciudad', sCiudad);
        oDatos.put('Prov', sProv);

        return oDatos;
    }

    /*
        Recuperar los días de refresco de datos en Salesforce vía Alfabético.
    */
    static public Integer getDiasRefrescoALF (String sInterfaz)
    {
        Integer iDias = 0;

        List<CC_InterfaceSettings__mdt> oConfig = [SELECT Id, CC_Activa__c, CC_DiasRef__c FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :sInterfaz AND CC_Activa__c = true];
        if (oConfig.size()==1)
        {
            if (oConfig[0].CC_DiasRef__c != null)
                iDias = Integer.valueOf(oConfig[0].CC_DiasRef__c);
        }

        return iDias;
    }

    /*
        Función para separar el nombre completo. De utilidad en el futuro para los contactos de una empresa.
    */
    static public List<String> getNombreSeparado (String sNomCompleto)
    {
        String sNombre = '';
        String sApellido1 = '';
        String sApellido2 = '';
        List<String> oNomCompleto = new List<String>();

        if (sNomCompleto != '')
        {
            List<String> oNomAux = sNomCompleto.split('\\s+');

            if (oNomAux.size()>=3)
            {
                sApellido2 = oNomAux[oNomAux.size()-1];
                sApellido1 = oNomAux[oNomAux.size()-2];
                for (Integer i=0; i<oNomAux.size()-2; i++)
                {
                    sNombre = sNombre + ' ' + oNomAux[i];
                }
            }else{
                if (oNomAux.size() == 2)
                {
                    sNombre = oNomAux[0];
                    sApellido1 = oNomAux[1];
                }else{
                    sApellido1 = sNomCompleto;
                }
            }
        }

        oNomCompleto.add(sNombre.trim());
        oNomCompleto.add(sApellido1.trim());
        oNomCompleto.add(sApellido2.trim());

        return oNomCompleto;
    }

    /*
        Método para recuperar todas las cuentas y contactos asociadas a la lista de NumPerso de entrada.
        El MAP de entrada tiene clave la siguiente información: NUMPERSO##TIPO_REGISTRO. Ahora el tipo de registro será Cliente,
        que se traducirá al RecordType de Clientes.
        El SObject de entrada por ahora será NULL, no se utiliza. Uso futuro.

        Devuelve solo los objetos que se han de actualizar vía Alfabético.
        El SObject que se devuelve por ahora será NULL, no se utiliza. Uso futuro.
    */
    static public Map<String,SObject> getContactAccountByNumPerso (Map<String,SObject> oNumPerso)
    {
        Map<String,SObject> oObj = new Map<String,SObject>();
        Map<String,String> oObjNoAct = new Map<String,String>();

        if (oNumPerso.size() > 0)
        {
            // Recuperar la configuración de la integración.
            Integer iDiasRef = getDiasRefrescoALF ('CC_Int_ALF');
            Date oFechaActual = Date.today();        

            // Preparar los NumPerso a buscar.
            Set<String> oAuxSearch = new Set<String>();
            for (String sAux : oNumPerso.keySet())
            {
                // Sólo buscamos los que son NumPerso.
                if (sAux.split('##')[1] == 'Cliente')
                {
                    oAuxSearch.add(sAux.split('##')[0]);
                }else{
                    oObj.put(sAux, null);
                }
            }

            List<Account> oAccount = [SELECT Id, CC_NumPerso__c, CC_FechaRefresco__c FROM Account WHERE CC_NumPerso__c in :oAuxSearch];
            for (Account oAux : oAccount)
            {
                // TO_DO. Aquellos que no cumplen la lógica, se eliminarán del MAP.

                Boolean bRefrescar = true;
                if (oAux.CC_FechaRefresco__c != null)
                {
                    Date oFechaAux = oAux.CC_FechaRefresco__c;
                    oFechaAux = oFechaAux.addDays(iDiasRef); 

                    if (oFechaAux > oFechaActual)
                        bRefrescar = false;
                }

                if (bRefrescar == false)
                    oObjNoAct.put(oAux.CC_NumPerso__c + '##Cliente', 'NO_REFRESCAR');
            }

            List<Contact> oContact = [SELECT Id, CC_NumPerso__c, CC_FechaRefresco__c FROM Contact WHERE CC_NumPerso__c in :oAuxSearch];
            for (Contact oAux : oContact)
            {
                // TO_DO. Aquellos que no cumplen la lógica, se eliminarán del MAP.

                Boolean bRefrescar = true;
                if (oAux.CC_FechaRefresco__c != null)
                {
                    Date oFechaAux = oAux.CC_FechaRefresco__c;
                    oFechaAux = oFechaAux.addDays(iDiasRef);

                    if (oFechaAux > oFechaActual)
                        bRefrescar = false;
                }

                if (bRefrescar == false)
                    oObjNoAct.put(oAux.CC_NumPerso__c + '##Cliente', 'NO_REFRESCAR');
            }

            oAuxSearch.clear();
            oAuxSearch = null;
        }

        // Cruzar Maps para obtener los NumPerso a consultar y los casos para actualizar.
        for (String sAux : oNumPerso.keySet())
        {
            String sAuxCL = sAux.split('##')[0] + '##Cliente';
            if (oObjNoAct.get(sAuxCL) == null) {
                // Casos para identificar.
                oObj.put(sAux, null);
            } else {
                // Casos identificados y que no se consulta a ALF por fecha de refresco.
                oObj.put('UPDCASO##' + sAux, null);
            }
        }

        oObjNoAct.clear();
        oObjNoAct = null;

        return oObj;
    }

    /*
        Método para tratar la respuesta de Alfabético y convertirla a objetos Salesforce.
        Se devolverá una lista de sObjects ordenada (Account y Contacts a crear).
        Retorno:
              Formato clave MAP. Objeto##Accion##Clave
              Objeto: Account, Contact, CanalCom
              Accion: 0 -> Upsert directo, 1 -> Consulta
              Clave: Numper para UP, Numper + Valor Búsqueda para QU (Separados por &&)

        TODO. Tratamiento empresas y pasaporte.
    */
    static private Map<String,Object> getContactAccountRespALFNP (String sNumPer, String sTipoReg, CC_WS_ALF_Cons_NP.outconsultapersonasws oRes, Map<String, Object> oParamAux)
    {
        Map<String,Object> oNewRes = new Map<String,Object>();

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
        Boolean bOrigenBankia = false;
        Boolean bOrigenCompartido = false;
        Boolean bFirmaDigitalizada = false;
        Boolean bDocumentoDigitalizado = false;

        if (oRes != null)
        {
            // Sección datos cabecera del XML de respuesta.
            if (oRes.datosCabecera != null)
            {
                if (oRes.datosCabecera.tipoPersona != null)
                {
                    sTipoPers = oRes.datosCabecera.tipoPersona.trim().unescapeHtml4();
                }
            }

            // Sección datos persona del XML de respuesta.
            if (oRes.datosPersona != null)
            {
                if (oRes.datosPersona.tipoIdentificador != null)
                    sTipoID = oRes.datosPersona.tipoIdentificador.trim().unescapeHtml4();

                if (oRes.datosPersona.numeroIdFiscal != null)
                    sFiscalId = oRes.datosPersona.numeroIdFiscal.trim().unescapeHtml4();
//sTipoID='CIF';
//sTipoPers = 'J';
                
                switch on sTipoID {
                    when 'CIF' {
                        sTipoCuenta = 'Empresa';

                        if (oRes.datosPersona.nombre != null)
                            sNombreCompleto = oRes.datosPersona.nombre.trim().unescapeHtml4();
                    }
                    when else {
                        sTipoCuenta = 'Particular';

                        if (oRes.datosPersona.nombre != null)
                            sNombreCompleto = oRes.datosPersona.nombre.trim().unescapeHtml4();

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
                            List<String> oDataNom = getNombreSeparado (sNombreCompleto);
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
                    //sOfGestora = sOfGestora + '-001';
                    sOfGestora = '001-' + sOfGestora;
                }
            }

            Map<String, CC_WS_ALF_Contactos> oContactos = new Map<String,CC_WS_ALF_Contactos>();

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

                    Map<String,String> oDomCP = getDatosDireccion (sDomCodPostal);
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

                    // Buscar Origen Bankia.
                    if (sTipoSenyal == '10' && sCodSenyal == '135')
                    {
                        bOrigenBankia = true;
                    }
                    
                    // Buscar Origen Compartido.
                    if (sTipoSenyal == '10' && sCodSenyal == '136')
                    {
                        bOrigenCompartido = true;
                    }

                    // Buscar Origen Compartido.
                    if (sTipoSenyal == '10' && sCodSenyal == '19')
                    {
                        bFirmaDigitalizada = true;
                    }

                    // Buscar Origen Compartido.
                    if (sTipoSenyal == '10' && sCodSenyal == '20')
                    {
                        bDocumentoDigitalizado = true;
                    }
                }
            }

            // Informar el tipo de cuenta.
            oNewRes.put('TipoCuenta##0##'+sNumPer, sTipoCuenta);

            /*
            ***********************************************************************************
            ***********************************************************************************
            GESTIÓN CLIENTES EMPRESAS
            ***********************************************************************************
            ***********************************************************************************
            */
            if (sTipoCuenta == 'Empresa')
            {
                Date oFechaRef = Date.today();

                // Separamos para la posible conversión de BusinessAccount <--> PersonAccount
                //if (sTipoReg == 'Cliente')
                //{
                    Account oConversionUpdate = new Account();
                    oConversionUpdate.CC_NumPerso__c = sNumPer;
                    oConversionUpdate.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                    oNewRes.put('ConvAccountRT##0##'+sNumPer,oConversionUpdate);

                    Contact oConversionUpdateContact = new Contact();
                    oConversionUpdateContact.CC_NumPerso__c = sNumPer;
                    oConversionUpdateContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                    oNewRes.put('ConvContactRT##0##'+sNumPer,oConversionUpdateContact);

                    Account oActualizarPAName = new Account();
                    oActualizarPAName.CC_NumPerso__c = sNumPer;
                    oActualizarPAName.LastName = sNombreCompleto.left(80);
                    oActualizarPAName.CC_NumPerso__pc = sNumPer;
                    //oNewRes.put('ConvPANameAccount##0##'+sNumPer,oActualizarPAName);
                    oNewRes.put('ConvNameAccountUpdate##0##'+sNumPer,oActualizarPAName);

                    Account oActualizarName = new Account();
                    oActualizarName.CC_NumPerso__c = sNumPer;
                    oActualizarName.Name = sNombreCompleto;
                    oNewRes.put('ConvNameAccount##0##'+sNumPer,oActualizarName);
                
                	Account oUpdANumPer = new Account();
                    oUpdANumPer.CC_NumPerso__c = sNumPer;
                    oNewRes.put('UpdANumPer##0##'+sNumPer,oUpdANumPer);
                //}

                Account oAccount = new Account();
                //oAccount.Name = sNombreCompleto;
                oAccount.CC_NumPerso__c = sNumPer;
                oAccount.CC_Numero_Documento__c = sFiscalId;
                oAccount.CC_TipoPersona__c = sTipoPers;
                oAccount.CC_TipoDocumento__c = sTipoID;
                oAccount.CC_IncapacitadoLegal__c = bIncapacitadoLegal;
                oAccount.CC_MenorEmancipado__c = bMenorEmancipado;
                oAccount.CBK_OrigenBankia__c = bOrigenBankia;
                oAccount.CBK_OrigenCompartido__c = bOrigenCompartido;
                oAccount.CC_FirmaDigitalizada__c = bFirmaDigitalizada;
                oAccount.CC_DocumentoDigitalizado__c = bDocumentoDigitalizado;
                
                /* Convertimos por separado el posible RecordType.
                if (sTipoReg == 'Cliente')
                {
                    //if (sTipoID == 'CIF')
                    //{
                        oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                    //}else{
                    //    oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                    //}
                }*/

                // Domicilio.
                oAccount.BillingStreet = sDomicilio;
                oAccount.BillingPostalCode = sDomCodPostal;
                oAccount.BillingCity = sDomCiudad;
                oAccount.BillingState = sDomProvincia;
                oAccount.BillingCountry = sDomPais;

                //oAccount.CC_FechaRefresco__c = oFechaRef;
                oAccount.CC_FechaRefresco__c = null;

                oNewRes.put('Account##0##'+sNumPer,oAccount);

                Account oAccountFR = new Account();
                oAccountFR.CC_NumPerso__c = sNumPer;
                oAccountFR.CC_FechaRefresco__c = oFechaRef;
                oNewRes.put('AccountFecha##0##'+sNumPer,oAccountFR);

                // Oficina gestora.
                if (sOfGestora != '')
                {
                    Account oAccountOf = new Account();
                    oAccountOf.CC_NumPerso__c = sNumPer;

                    Account oOficina = new Account(CC_Numero_Oficina_Empresa__c = sOfGestora);
                    oAccountOf.CC_OficinaGestoraId__r = oOficina;

                    oNewRes.put('Oficina##0##'+sNumPer,oAccountOf);
                }

                // Empleado gestor.
                if (sEmpGestor != '' && sEmpGestor != '0')
                {
                    Account oAccountOf = new Account();
                    oAccountOf.CC_NumPerso__c = sNumPer;

                    Contact oEmpleado = new Contact(CC_Num_Empleado__c = sEmpGestor);
                    oAccountOf.CC_EmpleadoGestorId__r = oEmpleado;

                    oNewRes.put('OficinaEmp##0##'+sNumPer,oAccountOf);
                }
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
                Date oFechaRef = Date.today();

                // Separamos para la posible conversión de BusinessAccount <--> PersonAccount
                //if (sTipoReg == 'Cliente')
                //{
                    Account oConversionUpdate = new Account();
                    oConversionUpdate.CC_NumPerso__c = sNumPer;
                    oConversionUpdate.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                    oNewRes.put('ConvAccountRT##0##'+sNumPer,oConversionUpdate);

                    Account oActualizarPAName = new Account();
                    oActualizarPAName.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                	oActualizarPAName.CC_NumPerso__c = sNumPer;
                    oActualizarPAName.FirstName = sNombre;
                    oActualizarPAName.LastName = sApellido1 + ' ' + sApellido2;
                    oActualizarPAName.CC_NumPerso__pc = sNumPer;
                    oNewRes.put('ConvPANameAccount##0##'+sNumPer,oActualizarPAName);

                    Account oActualizarName = new Account();
                    oActualizarName.CC_NumPerso__c = sNumPer;
                    oActualizarName.Name = sNombreCompleto;
                    oNewRes.put('ConvNameAccountUpdate##0##'+sNumPer,oActualizarName);
                
                	Account oUpdANumPer = new Account();
                    oUpdANumPer.CC_NumPerso__c = sNumPer;
                    oNewRes.put('UpdANumPer##0##'+sNumPer,oUpdANumPer);
                //}

                Account oAccount = new Account();
                //oAccount.FirstName = sNombre;
                //oAccount.LastName = sApellido1 + ' ' + sApellido2;
                //oAccount.Name = sNombreCompleto; --> con los person account se rellena FirstName y LastName.
                oAccount.CC_NumPerso__c = sNumPer;
                //oAccount.Phone = sPriTelf;
                oAccount.CC_Email__c = sPriMail;
                oAccount.CC_Numero_Documento__c = sFiscalId;
                oAccount.CC_TipoPersona__c = sTipoPers;
                oAccount.CC_TipoDocumento__c = sTipoID;
                oAccount.CC_IncapacitadoLegal__c = bIncapacitadoLegal;
                oAccount.CC_MenorEmancipado__c = bMenorEmancipado;
                oAccount.CBK_OrigenBankia__c = bOrigenBankia;
                oAccount.CBK_OrigenCompartido__c = bOrigenCompartido;
                oAccount.CC_FirmaDigitalizada__c = bFirmaDigitalizada;
                oAccount.CC_DocumentoDigitalizado__c = bDocumentoDigitalizado;
                
                /* Convertimos por separado el posible RecordType.
                if (sTipoReg == 'Cliente')
                    oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                */

                // Domicilio.
                oAccount.BillingStreet = sDomicilio;
                oAccount.BillingPostalCode = sDomCodPostal;
                oAccount.BillingCity = sDomCiudad;
                oAccount.BillingState = sDomProvincia;
                oAccount.BillingCountry = sDomPais;

                //oAccount.CC_FechaRefresco__c = oFechaRef;
                oAccount.CC_FechaRefresco__c = null;

                oNewRes.put('Account##0##'+sNumPer,oAccount);

                Account oAccountFR = new Account();
                oAccountFR.CC_NumPerso__c = sNumPer;
                oAccountFR.CC_FechaRefresco__c = oFechaRef;
                oNewRes.put('AccountFecha##0##'+sNumPer,oAccountFR);

                // Oficina gestora.
                /*if (sOfGestora != '' || sEmpGestor != '')
                {
                    Account oAccountOf = new Account();
                    oAccountOf.CC_NumPerso__c = sNumPer;

                    if (sOfGestora != '')
                    {
                        Account oOficina = new Account(CC_Numero_Oficina_Empresa__c = sOfGestora);
                        oAccountOf.CC_OficinaGestoraId__r = oOficina;
                    }

                    if (sEmpGestor != '' && sEmpGestor != '0')
                    {
                        Contact oEmpleado = new Contact(CC_Num_Empleado__c = sEmpGestor);
                        oAccountOf.CC_EmpleadoGestorId__r = oEmpleado;
                    }
                    oNewRes.put('Oficina##0##'+sNumPer,oAccountOf);
                }*/

                // Oficina gestora.
                if (sOfGestora != '')
                {
                    Account oAccountOf = new Account();
                    oAccountOf.CC_NumPerso__c = sNumPer;

                    Account oOficina = new Account(CC_Numero_Oficina_Empresa__c = sOfGestora);
                    oAccountOf.CC_OficinaGestoraId__r = oOficina;

                    oNewRes.put('Oficina##0##'+sNumPer,oAccountOf);
                }

                // Empleado gestor.
                if (sEmpGestor != '' && sEmpGestor != '0')
                {
                    Account oAccountOf = new Account();
                    oAccountOf.CC_NumPerso__c = sNumPer;

                    Contact oEmpleado = new Contact(CC_Num_Empleado__c = sEmpGestor);
                    oAccountOf.CC_EmpleadoGestorId__r = oEmpleado;

                    oNewRes.put('OficinaEmp##0##'+sNumPer,oAccountOf);
                }

                Contact oContact = new Contact();
                oContact.FirstName = sNombre;
                // ¿Activamos MiddleNames?
                oContact.LastName = sApellido1 + ' ' + sApellido2;
                //oContact.Account = new Account(CC_NumPerso__c = sNumPer); --> no vinculamos en PA, ya está vinculado automáticamente.
                oContact.CC_NumPerso__c = sNumPer;
                oContact.CC_Numero_Documento__c = sFiscalId;
                oContact.Email = sPriMail;
                //oContact.Phone = sPriTelf;

                // Con Person Account, el RecordType de contact no se informa.
                //if (sTipoReg == 'Cliente')
                //    oContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

                // Convertir idioma.
                //      Recuperar parámetro auxiliar lista de valores.
                if (oParamAux != null)
                {
                    if (oParamAux.size() > 0)
                    {
                        if (oParamAux.get('CC_Idioma_ALF') != null)
                        {
                            Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Idioma_ALF');
                            if (oMap.get(sIdiomaId) != null)
                            {
                                oContact.CC_Idioma__c = oMap.get(sIdiomaId);
                            }else{
                                // Idioma no configurado. Por defecto 'es'
                                oContact.CC_Idioma__c = 'es';
                            }
                        }
                    }
                }

                // Convertir sexo.
                //      Recuperar parámetro auxiliar lista de valores.
                if (oParamAux != null)
                {
                    if (oParamAux.size() > 0)
                    {
                        if (oParamAux.get('CC_Sexo_ALF') != null)
                        {
                            Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_Sexo_ALF');
                            if (oMap.get(sSexo) != null)
                            {
                                oContact.CC_Sexo__c = oMap.get(sSexo);
                            }
                        }
                    }
                }

                // Convertir fecha de nacimiento.
                if (sFechaNac != '')
                {
                    oContact.CC_FechaNac__c = getDateALF(sFechaNac);
                    oContact.Birthdate = getDateALF(sFechaNac);
                }

                // Convertir fecha de defunción.
                if (sFechaDef != '')
                {
                    oContact.CC_FechaDefuncion__c = getDateALF(sFechaDef);
                }

                // Oficina gestora. Look-up.

                // Domicilio.
                oContact.MailingStreet = sDomicilio;
                oContact.MailingPostalCode = sDomCodPostal;
                oContact.MailingCity = sDomCiudad;
                oContact.MailingState = sDomProvincia;
                oContact.MailingCountry = sDomPais;

                //oContact.CC_FechaRefresco__c = oFechaRef;
                oContact.CC_FechaRefresco__c = null;

                oNewRes.put('Contact##0##'+sNumPer,oContact);

                Contact oContactFR = new Contact();
                oContactFR.CC_NumPerso__c = sNumPer;
                oContactFR.CC_FechaRefresco__c = oFechaRef;
                oNewRes.put('ContactFecha##0##'+sNumPer,oContactFR);

                // PREMISA. Para particulares no hay personas de contacto vinculadas.

                // Añadir los teléfonos del contacto.
                for (String sCont : oContactos.keySet())
                {
                    // Nombre contacto.
                    String sNomContacto = oContactos.get(sCont).sNombreCompleto;

                    if (sNombreCompleto == sNomContacto)
                    {
                        // Gestión teléfonos.
                        if (oContactos.get(sCont).sTelefono != null)
                        {
                            for (String sTelf : oContactos.get(sCont).sTelefono.keySet())
                            {
                                //oTel = oContactos.get(sCont).sTelefono(sTel);
                                CC_Canal_Com__c oCCom = new CC_Canal_Com__c();
                                oCCom.CC_NumPerso__c=sNumPer;
                                oCCom.CC_Telefono__c = sTelf;
                                oCCom.CC_ContactoId__r = new Contact(CC_NumPerso__c = sNumPer);
                                oCCom.CC_CuentaId__r = new Account(CC_NumPerso__c = sNumPer);
                                oCCom.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();

                                // Parsear los valores rellenados más arriba. 
                                // Posición 0 -> Clase, Posición 1 -> Tipo
                                List<String>oData = oContactos.get(sCont).sTelefono.get(sTelf).split('##');
                                
                                if (oData[0] != '')
                                {
                                    // Convertir clase comunicación.
                                    //      Recuperar parámetro auxiliar lista de valores.
                                    if (oParamAux != null)
                                    {
                                        if (oParamAux.size() > 0)
                                        {
                                            if (oParamAux.get('CC_ClaseCom_ALF') != null)
                                            {
                                                Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ClaseCom_ALF');
                                                if (oMap.get(oData[0]) != null)
                                                {
                                                    oCCom.CC_Clase_Com__c = oMap.get(oData[0]);
                                                }
                                            }
                                        }
                                    }
                                }

                                if (oData[1] != '')
                                {
                                    // Convertir tipo de comunicación.
                                    //      Recuperar parámetro auxiliar lista de valores.
                                    if (oParamAux != null)
                                    {
                                        if (oParamAux.size() > 0)
                                        {
                                            if (oParamAux.get('CC_TipoCom_ALF') != null)
                                            {
                                                Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_TipoCom_ALF');
                                                if (oMap.get(oData[1]) != null)
                                                {
                                                    oCCom.CC_Tipo_Com__c = oMap.get(oData[1]);
                                                }
                                            }
                                        }
                                    }
                                }

                                oNewRes.put('CanalComTel##1##' + sNumPer + '&&' + sTelf, oCCom);
                            }
                        }
                    }
                }

                // Añadir los e-mails del contacto.
                for (String sCont : oContactos.keySet())
                {
                    // Nombre contacto.
                    String sNomContacto = oContactos.get(sCont).sNombreCompleto;

                    if (sNombreCompleto == sNomContacto)
                    {
                        // Gestión de los e-mails
                        if (oContactos.get(sCont).sMail != null)
                        {
                            for (String sMail : oContactos.get(sCont).sMail.keySet())
                            {
                                //oTel = oContactos.get(sCont).sMail(sTel);
                                CC_Canal_Com__c oCCom = new CC_Canal_Com__c();
                                oCCom.CC_NumPerso__c=sNumPer;
                                oCCom.CC_Email__c = sMail;
                                oCCom.CC_ContactoId__r = new Contact(CC_NumPerso__c = sNumPer);
                                oCCom.CC_CuentaId__r = new Account(CC_NumPerso__c = sNumPer);
                                oCCom.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();        

                                // Convertir clase comunicación.
                                //      Recuperar parámetro auxiliar lista de valores.
                                if (oParamAux != null)
                                {
                                    if (oParamAux.size() > 0)
                                    {
                                        if (oParamAux.get('CC_ClaseCom_ALF') != null)
                                        {
                                            Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ClaseCom_ALF');
                                            if (oMap.get(oContactos.get(sCont).sMail.get(sMail)) != null)
                                            {
                                                oCCom.CC_Clase_Com__c = oMap.get(oContactos.get(sCont).sMail.get(sMail));
                                            }
                                        }
                                    }
                                } 

                                oNewRes.put('CanalComMail##1##' + sNumPer + '&&' + sMail.toLowerCase(), oCCom);
                            }
                        }
                    }
                }
            }

            /*
            ***********************************************************************************
            ***********************************************************************************
            GESTIÓN CONTACTOS CUENTA
            ***********************************************************************************
            ***********************************************************************************
            */

            // Crear los contactos y sus teléfonos.
            for (String sCont : oContactos.keySet())
            {
                // Nombre contacto.
                String sNomContacto = oContactos.get(sCont).sNombreCompleto;

                // Si el nombre de la cuenta es diferente al contacto, tratarlo para crear un contacto nuevo.
                if (sNombreCompleto != sNomContacto)
                {
                    // Gestión teléfonos.
                    if (oContactos.get(sCont).sTelefono != null)
                    {
                        for (String sTelf : oContactos.get(sCont).sTelefono.keySet())
                        {
                            CC_Canal_Com__c oCCom = new CC_Canal_Com__c();
                            oCCom.CC_NumPerso__c=sNumPer;
                            oCCom.CC_Telefono__c = sTelf;
                            //oCCom.CC_ContactoId__r = new Contact(CC_NumPerso__c = sNumPer);
                            oCCom.CC_CuentaId__r = new Account(CC_NumPerso__c = sNumPer);
                            oCCom.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();

                            // Parsear los valores rellenados más arriba. 
                            // Posición 0 -> Clase, Posición 1 -> Tipo
                            List<String>oData = oContactos.get(sCont).sTelefono.get(sTelf).split('##');
                            
                            if (oData[0] != '')
                            {
                                // Convertir clase comunicación.
                                //      Recuperar parámetro auxiliar lista de valores.
                                if (oParamAux != null)
                                {
                                    if (oParamAux.size() > 0)
                                    {
                                        if (oParamAux.get('CC_ClaseCom_ALF') != null)
                                        {
                                            Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ClaseCom_ALF');
                                            if (oMap.get(oData[0]) != null)
                                            {
                                                oCCom.CC_Clase_Com__c = oMap.get(oData[0]);
                                            }
                                        }
                                    }
                                }
                            }

                            if (oData[1] != '')
                            {
                                // Convertir tipo de comunicación.
                                //      Recuperar parámetro auxiliar lista de valores.
                                if (oParamAux != null)
                                {
                                    if (oParamAux.size() > 0)
                                    {
                                        if (oParamAux.get('CC_TipoCom_ALF') != null)
                                        {
                                            Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_TipoCom_ALF');
                                            if (oMap.get(oData[1]) != null)
                                            {
                                                oCCom.CC_Tipo_Com__c = oMap.get(oData[1]);
                                            }
                                        }
                                    }
                                }
                            }

                            //oNewRes.put('CanalComTelACC##1##' + sNomContacto.toLowerCase() + '&&' + sNumPer + '&&' + sTelf, oCCom);
                            oNewRes.put('CanalComTelACC##1##' + sNomContacto + '&&' + sNumPer + '&&' + sTelf, oCCom);
                        }
                    }
                }
            }

            // Crear los contactos y sus e-mail.
            for (String sCont : oContactos.keySet())
            {

                // Nombre contacto.
                String sNomContacto = oContactos.get(sCont).sNombreCompleto;

                // Si el nombre de la cuenta es diferente al contacto, tratarlo para crear un contacto nuevo.
                if (sNombreCompleto != sNomContacto)
                {
                    // Gestión de los e-mails
                    if (oContactos.get(sCont).sMail != null)
                    {
                        for (String sMail : oContactos.get(sCont).sMail.keySet())
                        {
                            //oTel = oContactos.get(sCont).sMail(sTel);
                            CC_Canal_Com__c oCCom = new CC_Canal_Com__c();
                            oCCom.CC_NumPerso__c=sNumPer;
                            oCCom.CC_Email__c = sMail;
                            //oCCom.CC_ContactoId__r = new Contact(CC_NumPerso__c = sNumPer);
                            oCCom.CC_CuentaId__r = new Account(CC_NumPerso__c = sNumPer);
                            oCCom.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();        

                            // Convertir clase comunicación.
                            //      Recuperar parámetro auxiliar lista de valores.
                            if (oParamAux != null)
                            {
                                if (oParamAux.size() > 0)
                                {
                                    if (oParamAux.get('CC_ClaseCom_ALF') != null)
                                    {
                                        Map<String,String> oMap = (Map<String,String>)oParamAux.get('CC_ClaseCom_ALF');
                                        if (oMap.get(oContactos.get(sCont).sMail.get(sMail)) != null)
                                        {
                                            oCCom.CC_Clase_Com__c = oMap.get(oContactos.get(sCont).sMail.get(sMail));
                                        }
                                    }
                                }
                            } 

                            //oNewRes.put('CanalComMailACC##1##' + sNomContacto.toLowerCase() + '&&' + sNumPer + '&&' + sMail.toLowerCase(), oCCom);
                            oNewRes.put('CanalComMailACC##1##' + sNomContacto + '&&' + sNumPer + '&&' + sMail.toLowerCase(), oCCom);
                        }
                    }
                }
            }
        }
        
        return oNewRes;
    }

    /*
        Método para tratar la respuesta de Alfabético y convertirla a objetos Salesforce.
        Se devolverá una lista de sObjects ordenada (Account y Contacts a crear).
        Retorno:
              Formato clave MAP. Objeto##Accion##Clave
              Objeto: Account, Contact, CanalCom
              Accion: 0 -> Upsert directo, 1 -> Consulta
              Clave: Numper para UP, Numper + Valor Búsqueda para QU (Separados por &&)

        TODO. Tratamiento empresas y pasaporte.
    */
    //sIDToIdent
    static private Map<String,Object> getContactAccountConfidencial (String sIDToIdent, String sNumPer, String sTipoReg)
    {
        //sTipoReg = DATADOC
        Map<String,Object> oNewRes = new Map<String,Object>();

        // Indicar tipo de cuenta confidencial.
        oNewRes.put('TipoCuenta##0##'+sNumPer, 'Confidencial');

        // Los clientes confidenciales los tratamos como BusinessAccount.
        Account oConversionUpdate = new Account();
        oConversionUpdate.CC_NumPerso__c = sNumPer;
        oConversionUpdate.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        oNewRes.put('ConvAccountRT##0##'+sNumPer,oConversionUpdate);

        Contact oConversionUpdateContact = new Contact();
        oConversionUpdateContact.CC_NumPerso__c = sNumPer;
        oConversionUpdateContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        oNewRes.put('ConvContactRT##0##'+sNumPer,oConversionUpdateContact);

        Account oActualizarPAName = new Account();
        oActualizarPAName.CC_NumPerso__c = sNumPer;
        oActualizarPAName.FirstName = '';
        oActualizarPAName.LastName = 'CONFIDENCIAL';
        oActualizarPAName.CC_NumPerso__pc = sNumPer;
        if (sTipoReg == 'DATADOC'){
            oActualizarPAName.CC_Numero_Documento__c = sIDToIdent;
        }
        oNewRes.put('ConvPANameAccount##0##'+sNumPer,oActualizarPAName);

        Account oActualizarName = new Account();
        oActualizarName.CC_NumPerso__c = sNumPer;
        oActualizarName.Name = 'CONFIDENCIAL';
        if (sTipoReg == 'DATADOC'){
            oActualizarName.CC_Numero_Documento__c = sIDToIdent; 
        }
        oNewRes.put('ConvNameAccount##0##'+sNumPer,oActualizarName);

        // Crear cuenta confidencial.
        Account oAccount = new Account();
        oAccount.Name = 'CONFIDENCIAL';
        oAccount.CC_NumPerso__c = sNumPer;
        oAccount.CC_Confidencial__c = true;
        if (sTipoReg == 'DATADOC'){
            oAccount.CC_Numero_Documento__c = sIDToIdent;
        }
        //oAccount.CC_FechaRefresco__c = null;
            
        //if (sTipoReg == 'Cliente')
        //    oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        oNewRes.put('Account##0##'+sNumPer,oAccount);

        Contact oContact = new Contact();
        oContact.FirstName = '';
        oContact.LastName = 'CONFIDENCIAL';
        oContact.Account = new Account(CC_NumPerso__c = sNumPer);
        oContact.CC_NumPerso__c = sNumPer;
        oContact.CC_Confidencial__c = true;
        if (sTipoReg == 'DATADOC'){
            oContact.CC_Numero_Documento__c = sIDToIdent;
        }
        //oContact.CC_FechaRefresco__c = null;

        //if (sTipoReg == 'Cliente')
        //    oContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        oNewRes.put('Contact##0##'+sNumPer,oContact);

        // Los clientes confidenciales los tratamos como BusinessAccount.
        Account oConversionUpdateFechaRefresh = new Account();
        oConversionUpdateFechaRefresh.CC_NumPerso__c = sNumPer;
        oConversionUpdateFechaRefresh.CC_FechaRefresco__c = system.today();
        oNewRes.put('AccountFecha##0##'+sNumPer,oConversionUpdateFechaRefresh);

        Contact oConversionUpdateContactFechaRefresh = new Contact();
        oConversionUpdateContactFechaRefresh.CC_NumPerso__c = sNumPer;
        oConversionUpdateContactFechaRefresh.CC_FechaRefresco__c = system.today();
        oNewRes.put('ContactFecha##0##'+sNumPer,oConversionUpdateContactFechaRefresh);        
        
        return oNewRes;
    }

    /*
        Método para recuperar los datos de cliente y contacto de Alfabético.

        NOTA: oData. Se puede pasar la referencia del objeto existente para realizar comprobaciones sin tener que volver a buscar el registro.
        Ahora no se utiliza, viene NULL.

        Retorno:
              Formato clave MAP. Objeto##Accion##Clave
              Objeto: Account, Contact, CanalCom
              Accion: 0 -> Upsert directo, 1 -> Consulta
              Clave: Numper para UP, Numper + Valor Búsqueda para QU (Separados por &&)
    */
    static public Map<String,Object> getDataALFWSbyNumPerso (String sIDToIdent, String sNumPerso, String sTipoReg, String sIdOrig, SObject oData, Map<String, Object> oParamAux, CC_InterfaceSettings__mdt oConfig)
    {
        Map<String,Object> oObj = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        Boolean bConfidencial = false;

        if (sNumPerso != '')
        {
            // Recuperar configuración Alfabético.
			/**String sInterfaz = 'CC_Int_ALF';

            switch on CC_MetodosUtiles.getApplicationName(){
                when 'SAC'
                {
                    sInterfaz = 'SAC_Int_ALF';
                }
                when else {
                    sInterfaz = 'CC_Int_ALF';
                }
            }
            //System.Debug('sInterfaz:' + sInterfaz);
            //System.Debug('APP:' + CC_MetodosUtiles.getApplicationName());


            CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody (sInterfaz);*/

            if (oConfig != null)
            {
                // Preparar retorno del Servicio Web.
                CC_WS_ALF_Cons_NP.outconsultapersonasws oRes;

                Boolean bHttpRequest = oConfig.CC_HttpRequest__c;

                if (Test.isRunningTest())
                {
                    // Convertir llamada.
                    if (sTipoReg.length() > 4)
                    {
                        if (sTipoReg.substring(0,5) != 'AP2WL')
                        {
                            bHttpRequest = true;
                        }else{
                            bHttpRequest = false;
                        }
                    }else{
                        bHttpRequest = true;
                        // Probando resto de llamadas RRSS, DOC, TEL.
                        return oObj;
                    }
                }

                //if (oConfig.CC_HttpRequest__c && sTipoReg.substring(0,5) != 'AP2WL')
                if (bHttpRequest)
                {
                    if (Test.isRunningTest())
                    {
                        // Preparar callout test.
                        if (sTipoReg.length() > 4)
                        {
                            if (sTipoReg.substring(0,6) == 'INTCLI')
                            {
                                // Probando llamada a CLI. Saliendo del método sin datos a retornar.
                                return oObj;
                            }
                        }else{
                            // Probando resto de llamadas RRSS, DOC, TEL.
                            return oObj;
                        }

                        /*if (sTipoReg == 'CLIENTE')                        
                            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());

                        if (sTipoReg == 'CLIENTE_01')                        
                            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_02());

                        if (sTipoReg == 'CLIENTE_02')                        
                            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_03());

                        if (sTipoReg == 'CLIENTE_03')                        
                            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_04());

                        if (sTipoReg == 'CLIENTE_04')                        
                            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_05());
                            */
                    }

                    // Llamada vía HttpRequest.
                    Map<String,Object> oRetInt = CC_WS_Methods_ALF_RAW.getHttpALF (oConfig, sNumPerso, sIdOrig);


                    if (oRetInt.get('RETORNO') != null)
                        oRes = (CC_WS_ALF_Cons_NP.outconsultapersonasws)oRetInt.get('RETORNO');
                    
                    if (oRetInt.get('TRAZA') != null)
                        oTraza = (CC_TrazaInt__c)oRetInt.get('TRAZA');

                    if (oRetInt.get('CONFIDENCIAL') != null)
                        bConfidencial = (Boolean)oRetInt.get('CONFIDENCIAL');

                }else{

                    if (Test.isRunningTest())
                    {
                        //if (sTipoReg == 'AP2WL01')
                        //    Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALF_WSDL_01());
                        if (sTipoReg.substring(0,6) == 'INTCLI' || sTipoReg == 'Cliente')
                        {
                            // Probando llamada a CLI. Saliendo del método sin datos a retornar.
                            return oObj;
                        }
                    }

                    /*CC_WS_ALF_Cons_NP.AlfabeticPersonaWsPortTypePort oWS = new CC_WS_ALF_Cons_NP.AlfabeticPersonaWsPortTypePort();
                    oWS.clientCertName_x = oConfig.CC_Certificado__c;
                    oWS.timeout_x = Integer.valueOf(oConfig.CC_TimeOut__c);
                    oWS.endpoint_x = oConfig.CC_EndPoint__c;

                    CC_WS_ALF_Cons_NP.inconsultapersonasws oIn = new CC_WS_ALF_Cons_NP.inconsultapersonasws();
                    oIn.numeroPersona = sNumPerso;

                    oRes = oWS.ConsultaPersonas(oIn);*/

                    // Llamada vía AP2WSDL.
                    Map<String,Object> oRetInt = CC_WS_Methods_ALF_RAW.getAP2WSDLALF (oConfig, sNumPerso, sIdOrig);

                    if (oRetInt.get('RETORNO') != null)
                        oRes = (CC_WS_ALF_Cons_NP.outconsultapersonasws)oRetInt.get('RETORNO');
                    
                    if (oRetInt.get('TRAZA') != null)
                        oTraza = (CC_TrazaInt__c)oRetInt.get('TRAZA');

                    if (oRetInt.get('CONFIDENCIAL') != null)
                        bConfidencial = (Boolean)oRetInt.get('CONFIDENCIAL');
                    
                }

                // Llamada MOCK. Quitar con la integración.
                //CC_WS_ALF_Cons_NP.outconsultapersonasws oRes = CC_WS_Methods_ALF.getMockResponse1();

                // Se devolverá una lista de sObjects ordenada (Account y Contacts a crear).

                // Convertir respuesta a Objects.
                //      Formato clave MAP. Objeto##Accion##Clave
                //      Objeto: Account, Contact, CanalCom
                //      Accion: UP -> Upsert directo, QU -> Consulta
                //      Clave: Numper para UP, Numper + Valor Búsqueda para QU
                
                if (bConfidencial == false)
                {
                    Map<String,Object> oRes2 =  getContactAccountRespALFNP (sNumPerso, sTipoReg, oRes, oParamAux);
                    if (oRes2.size() > 0)
                    {
                        oObj.putAll(oRes2);
                    }
                }else{
                    //sIDToIdent
                    Map<String,Object> oRes2 =  getContactAccountConfidencial (sIDToIdent,sNumPerso, sTipoReg);
                    if (oRes2.size() > 0)
                    {
                        oObj.putAll(oRes2);
                    }
                }

                // Incorporar la traza.
                if (oTraza != null)
                {
                    String sClave = 'TRAZA##UP##' + sNumPerso;
                    oObj.put(sClave, oTraza);

                    // Debug. Quitar.
                    //insert oTraza;
                }

                // Logs Informativos sobre las caracteristicas del numPerso (se ven si se activa el check LogINFO)
                if (oRes != null)
                {
                    CC_WS_ALF_Cons_NP.caracteristicas[] caracArray = oRes.listaCaracteristicas;
                    if (caracArray != null)
                    {
                        String logString = 'Lista Caracteristicas de Alfabetico del numPerso ' + sNumPerso + '\n';
                        for (Integer i = 0; i < caracArray.size(); i++)
                        {
                            logString += 'Tipo-Codigo (' + caracArray[i].tipoSenyal + '-' + caracArray[i].codigoSenyal + '): ' + caracArray[i].descripcion;
                            if(i < (caracArray.size() - 1))
                            {
                                logString +='\n';
                            }
                        }
                        CBK_Log.debug(logString,logginglevel.INFO);
                    }    
                }
            }
        }

        return oObj;
    }

    /*
        Método para recuperar los datos de cliente y contacto de Alfabético desde RRSS.
    */
    static public Map<String,Object> getDataALFWSbyRRSS (String sIDToIdent, String sTipoReg, String sIdOrig, String sCanalRRSS, String sSocialPost, String sSocialPers, String sContactoId)
    {
        Map<String,Object> oObj = new Map<String,Object>();
/*        CC_TrazaInt__c oTraza;
        Set<String> oNumPer = new Set<String>();

        if (sIDToIdent != '')
        {
            // Recuperar configuración Alfabético.

            CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF_RRSS');

            if (oConfig != null)
            {
                // Preparar retorno del Servicio Web.
                CC_WS_ALF_RRSS.toredsocialsalidasi oRes;

                // No hay llamada HTTP implementada. Todo es Apex2WSDL.
                Boolean bHttpRequest = oConfig.CC_HttpRequest__c;

                // TO_DO. GESTIÓN TEST.

                // Comprobación formato Id Twitter.
                if (sCanalRRSS == 'Twitter')
                {
                    if (!sIDToIdent.startsWith('@'))
                    {
                        sIDToIdent = '@' + sIDToIdent;
                    }
                }

                // Llamada vía AP2WSDL.
                Map<String,Object> oRetInt = CC_WS_Methods_ALF_RAW.getAP2WSDL_ALF_RRSS (oConfig, sIDToIdent, sIdOrig, sCanalRRSS);

                if (oRetInt.get('RETORNO') != null)
                    oRes = (CC_WS_ALF_RRSS.toredsocialsalidasi)oRetInt.get('RETORNO');
                
                if (oRetInt.get('TRAZA') != null)
                    oTraza = (CC_TrazaInt__c)oRetInt.get('TRAZA');

                // Recuperar la lista de NumPer devueltos por Alfabético.
                if (oRes != null)
                {
                    oNumPer = getNumPerRespALFRRSS (sIDToIdent, oRes);

                    if (oNumPer.size() > 0)
                    {
                        oObj.put('NUMPER_RRSS', oNumPer);

                        // Vinculamos el contacto.
                        if (oNumPer.size() == 1 && sContactoId != '')
                        {
                            // Devolvemos el ID del contacto para actualizarlo.

                            /*List<String> oLAux = new List<String>(oNumPer);
                            Contact oContacto = new Contact();
                            oContacto.Id = sContactoId;
                            oContacto.Account = new Account(CC_NumPerso__c = oLAux[0]);
                            oContacto.CC_NumPerso__c = oLAux[0];

                            oObj.put('CONTACTO_ACT', oContacto);
                            oObj.put('CONTACTO_ACT_NP', oLAux[0]);
                            oLAux.clear();
                            oLAux =  null;*/

/*                            List<String> oLAux = new List<String>(oNumPer);
                            oObj.put('CONTACTO_ACT', sContactoId);
                            oObj.put('CONTACTO_ACT_NP', oLAux[0]);
                            oLAux.clear();
                            oLAux =  null;
                        }
                    }
                }

                // Incorporar la traza.
                if (oTraza != null)
                {
                    String sClave = 'TRAZA';
                    oObj.put(sClave, oTraza);
                }
            }
        }
*/

        return oObj;
    }

    /*
        Método para tratar la respuesta de Alfabético y convertirla a una colección de NumPerso.
    */
    static private Set<String> getNumPerRespALFRRSS (String sIdentRRSS, CC_WS_ALF_RRSS.toredsocialsalidasi oRes)
    {
        Set<String> oNewRes = new Set<String>();
/*        Boolean bVerificado = false;

        if (oRes != null)
        {
            if (oRes.idEntra != null)
            {
                // Control de verificación unitaria de la petición.
                if (sIdentRRSS == oRes.idEntra.trim().unescapeHtml4())
                {
                    bVerificado = true;
                }
            }
        }

        if (bVerificado)
        {
            if (oRes.lista != null)
            {
                // Recorrer los NumPer devueltos.
                for (CC_WS_ALF_RRSS.listaItem oDato : oRes.lista)
                {
                    if (oDato.numPerso != null)
                    {
                        String sAux = String.valueOf(oDato.numPerso);
                        if (sAux != '')
                        {
                            oNewRes.add(sAux);
                        }
                    }
                }
            }
        }*/

        return oNewRes;
    }

    /*
        Método para recuperar los datos de cliente y contacto de Alfabético desde Documento de identidad.
    */
    static public Map<String,Object> getDataALFWSbyDOC (String sIDToIdent, String sTipoReg, String sIdOrig, String sCuentaId, String sContactoId, CC_InterfaceSettings__mdt oConfig)
    {
        Map<String,Object> oObj = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        Set<String> oNumPer = new Set<String>();

        if (sIDToIdent != '')
        {
            // Recuperar configuración Alfabético.
			/**String sInterfaz = 'CC_Int_ALF_DOC';

            switch on CC_MetodosUtiles.getApplicationName(){
                when 'SAC'
                {
                    sInterfaz = 'SAC_Int_ALF_DOC';
                }
                when else {
                    sInterfaz = 'CC_Int_ALF_DOC';
                }
            }
            System.Debug('sInterfaz:' + sInterfaz);

            CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody (sInterfaz);*/

            if (oConfig != null)
            {
                // Preparar retorno del Servicio Web.
                CC_WS_ALF_SearchDP.outbuspersonadatospersonalesws oRes;

                // No hay llamada HTTP implementada. Todo es Apex2WSDL.
                Boolean bHttpRequest = oConfig.CC_HttpRequest__c;

                // Llamada vía AP2WSDL.
                Map<String,Object> oRetInt = CC_WS_Methods_ALF_RAW.getAP2WSDL_ALF_DOC (oConfig, sIDToIdent, sTipoReg, sIdOrig);

                if (oRetInt.get('RETORNO') != null)
                    oRes = (CC_WS_ALF_SearchDP.outbuspersonadatospersonalesws)oRetInt.get('RETORNO');
                
                if (oRetInt.get('TRAZA') != null)
                    oTraza = (CC_TrazaInt__c)oRetInt.get('TRAZA');

                // Recuperar la lista de NumPer devueltos por Alfabético.
                if (oRes != null)
                {
                    oNumPer = getNumPerRespALFDOC (sIDToIdent, oRes);

                    if (oNumPer.size() > 0)
                    {
                        oObj.put('NUMPER_DOC', oNumPer);

                        // Devolvemos la estructura de una persona identificada.
                        //if (oNumPer.size() == 1)
                        if (oNumPer.size() == 1 && (sContactoId != '' || sCuentaId != ''))
                        {
                            List<String> oLAux = new List<String>(oNumPer);

                            if (sContactoId != '')
                            {
                                oObj.put('CONTACTO_ACT', sContactoId);
                                oObj.put('CONTACTO_ACT_NP', oLAux[0]);
                            }

                            if (sCuentaId != '')
                            {
                                oObj.put('CUENTA_ACT', sCuentaId);
                                oObj.put('CUENTA_ACT_NP', oLAux[0]);
                            }

                            oLAux.clear();
                            oLAux =  null;
                        }
                    }
                }

                // Incorporar la traza.
                if (oTraza != null)
                {
                    String sClave = 'TRAZA';
                    oObj.put(sClave, oTraza);
                }
            }
        }


        return oObj;
    }

    /*
        Método para tratar la respuesta de Alfabético y convertirla a una colección de NumPerso.
    */
    static private Set<String> getNumPerRespALFDOC (String sIdentDOC, CC_WS_ALF_SearchDP.outbuspersonadatospersonalesws oRes)
    {
        Set<String> oNewRes = new Set<String>();
        Boolean bVerificado = false;

        if (oRes != null)
        {
            if (oRes.datosClientes != null)
            {
                for (Integer i=0;i<oRes.datosClientes.size();i++)
                {
                    if (oRes.datosClientes[i].numper != null)
                    {
                        oNewRes.add(String.valueOf(oRes.datosClientes[i].numper));
                    }

                    if (oRes.datosClientes[i].numpers != null)
                    {
                        oNewRes.add(String.valueOf(oRes.datosClientes[i].numpers));
                    }
                }
            }
        }

        return oNewRes;
    }

    /*
        Método para convertir la respuesta de representantes jurídicos de ALF a contactos
    */
    //static private List<CC_Representante_Contrato__c> getRepresentantesLegalesContactoJuridico (String sIdPersona, CC_GestionBastanteoALF.outextconslistarepre oRepresentantesALF)
    static private List<Contact> getRepresentantesLegalesContactoJuridico (String sIdPersona, CC_GestionBastanteoALF.outextconslistarepre oRepresentantesALF)
    {
        List<Contact> oRepresentantesRes = new List<Contact>();
        //List<CC_Representante_Contrato__c> oRepresentantesRes = new List<CC_Representante_Contrato__c>();

        if (oRepresentantesALF == null)
        {
            return oRepresentantesRes;
        }

        /* MODO TEST, QUITAR PARA PRUEBAS INTEGRADAS*/
        /*CC_GestionBastanteoALF.listaRepreItem oItem = new CC_GestionBastanteoALF.listaRepreItem();
        oItem.nif = '54534625S';
        oItem.nombre = 'PERSONA PRUEBA DEFINIDA';
        oItem.numperso = Decimal.valueOf(sIdPersona);
        oItem.indCaducidad = 'N';
        oItem.carrec = 'Director financiero';
        oItem.datosEscritura = 'Observaciones bastanteo';
        oItem.indFirmaDig = 'S';
        oItem.numperso = 88888888;
        List<CC_GestionBastanteoALF.listaRepreItem> oLista = new List<CC_GestionBastanteoALF.listaRepreItem>();
        oLista.add(oItem);
        oRepresentantesALF.listaRepre = oLista;*/

        /* FIN MODO TEST */

        if (oRepresentantesALF.listaRepre == null)
        {
            return oRepresentantesRes;
        }

        if (oRepresentantesALF.listaRepre.isEmpty())
        {
            return oRepresentantesRes;
        }

        if (String.isBlank(sIdPersona))
        {
            return oRepresentantesRes;
        }

        for (CC_GestionBastanteoALF.listaRepreItem oRepresentante : oRepresentantesALF.listaRepre)
        {
            /*
            public String carrec;
            public String datosEscritura;
            public Decimal dvtopod;
            public Decimal empresa;
            public Decimal fechaVencimiento;
            public String formatAct;
            public String indAccion;
            public String indCaducidad;
            public String indFirmaDig;
            public String nif;
            public String nombre;
            public Decimal numperso;
            public String ticketFirma;
            public String tipoFirma;
            public String tipoFirmaAnt;
            */

            String sNIF = '';
            String sNombreCompleto = '';
            String sNumPerso = sIdPersona;
            String sNumPersoContacto = '';
            String sCaducado = 'N';
            String sFirmaDigital = 'N';
            String sCargo = '';
            String sObservaciones = '';
            String sRelacion = 'Apoderado'; // Siempre es apoderado en esta integración.

            if (String.isNotBlank(oRepresentante.nif))
            {
                sNIF = oRepresentante.nif.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.nombre))
            {
                sNombreCompleto = oRepresentante.nombre.trim().unescapeHtml4();
            }

            if (oRepresentante.numperso != null)
            {
                sNumPersoContacto = String.valueOf(oRepresentante.numperso);
            }

            if (String.isNotBlank(oRepresentante.indCaducidad))
            {
                sCaducado = oRepresentante.indCaducidad.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.indFirmaDig))
            {
                sFirmaDigital = oRepresentante.indFirmaDig.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.carrec))
            {
                sCargo = oRepresentante.carrec.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.datosEscritura))
            {
                sObservaciones = oRepresentante.datosEscritura.trim().unescapeHtml4();
            }

            // Gestión datos obligatorios representante
            if (sNIF != '' && sNombreCompleto != '' && sNumPerso != '')
            {
                // Descomposición del nombre completo.
                String sNombre = '';
                String sApellido1 = '';
                String sApellido2 = '';

                List<String> oDataNom = getNombreSeparado (sNombreCompleto);
                if (oDataNom.size() == 3)
                {
                    sNombre = oDataNom[0];
                    sApellido1 = oDataNom[1];
                    sApellido2 = oDataNom[2];
                }else{
                    // Tratamiento valor obligatorio.
                    sApellido1 = sNombreCompleto;
                }

                Contact oNuevoRepresentante = new Contact();
                oNuevoRepresentante.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
                oNuevoRepresentante.FirstName = sNombre;
                oNuevoRepresentante.LastName = sApellido1 + ' ' + sApellido2;
                oNuevoRepresentante.CC_CuentaRepresentada__r = new Account(CC_NumPerso__c = sNumPerso);
                oNuevoRepresentante.CC_NumPerso__c = sNumPerso + '_' + sNIF;
                oNuevoRepresentante.CC_NumPersoAsoc__c = sNumPersoContacto;
                oNuevoRepresentante.CC_Numero_Documento__c = sNIF;
				oNuevoRepresentante.CC_CargoRepresentante__c = sCargo.left(40);
				oNuevoRepresentante.CC_TipoRepresentante__c = sRelacion;
				oNuevoRepresentante.CC_Observaciones__c = sObservaciones.left(500);
				oNuevoRepresentante.Account = new Account(CC_NumPerso__c = sNumPerso);
                
                if (sFirmaDigital == 'S')
                {
                    oNuevoRepresentante.CC_FirmaDigitalizada__c = true;
                }else{
                    oNuevoRepresentante.CC_FirmaDigitalizada__c = false;
                }

                if (sCaducado == 'S')
                {
                    oNuevoRepresentante.CC_Inactivo__c = true;
                }else{
                    oNuevoRepresentante.CC_Inactivo__c = false;
                }

                oRepresentantesRes.add(oNuevoRepresentante);

                /*CC_Representante_Contrato__c oNuevoRepresentante = new CC_Representante_Contrato__c();
                oNuevoRepresentante.RecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
                oNuevoRepresentante.Name = sNombreCompleto.left(80);
                oNuevoRepresentante.CC_Nombre__c = sNombre.left(50);
                oNuevoRepresentante.CC_Apellido1__c = sApellido1.left(50);
                oNuevoRepresentante.CC_Apellido2__c = sApellido2.left(50);
                oNuevoRepresentante.CC_ClienteRepresentante__r = new Account(CC_NumPerso__c = sNumPerso);
                oNuevoRepresentante.CC_IdExterno__c = sNumPerso + '_' + sNIF;
                oNuevoRepresentante.CC_NumPerso__c = sNumPerso;
                oNuevoRepresentante.CC_NumPerso_Representante__c = sNumPersoContacto;
                oNuevoRepresentante.CC_NumeroDocumento__c = sNIF.left(10);
                oNuevoRepresentante.CC_CargoRepresentante__c = sCargo.left(40);
                oNuevoRepresentante.CC_Observaciones__c = sObservaciones.left(500);
                oNuevoRepresentante.CC_TipoRepresentante__c = sRelacion;

                if (sCaducado == 'S')
                {
                    oNuevoRepresentante.CC_Inactivo__c = true;
                }else{
                    oNuevoRepresentante.CC_Inactivo__c = false;
                }

                if (sFirmaDigital == 'S')
                {
                    oNuevoRepresentante.CC_FirmaDigitalizada__c = true;
                }else{
                    oNuevoRepresentante.CC_FirmaDigitalizada__c = false;
                }

                oRepresentantesRes.add(oNuevoRepresentante);*/
            }

        }

        return oRepresentantesRes;
    }

    /*
        Método para recuperar los datos de representantes de un cliente jurídico.
    */
    static public Map<String,Object> getDataALFWS_RepresentantesJuridicos (String sIDToIdent, String sIdOrig, CC_InterfaceSettings__mdt oConfig)
    {
        Map<String,Object> oObj = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        //Set<String> oNumPer = new Set<String>();
        List<Contact> oRepresentantes = new List<Contact>();
        //List<CC_Representante_Contrato__c> oRepresentantes = new List<CC_Representante_Contrato__c>();

        if (sIDToIdent != '')
        {
            /**String sInterfaz = 'CC_Int_ALF_REP_JUR';
            switch on CC_MetodosUtiles.getApplicationName(){
                when 'SAC'
                {
                    sInterfaz = 'SAC_Int_ALF_REP_JUR';
                }
                when else {
                    sInterfaz = 'CC_Int_ALF_REP_JUR';
                }
            }
            // Recuperar configuración Alfabético.

            CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody (sInterfaz);*/

            if (oConfig != null)
            {
                // Preparar retorno del Servicio Web.
                CC_GestionBastanteoALF.outextconslistarepre oRes;

                // No hay llamada HTTP implementada. Todo es Apex2WSDL.
                Boolean bHttpRequest = oConfig.CC_HttpRequest__c;

                // Llamada vía AP2WSDL.
                Map<String,Object> oRetInt = CC_WS_Methods_ALF_RAW.getAP2WSDL_ALF_Representantes_Juridico (oConfig, sIDToIdent, sIdOrig);

                if (oRetInt.get('RETORNO') != null)
                    oRes = (CC_GestionBastanteoALF.outextconslistarepre)oRetInt.get('RETORNO');
                
                if (oRetInt.get('TRAZA') != null)
                    oTraza = (CC_TrazaInt__c)oRetInt.get('TRAZA');

                // Recuperar la lista de representantes de las cuentas jurídicas y convertir a lista de contactos.
                oRepresentantes = getRepresentantesLegalesContactoJuridico (sIDToIdent, oRes);

                if (oRepresentantes != null)
                {
                    if (!oRepresentantes.isEmpty())
                    {
                        oObj.put('REPR_JURIDICO', oRepresentantes);
                    }
                }

                // Incorporar la traza.
                if (oTraza != null)
                {
                    oObj.put('TRAZA', oTraza);
                }
            }
        }


        return oObj;
    }

    /*
        Método para convertir la respuesta de representantes de personas físicas de ALF a contactos
    */
/*
    static private List<CC_Representante_Contrato__c> getRepresentantesLegalesContactoFisico (String sIdPersona, CC_GestionPersRelacionadas.outextconsultapers oRepresentantesALF)
    {
        //List<Contact> oContactosRes = new List<Contact>();
        List<CC_Representante_Contrato__c> oRepresentantesRes = new List<CC_Representante_Contrato__c>();

        if (oRepresentantesALF == null)
        {
            return oRepresentantesRes;
        }

        if (oRepresentantesALF.listDadesRel == null)
        {
            return oRepresentantesRes;
        }

        if (oRepresentantesALF.listDadesRel.isEmpty())
        {
            return oRepresentantesRes;
        }

        if (String.isBlank(sIdPersona))
        {
            return oRepresentantesRes;
        }

        for (CC_GestionPersRelacionadas.dadesRel oRepresentante : oRepresentantesALF.listDadesRel)
        {
            String sTipoRel = '';
            String sRelCancelada = 'N';
            String sTitularPrincipal = 'Y';
            String sTipoDoc = '';
            String sNIF = '';
            String sNombreCompleto = '';
            String sNumPerso = sIdPersona;
            String sNumPersoContacto = '';
            String sFechaNacimiento = '';
            String sSexo = '';
            String sIdioma = '';

            if (oRepresentante.tiprel != null)
            {
                sTipoRel = String.valueOf(oRepresentante.tiprel);
            }

            if (String.isNotBlank(oRepresentante.indrela))
            {
                sRelCancelada = oRepresentante.indrela.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.tituprin))
            {
                sTitularPrincipal = oRepresentante.tituprin.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.tipdoc))
            {
                sTipoDoc = oRepresentante.tipdoc.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.nifperso))
            {
                sNIF = oRepresentante.nifperso.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.nomperso))
            {
                sNombreCompleto = oRepresentante.nomperso.trim().unescapeHtml4();
            }

            if (oRepresentante.numperso != null)
            {
                sNumPersoContacto = String.valueOf(oRepresentante.numperso);
            }

            if (oRepresentante.fnacim != null)
            {
                sFechaNacimiento = String.valueOf(oRepresentante.fnacim);
            }

            if (String.isNotBlank(oRepresentante.sexo))
            {
                sSexo = oRepresentante.sexo.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.idioma))
            {
                sIdioma = oRepresentante.idioma.trim().unescapeHtml4();
            }

            // Gestión datos obligatorios representante
            if (sNIF != '' && sNombreCompleto != '' && sNumPerso != '')
            {
                // Descomposición del nombre completo.
                String sNombre = '';
                String sApellido1 = '';
                String sApellido2 = '';

                List<String> oDataNom = getNombreSeparado (sNombreCompleto);
                if (oDataNom.size() == 3)
                {
                    sNombre = oDataNom[0];
                    sApellido1 = oDataNom[1];
                    sApellido2 = oDataNom[2];
                }else{
                    // Tratamiento valor obligatorio.
                    sApellido1 = sNombreCompleto;
                }

                // Tratar campos a formato Salesforce. Fecha nacimiento, idioma, sexo.
                // Pendiente disponer conversiones.

                CC_Representante_Contrato__c oNuevoRepresentante = new CC_Representante_Contrato__c();
                oNuevoRepresentante.RecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
                oNuevoRepresentante.Name = sNombreCompleto.left(80);
                oNuevoRepresentante.CC_Nombre__c = sNombre.left(50);
                oNuevoRepresentante.CC_Apellido1__c = sApellido1.left(50);
                oNuevoRepresentante.CC_Apellido2__c = sApellido2.left(50);
                oNuevoRepresentante.CC_ClienteRepresentante__r = new Account(CC_NumPerso__c = sNumPerso);
                oNuevoRepresentante.CC_IdExterno__c = sNumPerso + '_' + sNIF;
                oNuevoRepresentante.CC_NumPerso__c = sNumPerso;
                oNuevoRepresentante.CC_NumPerso_Representante__c = sNumPersoContacto;
                oNuevoRepresentante.CC_NumeroDocumento__c = sNIF;
                oNuevoRepresentante.CC_TipoRepresentante__c = 'Representante legal'; // MODO DEBUG.
                oNuevoRepresentante.CC_Inactivo__c = false;
                oNuevoRepresentante.CC_FirmaDigitalizada__c = false;

                oRepresentantesRes.add(oNuevoRepresentante);
            }

        }

        return oRepresentantesRes;
    }
*/
    /*
        Método para convertir la respuesta de representantes de personas físicas de ALF a contactos
    */
/*    
    static private List<CC_Representante_Contrato__c> getRelacionRepresentantesyContratos (String sIdPersona, List<CC_Representante_Contrato__c> oRepresentantes, String sEmpresa, String sArea, String sOficina, String sContrato)
    {
        List<CC_Representante_Contrato__c> oRepresentantesContratos = new List<CC_Representante_Contrato__c>();

        if (oRepresentantes == null)
        {
            return oRepresentantesContratos;
        }

        if (oRepresentantes.isEmpty())
        {
            return oRepresentantesContratos;
        }

        if (String.isBlank(sIdPersona) || String.isBlank(sEmpresa) || String.isBlank(sArea) || String.isBlank(sOficina) || String.isBlank(sContrato))
        {
            return oRepresentantesContratos;
        }

        for (CC_Representante_Contrato__c oRepresentante : oRepresentantes)
        {
            String sClaveRepresentante = oRepresentante.CC_IdExterno__c;
            String sClaveContrato = sIdPersona + '_' + sEmpresa + '_' + sArea + '_' + sOficina + '_' + sContrato;

            CC_Representante_Contrato__c oNuevaRelacion = new CC_Representante_Contrato__c();
            oNuevaRelacion.RecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_RepresentanteContrato').getRecordTypeId();
            oNuevaRelacion.Name = (sClaveRepresentante + '-' +sClaveContrato).left(80);
            oNuevaRelacion.CC_ContratoAsociado__r = new CC_Representante_Contrato__c(CC_IdExterno__c = sClaveContrato);
            oNuevaRelacion.CC_RepresentanteAsociado__r = new CC_Representante_Contrato__c(CC_IdExterno__c = sClaveRepresentante);
            oNuevaRelacion.CC_IdExterno__c = sClaveRepresentante + '-' +sClaveContrato;
            oNuevaRelacion.CC_NumPerso__c = sIdPersona;
            oNuevaRelacion.CC_Inactivo__c = false;

            oRepresentantesContratos.add(oNuevaRelacion);
        }

        return oRepresentantesContratos;
    }
*/
    /*
        Método para recuperar los datos de representantes de un cliente físico.
    */
/*   
 	static public Map<String,Object> getDataALFWS_RepresentantesFisicos (String sIDToIdent, String sIdOrig, String sEmpresa, String sArea, String sOficina, String sContrato)
    {
        Map<String,Object> oObj = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        //List<Contact> oContactos = new List<Contact>();
        List<CC_Representante_Contrato__c> oRepresentantes = new List<CC_Representante_Contrato__c>();
        List<CC_Representante_Contrato__c> oRepresentanteContratos = new List<CC_Representante_Contrato__c>();

        if (sIDToIdent != '')
        {
            // Recuperar configuración Alfabético.

            CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF_REP_FIS');

            if (oConfig != null)
            {
                // Preparar retorno del Servicio Web.
                CC_GestionPersRelacionadas.outextconsultapers oRes;

                // No hay llamada HTTP implementada. Todo es Apex2WSDL.
                Boolean bHttpRequest = oConfig.CC_HttpRequest__c;

                // Llamada vía AP2WSDL.
                Map<String,Object> oRetInt = CC_WS_Methods_ALF_RAW.getAP2WSDL_ALF_Representantes_Fisicas (oConfig, sEmpresa, sArea, sOficina, sContrato, sIDToIdent, sIdOrig);

                if (oRetInt.get('RETORNO') != null)
                    oRes = (CC_GestionPersRelacionadas.outextconsultapers)oRetInt.get('RETORNO');
                
                if (oRetInt.get('TRAZA') != null)
                    oTraza = (CC_TrazaInt__c)oRetInt.get('TRAZA');

                // Recuperar la lista de representantes de las cuentas jurídicas y convertir a lista de contactos.
                oRepresentantes = getRepresentantesLegalesContactoFisico (sIDToIdent, oRes);

                // Generar la unión de contratos y representantes.
                oRepresentanteContratos = getRelacionRepresentantesyContratos (sIDToIdent, oRepresentantes, sEmpresa, sArea, sOficina, sContrato);

                if (oRepresentantes != null)
                {
                    if (!oRepresentantes.isEmpty())
                    {
                        oObj.put('REPR_FISICO', oRepresentantes);
                    }
                }

                if (oRepresentanteContratos != null)
                {
                    if (!oRepresentanteContratos.isEmpty())
                    {
                        oObj.put('REL_REPR_FISICO_CONTRATO', oRepresentanteContratos);
                    }
                }

                // Incorporar la traza.
                if (oTraza != null)
                {
                    oObj.put('TRAZA', oTraza);
                }
            }
        }


        return oObj;
    }
*/

}