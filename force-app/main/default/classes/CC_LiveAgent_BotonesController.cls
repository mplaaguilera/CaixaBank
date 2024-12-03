public with sharing class CC_LiveAgent_BotonesController {

    @AuraEnabled
    public static Map<String,Object> getValuesIdioma(String chatId) {
       Map<String,Object> oRes = new Map<String,Object>();

       List<LiveChatTranscript> oChat = [SELECT Id, CC_IdiomaCV__c, CC_IdsGlobales__c from LiveChatTranscript  WHERE Id =:chatId];
       if (!oChat.isEmpty())
       {
            List<String> oIdsChat = new List<String>();
            String sIdsGlobales = oChat[0].CC_IdsGlobales__c;
            if (sIdsGlobales != null && sIdsGlobales != '')
            {
                oIdsChat = sIdsGlobales.split(',');
            }

            oRes.put('Idioma', oChat[0].CC_IdiomaCV__c);
            oRes.put('IdsGlobales', oIdsChat);
       }
       return oRes;
    }
    
    @AuraEnabled
    public static void actualizarCaso(Id recordId) {
         List<LiveChatTranscript> chatsUpdate = new List<LiveChatTranscript>();
        LiveChatTranscript lct = [SELECT CaseId, CC_Tipo__c, CC_Id_Cognitive__c, Case.CaseNumber  FROM LiveChatTranscript WHERE Id = :recordId];
        
        //String idCognitivo = 'XX_'+lct.CC_Id_Cognitive__c+'_'+lct.Case.CaseNumber;
            Case caso = new Case(
                Id = lct.CaseId,
                CC_Id_Cognitivo__c = lct.Case.CaseNumber,
                CC_Id_Cognitivo_Transfer__c = lct.CC_Id_Cognitive__c
            );
            update caso;
    }

    @AuraEnabled
    //public static Map<String,Object> getLiveChatTranscript(String recordId, String franjaHoraria)
    public static Map<String,Object> getLiveChatTranscript(String recordId)
    {
        Map<String,Object> oRes = new Map<String,Object>();
        Boolean bienvenida = true;
        Boolean bTransferir = false;
        List<String> mensajes = new List<String>();
        LiveChatTranscript chatUpdate = new LiveChatTranscript();
        Boolean bActualizar = false;
        Map<String,String> datosTransferir = new Map<String,String>();

        List<LiveChatTranscript> oChat = [SELECT Id, CC_Aplicacion__c, CC_Aplicacion_Origen__c, CC_Transferir__c, CC_Espacio__c, CC_Categoria__c, CC_Tipo__c, CC_Bienvenida__c, CC_IdiomaCV__c, CC_Nickname__c, CC_Idioma__c, CC_Canal_Procedencia__c,
                                            CaseId, Owner.Alias, CC_Cognitive_chat__c, CC_Id_Cognitive__c, CC_SRId__c, ContactId, CC_Actualizar_Siebel__c,
                                            CC_IdsGlobales__c, RecordTypeId, CC_Habilitar_Escalar_C2C__c
                                            FROM LiveChatTranscript
                                            WHERE Id = :recordId LIMIT 1];

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

            List<String> oIdsChat = new List<String>();
            String sIdsGlobales = oChat[0].CC_IdsGlobales__c;
            if (sIdsGlobales != null && sIdsGlobales != '')
            {
                oIdsChat = sIdsGlobales.split(',');
            }

            if(sAreaChat == 'Empleado')
            {
                List<LiveChatTranscript> listaChats = [SELECT Id, CC_Id_Cognitive__c FROM LiveChatTranscript
                                                       WHERE CC_Id_Cognitive__c =: oChat[0].CC_Id_Cognitive__c
                                                       AND CC_Tipo__c =: 'Hidden'];   //cambiar stop&go
                Integer contadorHidden = listaChats.size();
                oRes.put('ContadorHidden', contadorHidden);
            }
            Map<String,String> oIdiomas = recuperarIdiomasChat(oChat[0].CC_Aplicacion__c);

            if (bActualizar)
            {
        update chatUpdate;
            }

            oRes.put('DatosChat', oChat);
            oRes.put('AreaChat', sAreaChat);
            oRes.put('IdsGlobales', oIdsChat);
            oRes.put('IdiomasChat', oIdiomas);
            //oRes.put('MensajeBienvenida', mensajes);
            //oRes.put('Transferir',bTransferir);
            //oRes.put('DatosTransferir',datosTransferir);

        }

        //Se devuelven diferentes campos del chat
        return oRes;
    }

    @AuraEnabled
    public static void getContexto(String sourceApp, String sourceConversationId, String recordId, String caseId)
    {
    	CC_WS_Recupera_LogConversacion_Chat.CC_WS_Recupera_LogConversacion_Chat(sourceApp, sourceConversationId, recordId, caseId);
    }

    @AuraEnabled
    public static Map<String,Object> getLiveChatTranscript_v2(String recordId, String franjaHoraria)
    {
        Map<String,Object> oRes = new Map<String,Object>();
        Boolean bienvenida = true;
        Boolean bTransferir = false;
        List<String> mensajes = new List<String>();
        LiveChatTranscript chatUpdate = new LiveChatTranscript();
        Boolean bActualizar = false;
        String stopAndGo = '';
        String transfer = '';
        Integer contadorStopAndGo = 0;
        Integer contadorTransfer = 0;
        Map<String,String> datosTransferir = new Map<String,String>();

        List<LiveChatTranscript> oChat = [SELECT Id, CC_Aplicacion__c, CC_Aplicacion_Origen__c, Case.CC_URL_Encuesta_3N__c , CC_Transferir__c, CC_Espacio__c, CC_Categoria__c, CC_Tipo__c, CC_Bienvenida__c, CC_IdiomaCV__c, CC_Nickname__c, CC_Idioma__c, CC_Canal_Procedencia__c,
                                            CaseId, Owner.Alias, OwnerId, Owner.Name, Owner.FirstName, CC_Cognitive_chat__c, CC_Id_Cognitive__c, CC_SRId__c, ContactId, CC_Actualizar_Siebel__c,CC_PerfilVisitante__c,
                                            CC_IdsGlobales__c, RecordTypeId, CC_Habilitar_Escalar_C2C__c, CC_Agente_Chat_Atendido__c, Status, CC_Espacio_Transfer__c, CC_Categoria_Transfer__c, CC_Pilotaje__c, CC_Source_Aplicacion_Corpus__c, CC_Source_Conversation_Id__c, 
                                            CC_Contador_Transfer__c, CC_Chat_Transferido__c, Name
                                            FROM LiveChatTranscript
                                            WHERE Id = :recordId LIMIT 1];

        // Recuperar el área del chat.
        String sAreaChat = 'Cliente';
        if (!oChat.isEmpty())
        {
            /*if(oChat[0].CaseId != null && (oChat[0].Status == 'InProgress' || oChat[0].Status == 'Waiting')){

                List<Case> casosUpdate = new List<Case>();
                Case caso = new Case();
                caso.Id = oChat[0].CaseId;
                caso.OwnerId = oChat[0].OwnerId; // Asignación del caso al propietario del chat.
                casosUpdate.add(caso);

                // Lanzamos actualización primero, en el caso que no exista (primer hidden, fallará. Simulación Trigger BU)
                if (!casosUpdate.isEmpty())
                {
                    Database.SaveResult[] oResUp = Database.update(casosUpdate, false);
                }
            }*/

            String sChatEmpRT = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();
            if (oChat[0].RecordTypeId == sChatEmpRT)
            {
                // Chat empleados.
                sAreaChat = 'Empleado';
            }

            //recuperar el número de empleado
            //String sEmployeeNumber = '';
            List<User> sEmployeeNumber = [SELECT EmployeeNumber, CompanyName FROM User WHERE Id = :oChat[0].OwnerId and IsActive =: true];

            List<String> oIdsChat = new List<String>();
            String sIdsGlobales = oChat[0].CC_IdsGlobales__c;
            if (sIdsGlobales != null && sIdsGlobales != '')
            {
                oIdsChat = sIdsGlobales.split(',');
            }

            if(sAreaChat == 'Empleado')
            {
                List<LiveChatTranscript> listaChats = [SELECT Id, CC_Id_Cognitive__c, CC_StopGo__c, CC_Chat_Transferido__c FROM LiveChatTranscript
                                                       WHERE CC_Id_Cognitive__c =: oChat[0].CC_Id_Cognitive__c
                                                       /*AND CC_Tipo__c =: 'Hidden' */
                                                        /*AND CC_StopGo__c = true*/];

                    for (LiveChatTranscript chatRecorrido :listaChats) {
                        if(chatRecorrido.CC_StopGo__c == true){
                            contadorStopAndGo += 1;
                        }
                        if(chatRecorrido.CC_Chat_Transferido__c == true){
                            contadorTransfer += 1;
                        }
                    }
                                    //US461779: Visualizar Nº stop&go Se suplanta el contador de casos Hidden por el contador de stop&go
               //contadorStopAndGo = listaChats.size();
                
            }

            if (oChat[0].CC_Bienvenida__c != null && oChat[0].CC_Tipo__c != 'Hidden')
            {
                bienvenida = oChat[0].CC_Bienvenida__c;
                if (!bienvenida)
                {
                    // Recuperar el mensaje de bienvenida.
                    mensajes = getMensajesBienvenida(oChat[0].CC_IdiomaCV__c, oIdsChat, oChat[0].CC_Canal_Procedencia__c, oChat[0].ContactId, franjaHoraria, sAreaChat);

                    bActualizar = true;
                    chatUpdate.Id = oChat[0].Id;
                    chatUpdate.CC_Bienvenida__c = true;
                }
            }else{
                oChat[0].CC_Bienvenida__c = true;
            }
            if (oChat[0].CC_Transferir__c != null)
            {
                bTransferir = oChat[0].CC_Transferir__c;
                if (bTransferir && oChat[0].Status == 'InProgress')
                {
                    // Recuperar el mensaje de bienvenida.
                    datosTransferir = datosLiveChatTranscript(oChat[0].Id, oChat[0].CC_IdiomaCV__c, oChat[0].CC_Espacio_Transfer__c, oChat[0].CC_Categoria_Transfer__c,null);

                    bActualizar = true;
                    chatUpdate.Id = oChat[0].Id;
                    chatUpdate.CC_Transferir__c = false;
                    chatUpdate.CC_Chat_Transferido__c = true;
                    chatUpdate.CC_Espacio__c = oChat[0].CC_Espacio_Transfer__c;
                    chatUpdate.CC_Categoria__c = oChat[0].CC_Categoria_Transfer__c;
                    // Crear actividad.
                    CreateActivity(oChat[0].CaseId, 'Este chat se ha transferido', 'Chat - Transferir', 'Transferir', oChat[0].CC_Id_Cognitive__c, oChat[0].Id, null, oChat[0].CC_Espacio_Transfer__c, oChat[0].CC_Categoria_Transfer__c);
                }
            }else{
                oChat[0].CC_Transferir__c = false;
            }
            if( oChat[0].CC_Agente_Chat_Atendido__c !=null ){
                 stopAndGo = 'Si';
            }
           
            if(contadorTransfer > 0){
            transfer = 'Si';
           }

            if(oChat[0].CC_Contador_Transfer__c <= contadorTransfer){
                chatUpdate.CC_Contador_Transfer__c = contadorTransfer;
            }

            Map<String,String> oIdiomas = recuperarIdiomasChat(oChat[0].CC_Aplicacion__c);

            if (bActualizar)
            {
        		update chatUpdate;
            }
            oRes.put('DatosChat', oChat);
            oRes.put('AreaChat', sAreaChat);
            oRes.put('IdsGlobales', oIdsChat);
            oRes.put('IdiomasChat', oIdiomas);
            oRes.put('MensajeBienvenida', mensajes);
            oRes.put('Transferir',bTransferir);
            oRes.put('DatosTransferir',datosTransferir);
            oRes.put('StopAndGo',stopAndGo);
            oRes.put('Perfil',oChat[0].CC_PerfilVisitante__c);
            oRes.put('Pilotaje',oChat[0].CC_Pilotaje__c);
            oRes.put('EmployeeNumber',sEmployeeNumber[0].EmployeeNumber);
            oRes.put('Company',sEmployeeNumber[0].CompanyName);
            oRes.put('Encuesta', oChat[0].Case.CC_URL_Encuesta_3N__c);
            oRes.put('aplicacionOrigen', oChat[0].CC_Aplicacion_Origen__c);
            oRes.put('ContadorStopAndGo', contadorStopAndGo);
            oRes.put('ContadorTransfer', contadorTransfer);
            oRes.put('Transfer',transfer);

        }

        //Se devuelven diferentes campos del chat
        //system.debug('oRes: '+oRes);
        return oRes;
    }

    public static Map<String,String> recuperarIdiomasChat (String aplicacion)
    {
        Map<String,String> oRes = new Map<String,String>();
        List<CC_Parametros__mdt> oListParams = new List<CC_Parametros__mdt>();

        if(aplicacion == 'GinaAPP') {
            oListParams = [SELECT Id, CC_Activo__c, CC_AreaCfg__c, Nombre__c, Valor_Texto__c, CC_Orden__c  FROM CC_Parametros__mdt WHERE CC_Activo_Chat_GINA__c = true AND CC_AreaCfg__c = 'CC_IdiomaChat' ORDER BY CC_Orden__c ASC];
        }
        else {
            oListParams = [SELECT Id, CC_Activo__c, CC_AreaCfg__c, Nombre__c, Valor_Texto__c, CC_Orden__c  FROM CC_Parametros__mdt WHERE CC_Activo__c = true AND CC_AreaCfg__c = 'CC_IdiomaChat' ORDER BY CC_Orden__c ASC];
        }

        for (CC_Parametros__mdt oParam : oListParams)
        {
            oRes.put(oParam.Nombre__c, oParam.Valor_Texto__c);
        }
        return oRes;
    }

    @AuraEnabled
    public static Map<String,String> datosLiveChatTranscript(String recordId, String idioma, String espacio, String categoria, String tipoChat)
    {

        String telefono;
        String descripcionCategoria;
        String descripcionEspacio;
        String piloto = 'No';
		List <CC_Lista_Valores__c> serviciosPiloto = new List < CC_Lista_Valores__c>();

        List<CC_FAQ__c> faqs = new  List<CC_FAQ__c>();
        if(categoria != null){
            Id recordTypeCategoria = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();
            faqs=  [SELECT CC_Lookup_Espacio__r.CC_Descripcion_es__c, CC_Lookup_Espacio__r.Name, CC_Lookup_Espacio__r.CC_Descripcion_ca__c, CC_Descripcion_es__c, CC_Descripcion_ca__c, CC_Telefono__c, CC_TelefonoCA__c FROM CC_FAQ__c WHERE Name = :categoria AND RecordtypeId =: recordTypeCategoria LIMIT 1];
            if(tipoChat != null){
                serviciosPiloto = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_ChatEmpleadosSinExternalRouting' AND CC_Lista__r.CC_Activa__c = true AND CC_Activa__c = true AND CC_Valor2__c =: idioma AND CC_Valor__c =: espacio AND CC_Valor_SFDC__c= :categoria LIMIT 1];
            }
        }else{
            Id recordTypeEspacio = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
            faqs = [SELECT CC_Descripcion_es__c, CC_Descripcion_ca__c, CC_Telefono__c, CC_TelefonoCA__c FROM CC_FAQ__c WHERE Name = :espacio AND RecordtypeId =: recordTypeEspacio LIMIT 1];
            if(tipoChat != null){
                serviciosPiloto = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_ChatEmpleadosSinExternalRouting' AND CC_Lista__r.CC_Activa__c = true AND CC_Activa__c = true AND CC_Valor2__c =: idioma AND CC_Valor__c =: espacio LIMIT 1];
            }
        }

        if(!faqs.isEmpty()){
            for(CC_FAQ__c faq : faqs){
                if(categoria != null){
                    if(idioma == 'ca'){
                        descripcionCategoria = faq.CC_Descripcion_ca__c;
                        espacio = faq.CC_Lookup_Espacio__r.Name;
                        descripcionEspacio = faq.CC_Lookup_Espacio__r.CC_Descripcion_ca__c;
                        telefono = faq.CC_TelefonoCA__c;
                    }else{
                        descripcionCategoria = faq.CC_Descripcion_es__c;
                        espacio = faq.CC_Lookup_Espacio__r.Name;
                        descripcionEspacio = faq.CC_Lookup_Espacio__r.CC_Descripcion_es__c;
                        telefono = faq.CC_Telefono__c;
                    }
                }else{
                    if(idioma == 'ca'){
                        descripcionEspacio = faq.CC_Descripcion_ca__c;
                    }else{
                        descripcionEspacio = faq.CC_Descripcion_es__c;
                    }
                }
            }
        }

        if(!serviciosPiloto.isEmpty()){
        	piloto = 'Si';
        }
        Map<String,String> oRes = new Map<String,String>();
        oRes.put('Categoria',categoria);
        oRes.put('DescripcionCategoria',descripcionCategoria);
        oRes.put('Espacio',espacio);
        oRes.put('DescripcionEspacio',descripcionEspacio);
        oRes.put('Telefono',telefono);
        oRes.put('Piloto',piloto);
        return oRes;
    }
    
    @AuraEnabled
    public static Map<String,String> datosLiveChatTranscriptTransfer(String recordId, String idioma, String espacio, String categoria, String tipoChat, Boolean actualizar)
    {

        String telefono;
        String descripcionCategoria;
        String descripcionEspacio;
        String piloto = 'No';
        String doFind; 
        
		List <CC_Lista_Valores__c> serviciosPiloto = new List < CC_Lista_Valores__c>();
        List <CC_Lista_Valores__c> chatHDT = new List < CC_Lista_Valores__c>();

        List<CC_FAQ__c> faqs = new  List<CC_FAQ__c>();
        if(categoria != null){
            Id recordTypeCategoria = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();
            faqs=  [SELECT CC_Lookup_Espacio__r.CC_Descripcion_es__c, CC_Lookup_Espacio__r.Name, CC_Lookup_Espacio__r.CC_Descripcion_ca__c, CC_Descripcion_es__c, CC_Descripcion_ca__c, CC_Telefono__c, CC_TelefonoCA__c FROM CC_FAQ__c WHERE Name = :categoria AND RecordtypeId =: recordTypeCategoria LIMIT 1];
            if(tipoChat != null){
                serviciosPiloto = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_ChatEmpleadosSinExternalRouting' AND CC_Lista__r.CC_Activa__c = true AND CC_Activa__c = true AND CC_Valor2__c =: idioma AND CC_Valor__c =: espacio AND CC_Valor_SFDC__c= :categoria LIMIT 1];
            	chatHDT = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT_Relacion_EspacioCategoria_Skill_Chat' AND CC_Lista__r.CC_Activa__c = true AND CC_Activa__c = true AND Name =: espacio AND CC_Valor__c =: categoria LIMIT 1];
                if(!chatHDT.isEmpty()){
                    doFind = 'False';
                    if(actualizar){
                    	actualizarCaso(recordId);    
                    }
                    
        		}
            }
        }else{
            Id recordTypeEspacio = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
            faqs = [SELECT CC_Descripcion_es__c, CC_Descripcion_ca__c, CC_Telefono__c, CC_TelefonoCA__c FROM CC_FAQ__c WHERE Name = :espacio AND RecordtypeId =: recordTypeEspacio LIMIT 1];
            if(tipoChat != null){
                serviciosPiloto = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_ChatEmpleadosSinExternalRouting' AND CC_Lista__r.CC_Activa__c = true AND CC_Activa__c = true AND CC_Valor2__c =: idioma AND CC_Valor__c =: espacio LIMIT 1];
            }
        }

        if(!faqs.isEmpty()){
            for(CC_FAQ__c faq : faqs){
                if(categoria != null){
                    if(idioma == 'ca'){
                        descripcionCategoria = faq.CC_Descripcion_ca__c;
                        espacio = faq.CC_Lookup_Espacio__r.Name;
                        descripcionEspacio = faq.CC_Lookup_Espacio__r.CC_Descripcion_ca__c;
                        telefono = faq.CC_TelefonoCA__c;
                    }else{
                        descripcionCategoria = faq.CC_Descripcion_es__c;
                        espacio = faq.CC_Lookup_Espacio__r.Name;
                        descripcionEspacio = faq.CC_Lookup_Espacio__r.CC_Descripcion_es__c;
                        telefono = faq.CC_Telefono__c;
                    }
                }else{
                    if(idioma == 'ca'){
                        descripcionEspacio = faq.CC_Descripcion_ca__c;
                    }else{
                        descripcionEspacio = faq.CC_Descripcion_es__c;
                    }
                }
            }
        }

        if(!serviciosPiloto.isEmpty()){
        	piloto = 'Si';
        }
        /*if(!chatHDT.isEmpty()){
        	doFind = 'False';
            
        }*/
        Map<String,String> oRes = new Map<String,String>();
        oRes.put('Categoria',categoria);
        oRes.put('DescripcionCategoria',descripcionCategoria);
        oRes.put('Espacio',espacio);
        oRes.put('DescripcionEspacio',descripcionEspacio);
        oRes.put('Telefono',telefono);
        oRes.put('Piloto',piloto);
        oRes.put('doFind',doFind);
        return oRes;
    }

    @AuraEnabled
    public static Map<String,Object> changeLanguage(Id caseId, Id chatId, String idioma, String sAreaChat)
    {
        Map<String,Object> oRes = new Map<String,Object>();

        // Recuperar datos del Chat.
        List<LiveChatTranscript> chatLang = [SELECT Id, CC_IdiomaCV__c, CC_IdsGlobales__c, CC_Aplicacion__c, CC_PerfilVisitante__c
                                            FROM LiveChatTranscript WHERE Id =: chatId];

        if (chatLang.isEmpty())
        {
            oRes.put('Estado','KO');
            return oRes;
        }
        // Invocar al servicio de Cognitivo.
        String sIdiomaAnt = chatLang[0].CC_IdiomaCV__c;
        String sAplicacion = chatLang[0].CC_Aplicacion__c;
        String sIdioma = idioma;
        String sPerfil = chatLang[0].CC_PerfilVisitante__c;
        String sNuevosIDs = CC_FAQ.getNuevoPerfilCliente (sAplicacion, sIdioma, sPerfil);

        // Tratar respuesta WS.
        if (sNuevosIDs != '')
        {
            sNuevosIDs = sNuevosIDs.replace('[','');
            sNuevosIDs = sNuevosIDs.replace(']','');
            List<String> oGlobalIds = sNuevosIDs.split(',');

            // Update chat & case language
            Case currentCaseInfo = [select Id, CC_Idioma__c from Case where Id =: caseId];

            // Actualizar los idiomas.
            currentCaseInfo.CC_Idioma__c = idioma;
            chatLang[0].CC_IdiomaCV__c = idioma;
            chatLang[0].CC_IdsGlobales__c = sNuevosIDs;
            update currentCaseInfo;
            update chatLang;

            // Buscar el mensaje automático de cambio de idioma.
            String sCodigoMsj = 'Cambio de idioma';
            CC_FAQ__c oMensajeChat;
            List<CC_FAQ__c> oMensajes = CC_LiveAgent_FAQ_Controller.getMensaje(sCodigoMsj, idioma, oGlobalIds, '', sAreaChat);
            if (!oMensajes.isEmpty())
            {
                oMensajeChat = oMensajes[0];
            }

            oRes.put('IdsGlobales', oGlobalIds);
            oRes.put('MensajeChat', oMensajeChat);
            oRes.put('Estado','OK');
        }else{
            oRes.put('idiomaAnterior', sIdiomaAnt);
            oRes.put('Estado','KO');
        }

        return oRes;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_FAQ__c> getMensajesChat(String sCodigoMsj, String idioma, List<String> oGlobalIds, String sOrigen, String sAreaChat)
    {
        List<CC_FAQ__c> oMensajes = CC_LiveAgent_FAQ_Controller.getMensaje(sCodigoMsj, idioma, oGlobalIds, sOrigen, sAreaChat);

        return oMensajes;
    }

    @AuraEnabled
    public static List<String> getMensajesBienvenida(String idioma, List<String> oGlobalIds, String sOrigen, String contactoId, String sFranjaDia, String sAreaChat)
    {
        String sCodigoMsj = '';
        Boolean contactoConfidencial = false;

        List<Contact> oContacto = [SELECT Id, CC_Confidencial__c FROM Contact WHERE Id = :contactoId LIMIT 1];
        for (Contact oAux : oContacto)
        {
            if (oAux.CC_Confidencial__c != null)
            {
                contactoConfidencial = oAux.CC_Confidencial__c;
            }
        }

        List<String> oListaMensajes = new List<String>();
        if (contactoConfidencial) {
            sCodigoMsj = 'Bienvenida confidencial';
        }else{
            sCodigoMsj = 'Bienvenida';
        }

        List<CC_FAQ__c> oMensajes = CC_LiveAgent_FAQ_Controller.getMensaje(sCodigoMsj, idioma, oGlobalIds, sOrigen, sAreaChat);

        // Buscar el saludo por la franja del día.
        String sSaludoMsj = '';
        if (sFranjaDia != null && sFranjaDia != '')
        {
            sCodigoMsj = 'Franja Dia';
            List<CC_FAQ__c> oSaludo = CC_LiveAgent_FAQ_Controller.getMensaje(sCodigoMsj, idioma, oGlobalIds, '', sAreaChat);

            for (CC_FAQ__c oMensSaludo : oSaludo)
            {
                String sClave = sCodigoMsj + ' ' + sFranjaDia;
                if (oMensSaludo.Name == sClave)
                {
                    sSaludoMsj = oMensSaludo.CC_Respuesta_Mensaje_Automatico_es__c;
                    break;
                }
            }
        }

        // Creamos la lista de mensajes de bienvenida.
        for (CC_FAQ__c oMensaje : oMensajes)
        {
            String sMensajeAux = oMensaje.CC_Respuesta_Mensaje_Automatico_es__c;
            if (sSaludoMsj != null)
            {
                sMensajeAux = sMensajeAux.replace('{!saludo}',sSaludoMsj);
            }
            oListaMensajes.add(sMensajeAux);
        }

        return oListaMensajes;
    }

   @AuraEnabled
    public static void checkBienvenida(String recordId) {
        LiveChatTranscript liveChatTranscript = [SELECT CC_Bienvenida__c FROM LiveChatTranscript
                                                 WHERE Id = :recordId LIMIT 1];
        liveChatTranscript.CC_Bienvenida__c = true;
        update liveChatTranscript;
    }

    @AuraEnabled
    public static void CreateActivity(Id recordId, String comentario, String subject, String tipo, String cognitiveId, String transcriptId, String telefono, String espacio, String categoria ) {
        // Crear Tarea
        Task task = new Task();
        task.ActivityDate = System.today();
        task.Subject = subject;
        task.Type = tipo;
        task.Status = 'Completed';
        task.Description = comentario;
        task.WhatId = recordId;
        task.CC_Chat_Cognitivo_Id__c = cognitiveId;
        task.CC_LiveChatTranscript_Id__c = transcriptId;
        task.CC_Telefono__c = telefono;
        task.CC_Espacio__c = espacio;
        task.CC_Categoria__c = categoria;
        CC_Activity.crearActividad(task);
    }

    @AuraEnabled
    public static void UpdateLiveChatTrans(Id recordId) {
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(Id = recordId);
        liveChatTranscript.CC_Cerrado_TimeOut__c = true;
        update liveChatTranscript;
    }

    @AuraEnabled
    public static String envioAltaSiebel(Id recordId, String idSR) {
        LiveChatTranscript listNewObj = new LiveChatTranscript();
        listNewObj.CC_Actualizar_Siebel__c = false;
        listNewObj.Id = recordId;
        update listNewObj;

        return idSR;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_LiveAgent_FAQ_Controller.pickListWrapper> recuperarEspacios(String idioma, String espacio, String aplicacion){
        List<CC_LiveAgent_FAQ_Controller.pickListWrapper> options = CC_LiveAgent_FAQ_Controller.getValuesPicklistEspacios(idioma, espacio, aplicacion);
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_LiveAgent_FAQ_Controller.pickListWrapper> recuperarEspaciosFilter(String idioma, String espacio){
        List<CC_LiveAgent_FAQ_Controller.pickListWrapper> options = CC_LiveAgent_FAQ_Controller.getValuesPicklistFiltersEspacio(idioma,espacio);
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_LiveAgent_FAQ_Controller.pickListWrapper> recuperarCategorias(String espacio, String categoria, String aplicacion){

        List<CC_LiveAgent_FAQ_Controller.pickListWrapper> options = CC_LiveAgent_FAQ_Controller.getValuesPicklistFiltersCategoria(espacio, categoria, aplicacion);
        return options;
    }

    @AuraEnabled
    public static void actualizarLiveChat(Id recordId, String espacio, String categoria, Boolean transferir) {
        LiveChatTranscript liveChatTranscript = [SELECT CC_Transferir__c, CC_Espacio__c, CC_Categoria__c FROM LiveChatTranscript
                                                 WHERE Id = :recordId LIMIT 1];



        //liveChatTranscript.CC_Espacio__c = espacio;
        //liveChatTranscript.CC_Categoria__c = categoria;

        liveChatTranscript.CC_Espacio_Transfer__c = espacio;
        liveChatTranscript.CC_Categoria_Transfer__c = categoria;
        liveChatTranscript.CC_Transferir__c = transferir;
        update liveChatTranscript;
    }

    @AuraEnabled
    public static void cerrarCaso(Id recordId) {
        LiveChatTranscript lct = [SELECT CaseId, CC_Tipo__c, CC_Id_Cognitive__c, Case.CaseNumber FROM LiveChatTranscript WHERE Id = :recordId];
        if (lct.CC_Tipo__c == 'Hidden' && lct.CaseId != null)
        {
            Case caso = new Case(
                Id = lct.CaseId,
                CC_Tipo_ChatTranscript__c = lct.CC_Tipo__c,
                Status = 'Cerrado',
                CC_Canal_Operativo__c = 'Sin canal'
            );
            update caso;
        }
    }

    @AuraEnabled
    public static void gestionChatOwner_Interno2(Id chatsEntrantes) {
        if (chatsEntrantes != null) {
            List<Case> casosUpdate = new List<Case>();
            for (LiveChatTranscript chat : [SELECT OwnerId, CaseId FROM LiveChatTranscript
                                            WHERE Id = :chatsEntrantes AND Status IN ('InProgress', 'Waiting')]) {
                Case caso = new Case(Id = chat.CaseId);
                caso.OwnerId = chat.OwnerId; //Asignación del caso al propietario del chat.
                caso.CC_Chat_Atendido__c = true;
                casosUpdate.add(caso);
            }
            Database.update(casosUpdate, false);
        }
    }

    @AuraEnabled
    public static Id CreateActivityPausa(Id recordId, String cognitiveId, String transcriptId,Integer nPausas) {
        LiveChatTranscript lc = new LiveChatTranscript();
        lc.id= transcriptId;
        lc.CC_Numero_Pausas__c = nPausas;
        update lc;

        Date todaysDate = system.today();
        Task task = new Task();
        task.ActivityDate = todaysDate;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        task.Type = 'Pausa Chat';
        task.Subject = 'Pausa Chat';
        task.Status = 'Open';
        task.WhatId = recordId;
        task.CC_Chat_Cognitivo_Id__c = cognitiveId;
        task.CC_LiveChatTranscript_Id__c = transcriptId;
        task = CC_Activity.crearActividad(task);
        return task.Id;
    }

    @AuraEnabled
    public static void CloseActivityPausa(Id recordId, String transcriptId,Integer pausaTotal,Integer tiempoPausado, String motivo) {
        //System.debug('CloseActivityPausa');
        LiveChatTranscript lc = new LiveChatTranscript();
        lc.id= transcriptId;
        lc.CC_Tiempo_Pausado__c  = pausaTotal;
        update lc;
        Task task = new Task();
        task.id = recordId;
        task.AV_WaitingRoomTime__c = tiempoPausado;
        task.Status = 'Completed';
        task.CC_Tipo_Cierre__c = motivo;
        update task;
        //System.debug(task);
        CC_Activity.finalizarActividad(recordId);
    }

    @AuraEnabled
    public static List<String> getMensajesPausaChat(String areaChat, String idioma){
        //System.debug('getMensajesPausaChat');
        Id rt = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Mensaje_Automatico_Chat').getRecordTypeId();
        List<CC_FAQ__c> oMensajes = [SELECT CC_Mensaje_Agente_es__c FROM CC_FAQ__c WHERE RecordTypeId = :rt AND CC_Nombre__c = 'Mensaje Automatico Pausa' AND CC_AreaMensaje__c = :areaChat AND CC_IdiomaMsj__c = :idioma ORDER BY CC_Version__c ASC];
        List<String> listaMensajes = new List<String>();
            for(CC_FAQ__c m : oMensajes){
         //m.CC_Mensaje_Agente_es__c = String.valueOf(m.CC_Mensaje_Agente_es__c).replace('{!nombreEmpleado}',nombreEmpleado);                    
         listaMensajes.add(String.valueOf(m.CC_Mensaje_Agente_es__c));
            }
        // List<String> listaMensajes = new List<String>{'','',''};
        //     for(CC_FAQ__c m : oMensajes){
        //         if(m.CC_Mensaje_Agente_es__c.contains('Estoy haciendo unas comprobaciones') || m.CC_Mensaje_Agente_es__c.contains('Estic fent unes comprovacions per')){
        //             listaMensajes.set(0, String.valueOf(m.CC_Mensaje_Agente_es__c));
        //         }else if(m.CC_Mensaje_Agente_es__c.contains('Sigo haciendo comprobaciones') || m.CC_Mensaje_Agente_es__c.contains('Continuo fent comprovacion')){
        //             listaMensajes.set(1, String.valueOf(m.CC_Mensaje_Agente_es__c));
        //         }else if(m.CC_Mensaje_Agente_es__c.contains('No me he olvidado') || m.CC_Mensaje_Agente_es__c.contains('No m\'he oblidat! Segueixo amb les')){
        //             listaMensajes.set(2, String.valueOf(m.CC_Mensaje_Agente_es__c));
        //         }
        //     }
        return listaMensajes;
    }

    @AuraEnabled
     public static String getMensajesPausaChat(String areaChat){
       // System.debug('getMensajesPausaChat');
        Id rt = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Mensaje_Automatico_Chat').getRecordTypeId();
        List<CC_FAQ__c> oMensajes = [SELECT CC_Mensaje_Agente_es__c FROM CC_FAQ__c WHERE RecordTypeId = :rt AND CC_Nombre__c = 'Mensaje Automatico Pausa' AND CC_AreaMensaje__c = :areaChat];

        return oMensajes.get(0).CC_Mensaje_Agente_es__c;
    }

    //Desarrollo  US572038 - Pausa agente: mensaje automático de disculpa cuando el agente retoma la conversación
    @AuraEnabled
    public static List<String> getMensajesReanudarChat(String areaChat, String idioma, String nombreEmpleado){
        Id rt = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Mensaje_Automatico_Chat').getRecordTypeId();
       List<CC_FAQ__c> oMensajes = [SELECT CC_Mensaje_Agente_es__c FROM CC_FAQ__c WHERE RecordTypeId = :rt AND CC_Nombre__c = 'Mensaje Automatico Reanudar' AND CC_AreaMensaje__c = :areaChat AND CC_IdiomaMsj__c = :idioma ORDER BY CC_Version__c ASC];
       List<String> listaMensajes = new List<String>();
       for(CC_FAQ__c m : oMensajes){
        m.CC_Mensaje_Agente_es__c = String.valueOf(m.CC_Mensaje_Agente_es__c).replace('{!nombreEmpleado}',nombreEmpleado);                    
        listaMensajes.add(String.valueOf(m.CC_Mensaje_Agente_es__c));
       }
       return listaMensajes;
    }
}