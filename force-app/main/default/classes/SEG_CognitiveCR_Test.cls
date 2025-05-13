@isTest
public class SEG_CognitiveCR_Test implements HttpCalloutMock{
    
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

        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        
        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        
        Id accountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id contactId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        SEG_ClasificacionRapida__c classR = new SEG_ClasificacionRapida__c(
            Name = 'No procede',
            SEG_Organizacion__C = 'Banca Corporativa'
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
   
        Group grupoBO = [SELECT Id FROM Group WHERE Name = 'SEG_BO'];
        
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
            SEG_Subestado__c = 'En curso',
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
            OwnerId = grupoBO.Id
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
        
        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c(
            name = 'Test CR',
            SEG_Nombre_CR_Cognitive__c = 'Credit Cards',
            SEG_Canaldeentrada__c = 'Email',
            CBK_Negocio__c = 'Segmentos',
            SEG_Organizacion__C = 'Banca Corporativa'
        );
        insert clasRapida;   

        CBK_IntegrationSetting__c csCognitive = new CBK_IntegrationSetting__c();
        csCognitive.Name = 'SEG_COGNITIVE';
        csCognitive.NamedCredential__c = 'callout:API_SEG_PRO/tech/orqcor/predict';
        insert csCognitive;
        
    }    

    @isTest 
    public static void getCR(){ //Se comprueba el funcionamiento OK normal del WS obteniendo una clasificación rápida.

        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new SEG_MockHttpResponseGenerator(200, 'OK', '{"sr": "03934069", "model_name": "model-salesforce", "category": "Credit Cards", "categories": [{"category": "Tarjetas", "ratio": "0.57436"}, {"category": "Tarjetas-Alta tarjeta/ VIA T", "ratio": "0.26805"}, {"category": "Alfabético", "ratio": "0.06269"}, {"category": "Bastanteos", "ratio": "0.06056"}, {"category": "Tarjetas-Baja tarjeta/VIA T", "ratio": "0.01888"}], "attributes": {"text_regex": [{"name": "cif_regex", "value": "A-28010791"}]}, "text_vector_words": [0.0]}', null));
        
        System.runAs (usuarioTest) {
            Test.startTest();
            SEG_CognitiveCR.getCRCognitive(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id FROM CC_TrazaInt__c LIMIT 1];

        System.AssertNotEquals(null, trazaInsertada, 'No se ha creado traza');
    }

    @isTest 
    public static void getCRConOwner(){ //Se comprueba el funcionamiento OK normal del WS obteniendo una clasificación rápida.
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];
        caso.Subject = 'TEST Caso Owner';
        update caso;

        Test.setMock(HttpCalloutMock.class, new SEG_MockHttpResponseGenerator(200, 'OK', '{"sr": "03934069", "model_name": "model-salesforce", "category": "Credit Cards", "categories": [{"category": "Tarjetas", "ratio": "0.57436"}, {"category": "Tarjetas-Alta tarjeta/ VIA T", "ratio": "0.26805"}, {"category": "Alfabético", "ratio": "0.06269"}, {"category": "Bastanteos", "ratio": "0.06056"}, {"category": "Tarjetas-Baja tarjeta/VIA T", "ratio": "0.01888"}], "attributes": {"text_regex": [{"name": "cif_regex", "value": "A-28010791"}]}, "text_vector_words": [0.0]}', null));
        
        System.runAs (usuarioTest) {
            Test.startTest();
            SEG_CognitiveCR.getCRCognitive(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id FROM CC_TrazaInt__c LIMIT 1];

        System.AssertNotEquals(null, trazaInsertada, 'No se ha creado traza');
    }

    @isTest 
    public static void testCRNoExistente(){ //Se comprueba el funcionamiento KO cuando la clasificación rápida indicada por cógnitive no existe en Salesforce
        List<SEG_ClasificacionRapida__c> lstCR = [SELECT id FROM SEG_ClasificacionRapida__c];
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new SEG_CognitiveCR_Test());
     
        System.runAs (usuarioTest) {
            Test.startTest();
            delete lstCR;
            
            SEG_CognitiveCR.getCRCognitive(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id, CC_TipoError__c FROM CC_TrazaInt__c LIMIT 1];
        System.AssertEquals(trazaInsertada.CC_TipoError__c, 'CR No existente.', 'Error comunicaciones.');
    }   
    
    
    @isTest 
    public static void getCRError(){ //Se comprueba la traza de error cuando se obtiene un código distinto al 200 del WS
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('myStaticResourceName');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, mock); 
     	System.runAs (usuarioTest) {
            Test.startTest();
            SEG_CognitiveCR.getCRCognitive(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id FROM CC_TrazaInt__c LIMIT 1];

        System.AssertNotEquals(null, trazaInsertada, 'No se ha creado traza');
    } 

    @isTest 
    public static void testCRManual(){ //Se comprueba el caso en el que ya se ha indicado una clasificación rápida manualmente antes de consultar a cognitive.
        SEG_ClasificacionRapida__c clasifRapida = [SELECT Id FROM SEG_ClasificacionRapida__c WHERE name = 'Test CR'];
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SEG_MockHttpResponseGenerator(200, 'OK', null, null));
        
     	System.runAs (usuarioTest) {
            Test.startTest();
            caso.SEG_ClasificacionRapida__c = clasifRapida.Id;
        	Update caso;
            
            SEG_CognitiveCR.getCRCognitive(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id, CC_TipoError__c FROM CC_TrazaInt__c LIMIT 1];
        System.AssertEquals(trazaInsertada.CC_TipoError__c, 'Excepcion de asignacion', 'No se ha creado traza de inserción manual');
    } 
    
    @isTest 
    public static void testOwnerManual(){ //Se comprueba el caso en el que ya se ha indicado una clasificación rápida manualmente antes de consultar a cognitive.
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SEG_MockHttpResponseGenerator(200, 'OK', null, null));
        
     	System.runAs (usuarioTest) {
            Test.startTest();
            caso.OwnerID = UserInfo.getUserId();
        	Update caso;
            
            SEG_CognitiveCR.getCRCognitive(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id, CC_TipoError__c FROM CC_TrazaInt__c LIMIT 1];
        System.AssertEquals(trazaInsertada.CC_TipoError__c, 'Excepcion de asignacion', 'No se ha creado traza de inserción manual');
    } 
}