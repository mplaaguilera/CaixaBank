@isTest
private class CBK_BatchJob_test {

    @isTest 
    static void executeBatch1() {
        Test.startTest();
        	Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch');
        Test.stopTest();
        System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);        
    } 

    @isTest 
    static void executeBatch2() {
        Test.startTest();
        	Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',0);
        Test.stopTest();
        System.assertNotEquals(res, null);
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);
    }    

    @isTest 
    static void executeBatch3() {
        Test.startTest();
        	Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',100,0);
        Test.stopTest();
        System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);     
    }  
    
    @isTest 
    static void executeBatch4() {
        map<String,Object> params = New map<String,Object>();
        List<Id> idAgrupadores = new List<Id>();
        for (Case a : [select Id from Case limit 1]){
            idAgrupadores.add(a.id);
        }
        params.put('idAgrupadores',idAgrupadores);
        Id res;
        Test.startTest();
            System.runAs(createUser()) {
                res = CBK_BatchJob.executeBatch('CC_Agrupador_Batch', 100,params);
        	}
        Test.stopTest();
		System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);     
    }  

    @isTest 
    static void executeBatch5() {
        map<String,Object> params = New map<String,Object>();
        List<Id> idAgrupadores = new List<Id>();
        for (Case a : [select Id from Case limit 1]){
            idAgrupadores.add(a.id);
        }
        params.put('idAgrupadores',idAgrupadores);
        Id res;
        Test.startTest();
            System.runAs(createUser()) {
                res = CBK_BatchJob.executeBatch('CC_Agrupador_Batch', 100,params,1);
            }
        Test.stopTest();
		System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);     
    }  

    @isTest 
    static void executeBatch6() {
        map<String,Object> params = New map<String,Object>();
        List<Id> idAgrupadores = new List<Id>();
        for (Case a : [select Id from Case limit 1]){
            idAgrupadores.add(a.id);
        }
        params.put('idAgrupadores',idAgrupadores);
        Id res;
        Test.startTest();
            System.runAs(createUser()) {
                res = CBK_BatchJob.executeBatch('CC_Agrupador_Batch', 100,params,1,'OT');
            }
        Test.stopTest();
		System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);     
    }  

    @isTest 
    static void executeBatchFutur() {
        map<String,Object> params = New map<String,Object>();
        List<Id> idAgrupadores = new List<Id>();
        for (Case a : [select Id from Case limit 1]){
            idAgrupadores.add(a.id);
        }
        params.put('idAgrupadores',idAgrupadores);
        Test.startTest();
            System.runAs(createUser()) {
                CBK_BatchJob.executeBatchFuture('CC_Agrupador_Batch', 100,JSON.serialize(params));
            }
        Test.stopTest();
        System.assertEquals(params==null, false);
    } 

    @isTest 
    static void executeBatchFuturContext() {
        map<String,Object> params = New map<String,Object>();
        List<Id> idAgrupadores = new List<Id>();
        for (Case a : [select Id from Case limit 1]){
            idAgrupadores.add(a.id);
        }
        params.put('idAgrupadores',idAgrupadores);
        Test.startTest();
            System.runAs(createUser()) {
                CBK_BatchJob.executeBatchFutureContext('CC_Agrupador_Batch', 100,JSON.serialize(params),'OT');
            }
        Test.stopTest();
        System.assertEquals(params==null, false);
    }  

    @isTest 
    static void executeBatchContext1() {
        Id res;
        Test.startTest();
            System.runAs(createUser()) {
                res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch','OT');
            }
        Test.stopTest();
        System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);        
    } 

    @isTest 
    static void executeBatchContext2() {
        Id res;
        Test.startTest();
            System.runAs(createUser()) {
                res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',0,'OT');
            }
        Test.stopTest();
        System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);     }    

    @isTest 
    static void executeBatchContext3() {
        Id res;
        Test.startTest();
            System.runAs(createUser()) {
                res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',100,0,'OT');
            }
        Test.stopTest();
        System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);     }  
    
    @isTest 
    static void executeBatchContext4() {
        map<String,Object> params = New map<String,Object>();
        List<Id> idAgrupadores = new List<Id>();
        Test.startTest();
            for (Case a : [select Id from Case limit 1]){
                idAgrupadores.add(a.id);
            }
        Test.stopTest();
        params.put('idAgrupadores',idAgrupadores);
        
        Id res;
        System.runAs(createUser()) {
            res = CBK_BatchJob.executeBatch('CC_Agrupador_Batch', 100,params,'OT');
        }
		System.assertNotEquals(res, null);  
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);     
    }      


    @isTest 
    static void statusBatch() {
        Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',0);
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_Framework_Batch',Class_Name__c= 'CBK_Framework_Batch');
        jobDef.tipo__c = 'Periodico';
        jobDef.Priority__c = 1;
        jobDef.BatchSize__c = 100;
        jobDef.Status__c = 'Queued';
        jobDef.params__c=null;
        jobDef.RunningJobId__c= res;
        jobDef.Tipo_de_periodicidad__c='Horas';
        jobDef.Periodicidad__c=1;
        jobDef.lunes__c=true;
        jobDef.Activo__c=true;
        jobDef.LastExec_Sched__c=DateTime.now()-1;
        jobDef.Calc_NextExec__c='INI';
        jobDef.UsuarioContexto__c = 'OT';
        
        Test.startTest();
        	insert jobDef; 
        Test.stopTest();
        
        CBK_BatchJob.statusBatch();
        System.assertNotEquals(jobDef.Id, null);
    }    
    
    @isTest 
    static void reschedulledJobs() {
        Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',1);
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
        jobDef.UsuarioContexto__c = 'OT';
        
        Test.startTest();
        	insert jobDef; 
        Test.stopTest();
        
        CBK_BatchJob.reschedulledJobs();
        System.assertNotEquals(jobDef.Id, null);
    }        
    
    @isTest 
    static void batchOrder() {
        Test.startTest();
        	Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',1);
        Test.stopTest();
        
        CBK_BatchJob.batchOrder();
        CBK_BatchJob.cleanBatchOrder();
        System.assertNotEquals(res, null);
    }         

    
    @isTest 
    static void schedulleBatch() {
        Test.startTest();
        	Id res = CBK_BatchJob.schedulleBatch ('CBK_MonitorJobs_Batch_' + CBK_BatchJob_Helper.timestamp(), 'CBK_MonitorJobs_Batch', 100, New map<String,Object>(),system.Now());
        Test.stopTest();
        System.assertNotEquals(res, null);
    }   
    
    
    @isTest 
    static void runBatches1() {  
        Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch');

        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_MonitorJobsSched',Class_Name__c= 'CBK_MonitorJobs_Batch');
        jobDef.tipo__c = 'Periodico';
        jobDef.Priority__c = 1;
        jobDef.orden__c = 1;
        jobDef.BatchSize__c = 100;
        jobDef.runningJobId__c =null;
        jobDef.params__c=null;
        jobDef.Tipo_de_periodicidad__c='Horas';
        jobDef.Periodicidad__c=1;
        jobDef.lunes__c=true;
        jobDef.Activo__c=true;
        jobDef.LastExec_Sched__c=system.now()-1;
        jobDef.NextExec__c=system.now()-1;
        jobDef.Calc_NextExec__c='INI';
        jobDef.UsuarioContexto__c = 'OT';
        
        Test.startTest();
            insert jobDef; 
            CBK_BatchJob.runBatches();
        Test.stopTest();
        
        System.assertNotEquals(jobDef.Id, null);
    }
    
    @isTest 
    static void runBatches2() {  
        Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch');

        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_MonitorJobsSched',Class_Name__c= 'CBK_MonitorJobs_Batch');
        jobDef.tipo__c = 'Periodico';
        jobDef.Priority__c = 1;
        jobDef.orden__c = 1;
        jobDef.BatchSize__c = 100;
        jobDef.runningJobId__c =null;
        jobDef.params__c=null;
        jobDef.Tipo_de_periodicidad__c='Horas';
        jobDef.Periodicidad__c=1;
        jobDef.lunes__c=true;
        jobDef.Activo__c=true;
        jobDef.LastExec_Sched__c=system.now()-1;
        jobDef.NextExec__c=system.now()-1;
        jobDef.Calc_NextExec__c='INI';
        jobDef.UsuarioContexto__c='CC';
        Test.startTest();
            insert jobDef; 
            System.runAs(createUser()) {
                CBK_BatchJob.runBatches();
            }
        Test.stopTest();
        System.assertNotEquals(jobDef.Id, null);
    }
    
    @isTest
    static void full() {
        Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',1);
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_MonitorJobsSched',Class_Name__c= 'CBK_MonitorJobs_Batch');
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
        jobDef.UsuarioContexto__c = 'OT';
        Test.startTest();
            insert jobDef; 
            CBK_BatchJob.reschedulledJobs();
            CBK_BatchJob.statusBatch();
            CBK_BatchJob.cleanBatchOrder();
            CBK_BatchJob.BatchOrder();
            CBK_BatchJob.runBatches();
        Test.stopTest();
        System.assertNotEquals(jobDef.Id, null);
    }  
    @isTest
    static void withcontext() {
        Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch',1);
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_MonitorJobsSched',Class_Name__c= 'CBK_MonitorJobs_Batch');
        jobDef.tipo__c = 'Periodico';
        jobDef.Priority__c = 1;
        jobDef.BatchSize__c = 100;
        jobDef.UsuarioContexto__c ='OT';
        jobDef.params__c=null;
        jobDef.Tipo_de_periodicidad__c='Horas';
        jobDef.Periodicidad__c=1;
        jobDef.lunes__c=true;
        jobDef.Activo__c=true;
        jobDef.LastExec_Sched__c=DateTime.now()-1;
        jobDef.Calc_NextExec__c='INI';
        Test.startTest();
        	insert jobDef; 
            System.runAs(createUser()) {
                CBK_BatchJob.reschedulledJobs();
                CBK_BatchJob.statusBatch();
                CBK_BatchJob.cleanBatchOrder();
                CBK_BatchJob.BatchOrder();
                CBK_BatchJob.runBatches();
            }
        Test.stopTest();
        System.assertNotEquals(jobDef.Id, null);
    }  

    @isTest 
    static void executeBatchWithBuilder() {
        map<String,Object> params = New map<String,Object>();
        List<Id> idAgrupadores = new List<Id>();
        for (Case a : [select Id from Case limit 1]){
            idAgrupadores.add(a.id);
        }
        params.put('idAgrupadores',idAgrupadores);
		Test.startTest();
        	Id res;
        	System.runAs(createUser()) {
                res = CBK_BatchJob.executeBatch(new CBK_BatchJob.BatchProcessConfigBuilder('CBK_MonitorJobs_Batch')
                    .setClassName('CBK_MonitorJobs_Batch')    
                    .setBatchSize(100)
                    .setUserContext('OT')
                    .setParams(JSON.serialize(params))
                    .setPriority(1)
                    .setNotifyErrors(true)
                    .setProject('project')
                    .setNotificationEmail('testBatchUser@caixabankcc.com')
                    .setNextExec(DateTime.now())
                    .setType('Puntual')
                    .execute());
            }
        Test.stopTest();
        System.assertNotEquals(res, null);
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
        System.assertEquals(lstJobs.size(), 1);
    } 
    
    @isTest 
    static void executeBatchWithBuilder2() {
        map<String,Object> params = New map<String,Object>();
        List<Id> idAgrupadores = new List<Id>();
        for (Case a : [select Id from Case limit 1]){
            idAgrupadores.add(a.id);
        }
        params.put('idAgrupadores',idAgrupadores);
		Test.startTest();
        	Id res;
        	System.runAs(createUser()) {
                new CBK_BatchJob.BatchProcessConfigBuilder('CBK_MonitorJobs_Batch')
                    .setClassName('CBK_MonitorJobs_Batch')    
                    .setBatchSize(100)
                    .setUserContext('OT')
                    .setParams(JSON.serialize(params))
                    .setPriority(1)
                    .setNotifyErrors(true)
                    .setProject('project')
                    .setNotificationEmail('testBatchUser@caixabankcc.com')
                    .setNextExec(DateTime.now())
                    .setType('Puntual')
                    .execute();
            }
        Test.stopTest();
        List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c];
        System.assertEquals(lstJobs.size(), 1);
    } 

    private static user createUser() {
        String uniqueUserName = 'testBatchUser' + DateTime.now().getTime() + '@caixabankcc.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'testB', Email='testBatchUser@caixabankcc.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
        return(u);
    }    
}