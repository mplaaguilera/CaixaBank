@isTest
public class CC_Knowledge_BU_TRHan_Test {
    
     @TestSetup
    static void makeData(){
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileSupervisor = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        
        User administrador = new User();
        administrador.ProfileId = profileAdmin;
        administrador.FirstName = 'Usuario Admin Prueba';
        administrador.LastName = 'last211';
        administrador.Email = 'aalsdna@kfsb.com';
        administrador.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        administrador.CompanyName = 'MST';
        administrador.Title = 'title';
        administrador.Alias = 'alias';
        administrador.TimeZoneSidKey = 'Europe/Paris';
        administrador.EmailEncodingKey = 'UTF-8';
        administrador.LanguageLocaleKey = 'es';
        administrador.LocaleSidKey = 'es_ES';
		insert administrador;

        System.runAs(administrador)
        {
            User supervisor = new User();
            supervisor.ProfileId = profileSupervisor;
            supervisor.FirstName = 'Supervisor';
            supervisor.LastName = 'last11';
            supervisor.Email = 'tuser000@amamama.com';
            supervisor.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            supervisor.CompanyName = 'MST';
            supervisor.Title = 'title';
            supervisor.Alias = 'alias';
            supervisor.TimeZoneSidKey = 'Europe/Paris';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = rolCC.Id;
            insert supervisor;

            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);

            CC_Settings__c knowledgeSettings = new CC_Settings__c(
                Name = 'CC_Knowledge_Settings',
                CC_Activa__c = true,
                CC_Configuracion_1__c = '30;15;7',
                CC_Configuracion_2__c = '7'
            );
            insert knowledgeSettings;
        }
    }
    
    @isTest
    static void asignarPropietarioCola() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        List<Task> tareas = new List<Task>();
        List<Group> colasKnowledge = [SELECT id, DeveloperName  FROM Group WHERE DeveloperName IN ('CC_Knowledge_Cliente','CC_Knowledge_Empleado') and Type = 'Queue'];
        System.runAs(supervisor)
        {
            Test.startTest();
            Knowledge__kav know = new Knowledge__kav();
            know.Title = 'Test Apex';
            know.UrlName = 'Test-Apex';
            know.CC_Tipo__c = 'Cliente';
            know.CC_Fecha_Inicio_Publicacion__c = CBK_UtilsDate.nowDT().addHours(2);
            know.CC_Fecha_Caducidad__c = CBK_UtilsDate.nowDT().addHours(4);
            know.ValidationStatus = 'Validated';
            insert know;
           
            Knowledge__kav knowQueue = [SELECT ownerId, PublishStatus from Knowledge__kav where id = :know.id];
            String idAntiguo = String.valueOf(knowQueue.OwnerId);
            
            System.assertEquals(true,  String.valueOf(knowQueue.OwnerId).startsWith('00G'), 'El propietario no es la cola');
            knowQueue.CC_Tipo__c = 'Empleado';
            
            update knowQueue;
            
             Knowledge__kav knowQueueFinal = [SELECT ownerId, PublishStatus from Knowledge__kav where id = :know.id];
            String idNuevo = String.valueOf(knowQueueFinal.OwnerId);
            
            System.assertEquals(true,  String.valueOf(knowQueueFinal.OwnerId).startsWith('00G'), 'El propietario no es la cola');
            System.assertEquals(true,  idAntiguo!=idNuevo, 'La cola no es la de empleado');
            
            
            
            Test.stopTest();
        }
    }

}