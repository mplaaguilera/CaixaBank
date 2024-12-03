@isTest
private class CBK_BatchJob_Helper_test {
    @isTest 
    static void nextExecutionHora() {
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_Framework_Batch',Class_Name__c= 'CBK_Framework_Batch');
        jobDef.tipo__c = 'Periodico';
        jobDef.Priority__c = 1;
        jobDef.BatchSize__c = 100;
        jobDef.params__c=null;
        jobDef.Tipo_de_periodicidad__c='Horas';
        jobDef.Periodicidad__c=1;
        jobDef.lunes__c=true;
        jobDef.Activo__c=true;
        jobDef.LastExec_Sched__c=DateTime.now()-1;
        jobDef.Calc_NextExec__c='INI';
        insert jobDef; 
        CBK_BatchJob_Helper.nextExecution(jobDef);
        system.assertNotEquals(jobDef.Id, null);
    }
    @isTest 
    static void nextExecutionMinuto() {
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_Framework_Batch',Class_Name__c= 'CBK_Framework_Batch');
        jobDef.tipo__c = 'Periodico';
        jobDef.Priority__c = 1;
        jobDef.BatchSize__c = 100;
        jobDef.params__c=null;
        jobDef.Tipo_de_periodicidad__c='Minutos';
        jobDef.Periodicidad__c=1;
        jobDef.lunes__c=true;
        jobDef.Activo__c=true;
        jobDef.LastExec_Sched__c=DateTime.now()-1;
        jobDef.Calc_NextExec__c='END';
        insert jobDef; 
        CBK_BatchJob_Helper.nextExecution(jobDef);
        system.assertNotEquals(jobDef.Id, null);
    }
    @isTest 
    static void nextExecutionDia() {
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_Framework_Batch',Class_Name__c= 'CBK_Framework_Batch');
        jobDef.tipo__c = 'Periodico';
        jobDef.Priority__c = 1;
        jobDef.BatchSize__c = 100;
        jobDef.params__c=null;
        jobDef.Tipo_de_periodicidad__c='Dias';
        jobDef.Periodicidad__c=1;
        jobDef.lunes__c=true;
        jobDef.Activo__c=true;
        jobDef.LastExec_Sched__c=DateTime.now()-1;
        jobDef.Calc_NextExec__c='SCHED';
        insert jobDef; 
        CBK_BatchJob_Helper.nextExecution(jobDef);
        system.assertNotEquals(jobDef.Id, null);
    }
    
    @isTest 
    static void findProject() {
        String proyecto = CBK_BatchJob_Helper.findProject('CBK_BatchJob_Helper');
        system.assertNotEquals(proyecto,null);
    }

    @isTest 
    static void jobEjecutable() {
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_Framework_Batch',Class_Name__c= 'CBK_Framework_Batch');
        jobDef.tipo__c = 'Puntual';
        jobDef.Priority__c = 0;
        jobDef.BatchSize__c = 100;
        jobDef.params__c=null;
        insert jobDef; 
        
        list<CBK_BatchJob_Helper.batchJob> lstRunning = New list<CBK_BatchJob_Helper.batchJob>();
        CBK_BatchJob_Helper.batchJob running = new CBK_BatchJob_Helper.batchJob();
        running.jobId='xxxxxxx';
        running.batchName='CBK_Framework_Batch';
        running.classNane='CBK_Framework_Batch';
        running.project='Test';
        running.tipo='Puntual';
        lstRunning.add(running);

        boolean res = CBK_BatchJob_Helper.jobEjecutable(jobDef,lstRunning );
        system.assertEquals(res,true);
    }   
    
    @isTest 
    static void testerrorJob() {
        Test.startTest();
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='ErrorCBK_Framework_Batch',Class_Name__c= 'CBK_Framework_Batch');
        try{
            
            jobDef.tipo__c = 'Puntual';
            jobDef.Priority__c = 1;
            jobDef.BatchSize__c = 100;
            jobDef.params__c=null;
            jobDef.Activo__c=true;
            jobDef.LastExec_Sched__c=DateTime.now()-1;
            jobDef.Notif__c = true;
            jobDef.Email_Notif__c ='test@test.com';
            insert jobDef; 
        

            User lst = [Select Id from User LIMIT 2];
        } catch (Exception e) {
            CBK_BatchJob_Helper.errorJob(e, jobDef);
        }
        
        Test.stopTest();
        system.assertNotEquals(jobDef.Id, null);
    }   

}