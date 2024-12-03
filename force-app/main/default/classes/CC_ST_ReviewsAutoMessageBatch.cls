global class CC_ST_ReviewsAutoMessageBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id, CC_Primer_DM_Enviado__c, App_Reviews__c FROM CASE WHERE CC_Cierre_Automatico__c = true and CC_Control_ComApps__c = false and CC_Primer_DM_Enviado__c = false order by CreatedDate desc LIMIT 1';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        Set<Id> setIdsCasos = new Set<Id>();
        List<SocialPost> lstSocialPostUpdate = new List<SocialPost>();
        List<Case> lstCasosUpdate = new List<Case>();
        
        for (Case caso : scope) {
            setIdsCasos.add(caso.Id);
        }
        
        if (!setIdsCasos.isEmpty()) {
            Map<Id, CC_ST_AppReviews__c> mapReviews = new Map<Id, CC_ST_AppReviews__c>([SELECT Source__c, App__c, Id, case__c, case__r.CreatedDate, SocialPost__c, Author_Name__c, App_Id__c, CC_Idioma__c, Review_ID__c FROM CC_ST_AppReviews__c WHERE case__c IN :setIdsCasos ORDER BY CreatedDate DESC]);
        
            for(Case cs : scope){
                
                try{
                    SocialPost socPost = new SocialPost(); /*?*/
                    if (!mapReviews.isEmpty()) {
                        if (mapReviews.get(cs.App_Reviews__c).Source__c == 'Huawei App Store') {
                            socPost = CC_ST_AppGalleryReview.respuetaAutomatica(
                                mapReviews.get(cs.App_Reviews__c).App__c,
                                mapReviews.get(cs.App_Reviews__c).Review_ID__c,
                                mapReviews.get(cs.App_Reviews__c).case__c,
                                mapReviews.get(cs.App_Reviews__c).SocialPost__c,
                                mapReviews.get(cs.App_Reviews__c).Author_Name__c,
                                mapReviews.get(cs.App_Reviews__c).App_Id__c,
                                mapReviews.get(cs.App_Reviews__c).CC_Idioma__c
                            );
                        } else {
                            socPost = CC_ST_PlayStoreReviewsCtrl.Respuesta_automatica(
                                mapReviews.get(cs.App_Reviews__c).App__c,
                                mapReviews.get(cs.App_Reviews__c).Review_ID__c,
                                mapReviews.get(cs.App_Reviews__c).case__c,
                                mapReviews.get(cs.App_Reviews__c).SocialPost__c,
                                mapReviews.get(cs.App_Reviews__c).Author_Name__c,
                                mapReviews.get(cs.App_Reviews__c).App_Id__c,
                                mapReviews.get(cs.App_Reviews__c).CC_Idioma__c
                            );
                        }

                        lstSocialPostUpdate.add(socPost);
                        
                        Case nuevoCaso = new Case();
                        nuevoCaso.Id = cs.Id;
                        nuevoCaso.CC_Admin__c = true;
                        nuevoCaso.CC_Primer_DM_Enviado__c = true;                
                        nuevoCaso.CC_Fecha_Respuesta_Stores__c = mapReviews.get(cs.App_Reviews__c).case__r.CreatedDate;
                        lstCasosUpdate.add(nuevoCaso);
                    }
                } catch (Exception e) {
                    Case nuevoCaso = new Case();
                    nuevoCaso.Id = cs.Id;
                    nuevoCaso.CC_Admin__c = true;
                    nuevoCaso.CC_Primer_DM_Enviado__c = true;                
                    nuevoCaso.CC_Fecha_Respuesta_Stores__c = Datetime.valueOf(System.now());
                    lstCasosUpdate.add(nuevoCaso);
                }
            }
        }
        if (!lstSocialPostUpdate.isEmpty()) {
            Database.update(lstSocialPostUpdate,false);
        }
        if (!lstCasosUpdate.isEmpty()) {
            Database.update(lstCasosUpdate,false);
        }

    }

    global void finish(Database.BatchableContext bc) {
        //CC_ST_ReviewsBatch batch = new CC_ST_ReviewsBatch();
		//Database.executeBatch(batch,1);
		List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_ST_ReviewsBatch' and Activo__c=false LIMIT 1];
        String scheduleName = 'Carga Comentarios APPs ';
        String dt = DateTime.now().addMinutes(5).format('s m H d M ? y');
        String CRON_EXP = string.valueOf(dt);
        if (oConf.isEmpty()){
			//Replanificación desde el Framework            
        } else {
            if(!Test.isRunningTest()){
                CC_ST_ReviewsBatch_Schedule newJob = new CC_ST_ReviewsBatch_Schedule();
                System.schedule(scheduleName + dt, CRON_EXP, newJob);        
            }
        }
    }
}