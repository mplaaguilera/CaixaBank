/**********************************************************************************************************************
Name:      AV_HeaderCustomTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_HeaderCustomActivityTriggerHelper
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY		AUTHOR              DATE                Description
    1.0            Temas    		Jashanpreet         02/06/2021          Init version
    1.1		       Fix PMD Errors	Daniel Rodriguez	21/11/2023	        Modify all test
***********************************************************************************************************************/
@isTest
public with sharing class AV_HeaderCustomTriggerHelper_Test {

    @TestSetup
	static void setup(){
        Test.startTest();
        User us= AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        Task tsk = AV_TestHelper.createTareaOtherExternalID(us);
        Contact empleado  = AV_TestHelper.createEmployee(null, us);
        //empleado.CC_Matricula__c= '64735647654752343';
        //update empleado;
        Account acc=AV_TestHelper.createCustomer();
        Test.stopTest();
        Opportunity opp = AV_TestHelper.createOpportunityExternalId(acc, empleado, '123456');
        AV_CustomActivityOpportunity__c cAct = AV_TestHelper.createTareaOportunidad(opp,tsk);
       

	}

    /**
	* Validate Sync videoCall
	*/
    @isTest
    private static void validateHelper() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		System.runAs(userGcf){
            Test.startTest();
            AV_HeaderCustomActivity__c cabeceraTarea = [SELECT Id,AV_UrlTeams__c,RecordTypeId FROM AV_HeaderCustomActivity__c LIMIT 1];
            cabeceraTarea.AV_UrlTeams__c='https://www.google.com/';
            update cabeceraTarea;
            AV_HeaderCustomActivityTriggerHelper.checkGeneralRT(new List<AV_HeaderCustomActivity__c>{cabeceraTarea});
            Test.stopTest();
            System.assertNotEquals(null, cabeceraTarea, 'KO');
        }
    }

}