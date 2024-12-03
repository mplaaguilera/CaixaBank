@isTest
public class CSBD_FamiliaProductoPicklist_Test {
 @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

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
		CC_Lista_Valores__c motivosMac = new CC_Lista_Valores__c();
        motivosMac.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        motivosMac.Name = 'CSBD: Motivos MAC';
        motivosMac.CC_Activa__c = true;
        insert new List<CC_Lista_Valores__c>{empresa, familia, motivosMac};

		CC_Lista_Valores__c producto = new CC_Lista_Valores__c();
        producto.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        producto.CC_Lista__c = familia.Id;
        producto.Name = 'Producto prueba';
        producto.CC_Activa__c = true;
		CC_Lista_Valores__c motivoMac = new CC_Lista_Valores__c();
        motivoMac.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
		motivoMac.CC_Lista__c = motivosMac.Id;
        motivoMac.Name = 'Motivo MAC 1';
        motivoMac.CC_Activa__c = true;
		insert new List<CC_Lista_Valores__c>{producto, motivoMac};
    }

    @isTest
    public static void getEmpresasTest() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        System.runAs(usuarioGestor) {
            Test.startTest();
            List<CC_Lista_Valores__c> empresas = CSBD_FamiliaProductoPicklistController.getEmpresas('Préstamo');
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.listaCampo(empresas, 'Name').contains('CaixaBank'), true);
        }
    }

    @isTest
    public static void getFamiliasTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        System.runAs(usuarioGestor) {
            Test.startTest();
            List<CC_Lista_Valores__c> familias = CSBD_FamiliaProductoPicklistController.getFamilias('Préstamo', 'CaixaBank');
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.listaCampo(familias, 'Name').contains('Familia prueba'), true);
        }
    }

    @isTest
    public static void getProductosTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        System.runAs(usuarioGestor) {
            Test.startTest();
            List<CC_Lista_Valores__c> productos = CSBD_FamiliaProductoPicklistController.getProductos('Familia prueba', 'Hipoteca');
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.listaCampo(productos, 'Name').contains('Producto prueba'), true);
        }
    }

	@isTest
    public static void getMotivosMacTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        System.runAs(usuarioGestor) {
            Test.startTest();
            List<CC_Lista_Valores__c> motivosMac = CSBD_FamiliaProductoPicklistController.getMotivosMac();
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.listaCampo(motivosMac, 'Name').contains('Motivo MAC 1'), true);
        }
    }
}