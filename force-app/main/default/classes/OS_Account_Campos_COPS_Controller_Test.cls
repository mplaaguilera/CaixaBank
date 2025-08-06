@isTest
public with sharing class OS_Account_Campos_COPS_Controller_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Account cuenta = new Account();
        cuenta.Name = 'cuenta prueba';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.OS_Premium__c = true;
        insert cuenta;

        Account cuentaPA = new Account();
        cuentaPA.FirstName = 'cuenta pa';
        cuentaPA.LastName = 'Test';
        cuentaPA.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        cuentaPA.OS_Premium__c = true;
        cuentaPA.SEG_No_enviar_Acuse_Recibo__pc = true;
        insert cuentaPA;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'servicio.factoring@caixabank.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaPA.Id;
        acshare2.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        insert acshare2;

        OS_Cartera__c cartera = new OS_Cartera__c();
        cartera.Name = 'cartera test';
        cartera.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OS_Cartera__c', 'OS_Cartera');
        insert cartera;
        
        OS_Cartera__c centroManipulador = new OS_Cartera__c(); 
        centroManipulador.Name = 'centro manipulador test';
		centroManipulador.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OS_Cartera__c', 'OS_Centro_Manipulador');
        insert centroManipulador;
    }

    @isTest
    public static void test() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE Name = 'cuenta prueba' LIMIT 1];
        OS_Cartera__c cartera = [SELECT Id, Name FROM OS_Cartera__c WHERE Name = 'cartera test' LIMIT 1];
        OS_Cartera__c centroManipulador = [SELECT Id, Name FROM OS_Cartera__c WHERE Name = 'centro manipulador test' LIMIT 1];

        System.runAs (usuarioOperador) {
            Test.startTest();
            Map<String, Object> mapaCamposCopsAccount = OS_Account_Campos_COPS_Controller.init(cuenta.Id);
            OS_Account_Campos_COPS_Controller.guardar(cuenta.Id, cartera.Id, true, true, centroManipulador.Id);
            Test.stopTest();
            
            System.assertEquals(true,mapaCamposCopsAccount.get('OS_Premium__c'), 'Comprobamos el mapa contiene OS_Premium.');
            System.assertEquals(false,mapaCamposCopsAccount.get('CBK_HolaBank__c'), 'Comprobamos el mapa NO contiene CBK_HolaBank.');
            System.assertEquals('CC_CentroCaixaBank',mapaCamposCopsAccount.get('recordtype'), 'Comprobamos que el RT sea Centro CaixaBank.');
        }
    }
    
    @isTest
    public static void guardarPA() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Account cuentaPA = [SELECT Id, Name, CC_Numero_Documento__c, OS_Modificacion_Campos_COPS__c FROM Account WHERE FirstName = 'cuenta pa' LIMIT 1];
        OS_Cartera__c cartera = [SELECT Id, Name FROM OS_Cartera__c WHERE Name = 'cartera test' LIMIT 1];

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Account_Campos_COPS_Controller.guardarPA(cuentaPA.Id, cartera.Id, false, false);
            Test.stopTest();

            Account acc =[SELECT Id, OS_Modificacion_Campos_COPS__c FROM Account WHERE Id =:cuentaPA.Id];

            System.assertEquals(acc.OS_Modificacion_Campos_COPS__c, cuentaPA.OS_Modificacion_Campos_COPS__c, 'Comprobamos que coincide la modificación de campos del cliente.');
        }
    }

    @isTest
    static void guardarContact(){
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contactoGuardado = [SELECT Id, Name, CC_Numero_Documento__c, OS_Modificacion_Campos_Contact_COPS__c FROM Contact WHERE Email = 'servicio.factoring@caixabank.com' LIMIT 1];

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Account_Campos_COPS_Controller.guardarContact(contactoGuardado.Id, false);
            Test.stopTest();

            Contact contactoTest = [SELECT Id,OS_Modificacion_Campos_Contact_COPS__c FROM Contact WHERE Id =:contactoGuardado.Id LIMIT 1];

            System.assertEquals(contactoTest.OS_Modificacion_Campos_Contact_COPS__c, contactoGuardado.OS_Modificacion_Campos_Contact_COPS__c, 'Comprobamos que coincide la modificación de campos del cliente.');
        }
    }
}