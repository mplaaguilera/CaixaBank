public class CC_ST_PlayStoreReviewsCtrl 
{
    @AuraEnabled
    public static List<CC_ST_AppReviews__c> getReviews(String packageName){
        List<CC_ST_AppReviews__c> appList = [SELECT Name,Author_Name__c,Title__c,Content__c,Case__c,Rating__c,App__c,Source__c,Review_ID__c,Developer_Comment__c,App_Id__c,App_Image__c
                                            FROM CC_ST_AppReviews__c 
                                            WHERE Source__c='Google Play Store' and App_Id__c=:packageName
                                            order by Name desc limit 50 ];
        if(appList.size()>0)
            return appList;
        else
            return null;
    }
    
    @AuraEnabled
    public static List<CC_ST_AppReviews__c> insertReviews(String appId, String countryCode,boolean crear_casos){
        List<CC_ST_AppReviews__c> apList = new List<CC_ST_AppReviews__c>();
        //esta query para que se usa?? ultimos 10.000 comentarios en salesforce?
        DateTime fechaIntervalo = System.today().addDays(-10);
        List<CC_ST_AppReviews__c> appRevList = [SELECT Id,Name,Review_ID__c,Rating__c,Content__c,Fecha__c 
                                                FROM CC_ST_AppReviews__c 
                                                WHERE Source__c='Google Play Store' and App_Id__c=:appId 
                                                AND Fecha__c >= : fechaIntervalo
                                                order by Fecha__c desc LIMIT 10000]; 

        Map<String,Id> appMap = new Map<String,Id>();
        Map<String,String> appMapRating = new Map<String,String>();
        Map<String,String> appMapReview = new Map<String,String>();
        Set<String> revIdSet = new Set<String>();
        
        //Controlamos si llega una actualización de un comentario ya existente
        //if((appMapRating.get(reviewId)==String.valueOf(rating)) && (appMapReview.get(reviewId)==ReviewTitle)) {

        for(CC_ST_AppReviews__c app:appRevList){
            if (!appMap.containsKey(app.Review_ID__c)){
                appMap.put(app.Review_ID__c, app.Id);
                appMapRating.put(app.Review_ID__c, app.Rating__c);
                appMapReview.put(app.Review_ID__c, app.Content__c.trim());
            }
        }
       
        CC_Config_Stores__mdt  STConfig = [SELECT MasterLabel,Imagen__c,App_Name__c FROM CC_Config_Stores__mdt 
                                           WHERE Identificador__c  =:appId LIMIT 1];
		// Ini trazas
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        
        String jsonResults = '';
        String st = '';
        Boolean flag = false;
        Boolean nextPageFlag = false;
        String nextPageToken = '';
        
        // Gestión trazas.
        if (appId != null || Test.isRunningTest()){
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'Google_Play';
            oTraza.CC_Identificador__c = appId;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = countryCode;
        }
        
        try {        
            CC_ST_GoogleForce gForce = New CC_ST_GoogleForce('Google_CaixaBank');
            //String endpoint = 'https://www.googleapis.com/androidpublisher/v3/applications/com.lacaixa.bolsaabierta/reviews';
            String endpoint1 = 'https://www.googleapis.com/androidpublisher/v3/applications/' + appId + '/reviews';
            
            Map<String, String> param = new Map<String, String>();
            param.put('method', 'GET');
            param.put('endpoint', endpoint1);
			// Traza de la entrada de la conexión            
            oTraza.CC_MensajeEntrada__c = String.valueOf(param);
            if(Test.isRunningTest()){
				jsonResults = '{\"reviews\": [{\"reviewId\": \"gp:AOqpTOGNhMCKlDLIA_sbhKppY87KXTmWL-zLbtFDbhNLVt9K0jcy5mrnfOEo_qLtlkSkBdCPs42IHtP8p8f9fYQ\",\"authorName\": \"Franchesca Gutierrez B\",\"comments\": [{\"userComment\": {\"text\": \"Muy mala se queda colgado cuando estás intentando acceder para hacer una venta o una compra y encima te lo cobran sin ni siquiera haber echo nada.\",\"lastModified\": {\"seconds\": \"1594816980\",\"nanos\": 631000000},\"starRating\": 1,\"reviewerLanguage\": \"es\",\"appVersionCode\": 2020052106,\"appVersionName\": \"6.4.1\"}}]} ]}';
            } else{
                HttpResponse resp = gForce.sendRequest(param);
                jsonResults = resp.getBody();
                st = resp.getStatus();
                system.debug('Resultado: '+jsonResults);
            }            
        }catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if(Test.isRunningTest() || oTraza != null){
            oTraza.CC_FechaFin__c = datetime.now();

            if(Test.isRunningTest() && jsonResults != null)
                oTraza.CC_MensajeSalida__c = String.valueOf(jsonResults);

            if(sDescError != ''){
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }
        }

		// Insertamos el detalle de las trazas
		insert oTraza;
        
        if(st == 'Unauthorized')
                return null;

        // Control si jsonResults es null no hacer nada, error comunicaciones
        if(jsonResults != ''){
            if(jsonResults.length()<5)
                return new List<CC_ST_AppReviews__c>();

            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResults);        
            Map<String,Object> nextPage = (Map<String, Object>)jsonMap.get('tokenPagination');

            List<Object> reviewsList = (List<Object>)jsonMap.get('reviews');
           // system.debug('Elementos de la lista: '+reviewsList.size());
			String appName = STConfig.App_Name__c;
            String title = STConfig.MasterLabel;
            String imgURL = STConfig.Imagen__c;
            //String accessToken = accToken;
            String editId;
            String editIdFlag = '';

            if(reviewsList != null && reviewsList.size()>0){
                for(integer i=0; i<reviewsList.size(); i++){
                    Map<String,Object> reviews = (Map<String,Object>)reviewsList[i];

                    String reviewId = (String)reviews.get('reviewId');


                    String authorName = (String)reviews.get('authorName');

                    if(authorName == '')
                        authorName = 'anonymous';

                    List<Object> commentsList = (List<Object>)reviews.get('comments');

                    if(commentsList.size()>0){
                        //ap.Page__c = String.valueOf(k);

//                        for(integer j=0; j<commentsList.size(); j++){
//                        //user comments only
                            Map<String,Object> comments = (Map<String,Object>)commentsList[0];

                                Map<String,Object> userComment = (Map<String,Object>)comments.get('userComment');

                                String userText = (String)userComment.get('text');
                        		userText=userText.trim();

                        		String ReviewTitle ='';
                        		if (userText.length()<100){
                                    ReviewTitle = userText.substring(0,userText.length()).trim();//arr[0];
                                } else{
                                    ReviewTitle = userText.substring(0,100).trim();//arr[0];
                                }
                                String[] arr = userText.split('\t');
                                Decimal rating = (Decimal)userComment.get('starRating');
                                
                                Map<String,Object> lastModified = (Map<String,Object>)userComment.get('lastModified');
                                String unixDatetime = (String)lastModified.get('seconds') + '000';

                                //comparar dt con la fecha actual que este dentro del valor que ellos definan
                                DateTime dt = datetime.newinstance(long.valueOf(unixDateTime));

                                String appVersionName = (String)userComment.get('appVersionName');
                                Decimal androidOsVersion = (Decimal)userComment.get('androidOsVersion');
                                String device = (String)userComment.get('device');
                                String manufacturer;
                                String productName;
                                String deviceClass;

                        		// Controlamos si existe deviceMetadata
                                if((Map<String,Object>)userComment.get('deviceMetadata') != null){
                                	Map<String,Object> deviceMetadata = (Map<String,Object>)userComment.get('deviceMetadata');
                        			manufacturer = (String)deviceMetadata.get('manufacturer');
                        			productName = (String)deviceMetadata.get('productName');
                        			String cpuMake = (String)deviceMetadata.get('cpuMake');
                                    deviceClass = (String)deviceMetadata.get('deviceClass');
                                }
								
                        		CC_ST_AppReviews__c ap = new CC_ST_AppReviews__c();
                                ap.CC_Actualizacion_Review__c = false;
                        		if(appMap.containsKey(reviewId)){
                                    //Controlamos si llega una actualización de un comentario ya existente
                                    if((appMapRating.get(reviewId)==String.valueOf(rating)) && (appMapReview.get(reviewId)==userText)) {
                                        flag = true;
                                        break;
                                    } else {
                                        //Marcamos actualizado para que no genere respuestas automaticas en caso de ser una actualizacion
                                        //de un comentario ya existente en la App
                                        //
                                        
                                        ap.CC_Actualizacion_Review__c = true;
                                    }
                                }

                                ap.Procesado__c=false;
                                ap.Case__c = null;
                                ap.Review_ID__c = reviewId;
                                ap.Author_Name__c = authorName;
                                ap.Source__c = 'Google Play Store';
                                //ap.App_Package_Name__c = appId;
                                ap.App_ID__c = appId;
                                ap.App__c = appName;
                                ap.App_Image__c = imgURL;
                                ap.Rating__c = String.valueOf(rating);
                                ap.Version__c = appVersionName;
                                ap.CC_Fabricante__c = manufacturer;
                        		ap.CC_Modelo__c = productName;
                                ap.CC_Tipo_Dispositivo__c = deviceClass;
                                ap.Fecha__c = dt;
                                ap.Content__c = userText;//arr[1];
                                ap.Title__c = ReviewTitle;//arr[0];
                                //si la review recibida desde el endpoint no se ha modificado o insertado hace mas de 10 dias, se descarta para procesarla internamente en salesforce
                                if(dt >= System.today().addDays(-10)){
                                    apList.add(ap);
                                }
                                
                                //apList.add(ap);
                                
                                //if(ap.Rating__c == '1' || ap.Rating__c == '2')
                                //{
                                //    revIdSet.add(ap.Review_ID__c);
                                //}
                    }
                }
                List<CC_ST_AppReviews__c> reverseAppList = new List<CC_ST_AppReviews__c>();
                if(apList.size()>0 && apList != null){
                    for(integer j=apList.size()-1; j>=0; j--){
                        reverseAppList.add(apList[j]);
                    }
                }
                /*
                if(editIdFlag == 'insert')
                    insert editIdTok;
                else if(editIdFlag == 'update')
                    update editIdTok;
                */
                
                upsert reverseAppList;
                if((reverseAppList.size()>0) && (crear_casos==true)){
                    CC_ST_ReviewsController.creacionMasivaCasos(reverseAppList, appId) ;
                }
            }   
        }
        return null;
    }
    
/*    @AuraEnabled
    public static void createCaseApex(String obj)
    {
        Map<String, Object> review = (Map<String, Object>)JSON.deserializeUntyped(obj);
        String reviewId = (String)review.get('ReviewId');
        String replyText = (String)review.get('DevComment');
        String content = (String)review.get('Content');
      
        CC_ST_AppReviews__c ap = [Select Id,Review_ID__c,Developer_Comment__c,Case__c from CC_ST_AppReviews__c where Review_ID__c=:reviewId];
        
        Case c = new Case();
        c.Subject = 'Play Store Review';
        c.Description = content;
        //c.Origin = 'Google Play Store';
        insert c;
        
        ap.Case__c = c.Id;
        update ap;
    }*/
    
    @future(callout=true)
    public static void replyReview(String packageName,String reviewId, String replyText){
        String jsonResults = '';
        // Ini trazas
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        
        CC_ST_AppReviews__c ap = [SELECT Id,Review_ID__c,Developer_Comment__c,Case__c,CC_Error_Publicacion__c
                                  FROM CC_ST_AppReviews__c where Review_ID__c=:reviewId order by CreatedDate desc LIMIT 1];
        
        // Gestión trazas.
        if (ap.Id != null || Test.isRunningTest()){
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'Google_Play_Reply';
            oTraza.CC_Identificador__c = ap.Id;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = ap.Id;
        }
        
        if(replyText != null && reviewId != null) {
            try {
                replyText=replyText.replace('"', '\'');
	            CC_ST_GoogleForce gForce = New CC_ST_GoogleForce('Google_CaixaBank');
                String endpoint1 = 'https://www.googleapis.com/androidpublisher/v3/applications/' + packageName + '/reviews/'+ reviewId+':reply';
                String jsonstr = '{"replyText": "'+replyText+'"}';
                
                Map<String, String> param = new Map<String, String>();
                param.put('method', 'POST');
                param.put('endpoint', endpoint1);
                param.put('body',jsonstr);
                oTraza.CC_MensajeEntrada__c = String.valueOf(param);
                
                HttpResponse resp = gForce.sendRequest(param);
                jsonResults = resp.getBody();
            } catch (Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }
            if(jsonResults.contains('lastEdited')) {
                ap.Developer_Comment__c = replyText;
                ap.CC_Error_Publicacion__c = false;
                if(ap.Case__c != null) {
                    //post the reply to case feed 
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                    feedItemInput.subjectId = ap.Case__c;
                    
                    ConnectApi.FeedItemVisibilityType feedVisibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                    feedItemInput.visibility = feedVisibility;

                    // The MessageBodyInput object holds the text in the post
                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                    
                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                    
                    //Contact contId = [select name,id from contact where id=:t.WhoId];
                    textSegmentInput = new ConnectApi.TextSegmentInput();
                    textSegmentInput.text = replyText; 
                    messageBodyInput.messageSegments.add(textSegmentInput);
                    
                    feedItemInput.body = messageBodyInput;
                    // Añade la respuesta al comentario de la app en un chatter feed
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                    //update ap;
                    //return true;
                }
                update ap;
                //return true;
            } else {
                ap.CC_Error_Publicacion__c = true;
                System.JSONParser parserSR = System.JSON.createParser(String.valueOf(jsonResults));
                while (parserSR.nextToken() != null){
                    if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'code')) {
                        // Get the value.
                        parserSR.nextToken();
                        // Compute the grand total price for all invoices.
                        sDescError = parserSR.getText();
                    }
                    if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'message')) {
                        // Get the value.
                        parserSR.nextToken();
                        // Compute the grand total price for all invoices.
                        sDetalleError = parserSR.getText();
                    }
                }
                update ap;
            }
            // Finalizar traza.
            if(Test.isRunningTest() || oTraza != null) {
                oTraza.CC_FechaFin__c = datetime.now();
    
                if(Test.isRunningTest() || jsonResults != null)
                    oTraza.CC_MensajeSalida__c = String.valueOf(jsonResults);
    
                if(sDescError != ''){
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = sDescError;
                    oTraza.CC_DetalleError__c = sDetalleError;
					// Crear Actividad Error Comentario en Google
                    Task createTask = new Task(
                        Type = 'Automática'
                        ,TaskSubtype = 'Task'
                        ,Subject = 'Fallo Publicación en Google' 
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = 'Se ha producido el siguiente error al intentar publicar el comentario: ' + String.valueOf(jsonResults)
                        ,WhatId = ap.Case__c
                        ,Priority = 'High'
                    );
                    //insert createTask;
                    CC_Activity.crearActividad(createTask);
                } else{
                    oTraza.CC_FinOK__c = true;
                }
            }
            // Insertamos el detalle de las trazas
            insert oTraza;
        }
        //return false;
    }

    public static SocialPost Respuesta_automatica(String Store, String ReviewId, Id CaseId,Id SocialPostId, String NombreCliente, String packageName, String idioma){        
        Integer randomNumber;
        String mensaje = '';
        //List<CC_Respuestas_Stores__mdt> STRespuestas = [SELECT Respuesta__c  FROM CC_Respuestas_Stores__mdt where idioma__c = :idioma ];
        SocialPost socPost = New SocialPost();

        List<CC_Respuestas_Stores__mdt> STRespuestas = new List<CC_Respuestas_Stores__mdt>();
        List<CC_Respuesta_CBK_Sign__mdt> STRespSign = new List<CC_Respuesta_CBK_Sign__mdt>();
        //Buscar respuestas en función de la aplicacion
        if (Store == 'CaixaBank Sign' || Store == 'ImaginBank' || Store == 'ImaginKids' || Store == 'ImaginTeens') { //CBK Sign, ImaginBank, ImaginTeens e ImaginKids
            STRespSign = [SELECT Respuesta__c  FROM CC_Respuesta_CBK_Sign__mdt where idioma__c = :idioma ];
            if (STRespSign.size()>0){
                //Respuesta aleatoria
                randomNumber = Integer.valueof((Math.random() * (STRespSign.size()-1)));
                mensaje = STRespSign[randomNumber].Respuesta__c;
                if (NombreCliente == null){
                    NombreCliente = '';
                }
                mensaje = mensaje.replace('##ClientName##', NombreCliente);

                socPost = CC_ST_ReviewsController.createSocialPost(ReviewId,
                                                                   CaseId,
                                                                   Store,
                                                                   mensaje,
                                                                   'Respuesta automática',
                                                                   'Reply',
                                                                   true,
                                                                   false);
                
                //Mirar custom metadata para ver si se puede realizar la llamada o no
                List<CC_Valores__mdt> permisoReply = [SELECT CC_Valor__c, CC_Activa__c FROM CC_Valores__mdt WHERE DeveloperName =: 'CC_replyStore'];
                if (permisoReply.size()>0){
                    if (permisoReply[0].CC_Activa__c == true && permisoReply[0].CC_Valor__c != 'N'){
                        CC_ST_PlayStoreReviewsCtrl.replyReviewAuto(packageName, ReviewId, mensaje);
                    }
                }
                
            }
        } else{ //CaixaBank, CaixaBank Pay y BrokerNow.
            STRespuestas = [SELECT Respuesta__c  FROM CC_Respuestas_Stores__mdt where idioma__c = :idioma ];
            if (STRespuestas.size()>0){
                //Respuesta aleatoria
                randomNumber = Integer.valueof((Math.random() * (STRespuestas.size()-1)));
                mensaje = STRespuestas[randomNumber].Respuesta__c;
                if (NombreCliente == null){
                    NombreCliente = '';
                }
                mensaje = mensaje.replace('##ClientName##', NombreCliente);

                socPost = CC_ST_ReviewsController.createSocialPost(ReviewId,
                                                                   CaseId,
                                                                   Store,
                                                                   mensaje,
                                                                   'Respuesta automática',
                                                                   'Reply',
                                                                   true,
                                                                   false);
                
                //Mirar custom metadata para ver si se puede realizar la llamada o no
                List<CC_Valores__mdt> permisoReply = [SELECT CC_Valor__c, CC_Activa__c FROM CC_Valores__mdt WHERE DeveloperName =: 'CC_replyStore'];
                if (permisoReply.size()>0){
                    if (permisoReply[0].CC_Activa__c == true && permisoReply[0].CC_Valor__c != 'N'){
                        CC_ST_PlayStoreReviewsCtrl.replyReviewAuto(packageName, ReviewId, mensaje);
                    }
                }
            }
        }
        if (mensaje == ''){
            system.debug('No hay respuestas automáticas');
        }
        /*if (STRespuestas.size()>0){
			//Respuesta aleatoria
            randomNumber = Integer.valueof((Math.random() * (STRespuestas.size()-1)));
            mensaje = STRespuestas[randomNumber].Respuesta__c;
            if (NombreCliente == null){
                NombreCliente = '';
            }
            mensaje = mensaje.replace('##ClientName##', NombreCliente);

            socPost = CC_ST_ReviewsController.createSocialPost(ReviewId,
                                                               CaseId,
                                                               Store,
                                                               mensaje,
                                                               'Respuesta automática',
                                                               'Reply',
                                                               true,
                                                               false);
        } else {
        }*/

        return socPost;
        
    }
    
    //@future(callout=true)
    public static void replyReviewAuto(String packageName,String reviewId, String replyText){
        String jsonResults = '';
        // Ini trazas
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        
        CC_ST_AppReviews__c ap = [SELECT Id,Review_ID__c,Developer_Comment__c,Case__c,CC_Error_Publicacion__c
                                  FROM CC_ST_AppReviews__c WHERE Review_ID__c=:reviewId order by CreatedDate desc LIMIT 1];
        
        // Gestión trazas.
        if (ap.Id != null || Test.isRunningTest()){
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'Google_Play_AutoReply';
            oTraza.CC_Identificador__c = ap.Id;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = ap.Id;
        }
        
        if(replyText != null && reviewId != null){
            try{
                replyText=replyText.replace('"', '\'');
                CC_ST_GoogleForce gForce = New CC_ST_GoogleForce('Google_CaixaBank');
                String endpoint1 = 'https://www.googleapis.com/androidpublisher/v3/applications/' + packageName + '/reviews/'+ reviewId+':reply';
                String jsonstr = '{"replyText": "'+replyText+'"}';
                
                Map<String, String> param = new Map<String, String>();
                param.put('method', 'POST');
                param.put('endpoint', endpoint1);
                param.put('body',jsonstr);
                oTraza.CC_MensajeEntrada__c = String.valueOf(param);
                
                HttpResponse resp = gForce.sendRequest(param);
                jsonResults = resp.getBody();
			} catch (Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }
            
            if(jsonResults.contains('lastEdited')){
                ap.Developer_Comment__c = replyText;
                ap.CC_Error_Publicacion__c = false;
                
                if(ap.Case__c != null){
                    //post the reply to case feed 
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                    feedItemInput.subjectId = ap.Case__c;
                    
                    ConnectApi.FeedItemVisibilityType feedVisibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                    feedItemInput.visibility = feedVisibility;

                    // The MessageBodyInput object holds the text in the post
                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

                    //Contact contId = [select name,id from contact where id=:t.WhoId];
                    textSegmentInput = new ConnectApi.TextSegmentInput();
                    textSegmentInput.text = replyText; 
                    messageBodyInput.messageSegments.add(textSegmentInput);
                    
                    feedItemInput.body = messageBodyInput;
                    // Añade la respuesta al comentario de la app en un chatter feed
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                    update ap;
                    //return true;
                }
                update ap;
                //return true;
            } else {
                ap.CC_Error_Publicacion__c = true;
                System.JSONParser parserSR = System.JSON.createParser(String.valueOf(jsonResults));
                while (parserSR.nextToken() != null){
                    if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'code')) {
                        // Get the value.
                        parserSR.nextToken();
                        // Compute the grand total price for all invoices.
                        sDescError = parserSR.getText();
                    }
                    if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'message')) {
                        // Get the value.
                        parserSR.nextToken();
                        // Compute the grand total price for all invoices.
                        sDetalleError = parserSR.getText();
                    }
                }
                update ap;
            }
            // Finalizar traza.
            if(Test.isRunningTest() || oTraza != null) {
                oTraza.CC_FechaFin__c = datetime.now();
    
                if(Test.isRunningTest() || jsonResults != null)
                    oTraza.CC_MensajeSalida__c = String.valueOf(jsonResults);
    
                if(sDescError != ''){
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = sDescError;
                    oTraza.CC_DetalleError__c = sDetalleError;
                    // Crear Actividad Error Comentario en Google
                    Task createTask = new Task(
                        Type = 'Automática'
                        ,TaskSubtype = 'Task'
                        ,Subject = 'Fallo Publicación en Google' 
                        ,ActivityDate = System.today()
                        ,Status = 'Completed'
                        ,Description = 'Se ha producido el siguiente error al intentar publicar el comentario automático: ' + String.valueOf(jsonResults)
                        ,WhatId = ap.Case__c
                        ,Priority = 'High'
                    );
                    //insert createTask;
                    CC_Activity.crearActividad(createTask);
                } else{
                    oTraza.CC_FinOK__c = true;
                }
            }
            // Insertamos el detalle de las trazas
            insert oTraza;
        }
        //return false;
    }
}