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

***********************************************************************************************************************/

@isTest
public class CIBE_Contacts_Controller_Test {
	
    @TestSetup
    static void testSetup() {
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
      	User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);

        System.runAs(usuario) {
            Account acc = CIBE_TestHelper.createCustomer();
            
            Contact contact = new Contact();
            contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();
            contact.LastName = 'Prueba 1';
            contact.Phone = '987456321';
            contact.AccountId = acc.Id;
            insert contact;
            
            Contact contact2 = new Contact();
            contact2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();
            contact2.LastName = 'Prueba 2';
            contact2.Phone = '987456322';
            contact2.AccountId = acc.Id;
            insert contact2;
        }
    }
    
    @isTest
    public static void getRecordsTest() {
      	List<User> usuario = [SELECT id FROM user WHERE LastName = 'testLastName' LIMIT 1];
        System.runAs(usuario[0]) {
            Test.startTest();
          	List<Account> accList = [SELECT Id FROM Account LIMIT 1];
            List<CIBE_Contacts_Controller.Wrapper> contList = CIBE_Contacts_Controller.getRecords(accList[0].Id);
            System.assert(!accList.isEmpty());
            System.assert(!CIBE_Contacts_Controller.getRecords(accList[0].Id).isEmpty());
            System.assert(contList[0].compareTo(contList[1]) < 0);
         	Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordTypeTest() {
       	List<User> usuario = [SELECT id FROM user WHERE LastName = 'testLastName' LIMIT 1];

        System.runAs(usuario[0]) {
        	Test.startTest();
            	System.assert(String.isNotBlank(CIBE_Contacts_Controller.getRecordType()));
          	Test.stopTest(); 
        }
    }
    
    @isTest
    public static void deleteContactTest() {
        List<User> usuario = [SELECT id FROM user WHERE LastName = 'testLastName' LIMIT 1];
       	
        System.runAs(usuario[0]) {
        	Test.startTest();
                List<Contact> contactList = [SELECT Id FROM Contact where LastName = 'Prueba 1'  LIMIT 1];
                System.assert(!contactList.isEmpty());
                CIBE_Contacts_ControllerDelete.deleteContact(contactList[0].Id);
                System.assert([SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CIBE_ContactoComercial' and LastName = 'Prueba 1'].isEmpty());
            Test.stopTest(); 
        }
    }

    @isTest
    public static void hasPermissionTest() {
        List<User> usuarios = [SELECT Id, AV_TipoGestor__c FROM User WHERE LastName = 'testLastName' LIMIT 1];
        usuarios[0].AV_TipoGestor__c = 'Tec. Ges. Act.';
        update usuarios;
            
       PermissionSetAssignment existingPsa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usuarios[0].Id AND PermissionSet.Name = 'CIBE_OperativaEMP' LIMIT 1];
    
        if (existingPsa == null) {
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = usuarios[0].Id,
                PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CIBE_OperativaEMP' LIMIT 1].Id
            );
            insert psa;
        }
        
        Test.startTest();
        System.runAs(usuarios[0]) {
            boolean resultTrue = CIBE_Contacts_Controller.hasPermission();
            System.assertEquals(true, resultTrue);
        }

        Test.stopTest(); 
    }
}