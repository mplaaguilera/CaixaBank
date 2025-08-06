/**
 * @description CORE del framework de Jobs Apex 
 */ 

public with sharing class CBK_BatchJob_Sched  implements Schedulable {
    /**
     * @description execute
     * @param sc  : SchedulableContext
     */    
    public void execute(SchedulableContext sc)  
    {  
        CBK_BatchJob.reschedulledJobs();
        CBK_BatchJob.statusBatch();
        CBK_BatchJob.cleanBatchOrder();
        CBK_BatchJob.BatchOrder();
        CBK_BatchJob.runBatches();
        CBK_BatchJob.cleanBatchOrder();
        CBK_BatchJob.BatchOrder();
        
        //Replanificación de JOB
		newSchedule();
    }
    

    /**
     * @description replanidicación de Job para nueva ejecución
     */
    public static void newSchedule() {        
        AdminSettings__c  settings = AdminSettings__c.getInstance();
		Integer delay = (settings?.ScheduleJob__c == null) ? 5 :  (integer)settings.ScheduleJob__c + 0;

        Datetime sysTime = Datetime.now().addMinutes(delay);
   		sysTime = sysTime.addSeconds(-sysTime.second());
		
        //parse to cron expression
		String chronExp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
		CBK_BatchJob_Sched scheduler = new CBK_BatchJob_Sched(); 
        String jobName='Framework Batch: ' + String.valueOf(sysTime);
        if (!Test.isRunningTest()){ 
			System.schedule(jobName, chronExp, scheduler);
        }   
    }

    /**
     * @description Proceso que activa la planificación del proceso Batch
     */
    public static void start() {
        stop();
        newSchedule();
        BatchJobCheck_start();
    }

    /**
     * @description Proceso que para la planificación del proceso Batch
     */
    public static void stop() {
        list<CronTrigger> lstjobs = [SELECT Id, CronJobDetail.name, State FROM CronTrigger
									  Where (CronJobDetail.name like 'Framework Batch:%' or 
                                            CronJobDetail.name like  'Framework Batch Check:%')
										and State in ('WAITING','ACQUIRED','EXECUTING')];
        
        for (CronTrigger job : lstjobs) {
        	System.abortJob(job.Id);            
        }
    }
    
        /**
     * @description replanidicación de Job para nueva ejecución
     */
    public static void BatchJobCheck_start() {        
		//String chronExp = '0 0 * * * ?';
        Datetime sysTime = Datetime.now();
        String jobName='Framework Batch Check: ' + String.valueOf(sysTime);
        if (!Test.isRunningTest()){ 
            System.schedule(jobName  +  ' - 00', '0 0 * * * ?', new CBK_BatchJobCheck());
			System.schedule(jobName  +  ' - 15', '0 15 * * * ?', new CBK_BatchJobCheck());
			System.schedule(jobName  +  ' - 30', '0 30 * * * ?', new CBK_BatchJobCheck());
			System.schedule(jobName  +  ' - 45', '0 45 * * * ?', new CBK_BatchJobCheck());
        }   
    }
}

//https://help.salesforce.com/articleView?id=000314061&type=1&mode=1