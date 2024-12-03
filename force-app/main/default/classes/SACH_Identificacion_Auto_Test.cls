@isTest
public class SACH_Identificacion_Auto_Test {
    @TestSetup
    static void makeData(){
         //Usuario SAC General
		User usuarioGeneral = SACH_TestDataFactory.crearUsuarioaSACH(1)[0];      
        Database.insert(usuarioGeneral);

        // Insertar RecordTypes para Account y Contact si es necesario o asegurarse de que existen
        Id rtAccountCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');

        // Crear y insertar Account de prueba
        Account testAccount = new Account(LastName = 'Test Account',RecordTypeId = rtAccountCliente);
        insert testAccount;
        
        // Crear y insertar Contact de prueba
        Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contact', AV_NumPerso__c = '00DAC020');
        insert testContact;
    }
    
    
    @isTest
    static void identificarNUMPERSO_ContactoNoExistente_Test() {
       
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

        // Llamamos al método identificarNUMPERSO con un numperso que no existe en la base de datos
        Test.startTest();
        Contact resultado = SACH_Identificacion_Auto.identificarNUMPERSOsinCodificar('99999999');
        Test.stopTest();

        
        // Verificamos que el resultado es nulo
        System.assertEquals(null, resultado);
        }

    }

    @isTest
    static void formatearNumperso_NumeroInvalido_Test() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

        // Llamamos al método formatearNumperso con un numperso inválido
        String resultado = SACH_Identificacion_Auto.formatearNumperso('invalido');

            // Verificamos que el resultado es nulo
            System.assertEquals(null, resultado);
        }
    }

    @isTest
    public static void identificarClienteTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){


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

        //Inicio prueba
        Test.startTest();

        Map<Account, List<Contact>> mapCorreoExistente = SACH_Identificacion_Auto.identificarCliente(
            'Email',
            'correo@gmail.com'
        );
        
        Map<Account, List<Contact>> mapCorreoInexistente = SACH_Identificacion_Auto.identificarCliente(
            'Email',
            'inexistente@gmail.com'
        );
        
        Map<Account, List<Contact>> mapTelefonoExistente = SACH_Identificacion_Auto.identificarCliente(
            'Telefono',
            '973242323'
        );
        
        Map<Account, List<Contact>> mapTelefonoInexistente = SACH_Identificacion_Auto.identificarCliente(
            'Telefono',
            '666000000'
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

}