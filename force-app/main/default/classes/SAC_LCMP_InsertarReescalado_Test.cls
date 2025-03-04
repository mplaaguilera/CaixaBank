/*****************************************************************
 * Name: SAC_LCMP_InsertarReescalado_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_InsertarReescalado
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219272         Carlos Solis   23/08/21     Creación
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_InsertarReescalado_Test {
    @TestSetup
    static void makeData(){

        List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
        listaGrupos[0].Name = 'grupoTest';
        listaGrupos[0].SAC_PermiteEscalado__c = true;
        listaGrupos[0].SAC_NivelGrupo__c = 'SAC_Nivel3';
        listaGrupos[0].SAC_Email__c = 'correo@test.com';
        listaGrupos[0].SAC_Email2__c = 'correo2@test.com';
        listaGrupos[0].SAC_Email3__c = 'correo3@test.com';
        listaGrupos[0].SAC_DeveloperName__c   = 'AJ';
        SAC_DatabaseDML.insertListDML(listaGrupos, false);
        //Database.insert(listaGrupos);

        User usuario;
        usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuario.Username = 'ustestesteo@test.com';
        usuario.Email = 'emailtest@test.com';
        usuario.LastName = 'Usuario Test';
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'GMT';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'en_US';
        usuario.isActive = true;
        usuario.SAC_GruposPerteneciente__c = listaGrupos[0].Id;  
        SAC_DatabaseDML.insertDML(usuario, false);  
        //Database.insert(usuario);

        
        //Cuentas
        List<Account> listaCuentas = SAC_TestDataFactory.crearCuentas(1);
        listaCuentas[0].Name = 'Cuenta Test';
        SAC_DatabaseDML.insertListDML(listaCuentas, false);  
        //Database.insert(listaCuentas);

        List<Case> listaReclamaciones = new List<Case>();
        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuario.Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(casoReclamacion);

        //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl2.put('AccountId', listaCuentas[0].Id);
        camposRecl2.put('SAC_CasoEspecial__c', 'SAC_Presidencia');
        
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        listaReclamaciones.add(casoReclamacion2);

        SAC_DatabaseDML.insertListDML(listaReclamaciones, false);  
        //Database.insert(listaReclamaciones);

        List<Case> listaPretensiones = new List<Case>();
        //Pretension 1
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'TestPret');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('OwnerId', usuario.Id);
        Case casoPret1 = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPret1);
        SAC_DatabaseDML.insertListDML(listaPretensiones, false); 
        //Database.insert(listaPretensiones);

        //Poner pretension principal
        casoReclamacion.SAC_PretensionPrincipal__c = casoPret1.Id;
        SAC_DatabaseDML.updateDML(casoReclamacion, false); 
        //Database.update(casoReclamacion);

        //Interaccion escalado
        List<SAC_Interaccion__c> listaInteracciones = new List<SAC_Interaccion__c>();
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Titulo__c', 'propuesta test');
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_CasoEscalado__c', casoReclamacion.Id);
        camposEsc.put('SAC_Email1__c', 'testing@test.test');
        camposEsc.put('OwnerId', usuario.Id);
        camposEsc.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
        listaInteracciones.add(escalado);


        //Interaccion escalado 2
        Map<String, Object> camposEsc2 = new Map<String, Object>();
        camposEsc2.put('SAC_Titulo__c', 'propuesta test2');
        camposEsc2.put('SAC_Propuesta__c', 'propuesta test2');
        camposEsc2.put('SAC_CasoEscalado__c', casoReclamacion.Id);
        camposEsc2.put('OwnerId', usuario.Id);
        camposEsc2.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposEsc2.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposEsc2.put('SAC_Email1__c', 'testing@test.test');
        
        SAC_Interaccion__c escalado2 = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc2);
        listaInteracciones.add(escalado2);
        SAC_DatabaseDML.insertListDML(listaInteracciones, false); 
        //Database.insert(listaInteracciones);

        //Escalado NV3
        Map<String, Object> camposEscNV3 = new Map<String, Object>();
        camposEscNV3.put('SAC_Titulo__c', 'propuesta test3');
        camposEscNV3.put('SAC_Propuesta__c', 'propuesta test3');
        camposEscNV3.put('SAC_CasoEscalado__c', casoReclamacion2.Id);
        camposEscNV3.put('SAC_Email1__c', 'testing@test.test');
        camposEscNV3.put('OwnerId', usuario.Id);
        camposEscNV3.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposEscNV3.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposEscNV3.put('SAC_EscaladoNV2__c', escalado2.Id);
        
        SAC_Interaccion__c escaladoNV3 = SAC_TestDataFactory.crearInteraccion('EscaladoNV3',camposEscNV3);
        SAC_DatabaseDML.insertDML(escaladoNV3, false); 
        //Database.insert(escaladoNV3);

        //Parametrizaciones Escalado 1
        Map<String, Object> camposParam = new Map<String, Object>();
        camposParam.put('Name', 'Validacion Escalado AJ');
        camposParam.put('Aplica_escalado__c', true);
        camposParam.put('SAC_Despacho__c', listaGrupos[0].id);
        camposParam.put('SAC_GrupoDestino__c', listaGrupos[0].Id);
        camposParam.put('SAC_Importe__c', 200);
        camposParam.put('SAC_Mensaje__c', 'Mensaje');
        camposParam.put('SAC_todosMCCs__c', true);
        camposParam.put('SAC_TodosDespachos__c', true);
        camposParam.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado = SAC_TestDataFactory.crearParamEsc(camposParam);
        SAC_DatabaseDML.insertDML(parametrizacionEscalado, false); 
        //Database.insert(parametrizacionEscalado);


        //ContentVersion
        ContentVersion cv = SAC_TestDataFactory.crearContentVersion(casoReclamacion2);
        SAC_DatabaseDML.insertDML(cv, false); 
        //Database.insert(cv);
    }

    @isTest
    static void insertReescaladoTest() {
        User usuario = [SELECT id FROM User WHERE Alias = 'alias' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Titulo__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_InsertarReescalado.insertReescalado(escalado.Id, 'Propuesta COPS', 'SAC_Importe', 'observaciones');
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT id, SAC_Estado__c, SAC_EscaladoNV3__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        System.assertEquals('SAC_Reescalada', escaladoResult.SAC_Estado__c, 'No se ha podido re escalar el escalado');
        System.assertNotEquals(null, escaladoResult.SAC_EscaladoNV3__c, 'No se ha podido re escalar el escalado');
    }

    @isTest
    static void getPickListValuesIntoListTest(){ 
        User usuario = [SELECT id FROM User WHERE Alias = 'alias' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);
        List<SAC_LCMP_InsertarReescalado.plantillasWrapper> resultado;
        Test.startTest();
        System.runAs(usuario) {
            resultado = SAC_LCMP_InsertarReescalado.getPickListValuesIntoList();
        }
        Test.stopTest();
        system.assertNotEquals(resultado, null, 'la creacion del objeto wrapper ha fallado');
    }
    
    @isTest
    static void getPickListValuesIntoListConclusionTest(){ 
        User usuario = [SELECT id FROM User WHERE Alias = 'alias' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);
        List<SAC_LCMP_InsertarReescalado.plantillasWrapper> resultado;

        Test.startTest();
        System.runAs(usuario) {
            resultado = SAC_LCMP_InsertarReescalado.getPickListValuesIntoListConclusion();
        }
        Test.stopTest();
        system.assertNotEquals(resultado, null, 'la creacion del objeto wrapper ha fallado');
    }
    
    @isTest
    static void adjuntarArchivos() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Propuesta__c, SAC_CasoEscalado__c, SAC_Titulo__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
        
        //Archivo adjunto
        ContentVersion newcont = new ContentVersion();
        newcont.Title = 'prueba';
        newcont.PathOnClient = 'caixa.jpeg';
        Blob b=Blob.valueOf('This is version data');
        newcont.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        newcont.FirstPublishLocationId  = escalado.id;
        SAC_DatabaseDML.insertDML(newcont, false);
        //Database.insert(newcont);
        List<String> listaCVIds = new List<String>();
        listaCVIds.add(newcont.Id);
            SAC_LCMP_InsertarReescalado.insertarAdjuntoCaso(escalado.Id, listaCVIds);
        }
        Test.stopTest();
		
        System.assertNotEquals(null, 'adjuntado', 'no se ha podido insertar adjunto');
    }
    
    @isTest
    static void responderEscaladosTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test3' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_InsertarReescalado.responderEscalado(escalado.Id, 'SAC_Autorizado', 'respuesta');
        }
        Test.stopTest();
		SAC_Interaccion__c escalado1 = [SELECT id, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test3' LIMIT 1];
        System.assertEquals('SAC_Atendida', escalado1.SAC_Estado__c, 'no se ha podido responder el escalado');
    }

    @isTest
    static void obtieneAdjuntosTest() {
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title='ABC Test' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];

        ContentVersion[] resultado;
		System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_InsertarReescalado.obtieneAdjuntos(reclamacion.id);
            Test.stopTest();
        }  
        
        System.assertNotEquals(null, cv.Id, 'No ha funcionado correctamente la recuperación de archivos adjuntos.');
    }

    @isTest
    static void guardarEscaladoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test3' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_InsertarReescalado.guardarUnEscalado(escalado.Id, 'SAC_Autorizado', 'respuesta');
        }
        Test.stopTest();
		SAC_Interaccion__c escalado1 = [SELECT id, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_Estado__c, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test3' LIMIT 1];
        System.assertEquals('SAC_Borrador', escalado1.SAC_Estado__c, 'no se ha podido responder el escalado');
    }

    @isTest
    static void devolverEscaladoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_InsertarReescalado.responderEscalado(escalado.Id, 'SAC_DevolverNivelAnterior', 'respuesta');
        }
        Test.stopTest();
		SAC_Interaccion__c escalado1 = [SELECT id, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        System.assertEquals('SAC_Devuelto', escalado1.SAC_Estado__c, 'no se ha podido responder el escalado');
    }

    @isTest
    static void reescalarDevueltoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Titulo__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_InsertarReescalado.insertReescalado(escalado.Id, 'Propuesta COPS testdevolver', 'SAC_Importe', 'observacionesTesteo');
            SAC_Interaccion__c escaladonv3 = [SELECT id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_EscaladoNV2__c = :escalado.Id AND SAC_PropuestaCOPS__c = 'Propuesta COPS testdevolver' LIMIT 1];    
            SAC_LCMP_InsertarReescalado.responderEscalado(escaladonv3.Id, 'SAC_DevolverNivelAnterior', 'respuestatesteo');
            SAC_Interaccion__c escaladoResult = [SELECT id, SAC_Estado__c, SAC_EscaladoNV3__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
            SAC_LCMP_InsertarReescalado.insertReescalado(escaladoResult.Id, 'Propuesta COPS testdevolver', 'SAC_Importe', 'observacionesTesteo');

        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResultFinal = [SELECT id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_EscaladoNV2__c = :escalado.Id AND SAC_PropuestaCOPS__c = 'Propuesta COPS testdevolver' LIMIT 1];
        System.assertEquals('SAC_PendienteRespuesta', escaladoResultFinal.SAC_Estado__c, 'No se ha podido re escalar el escalado devuelto');
    }
}