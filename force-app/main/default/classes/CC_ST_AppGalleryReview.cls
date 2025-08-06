public with sharing class CC_ST_AppGalleryReview {
    

    public class ResponseData {
        @AuraEnabled
		public List<CC_ST_AppReviews__c> lstReview;
        @AuraEnabled
		public CC_TrazaInt__c traza;	
	}

    /**
     * @description extraer comentarios de Huawei
     */
    @AuraEnabled
    public static ResponseData insertReviews(String appId, String countryCode, Boolean crearCasos, String token){
        
        List<CC_ST_AppReviews__c> reviewToUpsertList = new List<CC_ST_AppReviews__c>();
        CC_ST_AppGallery.Response result = new CC_ST_AppGallery.Response();
        ResponseData response = new ResponseData();
        CC_TrazaInt__c trazaToInsert = new CC_TrazaInt__c();

        try {        
            result = CC_ST_AppGallery.sendRequest(appId, countryCode, 'Huawei_Store', token);  
        }catch (Exception e) {
            // Error comunicaciones.
            result.errorCode = 'Error comunicaciones.';
            result.errorMessage = e.getMessage();
        }

        // Control si jsonResults es null no hacer nada, error comunicaciones
        if(result != null && result.review != null && result.review.data != null && result.review.data.reviewList != null){
            
            if(result.review.data.reviewList.size() == 0){
                return null;
            }

            String appName;
            String title;
            String imgURL;
        
            CC_ST_AppGallery.cls_reviewList[] reviewsList = result.review.data.reviewList;

            List<CC_Config_Stores__mdt>  lstConfig = [SELECT MasterLabel, Imagen__c, App_Name__c FROM CC_Config_Stores__mdt WHERE Identificador__c  = :appId WITH SECURITY_ENFORCED LIMIT 1];

            if(!lstConfig.isEmpty()){
                appName = lstConfig.get(0).App_Name__c;
                title = lstConfig.get(0).MasterLabel;
                imgURL = lstConfig.get(0).Imagen__c;
            }
            
            if(!reviewsList.isEmpty()){
                
                //Mapa de los comentarios previos de la appId
                Map<String, CC_ST_AppReviews__c> appMapIdReview = mapComentariosExistentes(appId);

                for(CC_ST_AppGallery.cls_reviewList review :reviewsList){

                    Boolean isSame = false;
                    String reviewId = (String)review.reviewId;
                    String comment = (String)review.content;
                    String reviewTitle ='';

                    if (comment.length()<100){
                        reviewTitle = comment.substring(0,comment.length()).trim();
                    } else{
                         reviewTitle = comment.substring(0,100).trim();
                    }

                    Decimal rating = (Decimal)review.rating;
                    String appVersionName = (String)review.apkVersion;

					CC_ST_AppReviews__c appReview = new CC_ST_AppReviews__c();
                    appReview.CC_Actualizacion_Review__c = false;
                    
                    if(appMapIdReview.containsKey(reviewId)){
                        //Controlamos si llega una actualización de un comentario ya existente
                        if(appMapIdReview.get(reviewId).Rating__c.equalsIgnoreCase(String.valueOf(rating)) && appMapIdReview.get(reviewId).Content__c.equalsIgnoreCase(comment)) {
                            isSame = true;
                        } else {
                            //Marcamos actualizado para que no genere respuestas automaticas en caso de ser una actualizacion
                            //de un comentario ya existente en la App
                            appReview.CC_Actualizacion_Review__c = true;
                        }
                    }

                    appReview.Procesado__c = false;
                    appReview.Case__c = null;
                    //appReview.Author_Name__c = authorName; NO VIENE DESDE LA RESPONSE DE HUAWEI
                    appReview.Review_ID__c = reviewId;
                    appReview.Source__c = 'Huawei App Store';
                    appReview.App_ID__c = appId;
                    appReview.App__c = appName;
                    appReview.App_Image__c = imgURL;
                    appReview.Rating__c = String.valueOf(rating);
                    appReview.Version__c = appVersionName;
                    appReview.Content__c = comment;
                    appReview.Title__c = reviewTitle;
                    if(!isSame){
                        reviewToUpsertList.add(appReview);
                    }
                }

                if(!reviewToUpsertList.isEmpty()){
                    // Make sure we can update the database before even trying
                    if (!Schema.sObjectType.CC_ST_AppReviews__c.fields.Source__c.isCreateable()) {
                        return null;
                    }
                    //Database.upsert(reviewToUpsertList);
                    if(crearCasos){
                        CC_ST_ReviewsController.creacionMasivaCasos(reviewToUpsertList, appId);
                    }
                }
            }   
        }else{
            // Error comunicaciones.
            result.errorCode = 'Error comunicaciones.';
            result.errorMessage = 'Response null';
        }
     
        // Gestión trazas.
        if (appId != null || Test.isRunningTest()){
            trazaToInsert = insertTrazaGet(appId, countryCode, result);
        }
        
        response.lstReview = reviewToUpsertList;
        response.traza = trazaToInsert;
        return response;
    }

    /**
     * @description Responder a un comentario de HUAWEI
     */
    @future(callout=true)
    public static void replyReview(String appId, String reviewId, String replyText){
        
        replyReviewAux(appId, reviewId, replyText);

    } 

    /**
     * @description Responder a un comentario de HUAWEI
     */
    public static void replyReviewAux(String appId, String reviewId, String replyText){
        
        CC_ST_AppGallery.ResponseReply result = new CC_ST_AppGallery.ResponseReply();

        CC_ST_AppReviews__c comentario = [SELECT Id,Review_ID__c,Developer_Comment__c,Case__c,CC_Error_Publicacion__c, CC_Idioma__c, Case__r.CC_Cierre_Automatico__c
                                            FROM CC_ST_AppReviews__c where Review_ID__c =: reviewId order by CreatedDate desc LIMIT 1];
        
        if(replyText != null && reviewId != null) {
            try {        
                result = CC_ST_AppGallery.sendRequestReply(appId, reviewId, replyText, comentario);  
            }catch (Exception e) {
                // Error comunicaciones.
                result.errorCode = 'Error comunicaciones.';
                result.errorMessage = e.getMessage();
            }
        }

        // Control si jsonResults es null no hacer nada, error comunicaciones
        if(result != null && result.statusCode != null && result.statusCode.equalsIgnoreCase('200')){

            comentario.Developer_Comment__c = replyText;
            if(result.estado == 'success'){
                comentario.CC_Error_Publicacion__c = false;
            }else{
                comentario.CC_Error_Publicacion__c = true;
            }
            

            if(comentario.Case__c != null && !Test.isRunningTest()) {

                // Añade la respuesta al comentario de la app en un chatter feed
                insertFeed(comentario.Case__c, replyText);
                     
            }

        }else{
            comentario.CC_Error_Publicacion__c = true;
 
        }
        
        Database.update(comentario);
        
        // Gestión trazas.
        if (appId != null || Test.isRunningTest()){
            insertTrazaReply(comentario, appId, result);
        }
        

    } 
    
    /**
    * @description Responder automáticamente a un comentario de HUAWEI
    */
   public static SocialPost respuetaAutomatica(String store, String reviewId, Id CaseId,Id SocialPostId, String NombreCliente, String appId, String idioma){        
       Integer randomNumber;
       String mensaje = '';

       List<CC_Respuestas_Stores__mdt> stRespuestas = new List<CC_Respuestas_Stores__mdt>();
       List<CC_Respuesta_CBK_Sign__mdt> stRespSign = new List<CC_Respuesta_CBK_Sign__mdt>();
       //Buscar respuestas en función de la aplicacion
       if (store == 'CaixaBank Sign' || store == 'ImaginBank' || store == 'ImaginKids' || store == 'ImaginTeens') { //CBK Sign, ImaginBank, ImaginTeens e ImaginKids
           stRespSign = [SELECT Respuesta__c  FROM CC_Respuesta_CBK_Sign__mdt where idioma__c = :idioma ];
           if (stRespSign.size()>0){
               //Respuesta aleatoria
               randomNumber = Integer.valueof((Math.random() * (stRespSign.size()-1)));
               mensaje = stRespSign[randomNumber].Respuesta__c;
           }
       }else{
           stRespuestas = [SELECT Respuesta__c  FROM CC_Respuestas_Stores__mdt where idioma__c = :idioma ];
           if (stRespuestas.size()>0){
               //Respuesta aleatoria
               randomNumber = Integer.valueof((Math.random() * (stRespuestas.size()-1)));
               mensaje = stRespuestas[randomNumber].Respuesta__c;
            }
       }

       if (NombreCliente == null){
           NombreCliente = '';
       }
       mensaje = mensaje.replace('##ClientName##', NombreCliente);
       
       SocialPost socPost = CC_ST_ReviewsController.createSocialPost(reviewId,
                                                                        CaseId,
                                                                        store,
                                                                        mensaje,
                                                                        'Respuesta automática',
                                                                        'Reply',
                                                                        true,
                                                                        false);
               
       //Mirar custom metadata para ver si se puede realizar la llamada o no
       List<CC_Valores__mdt> permisoReply = [SELECT CC_Valor__c, CC_Activa__c FROM CC_Valores__mdt WHERE DeveloperName =: 'CC_replyStore'];
       if (permisoReply.size()>0){
            if (permisoReply[0].CC_Activa__c == true && permisoReply[0].CC_Valor__c != 'N'){
                replyReviewAux(appId, reviewId, mensaje);
            }
       }
       
       return socPost;
       
   }


    /**
     * @description Insertar la traza de la llamada
     */
    private static CC_TrazaInt__c insertTrazaGet(String appId, String countryCode, CC_ST_AppGallery.Response result){
        
        // Gestión trazas.
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
        oTraza.Name = 'Huawei_Store';
        oTraza.CC_Identificador__c = appId;
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_IdOrigen__c = countryCode;
        // Traza de la entrada de la conexión            
        oTraza.CC_MensajeEntrada__c = result.endpoint;

        // Finalizar traza.
        oTraza.CC_FechaFin__c = datetime.now();
        if(result.statusCode.equalsIgnoreCase('200') && result.review != null){
            oTraza.CC_MensajeSalida__c = String.valueOf(result.review);
        }

        if(result.errorCode != ''){
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = result.errorCode;
            oTraza.CC_DetalleError__c = result.errorMessage;
        }else{
            oTraza.CC_FinOK__c = true;
        }

        // Insertamos el detalle de las trazas
        if (!Schema.sObjectType.CC_TrazaInt__c.fields.Name.isCreateable()) {
            return null;
        }
        return oTraza;
    }

    /**
     * @description Insertar la traza de la llamada
     */
    private static void insertTrazaReply(CC_ST_AppReviews__c comentario, String appId, CC_ST_AppGallery.ResponseReply result){
        
        // Gestión trazas.
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
        oTraza.Name = 'Huawei_Store';
        oTraza.CC_Identificador__c = comentario.Id;
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_IdOrigen__c = comentario.Id;
        // Traza de la entrada de la conexión            
        oTraza.CC_MensajeEntrada__c = result.msjEntrada;

        // Finalizar traza.
        oTraza.CC_FechaFin__c = datetime.now();
        if(result != null && result.statusCode != null && result.statusCode.equalsIgnoreCase('200')){
            oTraza.CC_MensajeSalida__c = String.valueOf(result.estado);
        }
        
        if(result.errorCode != '' && result.errorCode != null){
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = result.errorCode;
            oTraza.CC_DetalleError__c = result.errorMessage;
            insertTask(comentario, result.errorMessage);
        }else{
            oTraza.CC_FinOK__c = true;
        }

        // Insertamos el detalle de las trazas
        if (!Schema.sObjectType.CC_TrazaInt__c.fields.Name.isCreateable()) {
            return;
        }
        Database.insert(oTraza);
    }


    /**
     * @description Búsqueda de comentarios existentes
     */
    private static Map<String, CC_ST_AppReviews__c> mapComentariosExistentes(String appId){
        
        Map<String, CC_ST_AppReviews__c> appMapIdReview = new Map<String, CC_ST_AppReviews__c>();
        //Buscamos si ya existe el comentario y es una actualización lo que recibimos
        List<CC_ST_AppReviews__c> reviewList = [SELECT Id, Name, Review_ID__c, Rating__c, Content__c, Fecha__c 
                                                FROM CC_ST_AppReviews__c 
                                                WHERE Source__c = 'Huawei App Store' and App_Id__c = :appId 
                                                order by CreatedDate desc LIMIT 10000]; 

        //Controlamos si llega una actualización de un comentario ya existente
        for(CC_ST_AppReviews__c app :reviewList){
            if (!appMapIdReview.containsKey(app.Review_ID__c)){
                appMapIdReview.put(app.Review_ID__c, app);
            }
        }

        return appMapIdReview;
    }

     /**
     * @description Insertar la app en un chatter feed
     */
    private static void insertFeed(String caseComment, String replyText){
        
        //post the reply to case feed 
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.subjectId = caseComment;
        
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

    }


     /**
     * @description Crear Actividad Error Comentario en Huawei
     */
    @TestVisible
    private static void insertTask(CC_ST_AppReviews__c comentario, String errorMessage){
        //
        Task createTask = new Task();
        createTask.Type = 'Automática';
        createTask.TaskSubtype = 'Task';
        createTask.Subject = 'Fallo Publicación en Huawei';
        createTask.ActivityDate = System.today();
        createTask.Status = 'Completed';
        if(comentario.Case__r.CC_Cierre_Automatico__c){
            createTask.Description = 'Se ha producido el siguiente error al intentar publicar el comentario automático: ' + errorMessage;
        }else{
            createTask.Description = 'Se ha producido el siguiente error al intentar publicar el comentario: ' + errorMessage;
        }
        createTask.WhatId = comentario.Case__c;
        createTask.Priority = 'High';

        CC_Activity.crearActividad(createTask);

    }
    
}