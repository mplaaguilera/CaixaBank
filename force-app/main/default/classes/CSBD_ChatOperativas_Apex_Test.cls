@isTest
private class CSBD_ChatOperativas_Apex_Test {
    
    @isTest
    static void testInitWithGestorUser() {
        User userGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(userGestor) {
            Test.startTest();
                Map<String, Object> result = CSBD_ChatOperativas_Apex.init(null);
            Test.stopTest();            
            Boolean u  =  (Boolean) result.get('admin');
            System.assertEquals(false, u, 'El usuario gestor no debería tener acceso');
        }
    }
    
    @isTest
    static void testInitWithAdminUser() {
        // Crear un usuario administrador
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'admin',
            Email = 'admin@caixabank.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es_ES',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'Europe/Madrid',
            UserName = 'admin@salesforce.caixabank.com'
        );
        
        System.runAs(adminUser) {
            Test.startTest();
            Map<String, Object> result = CSBD_ChatOperativas_Apex.init(null);
            Test.stopTest();
            System.Debug(result.get('admin'));
            Boolean u  =  (Boolean) result.get('admin');
            System.assertEquals(true, u, 'El usuario administrador debería tener acceso');
        }
    }
    
}