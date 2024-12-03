@isTest
public class CIBE_TaskCallReportFields_Test {
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
            event1.AV_ExternalID__c='1';
            event1.Subject = 'Test Event Con External';
            event1.DurationInMinutes = 60;
            event1.ActivityDateTime = System.now();
            event1.Location = 'Outlook';
            event1.OwnerId = usrTest.Id;
            //event1.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event1.Description = 'Prueba texto descripcion 1';
            event1.AV_Tipo__c = 'OCL';
            event1.IsRecurrence = false;
            event1.recordtypeId = rtCIB.Id;
            
            insert event1;
            
        }
    }
    
    @isTest
    public static void testGetExtensionId() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event LIMIT 1];
            
            String extensionId = CIBE_TaskCallReportFields.getExtensionId(event1.Id);
            
            System.assert(String.isNotBlank(extensionId));
            Test.stopTest();
        }
    }

}