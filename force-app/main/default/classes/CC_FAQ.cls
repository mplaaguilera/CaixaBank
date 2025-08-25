public with sharing class CC_FAQ {

    /* Nueva gestión de carga de datos de aplicaciones */

    @future(callout=true)
    static private void getAplicacionesCognitivoFuture (ID oId, String sAplicacion, Boolean bLanzarBatch) {
        getAplicacionesCognitivo (oId, sAplicacion, bLanzarBatch);
    }

    static private void getAplicacionesCognitivo (ID oId, String sAplicacion, Boolean bLanzarBatch) {

        String sServicio = '';
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_APP_FAQ');

        if (oConfig != null)
        {
            sServicio = oConfig.CC_EndPoint__c + sAplicacion;

            // Gestión trazas.
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'APP_FAQS_HTTP';
                oTraza.CC_Identificador__c = sAplicacion;
                oTraza.CC_FechaInicio__c = datetime.now();

                if (oConfig.CC_TrazaEntrada__c)
                    oTraza.CC_MensajeEntrada__c = sServicio;
            }

            HttpRequest request = new HttpRequest();
            Http http = new Http();
            HTTPResponse res;
            String sSalida = '';

            try {
                request.setTimeOut(Integer.valueOf(oConfig.CC_TimeOut__c));
                request.setMethod(oConfig.CC_TipoPeticion__c);
                request.setHeader('Content-Type', oConfig.CC_ContentType__c);

                if (!Test.isRunningTest())
                    request.setClientCertificateName(oConfig.CC_Certificado__c);

                request.setEndpoint(sServicio);
                res = http.send(request);

                if (res.getStatusCode() != 200) {
                    sDescError = 'Error petición.';
                    sDetalleError = res.getStatus() + ' (' + res.getStatusCode() + ')';
                }else{
                    sSalida = res.getBody();
                }

            }catch (Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }

            // Cargar respuesta.
            try {
                if (sDescError == '')
                {
                    cargarRespuestaApp (oId, sSalida);

                    // Lanzar el batch, frente a una carga puntual de una aplicación.
                    if (bLanzarBatch)
                    {
                        //Si el metadato está activo o no hay registro se planifica con el framework
                        List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_FAQ_Batch' and Activo__c=false LIMIT 1];
                        if ((oConf.isEmpty())&&(!Test.isRunningTest())){
                            map<String,Object> params = New map<String,Object>();
                            params.put('sAplicacion',String.valueOf(oId));
                            CBK_BatchJob.executeBatch('CC_FAQ_Batch', 1, params,0);
                        } else {
                            CC_FAQ_Batch batch = new CC_FAQ_Batch(String.valueOf(oId));
                            Database.executeBatch(batch,1);
                        }
                    }
                }
            } catch (Exception e) {
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

                // Insertar traza.
                List<CC_TrazaInt__c> oListTraza = new List<CC_TrazaInt__c>();
                oListTraza.add(oTraza);
                Database.SaveResult[] oResUp = Database.insert(oListTraza, false);
            }
        }

    }

    static public void cargarRespuestaApp (ID oId, String sJSONData)
    {
        if (String.isBlank(sJSONData))
        {
            return;
        }

        CC_AppFAQ_JSON datos = CC_AppFAQ_JSON.parse(sJSONData);

        // Actualizar datos de la aplicación.
        Integer iVersion = 0;
        List<CC_FAQ__c> oAplicaciones = [SELECT Id, Name, CC_Version__c, CC_Nombre__c, CC_Id_App__c, CC_FAQ_Id__c, CC_FAQ_Ident__c
                                        FROM CC_FAQ__c WHERE Id = :oId LIMIT 1];

        if (!oAplicaciones.isEmpty())
        {
            // Versionar aplicación.
            if (oAplicaciones[0].CC_Version__c != null)
            {
                iVersion = Integer.valueOf(oAplicaciones[0].CC_Version__c);
            }
            iVersion = iVersion + 1;

            oAplicaciones[0].Id = oId;
            oAplicaciones[0].Name = datos.codigo;
            oAplicaciones[0].CC_Nombre__c = datos.codigo;
            oAplicaciones[0].CC_Id_App__c = String.valueOf(datos.idAplicacion);
            oAplicaciones[0].CC_FAQ_Id__c = String.valueOf(datos.idAplicacion);
            oAplicaciones[0].CC_FAQ_Ident__c = String.valueOf(datos.idAplicacion);
            oAplicaciones[0].CC_VersionActualizando__c = iVersion;
            oAplicaciones[0].CC_Aplicacion_Siebel__c = String.valueOf(datos.aplicacionSiebel);

            update oAplicaciones;

            // Recorrer los espacios de la respuesta para actualizar la información en Salesforce.
            if (datos.espacios != null)
            {
                List<CC_FAQ__c> oListaEspacios = new List<CC_FAQ__c>();
                ID iRT = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
                for (CC_AppFAQ_JSON.Espacios oEspacio : datos.espacios)
                {
                    CC_FAQ__c oNewEspacio = new CC_FAQ__c();
                    oNewEspacio.CC_Id_Espacio__c = oEspacio.idEspacio;
                    oNewEspacio.Name = oEspacio.espacio;
                    oNewEspacio.CC_Descripcion_ca__c = oEspacio.descripcionCa;
                    oNewEspacio.CC_Descripcion_es__c = oEspacio.descripcionEs;
                    oNewEspacio.CC_FAQ_Id__c = String.valueOf(datos.idAplicacion) + '_'+ oEspacio.idEspacio;//Cambio Mayo2020
                    oNewEspacio.CC_FAQ_Ident__c = oEspacio.idEspacio;
                    oNewEspacio.CC_Nombre__c = oEspacio.espacio;
                    oNewEspacio.CC_Id_App__c = String.valueOf(datos.idAplicacion);
                    oNewEspacio.CC_VersionActualizando__c = iVersion;
                    oNewEspacio.CC_Lookup_App__c = oId;
                    oNewEspacio.RecordTypeId = iRT;
                    oNewEspacio.CC_Obsoleto__c = false;

                    // Preparar la lista de IDs globales a cargar (modo String).
                    if (oEspacio.idsGlobales != null)
                    {
                        String sListaIDs = '';
                        for (Integer idGlobal : oEspacio.idsGlobales)
                        {
                            if (sListaIDs != '')
                            {
                                sListaIDs = sListaIDs + ',';
                            }
                            sListaIDs = sListaIDs + String.valueOf(idGlobal);
                        }

                        oNewEspacio.CC_ListaIDsGlobales__c = sListaIDs;
                    }else{
                        oNewEspacio.CC_ListaIDsGlobales__c = '';
                    }

                    oListaEspacios.add(oNewEspacio);
                }

                // Cargar espacios.
                upsert oListaEspacios CC_FAQ_Id__c;

                // Preparar la lista de espacios e IDs globales a cargar.
                List<CC_FAQ__c> oListaEspaciosActualizar = new List<CC_FAQ__c>();
                ID iRTEspaciosAct = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_EspaciosActualizar').getRecordTypeId();
                for (CC_FAQ__c oEspacio : oListaEspacios)
                {
                    if (oEspacio.CC_ListaIDsGlobales__c != '')
                    {
                        List<String> oIDs = oEspacio.CC_ListaIDsGlobales__c.split(',');
                        for (String sID : oIDs)
                        {
                            CC_FAQ__c oNewEspacioAct = new CC_FAQ__c();
                            oNewEspacioAct.RecordTypeId = iRTEspaciosAct;
                            oNewEspacioAct.CC_GlobalId__c = sID;
                            oNewEspacioAct.Name = oEspacio.Name;
                            oNewEspacioAct.CC_Lookup_App__c = oEspacio.CC_Lookup_App__c;
                            oNewEspacioAct.CC_Lookup_Espacio__c = oEspacio.Id;
                            oNewEspacioAct.CC_Id_Espacio__c = oEspacio.CC_Id_Espacio__c;
                            //oNewEspacioAct.CC_FAQ_Id__c = oEspacio.CC_FAQ_Id__c;
                            //oNewEspacioAct.CC_FAQ_Ident__c = oEspacio.CC_FAQ_Ident__c;
                            oNewEspacioAct.CC_Nombre__c = oEspacio.CC_Nombre__c;
                            oNewEspacioAct.CC_Id_App__c = String.valueOf(datos.idAplicacion);
                            oNewEspacioAct.CC_VersionActualizando__c = iVersion;
                            oNewEspacioAct.CC_ErrorCola__c = false;
                            oListaEspaciosActualizar.add(oNewEspacioAct);
                        }
                    }
                }

                // Cargar la lista de espacios para actualizar por el batch.
                insert oListaEspaciosActualizar;
            }
        }
    }

    public static void cargarApps() {

        // Recuperar todas las aplicaciones dadas de alta.
        ID iRT = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        List<CC_FAQ__c> oAplicaciones = [SELECT Id, Name FROM CC_FAQ__c WHERE RecordTypeId = :iRT];

        for (CC_FAQ__c oAux : oAplicaciones)
        {
            // Obtener las FAQs del espacio.
            getAplicacionesCognitivoFuture (oAux.Id, oAux.Name, false);
        }
    }

    public static void refrescarApps(String sAplicacion) {

        // Recuperar todas las aplicaciones dadas de alta.
        ID iRT = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        List<CC_FAQ__c> oAplicaciones = [SELECT Id, Name FROM CC_FAQ__c WHERE RecordTypeId = :iRT AND Name = :sAplicacion LIMIT 1];

        if (oAplicaciones.isEmpty())
        {
            CC_FAQ__c oNewApp = new CC_FAQ__c();
            oNewApp.Name = sAplicacion;
            oNewApp.RecordTypeId = iRT;
            insert oNewApp;

            oAplicaciones.add(oNewApp);
        }

        for (CC_FAQ__c oAux : oAplicaciones)
        {
            // Obtener las FAQs del espacio.
            getAplicacionesCognitivo (oAux.Id, oAux.Name, true);
        }
    }

    /* NUEVA GESTIÓN DE CARGA DE FAQS POR BATCH */
    static public String getFAQCognitivoWSBatch (String sEspacio, String sIdGlobal)
    {
        String sRespuestaWS = '';
        String sServicio = '';
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_FAQ');

        if (oConfig != null)
        {
            sServicio = oConfig.CC_EndPoint__c;
            sServicio = sServicio.replace('##espacio##', sEspacio);
            sServicio = sServicio.replace('##idglobal##', sIdGlobal);

            // Gestión trazas.
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'FAQS_HTTP';
                oTraza.CC_Identificador__c = sEspacio;
                oTraza.CC_FechaInicio__c = datetime.now();

                if (oConfig.CC_TrazaEntrada__c)
                    oTraza.CC_MensajeEntrada__c = sServicio;
            }

            HttpRequest request = new HttpRequest();
            Http http = new Http();
            HTTPResponse res;
            String sSalida = '';

            try {
                request.setTimeOut(Integer.valueOf(oConfig.CC_TimeOut__c));
                request.setMethod(oConfig.CC_TipoPeticion__c);
                request.setHeader('Content-Type', oConfig.CC_ContentType__c);

                if (!Test.isRunningTest())
                    request.setClientCertificateName(oConfig.CC_Certificado__c);

                request.setEndpoint(sServicio);
                res = http.send(request);

                if (res.getStatusCode() != 200) {
                    sDescError = 'Error petición.';
                    sDetalleError = res.getStatus() + ' (' + res.getStatusCode() + ')';
                }else{
                    sSalida = res.getBody();
                }

            }catch (Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }

            // Preparar retorno al batch.
            sRespuestaWS = sSalida;

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

                // Insertar traza.
                List<CC_TrazaInt__c> oListTraza = new List<CC_TrazaInt__c>();
                oListTraza.add(oTraza);
                Database.SaveResult[] oResUp = Database.insert(oListTraza, false);
            }
        }

        return sRespuestaWS;
    }

    static public String cargarRespuestaEspacios (ID oId, String sJSONData)
    {
        String sPrimerError = '';
        CC_FAQ_JSON datos = CC_FAQ_JSON.parse(sJSONData);

        List<CC_FAQ_JSON.Faqs> faqsEntrada = (List<CC_FAQ_JSON.Faqs>)datos.faqs;
        List<CC_FAQ_JSON.Topics> categorias = (List<CC_FAQ_JSON.Topics>)datos.topics;
        CC_FAQ_JSON.Espacio espacioCognitive = datos.Espacio;

        List<CC_FAQ__c> espaciosToUpsert = new List<CC_FAQ__c>();

        Id recordTypeIdEspacio = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        List<CC_FAQ__c> espacios = [SELECT Id, Name,CC_FAQ_Id__c, CC_Lookup_App__r.CC_Id_App__c, CC_Descripcion_ca__c,
                                    CC_Descripcion_es__c, CC_Id_Espacio__c, CC_Version__c, CC_Lookup_App__r.Id,
                                    CC_VersionActualizando__c, CC_ListaIDsGlobales__c
                                    FROM CC_FAQ__c
                                    WHERE Id = :oId];

        Integer iVersion = 0;

        for(CC_FAQ__c espacio : espacios)
        {
            if(espacioCognitive != null)
            {
                iVersion = Integer.valueOf(espacio.CC_VersionActualizando__c);

            	espacio.CC_Id_Espacio__c = espacioCognitive.idEspacio;
                espacio.Name = espacioCognitive.espacio;
                espacio.CC_Descripcion_ca__c = espacioCognitive.descripcionCa;
                espacio.CC_Descripcion_es__c = espacioCognitive.descripcionEs;
                espacio.CC_FAQ_Id__c = espacio.CC_Lookup_App__r.CC_Id_App__c + '_' + espacioCognitive.idEspacio;//Cambio Mayo2020
                espacio.CC_Nombre__c = espacioCognitive.espacio;
                espacio.CC_Id_App__c = espacio.CC_Lookup_App__r.CC_Id_App__c;
                espacio.CC_Obsoleto__c = false;

                espaciosToUpsert.add(espacio);
            }
        }

        if(!espaciosToUpsert.isEmpty())
        {
            upsert espaciosToUpsert;
        }else{
            // El espacio no existe. Salir.
            return '';
        }

        // Preparar objeto espacio para utilizar en la carga de categorias y FAQs.
        CC_FAQ__c espacioUpsert = espaciosToUpsert[0];
        String appId = espaciosToUpsert[0].CC_Lookup_App__r.CC_Id_App__c;

        Map<String, String> nombresCategorias = new Map<String, String>();
        List<CC_FAQ__c> categoriasToUpsert = new List<CC_FAQ__c>();


        for (CC_FAQ_JSON.Topics c : categorias) {
            nombresCategorias.put(c.idTopic, c.topic);

            CC_FAQ__c categoriaUpsert = new CC_FAQ__c();
            if(espacioUpsert != null)
            {
                categoriaUpsert.CC_Lookup_Espacio__c = espacioUpsert.Id;
                categoriaUpsert.CC_Lookup_App__c = espacioUpsert.CC_Lookup_App__r.Id;
            }
            Id recordTypeCategoria = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();
            categoriaUpsert.Name = c.topic;
            categoriaUpsert.CC_Topic__c = c.topic;
            categoriaUpsert.CC_Id_Categoria__c = c.idTopic;
            categoriaUpsert.CC_Descripcion_ca__c = c.descripcionCa;
            categoriaUpsert.CC_Descripcion_es__c = c.descripcionEs;
            categoriaUpsert.RecordTypeId = recordTypeCategoria;
            categoriaUpsert.CC_FAQ_Id__c = appId + '_' + c.idEspacio + '_' + c.idTopic;//Cambio Mayo2020
            categoriaUpsert.CC_FAQ_Ident__c = c.idTopic;
            categoriaUpsert.CC_ListaIDsGlobales__c = espaciosToUpsert[0].CC_ListaIDsGlobales__c;
            categoriaUpsert.CC_Nombre__c = c.topic;
            categoriaUpsert.CC_Id_Espacio__c = c.idEspacio;
            categoriaUpsert.CC_Id_App__c = espacioUpsert.CC_Id_App__c;
            categoriaUpsert.CC_Obsoleto__c = false;
            categoriaUpsert.CC_Telefono__c = c.tfnoEs;
            categoriaUpsert.CC_TelefonoCA__c = c.tfnoCa;

            // Indicar la versión activa.
            categoriaUpsert.CC_VersionActualizando__c = iVersion;

            categoriasToUpsert.add(categoriaUpsert);
        }

        if(!categoriasToUpsert.isEmpty())
        {
            upsert categoriasToUpsert CC_FAQ_Id__c;
        }

        // Borrado objetos que ya no se utilizan.
        espaciosToUpsert = null;
        espacios = null;
        categoriasToUpsert = null;
        categorias = null;

        //Carga de FAQs
        List<CC_FAQ__c> carga_faqs = new List<CC_FAQ__c>();
        List<CC_FAQ__c> carga_faq_cust = new List<CC_FAQ__c>();
        List<CC_Intent__c> carga_intents = new List<CC_Intent__c>();
        List<CC_Intent__c> carga_intents_cust = new List<CC_Intent__c>();

        Id recordTypeFaq = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_FAQ').getRecordTypeId();
        Id recordTypeFaqCust = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_FAQ_Custom').getRecordTypeId();
        Id recordTypeIntent = Schema.SObjectType.CC_Intent__c.getRecordTypeInfosByDeveloperName().get('CC_Intent').getRecordTypeId();
        Id recordTypeIntentCust = Schema.SObjectType.CC_Intent__c.getRecordTypeInfosByDeveloperName().get('CC_Intent_Custom').getRecordTypeId();

        for (CC_FAQ_JSON.Faqs oFaq : faqsEntrada)
        {
            // Preparar el registro de FAQ a cargar.
            String sClaveCat = appId +'_'+ oFaq.idEspacio +'_'+ oFaq.idTopic;//Cambio Mayo2020
            String sClaveFAQ = appId +'_'+ oFaq.idEspacio +'_'+ oFaq.idTopic +'_'+ oFaq.idFaq;//Cambio Mayo2020

            CC_FAQ__c oNewFaq = new CC_FAQ__c();
            oNewFaq.CC_Espacio__c = espacioUpsert.Name;
            oNewFaq.CC_Categoria__c = nombresCategorias.get(oFaq.idTopic);
            oNewFaq.CC_Lookup_Espacio__c = espacioUpsert.Id;
            oNewFaq.CC_Lookup_Categoria__r = new CC_FAQ__c(CC_FAQ_Id__c = sClaveCat);
            oNewFaq.CC_Lookup_App__c = espacioUpsert.CC_Lookup_App__r.Id;
            oNewFaq.CC_FAQ_Id__c = sClaveFAQ;
            oNewFaq.CC_FAQ_Ident__c = oFaq.idFaq;
            oNewFaq.RecordTypeId = recordTypeFaq;

            // Indicar la versión de la FAQ.
            oNewFaq.CC_Version__c = iVersion;

            if (oFaq.texto == null || oFaq.texto == 'null')
            {
                oFaq.texto = '';
            }

            if (oFaq.texto != null)
            {
                if (oFaq.texto.length() > 255)
                {
                    oNewFaq.CC_Nombre__c = oFaq.texto.left(255);
                }else{
                    oNewFaq.CC_Nombre__c = oFaq.texto;
                }

                if (oFaq.texto.length() > 80)
                {
                    oNewFaq.Name = oFaq.texto.left(80);
                }else{
                    oNewFaq.Name = oFaq.texto;
                }
            }

            if (oFaq.textoParaUsuarioEs != null)
            {
                if (oFaq.textoParaUsuarioEs.length() > 500)
                {
                    oNewFaq.CC_Pregunta_ESP__c = oFaq.textoParaUsuarioEs.left(500);
                }else{
                    oNewFaq.CC_Pregunta_ESP__c = oFaq.textoParaUsuarioEs;
                }
            }

            if (oFaq.textoParaUsuarioCa != null)
            {
                if (oFaq.textoParaUsuarioCa.length() > 500)
                {
                    oNewFaq.CC_Pregunta_CAT__c = oFaq.textoParaUsuarioCa.left(500);
                }else{
                    oNewFaq.CC_Pregunta_CAT__c = oFaq.textoParaUsuarioCa;
                }
            }

            if(oFaq.idFaqSiebel == 'null' || oFaq.idFaqSiebel == null)
            {
                oFaq.idFaqSiebel = '';
            }

            if (oFaq.link == 'null' || oFaq.link == null)
            {
                oFaq.link = '';
            }

            if (oFaq.link != '')
            {
                if (oFaq.link.length() > 255)
                {
                    oNewFaq.CC_URL__c = oFaq.link.left(255);
                }else {
                    oNewFaq.CC_URL__c = oFaq.link;
                }
            }

            oNewFaq.CC_UltFaqSiebel__c = oFaq.idFaqSiebel;

            carga_faqs.add(oNewFaq);

            if (oFaq.customsFaq != null)
            {
                // Preparar las diferentes custom de cada FAQ.
                for (CC_FAQ_JSON.CustomsFaq oCustom : oFaq.customsFaq)
                {
                    CC_FAQ__c faqCust = new CC_FAQ__c();
                    faqCust.CC_Espacio__c = espacioUpsert.Name;
                    faqCust.CC_Categoria__c = nombresCategorias.get(oFaq.idTopic);
                    faqCust.CC_Lookup_Espacio__c = espacioUpsert.Id;
                    faqCust.CC_Lookup_Categoria__r = new CC_FAQ__c(CC_FAQ_Id__c = sClaveCat);
                    faqCust.CC_Lookup_App__c = espacioUpsert.CC_Lookup_App__r.Id;
                    faqCust.CC_Lookup_FAQ__r = new CC_FAQ__c(CC_FAQ_Id__c = sClaveFAQ);
                    faqCust.CC_FAQ_Id__c = sClaveFAQ + '_' + oCustom.idGlobal;
                    faqCust.CC_FAQ_Ident__c = oFaq.idFaq;
                    faqCust.RecordTypeId = recordTypeFaqCust;
                    faqCust.CC_GlobalId__c = oCustom.idGlobal;

                    // Indicar la versión de la FAQ Custom.
                    faqCust.CC_Version__c = iVersion;

                    if (oCustom.textoParaUsuario != null)
                    {
                        if (oCustom.textoParaUsuario.length() > 500)
                        {
                            faqCust.CC_TextoMostrar__c = oCustom.textoParaUsuario.left(500);
                        }else{
                            faqCust.CC_TextoMostrar__c = oCustom.textoParaUsuario;
                        }

                        if (oCustom.textoParaUsuario.length() > 255)
                        {
                            faqCust.CC_Nombre__c = oCustom.textoParaUsuario.left(255);
                        }else{
                            faqCust.CC_Nombre__c = oCustom.textoParaUsuario;
                        }

                        if (oCustom.textoParaUsuario.length() > 80)
                        {
                            faqCust.Name = oCustom.textoParaUsuario.left(80);
                        }else{
                            faqCust.Name = oCustom.textoParaUsuario;
                        }
                    }

                    if (oFaq.textoParaUsuarioEs != null)
                    {
                        if (oFaq.textoParaUsuarioEs.length() > 500)
                        {
                            faqCust.CC_Pregunta_ESP__c = oFaq.textoParaUsuarioEs.left(500);
                        }else{
                            faqCust.CC_Pregunta_ESP__c = oFaq.textoParaUsuarioEs;
                        }
                    }

                    if (oFaq.textoParaUsuarioCa != null)
                    {
                        if (oFaq.textoParaUsuarioCa.length() > 500)
                        {
                            faqCust.CC_Pregunta_CAT__c = oFaq.textoParaUsuarioCa.left(500);
                        }else{
                            faqCust.CC_Pregunta_CAT__c = oFaq.textoParaUsuarioCa;
                        }
                    }

                    if(oFaq.idFaqSiebel == 'null' || oFaq.idFaqSiebel == null)
                    {
                        oFaq.idFaqSiebel = '';
                    }
                    faqCust.CC_UltFaqSiebel__c = oFaq.idFaqSiebel;
                    faqCust.CC_URL__c = oNewFaq.CC_URL__c;
                    carga_faq_cust.add(faqCust);
                }
            }

            // Preparar los diferentes Intent de cada FAQ.
            for (CC_FAQ_JSON.Intents oInt : oFaq.intents) {

                String sClaveIntent = sClaveFAQ + '_' + String.valueOf(oInt.idIntent);

                CC_Intent__c oNewIntent = new CC_Intent__c();
                oNewIntent.CC_Nombre__c = oInt.intent;
                oNewIntent.CC_IntentIdExt__c = sClaveIntent;
                oNewIntent.CC_Intent_Id__c = oInt.idIntent;
                oNewIntent.CC_FAQ_Id__r = new CC_FAQ__C(CC_FAQ_Id__c = sClaveFAQ);
                oNewIntent.RecordTypeId = recordTypeIntent;

                // Indicar la versión del Intent.
                oNewIntent.CC_Version__c = iVersion;

                if (oInt.intent != null)
                {
                    if (oInt.intent.length() > 80)
                    {
                        oNewIntent.Name = oInt.intent.left(80);
                    }else{
                        oNewIntent.Name = oInt.intent;
                    }
                }

                if (oInt.descripcion != null)
                {
                    if (oInt.descripcion.length() > 500)
                    {
                        oNewIntent.CC_Descripcion__c = oInt.descripcion.left(500);
                    }else{
                        oNewIntent.CC_Descripcion__c = oInt.descripcion;
                    }
                }

                if (oInt.respuestaCortaEs != null)
                {
                    if (oInt.respuestaCortaEs.length() > 5000)
                    {
                        oNewIntent.CC_Respuesta_ESP__c = oInt.respuestaCortaEs.left(5000);
                    }else{
                        oNewIntent.CC_Respuesta_ESP__c = oInt.respuestaCortaEs;
                    }
                }

                if (oInt.respuestaCortaCa != null)
                {
                    if (oInt.respuestaCortaCa.length() > 5000)
                    {
                        oNewIntent.CC_Respuesta_ESP__c = oInt.respuestaCortaCa.left(5000);
                    }else{
                        oNewIntent.CC_Respuesta_ESP__c = oInt.respuestaCortaCa;
                    }
                }

                carga_intents.add(oNewIntent) ;

                if (oInt.customsIntent != null)
                {
                    // Preparar las diferentes custom de cada Intent.
                    for (CC_FAQ_JSON.CustomsIntent oCustomInt : oInt.customsIntent)
                    {
                        CC_Intent__c oNewIntentCust = new CC_Intent__c();
                        oNewIntentCust.CC_Nombre__c = oInt.intent;
                        oNewIntentCust.CC_GlobalId__c = oCustomInt.idGlobal;
                        oNewIntentCust.CC_IntentIdExt__c = sClaveIntent + '_' + oCustomInt.idGlobal;
                        oNewIntentCust.CC_Intent_Id__c = oInt.idIntent;
                        oNewIntentCust.CC_FAQ_Id__r = new CC_FAQ__C(CC_FAQ_Id__c = sClaveFAQ);
                        oNewIntentCust.CC_Intent_Padre__r = new CC_Intent__c(CC_IntentIdExt__c = sClaveIntent);
                        oNewIntentCust.RecordTypeId = recordTypeIntentCust;

                        // Indicar la versión del Intent Custom.
                        oNewIntentCust.CC_Version__c = iVersion;

                        if (oInt.intent != null)
                        {
                            if (oInt.intent.length() > 80)
                            {
                                oNewIntentCust.Name = oInt.intent.left(80);
                            }else{
                                oNewIntentCust.Name = oInt.intent;
                            }
                        }

                        if (oInt.descripcion != null)
                        {
                            if (oInt.descripcion.length() > 500)
                            {
                                oNewIntentCust.CC_Descripcion__c = oInt.descripcion.left(500);
                            }else{
                                oNewIntentCust.CC_Descripcion__c = oInt.descripcion;
                            }
                        }

                        if (oInt.respuestaCortaEs != null)
                        {
                            if (oInt.respuestaCortaEs.length() > 5000)
                            {
                                oNewIntentCust.CC_Respuesta_ESP__c = oInt.respuestaCortaEs.left(5000);
                            }else{
                                oNewIntentCust.CC_Respuesta_ESP__c = oInt.respuestaCortaEs;
                            }
                        }

                        if (oInt.respuestaCortaCa != null)
                        {
                            if (oInt.respuestaCortaCa.length() > 5000)
                            {
                                oNewIntentCust.CC_Respuesta_ESP__c = oInt.respuestaCortaCa.left(5000);
                            }else{
                                oNewIntentCust.CC_Respuesta_ESP__c = oInt.respuestaCortaCa;
                            }
                        }

                        if (oCustomInt.respCorta != null)
                        {
                            if (oCustomInt.respCorta.length() > 5000)
                            {
                                oNewIntentCust.CC_TextoMostrar__c = oCustomInt.respCorta.left(5000);
                            }else{
                                oNewIntentCust.CC_TextoMostrar__c = oCustomInt.respCorta;
                            }
                        }

                        carga_intents_cust.add(oNewIntentCust);
                    }
                }
            }
        }

        /*upsert carga_faqs CC_FAQ__c.Fields.CC_FAQ_Id__c;
        upsert carga_faq_cust CC_FAQ__c.Fields.CC_FAQ_Id__c;
        upsert carga_intents CC_Intent__c.Fields.CC_IntentIdExt__c;
        upsert carga_intents_cust CC_Intent__c.Fields.CC_IntentIdExt__c;*/

        Boolean bCargaOk = true;

        Schema.SObjectField oCampoSearch = CC_FAQ__c.Fields.CC_FAQ_Id__c;
        Database.UpsertResult[] oResUp = Database.upsert(carga_faqs, oCampoSearch, false);
        for (Database.UpsertResult oStatus : oResUp) {
            if (!oStatus.isSuccess() && bCargaOk) {
                for(Database.Error err : oStatus.getErrors()) {
                    if (sPrimerError != '')
                        sPrimerError = sPrimerError + '. ';
                    sPrimerError = err.getMessage();
                }

                bCargaOk = false;
                break;
            }
        }

        Schema.SObjectField oCampoSearch2 = CC_FAQ__c.Fields.CC_FAQ_Id__c;
        Database.UpsertResult[] oResUp2 = Database.upsert(carga_faq_cust, oCampoSearch2, false);
        for (Database.UpsertResult oStatus : oResUp2) {
            if (!oStatus.isSuccess() && bCargaOk) {
                for(Database.Error err : oStatus.getErrors()) {
                    if (sPrimerError != '')
                        sPrimerError = sPrimerError + '. ';
                    sPrimerError = err.getMessage();
                }

                bCargaOk = false;
                break;
            }
        }

        Schema.SObjectField oCampoSearch3 = CC_Intent__c.Fields.CC_IntentIdExt__c;
        Database.UpsertResult[] oResUp3 = Database.upsert(carga_intents, oCampoSearch3, false);
        for (Database.UpsertResult oStatus : oResUp3) {
            if (!oStatus.isSuccess() && bCargaOk) {
                for(Database.Error err : oStatus.getErrors()) {
                    if (sPrimerError != '')
                        sPrimerError = sPrimerError + '. ';
                    sPrimerError = err.getMessage();
                }

                bCargaOk = false;
                break;
            }
        }

        Schema.SObjectField oCampoSearch4 = CC_Intent__c.Fields.CC_IntentIdExt__c;
        Database.UpsertResult[] oResUp4 = Database.upsert(carga_intents_cust, oCampoSearch4, false);
        for (Database.UpsertResult oStatus : oResUp4) {
            if (!oStatus.isSuccess() && bCargaOk) {
                for(Database.Error err : oStatus.getErrors()) {
                    if (sPrimerError != '')
                        sPrimerError = sPrimerError + '. ';
                    sPrimerError = err.getMessage();
                }

                bCargaOk = false;
                break;
            }
        }

        if (!bCargaOk && sPrimerError == '')
        {
            sPrimerError = 'Error al cargar los datos.';
        }

        return sPrimerError;
    }

    /* Gestión del cambio de idioma */
    static public String getNuevoPerfilCliente (String sAplicacion, String sIdioma, String sPerfil)
    {
        String sRespuestaWS = '';
        String sServicio = '';
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';

        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_FAQ_Perfil');

        if (oConfig != null)
        {
            sServicio = oConfig.CC_EndPoint__c;
            sServicio = sServicio.replace('##aplicacion##', sAplicacion);
            sServicio = sServicio.replace('##idioma##', sIdioma);
            sServicio = sServicio.replace('##perfil##', sPerfil);


            // Gestión trazas.
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'FAQS_PERFIL_HTTP';
                oTraza.CC_Identificador__c = sAplicacion + '_' + sIdioma + '_' + sPerfil;
                oTraza.CC_FechaInicio__c = datetime.now();

                if (oConfig.CC_TrazaEntrada__c)
                    oTraza.CC_MensajeEntrada__c = sServicio;
            }

            HttpRequest request = new HttpRequest();
            Http http = new Http();
            HTTPResponse res;
            String sSalida = '';

            try {
                request.setTimeOut(Integer.valueOf(oConfig.CC_TimeOut__c));
                request.setMethod(oConfig.CC_TipoPeticion__c);
                request.setHeader('Content-Type', oConfig.CC_ContentType__c);

                if (!Test.isRunningTest())
                    request.setClientCertificateName(oConfig.CC_Certificado__c);

                request.setEndpoint(sServicio);
                res = http.send(request);

                if (res.getStatusCode() != 200) {
                    sDescError = 'Error petición.';
                    sDetalleError = res.getStatus() + ' (' + res.getStatusCode() + ')';
                }else{
                    sSalida = res.getBody();
                }

            }catch (Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }

            // Preparar retorno al batch.
            sRespuestaWS = sSalida;

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

                // Insertar traza.
                List<CC_TrazaInt__c> oListTraza = new List<CC_TrazaInt__c>();
                oListTraza.add(oTraza);
                Database.SaveResult[] oResUp = Database.insert(oListTraza, false);
            }
        }

        return sRespuestaWS;
    }

    /* Llamadas FAKE pruebas */
/*    static public String RespuestaFakeApp()
    {
        String sFakeRespuesta = '';
        sFakeRespuesta = sFakeRespuesta + '{';
        sFakeRespuesta = sFakeRespuesta + '"idAplicacion":99999999,';
        sFakeRespuesta = sFakeRespuesta + '"nombre":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"codigo":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"aplicacionSiebel":"APP",';
        sFakeRespuesta = sFakeRespuesta + '"espacios":[';
        sFakeRespuesta = sFakeRespuesta + '{';
        sFakeRespuesta = sFakeRespuesta + '"idEspacio":"9999999915000012",';
        sFakeRespuesta = sFakeRespuesta + '"idArea":null,';
        sFakeRespuesta = sFakeRespuesta + '"espacio":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"descripcionEs":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"descripcionAreaEs":null,';
        sFakeRespuesta = sFakeRespuesta + '"descripcionCa":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"descripcionAreaCa":null,';
        sFakeRespuesta = sFakeRespuesta + '"area":null,';
        sFakeRespuesta = sFakeRespuesta + '"piloto":null,';
        sFakeRespuesta = sFakeRespuesta + '"pilotoSim":null,';
        sFakeRespuesta = sFakeRespuesta + '"aplicacion":null,';
        sFakeRespuesta = sFakeRespuesta + '"topics":null,';
        sFakeRespuesta = sFakeRespuesta + '"ha":null,';
        sFakeRespuesta = sFakeRespuesta + '"ca":null,';
        sFakeRespuesta = sFakeRespuesta + '"espacioCustoms":null,';
        sFakeRespuesta = sFakeRespuesta + '"idAplicacion":0,';
        sFakeRespuesta = sFakeRespuesta + '"listaAplicacionesEspacio":null,';
        sFakeRespuesta = sFakeRespuesta + '"idsGlobales":[';
        sFakeRespuesta = sFakeRespuesta + '22,';
        sFakeRespuesta = sFakeRespuesta + '23,';
        sFakeRespuesta = sFakeRespuesta + '24';
        sFakeRespuesta = sFakeRespuesta + ']';
        sFakeRespuesta = sFakeRespuesta + '}';
        sFakeRespuesta = sFakeRespuesta + ']';
        sFakeRespuesta = sFakeRespuesta + '';
        sFakeRespuesta = sFakeRespuesta + '}';

        return sFakeRespuesta;
    }
*/
    static public String RespuestaFakeEspacio()
    {
        String sRespuesta = '';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"faqs": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idFaq": "993365923",';
        sRespuesta = sRespuesta + '"texto": "faq de prueba nuevo formato",';
        sRespuesta = sRespuesta + '"textoParaUsuarioEs": null,';
        sRespuesta = sRespuesta + '"textoParaUsuarioCa": null,';
        sRespuesta = sRespuesta + '"link": "",';
        sRespuesta = sRespuesta + '"idEspacio": "9999999915000012",';
        sRespuesta = sRespuesta + '"idTopic": "9999999913830021",';
        sRespuesta = sRespuesta + '"idFaqSiebel": "23432",';
        sRespuesta = sRespuesta + '"intents": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idIntent": 314376008,';
        sRespuesta = sRespuesta + '"intent": "Faq_de_prueba_Espacio_Pruebas_Custom_1_es314376008",';
        sRespuesta = sRespuesta + '"respuestaCortaEs": null,';
        sRespuesta = sRespuesta + '"respuestaCortaCa": null,';
        sRespuesta = sRespuesta + '"descripcion": "Faq de prueba Espacio Pruebas Custom 1 es",';
        sRespuesta = sRespuesta + '"customsIntent": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idGlobal": 22,';
        sRespuesta = sRespuesta + '"idIntent": 0,';
        sRespuesta = sRespuesta + '"respCorta": "intent prueba"';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + ']';
        sRespuesta = sRespuesta + '},';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idIntent": 314376009,';
        sRespuesta = sRespuesta + '"intent": "otro_intent_de_faq_pruebas_custom_1314376009",';
        sRespuesta = sRespuesta + '"respuestaCortaEs": null,';
        sRespuesta = sRespuesta + '"respuestaCortaCa": null,';
        sRespuesta = sRespuesta + '"descripcion": "otro intent de faq pruebas custom 1",';
        sRespuesta = sRespuesta + '"customsIntent": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idGlobal": 22,';
        sRespuesta = sRespuesta + '"idIntent": 0,';
        sRespuesta = sRespuesta + '"respCorta": "<p>rep corta es de otro intent de faq pruebas custom 1</p>"';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + ']';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + '],';
        sRespuesta = sRespuesta + '"customsFaq": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idGlobal": 22,';
        sRespuesta = sRespuesta + '"idFaq": 993365923,';
        sRespuesta = sRespuesta + '"preguntaDesam": null,';
        sRespuesta = sRespuesta + '"textoParaUsuario": "Faq de prueba Espacio Pruebas Custom 1 es",';
        sRespuesta = sRespuesta + '"subtitulo": "Subtitulo prueba Espacio Pruebas Custom 1 es",';
        sRespuesta = sRespuesta + '"urlMedia": "URL media prueba Espacio Pruebas Custom 1 es",';
        sRespuesta = sRespuesta + '"literalAccion": "",';
        sRespuesta = sRespuesta + '"urlAccion": "",';
        sRespuesta = sRespuesta + '"optionTitle": ""';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + ']';
        sRespuesta = sRespuesta + '},';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idFaq": "993365924",';
        sRespuesta = sRespuesta + '"texto": "faq de prueba 2 nuevo formato",';
        sRespuesta = sRespuesta + '"textoParaUsuarioEs": null,';
        sRespuesta = sRespuesta + '"textoParaUsuarioCa": null,';
        sRespuesta = sRespuesta + '"link": "",';
        sRespuesta = sRespuesta + '"idEspacio": "9999999915000012",';
        sRespuesta = sRespuesta + '"idTopic": "9999999913830021",';
        sRespuesta = sRespuesta + '"idFaqSiebel": "23432",';
        sRespuesta = sRespuesta + '"intents": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idIntent": 314376010,';
        sRespuesta = sRespuesta + '"intent": "FAq_de_pruebas_numero_2__de_espacio_pruebas_custom314376010",';
        sRespuesta = sRespuesta + '"respuestaCortaEs": null,';
        sRespuesta = sRespuesta + '"respuestaCortaCa": null,';
        sRespuesta = sRespuesta + '"descripcion": "FAq de pruebas numero 2  de espacio pruebas custom",';
        sRespuesta = sRespuesta + '"customsIntent": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idGlobal": 22,';
        sRespuesta = sRespuesta + '"idIntent": 314376010,';
        sRespuesta = sRespuesta + '"respCorta": "inent prueba wiwieuwiwie"';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + ']';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + '],';
        sRespuesta = sRespuesta + '"customsFaq": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idGlobal": 22,';
        sRespuesta = sRespuesta + '"idFaq": 993365924,';
        sRespuesta = sRespuesta + '"preguntaDesam": null,';
        sRespuesta = sRespuesta + '"textoParaUsuario": "FAq de pruebas numero 2  de espacio pruebas custom es ",';
        sRespuesta = sRespuesta + '"subtitulo": "sub es faq prueba num 2 espacio pruebas custom",';
        sRespuesta = sRespuesta + '"urlMedia": "",';
        sRespuesta = sRespuesta + '"literalAccion": "",';
        sRespuesta = sRespuesta + '"urlAccion": "",';
        sRespuesta = sRespuesta + '"optionTitle": ""';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + ']';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + '],';
        sRespuesta = sRespuesta + '"espacio": {';
        sRespuesta = sRespuesta + '"idEspacio": "9999999915000012",';
        sRespuesta = sRespuesta + '"espacio": "TestOnly",';
        sRespuesta = sRespuesta + '"descripcionEs": "Línea Abierta de LOE",';
        sRespuesta = sRespuesta + '"descripcionCa": "Línia Oberta de LOE"';
        sRespuesta = sRespuesta + '},';
        sRespuesta = sRespuesta + '"topics": [';
        sRespuesta = sRespuesta + '{';
        sRespuesta = sRespuesta + '"idTopic": "9999999913830021",';
        sRespuesta = sRespuesta + '"idEspacio": "9999999915000012",';
        sRespuesta = sRespuesta + '"topic": "testCatAPP",';
        sRespuesta = sRespuesta + '"descripcionEs": "Linea Abierta",';
        sRespuesta = sRespuesta + '"descripcionCa": "Linea Abierta"';
        sRespuesta = sRespuesta + '}';
        sRespuesta = sRespuesta + ']';
        sRespuesta = sRespuesta + '}';

        return sRespuesta;
    }
}