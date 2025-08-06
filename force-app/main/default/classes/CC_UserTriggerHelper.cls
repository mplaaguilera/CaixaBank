public with sharing class CC_UserTriggerHelper {

    public static void nuevoUsuarioAI(List<User> listNewObj) {
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        PermissionSetGroup psg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName = 'CC_PermisosUtiles'];

        if (psg.Status != 'Updated') {
            Test.calculatePermissionSetGroup(psg.Id);
        }
            for (User usuario : listNewObj) {
                permissionSetAssignments.add(
                    new PermissionSetAssignment(
                        AssigneeId = usuario.Id,
                        PermissionSetGroupId = psg.Id
                    )
                );
            }

        if (!permissionSetAssignments.isEmpty()) {
            insert permissionSetAssignments;
        }
    }

    public static void usuarioActivoAI(List<User> listNewObj) {
        List<Id> idsUsuarios = new List<Id>();
        for (User usuario : listNewObj) {
            if (usuario.isActive) {
                idsUsuarios.add(usuario.Id);
            }
        }
        CC_User_Metodos.usuariosGruposPublicos(idsUsuarios);
    }

    public static void usuarioActivoAU(List<User> listNewObj, Map<Id, User> mapOldObj) {
        List<Id> idsUsuarios = new List<Id>();
        for (User usuario : listNewObj) {
            if (usuario.isActive && usuario.ProfileId != mapOldObj.get(usuario.Id).ProfileId) {
                idsUsuarios.add(usuario.Id);
            }
        }
        CC_User_Metodos.usuariosGruposPublicos(idsUsuarios);
    }
}