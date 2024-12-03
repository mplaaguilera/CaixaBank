@istest
public with sharing class CC_ST_ReviewsHuaweiBatch_Test {
	
    @testSetup
    static void datos(){
	
    	Google_SA_Token__c tokenSA = new Google_SA_Token__c();
        tokenSA.Name = 'Huawei_Store';
        tokenSA.Timestamp__c = null;
        tokenSA.Value__c = '';
        insert tokenSA;
        
        CC_ST_AppReviews__c st1 = new CC_ST_AppReviews__c();
        st1.Source__c = 'Huawei App Store';
        st1.App__c = 'CaixaBank';
        st1.App_ID__c = '111111111111';
        st1.Author_Name__c = 'ST1';
        insert st1;
        
        CC_ST_AppReviews__c st2 = new CC_ST_AppReviews__c();
        st2.Source__c = 'Huawei App Store';
        st2.App__c = 'CaixaBank';
        st2.App_ID__c = '111111111112';
        st2.Author_Name__c = 'ST2';
        insert st2;

    }
    
    @istest
    public static void test() {
        
        Test.StartTest();
        CC_ST_ReviewsHuaweiBatch batch = new CC_ST_ReviewsHuaweiBatch();
		Database.executeBatch(batch);
        Test.stopTest();
        
        List<CC_Config_Stores__mdt> lstConf = [Select DeveloperName, Identificador__c, countryCode__c, Tipo__c from CC_Config_Stores__mdt where Activo__c = true];
        
        system.assert(lstConf.size()>0, 'Comprobamos existe configuración para los comentarios.');
    }
    
}