@isTest
public class SEG_BPO_WS_Test {
	
    @TestSetup
    public static void crearDatosPrueba(){
        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();

        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
        	Name = 'GrupoSegOp1',
            RecordTypeId = grupoOpSegId       
        );
		insert grupoCol1;
        
        CC_Grupo_Colaborador__c grupoCol2 = new CC_Grupo_Colaborador__c(
        	Name = 'BO*',
            RecordTypeId = grupoAutoSegId       
        );
        insert grupoCol2;
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111171H';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        Case casoSinClas = new Case(
            AccountId = cuentaSEG1.id,
            SEG_Numero_de_centro__c = cuentaSEG1.id,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId(),
            SEG_Grupo__c = grupoCol1.id,
            SEG_Grupo_Anterior__c = grupoCol2.id, 
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            Status = 'Activo',
            SEG_Subestado__c = 'En curso',
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa'
        );
        insert casoSinClas;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        EmailMessage emailbpo = new EmailMessage();
        emailbpo.FromName = 'bpoName';
        emailbpo.subject = 'Subject Bpo';
        emailbpo.HtmlBody = 'Buenas tardes bpo test class';
        emailbpo.ParentId = casoSinClas.Id;
        emailbpo.fromAddress = 'tstsmailbpo@mailtest.com';
        emailbpo.RelatedToId = casoSinClas.id;
        emailbpo.incoming = true;
        emailbpo.Headers = '[{"value": "' + headerValueStr + '", "name": "X-SFDC-Original-RCPT"}]';
        insert emailbpo;

        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
			WHERE LatestPublishedVersionId = :cv.Id
        ];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = emailbpo.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com', 
                    emailencodingkey='UTF-8', lastname='Smith', 
                    languagelocalekey='en_US', 
                    localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                    timezonesidkey='America/Los_Angeles', 
                    username='testSEGBI@acme.com');
            insert thisUser;
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
            insert new PermissionSetAssignment(AssigneeId = thisUser.id, PermissionSetId = ps.Id);
        }
    }
    
    @isTest
    public static void enviarCasoTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id,casenumber from Case LIMIT 1];
        List<String> listaFicheros = new List<String>();
        String notascif = '12345678X(AP)';
        Test.startTest();

        //Test.setMock(HttpCalloutMock.class, new SEG_WS_MockBPO());
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_BPO_WS.enviarCaso(caso.Id,'alta',notascif,listaFicheros);
        }
        
        Test.stopTest();

        System.assertNotEquals(caso, null, 'El caso no se ha conservado');
    }
    
    @isTest
    public static void actualizarCasoTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id,casenumber from Case LIMIT 1];
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_BPO_WS.actualizarCaso(caso.Id,'modificación');
        }
        Test.stopTest();
        System.assertNotEquals(caso, null, 'El caso no se ha conservado');
    }
    
    @isTest
    public static void altaomodificacionClienteTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id,casenumber from Case LIMIT 1];
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_BPO_WS.altaomodificacionCliente(caso.Id,'alta');
        }
        Test.stopTest();
        System.assertNotEquals(caso, null, 'El caso no se ha conservado');
    }
}