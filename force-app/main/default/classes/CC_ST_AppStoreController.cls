public class CC_ST_AppStoreController {

    @AuraEnabled
    public static List<CC_ST_AppReviews__c> insertReviews(String appId, String countryCode,boolean crear_casos){
        // Ini trazas
        List<CC_TrazaInt__c> oListTraza = new List<CC_TrazaInt__c>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        
        String result= '';
        List<CC_ST_AppReviews__c> reverseAppList = new List<CC_ST_AppReviews__c>();
        List<CC_ST_AppReviews__c> appRevList = [Select Id,Name,Review_ID__c from CC_ST_AppReviews__c where App_ID__c=:appId and createdDate = LAST_90_DAYS  order by createdDate desc];
        Map<String,Id> appMap = new Map<String,Id>();
        for (CC_ST_AppReviews__c item : appRevList){
            appMap.put(item.Review_ID__c,item.Id);
        }
		
        CC_Config_Stores__mdt  STConfig = [SELECT MasterLabel,Imagen__c,App_Name__c FROM CC_Config_Stores__mdt 
                                           WHERE Identificador__c  =:appId LIMIT 1];
        
        String jsonResultsApp = '';
        Boolean flag = false;
        String imageURL;
		String appName = STConfig.App_Name__c;
        
        // Gestión traza conexión principal.
        if (appId != null || Test.isRunningTest()){
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'Apple_Store';
            oTraza.CC_Identificador__c = appId;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = countryCode;
        }
        imageURL = STConfig.Imagen__c;
		/**
 		try {        
            //Datos de la App
            HttpRequest reqApp = new HttpRequest();
            Http httpApp = new Http();
            string urlApp = 'https://itunes.apple.com/lookup?id='+appId+'';
            reqApp.setMethod('GET');            
            reqApp.setEndPoint(urlApp);            
            HTTPResponse respApp = httpApp.send(reqApp);
            // Traza entrada
            oTraza.CC_MensajeEntrada__c = String.valueOf(reqApp);
            
            jsonResultsApp = respApp.getBody();
            String stApp = respApp.getStatus();
            Map<String, Object> jsonMapApp = (Map<String, Object>)JSON.deserializeUntyped(jsonResultsApp);
            List<Object> resultsList = (List<Object>) jsonMapApp.get('results');
            Map<String,Object> resultApp = (Map<String,Object>)resultsList[0];
            
            imageURL = (String)resultApp.get('artworkUrl60');
            //appName = (String)resultApp.get('trackName');
        } catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }
         */
        // Finalizar traza principal.
        if (Test.isRunningTest() || oTraza != null){
            oTraza.CC_FechaFin__c = datetime.now();
            
            if (Test.isRunningTest() && jsonResultsApp != null)
                oTraza.CC_MensajeSalida__c = String.valueOf(jsonResultsApp);
            
            if (sDescError != ''){
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }
            oListTraza.add(oTraza);
        }
        
        //reducción de 10 a 2 páginas
        for(integer k=1; k<=2; k++){
            List<CC_ST_AppReviews__c> apList = new List<CC_ST_AppReviews__c>();
            String jsonResults = '';
            CC_TrazaInt__c oTraza2;
            // Gestión traza conexión paginada.
            if (appId != null || Test.isRunningTest()){
                oTraza2 = new CC_TrazaInt__c();
                oTraza2.Name = 'Apple_Store_Pag_'+k;
                oTraza2.CC_Identificador__c = appId;
                oTraza2.CC_FechaInicio__c = datetime.now();
                oTraza2.CC_IdOrigen__c = countryCode;
            }
            
            try{
				HttpRequest req = new HttpRequest();
                Http http = new Http();
                string url = 'https://itunes.apple.com/rss/customerreviews/page='+k+'/id='+appId+'/sortby=mostrecent/json?cc='+countryCode+'';
                
                req.setMethod('GET');            
                req.setEndPoint(url);            
                // Traza entrada
            	oTraza2.CC_MensajeEntrada__c = String.valueOf(req);
                
                HTTPResponse resp = http.send(req);            
                jsonResults = resp.getBody();
                //system.debug('Espe: '+jsonResults);
                String st = resp.getStatus(); 
            } catch (Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }
            
            // Finalizar traza conexión paginada.
            if (Test.isRunningTest() || oTraza2 != null){
                oTraza2.CC_FechaFin__c = datetime.now();
                
                if (Test.isRunningTest() && jsonResults != null)
                    oTraza2.CC_MensajeSalida__c = String.valueOf(jsonResults);
                
                if (sDescError != ''){
                    oTraza2.CC_FinOK__c = false;
                    oTraza2.CC_TipoError__c = sDescError;
                    oTraza2.CC_DetalleError__c = sDetalleError;
                }else{
                    oTraza2.CC_FinOK__c = true;
                }
                oListTraza.add(oTraza2);
            }
            
            // Control si jsonResults no es null
            if(jsonResults != ''){
				if(k == 1)
                	result = jsonResults;

                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResults);
                Map<String,Object> feed = (Map<String,Object>)jsonMap.get('feed');
                
                List<Object> entryList = (List<Object>)feed.get('entry');
                if(entryList != null && entryList.size()>0){
                    Map<String,Object> entry = (Map<String,Object>)entryList[0];
                    
                    for(integer i=0; i<entryList.size(); i++){
                        Map<String,Object> entries = (Map<String,Object>)entryList[i];
                        
                        Map<String,Object> author = (Map<String,Object>)entries.get('author');
                        Map<String,Object> authorNameLabel = (Map<String,Object>)author.get('name');
                        String authorName = (String)authorNameLabel.get('label');
                        
                        Map<String,Object> ratingLabel = (Map<String,Object>)entries.get('im:rating');
                        String rating = (String)ratingLabel.get('label');
                        
                        Map<String,Object> versionLabel = (Map<String,Object>)entries.get('im:version');
                        String version = (String)versionLabel.get('label');
                        
                        Map<String,Object> revIdLabel = (Map<String,Object>)entries.get('id');
                        String revId = (String)revIdLabel.get('label');
                        
                        Map<String,Object> titleLabel = (Map<String,Object>)entries.get('title');
                        String title = (String)titleLabel.get('label');
                        
                        Map<String,Object> contentLabel = (Map<String,Object>)entries.get('content');
                        String content = (String)contentLabel.get('label');
    
                        //Map<String,Object> contentfecha = (Map<String,Object>)entries.get('updated');
                        //String fecha = (String)contentfecha.get('label');
                        
                        if(appMap.containsKey(revId)){
                            flag = true;
                            break;
                        }
                        CC_ST_AppReviews__c ap = new CC_ST_AppReviews__c();
                        ap.Review_ID__c = revId;
                        ap.Author_Name__c = authorName;
                        ap.Rating__c = rating;
                        ap.Version__c = version;
                        ap.Content__c = content;
                        ap.Title__c = title;
                        ap.App__c = appName;
                        ap.Page__c = String.valueOf(k);
                        ap.App_Image__c = imageURL;
                        ap.Source__c = 'Apple App Store';
                        ap.App_ID__c = appId;
                        ap.Country_Code__c = countryCode;
                        //ap.fecha__c = format_fecha_Appstore(fecha);
                        ap.fecha__c = system.now();
                        apList.add(ap);
                    }
                    // reversing apList to insert reviews in desc order
                    if(apList.size()>0 && apList != null){
                        for(integer j=apList.size()-1; j>=0; j--){
                            if(appMap.containskey(apList[j].Review_Id__c)){
                                system.debug(apList[j].Review_Id__c + ' duplicado');
                            } else{
                                reverseAppList.add(apList[j]);
                                appMap.put(apList[j].Review_ID__c, apList[j].Id);
                            }
                        }
                    }
                }
            }
            
            if(flag == true){
                break;
            }
            //return jsonResults;
        }        
        //insert reverseAppList;
        if (!reverseAppList.isEmpty()){
            Database.SaveResult[] oReverseAppList = Database.insert(reverseAppList, false);
        }
        
        // Insert de las trazas
        insert oListTraza;
        //system.debug('Espe Comentarios Size: '+reverseAppList.size());
        //system.debug('Espe Comentarios: '+reverseAppList);
        if((reverseAppList.size()>0) && (crear_casos==true)){
            CC_ST_ReviewsController.creacionMasivaCasos(reverseAppList, appId) ;
        }
        return null;
    }
    
    public static datetime format_fecha_Appstore(string fecha) {
		//2015-02-10T04:53:16-07:00
     	return Date.today();
    }
}