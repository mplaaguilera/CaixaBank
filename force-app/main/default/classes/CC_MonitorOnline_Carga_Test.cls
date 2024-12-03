@isTest
public class CC_MonitorOnline_Carga_Test
{
    @testSetup
    static void makeData()
    {
        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        
        User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        insert usuarioAdmin;

        System.runAs(usuarioAdmin)
        {
            Id role = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
            User supervisor = new User();
            supervisor.ProfileId = profileId;
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
            supervisor.UserRoleId = role;
            insert supervisor;
            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);
        	insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psSupervisor.Id);
        }
    }
    
    @isTest
    public static void cargaDatos()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor)
        {
            String json = JSON.serialize('Fecha;Proveedor;0:00;1:00;2:00;3:00;4:00;5:00;6:00;7:00;8:00;9:00;10:00;11:00;12:00;13:00;14:00;15:00;16:00;17:00;18:00;19:00;20:00;21:00;22:00;23:00;Tipo de registro;Servicio\n2023-07-31;DXC;0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;Chats; EXTRANJERO');
            CC_MonitorOnline_Carga.saveFile(json);
            List<CC_Prevision__c> prevision = [SELECT Id FROM CC_Prevision__c WHERE CreatedById = :supervisor.Id];
            System.assertEquals(1, prevision.size(), 'Se ha creado la previsión');
        }
    }
}