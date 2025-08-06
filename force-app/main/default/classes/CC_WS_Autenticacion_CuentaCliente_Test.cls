@isTest
public class CC_WS_Autenticacion_CuentaCliente_Test {
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
                AV_NumPerso__c = '206'
            );
            insert cuenta;

            CC_Settings__c parametrosIntegracion = new CC_Settings__c(
                Name = 'CC_Integracion_Autenticacion',
                CC_Activa__c = true,
                CC_Configuracion_1__c = 'walletle',
                CC_Configuracion_2__c = 'true',
                CC_Configuracion_3__c = 'false',
                CC_Configuracion_4__c = 'N',
                CC_Configuracion_5__c = 1,
                CC_Configuracion_6__c = '10',
                CC_Configuracion_7__c = ''
            );
            insert parametrosIntegracion;
        }
    }

    @isTest
    public static void validacionCuentaNOkTest() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Usuario Supervisor Prueba'];
        Account cuenta = [SELECT AV_NumPerso__c FROM Account WHERE AV_NumPerso__c = '206'];
        
        List<String> cuentas = new List<String>();
        System.runAs(usuario) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(404));
            cuentas = CC_WS_Autenticacion_CuentaCliente.validacionCuenta(cuenta.AV_NumPerso__c);
            Test.stopTest();
        }
        System.assertEquals(0, cuentas.size());
    }

    @isTest
    public static void validacionCuentaOkTest() {
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CC_Autenticacion_Cuenta';
		wsc.NamedCredential__c = 'callout:API_GWT_PRE_CCSF/accountingServices/positionKeeping/accounts/request';
		insert wsc;

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Usuario Supervisor Prueba'];
        Account cuenta = [SELECT AV_NumPerso__c FROM Account WHERE AV_NumPerso__c = '206'];

        List<String> cuentas = new List<String>();
        System.runAs(usuario) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            cuentas = CC_WS_Autenticacion_CuentaCliente.validacionCuenta(cuenta.AV_NumPerso__c);
            System.debug('::: cuentas: ' + cuentas);
        	Test.stopTest();
        }
        System.assertEquals(1, cuentas.size());
    }
}