@isTest
public with sharing class CC_WS_Autenticacion_SAU_Test {

    @TestSetup
    static void makeData() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Supervisor Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);
        insert userList;

        System.runAs(usuario1) {
            Account cuenta = new Account(
                Name = 'Cuenta prueba',
                AV_NumPerso__c = '51304694'
            );
            insert cuenta;

            Account cuenta2 = new Account(
                Name = 'Cuenta prueba 2',
                AV_NumPerso__c = '1352710'
            );
            insert cuenta2;

            CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
            customSetting.Name = 'CC_Autenticacion_SAU';
            customSetting.NamedCredential__c = 'callout:API_GWT_TST_CCSF/eChannels/eBranchManagement/customers/id/contracts/validation';
            customSetting.RegistroTrazaIntegracion__c = true;
            insert customSetting;
        }
    }

    @isTest
    static void testOK() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Usuario Supervisor Prueba'];
        Account cuenta = [SELECT AV_NumPerso__c FROM Account WHERE AV_NumPerso__c = '51304694'];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_SAU(200));
        String mensajeIntegracion;
        System.runAs(usuario) {
            Test.startTest();
            mensajeIntegracion = CC_WS_Autenticacion_SAU.ccWsEnvioAutenticacion(false, cuenta.AV_NumPerso__c, true);
            Test.stopTest();
        }
        System.assertEquals('exist_contract', mensajeIntegracion);
    }
}