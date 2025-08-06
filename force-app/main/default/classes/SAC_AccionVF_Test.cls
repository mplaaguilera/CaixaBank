/*****************************************************************
 * Name: SAC_AccionVF_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear las Clases SAC_AccionVF, SAC_ProrrogarTareasVF
 *              SAC_FinalizarTareaVF y SAC_AccionMetodos
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US204745         Marcela Neira        04/08/21     Creación
 * 1.1            US593664         Jose Carlos Blanco  	10/05/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@istest
public with sharing class SAC_AccionVF_Test {

    private static final String ORGID = UserInfo.getOrganizationId();

    @TestSetup
    static void makeData(){
       
        User usuario1;
        User usuario2; 
        User usuario3; 
        User usuarioAdmin;

        CC_Grupo_Colaborador__c grupoTareas = new CC_Grupo_Colaborador__c();
        List<CC_Grupo_Colaborador_Contact__c> contactoscolab = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoTareas1 = new CC_Grupo_Colaborador_Contact__c();
        CC_Grupo_Colaborador_Contact__c grupoTareasUser = new CC_Grupo_Colaborador_Contact__c();
        CC_Grupo_Colaborador_Contact__c grupoTareas3 = new CC_Grupo_Colaborador_Contact__c();
        
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuarios SAC General
            List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(4);
            usuarios[0].Username = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
            usuarios[0].Email = 'pablo@test.com';
            usuarios[0].LastName = 'usuarioPablo Test';
            usuarios[0].Alias = 'pablo';
          
            usuarios[1].Username = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
            usuarios[1].Email = 'maria@test.com';
            usuarios[1].LastName = 'usuarioMaria Test';
            usuarios[1].Alias = 'maria';    
           
            usuarios[2].Username = 'usergeneral3SAC150623SACTEST@test' + ORGID + '.com';
            usuarios[2].Email = 'dani@test.com';
            usuarios[2].LastName = 'usuarioDani Test';
            usuarios[2].Alias = 'dani';

            usuarios[3].Username = 'userAdminSAC150623SACTEST@test' + ORGID + '.com';
            usuarios[3].Email = 'admin@test.com';
            usuarios[3].LastName = 'usuarioAdmin Test';
            usuarios[3].Alias = 'admin';
            usuarios[3].profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id;
            SAC_DatabaseDML.insertListDML(usuarios, false);
            //Database.insert(usuarios);

            List<PermissionSetAssignment> listPSA = new List<PermissionSetAssignment>();
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi1 = new PermissionSetAssignment();
            permiSetAssi1.AssigneeId = usuarios[0].Id;
            permiSetAssi1.PermissionSetId = permiSet.Id;
            listPSA.add(permiSetAssi1);

            PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
            permiSetAssi2.AssigneeId = usuarios[1].Id;
            permiSetAssi2.PermissionSetId = permiSet.Id;
            listPSA.add(permiSetAssi2);

            PermissionSetAssignment permiSetAssi3 = new PermissionSetAssignment();
            permiSetAssi3.AssigneeId = usuarios[2].Id;
            permiSetAssi3.PermissionSetId = permiSet.Id;
            listPSA.add(permiSetAssi3);
            SAC_DatabaseDML.insertListDML(listPSA, false);
            //Database.insert(listPSA);

            usuario1 = usuarios[0];
            usuario2 = usuarios[1];
            usuario3 = usuarios[2];


        //Usuario SAC Admin
		usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'usertestadmin@test.com.testSetup';     
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);  

        
        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        SAC_DatabaseDML.insertDML(permiSetAssiAdmin, false); 

        PermissionSet permiSetAdmin2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_SystemAdmin'];
        PermissionSetAssignment permiSetAssiAdmin2 = new PermissionSetAssignment();
        permiSetAssiAdmin2.AssigneeId = usuarioAdmin.Id;
        permiSetAssiAdmin2.PermissionSetId = permiSetAdmin2.Id;
        SAC_DatabaseDML.insertDML(permiSetAssiAdmin2, false); 

            //Grupo colaborador
            Test.startTest();
            grupoTareas = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            grupoTareas.SAC_DeveloperName__c = 'COPS';
            SAC_DatabaseDML.insertDML(grupoTareas, false);
            //Database.insert(grupoTareas);

            //Contactos colaboradores
           
            grupoTareas1 = SAC_TestDataFactory.crearColaboradorContact(usuario1.id, grupoTareas.id);
            grupoTareas1.SAC_Administrador__c = true;
            contactoscolab.add(grupoTareas1) ;

            grupoTareasUser = SAC_TestDataFactory.crearColaboradorContact(Userinfo.getUserId(), grupoTareas.id);
            contactoscolab.add(grupoTareasUser) ;
            
            grupoTareas3 = SAC_TestDataFactory.crearColaboradorContact(usuario3.id, grupoTareas.id);
            contactoscolab.add(grupoTareas3);
            SAC_DatabaseDML.insertListDML(contactoscolab, false);
            //Database.insert(contactoscolab);
        }

        //Cuentas
        Account cuenta = SAC_TestDataFactory.crearCuentasOficina(1)[0];
        SAC_DatabaseDML.insertDML(cuenta, false);
        //Database.insert(cuenta);

        //Reclamaciones
        List<Case> reclamaciones = new List<Case>();
        //Reclamacion 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testrec1');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('SuppliedCompany', 'testCaso');

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        reclamaciones.add(reclamacion);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'testrec2');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl2.put('SuppliedCompany', 'testCaso2');
        camposRecl2.put('SEG_Grupo__c', grupoTareas.Id);

        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        reclamaciones.add(reclamacion2);

        //Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'testrec3');
        camposRecl3.put('Status', 'SAC_001');
        camposRecl3.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl3.put('SuppliedCompany', 'testCaso3');
        camposRecl3.put('CC_SuppliedTipo__c', 'Importes hipotecarios');
        camposRecl3.put('CC_Oficina_Afectada_Lookup__c', cuenta.Id);

        Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        reclamaciones.add(reclamacion3);
        SAC_DatabaseDML.insertListDML(reclamaciones, false);
        //Database.insert(reclamaciones);

        //Pretensiones
        List<Case> pretensiones = new List<Case>();
        //Pretension 1
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'testPret');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SuppliedCompany', 'testPreten');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret.put('SAC_ImpResueltoGestoria__c', 30);
        camposPret.put('SAC_ImpResueltoNotaria__c', 200);
        camposPret.put('SAC_ImpResueltoRegistros__c', 100);
        camposPret.put('SAC_ImpResueltoTasacion__c', 50);

        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        pretensiones.add(pretension);

        //Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Subject', 'testPret2');
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SuppliedCompany', 'testPreten2');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', reclamacion3.id);
        camposPret2.put('CC_SuppliedNIF__c', '44556677L');
        camposPret2.put('SEG_Grupo__c', grupoTareas.Id);
        camposPret2.put('CC_Oficina_Afectada_Lookup__c', cuenta.Id);

        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
        pretensiones.add(pretension2);
        SAC_DatabaseDML.insertListDML(pretensiones, false);
        //Database.insert(pretensiones);

        Test.stopTest(); 

        //Maestro acciones
        List<SAC_MaestroAccionesReclamacion__c> listaMaestros = SAC_TestDataFactory.crearMaestroAcciones(2,grupoTareas.id);
        listaMaestros[0].SAC_PlazoMaximo__c = 15;
        listaMaestros[0].SAC_Prorroga__c = 30;
        listaMaestros[1].SAC_PlazoMaximo__c = 15;
        listaMaestros[1].SAC_Prorroga__c = 30;
        listaMaestros[1].SAC_DeveloperName__c = 'GGH';
        listaMaestros[1].SAC_Activo__c = true;
        SAC_DatabaseDML.insertListDML(listaMaestros, false);
        //Database.insert(listaMaestros);

        //Tareas
        List<SAC_Accion__c> tareas = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaDeTareasOtras = SAC_TestDataFactory.crearTareas(6,reclamacion,false);
        listaDeTareasOtras[0].SAC_EquipoResponsable__c = grupoTareas.id;
        listaDeTareasOtras[0].SAC_Observaciones__c = 'tarea'; 
        listaDeTareasOtras[0].SAC_PlazoMaximo__c = 10; 
        listaDeTareasOtras[0].SAC_Prorroga__c = 5;
        listaDeTareasOtras[0].OwnerId = usuarioAdmin.id;
        listaDeTareasOtras[1].SAC_EquipoResponsable__c = grupoTareas.id;
        listaDeTareasOtras[1].SAC_Estado__c = 'SAC_FinalizadaIncompleta';
        listaDeTareasOtras[1].SAC_Observaciones__c = 'Tarea finalizada'; 
        listaDeTareasOtras[1].SAC_PlazoMaximo__c = 10;
        listaDeTareasOtras[2].SAC_EquipoResponsable__c = grupoTareas.id;
        listaDeTareasOtras[2].SAC_Observaciones__c = 'tarea 2';
        listaDeTareasOtras[2].SAC_Pretension__c = pretension2.Id;
       // listaDeTareasOtras[2].OwnerId = usuarioAdmin.id;
        //listaDeTareasOtras[2].OwnerId = usuario2.id; 
        listaDeTareasOtras[2].SAC_PlazoMaximo__c = 10; 
        listaDeTareasOtras[2].SAC_Prorroga__c = 5;
        listaDeTareasOtras[3].SAC_EquipoResponsable__c = grupoTareas.id;
        listaDeTareasOtras[3].SAC_Estado__c = 'SAC_PendienteAsignar';
        listaDeTareasOtras[3].SAC_Observaciones__c = 'Tarea test';
        listaDeTareasOtras[3].SAC_PlazoMaximo__c = 10;
        listaDeTareasOtras[3].SAC_Reclamacion__c = reclamacion2.Id;
        listaDeTareasOtras[3].SAC_Tercero__c = 'Otros';
        listaDeTareasOtras[3].SAC_FechaTentativa__c = System.today();
        listaDeTareasOtras[3].OwnerId = usuario1.id;
        listaDeTareasOtras[4].SAC_EquipoResponsable__c = grupoTareas.id;
        listaDeTareasOtras[4].SAC_Estado__c = 'SAC_PendienteAsignar';
        listaDeTareasOtras[4].SAC_Observaciones__c = 'Tarea test SAC con imp abonado';
        listaDeTareasOtras[4].SAC_Reclamacion__c = reclamacion2.Id;
        listaDeTareasOtras[4].SAC_ImporteAbonar__c = 1;
        listaDeTareasOtras[4].OwnerId = usuario1.id;
        tareas.addAll(listaDeTareasOtras);

        List<SAC_Accion__c> listaDeTareasMaestro = SAC_TestDataFactory.crearTareas(2,reclamacion3,true);
        listaDeTareasMaestro[0].SAC_EquipoResponsable__c = grupoTareas.id;
        listaDeTareasMaestro[0].SAC_Observaciones__c ='tarea4'; 
        listaDeTareasMaestro[0].SAC_PlazoMaximo__c = 10; 
        listaDeTareasMaestro[0].SAC_Prorroga__c = 5;
        listaDeTareasMaestro[0].OwnerId = usuario2.id;
        listaDeTareasMaestro[0].SAC_ImporteNotariaAbonar__c = 20;
        listaDeTareasMaestro[0].SAC_ImporteGestoriaAbonar__c = 30;
        listaDeTareasMaestro[0].SAC_ImporteRegistroAbonar__c = 35;
        listaDeTareasMaestro[0].SAC_ImporteTasacionAbonar__c = 25;
        listaDeTareasMaestro[0].SAC_NCuentaAbono__c = '1234567890';
        listaDeTareasMaestro[0].SAC_Comentarios__c = 'Comentario prueba';
        listaDeTareasMaestro[1].SAC_MaestroAccionesReclamacion__c = listaMaestros[1].Id;
        listaDeTareasMaestro[1].SAC_EquipoResponsable__c=grupoTareas.id;
        listaDeTareasMaestro[1].SAC_Observaciones__c ='tarea5'; 
        listaDeTareasMaestro[1].SAC_PlazoMaximo__c = 10; 
        listaDeTareasMaestro[1].SAC_Prorroga__c = 5;
        //listaDeTareasMaestro[1].OwnerId = usuario2.id;
        listaDeTareasMaestro[1].SAC_ImporteNotariaAbonar__c = 20;
        listaDeTareasMaestro[1].SAC_ImporteGestoriaAbonar__c = 30;
        listaDeTareasMaestro[1].SAC_ImporteRegistroAbonar__c = 35;
        listaDeTareasMaestro[1].SAC_ImporteTasacionAbonar__c = 25;
        listaDeTareasMaestro[1].SAC_NCuentaAbono__c = '1234567890';
        listaDeTareasMaestro[1].SAC_Comentarios__c = 'Comentario prueba';
        tareas.addAll(listaDeTareasMaestro);
        SAC_DatabaseDML.insertListDML(tareas, false);
        //Database.insert(tareas);
        
        //Content Version
        Blob body = blob.valueOf('Unit.Test');
        ContentVersion cv = new ContentVersion(
            Title= 'Documento test', 
            PathOnClient ='SampleTitle.pdf',
            VersionData = body,
            FirstPublishLocationId = listaDeTareasMaestro[1].Id
        );
        SAC_DatabaseDML.insertDML(cv, false);
        //Database.insert(cv);

        //Update reclamacion
        reclamacion.Status = 'SAC_004';
        reclamacion.SAC_StatusAuxiliar__c = 'SAC_004';
        reclamacion.CC_Oficina_Afectada_Lookup__c = cuenta.Id;
        SAC_DatabaseDML.updateDML(reclamacion, false);
        //Database.update(reclamacion);       
    }
    
    @isTest
    static void establecerFechaAltaTest(){
        Test.startTest();
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :UserName and IsActive = true limit 1];

        System.runAs(usuario){
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testrecEjemplo');
            camposRecl2.put('Status', 'SAC_001');
            camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposRecl2.put('SuppliedCompany', 'testCaso2');
    
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

            SAC_DatabaseDML.insertDML(reclamacion, false);

            List<SAC_Accion__c> listaDeTareasOtras = SAC_TestDataFactory.crearTareas(1,reclamacion,false);
            listaDeTareasOtras[0].SAC_Observaciones__c = 'tareaEjemplo'; 
            listaDeTareasOtras[0].SAC_PlazoMaximo__c = 10; 
            listaDeTareasOtras[0].SAC_Prorroga__c = 5;
            listaDeTareasOtras[0].OwnerId = usuario.id;
            SAC_DatabaseDML.insertDML(listaDeTareasOtras[0], false);


        }
        SAC_Accion__c tareaResult = [SELECT Id, SAC_FechaCreacion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tareaEjemplo'];
        Assert.areNotEqual(null, tareaResult.SAC_FechaCreacion__c, 'No se ha añadido la fecha de creación');
        Test.stopTest();
    }

    @isTest
    static void establecerFechaFinalizacionTest(){
        Test.startTest();
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :UserName and IsActive = true limit 1];

        System.runAs(usuario){
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testrecEjemplo');
            camposRecl2.put('Status', 'SAC_001');
            camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposRecl2.put('SuppliedCompany', 'testCaso2');
    
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

            SAC_DatabaseDML.insertDML(reclamacion, false);

            List<SAC_Accion__c> listaDeTareasOtras = SAC_TestDataFactory.crearTareas(1,reclamacion,false);
            listaDeTareasOtras[0].SAC_Observaciones__c = 'tareaEjemplo'; 
            listaDeTareasOtras[0].SAC_PlazoMaximo__c = 10; 
            listaDeTareasOtras[0].SAC_Prorroga__c = 5;
            listaDeTareasOtras[0].OwnerId = usuario.id;
            SAC_DatabaseDML.insertDML(listaDeTareasOtras[0], false);

            listaDeTareasOtras[0].SAC_Estado__c = 'SAC_Finalizada';
            SAC_DatabaseDML.updateDML(listaDeTareasOtras[0], false);

        }
        SAC_Accion__c tareaResult = [SELECT Id, SAC_FechaFinalizacion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tareaEjemplo'];
        Assert.areNotEqual(null, tareaResult.SAC_FechaFinalizacion__c, 'No se ha añadido la fecha de finalización');
        Test.stopTest();
    }

    @isTest
    static void establecerFechaEnvioTest(){
        Test.startTest();
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :UserName and IsActive = true limit 1];

        System.runAs(usuario){
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testrecEjemplo');
            camposRecl2.put('Status', 'SAC_001');
            camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposRecl2.put('SuppliedCompany', 'testCaso2');
    
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

            SAC_DatabaseDML.insertDML(reclamacion, false);

            List<SAC_Accion__c> listaDeTareasOtras = SAC_TestDataFactory.crearTareas(1,reclamacion,false);
            listaDeTareasOtras[0].SAC_Observaciones__c = 'tareaEjemplo'; 
            listaDeTareasOtras[0].SAC_PlazoMaximo__c = 10; 
            listaDeTareasOtras[0].SAC_Prorroga__c = 5;
            listaDeTareasOtras[0].OwnerId = usuario.id;
            listaDeTareasOtras[0].SAC_Estado__c = 'SAC_PendienteEnviar';
            SAC_DatabaseDML.insertDML(listaDeTareasOtras[0], false);

            //Se simula un envío:
            listaDeTareasOtras[0].SAC_Estado__c = 'SAC_PendienteAsignar';
            SAC_DatabaseDML.updateDML(listaDeTareasOtras[0], false);

            //Se simula otro envío, para eso primero hay que volver a pendiente de enviar:
            listaDeTareasOtras[0].SAC_Estado__c = 'SAC_PendienteEnviar';
            SAC_DatabaseDML.updateDML(listaDeTareasOtras[0], false);

            listaDeTareasOtras[0].SAC_Estado__c = 'SAC_PendienteAsignar';
            SAC_DatabaseDML.updateDML(listaDeTareasOtras[0], false);

        }
        SAC_Accion__c tareaResult = [SELECT Id, SAC_FechaPrimerEnvio__c, SAC_FechaUltimoEnvio__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tareaEjemplo'];
        Assert.areNotEqual(null, tareaResult.SAC_FechaPrimerEnvio__c, 'No se ha añadido la fecha de primer envío');
        Assert.areNotEqual(null, tareaResult.SAC_FechaUltimoEnvio__c, 'No se ha añadido la fecha de segundo envío');
        Test.stopTest();
    }


    @isTest
    static void establecerFechaDevolucionTest(){
        Test.startTest();
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :UserName and IsActive = true limit 1];

        System.runAs(usuario){
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testrecEjemplo');
            camposRecl2.put('Status', 'SAC_001');
            camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposRecl2.put('SuppliedCompany', 'testCaso2');
    
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

            SAC_DatabaseDML.insertDML(reclamacion, false);


            /*Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'testPretEjemplo');
            camposPret.put('Status', 'SAC_001');
            camposPret.put('SuppliedCompany', 'testPretenEjemplo');
            camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
    
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            SAC_DatabaseDML.insertDML(pretension, false);*/

            List<SAC_Accion__c> listaDeTareasOtras = SAC_TestDataFactory.crearTareas(1,reclamacion,false);
            listaDeTareasOtras[0].SAC_Observaciones__c = 'tareaEjemplo'; 
            listaDeTareasOtras[0].SAC_PlazoMaximo__c = 10; 
            listaDeTareasOtras[0].SAC_Prorroga__c = 5;
            listaDeTareasOtras[0].OwnerId = usuario.id;
            //listaDeTareasOtras[0].SAC_Pretension__c = pretension.Id;
            SAC_DatabaseDML.insertDML(listaDeTareasOtras[0], false);

            listaDeTareasOtras[0].SAC_Estado__c = 'SAC_Devuelta';
            SAC_DatabaseDML.updateDML(listaDeTareasOtras[0], false);


        }
        SAC_Accion__c tareaResult = [SELECT Id, SAC_FechaUltimaDevolucion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tareaEjemplo'];
        Assert.areNotEqual(null, tareaResult.SAC_FechaUltimaDevolucion__c, 'No se ha añadido la fecha de primer envío');
        Test.stopTest();
    }

    @istest
    static void autoasignarTareasTest() 
    {
        Test.startTest();
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';

        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        User usuario = [select id, name, UserRole.name from user where Username = :UserName and IsActive = true limit 1];
        
        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.setCurrentPage(testPage);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            stdSetController.setSelected(listaTares);
            SAC_AccionVF ext = new SAC_AccionVF(stdSetController);
            ext.save();
        }

        List <SAC_Accion__c> listaTares2 = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c];
        Test.stopTest();
        system.assertNotEquals(null, listaTares[0].ownerId , 'No se ha asignado al usuario');
    }

    @istest
    static void autoasignarTareasTestNegativo(){
        Boolean mostrar = true;
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='Tarea finalizada'] ;
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.startTest();
            Test.setCurrentPage(testPage);            
                
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            stdSetController.setSelected(listaTares);
            SAC_AccionVF ext = new SAC_AccionVF(stdSetController);
            mostrar = ext.mostrar;     
            
            Test.stopTest();
        }

        system.assertEquals(false, mostrar, 'No muestra el error de mensaje');
    }

   @istest
	static void finalizarTareasTest(){
	    //String Usernamev = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        Test.startTest();
		List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea 2' LIMIT 1];
		//User usuario = [select id, name, UserRole.name from user where Username =: Usernamev and IsActive = true limit 1];
        User usuario = [select id, name, UserRole.name from user where Username = 'usertestadmin@test.com.testSetup' limit 1];

		PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId = :usuario.id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId =usuario.id);
            SAC_DatabaseDML.insertDML(psa, false);
			//Database.insert(psa);
		}


		System.runAs(usuario){
			PageReference testPage = Page.SAC_AutoasignarTarea;
			Test.setCurrentPage(testPage);
            ApexPages.currentPage().getParameters().put('observaciones', 'observaciones test');
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
			stdSetController.setSelected(listaTares);
			SAC_FinalizarTareaVF ext = new SAC_FinalizarTareaVF(stdSetController);
            ext.observaciones = 'observaciones test';
			ext.save();
		}

		Test.stopTest();
		system.assertNotEquals(null, listaTares[0].ownerId , 'No se ha asignado al usuario');
	}

    @istest
	static void finalizarTareasTest2(){
	
        Test.startTest();
		List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea 2'];
		//User usuario = [select id, name, UserRole.name from user where Username = 'usergeneral2@test.com' and IsActive = true limit 1];
        User usuario = [select id, name, UserRole.name from user where Username = 'usertestadmin@test.com.testSetup' limit 1];
		PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId = :usuario.id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
            SAC_DatabaseDML.insertDML(psa, false);
			//Database.insert(psa);
		}

		System.runAs(usuario){
            listaTares[0].SAC_Estado__c = 'SAC_Finalizada';
            SAC_DatabaseDML.updateListDML(listaTares, false);
            //Database.update(listaTares);
			PageReference testPage = Page.SAC_AutoasignarTarea;
			Test.setCurrentPage(testPage);
            ApexPages.currentPage().getParameters().put('observaciones', 'observaciones test');
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
			stdSetController.setSelected(listaTares);
			SAC_FinalizarTareaVF ext = new SAC_FinalizarTareaVF(stdSetController);
            ext.observaciones = 'observaciones test';
			ext.save();
		}

		Test.stopTest();
		system.assertNotEquals(null, listaTares[0].ownerId , 'No se ha asignado al usuario');
	}



    @istest
	static void finalizarTareasIncompletasTest(){
	
        Test.startTest();
		List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea 2'];
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
		User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        /*User usuario = [select id, name, UserRole.name from user where Id = :UserInfo.getUserId() limit 1];
		PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId = :UserInfo.getUserId()];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = UserInfo.getUserId());
			Database.insert(psa);
		}*/

		System.runAs(usuario){
			PageReference testPage = Page.SAC_AutoasignarTarea;
			Test.setCurrentPage(testPage);
            ApexPages.currentPage().getParameters().put('observacionesInc', 'observaciones test');
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
			stdSetController.setSelected(listaTares);
			SAC_FinalizarTareaVF ext = new SAC_FinalizarTareaVF(stdSetController);
            ext.observaciones = 'observaciones test';
			ext.save();
		}

		Test.stopTest();
		system.assertNotEquals(null, listaTares[0].ownerId , 'No se ha asignado al usuario');
	}


    @istest
    static void finalizarTareasTestNegativo(){
        Boolean mostrar =true;
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Estado__c = 'SAC_FinalizadaIncompleta'] ;
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];

        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.startTest();
            Test.setCurrentPage(testPage);            
                
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            stdSetController.setSelected(listaTares);
            SAC_FinalizarTareaVF ext = new SAC_FinalizarTareaVF(stdSetController);
            mostrar = ext.mostrar;     
            
            Test.stopTest();
        }

        system.assertEquals(false, mostrar, 'No muestra el error de mensaje');
    }

    @istest
    static void prorrogarTareasTest() 
    {
        Test.startTest();
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];

        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.setCurrentPage(testPage);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            stdSetController.setSelected(listaTares);
            SAC_ProrrogarTareasVF ext = new SAC_ProrrogarTareasVF(stdSetController);
            ext.save();
        }

        List <SAC_Accion__c> listaTares2 = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c];
        Test.stopTest();
        system.assertNotEquals(null, listaTares[0].ownerId , 'No se ha asignado al usuario');
    }

    @istest
    static void prorrogarrTareasTestNegativo(){
        Boolean mostrar =true;
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c, RecordType.Name
                                        FROM SAC_Accion__c WHERE SAC_Observaciones__c='Tarea finalizada'] ;
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];

        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.startTest();
            Test.setCurrentPage(testPage);            
                
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares); 
            stdSetController.setSelected(listaTares);
            SAC_ProrrogarTareasVF ext = new SAC_ProrrogarTareasVF(stdSetController);
            mostrar = ext.mostrar;     
            Test.stopTest();
        }

        system.assertEquals(false, mostrar, 'No muestra el error de mensaje');
    }
    
    @istest
    static void cambiarPropietarioTarea(){
        Boolean error=false;
        SAC_Accion__c tarea = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='Tarea finalizada' LIMIT 1] ;
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        SAC_MaestroAccionesReclamacion__c maestro = [SELECT ID FROM SAC_MaestroAccionesReclamacion__c LIMIT 1];

        tarea.ownerId = usuario.id;
        tarea.SAC_MaestroAccionesReclamacion__c = maestro.id;

        System.RunAs(usuario){   
            Test.startTest();

            try {
                SAC_DatabaseDML.updateDML(tarea, true);
                //Database.update(tarea);
            } catch (Exception e) {
                error = true;
            }
            
            Test.stopTest();
        }

        system.assertEquals(true, error, 'Tarea finalizada o finalizada incompleta');
    }

    @istest
    static void cambiarPropietarioTarea2(){
        Test.startTest();
        Boolean error=false;
        SAC_Accion__c tarea = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea5' LIMIT 1] ;
        String userName = 'usergeneral3SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testrec3'];
        SAC_MaestroAccionesReclamacion__c maestro = [SELECT ID FROM SAC_MaestroAccionesReclamacion__c LIMIT 1];
        reclamacion.ownerId = usuario.id;
        tarea.ownerId = usuario.id;
        tarea.SAC_MaestroAccionesReclamacion__c = maestro.id;

        System.runAs(usuario) {
            
            try {
                SAC_DatabaseDML.updateDML(reclamacion, true);
                //Database.update(reclamacion);
                SAC_DatabaseDML.updateDML(tarea, true);
                //Database.update(tarea);
            } catch (Exception e) {
                error = true;
            }
        }

        Test.stopTest();
        system.assertEquals(false, error, 'No se puede cambiar el propietario');
    }

    @istest
    static void autoasignarSinSeleccion() 
    {   
        Boolean mostrar = true;
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Estado__c = 'SAC_FinalizadaIncompleta'] ;
        
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.startTest();
            Test.setCurrentPage(testPage);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            SAC_AccionVF ext = new SAC_AccionVF(stdSetController);
            mostrar = ext.mostrar;
            Test.stopTest();
        }

        system.assertEquals(false, mostrar , 'De lanzar el mensaje de "Debe seleccionar al menos un registro" ');
    }

    @istest
    static void finalizarSinSeleccion(){   
        Boolean mostrar = true;
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Estado__c = 'SAC_FinalizadaIncompleta'] ;
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.startTest();
            Test.setCurrentPage(testPage);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            SAC_FinalizarTareaVF ext = new SAC_FinalizarTareaVF(stdSetController);
            mostrar = ext.mostrar;
            Test.stopTest();
        }

        system.assertEquals(false, mostrar , 'De lanzar el mensaje de "Debe seleccionar al menos un registro" ');
    }

    @istest
    static void prorrogarSinSeleccion(){   
        Boolean mostrar = true;
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Estado__c = 'SAC_FinalizadaIncompleta'] ;
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.startTest();
            Test.setCurrentPage(testPage);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            SAC_ProrrogarTareasVF ext = new SAC_ProrrogarTareasVF(stdSetController);
            mostrar = ext.mostrar;
            Test.stopTest();
        }

        system.assertEquals(false, mostrar , 'De lanzar el mensaje de "Debe seleccionar al menos un registro" ');
    }

    @istest
    static void cerrarReclamacionesTest(){
        List<Id> lista = new List<Id>(); 
        Id idCaso = [select id from case WHERE SuppliedCompany = 'testCaso'].id;       
        lista.add(idCaso);

        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];

        System.RunAs(usuario){   
            Test.startTest();
            SAC_AccionMetodos.cerrarReclamaciones(lista);
            Test.stopTest();
        }
        String estadoCaso = [select id, status from case WHERE SuppliedCompany = 'testCaso'].status;
        System.assertEquals('Cerrado', estadoCaso, 'No se ha modificado el estado de la reclamación.');
    
    }

    @istest
    static void devolverTareasTest(){
        Test.startTest();
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.setCurrentPage(testPage);

            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            stdSetController.setSelected(listaTares);
            SAC_AccionVF ext = new SAC_AccionVF(stdSetController);
            ext.save();
            
            ApexPages.StandardSetController stdSetController2 = new ApexPages.StandardSetController(listaTares);
            stdSetController2.setSelected(listaTares);
            SAC_DevolverTareasGrupoVF ext2 = new SAC_DevolverTareasGrupoVF(stdSetController);
            ext2.save();
        }

        List <SAC_Accion__c> listaTares2 = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        Id colaId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1].id;
        Test.stopTest();
        system.assertEquals(colaId, listaTares2[0].ownerId , 'No se ha devuelto a la cola');
    }

    @istest
    static void esLaColaTest() {      
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';  
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        Boolean esCola;
        System.RunAs(usuario){  
            Test.startTest();      
            esCola = SAC_AccionMetodos.esLaCola(usuario.id);
            Test.stopTest();
        }
        system.assertNotEquals(null, esCola, 'No se ha podido comprobar si el Id es cola');
    }

    @istest
    static void devolverTareasTestNegativo(){
        Boolean mostrar =true;
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c 
                                        FROM SAC_Accion__c WHERE SAC_Observaciones__c='Tarea finalizada'] ;

        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.startTest();
            Test.setCurrentPage(testPage);            
                
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            stdSetController.setSelected(listaTares);
            SAC_DevolverTareasGrupoVF ext = new SAC_DevolverTareasGrupoVF(stdSetController);
            mostrar = ext.mostrar;     
            
            Test.stopTest();
        }

        system.assertEquals(false, mostrar, 'No muestra el error de mensaje');
    }
    
    @istest
    static void asignarTareasTest(){
        Test.startTest();
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.setCurrentPage(testPage);

            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            stdSetController.setSelected(listaTares);
            SAC_AsignarVF ext = new SAC_AsignarVF(stdSetController);
            ext.selectedUser = usuario.id;
            ext.save();
                
            ApexPages.StandardSetController stdSetController2 = new ApexPages.StandardSetController(listaTares);
            stdSetController2.setSelected(listaTares);
            SAC_DevolverTareasGrupoVF ext2 = new SAC_DevolverTareasGrupoVF(stdSetController);
            ext2.save();
        }

        List <SAC_Accion__c> listaTares2 = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        Id colaId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1].id;
        Test.stopTest();
        system.assertEquals(colaId, listaTares2[0].ownerId , 'No se ha devuelto a la cola');
    }
    
    @istest
    static void asignarTareasTest2() {
        Test.startTest();
        List <SAC_Accion__c> listaTares = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        String userName = 'usergeneral3SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
 		PageReference testPage = Page.SAC_AutoasignarTarea;
        System.runAs(usuario) {
            Test.setCurrentPage(testPage);
                
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaTares);
            stdSetController.setSelected(listaTares);
            SAC_AsignarVF ext = new SAC_AsignarVF(stdSetController);
            ext.selectedUser = usuario.id;
            ext.save();
            
            ApexPages.StandardSetController stdSetController2 = new ApexPages.StandardSetController(listaTares);
            stdSetController2.setSelected(listaTares);
            SAC_DevolverTareasGrupoVF ext2 = new SAC_DevolverTareasGrupoVF(stdSetController);
            ext2.save();
        }
        List <SAC_Accion__c> listaTares2 = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        Id colaId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1].id;
        Test.stopTest();

        system.assertEquals(colaId, listaTares2[0].ownerId , 'No se ha devuelto a la cola');
    }

    @isTest
    static void AccionComprobarOwnerYStatusTest2() {
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testrec2'];
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        reclamacion.OwnerId = usuario.id;
        SAC_DatabaseDML.updateDML(reclamacion, false);
        //Database.update(reclamacion);
        System.RunAs(usuario){  
            Test.startTest();
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Observaciones__c='test observacion test2';
            tarea.SAC_PlazoMaximo__c = 10;
            tarea.SAC_Reclamacion__c = reclamacion.id;
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
            SAC_DatabaseDML.insertDML(tarea, false);
            //Database.insert(tarea);
            Test.stopTest();
        }
        SAC_Accion__c tareaResultado = [SELECT Id, SAC_Observaciones__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'test observacion test2' LIMIT 1];
        system.assertEquals('test observacion test2', tareaResultado.SAC_Observaciones__c, 'No se ha podido insertar la acción');
    }

    @isTest
    static void AccionComprobarOwnerYStatusTest() {
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testrec2'];
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        
        reclamacion.OwnerId = usuario.id;
        SAC_DatabaseDML.updateDML(reclamacion, false);
        //Database.update(reclamacion);
        System.RunAs(usuario){   
            Test.startTest();
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Observaciones__c='test observacion test'; 
            tarea.SAC_PlazoMaximo__c = 10;
            tarea.SAC_Reclamacion__c = reclamacion.id;
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
            SAC_DatabaseDML.insertDML(tarea, false);
            //Database.insert(tarea);
            Test.stopTest();
        }

        SAC_Accion__c tareaResultado = [SELECT Id, SAC_Observaciones__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'test observacion test' LIMIT 1];

        system.assertEquals('test observacion test', tareaResultado.SAC_Observaciones__c, 'No se ha podido insertar la acción');
    }

    @istest
    static void comprobarTareasFinalizadasTest() {
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'testrec2'];
        List<SAC_Accion__c> tareas = [SELECT Id, SAC_Reclamacion__c, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :reclamacion.Id];

        Boolean resultado;
        System.RunAs(usuario){  
            Test.startTest();

            tareas[0].SAC_Estado__c = 'SAC_Finalizada';
            SAC_DatabaseDML.updateListDML(tareas, false);
            //Database.update(tareas);
            // Crea el mapa y añade la reclamación y las tareas asociadas
            Map<Id, List<SAC_Accion__c>> mapaRecTareas = new Map<Id, List<SAC_Accion__c>>();
            mapaRecTareas.put(reclamacion.Id, tareas);

            SAC_AccionMetodos.comprobarTareasFinalizadas(mapaRecTareas);
            Test.stopTest();
        }
        Case reclamacionCerrada = [SELECT Id, Status FROM Case WHERE Subject = 'testrec2'];
        System.assertEquals(reclamacion.Status, reclamacionCerrada.Status, 'Error en comprobar tareas finalizadas.');
    }

    @istest
    static void prorrogarTareaTest2() {
        Boolean error = false;
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        SAC_Accion__C accion = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];

        System.RunAs(usuario){   
            Test.startTest();
            Datetime navidad = Datetime.newInstance(2022, 12, 25, 12, 6, 8);
            accion.SAC_FechaVencimientoProrroga__c = navidad.date();
    
            try {
                SAC_DatabaseDML.updateDML(accion, true);
                //Database.update(accion);
            } catch (Exception e) {
                error = true;
            } 
            Test.stopTest();
        }
        System.assertEquals(true, error, 'No ha saltado el mensaje error.');
    }

    @istest
    static void envioGGH_Test() {        
        List<SAC_Accion__C> listaAcciones = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c];
        Boolean error = false; 

        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];

        CBK_IntegrationSetting__c csGGH = new CBK_IntegrationSetting__c();
        csGGH.Name = 'SAC_GGH_Callout';
        csGGH.NamedCredential__c = 'callout:API_GWT_PRE/tech/gdsusr/api/GGHAPI/AltaReclamacion';
        SAC_DatabaseDML.insertDML(csGGH, false);
        //Database.insert(csGGH);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));

        System.RunAs(usuario){   
            Test.startTest();  
            try {
                SAC_AccionMetodos.envioGGH(JSON.serialize(listaAcciones)); 
            } catch (Exception e) {
                error = true;
            } 
            Test.stopTest();
        }

        System.assertNotEquals(true, error, 'No ha saltado el mensaje error.');
    }

    @istest
    static void esPropietarioRecOPretTest() {        
        SAC_Accion__C accion = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];
        String userName = 'usergeneral2SAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [SELECT id, name, UserRole.name FROM user WHERE Username = :userName and IsActive = true limit 1];

        String userNameAdmin = 'userAdminSAC150623SACTEST@test' + ORGID + '.com';
        User admin = [SELECT id FROM user WHERE Username = :userNameAdmin and IsActive = true limit 1];
        
        System.RunAs(admin){   
            Test.startTest();       
            accion.ownerId = usuario.Id;
            SAC_DatabaseDML.updateDML(accion, false);
            //Database.update(accion);
            Test.stopTest();
        }

        SAC_Accion__C accionResult = [SELECT Id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c='tarea'];

        System.assertEquals(usuario.Id, accionResult.ownerId, 'No se ha podido cambiar el owner de la acción');
    }

    @istest
    static void cargarDatosTest() {        
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'testPret2'];
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];

        pretension.OwnerId = usuario.id;
        SAC_DatabaseDML.updateDML(pretension, false);
        //Database.update(pretension);

        System.RunAs(usuario){   
            Test.startTest();       
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Observaciones__c='test observacion test'; 
            tarea.SAC_Pretension__c = pretension.id;
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
            SAC_DatabaseDML.insertDML(tarea, false);
            //Database.insert(tarea);
            Test.stopTest();
        }

        SAC_Accion__c tareaResultado = [SELECT Id, SAC_Observaciones__c, SAC_GrupoCreadorTarea__c, SAC_Oficina__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'test observacion test' LIMIT 1];

        system.assertEquals('Grupo Responsable Accion 0', tareaResultado.SAC_GrupoCreadorTarea__c, 'No se ha podido insertar la acción');
    }

    @isTest
    static void rellenarFechaEjecucionTest() {
        List<SAC_Accion__c> tareas = [SELECT Id, SAC_Estado__c, SAC_FechaDeEjecucion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Tarea test' LIMIT 1];
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        System.RunAs(usuario){  
            Test.startTest();
            SAC_AccionMetodos.rellenarFechaEjecucion(tareas);
            SAC_DatabaseDML.updateListDML(tareas, false);
            //Database.update(tareas);
            Test.stopTest();
        }
        List<SAC_Accion__c> tareaResultado = [SELECT Id, SAC_Observaciones__c, SAC_Estado__c, SAC_FechaDeEjecucion__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Tarea test' LIMIT 1];
        system.assertNotEquals(null, tareaResultado[0].SAC_FechaDeEjecucion__c, 'La tarea no ha finalizado correctamente');
    }

    @isTest
    static void actualizarFechaTentativaTest() {
        List<SAC_Accion__c> tareas = [SELECT Id, SAC_Tercero__c, SAC_FechaTentativa__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Tarea test' LIMIT 1];
        Date fechaAntes = tareas[0].SAC_FechaTentativa__c;

        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [select id, name, UserRole.name from user where Username = :userName and IsActive = true limit 1];
        System.RunAs(usuario){  
            Test.startTest();
            tareas[0].SAC_Tercero__c = '';
            SAC_AccionMetodos.actualizarFechaTentativa(tareas);
            SAC_DatabaseDML.updateListDML(tareas, false);
            //Database.update(tareas);
            Test.stopTest();
        }
        List<SAC_Accion__c> tareaResultado = [SELECT Id, SAC_FechaTentativa__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Tarea test' LIMIT 1];

        system.assertNotEquals(fechaAntes, tareaResultado[0].SAC_FechaTentativa__c, 'No se ha actualizado el campo fecha tentativa correctamente.');
    }

    @isTest
    static void finalizarTareaConImpAbonadoTest() {
        List<SAC_Accion__c> tareas = [SELECT Id, SAC_Tercero__c, SAC_FechaTentativa__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Tarea test SAC con imp abonado' LIMIT 1];
        String userName = 'usergeneralSAC150623SACTEST@test' + ORGID + '.com';
        User usuario = [SELECT id, name, UserRole.name FROM user WHERE Username = :userName and IsActive = true LIMIT 1];
        Boolean hayError = false;

        System.RunAs(usuario){  
            Test.startTest();
                try {
                    tareas[0].SAC_Estado__c = 'SAC_Finalizada';
                    SAC_DatabaseDML.updateListDML(tareas, false);
                } catch (Exception e) {
                    hayError = true;
                }  
            Test.stopTest();
        }

        Assert.areEqual(false, hayError, 'No ha saltado la validación de importe abonado en la tarea.');
    }
}