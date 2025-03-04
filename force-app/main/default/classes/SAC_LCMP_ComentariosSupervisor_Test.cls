/*****************************************************************
 * Name: SAC_LCMP_ComentariosSupervisor_Test
 * Copyright © 2019  CaixaBank 
 * 
 * Proposito: Testear la clase SAC_LCMP_ComentariosSupervisor_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US453685         Sergio               21/09/22     Creación
 * 1.1            US619477         Jose Carlos Blanco   07/06/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/
@IsTest
public with sharing class SAC_LCMP_ComentariosSupervisor_Test {

    @TestSetup
    static void makeData() {

        //Usuario Admin
        User userAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(userAdmin, false);
        //Database.insert(userAdmin);

        CC_Grupo_Colaborador__c grupoCOPS;
        CC_Grupo_Colaborador__c grupoColaborador;
        Account cuenta;
        List<User> listadoUsuarios;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Grupos
            grupoCOPS = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            grupoCOPS.SAC_DeveloperName__c = 'COPS';
            grupoCOPS.SAC_MaximoCasosDiarios__c = 30;
            grupoCOPS.SAC_NivelGrupo__c = 'SAC_Nivel2';
        
            grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1)[0];
            grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
            grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
            grupoColaborador.SAC_NivelGrupo__c = 'SAC_Nivel2';
            
            SAC_DatabaseDML.insertDML(grupoCOPS, false);
            //Database.insert(grupoCOPS);
            SAC_DatabaseDML.insertDML(grupoColaborador, false);
            //Database.insert(grupoColaborador);

            //Cuenta
            cuenta = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            SAC_DatabaseDML.insertDML(cuenta, false);
            //Database.insert(cuenta);

            //Usuarios
            listadoUsuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
            listadoUsuarios[0].SAC_PerteneceCOPSAJ__c = true;
            listadoUsuarios[0].SAC_GruposPerteneciente__c = grupoCOPS.id;
            listadoUsuarios[1].SAC_GruposPerteneciente__c = grupoColaborador.id;
            SAC_DatabaseDML.insertListDML(listadoUsuarios, false);
            //Database.insert(listadoUsuarios);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = listadoUsuarios[0].Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
            //Database.insert(permiSetAssi);

            PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
            permiSetAssi2.AssigneeId = listadoUsuarios[1].Id;
            permiSetAssi2.PermissionSetId = permiSet2.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi2, false);
            //Database.insert(permiSetAssi2);

            //Grupos Contact
            List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
            CC_Grupo_Colaborador_Contact__c grupoColabContactCOPS = SAC_TestDataFactory.crearColaboradorContact(listadoUsuarios[0].id, grupoCOPS.id);
            grupoColabContactCOPS.SAC_Supervisor__c = true;
            grupoColabContactCOPS.SAC_Administrador__c = true;
            listaColaboradores.add(grupoColabContactCOPS);

            CC_Grupo_Colaborador_Contact__c grupoColabContact = SAC_TestDataFactory.crearColaboradorContact(listadoUsuarios[1].id, grupoColaborador.id);
            grupoColabContact.SAC_Supervisor__c = true;
            grupoColabContact.SAC_Administrador__c = true;
            listaColaboradores.add(grupoColabContact);

            SAC_DatabaseDML.insertListDML(listaColaboradores, false);
            //Database.insert(listaColaboradores);
        }

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('OwnerId', listadoUsuarios[0].Id);
        camposRecl.put('SEG_Grupo__C', grupoColaborador.id);
        camposRecl.put('SAC_UserElevoASupervisor__c', listadoUsuarios[0].id);
        camposRecl.put('SAC_ObservacionesSupervisor__c', 'Test');
        camposRecl.put('SAC_FechaRecepcion__c', system.now());
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);
        //Database.insert(casoReclamacion);
    
        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'Alta');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl2.put('AccountId', cuenta.Id);
        camposRecl2.put('OwnerId', listadoUsuarios[1].Id);
        camposRecl2.put('SEG_Grupo__C', grupoColaborador.id);
        camposRecl2.put('SAC_UserElevoASupervisor__c', listadoUsuarios[1].id);
        camposRecl2.put('SAC_ObservacionesSupervisor__c', 'Test');
        camposRecl2.put('SAC_FechaRecepcion__c', system.now());
        
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        SAC_DatabaseDML.insertDML(casoReclamacion2, false);
        //Database.insert(casoReclamacion2);
    
        //Reclamacion CC
        Map<String, Object> camposReclCC = new Map<String, Object>();
        camposReclCC.put('Subject', 'TestRecCC');
        camposReclCC.put('Origin', 'Backoffice');
        camposReclCC.put('Status', 'Alta');
        camposReclCC.put('SAC_StatusAuxiliar__c', 'Alta');
        camposReclCC.put('OwnerId', listadoUsuarios[0].Id);
        camposReclCC.put('SEG_Grupo__C', grupoCOPS.Id);
        camposReclCC.put('SAC_UserElevoASupervisor__c', listadoUsuarios[0].id);
        camposReclCC.put('SAC_FechaRecepcion__c', system.now());
        
        Case testRecCC = SAC_TestDataFactory.crearCaso('Reclamacion',camposReclCC);
        SAC_DatabaseDML.insertDML(testRecCC, false);
        //Database.insert(testRecCC);
    }

    @isTest
    static void cargarComentariosTest(){
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias0' AND isActive = true limit 1];
        Case reclamacion = [SELECT Id,OwnerId FROM Case WHERE Subject = 'TestRec'];
        String observaciones = '';

        System.runAs(usuario){
            Test.startTest();
                observaciones = SAC_LCMP_ComentariosSupervisor.cargarComentarios(reclamacion.Id);
            Test.stopTest();
        }
        system.assertEquals(observaciones, 'Test','No se han podido cargar los comentarios');
    }

    @isTest
    static void cargarComentariosTestNegativo(){
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias1' AND isActive = true limit 1];
        Case reclamacion = [SELECT Id,ownerId FROM Case WHERE Subject = 'TestRecCC'];

        System.runAs(usuario){
            try {
                Test.startTest();
                    SAC_LCMP_ComentariosSupervisor.cargarComentarios(reclamacion.Id);
                Test.stopTest();
            } catch (AuraHandledException except) {
                system.assertNotEquals(usuario.Id, reclamacion.ownerId, 'No ha salido la Excepcion del if');
            }  
        } 
    }


    @isTest
    static void esPropietarioTest() {
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec'];
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias0' AND isActive = true limit 1];
        Boolean espropietario = false;

        System.runAs(usuario){
            Test.startTest();
                espropietario = SAC_LCMP_ComentariosSupervisor.esPropietario(reclamacion.OwnerId, usuario.Id);
            Test.stopTest();
        }
        system.assertEquals(espropietario, true,'No es propietario del caso');
    }

    @isTest
    static void esCopsAJTest() {
        User usuario = [SELECT id, name, SAC_PerteneceCOPSAJ__c FROM user WHERE alias = 'alias1' AND isActive = true limit 1];
        Boolean esCOPSAJ;

        System.runAs(usuario){
            Test.startTest();
                esCOPSAJ = SAC_LCMP_ComentariosSupervisor.esCopsAJ(usuario.Id);
            Test.stopTest();
        }
        system.assertEquals(esCOPSAJ, true,'No es COPSAJ');
    }

    @isTest
    static void esQuienElevoTest() {
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias0' AND isActive = true limit 1];
        Case reclamacion = [SELECT Id, OwnerId, SAC_UserElevoASupervisor__c FROM Case WHERE Subject = 'TestRec'];
        Boolean esQuienElevo = false;

        System.runAs(usuario){
            Test.startTest();
                esQuienElevo = SAC_LCMP_ComentariosSupervisor.esQuienElevo(reclamacion.SAC_UserElevoASupervisor__c, usuario.Id);
            Test.stopTest();
        }
        system.assertEquals(esQuienElevo, true,'No es quien elevó a supervisor');
    }

    @isTest
    static void esSupervisorDelGrupoTest() {
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias1' AND isActive = true limit 1];
        User usuarioAdmin = [SELECT id, name FROM user WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true limit 1];
        Case reclamacion = [SELECT Id, OwnerId, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec'];
        Boolean esSupervisorDelGrupo = false;

        System.runAs(usuarioAdmin){
            Test.startTest();
                esSupervisorDelGrupo = SAC_LCMP_ComentariosSupervisor.esSupervisorDelGrupo(reclamacion.SEG_Grupo__c, usuario.Id);
            Test.stopTest();
        }
        system.assertEquals(esSupervisorDelGrupo, true,'El usuario actual no es supervisor administrador del grupo del caso que se esta tratando');
    }
}