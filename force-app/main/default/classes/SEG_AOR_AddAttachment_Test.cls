@isTest
public class SEG_AOR_AddAttachment_Test implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {   
        
        String sFakeRespuesta = '{"sr": "2-912076545","model_name": "model-001","category": "Credit Cards","categories": [{"category": "Credit Cards", "ratio": "0.52114"},{"category": "Credit Cards", "ratio": "0.22389"},{"category": "Credit Cards", "ratio": "0.20729"},{"category": "Credit Cards", "ratio": "0.02778"},{"category": "Credit Cards", "ratio": "0.01109"},{"category": "Credit Cards", "ratio": "0.00698"},{"category": "Credit Cards", "ratio": "0.00155"},{"category": "Robot no encontrado", "ratio": "0.00027"}]}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }
     @testSetup
    static void testSetup() {
            Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
            cuentaSEG1.Name = 'Empresa segmentos';
            cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
            cuentaSEG1.CC_Numero_Documento__c = '11111171H';
            insert cuentaSEG1;
    
            String jsonResults = 'Pruebadebody';
        System.JSONParser parserSR = System.JSON.createParser(String.valueOf(jsonResults));

            User thisUser;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
            insert thisUser;

            Case caso = new Case();
            caso.OwnerId = thisUser.Id;
            caso.SEG_Numero_centro__c = cuentaSEG1.id;
            caso.Subject = 'Test Case';
            caso.AccountId = cuentaSEG1.id;
            caso.SEG_Numero_de_centro__c = cuentaSEG1.id;
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario web';
            caso.Status = 'Activo';
            caso.SEG_Subestado__c = 'En curso';
            caso.SEG_Zona__c = 'Corporativa';
            caso.SEG_Organizacion__C = 'Banca Corporativa';
            caso.SEG_Identificador_AOR__c = parserSR.getText();
            insert caso;

            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }

            // Activa la traza de la interfaz para pruebas
            CC_InterfaceSettings__mdt config = new CC_InterfaceSettings__mdt(
                DeveloperName = 'SEG_AOR_Attachment',
                CC_TrazaActiva__c = true
            );
            
            CBK_IntegrationSetting__c csAOR = new CBK_IntegrationSetting__c();
            csAOR.Name = 'SEG_AOR_Attachment';
            csAOR.NamedCredential__c = 'callout:SEG_AOR/api/sicb/sfaor/addattachment/';
            insert csAOR;
        

    }

    
    @isTest
    static void testSEG_AOR_AddAttachmentSend() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case'];
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;
		
        ContentVersion archivo = new ContentVersion();
        archivo.ContentLocation = 'S';
        archivo.PathOnClient = 'test.txt';
        archivo.Title = 'Test File';
        archivo.VersionData = Blob.valueOf('Test Content');
        insert archivo;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
			WHERE LatestPublishedVersionId = :archivo.Id
        ];
        
        EmailMessage emailbpo = new EmailMessage();
        emailbpo.FromName = 'bpoName';
        emailbpo.subject = 'Subject Bpo';
        emailbpo.HtmlBody = 'Buenas tardes bpo test class';
        emailbpo.ParentId = caso.Id;
        emailbpo.fromAddress = 'tstsmailbpo@mailtest.com';
        emailbpo.RelatedToId = caso.id;
        emailbpo.incoming = true;
        emailbpo.Headers = '[{"value": "' + headerValueStr + '", "name": "X-SFDC-Original-RCPT"}]';
        insert emailbpo;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = emailbpo.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new SEG_AOR_Altapeticion_Test());
        
        System.runAs (usuarioTest) {
            Test.startTest();
            SEG_AOR_AddAttachment.SEG_AOR_AddAttachmentSend(caso.Id, cdl.ContentDocumentId);
            Test.stopTest();
            
            System.assertEquals(1, [SELECT count() FROM CC_TrazaInt__c]);
        }
    }
    
    @isTest
    static void testSEG_AOR_AddAttachmentSendKO() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case'];
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('myStaticResourceName');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
     
        Test.setMock(HttpCalloutMock.class, mock);   
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;
		
        ContentVersion archivo = new ContentVersion();
        archivo.ContentLocation = 'S';
        archivo.PathOnClient = 'test.txt';
        archivo.Title = 'Test File';
        archivo.VersionData = Blob.valueOf('Test Content');
        insert archivo;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
			WHERE LatestPublishedVersionId = :archivo.Id
        ];
        
        EmailMessage emailbpo = new EmailMessage();
        emailbpo.FromName = 'bpoName';
        emailbpo.subject = 'Subject Bpo';
        emailbpo.HtmlBody = 'Buenas tardes bpo test class';
        emailbpo.ParentId = caso.Id;
        emailbpo.fromAddress = 'tstsmailbpo@mailtest.com';
        emailbpo.RelatedToId = caso.id;
        emailbpo.incoming = true;
        emailbpo.Headers = '[{"value": "' + headerValueStr + '", "name": "X-SFDC-Original-RCPT"}]';
        insert emailbpo;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = emailbpo.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        System.runAs (usuarioTest) {
            Test.startTest();
            SEG_AOR_AddAttachment.SEG_AOR_AddAttachmentSend(caso.Id, cdl.ContentDocumentId);
            Test.stopTest();
            
            System.assertEquals(1, [SELECT count() FROM CC_TrazaInt__c]);
        }
    }
}