@isTest
public class CC_UserTriggerHelper_Test {
    @TestSetup
    static void makeData(){
        User usuarioBackup = new User();
        Id perfil = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor' LIMIT 1].Id;
        usuarioBackup.ProfileId = perfil;
        usuarioBackup.FirstName = 'Usuario Backup';
        usuarioBackup.LastName = 'last211';
        usuarioBackup.Email = 'aalsdna@kfsb.com';
        usuarioBackup.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioBackup.Title = 'title';
        usuarioBackup.Alias = 'alias';
        usuarioBackup.TimeZoneSidKey = 'Europe/Paris';
        usuarioBackup.EmailEncodingKey = 'UTF-8';
        usuarioBackup.LanguageLocaleKey = 'es';
        usuarioBackup.LocaleSidKey = 'es_ES';
        insert usuarioBackup;

        Case caso = new Case();
        caso.OwnerId = usuarioBackup.Id;
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;


    }

    @isTest
    public static void nuevoUsuarioTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Backup' LIMIT 1];
        
        Id perfil = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank' LIMIT 1].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE Name = 'Contact Center' LIMIT 1].Id;
        
        User usuario = new User();
        usuario.ProfileId = perfil;
        usuario.UserRoleId = roleCC;
        usuario.FirstName = 'Usuario Prueba';
        usuario.LastName = 'last211';
        usuario.Email = 'aalsdna@kfsb.com';
        usuario.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Paris';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        
        Test.startTest();
        insert usuario;
        Test.stopTest();
        
        System.runAs(supervisor) {
        	List<PermissionSetAssignment> psa = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :usuario.Id];
        	System.assertEquals(true, psa.Size() >= 1, '');
        }
        
    }

    @isTest
    public static void usuarioActivoTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Backup' LIMIT 1];
        
        Id perfil = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank' LIMIT 1].Id;
        Id perfil2 = [SELECT Id FROM Profile WHERE Name = 'CC_Operador básico CCO' LIMIT 1].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE Name = 'Contact Center' LIMIT 1].Id;
        User usuario = new User();
        usuario.ProfileId = perfil;
        usuario.UserRoleId = roleCC;
        usuario.isActive = true;
        usuario.FirstName = 'Usuario Prueba';
        usuario.LastName = 'last211';
        usuario.Email = 'aalsdna@kfsb.com';
        usuario.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Paris';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        insert usuario;

        Test.startTest();
        usuario.profileId = perfil2;
        update usuario;
        Test.stopTest();

        System.runAs(supervisor) {
            GroupMember grupo = [SELECT UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :usuario.Id];
            System.assertEquals(usuario.Id, grupo.UserOrGroupId);
        }

    }
}