@isTest
public with sharing class SEG_feedbackCognitive_Test implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {   
        
        String sFakeRespuesta = '{"sr": "2-912076545","model_name": "model-001","category": "Credit Cards","categories": [{"category": "Credit Cards", "ratio": "0.52114"},{"category": "Credit Cards", "ratio": "0.22389"},{"category": "Credit Cards", "ratio": "0.20729"},{"category": "Credit Cards", "ratio": "0.02778"},{"category": "Credit Cards", "ratio": "0.01109"},{"category": "Credit Cards", "ratio": "0.00698"},{"category": "Credit Cards", "ratio": "0.00155"},{"category": "Robot no encontrado", "ratio": "0.00027"}]}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }
      
    @TestSetup
    public static void crearDatosPrueba()  {
        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        
        Id accountId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id contactId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        SEG_ClasificacionRapida__c classR = new SEG_ClasificacionRapida__c(
            Name = 'No procede'
        );
        insert classR;
        
        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Segmentos',
            CC_Codigo_Externo__c = 'TE-031200001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Segmentos',
            CC_Codigo_Externo__c = 'PR-003250001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Segmentos',
            CC_Codigo_Externo__c = 'MO-000032101'
        );
        insert motivo;
        
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
        	Name = 'GrupoSegOp1',
            RecordTypeId = grupoOpSegId       
        );
		insert grupoCol1;
        
        CC_Grupo_Colaborador__c grupoCol2 = new CC_Grupo_Colaborador__c(
        	Name = 'BO*',
            RecordTypeId = grupoAutoSegId       
        );
        insert grupoCol2;

        Account acc = new Account(
        	Name = 'account',
            RecordTypeId = accountId
        );
        insert acc;
        
        Contact contacto = new Contact(
        	AccountId = acc.id,
            LastName = 'Fuentes',
            RecordTypeId = contactId
        );
        insert contacto;
        
        Account account = new Account(
        	Name = 'acc',
            CC_Numero_Oficina__c = '001',
			SEG_CentroSegmento__c = acc.id,
            SEG_GestorOperativaNacional__c = contacto.id,
			SEG_GestorOperativaInternacional__c = contacto.id,
			SEG_GestorFinEstructurada__c = contacto.id
        );
        insert account;
   
        Case caso = new Case(
            AccountId = account.id,
            Subject = 'case1',
            Description = 'Esto es un caso de prueba para Test',
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            SEG_Numero_de_centro__c = account.id,
            RecordTypeId = rt,
            SEG_Grupo__c = grupoCol1.id,
            SEG_Grupo_Anterior__c = grupoCol2.id, 
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            Status = 'Activo',
            SEG_Subestado__c = 'En curso'
        );
        insert caso; 
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            FirstPublishLocationId = caso.Id
        );
        insert contentVersion;   
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];

        CBK_IntegrationSetting__c csFeedbackCognitive = new CBK_IntegrationSetting__c();
        csFeedbackCognitive.Name = 'SEG_fbCognitive';
        csFeedbackCognitive.NamedCredential__c = 'callout:API_SEG_PRO/operationalServices/cognitive/mails/categories';
        insert csFeedbackCognitive;
    }
    
    

    @isTest 
    public static void SEG_feedbackCognitive_test(){ //Se comprueba el funcionamiento OK normal del WS obteniendo una clasificación rápida.
    Test.setMock(HttpCalloutMock.class, new SEG_feedbackCognitive_Test());

        String caseNumber = '2-912076545';
        String crName = 'Categoría real 1';

        SEG_feedbackCognitive testClass = new SEG_feedbackCognitive(caseNumber, crName);

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            System.enqueueJob(testClass);
            Test.stopTest();
            
            List<CC_TrazaInt__c> trazas = [SELECT Id FROM CC_TrazaInt__c];
            System.assertEquals(1, trazas.size());
        }
    }

    @isTest 
    public static void SEG_feedbackCognitive_KO_test(){ //Se comprueba el funcionamiento KO es erroneo y pasa por la 400.
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('myStaticResourceName');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json'); 
        
        String caseNumber = '2-912076545';
        String crName = 'Categoría real 1';

        SEG_feedbackCognitive testClass = new SEG_feedbackCognitive(caseNumber, crName);
        
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            System.enqueueJob(testClass);
            Test.stopTest();
            
            List<CC_TrazaInt__c> trazas = [SELECT Id FROM CC_TrazaInt__c];
            System.assertEquals(1, trazas.size());
        }
    }
}