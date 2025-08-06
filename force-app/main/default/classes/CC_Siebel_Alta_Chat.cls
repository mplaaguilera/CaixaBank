public with sharing class CC_Siebel_Alta_Chat {

    @future(callout=true)
    public static void CC_Siebel_Alta_Chat(Set<Id> oID) {

        // Recuperar los datos de la conexión contra Siebel
        CC_InterfaceSettings__mdt altaSiebel = CC_MetodosUtiles.getInterfazConfigBody('AltaSiebel');
        List<CC_TrazaInt__c> oListTraza = new List<CC_TrazaInt__c>();
        String idSR;
        
        if (altaSiebel != null) {
            // Recuperar datos origen.
            List<LiveChatTranscript> oChats = getDatosChat(oID);
            // Listado de chats para hacer el update
            List<LiveChatTranscript> ListChats = new List<LiveChatTranscript>();
            // Recuperar las categorias y aplicaciones entrantes.
            Set<String> oCat = new Set<String>();
            Set<String> oApp = new Set<String>();
            for (LiveChatTranscript oChatUn : oChats)
            {
                if (oChatUn.CC_Categoria__c != '')
                    oCat.add(oChatUn.CC_Categoria__c);
                
                if (oChatUn.CC_Aplicacion__c != '')
                    oApp.add(oChatUn.CC_Aplicacion__c);
            }
            // Recuperar los códigos de espacios y categorías y appSiebel.
            Map<String,String> oMap = getEspacioCategoria (oCat);
            Map<String,String> oMapApp = getAppSiebel (oApp);
            
            String oficina; // \"centro\": \"09945\",

            // Preparar las llamadas a SBL.
            for (LiveChatTranscript oChatUn : oChats)
            {
                // Gestión trazas.
                CC_TrazaInt__c oTraza;
                String sDescError = '';
                String sDetalleError = '';
                String sSalida = ''; 
                
                Id userId = oChatUn.OwnerId;//UserInfo.getUserId();
                String matricula;
                //Recuperamos el U01 del usuario
                if (Test.isRunningTest()){
                    matricula = 'U0137298';
                } else{
                    matricula = getFederationId(userId); // \"user\": \"U0137298\",
                }
                
                //TODO: Gestion campos informados
                if (oChatUn.CC_Id_Cognitive__c != null && oChatUn.CC_Id_Cognitive__c != ''
                    && oChatUn.CC_Espacio__c != null && oChatUn.CC_Espacio__c != ''
                    && oChatUn.CC_Categoria__c != null && oChatUn.CC_Categoria__c != ''
                    && oChatUn.CC_Aplicacion__c != null && oChatUn.CC_Aplicacion__c != ''
                    && matricula != null && matricula != ''
                    && (oChatUn.CC_Tipo__c == 'Agente' || oChatUn.CC_Tipo__c == 'Hidden')
                    && oChatUn.CC_IdiomaCV__c != null && oChatUn.CC_IdiomaCV__c != ''
                    && oChatUn.CC_NumPerso__c != null && oChatUn.CC_NumPerso__c != ''
                    && oMap.get(oChatUn.CC_Espacio__c + oChatUn.CC_Categoria__c) != null
                    && oMapApp.get(oChatUn.CC_Aplicacion__c) != null){
                    
                    if (altaSiebel.CC_TrazaActiva__c || Test.isRunningTest()) {
                        oTraza = new CC_TrazaInt__c();
                        oTraza.Name = 'SIEBEL_ALTA_HTTP';
                        oTraza.CC_Identificador__c = oChatUn.Name;
                        oTraza.CC_FechaInicio__c = datetime.now();
                    }
					String idChatLiveTrans = oChatUn.Id;
                    String AppSiebel = oMapApp.get(oChatUn.CC_Aplicacion__c);
                    // Replace del body por los datos correctos
                    String sBody = altaSiebel.CC_Body__c;
                    String json = oChatUn.CC_Cognitive_chat__c;
                    System.JSONParser parser = System.JSON.createParser(json);
                    while (parser.nextToken() != null){
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'centro')) {
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            oficina = parser.getText();
                        }
                    }
                    sBody = sBody.replace('##idTranscript##', oChatUn.CC_Id_Cognitive__c);
                    sBody = sBody.replace('##producto##', oMap.get(oChatUn.CC_Espacio__c + oChatUn.CC_Categoria__c));
                    sBody = sBody.replace('##matricula##', matricula);
    
                    if (oChatUn.CC_Tipo__c == 'Agente')
                        sBody = sBody.replace('##tipo##','ESPECIALIZADO');
                    else
                        sBody = sBody.replace('##tipo##','HIDDEN');
    
                    sBody = sBody.replace('##oficina##', oficina);
                    sBody = sBody.replace('##idioma##', oChatUn.CC_IdiomaCV__c);
                    sBody = sBody.replace('##canal##', AppSiebel);
                    sBody = sBody.replace('##numPer##', oChatUn.CC_NumPerso__c);
                    try {
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(altaSiebel.CC_EndPoint__c);
                        request.setMethod(altaSiebel.CC_TipoPeticion__c);
                        request.setHeader('Content-Type', altaSiebel.CC_ContentType__c);

                        if (!Test.isRunningTest())
                            request.setClientCertificateName(altaSiebel.CC_Certificado__c);

                        if ((altaSiebel.CC_TrazaActiva__c || Test.isRunningTest()) && altaSiebel.CC_TrazaEntrada__c && oTraza != null)
                            oTraza.CC_MensajeEntrada__c = sBody;

                        // TODO: Replace en el body del JSON
                        request.setBody(sBody);
                        HttpResponse response = http.send(request);
                        // Parse the JSON response
                        if (response.getStatusCode() != 200) {
                            System.debug('The status code returned was not expected: ' +
                                response.getStatusCode() + ' ' + response.getStatus());

                            sDescError = 'Error petición.';
                            sDetalleError = response.getStatus() + ' (' + response.getStatusCode() + ')';
                        } else {
                            sSalida = String.valueOf(response.getBody());
                            System.JSONParser parserSR = System.JSON.createParser(response.getBody());
                            while (parserSR.nextToken() != null){
                                if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'idSR')) {
                                    // Get the value.
                                    parserSR.nextToken();
                                    // Compute the grand total price for all invoices.
                                    idSR = parserSR.getText();
                                    LiveChatTranscript lct = new LiveChatTranscript();
                                    lct.Id = idChatLiveTrans;
                                    lct.CC_SRId__c = idSR;
                                    lct.CC_Actualizar_Siebel__c = true;
                                    ListChats.add(lct);
                                }
                            }
                        }
                    } catch (Exception e){
                        // Error comunicaciones.
                        System.debug(e);
                        sDescError = 'Error comunicaciones.';
                        sDetalleError = e.getMessage();
                    }
                }else{
                    // Registrar traza sin datos de envío.
                    sDescError = 'Datos entrada no informados.';
                    sDetalleError = 'No están informados todos los datos obligatorios. Chat: ' + String.valueOf(oChatUn);
                }
                
                // Finalizar traza.
                if ((altaSiebel.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
                {
                    oTraza.CC_FechaFin__c = datetime.now();
                    
                    if ((altaSiebel.CC_TrazaSalida__c || Test.isRunningTest()) && sSalida != '')
                        oTraza.CC_MensajeSalida__c = sSalida;
                    
                    if (sDescError != '')
                    {
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = sDescError;
                        oTraza.CC_DetalleError__c = sDetalleError;
                    }else{
                        oTraza.CC_FinOK__c = true;
                    }
                    
                    oListTraza.add(oTraza);
                }
                //return response;
            }
            // Insertar las trazas generadas.
            if (oListTraza.size() > 0)
            {
                Database.SaveResult[] oResUp = Database.insert(oListTraza, false);
            }
            //Update de la SR
            Database.SaveResult[] resultsChat = Database.update(ListChats, false);
        }
        //return idSR;
    }

    //Recuperar la matricula del usuario (Federation Id).
    public static String getFederationId (Id userId) {
        User oUser = new User();
        String matricula = '';
        if (userId != null)
        {
            oUser = [SELECT Id, FederationIdentifier, EmployeeNumber FROM User WHERE Id = : userId];
            matricula = oUser.EmployeeNumber;
        }
        return matricula;
    }
    
    //Recuperar datos origen
    public static List<LiveChatTranscript> getDatosChat (Set<Id> oID) {
        List<LiveChatTranscript> oChats = new List<LiveChatTranscript>();
        if (oID.size() > 0) {
            oChats = [SELECT Id, Name, CC_Id_Cognitive__c, CC_SRId__c, CC_Aplicacion__c, CC_Espacio__c, CC_Categoria__c, CC_Tipo__c, CC_UltFaqSiebel__c, OwnerId, UserAgent, CC_IdiomaCV__c, CC_NumPerso__c, CC_Cognitive_chat__c
                FROM LiveChatTranscript  WHERE Id IN :oID
            ];
        }

        return oChats;
    }

    /*
        Recuperar espacio - categoria.
    */
    static private Map<String, String> getEspacioCategoria (Set<String> Categoria)
    {
        Map<String, String> oData = new Map<String, String>();
        Id recordCat = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();

        List<CC_FAQ__c> oListFaq = [SELECT Id, Name, CC_Id_Categoria__c, CC_Lookup_Espacio__c, CC_Lookup_Espacio__r.CC_Id_Espacio__c, CC_Lookup_Espacio__r.Name
        FROM CC_FAQ__c WHERE RecordTypeId =: recordCat AND Name IN :Categoria];
        if (oListFaq.size() > 0)
        {
            for(Integer i = 0, size = oListFaq.size(); i < size; i++) {
                oData.put(oListFaq[i].CC_Lookup_Espacio__r.Name + oListFaq[i].Name, oListFaq[i].CC_Lookup_Espacio__r.CC_Id_Espacio__c + ':' + oListFaq[i].CC_Id_Categoria__c);
            }
        }
        return oData;
    }
    
    /*
        Recuperar aplicación Siebel.
    */
    static private Map<String, String> getAppSiebel (Set<String> Aplicacion)
    {
        Map<String, String> oData = new Map<String, String>();
        Id recordApp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();

        List<CC_FAQ__c> oListFaq = [SELECT Id, Name, CC_Aplicacion_Siebel__c FROM CC_FAQ__c WHERE RecordTypeId =: recordApp AND Name IN: Aplicacion ];
        if (oListFaq.size()>0)
        {
            for(Integer i = 0, size = oListFaq.size(); i < size; i++) {
                oData.put(oListFaq[i].Name, oListFaq[i].CC_Aplicacion_Siebel__c);
            }
        }
        return oData;
    }

    @future(callout=true)
    public static void CC_Siebel_Fin_Chat(Set<Id> oID) {


        // Recuperar la configuración de la interfaz.
        CC_InterfaceSettings__mdt oIntSBL = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_SBLFin');
        List<CC_TrazaInt__c> oListTraza = new List<CC_TrazaInt__c>();

        if (oIntSBL != null) {
            String sCertificado = oIntSBL.CC_Certificado__c;
            String sEndPoint = oIntSBL.CC_EndPoint__c;
            Integer iTimeOut = Integer.valueOf(oIntSBL.CC_TimeOut__c);
            String sTipoPeticion = oIntSBL.CC_TipoPeticion__c;
            String sContent = oIntSBL.CC_ContentType__c;
            String sBody = oIntSBL.CC_Body__c;

            // Recuperar datos origen.
            List<LiveChatTranscript> oChats = getDatosChat(oID);
            if (oChats.size() > 0)
            {
                // Recuperar las categorias entrantes.
                Set<String> oCat = new Set<String>();
                for (LiveChatTranscript oChatUn : oChats)
                {
                    if (oChatUn.CC_Categoria__c != '')
                        oCat.add(oChatUn.CC_Categoria__c);
                }

                // Recuperar los códigos de espacios y categorías.
                Map<String,String> oMap = getEspacioCategoria (oCat);

                // Preparar las llamadas a SBL.
                for (LiveChatTranscript oChatUn : oChats)
                {
                    // Gestión trazas.
                    CC_TrazaInt__c oTraza;
                    String sDescError = '';
                    String sDetalleError = '';
                    String sSalida = '';

                    if (oIntSBL.CC_TrazaActiva__c || Test.isRunningTest())
                    {
                        oTraza = new CC_TrazaInt__c();
                        oTraza.Name = 'SIEBEL_CIERRE_HTTP';
                        oTraza.CC_Identificador__c = oChatUn.Name;
                        oTraza.CC_FechaInicio__c = datetime.now();
                    }

                    if (oChatUn.CC_SRId__c != null && oChatUn.CC_SRId__c != ''
                        && oChatUn.CC_Id_Cognitive__c != null && oChatUn.CC_Id_Cognitive__c != ''
                        && oChatUn.CC_Espacio__c != null && oChatUn.CC_Espacio__c != ''
                        && oChatUn.CC_Categoria__c != null && oChatUn.CC_Categoria__c != ''
                        && (oChatUn.CC_Tipo__c == 'Agente' || oChatUn.CC_Tipo__c == 'Hidden')
                        && oMap.get(oChatUn.CC_Espacio__c + oChatUn.CC_Categoria__c) != null
                    ){
                        sBody = sBody.replace('##idChat##', oChatUn.CC_Id_Cognitive__c);
                        sBody = sBody.replace('##idSR##', oChatUn.CC_SRId__c);
                        sBody = sBody.replace('##producto##', oMap.get(oChatUn.CC_Espacio__c + oChatUn.CC_Categoria__c));

                        if (oChatUn.CC_Tipo__c == 'Agente')
                            sBody = sBody.replace('##tipoChat##','ESPECIALIZADO');
                        else
                            sBody = sBody.replace('##tipoChat##','HIDDEN');

                        String sAux = String.valueOf(oChatUn.CC_UltFaqSiebel__c);
                        if (sAux == '' || sAux == null)
                            sAux = '0';
                        sBody = sBody.replace('##idFaq##', sAux);

                        if ((oIntSBL.CC_TrazaActiva__c || Test.isRunningTest()) && oIntSBL.CC_TrazaEntrada__c && oTraza != null)
                            oTraza.CC_MensajeEntrada__c = sBody;


                        try {
                            Http http = new Http();
                            HttpRequest request = new HttpRequest();

                            if (!Test.isRunningTest())
                                request.setClientCertificateName(sCertificado); 

                            request.setEndpoint(sEndPoint);
                            request.setMethod(sTipoPeticion);
                            request.setHeader('Content-Type', sContent);
                            request.setBody(sBody);
                            request.setTimeout(iTimeOut);
                            HttpResponse response = http.send(request);

                            if (response.getStatusCode() != 200) {
                                sDescError = 'Error petición.';
                                sDetalleError = response.getStatus() + ' (' + response.getStatusCode() + ')';
                            }else{
                                sSalida = String.valueOf(response.getBody());

                                // Tratar respuesta SBL.
                                String sResultado = 'KO';
                                JSONParser oParText = JSON.createParser(response.getBody());            
                                while(oParText.nextToken() != JSONToken.END_OBJECT) 
                                {
                                    if(oParText.getCurrentToken() == JSONToken.FIELD_NAME) 
                                    {
                                        // Obtener el texto del campo.
                                        String sAttrcab = oParText.getText();
                        
                                        // Pasar al siguiente elemento.
                                        oParText.nextToken();                
                        
                                        // Inicio del mapeo de campos.
                                        if (sAttrcab == 'resultado')
                                        {
                                            sResultado = oParText.getText();
                                        }

                                        if (sAttrcab == 'codError')
                                        {
                                            sDescError = oParText.getText();
                                        }

                                        if (sAttrcab == 'mensaje')
                                        {
                                            sDetalleError = oParText.getText();
                                        }
                                    }
                                }


                                if (sResultado == 'OK')
                                {
                                    // Tratamiento correcto. Reseteamos cualquier posible mensaje.
                                    sDescError = '';
                                    sDetalleError = '';
                                }else{
                                    // Tratamiento incorrecto.
                                    sDetalleError = sDetalleError + '(' + sDescError + ')';
                                    sDescError = 'Error cierre SR.';                                
                                }

                            }

                        } catch (Exception e) {
                            // Error comunicaciones.
                            System.debug(e);
                            sDescError = 'Error comunicaciones.';
                            sDetalleError = e.getMessage();
                        }
                    }else{
                        // Registrar traza sin datos de envío.
                        sDescError = 'Datos entrada no informados.';
                        sDetalleError = 'No están informados todos los datos obligatorios. Chat: ' + String.valueOf(oChatUn);
                    }

                    // Finalizar traza.
                    if ((oIntSBL.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
                    {
                        oTraza.CC_FechaFin__c = datetime.now();

                        if ((oIntSBL.CC_TrazaSalida__c || Test.isRunningTest()) && sSalida != '')
                            oTraza.CC_MensajeSalida__c = sSalida;

                        if (sDescError != '')
                        {
                            oTraza.CC_FinOK__c = false;
                            oTraza.CC_TipoError__c = sDescError;
                            oTraza.CC_DetalleError__c = sDetalleError;
                        }else{
                            oTraza.CC_FinOK__c = true;
                        }

                        oListTraza.add(oTraza);
                    }
                }

                // Insertar las trazas generadas.
                if (oListTraza.size() > 0)
                {
                    Database.SaveResult[] oResUp = Database.insert(oListTraza, false);
                }
            }
        }
    }
    
    @InvocableMethod(label='Siebel LiveChatTranscript' description='Envio Siebel')
	public static void envioAltaChatSiebel(List<ID> listNewObj) {
        
        Set<ID> oID = new Set<ID>(listNewObj);

        // Si existen elementos nuevos enrutados, gestión llamada Alfabético.
        // Lanzamos un máximo de 50 callouts (límite Hard), con las llamadas repartidas.
        if (oID.size() > 0)
        {
            List<ID> oIDList = new List<ID>(oID);
            Integer j = 1;
            Map<Integer,Set<ID>> oMap = new Map<Integer,Set<ID>>();
            for (Integer i=0;i<oIDList.size();i++)
            {
                if (j > 50)
                    j = 1;

                // Inicializar listas.
                if (oMap.get(j) == null)
                {
                    Set<ID> oSet = new Set<ID>();
                    oMap.put(j,oSet);
                }

                // Añadir valor.
                oMap.get(j).add(oIDList[i]);

                j = j + 1;
            }

            // Lanzar llamadas Futuras.
            
            for (Integer i : oMap.keySet())
            {
                CC_Siebel_Alta_Chat.CC_Siebel_Alta_Chat(oMap.get(i));
            }

            oIDList.clear();
            oIDList = null;

            oMap.clear();
            oMap = null;
        }

        oID.clear();
        oID = null;
	}
}