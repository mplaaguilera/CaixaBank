/*
Name:	  CIBE_Apoderados_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for CIBE_Apoderados
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0                         Mikel Lezama        28/11/2022      Init Version
*/
@isTest
public class CIBE_Apoderados_Controller_Test {
	
    @testSetup
    public static void testSetup() {
        CIBE_TestInitialSetup.setupInitialDataEMP();
        
        User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Contact empleado = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001'];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account acc = CIBE_TestHelper.createCustomerWithEAPGestor(empleado);
            Contact contact = new Contact();
            contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.CONTACT_APODERADO_RT).getRecordTypeId();
            contact.LastName = 'Prueba 1';
            contact.AccountId = acc.Id;
            contact.OwnerId = gestor.Id;
            insert contact;
        }
    }
    
    @isTest
    public static void getRecordsTest() {
        User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        System.runAs(gestor) {
            String rt = CIBE_AppConstants.ACCOUNT_CLIENTE_RT;
            Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName =: rt];
            System.assert(!CIBE_Apoderados_Controller.getRecords(acc.Id).isEmpty());
        }
    }
    
    @isTest
    public static void getRecordTypeTest() {
        User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        System.runAs(gestor) {
            String rt = CIBE_AppConstants.CONTACT_APODERADO_RT;
            Contact contact = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: rt];
            System.assert(String.isNotBlank(CIBE_Apoderados_Controller.getRecordType()));
        }
    }
    
}