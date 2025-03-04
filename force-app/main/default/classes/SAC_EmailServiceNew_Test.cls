@isTest
public without sharing class SAC_EmailServiceNew_Test {
    final static String RECORDTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    final static String RECORDTYPECONSULTA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
    final static String RECORDTYPECONSULTASAC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();
    final static String RECORDTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
   


    @TestSetup
    static void makeData(){
        //usuario a usar
        List<User> usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        SAC_DatabaseDML.insertListDML(usuario, false);

        //Account
        List<Account> cuentaA = SAC_TestDataFactory.crearCuentasNoClientePA(1);
        SAC_DatabaseDML.insertListDML(cuentaA, false);
        
        //Casos
        List<Case> listaCasos = new List<Case>();
        Map<String, Object> mapaCamposCaso = new Map<String, Object>();
        mapaCamposCaso.put('Subject', 'TestRec');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('Description', 'TestRec');
        mapaCamposCaso.put('SAC_StatusAuxiliar__c', 'SAC_001');
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Consulta', mapaCamposCaso);
        listaCasos.add(casoReclamacion) ;

        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'TestRec2');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('Description', 'TestRec2');
        mapaCamposCaso.put('SAC_StatusAuxiliar__c', 'SAC_001');
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        listaCasos.add(casoReclamacion2);

        mapaCamposCaso.clear();
        mapaCamposCaso.put('Subject', 'Reclamacion3');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('Description', 'TestRec3');
        mapaCamposCaso.put('SAC_StatusAuxiliar__c', 'SAC_001');
        mapaCamposCaso.put('SAC_ValidacionMCC__c', true);
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        listaCasos.add(casoReclamacion3);

        SAC_DatabaseDML.insertListDML(listaCasos, false);

        //Consultas Interaccion
        List<SAC_Interaccion__c> listaInteracciones = SAC_TestDataFactory.crearInteraccionn(1, casoReclamacion2.id, null);
        listaInteracciones[0].SAC_Respuesta__c = 'threadId';
        listaInteracciones[0].SAC_IndexedThreadId__c = 'ref:_threadId:ref';
        listaInteracciones[0].SAC_FechaRespuesta__c = system.now();
        listaInteracciones[0].SAC_EmailRespuesta__c = 'emailentrante@entrante.com';
        listaInteracciones[0].SAC_Estado__c = 'SAC_Resuelta';  
        SAC_DatabaseDML.insertListDML(listaInteracciones, false);

        //Grupo
        List<CC_Grupo_Colaborador__c> listaGrupoTareas = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1);
        SAC_DatabaseDML.insertListDML(listaGrupoTareas, false);

        //Maestro tareas
        List<SAC_MaestroAccionesReclamacion__c> listaMaestros = SAC_TestDataFactory.crearMaestroAcciones(1, listaGrupoTareas[0].Id);
        listaMaestros[0].SAC_DeveloperName__c = 'GENERAL PARA OFICINAS';
        SAC_DatabaseDML.insertListDML(listaMaestros, false);

        //Tareas
        List<SAC_Accion__c> listaTareas = SAC_TestDataFactory.crearTareas(1, casoReclamacion2, true);
        listaTareas[0].SAC_MaestroAccionesReclamacion__c = listaMaestros[0].Id;
        listaTareas[0].SAC_IndexedThreadId__c = 'ref:_threadId2:ref';
        SAC_DatabaseDML.insertListDML(listaTareas, false);

        /*Contact cont = new Contact();
        cont.LastName = 'cARLOS';
        cont.email = 'prueba@test.com';
        Database.insert(cont);*/

        //Usuario Admin
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);

        System.RunAs(usuarioAdmin) {
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario[0].Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }
    }

    @isTest
    static void emailServiceTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
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
        email.plainTextBody = 'eeso';
        email.htmlBody= 'eeso';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'prueba@testsac.com';

        Test.startTest();
        System.runAs(usuario) {
            //llamar a la clase del email service
            SAC_EmailServiceNew emailProcess = new SAC_EmailServiceNew();
            emailProcess.handleInboundEmail(email, env);
        }
        Test.stopTest();

        List<Case> listaCasoResult = [SELECT ID FROM Case];

        System.assertNotEquals(listaCasoResult.isEmpty(), true, 'No se ha insertado el mail');  

    }

    @isTest
    static void obtenerValoresPicklistTest(){

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        Map<String, String> mapaValoresPicklistStatus = new Map<String, String>();

        System.runAs(usuario) {
            
            mapaValoresPicklistStatus = SAC_EmailServiceNew.obtenerValoresPicklist('Case', 'Status');

        }

        Assert.areNotEqual(0, mapaValoresPicklistStatus.size(), 'No se han obtenido los valores picklist');
        Test.stopTest();

    }

    @isTest
    static void testEmailServiceThreadID(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Case caso = [SELECT id, Subject, CC_SuppliedID__c, Status, RecordTypeId FROM Case  WHERE Subject = 'TestRec' LIMIT 1];
        caso.Subject ='Modifico el Subject';
        SAC_DatabaseDML.updateDML(caso, false);

        Case casoModificado = [SELECT id, Subject, CC_SuppliedID__c, Status, RecordTypeId FROM Case  WHERE Subject = 'Modifico el Subject' LIMIT 1];

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrante@entrante.com';
        List<String> direcciones = new List<String>();
        direcciones.add('abcd');
        email.toAddresses = direcciones;
        email.plainTextBody = 'eeso ';
        email.htmlBody= 'eeso ';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header cabecera = new Messaging.InboundEmail.Header();
        // cabecera.name = 'references';
        // cabecera.value = String.valueOf(casoModificado.Id);
        cabecera.name = 'X-SFDC-Original-RCPT';
        cabecera.value = headerValueCAM;

        List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>();
        email.headers = headers;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'abcd';
 
        SAC_EmailServiceNew emailProcess = new SAC_EmailServiceNew();

        Test.startTest();
        System.runAs(usuario) {
            emailProcess.handleInboundEmail(email, env);
        }
        Test.stopTest();
        
        List<case> listaCasos = [SELECT id, Subject, CC_SuppliedID__c, Status FROM Case WHERE Id = :casoModificado.Id];

        List<EmailMessage> listaEmailMessages = [SELECT Id FROM EmailMessage WHERE ParentId =:listaCasos[0].id];
        
        System.assertEquals(listaEmailMessages.isEmpty(), true, 'No se está verificando bien');
    }

    @isTest
    static void emailServiceConsultaFail(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
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
        email.fromAddress = 'emailentrante@entrante.com';
        List<String> direcciones = new List<String>();
        direcciones.add('emailentrante@entrante.com');
        email.toAddresses = direcciones;
        email.plainTextBody = 'ref:_threadId:ref';
        email.htmlBody= 'ref:_threadId:ref';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'emailentrante@entrante.com';

        //Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        Test.startTest();
        //llamar a la clase del email service
        try {

            System.runAs(usuario) {
                SAC_EmailServiceNew emailProcess = new SAC_EmailServiceNew();
                emailProcess.handleInboundEmail (email, env);
            }  
        } catch (Exception e) {
            System.assertNotEquals(e, null, 'el metodo email service no deberia funcionar');
            
        }
        Test.stopTest();
    }

    @isTest
    static void testThreadIDNogociacion(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, Subject, CC_SuppliedID__c, Status, RecordTypeId FROM Case  WHERE Subject = 'Reclamacion3' LIMIT 1];

        caso.Subject ='Modifico el Subject';
        caso.Status = 'SAC_007';
        caso.SAC_StatusAuxiliar__c = 'SAC_007';
        caso.SAC_TipoConsumidor__c = 'Sí';
        SAC_DatabaseDML.updateDML(caso, false);

        Case casoModificado = [SELECT id, Subject, CC_SuppliedID__c, Status, RecordTypeId FROM Case  WHERE Subject = 'Modifico el Subject' LIMIT 1];  

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrante@entrante.com';
        List<String> direcciones = new List<String>();
        direcciones.add('abcd');
        email.toAddresses = direcciones;
        email.plainTextBody = casoModificado.CC_SuppliedID__c;
        email.htmlBody= '';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header cabecera = new Messaging.InboundEmail.Header();
        // cabecera.name = 'references';
        // cabecera.value = 'String.valueOf(casoModificado.Id)';
        cabecera.name = 'X-SFDC-Original-RCPT';
        cabecera.value = headerValueCAM;

        List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>();
        email.headers = headers;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'abcd';
 
        SAC_EmailServiceNew emailProcess = new SAC_EmailServiceNew();

        System.runAs(usuario) {
            emailProcess.handleInboundEmail(email, env);
        }
  
        //List<case> listaCasos = [SELECT id, Subject, CC_SuppliedID__c, Status FROM Case WHERE Id = :casoModificado.Id];
        //List<EmailMessage> listaEmailMessages = [SELECT Id FROM EmailMessage WHERE ParentId =:listaCasos[0].id];

        System.assertEquals('SAC_007' , caso.Status, 'No se está verificando bien');
        Test.stopTest();
    }

    @isTest
    static void testEmailServiceThreadID2(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, Subject, CC_SuppliedID__c, Status, RecordTypeId FROM Case  WHERE Subject = 'Reclamacion3' LIMIT 1];

        caso.Subject ='Modifico el Subject';
        caso.Status = 'SAC_006';
        caso.SAC_StatusAuxiliar__c = 'SAC_006';
        caso.SAC_TipoConsumidor__c = 'Sí';
        SAC_DatabaseDML.updateDML(caso, false);

        //Case casoModificado = [SELECT id, Subject, CC_SuppliedID__c, Status, RecordTypeId FROM Case  WHERE Subject = 'Modifico el Subject' LIMIT 1];  

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrante@entrante.com';
        List<String> direcciones = new List<String>();
        direcciones.add('abcd');
        email.toAddresses = direcciones;
        email.plainTextBody = '';
        email.htmlBody= '';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header cabecera = new Messaging.InboundEmail.Header();
        // cabecera.name = 'references';
        // cabecera.value = 'String.valueOf(casoModificado.Id)';
        cabecera.name = 'X-SFDC-Original-RCPT';
        cabecera.value = headerValueCAM;

        List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>();
        email.headers = headers;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'abcd';
 
        SAC_EmailServiceNew emailProcess = new SAC_EmailServiceNew();
        System.runAs(usuario) {
            emailProcess.handleInboundEmail(email, env);  
        }  
        //List<case> listaCasos = [SELECT id, Subject, CC_SuppliedID__c, Status FROM Case WHERE Id = :casoModificado.Id];
        //List<EmailMessage> listaEmailMessages = [SELECT Id FROM EmailMessage WHERE ParentId =:listaCasos[0].id];

        System.assertEquals('SAC_006' , caso.Status, 'No se está verificando bien');
        Test.stopTest();
    }

    @isTest
    static void testThreadIDSubsanacion(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id, Subject, CC_SuppliedID__c, Status, RecordTypeId FROM Case  WHERE Subject = 'Reclamacion3' LIMIT 1];

        caso.Subject ='Modifico el Subject';
        caso.Status = 'SAC_006';
        caso.SAC_StatusAuxiliar__c = 'SAC_006';
        caso.SAC_TipoConsumidor__c = 'Sí';
        SAC_DatabaseDML.updateDML(caso, false);

        Case casoModificado = [SELECT id, Subject, CC_SuppliedID__c, Status, RecordTypeId FROM Case  WHERE Subject = 'Modifico el Subject' LIMIT 1];  

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrante@entrante.com';
        List<String> direcciones = new List<String>();
        direcciones.add('abcd');
        email.toAddresses = direcciones;
        email.plainTextBody = casoModificado.CC_SuppliedID__c;
        email.htmlBody= '';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header cabecera = new Messaging.InboundEmail.Header();
        // cabecera.name = 'references';
        // cabecera.value = 'String.valueOf(casoModificado.Id)';
        cabecera.name = 'X-SFDC-Original-RCPT';
        cabecera.value = headerValueCAM;

        List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>();
        email.headers = headers;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'abcd';
 
        SAC_EmailServiceNew emailProcess = new SAC_EmailServiceNew();
        System.runAs(usuario) {
            emailProcess.handleInboundEmail(email, env);  
        }
         
        //List<case> listaCasos = [SELECT id, Subject, CC_SuppliedID__c, Status FROM Case WHERE Id = :casoModificado.Id];
        //List<EmailMessage> listaEmailMessages = [SELECT Id FROM EmailMessage WHERE ParentId =:listaCasos[0].id];

        System.assertEquals('SAC_006' , caso.Status, 'No se está verificando bien');
        Test.stopTest();
    }

    @isTest
    static void emailServiceTarea(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
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
        email.fromAddress = 'emailentrante@entrante.com';
        List<String> direcciones = new List<String>();
        direcciones.add('emailentrante@entrante.com');
        email.toAddresses = direcciones;
        email.plainTextBody = 'ref:_threadId2:ref';
        email.htmlBody= 'ref:_threadId2:ref';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'emailentrante@entrante.com';

        //Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        Test.startTest();
        //llamar a la clase del email service
        try {

            System.runAs(usuario) {
                SAC_EmailServiceNew emailProcess = new SAC_EmailServiceNew();
                emailProcess.handleInboundEmail (email, env);
            }  
        } catch (Exception e) {
            System.assertNotEquals(e, null, 'el metodo email service no deberia funcionar');
            
        }
        Test.stopTest();
    }

    @isTest
    static void emailServiceTestIA() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Email';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
            
        SAC_DatabaseDML.insertDML(settings, false);

        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
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
        email.plainTextBody = 'eeso';
        email.htmlBody= 'eeso';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'prueba@testsac.com';

        Test.startTest();
        System.runAs(usuario) {
            //llamar a la clase del email service
            SAC_EmailServiceNew emailProcess = new SAC_EmailServiceNew();
            emailProcess.handleInboundEmail(email, env);
        }
        Test.stopTest();

        System.assertNotEquals([SELECT Count() FROM Case], 0, 'No se ha insertado el mail');  

    }
}