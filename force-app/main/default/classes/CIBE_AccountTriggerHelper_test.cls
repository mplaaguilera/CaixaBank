/**********************************************************************************************************************
Name:	  CIBE_AccountTriggerHelper_test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_AccountTriggerHelper_test"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Luis Martínez	   	07/10/2020		Init version
2.0			US425471	   Jose Maria			24/11/2022		add updateRatingPD method
3.0						    Lucia				21/05/2024		Add retrieveComercialInsertGroupTest, retrieveComercialUpdateGroupTest

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_AccountTriggerHelper_test {
    @TestSetup
    public static void testSetup() {
        CIBE_TestInitialSetup.setupInitialDataCIB();
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND ( Profile.Name = 'System Administrator' OR Profile.Name = 'Administrador del Sistema') LIMIT 1];
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c =: usrTest.Id LIMIT 1];

        System.runAs(admin){
            Account acc = CIBE_TestHelper.createCustomer(usrTest);
            Opportunity opp = CIBE_TestHelper.createOpportunityWithEmpleado(acc, cont, 'En curso', System.today() + 5, '', usrTest.Id);
            AV_Book__c purseTest = CIBE_TestHelper.createPurse('50077');
            purseTest.AV_Negocio__c = 'COR';
            purseTest.OwnerID = usrTest.Id;
            update purseTest;
            AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(acc, purseTest);
        }
    }
	/**
	 * Execute the Trigger class (CIBE_Account_AU_TRHan) and check if the business is correct for the CIBE context.
	 */
    @isTest
    public static void updateOppConfidentiality() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' LIMIT 1];
        Account acc = [SELECT Id, AV_Confidencial__c FROM Account WHERE OwnerId =: usrTest.Id AND RecordType.DeveloperName =: CIBE_AppConstants.ACCOUNT_CLIENTE_RT AND AV_NumPerso__c = '123'AND AV_Negocio__c = 'CIB' LIMIT 1];
        Opportunity oppor = [SELECT Id, AV_ClienteConfidencial__c FROM Opportunity WHERE AccountId=:acc.id AND OwnerId =:usrTest.Id limit 1];
        AV_Book__c bookTest = [SELECT id, RecordType.developername,AV_Activa__c, AV_Negocio__c, AV_ExternalID__c FROM AV_Book__c ];
        AV_BookMember__c bookMemberTest = [SELECT id, AV_Cliente__c,RecordType.developername,AV_Cartera__c, AV_Cartera__r.AV_Activa__c,AV_Cartera__r.AV_Negocio__c FROM AV_BookMember__c ];

        System.runAs(usrTest){
            Test.startTest();
                acc.AV_Confidencial__c = true;
                Database.update(acc);
            Test.stopTest();
        }
        Opportunity opp = [Select Id, AV_ClienteConfidencial__c From Opportunity Where id=:oppor.id limit 1];
        System.assertEquals(true, opp.AV_ClienteConfidencial__c == acc.AV_Confidencial__c, 'Confidentiality was not updated.');
    }

    /**
	 * Execute the Trigger class (CIBE_Account_AU_TRHan) and check if the business is correct for the CIBE context.
	 */
    @isTest
    public static void updateEventConfidentiality() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' LIMIT 1];
        Account acc = [SELECT Id, AV_Confidencial__c FROM Account WHERE OwnerId =: usrTest.Id AND RecordType.DeveloperName =: CIBE_AppConstants.ACCOUNT_CLIENTE_RT AND AV_NumPerso__c = '123'AND AV_Negocio__c = 'CIB' LIMIT 1];
        Datetime activityDate = Datetime.now();
        System.runAs(usrTest){
            Event evt = CIBE_TestHelper.createEvent(usrTest, activityDate, acc);
            Test.startTest();
                acc.AV_Confidencial__c = true;
                Database.update(acc);
            Test.stopTest();
            Event qevt = [Select Id, CIBE_Confidential__c From Event Where id=:evt.id limit 1];
            System.assertEquals(true, qevt.CIBE_Confidential__c == acc.AV_Confidencial__c, 'Confidentiality was not updated.');
        }
    }


    /**
	 * Execute the Trigger class (CIBE_Account_AU_TRHan) and check if the business is correct for the CIBE context.
	 */
    @isTest
    public static void updateTaskConfidentiality() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' LIMIT 1];
        Account acc = [SELECT Id, AV_Confidencial__c FROM Account WHERE OwnerId =: usrTest.Id AND RecordType.DeveloperName =: CIBE_AppConstants.ACCOUNT_CLIENTE_RT AND AV_NumPerso__c = '123'AND AV_Negocio__c = 'CIB' LIMIT 1];
        System.runAs(usrTest){
            RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
            Task tarea  = new Task();
            tarea.Subject = 'Llamada Saliente';
            tarea.OwnerId = usrTest.Id;		
            tarea.Status = 'Pendiente no localizado';
            tarea.Priority = 'Normal';
            tarea.AV_ExternalID__c = '01928363';
            tarea.RecordTypeId = rt.Id;
            tarea.ActivityDate = System.today()-3;
            tarea.WhatId=acc.id;
            insert tarea;
            Test.startTest();
                acc.AV_Confidencial__c = true;
                Database.update(acc);
            Test.stopTest();
            Task qTas = [Select Id, CIBE_Confidential__c From Task Where id=:tarea.id limit 1];
            System.assertEquals(true, qTas.CIBE_Confidential__c == acc.AV_Confidencial__c, 'Confidentiality was not updated.');
        }
    }

	/**
	 * Execute the Trigger class (CIBE_Account_AU_TRHan) and check if the business is correct for the CIBE context.
	 */
    @isTest
    public static void getNegocioTest() {
        
        RecordType rtPAccountTest = AV_AppUtilities.getRecordType('Account', 'CC_Cliente');
        List <Account> lstAccount = new List<Account>();
        List <Account> lstAssert = new List<Account>();
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' LIMIT 1];
        Account acc = [SELECT Id, AV_Confidencial__c FROM Account WHERE OwnerId =: usrTest.Id AND RecordType.DeveloperName =: CIBE_AppConstants.ACCOUNT_CLIENTE_RT AND AV_NumPerso__c = '123'AND AV_Negocio__c = 'CIB' LIMIT 1];
        AV_Book__c bookTest = [SELECT id, RecordType.developername,AV_Activa__c, AV_Negocio__c, AV_ExternalID__c FROM AV_Book__c ];
        AV_BookMember__c bookMemberT = [SELECT id, AV_Cliente__c,RecordType.developername,AV_Cartera__c, AV_Cartera__r.AV_Activa__c,AV_Cartera__r.AV_Negocio__c FROM AV_BookMember__c ];

        System.runAs(usrTest){
            Account accountTest = new Account();
            accountTest.AV_Cliente__c = true;
            accountTest.CC_Numero_Documento__c = '00000000T';
            accountTest.Name = 'Prueba';
            accountTest.RecordTypeId = rtPAccountTest.Id;
            
            lstAccount.add(accountTest);
            insert lstAccount;
            lstAccount.add(acc);
            Test.startTest();
                AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(accountTest, bookTest);
                AV_BookMember__c bookMemberTest2 = CIBE_TestHelper.createBookMember(acc, bookTest);
                lstAssert = CIBE_AccountTriggerHelper.getNegocio(lstAccount);
            Test.stopTest();
            System.assertEquals(lstAssert.size()>0, true);
        }
    }
    
    
    /**
	 * Execute the Trigger class (CIBE_Account_BU_TRHan y CIBE_Account_BI_TRHan)
	 */
    @isTest
    public static void updateRatingPDTest() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' LIMIT 1];

        //Es obligatorio el uso del SA por validaciones al crear el
        System.runAs(usrTest){
            CIBE_PD__c metadata = new CIBE_PD__c();
            metadata.CIBE_PDRating__c = 'AAA';
            metadata.CIBE_FechaCarga__c = Date.parse('20/12/2022');
            metadata.CIBE_PDMin__c = 0;
            metadata.CIBE_PDMax__c = 100;
            insert metadata;

            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = 'Name CIB 12345',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '12345',
                AV_Negocio__c = 'CIB',
                CIBE_PD__c = 90,
                AV_Rating__c = '7.5'
            );
            insert acc;
            
            Account accBf = [SELECT Id, CIBE_FechaRating_SP__c FROM Account WHERE Id=:acc.Id LIMIT 1];
            System.assert(accBf.CIBE_FechaRating_SP__c != Null);
        } 
    }

    @isTest
    public static void retrieveComercialInsertGroupTest() {
        
        User gcf = [SELECT  Id, name from user where Username like 'gcf-integration@cc-caixabank.com%'];

        System.runAs(gcf){
            List <Account> lstAccount = new List<Account>();
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_G_COMERCIAL_RT);

            Account accountTest = new Account();
            accountTest.Name = 'GC-Test';
            accountTest.RecordTypeId = rt.Id;
            accountTest.AV_NumPerso__c = '634';
            
            lstAccount.add(accountTest);
            insert lstAccount;
            lstAccount.add(accountTest);
            Test.startTest();
                Account acc = [SELECT Id, Name, CIBE_GrupoComercial__c FROM Account WHERE Id = :accountTest.Id];
                System.assertEquals(acc.Name, acc.CIBE_GrupoComercial__c);
            Test.stopTest();
        }
    }

    @isTest
    public static void retrieveComercialUpdateGroupTest() {
        
        User gcf = [SELECT  Id, name from user where Username like 'gcf-integration@cc-caixabank.com%'];

        System.runAs(gcf){
            List <Account> lstAccount = new List<Account>();
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_G_COMERCIAL_RT);

            Account accountTest = new Account();
            accountTest.Name = 'GC-Test';
            accountTest.RecordTypeId = rt.Id;
            accountTest.AV_NumPerso__c = '111';
            
            lstAccount.add(accountTest);
            insert lstAccount;
            lstAccount.add(accountTest);
            Test.startTest();
                Account acc = [SELECT Id, Name, CIBE_GrupoComercial__c FROM Account WHERE Id = :accountTest.Id];
                acc.CIBE_GrupoComercial__c = 'Cambio';
                update acc;
                Account accUpdate = [SELECT Id, Name, CIBE_GrupoComercial__c FROM Account WHERE Id = :acc.Id];
                System.assertEquals(accUpdate.Name, accUpdate.CIBE_GrupoComercial__c);
            Test.stopTest();
        }
    }
    
}