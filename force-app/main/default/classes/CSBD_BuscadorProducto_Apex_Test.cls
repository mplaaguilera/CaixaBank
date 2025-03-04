@isTest
public class CSBD_BuscadorProducto_Apex_Test {

    @TestSetup
    static void setupTestData() {
        CC_Lista_Valores__c empresa = new CC_Lista_Valores__c();
        empresa.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Empresas').getRecordTypeId();
        empresa.Name = 'CaixaBank';
        empresa.CSBD_Tipo_de_oportunidad__c = 'Préstamo';
        empresa.CC_Activa__c = true;
        CC_Lista_Valores__c familia = new CC_Lista_Valores__c();
        familia.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Familias').getRecordTypeId();
        familia.Name = 'Família 1';
        familia.CSBD_Empresa_Proveedora_Multi__c = 'CaixaBank';
        familia.CSBD_Tipo_de_oportunidad__c = 'Préstamo';
        familia.CC_Activa__c = true;
        insert new List<CC_Lista_Valores__c>{empresa, familia};

        CC_Lista_Valores__c producto1 = new CC_Lista_Valores__c();
        producto1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        producto1.CC_Lista__c = familia.Id;
        producto1.Name = 'Producto 1';
        producto1.CC_Activa__c = true;
        CC_Lista_Valores__c producto2 = new CC_Lista_Valores__c();
        producto2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        producto2.CC_Lista__c = familia.Id;
        producto2.Name = 'Producto 2';
        producto2.CC_Activa__c = true;
        insert new List<CC_Lista_Valores__c>{producto1, producto2};
    }

    @isTest
    private static void getEmpresasProveedorasTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<CC_Lista_Valores__c> empresasPrestamo = CSBD_BuscadorProducto_Apex.getEmpresasProveedoras('Préstamo');
            List<CC_Lista_Valores__c> empresasHipoteca = CSBD_BuscadorProducto_Apex.getEmpresasProveedoras('Hipoteca');
            Test.stopTest();

            System.assertEquals(1, empresasPrestamo.size(), 'Solo hay una empresa proveedora activa para préstamos');
            System.assertEquals(0, empresasHipoteca.size(), 'No hay empresas proveedoras para un tipo inexistente');
        }
    }

    @isTest
    private static void getProductosTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<CC_Lista_Valores__c> resultados1 = CSBD_BuscadorProducto_Apex.getProductos('Préstamo', 'Producto 1');
            List<CC_Lista_Valores__c> resultados2 = CSBD_BuscadorProducto_Apex.getProductos('Préstamo', 'Família');
            List<CC_Lista_Valores__c> resultados3 = CSBD_BuscadorProducto_Apex.getProductos('Préstamo', 'Prod');
            Test.stopTest();

            System.assertEquals(1, resultados1.size(), 'Hay 1 producto');
            System.assertEquals(2, resultados2.size(), 'Hay 2 productos');
            System.assertEquals(2, resultados3.size(), 'Hay 2 producto');
        }
    }
}