@isTest
public class CC_WS_Onboarding_Test {
    @TestSetup
    static void makeData() {
        User usuarioAdmin = CC_TestDataFactory.insertUserAdmin();

        System.runAs(usuarioAdmin) {
            User operador = CC_TestDataFactory.insertUserOperadorCliente('');

            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            cuenta.FirstName = 'Cuenta';
            cuenta.LastName = 'Prueba';
            cuenta.CC_Numero_Documento__c = '29785500D';
            insert cuenta;

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            insert caseExtension;

            Case caso = new Case();
            caso.AccountId = cuenta.Id;
            caso.Subject = 'Caso Prueba';
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            // caso.CBK_Case_Extension_Id__c = caseExtension.Id;
            insert caso;

            Case caso2 = new Case();
            caso2.AccountId = cuenta.Id;
            caso2.Subject = 'Caso Prueba 2';
            caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso2.CBK_Case_Extension_Id__c = caseExtension.Id;
            insert caso2;

            CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
            customSetting.Name = 'CC_Onboarding';
            customSetting.NamedCredential__c = 'callout:API_GWT_TST/assetProductsBackofficeOperations/cbpo02/v1/teamworks/webservices/GDS707A/ConsultaEstadoSolicitud.tws';
            customSetting.RegistroTrazaIntegracion__c = true;
            insert customSetting;
        }
    }

    @isTest
    public static void testOK() {
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Onboarding(200));
        String mensajeIntegracion;
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Case caso = [SELECT Id, Account.CC_Numero_Documento__c FROM Case WHERE Subject = 'Caso Prueba' LIMIT 1];
            Test.startTest();
                mensajeIntegracion = CC_WS_Onboarding.recuperarClienteOnboarding(caso.Id, caso.Account.CC_Numero_Documento__c);
            Test.stopTest();
        }
        System.assertNotEquals('El cliente no esta en proceso de Onboarding', mensajeIntegracion);
    }

    @isTest
    public static void testOK2() {
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Onboarding(200));
        String mensajeIntegracion;
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Case caso = [SELECT Id, Account.CC_Numero_Documento__c FROM Case WHERE Subject = 'Caso Prueba 2' LIMIT 1];
            Test.startTest();
                mensajeIntegracion = CC_WS_Onboarding.recuperarClienteOnboarding(caso.Id, '77788590F');
            Test.stopTest();
        }
        System.assertNotEquals('El cliente no esta en proceso de Onboarding', mensajeIntegracion);
    }

    @isTest
    public static void matrizTest() {
        List<String> lstString = new List<String>();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Test.startTest();
                lstString.add(CC_WS_Onboarding.matrizOnboarding('Validación Vídeo Desasistida','Espera Validación Vídeo Desasistida',''));
                lstString.add(CC_WS_Onboarding.matrizOnboarding('Alta Cliente','Incidencia Alta Cliente',''));
                lstString.add(CC_WS_Onboarding.matrizOnboarding('Alta Contratos','Incidencia Alta Contratos',''));
                lstString.add(CC_WS_Onboarding.matrizOnboarding('Revisión Documentación','Ver Error Envío NIF',''));
                lstString.add(CC_WS_Onboarding.matrizOnboarding('Espera Firma o Iberpay o Señales','Gestión Productos Adicionales',''));
                lstString.add(CC_WS_Onboarding.matrizOnboarding('Finalizado OK','Revisión Alta S214',''));

            Test.stopTest();
        }
        System.assertEquals(true, lstString.size() > 0, '');
    }
}