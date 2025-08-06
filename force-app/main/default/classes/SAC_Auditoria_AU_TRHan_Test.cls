@isTest
public with sharing class SAC_Auditoria_AU_TRHan_Test {
    
    @TestSetup
    static void makeData(){
        Test.startTest();
        UserRole uRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SAC_General'];

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);     
        //Database.insert(usuarioAdmin);

        User usuario;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com';   
            usuario.UserRoleId = uRole.Id;   
            usuario.SAC_PerteneceCOPSAJ__c = true;
            SAC_DatabaseDML.insertDML(usuario, false);
            //Database.insert(usuario);
        }
        Test.stopTest();

        List<CC_Grupo_Colaborador__c> listGrupoColab = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1);
        listGrupoColab[0].Name = 'Grupo Proveedores Test1';
        listGrupoColab[0].OwnerId = usuario.Id;
        SAC_DatabaseDML.insertListDML(listGrupoColab, false);
        //Database.insert(listGrupoColab);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SAC_TestDataFactory.crearColaboradorContact(usuario.Id,listGrupoColab[0].Id);
        grupoColaboradorContact.SAC_Auditor__c = true;
        SAC_DatabaseDML.insertDML(grupoColaboradorContact, false);
        //Database.insert(grupoColaboradorContact);

        Case casoReclamacion = SAC_TestDataFactory.crearReclamacion(1)[0];
        casoReclamacion.Subject = 'TestRec';
        casoReclamacion.Status = 'Cerrado';
        casoReclamacion.SAC_StatusAuxiliar__c = casoReclamacion.Status;
        casoReclamacion.OwnerId = usuario.Id;
        casoReclamacion.SEG_Grupo__c = listGrupoColab[0].id;
        SAC_DatabaseDML.insertDML(casoReclamacion, false);
        //Database.insert(casoReclamacion);

        SEG_Auditoria__c auditoriaPadre = new SEG_Auditoria__c();
        auditoriaPadre.SAC_NombreAuditoria__c = 'Auditoria Test';
        auditoriaPadre.RecordTypeId = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SAC_AuditoriaGeneral').getRecordTypeId();
        auditoriaPadre.OwnerId = usuario.Id;
        auditoriaPadre.SAC_Estado__c = 'SAC_Pendiente';
        SAC_DatabaseDML.insertDML(auditoriaPadre, false);
        //Database.insert(auditoriaPadre);

        SEG_Auditoria__c auditoriaHija = new SEG_Auditoria__c();
        auditoriaHija.SAC_NombreAuditoria__c = 'Auditoria Test Hija Clase Test';
        auditoriaHija.OwnerId = usuario.Id;
        auditoriaHija.RecordTypeId = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SAC_Auditoria').getRecordTypeId();
        auditoriaHija.SAC_Estado__c = 'SAC_Pendiente';
        auditoriaHija.SAC_Tipo__c = 'SAC_Altas';
        auditoriaHija.SAC_AuditoriaGeneral__c = auditoriaPadre.Id;
        auditoriaHija.SAC_Reclamacion__c = casoReclamacion.Id;
        SAC_DatabaseDML.insertDML(auditoriaHija, false);
        //Database.insert(auditoriaHija);
    }

    @isTest
    static void updatearAuditoriaPadre(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        SEG_Auditoria__c auditoria = [SELECT Id, SAC_Estado__c FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'Auditoria Test Hija Clase Test' LIMIT 1];

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General' OR Name = 'SAC_AdministradorGrupos'];
        List<PermissionSetAssignment> listaAsignaciones = new List<PermissionSetAssignment>();

        PermissionSetAssignment permiSetAssiGeneral = new PermissionSetAssignment();
        permiSetAssiGeneral.AssigneeId = usuario.Id;
        permiSetAssiGeneral.PermissionSetId = permiSets[0].Id;
        listaAsignaciones.add(permiSetAssiGeneral);

        PermissionSetAssignment permiSetAssiGeneral1 = new PermissionSetAssignment();
        permiSetAssiGeneral1.AssigneeId = usuario.Id;
        permiSetAssiGeneral1.PermissionSetId = permiSets[1].Id;
        listaAsignaciones.add(permiSetAssiGeneral1);
        SAC_DatabaseDML.insertListDML(listaAsignaciones, false);
        //Database.insert(listaAsignaciones);

        Test.startTest();
        System.runAs(usuario) {
            auditoria.SAC_Estado__c = 'SAC_Completada';
            SAC_DatabaseDML.updateDML(auditoria, false);
            //Database.update(auditoria);
        }
        Test.stopTest();

        Assert.areEqual('SAC_Completada', auditoria.SAC_Estado__c, 'no se ha actualizado la auditoria');
    }
}