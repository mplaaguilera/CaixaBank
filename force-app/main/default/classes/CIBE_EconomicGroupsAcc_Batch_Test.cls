/**********************************************************************************************************************
 Name:	  CIBE_EconomicGroupsAcc_Batch_Test
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
public class CIBE_EconomicGroupsAcc_Batch_Test {
    
    /**
	 * Create Data to test.
	 */
    @TestSetup
    static void setup() {
        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();
        
        Account acc = new Account(
            Name = 'Prueba',
            RecordtypeId = rtAccount,
            CIBE_FechaCargaGE__c = Date.valueOf('2022-01-01')
        );
        insert acc;
        
        Account acc2 = new Account(
            Name = 'Prueba 2',
            RecordtypeId = rtAccount,
            CIBE_FechaCargaGE__c = Date.valueOf('2022-01-02')
        );
        insert acc2;
    }

    /**
	 * Execute the Batch class (CIBE_EconomicGroupsAcc_Batch) 
	 */
    @isTest
    public static void deleteAccountTest() {
        Test.startTest();
        
        CIBE_EconomicGroupsAcc_Batch batch = new CIBE_EconomicGroupsAcc_Batch();
        Id batchId = Database.executeBatch(batch);
        
        Test.stopTest();
        List<Account> accs = [SELECT id FROM Account];
        System.assertEquals(1, accs.size());
    }
    
     /**
	 * Execute the Batch class (CIBE_EconomicGroupsAcc_Batch) 
	 */
    @isTest
    public static void deleteAccount2Test() {
        Test.startTest();
        
        String fecha = System.today().year() + '-' + System.today().month() + '-' + System.today().day();
        CIBE_EconomicGroupsAcc_Batch batch = new CIBE_EconomicGroupsAcc_Batch('SELECT Id, CIBE_FechaCargaGE__c FROM Account WHERE RecordTypeId = :RT_ACC and CIBE_FechaCargaGE__c != 2022-01-02');
        Id batchId = Database.executeBatch(batch);
        
        Test.stopTest();
        List<Account> accs = [SELECT id FROM Account];
        System.assertEquals(1, accs.size());
    }

}