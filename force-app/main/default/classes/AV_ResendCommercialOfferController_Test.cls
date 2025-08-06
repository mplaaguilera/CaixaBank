@isTest
public class AV_ResendCommercialOfferController_Test {
    
    @TestSetup
    static void setup(){
        
        AV_LeadOpportunity__c leadOpp = new AV_LeadOpportunity__c();
        leadOpp.AV_Status__c = '02';
        leadOpp.AV_EstadoEnvioOfComercial__c ='1';
        leadOpp.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_POTENCIAL;
        insert leadOpp;
        
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + 'Standard User' + '\' LIMIT 1');
    }
    
    
    @isTest
    private static void resetLeadOppTest(){
        AV_LeadOpportunity__c a = [SELECT Id FROM AV_LeadOpportunity__c LIMIT 1];
        User u = [SELECT id FROM User LIMIT 1];
        Test.startTest();
        AV_ResendCommercialOfferController.resetLeadOpp(a.Id);
        Test.stopTest();
        AV_LeadOpportunity__c lo = [SELECT  AV_Status__c FROM AV_LeadOpportunity__c LIMIT 1];
        System.assertEquals(lo.AV_Status__c, AV_AppConstants.LEADOPP_STATUS_ACTIVO);
    }

}