@isTest
public with sharing class SPV_QueueableEnvioGGH_Test {
    @TestSetup
    static void makeData(){
        Set<String> objetos = new Set<String>{'CC_MCC__c'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id recordTypeIdMCC1 = mapRTsObjects.get('CC_MCC__c').get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdMCC2 = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMCC3 = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdMCCSAC = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
        
        CC_MCC__c mccTematica = new CC_MCC__c(Name='Tematica', CC_Codigo_Externo__c='a', RecordTypeId=recordTypeIdMCC1, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccServicio = new CC_MCC__c(Name='Servicio', CC_Codigo_Externo__c='b', RecordTypeId=recordTypeIdMCC2, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccMotivo = new CC_MCC__c(Name='Motivo a', CC_Codigo_Externo__c='c', RecordTypeId=recordTypeIdMCC3, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Banca Electrónica', CC_Codigo_Externo__c='d', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');
        
        CC_MCC__c mccTematica2 = new CC_MCC__c(Name='Tematica2', CC_Codigo_Externo__c='a2', RecordTypeId=recordTypeIdMCC1, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccServicio2 = new CC_MCC__c(Name='Servicio2', CC_Codigo_Externo__c='b2', RecordTypeId=recordTypeIdMCC2, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccMotivo2 = new CC_MCC__c(Name='Motivo a2', CC_Codigo_Externo__c='c2', RecordTypeId=recordTypeIdMCC3, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccDetalle2 = new CC_MCC__c(Name='Banca Electrónica2', CC_Codigo_Externo__c='d2', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');

        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
        listaMCCs.add(mccTematica);
        listaMCCs.add(mccServicio);
        listaMCCs.add(mccMotivo);
        listaMCCs.add(mccDetalle);
        
        listaMCCs.add(mccTematica2);
        listaMCCs.add(mccServicio2);
        listaMCCs.add(mccMotivo2);
        listaMCCs.add(mccDetalle2);
        Database.upsert(listaMCCs);

 
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);

            PermissionSet ps = new PermissionSet(Name='spvtest',Label='spvtest');
            insert ps;
            List<ObjectPermissions> op = new List<ObjectPermissions>();
            op.add(new ObjectPermissions(ParentId=ps.Id,
                                        SobjectType='Case',
                                        PermissionsRead=true,
                                        PermissionsViewAllRecords=true));
            op.add(new ObjectPermissions(ParentId=ps.Id,
                                        SobjectType='SAC_MaestroAccionesReclamacion__c',
                                        PermissionsRead=true,
                                        PermissionsViewAllRecords=true
                                        ));
            insert op;

            insert new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=usuarioGeneral.Id);
            }


        //Grupos colaboradores
        List<CC_Grupo_Colaborador__c> gruposColaboradores = new List <CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor.SAC_MaximoCasosDiarios__c = 5;
        grupoGestor.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoGestor);

        CC_Grupo_Colaborador__c grupoLetrado = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',1)[0];
        grupoLetrado.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoLetrado);

        List<CC_Grupo_Colaborador__c> gruposTareas = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',2);
        gruposTareas[0].SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposTareas[0].SAC_DeveloperName__c = 'COPS';
        gruposTareas[0].SAC_PermiteTareas__c = true;
        gruposTareas[1].SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposTareas[1].SAC_DeveloperName__c = 'AJ';
        gruposColaboradores.addAll(gruposTareas);

        System.runAs(usuarioGeneral){
            Database.insert(gruposColaboradores);
        }

        //Colaboradores
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact1 = SPV_TestDataFactory.crearColaboradorContact(usuarioGeneral.Id, grupoGestor.Id);
        grupoColaboradorContact1.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact1);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SPV_TestDataFactory.crearColaboradorContact(usuarioGeneral.Id, grupoLetrado.Id);
        grupoColaboradorContact2.SAC_Administrador__c = false;
        listaColaboradores.add(grupoColaboradorContact2);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact3 = SPV_TestDataFactory.crearColaboradorContact(usuarioGeneral.Id, gruposTareas[0].Id);
        grupoColaboradorContact3.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact3);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact4 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, gruposTareas[0].Id);
        grupoColaboradorContact4.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact4);

        System.runAs(usuarioGeneral){
            Database.insert(listaColaboradores);
        }

        List<Case> listaReclamaciones = new List<Case>();
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_TipoConsumidor__c', 'No');
        camposRecl.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRecCrearTareas');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

        //Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Otros');
        camposRecl3.put('Status', 'SAC_004');
        camposRecl3.put('SAC_TipoConsumidor__c', 'No');
        camposRecl3.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl3.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl3);

        //Reclamaciones
        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(casoReclamacion);
        reclamaciones.add(casoReclamacion2);
        reclamaciones.add(casoReclamacion3);
        System.runAs(usuarioGeneral){
            Database.insert(reclamaciones);
        }


        //Maestro acciones reclamacion
        List<SAC_MaestroAccionesReclamacion__c> listaMaestroAccionesRec = SPV_TestDataFactory.crearMaestroAcciones(1, gruposTareas[0].Id);
        listaMaestroAccionesRec[0].SAC_DeveloperName__c = 'SPV_GGH';
        Database.insert(listaMaestroAccionesRec);

    
        //Tareas
        List<SAC_Accion__c> tareas = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaDeTareasOtras = SPV_TestDataFactory.crearTareas(2,casoReclamacion,null);
        
        //Tarea 0
        listaDeTareasOtras[0].SAC_Observaciones__c = 'tarea';
        listaDeTareasOtras[0].SAC_PlazoMaximo__c = 10;
        listaDeTareasOtras[0].SAC_Prorroga__c = 5;
        listaDeTareasOtras[0].OwnerId = usuarioAdmin.id;
        listaDeTareasOtras[0].SPV_GrupoTarea__c = gruposTareas[0].Id;

        //Tarea 1
        listaDeTareasOtras[1].SAC_Observaciones__c = 'tarea1';
        listaDeTareasOtras[1].SAC_PlazoMaximo__c = 10;
        listaDeTareasOtras[1].SAC_Prorroga__c = 5;
        listaDeTareasOtras[1].OwnerId = usuarioAdmin.id;
        listaDeTareasOtras[1].SPV_GrupoTarea__c = gruposTareas[0].Id;
        listaDeTareasOtras[1].SAC_Reclamacion__c = casoReclamacion3.Id;

        tareas.addAll(listaDeTareasOtras);

        System.runAs(usuarioAdmin){
            Database.insert(tareas);
        }

        Test.stopTest();
    }

    @isTest
    static void envioGGHTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearTareas' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c mAccionesRec = [SELECT Id, SAC_Descripcion__c, SAC_EquipoResponsable__c, SAC_PlazoMaximo__c, SAC_Prorroga__c FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'NombreTareaTest0' LIMIT 1];
       
        CBK_IntegrationSetting__c csGGH = new CBK_IntegrationSetting__c();
        csGGH.Name = 'SAC_GGH_Callout';
        csGGH.NamedCredential__c = 'callout:API_GWT_PRE/tech/gdsusr/api/GGHAPI/AltaReclamacion';
        Database.insert(csGGH);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
        Test.startTest();

        System.runAs(usuario) {
            //Tarea 2
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Observaciones__c = 'tareatest';
            tarea.SAC_PlazoMaximo__c = 10;
            tarea.SAC_Prorroga__c = 5;
            tarea.OwnerId = usuario.id;
            tarea.SAC_MaestroAccionesReclamacion__c = mAccionesRec.Id;
            tarea.SAC_Reclamacion__c = reclamacion.Id;
            tarea.SAC_NumeroContrato__c = '65465132135';
            tarea.SAC_NCuentaAbono__c = '97831256';
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            Database.insert(tarea);

            //Content Version
            Blob body = blob.valueOf('Unit.Test');
            ContentVersion cv = new ContentVersion(
                Title= 'Documento test', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = body,
                FirstPublishLocationId = tarea.Id
            );
            Database.insert(cv);

            tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
            Database.update(tarea);
        }

        SAC_Accion__c tareaResult = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tareatest'];
        Assert.areNotEqual(null, tareaResult.SAC_Estado__c, 'no se ha hecho el envio de GGH');
        Test.stopTest();
    }
}