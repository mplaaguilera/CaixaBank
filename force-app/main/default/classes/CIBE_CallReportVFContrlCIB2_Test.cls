@isTest
public class CIBE_CallReportVFContrlCIB2_Test {
	@testSetup
    public static void setup(){

        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI};

        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);

        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        
        
        Recordtype rtCIB = [SELECT Id FROM Recordtype where developername = :CIBE_AppConstants.EVENT_CLIENTE_CIB_RT];
        System.runAs(managerUser) {
            Account cliente = CIBE_TestHelper.createCustomer();  
            Event event1 = new Event();
            event1.whatId = cliente.Id;
            event1.AV_ExternalID__c='1';
            event1.Subject = 'Test Event 1';
            event1.DurationInMinutes = 60;
            event1.ActivityDateTime = System.now();
            event1.Location = 'Outlook';
            event1.OwnerId = managerUser.Id;
            event1.Description = 'Prueba texto descripcion 1';
            event1.AV_Tipo__c = 'OCL';
            event1.IsRecurrence = false;
            event1.recordtypeId = rtCIB.Id;
            
            Event event2 = new Event();
            event2.whatId = cliente.Id;
            event2.AV_ExternalID__c='2';
            event2.Subject = 'Test Event 2';
            event2.DurationInMinutes = 60;
            event2.ActivityDateTime = System.now();
            event2.Location = 'Outlook';
            event2.OwnerId = managerUser.Id;
            event2.Description = 'Prueba texto descripcion 2';
            event2.AV_Tipo__c = 'OCL';
            event2.IsRecurrence = false;
            event2.recordtypeId = rtCIB.Id;
            
            insert new List<Event>{event1, event2};
            Recordtype famRt = [SELECT id  from Recordtype where developername = 'CIBE_Familia']; 
            Recordtype prodRt = [SELECT id  from Recordtype where developername = 'CIBE_Producto'];
            
            Product2 familia = new Product2();
            familia.name = 'familia 1';
            familia.RecordTypeId = famRt.Id;
            
            insert familia;
                
            Product2 prod = new Product2();
            prod.CIBE_Familia__c = familia.Id;
            prod.name = 'producto 1';
            prod.RecordTypeId = prodRt.Id;
            
            Product2 prod2 = new Product2();
            prod2.CIBE_Familia__c = familia.Id;
            prod2.RecordTypeId = prodRt.Id;
            prod2.name = 'producto 2';
            
            insert new List<Product2>{prod, prod2};
            
            Event evt = [SELECT Id, AV_Task__c FROM Event where subject = 'Test Event 1' limit 1];
            
            CIBE_RelaccionadoCita__c relatedCita = new CIBE_RelaccionadoCita__c();
            relatedCita.CIBE_CitaRelaccionada__c = evt.AV_Task__c;
            relatedCita.CIBE_Producto__c = prod.Id;
            relatedCita.CIBE_Comentario__c = 'Comentario Producto';
            
            Contact empleado = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c =: managerUser.Id];
            
            CIBE_RelaccionadoCita__c relatedCita2 = new CIBE_RelaccionadoCita__c();
            relatedCita2.CIBE_CitaRelaccionada__c = evt.AV_Task__c;
            relatedCita2.CIBE_Contacto__c = empleado.Id;
            relatedCita.CIBE_TipoAsistente__c = 'Asistentes clientes';
            insert new List<CIBE_RelaccionadoCita__c>{relatedCita, relatedCita2};

            CBK_Activity_Extension__c activityExtensions = [SELECT Id,CIBE_ConclusionesCita__c, CIBE_ComentarioCita__c, CIBE_Country__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c =: evt.Id];
            activityExtensions.CIBE_ConclusionesCita__c ='Prueba';
            activityExtensions.CIBE_ComentarioCita__c ='Prueba';
            activityExtensions.CIBE_Country__c = 'España';
            update activityExtensions;

        }
        
    }
    
    @isTest
	public static void testController() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Event ev = [SELECT Id FROM Event Limit 1];
            
            PageReference pageRef = new PageReference('/apex/CIBE_CallReportCIB2');
            pageRef.getParameters().put('recordId', ev.Id);
            Test.setCurrentPage(pageRef);
            
            CIBE_CallReportVFControllerCIB2 controller = new CIBE_CallReportVFControllerCIB2();
            controller.setFlag('empresaRelativa', true);
            controller.setFlag('empresaAbsoluta', true);
            controller.setFlag('grupoAbsoluta', true);
            controller.setFlag('grupoRelativa', true);
            controller.setValue('absolutaEmpresa', 'Alta');
            controller.setValue('relativaEmpresa', 'Alta');
            controller.setValue('absolutaGrupo', 'Alta');
            controller.setValue('relativaGrupo', 'Alta');
            System.assert(controller != null);
        }
        Test.stopTest();
    }
}