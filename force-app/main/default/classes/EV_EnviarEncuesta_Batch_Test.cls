@isTest
public class EV_EnviarEncuesta_Batch_Test {
    @isTest
	private static void  test1() {
        Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
        campaign camp = New campaign(Name='Test', RecordTypeId = rtEvento,EV_Notification__c ='001');
        insert camp;
        Network comunidades = [SELECT Id FROM Network limit 1];
        
        EV_EnviarEncuesta_Batch sendEmailBatch = new EV_EnviarEncuesta_Batch(camp.Id, comunidades.Id);
        Database.executeBatch(sendEmailBatch);

    }
    
    @isTest
    private static void test2(){
        EV_EnviarEncuesta_Batch sendEmailBatch = new EV_EnviarEncuesta_Batch();
        Database.executeBatch(sendEmailBatch);
    }

}