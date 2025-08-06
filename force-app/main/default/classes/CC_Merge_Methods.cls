public with sharing class CC_Merge_Methods {
    
    public static void CC_Simple_Merge_Accounts(Account masterAcc, Account mergeAcc) {
        // Merge a la cuenta considerada master
        try {
            merge masterAcc mergeAcc;
        } catch (DmlException e) {
            // Process exception
            System.debug('An unexpected error has occurred: ' + e.getMessage()); 
        }
    }

    public static void CC_Database_Merge_Accounts(Account masterAcc, List<Account> duplicatesAcc) {
        // Merge accounts into master
        Database.MergeResult[] results = Database.merge(masterAcc, duplicatesAcc, false);

        for(Database.MergeResult res : results) {
            if (res.isSuccess()) {
                // Get the master ID from the result and validate it
                System.assertEquals(masterAcc.Id, res.getId());              
                
                // Get the IDs of the merged records and display them
                List<Id> mergedIds = res.getMergedRecordIds();
            }
            else {
                for(Database.Error err : res.getErrors()) {
                    // Write each error to the debug output
                    System.debug(err.getMessage());
                }
            }
        }
    }
    
    public static void CC_Simple_Merge_Contacts(Contact masterCont, Contact mergeCont) {
        // Merge a la cuenta considerada master
        try {
            merge masterCont mergeCont;
        } catch (DmlException e) {
            // Process exception
            System.debug('An unexpected error has occurred: ' + e.getMessage()); 
        }
    }
    
    public static void CC_Database_Merge_Contacts(Contact masterCont, List<Contact> duplicatesCont) {
        // Merge accounts into master
        Database.MergeResult[] results = Database.merge(masterCont, duplicatesCont, false);

        for(Database.MergeResult res : results) {
            if (res.isSuccess()) {
                // Get the master ID from the result and validate it
                System.assertEquals(masterCont.Id, res.getId());              
                
                // Get the IDs of the merged records and display them
                List<Id> mergedIds = res.getMergedRecordIds();
            }
            else {
                for(Database.Error err : res.getErrors()) {
                    // Write each error to the debug output
                    System.debug(err.getMessage());
                }
            }
        }
    }
}