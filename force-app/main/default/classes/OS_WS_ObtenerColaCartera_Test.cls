@isTest
public with sharing class OS_WS_ObtenerColaCartera_Test {

    @isTest
    public static void test() {

        OS_Cartera__c cartera = new OS_Cartera__c();
        cartera.Name = 'cartera test';
        cartera.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OS_Cartera__c', 'OS_Cartera');
        cartera.OS_Cola_Telefonia__c = '123456';
        insert cartera;

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'cuenta test';
        cuenta.OS_Cartera__c = cartera.Id;
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.AccountId = cuenta.Id;
        contacto.Phone = '666123123';
        contacto.LastName = 'contacto test';
        insert contacto;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        String colaCartera = OS_WS_ObtenerColaCartera.obtenerColaCarteraCops().colaCartera;
        Test.stopTest();

        System.assertEquals(
            'OK#C' + cartera.OS_Cola_Telefonia__c,  
            colaCartera,
            'La cola devuelta no coincide con la de la cuenta'
        );
        }   
    }
    
}