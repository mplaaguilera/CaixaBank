@isTest
private class CBK_Context_Trigger_Test {
    @isTest 
    static void executeBatch() {
        System.runAs(createUser()) {
            Id res = CBK_BatchJob.executeBatch('CBK_MonitorJobs_Batch','CC');
            System.assertNotEquals(res, null);  
            List<CBK_Framework_Batch__c> lstJobs =  [Select Id from CBK_Framework_Batch__c where Id = :res];
            System.assertEquals(lstJobs.size(), 1);  
        }   
    } 
    
	@isTest static void testOT() {    
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('OT');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }
	@isTest static void testOTSched() {   
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('OT');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }
    
    @isTest static void testAV() {         
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('AV');
            Test.stopTest();
            System.assertEquals(true, result);   
        } 
    }
	@isTest static void testAVSched() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('AV');
            Test.stopTest();
            System.assertEquals(true, result);   
        } 
    }
    
	@isTest static void testCAM() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('CAM');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }    
	@isTest static void testCAMSche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('CAM');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }    

    @isTest static void testCC() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('CC');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }    
	@isTest static void testCCSche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('CC');
            Test.stopTest();
            System.assertEquals(true, result);   
        }  
    }
    
	@isTest static void testCIBE() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('CIBE');
            Test.stopTest();
            System.assertEquals(true, result);   
        } 
    }    
	@isTest static void testCIBESche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('CIBE');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }
    
	@isTest static void testCSBD() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('CSBD');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }        
	@isTest static void testCSBDSche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('CSBD');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }
    
	@isTest static void testEV() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('EV');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }        
	@isTest static void testEVSche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('EV');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }
    
	@isTest static void testMCSOL() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('MCSOL');
            Test.stopTest();
            System.assertEquals(true, result);   
        } 
    }        
	@isTest static void testMCSOLSche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('MCSOL');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }
    
	@isTest static void testOS() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('OS');
            Test.stopTest();
            System.assertEquals(true, result);   
        } 
    }        
	@isTest static void testOSSche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('OS');
            Test.stopTest();
            System.assertEquals(true, result);   
        }  
    }
    
	@isTest static void testSACH() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('SACH');
            Test.stopTest();
            System.assertEquals(true, result);   
        } 
    }        
	@isTest static void testSACHSche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('SACH');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }
    
	@isTest static void testSEG() {        
        System.runAs(createUser()) {        
            Test.startTest();    
            boolean result = batchTest('SEG');
            Test.stopTest();
            System.assertEquals(true, result);   
        }
    }        
	@isTest static void testSEGSche() {        
        System.runAs(createUser()) {          
            Test.startTest();    
            boolean result = schedTest('SEG');
            Test.stopTest();
            System.assertEquals(true, result);   
        }   
    }
    
	private static boolean batchTest(string userPlatformEvent) {    
        Type tipoObjeto = Type.forName('CBK_Context_' + userPlatformEvent + '__e');
        sObject evento = (sObject) tipoObjeto.newInstance();
        evento.put('JobId__c', 'X');
        evento.put('Tipo__c', 'BatchProcess');
                    
        Database.SaveResult sr = EventBus.publish(evento);      
        boolean result = sr.isSuccess();            
        return(result);
    }  

	private static boolean schedTest(string userPlatformEvent) {   
        Type tipoObjeto = Type.forName('CBK_Context_' + userPlatformEvent + '__e');
        sObject evento = (sObject) tipoObjeto.newInstance();
        
        list<string> jobList = new list<string>();
        jobList.add('X');
        jobList.add('Y');        
        evento.put('JobList__c', JSON.serialize(jobList));
        evento.put('Tipo__c', 'SchedProcess');        					   
                
        Database.SaveResult sr = EventBus.publish(evento);                    
        boolean result = sr.isSuccess();     
        return(result);   
    }  

    @isTest
    static void testProcesaBatchApex() {
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
        insert jobDef; 
        
        list<String> lstJobs = new list<String>();
        lstJobs.add(jobDef.Id);
        
        System.runAs(createUser()) {      
            Test.startTest();
            CBK_ContextTrigger_Helper.procesaBatchApex(lstJobs);
            Test.stopTest();
        }
        System.assertEquals(1, lstJobs.size());   
    }
    @isTest
    static void testProcesaBatchApexFail() {
        CBK_Framework_Batch__c jobDef = New CBK_Framework_Batch__c(name='TestCBK_MonitorJobsSched',Class_Name__c= 'CLASEINEXISTENTE');
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
        insert jobDef; 
        
        list<String> lstJobs = new list<String>();
        lstJobs.add(jobDef.Id);       
        System.runAs(createUser()) {       
            Test.startTest();
            CBK_ContextTrigger_Helper.procesaBatchApex(lstJobs);
            Test.stopTest();
        }
        System.assertEquals(1, lstJobs.size());
    }
    
    @isTest
    static void testProcesaSchedProc() {
		CBK_SCH_PendingProcess__c pp = new CBK_SCH_PendingProcess__c();
		Datetime vToday = DateTime.newInstance(2021, 4, 23, 7, 8, 16);
		pp.Type__c = 'EMAIL';
		pp.RecordId__c = '12345677';
		pp.Schedule_Time__c = vToday.addDays(- 1);
		pp.ClassName__c = 'CBKSCHQueueable';
		pp.Retries__c = 0;
		insert(pp);
        list<String> lstJobs = new list<String>();
        lstJobs.add(pp.Id);
        
        System.runAs(createUser()) {      
            Test.startTest();
            CBK_ContextTrigger_Helper.procesaSchedProc(lstJobs);
            Test.stopTest();
        }
        System.assertEquals(1, lstJobs.size());

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