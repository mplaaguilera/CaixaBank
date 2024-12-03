global class CC_ST_ReviewsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global CC_ST_ReviewsBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
		String query = 'Select DeveloperName, Identificador__c, countryCode__c, Tipo__c from CC_Config_Stores__mdt where Activo__c = true' +(Test.isRunningTest()?' LIMIT 200':'');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CC_Config_Stores__mdt> scope) {
        
        List<CC_Config_Stores__mdt> lstConfHuawei = new List<CC_Config_Stores__mdt>();
        CC_ST_AppGalleryReview.ResponseData responseHuawei = new CC_ST_AppGalleryReview.ResponseData();
        List<CC_ST_AppReviews__c> lstReviewUpsert = new List<CC_ST_AppReviews__c>();
        List<CC_TrazaInt__c> lstTraza = new List<CC_TrazaInt__c>();
        //Ejecución solo si no hay instancias de los JOBS siguientes para asegurar la secuencialidad en el Framework de Batch Apex
        list<AsyncApexJob> lstAsyncApexJob = [SELECT Id, ApexClass.Name 
                                              	FROM AsyncApexJob 
                                               WHERE status not in ('Aborted','Completed','Failed') and JobType='BatchApex'
                                                AND ApexClass.Name in ('CC_ST_ReviewsHuaweiBatch', 'CC_ST_ReviewsDetidi_Batch','CC_ST_ReviewsCaseBatch','CC_ST_ReviewsAutoMessageBatch')];
        
        
        for (CC_Config_Stores__mdt store : scope) {
            if (store.Tipo__c == 'Apple Store' && !Test.isRunningTest()){
                CC_ST_AppStoreController.insertReviews(store.Identificador__c,store.countryCode__c,false);    
            } else if(store.Tipo__c == 'Google Play' && !Test.isRunningTest()){
                CC_ST_PlayStoreReviewsCtrl.insertReviews(store.Identificador__c,store.countryCode__c,false);  
            } 
        }
 

    }

    global void finish(Database.BatchableContext bc) {
        List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_ST_ReviewsHuaweiBatch' and Activo__c=true LIMIT 1];
        if (!oConf.isEmpty() && !Test.isRunningTest()){
            CC_ST_ReviewsHuaweiBatch batch = new CC_ST_ReviewsHuaweiBatch();
            Database.executeBatch(batch,(Test.isRunningTest()?1:50));
        }    
       
    }
}