/**********************************************************************************************************************
Name:      AV_Teams_Integration
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con Teams
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY 				AUTHOR              DATE                Description
	1.0            FE144643    		        Luis Fernández         15/01/2024          Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_ReTryScoringTest {
    @TestSetup
    static void setup(){
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        Account accTest = AV_TestHelper.createConfidencialCustomerSinInsert();
        accTest.OwnerId = userGestor.Id;
		Set<String> setRTs = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.EMPLOYEE_RT,'AV_ProductoFichaCliente'};
        
        Map<String,RecordType> rtMap = AV_AppUtilities.getRecordTypeInMap(setRTs);
        
        System.runAs(userGcf){
        
            insert accTest;
            Account cenTest = AV_TestHelper.createCaixaCenterSinInsert();
            Contact conTest = AV_TestHelper.createEmployeeSinInsert2(cenTest, userGestor, rtMap.get('Empleado'));
            insert conTest;
			Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115');
            insert prodPF4;
			Opportunity opp = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest, conTest, prodPF4, rtMap.get('Iniciativa'), '00000002', userGestor.Id);
            insert opp;
            
        }
        
        System.runAs(userGestor){
            List<AV_Score__c> scoreConf = new List<AV_Score__c>();
            Set<String> retailRts = new Set<String>{ 
                AV_AppConstants.OPPINICIATIVA_RT,
                AV_AppConstants.OPPALERTACOM_RT,
                AV_AppConstants.OPPPROPUESTA_RT,
                AV_AppConstants.OPPSUGERENCIA_RT,
                AV_AppConstants.OPPLLAMADA_RT
            };
            List<RecordType> scoreRts = [SELECT ID,DeveloperName FROM RecordType WHERE DeveloperName IN ('AV_ScoringOpportunity','AV_SalesExpectancy')];
            Map<String,String> rtsToId = new Map<String,String>();
            for(RecordType scrRT : scoreRts){
                rtsToId.put(scrRt.DeveloperName,scrRt.Id);
            }
            for(String rt : retailRts){
                scoreConf.add(new AV_Score__c(AV_Active__c = true,AV_RecordType__c = rt,AV_Object__c = AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_Score__c = 10,RecordTypeId = rtsToId.get('AV_ScoringOpportunity')));
            }
            List<Schema.PicklistEntry> picklistValues = Opportunity.AV_Potencial__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                scoreConf.add(new AV_Score__c(AV_Potencial__c = picklistEntry.getValue(), AV_Active__c = true,AV_Score__c = 10,RecordTypeId = rtsToId.get('AV_SalesExpectancy')));
            }
            insert scoreConf;
        }
    }
    
    @isTest
    public static void queueableTestErrorAccount(){
        User userGestor = [SELECT ID FROM USER WHERE AV_ExternalId__c = 'U01545454'];
        System.runAs(userGestor){
            List<Opportunity> opposToUpdt = [SELECT Id,AccountId FROM Opportunity WHERE AV_ExternalID__c = '00000002'];
            insert (new CBK_Log__c(Transaction_ID__c = 'AV_Scoring',retries__c = 4,subject__c = 'TestLog',object__c = AV_AppConstants.OBJECT_NAME_ACCOUNT));
            Test.startTest();
            String fakeIdAccount = '001000000000000000';
            try{
                insert new Account( RecordTypeId = '001000000000000000');
            }catch(Exception err ){

                System.enqueueJob(new AV_ReTryScoringQueueable(new Set<String>{fakeIdAccount},err,3,'AI'),1);
            }
            Test.stopTest();
            Database.executeBatch(new AV_ReTryScoringBatch(),200);
            List<CBK_Log__c> result = [SELECT ID FROM CBK_Log__c WHERE Transaction_ID__c = 'AV_Scoring']; 
            System.assert(!result.isEmpty());
        }
        
    }
}