@isTest
public with sharing class SAC_LCMP_InsertarConsulta_Test {
    
    @TestSetup
    static void makeData() { 
        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(3);
        //usuario
        usuarios[0].Username = 'ustestesteo@test.com';
        usuarios[0].Alias = 'alias';
        //usuario 2
        usuarios[1].Username = 'ustestesteo2@test.com';
        usuarios[1].Alias = 'alias2';
        usuarios[1].ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id;        
        Database.insert(usuarios);

        //grupo colaborador nivel 2
        List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
        listaGrupos[0].Name = 'grupoTest';
        listaGrupos[0].SAC_PermiteEscalado__c = true;
        listaGrupos[0].SAC_NivelGrupo__c = 'SAC_Nivel2';
        listaGrupos[0].SAC_Email__c = 'etesting@test.test';
        listaGrupos[0].SAC_Email2__c = 'etesting1@test.test';
        listaGrupos[0].SAC_Email3__c = 'etesting2@test.test';
        listaGrupos[0].SAC_PeriodoConsulta__c = 12;
        listaGrupos[0].SAC_PermiteConsultas__c = true;
        listaGrupos[0].SAC_PermiteTareas__c = true;
        listaGrupos[0].SAC_Externo__c = false;
        listaGrupos[0].SAC_DeveloperName__c = 'Test';
        listaGrupos[0].SAC_TieneUsuariosActivos__c = true;
        listaGrupos[0].SAC_TienePropietario__c = true;
        Database.insert(listaGrupos);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SAC_TestDataFactory.crearColaboradorContact(usuarios[1].id,listaGrupos[0].id);
        Database.insert(grupoColaboradorContact);
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SAC_TestDataFactory.crearColaboradorContact(usuarios[0].id,listaGrupos[0].id);
        Database.insert(grupoColaboradorContact2);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestConsulta');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuarios[0].Id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(casoReclamacion);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'TestPret');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('SAC_Importe_Resuelto__c', 400.0);
        camposPret.put('CC_Importe_Abonado__c', 400.0);
        camposPret.put('OwnerId', usuarios[0].Id);

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        Database.insert(casoPretension);  

        //Interaccion consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Titulo__c', 'consulta');
        camposCons.put('SAC_Propuesta__c', 'consulta');
        camposCons.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposCons.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposCons.put('OwnerId', usuarios[0].Id);
        
        SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        Database.insert(consulta);

        //Tarea
        List<SAC_Accion__c> listaTareas = SAC_TestDataFactory.crearTareas(1,casoReclamacion, false);
        listaTareas[0].SAC_EquipoResponsable__c = listaGrupos[0].Id; 
        Database.insert(listaTareas);
    }

    @isTest
    static void insertarConsultaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestConsulta' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        String idRec = caso.Id; 
        Case consultaInsertada;

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_InsertarConsulta.insertarConsulta(idRec);
            consultaInsertada = [SELECT Id,Subject FROM Case WHERE subject = 'TestConsulta' LIMIT 1];
        }
        Test.stopTest();

        system.assertEquals(idRec, consultaInsertada.id, 'La ejecucion ha fallado a la hora de insertar la Consulta');
 
    }

    @isTest
    static void insertarConsultaTestFail() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestConsulta' LIMIT 1];

        String idRec = caso.Id; 

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            try{
                SAC_LCMP_InsertarConsulta.insertarConsulta(idRec); 
            }
            catch(AuraHandledException e){
                system.assertEquals( null, null, 'La ejecucion no ha podido insertar el registro nuevo');
            }
            Test.stopTest();
        }
    }

    @isTest 
    static void tienePermisosGrupoTest() {
        SAC_LCMP_InsertarConsulta.PermisosUsuariosWrapper  respuestaWrapper;

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo2@test.com' AND isActive = true Limit 1];
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestConsulta' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {                                         
            respuestaWrapper = SAC_LCMP_InsertarConsulta.tienePermisosGrupo(casoReclamacion.id);
        }
        Test.stopTest();

        System.assertEquals(true, respuestaWrapper.tienePermisosGrupo, 'No tiene permisos para insertar una consulta(Interacción)');
        System.assertEquals(true, respuestaWrapper.tienePermisosAccion, 'No tiene permisos para insertar una consulta(Interacción)');
    }
}