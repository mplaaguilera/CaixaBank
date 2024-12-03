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

        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_Operador' LIMIT 1];
        if (permissionSet != null)
        {
            PermissionSetAssignment nuevoPermiso2 = new PermissionSetAssignment();
            nuevoPermiso2.PermissionSetId = permissionSet.Id;
            nuevoPermiso2.AssigneeId = usuario.Id;
            insert nuevoPermiso2;
        }

       // asignarPublicGroup('HDT_Operador_PSG', usuario.Id);
        //permisosUsuarioGenerico();

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

    public static void permisosUsuarioGenerico() {
        
        List<User> usuarioGenerico = [SELECT Id FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%' AND IsActive = true];
    
        if(!usuarioGenerico.isEmpty()) {
            asignarPublicGroup('HDT_Operador_PSG', usuarioGenerico[0].Id);
        }
    }


    public static void asignarPublicGroup(String nombreGroup, Id userId) {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Group grp = [SELECT Id FROM Group WHERE DeveloperName = :nombreGroup LIMIT 1];

            groupMember gp = new groupMember(GroupId = grp.Id);
            gp.UserOrGroupId = userId;
            insert gp; 
        }
    }
}