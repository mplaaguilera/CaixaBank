/**********************************************************************************************************************
Name:      AV_GestorReassignmentQueueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GestorReassignmentQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            Init             Sandra Gómez        05/04/2022          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_GestorReassignmentQueueable_Test {
	@TestSetup
	static void setup() {
		User usr = AV_TestHelper.createUser('','U0181273981391');
		Account acc = AV_TestHelper.createCustomerCompany();
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
		AV_TestHelper.createOpportunity(acc);
        
        Contact cnt = AV_TestHelper.createEmployeeSinInsert(acc, usr);
        insert cnt;
        Product2 prod=AV_TestHelper.createProductSinInsert(null,null,'123456');
        
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPLLAMADA_RT);
        //Create bulk insert
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < 150; i++){
        	 oppList.add(CIBE_TestHelper.createOpportunityWithProductSinInsert(acc, cnt,prod,'1234561'+i,null,null,rt));
        }
        insert oppList;
	}

	@isTest
	public static void validateOppQueueble() {
		User us=[Select Id from User where AV_ExternalId__c='U0181273981391' limit 1];
		List<Opportunity> listOpp= [Select Id, OwnerId from Opportunity limit 1];
		for(Opportunity opp: listOpp) {
			opp.OwnerId=us.Id;
		}
        AV_GestorReassignmentQueueable.doChainJob = false;
		Test.startTest();
		AV_GestorReassignmentQueueable a1 = new AV_GestorReassignmentQueueable(listOpp,null,null);
        System.enqueueJob(a1);
		Test.stopTest();
        System.assertNotEquals(a1, null);
	}
    
    @isTest
	public static void validateOppBulkQueueble() {
		User us=[Select Id from User where AV_ExternalId__c='U0181273981391' limit 1];
		List<Opportunity> listOpp= [Select Id, OwnerId from Opportunity limit 151];
        system.debug('### listOpp.size() ' + listOpp.size());
		for(Opportunity opp: listOpp) {
			opp.OwnerId=us.Id;
		}
        AV_GestorReassignmentQueueable.doChainJob = false;
		System.runAs(new User(Id = UserInfo.getUserId())){
			Test.startTest();
			AV_GestorReassignmentQueueable a1 = new AV_GestorReassignmentQueueable(listOpp,null,null);
			System.enqueueJob(a1);
			Test.stopTest();
			System.assertNotEquals(a1, null);
		}
	}
    
    @isTest
	public static void validateOppFailQueueble() {
		User us=[Select Id from User where AV_ExternalId__c='U0181273981391' limit 1];
        user us2 = AV_TestHelper.createUser(AV_AppConstants.AV_PROFILE, 'U01929239');
        
		List<Opportunity> listOpp= [Select Id, OwnerId from Opportunity limit 1];
		for(Opportunity opp: listOpp) {
			opp.OwnerId=us.Id;
            opp.name = 'otro nombre';
            opp.stageName = 'Vencido';
		}
        AV_GestorReassignmentQueueable.doChainJob = false;
        System.runAs(us2){
            Test.startTest();
			AV_GestorReassignmentQueueable a1 = new AV_GestorReassignmentQueueable(listOpp,null,null);
            System.enqueueJob(a1);
			Test.stopTest();
            System.assertNotEquals(a1, null);
        }
		
	}
    
    @isTest
	public static void validateOppEmptyQueueble() {
		System.runAs(new User(Id = UserInfo.getUserId())){
			Test.startTest();
			AV_GestorReassignmentQueueable a1 = new AV_GestorReassignmentQueueable(null,null,null);
			System.enqueueJob(a1); 
			Test.stopTest();
			System.assertNotEquals(a1, null);
		}
	}
}