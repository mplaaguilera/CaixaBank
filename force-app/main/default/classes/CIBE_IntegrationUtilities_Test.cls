/**********************************************************************************************************************
 Name:      CIBE_IntegrationUtilities_Test
 Copyright © 2023  CaixaBank
=======================================================================================================================
Proposito: CIBE_IntegrationUtilities Test Class
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
1.0                US559793       Alexandre Perez  02/08/2023          Created
2.0                               Borja Lavesiera   07/05/2024         Cambios Método updateObjectNullKO
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_IntegrationUtilities_Test {
    @TestSetup
    static void makeData(){
        User cIBUser = CIBE_TestHelper.createUser('CIBE_Gestor', '1234');
        System.runAs(cIBUser) {
            CIBE_TestHelper.createCustomer();
        }
    }

    @isTest
    private static void metadataTest() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        CC_InterfaceSettings__mdt dataInterface;
        System.runAs(usrTest){
            test.startTest();
            dataInterface = CIBE_IntegrationUtilities.fetchMetadataInterface(CIBE_Teams_Integration.AV_TEAMSLOGIN);
            test.stopTest();
        }
        system.assert(dataInterface != null);
    }

    @isTest
    private static void updateObject() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        string sError;
        map<string, object> fieldsToUpdate = new map<string, object>();
        account accTest;
        System.runAs(usrTest) {
            accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123'];
            fieldsToUpdate.put('CIBE_FechaRefrescoCirbe__c', dateTime.now());
            fieldsToUpdate.put('Id', accTest.Id);
            test.startTest();
            sError = CIBE_IntegrationUtilities.updateObject(fieldsToUpdate, 'Account');
            test.stopTest();
        }
        system.assert(string.isBlank(sError));
    }

    @isTest
    private static void updateObjectKO() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        string sError;
        map<string, object> fieldsToUpdate = new map<string, object>();
        account accTest;
        System.runAs(usrTest) {
            accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123'];
            fieldsToUpdate.put('CIBE_FechaRefrescoCirbe__c', dateTime.now());
            test.startTest();
            sError = CIBE_IntegrationUtilities.updateObject(fieldsToUpdate, 'Account');
            test.stopTest();
        }
        system.assert(string.isNotBlank(sError));
    }

    // tests de update object null
    @isTest
    private static void updateObjectNull() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        string sError;
        map<string, object> fieldsToUpdate = new map<string, object>();
        account accTest;
        System.runAs(usrTest) {
            accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123'];
            fieldsToUpdate.put('CIBE_FechaRefrescoCirbe__c', null);
            fieldsToUpdate.put('Id', accTest.Id);
            test.startTest();
            sError = CIBE_IntegrationUtilities.updateObjectNull(fieldsToUpdate, 'Account');
            test.stopTest();
        }
        system.assert(string.isBlank(sError));
    }
    @isTest
    private static void updateObjectNullKO() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        string sError;
        map<string, object> fieldsToUpdate = new map<string, object>();
        account accTest;
        System.runAs(usrTest) {
            accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123'];
            fieldsToUpdate.put('CIBE_FechaRefrescoCirbe__c', null);
            Test.startTest();
            try {
                sError = CIBE_IntegrationUtilities.updateObjectNull(fieldsToUpdate, 'Account');
            } catch(DmlException e){
                system.debug('Error' +e.getMessage());
            System.assert(e.getMessage().contains('Id not specified in an update call'));
            }
            Test.stopTest();
        }
        System.assertNotEquals('', sError, 'Se esperaba un mensaje de error.');
    }
}