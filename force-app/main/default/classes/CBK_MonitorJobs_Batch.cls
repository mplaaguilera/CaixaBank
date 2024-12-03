global class CBK_MonitorJobs_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,createdDate, Job_Id__c FROM CBK_log__c where (completado__c=false OR CreatedDate = LAST_N_DAYS:1) and recordtype.developername=\'data_Load_Log\' and Job_Id__c !=\'\' order by systemModstamp__c desc';
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<CBK_log__c> jobList) {
        Datetime dtToday = Datetime.now();
        date dToday = date.newInstance(dtToday.year(), dtToday.month(), dtToday.day());
        CBK_Config__mdt config = CBK_Config__mdt.getInstance('CBK_ConfigMonitorBatch');
        for(CBK_log__c job : jobList){        
            date todayjob = date.newInstance(job.createdDate.year(), job.createdDate.month(), job.createdDate.day());   
            integer days = todayjob.daysBetween(dToday);
            if(days <= Integer.valueOf(config.CBK_Paramertro1__c)){    
           	    // Update the Account Name 
                CBK_MonitorJobs.CBK_JobDetail(job.Job_Id__c);   
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    	// execute any post-processing operations
    }
}