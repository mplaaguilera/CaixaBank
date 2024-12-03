/**********************************************************************************************************************
 Name:	CIBE_AccConRelExtTriggerHelper_test
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: test de CIBE_AccConRelExtTriggerHelper
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			US493757	    Borja Lavesiera   	  16/01/2024	    Init version
***********************************************************************************************************************/
@isTest
public class CIBE_AccConRelExtTriggerHelper_test {
    @TestSetup
    public static void testSetup() {
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account centroCaixa = new Account();
        centroCaixa.Name = 'oficina1';
        centroCaixa.CC_Numero_Oficina_Empresa__c = '123456789';
        centroCaixa.CC_Numero_Oficina__c = '00615';
        centroCaixa.RecordTypeId = rt.Id;
        centroCaixa.CIBE_Negocios__c = '001';
        centroCaixa.CIBE_RedesSegmentos__c = '002';
        centroCaixa.CIBE_CentrosCarteras__c = '003';
        centroCaixa.CIBE_SectoresPaises__c = '004';
        insert centroCaixa;

        Account centroCaixa2 = new Account();
        centroCaixa2.Name = 'oficina2';
        centroCaixa2.CC_Numero_Oficina_Empresa__c = '987654321';
        centroCaixa2.CC_Numero_Oficina__c = '00616';
        centroCaixa2.RecordTypeId = rt.Id;
        centroCaixa2.CIBE_Negocios__c = '001';
        centroCaixa2.CIBE_RedesSegmentos__c = '002';
        centroCaixa2.CIBE_CentrosCarteras__c = '003';
        centroCaixa2.CIBE_SectoresPaises__c = '004';
        insert centroCaixa2;
        
        user usr = CIBE_TestHelper.createUser('CIBE_Gestor', 'U011');
        user cIBUser;
        List<User> sysAdminUser = [SELECT Id FROM User WHERE Profile.name LIKE 'System Administrator' AND IsActive=true LIMIT 1];
        if (!sysAdminUser.isEmpty()) {
            System.runAs(sysAdminUser[0]) {
            cIBUser = CIBE_TestHelper.loginUser('API Only', 'AV_MisClientes', '1234', new List<String>{'CIBE_OperativaCIB', 'CIBE_OperativaEMP', 'CIBE_Integracion'});
            }
        }       
    }
    @isTest
    static void testUpdateAccConRelation() {
        account acc = [SELECT ID FROM ACCOUNT WHERE NAME = 'oficina1' limit 1];
        account acc2 = [SELECT ID FROM ACCOUNT WHERE NAME = 'oficina2' limit 1];
        user us = [select id from user WHERE AV_ExternalID__c = '1234' limit 1];
        user userCib = [select id from user WHERE AV_ExternalID__c = 'U011' limit 1];
        AccountContactRelation acr1;
        system.runAs(us){
            contact con = CIBE_TestHelper.createEmployee(acc2, userCib);
            acr1 = new AccountContactRelation(AccountId = acc.Id, ContactId = con.Id, FinServ__SourceSystemId__c = 'CIBE_1234');
            insert acr1;
        Test.startTest();
        system.runAs(us){
            con.AccountId = acc.Id;
            update con;
        }  
        test.stopTest();
        System.assertNotEquals(0, [SELECT ID FROM CBK_Framework_Batch__c].size());
		}
	}

}