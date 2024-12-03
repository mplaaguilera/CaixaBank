@isTest
public with sharing class SPV_AccionHelper_Test {
    
    @TestSetup
    static void makeData(){
        
        Set<String> objetos = new Set<String>{'CC_MCC__c'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id recordTypeIdMCC1 = mapRTsObjects.get('CC_MCC__c').get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdMCC2 = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMCC3 = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdMCCSAC = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
        
        CC_MCC__c mccTematica = new CC_MCC__c(Name='Tematica', CC_Codigo_Externo__c='a', RecordTypeId=recordTypeIdMCC1, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccServicio = new CC_MCC__c(Name='Servicio', CC_Codigo_Externo__c='b', RecordTypeId=recordTypeIdMCC2, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccMotivo = new CC_MCC__c(Name='Motivo a', CC_Codigo_Externo__c='c', RecordTypeId=recordTypeIdMCC3, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Banca Electrónica', CC_Codigo_Externo__c='d', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');
        
        CC_MCC__c mccTematica2 = new CC_MCC__c(Name='Tematica2', CC_Codigo_Externo__c='a2', RecordTypeId=recordTypeIdMCC1, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccServicio2 = new CC_MCC__c(Name='Servicio2', CC_Codigo_Externo__c='b2', RecordTypeId=recordTypeIdMCC2, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccMotivo2 = new CC_MCC__c(Name='Motivo a2', CC_Codigo_Externo__c='c2', RecordTypeId=recordTypeIdMCC3, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccDetalle2 = new CC_MCC__c(Name='Banca Electrónica2', CC_Codigo_Externo__c='d2', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');

        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
        listaMCCs.add(mccTematica);
        listaMCCs.add(mccServicio);
        listaMCCs.add(mccMotivo);
        listaMCCs.add(mccDetalle);
        
        listaMCCs.add(mccTematica2);
        listaMCCs.add(mccServicio2);
        listaMCCs.add(mccMotivo2);
        listaMCCs.add(mccDetalle2);
        Database.upsert(listaMCCs);


        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);
        }


        //Grupos colaboradores
        List<CC_Grupo_Colaborador__c> gruposColaboradores = new List <CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor.SAC_MaximoCasosDiarios__c = 5;
        grupoGestor.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoGestor);

        CC_Grupo_Colaborador__c grupoLetrado = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',1)[0];
        grupoLetrado.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoLetrado);

        List<CC_Grupo_Colaborador__c> gruposTareas = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',2);
        gruposTareas[0].SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposTareas[0].SAC_DeveloperName__c = 'COPS';
        gruposTareas[0].SAC_PermiteTareas__c = true;
        gruposTareas[1].SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposTareas[1].SAC_DeveloperName__c = 'AJ';
        gruposColaboradores.addAll(gruposTareas);

        System.runAs(usuarioGeneral){
            Database.insert(gruposColaboradores);
        }

        //Colaboradores
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact1 = SPV_TestDataFactory.crearColaboradorContact(usuarioGeneral.Id, grupoGestor.Id);
        grupoColaboradorContact1.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact1);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SPV_TestDataFactory.crearColaboradorContact(usuarioGeneral.Id, grupoLetrado.Id);
        grupoColaboradorContact2.SAC_Administrador__c = false;
        listaColaboradores.add(grupoColaboradorContact2);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact3 = SPV_TestDataFactory.crearColaboradorContact(usuarioGeneral.Id, gruposTareas[0].Id);
        grupoColaboradorContact3.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact3);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact4 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, gruposTareas[0].Id);
        grupoColaboradorContact4.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact4);

        System.runAs(usuarioGeneral){
            Database.insert(listaColaboradores);
        }

        List<Case> listaReclamaciones = new List<Case>();
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_TipoConsumidor__c', 'No');
        camposRecl.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRecCrearTareas');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

        //Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Otros');
        camposRecl3.put('Status', 'SPV_PendienteRespuestaOrganismos');
        camposRecl3.put('SPV_Organismo__c', 'SPV_Consumo');
        camposRecl3.put('SEG_Subestado__c', 'Ejecucion y Pendiente Respuesta Organismo');
        camposRecl3.put('SAC_TipoConsumidor__c', 'No');
        camposRecl3.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl3.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl3);

        //Reclamaciones
        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(casoReclamacion);
        reclamaciones.add(casoReclamacion2);
        reclamaciones.add(casoReclamacion3);
        System.runAs(usuarioGeneral){
            Database.insert(reclamaciones);
        }

        List<Case> listaPretensiones = new List<Case>();
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pruebaPretension1');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_EsPrincipal__c', true);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');

        Case casoPretension1 = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension1);

        System.runAs(usuarioGeneral){
            Database.insert(listaPretensiones);
        }


        //Maestro acciones reclamacion
        List<SAC_MaestroAccionesReclamacion__c> listaMaestroAccionesRec = SPV_TestDataFactory.crearMaestroAcciones(1, gruposTareas[0].Id);
        Database.insert(listaMaestroAccionesRec);

    
        //Tareas
        List<SAC_Accion__c> tareas = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaDeTareasOtras = SPV_TestDataFactory.crearTareas(2,casoReclamacion,null);
        
        //Tarea 0
        listaDeTareasOtras[0].SAC_Observaciones__c = 'tarea';
        listaDeTareasOtras[0].SAC_PlazoMaximo__c = 0;
        listaDeTareasOtras[0].SAC_Prorroga__c = 5;
        listaDeTareasOtras[0].OwnerId = usuarioAdmin.id;
        listaDeTareasOtras[0].SPV_GrupoTarea__c = gruposTareas[0].Id;

        //Tarea 1
        listaDeTareasOtras[1].SAC_Observaciones__c = 'tarea1';
        listaDeTareasOtras[1].SAC_PlazoMaximo__c = 0;
        listaDeTareasOtras[1].SAC_Prorroga__c = 5;
        listaDeTareasOtras[1].OwnerId = usuarioAdmin.id;
        listaDeTareasOtras[1].SPV_GrupoTarea__c = gruposTareas[0].Id;
        listaDeTareasOtras[1].SAC_Reclamacion__c = casoReclamacion3.Id;

        List<SAC_Accion__c> listaDeTareasOtras2 = SPV_TestDataFactory.crearTareas(1,casoReclamacion,casoPretension1);
        listaDeTareasOtras2[0].SAC_Observaciones__c = 'tarea3';
        listaDeTareasOtras2[0].OwnerId = usuarioAdmin.id;
        listaDeTareasOtras2[0].SPV_GrupoTarea__c = gruposTareas[0].Id;

        tareas.addAll(listaDeTareasOtras);
        tareas.addAll(listaDeTareasOtras2);

        System.runAs(usuarioAdmin){
            Database.insert(tareas);
            }

        Test.stopTest();
    }


    @isTest
    static void comprobarNuevoOwnerTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
        User usuario2 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        SAC_Accion__c tarea = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea' LIMIT 1] ;

        System.runAs(usuario2){
            Test.startTest();
            tarea.OwnerId = usuario1.Id;
            Database.update(tarea);
            Test.stopTest();
        }

        SAC_Accion__c tareaResultado = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea' LIMIT 1] ;
        System.assertEquals(usuario1.Id, tareaResultado.OwnerId, 'No ha cambiado el owner de la accion');
    }

    @isTest
    static void crearNuevaTareaTest() {
       
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearTareas' LIMIT 1];
       
        Test.startTest();

        System.runAs(usuario) {
            SAC_Accion__C tarea = SPV_TestDataFactory.crearTareas(1, reclamacion, null)[0];
            Database.insert(tarea);

            List<SAC_Accion__Share> listaAccionShare = [SELECT Id FROM SAC_Accion__Share WHERE ParentId = :tarea.Id AND UserOrGroupId = :reclamacion.OwnerId];

            Assert.areNotEqual(listaAccionShare, null, 'Ha fallado al crear el SAC_Accion__Share');
        }

        Test.stopTest();
    }

    @isTest
    static void rellenarFechaEjecucionTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea' LIMIT 1];
       
        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_Estado__c = 'SAC_Finalizada';
            Database.update(tarea);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_FechaDeEjecucion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea' LIMIT 1];
        Assert.areNotEqual(null, tareaResult.SAC_FechaDeEjecucion__c, 'no se ha puesto la fecha de ejecución');
        Test.stopTest();
    }

    @isTest
    static void finalizarTMEsTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea' LIMIT 1];
       
        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_Estado__c = 'SAC_Finalizada';
            Database.update(tarea);
        }

        SAC_TMECaso__c tmeResult = [SELECT Id, SAC_FechaFin__c FROM SAC_TMECaso__c WHERE SAC_Accion__c = :tarea.Id LIMIT 1];
        Assert.areNotEqual(null, tmeResult.SAC_FechaFin__c, 'no se finalizado el tme');
        Test.stopTest();
    }

    @isTest
    static void comprobarTareasFinalizadasTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
       
        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_Estado__c = 'SAC_Finalizada';
            Database.update(tarea);
        }

        Case reclamacionResult = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        Assert.areEqual('Cerrado', reclamacionResult.Status, 'no se ha cerrado la reclamación');
        Test.stopTest();
    }

    @isTest
    static void cargarDatosMaestroAccionesTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearTareas' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c mAccionesRec = [SELECT Id, SAC_Descripcion__c, SAC_EquipoResponsable__c, SAC_PlazoMaximo__c, SAC_Prorroga__c FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'NombreTareaTest0' LIMIT 1];
       
        Test.startTest();

        System.runAs(usuario) {
            //Tarea 2
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Observaciones__c = 'tarea2';
            tarea.SAC_PlazoMaximo__c = 10;
            tarea.SAC_Prorroga__c = 5;
            tarea.OwnerId = usuario.id;
            tarea.SAC_MaestroAccionesReclamacion__c = mAccionesRec.Id;
            tarea.SAC_Reclamacion__c = reclamacion.Id;
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            Database.insert(tarea);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_Descripcion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea2' LIMIT 1];
        Assert.areEqual('DescTareaTest0', tareaResult.SAC_Descripcion__c, 'no se ha cargado la información del maestro de tareas');
        Test.stopTest();
    }

    @isTest
    static void calcularFechaVencimientoInicialTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearTareas' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c mAccionesRec = [SELECT Id, SAC_Descripcion__c, SAC_EquipoResponsable__c, SAC_PlazoMaximo__c, SAC_Prorroga__c FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'NombreTareaTest0' LIMIT 1];
       
        Test.startTest();

        System.runAs(usuario) {
            //Tarea 2
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Observaciones__c = 'tarea2';
            tarea.SAC_PlazoMaximo__c = 10;
            tarea.SAC_Prorroga__c = 5;
            tarea.OwnerId = usuario.id;
            tarea.SAC_MaestroAccionesReclamacion__c = mAccionesRec.Id;
            tarea.SAC_Reclamacion__c = reclamacion.Id;
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            Database.insert(tarea);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_FechaVencimientoInicial__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea2' LIMIT 1];
        Assert.areNotEqual(null, tareaResult.SAC_FechaVencimientoInicial__c, 'no se ha cargado la fecha vencimiento inicial');
        Test.stopTest();
    }

    @isTest
    static void cambioFechaVencimientoProrrogaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, SAC_ProrrogaCounter__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_FechaVencimientoProrroga__c = Date.today().addDays(7);
            Database.update(tarea);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_ProrrogaCounter__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
        Assert.areNotEqual(tarea.SAC_ProrrogaCounter__c, tareaResult.SAC_ProrrogaCounter__c, 'no se ha prorrogado');
        Test.stopTest();
    }

    @isTest
    static void cambioValorPicklistTerceroTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, SAC_FechaTentativa__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_Tercero__c = 'Otros';
            tarea.SAC_FechaTentativa__c = Date.today().addDays(2);
            Database.update(tarea);
            tarea.SAC_Tercero__c = null;
            Database.update(tarea);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_FechaTentativa__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
        Assert.areNotEqual(tarea.SAC_FechaTentativa__c, tareaResult.SAC_FechaTentativa__c, 'no se ha limpiado el campo fecha tentativa');
        Test.stopTest();
    }

    @isTest
    static void crearTMEProrrogaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_FechaVencimientoProrroga__c = Date.today().addDays(7);
            Database.update(tarea);
        }

        SAC_TMECaso__c tmeResult = [SELECT Id FROM SAC_TMECaso__c WHERE SAC_Accion__c = :tarea.Id AND Name = :'Prorroga de la tarea SPV' LIMIT 1];
        Assert.areNotEqual(null, tmeResult.Id, 'no se ha creado el tme de la prorroga de la tarea');
        Test.stopTest();
    }

    @isTest
    static void recalculoImportesTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
        Case reclamacion = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_ImporteAbonar__c = 10;
            tarea.SAC_ImporteResuelto__c = 10;
            Database.update(tarea);
            tarea.SAC_Estado__c = 'SAC_Descartada';
            Database.update(tarea);
        }

        Case reclamacionResult = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        Assert.areNotEqual(reclamacion.CC_Importe_Abonado__c, reclamacionResult.CC_Importe_Abonado__c, 'no se ha reclalculado el importe');
        Test.stopTest();
    }

    @isTest
    static void cambioImportesTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_ImporteAbonar__c = 10;
            tarea.SAC_ImporteResuelto__c = 10;
            Database.update(tarea);
        }

        Case reclamacionResult = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        Assert.areEqual(10, reclamacionResult.CC_Importe_Abonado__c, 'no se ha reclalculado el importe');
        Test.stopTest();
    }

    @isTest
    static void insertarAccionesReclamacionTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
        Case reclamacion = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c mAccionesRec = [SELECT Id, SAC_Descripcion__c, SAC_EquipoResponsable__c, SAC_PlazoMaximo__c, SAC_Prorroga__c FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'NombreTareaTest0' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            Case pretension = new Case();
            pretension.SAC_Reclamacion__c = reclamacion.Id;
            pretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Pretension').getRecordTypeId();
            Database.insert(pretension);

            SAC_Accion__c tareaInsert = new SAC_Accion__c();
            tareaInsert.SAC_Observaciones__c = 'tareaTest';
            tareaInsert.SAC_PlazoMaximo__c = 10;
            tareaInsert.SAC_Prorroga__c = 5;
            tareaInsert.OwnerId = usuario.id;
            tareaInsert.SAC_MaestroAccionesReclamacion__c = mAccionesRec.Id;
            tareaInsert.SAC_Pretension__c = pretension.Id;
            tareaInsert.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            Database.insert(tareaInsert);

        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_Reclamacion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tareaTest' LIMIT 1];
        Assert.areNotEqual(null, tareaResult.SAC_Reclamacion__c, 'no se ha informado la reclamación padre');
        Test.stopTest();
    }

    @isTest
    static void accionComprobarOwnerYStatusTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
        Case reclamacion = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c mAccionesRec = [SELECT Id, SAC_Descripcion__c, SAC_EquipoResponsable__c, SAC_PlazoMaximo__c, SAC_Prorroga__c FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'NombreTareaTest0' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            Case pretension = new Case();
            pretension.SAC_Reclamacion__c = reclamacion.Id;
            pretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Pretension').getRecordTypeId();
            Database.insert(pretension);

            SAC_Accion__c tareaInsert = new SAC_Accion__c();
            tareaInsert.SAC_Observaciones__c = 'tareaTest';
            tareaInsert.SAC_PlazoMaximo__c = 10;
            tareaInsert.SAC_Prorroga__c = 5;
            tareaInsert.OwnerId = usuario.id;
            tareaInsert.SAC_MaestroAccionesReclamacion__c = mAccionesRec.Id;
            tareaInsert.SAC_Pretension__c = pretension.Id;
            Database.insert(tareaInsert);

        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_Reclamacion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tareaTest' LIMIT 1];
        Assert.areNotEqual(null, tareaResult.Id, 'no se ha superado la validación de owner y status');
        Test.stopTest();
    }

    @isTest
    static void tareaReclamacionCerradaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c mAccionesRec = [SELECT Id, SAC_Descripcion__c, SAC_EquipoResponsable__c, SAC_PlazoMaximo__c, SAC_Prorroga__c FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'NombreTareaTest0' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            reclamacion.Status = 'Cerrado';
            Database.update(reclamacion);

            SAC_Accion__c tareaInsert = new SAC_Accion__c();
            tareaInsert.SAC_Observaciones__c = 'tareaTest';
            tareaInsert.SAC_PlazoMaximo__c = 10;
            tareaInsert.SAC_Prorroga__c = 5;
            tareaInsert.OwnerId = usuario.id;
            tareaInsert.SAC_MaestroAccionesReclamacion__c = mAccionesRec.Id;
            tareaInsert.SAC_Reclamacion__c = reclamacion.Id;
            tareaInsert.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            Database.insert(tareaInsert);

        }

        Case reclamacionResult = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        Assert.areNotEqual(reclamacion.Status, reclamacionResult.Status, 'no se ha reabierto la reclamación');
        Test.stopTest();
    }

    @isTest
    static void crearThreadIdTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c mAccionesRec = [SELECT Id, SAC_Descripcion__c, SAC_EquipoResponsable__c, SAC_PlazoMaximo__c, SAC_Prorroga__c FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'NombreTareaTest0' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            mAccionesRec.Name = 'GENERAL PARA OFICINAS';
            mAccionesRec.SAC_DeveloperName__c = 'SPV_GENERALOFICINAS';
            Database.update(mAccionesRec);

            reclamacion.Status = 'Cerrado';
            Database.update(reclamacion);

            SAC_Accion__c tareaInsert = new SAC_Accion__c();
            tareaInsert.SAC_Observaciones__c = 'tareaTest';
            tareaInsert.SAC_PlazoMaximo__c = 10;
            tareaInsert.SAC_Prorroga__c = 5;
            tareaInsert.OwnerId = usuario.id;
            tareaInsert.SAC_MaestroAccionesReclamacion__c = mAccionesRec.Id;
            tareaInsert.SAC_Reclamacion__c = reclamacion.Id;
            tareaInsert.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            Database.insert(tareaInsert);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_IndexedThreadId__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tareaTest' LIMIT 1];
        Assert.areNotEqual(null, tareaResult.SAC_IndexedThreadId__c, 'no se ha reabierto la reclamación');
        Test.stopTest();
    }

    @isTest
    static void automatizarCasoAplicaTareaDelTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];
        Case reclamacion = [SELECT Id, SAC_NoAplicaTareas__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c mAccionesRec = [SELECT Id, SAC_Descripcion__c, SAC_EquipoResponsable__c, SAC_PlazoMaximo__c, SAC_Prorroga__c FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'NombreTareaTest0' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            Case pretension = new Case();
            pretension.SAC_Reclamacion__c = reclamacion.Id;
            pretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Pretension').getRecordTypeId();
            Database.insert(pretension);

            SAC_Accion__c tareaInsert = new SAC_Accion__c();
            tareaInsert.SAC_Observaciones__c = 'tareaTest';
            tareaInsert.SAC_PlazoMaximo__c = 10;
            tareaInsert.SAC_Prorroga__c = 5;
            tareaInsert.OwnerId = usuario.id;
            tareaInsert.SAC_MaestroAccionesReclamacion__c = mAccionesRec.Id;
            tareaInsert.SAC_Pretension__c = pretension.Id;
            Database.insert(tareaInsert);

            Database.delete(tareaInsert);
        }

        Case reclamacionResult = [SELECT Id, SAC_NoAplicaTareas__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        Assert.areNotEqual(false, reclamacionResult.SAC_NoAplicaTareas__c, 'no se ha actualizado el campo');
        Test.stopTest();
    }

    @isTest
    static void calculoImportesDeleteTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea1' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_ImporteAbonar__c = 10;
            tarea.SAC_ImporteResuelto__c = 10;
            Database.update(tarea);

            Database.delete(tarea);
        }

        Case reclamacionResult = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        Assert.areEqual(0, reclamacionResult.CC_Importe_Abonado__c, 'no se ha reclalculado el importe');
        Test.stopTest();
    }

    @isTest
    static void finalizarTareaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea3' LIMIT 1];

        Test.startTest();

        System.runAs(usuario) {
            tarea.SAC_Estado__c = 'SAC_Finalizada';
            Database.update(tarea);
        }

        SAC_Accion__c tarearesult = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea3' LIMIT 1];
        Assert.areEqual(tarea.SAC_Estado__c, tarearesult.SAC_Estado__c, 'no se ha finalizado la tarea');
        Test.stopTest();
    }
}