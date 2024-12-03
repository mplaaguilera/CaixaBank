/**********************************************************************************************************************
 Name:      AV_DeleteRecordsAlertBatch_test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Test de la clase AV_DeleteRecordsAlertBatch
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          Maria Telleria   23/04/2020          Init version
   1.1			  App FSC		   Sandra Gómez		04/11/2020		    Refactor

***********************************************************************************************************************/
@isTest
public class AV_DeleteRecordsAlertBatch_Test {

    /**
     * Create 10 Alerts with the field  To Delete checked.
    */ 
    @TestSetup
    static void setup() {
        AV_TestHelper.activateLogger();

        // Insert 10 Alerts
        List<FinServ__Alert__c> alerts = new List<FinServ__Alert__c>();
        for (Integer i=0;i<10;i++) {
            alerts.add(new FinServ__Alert__c(AV_ToDelete__c=true,FinServ__Message__c='TEST'));
        }
        
        insert alerts;

    }

    /**
     * Execute the Batch class (AV_DeleteRecordsAlertBatch) and check if the alerts created in te previous method are deleted.
     */
    @isTest
    static void executeBatchDeleteRecord() {
        System.assertEquals(10, [select count() from FinServ__Alert__c where AV_ToDelete__c = true]);
        Test.startTest();
        AV_DeleteRecordsAlertBatch obj = new AV_DeleteRecordsAlertBatch();
		DataBase.executeBatch(obj);
        Test.stopTest();
        // Check if the inserted Alerts are deleted correctly
        System.assertEquals(0, [select count() from FinServ__Alert__c where AV_ToDelete__c = true]);
    }
    
}