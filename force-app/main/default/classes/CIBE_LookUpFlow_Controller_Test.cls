/**********************************************************************************************************************
 Name:      CIBE_LookUpFlow_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_LookUpFlow_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				DATE        Description
   	1.0      Initial				Mikel Lezama		27/10/2022  Init version

***********************************************************************************************************************/
@isTest
public class CIBE_LookUpFlow_Controller_Test {
  	@TestSetup
    static void setup(){
        User usrTest 	= CIBE_TestHelper.createUser('Standard User');
        Account customerBPA = CIBE_TestHelper.createCustomer();
        Task taskAux = CIBE_TestHelper.createTareaExternalIdWithCustomer(usrTest, '235235', customerBPA);
        Contact contactAux = CIBE_TestHelper.createRepresentante(null, usrTest, '000000000');
    }
    
    @isTest
    public static void searchTestWithSelectedIdsAndCondition(){
        
        Test.startTest();
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= 'AV_';       
        String condition ='RecordType.DeveloperName = \'CC_Representante\' and AccountId = \''+ acc.Id+'\'';
        String title = 'Subject';
        String subtitle = 'OwnerId';
        String objectName = 'Task';
        string icon='standard:contact';
        List<Task> taskId = [SELECT id From Task LIMIT 10];
        List<String> selectedIds = new List<String>();     
        for(Task auxId : taskId){
            selectedIds.add(auxId.id);
        }       
      	List<AV_LookupSearchResult> results = CIBE_LookUpFlow_Controller.search(searchTerm, selectedIds, condition, title, subtitle, objectName, icon);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
    }
    
    @isTest
    public static void searchTestWithSelectedIdsAndWithoutcondition(){
        
        Test.startTest();
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= 'Lla';       
        String condition ;
        String title = 'Subject';
        String subtitle = 'OwnerId';
        String objectName = 'Task';
        string icon='standard:contact';
        List<Task> taskId = [SELECT id From Task LIMIT 10];
        List<String> selectedIds = new List<String>();     
        for(Task auxId : taskId){
            selectedIds.add(auxId.id);
        }       
      	List<AV_LookupSearchResult> results = CIBE_LookUpFlow_Controller.search(searchTerm, selectedIds, condition, title, subtitle, objectName, icon);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
    }
    
	@isTest
    public static void searchTestWithoutSelectedIdsAndCondition(){
        
        Test.startTest();
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= 'AV_';       
        String condition ='RecordType.DeveloperName = \'AV_Otros\' and AccountId = \''+ acc.Id+'\'';
        String title = 'Subject';
        String subtitle = 'OwnerId';
        String objectName = 'Task';
        string icon='standard:contact';
        List<String> selectedIds = new List<String>();     
     
      	List<AV_LookupSearchResult> results = CIBE_LookUpFlow_Controller.search(searchTerm, selectedIds, condition, title, subtitle, objectName, icon);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
    }
    
	@isTest
    public static void searchTestWithoutSelectedIdsAndWithoutcondition(){
        
        Test.startTest();
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= 'Lla';       
        String condition ;
        String title = 'Subject';
        String subtitle = 'OwnerId';
        String objectName = 'Task';
        string icon='standard:contact';
        List<String> selectedIds = new List<String>();     
     
      	List<AV_LookupSearchResult> results = CIBE_LookUpFlow_Controller.search(searchTerm, selectedIds, condition, title, subtitle, objectName, icon);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
    }
}