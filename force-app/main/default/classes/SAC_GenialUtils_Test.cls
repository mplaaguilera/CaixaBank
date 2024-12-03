/*****************************************************************
* Name: SAC_GenialUtils_Test
* Copyright © 2023  CaixaBank
* 
* Proposito: Testear el componente SAC_GenialUtils
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US727970         David Ramos            26/10/23       Creación     
* 1.1            US866221         David Ramos            02/04/24       Modificar tests del randomizador para que use 
                                                                        el nuevo custom setting que separa 
                                                                        configuraciones por canal 
                                                                        + Añadir test para comprobar todas las restricciones, entren o no
* 1.2            US914420         Alexandre Perez        09/05/24       test para las clases de delay y las de update e insert
*****************************************************************/
@isTest
public with sharing class SAC_GenialUtils_Test {
    @TestSetup
    static void makeData(){
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);
        //Usuario SAC Admin
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];     
        Database.insert(usuarioAdmin);

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral) {

        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Description', 'Descripcion de prueba recla');
        camposRecl.put('SAC_GenialEstado__c', 'SAC_003');
        camposRecl.put('SAC_TiempoSLARegulatorio__c', 2);
        camposRecl.put('SAC_FechaVencimientoSLA__c', system.now());
        Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        
        Database.insert(reclamacion1);
        system.debug('Inserted Case ID: ' + reclamacion1.Id);

        List<Case> pretensiones = new List<Case>();

        Map<String, Object> camposPretMain = new Map<String, Object>();
        camposPretMain.put('SAC_Reclamacion__c', reclamacion1.Id);
        camposRecl.put('Description', 'Descripcion de prueba pretMain');
        camposPretMain.put('SAC_EsPrincipal__c', true);

        Case pretensionMain = SAC_TestDataFactory.crearCaso('Pretension',camposPretMain);
        pretensiones.add(pretensionMain);

        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SAC_Reclamacion__c', reclamacion1.Id);
        camposRecl.put('Description', 'Descripcion de prueba Pret2');

        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
        pretensiones.add(pretension2);

        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SAC_Reclamacion__c', reclamacion1.Id);
        camposRecl.put('Description', 'Descripcion de prueba pret3');

        Case pretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);
        pretensiones.add(pretension3);

        Database.insert(pretensiones);
        }
    }

    //para probar randomizador sobreescribir porcentaje de SAC_GenialSettings__c a 100 y a 0

    //prueba con settings.SAC_IAactiva__c = false y settings.SAC_shadow__c = false
    @isTest
    public static void testRandomizadorNoIANoShadow() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = false;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }

        System.assertEquals('SAC_PendienteAsignar', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }

    //prueba con settings.SAC_IAactiva__c = true o settings.SAC_shadow__c = true, con settings.SAC_Porcentaje__c = 0
    @isTest
    public static void testRandomizadorIAoShadowNoEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 0;
        
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }

        System.assertEquals('SAC_PendienteAsignar', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }

    //prueba con settings.SAC_IAactiva__c = false y settings.SAC_shadow__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorNoIASiShadowEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = false;
        settings.SAC_Shadow__c = true;
        settings.SAC_Porcentaje__c = 100;
        
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }

        System.assertEquals('SAC_PendienteAsignar;Shadow', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }
    
    //prueba con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorSiIAEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
            
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }
    
        System.assertEquals('SAC_GenialPdteIA;IA', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }

    @isTest
    public static void testCasteoCaseAgenialResultado() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(1);
        Account cuentatest = cuentas[0];

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('AccountId', cuentatest.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        SAC_Genial_Resultado__c casteoGenial = new SAC_Genial_Resultado__c();
    
        System.runAs(usuario){
            Test.startTest();
            casteoGenial = SAC_GenialUtils.casteoCaseAgenialResultado(reclamacion);
            Test.stopTest();
        }

        System.assertEquals(reclamacion.AccountId, casteoGenial.SAC_AccountId__c,'El cast no se ha hecho correctamente');

    }

    @isTest
    public static void testComparaCampos() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(1);
        Account cuentatest = cuentas[0];

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('AccountId', cuentatest.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        reclamacion.SAC_UsarDatos__c = true;
        reclamacion.SAC_FechaRecepcion__c = null;
        

        SAC_Genial_Resultado__c casteoGenial = new SAC_Genial_Resultado__c();
        casteoGenial = SAC_GenialUtils.casteoCaseAgenialResultado(reclamacion);
        casteoGenial.SAC_UsarDatos__c = false;
        casteoGenial.SAC_FechaRecepcion__c = null;
    
        Map<String, Boolean> comparaciones = new Map<String, Boolean>();

        System.runAs(usuario){
            Test.startTest();
            comparaciones = SAC_GenialUtils.comparaCampos(reclamacion,casteoGenial);
            Test.stopTest();
        }
        
        Boolean campoIgual = comparaciones.get('SAC_AccountId__c');
        Boolean campoDiferente = comparaciones.get('SAC_UsarDatos__c');

        System.assertEquals(true, (campoIgual && !campoDiferente),'Las comparaciones no se han hecho correctamente');

    }

    @isTest
    public static void testcomparaCamposYcasteo() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(1);
        Account cuentatest = cuentas[0];

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('AccountId', cuentatest.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        reclamacion.SAC_NumeroDelDocumento__c = '86645006G';
        reclamacion.SAC_EmailRepresentante__c = 'test@invalid.com';

        SAC_Genial_Resultado__c casteoGenial = new SAC_Genial_Resultado__c();
        casteoGenial = SAC_GenialUtils.casteoCaseAgenialResultado(reclamacion);
        casteoGenial.SAC_NumeroDelDocumento__c = '86645006G';
        casteoGenial.SAC_EmailRepresentante__c = 'diferente@invalid.com';

        System.runAs(usuario){
            Test.startTest();
            SAC_GenialUtils.comparaCamposYcasteo(reclamacion,casteoGenial);
            Test.stopTest();
        }
        
        Boolean campoIgual = casteoGenial.SAC_NumeroDelDocumento_OK__c;
        Boolean campoDiferente = casteoGenial.SAC_EmailRepresentante_OK__c;

        System.assertEquals(true, (campoIgual && !campoDiferente),'Las comparaciones y el cast no se han hecho correctamente');

    }

    @isTest
    public static void testFechaOKComparaCampos() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(1);
        Account cuentatest = cuentas[0];

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('AccountId', cuentatest.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        reclamacion.SAC_UsarDatos__c = true;
        reclamacion.SAC_FechaRecepcion__c = DateTime.newInstance(2024, 1, 1, 12, 20, 3);
        

        SAC_Genial_Resultado__c casteoGenial = new SAC_Genial_Resultado__c();
        casteoGenial = SAC_GenialUtils.casteoCaseAgenialResultado(reclamacion);
        casteoGenial.SAC_UsarDatos__c = false;
        casteoGenial.SAC_FechaRecepcion__c = DateTime.newInstance(2024, 1, 1, 12, 20, 3);
    
        Map<String, Boolean> comparaciones = new Map<String, Boolean>();

        System.runAs(usuario){
            Test.startTest();
            comparaciones = SAC_GenialUtils.comparaCampos(reclamacion,casteoGenial);
            Test.stopTest();
        }
        
        Boolean campoIgual = comparaciones.get('SAC_FechaRecepcion__c');

        System.assertEquals(true, campoIgual,'Las comparaciones no se han hecho correctamente');

    }

    @isTest
    public static void testFechaKOComparaCampos() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(1);
        Account cuentatest = cuentas[0];

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('AccountId', cuentatest.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        reclamacion.SAC_UsarDatos__c = true;
        reclamacion.SAC_FechaRecepcion__c = DateTime.newInstance(2023, 12, 12, 2, 2, 30);
        

        SAC_Genial_Resultado__c casteoGenial = new SAC_Genial_Resultado__c();
        casteoGenial = SAC_GenialUtils.casteoCaseAgenialResultado(reclamacion);
        casteoGenial.SAC_UsarDatos__c = false;
        casteoGenial.SAC_FechaRecepcion__c = DateTime.newInstance(2024, 1, 1, 12, 20, 3);
    
        Map<String, Boolean> comparaciones = new Map<String, Boolean>();

        System.runAs(usuario){
            Test.startTest();
            comparaciones = SAC_GenialUtils.comparaCampos(reclamacion,casteoGenial);
            Test.stopTest();
        }
        
        Boolean campoDiferente = comparaciones.get('SAC_FechaRecepcion__c');

        System.assertEquals(false, campoDiferente,'Las comparaciones no se han hecho correctamente');

    }

    //prueba con settings.SAC_HoraInicio__c y settings.SAC_HoraFin__c que entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorRangoHoraEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        DateTime fechaHoraActual = Datetime.now();
        Decimal horaActual = fechaHoraActual.hour();

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_HoraInicio__c = horaActual - 5;
        settings.SAC_HoraFin__c = horaActual + 5;
            
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }
    
        System.assertEquals('SAC_GenialPdteIA;IA', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }

    //prueba con settings.SAC_HoraInicio__c y settings.SAC_HoraFin__c que entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorRangoHoraNoEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        DateTime fechaHoraActual = Datetime.now();
        Decimal horaActual = fechaHoraActual.hour();

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_HoraInicio__c = horaActual + 5;
        settings.SAC_HoraFin__c = horaActual + 6;
            
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }
    
        System.assertEquals('SAC_PendienteAsignar', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }      

    //prueba con los dias de la semana que entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorRangoDiasEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_MondayON__c = true;
        settings.SAC_TuesdayON__c = true;
        settings.SAC_WednesdayON__c = true;
        settings.SAC_ThursdayON__c = true;
        settings.SAC_FridayON__c = true;
        settings.SAC_SaturdayON__c = true;
        settings.SAC_SundayON__c = true;
            
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }
    
        System.assertEquals('SAC_GenialPdteIA;IA', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }   

    //prueba con los dias de la semana que no entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorRangoDiasNoEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_MondayON__c = false;
        settings.SAC_TuesdayON__c = false;
        settings.SAC_WednesdayON__c = false;
        settings.SAC_ThursdayON__c = false;
        settings.SAC_FridayON__c = false;
        settings.SAC_SaturdayON__c = false;
        settings.SAC_SundayON__c = false;
            
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }
    
        System.assertEquals('SAC_PendienteAsignar', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }           

    //prueba con settings.SAC_FechaInicio__c y settings.SAC_FechaFin__c que entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorRangoFechaEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        DateTime fechaHoraActual = Datetime.now();
        Date fechaActual = fechaHoraActual.date();

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_FechaInicio__c = fechaActual.addDays(-5);
        settings.SAC_FechaFin__c = fechaActual.addDays(5);
            
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }
    
        System.assertEquals('SAC_GenialPdteIA;IA', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }   

    //prueba con settings.SAC_FechaInicio__c y settings.SAC_FechaFin__c que no entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorRangoFechaNoEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        DateTime fechaHoraActual = Datetime.now();
        Date fechaActual = fechaHoraActual.date();

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_FechaInicio__c = fechaActual.addDays(-5);
        settings.SAC_FechaFin__c = fechaActual.addDays(-2);
            
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }
    
        System.assertEquals('SAC_PendienteAsignar', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }      

    //prueba con restriccion por cantidad que entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorRestricCantidadEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_CantidadCasosMax__c = 3;
            
        Database.insert(settings);

        String nombreCola;
        System.runAs(usuario){
            Test.startTest();
            nombreCola = SAC_GenialUtils.randomizador('Test');
            Test.stopTest();
        }
    
        System.assertEquals('SAC_GenialPdteIA;IA', nombreCola,'El randomizador no ha generado el nombre cola correcto');
    }   

    
    //prueba con restriccion por cantidad que no entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void testRandomizadorRestricCantidadNoEntra() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        //custom setting
        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Otros';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_CantidadCasosMax__c = 1;
        Database.insert(settings);
       
        //reclamacion 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('SAC_GenialEstado__c', 'SAC_003');
        camposRecl.put('Origin', 'Otros');
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        

        String nombreCola1;

        System.runAs(usuario){
            Database.insert(reclamacion);
            Test.startTest();
            nombreCola1 = SAC_GenialUtils.randomizador('Otros');
            Test.stopTest();
        }
    
        //la segunda llamada es la que llega al limite y pone el check de maximo alcanzado, no entra y no entrará ninguna posterior (hasta el dia siguiente)
        Boolean testCorrecto = (nombreCola1 == 'SAC_PendienteAsignar');
        System.assertEquals(true, testCorrecto,'El randomizador no ha generado el nombre cola correcto');
    }
    
     //prueba con restriccion por cantidad que no entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void delayActivo() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_DelayEnvio__c = 30;
        Database.insert(settings);
        
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        System.runAs(usuario){
            Test.startTest();
            SAC_GenialUtils.programarEnviar(reclamacion.id, 'Test', 'Esto es una test', 'Azure');
            Test.stopTest();
        }
    
        list<CBK_SCH_PendingProcess__c> pendiente = [SELECT Id, className__c, param1__c FROM CBK_SCH_PendingProcess__c LIMIT 1];
        //ver que se ha generado registro para la programación del envío a azure
        System.assertEquals('SAC_GenialScheEnvioIntegracion', pendiente[0].className__c, 'No se ha programado hacia la clase esperada');
        System.assertEquals('Azure', pendiente[0].param1__c, 'debería programarla hacia azure');
    }
    @isTest
    public static void balanceador() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c(
            Name = 'Test Canal',
            SAC_IAactiva__c = true,
            SAC_shadow__c = true,
            SAC_DelayEnvio__c = 30,
            SAC_Balanceador_Integracion__c = 'Azure,60;OpenServices,40',
            SAC_Tamano_Maximo_Attach__c = 1,
            SAC_Integracion_Adjuntos_Pesados__c = 'Azure'
        );
        Database.insert (settings);

        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        // Verificar que el caso se ha creado
        //System.assertNotEquals(null, reclamacion.Id, 'El caso debería haberse creado correctamente');

        System.runAs(usuario){
            Database.insert(reclamacion);
            Test.startTest();
            SAC_GenialUtils.balanceador(reclamacion.Id, 'Test Canal', 'Esto es una test');
            Test.stopTest();
        }
        //Case CaseUpdate = [SELECT Id, SAC_Tipo_integracion_IA__c FROM Case WHERE Id =:reclamacion.Id];
        // Verificar que el job encolado ha creado un registro CBK_SCH_PendingProcess__c
        List<CBK_SCH_PendingProcess__c> pendingProcesses = [SELECT Id, recordId__c, className__c FROM CBK_SCH_PendingProcess__c WHERE recordId__c = :reclamacion.Id];
        
        // Validar que el registro se ha creado correctamente
        System.assertEquals(reclamacion.Id, pendingProcesses[0].recordId__c, 'El registro pendiente debe estar asociado a la reclamación correcta');
        System.assertEquals('SAC_GenialScheEnvioIntegracion', pendingProcesses[0].className__c, 'El registro pendiente debe tener la clase correcta');
        System.assertEquals('SAC_GenialScheEnvioIntegracion', pendingProcesses[0].className__c, 'El registro pendiente debe tener la clase correcta');
    }
    //prueba con restriccion por cantidad que no entra, con settings.SAC_IAactiva__c = true, con settings.SAC_Porcentaje__c = 100
    @isTest
    public static void delayInactivo() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csGenialAzureAI = new CBK_IntegrationSetting__c();
        csGenialAzureAI.Name = 'SAC_GenialAzureAI';
        csGenialAzureAI.NamedCredential__c = 'callout:API_GWT_SAC/tech/geni06/notify-case';
        csGenialAzureAI.CBK_Method__c = 'POST';
        csGenialAzureAI.CBK_TimeOut__c = 120000;
        csGenialAzureAI.CBK_ContentType__c = 'application/json';
        Database.insert(csGenialAzureAI);
        
        dateTime fechaAnteriorfwkInt = dateTime.newInstance(2023, 4, 16);
        Test.setCreatedDate(csGenialAzureAI.Id, fechaAnteriorfwkInt);
        update csGenialAzureAI;
        
        
        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_DelayEnvio__c = 0;
        Database.insert(settings);
         //el cambio de fwk capando por fechas al antiguo, obliga a realizar esta operación
        
        
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('SAC_GenialEstado__c', 'SAC_005');
        camposRecl.put('Origin', 'Email');
        camposRecl.put('SuppliedEmail', 'test07032024931@test1.com.invalid');
        Case reclamacion;
        
		Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(201, 'OK', '', new Map<String, String>()));
        System.runAs(usuario){
            reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        	insert reclamacion;
            Test.startTest();
            SAC_GenialUtils.programarEnviar(reclamacion.id, 'Test', 'Esto es una test', 'Azure');
            Test.stopTest();
        }
    
        case reclamaResult = [SELECT Id, SAC_GenialEstado__c FROM Case WHERE Id = : reclamacion.Id];
		//ver que se ha enviado a azure la info directamente
        system.assertEquals('SAC_001', reclamaResult.SAC_GenialEstado__c);
    }
    
    //testing insert de datos y su tratamiento de error
    @isTest
    static void testInsert(){
        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

        list<sobject> objRes = new list<sobject>();
        
        account acc1 = new account(
            CC_Numero_Documento__c='37548393L',
            AV_NumPerso__c = '12345',
            firstName='confidencial',
            lastName='Test',
            recordTypeId = clientePArt
        );
        objRes.add((sobject)acc1);
        account acc2 = new account(
            CC_Numero_Documento__c='37548392L',
            AV_NumPerso__c = '123456',
            firstName='confidencial',
            recordTypeId = clientePArt
        );
        objRes.add((sobject)acc2);
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        
        system.runAs(sacUser){
            test.startTest();
        	SAC_GenialUtils.modificarInsertarObjetos(objRes, 'insert');
            test.stopTest();
        }
        //insert acc2; 
        system.assertEquals('37548393L', [SELECT CC_Numero_Documento__c FROM ACCOUNT where CC_Numero_Documento__c = '37548393L'][0].CC_Numero_Documento__c);  
    }
    
    //testing update de datos y tratamiento de error
    @isTest
    static void testUpdate(){
        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

        list<account> listacc = new list<account>();
        list<sobject> objRes = new list<sobject>();
        
        account acc1 = new account(
            CC_Numero_Documento__c='37548393L',
            AV_NumPerso__c = '12345',
            lastName='Test',
            recordTypeId = clientePArt
        );
        listacc.add(acc1);
        objRes.add((sobject)acc1);
        account acc2 = new account(
            CC_Numero_Documento__c='65253567Z',
            AV_NumPerso__c = '123456',
            lastName='Test2',
            recordTypeId = clientePArt
        );
        listacc.add(acc2);
        objRes.add((sobject)acc2);
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        system.runAs(sacUser){
            insert listacc;
            acc1.firstname = 'OK';
            acc2.CC_Numero_Documento__c='37548392L';
            acc2.lastName = null;
         
            test.startTest();
        	SAC_GenialUtils.modificarInsertarObjetos(objRes, 'update');
            test.stopTest();
         }
        //insert acc2;
        system.assertEquals('OK', [SELECT ID, firstName FROM ACCOUNT where firstName = 'OK'][0].firstName);
    }
    //testing calculatemilestonetime para SAC_Genial Cases
    @isTest
    static void calculateMilestoneTriggerTimeTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];          
        Case casoReclamacion = [SELECT id, RecordTypeId, SAC_TiempoSLARegulatorio__c, SAC_FechaRecepcion__c, SAC_FechaVencimientoSLA__c, SAC_TipoConsumidor__c FROM case WHERE subject = 'TestRec' LIMIT 1];
        casoReclamacion.SAC_FechaVencimientoSLA__c = System.today().addDays(15); // Fecha inicial arbitraria que asegure diferencia
        update casoReclamacion;
        DateTime actualTriggerTime;
    
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = SAC_GenialUtils.calculateMilestoneTriggerTime(casoReclamacion);
            Test.stopTest();

            System.assertNotEquals(null, actualTriggerTime, 'No se ha calculado el sla');
        }
    }
    @isTest
    static void calculateMilestoneTimeRegulatorio() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];          
        Case casoReclamacion = [SELECT id, RecordTypeId, SAC_TiempoSLARegulatorio__c, SAC_FechaRecepcion__c, SAC_FechaVencimientoSLA__c, SAC_TipoConsumidor__c, SAC_Reclamacion__r.SAC_TipoConsumidor__c, SAC_Prorrogado__c FROM case WHERE subject = 'TestRec' LIMIT 1];
        casoReclamacion.SAC_FechaVencimientoSLA__c = System.today().addDays(15); // Fecha inicial arbitraria que asegure diferencia
        casoReclamacion.SAC_TiempoSLARegulatorio__c = 30; //Tiempo Regulatorio Standard
        update casoReclamacion;
        DateTime regulaTriggerTime;

        System.runAs(usuario){
            Test.startTest();
            regulaTriggerTime = SAC_GenialUtils.calculateMilestoneTriggerTime(casoReclamacion);
            Test.stopTest();

            System.assertNotEquals(null, regulaTriggerTime, 'Cubrimos regulatorio Standard');
        }
    } 
    @isTest
    static void calculateMilestoneTimeConsumidor() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Case casoReclamacion = [SELECT id, RecordTypeId, SAC_TiempoSLARegulatorio__c, SAC_FechaRecepcion__c, SAC_FechaVencimientoSLA__c, SAC_TipoConsumidor__c, SAC_Reclamacion__r.SAC_TipoConsumidor__c, SAC_Prorrogado__c FROM case WHERE subject = 'TestRec' LIMIT 1];
        casoReclamacion.SAC_FechaVencimientoSLA__c = System.today().addDays(15); // Fecha inicial arbitraria que asegure diferencia
        casoReclamacion.SAC_TiempoSLARegulatorio__c = 30;
        casoReclamacion.SAC_TipoConsumidor__c = 'Si';//Consumidor Si = 1 Mes adicional en el cálculo
        update casoReclamacion;

        DateTime consumidorTriggerTime;

        System.runAs(usuario){
            Test.startTest();
            consumidorTriggerTime = SAC_GenialUtils.calculateMilestoneTriggerTime(casoReclamacion);
            Test.stopTest();

            System.assertNotEquals(null, consumidorTriggerTime, 'Cubrimos Consumidor 1 Mes');
        }
    }  
}