/**********************************************************************************************************************
 Name:	  CIBE_EconGroupAccR_Batch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para borrar grupos económicos
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US429528		Mikel Lezama        06/09/2022			Init version
***********************************************************************************************************************/
@isTest
public class CIBE_EconomicGroupsAccR_Batch_Test {
    
    /**
	 * Create Data to test.
	 */
    @TestSetup
    static void setup() {
        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();
        String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();
        
        Account acc = new Account(
            Name = 'Prueba',
            RecordtypeId = rtAccount,
            CIBE_FechaCargaGE__c = Date.valueOf('2022-01-01')
        );
        insert acc;
        
        Account acc2 = new Account(
            Name = 'Prueba 2',
            RecordtypeId = rtAccount,
            CIBE_FechaCargaGE__c = Date.valueOf('2022-01-01')
        );
        insert acc2;
        
        Account acc3 = new Account(
            Name = 'Prueba',
            RecordtypeId = rtAccount,
            CIBE_FechaCargaGE__c = Date.valueOf('2022-01-02')
        );
        insert acc3;
        
        Account acc4 = new Account(
            Name = 'Prueba',
            RecordtypeId = rtAccount,
            CIBE_FechaCargaGE__c = Date.valueOf('2022-01-02')
        );
        insert acc4;
        
        FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
            Name = 'Parent',
            FinServ__InverseRole__c = 'Cliente'
        );
        insert role;
        
        FinServ__AccountAccountRelation__c accR = new FinServ__AccountAccountRelation__c(
            RecordtypeId = rtAccountRelation,
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            FinServ__Account__c = acc.id,
            FinServ__RelatedAccount__c = acc2.id,
            FinServ__Role__c = role.id
        );
        insert accR; 
        
        FinServ__AccountAccountRelation__c accR2 = new FinServ__AccountAccountRelation__c(
            RecordtypeId = rtAccountRelation,
            CIBE_FechaCargaGE__c = Date.Today(),
            FinServ__Account__c = acc3.id,
            FinServ__RelatedAccount__c = acc4.id,
            FinServ__Role__c = role.id
        );
        insert accR2;
    }

    /**
	 * Execute the Batch class (CIBE_EconomicGroupsAccR_Batch) 
	 */
    @isTest
    public static void deleteAccountRelationssTest() {
        Test.startTest();
        
        CIBE_EconomicGroupsAccR_Batch batch = new CIBE_EconomicGroupsAccR_Batch();
        Id batchId = Database.executeBatch(batch);
        
        Test.stopTest();
        List<FinServ__AccountAccountRelation__c> accRs = [SELECT id FROM FinServ__AccountAccountRelation__c];
        System.assertEquals(2, accRs.size());
    }
    
     /**
	 * Execute the Batch class (CIBE_EconomicGroupsAcc_Batch) 
	 */
    @isTest
    public static void deleteAccount2Test() {
        Test.startTest();
        
        CIBE_EconomicGroupsAccR_Batch batch = new CIBE_EconomicGroupsAccR_Batch('SELECT Id, CIBE_FechaCargaGE__c FROM FinServ__AccountAccountRelation__c WHERE RecordTypeId = :RT_ACCR and CIBE_FechaCargaGE__c != 2022-01-02');
        Id batchId = Database.executeBatch(batch);
        
        Test.stopTest();
        List<Account> accs = [SELECT id FROM Account];
        System.assertEquals(4, accs.size());
    }
    
}