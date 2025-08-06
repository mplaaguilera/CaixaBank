@isTest
public class CC_WS_Onboarding_Test {
    @TestSetup
    static void makeData() {
        User usuarioAdmin = CC_TestDataFactory.insertUserAdmin();

        System.runAs(usuarioAdmin) {
            User operador = CC_TestDataFactory.insertUserOperadorCliente('');

            CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
            customSetting.Name = 'CC_Onboarding';
            customSetting.NamedCredential__c = 'callout:API_GWT_TST/assetProductsBackofficeOperations/cbpo02/v1/teamworks/webservices/GDS707A/ConsultaEstadoSolicitud.tws';
            customSetting.RegistroTrazaIntegracion__c = true;
            insert customSetting;

            Id idCCListaValores = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            Id idCCValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            Id idCCValorSubestado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_ValorSubestado');

            CC_Lista_Valores__c listaVal = new CC_Lista_Valores__c();
            listaVal.Name = 'testMatrizOnboarding';
            listaVal.CC_Activa__c = true;
            listaVal.RecordTypeId = idCCListaValores;
            insert listaVal;

            List<CC_Lista_Valores__c> listavalores = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c val1 = new CC_Lista_Valores__c();
            val1.Name = 'testclienteyaexistente';
            val1.CC_Activa__c = true;
            val1.RecordTypeId = idCCValor;
            val1.CC_Lista__c = listaVal.Id;
            val1.CC_Valor2__c = 'Motivo Cierre';
            val1.CC_Mensajes_Mostrar__c = 'testmensajemotivocierre';
            listavalores.add(val1);

            CC_Lista_Valores__c val2 = new CC_Lista_Valores__c();
            val2.Name = 'testvalidacionvideo';
            val2.CC_Activa__c = true;
            val2.RecordTypeId = idCCValor;
            val2.CC_Lista__c = listaVal.Id;
            val2.CC_Valor2__c = 'Estado';
            listavalores.add(val2);
            insert listavalores;

            CC_Lista_Valores__c val3 = new CC_Lista_Valores__c();
            val3.Name = 'testvalidacionvideoSubestado';
            val3.CC_Activa__c = true;
            val3.RecordTypeId = idCCValorSubestado;
            val3.CC_Lista__c = val2.Id;
            val3.CC_Valor2__c = 'Subestado';
            val3.CC_Mensajes_Mostrar__c = 'testmensajesubestado';
            insert val3;
        }

        
    }

    @isTest
    public static void testOK() {
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Onboarding(200));
        String mensajeIntegracion;
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            cuenta.FirstName = 'Cuenta';
            cuenta.LastName = 'Prueba';
            cuenta.CC_Numero_Documento__c = '29053641H';
            insert cuenta;

            Case caso = new Case();
            caso.AccountId = cuenta.Id;
            caso.Subject = 'Caso Prueba';
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            insert caso;
            
            Test.startTest();
                mensajeIntegracion = CC_WS_Onboarding.recuperarCliente(caso.Id, caso.Account.CC_Numero_Documento__c);
            Test.stopTest();
        }
        System.assertNotEquals('El cliente no esta en proceso de Onboarding', mensajeIntegracion);
    }

    @isTest
    public static void testOK2() {
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Onboarding(200));
        String mensajeIntegracion;
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            insert caseExtension;

            Case caso = new Case();
            caso.Subject = 'Caso Prueba 2';
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.CBK_Case_Extension_Id__c = caseExtension.Id;
            insert caso;

            Test.startTest();
                mensajeIntegracion = CC_WS_Onboarding.recuperarClienteOnboarding(caso.Id, '77788590F');
            Test.stopTest();
        }
        System.assertNotEquals('El cliente no esta en proceso de Onboarding', mensajeIntegracion);
    }

    @isTest
    public static void matrizmotivoCierreTest() {
        List<String> lstString = new List<String>();
        String result = '';
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Test.startTest();
                result = CC_WS_Onboarding.matrizOnboarding('testvalidacionvideo', 'testvalidacionvideoSubestado', 'testclienteyaexistente');
            Test.stopTest();
        }
        System.assertEquals('testmensajemotivocierre', result, 'No se ha recogido el mensaje');
    }

    @isTest
    public static void matrizEstadoTest() {
        List<String> lstString = new List<String>();
        String result = '';
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Test.startTest();
                result = CC_WS_Onboarding.matrizOnboarding('testvalidacionvideo', 'testvalidacionvideoSubestado', '');
            Test.stopTest();
        }
        System.assertEquals('testmensajesubestado', result, 'No se ha recogido el mensaje');
    }
}