public with sharing class CSBD_LwcUtils_Apex {

    @AuraEnabled(cacheable=true)
    public static Boolean usuarioDesarrollador(Id idUsuario) {
        idUsuario = idUsuario ?? UserInfo.getUserId();
        return ![SELECT Id FROM GroupMember WHERE Group.DeveloperName = 'CSBD_Desarrollo' AND UserOrGroupId = :idUsuario LIMIT 1].isEmpty();
    }
}