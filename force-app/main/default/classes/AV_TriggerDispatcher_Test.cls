@IsTest
public with sharing class AV_TriggerDispatcher_Test {

    private static RecordType clienteRT = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);

    @IsTest
    public static void mainEntryTest() {
        insert new List<Account> {
            new Account(
                Name = 'Cliente Empresas',
                RecordTypeId = clienteRT.Id,
                AV_Negocio__c = 'EMP;COR'
            ),
            new Account(
                Name = 'Cliente Retail',
                RecordTypeId = clienteRT.Id,
                AV_Negocio__c = 'BPA'
            ),
            new Account(
                Name = 'Cliente Cross',
                RecordTypeId = clienteRT.Id,
                AV_Negocio__c = 'BPA;CIB'
            ), 
            new Account(
                Name = 'Cliente Negocio Vacio',
                RecordTypeId = clienteRT.Id,
                AV_Negocio__c = ''
            ),
             new Account(
                Name = 'Cliente Negocio Null',
                RecordTypeId = clienteRT.Id
            )
        };
            
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(5, accounts.size());
    }

}