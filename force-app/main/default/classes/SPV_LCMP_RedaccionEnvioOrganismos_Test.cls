@isTest
public with sharing class SPV_LCMP_RedaccionEnvioOrganismos_Test {
    @TestSetup
    static void makeData() {
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'useraadmin@test.com.testdata';
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            usuarioGeneral.Username = 'userageneral@test.com.testdata';
            SPV_DatabaseDML.insertDML(usuarioGeneral, true);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            SPV_DatabaseDML.insertDML(permiSetAssiAdmin, true);

            PermissionSet ps = new PermissionSet(Name='spvtest',Label='spvtest');
            SPV_DatabaseDML.insertDML(ps, true);
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
            SPV_DatabaseDML.insertListDML(op, true);
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=usuarioGeneral.Id);
            SPV_DatabaseDML.insertDML(psa, true);
        }
        Test.stopTest();

        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoGestor').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        cuenta.CC_Tipo_Centro__c = 'DT';
        SPV_DatabaseDML.insertDML(cuenta, true);

        

        Group supervisores = [SELECT id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar'];


        //grupo colaborador
        List<CC_Grupo_Colaborador__c> listaGrupos = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',1);
        listaGrupos[0].Name = 'grupo de tareas';
        listaGrupos[0].SAC_PermiteTareas__c = true;
        SPV_DatabaseDML.insertListDML(listaGrupos, true);

        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'grupoColaboradorTest';
        grupoColaborador.RecordTypeId = recType;
        grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
        grupos.add(grupoColaborador);

        SPV_DatabaseDML.insertListDML(grupos, true);
  
        List<Case> listaReclamaciones = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'ReclamacionTest';
        caso.Status = 'SPV_EnvioOrganismos';
        caso.SEG_Subestado__c = 'Envio Organismos';
        caso.SEG_Grupo__c = grupoColaborador.id;
        caso.AccountId = cuenta.Id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        caso.OwnerId = usuarioGeneral.Id;
        listaReclamaciones.add(caso);

        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        //Maestro temas
        SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
        maestroTema.Name = 'Alegaciones';
        maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_TipoAdjuntos').getRecordTypeId();
        maestroTema.SAC_DeveloperName__c = 'SPV_Alegaciones';
        maestroTema.SAC_Activo__c = true;

        SPV_DatabaseDML.insertDML(maestroTema, true);

        //Content Version
        // Blob body = blob.valueOf('Unit.Test');
        // ContentVersion cv = new ContentVersion(
        //     Title= 'Documento test', 
        //     PathOnClient ='SampleTitle.pdf',
        //     VersionData = body,
        //     FirstPublishLocationId = caso.Id,
        //     SAC_TipoAdjunto__c = maestroTema.id
        // );
        // Database.insert(cv);

        System.runAs(usuarioGeneral){
        //ContentVersion
        ContentVersion cv = SPV_TestDataFactory.crearContentVersion(caso);
        cv.SAC_TipoAdjunto__c = maestroTema.id;
        cv.SAC_Bloque__c = 'SAC_Respuesta';
        cv.SAC_ValidadoCV__c = true;
        List<ContentVersion> listaCV = new List<ContentVersion>();
        listaCV.add(cv);
        SPV_DatabaseDML.insertListDML(listaCV, true);
        }

        SAC_MaestroAccionesReclamacion__c maestro = SPV_TestDataFactory.crearMaestroAcciones(1,listaGrupos[0].Id)[0];
        maestro.SAC_DeveloperName__c ='SPV_TareaEnvioReclamante';
        SPV_DatabaseDML.insertDML(maestro, true);


        SAC_MaestroAccionesReclamacion__c maestro2 = SPV_TestDataFactory.crearMaestroAcciones(1,listaGrupos[0].Id)[0];
        maestro2.SAC_DeveloperName__c ='SPV_TareaEnvioOrganismo';
        SPV_DatabaseDML.insertDML(maestro2, true);
    }


    @isTest
    static void enviarDocOrganismosTest() {

        Test.startTest();
        User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status, SEG_Subestado__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        System.runAs(usuario) {
            List<ContentVersion> seleccionados = [SELECT id FROM ContentVersion];
            System.debug('CGR seleccionados ' + seleccionados);
            List<String> idSeleccionados = new List<String>();
            for(ContentVersion cv: seleccionados){
                idSeleccionados.add(cv.id);
            }
            SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos(caso.id, true, true, 'SPV_BDE', caso.Status, caso.SEG_Subestado__c, idSeleccionados);
        }
        Case casoActualizado = [SELECT id, Status FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        Test.stopTest();
        system.assertEquals('SPV_PendienteRespuestaOrganismos', casoActualizado.Status, 'No se ha podido enviar la documentacion');
    }


    @isTest
    static void enviarDocOrganismosTest2() {

        Test.startTest();
        User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status, SEG_Subestado__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        System.runAs(usuario) {

            List<ContentVersion> seleccionados = [SELECT id FROM ContentVersion];
        List<String> idSeleccionados = new List<String>();

        for(ContentVersion cv: seleccionados){
            idSeleccionados.add(cv.id);
        }
            SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos(caso.id, true, true, 'SPV_CNMV', caso.Status, caso.SEG_Subestado__c, idSeleccionados);
        }
        Case casoActualizado = [SELECT id, Status FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        Test.stopTest();
        system.assertEquals('SPV_PendienteRespuestaOrganismos', casoActualizado.Status, 'No se ha podido enviar la documentacion');
    }

    @isTest
    static void getDocumentosValidadosTest() {

        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status, SEG_Subestado__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        List<ContentVersion> resultado = new List<ContentVersion> ();
        System.runAs(usuario) {
            resultado = SPV_LCMP_RedaccionEnvioOrganismos.getDocumentosValidados(caso.id);
        }
        Test.stopTest();
        system.assertNotEquals(null , resultado, 'No se ha podido enviar la documentacion');
    }
}