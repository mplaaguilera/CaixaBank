global class CC_ST_ReviewsHuaweiBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global CC_ST_ReviewsHuaweiBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
		String query = 'Select DeveloperName, Identificador__c, countryCode__c, Tipo__c from CC_Config_Stores__mdt where Activo__c = true and Tipo__c = \'Huawei Store\' ' +(Test.isRunningTest()?' LIMIT 200':'');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CC_Config_Stores__mdt> scope) {
        
        List<CC_Config_Stores__mdt> lstConfHuawei = new List<CC_Config_Stores__mdt>();
        CC_ST_AppGalleryReview.ResponseData responseHuawei = new CC_ST_AppGalleryReview.ResponseData();
        List<CC_ST_AppReviews__c> lstReviewUpsert = new List<CC_ST_AppReviews__c>();
        Set<Id> setReviewIdUpsert = new Set<Id>();
        List<CC_TrazaInt__c> lstTraza = new List<CC_TrazaInt__c>();
        CC_ST_AppGallery.TokenObject tokenObject = new CC_ST_AppGallery.TokenObject();
        //Ejecución solo si no hay instancias de los JOBS siguientes para asegurar la secuencialidad en el Framework de Batch Apex
        list<AsyncApexJob> lstAsyncApexJob = [SELECT Id, ApexClass.Name 
                                              	FROM AsyncApexJob 
                                               WHERE status not in ('Aborted','Completed','Failed') and JobType='BatchApex'
                                                AND ApexClass.Name in ('CC_ST_ReviewsDetidi_Batch','CC_ST_ReviewsCaseBatch','CC_ST_ReviewsAutoMessageBatch')];
        

        //PARA HUAWEI
        if(!scope.isEmpty()){

            List<CC_App_Gallery_Token__mdt> lstAppQueryResult = [SELECT Id, CC_Endpoint__c, CC_Client_Id__c, CC_Client_Secret__c
                                                            FROM CC_App_Gallery_Token__mdt
                                                            WHERE MasterLabel = 'Huawei_Store' WITH SECURITY_ENFORCED
                                                            LIMIT 1];
            if(!lstAppQueryResult.isEmpty()){
                CC_App_Gallery_Token__mdt appQueryResult = lstAppQueryResult.get(0);
                //Calculo token
                tokenObject = CC_ST_AppGallery.getAccessToken(appQueryResult);
                //Llama a los comentarios
                for (CC_Config_Stores__mdt store : scope) {
                    if(Test.isRunningTest()){
                        responseHuawei.lstReview = [Select id from CC_ST_AppReviews__c];   	 
                    }else{
                        responseHuawei = CC_ST_AppGalleryReview.insertReviews(store.Identificador__c,store.countryCode__c,false, tokenObject.token);  
                    }
                    if(responseHuawei != null){
                        if(!responseHuawei.lstReview.isEmpty()){
                            for(CC_ST_AppReviews__c review :responseHuawei.lstReview){
                                if(!setReviewIdUpsert.contains(review.Id)){
                                    setReviewIdUpsert.add(review.Id);
                                	lstReviewUpsert.add(review);      
                                }
                            }  
                        }

                        if(responseHuawei.traza != null){
                            lstTraza.add(responseHuawei.traza);   
                        }
                    }
                }
            }
            
        }

        if(tokenObject.hasUpdate){
            Database.upsert(tokenObject.objectToken);
        }
        
        if(!lstReviewUpsert.isEmpty()){
            Database.upsert(lstReviewUpsert);
        }
        if(!lstTraza.isEmpty()){
            Database.insert(lstTraza);   
        }

    }

    global void finish(Database.BatchableContext bc) {
        List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_ST_ReviewsDetidi_Batch' and Activo__c=true LIMIT 1];
        if (!oConf.isEmpty() && !Test.isRunningTest()){
            CC_ST_ReviewsDetidi_Batch batch = new CC_ST_ReviewsDetidi_Batch();
            Database.executeBatch(batch,(Test.isRunningTest()?1:50));
        }         
    }
}