@isTest
public class CIBE_EventProductsCIBController_Test {
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
            
            insert relatedCita;
        }
        
        
        
    }
    
    
    @isTest
    public static void testCreateProductCIB() {
        Product2 prod = [SELECT ID FROM Product2 WHERE RECORDTYPE.DEVELOPERNAME = 'CIBE_Producto' and name = 'producto 2' LIMIT 1];
        
        List<Map<String,Object>> products = new List<Map<String,Object>>();
        Map<String,Object> prodMap = new Map<String,Object>();
        prodMap.put('idProducto', prod.Id);
        prodMap.put('comentario', 'Comentario 2');
        products.add(prodMap);
        
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event LIMIT 1];
            
            CIBE_EventProductsCIBController.createProductCIB(products, event1.Id);
            
            List<CIBE_RelaccionadoCita__c> relCitaList = [Select id from CIBE_RelaccionadoCita__c WHERE CIBE_Producto__c = :prod.Id];
            System.assert(relCitaList != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testGetProductosCita() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event LIMIT 1];
            
            List<CIBE_RelaccionadoCita__c> relCitaList = CIBE_EventProductsCIBController.getProductosCita(event1.Id);
            
            System.assert(relCitaList != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testDeleteProductCIB() {        
        CIBE_RelaccionadoCita__c relCitaList = [Select id from CIBE_RelaccionadoCita__c where CIBE_Producto__r.name = 'producto 1' limit 1];
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event LIMIT 1];
            
            CIBE_EventProductsCIBController.deleteProductCIB(relCitaList.Id);
            
            List<CIBE_RelaccionadoCita__c> relCitaListAfter = [Select id from CIBE_RelaccionadoCita__c where CIBE_Producto__r.name = 'producto 1' limit 1];
            
            System.assertEquals(relCitaListAfter, new List<CIBE_RelaccionadoCita__c>());
            Test.stopTest();
        }
    }
}