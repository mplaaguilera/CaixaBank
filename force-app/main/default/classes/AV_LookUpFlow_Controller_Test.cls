/**********************************************************************************************************************
 Name:      AV_LookUpFlow_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of AV_LookUpFlow_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				DATE        Description
   	1.0      Initial				Sandra Gómez		29/09/2022  Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_LookUpFlow_Controller_Test {
    
  	@TestSetup
    static void setup(){
        
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        List<Account> listAccounts = new List<Account>();
        System.runAs(userCli) {
            Account centro = AV_TestHelper.createCaixaCenterSinInsert();
            centro.OwnerId = userGestor.Id;
            listAccounts.add(centro);
            Database.insert(listAccounts,false);
        }
        

        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
			User usrTest= AV_TestHelper.createUser('AV_Usuario_CaixaBank', null, 'AV_MisClientes');
            Account customerBPA = AV_TestHelper.createCustomer();
            Task taskAux = AV_TestHelper.createTareaExternalIdWithCustomer(usrTest, '235235', customerBPA);
            Contact contactAux = AV_TestHelper.createRepresentante(null, usrTest, '000000000');
            Contact contact2 = AV_TestHelper.createRepresentante(listAccounts[0], usrTest); 
        }
        
        
        
    }
    
    @isTest
    public static void searchTestWithSelectedIdsAndCondition(){
        User us1=[SELECT Id FROM User WHERE Alias = 'AV-TF9'];
        
        Test.startTest();
        System.runAs(us1){
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= 'AV_';       
        String condition ='RecordType.DeveloperName = \'CC_Representante\' and AccountId = \''+ acc.Id+'\'';
        List<Task> taskId = [SELECT id From Task LIMIT 10];
        List<String> selectedIds = new List<String>();     
        for(Task auxId : taskId){
            selectedIds.add(auxId.id);
        }       
      	List<AV_LookupSearchResult> results = AV_LookUpFlow_Controller.search(searchTerm, selectedIds, acc.Id);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
        }
    }
    
    @isTest
    public static void searchTestWithSelectedIdsAndWithoutcondition(){
        User us1=[SELECT Id FROM User WHERE Alias = 'AV-TF9'];
        
        Test.startTest();
        System.runAs(us1){
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= 'AV_';       
        String condition ='';
        List<Task> taskId = [SELECT id From Task LIMIT 10];
        List<String> selectedIds = new List<String>();     
        for(Task auxId : taskId){
            selectedIds.add(auxId.id);
        }       
      	List<AV_LookupSearchResult> results = AV_LookUpFlow_Controller.search(searchTerm, selectedIds, acc.Id);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
        }
    }
    
	@isTest
    public static void searchTestWithoutSelectedIdsAndCondition(){
        User us1=[SELECT Id FROM User WHERE Alias = 'AV-TF9'];
        
        Test.startTest();
        System.runAs(us1){
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= 'AV_';       
        String condition ='RecordType.DeveloperName = \'AV_Otros\' and AccountId = \''+ acc.Id+'\'';
        List<String> selectedIds = new List<String>();     
     
      	List<AV_LookupSearchResult> results = AV_LookUpFlow_Controller.search(searchTerm, selectedIds, acc.Id);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
        }
    }
    
	@isTest
    public static void searchTestWithoutSelectedIdsAndWithoutcondition(){
        User us1=[SELECT Id FROM User WHERE Alias = 'AV-TF9'];
        
        Test.startTest();
        System.runAs(us1){
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= 'AV_';       
        String condition = 'RecordType.DeveloperName = \'AV_Otros\' and AccountId = \''+ acc.Id+'\'' ;
        List<String> selectedIds = new List<String>();     
     
      	List<AV_LookupSearchResult> results = AV_LookUpFlow_Controller.search(searchTerm, selectedIds, acc.Id);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
        }
    }
    
        
	@isTest
    public static void searchTestWithNullSearchTermAndCondition(){
        User us1=[SELECT Id FROM User WHERE Alias = 'AV-TF9'];
        
        Test.startTest();
        System.runAs(us1){
        User usr = [SELECT id FROM User LIMIT 1];
        Account acc = [Select Id From Account  limit 1]; 
        String searchTerm= '';       
        String condition = '';
        List<String> selectedIds = new List<String>();     
     
      	List<AV_LookupSearchResult> results = AV_LookUpFlow_Controller.search(searchTerm, selectedIds, acc.Id);
      	Test.stopTest();
        
       	System.assertNotEquals(null, results);
        }
    }
}