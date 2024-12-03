/**********************************************************************************************************************
 Name:	  CIBE_OpprtTeamMemberTriggerHelper_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_OpprtTeamMemberTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0			Data access		    Luis Martínez	    22/12/2022		    Init version
    1.1			US616750		    Lucia Muñoz 	    27/07/2023		    setOpportunityUsersTest

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_OpprtTeamMemberTriggerHelper_Test {

    @TestSetup
    static void setup() {
        CIBE_TestInitialSetup.setupInitialDataCIB();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(new User(Id = UserInfo.getUserId())){
            User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
            Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001'];
            Account accTest = CIBE_TestHelper.createCustomerWithEAPGestor(c);
            
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = accTest.Id;
            opp.Name = 'Test Alerta Comercial';
            opp.StageName = 'En gestión/insistir';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.OwnerId = u.Id;
            insert opp;
        }
    }

    @isTest
    static void setOpportunityUsersTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario){
            User usrTest = [SELECT Id  FROM User WHERE Alias = 'tsAlias' AND Profile.Name = 'CIBE_Gestor'];
            List<OpportunityTeamMember> opporTM = new List<OpportunityTeamMember>();

            List<Opportunity> opps = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Name = 'Test Alerta Comercial' AND OwnerId = :usuario.Id];
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.OpportunityId = opps[0].Id;
            otm.UserId = usrTest.Id;
            otm.TeamMemberRole = 'Participante';
            otm.OpportunityAccessLevel = 'Read';
            opporTM.add(otm);

            Test.startTest();
            if(!opps.isEmpty()) {
                insert opporTM;
                CIBE_OpprtTeamMemberTriggerHelper.createNotificationNewUser(opporTM);
                System.assert([SELECT Id, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opps.get(0).Id AND UserId != :usrTest.Id].isEmpty());

                List<Opportunity> oppList = [SELECT Id, CIBE_OpportunityTeam__c, CIBE_OpportunityTeamMember__c, OwnerId  FROM Opportunity WHERE Id = :opps[0].Id];
                System.assert(oppList[0].CIBE_OpportunityTeam__c != null);
                System.assertEquals(true, oppList[0].CIBE_OpportunityTeamMember__c);
                System.assert(oppList[0].CIBE_OpportunityTeam__c.contains(usuario.Id));

                List<OpportunityTeamMember> deleteOTM = [SELECT Id FROM OpportunityTeamMember WHERE UserId = :usrTest.Id];
                delete deleteOTM;
                List<Opportunity> oppList2 = [SELECT Id, CIBE_OpportunityTeam__c, CIBE_OpportunityTeamMember__c, OwnerId  FROM Opportunity WHERE Id = :opps[0].Id];
                System.assert(!oppList2[0].CIBE_OpportunityTeam__c.contains(usrTest.Id));


            }
            Test.stopTest();
        }
    }
}