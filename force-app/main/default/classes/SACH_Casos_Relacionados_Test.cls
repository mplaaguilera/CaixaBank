@IsTest
public with sharing class SACH_Casos_Relacionados_Test {

    @TestSetup
    static void setData() {

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'accountTest';
        insert cuenta;

        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.AccountId = cuenta.Id;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.CC_Tipo_Contacto__c = 'Consulta de cliente';
        caso.Status = 'Activo';
        insert caso;

    }


    //Test para el método getCasosRelacionados
    @isTest
    public static void getCasosRelacionadosTest() {

        Test.startTest();

        Account cuenta = [SELECT Id FROM Account WHERE Name = 'accountTest' LIMIT 1];

        List<Case> casosRelacionados = SACH_Casos_Relacionados.getCasosRelacionados(cuenta.Id);

        Test.stopTest();
        System.assertEquals(casosRelacionados.isEmpty(), false, 'Casos no encontrados');
    }
}