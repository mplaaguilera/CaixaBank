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
        caso.SAC_Prorrogado__c = true;
        caso.Status = 'SPV_AnalisisDecision';
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

        List<SAC_MaestroAccionesReclamacion__c> listmaestro = SPV_TestDataFactory.crearMaestroAcciones(8,listaGrupos[0].Id);
        listmaestro[0].SAC_DeveloperName__c = 'SPV_CertificadaReclamante';
        listmaestro[1].SAC_DeveloperName__c = 'SPV_EnvioOrgRectificacion';
        listmaestro[2].SAC_DeveloperName__c = 'SPV_EnvioOrgCompOrg';
        listmaestro[3].SAC_DeveloperName__c = 'SPV_RevisionProrroga';
        listmaestro[4].SAC_DeveloperName__c = 'SPV_RevisionCompEntidad';
        listmaestro[5].SAC_DeveloperName__c = 'SPV_EnvioAllanamiento';
        // listmaestro[6].SAC_DeveloperName__c = 'SPV_EnvioAlegaciones';
        // listmaestro[7].SAC_DeveloperName__c = 'SPV_EnvioDesistimiento';

        SPV_DatabaseDML.insertListDML(listmaestro, true);
    }


    @isTest
    static void enviarDocOrganismosTest() {

        Test.startTest();
        User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status, SEG_Subestado__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        System.runAs(usuario) {
            List<ContentVersion> seleccionados = [SELECT id FROM ContentVersion];
            List<String> idSeleccionados = new List<String>();
            for(ContentVersion cv: seleccionados){
                idSeleccionados.add(cv.id);
            }
            SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos(caso.id, true, true, 'SPV_BDE', idSeleccionados);
        }

        List<SAC_Accion__c> listTarea = [SELECT id FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :caso.Id LIMIT 1];

        Test.stopTest();
        system.assertEquals(false, listTarea.isEmpty(), 'No se ha podido enviar la documentacion');
    }


    @isTest
    static void enviarDocOrganismosTest2() {

        Test.startTest();
        User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status, SEG_Subestado__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        System.runAs(usuario) {

            caso.Status = 'SPV_EnvioRectificacion';
            SPV_DatabaseDML.updateDML(caso, true);

            List<ContentVersion> seleccionados = [SELECT id FROM ContentVersion];
            List<String> idSeleccionados = new List<String>();

            for(ContentVersion cv: seleccionados){
                idSeleccionados.add(cv.id);
            }
            SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos(caso.id, false, true, 'SPV_CNMV', idSeleccionados);

            caso.Status = 'SPV_EnvioComplementaria';
            SPV_DatabaseDML.updateDML(caso, true);
            SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos(caso.id, false, true, 'SPV_CNMV', idSeleccionados);
        }

        List<SAC_Accion__c> listTarea = [SELECT id FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :caso.Id LIMIT 1];

        Test.stopTest();
        system.assertEquals(false, listTarea.isEmpty(), 'No se ha podido enviar la documentacion');
    }

    @isTest
    static void enviarDocOrganismosTest3() {

        Test.startTest();
        User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];

        SPV_Formulario__c formulario = new SPV_Formulario__c();
        formulario.RecordTypeId =  Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_FormularioAnalisisDecision').getRecordTypeId();
        formulario.SPV_Caso__c = caso.Id;
        formulario.SPV_DecisionFinal__c = 'SPV_004';
        SPV_DatabaseDML.insertDML(formulario, true);

        System.runAs(usuario) {

            caso.Status = 'PendienteRespuestaOrganismo';
            caso.SPV_Complementaria_Entidad__c = true;
            SPV_DatabaseDML.updateDML(caso, true);

            List<ContentVersion> seleccionados = [SELECT id FROM ContentVersion];
            List<String> idSeleccionados = new List<String>();

            for(ContentVersion cv: seleccionados){
                idSeleccionados.add(cv.id);
            }
            SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos(caso.id, false, true, 'SPV_CNMV', idSeleccionados);

            caso.Status = 'SPV_Envio';
            SPV_DatabaseDML.updateDML(caso, true);
            SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos(caso.id, false, true, 'SPV_CNMV', idSeleccionados);
        }

        List<SAC_Accion__c> listTarea = [SELECT id FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :caso.Id LIMIT 1];

        Test.stopTest();
        system.assertEquals(false, listTarea.isEmpty(), 'No se ha podido enviar la documentacion');
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

    @isTest
    static void comprobarPermisosUsuarioTest() {

        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, OwnerId FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        Boolean resultado = false;
        System.runAs(usuario) {
            resultado = SPV_LCMP_RedaccionEnvioOrganismos.comprobarPermisosUsuario(caso.id, usuario.Id);
        }
        Test.stopTest();
        Assert.areEqual(false , resultado, 'No se ha podido comprobar los permisos del usuario');
    }
}