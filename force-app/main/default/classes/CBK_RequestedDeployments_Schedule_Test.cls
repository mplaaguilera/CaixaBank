/**********************************************************************************************************************
 Name:	  CBK_RequestedDeployments_Schedule_Test
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Test Class of CBK_RequestedDeployments_Schedule
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   	            	DATE				Description
	1.0			US868474		    Sergio García & Raphael        	17/10/2024		    Init version
***********************************************************************************************************************/
@isTest
private class CBK_RequestedDeployments_Schedule_Test {

    @TestSetup
    static void setup() {
        // Crear un usuario de prueba
        System.runAs (new User(Id = UserInfo.getUserId()) ) {
            Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole role = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User testUser = new User(
                alias = 'user2', 
                email='testuser@example.com',
                emailencodingkey='UTF-8', 
                lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', 
                profileid = profile.Id, 
                userroleid = role.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert testUser;

            List<CBK_IntegrationSetting__c> listIntSettings = new List<CBK_IntegrationSetting__c>();
            CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
            wsc.Name = 'CBK_ToolingQuery';
            wsc.NamedCredential__c = 'https://caixabankcc.my.salesforce.com/services/data/v58.0/tooling/query/?q=';
            wsc.CBK_Method__c = 'GET';
            listIntSettings.add(wsc);
            
            wsc = new CBK_IntegrationSetting__c();
            wsc.Name = 'CBK_StatusDeployRequest';
            wsc.NamedCredential__c = 'https://caixabankcc.my.salesforce.com/services/data/v58.0/tooling/sobjects/DeployRequest';
            wsc.CBK_Method__c = 'GET';
            listIntSettings.add(wsc);

            insert listIntSettings;
            
            //PendingProcess
            List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = new List<CBK_SCH_PendingProcess__c>();
            CBK_SCH_PendingProcess__c pendingProcess = new CBK_SCH_PendingProcess__c();
            pendingProcess.Param1__c = String.valueOf(System.now());
            pendingProcess.Param2__c = String.valueOf(System.now());
            pendingProcess.ClassName__c = 'CBK_Test';
            incomingPendingProcessList.add(pendingProcess);
            insert incomingPendingProcessList;
            
            //CBK_Log
            CBK_Log__c oLog = new CBK_Log__c();
            oLog.state__c = 'Deploy Request not valid';
            oLog.Equipo__c = '0Afxx00000000lWCAQ';
            insert oLog;
        }
    }

    // Test the scheduling functionality
    @isTest
    static void testSchedule() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@example.com' LIMIT 1];
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = [SELECT Id, Param1__c, Param2__c, ClassName__c FROM CBK_SCH_PendingProcess__c];
        String sch = '0 0 0 1 1 ? 2025'; // Schedule for January 1st, 2025, at midnight
        String jobName = 'Check Deploys Copado' + System.now();
        Test.setMock(HttpCalloutMock.class, new CBK_RequestedDeployments_Mock());        
        
        
        Test.startTest();

        System.runAs (testUser) {
            // Crear una instancia de la clase CBK_RequestedDeployments_Schedule
            AsyncOptions asyncOptions = new AsyncOptions();
            asyncOptions.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(testUser.Id)
                .build();
            Type typeProcessAction = Type.forName('CBK_RequestedDeployments_Schedule');
            CBK_SCH_Queueable_Abstract processAction = (CBK_SCH_Queueable_Abstract) typeProcessAction.newInstance();
            processAction.lstInfoProcess = incomingPendingProcessList;
            if(!Test.isRunningTest()){
                System.enqueueJob(processAction, asyncOptions);	
            }

            String jobID = System.enqueueJob(processAction);
        }

        Test.stopTest();

        // Verificar que se haya creado un nuevo deployment request
        String sRecordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_Deploy_Log').getRecordTypeId();
        Integer cbkLogCount = [SELECT COUNT() FROM CBK_Log__c WHERE RecordTypeId = :sRecordTypeId];
        System.assertEquals(10, cbkLogCount, 'The CBK Log records should have been created');
    }

    // Test the formToolingQuery method
    @isTest
    static void testFormToolingQuery() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@example.com' LIMIT 1];
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addDays(1);
        Test.setMock(HttpCalloutMock.class, new CBK_RequestedDeployments_Mock());
        
        // Verify the query
        String baseQuery = 'SELECT Id,CreatedDate+'
            + 'FROM+DeployRequest+'
            + 'ORDER+BY+CreatedDate+DESC'
            +' LIMIT+4';
        Set<String> depReqList;

        Test.startTest();

        System.runAs (testUser) {
            Test.setMock(HttpCalloutMock.class, new CBK_RequestedDeployments_Mock());
            depReqList = CBK_RequestedDeployments_Schedule.formToolingQuery(startDate, endDate);
        }

        Test.stopTest();

        //Comprobar output
        Assert.areNotEqual(null, depReqList, 'Output shouldn\'t be null');
        Assert.areEqual(10, depReqList.size(), 'There should be 10 DeployRequest record');
    }
}