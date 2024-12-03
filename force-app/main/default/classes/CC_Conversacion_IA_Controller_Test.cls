@isTest
public class CC_Conversacion_IA_Controller_Test {
    @TestSetup
    static void makeData(){

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole roleId = [SELECT Id FROM UserRole WHERE Name = 'Contact Center' LIMIT 1];
        List<User> userList = new List<User>();
        User usuario = new User();
        usuario.ProfileId = profileId;
        usuario.UserRoleId = roleId.Id;
        usuario.FirstName = 'Usuario Prueba';
        usuario.LastName = 'last1';
        usuario.Email = 'tuser000@amamamaaaa.com';
        usuario.Username = 'tuser000@amamamaaaa.com' + System.currentTimeMillis();
        usuario.CompanyName = 'MST';
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Paris';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        userList.add(usuario);
		
        insert userList;

    }

    @isTest
    public static void getRTCaseTest() {

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Usuario Prueba'];
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso prueba' LIMIT 1];
        Case caso = new Case(
            Subject = 'Caso prueba',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
        );
        insert caso;

        String rtCase;
        System.runAs(usuario) {
            Test.startTest();
            rtCase = CC_Conversacion_IA_Controller.getRTCase(caso.Id);
            Test.stopTest();
        }

        System.assertEquals('Cliente', rtCase, 'El RT del caso es incorrecto');
    }

    @isTest
    public static void getValoracionCaseTest() {

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Usuario Prueba'];
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso prueba' LIMIT 1];
        Case caso = new Case(
            Subject = 'Caso prueba',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
        );
        insert caso;

        String valoracionCase;
        System.runAs(usuario) {
            Test.startTest();
            valoracionCase = CC_Conversacion_IA_Controller.getRTCase(caso.Id);
            Test.stopTest();
        }

        System.assertEquals('Nada', valoracionCase, 'La valoración del caso es incorrecto');
    }

    @isTest
    public static void updateValoracionAITest() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Usuario Prueba'];
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso prueba' LIMIT 1];
        Case caso = new Case(
            Subject = 'Caso prueba',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
        );
        insert caso;
        
        System.runAs(usuario) {
            Test.startTest();
            CC_Conversacion_IA_Controller.updateValoracionAI(caso.Id, 'OK');
            Test.stopTest();
        }

        Case casoActualizado = [SELECT CC_Valoracion_AI__c FROM Case WHERE Subject = 'Caso prueba' LIMIT 1];

        System.assertEquals('OK', casoActualizado.CC_Valoracion_AI__c, 'La valoracion del caso es incorrecto');
        
    }

}