@isTest
public class SEG_Cognitive_FFEE_Test implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {   
        
        String sFakeRespuesta = '{"pkCodSr": "912076545","pkIdSalesforce": "iweqieiwqw", "status": "200"}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res; 
    }
      
    @TestSetup
    public static void crearDatosPrueba()  {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User thisUser = new User(
                alias = 'tsegmen',
                email = 'testSEGBI@acme.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Smith',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = [SELECT Id FROM Profile WHERE Name= 'System administrator'].Id,
                userroleid = [SELECT Id FROM UserRole WHERE Name = 'Segmentos + FFEE'].Id,
                timezonesidkey ='America/Los_Angeles',
                username ='testSEGBI@acme.com'
            );
            insert thisUser;

            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT PermissionSetGroupId, PermissionSetId, PermissionSet.Name
                                                                FROM PermissionSetGroupComponent
                                                                WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]) {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()) {
                insert listPermissionSetAssignment;
            }
        }

        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        
        Id accountId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id contactId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

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
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = caso.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c(
            name = 'Test CR',
            SEG_Nombre_CR_Cognitive__c = 'Credit Cards',
            SEG_Canaldeentrada__c = 'Email',
            CBK_Negocio__c = 'Segmentos',
            SEG_Organizacion__C = 'Banca Corporativa'
        );
        insert clasRapida;   

        CBK_IntegrationSetting__c csCognitive = new CBK_IntegrationSetting__c();
        csCognitive.Name = 'SEG_Cognitive_FFEE';
        csCognitive.NamedCredential__c = 'callout:API_SEG_PRO/tech/orqcor/predict';
        insert csCognitive;
        
    }    

    @isTest 
    public static void getCR(){ //Se comprueba el funcionamiento OK normal del WS obteniendo una clasificación rápida.
	    User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new SEG_MockHttpResponseGenerator(200, 'OK', '', null));
        
        System.runAs(usuarioTest) {
            Test.startTest();
            SEG_Cognitive_FFEE.getCRFFEE(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id FROM CC_TrazaInt__c LIMIT 1];

        System.AssertNotEquals(null, trazaInsertada, 'No se ha creado traza');
    }
    
    @isTest 
    public static void getCRError(){ //Se comprueba la traza de error cuando se obtiene un código distinto al 200 del WS
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('myStaticResourceName');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
     
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, mock); 
        System.runAs(usuarioTest) {
            Test.startTest();
            SEG_Cognitive_FFEE.getCRFFEE(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id FROM CC_TrazaInt__c LIMIT 1];

        System.AssertNotEquals(null, trazaInsertada, 'No se ha creado traza');
    } 

    @isTest 
    public static void testCRManual(){ //Se comprueba el caso en el que ya se ha indicado una clasificación rápida manualmente antes de consultar a cognitive.
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        SEG_ClasificacionRapida__c clasifRapida = [SELECT Id FROM SEG_ClasificacionRapida__c WHERE name = 'Test CR'];
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new SEG_MockHttpResponseGenerator(200, 'OK', null, null));
        
        System.runAs(usuarioTest) {
            Test.startTest();
            caso.SEG_ClasificacionRapida__c = clasifRapida.Id;
        	Update caso;
            
            SEG_Cognitive_FFEE.getCRFFEE(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id, CC_TipoError__c FROM CC_TrazaInt__c LIMIT 1];
        System.AssertEquals(trazaInsertada.CC_TipoError__c, 'Excepcion de asignacion', 'No se ha creado traza de inserción manual');
    } 
    
    @isTest 
    public static void testOwnerManual(){ //Se comprueba el caso en el que ya se ha indicado una clasificación rápida manualmente antes de consultar a cognitive.
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new SEG_MockHttpResponseGenerator(200, 'OK', null, null));
        
        System.runAs(usuarioTest) {
            Test.startTest();
            caso.OwnerID = UserInfo.getUserId();
        	Update caso;
            
            SEG_Cognitive_FFEE.getCRFFEE(caso.id);
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id, CC_TipoError__c FROM CC_TrazaInt__c LIMIT 1];
        System.AssertEquals(trazaInsertada.CC_TipoError__c, 'Excepcion de asignacion', 'No se ha creado traza de inserción manual');
    }
}