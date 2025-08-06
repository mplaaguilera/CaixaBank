/**********************************************************************************************************************
Name:      CIBE_OpportunityUpdateTeam_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test class for CIBE_OpportunityUpdateTeam
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY			AUTHOR				DATE            Description
1.0         US379981			Lucía		    	04/05/2023      Init version
***********************************************************************************************************************/
@IsTest
public without sharing class CIBE_OpportunityUpdateTeam_Test {
    
    @TestSetup  
    static void setup(){
        ID rtCon = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EMPLOYEE_RT).getRecordTypeId();
        ID rtOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.OPP_INICIATIVAEMP_RT).getRecordTypeId();
        RecordType rtAcc = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        
        CIBE_TestInitialSetup.setupInitialDataCIB();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        Account acc = new Account();
        //Run As ByPass Non Setup Object
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            acc = CIBE_TestHelper.createCustomer(u);            
        }
        
        System.runAs(u){
            Opportunity opp = new Opportunity();
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            opp.AccountId = acc.Id;
            opp.Name = 'Alerta Comercial Test';
            opp.StageName = 'En gestión/insistir';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.OwnerId = u.Id;
            insert opp;
            
            
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = opp.Id;
            oppTM.UserId = UserInfo.getUserId();
            oppTM.OpportunityAccessLevel = 'Edit';
            insert oppTM;
        }
    }
    
    @isTest
    public static void getAccountTeamMemberTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        Test.StartTest();
        Opportunity opp = new Opportunity();
        opp = [SELECT Id, Name, StageName, Owner.Name  FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND RecordType.DeveloperName=: CIBE_AppConstants.OPP_INICIATIVACIB_RT AND CreatedDate = Today AND createdbyId = :usuario.Id];
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Name' AND AV_NumPerso__c = '123' AND createdbyId = :UserInfo.getUserId()];
        
        AccountTeamMember accTM = new AccountTeamMember();
        accTM.AccountId = acc.Id;
        accTM.UserId = usuario.Id;
        insert accTM;
        
        System.runAs(usuario){
            Map<Id, Contact> mapC = CIBE_OpportunityUpdateTeam.getAccountTeamMember(opp.Id);
            System.assertEquals(1, mapC.size());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateOpportunityTeamMemberTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        Test.StartTest();
        Opportunity opp = new Opportunity();
        opp = [SELECT Id, Name, StageName, Owner.Name  FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND RecordType.DeveloperName=: CIBE_AppConstants.OPP_INICIATIVACIB_RT AND CreatedDate = Today AND createdbyId = :usuario.Id];
        
        System.runAs(usuario){
            
            List<OpportunityTeamMember> oppTM = new List<OpportunityTeamMember>();
            OpportunityTeamMember teamMember = new OpportunityTeamMember();
            oppTM.add(teamMember);
            
            CIBE_OpportunityUpdateTeam.updateOpportunityTeamMember(opp.Id, oppTM);
            System.assertEquals(1, oppTM.size()); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getOpportunityTeamMembersTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        Test.StartTest();
        Opportunity opp = new Opportunity();
        opp = [SELECT Id, Name, StageName, Owner.Name  FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND RecordType.DeveloperName=: CIBE_AppConstants.OPP_INICIATIVACIB_RT AND CreatedDate = Today AND createdbyId  = :usuario.Id];
        
        OpportunityTeamMember oppTM = new OpportunityTeamMember();
        oppTM.OpportunityId = opp.Id;
        oppTM.UserId = usuario.Id;
        oppTM.OpportunityAccessLevel = 'Edit';
        insert oppTM;
        List<OpportunityTeamMember> oppTMs = new List<OpportunityTeamMember>();
        oppTMs.add(oppTM);
        
        System.runAs(usuario){
            
            CIBE_OpportunityUpdateTeam.getOpportunityTeamMembers(opp.Id);
            System.assertEquals(1, oppTMs.size());
            Test.stopTest();
            
        }
    }
    
    @isTest
    public static void deleteTeamMemberTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        Test.StartTest();
        Opportunity opp = new Opportunity();
        opp = [SELECT Id, Name, StageName, Owner.Name  FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND RecordType.DeveloperName=: CIBE_AppConstants.OPP_INICIATIVACIB_RT AND CreatedDate = Today AND createdbyId = :usuario.Id];
        
        List<OpportunityTeamMember> listDelete = new List<OpportunityTeamMember>();
        
        System.runAs(usuario){
            OpportunityTeamMember opTM = [SELECT Id, UserId, OpportunityAccessLevel  FROM OpportunityTeamMember WHERE OpportunityId = :opp.Id LIMIT 1];
            CIBE_OpportunityUpdateTeam.deleteTeamMember(opTM.Id);
            listDelete = [SELECT Id, UserId FROM OpportunityTeamMember WHERE Id =: opTM.Id];
            System.assertEquals(0, listDelete.size());  
            Test.stopTest();          
        }
    }
    
    @isTest
    public static void showAddMemberButtonTestOwnerOpp(){
        
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        Test.StartTest();
        Boolean result = false;
        System.runAs(usuario){
            
            Opportunity opp = [SELECT Id, Name, StageName  FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND RecordType.DeveloperName=: CIBE_AppConstants.OPP_INICIATIVACIB_RT AND CreatedDate = Today AND createdbyId = :usuario.Id];
            result = CIBE_OpportunityUpdateTeam.showAddMemberButton(opp.Id);
            System.assertEquals(true, result);
            Test.stopTest();
            
        }
        
    }
    
    @isTest
    public static void updateTeamMemberTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        Test.StartTest();
        Opportunity opp = new Opportunity();
        opp = [SELECT Id, Name, StageName, Owner.Name  FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND RecordType.DeveloperName=: CIBE_AppConstants.OPP_INICIATIVACIB_RT AND CreatedDate = Today AND createdbyId = :usuario.Id];
        
        
        
        System.runAs(usuario){
            String accesLevel = 'Read';
            
            OpportunityTeamMember oppTM = [SELECT Id, UserId, OpportunityAccessLevel  FROM OpportunityTeamMember WHERE OpportunityId = :opp.Id LIMIT 1];
            oppTM.OpportunityAccessLevel = 'Read';
            update oppTM;
            CIBE_OpportunityUpdateTeam.updateTeamMember(oppTM.Id, oppTM.OpportunityAccessLevel);
            
            System.assertEquals(accesLevel, oppTM.OpportunityAccessLevel);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validationCloseDateTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        Boolean result = true;
        Opportunity opp = new Opportunity();
        opp = [SELECT Id, Name, StageName, Owner.Name  FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND RecordType.DeveloperName=: CIBE_AppConstants.OPP_INICIATIVACIB_RT AND CreatedDate = Today AND createdbyId = :usuario.Id];
        
        System.runAs(usuario){
            String accesLevel = 'Read';
            
            Test.StartTest();
            OpportunityTeamMember oppTM = [SELECT Id, UserId, OpportunityAccessLevel  FROM OpportunityTeamMember WHERE OpportunityId = :opp.Id LIMIT 1];
            
            result = CIBE_OpportunityUpdateTeam.validationCloseDate(opp.Id);
            
            System.assertEquals(result, false);
            Test.stopTest();
        }
    }
}