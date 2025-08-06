@isTest
public class CIBE_RelatedTaskController_Test {
	@testSetup
    public static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor' LIMIT 1];
        UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = 'CIBE_CIBEmpresas' LIMIT 1];
        
        
        User usrTest = new User(
            UserRoleId = ur.Id,
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044',
            ProfileId = p.Id,
            UserName = CIBE_TestHelper.getEmail(),
            AV_ExternalID__c = 'U0009003'
        );
        insert usrTest;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CIBE_OperativaCIB'];
        insert new PermissionSetAssignment(AssigneeId = usrTest.Id, PermissionSetId = ps.Id);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
            RecordType rt = cibe_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
            Contact empleado = new Contact();
            empleado.RecordTypeId = rt.Id;
            empleado.FirstName = 'Empleado';
            empleado.LastName = '1';
            empleado.Email = CIBE_TestHelper.getEmail();
            empleado.CC_Idioma__c = 'es';
            empleado.CC_Matricula__c = usrTest.AV_ExternalId__c;
            empleado.CIBE_Sector__c = '001';
            empleado.CIBE_Cartera__c = '001';
            //empleado.AccountId = centroCaixa.Id;
            empleado.AV_UsuarioAsociado__c = usrTest.Id;
            empleado.OwnerId = usrTest.Id;
            insert empleado;
        }
        
        Recordtype rtCIB = [SELECT Id FROM Recordtype where developername = :CIBE_AppConstants.EVENT_CLIENTE_CIB_RT];
        System.runAs(usrTest) {
            Account cliente = CIBE_TestHelper.createCustomer();  
            Event event1 = new Event();
            event1.whatId = cliente.Id;
            event1.AV_ExternalID__c='1';
            event1.Subject = 'Test Event 1';
            event1.DurationInMinutes = 60;
            event1.ActivityDateTime = System.now();
            event1.Location = 'Outlook';
            event1.OwnerId = usrTest.Id;
            //event1.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
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
            event2.OwnerId = usrTest.Id;
            //event1.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event2.Description = 'Prueba texto descripcion 2';
            event2.AV_Tipo__c = 'OCL';
            event2.IsRecurrence = false;
            event2.recordtypeId = rtCIB.Id;
            
            insert new List<Event>{event1, event2};
            
            Task task1 = new Task();
            task1.whatId = cliente.Id;
            task1.Subject = 'Subject 1';
            
            Task task2 = new Task();
            task2.whatId = cliente.Id;
            task2.Subject = 'Subject 2';
            
            insert new List<Task>{task1, task2};
            
            Task tsk = [SELECT Id, AV_Task__c FROM Task where id = :task1.Id];
            Event evt = [SELECT Id, AV_Task__c FROM Event where id = :event1.Id];
            
            CIBE_RelaccionadoCita__c relatedCita = new CIBE_RelaccionadoCita__c();
            relatedCita.CIBE_TareaRelaccionada__c = tsk.AV_Task__c;
            relatedCita.CIBE_CitaRelaccionada__c = evt.AV_Task__c;
            relatedCita.CIBE_IsMain__c = true;
            
            insert relatedCita;
        }
        
        
        
    }
    
    
    @isTest
    public static void testRetrieveListWithOutMeeting() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event LIMIT 1];
            
            List<Task> taskList = CIBE_Related_Task_Controller.retrieveListWithOutMeeting(event1.Id);
            
            System.assert(taskList != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testGetRecordInfo() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event LIMIT 1];
            
            List<CIBE_Related_Task_Controller.EventExtensionWrapper> wrap = CIBE_Related_Task_Controller.getRecordInfo(event1.Id);
            
            System.assert(wrap != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testGetMain() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event LIMIT 1];
            Task task1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Task LIMIT 1];
            
            Boolean isMain = CIBE_Related_Task_Controller.getMain(event1.AV_Task__c, task1.AV_Task__c);
            
            System.assert(isMain);
            Test.stopTest();
        }
    }
    
    
    
    @isTest
    public static void testGetTaskFields() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Task task1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Task LIMIT 1];
            
            Task tsk = CIBE_Related_Task_Controller.getTaskFields(task1.Id);
            
            System.assertEquals(tsk.AV_Task__c, task1.AV_Task__c);
            Test.stopTest();
        }
    }
    
    
    
    @isTest
    public static void testLinkTask() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event where subject = 'Test Event 1' LIMIT 1];
            Task task1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Task where subject = 'Subject 1' LIMIT 1];
            
            String result = CIBE_Related_Task_Controller.linkTask(event1.Id, task1.Id);
            
            System.assertEquals(result, 'KO');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testLinkTask2() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event where subject = 'Test Event 2' LIMIT 1];
            Task task1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Task where subject = 'Subject 2' LIMIT 1];
            
            String result = CIBE_Related_Task_Controller.linkTask(event1.Id, task1.Id);
            
            System.assertEquals(result, 'OK');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testUnlinkTask() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event where subject = 'Test Event 1' LIMIT 1];
            Task task1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Task where subject = 'Subject 1' LIMIT 1];
            
            CIBE_Related_Task_Controller.unlinkTask(task1.Id, event1.Id);
            
            List<CIBE_RelaccionadoCita__c> relCita = [SELECT ID FROM CIBE_RelaccionadoCita__c Limit 1];
            
            System.assertEquals(relCita, new List<CIBE_RelaccionadoCita__c>());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testUpdateMainRecord() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event where subject = 'Test Event 1' LIMIT 1];
            Task task1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Task where subject = 'Subject 1' LIMIT 1];
            
            CIBE_Related_Task_Controller.updateMainRecord(event1.Id, task1.Id);
            
            CIBE_RelaccionadoCita__c relCita = [SELECT ID, CIBE_IsMain__c FROM CIBE_RelaccionadoCita__c Limit 1];
            
            System.assertEquals(relCita.CIBE_IsMain__c, false);
            Test.stopTest();
        }
    }
}