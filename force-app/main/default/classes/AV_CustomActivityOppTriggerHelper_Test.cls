/**********************************************************************************************************************
Name:	  AV_CustomActivityOppTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_CustomActivityOppTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Eric Vázquez	   	   13/10/2020		Init version
1.1			Test Class	   Esperanza Conde	   14/10/2020		Init version
1.2			PMD     	   Víctor Santiago	   26/03/2021		MATRICULA_SAMPLE changed to matriculaSample
1.3			Fix			   Sandra Gómez		   26/08/2021		Fix product opportunity
1.4			AV_Query IT	   Daniel Rodríguez	   03/02/2022	    Change AV_Query to SOQL for User and Account
1.5			Fix			   Sandra Gómez		   04/04/2022		Change Test
1.6			Fix			   Sandra Gómez		   09/06/2022		Change Test
1.7         US481618       Ángel Medina        18/01/2023       Add new method validateFillChannelField()
1.8                        Oscar Moreno        22/01/2024       The class is empty and add getCustomActivityOppTest method
***********************************************************************************************************************/
@isTest
public with sharing class AV_CustomActivityOppTriggerHelper_Test {

    @TestSetup
    static void setup(){
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser(null);
        Account client;
        Account center;
        Contact cntGestor;
        AV_TestHelper.insertNeededPermissions(userGestor);
        System.runAs(usuCli){
          
            center = AV_TestHelper.createCaixaCenterSinInsert();
            center.OwnerId = userGestor.Id;
            insert center;
            cntGestor = AV_TestHelper.createEmployee(center, userGestor);
            client = AV_TestHelper.createCustomerSinInsert();
            client.OwnerId = userGestor.Id;
            insert client;
            
        }
    }

    @isTest
    public static void validateCustomActivityOppTrigger(){
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U0009003'];
        Account client = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT];        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

        System.runAs(userGestor){
            Opportunity opp1 = AV_TestHelper.createOpportunity(client);
            Event ev1 = AV_TestHelper.createEvent(userGestor, System.today().addDays(1),client);
            ev1 = [SELECT Id,AV_Task__c FROM Event WHERE Id = :ev1.Id];
            AV_CustomActivityOpportunity__c cao = AV_TestHelper.createTareaOportunidad(opp1,ev1.AV_Task__c);

            List<AV_CustomActivityOpportunity__c> caoList = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = :opp1.Id];

            delete caoList;
            caoList = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = :opp1.Id];

            System.assert(caoList.isEmpty(),caoList);

        }
        Test.stopTest();
    }


}