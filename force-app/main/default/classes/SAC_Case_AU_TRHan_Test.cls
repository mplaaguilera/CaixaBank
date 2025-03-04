/*****************************************************************
 * Name: SAC_Case_AU_TRHan_Test
 * Copyright © 2019  CaixaBank
 *
 * Proposito: Testear la clase SAC_Case_AU_TRHan
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            N/A              Nicolás García       11/05/21     Creación
 * 1.1            N/A              Esteve Llaó          30/09/21     Modificación
 * 1.2            DE70413          Jose Carlos Blanco   10/01/23     Modificación
 * 1.3              ---            Jose Carlos Blanco  	12/09/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_Case_AU_TRHan_Test {
    @TestSetup
    static void makeData() {

        Set<String> objetos = new Set<String>{'CC_MCC__c'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id mccTematicaRecordTypeId = mapRTsObjects.get('CC_MCC__c').get('CC_Tematica').getRecordTypeId();
        Id mccProdServRecordTypeId = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
        Id mccMotivoRecordTypeId = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();
        Id mccDetalleRecordTypeId = mapRTsObjects.get('CC_MCC__c').get('SEG_Detalle').getRecordTypeId();

        User usuarioGeneral;
        User usuarioGeneral2;
        User usuarioAdmin;

        System.runAs(new User(Id = Userinfo.getUserId())) {

            //Usuario SAC General
            List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);

            usuarioGeneral = usuarios[0];
            usuarioGeneral2 = usuarios[1];
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);
            //Database.insert(usuarioGeneral);
            SAC_DatabaseDML.insertDML(usuarioGeneral2, false);
            //Database.insert(usuarioGeneral2);     

            //Usuario SAC Admin
            usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
            SAC_DatabaseDML.insertDML(usuarioAdmin, false);
            //Database.insert(usuarioAdmin);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
            //Database.insert(permiSetAssi);

            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = permiSet.Id;
            sea.SetupEntityId = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'SAC_ByPass'].Id;
            SAC_DatabaseDML.insertDML(sea, false);
            //Database.insert(sea);

            PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
            permiSetAssi2.AssigneeId = usuarioAdmin.Id;
            permiSetAssi2.PermissionSetId = permiSet2.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi2, false);
            //Database.insert(permiSetAssi2);

            PermissionSet permiSet3 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi3 = new PermissionSetAssignment();
            permiSetAssi3.AssigneeId = usuarioGeneral2.Id;
            permiSetAssi3.PermissionSetId = permiSet3.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi3, false);
            //Database.insert(permiSetAssi3);
        }

        //Cuentas
        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(2);
        cuentas[0].name = 'cuentaTest';
        cuentas[1].name = 'cuentaTest2';
        SAC_DatabaseDML.insertListDML(cuentas, false);
        //Database.insert(cuentas);

        //Grupos
        Group grupo = SAC_TestDataFactory.crearGrupo(1)[0];
        grupo.name = 'grupoTest';
        SAC_DatabaseDML.insertDML(grupo, false);
        //Database.insert(grupo);

        //MCCs
        CC_MCC__c mccTematica = new CC_MCC__c(Name='Tematica', CC_Codigo_Externo__c='a', RecordTypeId=mccTematicaRecordTypeId, CC_Tipo_Cliente__c='Empleado');
        SAC_DatabaseDML.insertDML(mccTematica, false);
        //Database.insert(mccTematica);

        CC_MCC__c mccProdServ = new CC_MCC__c(Name='ProdServ',CC_Tematica__c = mccTematica.id , CC_Codigo_Externo__c='b', RecordTypeId=mccProdServRecordTypeId, CC_Tipo_Cliente__c='Cliente');
        SAC_DatabaseDML.insertDML(mccProdServ, false);
        //Database.insert(mccProdServ);

        CC_MCC__c mccMotivo = new CC_MCC__c(Name='Motivo',CC_Producto_Servicio__c = mccProdServ.id, CC_Codigo_Externo__c='c', RecordTypeId=mccMotivoRecordTypeId, CC_Tipo_Cliente__c='Cliente');
        SAC_DatabaseDML.insertDML(mccMotivo, false);
        //Database.insert(mccMotivo);

        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Detalle',CC_Motivo__c = mccMotivo.id, CC_Codigo_Externo__c='d', RecordTypeId=mccDetalleRecordTypeId, CC_Tipo_Cliente__c='Cliente');
        SAC_DatabaseDML.insertDML(mccDetalle, false);
        //Database.insert(mccDetalle);
		

        Test.startTest();
        List<Case> listaReclamaciones = new List<Case>();

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('CC_MCC_Tematica__c', mccTematica.Id);
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('SlaStartDate', system.today());
        camposRecl.put('SAC_FechaRecepcion__c', system.today().addDays(-1));
        camposRecl.put('SAC_DetenidoDesde__c', system.today().addDays(-1));
        camposRecl.put('SAC_DetenidoHasta__c', System.now());
        camposRecl.put('CC_Canal_Procedencia__c', 'Junta Andalucia');
        camposRecl.put('SAC_TipoConsumidor__c', 'No');
        camposRecl.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        listaReclamaciones.add(casoReclamacion);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestReclam');
        camposRecl2.put('SAC_TipoConsumidor__c', 'Sí');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('AccountId', cuentas[0].Id);
        camposRecl2.put('Status', 'SAC_010');
        camposRecl2.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl2.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
        listaReclamaciones.add(casoReclamacion2);

        //Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestReclamSub');
        camposRecl3.put('SAC_TipoConsumidor__c', 'Sí');
        camposRecl3.put('SAC_DetenidoDesde__c', system.today().addDays(-1));
        camposRecl3.put('SAC_DetenidoHasta__c', System.now());
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('AccountId', cuentas[0].Id);
        camposRecl3.put('Status', 'SAC_006');
        camposRecl3.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl3.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl3);
        listaReclamaciones.add(casoReclamacion3);

        //Reclamacion 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestReabrirRecl');
        camposRecl4.put('SAC_TipoConsumidor__c', 'Sí');
        camposRecl4.put('Origin', 'Backoffice');
        camposRecl4.put('AccountId', cuentas[0].Id);
        camposRecl4.put('Status', 'Cerrado');
        camposRecl4.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl4.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl4);
        listaReclamaciones.add(casoReclamacion4);

        //Reclamacion 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'TestCasoRel');
        camposRecl5.put('SAC_TipoConsumidor__c', 'Sí');
        camposRecl5.put('Origin', 'Backoffice');
        camposRecl5.put('AccountId', cuentas[0].Id);
        camposRecl5.put('Status', 'SAC_002');
        camposRecl5.put('CC_CasoRelacionado__c', casoReclamacion4.id);
        camposRecl5.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl5.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl5);
        listaReclamaciones.add(casoReclamacion5);

        SAC_DatabaseDML.insertListDML(listaReclamaciones, false);
        //Database.insert(listaReclamaciones);


        List<Case> listaPretensiones = new List<Case>();

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('SuppliedCompany', 'TestPret');
        camposPret.put('AccountId', cuentas[1].id);
        camposPret.put('SAC_FechaRecepcion__c', system.today().addDays(-1));
        camposPret.put('SEG_Detalle__c', mccTematica.id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('OwnerId', usuarioGeneral.id);
      
        Case pretensionPrincipal = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
        listaPretensiones.add(pretensionPrincipal);

        //Pretension 2
        Map<String, Object> camposPret2= new Map<String, Object>();
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('SuppliedCompany', 'TestPret2');
        camposPret2.put('SAC_FechaRecepcion__c', system.today().addDays(-1));
        camposPret2.put('SAC_DetenidoDesde__c', system.today().addDays(-1));
        camposPret2.put('SEG_Detalle__c', mccTematica.id);
        camposPret2.put('Status', 'SAC_006');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposPret2.put('SAC_TipoConsumidor__c', 'No');
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret2.put('OwnerId', usuarioGeneral.id);
      
        Case pretensionSecundaria = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);
        listaPretensiones.add(pretensionSecundaria);

        SAC_DatabaseDML.insertListDML(listaPretensiones, false);
        //Database.insert(listaPretensiones);  
		Test.stopTest();

        SAC_CaseReclamante__c reclamantePrin = SAC_TestDataFactory.crearReclamante(true, casoReclamacion, cuentas[0].id);
        SAC_DatabaseDML.insertDML(reclamantePrin, false);
        //Database.insert(reclamantePrin);

        System.runAs(usuarioGeneral){
        casoReclamacion.SAC_PretensionPrincipal__c = pretensionPrincipal.Id;
        SAC_DatabaseDML.updateDML(casoReclamacion, false);
        //Database.update(casoReclamacion);
        }
    }

    @isTest
    static void actualizacionCaso() {      
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'cuentaTest'];
        caso.Subject = 'Actualizado';
        //caso.AccountId = acc.Id;  

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }

        caso = [SELECT Id, CC_MCC_Tematica__c FROM Case WHERE Subject = 'Actualizado'];

        System.assertNotEquals(caso.CC_MCC_Tematica__c, null, 'No se ha igualado el MCC');
    }

    @isTest
    static void actualizacionPretension() {
        Id pretId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Case caso = [SELECT Id FROM Case WHERE SuppliedCompany = 'TestPret' ];
        Account acc = [SELECT Id FROM Account WHERE Name = 'cuentaTest'];
        caso.Subject = 'Actualizado';
        caso.AccountId = acc.Id;

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }

        caso = [SELECT Id, CC_MCC_Tematica__c,AccountId FROM Case WHERE Subject = 'Actualizado'];

        System.assertEquals(caso.AccountId, acc.Id, 'No se ha igualado el MCC');
    }


    @isTest
    static void testActualizarMcc() {
        Id recType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        
        Case prete = [SELECT Id FROM Case WHERE SuppliedCompany = 'TestPret'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'cuentaTest'];
        List<CC_MCC__c> mccs = new List<CC_MCC__c>();
        CC_MCC__c mccTematica = [SELECT id FROM CC_MCC__c WHERE name = 'Tematica'];
        CC_MCC__c mccDetalle = [SELECT id FROM CC_MCC__c WHERE name = 'Detalle'];
        CC_MCC__c mccProdServ = [SELECT id FROM CC_MCC__c WHERE name = 'ProdServ'];
        CC_MCC__c mccMotivo = [SELECT id FROM CC_MCC__c WHERE name = 'Motivo'];

        prete.Subject = 'Actualizado';
        prete.AccountId = acc.Id;
        prete.SEG_Detalle__c = mccDetalle.id;
        prete.CC_MCC_Tematica__c = mccTematica.id;
        prete.CC_MCC_ProdServ__c= mccProdServ.id;
        prete.CC_MCC_Motivo__c= mccMotivo.id;
        List<Case> casosQuery = new List<Case>();
        casosQuery.add(prete);
        List<Case> pretensiones = [SELECT id FROM Case WHERE RecordTypeId =: recType];
        Map<id,case> casosAct = new Map<Id,Case>();

        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(prete, false);
            //Database.update(prete);
            Test.stopTest();
        }
        prete = [SELECT Id, CC_MCC_Tematica__c FROM Case WHERE SuppliedCompany = 'TestPret'];
        System.assertNotEquals(prete.CC_MCC_Tematica__c, null, 'No se ha igualado el MCC');
    }

    @istest
    static void cambiarRTConsultas(){
        Id recordTypeConsul = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'cuentaTest'];
        caso.recordTypeId = recordTypeConsul;
        //caso.AccountId = acc.id;

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        Id recordTypeConsulta = [SELECT Id, RecordTypeId FROM Case WHERE Subject = 'TestRec'].recordTypeId;
        System.assertEquals(recordTypeConsul, recordTypeConsulta, 'No se ha cambiado el RT');
    }

    @istest
    static void cambiarResolucion(){
        Case caso = [SELECT Id, SAC_SentidoResolucion__c FROM Case WHERE Subject = 'TestRec'];
        Case pretension = [SELECT Id, SAC_SentidoResolucion__c FROM Case WHERE SuppliedCompany = 'TestPret'];
        Case casoOld = [SELECT Id, SAC_SentidoResolucion__c FROM Case WHERE Subject = 'TestRec'];
        Case pretensionOld = [SELECT Id, SAC_SentidoResolucion__c FROM Case WHERE SuppliedCompany = 'TestPret'];
        caso.SAC_SentidoResolucion__c = 'SAC_001';
        pretension.SAC_SentidoResolucion__c = 'SAC_001';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pretension, false);
            //Database.update(pretension);
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.SAC_SentidoResolucion__c, caso.SAC_SentidoResolucion__c, 'No se ha cambiado el sentido de la resolución.');
        System.assertNotEquals(pretensionOld.SAC_SentidoResolucion__c, pretension.SAC_SentidoResolucion__c, 'No se ha cambiado el sentido de la resolución.');    
    }

    @istest
    static void cambioPretension(){
        Case pret = [SELECT Id, CC_Importe_Abonado__c, Status, SAC_StatusAuxiliar__c 
                    FROM Case WHERE SuppliedCompany = 'TestPret'];
        Case pretOld = [SELECT Id, CC_Importe_Abonado__c, Status, SAC_StatusAuxiliar__c 
                       FROM Case WHERE SuppliedCompany = 'TestPret'];        
        pret.CC_Importe_Abonado__c = 10.0;
        pret.Status = 'SAC_009';
        pret.SAC_StatusAuxiliar__c = 'SAC_009';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pret, false);
            //Database.update(pret);
            Test.stopTest();
        }
        System.assertNotEquals(pretOld.CC_Importe_Abonado__c, pret.CC_Importe_Abonado__c, 'No se ha cambiado el importe.');
        System.assertNotEquals(pretOld.Status, pret.Status, 'No se ha cambiado el estado de la pretensión.');
        System.assertNotEquals(pretOld.SAC_StatusAuxiliar__c, pret.SAC_StatusAuxiliar__c, 'No se ha cambiado el estado de la pretensión.');
    } 

    @istest
    static void cambioBaja(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM case WHERE Subject = 'TestReclam'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM case WHERE Subject = 'TestReclam'];
        caso.Status = 'SAC_009';
        caso.SAC_StatusAuxiliar__c = 'SAC_009';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'No se ha cambiado el estado de la reclamación.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'No se ha cambiado el estado de la reclamación.');
    }

    @istest
    static void cambioNegociacion(){
        Case pret = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case Where SuppliedCompany = 'TestPret'];
        Case pretOld = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case Where SuppliedCompany = 'TestPret'];
        pret.Status = 'SAC_007';
        pret.SAC_StatusAuxiliar__c = 'SAC_007';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pret, false);
            //Database.update(pret);
            Test.stopTest();
        }
        System.assertNotEquals(pretOld.Status, pret.Status, 'No se ha cambiado el estado de la pretensión.');
        System.assertNotEquals(pretOld.SAC_StatusAuxiliar__c, pret.SAC_StatusAuxiliar__c, 'No se ha cambiado el estado de la pretensión.');
    }

    @istest
    static void vueltaSubsanacion(){
        Case pret = [SELECT Id, Status, SAC_StatusAuxiliar__c, SAC_TipoConsumidor__c, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'TestPret2'];
        Case pretOld = [SELECT Id, Status, SAC_StatusAuxiliar__c, SAC_TipoConsumidor__c, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'TestPret2'];
        pret.Status = 'SAC_002';
        pret.SAC_StatusAuxiliar__c = 'SAC_002';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pret, false);
            //Database.update(pret);
            Test.stopTest();
        }
        System.assertNotEquals(pretOld.Status, pret.Status, 'No se ha cambiado el estado de la pretensión.');
        System.assertNotEquals(pretOld.SAC_StatusAuxiliar__c, pret.SAC_StatusAuxiliar__c, 'No se ha cambiado el estado de la pretensión.');
    }

    @istest
    static void reclCerrada(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestRec'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestRec'];
        caso.Status = 'Cerrado';
        caso.SAC_StatusAuxiliar__c = 'Cerrado';

        Account cuenta = SAC_TestDataFactory.crearCuentasOficina(1)[0];
        SAC_DatabaseDML.insertDML(cuenta, false);
        //Database.insert(cuenta);
        
        caso.CC_Oficina_Afectada_Lookup__c = cuenta.id;
        SAC_DatabaseDML.updateDML(caso, false);
        //Database.update(caso);

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'No se ha cerrado la reclamación.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'No se ha cerrado la reclamación.');
    }

    @istest
    static void reclDerivacion(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestRec'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestRec'];
        caso.Status = 'SAC_008';
        caso.SAC_StatusAuxiliar__c = 'SAC_008';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'No se ha pasado la reclamación a derivación.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'No se ha pasado la reclamación a derivación.');
    }

    @istest
    static void reclSubsanacion(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c, SAC_TipoConsumidor__c FROM Case WHERE Subject = 'TestRec'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c, SAC_TipoConsumidor__c FROM Case WHERE Subject = 'TestRec'];
        caso.Status = 'SAC_006';
        caso.SAC_StatusAuxiliar__c = 'SAC_006';
        caso.SAC_TipoConsumidor__c = 'No';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'No se ha cambiado el estado de la reclamación.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'No se ha cambiado el estado de la reclamación.');
    }

    @istest
    static void reclNegociacion(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestRec'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestRec'];
        caso.Status = 'SAC_007';
        caso.SAC_StatusAuxiliar__c = 'SAC_007';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'La reclamación no se ha pasado a negociación.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'La reclamación no se ha pasado a negociación.');
    }

    @istest
    static void reclRechazada(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c, SAC_MotivoRechazo__c FROM Case WHERE Subject = 'TestRec'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c, SAC_MotivoRechazo__c FROM Case WHERE Subject = 'TestRec'];
        caso.Status = 'Rechazado';
        caso.SAC_StatusAuxiliar__c = 'Rechazado';
        caso.SAC_MotivoRechazo__c = 'Otros';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'No se ha rechazado la reclamación.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'No se ha rechazado la reclamación.');
    }

    @istest
    static void reclVueltaSubsanacion(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestReclamSub'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestReclamSub'];
        caso.Status = 'SAC_001';
        caso.SAC_StatusAuxiliar__c = 'SAC_001';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'La reclamación no ha vuelto a subsanación.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'La reclamación no ha vuelto a subsanación.');
    }

    @istest
    static void reabrirReclamacion(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestReabrirRecl'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE Subject = 'TestReabrirRecl'];
        caso.Status = 'SAC_002';
        caso.SAC_StatusAuxiliar__c = 'SAC_002';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'La reclamación no ha vuelto a subsanación.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'La reclamación no ha vuelto a subsanación.');
    }

    @istest
    static void consultasSAC(){
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec'];
        Case casoOld = [SELECT Id, Status, SAC_StatusAuxiliar__c, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec'];
        Case casoRel = [SELECT Id, Status, SAC_StatusAuxiliar__c, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestReclam'];
        Id recType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId(); 
        caso.recordTypeId = recType;
        caso.CC_CasoRelacionado__c = casoRel.id;
        caso.Status = 'SAC_006';
        caso.SAC_StatusAuxiliar__c = 'SAC_006';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoOld.Status, caso.Status, 'La reclamación no ha cambiado de estado.');
        System.assertNotEquals(casoOld.SAC_StatusAuxiliar__c, caso.SAC_StatusAuxiliar__c, 'La reclamación no ha cambiado de estado.');
        System.assertNotEquals(casoOld.CC_CasoRelacionado__c, caso.CC_CasoRelacionado__c, 'No se ha actualizado el caso relacionado.');
    }

    @istest
    static void cambioOwnerReclaToPret(){
        User userChangeOwner = [SELECT Id FROM User WHERE Username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case caso = [SELECT Id, Status, OwnerId FROM Case WHERE Subject = 'TestRec'];
        Case casoOld = [SELECT Id, Status, OwnerId FROM Case WHERE Subject = 'TestRec'];
        caso.Status = 'SAC_001';
        caso.OwnerId = userChangeOwner.Id;
        caso.SAC_GenialEstado__c = 'SAC_003';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        Case pretension = [SELECT Id, OwnerId FROM Case WHERE SAC_Reclamacion__c = :caso.Id LIMIT 1];
        System.assertNotEquals(casoOld.OwnerId, caso.OwnerId, 'Se ha modificado el owner');
        System.assertEquals(caso.OwnerId, pretension.OwnerId, 'Se ha cambiado el owner a las pretensiones hijas');
    }
}