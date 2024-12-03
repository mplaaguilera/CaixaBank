@isTest
public with sharing class CIBE_DetailExpCliente_Controller_Test {
    @TestSetup
    static void makeData(){
        Account acc = CIBE_TestHelper.createCustomerWithNumperson('13550');
        User adminCIBE = CIBE_TestHelper.createUser('System Administrator');
        user cIBUser;
        System.runAs(adminCIBE) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '1234', new List<String>{'CIBE_OperativaCIB', 'CIBE_OperativaEMP', 'CIBE_Integracion'});
        }
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CIBE_getSurveyDataExpCliente';
		wsc.NamedCredential__c = 'callout:API_GWT_PRO/marketing/customerSurveys/v2/customers/id/surveys';
		insert wsc;
        test.setCreatedDate(wsc.id, dateTime.newInstance(2023, 5, 1));
        update wsc;
    }
    @isTest
    public static void retrieveDataTest() { 
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234']; 
        Account acc = [SELECT Id, AV_NumPerso__c FROM Account WHERE AV_NumPerso__c = '13550' LIMIT 1];
        System.runAs(usrTest) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('ExpCliente', 'OK'));
            String result = CIBE_DetailExpCliente_Controller.retrieveData(acc.AV_NumPerso__c, acc.Id);
            Test.stopTest();
            List<CIBE_DetailExpCliente_Controller.SurveyBundle> data =
                (List<CIBE_DetailExpCliente_Controller.SurveyBundle>)JSON.deserialize(result, List<CIBE_DetailExpCliente_Controller.SurveyBundle>.class);
            System.assertEquals(true, String.isNotBlank(data.get(0).momento), 'Could not get data');
        }
    }
    @isTest
    public static void retrieveNoContent() { 
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234']; 
        Account acc = [SELECT Id, AV_NumPerso__c FROM Account WHERE AV_NumPerso__c = '13550' LIMIT 1];
        CIBE_CustomersSurveys_Integration.SurveyResponse expectedResponse = new CIBE_CustomersSurveys_Integration.SurveyResponse();
        expectedResponse.statusCode = 204;
        System.runAs(usrTest) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('ExpCliente', 'NO CONTENT'));
                CIBE_CustomersSurveys_Integration.SurveyResponse actualResponse = CIBE_CustomersSurveys_Integration.getSurveyData(acc.AV_NumPerso__c);
            Test.stopTest();
        System.assertNotEquals(204, actualResponse.statusCode);
        }
    }
}