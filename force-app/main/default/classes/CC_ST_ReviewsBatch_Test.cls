@istest
public with sharing class CC_ST_ReviewsBatch_Test {
	
    @istest
    public static void test() {
        
        Test.StartTest();
        CC_ST_ReviewsBatch batch = new CC_ST_ReviewsBatch();
		Database.executeBatch(batch);
        Test.stopTest();
        
        List<CC_Config_Stores__mdt> lstConf = [Select DeveloperName, Identificador__c, countryCode__c, Tipo__c from CC_Config_Stores__mdt where Activo__c = true];
        
        system.assert(lstConf.size()>0, 'Comprobamos existe configuración para los comentarios.');
    }
    
}