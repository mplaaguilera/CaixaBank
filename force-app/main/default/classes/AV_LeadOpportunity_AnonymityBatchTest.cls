/**********************************************************************************************************************
 Name:	  AV_LeadOpportunity_AnonymityBatchTest
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_LeadOpportunity_AnonymityBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		     AUTHOR				 DATE				Description
	1.0			US345266		Vladislav Lityagin     03/05/2022			Init version
   
***********************************************************************************************************************/

@isTest
private class AV_LeadOpportunity_AnonymityBatchTest {
    
    @TestSetup
    static void setup(){
        
        RecordType rtLead = AV_AppUtilities.getRecordType('Lead', 'AV_PlataformasHipotecarias');
        RecordType rtLeadOpp = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', 'AV_PlataformasHipotecarias');

        Lead l1 = new Lead();
        l1.FirstName = 'Test 1';
        l1.LastName = 'Lead 1';
        l1.Status = 'New';
        Date.newInstance(2001, 12, 9);
        l1.AV_CustomerId__c = 'X1234567A';
        l1.Email = 'test@gmail.com';
        l1.AV_PhonePrefix__c = '34';
        l1.MobilePhone = '633657845';
		l1.RecordTypeId = rtLead.Id;  
        insert l1;
        
        Lead l2 = new Lead();
        l2.FirstName = 'Test 2';
        l2.LastName = 'Lead 2';
        l2.Status = 'New';
        l2.AV_Birthdate__c = Date.newInstance(2000, 12, 9);
        l2.AV_CustomerId__c = 'X3214567A';
        l2.Email = 'test2@gmail.com';
        l2.AV_PhonePrefix__c = '34';
        l2.MobilePhone = '648361068';
       	l2.RecordTypeId = rtLead.Id;  


        
        insert l2;
        
        AV_LeadOpportunity__c leadOpp = new AV_LeadOpportunity__c();
        leadOpp.AV_Lead__c = [SELECT Id from Lead where FirstName = 'Test 1' limit 1].Id;
        leadOpp.AV_Lead2__c = [SELECT Id from Lead where FirstName = 'Test 2' limit 1].Id;
		leadOpp.AV_ContracType1__c = '01';
        leadOpp.AV_ContracType2__c = '01';
        leadOpp.AV_Status__c = '01';
        leadOpp.AV_StatusLeadOpp__c = 'Potencial';
        leadOpp.AV_Amount1__c = 25000;
        leadOpp.AV_Amount2__c = 52000;
        leadOpp.RecordTypeId = rtLeadOpp.Id;
        leadOpp.AV_CurrentBalanceAmount1__c = 1450;
        leadOpp.AV_CurrentBalanceAmount2__c = 4350;
		leadOpp.AV_InstallmentAmount1__c = 2345;
		leadOpp.AV_InstallmentAmount2__c = 5634;
        leadOpp.AV_SavingsAmountAmount__c = 10000;
        leadOpp.AV_DueDate__c = Date.newInstance(2000, 12, 9);

        
        insert leadOpp;
    }

    @isTest
    static void executeLeadOpportunityAnonymityBatch() {
        
        AV_LeadOpportunity_AnonymityBatch batch = new AV_LeadOpportunity_AnonymityBatch();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        Lead l1 = [SELECT Id, Name FROM Lead where Status='New' limit 1];
        //System.assertEquals(l1.Name, '--', 'Lead Name whiten');
        
        AV_LeadOpportunity__c lo = [SELECT Id, AV_ContracType1__c, AV_ContracType1_AN__c FROM AV_LeadOpportunity__c limit 1];
        System.assertNotEquals(lo.AV_ContracType1__c, lo.AV_ContracType1_AN__c, 'Lead Name whiten');
    }
}