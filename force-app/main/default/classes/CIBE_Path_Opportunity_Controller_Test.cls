/**********************************************************************************************************************
Name:	  CIBE_Path_Opportunity_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test class for the controller for the LWC cibe_TaskTabs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US420186    	Jose Maria	  	    20/10/2021		Init version copy retail methods 
	
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_Path_Opportunity_Controller_Test {

    @TestSetup
    static void makeData(){

        ID rtOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.OPP_INICIATIVAEMP_RT).getRecordTypeId();
        ID rtOppCIB = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.OPP_INICIATIVACIB_RT).getRecordTypeId();


        CIBE_TestInitialSetup.setupInitialDataCIB();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today ];
        List<Opportunity> listaOpp = new List<Opportunity>();

        Account acc = CIBE_TestHelper.createCustomer(usuario);
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);

        Opportunity opp = new Opportunity();
            opp.ownerId = usuario.Id;
            opp.RecordTypeId = rtOppCIB;
            opp.CloseDate = System.today();
            opp.AccountId = acc.Id;
            opp.Name = 'Alerta Comercial Test';
            opp.StageName = 'En curso';
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.AV_PF__c = prodPF.Id;


        Opportunity opp2 = new Opportunity();
            opp2.ownerId = usuario.Id;
            opp2.RecordTypeId = rtOpp;
            opp2.CloseDate = System.today();
            opp2.AccountId = acc.Id;
            opp2.Name = 'Alerta Comercial Test2';
            opp2.StageName = 'En curso';
            opp2.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp2.AV_PF__c = prodPF.Id;

        listaOpp.add(opp); 
        listaOpp.add(opp2); 
        insert  listaOpp;

    }

    @isTest
    public static void validateCIB() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today ];

        System.runAs(usuario) {
			Test.startTest();
            List<Opportunity> listOoppCIB = [SELECT id FROM Opportunity WHERE Name = 'Alerta Comercial Test' LIMIT 1];
            System.assertEquals(1, listOoppCIB.size());
            Boolean oppCIB = CIBE_Path_Opportunity_Controller.getRecordTypeVerification(listOoppCIB[0].Id);
            System.assertEquals(true, oppCIB);
            
            List<Opportunity> listOoppEMP = [SELECT id FROM Opportunity WHERE Name = 'Alerta Comercial Test2' LIMIT 1];
            System.assertEquals(1, listOoppEMP.size());
            Boolean oppCEMP = CIBE_Path_Opportunity_Controller.getRecordTypeVerification(listOoppEMP[0].Id);
            System.assertEquals(false, oppCEMP);
		}
        
    }

    @isTest
    public static void validateEMP() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today ];

        System.runAs(usuario) {
			Test.startTest();
            List<Opportunity> listOoppCIB = [SELECT id FROM Opportunity WHERE Name = 'Alerta Comercial Test' LIMIT 1];
            System.assertEquals(1, listOoppCIB.size());
            Boolean oppCIB = CIBE_Path_Opportunity_Controller.oppEmp(listOoppCIB[0].Id);
            System.assertEquals(false, oppCIB);
            
            List<Opportunity> listOoppEMP = [SELECT id FROM Opportunity WHERE Name = 'Alerta Comercial Test2' LIMIT 1];
            System.assertEquals(1, listOoppEMP.size());
            Boolean oppCEMP = CIBE_Path_Opportunity_Controller.oppEmp(listOoppEMP[0].Id);
            System.assertEquals(true, oppCEMP);
		}
        
    }

}