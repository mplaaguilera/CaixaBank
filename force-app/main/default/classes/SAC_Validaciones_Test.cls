/*****************************************************************
 * Name: SAC_Validaciones_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Validaciones
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US242669         Carlos Solis         30/06/21     Creación
 * 1.1            US342617         Marcela Neira        03/03/2022   Modificación
 * 1.2            US356803         Alex Perez           19/10/2022   clase test validacionEscaladoTarea
 * 1.3            US593664         Jose Carlos Blanco  	17/05/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_Validaciones_Test {
    @TestSetup
    static void makeData(){

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];    
        SAC_DatabaseDML.insertDML(usuarioAdmin, false); 
        //Database.insert(usuarioAdmin);
        
        
        User usuarioGeneral;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            SAC_DatabaseDML.insertDML(usuarioGeneral, false); 
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false); 
            //Database.insert(permiSetAssi);
        }

        Test.startTest();
        // MCCs
        String recordTypeIdMCCSAC = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        List<CC_MCC__c> listaMCC = new List<CC_MCC__c>();
        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Banca Electrónica', CC_Codigo_Externo__c='d', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');        
        CC_MCC__c mccGGH = new CC_MCC__c(Name='GGH',  CC_Codigo_Externo__c='ggh',   RecordTypeId=recordTypeIdMCCSAC,  CC_Tipo_Cliente__c='SAC', SAC_esGGH__c=True);
        listaMCC.add(mccDetalle);
        listaMCC.add(mccGGH);
        SAC_DatabaseDML.insertListDML(listaMCC, false); 
        //Database.insert(listaMCC);

        // Cuenta
        Account a = SAC_TestDataFactory.crearCuentas(1)[0];
        a.Name = 'test';
        SAC_DatabaseDML.insertDML(a, true); 
        //Database.insert(a);

        // Casos
        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();

        // Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuarioGeneral.id);
        camposRecl.put('AccountId', a.id);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');

        Case casoReclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(casoReclamacion1);

        // Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('OwnerId', usuarioGeneral.id);
        camposRecl2.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposRecl2.put('AccountId', a.id);
        camposRecl2.put('SAC_TipoConsumidor__c', 'Si');

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        listaReclamaciones.add(casoReclamacion2);

        // Reclamacion
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('Status', 'SAC_002');
        camposRecl3.put('OwnerId', usuarioGeneral.id);
        camposRecl3.put('AccountId', a.id);
        camposRecl3.put('SAC_TipoConsumidor__c', 'Si');

        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        listaReclamaciones.add(casoReclamacion3);

        // Reclamacion GGH
        Map<String, Object> camposReclGGH = new Map<String, Object>();
        camposReclGGH.put('Subject', 'GGH');
        camposReclGGH.put('Status', 'SAC_001');
        camposReclGGH.put('OwnerId', usuarioGeneral.id);
        camposReclGGH.put('SEG_Detalle__c', mccGGH.Id);
        camposReclGGH.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposReclGGH.put('SAC_TipoConsumidor__c', 'Si');

        Case casoReclaGGH = SAC_TestDataFactory.crearCaso('Reclamacion',camposReclGGH);
        listaReclamaciones.add(casoReclaGGH);

        // Reclamacion Entidad
        Map<String, Object> camposReclEnt = new Map<String, Object>();
        camposReclEnt.put('Subject', 'TestEntidad');
        camposReclEnt.put('Origin', 'Backoffice');
        camposReclEnt.put('Status', 'Cerrado');
        camposReclEnt.put('OwnerId', usuarioGeneral.id);
        camposReclEnt.put('AccountId', a.id);
        camposReclEnt.put('SAC_TipoConsumidor__c', 'Si');
        camposReclEnt.put('OS_Fecha_Resolucion__c', system.now());

        Case casoReclamacionEntidad = SAC_TestDataFactory.crearCaso('Reclamacion',camposReclEnt);
        listaReclamaciones.add(casoReclamacionEntidad);
 
        SAC_DatabaseDML.insertListDML(listaReclamaciones, true); 

        Map<String, Object> camposReclVinc = new Map<String, Object>();
        List<Case> listaComplementariasVinculadas = new List<Case>();
        camposReclVinc.clear();
        camposReclVinc.put('Subject', 'ComplementariaVinculada');
        camposReclVinc.put('Origin', 'Otros');
        camposReclVinc.put('Status', 'SAC_001');
        camposReclVinc.put('SAC_TipoConsumidor__c', 'No');
        camposReclVinc.put('SAC_Naturaleza__c', 'SAC_007');
        camposReclVinc.put('CC_Importe_Abonado__c', 5.0);
        camposReclVinc.put('OwnerId', usuarioGeneral.id);
        Case casoReclamacion8 = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclVinc);
        listaComplementariasVinculadas.add(casoReclamacion8);

        //Esta tiene naturaleza: reclamación, para en un método cambiarla ahí por Complementaria
        camposReclVinc.clear();
        camposReclVinc.put('Subject', 'ComplementariaVinculada2');
        camposReclVinc.put('Origin', 'Otros');
        camposReclVinc.put('Status', 'SAC_002');
        camposReclVinc.put('SAC_TipoConsumidor__c', 'No');
        camposReclVinc.put('SAC_Naturaleza__c', 'SAC_007');
        camposReclVinc.put('CC_Importe_Abonado__c', 10.0);
        //camposReclVinc.put('CC_CasoRelacionado__c', casoReclamacion2.Id);
        camposReclVinc.put('OwnerId', usuarioGeneral.id);
        Case casoReclamacion9 = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclVinc);
        listaComplementariasVinculadas.add(casoReclamacion9);

        //Esta tiene naturaleza: reclamación, para en un método cambiarla ahí por Complementaria
        camposReclVinc.clear();
        camposReclVinc.put('Subject', 'ComplementariaVinculada3');
        camposReclVinc.put('Origin', 'Otros');
        camposReclVinc.put('Status', 'SAC_003');
        camposReclVinc.put('SAC_TipoConsumidor__c', 'No');
        camposReclVinc.put('SAC_Naturaleza__c', 'SAC_007');
        camposReclVinc.put('CC_Importe_Abonado__c', 10.0);
        camposReclVinc.put('CC_CasoRelacionado__c', casoReclamacion2.Id);
        camposReclVinc.put('OwnerId', usuarioGeneral.id);
        camposReclVinc.put('OS_Fecha_Resolucion__C', system.now());
        Case casoReclamacion10 = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclVinc);
        listaComplementariasVinculadas.add(casoReclamacion10);

        SAC_DatabaseDML.insertListDML(listaComplementariasVinculadas, false);


        //Database.insert(listaReclamaciones);

        // Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('OwnerId', usuarioGeneral.id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion1.Id);
        camposPret.put('SEG_Detalle__c', mccDetalle.Id);
        camposPret.put('SuppliedCompany', 'casoPretension1');
        camposPret.put('SAC_Entidad_Afectada__c', 'SAC_007');

        Case casoPretension1 = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension1);

        // Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('OwnerId', usuarioGeneral.id);
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret2.put('SEG_Detalle__c', mccDetalle.Id);
        //camposPret2.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposPret2.put('SAC_NoAplicaTareas__c', false);
        camposPret2.put('SuppliedCompany', 'casoPretension2');

        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
        listaPretensiones.add(casoPretension2);

        // Pretension 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('Origin', 'Backoffice');
        camposPret3.put('Status', 'SAC_002');
        camposPret3.put('OwnerId', usuarioGeneral.id);
        camposPret3.put('SAC_Reclamacion__c', casoReclamacion3.Id);
        camposPret3.put('SEG_Detalle__c', mccDetalle.Id);
        camposPret3.put('SAC_NoAplicaTareas__c', false);
        camposPret3.put('SuppliedCompany', 'casoPretension3');

        Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);
        listaPretensiones.add(casoPretension3);

        // Pretension 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('Origin', 'Backoffice');
        camposPret4.put('Status', 'SAC_002');
        camposPret4.put('OwnerId', usuarioGeneral.id);
        camposPret4.put('SAC_Reclamacion__c', casoReclamacion9.Id);
        camposPret4.put('SEG_Detalle__c', mccDetalle.Id);
        camposPret4.put('SAC_NoAplicaTareas__c', false);
        camposPret4.put('SuppliedCompany', 'casoPretension4');

        Case casoPretension4 = SAC_TestDataFactory.crearCaso('Pretension',camposPret4);
        listaPretensiones.add(casoPretension4);

        // Pretension GGH
        Map<String, Object> camposPretGGH = new Map<String, Object>();
        camposPretGGH.put('Origin', 'Backoffice');
        camposPretGGH.put('Status', 'SAC_001');
        camposPretGGH.put('OwnerId', usuarioGeneral.id);
        camposPretGGH.put('SAC_Reclamacion__c', casoReclaGGH.Id);
        camposPretGGH.put('SEG_Detalle__c', mccGGH.Id);
        camposPretGGH.put('SAC_SentidoResolucion__c', 'SAC_001');

        Case casoPreteGGH = SAC_TestDataFactory.crearCaso('Pretension',camposPretGGH);
        listaPretensiones.add(casoPreteGGH);

        // Pretension Entidad
        Map<String, Object> camposPretEnt = new Map<String, Object>();
        camposPretEnt.put('Origin', 'Backoffice');
        camposPretEnt.put('Status', 'Cerrado');
        camposPretEnt.put('OwnerId', usuarioGeneral.id);
        camposPretEnt.put('SAC_Reclamacion__c', casoReclamacionEntidad.Id);
        camposPretEnt.put('SEG_Detalle__c', mccDetalle.Id);
        camposPretEnt.put('SuppliedCompany', 'casoPreteEntidad');
        camposPretEnt.put('SAC_Entidad_Afectada__c', 'SAC_008');
        camposPretEnt.put('SAC_EntidadProductora__c', 'Otras empresas ajenas al grupo CXB');

        Case casoPreteEntidad = SAC_TestDataFactory.crearCaso('Pretension',camposPretEnt);
        listaPretensiones.add(casoPreteEntidad);

        SAC_DatabaseDML.insertListDML(listaPretensiones, true); 
        //Database.insert(listaPretensiones);
        Test.stopTest();

        // Parametrizacion escalado
        Map<String, Object> camposParam = new Map<String, Object>();
        camposParam.put('Name', 'Validacion Escalado COPS');
        camposParam.put('Aplica_escalado__c', true);
        camposParam.put('SAC_Importe__c', 200);
        camposParam.put('SAC_Mensaje__c', 'Mensaje');
        camposParam.put('SAC_todosMCCs__c', true);
        camposParam.put('SAC_TodosDespachos__c', true);
        camposParam.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado = SAC_TestDataFactory.crearParamEsc(camposParam);
        SAC_DatabaseDML.insertDML(parametrizacionEscalado, true); 
        //Database.insert(parametrizacionEscalado);

        // Escalado
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_CasoEscalado__c', casoReclamacion2.Id);
        camposEsc.put('SAC_Email1__c', 'testing@test.test');
        camposEsc.put('SAC_Estado__c', 'SAC_Atendida');
        camposEsc.put('SAC_ImporteAutorizado__c', 100.0);
        
        SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
        SAC_DatabaseDML.insertDML(escalado, true); 
        //Database.insert(escalado);

        List<SAC_MaestroTemas__c> controlAlta = SAC_TestDataFactory.crearMaestroTemas(1, 'SAC_ControlAltas');
		SAC_DatabaseDML.insertListDML(controlAlta, false);

        SAC_Marca_Case__c controlAltaCaso = new SAC_Marca_Case__c();
		controlAltaCaso.SAC_Case__c = casoReclamacion2.Id;
		controlAltaCaso.SAC_Marca__c = controlAlta[0].id;
        SAC_DatabaseDML.insertDML(controlAltaCaso, false);

        // Tareas
        System.runAs(usuarioGeneral){
            List<SAC_Accion__c> listaTareas = SAC_TestDataFactory.crearTareas(2, casoReclamacion2, false);
            listaTareas[0].SAC_ImporteResuelto__c=300.0;
            listaTareas[0].SAC_ImporteAbonar__c=150.0;
            listaTareas[0].SAC_ImpResueltoInteresesLegales__c=150.0;
            listaTareas[1].SAC_ImporteResuelto__c=300.0;
            listaTareas[1].SAC_ImporteAbonar__c=150.0;
            listaTareas[1].SAC_ImpResueltoInteresesLegales__c=150.0;
            SAC_DatabaseDML.insertListDML(listaTareas, true); 
            //Database.insert(listaTareas);

            // Tareas Pretension 2
            List<SAC_Accion__c> listaTareasPret2 = SAC_TestDataFactory.crearTareas(2, casoPretension2, false);
            SAC_DatabaseDML.insertListDML(listaTareasPret2, true); 
            //Database.insert(listaTareasPret2);
        }
    }


    @isTest
    public static void validarComplementariaVinculadaTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'ComplementariaVinculada'];
        Boolean hayError = false;
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];

        Test.startTest();
        System.runAs(usuario){
            try {
                complementaria.Status = 'SAC_002';
                SAC_DatabaseDML.updateDML(complementaria, true);
            } catch (Exception e) {
                hayError = true;
            }  

        }
        Assert.areEqual(true, hayError, 'No ha saltado la validación de complementaria.');
        Test.stopTest();
    }

    @isTest
    public static void validarComplementariaAnalisisResolucionTest(){
        Case pretension = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'casoPretension4'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'ComplementariaVinculada2'];
        Boolean hayError = false;
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];

        Test.startTest();
        System.runAs(usuario){
            try {
                pretension.Status = 'SAC_003';
                SAC_DatabaseDML.updateDML(pretension, true);
            } catch (Exception e) {
                hayError = true;
            }  

        }
        Assert.areEqual(true, hayError, 'No ha saltado la validación de complementaria.');
        Test.stopTest();
    }

    @isTest
    public static void validarResolverComplementariasTest(){
        Case pretension = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'casoPretension4'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'ComplementariaVinculada2'];
        Boolean hayError = false;
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];

        Test.startTest();
        System.runAs(usuario){
            try {
                complementaria.OS_Fecha_Resolucion__c = system.now();
                SAC_DatabaseDML.updateDML(complementaria, true);
            } catch (Exception e) {
                hayError = true;
            }  

        }
        Assert.areEqual(true, hayError, 'No ha saltado la validación de complementaria.');
        Test.stopTest();
    }

    @isTest
    public static void validarCambioNaturalezaComplementariaResueltaTest(){
        Case pretension = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'casoPretension4'];
        Case complementaria = [SELECT Id, Status, CC_Importe_Abonado__c FROM Case WHERE Subject = 'ComplementariaVinculada3'];
        Boolean hayError = false;
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];

        Test.startTest();
        System.runAs(usuario){
            try {
                complementaria.SAC_Naturaleza__c = 'SAC_006';
                SAC_DatabaseDML.updateDML(complementaria, true);
            } catch (Exception e) {
                hayError = true;
            }  

        }
        Assert.areEqual(true, hayError, 'No ha saltado la validación de complementaria.');
        Test.stopTest();
    }


    @isTest
    static void validarMCCYPretPrincipalTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, subject, Status FROM Case WHERE subject = 'TestRec2' limit 1];
        Case pretension = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c FROM Case WHERE SuppliedCompany = 'casoPretension2' limit 1];

        caso.Status = 'SAC_002';
        caso.SAC_StatusAuxiliar__c = 'SAC_002';

        Test.startTest();
        System.runAs(usuario){
            SAC_DatabaseDML.updateDML(caso, true); 
            //Database.update(caso);
        }
        Test.stopTest();

        caso = [SELECT Id, Subject, Status, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'TestRec2' limit 1];
        
        Assert.areEqual(pretension.Id, caso.SAC_PretensionPrincipal__c, 'No se ha podido asignar la pretension principal');
    }

    @isTest
    static void validacionSentidoResolucionTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError = false;
        Case caso = [SELECT id, subject, Status, SAC_SentidoResolucion__c FROM Case WHERE subject = 'TestRec2' limit 1];
        Case pretension = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c, SAC_SentidoResolucion__c FROM Case WHERE SuppliedCompany = 'casoPretension2' limit 1];

        caso.SAC_SentidoResolucion__c = 'SAC_002';

        Test.startTest();
        System.runAs(usuario){
            try {
                SAC_DatabaseDML.updateDML(caso, true); 
                //Database.update(caso);
            } catch (Exception e) {
                hayError = true;
            }  
        }       
        Test.stopTest();

        Assert.areEqual(true, hayError, 'No ha saltado la validación de sentido de resolución.');
    }

    @isTest
    static void validarListoParaEnviarTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError;
        Case caso = [SELECT id, subject, Status FROM Case WHERE subject = 'TestRec2' limit 1];
        Case pretension = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c FROM Case WHERE SuppliedCompany = 'casoPretension2' limit 1];
        pretension.SAC_Redaccion__c = 'prueba redaccion';
        pretension.SAC_RedaccionFinal__c=true;
        pretension.SAC_SentidoResolucion__c = '';

        Test.startTest();
        System.runAs(usuario){
            try {
                SAC_DatabaseDML.updateDML(pretension, true); 
                //Database.update(pretension); 
            } catch (Exception e) {
                hayError=true;
            }
        }
        Test.stopTest();

        Assert.areEqual(true, hayError, 'No ha saltado la validación del sentido de resolución');
    }

    @isTest
    static void validarCheckTareasTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError;
        Case caso = [SELECT id, subject, Status FROM Case WHERE subject = 'TestRec2' limit 1];
        Case pretension = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c, SAC_NoAplicaTareas__c FROM Case WHERE SuppliedCompany = 'casoPretension2' limit 1];
        pretension.SAC_NoAplicaTareas__c = true;

        Test.startTest();
        System.runAs(usuario){
            try {
                SAC_DatabaseDML.updateDML(pretension, true); 
                //Database.update(pretension);
            } catch (Exception e) {
                hayError = true;
            }
        }
        Test.stopTest();   
        
        Assert.areEqual(true, hayError, 'No ha saltado la validación del check de tareas');
    }

    @isTest
    static void validarCasoEspecialTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, subject, Status FROM Case WHERE subject = 'TestRec2' limit 1];
        caso.Status = 'SAC_002';
        caso.SAC_StatusAuxiliar__c = 'SAC_002';
        caso.SAC_CasoEspecial__c = 'SAC_Sensible';

        Test.startTest();
        System.runAs(usuario){
            SAC_DatabaseDML.updateDML(caso, true); 
            //Database.update(caso);
        }
        Test.stopTest();

        Case casoResult = [SELECT id, subject, Status, SAC_CasoEspecial__c FROM Case WHERE subject = 'TestRec2' limit 1];

        Assert.areEqual('SAC_Sensible', casoResult.SAC_CasoEspecial__c, 'No se ha podido insertar el caso especial');
    }
    
        @isTest
    static void validarAltaAnalisisRechazarTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, subject, Status FROM Case WHERE subject = 'TestRec2' limit 1];
        caso.Status = 'Rechazado';
        caso.SAC_StatusAuxiliar__c = 'Rechazado';
        caso.SAC_MotivoRechazo__c = 'Spam';
        caso.CC_Importe_Abonado__c = 0;

        Test.startTest();
        System.runAs(usuario){
            SAC_DatabaseDML.updateDML(caso, true); 
            //Database.update(caso);
        }
        Test.stopTest();

        Case casoResult = [SELECT id, subject, Status, SAC_CasoEspecial__c FROM Case WHERE subject = 'TestRec2' limit 1];
        Assert.areEqual('Rechazado', casoResult.Status, 'No se ha podido actualizar el estado');
    }

    @istest
    static void validarImportesReclamadosTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, subject, Status FROM Case WHERE Subject = 'GGH' limit 1];
        Account cuenta = [SELECT id FROM Account WHERE Name = 'test'];
        Boolean hayError = false;

        Test.startTest();
        System.runAs(usuario){
            try {
                caso.AccountId = cuenta.id;
                caso.Status = 'SAC_002';
                caso.SAC_StatusAuxiliar__c = caso.Status;
                SAC_DatabaseDML.updateDML(caso, true); 
                //Database.update(caso);
            } catch (Exception e) {
                hayError = true;
            } 
        }
        Test.stopTest();
        Assert.areEqual(true, hayError, 'No ha validado los importes reclamados');
    }    
    @istest 
    static void comprobarReclamacionesVinculadasTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, subject, Status FROM Case WHERE subject = 'TestRec' limit 1];
        Boolean hayError = false;
        
        Test.startTest();
        System.runAs(usuario){
            try{
                caso.Status = 'Rechazado';
                caso.SAC_StatusAuxiliar__c = caso.Status;
                caso.SAC_MotivoRechazo__c = 'Rechazada por vinculacion';
                SAC_DatabaseDML.updateDML(caso, true); 
                //Database.update(caso);
            } catch (Exception e) {
                hayError = true;
            }  
        }    
        Test.stopTest();
        Assert.areEqual(true, hayError, 'No ha cambiado el estado');
    }
    
    @istest 
    static void validarComentarioRechazoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, subject, Status,Comments,SAC_MotivoRechazo__c,SAC_StatusAuxiliar__c,CC_Rechazar_Reabrir_Caso__c FROM Case WHERE subject = 'TestRec2' limit 1];
        Boolean hayError = false;
        
        Test.startTest();
        System.runAs(usuario){
            try{
                caso.Status = 'Rechazado';
                caso.SAC_StatusAuxiliar__c = caso.Status;
                caso.SAC_MotivoRechazo__c = 'Otros';
                caso.Comments = null;
                caso.CC_Rechazar_Reabrir_Caso__c = true;
                SAC_DatabaseDML.updateDML(caso, true); 
                //Database.update(caso);
            } catch (Exception e) {
                hayError = true;
            }  
        }    
        Test.stopTest();
        Assert.areEqual(true, hayError, 'No ha cambiado el estado');
    }

    @istest 
    static void comprobarReclamAltaErroneaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError= false;
        Case caso = [SELECT id, subject, Status,Comments,SAC_MotivoRechazo__c,SAC_StatusAuxiliar__c,CC_Rechazar_Reabrir_Caso__c 
                    FROM Case 
                    WHERE subject = 'TestRec' limit 1];

        caso.SAC_MotivoRechazo__c = 'SAC_AltaErronea';
        
        Test.startTest();
        System.runAs(usuario){
            try{
                SAC_DatabaseDML.updateDML(caso, true); 
                //Database.update(caso);
            } catch (Exception e) {
                hayError = true;
            } 
        }
        Test.stopTest();     

        Assert.areEqual(true, hayError, 'No ha cambiado el estado');
    }

    @istest 
    static void validarEscaladoEnvioTareaOK() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id FROM Case WHERE subject = 'TestRec' limit 1]; 
        String error;

        Test.startTest();
        System.runAs(usuario){
            error = SAC_Validaciones.validarEscaladoEnvioTarea(null, caso.Id, '');
        }
        Test.stopTest();
        Assert.areEqual(error, '', 'la validación debería ser OK con la cadena de error vacía');
    }

    @istest 
    static void validarEscaladoEnvioTareaKOEscalado() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String error;
        Case caso = [SELECT id, SAC_Importe_Resuelto__c FROM Case WHERE subject = 'TestRec' limit 1]; 
        caso.SAC_Importe_Resuelto__c = 300;
        SAC_DatabaseDML.updateDML(caso, true); 
        //Database.update(caso);

        Test.startTest();
        System.runAs(usuario){
            error = SAC_Validaciones.validarEscaladoEnvioTarea(null, caso.Id, '');
        }
        Test.stopTest();
        Assert.areEqual(error, 'Se necesita escalar la reclamación ya que el importe facultades ha sido superado. Mensaje', 'El error no concuerda');
    }

    @istest 
    static void validarEscaladoEnvioTareaKOEscaSup() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String error;
        Case caso = [SELECT id, SAC_Importe_Resuelto__c FROM Case WHERE subject = 'TestRec2' limit 1]; 
        caso.SAC_Importe_Resuelto__c = 300;
        SAC_DatabaseDML.updateDML(caso, true); 
        //Database.update(caso);

        Test.startTest();
        System.runAs(usuario){
            error = SAC_Validaciones.validarEscaladoEnvioTarea(null, caso.Id, '');
        }
        Test.stopTest();
        Assert.areEqual(error, 'La suma de los importes resueltos de las tareas asociadas a la reclamación son mayores que el importe resuelto de la misma', 'El error no concuerda');
    }

    @istest 
    static void validarEscaladoEnvioTareaKOCasEspNoEsc() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String error;
        Case caso = [SELECT id, SAC_Importe_Resuelto__c, SAC_CasoEspecial__c FROM Case WHERE subject = 'TestRec' limit 1]; 
        caso.SAC_CasoEspecial__c = 'SAC_Presidencia';
        SAC_DatabaseDML.updateDML(caso, true); 
        //Database.update(caso);

        Test.startTest();
        System.runAs(usuario){
            error = SAC_Validaciones.validarEscaladoEnvioTarea(null, caso.Id, '');
        }
        Test.stopTest();
        Assert.areEqual(error, 'Caso especial ALTA DIRECCIÓN(se necesita escalado)', 'El error no concuerda');
    }

    @istest 
    static void validarEscaladoEnvioTareaKOSumaResu() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String error;
        Case caso = [SELECT id, SAC_Importe_Resuelto__c, SAC_CasoEspecial__c FROM Case WHERE subject = 'TestRec2' limit 1]; 
        caso.SAC_Importe_Resuelto__c = 100;
        SAC_DatabaseDML.updateDML(caso, true); 
        //Database.update(caso);

        Test.startTest();
        System.runAs(usuario){
            error = SAC_Validaciones.validarEscaladoEnvioTarea(null, caso.Id, '');
        }
        Test.stopTest();
        Assert.areEqual(error, 'La suma de los importes resueltos de las tareas asociadas a la reclamación son mayores que el importe resuelto de la misma', 'El error no concuerda');
    }

    @istest 
    static void validarEscaladoEnvioTareaKOCasSumaAbo() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String error;
        Case caso = [SELECT id, SAC_Importe_Resuelto__c, SAC_CasoEspecial__c FROM Case WHERE subject = 'TestRec2' limit 1]; 
        list<SAC_Accion__c> tareas = [SELECT Id, OwnerId, SAC_Estado__c, SAC_Pretension__c, SAC_Reclamacion__c, Name, SAC_EquipoResponsable__c,
                            SAC_Reclamacion__r.SAC_CasoEspecial__c, SAC_Reclamacion__r.SAC_Entidad_Afectada__c, SAC_Reclamacion__r.SEG_Grupo__c,
                            SAC_ImporteResuelto__c, SAC_Reclamacion__r.CC_Importe_Reclamado__c, SAC_Reclamacion__r.SAC_Importe_Resuelto__c,
                            SAC_ImporteAbonar__c, SAC_ImpResueltoInteresesLegales__c
                            FROM SAC_Accion__c WHERE SAC_Reclamacion__c = : caso.Id];
   
        Test.startTest();
        System.runAs(usuario){
            for(SAC_Accion__c tarea : tareas) {
                tarea.SAC_ImporteResuelto__c = 50;
            }
            SAC_DatabaseDML.updateListDML(tareas, true); 
            //Database.update(tareas);
            caso.SAC_Importe_Resuelto__c = 100;
            caso.CC_Importe_Abonado__c = 300;
            SAC_DatabaseDML.updateDML(caso, true); 
            //Database.update(caso);

            error = SAC_Validaciones.validarEscaladoEnvioTarea(null, caso.Id, '');
        }
        Test.stopTest();
        Assert.areEqual(error, 'La suma de los importes resueltos de las tareas asociadas a la reclamación son mayores que el importe resuelto de la misma', 'El error no concuerda');
    }

    @istest 
    static void validarControlAltasTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String error;
        Case caso = [SELECT id, Status FROM Case WHERE subject = 'TestRec2' limit 1]; 
   
        Test.startTest();
        System.runAs(usuario){
            List<Case> listCase = new List<Case>();
            listCase.add(caso);
            SAC_Validaciones.validarControlAlta(listCase, false);
        }
        Test.stopTest();

        Assert.areEqual('SAC_001', caso.Status, 'Error al validar los campos de control de altas');
    }

    @isTest
    static void validarImporteAbonadoTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError = false;
        Case caso = [SELECT id, subject, Status, SAC_SentidoResolucion__c FROM Case WHERE subject = 'TestRec2' limit 1];

        caso.SAC_SentidoResolucion__c = 'SAC_005';
        caso.CC_Importe_Abonado__c = 2;

        Test.startTest();
        System.runAs(usuario){
            try {
                SAC_DatabaseDML.updateDML(caso, true); 
            } catch (Exception e) {
                hayError = true;
            }  
        }       
        Test.stopTest();

        Assert.areEqual(true, hayError, 'No ha saltado la validación de sentido de resolución.');
    }

    @isTest
    static void validarImporteAbonadoTest2(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError = false;
        Case pretension = [SELECT Id, CC_Importe_Abonado__c FROM Case WHERE SuppliedCompany = 'casoPretension2' limit 1];
        pretension.CC_Importe_Abonado__c = 2;

        Test.startTest();
        System.runAs(usuario){
            try {
                SAC_DatabaseDML.updateDML(pretension, true); 
            } catch (Exception e) {
                hayError = true;
            }  
        }       
        Test.stopTest();

        Assert.areEqual(true, hayError, 'No ha saltado la validación de sentido de resolución.');
    }

    @isTest
    static void validarImporteAbonadoTest3(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError = false;
        Case pretension = [SELECT Id, CC_Importe_Abonado__c FROM Case WHERE SuppliedCompany = 'casoPretension2' limit 1];
        pretension.CC_Importe_Abonado__c = 2;
        pretension.SAC_SentidoResolucion__c = 'SAC_001';

        Test.startTest();
        System.runAs(usuario){
            try {
                SAC_DatabaseDML.updateDML(pretension, true); 
            } catch (Exception e) {
                hayError = true;
            }  
        }       
        Test.stopTest();

        Assert.areEqual(true, hayError, 'No ha saltado la validación de sentido de resolución.');
    }

    @isTest
    static void validarOficinaAfectada(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError = false;
        Case caso = [SELECT id, subject, Status, SAC_SentidoResolucion__c FROM Case WHERE subject = 'TestRec3' limit 1];

        Test.startTest();
        System.runAs(usuario){
            try {
                caso.Status = 'SAC_003';
                caso.SAC_StatusAuxiliar__c = caso.Status;
                SAC_DatabaseDML.updateDML(caso, true); 
            } catch (Exception e) {
                hayError = true;
            }  
        }       
        Test.stopTest();

        Assert.areEqual(true, hayError, 'No ha saltado la validación de oficina.');
    }

    @isTest
    static void validarOficinaAfectada2(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Boolean hayError = false;
        Case pretension = [SELECT Id, CC_Importe_Abonado__c FROM Case WHERE SuppliedCompany = 'casoPretension3' limit 1];

        Test.startTest();
        System.runAs(usuario){
            try {
                pretension.Status = 'SAC_003';
                pretension.SAC_StatusAuxiliar__c = pretension.Status;
                SAC_DatabaseDML.updateDML(pretension, true); 
            } catch (Exception e) {
                hayError = true;
            }  
        }       
        Test.stopTest();

        Assert.areEqual(true, hayError, 'No ha saltado la validación de oficina.');
    }
}