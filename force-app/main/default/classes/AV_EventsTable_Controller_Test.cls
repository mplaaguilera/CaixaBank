/**********************************************************************************************************************
Name:	  AV_EventsTable_Controller_Test
Copyright © 2024  CaixaBank
=======================================================================================================================
Proposito: Test de la clase AV_EventsTable_Controller
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0         US796346        Gonzalo Ávila  	    20/03/2024		Init version

***********************************************************************************************************************/
@isTest
private class AV_EventsTable_Controller_Test {
    @TestSetup
	static void setup(){
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true LIMIT 1];
        AV_TestHelper.insertNeededPermissions(userGestor);
        DateTime activityTime= DateTime.now();

        System.runAs(userGcf){
            Account acc=AV_TestHelper.createCustomer();
            Opportunity testOpp = AV_TestHelper.createOpportunity(acc);
            Event testEvent = AV_TestHelper.createEvent(userGestor,activityTime, acc);
            }
    }
    
    @isTest
    static void testGetRecords_Opportunity() {
        Test.StartTest();
        User userGestor = [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U01545454'];        
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];

        System.runAs(userGestor){
            AV_EventsTable_Controller.DataResponse response = AV_EventsTable_Controller.getRecords(opp.Id, 'Opportunity');
            system.assertNotEquals(null, response);
        }
        Test.StopTest();
    }

    @isTest
    static void testGetRecords_Account() {
        Test.StartTest();
        User userGestor = [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U01545454'];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(userGestor){
        AV_EventsTable_Controller.DataResponse response = AV_EventsTable_Controller.getRecords(acc.Id, 'Account');
        system.assertNotEquals(null, response);
        }
        Test.StopTest();
    }

}