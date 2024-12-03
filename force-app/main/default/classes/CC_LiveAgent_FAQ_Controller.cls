public class CC_LiveAgent_FAQ_Controller { 

    public class FaqIntentListWrapper {
        @AuraEnabled public CC_FAQ__c faqRecord{get;set;}
        @AuraEnabled public List<CC_Intent__c> intentList{get;set;}
        @AuraEnabled public Integer intentCount{get;set;}
        @AuraEnabled public Boolean propuesta{get;set;}
        @AuraEnabled public List<Object> intentOptions {get;set;}
        @AuraEnabled public String sOfrecidaWatson {get;set;}
        @AuraEnabled public Boolean bContieneURL {get; set;}
        @AuraEnabled public Boolean bMostrarURL {get; set;}
    }

    @AuraEnabled
    public static Map<String,Object> getLiveChatTranscript(String chatId) {
        
        Map<String,Object> oRes = new Map<String,Object>();
        List<FaqIntentListWrapper> faqListWrapperSearch = new List<FaqIntentListWrapper>();

        List<LiveChatTranscript> oChat = [SELECT CaseId, CC_IdiomaCV__c, CC_Aplicacion__c, CC_Espacio__c, CC_Categoria__c, CC_IdsGlobales__c,CC_Tipo__c, 
                                          RecordTypeId,CC_FaqsOfrecidas__c
                                          //CC_Cognitive_chat__c, CC_FaqsOfrecidas__c
                                        FROM LiveChatTranscript WHERE Id = :chatId LIMIT 1];
        if (!oChat.isEmpty())
        {
			// Gestión FAQs Cognitivo.
            /*CC_Cognitive_Chat_JSON chatCognitivo = CC_Cognitive_Chat_JSON.parse(oChat[0].CC_Cognitive_chat__c);
            if (chatCognitivo != null)
            {
                List<CC_Cognitive_Chat_JSON.Results> faqs = chatCognitivo.getChatbotFaqs(); 
                List<String> respuesta = new List<String>();
                
                for (CC_Cognitive_Chat_JSON.Results listfaqs: faqs) {
                    respuesta.add(listfaqs.id);
                }
                
                // Modo test.
                //respuesta.add('Cuales_son_las_modalidades_de_pago_de_la_Declaracion_de_la_Renta_con_tarjeta');
                //respuesta.add('Cuales_son_las_modalidades_de_pago_de_la_Declaracion_de_la_Renta_con_tarjeta');
                
                List<CC_Intent__c> intentListId = new List<CC_Intent__c>();        
                intentListId = [SELECT CC_FAQ_Id__c, CC_FAQ_Id__r.CC_FAQ_Ident__c 
                                FROM CC_Intent__c WHERE CC_Nombre__c in :respuesta AND RecordType.DeveloperName = 'CC_Intent'];
                
                List <String> ids = new List<String>();
                for(CC_Intent__c listIntents: intentListId)
                {
                    ids.add(listIntents.CC_FAQ_Id__c);
                }*/
            
            	List<String> ids = new List<String>();
            	if (String.isNotBlank(oChat[0].CC_FaqsOfrecidas__c))
                {
                    ids = oChat[0].CC_FaqsOfrecidas__c.split(',');
                }
                
            	if (!ids.isEmpty())
                {
                    // Recuperar el idioma por defecto.
                    String idGlobalFaq = '';
                    List<CC_FAQ__c> oListEspacios = [SELECT Id, CC_Obsoleto__c,
                                                     CC_Lookup_App__r.CC_IdiomaESDefault__c,
                                                     CC_Lookup_App__r.CC_IdiomaCADefault__c,
                                                     CC_Lookup_App__r.CC_IdiomaENDefault__c
                                                     FROM CC_FAQ__c 
                                                     WHERE Name = :oChat[0].CC_Espacio__c AND RecordType.DeveloperName = 'CC_Espacios' AND CC_Obsoleto__c = false LIMIT 1];
                    if (!oListEspacios.isEmpty())
                    {
                        if (oChat[0].CC_IdiomaCV__c == 'es')
                        {
                            idGlobalFaq = oListEspacios[0].CC_Lookup_App__r.CC_IdiomaESDefault__c;
                        }else if (oChat[0].CC_IdiomaCV__c == 'ca') {
                            idGlobalFaq = oListEspacios[0].CC_Lookup_App__r.CC_IdiomaCADefault__c;
                        }else if (oChat[0].CC_IdiomaCV__c == 'en') {
                            idGlobalFaq = oListEspacios[0].CC_Lookup_App__r.CC_IdiomaENDefault__c;
                        }else{
                            idGlobalFaq = oListEspacios[0].CC_Lookup_App__r.CC_IdiomaESDefault__c;
                        }
                    }
                    
                    List<CC_FAQ__c> oListFaqWatson = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c, CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                                      CC_URL__c
                                                      FROM CC_FAQ__c
                                                      WHERE RecordType.DeveloperName = 'CC_FAQ_Custom' 
                                                      AND CC_GlobalId__c = :idGlobalFaq
                                                      AND CC_Lookup_FAQ__r.Id in :ids];
                    
                    // Recorrer las FAQs ofrecidas por Watson.
                    for (CC_FAQ__c oFAQ : oListFaqWatson)
                    {
                        if (oFAQ.CC_TextoMostrar__c != null)
                        {
                            FaqIntentListWrapper faqWrapper = new FaqIntentListWrapper();
                            faqWrapper.propuesta = true;
                            faqWrapper.sOfrecidaWatson = 'Y';
                            faqWrapper.faqRecord = oFAQ;
                            faqWrapper.bMostrarURL = false;         
                            faqWrapper.bContieneURL = String.isBlank(oFAQ.CC_URL__c) ? false : true;                         
                            faqListWrapperSearch.add(faqWrapper);
                        }
                    }
                }
            //}
            
            List<String> oIdsChat = new List<String>();
            String sIdsGlobales = oChat[0].CC_IdsGlobales__c;
            if (sIdsGlobales != null && sIdsGlobales != '')
            {
                oIdsChat = sIdsGlobales.split(',');
            }

            // Recuperar el área del chat.
            String sAreaChat = 'Cliente';
            if (!oChat.isEmpty())
            {
                String sChatEmpRT = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();
                if (oChat[0].RecordTypeId == sChatEmpRT)
                {
                    // Chat empleados.
                    sAreaChat = 'Empleado';
                }
            }

            oRes.put('DatosChat', oChat);
            oRes.put('IdsGlobales', oIdsChat);
            oRes.put('AreaChat', sAreaChat);
            oRes.put('FaqsCognitivo',faqListWrapperSearch);
        }
        
        //Se devuelven diferentes campos del chat 
        return oRes; 
    }   

    @AuraEnabled
    public static List<FaqIntentListWrapper> getFAQsWrapper(String recordId, String espacio, String categoria, String searchKey, String idioma, Integer limite, List<String> oGlobalId) {
        if (oGlobalId  == null || oGlobalId.isEmpty()){           
            return null;
        }
        
        List<FaqIntentListWrapper> faqListWrapperSearch = new List<FaqIntentListWrapper>();        
        if (searchKey != null) {			         
            searchKey = searchKey.toLowerCase();            
        }

	    //JSON cognitivo
        if (recordId != null && recordId != '') {          

            // Recuperar la versión activa del espacio.
            Id recordTypeIdEspacio = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
            
            Integer iVersionActiva = 0;
            Integer iVersionActEnCurso = 0;
            List<CC_FAQ__c> oListEspacios = [SELECT Id, CC_Version__c, CC_VersionActualizando__c, CC_Obsoleto__c FROM CC_FAQ__c WHERE Name = :espacio AND RecordTypeId = :recordTypeIdEspacio LIMIT 1];
            
            
            for (CC_FAQ__c oEspacio : oListEspacios){
                if (!oEspacio.CC_Obsoleto__c){
                    if (oEspacio.CC_Version__c != null){
                        iVersionActiva = Integer.valueOf(oEspacio.CC_Version__c);
                    }

                    if (oEspacio.CC_VersionActualizando__c != null){
                        iVersionActEnCurso = Integer.valueOf(oEspacio.CC_VersionActualizando__c);
                    }else{
                        iVersionActEnCurso = iVersionActiva;
                    }
                }else{
                    iVersionActiva = -1;
                    iVersionActEnCurso = -1;
                }
            }
            

            //Se recupera el mensaje de cognitivo para recordId indicado
            String jsonInput = [SELECT CC_Cognitive_chat__c FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].CC_Cognitive_chat__c;
            CC_Cognitive_Chat_JSON chat = CC_Cognitive_Chat_JSON.parse(jsonInput);
            if (chat == null){
             return null; //Si no se ha podido parsear el JSON no se retornan FAQs   
            } 

            List<CC_Cognitive_Chat_JSON.Results> faqs = chat.getChatbotFaqs();
            //List<CC_Cognitive_Chat_JSON.Results> faqs = new List<CC_Cognitive_Chat_JSON.Results>();
            List<String> respuesta = new List<String>();

            for (CC_Cognitive_Chat_JSON.Results listfaqs: faqs) {
                respuesta.add(listfaqs.id);
            }
            
            Id sIntentRTId = Schema.getGlobalDescribe().get('CC_Intent__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Intent').getRecordTypeId();
            
            List<CC_Intent__c> intentListId = new List<CC_Intent__c>();
            intentListId = [SELECT CC_FAQ_Id__c, CC_FAQ_Id__r.CC_FAQ_Ident__c FROM CC_Intent__c WHERE CC_Nombre__c in :respuesta AND RecordTypeId = :sIntentRTId];
            List <String> ids = new List<String>();
            for(CC_Intent__c listIntents: intentListId)
            {
                ids.add(listIntents.CC_FAQ_Id__c);
            }

            // ids -> Contiene la lista de FAQs ofrecidas por Watson.

            Id sCustFAQRTId = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_FAQ_Custom').getRecordTypeId();
            Id sCustIntRTId = Schema.getGlobalDescribe().get('CC_Intent__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Intent_Custom').getRecordTypeId();
            
            List<ID> oListFAQMostrar = new List<ID>();

            // Separamos las búsquedas en FAQs ofrecidas por Watson y las no ofrecidas.

            // FAQS WATSON. Recuperar las ofrecidas por Watson.
            
            for (String sClaveGlobalId : oGlobalId){
                List<CC_FAQ__c> oListFaqWatson = new List<CC_FAQ__c>();

                if (limite > 1){
                    if (String.isBlank(categoria) || categoria == '--Selecciona una categoría--'){
						oListFaqWatson = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c, CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                            CC_URL__c,
                                        (
                                                SELECT Id, CC_Nombre__c, CC_Respuesta_CAT__c, CC_Respuesta_ESP__c, CC_TextoMostrar__c 
                                                FROM Intents__r
                                                WHERE RecordTypeId = :sCustIntRTId
                                        ) 
                                        FROM CC_FAQ__c
                                        WHERE CC_Espacio__c = :espacio //AND CC_Categoria__c = :categoria 
                                          AND RecordType.Id = :sCustFAQRTId 
                                        AND CC_Lookup_FAQ__r.Id in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                        AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                        AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                        ORDER BY LastModifiedDate LIMIT :limite];
                 
                    }else{
                        oListFaqWatson = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c, CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                            CC_URL__c,
                                        (
                                                SELECT Id, CC_Nombre__c, CC_Respuesta_CAT__c, CC_Respuesta_ESP__c, CC_TextoMostrar__c 
                                                FROM Intents__r
                                                WHERE RecordTypeId = :sCustIntRTId
                                        ) 
                                        FROM CC_FAQ__c
                                        WHERE CC_Espacio__c = :espacio AND CC_Categoria__c = :categoria 
                                          AND RecordType.Id = :sCustFAQRTId 
                                        AND CC_Lookup_FAQ__r.Id in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                        AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                        AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                        ORDER BY LastModifiedDate LIMIT :limite];
                        
                    }
                }else{
                    if (String.isBlank(categoria) || categoria == '--Selecciona una categoría--'){
                        oListFaqWatson = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c, CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                            CC_URL__c,
                                        (
                                                SELECT Id, CC_Nombre__c, CC_Respuesta_CAT__c, CC_Respuesta_ESP__c, CC_TextoMostrar__c 
                                                FROM Intents__r
                                        ) 
                                        FROM CC_FAQ__c
                                        WHERE CC_Espacio__c = :espacio //AND CC_Categoria__c = :categoria
                                          AND RecordType.Id = :sCustFAQRTId 
                                        AND CC_Lookup_FAQ__r.Id in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                        AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                        AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                        ORDER BY LastModifiedDate];
                    }else{
                        
                    	oListFaqWatson = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c, CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                        CC_URL__c,
                                    (
                                            SELECT Id, CC_Nombre__c, CC_Respuesta_CAT__c, CC_Respuesta_ESP__c, CC_TextoMostrar__c 
                                            FROM Intents__r
                                    ) 
                                    FROM CC_FAQ__c
                                    WHERE CC_Espacio__c = :espacio AND CC_Categoria__c = :categoria
                                      AND RecordType.Id = :sCustFAQRTId 
                                    AND CC_Lookup_FAQ__r.Id in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                    AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                    AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                    ORDER BY LastModifiedDate];
                    }
                }


                // Recorrer las FAQs ofrecidas por Watson.
                // Se aplicará filtro de texto, si el usuario ha escrito algún texto.
                for (CC_FAQ__c oFAQ : oListFaqWatson){
                    if (oFAQ.CC_TextoMostrar__c != null){
                        FaqIntentListWrapper faqWrapper = new FaqIntentListWrapper();
                        faqWrapper.propuesta = true;
                        faqWrapper.sOfrecidaWatson = 'Y';
                        faqWrapper.faqRecord = oFAQ;
                        //faqWrapper.intentList = oFAQ.Intents__r;
                        faqWrapper.intentCount = oFAQ.Intents__r.size();
                        faqWrapper.bMostrarURL = false;

                        if (String.isBlank(oFAQ.CC_URL__c)){
                            faqWrapper.bContieneURL = false;
                        }else{
                            faqWrapper.bContieneURL = true;
                        }

                        List<Object> oListaIntent = new List<Object>();
                        for (CC_Intent__c oIntent : oFAQ.Intents__r){
                            Map<String,String> oOpcionIntent = new Map<String,String>();
                            oOpcionIntent.put('label', oIntent.CC_TextoMostrar__c);
                            oOpcionIntent.put('value', oIntent.Id);
                            oOpcionIntent.put('name', oIntent.CC_Nombre__c);
                            oListaIntent.add(oOpcionIntent);
                        }
                        faqWrapper.intentOptions = oListaIntent;

                        if (searchKey != null){
                            if (oFAQ.CC_TextoMostrar__c.toLowerCase().contains(searchKey)){
                                // Incorporar FAQ a mostrar.
                                oListFAQMostrar.add(oFAQ.CC_Lookup_FAQ__r.Id);
                                faqListWrapperSearch.add(faqWrapper);
                            }
                        }else{
                            // Incorporar FAQ a mostrar.
                            oListFAQMostrar.add(oFAQ.CC_Lookup_FAQ__r.Id);
                            faqListWrapperSearch.add(faqWrapper);
                        }
                    }
                }
            }
            for (String sClaveGlobalId : oGlobalId){
                List<CC_FAQ__c> oListFaqResto = new List<CC_FAQ__c>();

                if (limite > 1){
                    if (String.isBlank(categoria) || categoria == '--Selecciona una categoría--'){
                        
                    	oListFaqResto = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c,CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                        CC_URL__c,
                                    (
                                            SELECT Id, CC_Nombre__c, CC_Respuesta_CAT__c, CC_Respuesta_ESP__c, CC_TextoMostrar__c 
                                            FROM Intents__r
                                            WHERE RecordTypeId = :sCustIntRTId
                                    ) 
                                    FROM CC_FAQ__c
                                    WHERE CC_Espacio__c = :espacio //AND CC_Categoria__c = :categoria 
                                     AND
                                      RecordType.Id = :sCustFAQRTId 
                                    AND CC_Lookup_FAQ__r.Id not in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                    AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                    AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                    ORDER BY LastModifiedDate LIMIT :limite];
                    }else{
                    	oListFaqResto = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c,CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                        CC_URL__c,
                                    (
                                            SELECT Id, CC_Nombre__c, CC_Respuesta_CAT__c, CC_Respuesta_ESP__c, CC_TextoMostrar__c 
                                            FROM Intents__r
                                            WHERE RecordTypeId = :sCustIntRTId
                                    ) 
                                    FROM CC_FAQ__c
                                    WHERE CC_Espacio__c = :espacio AND CC_Categoria__c = :categoria 
                                     AND
                                      RecordType.Id = :sCustFAQRTId 
                                    AND CC_Lookup_FAQ__r.Id not in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                    AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                    AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                    ORDER BY LastModifiedDate LIMIT :limite];
                    }
                }else{
					if (String.isBlank(categoria) || categoria == '--Selecciona una categoría--')
                    {
                    	oListFaqResto = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c,CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                        CC_URL__c,
                                    (
                                            SELECT Id, CC_Nombre__c, CC_Respuesta_CAT__c, CC_Respuesta_ESP__c, CC_TextoMostrar__c 
                                            FROM Intents__r
                                    ) 
                                    FROM CC_FAQ__c
                                    WHERE CC_Espacio__c = :espacio //AND CC_Categoria__c = :categoria  
                                     AND
                                      RecordType.Id = :sCustFAQRTId 
                                    AND CC_Lookup_FAQ__r.Id not in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                    AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                    AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                    ORDER BY LastModifiedDate];
                    }else{
                    	oListFaqResto = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c,CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                        CC_URL__c,
                                    (
                                            SELECT Id, CC_Nombre__c, CC_Respuesta_CAT__c, CC_Respuesta_ESP__c, CC_TextoMostrar__c 
                                            FROM Intents__r
                                    ) 
                                    FROM CC_FAQ__c
                                    WHERE CC_Espacio__c = :espacio AND CC_Categoria__c = :categoria  
                                     AND
                                      RecordType.Id = :sCustFAQRTId 
                                    AND CC_Lookup_FAQ__r.Id not in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                    AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                    AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                    ORDER BY LastModifiedDate];
                    }
                }

                // Recorrer las FAQs NO ofrecidas por Watson.
                // Se aplicará filtro de texto, si el usuario ha escrito algún texto.
				
                for (CC_FAQ__c oFAQ : oListFaqResto){
                    if (oFAQ.CC_TextoMostrar__c != null){
                        FaqIntentListWrapper faqWrapper = new FaqIntentListWrapper();
                        faqWrapper.propuesta = false;
                        faqWrapper.sOfrecidaWatson = 'N';
                        faqWrapper.faqRecord = oFAQ;
                        //faqWrapper.intentList = oFAQ.Intents__r;
                        //faqWrapper.intentCount = oFAQ.Intents__r.size();

                        faqWrapper.bMostrarURL = false;

                        if (String.isBlank(oFAQ.CC_URL__c)){
                            faqWrapper.bContieneURL = false;
                        }else{
                            faqWrapper.bContieneURL = true;
                        }

                        List<Object> oListaIntent = new List<Object>();
                        for (CC_Intent__c oIntent : oFAQ.Intents__r){
                            Map<String,String> oOpcionIntent = new Map<String,String>();
                            oOpcionIntent.put('label', oIntent.CC_TextoMostrar__c);
                            oOpcionIntent.put('value', oIntent.Id);
                            oOpcionIntent.put('name', oIntent.CC_Nombre__c);
                            oListaIntent.add(oOpcionIntent);
                        }
                        faqWrapper.intentOptions = oListaIntent;

                        if (searchKey != null){
                            if (oFAQ.CC_TextoMostrar__c.toLowerCase().contains(searchKey)){
                                // Incorporar FAQ a mostrar.
                                oListFAQMostrar.add(oFAQ.CC_Lookup_FAQ__r.Id);
                                faqListWrapperSearch.add(faqWrapper);
                            }
                        }else{
                            // Incorporar FAQ a mostrar.
                            oListFAQMostrar.add(oFAQ.CC_Lookup_FAQ__r.Id);
                            faqListWrapperSearch.add(faqWrapper);
                        }
                    }
                }
                
                
                
            }
            return faqListWrapperSearch;
        } else {
            return null;
        }
    }
    
    //public static Map<String,List<FaqIntentListWrapper>> getFAQsWrapper_Cache(String espacio)
    @AuraEnabled(cacheable=true)
    public static List<FaqIntentListWrapper> getFAQsWrapper_Cache(String espacio, String idioma, String aplicacion)
    {
        if (!String.isBlank(espacio))
        {
            //Map<String,List<FaqIntentListWrapper>> resultadoFAQs = new Map<String,List<FaqIntentListWrapper>>();
            List<FaqIntentListWrapper> resultadoFAQs = new List<FaqIntentListWrapper>();
            List<String> oGlobalId = new List<String>();
                        
            // Recuperar la versión activa del espacio.
            Id recordTypeIdEspacio = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
            Integer iVersionActiva = 0;
            Integer iVersionActEnCurso = 0;
            List<CC_FAQ__c> oListEspacios = [SELECT Id, CC_Lookup_App__r.Name, CC_Version__c, CC_VersionActualizando__c, CC_Obsoleto__c, CC_ListaIDsGlobales__c,
                                             CC_Lookup_App__r.CC_IdiomaESDefault__c,
                                             CC_Lookup_App__r.CC_IdiomaCADefault__c,
                                             CC_Lookup_App__r.CC_IdiomaENDefault__c
                                             FROM CC_FAQ__c 
                                             WHERE Name = :espacio AND RecordTypeId = :recordTypeIdEspacio AND CC_Lookup_App__r.Name = :aplicacion LIMIT 1];
            
            for (CC_FAQ__c oEspacio : oListEspacios)
            {
                if (!oEspacio.CC_Obsoleto__c)
                {
                    if (oEspacio.CC_Version__c != null)
                    {
                        iVersionActiva = Integer.valueOf(oEspacio.CC_Version__c);
                    }

                    if (oEspacio.CC_VersionActualizando__c != null)
                    {
                        iVersionActEnCurso = Integer.valueOf(oEspacio.CC_VersionActualizando__c);
                    }else{
                        iVersionActEnCurso = iVersionActiva;
                    }
                    
                    String sIdsGlobalesFAQs = '';
                    if (idioma == 'es')
                    {
                        sIdsGlobalesFAQs = oEspacio.CC_Lookup_App__r.CC_IdiomaESDefault__c;
                    }else if (idioma == 'ca') {
                        sIdsGlobalesFAQs = oEspacio.CC_Lookup_App__r.CC_IdiomaCADefault__c;                                
                    }else if (idioma == 'en') {
                        sIdsGlobalesFAQs = oEspacio.CC_Lookup_App__r.CC_IdiomaENDefault__c;
                    }else{
                        sIdsGlobalesFAQs = oEspacio.CC_ListaIDsGlobales__c;
                    }
                    
                    if (String.isNotBlank(sIdsGlobalesFAQs))
                    {
                        oGlobalId = sIdsGlobalesFAQs.split(',');
                    }
                    
                }else{
                    iVersionActiva = -1;
                    iVersionActEnCurso = -1;
                }
            }

            Id sCustFAQRTId = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_FAQ_Custom').getRecordTypeId();
            Id sCustIntRTId = Schema.getGlobalDescribe().get('CC_Intent__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Intent_Custom').getRecordTypeId();
            
            
            List<ID> oListFAQMostrar = new List<ID>();

            for (String sClaveGlobalId : oGlobalId)
            {
                List<CC_FAQ__c> oListFaqResto = new List<CC_FAQ__c>();
                List<FaqIntentListWrapper> faqListWrapperSearch = new List<FaqIntentListWrapper>();

                /*if (limite > 1)
                {
                    oListFaqResto = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c,CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                     CC_URL__c
                                     FROM CC_FAQ__c
                                     WHERE CC_Espacio__c = :espacio //AND CC_Categoria__c = :categoria 
                                     AND RecordType.Id = :sCustFAQRTId 
                                     AND CC_Lookup_FAQ__r.Id not in :ids AND CC_GlobalId__c = :sClaveGlobalId
                                     AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                     AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                     ORDER BY LastModifiedDate LIMIT :limite];
                }else{*/
                    oListFaqResto = [SELECT Id, Name, CC_TextoMostrar__c, CC_Espacio__c,CC_Categoria__c, CC_Lookup_FAQ__r.Id,
                                     CC_URL__c
                                     FROM CC_FAQ__c
                                     WHERE CC_Espacio__c = :espacio //AND CC_Categoria__c = :categoria  
                                     AND RecordType.Id = :sCustFAQRTId 
                                     AND CC_GlobalId__c = :sClaveGlobalId
                                     AND CC_Lookup_FAQ__c not in :oListFAQMostrar 
                                     AND (CC_Version__c = :iVersionActiva OR CC_Version__c = :iVersionActEnCurso)
                                     ORDER BY LastModifiedDate];
                //}

                // Recorrer las FAQs NO ofrecidas por Watson.
                // Se aplicará filtro de texto, si el usuario ha escrito algún texto.
				
                for (CC_FAQ__c oFAQ : oListFaqResto)
                {
                    if (oFAQ.CC_TextoMostrar__c != null)
                    {
                        FaqIntentListWrapper faqWrapper = new FaqIntentListWrapper();
                        faqWrapper.propuesta = false;
                        faqWrapper.sOfrecidaWatson = 'N';
                        faqWrapper.faqRecord = oFAQ;
                        //faqWrapper.intentCount = oFAQ.Intents__r.size();

                        faqWrapper.bMostrarURL = false;

                        if (String.isBlank(oFAQ.CC_URL__c))
                        {
                            faqWrapper.bContieneURL = false;
                        }else{
                            faqWrapper.bContieneURL = true;
                        }
                        
                        faqListWrapperSearch.add(faqWrapper);

                        /*List<Object> oListaIntent = new List<Object>();
                        for (CC_Intent__c oIntent : oFAQ.Intents__r)
                        {
                            Map<String,String> oOpcionIntent = new Map<String,String>();
                            oOpcionIntent.put('label', oIntent.CC_TextoMostrar__c);
                            oOpcionIntent.put('value', oIntent.Id);
                            oOpcionIntent.put('name', oIntent.CC_Nombre__c);
                            oListaIntent.add(oOpcionIntent);
                        }
                        faqWrapper.intentOptions = oListaIntent;*/

                        /*if (searchKey != null)
                        {
                            if (oFAQ.CC_TextoMostrar__c.toLowerCase().contains(searchKey))
                            {
                                // Incorporar FAQ a mostrar.
                                oListFAQMostrar.add(oFAQ.CC_Lookup_FAQ__r.Id);
                                faqListWrapperSearch.add(faqWrapper);
                            }
                        }else{
                            // Incorporar FAQ a mostrar.
                            oListFAQMostrar.add(oFAQ.CC_Lookup_FAQ__r.Id);
                            faqListWrapperSearch.add(faqWrapper);
                        }*/
                    }
                }
                
                //resultadoFAQs.put(sClaveGlobalId,faqListWrapperSearch);
                resultadoFAQs.addall(faqListWrapperSearch);
            }
            return resultadoFAQs;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static List<CC_Intent__c> getFaqWithIntentsByFAQ(String oFaqCustId, List<String> oGlobalId)
    {
        if (oGlobalId  == null)
        {
            return null;
        }else{
            if (oGlobalId.isEmpty())
            {
                return null;
            }
        }

        // Buscar la FAQ padre de la custom.
        List<CC_FAQ__c> oFAQPadre = [SELECT Id, CC_Lookup_FAQ__c, CC_TextoMostrar__c, CC_Version__c, CC_URL__c
                                    FROM CC_FAQ__c WHERE Id = :oFaqCustId LIMIT 1];
        if (oFAQPadre.isEmpty())
        {
            return null;
        }

        List<CC_Intent__c> oIntentRes = new List<CC_Intent__c>();
        Id sCustIntRTId = Schema.getGlobalDescribe().get('CC_Intent__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Intent_Custom').getRecordTypeId();

        // Buscamos el Intent asociado a la FAQ.
        for (String sClaveGlobalId : oGlobalId)
        {
            List<CC_Intent__c> oSearchIntent = [SELECT Id, CC_TextoMostrar__c, CC_Nombre__c, CC_FAQ_Id__c, CC_FAQ_Id__r.CC_TextoMostrar__c,
                            CC_FAQ_Id__r.CC_URL__c
                            FROM CC_Intent__c
                            WHERE CC_FAQ_Id__c = :oFAQPadre[0].CC_Lookup_FAQ__c AND RecordTypeId = :sCustIntRTId
                            AND CC_GlobalId__c = :sClaveGlobalId AND CC_Version__c = :oFAQPadre[0].CC_Version__c];

            if (!oSearchIntent.isEmpty())
            {
                // Nos quedamos con el primer Intent encontrado del GlobalId.

                for (CC_Intent__c oCustInt : oSearchIntent)
                {
                    // Asignamos el texto a mostrar de la pregunta (FAQ Custom).
                    String sTextoIntent = oCustInt.CC_TextoMostrar__c;
                    if (String.isBlank(sTextoIntent))
                    {
                        sTextoIntent = oCustInt.CC_Nombre__c;
                    }
                    
                    if (!String.isBlank(sTextoIntent))
                    {
                        oCustInt.CC_TextoMostrar__c = sTextoIntent;
                        oCustInt.CC_FAQ_Id__r.CC_TextoMostrar__c = oFAQPadre[0].CC_TextoMostrar__c;
                        if (!String.isBlank(oFAQPadre[0].CC_URL__c))
                        {
                            oCustInt.CC_FAQ_Id__r.CC_URL__c = oFAQPadre[0].CC_URL__c;
                        }else{
                            oCustInt.CC_FAQ_Id__r.CC_URL__c = '';
                        }
                        oIntentRes.add(oCustInt);
                    }
                }

                break;
            }
        }

        return oIntentRes;
    }  

    @AuraEnabled(cacheable=true)
    public static List<CC_FAQ__c> getMensaje(String sCodigoMsj, String sIdioma, List<String> oGlobalIds, String sOrigen, String sAreaChat) {

        Boolean bEncontrado = false;

        if (sCodigoMsj == null || sCodigoMsj == '')
        {
            return null;
        }

        if (sIdioma == null || sIdioma == '')
        {
            if (oGlobalIds == null || oGlobalIds.isEmpty()){
                return null;
            }
        }

        // Buscar el mensaje por los Global Id
        List<CC_FAQ__c> oMensajes = new List<CC_FAQ__c>();
        Id sMsjRTId = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Mensaje_Automatico_Chat').getRecordTypeId();
        
        if (oGlobalIds != null)
        {
            // NOTA: bucle con FOR, mantener orden de la lista (no vienen más de 5 Ids).
            for (String sClaveGlobalId : oGlobalIds)
            {
                if (sOrigen != null && sOrigen != '')
                {
                    oMensajes = [SELECT Id, Name, CC_Codigo_Cognitive__c, CC_Mensaje_Agente_es__c, CC_Respuesta_Mensaje_Automatico_es__c
                                        FROM CC_FAQ__c
                                        WHERE RecordTypeId = :sMsjRTId AND CC_Procedencia_Mensaje_Automatico__c = :sCodigoMsj AND
                                        CC_GlobalId__c = :sClaveGlobalId AND CC_Origen__c includes(:sOrigen) AND
                                        CC_AreaMensaje__c = :sAreaChat AND CC_Activo__c = true Order by CreatedDate DESC];
                }
                
                if (oMensajes.isEmpty()){
                    oMensajes = [SELECT Id, Name, CC_Codigo_Cognitive__c, CC_Mensaje_Agente_es__c, CC_Respuesta_Mensaje_Automatico_es__c
                                        FROM CC_FAQ__c
                                        WHERE RecordTypeId = :sMsjRTId AND CC_Procedencia_Mensaje_Automatico__c = :sCodigoMsj AND
                                        CC_GlobalId__c = :sClaveGlobalId AND CC_AreaMensaje__c = :sAreaChat AND
                                        CC_Activo__c = true Order by CreatedDate DESC];
                }

                if (!oMensajes.isEmpty())
                {
                    bEncontrado = true;
                    break;
                }
            }
        }

        if (!bEncontrado && sIdioma != null && sIdioma != '')
        {
            // Buscamos por idioma, al no encontrar por Id Global.
            if (sOrigen != null && sOrigen != '')
            {
                oMensajes = [SELECT Id, Name, CC_Codigo_Cognitive__c, CC_Mensaje_Agente_es__c, CC_Respuesta_Mensaje_Automatico_es__c
                                FROM CC_FAQ__c
                                WHERE RecordTypeId = :sMsjRTId AND CC_Procedencia_Mensaje_Automatico__c = :sCodigoMsj AND
                                CC_IdiomaMsj__c = :sIdioma AND CC_Origen__c includes(:sOrigen) AND
                                CC_AreaMensaje__c = :sAreaChat AND CC_Activo__c = true Order by CreatedDate DESC];
            }
            
            if (oMensajes.isEmpty())
            {
                oMensajes = [SELECT Id, Name, CC_Codigo_Cognitive__c, CC_Mensaje_Agente_es__c, CC_Respuesta_Mensaje_Automatico_es__c
                                FROM CC_FAQ__c
                                WHERE RecordTypeId = :sMsjRTId AND CC_Procedencia_Mensaje_Automatico__c = :sCodigoMsj AND
                                CC_IdiomaMsj__c = :sIdioma AND CC_AreaMensaje__c = :sAreaChat AND
                                CC_Activo__c = true Order by CreatedDate DESC];
            }
        }

        return oMensajes;
    }
    
    public class pickListWrapper {
        @AuraEnabled public String picklistLabel {get; set;}
        @AuraEnabled public String picklistValue {get; set;}
        @AuraEnabled public Boolean bSel {get; set;}
	}
    
    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getValuesPicklistFiltersEspacio(String idioma, String espacio) {
		//Esta función se utiliza para poder realizar los filtros de búsqueda de las faqs por idioma y por espacio.          
        List<pickListWrapper> options = new List<pickListWrapper>();
        List <CC_FAQ__c> espacios = new List<CC_FAQ__c>();
        ID iRT = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        espacios = [SELECT CC_Descripcion_es__c, CC_Descripcion_ca__c FROM CC_FAQ__c WHERE RecordTypeId = :iRT AND CC_Obsoleto__c = false];
        pickListWrapper wrap = new pickListWrapper();        
        for (CC_FAQ__c espacioFaq : espacios) {
                wrap.picklistLabel = espacioFaq.CC_Descripcion_es__c;
                wrap.picklistValue = espacio;
                wrap.bSel = true;
                options.add(wrap);                       

        }
        return options;
	}
    
    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getValuesPicklistFiltersCategoria(String espacio, String categoria, String aplicacion) { 
        //Esta función se utiliza para poder realizar los filtros de búsqueda de las faqs por espacio, devolviendo sus categorías correspondientes.   
        List<pickListWrapper> options = new List<pickListWrapper>();

        Id recordTypeIdEspacio = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        Id recordTypeIdCategoria = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();

        List<CC_FAQ__c> oEspacios = new List<CC_FAQ__c>();
            
        if(!String.isBlank(aplicacion)){
        	 oEspacios = [SELECT Id FROM CC_FAQ__c WHERE Name = :espacio AND RecordTypeId = :recordTypeIdEspacio AND CC_Obsoleto__c = false  AND CC_Lookup_App__r.Name = :aplicacion LIMIT 1]; 
            
        }else{
            oEspacios = [SELECT Id FROM CC_FAQ__c WHERE Name = :espacio AND RecordTypeId = :recordTypeIdEspacio AND CC_Obsoleto__c = false LIMIT 1];    
        }
         
        for (CC_FAQ__c oEspacio : oEspacios)
        {        
            List <CC_FAQ__c> categorias = new List<CC_FAQ__c>();
            if(!String.isBlank(aplicacion)){
                categorias = [SELECT Name, CC_Descripcion_es__c, CC_Descripcion_ca__c FROM CC_FAQ__c WHERE CC_Lookup_Espacio__c = :oEspacio.Id AND RecordTypeId = :recordTypeIdCategoria AND CC_Obsoleto__c = false AND CC_Lookup_App__r.Name = :aplicacion];
            }else{
                categorias = [SELECT Name, CC_Descripcion_es__c, CC_Descripcion_ca__c FROM CC_FAQ__c WHERE CC_Lookup_Espacio__c = :oEspacio.Id AND RecordTypeId = :recordTypeIdCategoria AND CC_Obsoleto__c = false];
            }
            
            pickListWrapper wrapDefault = new pickListWrapper();
            wrapDefault.picklistLabel = '--Selecciona una categoría--';
            wrapDefault.picklistValue = '--Selecciona una categoría--';
            options.add(wrapDefault); 
            
            for (CC_FAQ__c categoriaFaq : categorias) {
                pickListWrapper wrap = new pickListWrapper();
                wrap.picklistLabel = categoriaFaq.CC_Descripcion_es__c;
                wrap.picklistValue = categoriaFaq.Name;
				
                wrap.bSel = categoriaFaq.Name == categoria ? true : false;              
                options.add(wrap);
            }   
        }     
        return options;
	}
    
    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getValuesPicklistEspacios(String idioma, String espacio, String aplicacion) {
		//Esta función se utiliza para poder realizar los filtros de búsqueda de las faqs por idioma y por espacio.          
        List<pickListWrapper> options = new List<pickListWrapper>();
        List <CC_FAQ__c> espacios = new List<CC_FAQ__c>();
        Id iRT = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        espacios = [SELECT Name, CC_Descripcion_es__c, CC_Descripcion_ca__c, CC_Lookup_App__c, CC_Lookup_App__r.Name FROM CC_FAQ__c WHERE RecordTypeId = :iRT 
                    AND CC_Lookup_App__r.Name = :aplicacion
                    AND CC_Obsoleto__c = false order by Name asc];
        
        for (CC_FAQ__c espacioFaq : espacios) {
            pickListWrapper wrap = new pickListWrapper();   
            wrap.picklistLabel = idioma == 'ca' ?  espacioFaq.CC_Descripcion_ca__c : espacioFaq.CC_Descripcion_es__c;
            wrap.picklistValue = espacioFaq.Name;
            //wrap.bSel = true;
            
             wrap.bSel = espacioFaq.Name == espacio ? true : false;

            options.add(wrap); 
            

        }
        return options;
	}    
    
    // Método que llamado desde el aura para recuperar la descripción del espacio
    @AuraEnabled   
    public static Map<String,String> datosLiveChatTranscript(String recordId, String idioma, String espacio, String categoria) { 
        return CC_LiveAgent_BotonesController.datosLiveChatTranscript(recordId, idioma, espacio, categoria, null);
    }
}