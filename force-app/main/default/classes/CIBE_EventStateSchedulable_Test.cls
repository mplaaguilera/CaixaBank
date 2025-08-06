/**********************************************************************************************************************
Name:	  CIBE_EventStateSchedulable
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para pasar a estado 'Vencido' todos eventos que tengan el closeDate inferior a TODAY
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				        DATE				Description
	1.0					            Ali & Bea                   07/03/2024			Init version
***********************************************************************************************************************/
@isTest
public class CIBE_EventStateSchedulable_Test {
    
    /**
	 * Create Data to test.
	 */
    @TestSetup
    static void setup() {
        
        // CIBE_TestInitialSetup.setupInitialData(null,CIBE_AppConstants.CIBE_ROLECIB,null,null,null,new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB, CIBE_AppConstants.CIBE_CUSTOMMETADATA, CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_ANALYTICS, CIBE_AppConstants.USER_AV_AvoidBulkApi});
		List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,
                                            CIBE_AppConstants.CIBE_CUSTOMMETADATA,
                                            CIBE_AppConstants.CIBE_ANALYTICS,
                                            CIBE_AppConstants.CIBE_OPERATIVAEMP, 
                                            CIBE_AppConstants.USER_AV_AVOIDBULKAPI};
        RecordType rtCliente = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_CIB_RT);
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
		User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(admin) {
            Account acc = CIBE_TestHelper.createCustomer();
            Event event = new Event();
            event.AV_ExternalID__c='1';
            event.Subject = 'Test Event Con External';
            event.RecordTypeId = rtCliente.Id;
            event.DurationInMinutes = 60;
            event.ActivityDate =   Date.today() - 5;
            event.ActivityDateTime = event.ActivityDate;
            event.OwnerId = usrTest.Id;
            event.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PLANIFICADA;
            event.Description = 'Prueba texto descripcion 1';
            event.AV_Tipo__c = 'VLD';

            insert event;
        
        List<Event> listEvent = new List<Event>();
        listEvent.add(event);
        }
    }

    /**
	 * Execute the Batch class (CIBE_EventStateSchedulable) 
	 */
    @isTest
    public static void validateBatch() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usrTest) {
			Test.startTest();
                CIBE_EventStateSchedulable batch = new CIBE_EventStateSchedulable();
                Id batchId = Database.executeBatch(batch);
                Database.executeBatch(new CIBE_EventStateSchedulable(null), 200);
            Test.stopTest();
		}
        List<Event> listEvent = [SELECT id FROM Event WHERE CSBD_Evento_Estado__c = 'Vencida'  LIMIT 1];
        System.assertEquals(1, listEvent.size());
    }


}