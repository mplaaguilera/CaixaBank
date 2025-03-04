@IsTest
public with sharing class SAC_LCMP_BusquedaSecundaria_Test {
    
    @TestSetup
    static void makeData() {

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            // Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }

        // Crear cuentas
        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(5);
        cuentas[0].name = 'Test01';
        cuentas[0].CC_Numero_Documento__c = '12345678Z';
        cuentas[0].CC_NumPerso__c = '99999991';
        cuentas[1].name = 'Test02';
        cuentas[1].CC_Numero_Documento__c = '09881783V';
        cuentas[1].CC_NumPerso__c = '99999992';
        cuentas[2].name = 'Test03';
        cuentas[2].CC_Numero_Documento__c = '06898789P';
        cuentas[2].CC_NumPerso__c = '99999993';
        cuentas[3].name = 'Test05';
        cuentas[3].CC_Numero_Documento__c = '71234771E';
        cuentas[3].CC_TipoPersona__c = 'F';
        cuentas[4].name = 'Test07';
        cuentas[4].CC_Numero_Documento__c = '15197951B'; 
        cuentas[4].CC_TipoPersona__c = 'J';
        cuentas[4].CC_NumPerso__c = '99999997';                                      
        SAC_DatabaseDML.insertListDML(cuentas, false);
        
        // Crear contactos
        List<Contact> contactos = new List<Contact>();
        Contact contacto1 = SAC_TestDataFactory.crearContacto(1,cuentas[0].id)[0];
        Contact contacto2 = SAC_TestDataFactory.crearContacto(1,cuentas[1].id)[0];
        Contact contacto3 = SAC_TestDataFactory.crearContacto(1,cuentas[2].id)[0];
        Contact contacto4 = SAC_TestDataFactory.crearContacto(1,cuentas[4].id)[0];
        Contact contacto5 = SAC_TestDataFactory.crearContacto(1,null)[0];
        contacto1.LastName = 'Test01';
        contacto1.CC_NumPerso__c = '99999991';
        contacto1.CC_CuentaRepresentada__c = cuentas[0].id;
        contacto2.LastName = 'Test02';
        contacto2.CC_NumPerso__c = '99999992';
        contacto3.LastName = 'Test03';
        contacto4.LastName = 'Test04';
        contacto4.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId(); 
        contacto4.CC_CuentaRepresentada__c = cuentas[4].id;
        contacto5.LastName = 'Test06';
        contactos.add(contacto1);
        contactos.add(contacto2);
        contactos.add(contacto3);
        contactos.add(contacto4);
        contactos.add(contacto5);                       
        SAC_DatabaseDML.insertListDML(contactos, false);
    
        // Crear casos
        List<Case> reclamaciones = new List<Case>();
        // Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test01');
        camposRecl.put('Description', 'Prueba2');
        camposRecl.put('Status', 'Activo');
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('CC_Tipo_Contacto__c', 'Consulta');
        camposRecl.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl.put('CC_Canal_Procedencia__c', 'Junta Andalucia');
        camposRecl.put('AccountId', cuentas[0].id);
        camposRecl.put('ContactId', contacto1.id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        reclamaciones.add(reclamacion);

        // Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'Test02');
        camposRecl2.put('Description', 'Prueba3');
        camposRecl2.put('Status', 'Activo');
        camposRecl2.put('Origin', 'Otros');
        camposRecl2.put('CC_Idioma__c', 'es');
        camposRecl2.put('CC_Tipo_Contacto__c', 'Consulta');
        camposRecl2.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl2.put('CC_Canal_Procedencia__c', 'Junta Andalucia');
        camposRecl2.put('AccountId', cuentas[1].id);
        camposRecl2.put('ContactId', contacto2.id);

        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        reclamaciones.add(reclamacion2);

        // Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'Test03');
        camposRecl3.put('Description', 'Prueba4');
        camposRecl3.put('Status', 'Activo');
        camposRecl3.put('Origin', 'Otros');
        camposRecl3.put('CC_Idioma__c', 'es');
        camposRecl3.put('CC_Tipo_Contacto__c', 'Consulta');
        camposRecl3.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl3.put('CC_Canal_Procedencia__c', 'Junta Andalucia');
        camposRecl3.put('AccountId', cuentas[2].id);

        Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        reclamaciones.add(reclamacion3);

        // Reclamacion 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'Test04');
        camposRecl4.put('Description', 'Prueba5');
        camposRecl4.put('Status', 'Activo');
        camposRecl4.put('Origin', 'Otros');
        camposRecl4.put('CC_Idioma__c', 'es');
        camposRecl4.put('CC_Tipo_Contacto__c', 'Consulta');
        camposRecl4.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl4.put('CC_Canal_Procedencia__c', 'Junta Andalucia');
        camposRecl4.put('AccountId', cuentas[2].id);

        Case reclamacion4 = SAC_TestDataFactory.crearCaso('Pretension',camposRecl4);
        reclamaciones.add(reclamacion4);

        // Reclamacion 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'Test05');
        camposRecl5.put('Description', 'Prueba6');
        camposRecl5.put('Status', 'Activo');
        camposRecl5.put('Origin', 'Otros');
        camposRecl5.put('CC_Idioma__c', 'es');
        camposRecl5.put('CC_Tipo_Contacto__c', 'Consulta');
        camposRecl5.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl5.put('CC_Canal_Procedencia__c', 'Junta Andalucia');

        Case reclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl5);
        reclamaciones.add(reclamacion5);

        // Reclamacion 6
        Map<String, Object> camposRecl6 = new Map<String, Object>();
        camposRecl6.put('Subject', 'Test06');
        camposRecl6.put('Description', 'Prueba7');
        camposRecl6.put('Status', 'Activo');
        camposRecl6.put('Origin', 'Otros');
        camposRecl6.put('CC_Idioma__c', 'es');
        camposRecl6.put('CC_Tipo_Contacto__c', 'Consulta');
        camposRecl6.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl6.put('CC_Canal_Procedencia__c', 'Junta Andalucia');

        Case reclamacion6 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl6);
        reclamaciones.add(reclamacion6);

        // Reclamacion 7
        Map<String, Object> camposRecl7 = new Map<String, Object>();
        camposRecl7.put('Subject', 'Test07');
        camposRecl7.put('Description', 'Prueba');
        camposRecl7.put('Status', 'Activo');
        camposRecl7.put('Origin', 'Otros');
        camposRecl7.put('CC_Idioma__c', 'es');
        camposRecl7.put('CC_Tipo_Contacto__c', 'Consulta');
        camposRecl7.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl7.put('CC_Canal_Procedencia__c', 'Junta Andalucia');

        Case reclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl7);
        reclamaciones.add(reclamacion7); 
        SAC_DatabaseDML.insertListDML(reclamaciones, false);
    }
    
    @isTest
    static void testRepresentanteReclamante() {

        String sPretensionRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        
        SAC_LCMP_BusquedaCliente.RepresentanteOrContactoWrapper wrapper = new SAC_LCMP_BusquedaCliente.RepresentanteOrContactoWrapper();
        wrapper.idRepresentante     = 'idprueba';
        wrapper.idJunction          = 'idprueba';
        wrapper.nombreContrato      = 'nombrecontrato';
        wrapper.tipoRepresentante   = 'tipo';
        wrapper.cargoRepresentante  = 'cargo';
        wrapper.tipoPersonaCliente  = 'tipoPersona';
        Case caso = [SELECT Id FROM Case WHERE Subject='Test01'];
        Case caso4 = [SELECT Id FROM Case WHERE RecordTypeId=:sPretensionRecordType];
        caso4.AccountId = [SELECT Id FROM Account WHERE Name='Test07'].Id;
        SAC_DatabaseDML.updateDML(caso4, false);
        Contact cont = [SELECT ID FROM Contact WHERE CC_NumPerso__c = '99999991' LIMIT 1];

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            try{
                SAC_LCMP_BusquedaCliente.crearReclamanteSecundario(cont.Id, 'Representante', caso.Id);
            }
            catch(exception e){
                System.assertNotEquals(0, [SELECT Count() FROM SAC_CaseReclamante__c],'No se ha insertado el reclamante');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testContactoReclamante() {
        
        Case caso = [SELECT Id FROM Case WHERE Subject='Test01'];
        Contact cont = [SELECT ID FROM Contact WHERE CC_NumPerso__c = '99999992' LIMIT 1];

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_BusquedaCliente.crearReclamanteSecundario(cont.Id, 'Contacto', caso.Id);
        }
        Test.stopTest();

        System.assertNotEquals(0, [SELECT Count() FROM SAC_CaseReclamante__c],'No se ha insertado el reclamante');
    }

    @isTest
    static void testCuentaReclamante() {
        
        Case caso = [SELECT Id FROM Case WHERE Subject='Test01'];
        Account cont = [SELECT ID FROM Account WHERE CC_Numero_Documento__c = '15197951B' LIMIT 1];

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_BusquedaCliente.crearReclamanteSecundario(cont.Id, 'Cuenta', caso.Id);
        }
        Test.stopTest();

        System.assertNotEquals(0,[SELECT Count() FROM SAC_CaseReclamante__c], 'No se ha insertado el reclamante');
    }

    @isTest
    static void testGetContactoAsoc() {
        
        Account cont = [SELECT ID FROM Account WHERE Name = 'Test07' LIMIT 1];
        String var;

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            var = SAC_LCMP_BusquedaCliente.getContactoAsoc(String.valueOf(cont.Id));
        }
        Test.stopTest();

        Contact contacto = [SELECT Id FROM Contact WHERE AccountId = :cont.Id]; 
        System.assertEquals(String.valueOf(contacto.Id), var, 'No se ha devuelto bien');
    }

    @isTest
    static void testGetEsPropietarioCaso() {
        
        Case caso = [SELECT Id FROM Case WHERE Subject='Test01'];
        Boolean propietario;

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        // El usuario que ejecuta no es el Owner del caso, así que dará false
        System.runAs(usuario){ 
            propietario = SAC_LCMP_BusquedaCliente.getEsPropietarioCaso(caso.Id);
        }
        Test.stopTest();

        System.assertEquals(propietario, false, 'Es propietario del caso.');
    }

    @isTest
    static void testDatosCaso() {
        
        Case caso = [SELECT Id FROM Case WHERE Subject='Test01'];
        List<Case> listaCasos;

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            listaCasos = SAC_LCMP_BusquedaCliente.datosCaso(String.valueOf(caso.Id));
        }
        Test.stopTest();

        System.assertEquals(listaCasos.isEmpty(), false, 'No hay casos');
    }

    @isTest
    static void testDatosRegistro() {
        
        Case caso = [SELECT Id, AccountId FROM Case WHERE Subject='Test01'];
        sObject sCaso;

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            sCaso = SAC_LCMP_BusquedaCliente.datosRegistro(caso.Id);
        }
        Test.stopTest();

        System.assertEquals(caso.AccountId, sCaso.get('AccountId'), 'No hay casos');
    }

    @isTest
    static void testActualizarIdentificacion() {
        
        Case caso = [SELECT Id, AccountId FROM Case WHERE Subject='Test01'];
        
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_LCMP_BusquedaCliente.actualizarIdentificacion(caso.Id, true, 'Case');
        }
        Test.stopTest();

        caso = [SELECT Id, AccountId, CC_No_Identificado__c FROM Case WHERE Subject='Test01'];

        System.assertEquals(caso.CC_No_Identificado__c, true, 'Se ha actualizado bien.');
    }

    @isTest
    static void testGetRepresentantesOrContactosClienteJ() {
        
        Account cont = [SELECT ID FROM Account WHERE Name = 'Test07' LIMIT 1];
        List<SAC_LCMP_BusquedaCliente.RepresentanteOrContactoWrapper> retur;

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            retur = SAC_LCMP_BusquedaCliente.getRepresentantesOrContactosCliente(cont.Id);
        }
        Test.stopTest();

        System.assertEquals(retur.isEmpty(), false, 'Se ha actualizado bien.');
    }

    @isTest
    static void testGetRepresentantesOrContactosClienteF() {
        
        Account cont = [SELECT ID FROM Account WHERE Name = 'Test05' LIMIT 1];
        List<SAC_LCMP_BusquedaCliente.RepresentanteOrContactoWrapper> retur;
        
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            retur = SAC_LCMP_BusquedaCliente.getRepresentantesOrContactosCliente(cont.Id);
        }
        Test.stopTest();

        System.assertEquals(retur.isEmpty(), false, 'Se ha actualizado bien.');
    }

    @isTest
    public static void actualizarReclamanteNoClienteTest() {            

        Case caso1 =  [SELECT Id FROM Case WHERE Subject = 'Test01' LIMIT 1];
        Case caso2 = [SELECT Id FROM Case WHERE Subject = 'Test06' LIMIT 1];

        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE DeveloperName = 'SAC_NoCliente_PA' and SobjectType='Account' AND IsPersonType=True LIMIT 1];

        Id recordTypeIdCliente = personAccountRecordType.Id;
        Account cuenta = new Account(
            FirstName = 'CuentaTest',
            LastName = 'NoCliente',
            RecordTypeId = recordTypeIdCliente
        );
        SAC_DatabaseDML.insertDML(cuenta, false);

        Integer contadorReclamantes1 = [SELECT Count() FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: caso1.Id];
        Integer contadorReclamantes2 = [SELECT Count() FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: caso2.Id];

        String idRecordType = '';

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            idRecordType = SAC_LCMP_BusquedaCliente.getRecTypeCliente();
            SAC_LCMP_BusquedaCliente.actualizarReclamanteNoCliente(caso1.Id, cuenta.Id);
            SAC_LCMP_BusquedaCliente.actualizarReclamanteNoCliente(caso2.Id, cuenta.Id);
        }
        Test.stopTest();
        
        System.assertNotEquals(contadorReclamantes1, [SELECT Count() FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: caso1.Id], 'No se ha insertado reclamantes 1');
        System.assertNotEquals(contadorReclamantes2, [SELECT Count() FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: caso2.Id], 'No se ha insertado reclamantes 2');
        System.assertNotEquals('', idRecordType, 'No se ha devuelto el id del recordType');
    }
}