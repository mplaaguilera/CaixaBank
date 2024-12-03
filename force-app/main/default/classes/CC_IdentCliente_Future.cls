public with sharing class CC_IdentCliente_Future {
    /*
        Clase para identificación de clientes / contactos en enrutamientos Omnichannel.
    */

    /*
        Llamada Futura para invocar desde el Trigger de elementos a enrutar.
    */
    @future(callout=true)
    static public void CallUpdateALF (List<ID> oID) {
        /*
            TODO:
                Pendiente gestión actualización empresas.
                Pendiente nuevos orígenes de datos.
        */

        // Recuperar NumPerso del origen de datos.
        // El SObject ahora siempre estará NULL, no se utiliza por datos ya recuperados. No es necesario.
        Map<String,SObject> oNumPerRes = ObtenerNumPerOrigen(oID);


        // Tratar los registros identificados para actualizar su caso asociado.
        // Por fecha de refresco no se actualiza contra ALF.
        Map<String,SObject> oNumPer = new Map<String,SObject>();
        Set<String> oCasosUpd = new Set<String>();
        for (String sClave : oNumPerRes.keySet())
        {
            if (sClave.split('##')[0] == 'UPDCASO')
            {
                // Casos para actualizar.
                oCasosUpd.add(sClave);
            }else{
                // Registros a identificar.
                oNumPer.put(sClave, oNumPerRes.get(sClave));
            }
        }

        oNumPerRes.clear();
        oNumPerRes = null;

        // Si existen datos a actualizar, realizar gestión de identificación vía Alfabético y CLI.
        if (oNumPer.size() > 0)
        {
            ActualizarDatosALF (oNumPer);
        }

        // Actualizar casos identificados por fecha refresco.
        actualizarCasosIdentificados (oCasosUpd);
    }

    /*
        Llamada Futura para invocar desde el Trigger de elementos a enrutar.
    */
    @future(callout=true)
    static public void CallUpdateALFExistentes (List<ID> oID) {
    
        /*
            TODO:
                Pendiente gestión actualización empresas.
                Pendiente nuevos orígenes de datos.
        */

        // Recuperar NumPerso del origen de datos.
        // El SObject ahora siempre estará NULL, no se utiliza por datos ya recuperados. No es necesario.
        Map<String,SObject> oNumPer = ObtenerNumPerOrigenExistentes (oID);


        // Si existen datos a actualizar, realizar gestión de identificación vía Alfabético y CLI.
        if (oNumPer.size() > 0)
        {
            ActualizarDatosALF (oNumPer);
        }
    }

    /*
        Obtención de las cuentas y contactos a identificar en Alfabético y CLI del elemento enrutado.
    */
    static private Map<String,SObject> ObtenerNumPerOrigen (List<ID> oID)
    {
        Set<String> oLCTNP = new Set<String>();
        Set<String> oCNP = new Set<String>();
        Set<String> oPS = new Set<String>();
        Set<String> oCase = new Set<String>();
        Set<String> oSocialPost = new Set<String>();
        Set<String> oLlamada = new Set<String>();
        String sObjName = '';

        for (ID iIdent : oID)
        {
            // Recuperar objeto origen donde está el cliente identificado.
            // Tratados hasta el momento: LiveChatTranscript.
            sObjName = '';
            Schema.SObjectType oTipoObj = iIdent.getSobjectType();
            if (oTipoObj != null)
            {
                try {
                    sObjName = oTipoObj.getDescribe().getName();
                } catch (Exception e) {
                    sObjName = '';
                    CBK_Log.error('Error sObjName en metodo ObtenerNumPerOrigen' + e.getMessage());
                }
            }

            // Tratamiento origen LiveChatTranscript.
            if (sObjName == 'LiveChatTranscript')
            {
                oLCTNP.add(iIdent);
            }

            // Contacto.
            if (sObjName == 'Contact')
            {
                oCNP.add(iIdent);
            }

            // SocialPost. Identificación de RRSS.
            if (sObjName == 'SocialPost')
            {
                oSocialPost.add(iIdent);
            }

            // Caso. Identificación NumPer, Doc. Identidad y RRSS.
            if (sObjName == 'Case')
            {
                oCase.add(iIdent);
            }

            // Llamada. Identificación por NumPer.
            if (sObjName == 'CC_Llamada__c')
            {
                oLlamada.add(iIdent);
            }

            // TO_DO. Futuro. Próximos objetos a tener en cuenta.
        }

        Set<String> oSetNP = new Set<String>();

        // <LiveChatTranscript>. Recuperar los NumPerso asociados al chat.
        if (oLCTNP.size() > 0)
        {
            Set<String> oSetAux = getNumPersoLiveChat(oLCTNP);
            if (oSetAux.size() > 0)
            {
                // Incorporar NumPerso a la lista final.
                oSetNP.addAll(oSetAux);
            }

            // Limpiar objeto.
            oSetAux.clear();
            oSetAux = null;
        }

        // Limpiar objeto.
        oLCTNP.clear();
        oLCTNP = null;

        // <SocialPost>. Recuperar la identificación del Social Post.
        if (oSocialPost.size() > 0)
        {
            Set<String> oSetAux = getContactSocialPost(oSocialPost);
            if (oSetAux.size() > 0)
            {
                // Incorporar NumPerso a la lista final.
                oSetNP.addAll(oSetAux);
            }

            // Limpiar objeto.
            oSetAux.clear();
            oSetAux = null;
        }

        // <Case>. Recuperar la identificación de cliente del caso.
        if (oCase.size() > 0)
        {
            Set<String> oSetAux = getContactCase(oCase);
            if (oSetAux.size() > 0)
            {
                // Incorporar NumPerso a la lista final.
                oSetNP.addAll(oSetAux);
            }

            // Limpiar objeto.
            oSetAux.clear();
            oSetAux = null;
        }

        // <Llamada>. Recuperar los NumPer a identificar.
        if (!oLlamada.isEmpty())
        {
            Set<String> oSetAux = getNumPersoLlamada(oLlamada);
            if (oSetAux.size() > 0)
            {
                // Incorporar NumPerso a la lista final.
                oSetNP.addAll(oSetAux);
            }

            // Limpiar objeto.
            oSetAux.clear();
            oSetAux = null;
        }

        // TO_DO. Futuro. Próximos objetos a tener en cuenta.

        // Preparar la estructura de NumPerso a obtener.
        Map<String,SObject> oObj = new Map<String,SObject>();
        for (String sNum : oSetNP)
        {
            // Inicializamos el MAP.
            oObj.put(sNum, null);
        }

        // Limpiar objeto.
        oSetNP.clear();
        oSetNP = null;


        // Recuperar las cuentas y contactos que requieren actualización.
        // Incorpora la lógica de cálculo para determinar si se ha de actualizar o no.
        // El SObject ahora siempre estará NULL, no se utiliza por datos ya recuperados. No es necesario. Uso futuro.
        Map<String,SObject> oObjRes = CC_WS_Methods_ALF.getContactAccountByNumPerso(oObj);

        // Actualizar estructura retorno.
        oObj.clear();

        for (String sClave : oObjRes.keySet())
        {
            oObj.put(sClave, oObjRes.get(sClave));
        }


        return oObj;
    }

    /*
        Obtención de las cuentas y contactos a identificar en Alfabético y CLI del elemento enrutado.
    */
    static public Map<String,SObject> ObtenerNumPerOrigenExistentes (List<ID> oID)
    {
        Set<String> oLCTNP = new Set<String>();
        Set<String> oCNP = new Set<String>();
        Set<String> oPS = new Set<String>();
        String sObjName = '';

        for (ID iIdent : oID)
        {
            // Recuperar objeto origen donde está el cliente identificado.
            // Tratados hasta el momento: LiveChatTranscript.
            sObjName = '';
            Schema.SObjectType oTipoObj = iIdent.getSobjectType();
            if (oTipoObj != null)
            {
                try {
                    sObjName = oTipoObj.getDescribe().getName();
                } catch (Exception e) {
                    sObjName = '';
                    CBK_Log.error('Error sObjName en metodo ObtenerNumPerOrigenExistentes' + e.getMessage());
                }
            }

            // Tratamiento origen LiveChatTranscript.
            if (sObjName == 'LiveChatTranscript')
            {
                oLCTNP.add(iIdent);
            }

            // TO_DO. Futuro. Próximos objetos a tener en cuenta.
        }

        Set<String> oSetNP = new Set<String>();

        // <LiveChatTranscript>. Recuperar los NumPerso asociados al chat. Sólo existentes.
        if (oLCTNP.size() > 0)
        {
            Set<String> oSetAux = getNumPersoLCContact(oLCTNP);
            if (oSetAux.size() > 0)
            {
                // Incorporar NumPerso a la lista final.
                oSetNP.addAll(oSetAux);
            }

            // Limpiar objeto.
            oSetAux.clear();
            oSetAux = null;
        }

        // Limpiar objeto.
        oPS.clear();
        oPS = null;

        // TO_DO. Futuro. Próximos objetos a tener en cuenta.

        // Preparar la estructura de NumPerso a obtener.
        Map<String,SObject> oObj = new Map<String,SObject>();
        for (String sNum : oSetNP)
        {
            // Inicializamos el MAP.
            oObj.put(sNum, null);
        }

        // Limpiar objeto.
        oSetNP.clear();
        oSetNP = null;


        // Recuperar las cuentas y contactos que requieren actualización.
        // Incorpora la lógica de cálculo para determinar si se ha de actualizar o no.
        // El SObject ahora siempre estará NULL, no se utiliza por datos ya recuperados. No es necesario. Uso futuro.
        Map<String,SObject> oObjRes = CC_WS_Methods_ALF.getContactAccountByNumPerso(oObj);

        // Actualizar estructura retorno.
        oObj.clear();

        for (String sClave : oObjRes.keySet())
        {
             oObj.put(sClave, oObjRes.get(sClave));
        }


        return oObj;
    }

    /*
        Método para recuperar los NumPerso asociados al chat.
        El SET devuelto se genera como clave la siguiente información:

        NUMPERSO##TIPO_REGISTRO##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID

        Ahora el tipo de registro será Cliente, que se traducirá al RecordType de Clientes.
    */
    static public Set<String> getNumPersoLiveChat (Set<String> oLCT)
    {
        Set<String> oNumPer = new Set<String>();

        if (oLCT.size() > 0)
        {
            List<LiveChatTranscript> oChats = [SELECT Id, CC_NumPerso__c, CC_NumPerso2__c, CaseId, AccountId, ContactId FROM LiveChatTranscript WHERE Id IN :oLCT];
            for (LiveChatTranscript oChat : oChats)
            {
                if (oChat.CC_NumPerso__c != null && oChat.CC_NumPerso__c != '')
                {
                    // Añadir el NumPerso a la lista, si hay que llamar a Alfabético / CLI.
                    oNumPer.add(oChat.CC_NumPerso__c + '##Cliente##' + oChat.Id + '##N/A##N/A##' + oChat.AccountId + '##' + oChat.ContactId + '##' + oChat.CaseId);
                }

                if (oChat.CC_NumPerso2__c != null && oChat.CC_NumPerso2__c != '')
                {
                    // Añadir el NumPerso a la lista, si hay que llamar a Alfabético / CLI.
                    oNumPer.add(oChat.CC_NumPerso2__c + '##Cliente##' + oChat.Id + '##N/A##N/A##' + oChat.AccountId + '##' + oChat.ContactId + '##' + oChat.CaseId);
                }
            }
        }

        return oNumPer;
    }

    /*
        Método para recuperar los contactos del caso.

        El SET devuelto se genera como clave la siguiente información:

        ID_RRSS##RRSS##ID_ORIGEN##CANAL##SOCIALPOST##SOCIALPERSONA##CONTACTO_ID##CASO_ID --> Identificadores de RRSS a buscar en ALF.
        (PARA USO FUTURO). NUMPERSO##TIPO_REGISTRO##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID  --> Ahora el tipo de registro será Cliente, que se traducirá al RecordType de Clientes.
    */
    static private Set<String> getContactSocialPost (Set<String> oSetSocialPost)
    {
        Set<String> oCliOrig = new Set<String>();
        Map<String,String> oSPost = new Map<String,String>();

        // Buscar los datos asociados al post.
        if (oSetSocialPost != null)
        {
            if (oSetSocialPost.size() > 0)
            {
                List<SocialPost> oSPostAux = [SELECT Id, Handle, Provider, PersonaId, Persona.ParentId, ParentId FROM SocialPost WHERE Id IN :oSetSocialPost];
                for (SocialPost oPost : oSPostAux)
                {
                    String sClave = oPost.Handle + '##RRSS##' + oSPost.get(oPost.Id) + '##' + oPost.Provider + '##' + oPost.Id + '##' + oPost.PersonaId;
                    sClave = sClave + '##' + oPost.Persona.ParentId + '##' + oPost.ParentId;
                    oCliOrig.add(sClave);

                    // TEMPORAL. QUITAR.
                    //String sClave2 = '17880824@clubara.com##RRSS##' + oSPost.get(oPost.Id) + '##FAKE_TWITTER##' + oPost.Id + '##' + oPost.PersonaId;
                    //sClave2 = sClave2 + '##' + oPost.Persona.ParentId + '##' + oPost.ParentId;
                    //oCliOrig.add(sClave2);
                }
            }
        }

        return oCliOrig;
    }

    /*
        Método para identificar un cliente a partir de un caso generado.

        El SET devuelto se genera como clave la siguiente información:

        NUMPERSO##TIPO_REGISTRO##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID. Ahora el tipo de registro será Cliente, que se traducirá al RecordType de Clientes.
        ID_RRSS##RRSS##ID_ORIGEN##CANAL##SOCIALPOST##SOCIALPERSONA##CONTACTO_ID##CASO_ID --> Identificadores de RRSS a buscar en ALF.
        ID_DOC##DATADOC/DATATEL##ID_ORIGEN##N/A##N/A##N/A##CONTACTO_ID##CASO_ID --> Identificadores de Documentos de Identidad / Teléfonos a buscar en ALF.
    */
    static public Set<String> getContactCase (Set<String> oSetCase)
    {
        Set<String> oCliOrig = new Set<String>();
//        Map<String,String> oSPost = new Map<String,String>();

        if (oSetCase.size() > 0)
        {
            List<Case> oCases = [SELECT Id, CC_CuentaRRSS_CLI__c, CC_NumPerso__c, CC_Numero_Documento__c, Origin, SourceId, AccountId, ContactId FROM Case WHERE Id IN :oSetCase];
            for (Case oCase : oCases)
            {
                // Priorizamos la identificación del cliente por el siguiente orden:
                // NumPerso --> Doc. Identidad --> RRSS.

                String sClaveIdent = '';

                if (oCase.CC_NumPerso__c != null)
                {
                    if (oCase.CC_NumPerso__c != '')
                    {
                        // Identificación por NumPerso.
                        // NUMPERSO##TIPO_REGISTRO##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID
                        sClaveIdent = oCase.CC_NumPerso__c + '##Cliente##' + oCase.Id + '##';
                        sClaveIdent = sClaveIdent + 'N/A##N/A##' + oCase.AccountId;
                        sClaveIdent = sClaveIdent + '##' + oCase.ContactId + '##' + oCase.Id;
                    }
                }else if (oCase.CC_Numero_Documento__c != null)
                {
                    if (oCase.CC_Numero_Documento__c != '')
                    {
                        // Identificación por Doc. Identidad.
                        // ID_DOC##DATADOC/DATATEL##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID

                        // NOTA: Por ahora no pasamos el CONTACTO_ID, ya que no se crea previamente en el caso.
                        sClaveIdent = oCase.CC_Numero_Documento__c + '##DATADOC##' + oCase.Id + '##';
                        sClaveIdent = sClaveIdent + 'N/A##N/A##' + oCase.AccountId + '##' + oCase.ContactId;
                        sClaveIdent = sClaveIdent + '##' + oCase.Id;
                    }
                }else if (oCase.CC_CuentaRRSS_CLI__c != null)
                {
                    if (oCase.CC_CuentaRRSS_CLI__c != '')
                    {
                        // Identificación por RRSS.
                        // ID_RRSS##RRSS##ID_ORIGEN##CANAL##SOCIALPOST##SOCIALPERSONA##CONTACTO_ID##CASO_ID
                        sClaveIdent = oCase.CC_CuentaRRSS_CLI__c + '##RRSS##' + oCase.Id + '##';
                        sClaveIdent = sClaveIdent + oCase.Origin + '##' + oCase.SourceId + '##N/A';
                        sClaveIdent = sClaveIdent + '##N/A##' + oCase.Id;
                    }
                }

                // Añadir datos a identificar.
                if (sClaveIdent != '')
                {
                    oCliOrig.add(sClaveIdent);
                }

                // TO_DO. Otra lógica o SourceId a tratar.
            }
        }

        return oCliOrig;
    }

    /*
        Método para recuperar los NumPerso asociados al LiveChatTranscript.
        El SET devuelto se genera como clave la siguiente información:

        NUMPERSO##TIPO_REGISTRO##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID

        Ahora el tipo de registro será Cliente, que se traducirá al RecordType de Clientes.

        Método solo para contactos existentes.
    */
    static public Set<String> getNumPersoLCContact (Set<String> oPS)
    {
        Set<String> oNumPer = new Set<String>();
        Map<String,String> oNumPerMap = new Map<String,String>();
        Set<String> oAuxNumPer = new Set<String>();
        Map<String,String> oMapChat = new Map<String,String>();

        if (oPS.size() > 0)
        {
            // Buscar los contactos existentes.
            List<LiveChatTranscript> oListChat = [SELECT Id, CC_NumPerso__c, CC_NumPerso2__c, CaseId, AccountId, ContactId FROM LiveChatTranscript WHERE Id IN :oPS];
            for (LiveChatTranscript oAux : oListChat)
            {
                if (oAux.CC_NumPerso__c != '')
                {
                    oAuxNumPer.add(oAux.CC_NumPerso__c);
                    oMapChat.put(oAux.CC_NumPerso__c, oAux.CC_NumPerso__c + '##Cliente##' + oAux.Id + '##N/A##N/A##' + oAux.AccountId + '##' + oAux.ContactId + '##' + oAux.CaseId);
                }

                if (oAux.CC_NumPerso2__c != '')
                {
                    oAuxNumPer.add(oAux.CC_NumPerso2__c);
                    oMapChat.put(oAux.CC_NumPerso2__c, oAux.CC_NumPerso2__c + '##Cliente##' + oAux.Id + '##N/A##N/A##' + oAux.AccountId + '##' + oAux.ContactId + '##' + oAux.CaseId);
                }
            }

            // Recuperar los Account existentes.
            List<Account> oListAccount = [SELECT Id, CC_NumPerso__c FROM Account WHERE CC_NumPerso__c IN :oAuxNumPer];
            for (Account oAux : oListAccount)
            {
                //oNumPerMap.put(oAux.CC_NumPerso__c, oAux.CC_NumPerso__c + '##Cliente##' + oAux.Id);
                oNumPerMap.put(oAux.CC_NumPerso__c, oMapChat.get(oAux.CC_NumPerso__c));
            }

            // Recuperar los Contact existentes.
            List<Contact> oListContact = [SELECT Id, CC_NumPerso__c FROM Contact WHERE CC_NumPerso__c IN :oAuxNumPer];
            for (Contact oAux : oListContact)
            {
                //oNumPerMap.put(oAux.CC_NumPerso__c, oAux.CC_NumPerso__c + '##Cliente##' + oAux.Id);
                oNumPerMap.put(oAux.CC_NumPerso__c, oMapChat.get(oAux.CC_NumPerso__c));
            }

            for (String sClave : oNumPerMap.keySet())
            {
                oNumPer.add(oNumPerMap.get(sClave));
            }

        }

        // En modo test, no devolvemos NumPerso (evitar Callout ALF)
        if (Test.isRunningTest())
        {
            oNumPer.clear();
        }


        return oNumPer;
    }

    // POR AHORA DESCARTADO
    /*
        Método para recuperar los NumPerso asociados al contacto.
        El SET devuelto se genera como clave la siguiente información: NUMPERSO##TIPO_REGISTRO##ID_ORIGEN. Ahora el tipo de registro será Cliente,
        que se traducirá al RecordType de Clientes.

        Método solo para contactos nuevos.
    */
    /*static private Set<String> getNumPersoContactNew (Set<String> oCContact)
    {
        Set<String> oNumPer = new Set<String>();
        Set<String> oNoTratar = new Set<String>();

        if (oCContact.size() > 0)
        {
            List<Contact> oListContact = [SELECT Id, CC_NumPerso__c FROM Contact WHERE Id IN :oCContact];
            for (Contact oAux : oListContact)
            {
                if (oAux.CC_NumPerso__c != '')
                {
                    //oNoTratar.add(oAux.Id);
                    oNumPer.add(oAux.CC_NumPerso__c + '##Cliente##' + oAux.Id);
                }
            }

            //for (String sAux : oCContact)
            //{
            //    if (!oNoTratar.contains(sAux))
            //    {
            //        oNumPer.add(sAux);
            //    }
            //}
        }

        // En modo test, no devolvemos NumPerso (evitar Callout ALF)
        if (Test.isRunningTest())
        {
            oNumPer.clear();
        }


        return oNumPer;
    }*/

    /*
        Llamada para identificar una lista de documentos de identidad y teléfonos de forma síncrona.
        No actualiza datos de caso origen ni otros datos.
        Identifica los datos y devuelve los datos creados en Salesforce.
    */
    static public Map<String,Object> IdentificarPersALFSync (String sTipoBusqueda, String sBusqueda)
    {
        Map<String,Object> oRes = new Map<String,Object>();
        // Si no hay datos, salir.
        if (sBusqueda == '' || sBusqueda == null || sTipoBusqueda == '' || sTipoBusqueda == null)
        {
            return null;
        }

        // Búsqueda datos en Alfabético (Síncrono).
        Map<String, String> oNumDoc = new Map<String, String>();
        String sALFBusqueda = sTipoBusqueda;
        Boolean bBuscar = true;

        if (sALFBusqueda == 'DOC' || sALFBusqueda == 'TEL')
            {sALFBusqueda = 'DATA' + sALFBusqueda;}
        else if (sALFBusqueda == 'NP')
        {
            sALFBusqueda = 'Cliente';

            // Las búsquedas por NumPerso son automáticas, incorporar si se ha de realizar llamada a ALF por fecha de refresco.
            Set<String> oNumPerIni = new Set<String>();
            oNumPerIni.add(sBusqueda);
            Set<String> oNumPerAct = getNumPerSinActualizar (oNumPerIni);

            if (oNumPerAct.isEmpty())
            {
                // NumPer Actualizado.
                bBuscar = false;
            }
        }

        if (bBuscar)
        {
            oNumDoc.put(sBusqueda,sALFBusqueda);
            CC_IdentCliente_Future.CallUpdatePERSALFSync(oNumDoc);
        }

        // Tras refrescar la información, buscar datos en la BBDD.
        List<Contact> oContactos = new List<Contact>();
        List<Account> oCuentas = new List<Account>();
        List<Contact> oRepresentantes = new List<Contact>();

        if (sTipoBusqueda == 'DOC')
        {
            // Buscar en contactos.
            //String sRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            //oContactos = [SELECT Id, AccountId, Name, Account.Name FROM Contact WHERE Account.CC_Numero_Documento__c = :sBusqueda AND Account.CC_NumPerso__c <> null AND RecordTypeId = :sRecordType];

            // Buscar en cuentas (aquellos que no hemos encontrado en contactos)
            String sRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            String sClientePARecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
            oCuentas = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = :sBusqueda AND CC_NumPerso__c <> null AND (RecordTypeId = :sRecordType OR RecordTypeId = :sClientePARecordType)];

        }else if (sTipoBusqueda == 'TEL') {
            // Buscar en canales de comunicación.
            String sRecordType = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
            sBusqueda = '%' + sBusqueda;
            List<CC_Canal_Com__c> oCanales = [SELECT Id, CC_CuentaId__c, CC_ContactoId__c FROM CC_Canal_Com__c WHERE CC_TelefonoIDX__c LIKE :sBusqueda AND RecordTypeId = :sRecordType];

            Set<String> oIDs = new Set<String>();
            for (CC_Canal_Com__c oCanal : oCanales)
            {
                if (oCanal.CC_ContactoId__c != null)
                    {oIDs.add(oCanal.CC_ContactoId__c);}

                if (oCanal.CC_CuentaId__c != null)
                    {oIDs.add(oCanal.CC_CuentaId__c);}
            }

            // Buscar en contactos.
            //sRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            //oContactos = [SELECT Id, AccountId, Name, Account.Name FROM Contact WHERE Id IN :oIDs AND CC_NumPerso__c <> null AND RecordTypeId = :sRecordType];

            // Buscar en cuentas (aquellos que no hemos encontrado en contactos)
            sRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            String sClientePARecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
            oCuentas = [SELECT Id, Name FROM Account WHERE Id = :oIDs AND CC_NumPerso__c <> null AND (RecordTypeId = :sRecordType OR RecordTypeId = :sClientePARecordType)];
        }else if (sTipoBusqueda == 'NP') {
            // Buscar en cuentas.
            String sClienteRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            String sClientePARecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
            oCuentas = [SELECT Id, Name FROM Account WHERE CC_NumPerso__c = :sBusqueda AND (RecordTypeId = :sClienteRecordType OR RecordTypeId = :sClientePARecordType)];
            // Buscar contactos de la cuenta.
            List<ID> oAuxCli = new List<ID>();
            for (Account oCliente : oCuentas)
            {
                oAuxCli.add(oCliente.Id);
            }

            //sRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            //oContactos = [SELECT Id, AccountId, Name, Account.Name FROM Contact WHERE AccountId IN :oAuxCli AND RecordTypeId = :sRecordType];
            String sRTRep = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
            oContactos = [SELECT Id, AccountId, Name, Account.Name
                            FROM Contact
                            WHERE AccountId IN :oAuxCli
                            AND RecordTypeId <> :sRTRep];

            // Modificación para representantes e identificación de llamadas automática.
            oRepresentantes = [SELECT Id, AccountId, Name, Account.Name
                                FROM Contact
                                WHERE CC_CuentaRepresentada__c IN :oAuxCli
                                AND RecordTypeId = :sRTRep];
        }

        // Devolver los datos encontrados.
        if (!oContactos.isEmpty())
        {
            oRes.put('CONTACTOS', oContactos);
        }
        oRes.put('CUENTAS', oCuentas);

        if (!oRepresentantes.isEmpty())
        {
            oRes.put('REPRESENTANTES', oRepresentantes);
        }


        return oRes;
    }

    /*
        Llamada para identificar una lista de documentos de identidad y teléfonos.
        No actualiza datos de caso origen ni otros datos.
    */
    static private void CallUpdatePERSALFSync (Map<String, String> oDatos)
    {
        Map<String,SObject> oMapData = new Map<String,SObject>();

        if (oDatos != null)
        {
            for (String sClave : oDatos.keySet())
            {
                if (oDatos.get(sClave) != null)
                {
                    String sValor = sClave + '##' + oDatos.get(sClave) + '##N/A##N/A##N/A##N/A##N/A##N/A';
                    oMapData.put(sValor, null);
                }
            }


            // Llamar a Alfabético.
            ActualizarDatosALF (oMapData);
        }
    }

    /*
        Obtención de las cuentas y contactos a identificar en Alfabético y CLI del elemento enrutado.
        El MAP de entrada ya viene tratado para realizar las llamadas a Alfabético / CLI.
        El MAP de entrada tiene clave la siguiente información:

        NUMPERSO##TIPO_REGISTRO##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID. Ahora el tipo de registro será Cliente, que se traducirá al RecordType de Clientes.
        ID_RRSS##RRSS##ID_ORIGEN##CANAL##SOCIALPOST##SOCIALPERSONA##CONTACTO_ID##CASO_ID --> Identificadores de RRSS a buscar en ALF.
        ID_DOC##DATADOC/DATATEL##ID_ORIGEN##N/A##N/A##N/A##CONTACTO_ID##CASO_ID --> Identificadores de Documentos de Identidad / Teléfonos a buscar en ALF.

        El SObject de entrada por ahora será NULL, no se utiliza. Uso futuro.

        Mejoras futuras de rendimiento:
            * Priorizar datos a crear de 0 frente a los que hay que actualizar. Realizar dos llamadas con un input nuevo: Boolean bNuevos)
    */
    static private void ActualizarDatosALF (Map<String,SObject> oNumPer)
    {
        // Lista de clientes a actualizar / insertar.
        List<Account> oAccount = new List<Account>();
		List<Account> oAccountCLI = new List<Account>();
        List<Account> oAccountFechaRefresh = new List<Account>();
        List<Account> oAccountConvRT = new List<Account>();
        List<Contact> oContactConvRT = new List<Contact>();
        List<Account> oAccountConvName = new List<Account>();
        List<Account> oAccountConvNamePA = new List<Account>();
        List<Account> oAccountConvNameUpdate = new List<Account>();
        List<Account> oAccountUpdANumPer = new List<Account>();

        // Lista de contactos a actualizar / insertar.
        List<Contact> oContact = new List<Contact>();
        List<Contact> oContactFechaRefresh = new List<Contact>();

        // Lista de oficinas gestoras para actualizar en cliente.
        //List<Contact> oOficina = new List<Contact>();
        List<Account> oOficina = new List<Account>();
        List<Account> oOficinaEmp = new List<Account>();

        // Lista de canales de comunicación a crear.
        List<CC_Canal_Com__c> oCanalComNew = new List<CC_Canal_Com__c>();

        // Lista de canales de comunicación a actualizar.
        List<CC_Canal_Com__c> oCanalComUp = new List<CC_Canal_Com__c>();

        // Canales de comunicación potenciales de crear. Se revisa y se divide en las dos listas anteriores.
        Map<String,CC_Canal_Com__c> oPotCrear = new Map<String,CC_Canal_Com__c>();

        // Lista de canales de comunicación a crear (Contactos empresas o particulares especiales)
        List<CC_Canal_Com__c> oCanalAccComNew = new List<CC_Canal_Com__c>();

        // Lista de canales de comunicación a actualizar (Contactos empresas o particulares especiales)
        List<CC_Canal_Com__c> oCanalAccComUp = new List<CC_Canal_Com__c>();

        // Canales de comunicación potenciales de crear (Empresas o particulares especiales).
        // Se revisa y se divide en dos listas anteriores.
        Map<String,CC_Canal_Com__c> oPotAccCrear = new Map<String,CC_Canal_Com__c>();

        // Contactos potenciales de crear (Empresas o particulares especiales).
        Map<String,String> oContPotAccCrear = new Map<String,String>();

        // Lista de contactos para actualizar (Empresas)
        List<Contact> oContactUp = new List<Contact>();

        // Lista de contactos para crear (Empresas)
        List<Contact> oContactNew = new List<Contact>();

        // Lista de trazas a crear.
        List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();

        // Lista de NumPer y SocialPersona. Tratamiento de revinculación / actualización.
        Map<String,String> oNumPerSocial = new Map<String,String>();

        // Lista para actualizar la cuenta padre del contacto.
        Map<String,Contact> oContAccount = new Map<String,Contact>();

        // Lista para actualizar la cuenta identificada.
        Map<String,Account> oAccAccount = new Map<String,Account>();

        // Lista para actualizar el NumPer en particulares de contactos existentes.
        Map<String,Contact> oContNumPer = new Map<String,Contact>();

        // Lista para actualizar el NumPer de cuentas existentes.
        Map<String,Account> oAccNumPer = new Map<String,Account>();

        // Actualizar datos del posible caso origen.
        Map<String,Case> oCasosUp = new Map<String,Case>();

        // Lista para actualizar los contactos a confidenciales de los ya existentes.
        //Map<String,Contact> oContConfi = new Map<String,Contact>();

        // Reintentar actualización datos.
        Boolean bReintento = false;

        // Recuperar las listas de valores a tratar por Alfabético.
        List<String> oLista = new List<String>();
        oLista.add('CC_Idioma_ALF');
        oLista.add('CC_Sexo_ALF');
        oLista.add('CC_ClaseCom_ALF');
        oLista.add('CC_TipoCom_ALF');
        Map<String, Object> oParamAux = CC_MetodosUtiles.getLOVMeta(oLista);

        // Recuperar las listas de valores a tratar por CLI.
        List<String> oListaCLI = new List<String>();
        oListaCLI.add('CC_Segmento_CLI');
        oListaCLI.add('CC_Subsegmento_CLI');
        Map<String, Object> oParamAuxCLI = CC_MetodosUtiles.getLOV(oListaCLI);

        // Lista de búsqueda de canales de comunicación telefónico.
        List<String> oCComSearch = new List<String>();

        // Lista de búsqueda de canales de comunicación e-mail.
        List<String> oCComSearch2 = new List<String>();

        // Lista de búsqueda de contactos.
        List<String> oContAccSearch = new List<String>();

        // Representantes jurídicos.
        //List<CC_Representante_Contrato__c> oRepresentantesJuridicos = new List<CC_Representante_Contrato__c>();
        List<Contact> oRepresentantesJuridicos = new List<Contact>();

        // Representantes personas físicas.
        //List<CC_Representante_Contrato__c> oRepresentantesFisicas = new List<CC_Representante_Contrato__c>();

        // Representantes personas físicas y sus contratos
        //List<CC_Representante_Contrato__c> oRepresentantesContratos = new List<CC_Representante_Contrato__c>();

        // Contratos de un cliente.
        //List<CC_Representante_Contrato__c> oContratosCliente = new List<CC_Representante_Contrato__c>();

        // NumPers tratados contra Alfabético.
        Set<String> oNumPerAlfabetico = new Set<String>();

        // Set de Numper a borrar duplicados.
        Set<String> setNumPerDuplicados = new Set<String>();
        List<Account> oAccTest = [SELECT Id FROM Account LIMIT 1];
        List<Contact> oContTest = [SELECT Id FROM Contact LIMIT 1];
        CC_InterfaceSettings__mdt configCLI = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_CLI');
        String sInterfaz = 'CC_Int_ALF_REP_JUR';
        String sInterfazDOC = 'CC_Int_ALF_DOC';
        String sInterfazIntALF = 'CC_Int_ALF';

            switch on CC_MetodosUtiles.getApplicationName(){
                when 'SAC', 'Reclamaciones'
                {
                    sInterfaz = 'SAC_Int_ALF_REP_JUR';
                    sInterfazDOC = 'SAC_Int_ALF_DOC';
                    sInterfazIntALF = 'SAC_Int_ALF';
                }
                when else {
                    sInterfaz = 'CC_Int_ALF_REP_JUR';
                    sInterfazDOC = 'CC_Int_ALF_DOC';
                    sInterfazIntALF = 'CC_Int_ALF';
                }
            }
            // Recuperar configuración Alfabético.

        CC_InterfaceSettings__mdt oConfigALF = CC_MetodosUtiles.getInterfazConfigBody (sInterfaz);
        CC_InterfaceSettings__mdt configPartyReferenceMdt = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_ObtenerSenalesCliente');
        CC_InterfaceSettings__mdt oConfigDOC = CC_MetodosUtiles.getInterfazConfigBody (sInterfazDOC);
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody (sInterfazIntALF);

        for (String sNumPer : oNumPer.keySet())
        {
            if (sNumPer != '')
            {
                // TO_DO: Llamada al WebService Alfabético.
                // TO_DO. Lógica de actualización alfabético.

                Boolean bIdentNumPer = false;

                // Recuperar datos de la clave a tratar. NUMPERSO##TIPO_REGISTRO##ID_ORIGEN
                List<String> oAux = sNumPer.split('##');


                String sIDToIdent = oAux[0];
                String sTipoReg = oAux[1];
                String sIDOrigen = oAux[2];
                String sCasoId = '';

                Set<String> oSetNumPerCons = new Set<String>();

                // Map para el tratamiento de actualización de contactos ya existentes.
                Map<String,String> oContActIdent = new Map<String,String>();
                Map<String,String> oAccActIdent = new Map<String,String>();


                if (sTipoReg == 'DATADOC' || sTipoReg == 'DATATEL')
                {
                    /*
                    *****************************************************************
                    *****************************************************************
                    TRATAMIENTO DE BÚSQUEDA POR DOCUMENTO DE IDENTIDAD / TELÉFONO.
                    *****************************************************************
                    *****************************************************************
                    */

                    String sCuentaId = oAux[5];
                    String sContactoId = oAux[6];
                    sCasoId = oAux[7];

                    Map<String,Object> oObjDOC = CC_WS_Methods_ALF.getDataALFWSbyDOC (sIDToIdent, sTipoReg, sIDOrigen, sCuentaId, sContactoId, oConfigDOC);
                    // Pendiente tratar respuesta.

                    for (String sClave : oObjDOC.keySet())
                    {
                        if (sClave == 'NUMPER_DOC')
                        {
                            // Incorporar los NumPerso detectados.
                            Set<String> oDataAux = (Set<String>)oObjDOC.get(sClave);
                            if (oDataAux != null)
                            {
                                if (oDataAux.size() > 0)
                                {
                                    // En modo test, no insertamos los NumPer para no lanzar la siguiente integración.
                                    if (!Test.isRunningTest())
                                        {oSetNumPerCons.addAll(oDataAux);}
                                }
                            }
                            oDataAux.clear();
                            oDataAux = null;

                        } else if ((sClave == 'CONTACTO_ACT_NP' || sClave == 'CONTACTO_ACT') && oObjDOC.get('CONTACTO_ACT_NP') != null && oObjDOC.get('CONTACTO_ACT') != null) {
                            oContActIdent.put((String)oObjDOC.get('CONTACTO_ACT_NP'),(String)oObjDOC.get('CONTACTO_ACT'));
                        } else if ((sClave == 'CUENTA_ACT_NP' || sClave == 'CUENTA_ACT') && oObjDOC.get('CUENTA_ACT_NP') != null && oObjDOC.get('CUENTA_ACT') != null) {
                            oAccActIdent.put((String)oObjDOC.get('CUENTA_ACT_NP'),(String)oObjDOC.get('CUENTA_ACT'));
                        } else if (sClave == 'TRAZA') {
                            oTraza.add((CC_TrazaInt__c)oObjDOC.get(sClave));
                        }
                    }

                }else if (sTipoReg == 'RRSS')
                {
                    /*
                    *****************************************************************
                    *****************************************************************
                    TRATAMIENTO DE BÚSQUEDA POR RRSS.
                    *****************************************************************
                    *****************************************************************
                    */

                    String sCanalRRSS = oAux[3];
                    String sSocialPost = oAux[4];
                    String sSocialPers = oAux[5];
                    String sContactoId = oAux[6];
                    sCasoId = oAux[7];

                    Map<String,Object> oObjRRSS = CC_WS_Methods_ALF.getDataALFWSbyRRSS (sIDToIdent, sTipoReg, sIDOrigen, sCanalRRSS, sSocialPost, sSocialPers, sContactoId);

                    // Pendiente tratar respuesta.

                    for (String sClave : oObjRRSS.keySet())
                    {
                        if (sClave == 'NUMPER_RRSS')
                        {
                            // TEMPORAL!!!
                            //if (sNumPerSP == '17880824')
                            //{
                            /*    String sNumPerSP2 = '10559714';
                                Set<String> oAux1 = new Set<String>();
                                oAux1.add(sNumPerSP2);
                                oObjRRSS.put(sClave,oAux1);*/
                            //}

                            // Incorporar los NumPerso detectados.
                            Set<String> oDataAux = (Set<String>)oObjRRSS.get(sClave);
                            if (oDataAux != null && oDataAux.size() > 0) {
                                // En modo test, no insertamos los NumPer para no lanzar la siguiente integración.
                                if (!Test.isRunningTest())
                                    {oSetNumPerCons.addAll(oDataAux);}

                                // Datos para el tratamiento final de RRSS.
                                for (String sNumPerSP : oSetNumPerCons)
                                {
                                    if (sNumPerSP != '') {
                                        oNumPerSocial.put(sNumPerSP, sNumPer);
                                    }
                                }
                            }
                            oDataAux.clear();
                            oDataAux = null;

                        } else if (sClave == 'CONTACTO_ACT' || sClave == 'CONTACTO_ACT_NP' && oObjRRSS.get('CONTACTO_ACT_NP') != null && oObjRRSS.get('CONTACTO_ACT') != null) {
                            oContActIdent.put((String)oObjRRSS.get('CONTACTO_ACT_NP'),(String)oObjRRSS.get('CONTACTO_ACT'));
                        }else if (sClave == 'TRAZA') {
                            oTraza.add((CC_TrazaInt__c)oObjRRSS.get(sClave));
                        }
                    }

                }else{

                    /*
                    *****************************************************************
                    *****************************************************************
                    TRATAMIENTO DE BÚSQUEDA POR NUMPERSO.
                    *****************************************************************
                    *****************************************************************
                    */

                    bIdentNumPer = true;
                    sCasoId = oAux[7];
                    oSetNumPerCons.add(sIDToIdent);
                }

                // Preparar la lista de NumPers totales que se actualizan contra Alfabético.
                if (!oSetNumPerCons.isEmpty())
                {
                    oNumPerAlfabetico.addAll(oSetNumPerCons);
                }

                // Por cada NumPer detectado, buscar los datos en ALF / CLI.

                for (String sNumPerIdent : oSetNumPerCons)
                {

                    // Se devolverá una lista de sObjects ordenada (Account y Contacts a crear).
                    // Retorno:
                    //      Formato clave MAP. Objeto##Accion##Clave
                    //      Objeto: Account, Contact, CanalCom
                    //      Accion: 0 -> Upsert directo, 1 -> Consulta
                    //      Clave: Numper para UP, Numper + Valor Búsqueda para QU (Separados por &&)

                    //oAccActIdent (NP, id)
                    //oContActIdent (NP, id)
                    //sIDToIdent
                    Map<String,Object> oObj = CC_WS_Methods_ALF.getDataALFWSbyNumPerso (sIDToIdent, sNumPerIdent, sTipoReg, sIDOrigen, oNumPer.get(sNumPer), oParamAux, oConfigIntALF);
                    Map<String,SObject> oObjCLI = CC_WS_Methods_CLI.getDataCLIWSbyNumPerso (sNumPerIdent, sTipoReg, sIDOrigen, oNumPer.get(sNumPer), oParamAuxCLI, oObj, configCLI);

                    // Llamada para obtener los representantes.
                    Map<String,Object> oObjRepJur = CC_WS_Methods_ALF.getDataALFWS_RepresentantesJuridicos (sNumPerIdent, sIDOrigen, oConfigALF);

                    //Llamada para obtener las señales del cliente --- 23 si es Senior
                    CC_ObtenerSenalesCliente.obtenerSenalesCliente(sNumPerIdent, configPartyReferenceMdt);

                    // PENDIENTE CONTRATOS CLIENTE. AHORA MODO DEBUG CONTRA DOS LLAMADAS DE CONTRATOS DE PRUEBA.

                    // FIN DEBUG.

                    // Recorrer los resultados.
                    for (String sClave : oObj.keySet())
                    {
                        List<String> oData = sClave.split('##');

                        if (oData[0] == 'TipoCuenta') {

                            // Preparar actualización de contactos previos no identificados.

                            // MODO TEST.
                            if (Test.isRunningTest()) {
                                oAccActIdent.put(sNumPerIdent, oAccTest[0].Id);
                                oContActIdent.put(sNumPerIdent,oContTest[0].Id);
                            }

                            // Actualización de la cuenta padre (Sólo cuando hemos identificado un NumPer)

                            if (oAccActIdent.get(sNumPerIdent) != null)
                            {
                                // Tenemos el ID de la cuenta asociada a identificar.
                                if (oAccActIdent.get(sNumPerIdent) != '' && oAccActIdent.get(sNumPerIdent) != 'N/A')
                                {
                                    // Cualquier tipo de cliente se apunta al NumPer identificado.
                                    Account oADup = new Account();
                                    oADup.Id = oAccActIdent.get(sNumPerIdent);
                                    oADup.CC_NumPersoOrig__c = sNumPerIdent;

                                    // Actualizar la cuenta existente.
                                    Account oANumPer = new Account();
                                    oANumPer.Id = oAccActIdent.get(sNumPerIdent);
                                    oANumPer.CC_NumPerso__c = sNumPerIdent;
                                    oAccNumPer.put(sNumPerIdent,oANumPer);

                                    if ((String)oObj.get(sClave) == 'Confidencial')
                                    {
                                        // Actualizar la cuenta existente a confidencial.
                                        oADup.CC_Confidencial__c = true;

                                    }

                                    oAccAccount.put(sNumPerIdent,oADup);

                                    // Cualquier otro tipo, no se hace nada con los contactos existentes.


                                }
                            }

                            if (oContActIdent.get(sNumPerIdent) != null)
                            {
                                // Tenemos el ID del contacto asociado a identificar.
                                if (oContActIdent.get(sNumPerIdent) != '' && oContActIdent.get(sNumPerIdent) != 'N/A')
                                {
                                    // Cualquier tipo de cliente se apunta a su cuenta padre identificada.
                                    Contact oCDup = new Contact();
                                    oCDup.Id = oContActIdent.get(sNumPerIdent);
                                    oCDup.CC_NumPersoOrig__c = sNumPerIdent;

                                    if ((String)oObj.get(sClave) == 'Particular')
                                    {
                                        // Actualizar el contacto existente e intentar unirlos si no estaba identificado.
                                        Contact oCNumPer = new Contact();
                                        oCNumPer.Id = oContActIdent.get(sNumPerIdent);
                                        oCNumPer.CC_NumPerso__c = sNumPerIdent;
                                        oContNumPer.put(sNumPerIdent,oCNumPer);

                                    }else if ((String)oObj.get(sClave) == 'Confidencial')
                                    {
                                        // Actualizar el contacto a confidencial existente.
                                        //Contact oCConfi = new Contact();
                                        //oCConfi.Id = oContActIdent.get(sNumPerIdent);
                                        oCDup.CC_Confidencial__c = true;
                                        //oContConfi.put(sNumPerIdent,oCConfi);

                                    }else{
                                        oCDup.Account = new Account(CC_NumPerso__c = sNumPerIdent);
                                    }

                                    oContAccount.put(sNumPerIdent,oCDup);

                                    // Cualquier otro tipo, no se hace nada con los contactos existentes.



                                    // Actualizar datos del caso asociado.
                                    /*if (sCasoId != '')
                                    {
                                        Case oCaso = new Case();
                                        oCaso.Id = sCasoId;
                                        oCaso.Account = new Account(CC_NumPerso__c = sNumPerIdent);

                                        if ((String)oObj.get(sClave) == 'Particular')
                                        {
                                            oCaso.Contact = new Contact(CC_NumPerso__c = sNumPerIdent);
                                        }

                                        oCasosUp.put(sCasoId, oCaso);
                                    }*/
                                }
                            }

                            // Tratamiento identificación directa por NumPer. Actualizar caso origen.
                            if (oContActIdent.get(sNumPerIdent) != null || bIdentNumPer == true)
                            {
                                // Actualizar datos del caso asociado.
                                if (sCasoId != '' && sCasoId != null && sCasoId != 'N/A')
                                {
                                    Case oCaso = new Case();
                                    oCaso.Id = sCasoId;
                                    oCaso.Account = new Account(CC_NumPerso__c = sNumPerIdent);

                                    if ((String)oObj.get(sClave) == 'Particular')
                                    {
                                        oCaso.Contact = new Contact(CC_NumPerso__c = sNumPerIdent);
                                    }

                                    // Identificación automática por ALF.
                                    oCaso.CC_IdentCliente__c = '1';

                                    oCasosUp.put(sCasoId, oCaso);

                                    // Preparar los numper a borrar como duplicados.
                                    setNumPerDuplicados.add(sNumPerIdent);
                                }
                            }

                        }else if (oData[0] == 'Account') {
                            // Tratamiento Account.
                            oAccount.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'ConvAccountRT') {
                            oAccountConvRT.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'ConvContactRT') {
                            oContactConvRT.add((Contact)oObj.get(sClave));
                        }else if (oData[0] == 'ConvNameAccount') {
                            oAccountConvName.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'ConvPANameAccount') {
                            oAccountConvNamePA.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'ConvNameAccountUpdate') {
                            oAccountConvNameUpdate.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'UpdANumPer') { //Nuevo update para el AV_NumPerso
                            oAccountUpdANumPer.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'AccountFecha') {
                            // Actualizar fecha refresco. Sin colisión validation rule.
                            oAccountFechaRefresh.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'Contact') {

                            // Tratamiento Contact.
                            if (oData[1] == '0')
                            {
                                oContact.add((Contact)oObj.get(sClave));
                            }//else{
                                // Añadir dato a buscar. Pendiente para empresas.
                                // Futuro. Con el parámetro bNuevo se podrá discriminar.
                            //}

                        }else if (oData[0] == 'ContactFecha') {
                            // Tratamiento Contact.
                            if (oData[1] == '0')
                            {
                                oContactFechaRefresh.add((Contact)oObj.get(sClave));
                            }
                        }else if (oData[0] == 'Oficina') {

                            // Tratamiento oficina contacto.
                            //oOficina.add((Contact)oObj.get(sClave));
                            oOficina.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'OficinaEmp') {
                            oOficinaEmp.add((Account)oObj.get(sClave));
                        }else if (oData[0] == 'CanalComTel') {

                            // Canal de comunicación telefónico.

                            // Con el parámetro bNuevo se podrá discriminar y priorizar sin realizar consultas.
                            //if (bNuevos)
                            //{
                            //    oCanalComNew.add((CC_Canal_Com__c)oOneObj);
                            //}else{

                                // Añadir datos a buscar para crear o actualizar.
                                List<String> oClaveSearch = oData[2].split('&&');
                                oCComSearch.add(oClaveSearch[0]);
                                oPotCrear.put(sClave, (CC_Canal_Com__c)oObj.get(sClave));
                            //}
                        }else if (oData[0] == 'CanalComMail') {

                            // Canal de comunicación e-mail.

                            // Con el parámetro bNuevo se podrá discriminar y priorizar sin realizar consultas.
                            //if (bNuevos)
                            //{
                            //    oCanalComNew.add((CC_Canal_Com__c)oOneObj);
                            //}else{

                                // Añadir datos a buscar para crear o actualizar.
                                List<String> oClaveSearch = oData[2].split('&&');
                                oCComSearch2.add(oClaveSearch[0]);
                                oPotCrear.put(sClave, (CC_Canal_Com__c)oObj.get(sClave));
                            //}
                        }else if (oData[0] == 'CanalComTelACC') {

                            // Canal de comunicación teléfono.

                            // Añadir datos a buscar para crear o actualizar.
                            List<String> oClaveSearchAcc = oData[2].split('&&');
                            oContAccSearch.add(oClaveSearchAcc[1]);

                            // Tratamiento para la gestión de contactos.
                            List<String> oClaveCont = sClave.split('&&');
                            List<String> oInicioClave = oClaveCont[0].split('##');

                            oContPotAccCrear.put('CanalComACC##' + oInicioClave[1] + '##' + oInicioClave[2] + '&&' + oClaveCont[1],oClaveCont[0] + '&&' + oClaveCont[1]);
                            oPotAccCrear.put(sClave, (CC_Canal_Com__c)oObj.get(sClave));

                        }else if (oData[0] == 'CanalComMailACC') {

                            // Canal de comunicación e-mail.

                            // Añadir datos a buscar para crear o actualizar.
                            List<String> oClaveSearchAcc = oData[2].split('&&');
                            oContAccSearch.add(oClaveSearchAcc[1]);

                            // Tratamiento para la gestión de contactos.
                            List<String> oClaveCont = sClave.split('&&');
                            List<String> oInicioClave = oClaveCont[0].split('##');

                            //oContPotAccCrear.put(oClaveCont[0] + '&&' + oClaveCont[1],oClaveCont[0] + '&&' + oClaveCont[1]);
                            oContPotAccCrear.put('CanalComACC##' + oInicioClave[1] + '##' + oInicioClave[2] + '&&' + oClaveCont[1],oClaveCont[0] + '&&' + oClaveCont[1]);
                            oPotAccCrear.put(sClave, (CC_Canal_Com__c)oObj.get(sClave));

                        }else if (oData[0] == 'TRAZA') {
                            // Gestión de trazas.

                            oTraza.add((CC_TrazaInt__c)oObj.get(sClave));
                        }
                    }

                    //CLI
                    for (String sClaveCLI : oObjCLI.keySet())
                    {
                        List<String> oDataCLI = sClaveCLI.split('##');

                        if (oDataCLI[0] == 'Account')
                        {
                            // Tratamiento Account.
                            oAccountCLI.add((Account)oObjCLI.get(sClaveCLI));
                        }else if (oDataCLI[0] == 'TRAZA') {
                            // Gestión de trazas.

                            oTraza.add((CC_TrazaInt__c)oObjCLI.get(sClaveCLI));
                        }
                    }

                    // Recorrer el resultado de los representantes para personas jurídicas.
                    for (String sClaveRepJur : oObjRepJur.keySet())
                    {
                        if (sClaveRepJur == 'TRAZA')
                        {
                            oTraza.add((CC_TrazaInt__c)oObjRepJur.get(sClaveRepJur));
                        }else if (sClaveRepJur == 'REPR_JURIDICO')
                        {
                            /*if (!((List<CC_Representante_Contrato__c>)oObjRepJur.get(sClaveRepJur)).isEmpty())
                            {
                                oRepresentantesJuridicos.addAll((List<CC_Representante_Contrato__c>)oObjRepJur.get(sClaveRepJur));
                            }*/
                            if (!((List<Contact>)oObjRepJur.get(sClaveRepJur)).isEmpty())
                            {
                                oRepresentantesJuridicos.addAll((List<Contact>)oObjRepJur.get(sClaveRepJur));
                            }
                        }
                    }

                    // Recorrer el resultado de los representantes para personas físicas.
 /*                   for (String sClaveRepFis : oObjRepFis.keySet())
                    {
                        if (sClaveRepFis == 'TRAZA')
                        {
                            oTraza.add((CC_TrazaInt__c)oObjRepFis.get(sClaveRepFis));
                        }else if (sClaveRepFis == 'REPR_FISICO')
                        {
                            if (!((List<CC_Representante_Contrato__c>)oObjRepFis.get(sClaveRepFis)).isEmpty())
                            {
                                oRepresentantesFisicas.addAll((List<CC_Representante_Contrato__c>)oObjRepFis.get(sClaveRepFis));
                            }
                        }else if (sClaveRepFis == 'REL_REPR_FISICO_CONTRATO')
                        {
                            if (!((List<CC_Representante_Contrato__c>)oObjRepFis.get(sClaveRepFis)).isEmpty())
                            {
                                oRepresentantesContratos.addAll((List<CC_Representante_Contrato__c>)oObjRepFis.get(sClaveRepFis));
                            }
                        }
                    }
*/
                }

                oSetNumPerCons.clear();
                oSetNumPerCons = null;
            }
        }

        // Inactivar representantes de las cuentas a actualizar.
        inactivarRepresentantesCuentaySusContratos (oNumPerAlfabetico);

        // Inactivar contratos de las cuentas a actualizar.

        // TODO. Tratamiento personas de contactos para empresas.

        // Actualizar cuenta existente el NumPerso obtenido.
        // Si ya existe en otra cuenta, no realizará nada, dejará 2 cuentas para fusionar más adelante.
        if (oAccNumPer.size() > 0)
        {
            List<Account> oLUpd = new List<Account>();
            for (String sClave : oAccNumPer.keySet())
            {
                if (oAccNumPer.get(sClave) != null)
                    {oLUpd.add(oAccNumPer.get(sClave));}
            }

            Database.SaveResult[] oResUp = Database.update(oLUpd, false);
            oResUp = null;
            oLUpd = null;
        }

        // Actualizar contacto existente el NumPerso obtenido.
        // Si ya existe en otro contacto, no realizará nada, dejará 2 contactos para fusionar más adelante.
        if (oContNumPer.size() > 0)
        {
            List<Contact> oLUpd = new List<Contact>();
            for (String sClave : oContNumPer.keySet())
            {
                if (oContNumPer.get(sClave) != null){oLUpd.add(oContNumPer.get(sClave));}
            }

            Database.SaveResult[] oResUp = Database.update(oLUpd, false);
            oResUp = null;
            oLUpd = null;
        }

        // Intentar la conversión BusinessAccount <--> PersonAccount
        if (oAccountConvRT.size() > 0)
        {
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oAccountConvRT, oCampoSearch, false);
        }

        if (oContactConvRT.size() > 0)
        {
            Schema.SObjectField oCampoSearch = Contact.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oContactConvRT, oCampoSearch, false);
        }

        if (oAccountConvName.size() > 0)
        {
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oAccountConvName, oCampoSearch, false);
        }

        if (oAccountConvNamePA.size() > 0)
        {
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oAccountConvNamePA, oCampoSearch, false);
        }

        if (oAccountConvNameUpdate.size() > 0)
        {
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oAccountConvNameUpdate, oCampoSearch, false);
        }

        if (oAccountUpdANumPer.size() > 0)
        {
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oAccountUpdANumPer, oCampoSearch, false);
        }

        // Creación / Actualización de clientes.
        if (oAccount.size() > 0)
        {
            //upsert oAccount CC_NumPerso__c;
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oAccount, oCampoSearch, false);

            /*for (Database.UpsertResult oStatus : oResUp)
            {
                if (oStatus.isSuccess() == false)
                {
                    bReintento = true;
                    break;
                }
            }*/
        }
        oAccount.clear();
        oAccount = null;

        // Actualizar cuenta padre de contactos existentes e identificados en esta transacción.
        if (oContAccount.size() > 0)
        {
            List<Contact> oLUpd = new List<Contact>();
            for (String sClave : oContAccount.keySet())
            {
                if (oContAccount.get(sClave) != null)
                    {oLUpd.add(oContAccount.get(sClave));}
            }

            Database.SaveResult[] oResUp = Database.update(oLUpd, false);
            oResUp = null;
            oLUpd = null;
        }

        // Actualizar cuentas existentes e identificados en esta transacción.
        if (oAccAccount.size() > 0)
        {
            List<Account> oLUpd = new List<Account>();
            for (String sClave : oAccAccount.keySet())
            {
                if (oAccAccount.get(sClave) != null)
                    {oLUpd.add(oAccAccount.get(sClave));}
            }

            Database.SaveResult[] oResUp = Database.update(oLUpd, false);
            oResUp = null;
            oLUpd = null;
        }

        // Creación / Actualización de contactos.
        if (oContact.size() > 0)
        {
            //upsert oContact CC_NumPerso__c;
            Schema.SObjectField oCampoSearch = Contact.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oContact, oCampoSearch, false);

            /*for (Database.UpsertResult oStatus : oResUp)
            {
                if (oStatus.isSuccess() == false)
                {
                    bReintento = true;
                    break;
                }
            }*/
        }
        oContact.clear();
        oContact = null;

        // TEMPORAL. Reintento por fallo.
        /*if (bReintento)
        {
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oAccount, oCampoSearch, false);

            Schema.SObjectField oCampoSearch2 = Contact.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp2 = Database.upsert(oContact, oCampoSearch2, false);
        }*/

        // Actualización de la oficina.
        if (oOficina.size() > 0)
        {
            //upsert oOficina CC_NumPerso__c;
            //Schema.SObjectField oCampoSearch = Contact.Fields.CC_NumPerso__c;
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oOficina, oCampoSearch, false);
        }
        oOficina.clear();
        oOficina = null;

        // Actualización del empleado gestor.
        if (oOficinaEmp.size() > 0)
        {
            //upsert oOficina CC_NumPerso__c;
            //Schema.SObjectField oCampoSearch = Contact.Fields.CC_NumPerso__c;
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oOficinaEmp, oCampoSearch, false);
        }
        oOficinaEmp.clear();
        oOficinaEmp = null;

        String sRecordType = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();

        // Teléfonos. Tratamiento Bulk.
        for (CC_Canal_Com__c oCComAux : [SELECT Id, CC_NumPerso__c, CC_Telefono__c FROM CC_Canal_Com__c WHERE CC_NumPerso__c IN :oCComSearch AND RecordTypeId = :sRecordType])
        {
            // Buscar si existe.
            String sClave = 'CanalComTel##1##' + oCComAux.CC_NumPerso__c + '&&' + oCComAux.CC_Telefono__c;



            if (oPotCrear.get(sClave) != null)
            {
                // Actualización campos.
                oCComAux.CC_Clase_Com__c = oPotCrear.get(sClave).CC_Clase_Com__c;
                oCComAux.CC_Tipo_Com__c = oPotCrear.get(sClave).CC_Tipo_Com__c;
                oCComAux.CC_ContactoId__r = oPotCrear.get(sClave).CC_ContactoId__r;
                oCComAux.CC_CuentaId__r = oPotCrear.get(sClave).CC_CuentaId__r;

                // Añadir a lista de actualización.
                oCanalComUp.add(oCComAux);

                // Vaciar memoria.
                oPotCrear.remove(sClave);
            }
        }

        sRecordType = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();

        // Mail. Tratamiento Bulk.
        for (CC_Canal_Com__c oCComAux : [SELECT Id, CC_NumPerso__c, CC_Email__c FROM CC_Canal_Com__c WHERE CC_NumPerso__c IN :oCComSearch2 AND RecordTypeId = :sRecordType])
        {
            // Buscar si existe.
            String sClave = 'CanalComMail##1##' + oCComAux.CC_NumPerso__c + '&&' + oCComAux.CC_Email__c.toLowerCase();



            if (oPotCrear.get(sClave) != null)
            {
                // Actualización campos.
                oCComAux.CC_Clase_Com__c = oPotCrear.get(sClave).CC_Clase_Com__c;
                oCComAux.CC_ContactoId__r = oPotCrear.get(sClave).CC_ContactoId__r;
                oCComAux.CC_CuentaId__r = oPotCrear.get(sClave).CC_CuentaId__r;

                // Añadir a lista de actualización.
                oCanalComUp.add(oCComAux);

                // Vaciar memoria.
                oPotCrear.remove(sClave);
            }
        }

        // Los potenciales de crear, se pasan a la lista de nuevos.
        for (String sClave : oPotCrear.keySet())
        {
            oCanalComNew.add(oPotCrear.get(sClave));
        }


        // Vaciar memoria.
        oPotCrear.clear();
        oPotCrear = null;

        if (oCanalComUp.size() > 0)
        {
            //update oCanalComUp;
            Database.SaveResult[] oResUp = Database.update(oCanalComUp, false);
        }

        oCanalComUp.clear();
        //oCanalComUp = null;

        if (oCanalComNew.size() > 0)
        {
            //insert oCanalComNew;
            Database.SaveResult[] oResUp = Database.insert(oCanalComNew, false);
        }

        oCanalComNew.clear();
        //oCanalComNew = null;

        // Contactos para empresas / particulares especiales identificadas.

        sRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        // Teléfonos / Mails EMPRESAS y PARTICULARES ESPECIALES. Tratamiento Bulk.
        for (Contact oCContAux : [SELECT Id, CC_NumPersoAsoc__c, Name FROM Contact WHERE CC_NumPersoAsoc__c IN :oContAccSearch AND (RecordTypeId = :sRecordType OR RecordTypeId = null)])
        {
            // Buscar si existe.
            //String sClave = 'CanalComTelACC##1##' + oCContAux.Name.toLowerCase() + '&&' + oCContAux.CC_NumPersoAsoc__c;
            //String sClave2 = 'CanalComMailACC##1##' + oCContAux.Name.toLowerCase() + '&&' + oCContAux.CC_NumPersoAsoc__c;
            //String sClave = 'CanalComACC##1##' + oCContAux.Name.toLowerCase() + '&&' + oCContAux.CC_NumPersoAsoc__c;
            String sClave = 'CanalComACC##1##' + oCContAux.Name + '&&' + oCContAux.CC_NumPersoAsoc__c;

            //if (oContPotAccCrear.get(sClave) != null || oContPotAccCrear.get(sClave2) != null)
            if (oContPotAccCrear.get(sClave) != null)
            {
                // Actualizar contacto.
                oCContAux.RecordTypeId = sRecordType;
                oCContAux.FirstName = '';
                oCContAux.LastName = oCContAux.Name;
                oCContAux.Account = new Account(CC_NumPerso__c = oCContAux.CC_NumPersoAsoc__c);

                // Añadir a lista de actualización.
                oContactUp.add(oCContAux);

                // Vaciar memoria.
                oContPotAccCrear.remove(sClave);
                //oContPotAccCrear.remove(sClave2);
            }
        }


        // Los potenciales de crear, se pasan a la lista de nuevos.
        for (String sClave : oContPotAccCrear.keySet())
        {
            List<String> oClave = sClave.split('##');
            List<String> oData = oClave[2].split('&&');

            Contact oCAux = new Contact();
            oCAux.RecordTypeId = sRecordType;
            oCAux.FirstName = '';
            oCAux.LastName = oData[0];
            oCAux.CC_NumPersoAsoc__c = oData[1];
            oCAux.Account = new Account(CC_NumPerso__c = oData[1]);

            oContactNew.add(oCAux);
        }


        // Vaciar memoria.
        oContPotAccCrear.clear();
        oContPotAccCrear = null;

        if (oContactUp.size() > 0)
        {
            //update oContactUp;
            Database.SaveResult[] oResUp = Database.update(oContactUp, false);
        }

        oContactUp.clear();
        oContactUp = null;

        if (oContactNew.size() > 0)
        {
            //insert oContactNew;
            Database.SaveResult[] oResUp = Database.insert(oContactNew, false);
        }

        oContactNew.clear();
        oContactNew = null;

        sRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        // Recuperar todos los contactos a tratar para crear sus teléfonos y e-mails.
        Map<String,Id> oContactACC = new Map<String,Id>();
        for (Contact oCContAux : [SELECT Id, CC_NumPersoAsoc__c, Name FROM Contact WHERE CC_NumPersoAsoc__c IN :oContAccSearch AND RecordTypeId = :sRecordType])
        {
            //oContactACC.put(oCContAux.Name.toLowerCase() + '##' + oCContAux.CC_NumPersoAsoc__c, oCContAux.Id);
            oContactACC.put(oCContAux.Name + '##' + oCContAux.CC_NumPersoAsoc__c, oCContAux.Id);
        }


        sRecordType = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();

        // Teléfonos Empresas y Particulares especiales. Tratamiento Bulk.
        for (CC_Canal_Com__c oCComAux : [SELECT Id, CC_NumPerso__c, CC_Telefono__c, CC_ContactName__c FROM CC_Canal_Com__c WHERE CC_NumPerso__c IN :oContAccSearch AND RecordTypeId = :sRecordType])
        {
            // Buscar si existe.
            //String sClave = 'CanalComTelACC##1##' + oCComAux.CC_ContactName__c.toLowerCase() + '&&' + oCComAux.CC_NumPerso__c + '&&' + oCComAux.CC_Telefono__c;
            String sClave = 'CanalComTelACC##1##' + oCComAux.CC_ContactName__c + '&&' + oCComAux.CC_NumPerso__c + '&&' + oCComAux.CC_Telefono__c;


            if (oPotAccCrear.get(sClave) != null)
            {
                // Actualización campos.
                oCComAux.CC_Clase_Com__c = oPotAccCrear.get(sClave).CC_Clase_Com__c;
                oCComAux.CC_Tipo_Com__c = oPotAccCrear.get(sClave).CC_Tipo_Com__c;

                //if (oContactACC.get(oCComAux.CC_ContactName__c.toLowerCase() + '##' + oCComAux.CC_NumPerso__c) != null)
                if (oContactACC.get(oCComAux.CC_ContactName__c + '##' + oCComAux.CC_NumPerso__c) != null)
                    {oCComAux.CC_ContactoId__c = oContactACC.get(oCComAux.CC_ContactName__c + '##' + oCComAux.CC_NumPerso__c);}

                oCComAux.CC_CuentaId__r = oPotAccCrear.get(sClave).CC_CuentaId__r;

                // Añadir a lista de actualización.
                oCanalComUp.add(oCComAux);

                // Vaciar memoria.
                oPotAccCrear.remove(sClave);
            }
        }

        sRecordType = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();

        // Mails Empresas y Particulares especiales. Tratamiento Bulk.
        for (CC_Canal_Com__c oCComAux : [SELECT Id, CC_NumPerso__c, CC_Email__c, CC_ContactName__c FROM CC_Canal_Com__c WHERE CC_NumPerso__c IN :oContAccSearch AND RecordTypeId = :sRecordType])
        {
            // Buscar si existe.
            //String sClave = 'CanalComMailACC##1##' + oCComAux.CC_ContactName__c.toLowerCase() + '&&' + oCComAux.CC_NumPerso__c + '&&' + oCComAux.CC_Email__c.toLowerCase();
            String sClave = 'CanalComMailACC##1##' + oCComAux.CC_ContactName__c + '&&' + oCComAux.CC_NumPerso__c + '&&' + oCComAux.CC_Email__c.toLowerCase();


            if (oPotAccCrear.get(sClave) != null)
            {
                // Actualización campos.
                oCComAux.CC_Clase_Com__c = oPotAccCrear.get(sClave).CC_Clase_Com__c;
                oCComAux.CC_Tipo_Com__c = oPotAccCrear.get(sClave).CC_Tipo_Com__c;

                //if (oContactACC.get(oCComAux.CC_ContactName__c.toLowerCase() + '##' + oCComAux.CC_NumPerso__c) != null)
                if (oContactACC.get(oCComAux.CC_ContactName__c + '##' + oCComAux.CC_NumPerso__c) != null)
                    {oCComAux.CC_ContactoId__c = oContactACC.get(oCComAux.CC_ContactName__c + '##' + oCComAux.CC_NumPerso__c);}

                oCComAux.CC_CuentaId__r = oPotAccCrear.get(sClave).CC_CuentaId__r;

                // Añadir a lista de actualización.
                oCanalComUp.add(oCComAux);

                // Vaciar memoria.
                oPotAccCrear.remove(sClave);
            }
        }

        // Los potenciales de crear, se pasan a la lista de nuevos.
        for (String sClave : oPotAccCrear.keySet())
        {
            if (oPotAccCrear.get(sClave) != null)
            {
                CC_Canal_Com__c oCanal = oPotAccCrear.get(sClave);

                List<String> oData = sClave.split('##');
                if (oData.size() == 3)
                {
                    List<String> oCont = oData[2].split('&&');
                    if (oCont.size() == 3)
                    {
                        if (oContactACC.get(oCont[0] + '##' + oCont[1]) != null)
                            {oCanal.CC_ContactoId__c = oContactACC.get(oCont[0] + '##' + oCont[1]);}

                        oCanalComNew.add(oCanal);
                    }
                }
            }
        }

        // Vaciar memoria.
        oPotAccCrear.clear();
        oPotAccCrear = null;

        if (oCanalComUp.size() > 0)
        {
            Database.SaveResult[] oResUp = Database.update(oCanalComUp, false);
        }

        oCanalComUp.clear();
        oCanalComUp = null;

        if (oCanalComNew.size() > 0)
        {
            Database.SaveResult[] oResUp = Database.insert(oCanalComNew, false);
        }

        oCanalComNew.clear();
        oCanalComNew = null;

        // Actualización caso origen.
        if (oCasosUp.size() > 0)
        {
            List<Case> oCasos = new List<Case>();
            for (String sClave : oCasosUp.keySet())
            {
                if (oCasosUp.get(sClave) != null)
                {
                    oCasos.add(oCasosUp.get(sClave));
                }
            }

            if (oCasos.size() > 0)
            {
                Database.SaveResult[] oResUp = Database.update(oCasos, false);
            }
        }

        // Actualización datos CLI.
        if (oAccountCLI.size() > 0)
        {
            //upsert oAccount CC_NumPerso__c;
            Schema.SObjectField oCampoSearchCLI = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUpCLI = Database.upsert(oAccountCLI, oCampoSearchCLI, false);
        }
        oAccountCLI.clear();
        oAccountCLI = null;

        // Actualizar los representantes de las personas jurídicas.

        if (!oRepresentantesJuridicos.isEmpty())
        {
            //Schema.SObjectField oCampoSearch = CC_Representante_Contrato__c.Fields.CC_IdExterno__c;
            //Database.UpsertResult[] oResUp = Database.upsert(oRepresentantesJuridicos, oCampoSearch, false);
            Schema.SObjectField oCampoSearch = Contact.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oRepresentantesJuridicos, oCampoSearch, false);
        }
        oRepresentantesJuridicos.clear();
        oRepresentantesJuridicos = null;

        // Actualizar los representantes de las personas físicas.
/*
        if (!oRepresentantesFisicas.isEmpty())
        {
            Schema.SObjectField oCampoSearch = CC_Representante_Contrato__c.Fields.CC_IdExterno__c;
            Database.UpsertResult[] oResUp = Database.upsert(oRepresentantesFisicas, oCampoSearch, false);
        }
        oRepresentantesFisicas.clear();
        oRepresentantesFisicas = null;

        // Actualizar los contratos de los clientes.

        if (!oContratosCliente.isEmpty())
        {
            Schema.SObjectField oCampoSearch = CC_Representante_Contrato__c.Fields.CC_IdExterno__c;
            Database.UpsertResult[] oResUp = Database.upsert(oContratosCliente, oCampoSearch, false);
        }

        oContratosCliente.clear();
        oContratosCliente = null;

        // Actualizar la vinculación de representantes y contratos.
        if (!oRepresentantesContratos.isEmpty())
        {
            Schema.SObjectField oCampoSearch = CC_Representante_Contrato__c.Fields.CC_IdExterno__c;
            Database.UpsertResult[] oResUp = Database.upsert(oRepresentantesContratos, oCampoSearch, false);
        }
        oRepresentantesContratos.clear();
        oRepresentantesContratos = null;
*/
        // Gestión de representantes de los casos asociados e identificados.
        if (!oCasosUp.isEmpty())
        {
            gestionRepresentantesCaso (oCasosUp.keySet());
        }

        // Consolidar fecha refresco. Activar validation rule existente.
        if (oAccountFechaRefresh.size() > 0)
        {
            //upsert oAccount CC_NumPerso__c;
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oAccountFechaRefresh, oCampoSearch, false);
        }
        oAccountFechaRefresh.clear();
        oAccountFechaRefresh = null;

        // Consolidar fecha refresco. Activar validation rule existente.
        if (oContactFechaRefresh.size() > 0)
        {
            //upsert oContact CC_NumPerso__c;
            Schema.SObjectField oCampoSearch = Contact.Fields.CC_NumPerso__c;
            Database.UpsertResult[] oResUp = Database.upsert(oContactFechaRefresh, oCampoSearch, false);
        }
        oContactFechaRefresh.clear();
        oContactFechaRefresh = null;

        // Gestión clientes / contactos duplicados (casos formulario web).
        gestionarCuentasDuplicadas (setNumPerDuplicados);

        // Insertar las trazas generadas.
        if (oTraza.size() > 0)
        {
            Database.SaveResult[] oResUp = Database.insert(oTraza, false);
        }

        oTraza.clear();
        oTraza = null;

        // Actualizar la información en base a las RRSS.
        /*if (oNumPerSocial.size() > 0)
        {
            // Recibe un MAP con la siguiente información:
            //  Key: NUMPER
            //  Value: ID_RRSS##RRSS##ID_ORIGEN##CANAL##SOCIALPOST##SOCIALPERSONA
            tratarAccountContactRRSS (oNumPerSocial);
        }*/
    }

    /*
        Función para realizar el post-procesado tras identificar en RRSS.
    */
/*    public static void tratarAccountContactRRSS (Map<String,String> oDatos)
    {
        Map<String,String> oNumPerSP = new Map<String,String>();
        Map<String,String> oSocialIdNP = new Map<String,String>();
        Map<String,String> oPartVinc = new Map<String,String>();
        Map<String,String> oEmpVinc = new Map<String,String>();
        Map<String,String> oSPVinc = new Map<String,String>();

        if (oDatos != null)
        {
            for (String sNumPer : oDatos.keySet())
            {
                // Deseralizar la clave.
                if (oDatos.get(sNumPer) != null)
                {
                    String sClave = oDatos.get(sNumPer);
                    if (sClave != '')
                    {
                        List<String> oAux = sClave.split('##');
                        String sSocialId = oAux[5];

                        if (sSocialId != '')
                        {
                            oNumPerSP.put(sNumPer, sSocialId);
                            oSocialIdNP.put(sSocialId, sNumPer);
                        }
                    }
                }
            }

            // Buscar los datos en contactos (particulares).
            if (oNumPerSP.size() > 0)
            {
                for (Contact oContact : [SELECT Id, CC_NumPerso__c FROM Contact WHERE CC_NumPerso__c IN :oNumPerSP.keySet()])
                {
                    oPartVinc.put(oContact.CC_NumPerso__c, oContact.Id);
                    //oPartVinc.put(oContact.Id, oContact.CC_NumPerso__c);
                }
            }

            // Buscar los datos en cuentas (empresas).
            if (oNumPerSP.size() > 0)
            {
                for (Account oAccount : [SELECT Id, CC_NumPerso__c FROM Account WHERE CC_NumPerso__c IN :oNumPerSP.keySet()])
                {
                    if (oPartVinc.get(oAccount.CC_NumPerso__c) == null)
                    {
                        oEmpVinc.put(oAccount.CC_NumPerso__c, oAccount.Id);
                        //oEmpVinc.put(oAccount.Id, oAccount.CC_NumPerso__c);
                    }
                }
            }

            // Buscar las personas sociales.
            if (oSocialIdNP.size() > 0)
            {
                for (SocialPersona oSP : [SELECT Id, ParentId FROM SocialPersona WHERE Id IN :oSocialIdNP.keySet()])
                {
                    oSPVinc.put(oSP.ParentId, oSP.Id);
                }
            }

            // Preparar nuevos vínculos y posibles contactos a borrar.
            for (String sIdParent : oSPVinc.keySet())
            {
                String sSocialId = oSPVinc.get(sIdParent);
                String sSocialNP = '';

                // Disponemos de NumPer asociado.
                if (oSocialIdNP.get(sSocialId) != null)
                {
                    sSocialNP = oSocialIdNP.get(sSocialId);

                    // Buscar si es contacto o cliente para vincular (particular / empresa).
                    if (oPartVinc.get(sSocialNP) != null)
                    {
                        // Encuentro contacto.
                        SocialPersona oSPAux = new SocialPersona();
                        oSPAux.Id = sSocialId;
                        oSPAux.ParentId = oPartVinc.get(sSocialNP);

                    }else if (oEmpVinc.get(sSocialNP) != null) {
                        // Encuentro cliente.


                    }
                }
            }
        }
    }
*/
    //@InvocableMethod(label='Procesar LiveChatTranscript' description='Identificación de clientes')
    @InvocableMethod(label='Procesar Identificación Clientes' description='Identificación de clientes')
    public static void identificarClientesChat(List<ID> listNewObj) {

        Set<ID> oID = new Set<ID>(listNewObj);

        // Si existen elementos nuevos enrutados, gestión llamada Alfabético.
        // Lanzamos un máximo de 50 callouts (límite Hard), con las llamadas repartidas.
        if (oID.size() > 0)
        {
            List<ID> oIDList = new List<ID>(oID);
            Integer j = 1;
            Map<Integer,List<ID>> oMap = new Map<Integer,List<ID>>();
            for (Integer i=0;i<oIDList.size();i++)
            {
                if (j > 50)
                    {j = 1;}

                // Inicializar listas.
                if (oMap.get(j) == null)
                {
                    List<ID> oSet = new List<ID>();
                    oMap.put(j,oSet);
                }

                // Añadir valor.
                oMap.get(j).add(oIDList[i]);

                j = j + 1;
            }

            // Lanzar llamadas Futuras.

            for (Integer i : oMap.keySet())
            {
                CC_IdentCliente_Future.CallUpdateALF(oMap.get(i));
            }

            oIDList.clear();
            oIDList = null;

            oMap.clear();
            oMap = null;
        }

        oID.clear();
        oID = null;
    }

 /*   @InvocableMethod(label='Procesar Identificación Clientes Existentes' description='Identificación de clientes Existentes')
    public static void identificarClientesChatExistentes(List<ID> listNewObj) {

        Set<ID> oID = new Set<ID>(listNewObj);

        // Si existen elementos nuevos enrutados, gestión llamada Alfabético.
        // Lanzamos un máximo de 50 callouts (límite Hard), con las llamadas repartidas.
        if (oID.size() > 0)
        {
            List<ID> oIDList = new List<ID>(oID);
            Integer j = 1;
            Map<Integer,List<ID>> oMap = new Map<Integer,List<ID>>();
            for (Integer i=0;i<oIDList.size();i++)
            {
                if (j > 50)
                    j = 1;

                // Inicializar listas.
                if (oMap.get(j) == null)
                {
                    List<ID> oSet = new List<ID>();
                    oMap.put(j,oSet);
                }

                // Añadir valor.
                oMap.get(j).add(oIDList[i]);

                j = j + 1;
            }

            // Lanzar llamadas Futuras.

            for (Integer i : oMap.keySet())
            {
                CC_IdentCliente_Future.CallUpdateALFExistentes(oMap.get(i));
            }

            oIDList.clear();
            oIDList = null;

            oMap.clear();
            oMap = null;
        }

        oID.clear();
        oID = null;
    }*/

    /*
        Actualizar los casos que se han identificado.

        UPDCASO##NUMPERSO##TIPO_REGISTRO##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID. Ahora el tipo de registro será Cliente, que se traducirá al RecordType de Clientes.


        PTE -> ID_RRSS##RRSS##ID_ORIGEN##CANAL##SOCIALPOST##SOCIALPERSONA##CONTACTO_ID##CASO_ID --> Identificadores de RRSS a buscar en ALF.
        PTE -> ID_DOC##DATADOC/DATATEL##ID_ORIGEN##N/A##N/A##N/A##N/A##N/A --> Identificadores de Documentos de Identidad / Teléfonos a buscar en ALF.

    */
    public static void actualizarCasosIdentificados (Set<String> oCasos)
    {
        List<Case> oListCasos = new List<Case>();
        Set<String> oCasosRepresentantes = new Set<String>();
        Set<String> setNumPerDuplicados = new Set<String>();

        if (oCasos != null)
        {
            // Tratamiento de la lista recibida.
            for (String sClave : oCasos)
            {
                try
                {
                    List<String> oData = sClave.split('##');
                    String sTipoReg = oData[2];
                    String sCasoId = '';
                    String sNumPer = '';

                    if (sTipoReg == 'Cliente')
                    {
                        sCasoId = oData[8];
                        sNumPer = oData[1];

                        if (sCasoId != '' && sCasoId != 'N/A')
                        {
                            Case oCaso = new Case();
                            oCaso.Id = sCasoId;
                            oCaso.CC_IdentCliente__c = '1';
                            oListCasos.add(oCaso);

                            oCasosRepresentantes.add(sCasoId);

                            if (String.isNotBlank(sNumPer))
                                {setNumPerDuplicados.add(sNumPer);}
                        }
                    }

                }catch(Exception e){
                    // Tratamiento unitario de error. Por ahora descartamos y se quedan los casos como no identificados.
                    CBK_Log.error('Error en metodo actualizarCasosIdentificados ' + e.getMessage());
                }
            }

            // Lanzar actualización de los casos.
            if (!oListCasos.isEmpty())
            {
                Database.SaveResult[] oResUp = Database.update(oListCasos, false);
            }

            // Borrar posibles contactos duplicados.
            if (!setNumPerDuplicados.isEmpty())
            {
                gestionarCuentasDuplicadas (setNumPerDuplicados);
            }

            // Gestión de representantes de los casos asociados e identificados.
            if (!oCasosRepresentantes.isEmpty())
            {
                gestionRepresentantesCaso (oCasosRepresentantes);
            }
        }
    }

    public static void identificarClientesAsync(List<ID> listNewObj) {

        Set<ID> oID = new Set<ID>(listNewObj);

        // Si existen elementos nuevos enrutados, gestión llamada Alfabético.
        // Lanzamos un máximo de 50 callouts (límite Hard), con las llamadas repartidas.
        if (oID.size() > 0)
        {
            List<ID> oIDList = new List<ID>(oID);
            Integer j = 1;
            Map<Integer,List<ID>> oMap = new Map<Integer,List<ID>>();
            for (Integer i=0;i<oIDList.size();i++)
            {
                if (j > 50)    {j = 1;}

                // Inicializar listas.
                if (oMap.get(j) == null)
                {
                    List<ID> oSet = new List<ID>();
                    oMap.put(j,oSet);
                }

                // Añadir valor.
                oMap.get(j).add(oIDList[i]);

                j = j + 1;
            }

            // Lanzar llamadas Futuras.

            for (Integer i : oMap.keySet())
            {
                CC_IdentCliente_Future.CallUpdateALF(oMap.get(i));
            }

            oIDList.clear();
            oIDList = null;

            oMap.clear();
            oMap = null;
        }

        oID.clear();
        oID = null;
    }

    /*
        Método para recuperar los NumPerso asociados a una llamada.
        El SET devuelto se genera como clave la siguiente información:

        NUMPERSO##TIPO_REGISTRO##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##CASO_ID

        Ahora el tipo de registro será Cliente, que se traducirá al RecordType de Clientes.
    */
    static private Set<String> getNumPersoLlamada (Set<String> oLlamadas)
    {
        Set<String> oNumPer = new Set<String>();

        /*if (oLlamadas.size() > 0)
        {
            List<CC_Llamada__c> oDatosLlamadas = [SELECT Id, CC_NumPerso__c, CC_Caso__c, CC_Cuenta__c, CC_Contacto__c FROM CC_Llamada__c WHERE Id IN :oLlamadas];
            for (CC_Llamada__c oLlamada : oDatosLlamadas)
            {
                if (oLlamada.CC_NumPerso__c != null && oLlamada.CC_NumPerso__c != '')
                {
                    // Añadir el NumPerso a la lista, si hay que llamar a Alfabético / CLI.

                    String sClaveNP = '';
                    sClaveNP = sClaveNP + oLlamada.CC_NumPerso__c + '##Cliente##' + oLlamada.Id + '##N/A##N/A##';

                    if (oLlamada.CC_Cuenta__c != null) {
                        sClaveNP = sClaveNP + oLlamada.CC_Cuenta__c + '##';
                    }else{
                        sClaveNP = sClaveNP + 'N/A##';
                    }

                    if (oLlamada.CC_Contacto__c != null) {
                        sClaveNP = sClaveNP + oLlamada.CC_Contacto__c + '##';
                    }else{
                        sClaveNP = sClaveNP + 'N/A##';
                    }

                    if (oLlamada.CC_Caso__c != null) {
                        sClaveNP = sClaveNP + oLlamada.CC_Caso__c + '##';
                    }else{
                        sClaveNP = sClaveNP + 'N/A##';
                    }

                    oNumPer.add(sClaveNP);
                }
            }
        }*/

        return oNumPer;
    }

    /*
        Método para buscar un cliente en ALF. Búsquedas disponibles: NumPer, Teléfono y NIF.
    */
    public static Map<String,Object> getIdentificacionALF (String sTipoBusqueda, String sBusqueda)
    {
        // Si no hay datos, salir.
        if (sBusqueda == '' || sBusqueda == null || sTipoBusqueda == '' || sTipoBusqueda == null)
        {
            return null;
        }

        Map<String,Object> oRes = CC_IdentCliente_Future.IdentificarPersALFSync(sTipoBusqueda, sBusqueda);

        return oRes;
    }

    /*
        Método para recuperar si el NumPer está actualizado o no de ALF.
        Se devuelve un SET con los NumPer a buscar en ALF.
    */
    static public Set<String> getNumPerSinActualizar (Set<String> oNumPerso)
    {
        Set<String> oObj = new Set<String>();
        Set<String> oObjNoAct = new Set<String>();

        if (!oNumPerso.isEmpty())
        {
            // Recuperar la configuración de la integración.
            Integer iDiasRef = CC_WS_Methods_ALF.getDiasRefrescoALF ('CC_Int_ALF');
            Date oFechaActual = Date.today();

            List<Account> oAccount = [SELECT Id, CC_NumPerso__c, CC_FechaRefresco__c FROM Account WHERE CC_NumPerso__c in :oNumPerso];
            for (Account oAux : oAccount)
            {
                Boolean bRefrescar = true;
                if (oAux.CC_FechaRefresco__c != null)
                {
                    Date oFechaAux = oAux.CC_FechaRefresco__c;
                    oFechaAux = oFechaAux.addDays(iDiasRef);

                    if (oFechaAux > oFechaActual)
                        {bRefrescar = false;}
                }

                if (bRefrescar == false)    {oObjNoAct.add(oAux.CC_NumPerso__c);}
            }

            List<Contact> oContact = [SELECT Id, CC_NumPerso__c, CC_FechaRefresco__c FROM Contact WHERE CC_NumPerso__c in :oNumPerso];
            for (Contact oAux : oContact)
            {
                Boolean bRefrescar = true;
                if (oAux.CC_FechaRefresco__c != null)
                {
                    Date oFechaAux = oAux.CC_FechaRefresco__c;
                    oFechaAux = oFechaAux.addDays(iDiasRef);

                    if (oFechaAux > oFechaActual)
                        {bRefrescar = false;}
                }

                if (bRefrescar == false)
                    {oObjNoAct.add(oAux.CC_NumPerso__c);}
            }
        }

        // Cruzar Sets para obtener los NumPerso a consultar.
        for (String sAux : oNumPerso)
        {
            if (!oObjNoAct.contains(sAux))
            {
                oObj.add(sAux);
            }
        }

        oObjNoAct.clear();
        oObjNoAct = null;

        return oObj;
    }

    /*
        Función temporal. Simular la consulta de contratos.
    */
    //static public List<CC_Representante_Contrato__c> generarSimulacionContratosCliente (String sNumPerso)
    // static public List<CC_Representante_Contrato__c> generarSimulacionContratosCliente (String sNumPerso)
    // {
    //     List<CC_Representante_Contrato__c> oContratosRes = new List<CC_Representante_Contrato__c>();

    //     CC_Representante_Contrato__c oNuevoContrato = new CC_Representante_Contrato__c();
    //     oNuevoContrato.RecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Contrato').getRecordTypeId();
    //     oNuevoContrato.CC_ClienteContrato__r = new Account(CC_NumPerso__c = sNumPerso);
    //     //oNuevoContrato.Account = new Account(CC_NumPerso__c = sNumPerso);
    //     oNuevoContrato.CC_IdExterno__c = sNumPerso + '_1_1_2665_100482';
    //     oNuevoContrato.CC_Empresa__c = '1';
    //     oNuevoContrato.CC_Area__c = '1';
    //     oNuevoContrato.CC_Oficina__c = '2665';
    //     //oNuevoContrato.CC_Contrato__c = '100482';
    //     oNuevoContrato.Name = '100482';
    //     oNuevoContrato.CC_NumPerso__c = sNumPerso;
    //     oNuevoContrato.CC_Inactivo__c = false;
    //     //oNuevoContrato.Status = 'Activated';

    //     oContratosRes.add(oNuevoContrato);

    //     CC_Representante_Contrato__c oNuevoContrato2 = new CC_Representante_Contrato__c();
    //     oNuevoContrato2.RecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Contrato').getRecordTypeId();
    //     oNuevoContrato2.CC_ClienteContrato__r = new Account(CC_NumPerso__c = sNumPerso);
    //     oNuevoContrato2.CC_IdExterno__c = sNumPerso + '_1_1_2665_100483';
    //     oNuevoContrato2.CC_Empresa__c = '1';
    //     oNuevoContrato2.CC_Area__c = '1';
    //     oNuevoContrato2.CC_Oficina__c = '2665';
    //     //oNuevoContrato2.CC_Contrato__c = '100483';
    //     oNuevoContrato2.Name = '100483';
    //     oNuevoContrato2.CC_NumPerso__c = sNumPerso;
    //     oNuevoContrato2.CC_Inactivo__c = false;
    //     //oNuevoContrato.Status = 'Activated';

    //     oContratosRes.add(oNuevoContrato2);

    //     return oContratosRes;
    // }

    /*
        Método para inactivar los representantes legales de un cliente y sus contratos que se está consultando a Alfabético (refresco de información).
    */
    static public void inactivarRepresentantesCuentaySusContratos (Set<String> oNumPers)
    {
        /*
        //String sRTRepresentantes = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        List<CC_Representante_Contrato__c> oRepresentanteContratoActualizar = new List<CC_Representante_Contrato__c>();
        //List<Contract> oContratosActualizar = new List<Contract>();

        if (!oNumPers.isEmpty())
        {
            for (CC_Representante_Contrato__c oRepresentanteContrato : [SELECT Id, CC_NumPerso__c, CC_Inactivo__c FROM CC_Representante_Contrato__c WHERE CC_NumPerso__c IN :oNumPers])
            {
                oRepresentanteContrato.CC_Inactivo__c = true;
                oRepresentanteContratoActualizar.add(oRepresentanteContrato);
            }

            /*for (Contract oContrato : [SELECT Id, CC_NumPerso__c, CC_Inactivo__c FROM Contract WHERE CC_NumPerso__c IN :oNumPers])
            {
                oContrato.CC_Inactivo__c = true;
                oContratosActualizar.add(oContrato);
            }*/
        //}

        /*if (!oContratosActualizar.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.update(oContratosActualizar, false);
        }*/

        /*if (!oRepresentanteContratoActualizar.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.update(oRepresentanteContratoActualizar, false);
        }*/
        List<Contact> oRepresentanteContratoActualizar = new List<Contact>();
        String sRTRepresentante = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        if (!oNumPers.isEmpty())
        {
            for (Contact oRepresentanteContrato : [SELECT Id, CC_NumPerso__c, CC_Inactivo__c
                                                                        FROM Contact
                                                                        WHERE CC_NumPersoAsoc__c IN :oNumPers
                                                                        AND RecordTypeId = :sRTRepresentante])
            {
                oRepresentanteContrato.CC_Inactivo__c = true;
                oRepresentanteContratoActualizar.add(oRepresentanteContrato);
            }
        }

        if (!oRepresentanteContratoActualizar.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.update(oRepresentanteContratoActualizar, false);
        }
    }

    /*
        Método para actualizar los casos asociados. Gestión de representantes (no vincular contacto).
    */
    static public void gestionRepresentantesCaso (Set<String> oCasos)
    {
        if (oCasos.isEmpty())
        {
            return;
        }

        List<Case> oCasosActualizar = new List<Case>();

        for (Case oCaso : [SELECT Id, AccountId, ContactId, Account.CC_IncapacitadoLegal__c, Account.CC_MenorEmancipado__c, Account.CC_Tipo_Persona__c, Contact.CC_Edad__c FROM Case WHERE Id IN :oCasos])
        {
            if (oCaso.AccountId != null && oCaso.ContactId != null)
            {
                // Empresas. No vincular un contacto al caso.
                if (oCaso.Account.CC_Tipo_Persona__c == 'J')
                {
                    oCaso.ContactId = null;
                    oCasosActualizar.add(oCaso);
                }

                // Personas físicas.
                if (oCaso.Account.CC_Tipo_Persona__c == 'F')
                {
                    // Menor de edad, no emancipado. No se vincula contacto.
                    if (oCaso.Account.CC_MenorEmancipado__c == false && oCaso.Contact.CC_Edad__c < 18)
                    {
                        oCaso.ContactId = null;
                        oCasosActualizar.add(oCaso);
                    }

                    // Incapacitado legal. No se vincula contacto.
                    if (oCaso.Account.CC_IncapacitadoLegal__c == true)
                    {
                        oCaso.ContactId = null;
                        oCasosActualizar.add(oCaso);
                    }
                }
            }
        }

        if (!oCasosActualizar.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.update(oCasosActualizar, false);
        }
    }

    static public void gestionarCuentasDuplicadas (Set<String> setNumPerDuplicados)
    {
        if (setNumPerDuplicados != null && !setNumPerDuplicados.isEmpty())
        {
            List<Contact> listadoContact = [SELECT Id FROM Contact
                                            WHERE AccountId <> null AND
                                            (Account.CC_NumPerso__c = null OR Account.CC_NumPerso__c = '') AND
                                            Account.CC_NumPersoOrig__c IN :setNumPerDuplicados];

            List<Account> listadoAccount = [SELECT Id FROM Account
                                            WHERE (CC_NumPerso__c = null OR CC_NumPerso__c = '') AND
                                            CC_NumPersoOrig__c IN :setNumPerDuplicados];

            if (!listadoContact.isEmpty())
            {
                Database.DeleteResult[] drList = Database.delete(listadoContact, false);
            }

            if (!listadoAccount.isEmpty())
            {
                Database.DeleteResult[] drList = Database.delete(listadoAccount, false);
            }
        }
    }

    /*
        Llamada para identificar una lista de documentos de identidad y teléfonos de forma síncrona.
        No actualiza datos de caso origen ni otros datos.
        Identifica los datos y devuelve los datos creados en Salesforce.
    */
    @future(callout=true)
    static public void IdentificarPersALFASynchronous (String sTipoBusqueda, String sBusqueda)
    {
        Map<String,Object> oRes = IdentificarPersALFSync (sTipoBusqueda, sBusqueda);
    }
}