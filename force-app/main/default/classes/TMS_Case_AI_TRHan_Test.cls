@isTest
public class TMS_Case_AI_TRHan_Test {
    
     @TestSetup
    public static void crearDatosPrueba() {
        
        User uTMS = TMS_Usuarios.usuarioAdminTMS();
        
        System.runAs(uTMS) {
            // The following code runs as user 'u'
//Añadir cuenta
            
            List<Account> cuentasInsertar = new List<Account>();
            List<Contact> contactosUpdate = new List<Contact>();


            Account oficinaGestora1 = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId(), 
                LastName = 'Cuenta oficina gestora', 
                CC_Email__c = 'test@test.com', 
                CC_Numero_Oficina__c = '00001');
                cuentasInsertar.add(oficinaGestora1);

                Account oficinaGestora2 = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId(), 
                LastName = 'Cuenta oficina gestora 2', 
                CC_Email__c = 'test2@test.com',
                AV_Confidencial__c = false,
                CC_Numero_Oficina__c = '00002');
            cuentasInsertar.add(oficinaGestora2);

            insert cuentasInsertar;


            Contact contacto1 = new Contact();
            contacto1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto1.LastName = 'Contacto test';
            contacto1.Email='test@test.com';
            contacto1.AV_NumPerso__c = '2147483647';
            contacto1.Account = oficinaGestora1;
            contactosUpdate.add(contacto1);
            

            Contact contacto2 = new Contact();
            contacto2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto2.LastName = 'Contacto test 2';
            contacto2.Email='test2@test.com';
            contacto2.AV_NumPerso__c = '2147583647';
            contacto2.Account = oficinaGestora2;
            contactosUpdate.add(contacto2);
            insert contactosUpdate;



            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.Name='TMS - Creación de tareas automáticas';
            lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            
            insert lista;
            
            List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
            valor1.CC_Lista__c = lista.Id;
            valor1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor1.Name = 'Primer Contacto';
            valor1.CC_Valor__c='Primer intento de llamada';
            valor1.CC_Valor2__c='TRUE';
            
            valores.add(valor1);
            
            CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
            valor2.CC_Lista__c = lista.Id;
            valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor2.Name = 'Primer Contacto';
            valor2.CC_Valor__c='Primer intento de llamada';
            valor2.CC_Valor2__c='TRUE';
            
            valores.add(valor2);
            
            CC_Lista_Valores__c valor3 = new CC_Lista_Valores__c();
            valor3.CC_Lista__c = lista.Id;
            valor3.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor3.Name = 'Primer Contacto';
            valor3.CC_Valor__c='Primer intento de llamada';
            valor3.CC_Valor2__c='TRUE';
            
            valores.add(valor3);
            
            CC_Lista_Valores__c valor4 = new CC_Lista_Valores__c();
            valor4.CC_Lista__c = lista.Id;
            valor4.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor4.Name = 'Acreditación heredero';
            valor4.CC_Valor__c='Primer intento de llamada';
            valor4.CC_Valor2__c='TRUE';
            
            valores.add(valor4);
            
            CC_Lista_Valores__c valor5 = new CC_Lista_Valores__c();
            valor5.CC_Lista__c = lista.Id;
            valor5.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor5.Name = 'Acreditación heredero';
            valor5.CC_Valor__c='Primer intento de llamada';
            valor5.CC_Valor2__c='TRUE';
            
            valores.add(valor5);
            
            CC_Lista_Valores__c valor6 = new CC_Lista_Valores__c();
            valor6.CC_Lista__c = lista.Id;
            valor6.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor6.Name = 'Acreditación heredero';
            valor6.CC_Valor__c='Primer intento de llamada';
            valor6.CC_Valor2__c='TRUE';
            
            valores.add(valor6);

            insert valores;
        }
    }
    @isTest
    static void testCaso(){
        

        User us = [SELECT Id FROM User WHERE Alias = 'adminTMS'];
        
        System.runAs (us){
            
            Case caso = new Case();
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
            caso.Subject = 'Caso TMS ' + System.Today();
			caso.Origin = 'SAC_Manual';
            caso.CC_Canal_Procedencia__c = 'Testamentarias';
            caso.TMS_Numexp__c = '11111111';
            caso.CC_Tipo_Contacto__c='Gestión expediente';
            caso.Status='TMS_001';
            caso.ContactId = [SELECT Id FROM Contact WHERE Email = 'test@test.com'].Id;
            
            Test.startTest();
            insert caso;
            Test.stopTest();
            List<Task> tareasCaso =[SELECT Id FROM Task WHERE WhatId = :caso.Id];
            
            System.AssertEquals(3, tareasCaso.size());
        }
    }
    
   
}