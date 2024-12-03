public with sharing class CC_Usuario_Genesys {
    public static CC_Usuario_Genesys__c obtenerDatosUsuario() {
        Id userId = UserInfo.getUserId();
        List<CC_Usuario_Genesys__c> usuariosGenesys = [SELECT Name, CC_User__c, CC_DN__c, CC_Acceso__c, CC_Negocio__c FROM CC_Usuario_Genesys__c WHERE CC_User__c =: userId LIMIT 1];
        CC_Usuario_Genesys__c usuarioGenesys = null;
        if (!usuariosGenesys.isEmpty()) {
            usuarioGenesys = usuariosGenesys[0];
        }
        return usuarioGenesys;
    }
}