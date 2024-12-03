@isTest
public class CBK_Fusion_Batch_Test {
    @isTest
    public static void Test_Batch() {
        
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account a1 = New Account(Name='Test 1',RecordTypeId=cuentaRecordTypeId);
        insert a1;       
        Account a2 = New Account(Name='Test 2',RecordTypeId=cuentaRecordTypeId);
        insert a2;
        
        CBK_Fusion__c fus = New CBK_Fusion__c(
            Id_Principal__c = a1.Id,
            Id_Secundario__c = a2.Id,
            Tipo__c = 'Merge',
        	Entidad__c ='Account');
        insert fus;
        
        test.startTest();
        CBK_Fusion_Batch b = new CBK_Fusion_Batch();
        Id batchId = Database.executeBatch(b);
        System.assertNotEquals(null,batchId);

        test.stopTest();
    }
}