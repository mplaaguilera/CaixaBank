/********************************************************************************************************************
Name: CIBE_AccountTriggerHelperWS_test
Copyright © 2022 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: clase test de CIBE_AccountTriggerHelperWS
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			    	        									Init version
    1.1         US493757        Alex Perez        28/03/2023      	Añadiendo al recálculo el cambio de oficina principal
    1.2         US632725        Alex Perez        27/06/2023        Filtrar negocio CIB
    1.3         IT              Lucia Muñoz       11/07/2023        Quitar las refencias a los campos CIBE_Negocios__c, CIBE_RedesSegmentos__c, CIBE_CentrosCarteras__c y CIBE_SectoresPaises__c

************************************************************************************************************************/
@IsTest
public with sharing class CIBE_AccountTriggerHelperWS_test {
    
    @TestSetup
    public static void testSetup() {
        Account center = CIBE_TestHelper.createCaixaCenter();

        User usr = CIBE_TestHelper.createUser('CIBE_Gestor', 'U011');
        CIBE_TestHelper.createEmployee(center, usr);

        User usr2 = CIBE_TestHelper.createUser('CIBE_Gestor', 'U012');
        CIBE_TestHelper.createEmployee(center, usr2);
        user cIBUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('API Only', 'AV_MisClientes', '1234', new List<String>{'CIBE_OperativaCIB', 'CIBE_OperativaEMP', 'CIBE_Integracion'});
        }

        System.runAs(cIBUser) {
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
            Account centroCaixa = new Account();
            centroCaixa.Name = '00616 STORE DOS DE MAIG-ROSSELLO';
            centroCaixa.CC_Numero_Oficina_Empresa__c = '987654321';
            centroCaixa.CC_Numero_Oficina__c = '00616';
            centroCaixa.RecordTypeId = rt.Id;
            insert centroCaixa;
            contact con = [SELECT ID, AV_UsuarioAsociado__c FROM CONTACT WHERE AV_UsuarioAsociado__r.AV_ExternalId__c = 'U011' LIMIT 1];
            AccountContactRelation acr1 = new AccountContactRelation(AccountId = centroCaixa.Id, ContactId = con.Id, FinServ__SourceSystemId__c = 'CIBE_1234');
            insert acr1;
            account acc1 = new Account(Name = 'Test Account 1',
            AV_NumPerso__c = 'CIBE123',
            AV_Negocio__c = 'EMP',
            RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('CC_Cliente').getRecordTypeId());
            account acc2 = new Account(Name = 'Test Account 2',
            AV_NumPerso__c = 'CIBE456',
            AV_Negocio__c = 'CIB',
            RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('CC_Cliente').getRecordTypeId());
            list<account> listacc = new list<account>{acc1, acc2};
            insert listacc;
            
        }
        

    }

    @IsTest
    public static void queryTeamMembersTest() {
        User usr = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U011'];
        User usr2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U012'];
        User usr3 =[SELECT NAME, id FROM user where AV_ExternalID__c = '1234'];
        Account client = CIBE_TestHelper.createCustomer(usr);

        insert new List<AccountTeamMember>{
            new AccountTeamMember(
                AccountId = client.Id,
                UserId = usr.Id
            ),
            new AccountTeamMember(
                AccountId = client.Id,
                UserId = usr2.Id
            )
        };

        Test.startTest();
        System.runAs(usr3){
            client.OwnerId = usr2.Id;
            update client;
        }

        System.assert(!CIBE_AccountTriggerHelperWS.teamMembersPerClient.isEmpty());
        Test.stopTest();
    }

    @IsTest
    public static void commitTeamMembersTest() {
        User usr = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U011'];
        User usr2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U012'];
        User usr3 =[SELECT NAME, id FROM user where AV_ExternalID__c = '1234'];
        Account client = CIBE_TestHelper.createCustomer(usr);

        insert new List<AccountTeamMember>{
            new AccountTeamMember(
                AccountId = client.Id,
                UserId = usr.Id
            ),
            new AccountTeamMember(
                AccountId = client.Id,
                UserId = usr2.Id
            )
        };

        Test.startTest();
        client.OwnerId = usr2.Id;
        System.runAs(usr3){
            update client;
        }

        client = [SELECT Id, OwnerId FROM Account WHERE Id = :client.Id LIMIT 1];
        List<AccountTeamMember> teamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId = :client.Id];

        System.assertEquals(client.OwnerId, usr2.Id);
        System.assert(!teamMembers.isEmpty());
        Test.stopTest();
    }

    @IsTest
    public static void changeCenter() {
        User usr =[SELECT NAME, id FROM user where AV_ExternalID__c = '1234'];

        System.runAs(usr){
           
            account centroCaixa = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00616' LIMIT 1];
            list<account> listacc = [SELECT Id, AV_OficinaPrincipal__c, av_negocio__c FROM ACCOUNT WHERE AV_NumPerso__c LIKE 'CIBE%'];
            Account acc1;
            for(Account acc : listacc){
                acc.AV_OficinaPrincipal__c = centroCaixa.Id;
                if(acc.av_negocio__c == 'EMP'){
                    acc1 = acc;
                }
            }
            contact con = [SELECT ID, AV_UsuarioAsociado__c FROM CONTACT WHERE AV_UsuarioAsociado__r.AV_ExternalId__c = 'U011' LIMIT 1];
            
            Test.startTest();
            update listacc;
            Test.stopTest();
        
            AccountTeamMember atmlist = [SELECT Id, AccountId, UserId from AccountTeamMember];
            system.assert(atmlist.AccountId == acc1.id && atmlist.userId == con.AV_UsuarioAsociado__c, 'No se ha creado el registro en accountTeamMember como debería');
        }
    }

    @IsTest
    public static void mantainCenter() {
        User usr =[SELECT NAME, id FROM user where AV_ExternalID__c = '1234'];

        System.runAs(usr){
          
            account centroCaixa = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00616' LIMIT 1];
            list<account> listacc = [SELECT Id, AV_OficinaPrincipal__c, av_negocio__c FROM ACCOUNT WHERE AV_NumPerso__c LIKE 'CIBE%'];
            Account acc1;
            for(Account acc : listacc){
                acc.AV_OficinaPrincipal__c = centroCaixa.Id;
                if(acc.av_negocio__c == 'EMP'){
                    acc1 = acc;
                }
            }
            contact con = [SELECT ID, AV_UsuarioAsociado__c FROM CONTACT WHERE AV_UsuarioAsociado__r.AV_ExternalId__c = 'U011' LIMIT 1];
            
            //tiene que evitar eliminar
            AccountTeamMember accTM = new AccountTeamMember();
            accTM.UserId = con.AV_UsuarioAsociado__c;
            accTM.accountId = acc1.id;
            accTM.AccountAccessLevel = 'Read';
            accTM.OpportunityAccessLevel = 'Read';
            accTM.CaseAccessLevel = 'Read';
            accTM.ContactAccessLevel = 'Read';
            accTM.AV_Tipo__c = 'MC';
            accTM.CIBE_isAutomatic__c = false;
            insert accTM;

            for(Account acc : listacc){
                acc.AV_OficinaPrincipal__c = null;
            }

            Test.startTest();
            update listacc;
            Test.stopTest();

            system.assertEquals([SELECT Id, AccountId, UserId from AccountTeamMember].size(),1, 'Debe mantener el registro porque no es automático');
        }
    }

    @IsTest
    public static void eliminateCenter() {
        User usr =[SELECT NAME, id FROM user where AV_ExternalID__c = '1234'];

        System.runAs(usr){
           
            account centroCaixa = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00616' LIMIT 1];
            list<account> listacc = [SELECT Id, AV_OficinaPrincipal__c, av_negocio__c FROM ACCOUNT WHERE AV_NumPerso__c LIKE 'CIBE%'];
            Account acc1;
            for(Account acc : listacc){
                acc.AV_OficinaPrincipal__c = centroCaixa.Id;
                if(acc.av_negocio__c == 'EMP'){
                    acc1 = acc;
                }
            }
            system.debug('@@@listacc. '+listacc);
            update listacc;
            contact con = [SELECT ID, AV_UsuarioAsociado__c FROM CONTACT WHERE AV_UsuarioAsociado__r.AV_ExternalId__c = 'U011' LIMIT 1];
            
            //tiene que evitar eliminar
            AccountTeamMember accTM = new AccountTeamMember();
            accTM.UserId = con.AV_UsuarioAsociado__c;
            accTM.accountId = acc1.id;
            accTM.AccountAccessLevel = 'Read';
            accTM.OpportunityAccessLevel = 'None';
            accTM.CaseAccessLevel = 'Read';
            accTM.ContactAccessLevel = 'Read';
            accTM.AV_Tipo__c = 'MC';
            accTM.CIBE_isAutomatic__c = true;
            insert accTM;
            for(Account acc : listacc){
                acc.AV_OficinaPrincipal__c = null;
            }

            Test.startTest();
            update listacc;
            Test.stopTest();

            system.assertEquals([SELECT Id, AccountId, UserId from AccountTeamMember].size(),0, 'Debería haber borrado el registro de la AccountTeamMember');
        }
    }

}