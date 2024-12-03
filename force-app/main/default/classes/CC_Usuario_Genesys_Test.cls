@isTest
public with sharing class CC_Usuario_Genesys_Test {
    @isTest
    public static void test() {
        Id userId = UserInfo.getUserId();
        CC_Usuario_Genesys__c usuarioGen = new CC_Usuario_Genesys__c(
            CC_User__c = userId,
            Name = 'LOGINTEST',
            CC_DN__c = '1234',
            CC_Acceso__c = 'Teléfono;Chat'
        );
        insert usuarioGen;

        CC_Usuario_Genesys__c datosUsuarioGen = CC_Usuario_Genesys.obtenerDatosUsuario();
        System.assertEquals(userId, datosUsuarioGen.CC_User__c);
        System.assertEquals('LOGINTEST', datosUsuarioGen.Name);
        System.assertEquals('1234', datosUsuarioGen.CC_DN__c);
        System.assertEquals('Teléfono;Chat', datosUsuarioGen.CC_Acceso__c);
    }
}