/**********************************************************************************************************************
Name: CIBE_SIR_IntegrationTest
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: clase test de CIBE_SIR_Integration
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY              AUTHOR                 DATE			Description
    1.0     US473463                Alexandre Pérez        19/06/2023       Initial version
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_SIR_IntegrationTest {
    @TestSetup
    static void setup(){

        List<CBK_IntegrationSetting__c> listEndpointConf = new list<CBK_IntegrationSetting__c>();
        CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(Name='getSir', NamedCredential__c = 'callout:API_GWT_CIBE/customerManagement/customerCreditRating/customers/id/scoring/risks/evaluable');
        listEndpointConf.add(endpointConf);
        insert listEndpointConf;

    }
    @isTest
    public static void sirIntegrationCalloutOK_Test() {
 
        User cIBUser;
        String result;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }
        Account dummyAcc;
        System.runAs(cIBUser) {
            dummyAcc = AV_TestHelper.createCustomer();
        }
        
        // Llama al método de integración
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('SIR','OK'));
        System.runAs(cIBUser) {
            result = CIBE_SIR_Integration.sirIntegrationCallout(dummyAcc.Id);
        }
        Test.stopTest();
        
        //la llamada es correcta y no debe devolver error
        System.assert(String.isBlank(result), 'No debería devolver error');
        
    }

    @istest
    public static void sirIntegrationCalloutKO_Test() {

        Account dummyAcc;
        User cIBUser;
        String result;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }

        System.runAs(cIBUser) {
            dummyAcc = AV_TestHelper.createCustomer();
        }

        boolean error = false;
        // Llama al método de integración
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('SIR','KO'));
        System.runAs(cIBUser) {
            try {
                result = CIBE_SIR_Integration.sirIntegrationCallout(dummyAcc.Id);
            } catch(Exception e) {
                error = true;
            }
        }
        Test.stopTest();
        
        //comprobar si devuelve error
        System.assert(error, 'Debería devolver error');
        
    }

    @istest
    public static void sirIntegrationCalloutRefresco_Test() {

        Account dummyAcc;
        User cIBUser;
        String result;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }

        System.runAs(cIBUser) {
            dummyAcc = AV_TestHelper.createCustomer();
            dummyAcc.CIBE_FechaRefrescoSIR__c = dateTime.now();
            update dummyAcc;
        }


        boolean error = false;
        // Llama al método de integración
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('SIR','KO'));
        System.runAs(cIBUser) {
            
            result = CIBE_SIR_Integration.sirIntegrationCallout(dummyAcc.Id);
        
        }
        Test.stopTest();
        
        //comprobar si devuelve error
        System.assertEquals('Han pasado menos de 24H desde el último refresco ' + dummyAcc.CIBE_FechaRefrescoSIR__c.format('d/M/y H:m'), result, 'Debería devolver el mensaje 24h para refrescar');
        
    }

    @istest
    public static void sirIntegrationCalloutJsonKO_Test() {

        Account dummyAcc;
        User cIBUser;
        String result;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }

        System.runAs(cIBUser) {
            dummyAcc = AV_TestHelper.createCustomer();
            //dummyAcc.CIBE_FechaRefrescoSIR__c = dateTime.now();
            //update dummyAcc;
        }


        boolean error = false;
        // Llama al método de integración
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('SIR','JsonOK'));
        System.runAs(cIBUser) {
            try {
                result = CIBE_SIR_Integration.sirIntegrationCallout(dummyAcc.Id);
            } catch (Exception e) {
                error = true;
            }
        
        }
        Test.stopTest();
        
        //comprobar si devuelve error
        System.assert(error, 'Debería devolver error APEX');
        
    }
}