@isTest
public class OS_Identificacion_Auto_Test {

    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
    }

    @isTest
    public static void identificarClienteTest() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        //Cuentas para la prueba
        List<Account> cuentas = new List<Account>();
        Id rtAccountCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');

        Account cuentaA = new Account();
        cuentaA.RecordTypeId = rtAccountCliente;
        cuentaA.Name = 'Cuenta personal test A';
        cuentas.add(cuentaA);

        Account cuentaB = new Account();
        cuentaB.RecordTypeId = rtAccountCliente;
        cuentaB.Name = 'Cuenta personal test B';
        cuentas.add(cuentaB);
        insert cuentas;

        List<AccountShare> totalAcShare = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaA.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalAcShare.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaB.Id;
        acshare2.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalAcShare.add(acshare2);
        insert totalAcShare;
        
        //Contactos para la prueba
        List<Contact> contactos = new List<Contact>();
        Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        
        Contact contacto1 = new Contact();
        contacto1.RecordTypeId = rtContactCliente;
        contacto1.AccountId = cuentaA.Id;
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '25345569';
        contacto1.CC_Idioma__c = 'ca';
        contacto1.Email = 'correo@gmail.com';
        contacto1.Phone = '973242323';
        contactos.add(contacto1);

        Contact contacto2 = new Contact();
        contacto2.RecordTypeId = rtContactCliente;
        contacto2.AccountId = cuentaA.Id;
        contacto2.FirstName = 'Contacto2';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '26345569';
        contacto2.CC_Idioma__c = 'es';
        contacto2.Email = 'correo@gmail.com';
        contacto2.Phone = '973242323';
        contactos.add(contacto2);
        
        Contact contacto3 = new Contact();
        contacto3.RecordTypeId = rtContactCliente;
        contacto3.AccountId = cuentaB.Id;
        contacto3.FirstName = 'Contacto3';
        contacto3.LastName = '03';
        contacto3.CC_NumPerso__c = '26344159';
        contacto3.CC_Idioma__c = 'es';
        contacto3.Email = 'corre@gmail.com';
        contacto3.Phone = '973242323';
        contactos.add(contacto3);

        insert contactos;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            //Inicio prueba
            Test.startTest();
            Map<Account, List<Contact>> mapCorreoExistente = OS_Identificacion_Auto.identificarCliente(
                'Email',
                'correo@gmail.com',
                ''
            );
            
            Map<Account, List<Contact>> mapCorreoInexistente = OS_Identificacion_Auto.identificarCliente(
                'Email',
                'inexistente@gmail.com',
                ''
            );
            
            Map<Account, List<Contact>> mapTelefonoExistente = OS_Identificacion_Auto.identificarCliente(
                'Telefono',
                '973242323',
                'cliente'       //con tipologia
            );
            
            Map<Account, List<Contact>> mapTelefonoInexistente = OS_Identificacion_Auto.identificarCliente(
                'Telefono',
                '666000000',
                ''              //sin tipologia
            );
            Test.stopTest();

            //Evaluar resultados

            //Correo existente
            System.assertEquals(1, mapCorreoExistente.size(), 'Debería identificarse una única cuenta.');
            System.assertEquals(2, mapCorreoExistente.values()[0].size(), 'Deberían identificarse 2 contactos.');

            //Correo inexistente
            System.assertEquals(0, mapCorreoInexistente.size(), 'No deberían identificarse cuentas.');
            
            //Teléfono existente
            System.assertEquals(2, mapTelefonoExistente.size(), 'Deberían identificarse 2 cuentas.');
            System.assertEquals(2, mapTelefonoExistente.values()[0].size(), 'Deberían identificarse 2 contactos para la cuenta A.');
            System.assertEquals(1, mapTelefonoExistente.values()[1].size(), 'Deberían identificarse 2 contactos para la cuenta B.');
            
            //Email inexistente
            System.assertEquals(0, mapTelefonoInexistente.size(), 'No deberían identificarse cuentas.');
        }
    }

    @isTest
    public static void identificarEmpleadoTest() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        //Cuentas para la prueba
        List<Account> cuentas = new List<Account>();
        Id rtAccountCentro = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');

        Account cuentaA = new Account();
        cuentaA.RecordTypeId = rtAccountCentro;
        cuentaA.Name = 'Cuenta personal test A';
        cuentas.add(cuentaA);
        insert cuentas;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaA.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        //Contactos para la prueba
        List<Contact> contactos = new List<Contact>();
        Id rtContactEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        
        Contact contacto1 = new Contact();
        contacto1.RecordTypeId = rtContactEmpleado;
        contacto1.AccountId = cuentaA.Id;
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '25345569';
        contacto1.CC_Idioma__c = 'ca';
        contacto1.Email = 'correo@gmail.com';
        contacto1.Phone = '973242323';
        contactos.add(contacto1);

        insert contactos;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            //Inicio prueba
            Test.startTest();
            Map<Account, List<Contact>> mapCorreoExistente = OS_Identificacion_Auto.identificarCliente(
                'Telefono',
                '973242323',
                ''
            );

            Map<Account, List<Contact>> mapCorreoExistenteTipologia = OS_Identificacion_Auto.identificarCliente(
                'Telefono',
                '973242323',
                'empleado'
            );
            Test.stopTest();

            //Correo existente
            System.assertEquals(1, mapCorreoExistente.size(), 'Debería identificarse una única cuenta.');
            System.assertEquals(1, mapCorreoExistente.values()[0].size(), 'Deberían identificarse un contacto.');
        }
    }
}