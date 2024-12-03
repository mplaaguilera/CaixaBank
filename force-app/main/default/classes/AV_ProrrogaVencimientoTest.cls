@isTest
public class AV_ProrrogaVencimientoTest {
    
    @TestSetup
	static void setup(){
            
	//RecordType rtLead = AV_AppUtilities.getRecordType('Lead', 'AV_PlataformasHipotecarias');
	//RecordType rtLeadOpp = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', 'AV_PlataformasHipotecarias');
	//
    Lead l = AV_TestHelper.createLead();
    AV_LeadOpportunity__c lo = AV_TestHelper.createLeadOpportunity(l);
    lo.AV_DueDate__c =  Date.newInstance(2022, 5, 1);
	Database.update(lo);
    }
    
    @isTest
	static void sumaDiasFechaVencimientotest() {
		Test.startTest();
        AV_LeadOpportunity__c loOld = [SELECT Id FROM AV_LeadOpportunity__c LIMIT 1];
        AV_ProrrogaVencimiento.sumaDiasFechaVencimiento(loOld.Id);
        AV_LeadOpportunity__c lo = [SELECT Id, AV_DueDate__c FROM AV_LeadOpportunity__c LIMIT 1];
        Date fechaEsperada = Date.newInstance(2022, 5, 31);
        System.assertEquals(fechaEsperada, lo.AV_DueDate__c);
		Test.stopTest();
	}
}