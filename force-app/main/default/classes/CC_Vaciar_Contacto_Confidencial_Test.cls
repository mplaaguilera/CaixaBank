@isTest
public class CC_Vaciar_Contacto_Confidencial_Test {
    @isTest
    static void borrarContactoCliente() {
        Id recordTypAccountCliente = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        Account cuentaGestora = new Account();
        cuentaGestora.Name = 'Cuenta Test Gestora';
        cuentaGestora.CC_Email__c = 'test@test.com';
        cuentaGestora.RecordTypeId = recordTypAccountCliente;
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.Phone = '973134324';
        cuentaGestora.CC_Confidencial__c = true;
        insert cuentaGestora;

        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeCliente;
        oContacto.AccountId = cuentaGestora.Id;
        oContacto.CC_NumPerso__c = 'a';
        oContacto.MailingLatitude = 11.23;
        oContacto.MailingLongitude = 12.10;
        insert oContacto;


        List<Id> contactos = new List<Id>();
        contactos.add(oContacto.Id);

        CC_Vaciar_Contacto_Confidencial.borrarDatos(contactos);
        Account account = [SELECT Name, CC_Email__c, AV_NumPerso__c, BillingAddress, Phone FROM Account WHERE Id = :cuentaGestora.Id];
        Contact contacto = [SELECT Name, Email, Birthdate, CC_CuentaFacebook__c, CC_CuentaTwitter__c, CC_EmpleadoGestorId__c, CC_FechaNac__c, CC_Identificador_CBKNow__c,
                            CC_Idioma__c, CC_OficinaGestoraId__c, CC_Segmento__c, CC_SubSegmento__c, CC_Sexo__c, MobilePhone, MailingAddress
                            FROM Contact WHERE Id = :oContacto.Id];
		
        //Account
        System.assertEquals('CONFIDENCIAL', account.Name);
        System.assertEquals(account.CC_Email__c, null);
        System.assertEquals(account.AV_NumPerso__c, null);
        System.assertEquals(account.BillingAddress, null);
        System.assertNotEquals(account.Phone, null);
        
        //Contacto
        System.assertEquals(contacto.Name, 'CONFIDENCIAL');
        System.assertEquals(contacto.Email, null);
        System.assertEquals(contacto.Birthdate, null);
        System.assertEquals(contacto.CC_CuentaFacebook__c, null);
        System.assertEquals(contacto.CC_CuentaTwitter__c, null);
        System.assertEquals(contacto.CC_EmpleadoGestorId__c, null);
        System.assertEquals(contacto.CC_FechaNac__c, null);
        System.assertEquals(contacto.CC_Identificador_CBKNow__c, null);
        System.assertEquals(contacto.CC_Idioma__c, null);
        System.assertEquals(contacto.CC_OficinaGestoraId__c, null);
        System.assertEquals(contacto.CC_Segmento__c, null);
        System.assertEquals(contacto.CC_SubSegmento__c, null);
        System.assertEquals(contacto.CC_Sexo__c, null);
        System.assertEquals(contacto.MailingAddress, null);
    }
    
    
    @isTest
    static void borrarContactoClientePA() {        
        Account cuentaGestora = new Account();
        cuentaGestora.FirstName = 'Cuenta Test';
        cuentaGestora.LastName = 'Gestora';
        cuentaGestora.CC_Email__c = 'test@test.com';
        cuentaGestora.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.Phone = '973134324';
        insert cuentaGestora;
		        
        List<Id> accounts = new List<Id> ();
		accounts.add(cuentaGestora.Id);
        CC_Vaciar_Contacto_Confidencial.borrarDatos(accounts);
        
        List<Id> contactos = new List<Id>();
        contactos.add([SELECT Id FROM CONTACT WHERE AccountId = :cuentaGestora.Id].Id);
        
        Account account = [SELECT Name, CC_Email__c, AV_NumPerso__c, BillingAddress, Phone FROM Account WHERE Id = :cuentaGestora.Id];
        Contact contacto = [SELECT Name, Email, Birthdate, CC_CuentaFacebook__c, CC_CuentaTwitter__c, CC_EmpleadoGestorId__c, CC_FechaNac__c, CC_Identificador_CBKNow__c,
                            CC_Idioma__c, CC_OficinaGestoraId__c, CC_Segmento__c, CC_SubSegmento__c, CC_Sexo__c, MailingAddress
                            FROM Contact WHERE Id = :contactos[0]]; 
		
        //Account
        System.assertEquals('CONFIDENCIAL', account.Name);
        System.assertEquals(account.CC_Email__c, null);
        System.assertEquals(account.AV_NumPerso__c, null);
        System.assertEquals(account.BillingAddress, null);
        System.assertNotEquals(account.Phone, null);
        
        //Contacto
        System.assertEquals(contacto.Name, 'CONFIDENCIAL');
        System.assertEquals(contacto.Email, null);
        System.assertEquals(contacto.Birthdate, null);
        System.assertEquals(contacto.CC_CuentaFacebook__c, null);
        System.assertEquals(contacto.CC_CuentaTwitter__c, null);
        System.assertEquals(contacto.CC_EmpleadoGestorId__c, null);
        System.assertEquals(contacto.CC_FechaNac__c, null);
        System.assertEquals(contacto.CC_Identificador_CBKNow__c, null);
        System.assertEquals(contacto.CC_Idioma__c, 'es');
        System.assertEquals(contacto.CC_OficinaGestoraId__c, null);
        System.assertEquals(contacto.CC_Segmento__c, null);
        System.assertEquals(contacto.CC_SubSegmento__c, null);
        System.assertEquals(contacto.CC_Sexo__c, null);
        System.assertEquals(contacto.MailingAddress, null); 
    }
    
    
}