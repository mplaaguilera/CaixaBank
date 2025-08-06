global class CC_Contact_Fusion implements Schedulable {
    global void execute(SchedulableContext SC) {
        
        // Recopilamos los contactos a fusionar
        Map<String, Contact> contactsToMerge = new Map<String, Contact>();
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        for (Contact contactToMerge : [SELECT Id, CC_NumPersoOrig__c, AccountId FROM Contact WHERE CC_NumPerso__c = null AND CC_NumPersoOrig__c != null LIMIT 10]) {
            contactsToMerge.put(contactToMerge.CC_NumPersoOrig__c, contactToMerge);
        }

        // Fusionamos contactos
        contactsToMerge = mergeContacts(contactsToMerge);

        // Fusionamos cuentas
        mergeAccounts(contactsToMerge);
    }

    public static Map<String, Contact> mergeContacts(Map<String, Contact> contactsToMerge) {

        for (Contact masterContact : [SELECT Id, CC_NumPerso__c FROM Contact WHERE CC_NumPerso__c in :contactsToMerge.keyset()]) {
            Contact contactToMerge = contactsToMerge.get(masterContact.CC_NumPerso__c);
            CC_Merge_Methods.CC_Simple_Merge_Contacts(masterContact, contactToMerge);
            contactsToMerge.remove(masterContact.CC_NumPerso__c);
        }

        return contactsToMerge;
    }

    public static void mergeAccounts(Map<String, Contact> contactsToMerge) {

        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Account masterAccount : [SELECT Id, CC_NumPerso__c FROM Account WHERE CC_NumPerso__c in :contactsToMerge.keyset()]) {
            Contact contactToMerge = contactsToMerge.get(masterAccount.CC_NumPerso__c);
            if (contactToMerge.AccountId != null) {
                CC_Merge_Methods.CC_Simple_Merge_Accounts(masterAccount, contactToMerge.Account);
            }
            else {
                contactToMerge.Account = new Account(CC_NumPerso__c = contactToMerge.CC_NumPersoOrig__c);
                contactsToUpdate.add(contactToMerge);
            }
        }
        update contactsToUpdate;
    }
}