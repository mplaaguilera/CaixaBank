public with sharing class HDT_TestDataFactory {
    public static User usuarioPruebasHdt() {
        
        User usuario = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        usuario.IsActive = true;
        usuario.Alias = 'usr_test';
        usuario.Email = 'usuario_test@test.com';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LastName = 'Usuario Test';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'HDT'].Id;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'HDT_Usuario_CaixaBank'].Id;
        usuario.TimeZoneSidKey = 'Europe/Madrid';
        usuario.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        insert usuario;

        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_Analista_2N' LIMIT 1];
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = usuario.Id;
                insert nuevoPermiso;
            }
        }
        //asignarPublicGroup('CSBD_Empleados', gestor.Id);
        //permisosUsuarioGenerico();
        return usuario;
    }

    public static User usuarioAHdt() {
        User usuario = new User();
        usuario.IsActive = true;
        usuario.Alias = 'usr_test';
        usuario.Email = 'usuario_test@test.com';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LastName = 'Usuario Test';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'HDT'].Id;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usuario.TimeZoneSidKey = 'Europe/Madrid';
        usuario.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        insert usuario;
        return usuario;
    }
}