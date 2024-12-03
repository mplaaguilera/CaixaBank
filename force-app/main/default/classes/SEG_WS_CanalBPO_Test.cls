@isTest
public with sharing class SEG_WS_CanalBPO_Test {
    @testSetup
    static void datosIniciales ()
    { 
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
        	Name = 'GrupoSegOp1',
            SEG_GrupoSegmentos__c = true,
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

        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
		mccTematicaSEG.Name = 'Tematica1SEG';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematicaSEG;
        
        CC_MCC__c mccProductoSEG = new CC_MCC__c();
        mccProductoSEG.Name = 'Producto1SEG';
        mccProductoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG.RecordTypeId = recordTypeIdProducto;
        mccProductoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccProductoSEG.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProductoSEG; 
        
       	CC_MCC__c mccMotivoSEG = new CC_MCC__c();
        mccMotivoSEG.Name = 'Motivo1SEG';
        mccMotivoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccMotivoSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccMotivoSEG.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivoSEG;

       	CC_MCC__c mccDetalleSEG = new CC_MCC__c();
        mccDetalleSEG.Name = 'Detalle1SEG';
        mccDetalleSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccDetalleSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccDetalleSEG.CC_Motivo__c = mccMotivoSEG.Id;
        mccDetalleSEG.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalleSEG;
        
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
            SEG_Organizacion__C = 'Banca Corporativa',
            Subject = 'test 2',
            CC_MCC_Tematica__c = mccTematicaSEG.Id,
            CC_MCC_ProdServ__c = mccProductoSEG.Id,
            CC_MCC_Motivo__c = mccMotivoSEG.Id,
            SEG_Detalle__c = mccDetalleSEG.Id
        );
        insert casoSinClas;

        CC_MCC_Grupo_Colaborador__c grupoDetalle = new CC_MCC_Grupo_Colaborador__c();
		grupoDetalle.Name = 'detalle';
		grupoDetalle.CC_MCC__c = mccDetalleSEG.Id;
		grupoDetalle.SEG_Grupo_respuesta__c = grupoCol1.Id;
		grupoDetalle.SEG_Zona__c = 'Corporativa';
		grupoDetalle.SEG_Organizacion__c = 'Banca Corporativa';
        insert grupoDetalle;

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
    public static void entradaCanalBPO_B03()
    {
        List<Case> listaCasos = [SELECT Id,CaseNumber FROM Case WHERE Subject = 'test 2'];
       
        SEG_WS_CanalBPO.Input datosEntrada = new SEG_WS_CanalBPO.Input();
        datosEntrada.tipoProceso = 'B03';
        datosEntrada.caseId = listaCasos[0].Id;
        datosEntrada.origen = '';
        datosEntrada.caseNumber = listaCasos[0].CaseNumber;
        datosEntrada.fechaEvento = '26-1-2022';
        datosEntrada.textoEmail = 'Test textoemail ws bpo';

        List<SEG_WS_CanalBPO.ContenidoAdicional> listofAdicional= new List<SEG_WS_CanalBPO.ContenidoAdicional>();

        SEG_WS_CanalBPO.ContenidoAdicional contad = new SEG_WS_CanalBPO.ContenidoAdicional();
        contad.key = 'NIF';
        contad.value = '11111171H';
        listofAdicional.add(contad);
        SEG_WS_CanalBPO.ContenidoAdicional contadas= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadas.key = 'ASUNTO';
        contadas.value = 'test';
        listofAdicional.add(contadas);
        SEG_WS_CanalBPO.ContenidoAdicional contadrem= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrem.key = 'REMITENTE';
        contadrem.value = 'testrembpo@mailnovalid.com';
        listofAdicional.add(contadrem);
        SEG_WS_CanalBPO.ContenidoAdicional contadrec= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrec.key = 'RECEPTOR';
        contadrec.value = 'testreceptmbpo@mailnovalid.com';
        listofAdicional.add(contadrec);

        List<SEG_WS_CanalBPO.Documentsid> listofdocs= new List<SEG_WS_CanalBPO.Documentsid>();
        SEG_WS_CanalBPO.Documentsid docs = new SEG_WS_CanalBPO.Documentsid();
        ContentDocument documento = [SELECT Id FROM ContentDocument LIMIT 1];
        docs.key = documento.Id;
        docs.value = 'nombreDummy1.xls';
        listofdocs.add(docs);

        datosEntrada.contenidoAdicional = listofAdicional;
        datosEntrada.documentsid = listofdocs;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/CanalBPO/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();

            SEG_WS_CanalBPO.Output output = SEG_WS_CanalBPO.entradaCanalBPO();
            Test.stopTest();
            System.assertNotEquals(output, null, 'No se ha realizado la petición BPO');
        }
    }
    
    @isTest
    public static void entradaCanalBPO_B04()
    {
        List<Case> listaCasos = [SELECT Id,CaseNumber FROM Case WHERE Subject = 'test 2'];
       
        SEG_WS_CanalBPO.Input datosEntrada = new SEG_WS_CanalBPO.Input();
        datosEntrada.tipoProceso = 'B04';
        datosEntrada.caseId = listaCasos[0].Id;
        datosEntrada.origen = '';
        datosEntrada.caseNumber = listaCasos[0].CaseNumber;
        datosEntrada.fechaEvento = '26-1-2022';
        datosEntrada.textoEmail = 'Test textoemail ws bpo';

        List<SEG_WS_CanalBPO.ContenidoAdicional> listofAdicional= new List<SEG_WS_CanalBPO.ContenidoAdicional>();

        SEG_WS_CanalBPO.ContenidoAdicional contad = new SEG_WS_CanalBPO.ContenidoAdicional();
        contad.key = 'NIF';
        contad.value = '11111171H';
        listofAdicional.add(contad);
        SEG_WS_CanalBPO.ContenidoAdicional contadas= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadas.key = 'ASUNTO';
        contadas.value = 'test';
        listofAdicional.add(contadas);
        SEG_WS_CanalBPO.ContenidoAdicional contadrem= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrem.key = 'REMITENTE';
        contadrem.value = 'testrembpo@mailnovalid.com';
        listofAdicional.add(contadrem);
        SEG_WS_CanalBPO.ContenidoAdicional contadrec= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrec.key = 'RECEPTOR';
        contadrec.value = 'testreceptmbpo@mailnovalid.com';
        listofAdicional.add(contadrec);

        List<SEG_WS_CanalBPO.Documentsid> listofdocs= new List<SEG_WS_CanalBPO.Documentsid>();
        SEG_WS_CanalBPO.Documentsid docs = new SEG_WS_CanalBPO.Documentsid();
        ContentDocument documento = [SELECT Id FROM ContentDocument LIMIT 1];
        docs.key = documento.Id;
        docs.value = 'nombreDummy1.xls';
        listofdocs.add(docs);

        datosEntrada.contenidoAdicional = listofAdicional;
        datosEntrada.documentsid = listofdocs;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/CanalBPO/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();

            SEG_WS_CanalBPO.Output output = SEG_WS_CanalBPO.entradaCanalBPO();
            Test.stopTest();
            System.assertNotEquals(output, null, 'No se ha realizado la petición BPO');
        }
    }
    
    @isTest
    public static void entradaCanalBPO_B05()
    {
        List<Case> listaCasos = [SELECT Id,CaseNumber FROM Case WHERE Subject = 'test 2'];
       
        SEG_WS_CanalBPO.Input datosEntrada = new SEG_WS_CanalBPO.Input();
        datosEntrada.tipoProceso = 'B05';
        datosEntrada.caseId = listaCasos[0].Id;
        datosEntrada.origen = '';
        datosEntrada.caseNumber = listaCasos[0].CaseNumber;
        datosEntrada.fechaEvento = '26-1-2022';
        datosEntrada.textoEmail = 'Test textoemail ws bpo';

        List<SEG_WS_CanalBPO.ContenidoAdicional> listofAdicional= new List<SEG_WS_CanalBPO.ContenidoAdicional>();

        SEG_WS_CanalBPO.ContenidoAdicional contad = new SEG_WS_CanalBPO.ContenidoAdicional();
        contad.key = 'NIF';
        contad.value = '11111171H';
        listofAdicional.add(contad);
        SEG_WS_CanalBPO.ContenidoAdicional contadas= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadas.key = 'ASUNTO';
        contadas.value = 'test';
        listofAdicional.add(contadas);
        SEG_WS_CanalBPO.ContenidoAdicional contadrem= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrem.key = 'REMITENTE';
        contadrem.value = 'testrembpo@mailnovalid.com';
        listofAdicional.add(contadrem);
        SEG_WS_CanalBPO.ContenidoAdicional contadrec= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrec.key = 'RECEPTOR';
        contadrec.value = 'testreceptmbpo@mailnovalid.com';
        listofAdicional.add(contadrec);

        List<SEG_WS_CanalBPO.Documentsid> listofdocs= new List<SEG_WS_CanalBPO.Documentsid>();
        SEG_WS_CanalBPO.Documentsid docs = new SEG_WS_CanalBPO.Documentsid();
        ContentDocument documento = [SELECT Id FROM ContentDocument LIMIT 1];
        docs.key = documento.Id;
        docs.value = 'nombreDummy1.xls';
        listofdocs.add(docs);

        datosEntrada.contenidoAdicional = listofAdicional;
        datosEntrada.documentsid = listofdocs;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/CanalBPO/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();

            SEG_WS_CanalBPO.Output output = SEG_WS_CanalBPO.entradaCanalBPO();
            Test.stopTest();
            System.assertNotEquals(output, null, 'No se ha realizado la petición BPO');
        }
    }
    
    @isTest
    public static void entradaCanalBPO_B07()
    {
        List<Case> listaCasos = [SELECT Id,CaseNumber FROM Case WHERE Subject = 'test 2'];
       
        SEG_WS_CanalBPO.Input datosEntrada = new SEG_WS_CanalBPO.Input();
        datosEntrada.tipoProceso = 'B07';
        datosEntrada.caseId = listaCasos[0].Id;
        datosEntrada.origen = '';
        datosEntrada.caseNumber = listaCasos[0].CaseNumber;
        datosEntrada.fechaEvento = '26-1-2022';
        datosEntrada.textoEmail = 'Test textoemail ws bpo';

        List<SEG_WS_CanalBPO.ContenidoAdicional> listofAdicional= new List<SEG_WS_CanalBPO.ContenidoAdicional>();

        SEG_WS_CanalBPO.ContenidoAdicional contad = new SEG_WS_CanalBPO.ContenidoAdicional();
        contad.key = 'NIF';
        contad.value = '11111171H';
        listofAdicional.add(contad);
        SEG_WS_CanalBPO.ContenidoAdicional contadas= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadas.key = 'ASUNTO';
        contadas.value = 'test';
        listofAdicional.add(contadas);
        SEG_WS_CanalBPO.ContenidoAdicional contadrem= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrem.key = 'REMITENTE';
        contadrem.value = 'testrembpo@mailnovalid.com';
        listofAdicional.add(contadrem);
        SEG_WS_CanalBPO.ContenidoAdicional contadrec= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrec.key = 'RECEPTOR';
        contadrec.value = 'testreceptmbpo@mailnovalid.com';
        listofAdicional.add(contadrec);

        List<SEG_WS_CanalBPO.Documentsid> listofdocs= new List<SEG_WS_CanalBPO.Documentsid>();
        SEG_WS_CanalBPO.Documentsid docs = new SEG_WS_CanalBPO.Documentsid();
        ContentDocument documento = [SELECT Id FROM ContentDocument LIMIT 1];
        docs.key = documento.Id;
        docs.value = 'nombreDummy1.xls';
        listofdocs.add(docs);

        datosEntrada.contenidoAdicional = listofAdicional;
        datosEntrada.documentsid = listofdocs;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/CanalBPO/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();

            SEG_WS_CanalBPO.Output output = SEG_WS_CanalBPO.entradaCanalBPO();
            Test.stopTest();
            System.assertNotEquals(output, null, 'No se ha realizado la petición BPO');
        }
    }
    
    @isTest
    public static void entradaCanalBPO_B08()
    {
        List<Case> listaCasos = [SELECT Id,CaseNumber FROM Case WHERE Subject = 'test 2'];
       
        SEG_WS_CanalBPO.Input datosEntrada = new SEG_WS_CanalBPO.Input();
        datosEntrada.tipoProceso = 'B08';
        datosEntrada.caseId = listaCasos[0].Id;
        datosEntrada.origen = '';
        datosEntrada.caseNumber = listaCasos[0].CaseNumber;
        datosEntrada.fechaEvento = '26-1-2022';
        datosEntrada.textoEmail = 'Test textoemail ws bpo';

        List<SEG_WS_CanalBPO.ContenidoAdicional> listofAdicional= new List<SEG_WS_CanalBPO.ContenidoAdicional>();

        SEG_WS_CanalBPO.ContenidoAdicional contad = new SEG_WS_CanalBPO.ContenidoAdicional();
        contad.key = 'NIF';
        contad.value = '11111171H';
        listofAdicional.add(contad);
        SEG_WS_CanalBPO.ContenidoAdicional contadas= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadas.key = 'ASUNTO';
        contadas.value = 'test';
        listofAdicional.add(contadas);
        SEG_WS_CanalBPO.ContenidoAdicional contadrem= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrem.key = 'REMITENTE';
        contadrem.value = 'testrembpo@mailnovalid.com';
        listofAdicional.add(contadrem);
        SEG_WS_CanalBPO.ContenidoAdicional contadrec= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrec.key = 'RECEPTOR';
        contadrec.value = 'testreceptmbpo@mailnovalid.com';
        listofAdicional.add(contadrec);

        List<SEG_WS_CanalBPO.Documentsid> listofdocs= new List<SEG_WS_CanalBPO.Documentsid>();
        SEG_WS_CanalBPO.Documentsid docs = new SEG_WS_CanalBPO.Documentsid();
        ContentDocument documento = [SELECT Id FROM ContentDocument LIMIT 1];
        docs.key = documento.Id;
        docs.value = 'nombreDummy1.xls';
        listofdocs.add(docs);

        datosEntrada.contenidoAdicional = listofAdicional;
        datosEntrada.documentsid = listofdocs;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/CanalBPO/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();

            SEG_WS_CanalBPO.Output output = SEG_WS_CanalBPO.entradaCanalBPO();
            Test.stopTest();
            System.assertNotEquals(output, null, 'No se ha realizado la petición BPO');
        }
    }
    
    @isTest
    public static void entradaCanalBPO_B10()
    {
        List<Case> listaCasos = [SELECT Id,CaseNumber FROM Case WHERE Subject = 'test 2'];
       
        SEG_WS_CanalBPO.Input datosEntrada = new SEG_WS_CanalBPO.Input();
        datosEntrada.tipoProceso = 'B10';
        datosEntrada.caseId = listaCasos[0].Id;
        datosEntrada.origen = '';
        datosEntrada.caseNumber = listaCasos[0].CaseNumber;
        datosEntrada.fechaEvento = '26-1-2022';
        datosEntrada.textoEmail = 'Test textoemail ws bpo';

        List<SEG_WS_CanalBPO.ContenidoAdicional> listofAdicional= new List<SEG_WS_CanalBPO.ContenidoAdicional>();

        SEG_WS_CanalBPO.ContenidoAdicional contad = new SEG_WS_CanalBPO.ContenidoAdicional();
        contad.key = 'NIF';
        contad.value = '11111171H';
        listofAdicional.add(contad);
        SEG_WS_CanalBPO.ContenidoAdicional contadas= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadas.key = 'ASUNTO';
        contadas.value = 'test';
        listofAdicional.add(contadas);
        SEG_WS_CanalBPO.ContenidoAdicional contadrem= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrem.key = 'REMITENTE';
        contadrem.value = 'testrembpo@mailnovalid.com';
        listofAdicional.add(contadrem);
        SEG_WS_CanalBPO.ContenidoAdicional contadrec= new SEG_WS_CanalBPO.ContenidoAdicional();
        contadrec.key = 'RECEPTOR';
        contadrec.value = 'testreceptmbpo@mailnovalid.com';
        listofAdicional.add(contadrec);

        List<SEG_WS_CanalBPO.Documentsid> listofdocs= new List<SEG_WS_CanalBPO.Documentsid>();
        SEG_WS_CanalBPO.Documentsid docs = new SEG_WS_CanalBPO.Documentsid();
        ContentDocument documento = [SELECT Id FROM ContentDocument LIMIT 1];
        docs.key = documento.Id;
        docs.value = 'nombreDummy1.xls';
        listofdocs.add(docs);

        datosEntrada.contenidoAdicional = listofAdicional;
        datosEntrada.documentsid = listofdocs;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/CanalBPO/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();

            SEG_WS_CanalBPO.Output output = SEG_WS_CanalBPO.entradaCanalBPO();
            Test.stopTest();
            System.assertNotEquals(output, null, 'No se ha realizado la petición BPO');

            List<Case> listaCasosupdt = [SELECT Id,CaseNumber, SEG_Grupo__c FROM Case WHERE Subject = 'test 2'];
            System.assertNotEquals(null, listaCasosupdt[0].SEG_Grupo__c, 'Se debería haber informado el grupo respuesta');
        }
    }
}