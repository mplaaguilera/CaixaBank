@isTest
public with sharing class SPV_LCMP_CrearTarea_Test {
    @TestSetup
    static void makeData(){

        List<User> usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
        usuarioGeneral[0].Username = 'ustestesteo@test.com';   
        usuarioGeneral[1].Username = 'ustestesteoDOS@test.com';     
        Database.insert(usuarioGeneral);
        List<User> usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        Database.insert(usuarioAdmin);

        PermissionSet ps = new PermissionSet(Name='spvtest',Label='spvtest');
        insert ps;
        List<ObjectPermissions> op = new List<ObjectPermissions>();
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='Case',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='CC_Grupo_Colaborador__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true
                                     ));
        insert op;

        insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=usuarioGeneral[0].Id);
        insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=usuarioGeneral[1].Id);

        System.runAs(usuarioGeneral[1]){
            Test.startTest();

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestTarea');
            camposRecl.put('OwnerId', usuarioGeneral[0].Id);
            Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(casoReclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'TestTarea2');
            camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
            camposPret.put('OwnerId', usuarioGeneral[0].Id);
            Case casoPretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
            //Database.insert(casoPretension);  

            //grupo colaborador
            List<CC_Grupo_Colaborador__c> listaGrupos = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',1);
            listaGrupos[0].Name = 'grupo de tareas';
            listaGrupos[0].SAC_PermiteTareas__c = true;
            Database.insert(listaGrupos);

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SPV_TestDataFactory.crearColaboradorContact(usuarioGeneral[1].Id,listaGrupos[0].id);
            Database.insert(grupoColaboradorContact2);

            SAC_MaestroAccionesReclamacion__c maestroTareas = new SAC_MaestroAccionesReclamacion__c();
            maestroTareas.RecordTypeId = Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroAcciones').getRecordTypeId();
            maestroTareas.Name = 'maestro tarea';
            maestroTareas.SAC_Descripcion__c = 'test maestro';
            maestroTareas.SAC_PlazoMaximo__c = 8;
            maestroTareas.SAC_EquipoResponsable__c = listaGrupos[0].Id;
            maestroTareas.SAC_Prorroga__c = 2;
            maestroTareas.SAC_Activo__c = true;

            Database.insert(maestroTareas);

            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            tarea.SAC_EquipoResponsable__c = listaGrupos[0].Id;
            tarea.SAC_Reclamacion__c = casoReclamacion.Id;
            Database.insert(tarea);

            Test.stopTest();
        }

    }

    @isTest
    static void insertarTareaTest() {

        Case caso = [SELECT Id,Subject, Owner.Name FROM Case WHERE subject = 'TestTarea' LIMIT 1];
        CC_Grupo_Colaborador__c grupoTarea = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE name = 'grupo de tareas' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true Limit 1];
        
        String idRec = caso.Id; 
        String descripcion = 'test';
        String equipoResponsableId = grupoTarea.Id;
        Boolean esMaestroOrOtras = true;
        SAC_Accion__c tareaInsertada;

        caso.OwnerId = usuario.Id;
        Database.update(caso);

        System.RunAs(usuario){   
            Test.startTest();
            SPV_LCMP_CrearTarea.insertarTarea(idRec, descripcion, equipoResponsableId, esMaestroOrOtras);
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
        
        String idRec = caso.Id; 
        String descripcion = '';
        String equipoResponsableId = maestroTarea.Id;
        Boolean esMaestroOrOtras = false;
        SAC_Accion__c tareaInsertada;

        caso.OwnerId = usuario.Id;
        Database.update(caso);

        System.RunAs(usuario){   
            Test.startTest();
            SPV_LCMP_CrearTarea.insertarTarea(idRec, descripcion, equipoResponsableId, esMaestroOrOtras);
            tareaInsertada = [SELECT Id FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :idRec LIMIT 1];
            Test.stopTest();
        }

        System.assertNotEquals(null, tareaInsertada.id, 'La ejecucion ha fallado a la hora de insertar la tarea');
    }

    @isTest 
    static void tienePermisosTest() {
        Boolean respuesta=false;
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true LIMIT 1];

        casoReclamacion.OwnerId = usuario.Id;
        Database.update(casoReclamacion);
        

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
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true LIMIT 1];

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
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true LIMIT 1];

        List<SAC_MaestroAccionesReclamacion__c> listaGrupos;

        System.RunAs(usuario){   
            Test.startTest();
            listaGrupos = SPV_LCMP_CrearTarea.camposRequeridosMaestro(casoReclamacion.id, 'MaestroTareas');
            Test.stopTest();
        }
        
        System.assertEquals(null, listaGrupos, 'No se han podido recuperar los grupos');
    }

    @isTest 
    static void tienePermisosTest2() {
        Boolean respuesta=false;
        Case casoReclamacion = [SELECT id, Status, Origin, recordTypeId, RecordType.DeveloperName FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id, Name, UserRoleId, UserRole.Name FROM User WHERE Username = 'ustestesteoDOS@test.com' AND IsActive = true LIMIT 1];

        System.RunAs(usuario){
            Test.startTest();
            respuesta = SPV_LCMP_CrearTarea.tienePermisos(casoReclamacion.id);
            Test.stopTest();
        }

        System.assertEquals(true, respuesta, 'No tiene permisos para insertar una tarea');
    }
}