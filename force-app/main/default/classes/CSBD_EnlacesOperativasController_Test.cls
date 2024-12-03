@isTest
public with sharing class CSBD_EnlacesOperativasController_Test {
     @TestSetup
    static void data(){
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        Account cuenta = crearCuentaContacto('12345678N');
        User userPrueba = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = userPrueba.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
    }

    public static Account crearCuentaContacto(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        return cuenta;
    }
    @isTest
    public static void obtenerDatosCuentaTest() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        System.runAs (usuarioGestor) {
            Test.startTest();
            Account cuenta2 = CSBD_EnlacesOperativasController.obtenerDatosCuenta(cuenta.id);
            System.assertNotEquals(cuenta2, null, 'No hay cuenta con ese Id');
            Test.stopTest();
        }
       
    }
    
     @isTest
    public static void obtenerDatosUserTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
       
        System.runAs (usuarioGestor) {
            Test.startTest();
            User usuario = CSBD_EnlacesOperativasController.obtenerDatosUser(usuarioGestor.id);
            System.assertNotEquals(cuenta, null, 'No hay user con ese Id');
            Test.stopTest();
        }
       
    }
}