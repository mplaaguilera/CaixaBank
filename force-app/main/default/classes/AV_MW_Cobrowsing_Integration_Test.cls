/**********************************************************************************************************************
Name: AV_MW_Cobrowsing_Integration
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: clase test - Integración Cobrowsing - Unblu
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY              AUTHOR                 DATE			   Description
    1.0                             Bea y Ali              28/6/2024       Initial version
***********************************************************************************************************************/

@isTest
public with sharing class AV_MW_Cobrowsing_Integration_Test {
    @TestSetup
    static void setup(){
        User usrGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U01Test', 'AV_SistematicaComercial');
        User usrAdmin = AV_TestHelper.createUser('System Administrator');
        AV_TestHelper.insertPermissionSet(usrGestor.Id, 'AV_Cobrowsing');
        AV_TestHelper.insertNeededPermissions(usrGestor);
        // Usuario de cli para insertar el account
        User usuarioCli =[SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
        
        System.runAs(usrAdmin){
            CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(
				Name= 'AV_Cobrowsing', 
				NamedCredential__c = 'callout:API_GWT_MC_PRO/crossChannel/screenSharing/customers/id/calls');
            insert endpointConf;
        }

        System.runAs(usuarioCli){
            Account acc = AV_TestHelper.createCustomerSinInsert();
                acc.AV_Numperso__c = '4439444';
                acc.OwnerId = usrGestor.Id;
            insert acc;

            Case caso = new Case();
                caso.Subject = 'Test cobrowsing';
                caso.Status = 'New';
                caso.Description = 'Test cobrowsing';
                caso.AccountId = acc.Id;
                caso.OwnerId = usrGestor.Id;
                caso.Priority = 'High';
            insert caso;
        }
    }

    @isTest
    public static void cobrowsingIntegrationCalloutOKTest() {

        User usrGestor = [SELECT Id FROM USER WHERE AV_ExternalID__c = 'U01Test' LIMIT 1];
        String pinCode = '539406';
        String result;
        
        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('COBROWSING','OK'));

            System.runAs(usrGestor) {
                Account acc = [SELECT Id, RecordType.DeveloperName FROM Account WHERE AV_NumPerso__c = '4439444' LIMIT 1];
                result = AV_MW_Cobrowsing_Integration.cobrowsingIntegrationCallout(acc.Id, pinCode);
            }

        Test.stopTest();

        System.assert(!result.contains('301'), 'Correcto');
    }

      @isTest
    public static void cobrowsingIntegrationCalloutOKTestCaso() {

        User usrGestor = [SELECT Id FROM USER WHERE AV_ExternalID__c = 'U01Test' LIMIT 1];
        String pinCode = '539406';
        String result;
        
        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('COBROWSING','OK'));

            System.runAs(usrGestor) {
                //Account acc = [SELECT Id, RecordType.DeveloperName FROM Account WHERE AV_NumPerso__c = '4439444' LIMIT 1];
                Case caso = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Subject = 'Test cobrowsing' LIMIT 1];
                result = AV_MW_Cobrowsing_Integration.cobrowsingIntegrationCallout(caso.Id, pinCode);
            }

        Test.stopTest();

        System.assert(!result.contains('301'), 'Correcto');
    }

    @isTest
    public static void cobrowsingIntegrationCalloutKOTest() {
        User usrGestor = [SELECT Id FROM USER WHERE AV_ExternalID__c = 'U01Test' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '4439444' LIMIT 1];
        String result;
        
        Test.startTest();
            boolean error = false;
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('COBROWSING','KO'));

            System.runAs(usrGestor) {

                try {
                    result = AV_MW_Cobrowsing_Integration.cobrowsingIntegrationCallout(acc.Id, null);
                } catch(Exception e) {
                    error = true;
                }        
            
            }
        Test.stopTest();
        // System.assert(error, 'Debería devolver error APEX');
        System.assert(!result.contains('201'), 'error');
    }
    
    @IsTest
    static void callTestOK() {
        User usrGestor = [SELECT Id FROM USER WHERE AV_ExternalID__c = 'U01Test' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '4439444' LIMIT 1];
        Object result;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('COBROWSING','OK'));
            System.runAs(usrGestor) {
                AV_MW_Cobrowsing_Integration myCallable = new AV_MW_Cobrowsing_Integration();
                Map<String, Object> args = new Map<String, Object>{
                    'recordId' => acc.Id,
                    'pinCode' => '539406'
                };
                result = myCallable.call('cobrowsingIntegrationCallout', args);
            }
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
    
    @IsTest
    static void callTestKO() {
        User usrGestor = [SELECT Id FROM USER WHERE AV_ExternalID__c = 'U01Test' LIMIT 1];
        AV_MW_Cobrowsing_Integration myCallable = new AV_MW_Cobrowsing_Integration();

        Map<String, Object> args = new Map<String, Object>();
        System.runAs(usrGestor) {
            try {
                myCallable.call('nonExistentAction', args);
                System.assert(false, 'Expected CalloutException was not thrown');
            } catch (CalloutException e) {
                System.assertEquals('Method not implemented', e.getMessage());
            }
        }
    }
}