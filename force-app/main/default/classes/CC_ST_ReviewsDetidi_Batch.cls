global class CC_ST_ReviewsDetidi_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global CC_ST_ReviewsDetidi_Batch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
		String query = 'Select Id,Title__c,Content__c,Review_ID__c,Rating__c,App__c,App_ID__c,Case__c,Author_Name__c,SocialPost__c,Source__c,CC_Actualizacion_Review__c,CC_Idioma__c from CC_ST_AppReviews__c where Case__c = null and procesado__c=false' +(Test.isRunningTest()?' LIMIT 200':'');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CC_ST_AppReviews__c> scope) {
        List<Id> oListRevApp = new List<Id>();
        for (CC_ST_AppReviews__c Review : scope) {
			oListRevApp.add(Review.Id);
        }
        //Detector idioma 2 inputs: Listado de Id's, string para saber la entidad a actualizar
        CC_Detector_Idioma.getIdioma(oListRevApp, 'App Review');
    }

    global void finish(Database.BatchableContext bc) {
        
        List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_ST_ReviewsCaseBatch' and Activo__c=true LIMIT 1];
        if (oConf.isEmpty()){
            //Planificación desde el framework
            //CBK_BatchJob.executeBatch('CC_ST_ReviewsCaseBatch',(Test.isRunningTest()?1:50),1);
        } else {
            CC_ST_ReviewsCaseBatch batch = new CC_ST_ReviewsCaseBatch();
            Database.executeBatch(batch,(Test.isRunningTest()?1:50));
        }    
        
        
        /*if(Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }else{
            Database.executeBatch(batch,50);
        }*/        
        
    }
}