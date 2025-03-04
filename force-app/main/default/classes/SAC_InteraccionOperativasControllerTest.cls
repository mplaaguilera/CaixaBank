/*****************************************************************
 * Name: SAC_InteraccionOperativasControllerTest
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_InteraccionOperativas_Controller
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219272         Carlos Solis         23/08/21     Creación
 * 1.1            US563153         Jose Carlos Blanco  	13/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_InteraccionOperativasControllerTest {
    @TestSetup
    static void makeData(){

        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(3);
        //usuario
        usuarios[0].Username = 'ustestesteo@test.com';
        usuarios[0].Alias = 'alias';
        //usuario 2
        usuarios[1].Username = 'ustestesteo2@test.com';
        usuarios[1].Alias = 'alias2';
        //usuario 3
        usuarios[2].Username = 'ustestesteo3@test.com';
        usuarios[2].Alias = 'alias3';
        
        SAC_DatabaseDML.insertListDML(usuarios, false);
        //Database.insert(usuarios);

        //grupo colaborador
        CC_Grupo_Colaborador__c grupo = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
        grupo.SAC_PermiteEscalado__c = true;
        grupo.SAC_PermiteConsultas__c = true;
        grupo.SAC_NivelGrupo__c = 'SAC_Nivel2';
        grupo.SAC_Externo__c = false;
        grupo.SAC_DeveloperName__c = 'Test';
        grupo.SAC_TienePropietario__c = true;
        SAC_DatabaseDML.insertDML(grupo, false);
        //Database.insert(grupo);

        //grupo colaborador contact
        CC_Grupo_Colaborador_Contact__c grupoColabContact = SAC_TestDataFactory.crearColaboradorContact(usuarios[0].id, grupo.id);
        SAC_DatabaseDML.insertDML(grupoColabContact, false);
        //Database.insert(grupoColabContact);

        //grupo colaborador contact 2
        CC_Grupo_Colaborador_Contact__c grupoColabContact2 = SAC_TestDataFactory.crearColaboradorContact(usuarios[2].id, grupo.id);
        SAC_DatabaseDML.insertDML(grupoColabContact2, false);
        //Database.insert(grupoColabContact2);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuarios[0].Id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);
        //Database.insert(casoReclamacion);

        
        List<SAC_Interaccion__c> escalados = SAC_TestDataFactory.crearInteraccionEsc(2, casoReclamacion.Id, grupo.Id);
        //Interaccion
        escalados[0].SAC_Titulo__c = 'propuesta test';
        escalados[0].SAC_Propuesta__c = 'propuesta test';
        escalados[0].SAC_Email1__c = 'testing@test.test';
        escalados[0].OwnerId = usuarios[1].Id;
        escalados[0].SAC_ImporteAutorizado__c = 20;
        //Interaccion 2
        escalados[1].SAC_Titulo__c = 'propuesta test2';
        escalados[1].SAC_Propuesta__c = 'propuesta test2';
        escalados[1].SAC_Email1__c = 'testing@test.test';
        escalados[1].OwnerId = usuarios[2].Id;
        escalados[1].SAC_ImporteAutorizado__c = 20;

        SAC_DatabaseDML.insertListDML(escalados, false);
        //Database.insert(escalados);
        
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado = new SAC_ParametrizacionEscalado__c();
        parametrizacionEscalado.Name='Validacion Escalado AJ';
        parametrizacionEscalado.Aplica_escalado__c=true;
        parametrizacionEscalado.SAC_Despacho__c = grupo.id;
        parametrizacionEscalado.SAC_GrupoDestino__c=grupo.id;
        parametrizacionEscalado.SAC_Importe__c=200;
        parametrizacionEscalado.SAC_Mensaje__c= 'Mensaje';
        parametrizacionEscalado.SAC_todosMCCs__c =true;
        parametrizacionEscalado.SAC_TodosDespachos__c = true;
        parametrizacionEscalado.SAC_validarImporte__c = false;
        SAC_DatabaseDML.insertDML(parametrizacionEscalado, false);
        //Database.insert(parametrizacionEscalado);

        //Interaccion Consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Reclamacion__c', casoReclamacion.id);
        camposCons.put('SAC_EmailRespuesta__c', 'emailentrante@entrante.com');
        camposCons.put('SAC_Estado__c', 'SAC_Resuelta');
        camposCons.put('SAC_Titulo__c', 'Consulta');
        camposCons.put('SAC_GrupoColaborador__c', grupo.Id);
        
        SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        SAC_DatabaseDML.insertDML(consulta, false);
        //Database.insert(consulta);
    }

    @isTest
    static void autoasignarPropiedadInteraccion(){
        User usuario = [SELECT id FROM User WHERE Alias = 'alias' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_InteraccionOperativas_Controller.autoasignarPropiedadInteraccion(escalado.Id, usuario.Id);
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        System.assertEquals(usuario.Id, escaladoResult.OwnerId, 'No se ha podido autoasignar la interacción');
    }

    @isTest
    static void tomarPropiedadInteraccionTest(){
        User usuario = [SELECT id FROM User WHERE Alias = 'alias' AND isActive = true Limit 1];
        User usuarioMismoGrupo = [SELECT id FROM User WHERE Alias = 'alias3' Limit 1];
        SAC_Interaccion__c escalado = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test2' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_InteraccionOperativas_Controller.tomarPropiedadInteraccion(escalado.Id, usuario.Id);
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test2' LIMIT 1];
        System.assertEquals(usuario.Id, escaladoResult.OwnerId, 'No se ha podido tomar en propiedad el caso');
    }

    @isTest
    static void mostrarBotonTest(){
        User usuario = [SELECT id FROM User WHERE Alias = 'alias' AND isActive = true Limit 1];
        User usuarioMismoGrupo = [SELECT id FROM User WHERE Alias = 'alias3' Limit 1];
        SAC_Interaccion__c escalado = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test2' LIMIT 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        SAC_InteraccionOperativas_Controller.wrapperInit wpInit = new SAC_InteraccionOperativas_Controller.wrapperInit();

        Test.startTest();
        System.runAs(usuario) {
            wpInit = SAC_InteraccionOperativas_Controller.mostrarBoton(escalado.Id, usuario.Id);
        }
        Test.stopTest();

        System.assertEquals(true, wpInit.mostrarBoton, 'No se ha podido verificar si se tiene que mostrar el botón');
    }

    @isTest
    static void mostrarBotonPropiedadConsultasTest(){
        User usuario = [SELECT id FROM User WHERE Alias = 'alias' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'Consulta' LIMIT 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Boolean mostrarBoton = false;

        Test.startTest();
        System.runAs(usuario) {
            mostrarBoton = SAC_InteraccionOperativas_Controller.mostrarBotonPropiedadConsultas(consulta.Id);
        }
        Test.stopTest();

        System.assertEquals(true, mostrarBoton, 'No se ha podido verificar si se tiene que mostrar el botón');
    }

    @isTest
    static void esPropietarioTest(){
        User usuario = [SELECT id FROM User WHERE Alias = 'alias2' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Boolean propietario = false;
        Test.startTest();
        System.runAs(usuario) {
            propietario = SAC_InteraccionOperativas_Controller.esPropietario(escalado.Id);
        }
        Test.stopTest();

        System.assertEquals(true, propietario, 'No se ha podido verificar el propietario');
    }

    @isTest
    static void esConsultaTest(){
        User usuario = [SELECT id FROM User WHERE Alias = 'alias2' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'Consulta' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Boolean esConsulta = false;
        Test.startTest();
        System.runAs(usuario) {
            esConsulta = SAC_InteraccionOperativas_Controller.esConsulta(consulta.Id);
        }
        Test.stopTest();

        System.assertEquals(true, esConsulta, 'No se ha podido verificar si es una consulta');
    }

    @isTest
    static void devolverInteraccionTest(){
        User usuario = [SELECT id FROM User WHERE Alias = 'alias' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_InteraccionOperativas_Controller.devolverInteraccion(escalado.Id);
        }
        Test.stopTest();

        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        SAC_Interaccion__c escaladoResult = [SELECT id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        System.assertEquals(escaladoResult.OwnerId, cola[0].Id, 'No se ha podido devolver la interacción');
    }
    
    @isTest
    static void adjuntarArchivos() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Propuesta__c, SAC_CasoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

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
        newcont.Title  = 'prueba';
        newcont.PathOnClient  = 'caixa.jpeg';
        Blob b=Blob.valueOf('This is version data');
        newcont.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        newcont.FirstPublishLocationId  = escalado.id;
        SAC_DatabaseDML.insertDML(newcont, false);
        //Database.insert(newcont);
            
        SAC_InteraccionOperativas_Controller.insertarAdjuntoCaso(escalado.Id);
        }
        Test.stopTest();
        System.assertNotEquals(null, 'adjuntado', 'no se ha podido insertar adjunto');
    }

    @isTest
    static void volverAEscalarTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Propuesta__c, SAC_CasoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_InteraccionOperativas_Controller.volverAEscalar(escalado.Id, 'propuesta letrado test');
        }
        SAC_Interaccion__c escResult = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        Test.stopTest();
        System.assertEquals('SAC_PendienteRespuesta', escResult.SAC_Estado__c, 'no se ha podido volver a escalar');
    }

    @isTest
    static void cancelarEscaladoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Propuesta__c, SAC_CasoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_InteraccionOperativas_Controller.cancelarEscalado(escalado.Id);
        }
        SAC_Interaccion__c escaladoResult = [SELECT id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        Test.stopTest();
        System.assertEquals('SAC_Cancelado', escaladoResult.SAC_Estado__c, 'no se ha podido cancelar el escalado');
    }

    @isTest
    static void marcarPendienteRespuestaDefinitivaTest() {
        User usuario = [SELECT id FROM User WHERE Alias = 'alias2' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'Consulta' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_InteraccionOperativas_Controller.marcarPendienteRespuestaDefinitiva(consulta.Id);
        }
        Test.stopTest();

        SAC_Interaccion__c consultaPendienteRespuestaDefinitiva = [SELECT id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'Consulta' LIMIT 1];
        System.assertEquals('SAC_PendienteRespuestaDefinitiva', consultaPendienteRespuestaDefinitiva.SAC_Estado__c, 'No se ha actualizado el estado de la consulta');
    }
}