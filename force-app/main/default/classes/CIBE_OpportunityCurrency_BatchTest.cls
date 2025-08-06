/**********************************************************************************************************************
 Name:      CIBE_AppConstants
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test que cubre el batch  CIBE_OpportunityCurrency_Batch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION        USER_STORY       AUTHOR           DATE                Description
   	1.0            Create Test	    Jose Maria       21/12/2022          Init version
	
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_OpportunityCurrency_BatchTest {
     
	@isTest
    private static void calculateCurrencyTEST() {
        CIBE_Divisas__c divisa =  new CIBE_Divisas__c();
        divisa.CIBE_DivisaBase__c ='166' ;
        divisa.CIBE_CodigoDivisa__c = 'ESP';
        divisa.CIBE_NombreDivisa__c = 'PESETA';
        divisa.CIBE_FechaTipoCambio__c = System.Today();
        
        insert divisa;
        
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account accTest = CIBE_TestHelper.createConfidencialCustomer();
        Account cenTest = CIBE_TestHelper.createCaixaCenter();
       
        
        Contact conTest = CIBE_TestHelper.createEmployee(cenTest, usrTest);
       
        
        
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        Opportunity opp = new Opportunity();
        opp.AccountId = accTest.Id;
        opp.AV_ExternalID__c = '00000001';
        opp.Name = 'Alerta Comercial';
        opp.StageName = 'Potencial';
        opp.CIBE_Divisa__c = 'ESP';
        opp.RecordTypeId = rt.Id;
        opp.CloseDate = System.today() + 5;
        opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
        opp.AV_Gestor__c = conTest.Id;
        opp.AV_PF__c = prodPF.Id;
        insert opp;
        
 		Test.StartTest();
        CIBE_OpportunityCurrency_Batch batch = new CIBE_OpportunityCurrency_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
        
       
        
        List<Opportunity> listOpp=[Select Id,CIBE_FechaCambioDivisa__c from Opportunity];
        if(!listOpp.isEmpty()){
        	System.assertNotEquals(listOpp[0].CIBE_FechaCambioDivisa__c,null);    
        } 
    }
    
}