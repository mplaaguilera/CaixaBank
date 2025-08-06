@IsTest
public with sharing class SAC_LCMP_BusquedaCliente_Test {
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        User usuarioSACAdmin;
        User usuarioAdmin;
        List<User> listaUsuarios = new List<User>();

        //Usuario Admin
        usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        listaUsuarios.add(usuarioAdmin); 
        
        // Usuario SAC General
        usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
        listaUsuarios.add(usuarioGeneral);

        //Usuario SAC Admin
        usuarioSACAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioSACAdmin.Username = 'usertestadmin@test.com.testSetup';      
        listaUsuarios.add(usuarioSACAdmin);

        SAC_DatabaseDML.insertListDML(listaUsuarios, false);
        //Database.insert(listaUsuarios);

        System.runAs(usuarioAdmin) {
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
            //Database.insert(permiSetAssi);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioSACAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            SAC_DatabaseDML.insertDML(permiSetAssiAdmin, false);
            //Database.insert(permiSetAssiAdmin);
        }

        // Crear cuentas
		Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(5);
        cuentas[0].name = 'Test01';
        cuentas[0].CC_Numero_Documento__c = '12345678Z';
        cuentas[0].CC_NumPerso__c = '99999991';
        cuentas[0].RecordTypeId = recordTypeIdCliente; 
        cuentas[0].CC_TipoPersona__c = 'J';
        cuentas[1].name = 'Test02';
        cuentas[1].CC_Numero_Documento__c = '09881783V';
        cuentas[1].CC_NumPerso__c = '99999992';
        cuentas[2].name = 'Test03';
        cuentas[2].CC_Numero_Documento__c = '06898789P';
        cuentas[2].CC_NumPerso__c = '99999993';
        cuentas[3].name = 'Test05';
        cuentas[3].CC_Numero_Documento__c = '71234771E';
        cuentas[4].name = 'Test07';
        cuentas[4].CC_Numero_Documento__c = '15197951B';    
        SAC_DatabaseDML.insertListDML(cuentas, false);                               
        //Database.insert(cuentas);
        
    
        // Crear contactos
        List<Contact> contactos = new List<Contact>();
        Contact contacto1 = SAC_TestDataFactory.crearContacto(1,cuentas[0].id)[0];
        Contact contacto2 = SAC_TestDataFactory.crearContacto(1,cuentas[1].id)[0];
        Contact contacto3 = SAC_TestDataFactory.crearContacto(1,cuentas[2].id)[0];
        Contact contacto4 = SAC_TestDataFactory.crearContacto(1,null)[0];
        Contact contacto5 = SAC_TestDataFactory.crearContacto(1,null)[0];
        contacto1.LastName = 'Test01';
        contacto1.CC_NumPerso__c = '99999991';
        contacto2.LastName = 'Test02';
        contacto2.CC_NumPerso__c = '99999992';
        contacto3.LastName = 'Test03';
        contacto4.LastName = 'Test04';
        contacto5.LastName = 'Test06';
        contactos.add(contacto1);
        contactos.add(contacto2);
        contactos.add(contacto3);
        contactos.add(contacto4);
        contactos.add(contacto5);   
        SAC_DatabaseDML.insertListDML(contactos, false);                      
        //Database.insert(contactos);
    
        // Crear casos
        List<Case> reclamaciones = new List<Case>();
        // Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test01');
        camposRecl.put('Description', 'Prueba2');
        camposRecl.put('Status', 'Activo');
        camposRecl.put('Origin', 'Comentarios Stores');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl.put('AccountId', cuentas[0].id);
        camposRecl.put('ContactId', contacto1.id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        reclamaciones.add(reclamacion);

        // Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'Test02');
        camposRecl2.put('Description', 'Prueba3');
        camposRecl2.put('Status', 'Activo');
        camposRecl2.put('Origin', 'Comentarios Stores');
        camposRecl2.put('CC_Idioma__c', 'es');
        camposRecl2.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl2.put('AccountId', cuentas[1].id);
        camposRecl2.put('ContactId', contacto2.id);

        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        reclamaciones.add(reclamacion2);

        // Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'Test03');
        camposRecl3.put('Description', 'Prueba4');
        camposRecl3.put('Status', 'Activo');
        camposRecl3.put('Origin', 'Comentarios Stores');
        camposRecl3.put('CC_Idioma__c', 'es');
        camposRecl3.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl3.put('AccountId', cuentas[2].id);

        Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        reclamaciones.add(reclamacion3);

        // Reclamacion 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'Test04');
        camposRecl4.put('Description', 'Prueba5');
        camposRecl4.put('Status', 'Activo');
        camposRecl4.put('Origin', 'Comentarios Stores');
        camposRecl4.put('CC_Idioma__c', 'es');
        camposRecl4.put('CC_Tipo_Cliente__c', 'Cliente');

        Case reclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl4);
        reclamaciones.add(reclamacion4);

        // Reclamacion 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'Test05');
        camposRecl5.put('Description', 'Prueba6');
        camposRecl5.put('Status', 'Activo');
        camposRecl5.put('Origin', 'Comentarios Stores');
        camposRecl5.put('CC_Idioma__c', 'es');
        camposRecl5.put('CC_Tipo_Cliente__c', 'Cliente');

        Case reclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl5);
        reclamaciones.add(reclamacion5);

        // Reclamacion 6
        Map<String, Object> camposRecl6 = new Map<String, Object>();
        camposRecl6.put('Subject', 'Test06');
        camposRecl6.put('Description', 'Prueba7');
        camposRecl6.put('Status', 'Activo');
        camposRecl6.put('Origin', 'Comentarios Stores');
        camposRecl6.put('CC_Idioma__c', 'es');
        camposRecl6.put('CC_Tipo_Cliente__c', 'Cliente');

        Case reclamacion6 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl6);
        reclamaciones.add(reclamacion6);

        // Reclamacion 7
        Map<String, Object> camposRecl7 = new Map<String, Object>();
        camposRecl7.put('Subject', 'Test07');
        camposRecl7.put('Description', 'Prueba');
        camposRecl7.put('Status', 'Activo');
        camposRecl7.put('Origin', 'Comentarios Stores');
        camposRecl7.put('CC_Idioma__c', 'es');
        camposRecl7.put('CC_Tipo_Cliente__c', 'Cliente');

        Case reclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl7);
        reclamaciones.add(reclamacion7);
        
        SAC_DatabaseDML.insertListDML(reclamaciones, false); 
        //Database.insert(reclamaciones);

        
        // Crear canal comunicación.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '99999991';
        c1.CC_ContactoId__c = contacto1.Id;
        c1.CC_CuentaId__c = cuentas[0].Id;
        c1.CC_Telefono__c = '938500000';
        c1.RecordTypeId = sRecordType1;
        SAC_DatabaseDML.insertDML(c1, false);
        //Database.insert(c1);

        // Alta de datos para la prueba
        Id recordTypeIdContrato = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Contrato').getRecordTypeId();
        Id recordTypeIdRepresentante = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        
        CC_Representante_Contrato__c representante = new CC_Representante_Contrato__c();
        representante.RecordTypeId = recordTypeIdRepresentante;
        representante.CC_ClienteRepresentante__c = cuentas[0].Id;
        SAC_DatabaseDML.insertDML(representante, false);
        //Database.insert(representante);

        CC_Representante_Contrato__c contrato = new CC_Representante_Contrato__c();
        contrato.RecordTypeId = recordTypeIdContrato;
        contrato.CC_ClienteContrato__c = cuentas[0].Id;
        SAC_DatabaseDML.insertDML(contrato, false);
        //Database.insert(contrato);
    }

    @isTest
    static void test01setClienteCaso01() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case oCaso;
        Contact oCont;
        Account oAcc;
        
        // Vincular contacto identificado en origen y destino.
        oCaso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test01'];
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        oAcc = [SELECT Id FROM Account WHERE Name = 'Test01'];
        oCaso.OwnerId = usuario.id;
        SAC_DatabaseDML.updateDML(oCaso, false);
        //Database.update(oCaso);
        
        System.runAs(usuario) {
            Test.startTest();
            Case pretension = new Case(
            Subject = 'Pret01',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId(),
            SAC_Reclamacion__c = oCaso.Id,
            AccountId = oAcc.id
            );
            SAC_DatabaseDML.insertDML(pretension, false);
            //Database.insert(pretension);

            SAC_LCMP_BusquedaCliente.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);
            Test.stopTest();
            System.assertEquals(oCaso.AccountId, pretension.AccountId, 'No coincide la cuenta en reclamación y pretensión.');
        }
    }
    
    @isTest
    static void test01setClienteCaso02() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
		Account oAcc;
        Contact oCont;
        Case oCaso;
        Test.startTest();
        // Vincular cuenta identificada en origen y destino.
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test02'];
        oAcc = [SELECT Id FROM Account WHERE name = 'Test02'];
        System.runAs(usuario) {
            SAC_LCMP_BusquedaCliente.setClienteCaso (oAcc.Id, 'Cuenta', oCaso.Id);
        }
        oCaso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test02'];
        System.assertEquals(oAcc.Id, oCaso.AccountId, 'No se ha asignado la cuenta al caso.');
        
        // Vincular cuenta identificada en origen y destino (empresa)
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test03'];
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test03'];
        oCaso.ContactId = oCont.Id;
        SAC_DatabaseDML.updateDML(oCaso, false);
        //Database.update(oCaso);
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        System.runAs(usuario) {
            SAC_LCMP_BusquedaCliente.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);
        }
        
        // Vincular cuenta identificada en origen (contacto sin cuenta) y destino (empresa)
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test04'];
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test04'];
        oCaso.ContactId = oCont.Id;
        SAC_DatabaseDML.updateDML(oCaso, false);
        //Database.update(oCaso);
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        System.runAs(usuario) {
            SAC_LCMP_BusquedaCliente.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);
        }
        Test.stopTest();
    }
    
    @isTest
    static void test01setClienteCaso03() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
		Account oAcc;
        Contact oCont;
        Case oCaso;
        Test.startTest();
        // Vincular cuenta identificada en origen (cuenta sin contacto) y destino (empresa)
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test05'];
        oAcc = [SELECT Id FROM Account WHERE Name = 'Test05'];
        oCaso.AccountId = oAcc.Id;
        SAC_DatabaseDML.updateDML(oCaso, false);
        //Database.update(oCaso);
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        System.runAs(usuario){
            SAC_LCMP_BusquedaCliente.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);
            System.assertEquals(oAcc.Id, oCaso.AccountId, 'No se ha asignado la cuenta al caso.');
        }
        
        // Vincular cuenta identificada en origen (contacto sin cuenta) y destino (particular)
        oCaso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test06'];
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test06'];
        oCaso.ContactId = oCont.Id;
        SAC_DatabaseDML.updateDML(oCaso, false);
        //Database.update(oCaso);
        oAcc = [SELECT Id FROM Account WHERE Name = 'Test01'];
        System.runAs(usuario){
            SAC_LCMP_BusquedaCliente.setClienteCaso (oAcc.Id, 'Cuenta', oCaso.Id);
        }
        //oCaso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test02'];
        
        // Vincular cuenta identificada en origen (cuenta sin identificar) y destino (particular)
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test07'];
        oAcc = [SELECT Id FROM Account WHERE Name = 'Test07'];
        oCaso.AccountId = oAcc.Id;
        SAC_DatabaseDML.updateDML(oCaso, false);
        //Database.update(oCaso);
        oAcc = [SELECT Id FROM Account WHERE Name = 'Test01'];
        System.runAs(usuario){
            SAC_LCMP_BusquedaCliente.setClienteCaso (oAcc.Id, 'Cuenta', oCaso.Id);
        }
        Test.stopTest();
    }
    
    @isTest
    static void test02getIdentidad() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Account cuenta = [SELECT Id FROM Account WHERE name = 'Test01' LIMIT 1];
        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());
        
        Map<String,Object> oData = SAC_LCMP_BusquedaCliente.getIdentidad ('DOC', '12345678Z');
        
        Test.stopTest();
        
        System.assertEquals(1, ((List<Account>)oData.get('CUENTAS')).size(), 'Hay un error');
        
        System.runAs(usuario){
            // Recuperar los contactos de la cuenta obtenida.
            List<Object> oListaCont = SAC_LCMP_BusquedaCliente.getRepresentantesOrContactosCliente(cuenta.Id);
            System.assertEquals(oListaCont.size(), 1, 'Hay un error');
        }
        
    }
    
    @isTest
    static void test03getIdentidad() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Account oAcc = [SELECT Id FROM Account WHERE Name = 'Test01'];
        Contact oCon = [SELECT Id FROM Contact WHERE LastName = 'Test01'];
        oCon.Account = oAcc;
        SAC_DatabaseDML.updateDML(oCon, false);
        //Database.update(oCon);
        CC_Canal_Com__c canal = [SELECT Id, CC_ContactoId__c, CC_CuentaId__c, CC_Telefono__c FROM CC_Canal_Com__c WHERE CC_Telefono__c = '938500000' LIMIT 1];

        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());
        
        System.runAs(usuario){
            Map<String,Object> oData = SAC_LCMP_BusquedaCliente.getIdentidad ('TEL', '938500000');
            System.assertEquals(1, ((List<Account>)oData.get('CUENTAS')).size(), 'Hay un error');
        }
        Test.stopTest();   
    }
    
    @isTest
    static void test04controlVacios() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Test.startTest();
        // Control de datos vacíos.
        System.runAs(usuario){
            Map<String,Object> oData = SAC_LCMP_BusquedaCliente.getIdentidad ('', '');
            System.assertEquals(oData, null, 'Mensaje de error');
        }
        System.runAs(usuario){
            List<Object> oListaCont = SAC_LCMP_BusquedaCliente.getRepresentantesOrContactosCliente('');
            System.assertEquals(oListaCont, null, 'Mensaje de error');
        }
        Test.stopTest();
    }

    @isTest
    static void test05getIdentidadSalesforce() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(usuario){
            Map<String,Object> oData = SAC_LCMP_BusquedaCliente.getIdentidad ('SF', '12345678Z');
            System.assertEquals(oData.size(), 1, 'Mensaje de error');
        }
        Test.stopTest(); 
    }
    
    @isTest
    public static void getContratosCliente() {
        Id recordTypeIdRepresentante = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Test01' LIMIT 1];
        CC_Representante_Contrato__c representante = [SELECT Id, CC_ClienteRepresentante__c FROM CC_Representante_Contrato__c WHERE RecordTypeId = :recordTypeIdRepresentante];

        // Ejecución de la prueba
        Test.startTest();
        System.runAs(usuario){
            List<SAC_LCMP_BusquedaCliente.ContratoPicklistItemWrapper> contratosCliente = SAC_LCMP_BusquedaCliente.getContratosCliente(contacto.Id, 'Contacto');
            List<SAC_LCMP_BusquedaCliente.ContratoPicklistItemWrapper> representantesCliente = SAC_LCMP_BusquedaCliente.getContratosCliente(representante.Id, 'Representante');
            Boolean casosRepetidos = SAC_LCMP_BusquedaCliente.comprobarMultiplesCasosCliente(null, null);
            System.assertNotEquals(null, contratosCliente, 'No se ha devuelto ningun contrato.');
            System.assertNotEquals(null, representantesCliente, 'No se ha devuelto ningun contrato.');
        }
        Test.stopTest();
    }

    @isTest
    static void insertarPermisosAccountTest(){
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Test01' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        Test.startTest();
        System.runAs(usuario){
            SAC_LCMP_BusquedaCliente.insertarPermisosAccount(cuenta.Id);
        }

        AccountShare accShare = [SELECT Id FROM AccountShare WHERE AccountId = :cuenta.Id AND UserOrGroupId =: usuario.id LIMIT 1];
        System.assertNotEquals(null, accShare, 'No se ha podido insertar el permiso');
        Test.stopTest();
    }

    @isTest
    static void insertarNoCliTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertestadmin@test.com.testSetup' AND isActive = true Limit 1];
        Id idAccount;
       
        Test.startTest();
        System.runAs(usuario){
            idAccount = SAC_LCMP_BusquedaCliente.crearNoCli('cliente', 'prueba', 'test@test.com', /*Date.newInstance(2016, 12, 9),*/ '674776789', 'DNI', '62560354D', /*'es', 'V',*/ 'prueba', 'prueba', 'prueba', 'prueba', 'prueba');
        }  

        List<Account> cuenta = [SELECT id, FirstName, LastName FROM Account WHERE FirstName = 'cliente' AND LastName = 'prueba'];
        System.assertEquals(cuenta[0].id, idAccount, 'no se ha insertado el registro');
        Test.stopTest();
    }
    
    @isTest
    static void getPickListValuesIntoListIdiomaTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(usuario){
            List<SAC_LCMP_BusquedaCliente.plantillasWrapper> pickListValuesList = SAC_LCMP_BusquedaCliente.getPickListValuesIntoListIdioma();
            System.assertNotEquals(null, pickListValuesList, 'No se han devuelto los valores.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getPickListValuesIntoListTipoCodigoTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(usuario){
            List<SAC_LCMP_BusquedaCliente.plantillasWrapper> pickListValuesList = SAC_LCMP_BusquedaCliente.getPickListValuesIntoListTipoCodigo();
            System.assertNotEquals(null, pickListValuesList, 'No se han devuelto los valores.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void getPickListValuesIntoListSexoTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(usuario){
            List<SAC_LCMP_BusquedaCliente.plantillasWrapper> pickListValuesList = SAC_LCMP_BusquedaCliente.getPickListValuesIntoListSexo();
            System.assertNotEquals(null, pickListValuesList, 'No se han devuelto los valores.');
        }
        Test.stopTest();
    }  

    @isTest
    static void crearReclamanteSecundarioTest1() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso;
        Contact cont;
        
        
        caso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test01'];
        cont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        caso.OwnerId = usuario.id;
        SAC_DatabaseDML.updateDML(caso, false);
        //Database.update(caso);
        
        System.runAs(usuario) {
            Test.startTest();
            SAC_LCMP_BusquedaCliente.crearReclamanteSecundario(cont.Id, 'Contacto', caso.Id);
            Test.stopTest();
            System.assertNotEquals(caso.AccountId, null, 'No se ha creado el reclamante secundario');
        }
    }
    @isTest
    static void crearReclamanteSecundarioTest2() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso;
        Contact cont;
        
        
        caso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test01'];
        cont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        caso.OwnerId = usuario.id;
        SAC_DatabaseDML.updateDML(caso, false);
        //Database.update(caso);
        
        System.runAs(usuario) {
            Test.startTest();
            SAC_LCMP_BusquedaCliente.crearReclamanteSecundario(cont.Id, 'Representante', caso.Id);
            Test.stopTest();
            System.assertNotEquals(caso.AccountId, null, 'No se ha creado el reclamante secundario');
        }
    }

    @isTest
    static void getEsPropietarioCasoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso;

        caso = [SELECT Id FROM Case WHERE Subject = 'Test01'];
        caso.OwnerId = usuario.id;
        SAC_DatabaseDML.updateDML(caso, false);
        //Database.update(caso);
        Boolean test;

        System.runAs(usuario){
            test = SAC_LCMP_BusquedaCliente.getEsPropietarioCaso(caso.Id);
            System.assertNotEquals(test, false, 'Hay un error');
        }
        
    }
    @isTest
    static void getActualizarIdentificacionTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso;
        Case newcase;
        Boolean noIdentificado = true;

        caso = [SELECT Id, CC_No_Identificado__c FROM Case WHERE Subject = 'Test01'];
        
        System.runAs(usuario){
        
            SAC_LCMP_BusquedaCliente.actualizarIdentificacion(caso.Id, noIdentificado, 'Case');
            
            System.assertNotEquals(caso.CC_No_Identificado__c, null, 'Hay un error');
        }
        
    }

    @isTest
    static void getContactoAsocTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Account cuenta = [SELECT id FROM Account WHERE name = 'Test01' ];
        String retorno;
        
        System.runAs(usuario){
        
            retorno = SAC_LCMP_BusquedaCliente.getContactoAsoc(cuenta.Id);
            
            System.assertNotEquals(retorno, null, 'Hay un error');
        }
        
    }

    @isTest
    static void datosCasoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Case caso = [SELECT Id, CC_No_Identificado__c FROM Case WHERE Subject = 'Test01'];
        List<Case> listaCaso = new List<Case>();
        
        System.runAs(usuario){
        
            listaCaso = SAC_LCMP_BusquedaCliente.datosCaso(caso.id);
            
            System.assertNotEquals(listaCaso.size(), null, 'Hay un error');
        }
        
    }

    @isTest
    static void datosRegistroTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Case caso = [SELECT Id, CC_No_Identificado__c FROM Case WHERE Subject = 'Test01'];
        SObject retorno;
        System.runAs(usuario){
        
            retorno = SAC_LCMP_BusquedaCliente.datosRegistro(caso.id);
            
            System.assertNotEquals(retorno.Id, null, 'Hay un error');
        }
        
    }
    @isTest
    static void getRecTypeClienteTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        string test;
        System.runAs(usuario){
        
            test = SAC_LCMP_BusquedaCliente.getRecTypeCliente();
            
            System.assertNotEquals(test, null, 'Hay un error');
        }
        
    }

    @isTest
    static void actualizarReclamanteNoClienteTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test01'];
        Account cuenta = [SELECT id FROM Account WHERE name = 'Test01' ];
       
        System.runAs(usuario){
        
            SAC_LCMP_BusquedaCliente.actualizarReclamanteNoCliente(caso.id, cuenta.id);
            
            System.assertNotEquals(caso.id, null, 'Hay un error');
        }
        
    }

    
    @isTest
    static void comprobarCartacteristicasClienteTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Account cuenta = [SELECT id FROM Account WHERE name = 'Test01' ];

        List<CC_Caracteristica_Detalle__c> caracteristicasCliente = new List<CC_Caracteristica_Detalle__c>();
       
        System.runAs(usuario){
        
            caracteristicasCliente =  SAC_LCMP_BusquedaCliente.comprobarCaracteristicasCliente(cuenta.id);
            
            System.assertNotEquals(caracteristicasCliente, null, 'Hay un error');
        }
        
    }
}