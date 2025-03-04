/*****************************************************************
 * Name: SAC_LCMP_ForzarResolucion_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_ForzarResolucion.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US505370         Raúl Santos          08/03/2023   Creación
 * 1.1            US563153         Jose Carlos Blanco  	27/04/2023   Modificación (test modificada usando el SAC_TestDataFactory)       
*****************************************************************/

@isTest
public with sharing class SAC_LCMP_ForzarResolucion_Test {
    @TestSetup
    static void makeData(){
        
        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioGeneral.SAC_PerteneceCOPSAJ__c = true;
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);      
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);
        
        //Grupos
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
        grupo.Name = 'grupoTest';
        grupo.SAC_PermiteEscalado__c = true;
        grupo.SAC_NivelGrupo__c = 'SAC_Nivel2';
        grupo.SAC_Email__c = 'etesting@test.test';
        grupo.SAC_Email2__c = 'etesting1@test.test';
        grupo.SAC_Email3__c = 'etesting2@test.test';
        grupo.SAC_PeriodoConsulta__c = 12;
        grupo.SAC_PermiteConsultas__c = true;
        grupo.SAC_TieneUsuariosActivos__c = true;
        listaGrupos.add(grupo); 

        CC_Grupo_Colaborador__c grupoTareas = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
        grupoTareas.name = 'grupo de tareas';
        grupoTareas.SAC_DeveloperName__c = 'grupo de tareas';
        grupoTareas.SAC_PermiteTareas__c = true;
        listaGrupos.add(grupoTareas);

        System.runAs(usuarioGeneral){
            SAC_DatabaseDML.insertListDML(listaGrupos, false);
            //Database.insert(listaGrupos);

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestResolucion');
            camposRecl.put('Origin', 'Backoffice');
            camposRecl.put('Status', 'Alta');
            camposRecl.put('Status', 'Alta');
            camposRecl.put('OwnerId', usuarioGeneral.Id);

            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(casoReclamacion, false);
            //Database.insert(casoReclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'TestPret');
            camposPret.put('Origin', 'Backoffice');
            camposPret.put('Status', 'Alta');
            camposPret.put('SAC_StatusAuxiliar__c', 'Alta');
            camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
            camposPret.put('OwnerId', usuarioGeneral.Id);

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            SAC_DatabaseDML.insertDML(casoPretension, false);
            //Database.insert(casoPretension); 
            
            
            List<SAC_Interaccion__c> listaInteracciones = new List<SAC_Interaccion__c>();
            //Interaccion Escalado
            Map<String, Object> camposEsc = new Map<String, Object>();
            camposEsc.put('SAC_Titulo__c', 'propuesta test');
            camposEsc.put('SAC_Propuesta__c', 'propuesta test');
            camposEsc.put('SAC_CasoEscalado__c', casoReclamacion.Id);
            camposEsc.put('SAC_Email1__c', 'testing@test.test');
            camposEsc.put('OwnerId', usuarioGeneral.Id);
            camposEsc.put('SAC_GrupoColaborador__c', grupo.Id);
            camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
            
            SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
            listaInteracciones.add(escalado);

            //Interaccion Consulta
            Map<String, Object> camposCons = new Map<String, Object>();
            camposCons.put('SAC_Titulo__c', 'propuestaConsulta');
            camposCons.put('SAC_Propuesta__c', 'propuestaConsulta');
            camposCons.put('SAC_CasoEscalado__c', casoReclamacion.Id);
            camposCons.put('SAC_Email1__c', 'testing@test.test');
            camposCons.put('OwnerId', usuarioGeneral.Id);
            camposCons.put('SAC_GrupoColaborador__c', grupo.Id);
            camposCons.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
            
            SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
            listaInteracciones.add(consulta);

            SAC_DatabaseDML.insertListDML(listaInteracciones, false);
            //Database.insert(listaInteracciones);
            
            //Tarea
            SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1, casoReclamacion, false)[0];
            tarea.SAC_EquipoResponsable__c = grupoTareas.id;
            tarea.SAC_Observaciones__c = 'tarea'; 

            SAC_DatabaseDML.insertDML(tarea, false);
            //Database.insert(tarea);
        }  
    }

    @isTest 
    static void perteneceCOPSAJTest() {
        Boolean respuesta=false;
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestResolucion' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
			//Database.insert(psa,false);
		}

        System.RunAs(usuario){   
            Test.startTest();
            respuesta = SAC_LCMP_ForzarResolucion.perteneceCOPSAJ(casoReclamacion.id);
            Test.stopTest();
        }

        system.assertEquals(True, respuesta, 'No tiene permisos para insertar una tarea ');
    }

    @isTest 
    static void recuperarEscaladosTest() {
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestResolucion' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
			//Database.insert(psa,false);
		}

        System.RunAs(usuario){   
            Test.startTest();
            listaEscalados = SAC_LCMP_ForzarResolucion.recuperarEscalados(casoReclamacion.id);
            Test.stopTest();
        }

        system.assertNotEquals(null, listaEscalados.size(), 'No ha podido recuperar el escalado ');
    }

    @isTest 
    static void recuperarConsultasTest() {
        List<SAC_Interaccion__c> lsitaConsultas = new List<SAC_Interaccion__c>();
        
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestResolucion' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
            //Database.insert(psa,false);		
            }

        System.RunAs(usuario){   
            Test.startTest();
            lsitaConsultas = SAC_LCMP_ForzarResolucion.recuperarConsultas(casoReclamacion.id);
            Test.stopTest();
        }

        system.assertNotEquals(null, lsitaConsultas.size(), 'No ha podido recuperar la consulta ');
    }

    @isTest 
    static void recuperarTareasTest() {
        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
        
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestResolucion' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
            //Database.insert(psa,false);		
            }

        System.RunAs(usuario){   
            Test.startTest();
            listaTareas = SAC_LCMP_ForzarResolucion.recuperarTareas(casoReclamacion.id);
            Test.stopTest();
        }

        system.assertNotEquals(null, listaTareas.size(), 'No ha podido recuperar el escalado ');
    }

    @isTest 
    static void finalizarProcesoForzadoTest() {
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();
        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
        Case reclamacionMod = new Case();
        
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestResolucion' LIMIT 1];
        listaEscalados = [SELECT id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        listaConsultas = [SELECT id, SAC_Estado__c, SAC_MotivoDeFinalizado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuestaConsulta' LIMIT 1];
        listaTareas = [SELECT id, SAC_Estado__c, SAC_SaltarValidacion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
            //Database.insert(psa,false);		
        }

        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_ForzarResolucion.finalizarProcesoForzado(casoReclamacion.id, listaEscalados, listaConsultas, listaTareas, 'test');

            reclamacionMod= [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestResolucion' LIMIT 1];

            Test.stopTest();
        }

        system.assertNotEquals(casoReclamacion.Status, reclamacionMod.Status, 'No ha podido recuperar el escalado ');
    }
}