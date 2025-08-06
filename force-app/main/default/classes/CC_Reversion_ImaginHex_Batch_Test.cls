@isTest
public class CC_Reversion_ImaginHex_Batch_Test {
	@isTest
    public static void encryptNumperso_beforeUpdate() {
        // Alta de datos para la prueba
        Account acc = new Account();
		acc.FirstName = 'Prueba';
        acc.LastName = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        acc.CC_Numero_Documento__c = '45855598S';
		acc.CC_NumPerso__c = '533752';
        insert acc;
        
        acc.CC_Numperso_HEX__c = '';
        update acc;
        
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.Status = 'Cerrado';
        caso.AccountId = acc.id;
        caso.CC_Estado_Reversion__c = 'Pendiente envío';
        insert caso;
        
        // Ejecución de la prueba
        Test.startTest();
        CC_Reversion_ImaginHex_Batch batch = new CC_Reversion_ImaginHex_Batch();
		Database.executeBatch(batch,1);
        Test.stopTest();
        
        // Evaluación del resultado de la prueba
        Account accInsertado = [SELECT CC_Numperso_HEX__c FROM Account WHERE Id = :acc.Id];
        if (accInsertado != null) {
            System.assertNotEquals(accInsertado.CC_Numperso_HEX__c, null);
        }
    }
}