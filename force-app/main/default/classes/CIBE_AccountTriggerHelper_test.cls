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
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_AccountTriggerHelper_test {
 
	/**
	 * Execute the Trigger class (CIBE_Account_AU_TRHan) and check if the business is correct for the CIBE context.
	 */
    @isTest
    public static void updateOppConfidentiality() {
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account acc = CIBE_TestHelper.createCustomer(usrTest);
        Opportunity oppor =CIBE_TestHelper.createOpportunity(acc);
        AV_Book__c purseTest = CIBE_TestHelper.createPurse('50077');
        purseTest.AV_Negocio__c = 'COR';    
        update purseTest;
        AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(acc, purseTest);
        Test.startTest();
            acc.AV_Confidencial__c = true;
            Database.update(acc);
        Test.stopTest();
        Opportunity opp = [Select Id, AV_ClienteConfidencial__c From Opportunity Where id=:oppor.id limit 1];
        System.assertEquals(true, opp.AV_ClienteConfidencial__c == acc.AV_Confidencial__c, 'Confidentiality was not updated.');
    }

    	/**
	 * Execute the Trigger class (CIBE_Account_AU_TRHan) and check if the business is correct for the CIBE context.
	 */
    @isTest
    public static void updateEventConfidentiality() {
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account acc = CIBE_TestHelper.createCustomer(usrTest);
        Datetime activityDate = Datetime.now();
        Event evt = CIBE_TestHelper.createEvent(usrTest, activityDate, acc);
        AV_Book__c purseTest = CIBE_TestHelper.createPurse('50078');
        purseTest.AV_Negocio__c = 'COR';    
        update purseTest;
        AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(acc, purseTest);
        Test.startTest();
            acc.AV_Confidencial__c = true;
            Database.update(acc);
        Test.stopTest();
        Event qevt = [Select Id, CIBE_Confidential__c From Event Where id=:evt.id limit 1];
        System.assertEquals(true, qevt.CIBE_Confidential__c == acc.AV_Confidencial__c, 'Confidentiality was not updated.');
    }
    	/**
	 * Execute the Trigger class (CIBE_Account_AU_TRHan) and check if the business is correct for the CIBE context.
	 */
    @isTest
    public static void updateTaskConfidentiality() {
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account acc = CIBE_TestHelper.createCustomer(usrTest);
        Task tarea = CIBE_TestHelper.createTareaOtherExternalID(usrTest);
        tarea.WhatId=acc.id;
        update tarea;
        AV_Book__c purseTest = CIBE_TestHelper.createPurse('50077');
        purseTest.AV_Negocio__c = 'COR';    
        update purseTest;
        AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(acc, purseTest);

        Test.startTest();
            acc.AV_Confidencial__c = true;
            Database.update(acc);
        Test.stopTest();
        Task qTas = [Select Id, CIBE_Confidential__c From Task Where id=:tarea.id limit 1];
        System.assertEquals(true, qTas.CIBE_Confidential__c == acc.AV_Confidencial__c, 'Confidentiality was not updated.');
    }
	/**
	 * Execute the Trigger class (CIBE_Account_AU_TRHan) and check if the business is correct for the CIBE context.
	 */
    @isTest
    public static void getNegocio_Test() {
        
        RecordType rtPAccountTest = AV_AppUtilities.getRecordType('Account', 'CC_Cliente');
        List <Account> lstAccount = new List<Account>();
        List <Account> lstAssert = new List<Account>();
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account accTest = CIBE_TestHelper.createCustomer(usrTest);
        AV_Book__c purseTest = CIBE_TestHelper.createPurse('50071');
        System.assert(purseTest != null);
        purseTest.AV_Negocio__c = 'COR';    
        update purseTest;
        Account accountTest = new Account();
        accountTest.AV_Cliente__c = true;
        accountTest.CC_Numero_Documento__c = '00000000Z';
        accountTest.Name = 'Prueba';
        accountTest.RecordTypeId = rtPAccountTest.Id;
        
        lstAccount.add(accountTest);
        insert lstAccount;
        lstAccount.add(accTest);
        AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(accountTest, purseTest);
        AV_BookMember__c bookMemberTest2 = CIBE_TestHelper.createBookMember(accTest, purseTest);
        Test.startTest();
            lstAssert = CIBE_AccountTriggerHelper.getNegocio(lstAccount);
        Test.stopTest();
        System.assertEquals(lstAssert.size()>0, true);
    }
    
    
    /**
	 * Execute the Trigger class (CIBE_Account_BU_TRHan y CIBE_Account_BI_TRHan)
	 */
    @isTest
    public static void updateRatingPD_Test() {
        CIBE_PD__c metadata = new CIBE_PD__c();
        metadata.CIBE_PDRating__c = 'AAA';
        metadata.CIBE_FechaCarga__c = Date.parse('20/12/2022');
        metadata.CIBE_PDMin__c = 0;
        metadata.CIBE_PDMax__c = 100;
       	insert metadata;

    	RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = 'Name',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '123',
            AV_Negocio__c = 'CIB',
            CIBE_PD__c = 90,
            AV_Rating__c = '7.5'
        );
        insert acc;
        
        Account accBf = [SELECT Id, CIBE_FechaRating_SP__c FROM Account LIMIT 1];
        System.assert(accBf.CIBE_FechaRating_SP__c != Null); 
    }
    
}