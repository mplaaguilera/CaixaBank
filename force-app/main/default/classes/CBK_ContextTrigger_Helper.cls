public without Sharing class CBK_ContextTrigger_Helper {
   
    /**
     * @description Helper para triggers de eventos de FWK Batch
     * @param batchJob  : Id del Batch planificable
     */
    public static void procesaBatchApex(list<String> lstJobs){      
        
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Async_Apex_Job').getRecordTypeId();
        list<Id> lstJobId = New list<Id>();    
        Map<Id,String> mapStatus = New Map<Id,String>();
        list<CBK_Log__c> lstDetail = New list<CBK_Log__c>();
        list<CBK_Framework_Batch__c> lstJobDef = [select Id,Name,status__c,Class_Name__c,batchSize__c,params__c,tipo__c,priority__c,proyecto__c,NextExec__c, Activo__c,
                                                           Email_Notif__c, Notif__c,RunningJobId__c,dependencia__r.Name,JobPath__c
                                                        from CBK_Framework_Batch__c 
                                                       where id in :lstJobs
                                                       LIMIT 20];
        Id batchprocessid;
        for (CBK_Framework_Batch__c jobDef : lstJobDef) {
            try {
                cbk_log.debug(jobDef.name);
                map<String,Object> params = New map<String,Object>();
                if(jobDef.params__c!=null){        
                    params = (Map<String, Object>)JSON.deserializeUntyped(jobDef.params__c);
                }
                
                batchprocessid = CBK_BatchJob.runBatch(jobDef.Class_Name__c, (integer)jobDef.batchSize__c, params);
                lstJobId.add(batchprocessid);
                jobDef.RunningJobId__c=batchprocessid; 
                
                if (jobDef.NextExec__c==null) {
                    jobDef.NextExec__c=DateTime.now();
                }
            } catch (Exception e) {
                CBK_BatchJob_Helper.errorJob(e, jobDef);                
                CBK_Log__c detail = New CBK_Log__c ();    
                detail.recordtypeId = recordTypeId;
                detail.FwkJobId__c = jobDef.Id;
                detail.Apex_Class__c=jobDef.Class_Name__c;
                detail.state__c = 'Error';
                detail.batchSize__c=jobDef.BatchSize__c;
                detail.params__c = jobDef.params__c;
                detail.jobType__c = jobDef.tipo__c;
                detail.priority__c = jobDef.priority__c;
                detail.project__c = jobDef.proyecto__c;
                detail.Log_Message__c = e.getMessage()?.left(2000);
                detail.createdDate__c = System.now();
                detail.systemModstamp__c = System.now();
                lstDetail.add(detail);
                
                if(jobDef.Tipo__c=='Puntual'){ 
                    jobDef.NextExec__c=null;
                    jobDef.status__c='Error';
                }
            }
        }
        
        list<AsyncApexJob> lstStatus = [SELECT Id, Status FROM AsyncApexJob WHERE ID =: lstJobId];
            
        for (AsyncApexJob iStatus : lstStatus){
            mapStatus.put(iStatus.Id,iStatus.Status);
        }
        
        for (CBK_Framework_Batch__c jobDef : lstJobDef) {
            if (jobDef.RunningJobId__c!=null){
                jobDef.status__c=mapStatus.get(jobDef.RunningJobId__c);     
            }
        }
        database.update(lstJobDef,false);
        database.insert(lstDetail,false);
    }
    /**
     * @description Helper para triggers de eventos de FWK de Schedulables Process
     * @param lstJobs  : List Ids del procesos Schedulable
     */
    public static void procesaSchedProc(list<String> lstJobs){  
        system.debug('ENTRA procesaSchedProc: ' + lstJobs);
        string DISPACHER_SCH = 'CBK_ScheduleProcess_Dispacher';
        
        List<CBK_SCH_PendingProcess__c> lstPP = [SELECT Id, ClassName__c, Type__c, RecordId__c, Param1__c, Param2__c, Check__c, Retries__c, Schedule_Time__c, QueuedDate__c,UsuarioContexto__c,CBK_ParamTextArea__c FROM CBK_SCH_PendingProcess__c
		                                         WHERE Id in :lstJobs];

        Map<String, List<CBK_SCH_PendingProcess__c>> mapPendingProcess = new Map<String, List<CBK_SCH_PendingProcess__c>> ();

        for (CBK_SCH_PendingProcess__c pp : lstPP){           
            if (!mapPendingProcess.containsKey(pp.ClassName__c)){
                mapPendingProcess.put(pp.ClassName__c, new List<CBK_SCH_PendingProcess__c> { pp });
            }else {
                mapPendingProcess.get(pp.ClassName__c).add(pp);
            }
        }

        if (mapPendingProcess.size()> 0)
		{
            Type typeProcessAction = Type.forName(DISPACHER_SCH);
            CBK_log.debug('CBK_ScheduleProcess_Controller - ' + DISPACHER_SCH + ' Map: ' + mapPendingProcess, LoggingLevel.INFO);	
    	    CBK_ScheduleProcess_Abstract processAction = (CBK_ScheduleProcess_Abstract) typeProcessAction.newInstance();
        	processAction.execute(mapPendingProcess);           
        }
        
    }
}