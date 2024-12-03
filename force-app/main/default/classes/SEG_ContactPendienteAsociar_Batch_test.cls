@isTest
public with sharing class SEG_ContactPendienteAsociar_Batch_test {

    @TestSetup
    public static void crearDatosPrueba() 
    {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(
                alias = 'user2', 
                email ='testSEGBI2@acme.com',
                emailencodingkey ='UTF-8', 
                lastname='Smith',
                languagelocalekey ='en_US',
                localesidkey ='en_US', 
                profileid = perfil.Id, 
                userroleid = rol.Id,
                timezonesidkey ='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin','SEG_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }
    }

    @IsTest
	static void Paso1(){
        
        //Crear Accounts
        list<Account> lstAccount = new list<Account>();
		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'CUENTA PENDIENTE ASOCIAR';		
        lstAccount.add(cuentaSEG1);
		
        Account cuentaSEG2 = new Account();
		cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		cuentaSEG2.Name = 'CUENTA EMPRESA';
		cuentaSEG2.CC_Numero_Documento__c = '11111111H';
        lstAccount.add(cuentaSEG2);
        
        insert lstAccount;

        //Crear Contacts
        Id cRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        list<Contact> lstContact = new list<Contact>();
		Contact contactSEG1 = new Contact();
		contactSEG1.RecordTypeId = cRT;
		contactSEG1.LastName = 'CUENTA PENDIENTE ASOCIAR';	
        contactSEG1.email='pruebas@test.com';	
        contactSEG1.AccountId=lstAccount[0].Id;
        lstContact.add(contactSEG1);
	
        Contact contactSEG2 = new Contact();
		contactSEG2.RecordTypeId = cRT;
		contactSEG2.LastName = 'CUENTA EMPRESA';
        contactSEG2.email='pruebas@test.com';
        contactSEG2.AccountId=lstAccount[1].Id; 
        lstContact.add(contactSEG2);
        
        insert lstContact;

        Test.startTest();
        Id jobid= Database.executeBatch(new SEG_ContactPendienteAsociar_P1_Batch(), 1);
        Test.stopTest();
        list<Contact> lstfinal = [Select Id from contact where email='pruebas@test.com' and RecordTypeId=:cRT];
        system.AssertEquals(1,lstfinal.size());
        
    }
    @IsTest
	static void Paso2(){
        
        //Crear Accounts
        list<Account> lstAccount = new list<Account>();
		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'CUENTA PENDIENTE ASOCIAR';		
        lstAccount.add(cuentaSEG1);
		
        Account cuentaSEG2 = new Account();
		cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		cuentaSEG2.Name = 'CUENTA EMPRESA';
		cuentaSEG2.CC_Numero_Documento__c = '11111111H';
        lstAccount.add(cuentaSEG2);
        
        insert lstAccount;

        //Crear Contacts
        Id cRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        list<Contact> lstContact = new list<Contact>();
		Contact contactSEG1 = new Contact();
		contactSEG1.RecordTypeId = cRT;
		contactSEG1.LastName = 'CUENTA PENDIENTE ASOCIAR';	
        contactSEG1.email='pruebas@test.com';	
        contactSEG1.AccountId=lstAccount[0].Id;
        lstContact.add(contactSEG1);
	
/*        Contact contactSEG2 = new Contact();
		contactSEG2.RecordTypeId = cRT;
		contactSEG2.LastName = 'CUENTA EMPRESA';
        contactSEG2.email='pruebas@test.com';
        contactSEG2.AccountId=lstAccount[1].Id; 
        lstContact.add(contactSEG2);*/
        
        insert lstContact;

        contactSEG1.AccountId=lstAccount[1].Id;
        update contactSEG1;


        Test.startTest();
        Id jobid= Database.executeBatch(new SEG_ContactPendienteAsociar_P2_Batch(), 1);
        Test.stopTest();
        list<AccountContactRelation> lstfinal = [Select Id from AccountContactRelation where contactId=:lstContact[0].Id];        
        system.AssertEquals(1,lstfinal.size());
    }

    @IsTest
	static void Paso3(){
        
        //Crear Accounts
        list<Account> lstAccount = new list<Account>();
		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'CUENTA PENDIENTE ASOCIAR';		
        lstAccount.add(cuentaSEG1);
		
        Account cuentaSEG2 = new Account();
		cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		cuentaSEG2.Name = 'CUENTA EMPRESA';
		cuentaSEG2.CC_Numero_Documento__c = '11111111H';
        lstAccount.add(cuentaSEG2);
        
        insert lstAccount;

        //Crear Contacts
        Id cRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        list<Contact> lstContact = new list<Contact>();
/*		Contact contactSEG1 = new Contact();
		contactSEG1.RecordTypeId = cRT;
		contactSEG1.LastName = 'CUENTA PENDIENTE ASOCIAR';	
        contactSEG1.email='pruebas@test.com';	
        contactSEG1.AccountId=lstAccount[0].Id;
        lstContact.add(contactSEG1);*/
	
        Contact contactSEG2 = new Contact();
		contactSEG2.RecordTypeId = cRT;
		contactSEG2.LastName = 'CUENTA EMPRESA';
        contactSEG2.email='pruebas@test.com';
        contactSEG2.AccountId=lstAccount[1].Id; 
        lstContact.add(contactSEG2);        
        insert lstContact;

        //Crear Caso
		Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.AccountId = lstAccount[0].Id ;
		caso1.ContactId = lstContact[0].Id;
		caso1.SEG_Idioma__c = 'en';
        caso1.CC_MailTelfNotif__c = 'test@test.com';
		caso1.CC_AcuseRecibo__c = '1';
		caso1.Subject = 'Activo';
		caso1.Status = 'Pendiente';
		insert caso1;


        Test.startTest();
        Id jobid= Database.executeBatch(new SEG_ContactPendienteAsociar_P3_Batch(), 1);
        Test.stopTest();
        list<Case> lstfinal = [Select Id from Case where AccountId=:lstAccount[0].Id and contactId=:lstContact[0].Id];        
        system.AssertEquals(0,lstfinal.size());
    }

 
    @IsTest
	static void Paso4(){
        
        //Crear Accounts
		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'CUENTA PENDIENTE ASOCIAR';		
		        
        insert cuentaSEG1;

        
        Test.startTest();
        Id jobid= Database.executeBatch(new SEG_ContactPendienteAsociar_P4_Batch(), 1);
        Test.stopTest();
        list<Account> lstfinal = [Select Id from Account where Id=:cuentaSEG1.Id ];        
        system.AssertEquals(0,lstfinal.size());
    }   

    @IsTest
    static void pasoCinco(){

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];
        
        System.runAs(usuarioTest) {
            // Crear Accounts
            List<Account> lstAccount = new List<Account>();
            Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
            cuentaSEG1.Name = 'CUENTA PENDIENTE ASOCIAR';		
            lstAccount.add(cuentaSEG1);
            
            Account cuentaSEG2 = new Account();
            cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuentaSEG2.Name = 'CUENTA EMPRESA';
            cuentaSEG2.CC_Numero_Documento__c = '11111111H';
            lstAccount.add(cuentaSEG2);
            
            insert lstAccount;
        
            // Crear Contacts
            Id cRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            List<Contact> lstContact = new List<Contact>();
            Contact contactSEG1 = new Contact();
            contactSEG1.RecordTypeId = cRT;
            contactSEG1.LastName = 'CUENTA PENDIENTE ASOCIAR';	
            contactSEG1.email='pruebas@test.com';	
            contactSEG1.AccountId=lstAccount[0].Id;
            lstContact.add(contactSEG1);
            
            Contact contactSEG2 = new Contact();
            contactSEG2.RecordTypeId = cRT;
            contactSEG2.LastName = 'CUENTA EMPRESA';
            contactSEG2.email='pruebas@test.com';
            contactSEG2.AccountId=lstAccount[1].Id; 
            lstContact.add(contactSEG2);
            
            insert lstContact;
        
            // Crear Caso
            Case caso1 = new Case();
            caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
            caso1.AccountId = lstAccount[0].Id ;
            caso1.ContactId = lstContact[0].Id;
            caso1.SEG_Idioma__c = 'en';
            caso1.CC_MailTelfNotif__c = 'test@test.com';
            caso1.CC_AcuseRecibo__c = '1';
            caso1.Subject = 'Activo';
            caso1.Status = 'Descartado';
            insert caso1;
        
            Test.startTest();
            Id jobid= Database.executeBatch(new SEG_ContactPendienteAsociar_P5_Batch(), 1);
            Test.stopTest();
        
            // Verificar que los contactos y cuentas hayan sido eliminados
            List<Contact> lstfinalContact = [Select Id from Contact where LastName='CUENTA PENDIENTE ASOCIAR'];
            system.assertEquals(true,lstfinalContact.isEmpty(), 'No se ha borrado el contacto');
        
            List<Account> lstfinalAccount = [Select Id from Account where Name='CUENTA PENDIENTE ASOCIAR'];
            system.assertEquals(true,lstfinalAccount.isEmpty(), 'No se ha borrado la cuenta');
            
            Case caso = [SELECT Id, AccountId, ContactId FROM Case LIMIT 1];
            System.assertEquals(caso.AccountId,null, 'No se ha borrado la cuenta del caso');
            System.assertEquals(caso.ContactId,null, 'No se ha borrado el contacto del caso');
        }
    }
}