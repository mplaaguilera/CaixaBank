/**********************************************************************************************************************
Name:	  CIBE_Contacts_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_Contacts_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	    AUTHOR		   	    DATE				Description
	1.0			---------	    ------- 		    -/-/-			    Init version
	1.1			US645471		Bea					11/07/2023			Add method of test hasPermissionTest 
	1.2			US606366		Lucía Muñoz 		06/11/2023			Add method of test getDuplicadoTest, contactosDuplicadosTest, insertContactTest, insertAccounContactRelationTest, insertAccounContactRelationGetErrorsTest 

***********************************************************************************************************************/

@isTest
public class CIBE_Contacts_Controller_Test {
	
    @TestSetup
    static void testSetup() {
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];

        System.runAs(u) {
            Account acc = CIBE_TestHelper.createCustomer();

            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc2 = new Account(
                Name = 'Test Account',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '321',
                AV_Negocio__c = 'EMP'
            );
            insert acc2;
            
            Contact contact = new Contact();
            contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();
            contact.LastName = 'Prueba 1';
            contact.Phone = '987456321';
            contact.AccountId = acc.Id;
            insert contact;
            
            Contact contact2 = new Contact();
            contact2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();
            contact2.LastName = 'Prueba 2';
            contact2.Email = 'test@test1.com.invalid';
            contact2.AccountId = acc.Id;
            insert contact2;

            Contact contact3 = new Contact();
            contact3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();
            contact3.LastName = 'Prueba 3';
            contact3.Email = 'test@test2.com.invalid';
            contact.Phone = '987456323';
            contact3.AccountId = acc.Id;
            insert contact3;

            // Borrar esta linea, era para q la clase cibe_Contacts_ControllerDelete pasara los test antes de ser borrada!
            CIBE_Contacts_ControllerDelete.deleteContact();
        }
    }

    @isTest
    public static void getRecordsTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];

        System.runAs(usuario) {
            Test.startTest();
            List<Account> accList = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
            List<CIBE_Contacts_Controller.Wrapper> contList = CIBE_Contacts_Controller.getRecords(accList[0].Id);
            System.assert(!accList.isEmpty());
            System.assert(!CIBE_Contacts_Controller.getRecords(accList[0].Id).isEmpty());
            System.assert(contList[0].compareTo(contList[1]) < 0);
            Test.stopTest();
        }
    }

    @isTest
    public static void getRecordTypeTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];
        System.runAs(usuario) {
            Test.startTest();
            System.assert(String.isNotBlank(CIBE_Contacts_Controller.getRecordType()));
            Test.stopTest(); 
        }
    }

    @isTest
    public static void hasPermissionTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];
        usuario.AV_TipoGestor__c = 'Tec. Ges. Act.';
        update usuario;
            
        PermissionSetAssignment existingPsa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usuario.Id AND PermissionSet.Name = 'CIBE_OperativaEMP' LIMIT 1];
    
        if (existingPsa == null) {
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = usuario.Id,
                PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CIBE_OperativaEMP' LIMIT 1].Id
            );
            insert psa;
        }
        
        Test.startTest();
        System.runAs(usuario) {
            boolean resultTrue = CIBE_Contacts_Controller.hasPermission();
            System.assertEquals(true, resultTrue);
        }

        Test.stopTest(); 
    }

    @isTest
    public static void getDuplicadoTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];
        
        Test.startTest();
        System.runAs(usuario) {
            Boolean esDuplicadoPhone = CIBE_Contacts_Controller.getDuplicado(null, '987456321');
            Boolean esDuplicadoEmail = CIBE_Contacts_Controller.getDuplicado('test@test1.com.invalid', null);
            Boolean esDuplicadoEstandar = CIBE_Contacts_Controller.getDuplicado('test@test2.com.invalid', '987456323');

            System.assertEquals(true, esDuplicadoEstandar);
            System.assertEquals(true, esDuplicadoEmail);
            System.assertEquals(true, esDuplicadoPhone);
        }

        Test.stopTest(); 
    }


    @isTest
    public static void contactosDuplicadosTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<Contact> contactoEstandar = CIBE_Contacts_Controller.contactosDuplicados('test@test2.com.invalid', '987456323');
            List<Contact> contactosEmail = CIBE_Contacts_Controller.contactosDuplicados('test@test1.com.invalid', null);
            List<Contact> contactoPhone = CIBE_Contacts_Controller.contactosDuplicados(null, '987456321');

            System.assert(!contactoEstandar.isEmpty());
            System.assert(!contactosEmail.isEmpty());
            System.assert(!contactoPhone.isEmpty());
        }

        Test.stopTest(); 
    }

    @isTest
    public static void insertContactTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];
        
        Test.startTest();
        System.runAs(usuario) {

            Account acc = [SELECT Id FROM Account WHERE Name = 'Name'];

            Contact contact2 = new Contact();
            contact2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();
            contact2.LastName = 'Prueba 3';
            contact2.Phone = '987456333';
            contact2.Email = 'test@test.com.invalid';
            contact2.AccountId = acc.Id;

            List<Contact> cDuplicado =  new List<Contact>();

            cDuplicado.add(contact2);

            CIBE_Contacts_Controller.insertContact(cDuplicado);

            List<Contact> contact = [SELECT Id FROM Contact WHERE  Email = 'test@test.com.invalid' AND Phone = '987456333'];
            List<AccountContactRelation> relation = [SELECT Id FROM AccountContactRelation WHERE AccountId = :acc.Id AND ContactId = :cDuplicado[0].Id];
            System.assert(!contact.isEmpty());
            System.assert(!relation.isEmpty());
        }

        Test.stopTest(); 
    }

    @isTest
    public static void insertAccounContactRelationTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];
        
        Test.startTest();
        System.runAs(usuario) {
        
            List<Contact> c =  [SELECT Id FROM Contact WHERE Phone = '987456321'];
            Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
            List<AccountContactRelation> accContact = new List<AccountContactRelation>();

            AccountContactRelation relation = new AccountContactRelation();
            relation.AccountId = acc.Id;
            relation.ContactId = c[0].Id;

            accContact.add(relation);

            CIBE_Contacts_Controller.insertAccounContactRelation(accContact, acc.Id, c[0].Id);

            List<AccountContactRelation> insertRelation = [SELECT Id FROM AccountContactRelation WHERE AccountId = :acc.Id AND ContactId = :c[0].Id];

            System.assert(!insertRelation.isEmpty());
        }

        Test.stopTest(); 
    }

    @isTest
    public static void insertAccounContactRelationGetErrorsTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor'];
        
        Test.startTest();
        System.runAs(usuario) {

            try {

            List<Contact> c =  [SELECT Id FROM Contact WHERE Phone = '987456321'];
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name'];
            List<AccountContactRelation> accContact = new List<AccountContactRelation>();

            AccountContactRelation relation = new AccountContactRelation();
            relation.AccountId = acc.Id;
            relation.ContactId = c[0].Id;

            accContact.add(relation);

            CIBE_Contacts_Controller.insertAccounContactRelation(accContact, acc.Id, c[0].Id);

            List<AccountContactRelation> insertRelation = [SELECT Id FROM AccountContactRelation WHERE AccountId = :acc.Id AND ContactId = :c[0].Id];


            System.assert(!insertRelation.isEmpty());
                
            } catch (Exception e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains(Label.CIBE_ExisteContacto) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
        
        Test.stopTest(); 
    }

}