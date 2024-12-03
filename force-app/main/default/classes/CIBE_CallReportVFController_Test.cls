@isTest
public class CIBE_CallReportVFController_Test {
    
    @testSetup
    public static void setup() {
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        System.runAs(usuario) {
            RecordType rtCliente = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            
            Event event1 = new Event();
            event1.AV_ExternalID__c='1';
            event1.Subject = 'Test Event Con External';
            event1.RecordTypeId = rtCliente.Id;
            event1.DurationInMinutes = 60;
            event1.ActivityDateTime = System.now();
            event1.Location = 'Outlook';
            event1.OwnerId = usuario.Id;
            event1.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event1.Description = 'Prueba texto descripcion 1';
            event1.AV_Tipo__c = 'VC';
            event1.IsRecurrence = false;
            insert event1;
        }
    }
    
    @isTest
	public static void testController() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Event ev = [SELECT Id FROM Event WHERE AV_ExternalID__c = '1'];
            
            PageReference pageRef = new PageReference('/apex/CIBE_CallReportEMP');
            pageRef.getParameters().put('recordId', ev.Id);
            Test.setCurrentPage(pageRef);
            
            CIBE_CallReportVFController controller = new CIBE_CallReportVFController();
            System.assert(controller != null);
        }
        Test.stopTest();
    }
    
}