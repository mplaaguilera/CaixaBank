@isTest
public with sharing class SPV_EmailService_Test {
    @TestSetup
    static void makeData(){
        //usuario a usar
        User usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
        Database.insert(usuario);
        User usuarioAd = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAd);

        Case casoReclamacion2 = new Case();
        Case casoReclamacion3 = new Case();

        List<SAC_MaestroAccionesReclamacion__c> listaMaestros = new List<SAC_MaestroAccionesReclamacion__c>();

        System.runAs(usuario) {
            //Account
            List<Account> cuentaA = SAC_TestDataFactory.crearCuentasNoClientePA(1);
            Database.insert(cuentaA);
            
            //Casos
            List<Case> listaCasos = new List<Case>();
            Map<String, Object> mapaCamposCaso = new Map<String, Object>();
            mapaCamposCaso.put('Subject', 'TestRec2');
            mapaCamposCaso.put('Origin', 'Backoffice');
            mapaCamposCaso.put('Status', 'SAC_001');
            mapaCamposCaso.put('Description', 'TestRec2');
            mapaCamposCaso.put('SAC_StatusAuxiliar__c', 'SAC_001');
            casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
            listaCasos.add(casoReclamacion2);

            mapaCamposCaso.clear();
            mapaCamposCaso.put('Subject', 'Reclamacion3');
            mapaCamposCaso.put('Origin', 'Backoffice');
            mapaCamposCaso.put('Status', 'SAC_001');
            mapaCamposCaso.put('Description', 'TestRec3');
            mapaCamposCaso.put('SAC_StatusAuxiliar__c', 'SAC_001');
            mapaCamposCaso.put('SAC_ValidacionMCC__c', true);
            casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
            listaCasos.add(casoReclamacion3);

            Database.insert(listaCasos);

            //Consultas Interaccion
            Map<String, Object> mapaCamposInteraccion = new Map<String, Object>();
            mapaCamposInteraccion.put('SAC_Respuesta__c', 'threadId');
            mapaCamposInteraccion.put('SAC_IndexedThreadId__c', 'ref:_threadId:ref');
            mapaCamposInteraccion.put('SAC_FechaRespuesta__c', system.now());
            mapaCamposInteraccion.put('SAC_EmailRespuesta__c', 'emailentrante@entrante.com');
            mapaCamposInteraccion.put('SAC_Estado__c', 'SAC_Resuelta');
            SAC_Interaccion__c consulta = SPV_TestDataFactory.crearInteraccion('Consulta', mapaCamposInteraccion);
            Database.insert(consulta);

            //Grupo
            List<CC_Grupo_Colaborador__c> listaGrupoTareas = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas', 1);
            listaGrupoTareas[0].SAC_PermiteTareas__c = true;
            Database.insert(listaGrupoTareas);

            //Maestro tareas
            listaMaestros = SPV_TestDataFactory.crearMaestroAcciones(1, listaGrupoTareas[0].Id);
            listaMaestros[0].SAC_DeveloperName__c = 'GENERAL PARA OFICINAS';
            listaMaestros[0].SAC_Descripcion__c = 'pruebatest';
            Database.insert(listaMaestros);
        }

        System.runAs(usuarioAd) {
            casoReclamacion2.OwnerId = usuario.Id;
            Database.update(casoReclamacion2);
        }

        system.runAs(usuario) {
            //Tareas
            List<SAC_Accion__c> listaTareas = SPV_TestDataFactory.crearTareas(1, casoReclamacion2, null);
            listaTareas[0].SAC_MaestroAccionesReclamacion__c = listaMaestros[0].Id;
            listaTareas[0].SAC_IndexedThreadId__c = 'ref:_threadId:ref';
            listaTareas[0].RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
            listaTareas[0].SAC_Descripcion__c = 'pruebatest';
            Database.insert(listaTareas);
        }
    }

    @isTest
    static void emailServiceConsultaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true Limit 1];

        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SPV_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'X-SFDC-Original-RCPT';
        header.value = headerValueCAM;

        Messaging.InboundEmail.TextAttachment txtAttachment = new Messaging.InboundEmail.TextAttachment();
        txtAttachment.body = 'my attachment text';
        txtAttachment.fileName = 'textfile2.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrantes@entrante.com';        
        List<String> direcciones = new List<String>();
        direcciones.add('prueba@testsac.com');
        direcciones.add('consulta_cops@entrante.com');
        email.toAddresses = direcciones;
        email.ccAddresses = direcciones;
        email.plainTextBody = 'ref:_threadIdInteraccion:ref';
        email.htmlBody= 'ref:_threadIdInteraccion:ref';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'prueba@testsac.com';

        SAC_Interaccion__c inter = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_EmailRespuesta__c = 'emailentrante@entrante.com'];
        inter.SAC_IndexedThreadId__c = 'ref:_threadIdInteraccion:ref';
        Database.update(inter);

        Test.startTest();
        System.runAs(usuario) {
            //llamar a la clase del email service
            SPV_EmailService emailProcess = new SPV_EmailService();
            emailProcess.handleInboundEmail(email, env);
        }
        Test.stopTest();

        SAC_Interaccion__c inter2 = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_IndexedThreadId__c = 'ref:_threadIdInteraccion:ref'];
        List<EmailMessage> em = [SELECT Id FROM EmailMessage WHERE RelatedToId = :inter2.Id];

        System.assertNotEquals(em.isEmpty(), true, 'No se ha insertado el mail');
    }

    @isTest
    static void emailServiceAccionTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true Limit 1];

        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SPV_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'X-SFDC-Original-RCPT';
        header.value = headerValueCAM;

        Messaging.InboundEmail.TextAttachment txtAttachment = new Messaging.InboundEmail.TextAttachment();
        txtAttachment.body = 'my attachment text';
        txtAttachment.fileName = 'textfile2.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrantes@entrante.com';        
        List<String> direcciones = new List<String>();
        direcciones.add('prueba@testsac.com');
        direcciones.add('consulta_cops@entrante.com');
        email.toAddresses = direcciones;
        email.ccAddresses = direcciones;
        email.plainTextBody = 'ref:_threadIdAccion:ref';
        email.htmlBody= 'ref:_threadIdAccion:ref';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'prueba@testsac.com';

        SAC_Accion__c accion = [SELECT Id FROM SAC_Accion__c WHERE SAC_Descripcion__c = 'pruebatest'];
        accion.SAC_IndexedThreadId__c = 'ref:_threadIdAccion:ref';
        Database.update(accion);

        Test.startTest();
        System.runAs(usuario) {
            //llamar a la clase del email service
            SPV_EmailService emailProcess = new SPV_EmailService();
            emailProcess.handleInboundEmail(email, env);
        }
        Test.stopTest();

        SAC_Accion__c accion2 = [SELECT Id FROM SAC_Accion__c WHERE SAC_IndexedThreadId__c = 'ref:_threadIdAccion:ref'];
        List<EmailMessage> em = [SELECT Id FROM EmailMessage WHERE RelatedToId = :accion2.Id];

        System.assertNotEquals(em.isEmpty(), true, 'No se ha insertado el mail');
    }

    @isTest
    static void emailServiceCaseTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true Limit 1];

        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SPV_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'X-SFDC-Original-RCPT';
        header.value = headerValueCAM;

        Messaging.InboundEmail.TextAttachment txtAttachment = new Messaging.InboundEmail.TextAttachment();
        txtAttachment.body = 'my attachment text';
        txtAttachment.fileName = 'textfile2.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrantes@entrante.com';        
        List<String> direcciones = new List<String>();
        direcciones.add('prueba@testsac.com');
        direcciones.add('consulta_cops@entrante.com');
        email.toAddresses = direcciones;
        email.ccAddresses = direcciones;
        email.plainTextBody = 'ref:_threadIdCase:ref';
        email.htmlBody= 'ref:_threadIdCase:ref';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'prueba@testsac.com';

        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec2'];
        caso.CC_SuppliedID__c = 'ref:_threadIdCase:ref';
        Database.update(caso);

        Test.startTest();
        System.runAs(usuario) {
            //llamar a la clase del email service
            SPV_EmailService emailProcess = new SPV_EmailService();
            emailProcess.handleInboundEmail(email, env);
        }
        Test.stopTest();

        Case caso2 = [SELECT Id FROM Case WHERE CC_SuppliedID__c = 'ref:_threadIdCase:ref'];
        List<EmailMessage> em = [SELECT Id FROM EmailMessage WHERE RelatedToId = :caso2.Id];

        System.assertNotEquals(em.isEmpty(), true, 'No se ha insertado el mail');
    }
}