@isTest
private class SEG_Usuarios_Test{
    @isTest 
    static void testUsuarioOperativo() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            User usuario = SEG_Usuarios.usuarioOperativo();
            System.assertNotEquals(null, usuario.Id, 'El usuario operativo no fue creado correctamente');
            System.assertEquals('Operador', usuario.FirstName, 'El nombre del usuario operativo no es correcto');
            System.assertEquals('Operador', usuario.Alias, 'El alias del usuario operativo no es correcto');
            // Verificar que el usuario tenga el permiso adecuado
            Set<Id> permisos = new Set<Id>();
            for (PermissionSetAssignment permiso : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :usuario.Id]) {
                permisos.add(permiso.PermissionSetId);
            }
            System.assertEquals(true, permisos.contains([SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'].Id), 'El usuario operativo no tiene el permiso adecuado');
        }
    }
    @isTest 
    static void testUsuarioSupervisor() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            User usuario = SEG_Usuarios.usuarioSupervisor();
            System.assertNotEquals(null, usuario.Id, 'El usuario supervisor no fue creado correctamente');
            System.assertEquals('supervisor', usuario.FirstName, 'El nombre del usuario supervisor no es correcto');
            System.assertEquals('supervi', usuario.Alias, 'El alias del usuario supervisor no es correcto');
            // Verificar que el usuario tenga los permisos adecuados
            Set<Id> permisos = new Set<Id>();
            for (PermissionSetAssignment permiso : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :usuario.Id]) {
                permisos.add(permiso.PermissionSetId);
            }
            
            System.assertEquals(False, permisos.contains([SELECT Id FROM PermissionSet WHERE Name = 'SEG_Supervisor'].Id), 'El usuario Supervisor no tiene el permiso adecuado');
        }
    }
}