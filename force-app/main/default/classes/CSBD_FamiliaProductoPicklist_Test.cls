@isTest
public class CSBD_FamiliaProductoPicklist_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        CC_Lista_Valores__c familia = new CC_Lista_Valores__c();
        familia.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Familias').getRecordTypeId();
        familia.Name = 'Familia prueba';
        familia.CC_Activa__c = true;
        familia.CSBD_Tipo_de_oportunidad__c = 'Hipoteca;Préstamo;Renting;TPV;PRO Automática;Llamada Servicio';
        familia.CSBD_Empresa_Proveedora_Multi__c ='CaixaBank;imaginBank;inTouch;Now In Empleado;Now In Soporte';
        CC_Lista_Valores__c empresa = new CC_Lista_Valores__c();
        empresa.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Empresas').getRecordTypeId();
        empresa.Name = 'CaixaBank';
        empresa.CC_Activa__c = true;
        empresa.CSBD_Tipo_de_oportunidad__c = 'Hipoteca;Préstamo;Renting;TPV;PRO Automática;Llamada Servicio';
		CC_Lista_Valores__c motivosAC = new CC_Lista_Valores__c();
        motivosAC.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Motivos_CSCC').getRecordTypeId();
        motivosAC.Name = 'Motivo AC 1';
        motivosAC.CC_Activa__c = true;
        insert new List<CC_Lista_Valores__c>{empresa, familia, motivosAC};

		CC_Lista_Valores__c producto = new CC_Lista_Valores__c();
        producto.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        producto.CC_Lista__c = familia.Id;
        producto.Name = 'Producto prueba';
        producto.CC_Activa__c = true;
		CC_Lista_Valores__c motivoAC = new CC_Lista_Valores__c();
        motivoAC.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
		motivoAC.CC_Lista__c = motivosAC.Id;
        motivoAC.Name = 'Producto AC';
        motivoAC.CC_Activa__c = true;
		insert new List<CC_Lista_Valores__c>{producto, motivoAC};
    }

    @isTest
    public static void getEmpresasTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<CC_Lista_Valores__c> empresas = CSBD_FamiliaProductoPicklistController.getEmpresas('Préstamo');
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.listaCampo(empresas, 'Name').contains('CaixaBank'), true, 'Empresa no encontrada');
        }
    }

    @isTest
    public static void getFamiliasTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<CC_Lista_Valores__c> familias = CSBD_FamiliaProductoPicklistController.getFamilias('Préstamo', 'CaixaBank');
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.listaCampo(familias, 'Name').contains('Familia prueba'), true, 'Familia no encontrada');
        }
    }

    @isTest
    public static void getProductosTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<CC_Lista_Valores__c> productos = CSBD_FamiliaProductoPicklistController.getProductos('Familia prueba');
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.listaCampo(productos, 'Name').contains('Producto prueba'), true, 'Producto no encontrado');
        }
    }

	@isTest
    public static void getMotivosAcTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<CC_Lista_Valores__c> motivosAc = CSBD_FamiliaProductoPicklistController.getMotivosMac('Producto AC');
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.listaCampo(motivosAc, 'CC_Lista__r.Name').contains('Motivo AC 1'), true, 'Motivo no encontrado');
        }
    }
}