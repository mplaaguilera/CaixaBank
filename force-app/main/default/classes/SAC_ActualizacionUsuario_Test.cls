/*****************************************************************
 * Name: SAC_ActualizacionUsuario_Test
 * Copyright © 2021  CaixaBank
 *
 * Proposito: Testear la clase SAC_ActualizacionUsuario
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US206848         Marcela Neira        21/04/21     Creación
 * 1.1            US563153         Jose Carlos Blanco  	13/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/

@istest
public with sharing class SAC_ActualizacionUsuario_Test {
    @TestSetup
    static void makeData(){
       
        List<CC_Grupo_Colaborador__c> gruposColaboradores = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',3);
        gruposColaboradores[0].Name = 'Grupo Proveedores Test';
        gruposColaboradores[0].SAC_PorcentajeAsignacion__c=100;
        gruposColaboradores[0].SAC_MaximoCasosDiarios__c = 15;
        gruposColaboradores[1].Name = 'Grupo Proveedores Test Secundario';
        gruposColaboradores[1].SAC_PorcentajeAsignacion__c=0;
        gruposColaboradores[1].SAC_MaximoCasosDiarios__c = 15;
        gruposColaboradores[2].Name = 'VCX Test';
        gruposColaboradores[2].SAC_PorcentajeAsignacion__c=0;
        gruposColaboradores[2].SAC_MaximoCasosDiarios__c = 15;

        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(3);
        //USUARIO CON EL QUE EJECUTO LA ACCIÓN
        usuarios[0].Username = 'admin123@testcaixa1.com';
        usuarios[0].LastName = 'usuarioAdmin Test';      

        //USUARIO AL QUE ASIGNO UN GRUPO COLABORADOR
        usuarios[1].Username = 'usergeneralcaixa@testcaixa.com';
        usuarios[1].LastName = 'usuarioGeneral Test'; 
        usuarios[1].SAC_GruposPerteneciente__c = gruposColaboradores[0].id;     
        
        //USUARIO ADMINISTRADOR DE GRUPOS
        usuarios[2].Username = 'usuarioAdminGrupocaixa@testcaixa.com';
        usuarios[2].LastName = 'usuarioAdminGrupo Test'; 
 
        SAC_DatabaseDML.insertListDML(usuarios, false);

        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_AdministradorGrupos'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarios[2].id);       
        permisos.add(psa);

        PermissionSet ps2 = [select id from PermissionSet where  PermissionSet.Label ='SAC_Administrador'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps2.id, AssigneeId = usuarios[2].id);       
        permisos.add(psa2);

        SAC_DatabaseDML.insertListDML(permisos, false);

        System.runAs(usuarios[0]){
            SAC_DatabaseDML.insertListDML(gruposColaboradores, false);

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SAC_TestDataFactory.crearColaboradorContact(usuarios[0].id,gruposColaboradores[1].id);
            CC_Grupo_Colaborador_Contact__c grupoColaboradorContactSecundario = SAC_TestDataFactory.crearColaboradorContact(usuarios[1].id,gruposColaboradores[1].id);
            SAC_DatabaseDML.insertDML(grupoColaboradorContact2, false);
            SAC_DatabaseDML.insertDML(grupoColaboradorContactSecundario, false);
        }
        
    }
    @isTest

    static void insertarUsuarioAGrupoColaboradorTest() {

        User usuarioAdministrador = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];
        User usuarioQueSeActualiza = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'usergeneralcaixa@testcaixa.com' AND isActive = true];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedores Test Secundario' LIMIT 1];

        PermissionSet ps2 = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps2.id, AssigneeId = usuarioAdministrador.id);       
        SAC_DatabaseDML.insertDML(psa2, false);


        system.runAs(usuarioAdministrador){
            Test.startTest();
            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SAC_TestDataFactory.crearColaboradorContact(usuarioAdministrador.id,grupo.id);
            SAC_DatabaseDML.insertDML(grupoColaboradorContact2, false);

            List<CC_Grupo_Colaborador_Contact__c> listaTest = [SELECT Id, CC_Grupo_Colaborador__r.RecordTypeId, CC_Usuario__c, CC_Grupo_Colaborador__c
                                                            FROM CC_Grupo_Colaborador_Contact__c ];

            SAC_ActualizacionUsuario.actualizar(listaTest, null);
            Test.stopTest();
        }  
        
        usuarioQueSeActualiza = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'usergeneralcaixa@testcaixa.com'];
        system.assertNotEquals(null,usuarioQueSeActualiza.SAC_GruposPerteneciente__c,'No se actualizó el Campo de Grupo al que pertenece');
        
    }

    @isTest

    static void actualizarUsuarioAGrupoColaboradorTest() {
        User usuarioAdministrador = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];
        User usuarioQueSeActualiza = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'usergeneralcaixa@testcaixa.com' AND isActive = true];
        String grupoViejo;
        String grupoNuevo;

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_Administrador'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioAdministrador.id);       
        SAC_DatabaseDML.insertDML(psa, false);

        grupoViejo = [SELECT SAC_GruposPerteneciente__c FROM User WHERE Username = 'admin123@testcaixa1.com'].SAC_GruposPerteneciente__c;
           
        List<CC_Grupo_Colaborador_Contact__c> listaTest = [SELECT Id, CC_Grupo_Colaborador__r.RecordTypeId, CC_Usuario__c, CC_Grupo_Colaborador__c
                                                            FROM CC_Grupo_Colaborador_Contact__c
                                                            WHERE  CC_Usuario__c = :usuarioQueSeActualiza.id AND CC_Grupo_Colaborador__r.Name = 'Grupo Proveedores Test Secundario'];

        listaTest[0].CC_Usuario__c=usuarioAdministrador.Id;
        
        system.runAs(usuarioAdministrador){
            Test.startTest(); 
            SAC_DatabaseDML.updateListDML(listaTest, false);

            Test.stopTest();
        }    

        grupoNuevo = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'admin123@testcaixa1.com'].SAC_GruposPerteneciente__c;
        
        system.assertNotEquals(grupoNuevo, grupoViejo, 'No cambió de grupo');
    }

    @isTest
    static void eliminarUsuarioAGrupoColaboradorTest() {

        User usuarioAdministrador = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];
        User usuarioQueSeActualiza = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'usergeneralcaixa@testcaixa.com' AND isActive = true];

        system.runAs(usuarioAdministrador){
            Test.startTest();
            CC_Grupo_Colaborador__c grupoC = new CC_Grupo_Colaborador__c();
            grupoC.Name = 'Grupo Proveedores Test 2';
            grupoC.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
            grupoC.SAC_MaximoCasosDiarios__c=10;
            SAC_DatabaseDML.insertDML(grupoC, false);
       
            CC_Grupo_Colaborador_Contact__c grupoCC = new CC_Grupo_Colaborador_Contact__c();
            grupoCC.CC_Grupo_Colaborador__c = grupoC.id;
            grupoCC.CC_Usuario__c = usuarioQueSeActualiza.id;
            SAC_DatabaseDML.insertDML(grupoCC, false);

            List<CC_Grupo_Colaborador_Contact__c> listaTest = [SELECT Id, CC_Grupo_Colaborador__r.RecordTypeId, CC_Usuario__c, CC_Grupo_Colaborador__c
                                                            FROM CC_Grupo_Colaborador_Contact__c ];

            SAC_ActualizacionUsuario.actualizar(null, listaTest);
            Test.stopTest();
        }  

        usuarioQueSeActualiza = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'usergeneralcaixa@testcaixa.com'];

        system.assertEquals(usuarioQueSeActualiza.SAC_GruposPerteneciente__c,null,'No se actualizó el Campo de Grupo al que pertenece');
    }

    @isTest
    static void borrarGrupoColaboradorContactTest() {

        User usuarioAdministrador = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];


        List<CC_Grupo_Colaborador_Contact__c> listaTest = [SELECT Id, CC_Grupo_Colaborador__r.RecordTypeId, CC_Usuario__c, CC_Grupo_Colaborador__c
                                                        FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c = :usuarioAdministrador.Id LIMIT 1];

        Id idGrupoColaboradorContact = listaTest[0].Id;

        system.runAs(usuarioAdministrador){
            Test.startTest();
            SAC_DatabaseDML.deleteListDML(listaTest, false);
            Test.stopTest();
        }

        system.assertEquals([SELECT Count() FROM CC_Grupo_Colaborador_Contact__c WHERE Id = :idGrupoColaboradorContact] , 0, 'No se ha borrado la lista.');
    }

    @isTest
    static void borrarGrupoColaboradorTest() {

        List<CC_Grupo_Colaborador__c> listaTest = [SELECT Id
                                                        FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedores Test Secundario'];

        Id idGrupoColaborador = listaTest[0].Id;

        User usuarioAdministrador = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_AdministradorGrupos'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioAdministrador.id);       
        SAC_DatabaseDML.insertDML(psa, false);

        system.runAs(usuarioAdministrador){
            Test.startTest();
            SAC_DatabaseDML.deleteListDML(listaTest, false);
            Test.stopTest();
        }


        system.assertEquals([SELECT Count() FROM CC_Grupo_Colaborador__c WHERE Id = :idGrupoColaborador] , 0, 'No se ha borrado la lista.');
    }

    @istest
    static void actualizarSupervisoresTest() {

        User usuarioAdministrador = [SELECT id From User Where Username = 'usuarioAdminGrupocaixa@testcaixa.com' AND isActive = true Limit 1];
        User usuarioQueSeActualiza = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'usergeneralcaixa@testcaixa.com' AND isActive = true];

        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();

        system.runAs(usuarioAdministrador){
            Test.startTest();
            
            grupoColaborador.Name = 'Grupo DXC';
            grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
            grupoColaborador.SAC_PorcentajeAsignacion__c=0;
            grupoColaborador.SAC_MaximoCasosDiarios__c = 15;

            SAC_DatabaseDML.insertDML(grupoColaborador, false);

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = new CC_Grupo_Colaborador_Contact__c();
            grupoColaboradorContact.CC_Grupo_Colaborador__c = grupoColaborador.id;
            grupoColaboradorContact.CC_Usuario__c = usuarioQueSeActualiza.id;
            grupoColaboradorContact.SAC_Supervisor__c = true;

            SAC_DatabaseDML.insertDML(grupoColaboradorContact, false);

            grupoColaboradorContact.SAC_Supervisor__c = false;
            SAC_DatabaseDML.updateDML(grupoColaboradorContact, false);

            grupoColaboradorContact.SAC_Supervisor__c = true;
            SAC_DatabaseDML.updateDML(grupoColaboradorContact, false);

            SAC_DatabaseDML.deleteDML(grupoColaboradorContact, false);
            Test.stopTest();
        }

        System.assertEquals(0, [SELECT Count() FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Usuario__c = :usuarioQueSeActualiza.Id AND CC_Grupo_Colaborador__c =: grupoColaborador.Id], 'NO se ha eliminado el grupo colaborador contact correctamente.');
    }

    @istest
    static void actualizarAdministradoresTest() {

        User usuarioAdministrador = [SELECT id From User Where Username = 'usuarioAdminGrupocaixa@testcaixa.com' AND isActive = true Limit 1];
        User usuarioQueSeActualiza = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'usergeneralcaixa@testcaixa.com' AND isActive = true];

        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();

        system.runAs(usuarioAdministrador){
            Test.startTest();
            
            grupoColaborador.Name = 'COPS';
            grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
            grupoColaborador.SAC_PorcentajeAsignacion__c=0;
            grupoColaborador.SAC_MaximoCasosDiarios__c = 15;

            SAC_DatabaseDML.insertDML(grupoColaborador, false);

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = new CC_Grupo_Colaborador_Contact__c();
            grupoColaboradorContact.CC_Grupo_Colaborador__c = grupoColaborador.id;
            grupoColaboradorContact.CC_Usuario__c = usuarioQueSeActualiza.id;
            grupoColaboradorContact.SAC_Administrador__c = true;

            SAC_DatabaseDML.insertDML(grupoColaboradorContact, false);

            grupoColaboradorContact.SAC_Administrador__c = false;
            SAC_DatabaseDML.updateDML(grupoColaboradorContact, false);

            grupoColaboradorContact.SAC_Administrador__c = true;
            SAC_DatabaseDML.updateDML(grupoColaboradorContact, false);

            SAC_DatabaseDML.deleteDML(grupoColaboradorContact, false);
            Test.stopTest();
        }
        
        System.assertEquals(0, [SELECT Count() FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Usuario__c = :usuarioQueSeActualiza.Id AND CC_Grupo_Colaborador__c =: grupoColaborador.Id], 'NO se ha eliminado el grupo colaborador contact correctamente.');
    }


    @istest
    static void actualizarGrupoMoneyToPayTest() {

        User usuarioAdministrador = [SELECT id From User Where Username = 'usuarioAdminGrupocaixa@testcaixa.com' AND isActive = true Limit 1];
        User usuarioQueSeActualiza = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'usergeneralcaixa@testcaixa.com' AND isActive = true];

        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();

        system.runAs(usuarioAdministrador){
            Test.startTest();
            
            grupoColaborador.Name = 'Grupo DXC';
            grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
            grupoColaborador.SAC_PorcentajeAsignacion__c=0;
            grupoColaborador.SAC_MaximoCasosDiarios__c = 15;

            SAC_DatabaseDML.insertDML(grupoColaborador, false);

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = new CC_Grupo_Colaborador_Contact__c();
            grupoColaboradorContact.CC_Grupo_Colaborador__c = grupoColaborador.id;
            grupoColaboradorContact.CC_Usuario__c = usuarioQueSeActualiza.id;
            grupoColaboradorContact.SAC_Administrador__c = true;

            SAC_DatabaseDML.insertDML(grupoColaboradorContact, false);

            SAC_DatabaseDML.deleteDML(grupoColaboradorContact, false);
            Test.stopTest();
        }
        
        List<CC_Grupo_Colaborador_Contact__c> listaComprobacion = [SELECT Id, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Usuario__c = :usuarioQueSeActualiza.Id AND CC_Grupo_Colaborador__c =: grupoColaborador.Id];

        System.assertEquals(true, listaComprobacion.isEmpty(), 'NO se ha eliminado el grupo colaborador contact correctamente.');
    }  
}