/********************************************************************************************************************
Name: CIBE_AccTMAccConRelBatch_Test
Copyright © 2022 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito:
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			    	        Alex Perez			7/6/2023		Init version
    1.1         IT              Lucia Muñoz         11/07/2023       Quitar las refencias a los campos CIBE_Negocios__c, CIBE_RedesSegmentos__c, CIBE_CentrosCarteras__c y CIBE_SectoresPaises__c

************************************************************************************************************************/


@isTest
public with sharing class CIBE_AccTMAccConRelBatch_Test {
    @TestSetup
    public static void testSetup() {
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        list<account> acclist = new list<account>();
        Account centroCaixa = new Account();
        centroCaixa.Name = 'oficina1';
        centroCaixa.CC_Numero_Oficina_Empresa__c = '123456789';
        centroCaixa.CC_Numero_Oficina__c = '00615';
        centroCaixa.RecordTypeId = rt.Id;
        insert centroCaixa;

        Account centroCaixa2 = new Account();
        centroCaixa2.Name = '00616 STORE DOS DE MAIG-ROSSELLO';
        centroCaixa2.CC_Numero_Oficina_Empresa__c = '987654321';
        centroCaixa2.CC_Numero_Oficina__c = '00616';
        centroCaixa2.RecordTypeId = rt.Id;
        insert centroCaixa2;
        
        user usr = CIBE_TestHelper.createUser('CIBE_Gestor', 'U011');
        user cIBUser;
         System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('API Only', 'AV_MisClientes', '1234', new List<String>{'CIBE_OperativaCIB', 'CIBE_OperativaEMP', 'CIBE_Integracion'});
        }
        System.runAs(cIBUser) {
            contact con = CIBE_TestHelper.createEmployee(centroCaixa2, usr);
            account acc1 = new Account(Name = 'Test Account 1',
             AV_OficinaPrincipal__c = centroCaixa.id,
             AV_NumPerso__c = '123',
             AV_Negocio__c = 'EMP',
             RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('CC_Cliente').getRecordTypeId());
             account acc2 = new Account(Name = 'Test Account 1',
             AV_OficinaPrincipal__c = centroCaixa.id,
             AV_NumPerso__c = '456',
             AV_Negocio__c = 'CIB',
             RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('CC_Cliente').getRecordTypeId());
             list<account> accList2 = new list<account>();
             accList2.add(acc1);
             accList2.add(acc2);
             insert accList2;
        }
    }

    @isTest
    static void testInsert() {
        account acc = [SELECT ID FROM ACCOUNT WHERE NAME = 'oficina1' limit 1];
        contact con = [select id from contact where av_usuarioAsociado__r.AV_ExternalID__c = 'U011' limit 1];
        user apiUser;
        user empleado;
        for(user us : [SELECT AV_ExternalID__c, id FROM user where AV_ExternalID__c IN ('1234', 'U011')]){
            if(us.AV_ExternalID__c == '1234'){
                apiUser = us;
            }
            if(us.AV_ExternalID__c =='U011'){
                empleado = us;
            }
        }
        AccountContactRelation acr1 = new AccountContactRelation(AccountId = acc.Id, ContactId = con.Id, FinServ__SourceSystemId__c = 'CIBE_1234');
        insert acr1;
        list<id> listacr = new list<id>{acr1.id};
        Test.startTest();
        system.runAs(apiUser){
            CIBE_AccTMAccConRel_Batch btch = new CIBE_AccTMAccConRel_Batch(listacr);
            Database.executeBatch(btch);
        }
        test.stopTest();
        AccountTeamMember atmlist = [SELECT Id, AccountId, UserId from AccountTeamMember];
        account acc2 = [SELECT ID FROM ACCOUNT WHERE Name = 'Test Account 1' LIMIT 1];
        system.assert(atmlist.AccountId == acc2.id && atmlist.userId == empleado.id, 'No se ha creado el registro en accountTeamMember como debería');
        //system.debug([SELECT ID, params__c FROM CBK_Framework_Batch__c where Class_Name__c = 'CIBE_AccTMAccConRel_Batch' LIMIT 1].params__c);	
        //System.assertNotEquals(0, [SELECT ID FROM CBK_Framework_Batch__c].size());	  
    }

    @isTest
    static void testUpdate() {
        account acc = [SELECT ID, owner.name FROM ACCOUNT WHERE NAME = 'oficina1' limit 1];
        account acc2 = [SELECT ID FROM ACCOUNT WHERE av_numperso__c = '123' limit 1];
        contact con = [select id from contact where av_usuarioAsociado__r.AV_ExternalID__c = 'U011' limit 1];
        user us = [select id from user WHERE AV_ExternalID__c = '1234' limit 1];
        user us2 = [select id from user WHERE AV_ExternalID__c = 'U011' limit 1];
        AccountContactRelation acr1;
        system.runAs(us){
            acr1 = new AccountContactRelation(AccountId = acc.Id, ContactId = con.Id, FinServ__SourceSystemId__c = 'CIBE_1234');
            insert acr1;
            accountTeamMember atm = new accountTeamMember(AccountId = acc2.Id, UserId = us2.id, cibe_isAutomatic__c = true);
            insert atm;
            acr1.isActive = false;
            update acr1;
        }
        list<id> listacr = new list<id>{acr1.id};

        Test.startTest();
        system.runAs(us){
            CIBE_AccTMAccConRel_Batch btch = new CIBE_AccTMAccConRel_Batch(listacr);
            Database.executeBatch(btch);
        }  
        test.stopTest();
        system.assertEquals([SELECT Id, AccountId, UserId from AccountTeamMember].size(),0, 'Se debería haber borrado el registro en la accountTeamMember');
        //System.assertNotEquals(0, [SELECT ID FROM CBK_Framework_Batch__c].size());
    }
}