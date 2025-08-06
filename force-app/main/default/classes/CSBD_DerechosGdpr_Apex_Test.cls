@isTest
public class CSBD_DerechosGdpr_Apex_Test {

    @isTest
    static void testGetDerechosGdpr() {
        Test.setMock(HttpCalloutMock.class, new CC_GDPR_Mock());

        Map<String, Object> cuentaContacto;
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('12345678Z');
        }
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto = (Contact)cuentaContacto.get('contacto');
            Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                'AccountId' => cuenta.Id, 'CSBD_Contact__c' => contacto.Id
            });
            String idRecordTypeDerecho = Schema.SObjectType.CC_Derecho__c.getRecordTypeInfosByName().values()[0].getRecordTypeId();
            CC_Derecho__c derecho1 = new CC_Derecho__c();
            derecho1.RecordTypeId = idRecordTypeDerecho;
            derecho1.CC_Cliente__c = cuenta.Id;
            derecho1.CSBD_Opportunity__c = prestamo.Id;
            derecho1.CC_DocumentoCliente__c = '12345678A';
            derecho1.CC_Nombre__c = 'NOMBRE';
            derecho1.CC_Apellido1__c = 'APELLIDO 1';
            derecho1.CC_Apellido2__c = 'APELLIDO 2';
            derecho1.CC_TipoVia__c = 'CALLE';
            derecho1.CC_NombreVia__c = 'NOMBRE DE VIA';
            derecho1.CC_NumeroVia__c = 1;
            derecho1.CC_Edificio__c = 'EDIFICIO';
            derecho1.CC_Bloque__c = 'BLOQUE';
            derecho1.CC_Escalera__c = 'IZQ';
            derecho1.CC_Piso__c = '1';
            derecho1.CC_Puerta__c = '1';
            derecho1.CC_CodigoPostal__c = '08021';
            derecho1.CC_Localidad__c = 'BARCELONA';
            derecho1.CC_Provincia__c = 'BARCELONA';
            derecho1.CC_Pais__c = 'ESPAÑA';
            derecho1.CC_Resto__c = 'RESTO';
            derecho1.CC_Empresa__c = 'CAIXABANK S.A.';
            derecho1.CC_Oficina__c = 'ATENCIÓN AL CLIENTE';
            derecho1.CC_DatosClienteVerificados__c = true;
            CC_Derecho__c derecho2 = new CC_Derecho__c();
            derecho2.RecordTypeId = idRecordTypeDerecho;
            derecho2.CC_Cliente__c = cuenta.Id;
            derecho2.CSBD_Opportunity__c = prestamo.Id;
            derecho2.CC_DocumentoCliente__c = '12345678A';
            derecho2.CC_Nombre__c = 'NOMBRE';
            derecho2.CC_Apellido1__c = 'APELLIDO 1';
            derecho2.CC_Apellido2__c = 'APELLIDO 2';
            derecho2.CC_TipoVia__c = 'CALLE';
            derecho2.CC_NombreVia__c = 'NOMBRE DE VIA';
            derecho2.CC_NumeroVia__c = 1;
            derecho2.CC_Edificio__c = 'EDIFICIO';
            derecho2.CC_Bloque__c = 'BLOQUE';
            derecho2.CC_Escalera__c = 'IZQ';
            derecho2.CC_Piso__c = '1';
            derecho2.CC_Puerta__c = '1';
            derecho2.CC_CodigoPostal__c = '08021';
            derecho2.CC_Localidad__c = 'BARCELONA';
            derecho2.CC_Provincia__c = 'BARCELONA';
            derecho2.CC_Pais__c = 'ESPAÑA';
            derecho2.CC_Resto__c = 'RESTO';
            derecho2.CC_Empresa__c = 'CAIXABANK S.A.';
            derecho2.CC_Oficina__c = 'ATENCIÓN AL CLIENTE';
            derecho2.CC_DatosClienteVerificados__c = true;
            insert new List<CC_Derecho__c>{derecho1, derecho2};

            Test.startTest();
            List<CC_Derecho__c> result = CSBD_DerechosGdpr_Apex.getDerechosGdpr(prestamo.Id, cuenta.Id);
            Test.stopTest();

            System.assertEquals(2, result.size(), 'Se esperan dos registros de derechos');
            System.assertEquals(derecho1.Id, result[0].Id, 'El ID del derecho debería coincidir');
            System.assertEquals(derecho2.Id, result[1].Id, 'El ID del derecho debería coincidir');
            System.assertEquals(cuenta.Id, result[0].CC_Cliente__c, 'El cliente del derecho debería coincidir');
            System.assertEquals(prestamo.Id, result[0].CSBD_Opportunity__c, 'La oportunidad del derecho debería coincidir');
        }
    }

	@isTest
    public static void obtenerRecordTypesDerecho() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<Map<String, String>> recordTypesMap = CSBD_DerechosGdpr_Apex.getTiposDerecho();
            Test.stopTest();

            System.assert(!recordTypesMap.isEmpty(), 'Se esperan tipos de derecho');
        }
    }
}