@isTest
public class CSBD_Usuarios {

    public static User usuarioGestor(){
        User gestor = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            gestor.FirstName = 'GestorCSBD';
            gestor.LastName = '1';
            gestor.IsActive = true;
            gestor.Alias = 'Gestor';
            gestor.Email = 'usuario_test@test.com';
            gestor.EmailEncodingKey = 'ISO-8859-1';
            gestor.LanguageLocaleKey = 'es';
            gestor.LocaleSidKey = 'es_ES';
            gestor.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
            gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
            gestor.TimeZoneSidKey = 'Europe/Madrid';
            gestor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            insert gestor;

            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor' LIMIT 1];
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = gestor.Id;
                insert nuevoPermiso;
            }
        }
        asignarPublicGroup('CSBD_Empleados', gestor.Id);
        permisosUsuarioGenerico();
        return gestor;
    }

    public static User usuarioResponsable(){
        User responsable = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            responsable.FirstName = 'ResponsCSBD';
            responsable.LastName = '1';
            responsable.IsActive = true;
            responsable.Alias = 'Respons';
            responsable.Email = 'usuario_test@test.com';
            responsable.EmailEncodingKey = 'ISO-8859-1';
            responsable.LanguageLocaleKey = 'es';
            responsable.LocaleSidKey = 'es_ES';
            responsable.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
            responsable.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
            responsable.TimeZoneSidKey = 'Europe/Madrid';
            responsable.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            insert responsable;

            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Responsable' LIMIT 1];
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = responsable.Id;
                insert nuevoPermiso;
            }
        }
        permisosUsuarioGenerico();
        return responsable;
    }

    public static User usuarioAdministrador(){
        User admin = new User();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            admin.FirstName = 'AdminCSBD';
            admin.LastName = '1';
            admin.IsActive = true;
            admin.Alias = 'Admin';
            admin.Email = 'usuario_test@test.com';
            admin.EmailEncodingKey = 'ISO-8859-1';
            admin.LanguageLocaleKey = 'es';
            admin.LocaleSidKey = 'es_ES';
            admin.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
            admin.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
            admin.TimeZoneSidKey = 'Europe/Madrid';
            admin.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            insert admin;

            Group grp = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Administrador' LIMIT 1];

            groupMember gp = new groupMember(GroupId = grp.Id);
            gp.UserOrGroupId = admin.Id;
            insert gp;

            List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
            List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE Name LIKE 'CSBD%' AND Type != 'Group'];

            for (PermissionSet permissionSet1:permissionSet )
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet1.Id;
                nuevoPermiso.AssigneeId = admin.Id;
                nuevosPermisos.add(nuevoPermiso);
            }
            insert nuevosPermisos;
            permisosUsuarioGenerico();
        }

        return admin;
    }

    public static User usuarioIntegracion() {
        User usuarioIntegracion = new User();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            usuarioIntegracion.FirstName = 'Integración';
            usuarioIntegracion.LastName = 'Integración';
            usuarioIntegracion.IsActive = true;
            usuarioIntegracion.Alias = 'integracion';
            usuarioIntegracion.Email = 'usuario_integracion@test.com';
            usuarioIntegracion.EmailEncodingKey = 'ISO-8859-1';
            usuarioIntegracion.LanguageLocaleKey = 'es';
            usuarioIntegracion.LocaleSidKey = 'es_ES';
            usuarioIntegracion.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Contact Center'].Id;
            usuarioIntegracion.ProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only'].Id;
            usuarioIntegracion.TimeZoneSidKey = 'Europe/Madrid';
            usuarioIntegracion.UserName = 'integracion_test_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            insert usuarioIntegracion;

            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('CSBD API Only', 'CC_Classes')]) {
                PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                psAssignment.PermissionSetId = ps.Id;
                psAssignment.AssigneeId = usuarioIntegracion.Id;
                psAssignments.add(psAssignment);
            }
            insert psAssignments;
        }
        return usuarioIntegracion;
    }

    public static void permisosUsuarioGenerico() {
        List<User> usuarioGenerico = [SELECT Id FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%' AND IsActive = true];

        if(!usuarioGenerico.isEmpty()) {
            asignarPublicGroup('CSBD_Empleados', usuarioGenerico[0].Id);
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

    public static User usuarioDerivarGestor() {
        User gestor = new User();
        System.runAs (new User(Id = UserInfo.getUserId())) {
            gestor.FirstName = 'GestorDerivar';
            gestor.LastName = '1';
            gestor.IsActive = true;
            gestor.Alias = 'GestDer';
            gestor.Email = 'usuario_test@test.com';
            gestor.EmailEncodingKey = 'ISO-8859-1';
            gestor.LanguageLocaleKey = 'es';
            gestor.LocaleSidKey = 'es_ES';
            gestor.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
            gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
            gestor.TimeZoneSidKey = 'Europe/Madrid';
            gestor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            insert gestor;

            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'AV_NowIn' LIMIT 1];
            if (permissionSet != null)
            {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = gestor.Id;
                insert nuevoPermiso;
            }

            PermissionSet permissionSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor' LIMIT 1];
            if (permissionSet2 != null)
            {
                PermissionSetAssignment nuevoPermiso2 = new PermissionSetAssignment();
                nuevoPermiso2.PermissionSetId = permissionSet2.Id;
                nuevoPermiso2.AssigneeId = gestor.Id;
                insert nuevoPermiso2;
            }
        }
        asignarPublicGroup('CSBD_Empleados', gestor.Id);
        permisosUsuarioGenerico();
        return gestor;
    }
}