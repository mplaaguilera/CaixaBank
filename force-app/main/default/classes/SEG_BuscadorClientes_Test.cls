@isTest
public with sharing class SEG_BuscadorClientes_Test {
    @testSetup
    static void datosIniciales ()
    { 
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;

        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG2.Name = 'Empresa segmentos 2';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG2';
        cuentaSEG2.CC_Numero_Documento__c = '22222222J';
        insert cuentaSEG2;

        Account cuentaSEG3 = new Account();
        cuentaSEG3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG3.Name = 'Empresa segmentos 3';
        cuentaSEG3.SEG_DominioMail__c = '@cuentaSEG3';
        cuentaSEG3.CC_Numero_Documento__c = '33333333J';
        insert cuentaSEG3;

        Account cuentaALF1 = new Account();
        cuentaALF1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaALF1.Name = 'Empresa ALF 1';
        cuentaALF1.SEG_DominioMail__c = '@cuentaALF1';
        cuentaALF1.CC_Numero_Documento__c = '11111111H';
        cuentaALF1.CC_NumPerso__c = '00000001';
        insert cuentaALF1;

        Account cuentaALF2 = new Account();
        cuentaALF2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaALF2.Name = 'Empresa ALF 2';
        cuentaALF2.SEG_DominioMail__c = '';
        cuentaALF2.CC_Numero_Documento__c = '22222222J';
        cuentaALF2.CC_NumPerso__c = '00000002';
        insert cuentaALF2;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        insert contactoSEG1;

        Contact contactoSEG2 = new Contact();
        contactoSEG2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG2.LastName = 'Contacto SEG 2';
        contactoSEG2.AccountId = cuentaSEG2.Id;
        insert contactoSEG2;

        Contact contactoSEG3 = new Contact();
        contactoSEG3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG3.LastName = 'Contacto SEG 1.1';
        contactoSEG3.AccountId = cuentaSEG1.Id;
        insert contactoSEG3;

        Contact contactoSEG4 = new Contact();
        contactoSEG4.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG4.LastName = 'Contacto SEG 2.1';
        contactoSEG4.AccountId = cuentaSEG2.Id;
        insert contactoSEG4;

        // Crear contacto para cuenta ALF.
        Contact contactoALF1 = new Contact();
        contactoALF1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoALF1.LastName = 'Contacto ALF 1';
        contactoALF1.AccountId = cuentaALF1.Id;
        insert contactoALF1;

        // Crear representante para cuenta ALF.
        Contact contactoRep1 = new Contact();
        contactoRep1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        contactoRep1.LastName = 'Representante ALF 1';
        //contactoRep1.AccountId = cuentaALF1.Id; --> No lo utilizamos por ahora.
        contactoRep1.CC_CuentaRepresentada__c = cuentaALF1.Id;
        insert contactoRep1;

        // Crear contactos relacionados entre las cuentas de segmentos
        List<AccountContactRelation> relacionContactos = new List<AccountContactRelation>();
        
        AccountContactRelation relacionSEG1 = new AccountContactRelation();
        relacionSEG1.AccountId = cuentaSEG1.Id;
        relacionSEG1.ContactId = contactoSEG4.Id;
        relacionContactos.add(relacionSEG1);

        AccountContactRelation relacionSEG2 = new AccountContactRelation();
        relacionSEG2.AccountId = cuentaSEG2.Id;
        relacionSEG2.ContactId = contactoSEG3.Id;
        relacionSEG2.SEG_Cargos_en_la_empresa__c = 'ACCOUNTANT';
        relacionContactos.add(relacionSEG2);

        AccountContactRelation relacionSEG3 = new AccountContactRelation();
        relacionSEG3.AccountId = cuentaSEG1.Id;
        relacionSEG3.ContactId = contactoALF1.Id;
        relacionContactos.add(relacionSEG3);

        AccountContactRelation relacionSEG4 = new AccountContactRelation();
        relacionSEG4.AccountId = cuentaALF1.Id;
        relacionSEG4.ContactId = contactoSEG1.Id;
        relacionContactos.add(relacionSEG4);

        insert relacionContactos;

        // Crear canales de comunicación.
        List<CC_Canal_Com__c> listaCanales = new List<CC_Canal_Com__c>();

        CC_Canal_Com__c canal1 = new CC_Canal_Com__c();
        canal1.CC_CuentaId__c = cuentaSEG1.Id;
        canal1.CC_ContactoId__c = contactoSEG1.Id;
        canal1.CC_Email__c = 'contseg1@test.es';
        canal1.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        listaCanales.add(canal1);

        CC_Canal_Com__c canal2 = new CC_Canal_Com__c();
        canal2.CC_CuentaId__c = cuentaSEG1.Id;
        canal2.CC_Email__c = 'accountSeg1@test.es';
        canal2.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        listaCanales.add(canal2);

        CC_Canal_Com__c canal3 = new CC_Canal_Com__c();
        canal3.CC_ContactoId__c = contactoSEG1.Id;
        canal3.CC_Email__c = 'contactSeg1@test.es';
        canal3.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        listaCanales.add(canal3);

        CC_Canal_Com__c canal4 = new CC_Canal_Com__c();
        canal4.CC_CuentaId__c = cuentaSEG3.Id;
        canal4.CC_Email__c = 'contactSeg1@test.es';
        canal4.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        listaCanales.add(canal4);

        insert listaCanales;

        // Crear casos de los clientes.
        List<Case> listadoCasos = new List<Case>();

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.Subject = 'test 1';
        listadoCasos.add(caso1);

        Case caso11 = new Case();
        caso11.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso11.AccountId = cuentaSEG1.Id;
        caso11.ContactId = contactoSEG1.Id;
        caso11.Subject = 'test 1 caso11';
        listadoCasos.add(caso11);

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.AccountId = cuentaSEG2.Id;
        caso2.ContactId = contactoSEG2.Id;
        caso2.Subject = 'test 1';
        listadoCasos.add(caso2);

        insert listadoCasos;
    }


    @isTest
    public static void datosRegistroTest()
    {
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 1'];

        //Se ejecuta el batch
		Test.startTest();
            SEG_BuscadorClientes.infoCasoPermissionSets permisos = SEG_BuscadorClientes.datosRegistro(listaCasos[0].Id);
        Test.stopTest();

        System.assert(listaCasos.size() > 0);
        System.assert(permisos != null);
    } 

    @isTest
    public static void getEsPropietarioObjetoTest()
    {
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 1'];

        //Se ejecuta el batch
		Test.startTest();
        	Boolean esPropietario = SEG_BuscadorClientes.getEsPropietarioObjeto(listaCasos[0].Id);
        Test.stopTest();

        System.assert(listaCasos.size() > 0);
        System.assert(esPropietario);
    } 

    @isTest
    public static void getIdentidadTest()
    {
        List<Id> resultadosSOSLTest = new List<Id>();
        resultadosSOSLTest.add([SELECT Id FROM Account WHERE Name = 'Empresa segmentos'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Account WHERE Name = 'Empresa segmentos 2'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Account WHERE Name = 'Empresa ALF 1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Account WHERE Name = 'Empresa ALF 2'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 2'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1.1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 2.1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto ALF 1'].Id);

        List<CC_Canal_Com__c> canales = [SELECT Id FROM CC_Canal_Com__c LIMIT 10];
        for (CC_Canal_Com__c canal : canales)
        {
            resultadosSOSLTest.add(canal.Id);
        }

        //Se ejecuta el batch
        Test.startTest();
            
            Test.setFixedSearchResults(resultadosSOSLTest);
            Map<String, Object> busqueda1 = SEG_BuscadorClientes.getIdentidad('','SEG','','');
        Test.stopTest();

        System.assert((String)busqueda1.get('RESULTADO')=='1');
    } 

    @isTest
    public static void getIdentidadTest2()
    {
        List<Id> resultadosSOSLTest = new List<Id>();
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 2'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1.1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 2.1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto ALF 1'].Id);

        //Se ejecuta el batch
        Test.startTest();
            
            Test.setFixedSearchResults(resultadosSOSLTest);
            Map<String, Object> busqueda1 = SEG_BuscadorClientes.getIdentidad('','SEG','','');
        Test.stopTest();

        System.assert((String)busqueda1.get('RESULTADO')=='1');
    }
    
    @isTest
    public static void getIdentidadTest3()
    {
        ID cuenta = [SELECT Id FROM Account WHERE Name = 'Empresa segmentos'].Id;

        //Se ejecuta el batch
        Test.startTest();
            
            Map<String, Object> busqueda1 = SEG_BuscadorClientes.getIdentidad(cuenta,'SEG','','');
        Test.stopTest();

        System.assert((String)busqueda1.get('RESULTADO')=='1');
    } 

    @isTest
    public static void getIdentidadTest4()
    {
        List<Id> resultadosSOSLTest = new List<Id>();
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 2'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1.1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 2.1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Contacto ALF 1'].Id);
        resultadosSOSLTest.add([SELECT Id FROM Contact WHERE LastName = 'Representante ALF 1'].Id);

        //Se ejecuta el batch
        Test.startTest();
            
            Test.setFixedSearchResults(resultadosSOSLTest);
            Map<String, Object> busqueda1 = SEG_BuscadorClientes.getIdentidad('','SEG','Cargo','Administrador');
        Test.stopTest();

        System.assert((String)busqueda1.get('RESULTADO')=='1');
    }

    @isTest
    public static void actualizarIdentificacionTest()
    {
        ID cuenta = [SELECT Id FROM Account WHERE Name = 'Empresa segmentos'].Id;
        ID contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1.1'].Id;
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 1'];

        //Se ejecuta el batch
        Test.startTest();
            
            SEG_BuscadorClientes.actualizarIdentificacion(listaCasos[0].Id, true, 'Case');
        Test.stopTest();

        listaCasos = [SELECT Id, AccountId FROM Case WHERE Subject = 'test 1'];
        System.assert(listaCasos[0].AccountId == null);
    } 

    @isTest
    public static void setClienteContactoCasoTest()
    {
        ID cuenta = [SELECT Id FROM Account WHERE Name = 'Empresa segmentos'].Id;
        ID contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1.1'].Id;
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 1'];

        //Se ejecuta el batch
        Test.startTest();
            
            String resultado = SEG_BuscadorClientes.setClienteContactoCaso(cuenta,contacto,listaCasos[0].Id);
        Test.stopTest();

        listaCasos = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'test 1'];
        System.assert(listaCasos[0].AccountId != null);
        System.assert(listaCasos[0].ContactId != null);
    } 
    
    @isTest
    public static void actualizarClienteAlfabeticoTest()
    {
        ID cuenta = [SELECT Id FROM Account WHERE Name = 'Empresa segmentos'].Id;

        //Se ejecuta el batch
        Test.startTest();
            
            Map<String,String> resultado = SEG_BuscadorClientes.actualizarClienteAlfabetico(cuenta);
        	Map<String,String> resultado2 = SEG_BuscadorClientes.actualizarClienteAlfabetico(null);
        Test.stopTest();

        System.assert(resultado != null);
        System.assert(resultado2 != null);
        System.assert(resultado2.get('errorUser') == 'No se ha seleccionado un registro válido.');
    } 
}