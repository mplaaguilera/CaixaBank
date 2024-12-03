global class CC_SocialPostReclBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global CC_SocialPostReclBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, ParentId, Posted, CC_ReclamacionActiva__c, CC_Respuesta_Reclamada__c FROM SocialPost WHERE Provider = \'Twitter\' AND CC_ReclamacionActiva__c = true AND IsOutbound = true AND CC_Solicitud_Informacion__c = true ORDER BY Posted ASC' + (Test.isRunningTest()?' LIMIT 1':' ') ;
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SocialPost> scope) {
        
        // Control que exista un registro por procesar.
        if (scope == null)
        {
            return;
        }

        if (scope.isEmpty())
        {
            return;
        }

		List<ID> oPostReclamar = new List<ID>();
		for (SocialPost oPost : scope)
        {
            Long dt1Long = oPost.Posted.getTime();
            Long dt2Long = DateTime.now().getTime();
            if (dt2Long > dt1Long)
            {
                Long diferencia = (dt2Long-dt1Long) / 1000 / 60 / 60;
                if (diferencia >= 24 && !oPost.CC_Respuesta_Reclamada__c)
                {
                    // Primera reclamación.
                    oPostReclamar.add(oPost.Id);
                }
                
                if (diferencia >= 48 && oPost.CC_Respuesta_Reclamada__c)
                {
                    // Segunda reclamación.
                    oPostReclamar.add(oPost.Id);
                }
            }
        }
        
        if (!oPostReclamar.isEmpty())
        {
            CC_SocialPost_Respuestas.CC_SocialPost_Reclamacion_Respuesta(oPostReclamar);
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
            //Si el metadato está activo o no hay registro se planifica con el framework
        	List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_SocialPostReclBatch' and Activo__c=true LIMIT 1];
  			String dt = DateTime.now().addMinutes(30).format('s m H d M ? y');
            String CRON_EXP = string.valueOf(dt);
        	if (oConf.isEmpty()){
                //La replanificación se realiza desde el framework
            } else {
                //if(!Test.isRunningTest())
                //{
                    CC_SocialPostReclScheduled newJob = new CC_SocialPostReclScheduled();
                    System.schedule('CC_SocialPostReclScheduled' + dt, CRON_EXP, newJob);
                //}      
            }                      
    }
}