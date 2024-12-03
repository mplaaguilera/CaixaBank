@isTest
public with sharing class SAC_AdministrarUsuarios_Test {
        @TestSetup
        static void makeData(){    
            User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuarioAdmin.Username = 'usergadmin3@test.com';
            Database.insert(usuarioAdmin);

            CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1)[0];
            grupoColaborador.Name = 'Grupo Proveedores Test';
            grupoColaborador.SAC_PorcentajeAsignacion__c=10;
            grupoColaborador.SAC_MaximoCasosDiarios__c = 5;

            System.runAs(usuarioAdmin){
                Database.insert(grupoColaborador);
            }

            List<CC_Grupo_Colaborador__c> listaGrupoColab = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',3);
            listaGrupoColab[0].Name = 'Grupo Proveedores Test2';
            listaGrupoColab[0].SAC_PorcentajeAsignacion__c=90;
            listaGrupoColab[1].Name = 'Grupo VidaCaixa Test';
            listaGrupoColab[1].SAC_PorcentajeAsignacion__c=90;
            listaGrupoColab[2].Name = 'Asesoría Jurídica';
            listaGrupoColab[2].SAC_PorcentajeAsignacion__c=90;

            CC_Grupo_Colaborador__c grupoColaboradorRespAccion = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            grupoColaboradorRespAccion.Name = 'COPS';
            grupoColaboradorRespAccion.SAC_PorcentajeAsignacion__c=90;
            listaGrupoColab.add(grupoColaboradorRespAccion);
            
            Database.insert(listaGrupoColab);

            List<User> usuariosGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(7);
            usuariosGeneral[0].Username = 'usergeneral@test.com';
            usuariosGeneral[0].SAC_GruposPerteneciente__c = grupoColaborador.id;      
            usuariosGeneral[1].Username = 'usergeneral2@test.com';
            usuariosGeneral[1].SAC_GruposPerteneciente__c = grupoColaborador.id;
            usuariosGeneral[2].Username = 'usergeneral3@test.com';
            usuariosGeneral[2].SAC_GruposPerteneciente__c = grupoColaborador.id;
            usuariosGeneral[3].Username = 'usergeneral4@test.com';
            usuariosGeneral[3].SAC_GruposPerteneciente__c = listaGrupoColab[0].id;
            usuariosGeneral[4].Username = 'usergeneral5@test.com';
            usuariosGeneral[4].SAC_GruposPerteneciente__c = listaGrupoColab[0].id;
            usuariosGeneral[5].Username = 'usergeneral6@test.com';
            usuariosGeneral[5].SAC_GruposPerteneciente__c = listaGrupoColab[1].id;
            usuariosGeneral[6].Username = 'usergeneral7@test.com';
            usuariosGeneral[6].SAC_GruposPerteneciente__c = listaGrupoColab[1].id;
         
            Database.insert(usuariosGeneral);

            //GRUPO COLABORADOR CONTACT
            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SAC_TestDataFactory.crearColaboradorContact(usuariosGeneral[0].Id,grupoColaborador.Id);
            grupoColaboradorContact.SAC_Administrador__c = true;

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContactAdmin = SAC_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id,grupoColaborador.Id);
            grupoColaboradorContactAdmin.SAC_Administrador__c = true;

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SAC_TestDataFactory.crearColaboradorContact(usuariosGeneral[2].Id,grupoColaborador.Id);
            grupoColaboradorContact2.SAC_Administrador__c = false;

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact3 = SAC_TestDataFactory.crearColaboradorContact(usuariosGeneral[3].Id,listaGrupoColab[0].Id);
            grupoColaboradorContact3.SAC_Administrador__c = true;

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact4 = SAC_TestDataFactory.crearColaboradorContact(usuariosGeneral[4].Id,listaGrupoColab[0].Id);
            grupoColaboradorContact4.SAC_Administrador__c = true;

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact5 = SAC_TestDataFactory.crearColaboradorContact(usuariosGeneral[5].Id,listaGrupoColab[1].Id);
            grupoColaboradorContact5.SAC_Administrador__c = true;

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact6 = SAC_TestDataFactory.crearColaboradorContact(usuariosGeneral[6].Id,listaGrupoColab[1].Id);
            grupoColaboradorContact6.SAC_Administrador__c = true;

            List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
            listaColaboradores.add(grupoColaboradorContact2);
            listaColaboradores.add(grupoColaboradorContact);
            listaColaboradores.add(grupoColaboradorContact3);
            listaColaboradores.add(grupoColaboradorContact4);
            listaColaboradores.add(grupoColaboradorContact5);
            listaColaboradores.add(grupoColaboradorContact6);
            listaColaboradores.add(grupoColaboradorContactAdmin);
            Database.insert(listaColaboradores);

            Case casoReclamacion = SAC_TestDataFactory.crearReclamacion(1)[0];
            casoReclamacion.Subject = 'TestRec';
            casoReclamacion.Status = 'SAC_001';
            casoReclamacion.SAC_StatusAuxiliar__c = casoReclamacion.Status;
            casoReclamacion.OwnerId = usuariosGeneral[2].Id;
            casoReclamacion.SEG_Grupo__c = listaGrupoColab[0].id;
            Database.insert(casoReclamacion);
    }

    @IsTest
    public static void insertarUserTest(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral2@test.com' AND IsActive = true ];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedores Test'];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();

        colaboradorNuevo.SAC_Administrador__c = true;
        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        listaUsers.add(colaboradorNuevo);

        User usuarioAdmin = [SELECT Id FROM User WHERE Username = 'usergadmin3@test.com' AND IsActive = true ];
        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        Database.insert(permiSetAssiAdmin);
          
        Test.startTest();

        System.runAs(usuarioAdmin){
            PermissionSet ps = [SELECT id 
                FROM PermissionSet 
                WHERE  PermissionSet.Label ='SAC_AdministradorGrupos'];

            List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];   
            Database.insert(colaboradorNuevo);

            Test.stopTest();

            List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];   

            system.assertNotEquals(psa, psaV2, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
        }
    } 

    @IsTest
    public static void modificarUserTest(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral@test.com' AND IsActive = true ];
        User usuarioGeneral3 = [SELECT Id FROM User WHERE Username = 'usergeneral3@test.com' AND IsActive = true ];
        User admin = [SELECT Id FROM User WHERE Username = 'usergadmin3@test.com' AND IsActive = true  LIMIT 1];

        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = [SELECT Id, SAC_Administrador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: usuarioGeneral.Id];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo2 = [SELECT Id, SAC_Administrador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: usuarioGeneral3.Id];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo3 = [SELECT Id, SAC_Administrador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: admin.Id];

        colaboradorNuevo.SAC_Administrador__c = false;
        colaboradorNuevo2.SAC_Administrador__c = true;

        List<CC_Grupo_Colaborador_Contact__c> listadoUpdate = new List<CC_Grupo_Colaborador_Contact__c>();
        listadoUpdate.add(colaboradorNuevo);
        listadoUpdate.add(colaboradorNuevo2);


        PermissionSet permiso = [SELECT Id FROM PermissionSet WHERE PermissionSet.Label ='SAC_Administrador'];
       
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment asignacionPermiso = new PermissionSetAssignment();
        asignacionPermiso.AssigneeId = admin.Id;
        asignacionPermiso.PermissionSetId = permiso.Id;
        Database.insert(asignacionPermiso);

        Set<Id> ids = new Set<Id>();
        ids.add(colaboradorNuevo.Id);
        ids.add(colaboradorNuevo2.Id);

        List<UserRecordAccess> lstUserRecordAccess = [SELECT RecordId,MaxAccessLevel,HasAllAccess, 
                                                     HasDeleteAccess, 
                                                     HasEditAccess,
                                                     HasReadAccess, 
                                                     HasTransferAccess 
                                                FROM UserRecordAccess 
                                               WHERE UserId =: admin.Id 
                                                 AND RecordId IN: ids];
        
        Test.startTest();
        PermissionSet ps = [SELECT id 
            FROM PermissionSet 
            WHERE  PermissionSet.Label ='SAC_AdministradorGrupos'];
        List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND (AssigneeId =: colaboradorNuevo.CC_Usuario__c OR AssigneeId =: colaboradorNuevo2.CC_Usuario__c OR AssigneeId =: colaboradorNuevo3.CC_Usuario__c)];   
        System.runAs(admin){
            Database.update(listadoUpdate);
        }
        Test.stopTest();
        List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND (AssigneeId =: colaboradorNuevo.CC_Usuario__c OR AssigneeId =: colaboradorNuevo2.CC_Usuario__c OR AssigneeId =: colaboradorNuevo3.CC_Usuario__c)];   

        system.assertNotEquals(psa, psaV2, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
    }

    @isTest
    public static void changeOwnerTest(){

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral5@test.com' AND IsActive = true ];
        User usuarioGeneral2 = [SELECT Id FROM User WHERE Username = 'usergeneral4@test.com' AND IsActive = true ];

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE PermissionSet.Label = 'SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = usuarioGeneral.Id);
        Database.insert(psa);

        Case caso = [SELECT OwnerId FROM Case WHERE Subject = 'TestRec'];
        

        caso.OwnerId = usuarioGeneral2.Id;
        Test.startTest();
        system.runAs(usuarioGeneral){
            Database.SaveResult resultado = Database.update(caso, false);
        }
        Test.stopTest();
        
        Case casoV2 = [SELECT OwnerId FROM Case WHERE Subject = 'TestRec'];
        system.assertNotEquals(caso.OwnerId, casov2.OwnerId, 'La ejecución no ha funcionado a la hora de cambiar los propietarios del caso.');
    }

    @IsTest
    public static void insertarUserVidaCaixa(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral6@test.com' AND IsActive = true ];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo VidaCaixa Test'];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();

        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        listaUsers.add(colaboradorNuevo);

        Test.startTest();

        PermissionSet ps = [SELECT id 
            FROM PermissionSet 
            WHERE  PermissionSet.Name ='SAC_Vidacaixa'];
        
        System.runAs(usuarioGeneral){
            SAC_AdministrarUsuarios.asignarVidaCaixaPermisionSet(listaUsers, 'agregar');
        }
        
        Test.stopTest();
        List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];  

        system.assertNotEquals(null, psaV2, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
    } 

    @IsTest
    public static void deleteUserVidaCaixa(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral7@test.com' AND IsActive = true];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo VidaCaixa Test'];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();

        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        listaUsers.add(colaboradorNuevo);
        Test.startTest();

        PermissionSet ps = [SELECT id 
            FROM PermissionSet 
            WHERE  PermissionSet.Name ='SAC_Vidacaixa'];

        List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];           
        
        System.runAs(usuarioGeneral){
            SAC_AdministrarUsuarios.asignarVidaCaixaPermisionSet(listaUsers, 'eliminar');
        }
        

        Test.stopTest();
        List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];  

        system.assertNotEquals(psa, psaV2, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
    } 

    @IsTest
    public static void insertarUserAJ(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral6@test.com' AND IsActive = true];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Asesoría Jurídica'];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();

        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        listaUsers.add(colaboradorNuevo);

        Test.startTest();

        PermissionSet ps = [SELECT id 
            FROM PermissionSet 
            WHERE  PermissionSet.Name ='SAC_Asignar_Escalado'];
        
        System.runAs(usuarioGeneral){
            SAC_AdministrarUsuarios.asignarAJPermisionSet(listaUsers, 'agregar');
        }
        
        Test.stopTest();
        List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];  

        system.assertNotEquals(null, psaV2, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
    } 

    @IsTest
    public static void deleteUserAJ(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral7@test.com' AND IsActive = true];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Asesoría Jurídica'];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();

        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        listaUsers.add(colaboradorNuevo);
        Test.startTest();

        PermissionSet ps = [SELECT id 
            FROM PermissionSet 
            WHERE  PermissionSet.Name ='SAC_Asignar_Escalado'];

        List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];             

        System.runAs(usuarioGeneral){
            SAC_AdministrarUsuarios.asignarAJPermisionSet(listaUsers, 'eliminar');
        }
        

        Test.stopTest();
        List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];  
        
        system.assertEquals(True, psaV2.isEmpty());
    } 


    @IsTest
    public static void insertarUserAuditor(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral6@test.com' AND IsActive = true];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS'];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();

        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;
        colaboradorNuevo.SAC_Administrador__c = true;

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        listaUsers.add(colaboradorNuevo);

        Test.startTest();

        PermissionSet ps = [SELECT id 
            FROM PermissionSet 
            WHERE  PermissionSet.Name ='SAC_Auditor'];
        
        System.runAs(usuarioGeneral){
            SAC_AdministrarUsuarios.asignarAuditorPermisionSet(listaUsers, 'agregar');
        }
        
        Test.stopTest();
        List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];  

        system.assertNotEquals(null, psaV2, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
    } 

    @IsTest
    public static void deleteUserAuditor(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral7@test.com' AND IsActive = true];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS'];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();

        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        listaUsers.add(colaboradorNuevo);
        Test.startTest();

        PermissionSet ps = [SELECT id 
            FROM PermissionSet 
            WHERE  PermissionSet.Name ='SAC_Auditor'];

        List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];             

        System.runAs(usuarioGeneral){
            SAC_AdministrarUsuarios.asignarAuditorPermisionSet(listaUsers, 'eliminar');
        }
        

        Test.stopTest();
        List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];  
        
        system.assertEquals(True, psaV2.isEmpty());
    } 

    @IsTest
    public static void insertarUserAdministrador(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usergeneral6@test.com' AND IsActive = true];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS'];
        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();

        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;
        colaboradorNuevo.SAC_Administrador__c = false;

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        listaUsers.add(colaboradorNuevo);

        Test.startTest();

        PermissionSet ps = [SELECT id 
            FROM PermissionSet 
            WHERE  PermissionSet.Name ='SAC_Administrador'];
        
        System.runAs(usuarioGeneral){
            SAC_AdministrarUsuarios.asignarAdministradorPermisionSet(listaUsers, 'agregar');
        }
        
        Test.stopTest();
        List<PermissionSetAssignment> psaV2 = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];  

        system.assertNotEquals(null, psaV2, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
    } 
}