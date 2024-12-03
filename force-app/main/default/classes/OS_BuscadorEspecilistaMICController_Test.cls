@isTest
public class OS_BuscadorEspecilistaMICController_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioResponsable = OS_Usuarios.usuarioResponsable();

        OS_Cartera__c cartera = new OS_Cartera__c();
        cartera.Name = 'especialista test';
        cartera.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OS_Cartera__c', 'OS_Especialista_MIC');
        insert cartera;

        Account cuenta = new Account();
        cuenta.Name = 'cuenta prueba';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.OS_Premium__c = true;
        cuenta.OS_Especialista_MIC__c = cartera.Id;
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'servicio.test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Account cuenta2 = new Account();
        cuenta2.Name = 'cuenta prueba2';
        cuenta2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta2.OS_Premium__c = true;
        insert cuenta2;

        Account cuenta3 = new Account();
        cuenta3.Name = 'cuenta prueba3';
        cuenta3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta3.OS_Premium__c = true;
        cuenta.OS_Especialista_MIC__c = cartera.Id;
        insert cuenta3;

        Contact contacto2 = new Contact();
        contacto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto2.Email = 'servicio.test2@test3.com';
        contacto2.FirstName = 'Nombre2';
        contacto2.LastName = 'Apellido2';
        contacto2.AccountId = cuenta2.Id;
        insert contacto2;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' AND Profile.Name = 'OS_Responsable' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuenta2.Id;
        acshare2.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' AND Profile.Name = 'OS_Responsable' LIMIT 1].Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        insert acshare2;
        
        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuenta3.Id;
        acshare3.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' AND Profile.Name = 'OS_Responsable' LIMIT 1].Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        insert acshare3;
    }
    
    @isTest
    public static void asociar() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' AND Profile.Name = 'OS_Responsable' LIMIT 1];
        
        Account cuenta = [SELECT Id, Name, OS_Especialista_MIC__c, OS_Modificacion_Campos_COPS__c FROM Account WHERE Name = 'cuenta prueba' LIMIT 1];
        Account cuenta2 = [SELECT Id, Name, OS_Especialista_MIC__c, OS_Modificacion_Campos_COPS__c FROM Account WHERE Name = 'cuenta prueba2' LIMIT 1];
        Account cuenta3 = [SELECT Id, Name, OS_Especialista_MIC__c, OS_Modificacion_Campos_COPS__c FROM Account WHERE Name = 'cuenta prueba3' LIMIT 1];
        OS_Cartera__c cartera = [SELECT Id, Name FROM OS_Cartera__c WHERE Name = 'especialista test' LIMIT 1];
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_BuscadorEspecilistaMICController.asociar(new List<Account>{cuenta2, cuenta3}, String.valueOf(cartera.Id));
            Test.stopTest();

        	Account cuentaCarteraEliminada = [SELECT OS_Especialista_MIC__c, OS_Modificacion_Campos_COPS__c FROM Account WHERE Name = 'cuenta prueba' LIMIT 1];
        	Account cuentaCarteraIncluida = [SELECT OS_Especialista_MIC__c, OS_Modificacion_Campos_COPS__c FROM Account WHERE Name = 'cuenta prueba2' LIMIT 1];

            System.assertEquals(cuentaCarteraEliminada.OS_Modificacion_Campos_COPS__c, false,'no se eliminó correctamente la cartera del usuario anterior');
            System.assertEquals(cuentaCarteraEliminada.OS_Especialista_MIC__c, null,'no se eliminó correctamente la cartera del usuario anterior');

            System.assertEquals(cuentaCarteraIncluida.OS_Modificacion_Campos_COPS__c, false,'no se añadió correctamente la cartera del usuario nuevo');
            System.assertEquals(cuentaCarteraIncluida.OS_Especialista_MIC__c, String.valueOf(cartera.Id),'no se añadió correctamente la cartera del usuario nuevo');
        }
    }
    
    @isTest
    public static void searchAccounts() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' AND Profile.Name = 'OS_Responsable' LIMIT 1];
        
        Account cuenta = [SELECT Id, Name, OS_Especialista_MIC__c FROM Account WHERE Name = 'cuenta prueba' LIMIT 1];
      
        System.runAs (usuarioOperador) {
            Test.startTest();
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = cuenta.Id;
            Test.setFixedSearchResults(fixedSearchResults);

            List<Account> resultadosBusqueda = OS_BuscadorEspecilistaMICController.searchAccounts(String.valueOf(cuenta.Name));
            Test.stopTest();

            System.assertEquals(resultadosBusqueda[0].Name, cuenta.Name,'no coinciden los datos con el del usuario que buscamos');
            System.assertEquals(resultadosBusqueda[0].Id, cuenta.Id,'no coinciden los datos con el del usuario que buscamos');
        }
    }
    
    @isTest
    public static void cargarDatos() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' AND Profile.Name = 'OS_Responsable' LIMIT 1];
        
        Account cuenta = [SELECT Id, Name FROM Account WHERE Name = 'cuenta prueba' LIMIT 1];
        OS_Cartera__c cartera = [SELECT Id, Name FROM OS_Cartera__c WHERE Name = 'especialista test' LIMIT 1];
      
        System.runAs (usuarioOperador) {
            Test.startTest();
            List<Account> resultadoBusqueda = OS_BuscadorEspecilistaMICController.cargarDatos(String.valueOf(cartera.Id));
            Test.stopTest();

            System.assertEquals(resultadoBusqueda[0].Name, cuenta.Name,'no coincide el nombre con el del usuario que buscamos');
            System.assertEquals(resultadoBusqueda[0].Id, cuenta.Id,'no coincide la id con el del usuario que buscamos');
        }
    }
}