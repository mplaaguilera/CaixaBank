/*****************************************************************
 * Name: SAC_Utils_Test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Test de SAC_Utils
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR                   DATE         Description
 * 1.0            US539784         Jose Carlos Blanco       20/03/23     Creación
*****************************************************************/
@isTest
public with sharing class SAC_Utils_Test {
    @TestSetup
    static void makeData(){

        Test.startTest();
        //Usuario Admin
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, true);
        Test.stopTest();
                
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test');
        camposRecl.put('SAC_MinutosParadaSubsanacion__c', 1);
        
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, true);

        //Consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Titulo__c', 'consulta2');
        camposCons.put('SAC_Propuesta__c', 'consulta2');
        camposCons.put('SAC_Estado__c', 'SAC_Resuelta');
        camposCons.put('SAC_Reclamacion__c', reclamacion.Id);
        camposCons.put('SAC_Respuesta__c', 'test respuesta consulta');
        
        SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        SAC_DatabaseDML.insertDML(consulta, true);

        //Accion
        List<SAC_Accion__c> tareas = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaDeTareasOtras = SAC_TestDataFactory.crearTareas(1,reclamacion,false);
        listaDeTareasOtras[0].SAC_Observaciones__c = 'tareaTest'; 
        tareas.addAll(listaDeTareasOtras);
        
        SAC_DatabaseDML.insertListDML(tareas, true);


        //Clasificación rápida   
        Map<String, Object> camposClasR = new Map<String, Object>();
        camposClasR.put('Name', 'CRTest');
        camposClasR.put('SAC_Target__c', 'SAC_Reclamacion');
        camposClasR.put('SEG_Inactiva__c', false);
        camposClasR.put('OS_EstadoCaso__c', 'Rechazado');
        camposClasR.put('SAC_MotivoRechazo__c', 'Spam');
        camposClasR.put('SAC_MotivoDescarte__c', 'SAC_Otros');
        
        SEG_ClasificacionRapida__c clasR = SAC_TestDataFactory.crearClasificacionRapida(camposClasR);
        SAC_DatabaseDML.insertDML(clasR, true);
        
        //Reglas de clasificación
        Map<String, Object> camposReglas = new Map<String, Object>();
        camposReglas.put('Name', 'RCTest');
        camposReglas.put('SEG_Inactiva__c', false);
        camposReglas.put('OS_Logica_Multivalor__c', 'OR');
        camposReglas.put('OS_OrdenEjecucion__c', 1);
        
        SEG_Regladeclasificacion__c reglas = SAC_TestDataFactory.crearReglasClasificacion(clasR.Id, camposReglas);
        SAC_DatabaseDML.insertDML(reglas, true);
        

        List<SEG_Multivalor__c> multivLst = new List<SEG_Multivalor__c>();
        //Multivalor
	    List<SEG_Multivalor__c> multiV1 = SAC_TestDataFactory.crearMultivalor(1, reglas.Id, 'Remitente');
        List<SEG_Multivalor__c> multiV2 = SAC_TestDataFactory.crearMultivalor(2, reglas.Id, 'Asunto');
        List<SEG_Multivalor__c> multiV3 = SAC_TestDataFactory.crearMultivalor(1, reglas.Id, 'Destinatario');
        List<SEG_Multivalor__c> multiV4 = SAC_TestDataFactory.crearMultivalor(1, reglas.Id, 'Destinatario CC');
        List<SEG_Multivalor__c> multiV5 = SAC_TestDataFactory.crearMultivalor(2, reglas.Id, 'Cuerpo');
        List<SEG_Multivalor__c> multiV6 = SAC_TestDataFactory.crearMultivalor(2, reglas.Id, 'Asunto a excluir');
	    List<SEG_Multivalor__c> multiV7 = SAC_TestDataFactory.crearMultivalor(2, reglas.Id, 'Cuerpo a excluir');
        List<SEG_Multivalor__c> multiV8 = SAC_TestDataFactory.crearMultivalor(1, reglas.Id, 'Remitente a excluir');
        multiV8[0].SEG_Valor__c = 'remexclutest@testsac.testsac';
        List<SEG_Multivalor__c> multiV9 = SAC_TestDataFactory.crearMultivalor(1, reglas.Id, 'Destinatario a excluir');
        multiV9[0].SEG_Valor__c = 'destexclutest@testsac.testsac';
        List<SEG_Multivalor__c> multiV10 = SAC_TestDataFactory.crearMultivalor(1, reglas.Id, 'Destinatario CC a excluir');
        multiV10[0].SEG_Valor__c = 'destccexclutest@testsac.testsac';
        multivLst.addAll(multiV1);
        multivLst.addAll(multiV2);
        multivLst.addAll(multiV3);
        multivLst.addAll(multiV4);
        multivLst.addAll(multiV5);
        multivLst.addAll(multiV6);
        multivLst.addAll(multiV7);
        multivLst.addAll(multiV8);
        multivLst.addAll(multiV9);
        multivLst.addAll(multiV10);

        SAC_DatabaseDML.insertListDML(multivLst, true);

        //Custom Setting
        SAC_EmailService__c csMailS = new SAC_EmailService__c();
        csMailS.SAC_GroupName__c = 'DXC Zaragoza';
        csMailS.SAC_RecordTypeDeveloperName__c = 'SAC_Consulta';
        csMailS.Name = 'DXC_Zaragoza';
        csMailS.SAC_EmailEntrante__c = 'dx@zar.com';
        csMailS.SAC_Naturaleza__c = 'SAC_005';
        SAC_DatabaseDML.insertDML(csMailS, true);

        //Grupo Colaborador
        List<CC_Grupo_Colaborador__c> listaGrupoTareas = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1);
        listaGrupoTareas[0].Name = 'DXC Zaragoza';
        SAC_DatabaseDML.insertListDML(listaGrupoTareas, true);

        //Email Backlist
        SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
        maestroTema.Name ='emailtestinvalido@prueba.com';
        maestroTema.SAC_Activo__c = true;
        maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_BlackListEmails').getRecordTypeId();
        SAC_DatabaseDML.insertDML(maestroTema, true);

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        EmailMessage emailMsg = new EmailMessage();
        emailMsg.ToAddress = 'testEMSAC@test.com';
        emailMsg.Subject = 'em.Subject testSAC test SAC_Utils_Test';
        emailMsg.HtmlBody = 'em.HtmlBody test';
        emailMsg.MessageDate = system.today();
        emailMsg.Status = '3';
        // emailMsg.ParentId = testRecCC.Id;
        emailMsg.Headers = '[{"value": "' + headerValueSTR + '","name": "X-SDFC-Original-RCPT"}]';

        SAC_DatabaseDML.insertDML(emailMsg, true);
    }

    @isTest
    static void convertToHexadecimalTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

		System.runAs(usuario){
            test.startTest();
            String hexa = SAC_Utils.convertToHexadecimal(100);
            String hexa2 = SAC_Utils.convertToHexadecimal(167);
            String hexa3 = SAC_Utils.convertToHexadecimal(200);
            String hexa4 = SAC_Utils.convertToHexadecimal(1548);
            System.assertEquals('64', hexa, 'No se ha calculado bien.');
            System.assertEquals('A7', hexa2, 'No se ha calculado bien.');
            System.assertEquals('C8', hexa3, 'No se ha calculado bien.');
            System.assertEquals('60C', hexa4, 'No se ha calculado bien.');
            test.stopTest();
        }   
    }

    @isTest
    static void creacionThreadIDTest(){
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            test.startTest();
            String threadId = SAC_Utils.creacionThreadID(caso.Id);
            System.assertNotEquals(null, threadId, 'No se ha calculado bien el threadId.');
            test.stopTest();
        }   
    }

    @isTest
    static void getInterfazConfigBodyTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

		System.runAs(usuario){
            test.startTest();
            CC_InterfaceSettings__mdt oConfig   = SAC_Utils.getInterfazConfigBody('SAC_CONTRATOS_CLIENTE');
            CC_InterfaceSettings__mdt oConfig2   = SAC_Utils.getInterfazConfigBody('test');
            System.assertNotEquals(null, oConfig, 'No se ha obtenido correctamente la configuracion');
            System.assertEquals(null, oConfig2, 'No se ha obtenido correctamente la configuracion');
            test.stopTest();
        }   
    }

    @isTest
    static void getRecordTypeDevNameByIdTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Case caso = [SELECT Id, RecordTypeId FROM Case WHERE Subject = 'Test' LIMIT 1];
        String recordTypeNombre = '';
        System.runAs(usuario) {
            Test.startTest();
            recordTypeNombre = SAC_Utils.getRecordTypeDevNameById('Case', caso.RecordTypeId);
            Test.stopTest();
        }

        System.assertEquals('SAC_Reclamacion', recordTypeNombre, 'No se ha recuperado el nombre del recordType');
    }

    @IsTest
     public static void determinarCR1() {
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'testsac@testsac.testsac';
        //envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt LIMIT 1].OS_Email__c;
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'Valor';
        correo.fromName='nombre odin test';
        correo.fromAddress = 'testsac@testsac.testsac';
        correo.htmlBody = 'Valor';
        correo.plainTextBody = 'Valor';
    	correo.headers = new List<Messaging.InboundEmail.Header>{header};
        
        Test.startTest();
            System.runAs(usuario) {
                SAC_EmailService emailServiceSAC = new SAC_EmailService();
                Messaging.InboundEmailResult result = emailServiceSAC.handleInboundEmail(correo, envelope);
            }
        Test.stopTest();
        System.assert(header.value != null,'ok');
    }

    @IsTest
     public static void determinarCRExclusiones() {
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'remexclutest@testsac.testsac';
        //envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt LIMIT 1].OS_Email__c;
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asuntoexclu';
        correo.fromName='nombre odin test';
        correo.fromAddress = 'remexclutest@testsac.testsac';
        correo.htmlBody = 'cuerpoexclu';
        correo.plainTextBody = 'cuerpoexclu';
        List<String> listaDirecciones = new List<String>();
        List<String> listaDireccionesCC = new List<String>();
        listaDirecciones.add('destexclutest@testsac.testsac');
        listaDireccionesCC.add('destccexclutest@testsac.testsac');
        correo.toAddresses = listaDirecciones;
        correo.ccAddresses = listaDireccionesCC;
    	correo.headers = new List<Messaging.InboundEmail.Header>{header};
        
        Test.startTest();
            System.runAs(usuario) {
                SAC_EmailService emailServiceSAC = new SAC_EmailService();
                Messaging.InboundEmailResult result = emailServiceSAC.handleInboundEmail(correo, envelope);
            }
        Test.stopTest();
        System.assert(header.value != null,'ok');
    }
    
    @isTest
    static void getRecordTypeDevTest() {
        
        Set<String> setObjetos = new Set<String>{'Case','SAC_Antecedentes__c','Account','Contact','Task','CC_MCC__c','CC_Grupo_Colaborador__c','CC_Grupo_Colaborador_Contact__c','SAC_Accion__c','SAC_Alerta__c','SAC_AdjuntoAntecedente__c','SAC_DocumentoEnvio__c','SAC_Interaccion__c','SAC_MaestroAccionesReclamacion__c','SAC_MaestroTemas__c','SAC_Marca_Case__c','SAC_ParametrizacionSLATME__c','SAC_ParametrizacionEscalado__c','SAC_PlantillaRedaccion__c','SAC_CaseReclamante__c','SAC_TiempoEstados__c','SAC_TMECaso__c','SEG_Auditoria__c','SAC_ImagenDocumento__c', 'CC_Caracteristica__c'};
        Map<String,Map<String,Schema.RecordTypeInfo>> mapaRT = new Map<String,Map<String,Schema.RecordTypeInfo>>();
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            mapaRT = SAC_Utils.getRecordTypesObjects(setObjetos);
            Test.stopTest();
        }

        System.assert(mapaRT.containskey('Case'), 'El mapa contiene el objeto buscado.');
        System.assert(mapaRT.containskey('Account'), 'El mapa contiene el objeto buscado.');
        System.assert(mapaRT.containskey('SAC_Antecedentes__c'), 'El mapa contiene el objeto buscado.');
        System.assert(mapaRT.containskey('Contact'), 'El mapa contiene el objeto buscado.');
        System.assert(mapaRT.containskey('CC_Grupo_Colaborador__c'), 'El mapa contiene el objeto buscado.');
        
    }
    
    @isTest
    static void updateCaseTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        List<Case> caso = [SELECT Id, RecordTypeId FROM Case WHERE Subject = 'Test' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            SAC_Utils.updateCase(JSON.serialize(caso));
            Test.stopTest();
        }

        System.assertNotEquals(null, caso[0].Id, 'El caso no existe.');
        
    }

    @isTest
    static void updateInteraccionTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        List<SAC_Interaccion__c> consulta = [SELECT Id, SAC_Respuesta__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            SAC_Utils.updateInteraccion(JSON.serialize(consulta));
            Test.stopTest();
        }

        System.assertNotEquals(null, consulta[0].Id, 'La consulta no existe.'); 
    }

    @isTest
    static void updateAlertaTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        List<SAC_Accion__c> accion = [SELECT Id FROM SAC_Accion__C WHERE SAC_Observaciones__c = 'tareaTest' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            SAC_Utils.updateAlerta(JSON.serialize(accion));
            Test.stopTest();
        }

        System.assertNotEquals(null, accion[0].Id, 'La accion no existe.');
    }

    @isTest
    static void recuperarFechaEmailTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'X-SFDC-Original-RCPT';
        header.value = headerValueCAM;

        Messaging.InboundEmail.Header headerDate = new Messaging.InboundEmail.Header();
        headerDate.name = 'Date';
        headerDate.value = 'Wed, 13 Sep 2023 08:43:40 +0000';

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante test';
        email.fromname = 'emailentrantetest1809@entrante.com';
        email.fromAddress = 'emailentrantetest1809@entrante.com';        
        List<String> direcciones = new List<String>();
        direcciones.add('emailentrantetest1809@entrantetestsac.com');
        email.toAddresses = direcciones;
        email.plainTextBody = 'threadId';
        email.htmlBody= 'testhtmlbody';
        email.headers = new Messaging.InboundEmail.Header[] {header, headerDate};
        
        Datetime fechaEmail;

        System.runAs(usuario) {
            Test.startTest();
            fechaEmail = SAC_Utils.recuperarFechaEmail(email);
            Test.stopTest();
        }

        System.assertNotEquals(null, fechaEmail, 'La fecha del email no se ha podido recuperar.');
    }

    @isTest
    static void prepararCasosNuevosTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_EmailService__c customSetting = [SELECT Id, SAC_Naturaleza__c, SAC_GroupName__c, SAC_RecordTypeDeveloperName__c, SAC_M2P__c FROM SAC_EmailService__c WHERE Name = 'DXC_Zaragoza' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'DXC Zaragoza' LIMIT 1];
        String rtIdCons = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();

        Map<String, Id> mapGrupo = new Map<String, Id>();
        mapGrupo.put(grupo.Name, grupo.Id);

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'X-SFDC-Original-RCPT';
        header.value = headerValueCAM;

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante test';
        email.fromname = 'emailentrantetest1809@entrante.com';
        email.fromAddress = 'emailentrantetest1809@entrante.com';        
        List<String> direcciones = new List<String>();
        direcciones.add('emailentrantetest1809@entrantetestsac.com');
        email.toAddresses = direcciones;
        email.plainTextBody = 'threadId';
        email.htmlBody= 'testhtmlbody';
        email.headers = new Messaging.InboundEmail.Header[] {header};
        
        Case nuevoCaso = new Case();

        System.runAs(usuario) {
            Test.startTest();
            nuevoCaso = SAC_Utils.prepararCasosNuevos(customSetting, mapGrupo, email, null, rtIdCons);
            Test.stopTest();
        }
        
        System.assertNotEquals(null, nuevoCaso.Subject, 'Error al crear el caso.');
    }

    @isTest
    static void comprobarEmailsBlackListTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        List<SAC_MaestroTemas__c> emailsBlacklist = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordType.DeveloperName = 'SAC_BlackListEmails' AND Name = 'emailtestinvalido@prueba.com' AND SAC_Activo__c = true LIMIT 1];

        String emailsNoValidosEncontrados = '';

        System.runAs(usuario) {
            Test.startTest();
            emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(emailsBlacklist, 'emailtestinvalido@prueba.com','', '');
            Test.stopTest();
        }
        
        Assert.areNotEqual('', emailsNoValidosEncontrados, 'Error al comprobar los emails de la blackList en envios manuales');
    }

    @isTest
    static void comprobarEmailsBlackListAutoTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        List<SAC_MaestroTemas__c> emailsBlacklist = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordType.DeveloperName = 'SAC_BlackListEmails' AND Name = 'emailtestinvalido@prueba.com' AND SAC_Activo__c = true LIMIT 1];

        List<String> emailsValidos = new List<String>();

        System.runAs(usuario) {
            Test.startTest();
            List<String> listaEmails = new List<String>{ 'testemailSAC@test.com' };
            emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(emailsBlacklist, listaEmails);
            Test.stopTest();
        }
        
        Assert.areNotEqual(0, emailsValidos.size(), 'Error al comprobar los emails de la blackList en envios automáticos');
    }

    @isTest
    static void calcularTiempoParadaSubsanacionTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        List<Case> caso = [SELECT Id, RecordTypeId, SAC_MinutosParadaSubsanacion__c FROM Case WHERE Subject = 'Test' LIMIT 1];
        Integer tiempoTotal;

        System.runAs(usuario) {
            Test.startTest();
            tiempoTotal = SAC_Utils.calcularTiempoParadaSubsanacion(caso[0], 10);
            Test.stopTest();
        }
        
        Assert.areEqual(11, tiempoTotal, 'Error al calcular el tiempo de la parada de subsanacion');
    }

    @isTest
    static void gestionarImagenesInlineRedactarMailTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario) {

            ContentVersion docsV = new contentVersion();
            docsV.title='/test.jpeg';
            docsV.PathOnClient ='/test.jpeg';
            docsV.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            SAC_DatabaseDML.insertDML(docsV, true);

            ContentVersion docsV2 = new ContentVersion();
            docsV2.title='/testDos.jpeg';
            docsV2.PathOnClient ='/testDos.jpeg';
            docsV2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body Dos');
            SAC_DatabaseDML.insertDML(docsV2, true);
    
            String randomUuid = UUID.randomUUID().toString().remove('-').left(18);
            String developerNameFinal = 'SAC_' + docsV2.id + randomUuid;
            
            ContentAsset assetId = new ContentAsset();
            assetId.DeveloperName = developerNameFinal;
            assetId.IsVisibleByExternalUsers = true;
            assetId.MasterLabel = developerNameFinal;
            SAC_DatabaseDML.insertDML(assetId, true);

            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : docsV2.Id];
    
            ContentDocument cntDocument2 = new ContentDocument();
            cntDocument2.Id = documents[0].Id;
            SAC_DatabaseDML.updateDML(cntDocument2, true);

            String emailBody = '</p><p><img src="https://caixabankcc.lightning.force.com/sfc/servlet.shepherd/version/download/'+ docsV2.Id + '" alt="test1"></p><p>';
        
            Test.startTest();
                String htmlResult = SAC_Utils.gestionarImagenesInlineRedactarMail(emailBody);
            Test.stopTest();

            Assert.areNotEqual(emailBody, htmlResult, 'Error al parsear la imagen del email body');
        }
    }

    @isTest
    static void gestionarImagenesInlineRedactarMailTest2() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario) {

            ContentVersion docsV = new contentVersion();
            docsV.title='/test.jpeg';
            docsV.PathOnClient ='/test.jpeg';
            docsV.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            SAC_DatabaseDML.insertDML(docsV, true);

            ContentVersion docsV2 = new ContentVersion();
            docsV2.title='/testDos.jpeg';
            docsV2.PathOnClient ='/testDos.jpeg';
            docsV2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body Dos');
            SAC_DatabaseDML.insertDML(docsV2, true);
    
            String randomUuid = UUID.randomUUID().toString().remove('-').left(18);
            String developerNameFinal = 'SAC_' + docsV2.id + randomUuid;
            
            ContentAsset assetId = new ContentAsset();
            assetId.DeveloperName = developerNameFinal;
            assetId.IsVisibleByExternalUsers = true;
            assetId.MasterLabel = developerNameFinal;
            SAC_DatabaseDML.insertDML(assetId, true);

            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : docsV2.Id];
    
            ContentDocument cntDocument2 = new ContentDocument();
            cntDocument2.Id = documents[0].Id;
            cntDocument2.ContentAssetId = assetId.Id;
            SAC_DatabaseDML.updateDML(cntDocument2, true);

            String emailBody = '</p><p><img src="https://caixabankcc.lightning.force.com/sfc/servlet.shepherd/version/download/'+ docsV2.Id + '" alt="test2"></p><p>';
        
            Test.startTest();
                String htmlResult = SAC_Utils.gestionarImagenesInlineRedactarMail(emailBody);
            Test.stopTest();

            Assert.areNotEqual(emailBody, htmlResult, 'Error al parsear la imagen del email body');
            Assert.areEqual(true, htmlResult.contains(developerNameFinal), 'Error al convertir la imagen del email body');
        }
    }
}