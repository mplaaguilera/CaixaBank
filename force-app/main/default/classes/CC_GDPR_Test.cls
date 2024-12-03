@isTest
public class CC_GDPR_Test {

    @isTest
    public static void obtenerDerechosDelCliente() {
        
        // Alta de datos para la prueba
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Nombre';
        cuenta.CC_Numero_Documento__c = '44445555X';
        insert cuenta;
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.Subject = 'Asunto';
        caso.AccountId = cuenta.Id;
        insert caso;
        CC_Derecho__c derecho = new CC_Derecho__c();
        derecho.RecordTypeId = Schema.SObjectType.CC_Derecho__c.getRecordTypeInfosByDeveloperName().get('CC_Acceso').getRecordTypeId();
        derecho.CC_Caso__c = caso.Id;
        derecho.CC_Cliente__c = cuenta.Id;
        derecho.CC_DocumentoCliente__c = cuenta.CC_Numero_Documento__c;
        derecho.CC_Nombre__c = 'NOMBRE';
        derecho.CC_Apellido1__c = 'APELLIDO 1';
        derecho.CC_Apellido2__c = 'APELLIDO 2';
        derecho.CC_TipoVia__c = 'CALLE';
        derecho.CC_NombreVia__c = 'NOMBRE DE VIA';
        derecho.CC_NumeroVia__c = 1;
        derecho.CC_Edificio__c = 'EDIFICIO';
        derecho.CC_Bloque__c = 'BLOQUE';
        derecho.CC_Escalera__c = 'IZQ';
        derecho.CC_Piso__c = '1';
        derecho.CC_Puerta__c = '1';
        derecho.CC_CodigoPostal__c = '08021';
        derecho.CC_Localidad__c = 'BARCELONA';
        derecho.CC_Provincia__c = 'BARCELONA';
        derecho.CC_Pais__c = 'ESPAÑA';
        derecho.CC_Resto__c = 'RESTO';
        derecho.CC_Empresa__c = 'CAIXABANK S.A.';
        derecho.CC_Oficina__c = 'ATENCIÓN AL CLIENTE';
        
        
        derecho.CC_DatosClienteVerificados__c = true;
        insert derecho;

        // Ejecución de la prueba
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CC_GDPR_Mock());
        List<CC_GDPR.DerechoWrapper> derechos = CC_GDPR.obtenerDerechosDelCliente(caso.Id);
        Test.stopTest();

        // Evaluación del resultado de la prueba
        // TODO
    }

    @isTest
    public static void obtenerDerechosDelCaso() {
        
        // Alta de datos para la prueba
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Nombre';
        cuenta.CC_Numero_Documento__c = '44445555X';
        insert cuenta;
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.Subject = 'Asunto';
        caso.AccountId = cuenta.Id;
        insert caso;
        CC_Derecho__c derecho = new CC_Derecho__c();
        derecho.RecordTypeId = Schema.SObjectType.CC_Derecho__c.getRecordTypeInfosByDeveloperName().get('CC_Acceso').getRecordTypeId();
        derecho.CC_Caso__c = caso.Id;
        derecho.CC_Cliente__c = cuenta.Id;
        derecho.CC_DocumentoCliente__c = cuenta.CC_Numero_Documento__c;
        derecho.CC_Nombre__c = 'NOMBRE';
        derecho.CC_Apellido1__c = 'APELLIDO 1';
        derecho.CC_Apellido2__c = 'APELLIDO 2';
        derecho.CC_TipoVia__c = 'CALLE';
        derecho.CC_NombreVia__c = 'NOMBRE DE VIA';
        derecho.CC_NumeroVia__c = 1;
        derecho.CC_Edificio__c = 'EDIFICIO';
        derecho.CC_Bloque__c = 'BLOQUE';
        derecho.CC_Escalera__c = 'IZQ';
        derecho.CC_Piso__c = '1';
        derecho.CC_Puerta__c = '1';
        derecho.CC_CodigoPostal__c = '08021';
        derecho.CC_Localidad__c = 'BARCELONA';
        derecho.CC_Provincia__c = 'BARCELONA';
        derecho.CC_Pais__c = 'ESPAÑA';
        derecho.CC_Resto__c = 'RESTO';
        derecho.CC_Empresa__c = 'CAIXABANK S.A.';
        derecho.CC_Oficina__c = 'ATENCIÓN AL CLIENTE';
        
        
        
        
        derecho.CC_DatosClienteVerificados__c = true;
        insert derecho;

        // Ejecución de la prueba
        Test.startTest();
        List<CC_GDPR.DerechoWrapper> derechos = CC_GDPR.obtenerDerechosDelCaso(caso.Id);
        Test.stopTest();

        // Evaluación del resultado de la prueba
        // TODO
    }

	@isTest
    public static void obtenerRecordTypesDerecho() {
        
        // Ejecución de la prueba
        Test.startTest();
        Map<Id, String> recordTypesMap = CC_GDPR.obtenerRecordTypesDerecho();
        Test.stopTest();
        
        // Evaluación del resultado de la prueba
        // TODO
    }
    
}