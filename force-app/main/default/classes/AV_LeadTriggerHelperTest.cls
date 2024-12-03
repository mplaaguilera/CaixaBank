/**********************************************************************************************************************
Name:	  AV_LeadTriggerHelperTest
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_LeadTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE			Description
    1.0			Test Class		Vladislav Lityagin		20/05/2022		Init version
    1.1         Fix             Patricia Villacañas     17/05/2023      Modified to set run as
***********************************************************************************************************************/
@isTest
public with sharing class AV_LeadTriggerHelperTest {
    
    @TestSetup
	static void setup(){ 

        User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');
        userGestor.Alias = 'gest';
        userGestor.Email = 'gestor-test@test.com';
        userGestor.IsActive = true;
        insert userGestor;

        System.runAs(userGestor){
            AV_TestHelper.activateLogger();
			AV_TestHelper.createForbiddenWords();
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AV_NowInDirectores'];
            List<PermissionSetGroupComponent> psgcList = [SELECT PermissionSetId FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName = 'AV_Gestor'];
            List<PermissionSetAssignment> psToInsert = new List<PermissionSetAssignment>{
                new PermissionSetAssignment(
                    AssigneeId = userGestor.Id,
                    PermissionSetId = ps.Id
                )
            };
            for(PermissionSetGroupComponent psgc : psgcList){
                psToInsert.add(
                    new PermissionSetAssignment(
                        AssigneeId = userGestor.Id,
                        PermissionSetId = psgc.PermissionSetId
                    )
                );
            }
            insert psToInsert;
            RecordType rtLeadOpp = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', AV_AppConstants.LEAD_PPHH_RT);
            RecordType rtLead = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_LEAD, AV_AppConstants.LEAD_PPHH_RT);
            Product2 pf = AV_TestHelper.createProduct2(null, '50030');
            
            Account acc1= AV_TestHelper.createCustomerSinInsert();
            insert(acc1);
            
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
            l1.AV_IsClient__c = false;
            l1.AV_Requester__c=true;
            l1.AV_Country__c='ESP';
            l1.AV_CustomerType__c='1';
            l1.AV_IssuingCountry__c='ESP';
            l1.AV_Birthdate__c=Date.newInstance(1968, 12, 9);
            l1.AV_numperso__c=acc1.Id;
            
            
            insert l1;
            
            List<AV_LeadOpportunity__c> leadOppList = new List<AV_LeadOpportunity__c>();
            AV_LeadOpportunity__c leadOpp = new AV_LeadOpportunity__c();
            leadOpp.AV_ContracType1__c = '01';
            leadOpp.AV_ContracType2__c = '01';
            leadOpp.AV_Status__c = '01';
            leadOpp.AV_Amount1__c = 25000;
            leadOpp.AV_Amount2__c = 52000;
            leadOpp.RecordTypeId = rtLeadOpp.Id;
            leadOpp.AV_CurrentBalanceAmount1__c = 1450;
            leadOpp.AV_CurrentBalanceAmount2__c = 4350;
            leadOpp.AV_InstallmentAmount1__c = 2345;
            leadOpp.AV_InstallmentAmount2__c = 5634;
            leadOpp.AV_SavingsAmountAmount__c = 10000;
            leadOpp.AV_DueDate__c = Date.newInstance(2000, 12, 9);
            leadOpp.AV_StatusLeadOpp__c = 'Potencial';
            leadOpp.AV_CreationDate__c = Date.today();
            leadOpp.AV_EstadoEnvioOfComercial__c='1';
            leadOpp.AV_Lead__c = l1.Id;
            leadOpp.AV_Lead2__c = null;
            
            
            leadOppList.add(leadOpp);
            //AV_LeadOpportunity__c leadOpp2 = new AV_LeadOpportunity__c();
            //leadOpp2.AV_EstadoEnvioOfComercial__c='1';
            //leadOpp2= AV_TestHelper.createRejectedLeadOpportunity(l1);
            
            
            AV_LeadOpportunity__c leadOpp2 = new AV_LeadOpportunity__c();
            leadOpp2.AV_ContracType1__c = '01';
            leadOpp2.AV_ContracType2__c = '01';
            leadOpp2.AV_Status__c = '01';
            leadOpp2.AV_Amount1__c = 25000;
            leadOpp2.AV_Amount2__c = 52000;
            leadOpp2.RecordTypeId = rtLeadOpp.Id;
            leadOpp2.AV_CurrentBalanceAmount1__c = 1450;
            leadOpp2.AV_CurrentBalanceAmount2__c = 4350;
            leadOpp2.AV_InstallmentAmount1__c = 2345;
            leadOpp2.AV_InstallmentAmount2__c = 5634;
            leadOpp2.AV_SavingsAmountAmount__c = 10000;
            leadOpp2.AV_DueDate__c = Date.newInstance(2000, 12, 9);
            leadOpp2.AV_StatusLeadOpp__c = 'Potencial';
            leadOpp2.AV_CreationDate__c = Date.today();
            leadOpp2.AV_EstadoEnvioOfComercial__c='1';
            leadOpp2.AV_Lead__c = null;
            leadOpp2.AV_Lead2__c = l1.Id;
            
            
            leadOppList.add(leadOpp2);
             
            insert leadOppList;
            
            AV_TestHelper.createLeadSinInsert(rtLead);
        }
		
	} 
	/**
	 * Execute the Trigger class (AV_Lead_BU_TRHan) and check the OwnerId
	 */
    
	@isTest
	private static void executeUpdateLeadStatus() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		Test.startTest();
        System.runAs(userGcf){
            Lead lOld = [SELECT Id, Name, AV_IsClient__c, Status from Lead WHERE AV_CustomerId__c = 'X1234567A' LIMIT 1];
            lOld.AV_IsClient__c = true;
            Database.update(lOld);
        }
		Test.stopTest();
        Lead l = [SELECT Id, Name, AV_IsClient__c, Status from Lead WHERE AV_CustomerId__c = 'X1234567A' LIMIT 1];
        System.assertEquals('Convertido', l.Status);

	}
    
    @isTest
    private static void checkLeadOpportunityHoldersTest(){
		Test.startTest();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		//User u = [SELECT Id from User WHERE AV_ExternalId__c = 'U0109003' LIMIT 1];
        AV_LeadOpportunity__c lTest = [SELECT id FROM AV_LeadOpportunity__c LIMIT 1];
        Set<Id> setTestIdLead = new Set<Id>{lTest.id};
        System.runAs(userGcf){
            AV_LeadTriggerHelper.checkLeadOpportunityHolders(setTestIdLead);   
        }
    	Test.stopTest();
        System.assertNotEquals(null, setTestIdLead);
    }
    
    
   
}