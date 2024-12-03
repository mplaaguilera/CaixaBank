@isTest
public class CIBE_DeleteNotAssignedContactsBatch_Test {
	@TestSetup
	static void setup() {
                
        CIBE_TestInitialSetup.setupInitialDataEMP();
        Contact contactToDelete = new Contact();
        contactToDelete.lastname = 'contactToDelete';
        contactToDelete.CIBE_AsistenteNoRegistrado__c = true;
        
        insert contactToDelete;
        
        Test.setCreatedDate(contactToDelete.Id, Date.today().addDays(-100));
	}

	/**
	 * Execute the Batch class (CIBE_DeleteNotAssignedContactsBatch) 
	 */
	@isTest
	static void executeDeleteNotAssignedContactsBatch() {
                User userAs = [SELECT Id From User WHERE AV_ExternalID__c = 'U0000001'];
                System.runAs(userAs){
                        CIBE_DeleteNotAssignedContactsBatch b = new CIBE_DeleteNotAssignedContactsBatch();
                
                        Test.startTest();	
                        Database.executeBatch(b);
                        Test.stopTest();
                        
                        List<Contact> contactList = [SELECT id FROM Contact];
                        System.assertNotEquals(contactList, new List<Contact>());
                }
                
	}
    
    /**
	 * Execute the Batch class (CIBE_DeleteNotAssignedContactsBatch) 
	 */
	@isTest
	static void executeDeleteNotAssignedContactsBatch2() {
                User userAs = [SELECT Id From User WHERE AV_ExternalID__c = 'U0000001'];
                System.runAs(userAs){
        
                        CIBE_DeleteNotAssignedContactsBatch b = new CIBE_DeleteNotAssignedContactsBatch('SELECT ID FROM CONTACT');
                                
                        Test.startTest();	
                        Database.executeBatch(b);
                        Test.stopTest();
                        
                        List<Contact> contactList = [SELECT id FROM Contact];
                        System.assertEquals(contactList, new List<Contact>());
                }
	}
    
    /**
	 * Execute the Batch class (CIBE_DeleteNotAssignedContactsBatch) 
	 */
	@isTest
	static void executeDeleteNotAssignedContactsBatchCronExpression() {
                User userAs = [SELECT Id From User WHERE AV_ExternalID__c = 'U0000001'];
                System.runAs(userAs){
			
                        Test.startTest();
                        
                        String cronExpr = '0 0 0 15 3 ? 2030';
                        CIBE_DeleteNotAssignedContactsBatch b = new CIBE_DeleteNotAssignedContactsBatch();
                        String jobId = System.schedule('schedulable', cronExpr, b);
                        Test.stopTest();
                        
                        List<Contact> contactList = [SELECT id FROM Contact];
                        System.assertNotEquals(contactList, new List<Contact>());
                }
	}
}