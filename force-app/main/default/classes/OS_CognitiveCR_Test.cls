@isTest
Global class OS_CognitiveCR_Test implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) 
    {   
        String sFakeRespuesta = '';

        sFakeRespuesta = '{cat=0.777, eng=0.591, esp=1.000, language=esp}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }

    @TestSetup
    static void makeData(){
        User usuarioAdmin = OS_Usuarios.usuarioAdmin();

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        
        Id grupoColOsId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        
        Id accountId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id contactId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        SEG_ClasificacionRapida__c classR = new SEG_ClasificacionRapida__c(
            Name = 'No procede'
        );
        insert classR;

        List<BusinessHours> horario = [SELECT Id FROM BusinessHours WHERE Name = 'cops' LIMIT 1];
        
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.Name = 'tematica cops test';
        tematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        tematica.CC_Fecha_Vigencia_Inicio__c = System.now();
        tematica.OS_Horario__C = horario[0].Id;
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Codigo_Externo__c = 'TEC-000001';
        tematica.OS_Departamento__c = 'UAC';
        insert tematica;
        
        CC_MCC__c producto = new CC_MCC__c();
        producto.Name = 'producto cops test';
        producto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        producto.CC_Fecha_Vigencia_Inicio__c = System.now();
        producto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert producto;
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'motivo cops test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = System.now();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = tematica.Id;
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;
        
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
            Name = 'GrupoSegOp1',
            RecordTypeId = grupoColOsId       
        );
        insert grupoCol1;
        
        Account acc = new Account(
            Name = 'account',
            RecordTypeId = accountId
        );
        insert acc;
        
        Contact contacto2 = new Contact(
            AccountId = acc.id,
            LastName = 'Fuentes',
            RecordTypeId = contactId
        );
        insert contacto2;
        
        Account account = new Account(
            Name = 'acc',
            CC_Numero_Oficina__c = '001'
        );
        insert account;
        
        Case caso = new Case(
            AccountId = account.id,
            Subject = 'Caso test',
            Description = 'Esto es un caso de prueba para Test', 
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            RecordTypeId = rt,
            OS_ViaClasificacion__C = 'Ninguno',
            CC_Grupo_Colaborador__c = grupoCol1.id,
            Origin = 'Email',
            CC_Tipo_Contacto__c = 'Asesoramiento',
            CC_Canal_Procedencia__c = 'Buzón Comercio Exterior',
            Status = 'Activo',
            OwnerId = usuarioAdmin.Id
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
        
        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c(
            name = 'Test CR',
            SEG_Nombre_CR_Cognitive__c = 'UAFE Confirming',
            SEG_Canaldeentrada__c = 'Email',
            OS_EstadoCaso__c = 'Activo',
            CBK_Negocio__c = 'Cops',
            SEG_Tematica__c = tematica.id,
            SEG_Producto__c = producto.id,
            SEG_Motivo__c = motivo.id
        );
        insert clasRapida;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];

        CBK_IntegrationSetting__c csCognitive = new CBK_IntegrationSetting__c();
        csCognitive.Name = 'OS_COGNITIVE';
        csCognitive.NamedCredential__c = 'callout:API_OS_PRE/operationalServices/cognitive/mails/categories/predict';
        insert csCognitive;
    }

    @isTest public static void getCROK(){
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new CSBD_MockCallout_Test('COGNITIVO','OK'));                
        Case caso = [Select id from Case where Subject = 'Caso test'];
        
        System.runAs (usuarioAdmin) {
            Test.startTest();
            OS_CognitiveCR.getCRCognitive(caso.Id);
            Test.stopTest();
    
            Case casoUpdate = [Select id, OS_ViaClasificacion__c from Case where Subject = 'Caso test'];
            
            system.assertEquals('Cognitivo', casoUpdate.OS_ViaClasificacion__c, 'Comprobamos la clasificación es de cognitivo');
        }
    }

    @isTest public static void getCRFEEDBACKOK(){
        Map<String, String> mapCaseName = new Map<String, String>();
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new CSBD_MockCallout_Test('COGNITIVO','OK'));                
        Case caso = [Select id, CaseNumber from Case where Subject = 'Caso test'];
        mapCaseName.put(caso.CaseNumber, '');
        
        System.runAs (usuarioAdmin) {
            Test.startTest();
            Id jobId = System.enqueueJob(new OS_feedbackCognitive(mapCaseName));
            Test.stopTest();
            
            system.assert(jobId != null, 'Comprobamos que existe un id de trabajo para cognitivo');
        }
    } 
    
    @isTest public static void getCRFEEDBACKKO(){
        Map<String, String> mapCaseName = new Map<String, String>();
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new CSBD_MockCallout_Test('FEEDBACK','KO'));                
        Case caso = [Select id, CaseNumber from Case where Subject = 'Caso test'];
        mapCaseName.put(caso.CaseNumber, '');
        
        System.runAs (usuarioAdmin) {
            Test.startTest();
            Id jobId = System.enqueueJob(new OS_feedbackCognitive(mapCaseName));
            Test.stopTest();
            
            system.assert(jobId != null, 'Comprobamos que existe un id de trabajo para cognitivo');
        }
    } 
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"idiomaDetectado": "es"}');
            return response;
        }
    }

    @isTest public static void getCRKO(){
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new CSBD_MockCallout_Test('COGNITIVO','KO'));                
        Case caso = [Select id from Case where Subject = 'Caso test'];
        
        System.runAs (usuarioAdmin) {
            Test.startTest();
            OS_CognitiveCR.getCRCognitive(caso.Id);
            Test.stopTest();
            
            CC_TrazaInt__c traza = [Select CC_FinOK__c from CC_TrazaInt__c limit 1];
            
            system.assert(!traza.CC_FinOK__c, 'Comprobamos el KO');
        }
    }    
}