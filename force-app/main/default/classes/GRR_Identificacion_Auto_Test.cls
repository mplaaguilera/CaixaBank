@isTest
public with sharing class GRR_Identificacion_Auto_Test {

    @isTest
    public static void testIdentificarCliente() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            List<Account> cuentas = new List<Account>();
            Id rtAccountCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            Account cuentaA = new Account();
            cuentaA.RecordTypeId = rtAccountCliente;
            cuentaA.Name = 'Cuenta personal test A';
            cuentas.add(cuentaA);
            Account cuentaB = new Account();
            cuentaB.RecordTypeId = rtAccountCliente;
            cuentaB.Name = 'Cuenta personal test B';
            cuentas.add(cuentaB);
            insert cuentas;
            List<Contact> contactos = new List<Contact>();
            Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');  
            Contact contacto1 = new Contact();
            contacto1.RecordTypeId = rtContactCliente;
            contacto1.AccountId = cuentaA.Id;
            contacto1.FirstName = 'Contacto';
            contacto1.LastName = '01';
            contacto1.CC_NumPerso__c = '25345569';
            contacto1.CC_Idioma__c = 'ca';
            contacto1.Email = 'correo@gmail.com';
            contacto1.Phone = '973242323';
            contactos.add(contacto1);
            Contact contacto2 = new Contact();
            contacto2.RecordTypeId = rtContactCliente;
            contacto2.AccountId = cuentaA.Id;
            contacto2.FirstName = 'Contacto2';
            contacto2.LastName = '02';
            contacto2.CC_NumPerso__c = '26345569';
            contacto2.CC_Idioma__c = 'es';
            contacto2.Email = 'correo@gmail.com';
            contacto2.Phone = '973242323';
            contactos.add(contacto2);       
            Contact contacto3 = new Contact();
            contacto3.RecordTypeId = rtContactCliente;
            contacto3.AccountId = cuentaB.Id;
            contacto3.FirstName = 'Contacto3';
            contacto3.LastName = '03';
            contacto3.CC_NumPerso__c = '26344159';
            contacto3.CC_Idioma__c = 'es';
            contacto3.Email = 'corre@gmail.com';
            contacto3.Phone = '973242323';
            contactos.add(contacto3);
            insert contactos;
            
            Map<Account, List<Contact>> mapCorreoExistente = GRR_Identificacion_Auto.identificarCliente('Email', 'correo@gmail.com');      
            Map<Account, List<Contact>> mapCorreoInexistente = GRR_Identificacion_Auto.identificarCliente('Email','inexistente@gmail.com');
            System.assertEquals(1, mapCorreoExistente.size());
            System.assertEquals(2, mapCorreoExistente.values()[0].size());
            System.assertEquals(0, mapCorreoInexistente.size());

            Test.stopTest();
        }
    }

}