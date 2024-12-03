/*****************************************************************
 * Name: SAC_LCMP_Derivar_Test
 * Copyright © 2021  CaixaBank
 *                                                                                       
 * Proposito: Testear la clase SAC_LCMP_Derivar
 *                                                                                       
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US289217         Carlos Solis         09/11/21     Creación
 * 1.1            US563153         Jose Carlos Blanco  	24/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_Derivar_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC Admin
		User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioAdmin.Username = 'usertestadmin@test.com.testSetup';      
        Database.insert(usuarioAdmin);

        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        Database.insert(permiSetAssiAdmin);

        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioAdmin){
            //EmailTemplate
            EmailTemplate template = new EmailTemplate();
            template.developerName = 'test';
            template.FolderId = usuarioAdmin.Id;
            template.TemplateType= 'Text';
            template.Name = 'test';
            template.Subject = 'testSubject';
            template.HtmlValue = 'test body';
            Database.insert(template);
        }
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE developerName = 'test'];

        System.runAs(usuarioAdmin){

            //SAC_PlantillaRedaccion__c
            SAC_PlantillaRedaccion__c plantillaRed = new SAC_PlantillaRedaccion__c();
            plantillaRed.Name = 'testPlantillaRed';
            plantillaRed.SAC_TipoPlantilla__c = 'SAC_Derivacion';
            plantillaRed.SAC_PlantillaCastellanoId__c = template.Id;
            Database.insert(plantillaRed);

            //Grupos
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',2);
            listaGrupos[0].name = 'grupoA';
            listaGrupos[0].SAC_PorcentajeAsignacion__c = 80;
            listaGrupos[0].SAC_MaximoCasosDiarios__c = 1;
            listaGrupos[0].SAC_PermiteDerivacion__c = true;
            listaGrupos[0].SAC_Email__c = 'testingsac@testsac.testsac';
            listaGrupos[0].SAC_PlantillaConsultaId__c = template.Id;
            listaGrupos[0].SAC_PlantillaReclamacionId__c = template.Id;
            listaGrupos[0].SAC_PlantillaReclamante__c = plantillaRed.Id;
            listaGrupos[1].name = 'grupoB';
            listaGrupos[1].SAC_PorcentajeAsignacion__c = 20;
            listaGrupos[1].SAC_MaximoCasosDiarios__c = 1;
            listaGrupos[1].SAC_PermiteDerivacion__c = true;
            listaGrupos[1].SAC_Email__c = 'testingsac@testsac.testsac';
            listaGrupos[1].SAC_PlantillaConsultaId__c = template.Id;
            listaGrupos[1].SAC_PlantillaReclamacionId__c = template.Id;
            listaGrupos[1].SAC_PlantillaReclamante__c = plantillaRed.Id;

            Database.insert(listaGrupos);  
        }
		
        System.runAs(usuarioGeneral){
            Test.startTest();
            //Account
            Account cuenta = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            Database.insert(cuenta);

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'testRec1');
            camposRecl.put('AccountId', cuenta.Id);
            camposRecl.put('CC_Idioma__c', 'es');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);

            //Consulta
            Map<String, Object> camposCons = new Map<String, Object>();
            camposCons.put('Subject', 'consulta');

            Case consulta = SAC_TestDataFactory.crearCaso('Consulta',camposCons);
            Database.insert(consulta);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SuppliedCompany', 'pret1');
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);

            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            Database.insert(pretension);  

            //Acciones (tareas)
            SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1,reclamacion,false)[0];
            tarea.SAC_Observaciones__c ='tareaTest'; 
            tarea.SAC_PlazoMaximo__c = 10; 
            tarea.SAC_Prorroga__c = 5;
            Database.insert(tarea);

            //Ficheritos (ContentVersion)
            ContentVersion cv = SAC_TestDataFactory.crearContentVersion(reclamacion);
            Database.insert(cv);

            
            //Email Backlist
            SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
            maestroTema.Name ='emailtest@prueba.com';
            maestroTema.SAC_Activo__c = true;
            maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_BlackListEmails').getRecordTypeId();
            Database.insert(maestroTema);

            Test.stopTest();
        }
    }

    @isTest
    static void getCasoTest() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            Case casoFinal = SAC_LCMP_Derivar.getCaso(caso.Id);
            Test.stopTest();

            System.assertEquals(caso.Id, casoFinal.Id, 'No se ha podido recuperar el caso');
        }
    }

    @isTest
    static void buscarGruposTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_LCMP_Derivar.buscarGrupos();
            Test.stopTest();

            System.assertNotEquals(null, listaGrupos, 'No se han podido recuperar los grupos');
        }
    }

    @isTest
    static void buscarOficinaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Account oficina = [SELECT Id FROM Account WHERE PersonEmail = 'acuserecibo0@acuse.com.test' LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            List<Account> listaOficinas = SAC_LCMP_Derivar.buscarOficina(oficina.Id);
            Test.stopTest();

            System.assertNotEquals(null, listaOficinas, 'No se han podido recuperar las oficinas');
        }
    }

    @isTest
    static void getPlantillasTest() {
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoA'];
        Case caso = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Subject = 'testRec1'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_Derivar.TemplateWrapper templateWrap = SAC_LCMP_Derivar.getPlantillas(grupo.Id, caso.RecordType.DeveloperName, caso.Id);
            Test.stopTest();

            System.assertNotEquals(null, templateWrap, 'No se ha podido recuperar la plantilla');
        }
    }

    @isTest
    static void getPlantillaReclamanteTest() {
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoA'];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_Derivar.TemplateWrapper templateWrap = SAC_LCMP_Derivar.getPlantillaReclamante(grupo.Id, caso.Id);
            Test.stopTest();

            System.assertNotEquals(null, templateWrap, 'No se ha podido recuperar la plantilla');
        }
    }

    @isTest
    static void finalizarDerivacionTest() {
        Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'testRec1'];
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        }
        String idsAdjuntos = JSON.serialize(listaIds);

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_Derivar.finalizarDerivacion(caso.Id, 'testingsac@testsac.testsac', '', 'testingsac@testsac.testsac', 'body email', 'subject email', idsAdjuntos, 'GrupoSeleccionado');
            

            Case casoFinal = [SELECT Id, Status FROM Case WHERE Subject = 'testRec1'];
            Case pretensionFinal = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'pret1'];
            SAC_Accion__c tareaFinal = [SELECT Id, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tareaTest'];
            List<EmailMessage> listaEmailMsgFinal = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
            Test.stopTest();

            System.assertEquals('SAC_008', casoFinal.Status, 'No se ha cambiado el estado de la reclamación a derivada');
            System.assertEquals('SAC_009', pretensionFinal.Status, 'No se ha cambiado el estado de la pretensión a baja');
            System.assertEquals('SAC_FinalizadaIncompleta', tareaFinal.SAC_Estado__c, 'No se ha cambiado el estado de la tarea a SAC_FinalizadaIncompleta');
            System.assertNotEquals(listaEmailMsg, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');
        }
    }

    @isTest
    static void enviarEmailClienteTest() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];

        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        }
        String idsAdjuntos = JSON.serialize(listaIds);
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_Derivar.enviarEmailCliente(caso.Id, 'testingsac@testsac.testsac', '', 'testingsac@testsac.testsac', 'body email', 'subject email', idsAdjuntos);
            List<EmailMessage> listaEmailMsgFinal = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
            Test.stopTest();

            System.assertNotEquals(listaEmailMsg, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');
        }
    }

    @isTest 
    static void cerrarCasosTest() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'consulta'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoA'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_Derivar.cerrarCasos(caso.id, grupo.id);
            Test.stopTest();
        }

        Case caso2 = [SELECT Id, Status FROM Case WHERE Subject = 'consulta'];

        System.assertEquals('SAC_008', caso2.Status, 'No se ha cerrado el caso');
    }

    @isTest 
    static void getPlantillasTest2() {
        Case caso = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Subject = 'consulta'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoA'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_Derivar.templateWrapper resultado = SAC_LCMP_Derivar.getPlantillas(grupo.Id, caso.RecordType.DeveloperName, caso.id);
            Test.stopTest();

            System.assertNotEquals(null, resultado, 'No se ha ejecutado el método getPlantillas');
        }
    }

    @isTest
    static void comprobarEmailsEnvioTest() {
    
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        string para = 'emailtest@prueba.com';
        string copia1 ='emailtestcopia1@prueba.com';
        string copia2 ='emailtestcopia2@prueba.com';
        string result;
        Test.startTest();
        System.runAs(usuario){
           result =  SAC_LCMP_Derivar.comprobarEmailsEnvio(para, copia1, copia2);
        }
        System.assertEquals('emailtest@prueba.com', result, 'No coincide');
        Test.stopTest();
    }
}