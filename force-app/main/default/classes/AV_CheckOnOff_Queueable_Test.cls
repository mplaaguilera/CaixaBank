/**********************************************************************************************************************
Name:	  AV_CheckOnOff_Queueable_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_OpportunityTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY		AUTHOR				DATE			Description
   
***********************************************************************************************************************/

@isTest
public with sharing class AV_CheckOnOff_Queueable_Test {

	@TestSetup static void data_setup(){
        User user1 = AV_TestHelper.createUser(null);
      	Task tarea1 = AV_TestHelper.createTarea(null);
        Account accAux = AV_TestHelper.createCustomer();
        AV_TestHelper.createPricebook2();
  		Opportunity opp1 = AV_TestHelper.createOpportunity(accAux);		

        }
    
    @isTest
	private static void createTaskCheckOnOffTest(){
        Test.startTest();
        List<Task> listTask = [SELECT Id, AV_ExternalID__c, AV_Task__c, Status FROM Task limit 4];
        Map<String, Task> mapTask= new Map<String, Task>();
           	for(Task tk: listTask){
               	mapTask.put(tk.AV_ExternalID__c,tk);                
           	}
        List<Opportunity> listUsedOpp =new List<Opportunity>();
        Datetime dateExternalId = datetime.newInstance(2022, 01, 01);
        AV_CheckOnOff_Queueable.createTaskCheckOnOff(listTask, mapTask, listUsedOpp, dateExternalId);
        Test.stopTest();
        System.assertEquals(listTask[0].Status, 'Open', 'createTaskCheckOnOffTest');
		
        }    

    @isTest
    private static void updateListOppTest(){
        Test.startTest();
        List<Opportunity> oppList=[SELECT id, name, AV_FechaProximoRecordatorio__c,AV_IncludeInPrioritizingCustomers__c,StageName,AV_PF__r.Name FROM opportunity LIMIT 2];
        String jsonString = '[]';
        List<Opportunity> updateList = (List<Opportunity>)Json.deserialize(jsonString,List<Opportunity>.class);
        AV_CheckOnOff_Queueable.updateListOpp(jsonString);
        List<Opportunity> oppList2=[SELECT id, name, AV_FechaProximoRecordatorio__c,AV_IncludeInPrioritizingCustomers__c,StageName,AV_PF__r.Name FROM opportunity LIMIT 2];
        Test.stopTest();
        System.assertEquals(oppList2[0].AV_IncludeInPrioritizingCustomers__c, false);

        
    }
    
    
    @isTest
    private static void executeTest(){
        Test.startTest();
       	User us=[Select Id from User LIMIT 1];
        List<Opportunity> listOpp= [Select Id, OwnerId, AV_IncludeInPrioritizingCustomers__c from Opportunity];
		System.enqueueJob(new AV_CheckOnOff_Queueable(listOpp));
        Test.stopTest();
   
        System.assertEquals(listOpp[0].AV_IncludeInPrioritizingCustomers__c, false, 'executeTest');

	}
    
    @isTest
    private static void executeTestContructor2(){
        Test.startTest();
        List<Task> listTask= [Select Id, OwnerId, Status from Task];
		System.enqueueJob(new AV_CheckOnOff_Queueable(listTask));
        Test.stopTest();

        System.assertEquals(listTask[0].Status, 'Open', 'executeTestContructor2');

   
	}
    
    @isTest
    private static void executeTestContructor3(){
        Test.startTest();
        List<Task> listTaskId = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Task limit 4];
        List<Id> listDeleteTaskOpp = new List<Id>();
        	for(Task aux: listTaskId){
               	listDeleteTaskOpp.add(aux.Id);              
           	}
        List<Opportunity> listUsedOpp =[SELECT Id,Name,StageName,AV_Comentarios__c,RecordTypeId FROM Opportunity limit 4];
        List<Id> listDeleteHeaderTsk = new List<Id>();
        	for(Opportunity auxOpp: listUsedOpp){
               	listDeleteHeaderTsk.add(auxOpp.Id);              
           	}
        List<Task> listDeleteTaskAux = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Task limit 4];
        System.debug('@@@ listDeleteTaskAux size: '+listDeleteTaskAux.size());
        List<Id> listDeleteTask = new List<Id>();
        	for(Task auxTask: listDeleteTaskAux){
               	listDeleteTask.add(auxTask.Id);              
           	}
        System.enqueueJob(new AV_CheckOnOff_Queueable(listDeleteTaskOpp,listDeleteHeaderTsk,listDeleteTask));
        Test.stopTest();
   
        List<Task> taskList = [SELECT Id FROM Task];
        System.assertEquals(0, taskList.size(), 'executeTestContructor3');
   
	}
    
    @isTest
    private static void executeTestContructor4(){
        Test.startTest();
        List<Task> newTask = new List<Task>();
        List<Task> listTask = [SELECT Id, AV_ExternalID__c, AV_Task__c, Status FROM Task limit 4];
        Map<String, Task> mapTask= new Map<String, Task>();
           	for(Task tk: listTask){
               	mapTask.put(tk.AV_ExternalID__c,tk);                
           	}
        List<Opportunity> listUsedOpp =[SELECT Id,Name,StageName,AV_Comentarios__c,RecordTypeId FROM Opportunity limit 4];
        Datetime dateExternalId = datetime.newInstance(2022, 01, 01);
        
		System.enqueueJob(new AV_CheckOnOff_Queueable(newTask,mapTask,listUsedOpp,dateExternalId));

        Test.stopTest();
        System.assertEquals(listTask[0].Status, 'Open', 'executeTestContructor4');

   
	}  
}