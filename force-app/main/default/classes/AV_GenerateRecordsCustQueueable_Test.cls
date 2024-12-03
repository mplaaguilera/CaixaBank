/**********************************************************************************************************************
Name: AV_GenerateRecordsCustQueueable_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GenerateRecordsQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            US466765         Patricia Solano     07/12/2022          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_GenerateRecordsCustQueueable_Test {
    @TestSetup
    static void setup(){

        AV_TestHelper.activateLogger();
        Account centroCaixa = AV_TestHelper.createCaixaCenter();
        Account accTest = AV_TestHelper.createCustomer();
		User user = AV_TestHelper.createUser(null);
		Contact employee = AV_TestHelper.createEmployee(centroCaixa, user);
        Account client = AV_TestHelper.createCustomerWithNumperson('000000001');
        AV_TestHelper.createPricebook2();
        Opportunity opp1 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '99999', AV_TestHelper.createProduct2(null,'9999'));
        Opportunity opp2 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '88888', AV_TestHelper.createProduct2(null,'99999'));

        insert new List<Opportunity>{opp1,opp2};
    }

    @isTest
    public static void generateRecordsCusActOppQueueableTaskTest() {

        Test.startTest();
        User user = [SELECT ID FROM USER WHERE ID IN (SELECT AV_UsuarioAsociado__c FROM Contact) LIMIT 1];
        String externalId = 'Task-#681735';
        Account client = [SELECT ID FROM ACCOUNT WHERE AV_Numperso__c = '000000001' LIMIT 1];
        List<Task> task =  new List<Task>{AV_TestHelper.createTareaExternalIdWithCustomer(user, externalId, client)};
        Set<String> taskId = new Set<String>{task[0].Id};
        Set<String> oppStageName = new Set<String> {	
            AV_AppConstants.OPP_STATUS_ENGESTION, 
            AV_AppConstants.OPP_STATUS_POTENCIAL,
            AV_AppConstants.OPP_STATUS_ENESPERA
        };
        Id taskAccoundID = [SELECT WhatId FROM TASK LIMIT 1].WhatId;
        Map<Id,Task> taskMap = new Map<Id,Task>{taskAccoundID=> task[0]};
        Set<Id> accIds = taskMap.keySet();
        List<Opportunity> opportunitiesListAux =  [SELECT Id, AccountId,RecordType.DeveloperName,StageName FROM Opportunity ];
        List<Opportunity> opportunitiesList =  [SELECT Id, AccountId FROM Opportunity WHERE AccountId in :accIds AND RecordType.DeveloperName = 'AV_Iniciativa' AND StageName IN :oppStageName ];
        Map<Id,List<Opportunity>> oppMap = new Map<Id,List<Opportunity>>();
        for(Opportunity opp: opportunitiesList){
            if(oppMap.keySet().contains(opp.AccountId)){
                oppMap.get(opp.AccountId).add(opp);
            }else{
                oppMap.put(opp.AccountId, new List<Opportunity>{opp});
            }
        }

        List<AV_CustomActivityOpportunity__c> customAct = AV_GenerateRecords.insertTaskOpportunity(taskId.size(), oppMap, taskMap, taskMap.keySet());
        System.enqueueJob(new AV_GenerateRecordsCusActOppQueueable(customAct));
        Test.stopTest();
        List<AV_CustomActivityOpportunity__c> retrieveResults = [SELECT ID FROM Av_customActivityOpportunity__c];
        System.assert(!retrieveResults.isEmpty());
    }
    
    @isTest 
    public static void testFinishLine(){
        Test.startTest();
        System.enqueueJob(new AV_GenerateRecordsCusActOppQueueable(new List<AV_CustomActivityOpportunity__c>()));
        Test.stopTest();
        System.assert(true);
    }
}