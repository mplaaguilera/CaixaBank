/*****************************************************************
 * Name: SAC_LCMP_ReenvioCartaPostal_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_ReenvioCartaPostal
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US330921     Marcela Neira     14/02/22      Creación
*****************************************************************/
@istest
public with sharing class SAC_LCMP_ReenvioCartaPostal_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);      
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Cuenta
            Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
            cuenta.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Generico').getRecordTypeId();
            SAC_DatabaseDML.insertDML(cuenta, false);
            //Database.insert(cuenta);
            
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'Reclamacion');
            camposRecl.put('AccountId', cuenta.Id);
            
            Case caso = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);

            //Reclamacion sin RT
            Case caso2 = New Case(Subject = 'Sin RT', AccountId = cuenta.id);

            SAC_DatabaseDML.insertDML(caso, false);
            //Database.insert(caso);
            SAC_DatabaseDML.insertDML(caso2, false);
            //Database.insert(caso2);
            
            SAC_DocumentoEnvio__c documento = new SAC_DocumentoEnvio__c(SAC_Caso__c = caso.id, SAC_TipoDocumento__c = 'redacción');
            SAC_DatabaseDML.insertDML(documento, false);
            //Database.insert(documento);
            
            Blob vd =  blob.valueOf('Unit.Test');
            List<ContentVersion> cvs = new List<ContentVersion>();
            ContentVersion cv = new ContentVersion(VersionData = vd, PathOnClient = 'SampleTitle.pdf' , Title = 'tituloTest', FirstPublishLocationId = caso.Id, SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion');
            cvs.add(cv);
            SAC_DatabaseDML.insertListDML(cvs, false);

            //ContentVersion
            ContentVersion adjunto = SAC_TestDataFactory.crearContentVersion(caso);
            List<ContentVersion> listaCV = new List<ContentVersion>();
            listaCV.add(adjunto);
            SAC_DatabaseDML.insertListDML(listaCV, true);

            //grupo colaborador
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
            listaGrupos[0].Name = 'grupo de tareas';
            listaGrupos[0].SAC_PermiteTareas__c = true;
            listaGrupos[0].SAC_Email__c = 'test@test.com';
            SAC_DatabaseDML.insertListDML(listaGrupos, true);
            
            SAC_MaestroAccionesReclamacion__c maestroTema = SAC_TestDataFactory.crearMaestroAcciones(1,listaGrupos[0].Id)[0];
            maestroTema.SAC_DeveloperName__c ='SAC_ImprimirCartasOrdinario';
            SAC_DatabaseDML.insertDML(maestroTema, true);

        }
    }
    
    @istest
    static void reenvioRedaccionCartaPostalTest() {
        Case caso = [SELECT id FROM case WHERE Subject = 'Reclamacion'];
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        string tareaId;

        System.runAs(usuarioGeneral){
            Test.startTest();
            List <ContentVersion> seleccionados = [SELECT id FROM ContentVersion Limit 1];
            String idSeleccionados;
    
            for(ContentVersion cv: seleccionados){
                idSeleccionados = cv.id;
            }
            String idAdjuntosJson = '["' + idSeleccionados + '"]'; 
            tareaId = SAC_LCMP_ReenvioCartaPostal.reenvioRedaccionCartaPostal(caso.id, 'test', 'test', 'test', 'test', '011', '[]');        
            Test.stopTest();
        }
        SAC_DocumentoEnvio__c documentoEnvio = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :caso.id 
                                                AND SAC_TipoDocumento__c = 'reenvioRedaccion' ];

        System.assertNotEquals(null, documentoEnvio, 'No se ha hecho el reenvio de la carta postal');
    }

    @istest
    static void reenvioRedaccionCartaPostalNegativoTest() {
        Boolean hayError;
        Case caso = [SELECT id FROM case WHERE Subject = 'Sin RT'];
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        string tareaId;

        System.runAs(usuarioGeneral){
            Test.startTest();
            try {
                tareaId = SAC_LCMP_ReenvioCartaPostal.reenvioRedaccionCartaPostal(caso.id, 'test', 'test', 'test', 'test', 'test', '');        
            } catch (Exception e) {
                hayError= true;
            } 
            Test.stopTest();
        }
        System.assertEquals(true, hayError, 'No ha saltado el error');
    }

    @isTest
    static void obtenerDatosDireccionTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'Reclamacion' LIMIT 1];
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_LCMP_ReenvioCartaPostal.DatosDireccionWrapper informacion;

        System.runAs(usuarioGeneral){
            Test.startTest();
            informacion = SAC_LCMP_ReenvioCartaPostal.obtenerDatosDireccion(reclamacion.Id);
            Test.stopTest();
        }
        System.assertNotEquals(informacion, null, 'El objeto wrapper con datos de la carta postal no se ha instanciado correctamente.');
    }
}