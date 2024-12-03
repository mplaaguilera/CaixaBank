/**********************************************************************************************************************
 Name:	  CIBE_AccountTeamMemberTriggerHelper_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_AccountTeamMemberTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0			US616750		    Lucia Muñoz 	    27/07/2023		    setOpportunityUsersTest

***********************************************************************************************************************/

@IsTest
public class CIBE_AccountTeamMemberTriggerHelper_Test {


    @TestSetup
    static void setup(){
        CIBE_TestInitialSetup.setupInitialDataCIB();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(new User(Id = UserInfo.getUserId())){
            User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
            Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001'];
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = 'clase de test',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '05667',
                AV_Negocio__c = 'CIB',
                AV_EAPGestor__c = c.Id,
                OwnerId = u.Id
            );
            insert acc;

        }
    
    }

    @isTest
    static void setAccountUsersTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        User usrTest = [SELECT Id  FROM User WHERE Alias = 'tsAlias' AND Profile.Name = 'CIBE_Gestor'];
         List<Account> acc = [SELECT Id, OwnerId, name FROM Account WHERE Name = 'clase de test' AND AV_NumPerso__c = '05667'  AND AV_Negocio__c = 'CIB' AND OwnerId = :usuario.Id];

        System.runAs(usuario){
            Test.startTest();
           
            if(!acc.isEmpty()){
                List<AccountTeamMember> accTM = new List<AccountTeamMember>();
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = acc[0].Id;
                atm.UserId = usrTest.Id;
                atm.TeamMemberRole = 'Participante';
                atm.AccountAccessLevel = 'Read';
                accTM.add(atm);
                insert accTM;

                Account accList = [SELECT Id, CIBE_AccountTeam__c, CIBE_AccountTeamMember__c, OwnerId, AV_Negocio__c  FROM Account WHERE Id = :acc[0].Id];
                System.assert(String.isNotBlank(accList.CIBE_AccountTeam__c));
                System.assertEquals(true, accList.CIBE_AccountTeamMember__c);
                System.assert(accList.CIBE_AccountTeam__c.contains(usuario.Id));
         
            }

                List<AccountTeamMember> deleteATM = [SELECT Id FROM AccountTeamMember WHERE UserId = :usrTest.Id];
                delete deleteATM;
                List<Account> accList2 = [SELECT Id, CIBE_AccountTeam__c, CIBE_AccountTeamMember__c, OwnerId, AV_Negocio__c  FROM Account WHERE Id = :acc[0].Id];
                System.assert(!accList2[0].CIBE_AccountTeam__c.contains(usrTest.Id));
         
            
            Test.stopTest();
        
    }
    }
}