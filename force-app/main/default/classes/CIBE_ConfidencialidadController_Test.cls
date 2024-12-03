/**********************************************************************************************************************
Name:	  CIBE_ConfidencialidadController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_ConfidencialidadController"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Alex Campos 		28/06/2022		Init version
    2.0         US527030        Jose Maria          14/02/2023      Añadido el update de ESG
    3.0         US527030        Luis                24/07/2023      Añadido el test update ECA y Sindicaciones

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class CIBE_ConfidencialidadController_Test {
    
    /***********************************************************************************************************/
    @TestSetup
    static void setup(){
        
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        System.runAs(usuario){
            Account accTest = CIBE_TestHelper.createConfidencialCustomer();
            Contact conTest = CIBE_TestHelper.createEmployee(accTest, usuario);
            CIBE_TestHelper.createOpportunityWithEmpleado(accTest, conTest);
        }
    
    }
    /***********************************************************************************************************/
    @isTest
    private static void createNotificationTEST() {
        User usuario = [SELECT id FROM User Where profile.Name =:CIBE_AppConstants.CIBE_GESTOR AND AV_NumeroOficinaEmpresa__c = '001-03044' Limit 1];
		System.runAs(usuario){
            Test.startTest();
                List<Opportunity> opps = [SELECT Id, OwnerId FROM Opportunity];
                
                
                if(!opps.isEmpty()){
                    CIBE_ConfidencialidadController.createNotification(opps.get(0).Id);
                    System.assert(!opps.isEmpty());
                    System.assert([SELECT Id, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opps.get(0).Id AND UserId != :opps.get(0).OwnerId].isEmpty());
                }
        	Test.stopTest();
        }
    }
    /***********************************************************************************************************/
  	@isTest
    private static void esgTEST() {
        User usuario = [SELECT id FROM User Where profile.Name =:CIBE_AppConstants.CIBE_GESTOR AND AV_NumeroOficinaEmpresa__c = '001-03044' Limit 1];
		System.runAs(usuario){
            Test.startTest();
                List<Opportunity> opps = [SELECT Id,CIBE_ESG__c FROM Opportunity];
                if(!opps.isEmpty()){
                    CIBE_ConfidencialidadController.saveESG(opps.get(0).Id, true);
                    opps = [SELECT Id,CIBE_ESG__c FROM Opportunity];
                    System.assert(!opps.isEmpty());
                }
        	Test.stopTest();
        }
    }
    /***********************************************************************************************************/
    @isTest
    private static void saveFieldsTEST() {
        
        User usuario = [SELECT id FROM User Where profile.Name =:CIBE_AppConstants.CIBE_GESTOR AND AV_NumeroOficinaEmpresa__c = '001-03044' Limit 1];
		System.runAs(usuario){
            Test.startTest();
                List<Opportunity> opps = [SELECT Id,CIBE_ESG__c,CIBE_ECAs__c,CIBE_Sindicaciones__c, CIBE_Linea__c FROM Opportunity 
                WHERE AV_ExternalID__c = '00000001'AND Name = 'Alerta Comercial' AND StageName = 'Potencial' AND
                RecordType.DeveloperName =:CIBE_AppConstants.OPP_INICIATIVACIB_RT];
    
                if(!opps.isEmpty()){
                    CIBE_ConfidencialidadController.saveFields(opps.get(0).Id, true,'ecas');
                    CIBE_ConfidencialidadController.saveFields(opps.get(0).Id, true,'esg');
                    CIBE_ConfidencialidadController.saveFields(opps.get(0).Id, true,'sindicaciones');
                    CIBE_ConfidencialidadController.saveFields(opps.get(0).Id, true,'linea');

                    opps = [SELECT Id,CIBE_ESG__c,CIBE_ECAs__c,CIBE_Sindicaciones__c, CIBE_Linea__c FROM Opportunity];
                    System.assert(!opps.isEmpty());
                    System.assert(opps[0].CIBE_ESG__c);
                    System.assert(opps[0].CIBE_ECAs__c);
                    System.assert(opps[0].CIBE_Sindicaciones__c);
                    System.assert(opps[0].CIBE_Linea__c);
                }
            Test.stopTest();
        }
    }
    /***********************************************************************************************************/
    @isTest
    private static void getOpportunityRTTest() {
        
        User usuario = [SELECT id FROM User Where profile.Name =:CIBE_AppConstants.CIBE_GESTOR AND AV_NumeroOficinaEmpresa__c = '001-03044' Limit 1];
		System.runAs(usuario){
            Test.startTest();
            List<Opportunity> opps = [SELECT Id,CIBE_ESG__c,CIBE_ECAs__c,CIBE_Sindicaciones__c, CIBE_Linea__c FROM Opportunity 
            WHERE AV_ExternalID__c = '00000001'AND Name = 'Alerta Comercial' AND StageName = 'Potencial' AND
            RecordType.DeveloperName =:CIBE_AppConstants.OPP_INICIATIVACIB_RT];
                if(!opps.isEmpty()){
                    CIBE_ConfidencialidadController.getOpportunityRT(opps.get(0).Id);
                    opps = [SELECT Id,CIBE_ESG__c FROM Opportunity where id=:opps.get(0).Id];
                    System.assert(!opps.isEmpty());
                }
            Test.stopTest();
        }
    }
}