@isTest
public with sharing class CC_Contact_Fusion_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static testMethod void fusionarContactosDuplicados() {
		Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id clienteRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        Account cuenta1 = new Account(
        	RecordTypeId = cuentaRecordTypeId,
            Name = 'Cuenta Cliente Test 1',
            CC_NumPerso__c = '42671'
        );
        insert cuenta1;
        Account cuenta2 = new Account(
        	RecordTypeId = cuentaRecordTypeId,
            Name = 'Cuenta Cliente Test 2',
            CC_NumPerso__c = '42672'
        );
        insert cuenta2;

        List<Contact> mergeContacts = new List<Contact>();
        for(Integer i = 0 ; i < 10; i++) {
            Contact mergeContact = new Contact(
                RecordTypeId = clienteRecordTypeId,
                FirstName = 'Merge',
                LastName = 'Contact'+i,
                //AccountId = cuenta.id,
                CC_Idioma__c = 'es',
                CC_NumPersoOrig__c = ''+i
            );
            mergeContacts.add(mergeContact);
        }
        insert mergeContacts;

        List<Contact> masterContacts = new List<Contact>();
        for(Integer i = 0 ; i < 10; i++) {
            Contact masterContact = new Contact(
                RecordTypeId = clienteRecordTypeId,
                FirstName = 'Master',
                LastName = 'Contact'+i,
                //AccountId = cuenta.id,
                CC_Idioma__c = 'es',
                CC_NumPerso__c = ''+i
            );
            masterContacts.add(masterContact);
        }
        insert masterContacts;
		
        List<Contact> mergeContactsBefore = [SELECT Id FROM Contact WHERE FirstName = 'Merge'];
        List<Contact> masterContactsBefore = [SELECT Id FROM Contact WHERE FirstName = 'Master'];
        System.assertEquals(10, mergeContactsBefore.size());
        System.assertEquals(10, masterContactsBefore.size());

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new CC_Contact_Fusion());    
        Test.stopTest();
        
        List<Contact> mergeContactsAfter = [SELECT Id FROM Contact WHERE FirstName = 'Merge'];
        List<Contact> masterContactsAfter = [SELECT Id FROM Contact WHERE FirstName = 'Master'];
        System.assertEquals(0, mergeContactsAfter.size());
        System.assertEquals(10, masterContactsAfter.size());
    }
}