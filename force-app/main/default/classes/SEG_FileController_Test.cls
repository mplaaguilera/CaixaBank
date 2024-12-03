@isTest
private class SEG_FileController_Test{
	@testSetup static void setup(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.CC_Idioma__c = 'es';
        insert contactoSEG1;


        //Crear reclamaciones
        SEG_Reclamaciones__c recl = new SEG_Reclamaciones__c();
        recl.Name = 'Testreclamaciones';
        recl.SEG_Plazo1Reclamacion__c = 1;
        recl.SEG_Plazo2Reclamacion__c = 2;
        recl.SEG_Plazo3Reclamacion__c = 3;
        recl.SEG_PlazoEnvioGestor__c = 4;
        recl.SEG_PlazoLlamada__c = 1;

        insert recl;
        
        
        //Crear MCC para CR

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
       	CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.Name = 'Detalle1';
        mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle.RecordTypeId = recordTypeIdDetalle;
        mccDetalle.CC_Tematica__c = mccTematica.Id;
        mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
        mccDetalle.CC_Motivo__c = mccMotivo.Id;
        mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalle;

       
        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;
        regla1.SEG_ReclamacionesContratos__c = recl.Id;
        regla1.SEG_CRContratos__c  = true;
        regla1.CBK_Negocio__c = 'Segmentos';
        insert regla1;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        
        // Crear casos de los clientes.
        Case caso1 = new Case();
        //caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.Subject = 'test 1';
        caso1.SEG_ClasificacionRapida__c = regla1.Id;
        insert caso1;

        //Crear contratos
        List<SEG_Contratos__c> listadoContratos = new List<SEG_Contratos__c>();
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso1.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        listadoContratos.add(contrato1);

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato2.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato2.SEG_SR_Seguimiento__c=caso1.Id;
        contrato2.SEG_Estado__c = 'No firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();
        listadoContratos.add(contrato2);
        insert listadoContratos;
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        cv.SEG_Firmado__c = true;
        cv.PathOnClient = 'TestDocument.pdf';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = contrato1.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'I';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = caso1.Id;
        emailmes.TextBody='CORREO ENTRANTE';
        emailmes.Incoming=true;
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;   
	}

	@isTest static void getFilesListTest() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

		List<Account> listaAccount = [SELECT Id, Name FROM Account WHERE Name = 'Empresa segmentos'];
        List<Contact> listaContact = [SELECT Id, AccountId,LastName  FROM Contact WHERE LastName = 'Contacto SEG 1'];
        List<SEG_ClasificacionRapida__c> listCR = [Select Id,Name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR1'];
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 1'];
        List<SEG_Contratos__c> listaContratos = [SELECT Id FROM SEG_Contratos__c WHERE Name = 'Number1'];
		List<ContentDocumentLink> lstCdl =[SELECT ContentDocumentId,ContentDocument.LatestPublishedVersion.Title,ContentDocument.LatestPublishedVersion.CreatedDate,
                ContentDocument.LatestPublishedVersion.CreatedBy.Name,ContentDocument.Description,ContentDocument.LatestPublishedVersion.SEG_Firmado__c
                FROM ContentDocumentLink WHERE LinkedEntityId = :listaContratos[0].Id];

        System.runAs ( supervisor ) {
            Test.startTest();
            SEG_FileController.FilesWrapper[] filesList = SEG_FileController.getFilesList(listaContratos[0].Id);
            Test.stopTest();
            
            System.assert(filesList != null, 'No se han generado registros');
        }
	}
    
	@isTest static void getFileVersionDetailsTest() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

		List<Account> listaAccount = [SELECT Id, Name FROM Account WHERE Name = 'Empresa segmentos'];
        List<Contact> listaContact = [SELECT Id, AccountId,LastName  FROM Contact WHERE LastName = 'Contacto SEG 1'];
        List<SEG_ClasificacionRapida__c> listCR = [Select Id,Name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR1'];
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 1'];
        List<SEG_Contratos__c> listaContratos = [SELECT Id FROM SEG_Contratos__c WHERE Name = 'Number1'];
		List<ContentDocumentLink> lstCdl =[SELECT ContentDocumentId,ContentDocument.LatestPublishedVersion.Title,ContentDocument.LatestPublishedVersion.CreatedDate,
                ContentDocument.LatestPublishedVersion.CreatedBy.Name,ContentDocument.Description,ContentDocument.LatestPublishedVersion.SEG_Firmado__c
                FROM ContentDocumentLink WHERE LinkedEntityId = :listaContratos[0].Id];

        System.runAs ( supervisor ) {
            Test.startTest();
            SEG_FileController.FileVersionWrapper[] filesList = SEG_FileController.getFileVersionDetails(lstCdl[0].ContentDocumentId);
            Test.stopTest();
            
            System.assert(filesList != null, 'No se han generado registros');
        }
	}
    
	@isTest static void createContentDocLinkTest() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<SEG_Contratos__c> listaContratos = [SELECT Id FROM SEG_Contratos__c WHERE Name = 'Number1'];
        
        System.runAs ( supervisor ) {
            ContentVersion ficheroSFDC = new ContentVersion();
            //ficheroSFDC.ContentLocation = 'S';
            ficheroSFDC.Description = 'fichero_SEG_1';
            ficheroSFDC.PathOnClient = 'fichero_SEG_1.txt';
            ficheroSFDC.Title = 'fichero_SEG_1';
            ficheroSFDC.VersionData = Blob.valueOf('test');
            ficheroSFDC.IsMajorVersion = true;
            insert ficheroSFDC;
        
            Test.startTest();
            Id returnedId = SEG_FileController.createContentDocLink(ficheroSFDC.Id,listaContratos[0].Id,'Test');
            Test.stopTest();
            
            System.assert(returnedId != null, 'Id no devuelta.');
        }
	}
    
	@isTest static void updateContentDocLinkTest() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<SEG_Contratos__c> listaContratos = [SELECT Id FROM SEG_Contratos__c WHERE Name = 'Number1'];
        
        System.runAs ( supervisor ) {
            ContentVersion ficheroSFDC = new ContentVersion();
            ficheroSFDC.ContentLocation = 'S';
            ficheroSFDC.Description = 'fichero_SEG_1';
            ficheroSFDC.PathOnClient = 'fichero_SEG_1.txt';
            ficheroSFDC.Title = 'fichero_SEG_1';
            ficheroSFDC.VersionData = Blob.valueOf('test');
            ficheroSFDC.IsMajorVersion = true;
            insert ficheroSFDC;
        
            Test.startTest();
            Id returnedId = SEG_FileController.updateContentDocLink(ficheroSFDC.Id,listaContratos[0].Id,'Test',True, 'Test');
            Test.stopTest();
            
            System.assert(returnedId != null, 'Id no devuelta.');
        }
	}

    @isTest static void uploadFileModifyTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<SEG_Contratos__c> listaContratos = [SELECT Id FROM SEG_Contratos__c WHERE Name = 'Number1'];

        System.runAs ( supervisor ) {
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
            cdl.LinkedEntityId = listaContratos[0].Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            String description = 'test';
            String titulo = 'test';
            String gdd = 'gdd';

        
            Test.startTest();
                SEG_FileController.uploadFileModify(documents[0].id, titulo, description, false, gdd );
            Test.stopTest();
            
            System.assert(!documents.isEmpty() == true,'ok');
        }
    }

    @isTest static void deleteUploadedFileTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ]; 
        String description = 'test';
        String titulo = 'test';
        String gdd = 'gdd';

        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_FileController.deleteUploadedFile(documents[0].id);
            Test.stopTest();
            
            System.assert(!documents.isEmpty() == true,'ok');
        }
    }

    @isTest static void deleteFilesTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ]; 
        String description = 'test';
        String titulo = 'test';
        String gdd = 'gdd';
        List<Id> listIds = new List<Id>();
        listIds.add(documents[0].id);
        System.runAs ( supervisor ) {
            Test.startTest();
                SEG_FileController.deleteFiles(listIds);
            Test.stopTest();
            
            System.assert(!documents.isEmpty() == true,'ok');
        }
    }
}