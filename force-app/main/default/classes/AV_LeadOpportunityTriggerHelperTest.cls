/**********************************************************************************************************************
Name:	  AV_LeadOpportunityTriggerHelperTest
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_LeadOpportunityTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE			Description
    1.0			Test Class		Vladislav Lityagin		20/05/2022		Init version
	1.1			US449777		Carolina Alonso			06/10/2022		Add activateLogger() method to create custom setting for bypass used in forbidden words
	1.2			US378818		Vladislav Lityagin		14/10/2022		Modified methods to increase coverage
    1.3         Fix             Patricia Villacañas     17/05/2023      Modified to set run as
***********************************************************************************************************************/
@isTest
public with sharing class AV_LeadOpportunityTriggerHelperTest {
    
	@TestSetup
	static void setup(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');
        userGestor.Alias = 'gest';
        userGestor.Email = 'gestor-test@test.com';
        userGestor.IsActive = true;
        insert userGestor;

        System.runAs(userGcf){
            AV_TestHelper.activateLogger();
			AV_TestHelper.createForbiddenWords();
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AV_PlataformasHipotecarias' LIMIT 1];
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

            Account acc = AV_TestHelper.createCustomerSinInsert();
            List<AV_LeadOpportunity__c> leadOppList = new List<AV_LeadOpportunity__c>();
            List<Lead> leadList = new List<Lead>();
            insert acc;
            //User usrTestApiOnly = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
            RecordType rtLeadOpp = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_LEADOPP, AV_AppConstants.LEAD_PPHH_RT);
            RecordType rtLead = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_LEAD, AV_AppConstants.LEAD_PPHH_RT);
            Product2 pf = AV_TestHelper.createProduct2(null, '50030');
            Lead l1 = AV_TestHelper.createLeadSinInsert(rtLead);
            /*l1.FirstName = 'Test 1';
            l1.LastName = 'Lead 1';
            l1.Status = 'New';
            Date.newInstance(2001, 12, 9);*/
            l1.AV_CustomerId__c = 'X1234567A';
            l1.Email = 'test@gmail.com';
            l1.MobilePhone = '633657845';
            l1.AV_IsClient__c = false;
            l1.AV_numperso__c = acc.Id;
            l1.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_LEAD, AV_AppConstants.LEAD_PPHH_RT).Id;  //mio
            leadList.add(l1);
            
            Lead l2 = AV_TestHelper.createLeadSinInsert(rtLead);
            /*l2.FirstName = 'Test 2';
            l2.LastName = 'Lead 2';
            l2.Status = 'New';
            Date.newInstance(2001, 12, 9);*/
            l2.AV_CustomerId__c = 'X1234562A';
            l2.Email = 'test2@gmail.com';
            l2.MobilePhone = '633227845';
            l2.AV_IsClient__c = true;
            l2.AV_numperso__c = acc.Id;
            leadList.add(l2);
            //insert leadList;
            
            
            Lead l3 = AV_TestHelper.createLeadSinInsert(rtLead);
            l3.AV_CustomerId__c = 'X1234567A';
            l3.Email = 'test3@gmail.com';
            l2.MobilePhone = '633227845';
            l2.AV_IsClient__c = true;
            l3.AV_numperso__c = acc.Id;
            l3.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_LEAD, AV_AppConstants.LEAD_PPHH_RT).Id;
            leadList.add(l3);
            insert leadList;
            
           
            AV_LeadOpportunity__c leadOpp = AV_TestHelper.createLeadOpportunitySinInsert(l1, rtLeadOpp);
            //leadOpp.AV_Status__c = '01';
            //leadOpp.AV_DueDate__c = Date.newInstance(2000, 12, 9);
            leadOpp.AV_CreationDate__c = Date.today();
            leadOpp.AV_Lead2__c = l2.Id;
            leadOpp.AV_EstadoEnvioOfComercial__c= '1';
            leadOpp.AV_Lead__c = l1.Id; 
            leadOppList.add(leadOpp);
            //AV_LeadOpportunity__c leadOpp2 = AV_TestHelper.createRejectedLeadOpportunity(l1);
            insert leadOppList;
            
            
        }
	}
    	

	/**
	 * Execute the Trigger class (AV_LeadOpportunity_BI_TRHan && AV_LeadOpportunity_BU_TRHan) and check the OwnerId
	 */
	@isTest
	private static void executeUpdateLeadOpportunityStatus() {
		Test.startTest();
        //User u = [SELECT Id from User WHERE AV_ExternalID__c = 'U0109003' LIMIT 1];
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		AV_LeadOpportunity__c loOld = [SELECT Id, Name, AV_StatusLeadOpp__c, AV_Status__c, AV_FechaCierreGestion__c from AV_LeadOpportunity__c LIMIT 1];
        
        System.runAs(userGcf){
            loOld.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_POSITIVA;
            Database.update(loOld);
            loOld.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_NO_APTO;
            Database.update(loOld);
            loOld.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_GESTION;
			Database.update(loOld);
        }
        Test.stopTest();
        AV_LeadOpportunity__c lo = [SELECT Id, Name, AV_StatusLeadOpp__c, AV_Status__c FROM AV_LeadOpportunity__c LIMIT 1];
        System.assertEquals(AV_AppConstants.LEADOPP_STATUS_ACTIVO, lo.AV_Status__c, 'executeUpdateLeadOpportunityStatus');
		
	}
    
    @isTest
	public static void validateCheckLeadOppStatus(){
		Test.startTest();
        AV_LeadOpportunity__c loOld = [SELECT Id, AV_StatusLeadOpp__c, AV_Resolution__c, AV_EstadoEnvioOfComercial__c FROM AV_LeadOpportunity__c WHERE AV_StatusLeadOpp__c =: AV_AppConstants.OPP_STATUS_POTENCIAL LIMIT 1];
        //User u = [SELECT Id from User WHERE AV_ExternalID__c = 'U0109003' LIMIT 1];
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        System.runAs(userGcf){
            loOld.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_POSITIVA;
            Database.update(loOld);
        }
		loOld.AV_EstadoEnvioOfComercial__c = '1';
        Database.update(loOld);
        Test.stopTest();
		AV_LeadOpportunity__c loNew = [SELECT Id, AV_StatusLeadOpp__c, AV_Resolution__c FROM AV_LeadOpportunity__c WHERE Id = :loOld.Id LIMIT 1];
        System.assertEquals(null,loNew.AV_Resolution__c, 'validateCheckLeadOppStatus');
	}
    
    @isTest
    private static void checkHolderIsClientTestHolder2() {
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
        List<Lead> le = [Select id from Lead where Email = 'test3@gmail.com' limit 1];
		Test.startTest();
        System.runAs(userGestor){
            String typeOfHolder = 'holder2';
            List<AV_LeadOpportunity__c> leadOppList = new List<AV_LeadOpportunity__c>();
            AV_LeadOpportunity__c leadOpp = new AV_LeadOpportunity__c();
            leadOpp.AV_Comment__c = 'ABELLOTS and CAUCASIC';
            leadOpp.AV_CreationDate__c = Date.today();
            leadOpp.AV_Lead__c = le[0].Id;
            leadOpp.AV_Status__c = AV_AppConstants.LEADOPP_STATUS_NUEVO;
            leadOpp.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_POTENCIAL;
            leadOppList.add(leadOpp);
    
            AV_LeadOpportunityTriggerHelper.checkHolderIsClient(leadOppList, typeOfHolder);
            Test.stopTest();
            Date myDate = Date.today().addDays(30);
            AV_LeadOpportunity__c lo = [SELECT Id, AV_DueDate__c, AV_Lead2__r.AV_DueDateLead__c FROM AV_LeadOpportunity__c WHERE AV_Lead2__c!=NULL LIMIT 1];
            System.assertEquals(lo.AV_DueDate__c,myDate);
        }
            
    }
    
    @isTest
    private static void checkHolderIsClientTestHolder1() {
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
        List<Lead> le = [Select id from Lead where AV_CustomerId__c = 'X1234567A' limit 1];
		Test.startTest();
        System.runAs(userGestor){
            String typeOfHolder = 'holder1';
            List<AV_LeadOpportunity__c> leadOppList = new List<AV_LeadOpportunity__c>();
            AV_LeadOpportunity__c leadOpp = new AV_LeadOpportunity__c();
            leadOpp.AV_Comment__c = 'ABELLOTS and CAUCASIC';
            leadOpp.AV_CreationDate__c = Date.today();
            leadOpp.AV_Lead__c = le[0].Id;
            leadOpp.AV_Status__c = AV_AppConstants.LEADOPP_STATUS_NUEVO;
            leadOpp.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_POTENCIAL;
            leadOppList.add(leadOpp);
    
            AV_LeadOpportunityTriggerHelper.checkHolderIsClient(leadOppList, typeOfHolder);
            Test.stopTest();
            Date myDate = Date.today().addDays(30);
            AV_LeadOpportunity__c lo = [SELECT Id, AV_DueDate__c, AV_Lead2__r.AV_DueDateLead__c FROM AV_LeadOpportunity__c WHERE AV_Lead2__c!=NULL LIMIT 1];
            System.assertEquals(lo.AV_DueDate__c,myDate);
        }
            
    }
    
}