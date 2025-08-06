@isTest
public with sharing class SPV_LCMP_CrearTarea_Test {
    @TestSetup
    static void makeData(){

        Test.startTest();

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioADmin, true);

        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            SPV_DatabaseDML.insertListDML(listUsuarios, true);
        }

        Test.stopTest();

        List<Account> listaCuentas = new List<Account>();
        //Cuentas
        listaCuentas = SPV_TestDataFactory.crearCuentas(1);
        listaCuentas[0].Name = 'Cuenta A - Test SPV';
        listaCuentas[0].CC_Tipo_Centro__c = 'OF';
        listaCuentas[0].Phone = '123456789';
        listaCuentas[0].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[0].billingStreet  = 'Calle Mayor 55';
        listaCuentas[0].BillingCountry = 'España';
        listaCuentas[0].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        SPV_DatabaseDML.insertListDML(listaCuentas, true);

        //Grupo
        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
        grupo.Name = 'grupotest';
        grupo.SAC_PermiteEscalado__c = true;
        grupo.SAC_PermiteConsultas__c = true;
        grupo.SAC_PermiteTareas__c = true;
        grupo.SAC_TienePropietario__c = true;
        grupo.SAC_PeriodoConsulta__c = 12;
        grupo.OS_Negocio__c = 'SPV';
        grupo.SAC_DeveloperName__c = 'OFICINA';
        listGrupos.add(grupo);

        SPV_DatabaseDML.insertListDML(listGrupos, true);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestTarea');
        camposRecl.put('OwnerId', listUsuarios[0].Id);
        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SPV_DatabaseDML.insertDML(casoReclamacion, true);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'TestTarea2');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('OwnerId', listUsuarios[0].Id);
        Case casoPretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret);

        //grupo colaborador
        List<CC_Grupo_Colaborador__c> listaGrupos = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',1);
        listaGrupos[0].Name = 'grupo de tareas';
        listaGrupos[0].SAC_PermiteTareas__c = true;
        SPV_DatabaseDML.insertListDML(listaGrupos, true);


        System.runAs(usuarioAdmin){
            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SPV_TestDataFactory.crearColaboradorContact(listUsuarios[0].Id,listaGrupos[0].id);
            SPV_DatabaseDML.insertDML(grupoColaboradorContact2, true);
        }

        SAC_MaestroAccionesReclamacion__c maestroTareas = new SAC_MaestroAccionesReclamacion__c();
        maestroTareas.RecordTypeId = Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroAcciones').getRecordTypeId();
        maestroTareas.Name = 'maestro tarea';
        maestroTareas.SAC_Descripcion__c = 'test maestro';
        maestroTareas.SAC_PlazoMaximo__c = 8;
        maestroTareas.SAC_EquipoResponsable__c = listaGrupos[0].Id;
        maestroTareas.SAC_Prorroga__c = 2;
        maestroTareas.SAC_Activo__c = true;
        SPV_DatabaseDML.insertDML(maestroTareas, true);

        SAC_Accion__c tarea = new SAC_Accion__c();
        tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
        tarea.SAC_EquipoResponsable__c = listaGrupos[0].Id;
        tarea.SAC_Reclamacion__c = casoReclamacion.Id;
        SPV_DatabaseDML.insertDML(tarea, true);

        //Oficinas afectadas
        List<SAC_ImagenDocumento__c> listaOficinasAfectadas = new List<SAC_ImagenDocumento__c>();

        SAC_ImagenDocumento__c objIntermedio1 = new SAC_ImagenDocumento__c();
        objIntermedio1.SAC_Caso__c = casoReclamacion.Id;
        objIntermedio1.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        objIntermedio1.RecordTypeId = Schema.SObjectType.SAC_ImagenDocumento__c.getRecordTypeInfosByDeveloperName().get('SPV_OficinaAfectada').getRecordTypeId();
        listaOficinasAfectadas.add(objIntermedio1);
        SPV_DatabaseDML.insertListDML(listaOficinasAfectadas, true);
    }

    @isTest
    static void insertarTareaTest() {

        Case caso = [SELECT Id,Subject, Owner.Name FROM Case WHERE subject = 'TestTarea' LIMIT 1];
        CC_Grupo_Colaborador__c grupoTarea = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE name = 'grupo de tareas' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true Limit 1];
        Account oficina = [SELECT Id FROM Account WHERE Name = 'Cuenta A - Test SPV' LIMIT 1];
        
        String idRec = caso.Id; 
        String descripcion = 'test';
        String equipoResponsableId = grupoTarea.Id;
        Boolean esMaestroOrOtras = true;
        SAC_Accion__c tareaInsertada;

        caso.OwnerId = usuario.Id;
        SPV_DatabaseDML.updateDML(caso, true);

        System.RunAs(usuario){   
            Test.startTest();
            SPV_LCMP_CrearTarea.insertarTarea(idRec, descripcion, equipoResponsableId, oficina.Id, esMaestroOrOtras);
            tareaInsertada = [SELECT Id FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :idRec LIMIT 1];
            Test.stopTest();
        }

        System.assertNotEquals(null, tareaInsertada.id, 'La ejecucion ha fallado a la hora de insertar la tarea');
    }
    
    @isTest
    static void insertarTareaTest2() {

        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c maestroTarea = [SELECT Id FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'maestro tarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true Limit 1];
        Account oficina = [SELECT Id FROM Account WHERE Name = 'Cuenta A - Test SPV' LIMIT 1];
        
        String idRec = caso.Id; 
        String descripcion = '';
        String equipoResponsableId = maestroTarea.Id;
        Boolean esMaestroOrOtras = false;
        SAC_Accion__c tareaInsertada;

        caso.OwnerId = usuario.Id;
        SPV_DatabaseDML.updateDML(caso, true);

        System.RunAs(usuario){   
            Test.startTest();
            SPV_LCMP_CrearTarea.insertarTarea(idRec, descripcion, equipoResponsableId, oficina.Id, esMaestroOrOtras);
            tareaInsertada = [SELECT Id FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :idRec LIMIT 1];
            Test.stopTest();
        }

        System.assertNotEquals(null, tareaInsertada.id, 'La ejecucion ha fallado a la hora de insertar la tarea');
    }

    @isTest 
    static void tienePermisosTest() {
        Boolean respuesta=false;
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        casoReclamacion.OwnerId = usuario.Id;
        SPV_DatabaseDML.updateDML(casoReclamacion, true);

        System.RunAs(usuario){   
            Test.startTest();
            respuesta = SPV_LCMP_CrearTarea.tienePermisos(casoReclamacion.id);
            Test.stopTest();
        }

        System.assertEquals(true, respuesta, 'No tiene permisos para insertar una tarea ');
    }

    @isTest
    static void camposRequeridosTest() {

        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        List<CC_Grupo_Colaborador__c> listaGrupos;

        System.RunAs(usuario){   
            Test.startTest();
            listaGrupos = SPV_LCMP_CrearTarea.camposRequeridos(casoReclamacion.id, 'OtrasTareas');
            Test.stopTest();
        }
        
        System.assertNotEquals(null, listaGrupos, 'No se han podido recuperar los grupos');
    }

    @isTest
    static void camposRequeridosMaestroTest() {

        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        List<SAC_MaestroAccionesReclamacion__c> listaGrupos;

        System.RunAs(usuario){   
            Test.startTest();
            listaGrupos = SPV_LCMP_CrearTarea.camposRequeridosMaestro(casoReclamacion.id, 'MaestroTareas');
            Test.stopTest();
        }
        
        Assert.areNotEqual(null, listaGrupos, 'No se han podido recuperar los grupos');
    }

    @isTest 
    static void tienePermisosTest2() {
        Boolean respuesta=false;
        Case casoReclamacion = [SELECT id, Status, Origin, recordTypeId, RecordType.DeveloperName FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id, Name, UserRoleId, UserRole.Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.RunAs(usuario){
            Test.startTest();
            respuesta = SPV_LCMP_CrearTarea.tienePermisos(casoReclamacion.id);
            Test.stopTest();
        }

        Assert.areNotEqual(true, respuesta, 'No tiene permisos para insertar una tarea');
    }

    @isTest 
    static void comprobarPosibleOficinaTest() {
        Case casoReclamacion = [SELECT id, Status, Origin, recordTypeId, RecordType.DeveloperName FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id, Name, UserRoleId, UserRole.Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupotest' LIMIT 1];
        List<SAC_ImagenDocumento__c> listOficinas = new List<SAC_ImagenDocumento__c>();

        Test.startTest();
        System.runAs(usuario) {
            listOficinas = SPV_LCMP_CrearTarea.comprobarPosibleOficina(grupo.Id, casoReclamacion.Id);
        }
        Test.stopTest();

        Assert.areEqual(false, listOficinas.isEmpty(), 'No se han comprobado las oficinas correctamente');
    }
}