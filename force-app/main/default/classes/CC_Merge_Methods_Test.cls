@IsTest
public with sharing class CC_Merge_Methods_Test {
    
    static testMethod void simpleMerge() {
        // Insert new accounts
        List<Account> ls = new List<Account>{
            new Account(name='Acme Inc.'),
                new Account(name='Acme')
                };                                        
        insert ls;
        // Queries to get the inserted accounts 
        Account masterAcct = [SELECT Id, Name FROM Account WHERE Name = 'Acme Inc.' LIMIT 1];
        Account mergeAcct = [SELECT Id, Name FROM Account WHERE Name = 'Acme' LIMIT 1];

        // Add a contact to the account to be merged
        Contact c = new Contact(FirstName='Joe',LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        
        CC_Merge_Methods.CC_Simple_Merge_Accounts(masterAcct, mergeAcct);

        // the related contact should be moved to the master record.
        masterAcct = [SELECT Id, Name, (SELECT FirstName,LastName From Contacts) FROM Account WHERE Name = 'Acme Inc.' LIMIT 1];
        System.assert(masterAcct.getSObjects('Contacts').size() > 0);
        System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
        System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));

        // Verificar que se ha borrado el que se ha fusionado
        Account[] result = [SELECT Id, Name FROM Account WHERE Id=:mergeAcct.Id];
        System.assertEquals(0, result.size());
    }
    
    static testMethod void simpleMergeKO() {
        // Insert new accounts
        List<Account> ls = new List<Account>{
            new Account(name='Acme Inc.'),
                new Account(name='Acme')
                };                                        
        insert ls;
        // Queries to get the inserted accounts 
        Account masterAcct = [SELECT Id, Name FROM Account WHERE Name = 'Acme Inc.' LIMIT 1];
        Account mergeAcct = [SELECT Id, Name FROM Account WHERE Name = 'Acme Inc.' LIMIT 1];

        // Add a contact to the account to be merged
        Contact c = new Contact(FirstName='Joe',LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        
        CC_Merge_Methods.CC_Simple_Merge_Accounts(masterAcct, mergeAcct);

        // Verificar que no se ha borrado porque ha dado error
        Account[] result = [SELECT Id, Name FROM Account WHERE Id=:mergeAcct.Id];
        System.assertEquals(1, result.size());
    }

    static testMethod void databaseMerge() {
        // Create master account
        Account master = new Account(Name='Account1');
        insert master;

        // Create duplicate accounts
        List<Account> duplicates = new List<Account>{
            // Duplicate account 
            new Account(Name='Account1, Inc.'),
            // Second duplicate account
            new Account(Name='Account 1')
        };                                        
        insert duplicates;

        // Create child contact and associate it with first account
        Id accountId = [SELECT Id FROM Account WHERE Name =: 'Account1, Inc.'].Id;
        Contact c = new Contact(firstname='Joe',lastname='Smithy', accountId=accountId);
        insert c;

        CC_Merge_Methods.CC_Database_Merge_Accounts(master, duplicates);

        // the related contact should be moved to the master record.
        Account masterAcct = [SELECT Id, Name, (SELECT FirstName,LastName From Contacts) FROM Account WHERE Name = 'Account1' LIMIT 1];
        System.assert(masterAcct.getSObjects('Contacts').size() > 0);
        System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
        System.assertEquals('Smithy', masterAcct.getSObjects('Contacts')[0].get('LastName'));

        // Verificar que se ha borrado el que se ha fusionado
        Account[] result = [SELECT Id, Name FROM Account WHERE Name=:'Account1, Inc.'];
        System.assertEquals(0, result.size());
    }
    
    static testMethod void databaseMergeKO() {
        // Create master account
        Account master = new Account(Name='Account1');
        insert master;

        // Create duplicate accounts
        List<Account> duplicates = new List<Account>{
            // Duplicate account 
            new Account(Name='Account1, Inc.'),
            // Second duplicate account
            new Account(Name='Account 1'),
            // Third duplicate account
            new Account(Name='Account_1')
        };                                        
        insert duplicates;

        // Create child contact and associate it with first account
        Id accountId = [SELECT Id FROM Account WHERE Name =: 'Account1, Inc.'].Id;
        Contact c = new Contact(firstname='Joe',lastname='Smithy', accountId=accountId);
        insert c;

        CC_Merge_Methods.CC_Database_Merge_Accounts(master, duplicates);

        // Verificar que se ha borrado el que se ha fusionado
        Account[] result = [SELECT Id, Name FROM Account WHERE Name=:'Account1, Inc.'];
        System.assertEquals(1, result.size());
    }
    
    static testMethod void simpleContactMerge() {
        // Insert new accounts
        List<Contact> ls = new List<Contact>{
            new Contact(FirstName ='Acme Inc.', LastName='1'),
            new Contact(FirstName ='Acme', LastName='2')
                };                                        
        insert ls;
        // Queries to get the inserted accounts 
        Contact masterAcct = [SELECT Id, FirstName  FROM Contact WHERE FirstName  = 'Acme Inc.' LIMIT 1];
        Contact mergeAcct = [SELECT Id, FirstName  FROM Contact WHERE FirstName  = 'Acme' LIMIT 1];
        
        CC_Merge_Methods.CC_Simple_Merge_Contacts(masterAcct, mergeAcct);

        // the related contact should be moved to the master record.
        masterAcct = [SELECT Id, FirstName  FROM Contact WHERE FirstName  = 'Acme Inc.' LIMIT 1];
        
        // Verificar que se ha borrado el que se ha fusionado
        Contact[] result = [SELECT Id, FirstName  FROM Contact WHERE Id=:mergeAcct.Id];
        System.assertEquals(0, result.size());
    }
    
    static testMethod void simpleContactMergeKO() {
        // Insert new accounts
        List<Contact> ls = new List<Contact>{
            new Contact(FirstName ='Acme Inc.', LastName='1')
                };                                        
        insert ls;
        // Queries to get the inserted accounts 
        Contact masterAcct = [SELECT Id, FirstName  FROM Contact WHERE FirstName  = 'Acme Inc.' LIMIT 1];
        Contact mergeAcct = [SELECT Id, FirstName  FROM Contact WHERE FirstName  = 'Acme Inc.' LIMIT 1];
        
        CC_Merge_Methods.CC_Simple_Merge_Contacts(masterAcct, mergeAcct);

        // the related contact should be moved to the master record.
        masterAcct = [SELECT Id, FirstName  FROM Contact WHERE FirstName  = 'Acme Inc.' LIMIT 1];
        
        // Verificar que se ha borrado el que se ha fusionado
        Contact[] result = [SELECT Id, FirstName  FROM Contact WHERE Id=:mergeAcct.Id];
        System.assertEquals(1, result.size());
    }
    
    static testMethod void databaseMergeContact() {
        // Create master account
        Contact master = new Contact(FirstName='Account1',LastName='1');
        insert master;

        // Create duplicate accounts
        List<Contact> duplicates = new List<Contact>{
            // Duplicate account 
            new Contact(FirstName='Account1, Inc.',LastName='2'),
            // Second duplicate account
            new Contact(FirstName='Account 1',LastName='3')
        };                                        
        insert duplicates;

        CC_Merge_Methods.CC_Database_Merge_Contacts(master, duplicates);

        // the related contact should be moved to the master record.
        Contact masterAcct = [SELECT Id, FirstName FROM Contact WHERE FirstName = 'Account1' LIMIT 1];

        // Verificar que se ha borrado el que se ha fusionado
        Contact[] result = [SELECT Id, FirstName FROM Contact WHERE FirstName=:'Account1, Inc.'];
        System.assertEquals(0, result.size());
    }
    
    static testMethod void databaseMergeContactKO() {
        // Create master account
        Contact master = new Contact(FirstName='Account1',LastName='1');
        insert master;

        // Create duplicate accounts
        List<Contact> duplicates = new List<Contact>{
            // Duplicate account 
            new Contact(FirstName='Account1, Inc.',LastName='2'),
            // Second duplicate account
            new Contact(FirstName='Account 1',LastName='3'),
            // Third duplicate account
            new Contact(FirstName='Account_1',LastName='4')
        };                                        
        insert duplicates;

        CC_Merge_Methods.CC_Database_Merge_Contacts(master, duplicates);

        // the related contact should be moved to the master record.
        Contact masterAcct = [SELECT Id, FirstName FROM Contact WHERE FirstName = 'Account1' LIMIT 1];

        // Verificar que se ha borrado el que se ha fusionado
        Contact[] result = [SELECT Id, FirstName FROM Contact WHERE FirstName=:'Account1, Inc.'];
        System.assertEquals(1, result.size());
    }
}