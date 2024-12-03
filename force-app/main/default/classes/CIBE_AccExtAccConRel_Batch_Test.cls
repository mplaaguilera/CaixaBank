/********************************************************************************************************************
Name: CIBE_AccExtAccConRel_Batch_Test
Copyright © 2024 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito:
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US493757	    Borja Lavesiera	    21/01/24		Init version

************************************************************************************************************************/
@isTest
public with sharing class CIBE_AccExtAccConRel_Batch_Test {
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
        centroCaixa2.Name = 'oficina2';
        centroCaixa2.CC_Numero_Oficina_Empresa__c = '987654321';
        centroCaixa2.CC_Numero_Oficina__c = '00616';
        centroCaixa2.RecordTypeId = rt.Id;
        insert centroCaixa2;
        user usr = CIBE_TestHelper.createUser('CIBE_Gestor', 'U011');
        List<User> sysAdminUser = [SELECT Id FROM User WHERE Profile.name LIKE 'System Administrator' AND IsActive=true];
        if (!sysAdminUser.isEmpty()) {
            System.runAs(sysAdminUser[0]) {
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
    }
    @isTest
    static void testUpdate() {
        account acc = [SELECT ID, owner.name FROM ACCOUNT WHERE NAME = 'oficina1' limit 1];
        contact con = [select id from contact where av_usuarioAsociado__r.AV_ExternalID__c = 'U011' limit 1];
        user us = [select id from user WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true LIMIT 1];
        AccountContactRelation acr1;
        acr1 = new AccountContactRelation(AccountId = acc.Id, ContactId = con.Id, FinServ__SourceSystemId__c = '');
        insert acr1;
        list<id> listacr = new list<id>{acr1.id};
        Test.startTest();
        system.runAs(us){
            CIBE_AccExtAccConRel_Batch btch = new CIBE_AccExtAccConRel_Batch(listacr);
            Database.executeBatch(btch);
        }  
        test.stopTest();
        system.assertEquals([SELECT FinServ__SourceSystemId__c, isDirect from AccountContactRelation WHERE FinServ__SourceSystemId__c != null AND IsDirect = false].size(),1, 'Se debería haber modificado el registro con externalId y Indirect to false');
    }
}