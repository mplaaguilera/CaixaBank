@isTest
public with sharing class CSBD_Llamada_Oportunidad_Controller_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;
    }

    @isTest
    public static void getIdOportunidad() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            cuenta.Name = 'test@test.com';
            cuenta.CC_Numero_Documento__c = '46979396X';
            cuenta.Phone = '666666666';
            insert cuenta;
            
            Contact contacto = new Contact();
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            contacto.Email = 'test@test.com';
            contacto.Phone = '666666666';
            contacto.FirstName = 'Nombre';
            contacto.LastName = 'Apellido';
            contacto.AccountId = cuenta.Id;
            insert contacto;

            Map<String, Object> campos = new Map<String, Object>();
            campos.put('Name', 'oportunidad de prueba');
            campos.put('AccountId', cuenta.Id);
            campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
            campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);

            Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

            CC_Llamada__c llamadaCsbd = new CC_Llamada__c();
            llamadaCsbd.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CSBD_Cliente');
            insert llamadaCsbd;

            Map<String, String> camposTarea = new Map<String, String>{'CC_Llamada_Id__c' => llamadaCsbd.Id};
            Task tareaLlamadaCsbd = CSBD_Activity.crearActividad(prestamo.Id, 'test', 'Completed', 'test', null, camposTarea);

            Test.startTest();
            Id idOportunidad = CSBD_Llamada_Oportunidad_Controller.getIdOportunidad(llamadaCsbd.Id);
            Test.stopTest();

            System.assertEquals(prestamo.Id, idOportunidad, 'Id de oportunidad incorrecto');
        }
    }
}