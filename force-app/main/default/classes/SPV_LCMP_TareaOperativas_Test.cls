@isTest
public with sharing class SPV_LCMP_TareaOperativas_Test {
    @TestSetup
    static void makeData(){
        List<User> usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
        usuarioGeneral[0].Username = 'ustestesteo@test.com';   
        usuarioGeneral[1].Username = 'ustestesteoDOS@test.com';     
        Database.insert(usuarioGeneral);
        List<User> usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        usuarioAdmin[0].Username = 'usadtesteo1@test.com';
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
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='Account',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='Contact',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='SAC_Accion__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
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
            tarea.SAC_Observaciones__c = 'Llamar';
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            tarea.SAC_EquipoResponsable__c = listaGrupos[0].Id;
            tarea.SAC_Reclamacion__c = casoReclamacion.Id;
            tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
            Database.insert(tarea);

            Test.stopTest();
        }
    }

    @isTest
    static void tomarPropiedadTareaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.tomarPropiedadTarea(tarea.Id, usuario.Id);
        }

        String nuevoPropetarioTarea = [SELECT id, ownerId FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1].ownerId;

        System.assertEquals(usuario.id, nuevoPropetarioTarea, 'No ha cambiado de propietario');
        Test.stopTest();
    }

    @isTest
    static void devolverTareaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.devolverTarea(tarea.Id);
        }

        String nuevoPropetarioTarea = [SELECT id, ownerId FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1].ownerId;

        System.assertNotEquals(usuario.id, nuevoPropetarioTarea, 'No se ha devuelto a la cola');
        Test.stopTest();
    }

    @isTest
    static void devolverTareaGestorLetradoTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.devolverTareaGestorLetrado(tarea.Id, 'motivo devolucion test');
        }

        String nuevoPropetarioTarea = [SELECT id, ownerId FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1].ownerId;

        System.assertNotEquals(usuario.id, nuevoPropetarioTarea, 'No se ha devuelto al gestor');
        Test.stopTest();
    }

    @isTest
    static void enviarTareaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.enviarTarea(tarea.Id);
        }

        SAC_Accion__c tareaResult = [SELECT SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals('SAC_PendienteAsignar', tareaResult.SAC_Estado__c, 'No se ha enviado');
        Test.stopTest();
    }

    @isTest
    static void enviarTareaDevueltaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            tarea.SAC_Estado__c = 'SAC_Devuelta';
            Database.update(tarea);
            SPV_LCMP_TareaOperativas.enviarTarea(tarea.Id);
        }

        SAC_Accion__c tareaResult = [SELECT SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals('SAC_PendienteAsignar', tareaResult.SAC_Estado__c, 'No se ha enviado');
        Test.stopTest();
    }

    @isTest
    static void comprobarUserEsDelGrupoTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupo de tareas'];
        Boolean result = false;
        
        System.runAs(usuario) {
            result = SPV_LCMP_TareaOperativas.comprobarUserEsDelGrupo(usuario.Id, grupo.Id);
        }

        System.assertEquals(true, result, 'No se ha comprobado');
        Test.stopTest();
    }

    @isTest
    static void prorrogarTareaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        Date fecha = System.today().addDays(1);
        DateTime fechaDateTime = DateTime.newInstance(fecha.year(), fecha.month(), fecha.day());
        String dayOfWeek = fechaDateTime.format('E');

        //Comprobar si la fecha es sábado o domingo y ajustarla para que no salte la validation rule.
        while (dayOfWeek == 'Sat' || dayOfWeek == 'Sun') {
            fecha = fecha.addDays(1);
            fechaDateTime = DateTime.newInstance(fecha.year(), fecha.month(), fecha.day());
            dayOfWeek = fechaDateTime.format('E');
        }

        String year = String.valueOf(fecha.year());
        String month = String.valueOf(fecha.month());
        String day = String.valueOf(fecha.day());

        if (month.length() == 1) {
            month = '0' + month;
        }
        if (day.length() == 1) {
            day = '0' + day;
        }
        String fechaString = year + '-' + month + '-' + day;
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.prorrogarTarea(tarea.Id, fechaString);
        }

        SAC_Accion__c tareaResult = [SELECT SAC_FechaVencimientoProrroga__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals(fecha, tareaResult.SAC_FechaVencimientoProrroga__c, 'No se ha prorrogado');
        Test.stopTest();
    }

    @isTest
    static void descartarTareaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.descartarTarea(tarea.Id, 'comentariotest');
        }

        SAC_Accion__c tareaResult = [SELECT SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals('SAC_Descartada', tareaResult.SAC_Estado__c, 'No se ha descartado');
        Test.stopTest();
    }

    @isTest
    static void finalizarIncompletaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.finalizarIncompleta(tarea.Id, 'comentariotest');
        }

        SAC_Accion__c tareaResult = [SELECT SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals('SAC_FinalizadaIncompleta', tareaResult.SAC_Estado__c, 'No se ha finalizado');
        Test.stopTest();
    }

    @isTest
    static void finalizarTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id, ownerId, SAC_EquipoResponsable__c FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.finalizarTarea(tarea.Id, 'comentariotest');
        }

        SAC_Accion__c tareaResult = [SELECT SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals('SAC_Finalizada', tareaResult.SAC_Estado__c, 'No se ha finalizado');
        Test.stopTest();
    }

    @isTest
    static void usuarioPerteneceGrupoCasoTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        Boolean result = false;
        
        System.runAs(usuario) {
            tarea = SPV_LCMP_TareaOperativas.recuperarTarea(tarea.Id);
            result = SPV_LCMP_TareaOperativas.usuarioPerteneceGrupoCaso(tarea, usuario.Id);
        }

        System.assertEquals(false, result, 'No se ha comprobado');
        Test.stopTest();
    }

    @isTest
    static void perteneceCOPSAJTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        Boolean result = false;
        
        System.runAs(usuario) {
            result = SPV_LCMP_TareaOperativas.perteneceCOPSAJ(usuario.Id);
        }

        System.assertEquals(false, result, 'No se ha comprobado');
        Test.stopTest();
    }

    @isTest
    static void usuarioPerteneceGrupoTareaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        Boolean result = false;
        
        System.runAs(usuario) {
            tarea = SPV_LCMP_TareaOperativas.recuperarTarea(tarea.Id);
            result = SPV_LCMP_TareaOperativas.usuarioPerteneceGrupoTarea(tarea, usuario.Id);
        }

        System.assertEquals(true, result, 'No se ha comprobado');
        Test.stopTest();
    }

    @isTest
    static void enviarTareaGGHTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        Boolean result = false;
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.enviarTareaGGH(tarea.Id);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals('SAC_PendienteAsignar', tareaResult.SAC_Estado__c, 'No se ha enviado');
        Test.stopTest();
    }

    @isTest
    static void enviarTareaGGHFailTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        Boolean result = false;
        
        System.runAs(usuario) {
            try {
                SPV_LCMP_TareaOperativas.enviarTareaGGH(null);
            } catch (Exception e) {
                SAC_Accion__c tareaResult = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
                System.assertNotEquals('SAC_PendienteAsignar', tareaResult.SAC_Estado__c, 'No se ha enviado');
            }
        }
        
        Test.stopTest();
    }

    @isTest
    static void finalizarTareaGGHTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        Boolean result = false;
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.finalizarTareaGGH(tarea.Id);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals('SAC_Finalizada', tareaResult.SAC_Estado__c, 'No se ha finalizado');
        Test.stopTest();
    }

    @isTest
    static void enviarTareaOficinaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupo de tareas'];
        Case casoReclamacion = [SELECT Id FROM Case WHERE Subject = 'TestTarea'];

        List<Account> listaCuentas = new List<Account>();
        //Cuentas
        listaCuentas = SPV_TestDataFactory.crearCuentas(1);
        listaCuentas[0].Name = 'Cuenta A';
        listaCuentas[0].CC_Tipo_Centro__c = 'OF';
        listaCuentas[0].Phone = '123456789';
        listaCuentas[0].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[0].billingStreet  = 'Calle Mayor 55';
        listaCuentas[0].BillingCountry = 'España';
        listaCuentas[0].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Database.insert(listaCuentas);
        
        System.runAs(usuario) {
            SAC_MaestroAccionesReclamacion__c maestroTareas = new SAC_MaestroAccionesReclamacion__c();
            maestroTareas.RecordTypeId = Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroAcciones').getRecordTypeId();
            maestroTareas.Name = 'maestro tarea';
            maestroTareas.SAC_Descripcion__c = 'test maestro';
            maestroTareas.SAC_PlazoMaximo__c = 8;
            maestroTareas.SAC_EquipoResponsable__c = grupo.Id;
            maestroTareas.SAC_Prorroga__c = 2;
            maestroTareas.SAC_Activo__c = true;
            maestroTareas.SAC_DeveloperName__c = 'SPV_GENERALOFICINAS';
            Database.insert(maestroTareas);

            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Observaciones__c = 'Llamar2';
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            tarea.SAC_EquipoResponsable__c = grupo.Id;
            tarea.SAC_Reclamacion__c = casoReclamacion.Id;
            tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
            tarea.SAC_MaestroAccionesReclamacion__c = maestroTareas.Id;
            tarea.SAC_Oficina__c = listaCuentas[0].Id;
            tarea.SAC_Comentarios__c = 'prueba';
            Database.insert(tarea);

            SPV_LCMP_TareaOperativas.enviarTarea(tarea.Id);
        }

        SAC_Accion__c tareaResult = [SELECT SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar2' LIMIT 1];

        System.assertEquals('SAC_PendienteAsignar', tareaResult.SAC_Estado__c, 'No se ha enviado');
        Test.stopTest();
    }

    @isTest
    static void notificarTareaResolutorTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND isActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM   SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];
        
        System.runAs(usuario) {
            SPV_LCMP_TareaOperativas.notificarTareaResolutor(tarea.Id,'test comentarios');
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Llamar' LIMIT 1];

        System.assertEquals('SAC_PendienteEnviar', tareaResult.SAC_Estado__c, 'No se ha finalizado');
        Test.stopTest();
    }
}