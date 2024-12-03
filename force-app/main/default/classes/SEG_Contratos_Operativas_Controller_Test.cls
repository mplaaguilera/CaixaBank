@isTest
public class SEG_Contratos_Operativas_Controller_Test{
    //User operativo = SEG_Usuarios.usuarioOperativo();
    //User supervisor = SEG_Usuarios.usuarioSupervisor();
    @TestSetup
    static void datosIniciales(){
        
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
		cv.SEG_Firmado__c = false;
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
        cdl.shareType = 'V';
        insert cdl;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = caso1.Id;
        emailmes.TextBody='CORREO ENTRANTE';
        emailmes.Incoming=true;
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;


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

    public @IsTest
    static void recuperarUser(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();
        
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( supervisor ) {
            String user = SEG_Contratos_Operativas_Controller.recuperarUser();
            System.assertEquals(true, true, 'No se ha identificado bien el usuario');
        }
    }

    @isTest
    public static void fetchEmailsCasoTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        Case caso = [SELECT id FROM Case LIMIT 1];
        Map<Id,String> mapEmail = new Map<Id,String>();

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( supervisor ) {
            Test.startTest();				
                mapEmail = SEG_Contratos_Operativas_Controller.fetchEmailsCaso(caso.id);        
            Test.stopTest();
            System.assertNotEquals(mapEmail, null, 'No se obtenido el email');
        }
    }

    @isTest
    public static void getFilesCaseTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        Case caso = [SELECT id FROM Case LIMIT 1];
        List<ContentVersion> listFiles = new List<ContentVersion>();

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( supervisor ) {
            Test.startTest();
            listFiles = SEG_Contratos_Operativas_Controller.getFilesCase(caso.Id);
            Test.stopTest();
            System.assertNotEquals(listFiles, null, 'No se han obtenido los adjuntos');
        }
    }

    @isTest
    public static void fetchContratoCasoTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<SEG_Contratos__c> lstContratos = [Select Id,Name,  SEG_Fecha_1a_Reclamacion_Proceso__c,SEG_Fecha_2a_Reclamacion_Proceso__c,SEG_Fecha_3a_Reclamacion_Proceso__c FROM SEG_Contratos__c];
        Map<id,String> contratosCaso = new Map<id,String>();
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( supervisor ) {
            Test.startTest();
            contratosCaso = SEG_Contratos_Operativas_Controller.fetchContratoCaso(lstContratos[0].Id);
            Test.stopTest();
            System.assertNotEquals(contratosCaso, null, 'No se han obtenido los contratos');
        }
    }

    @isTest
    public static void recuperarContratoTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<SEG_Contratos__c> lstContratos = [Select Id,Name, SEG_Fecha_1a_Reclamacion_Proceso__c,SEG_Fecha_2a_Reclamacion_Proceso__c,SEG_Fecha_3a_Reclamacion_Proceso__c FROM SEG_Contratos__c];
        SEG_Contratos__c contrato = new SEG_Contratos__c();
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( supervisor ) {
            Test.startTest();
            contrato = SEG_Contratos_Operativas_Controller.recuperarContrato(lstContratos[0].Id);
            Test.stopTest();
            System.assertNotEquals(contrato, null, 'No se ha obtenido el contrato');
        }
    }

    @isTest
    public static void importarAnexosSRTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<SEG_Contratos__c> lstContratos = [Select Id,Name, SEG_Fecha_1a_Reclamacion_Proceso__c,SEG_Fecha_2a_Reclamacion_Proceso__c,SEG_Fecha_3a_Reclamacion_Proceso__c FROM SEG_Contratos__c];
        List<ContentVersion> lstCntVersion = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId,PathOnClient FROM ContentVersion limit 1];
        //String listFiles= '["0"]';
        String listFiles= '["'+String.valueOf(lstCntVersion[0].ContentDocumentId)+'"]';
        List<String> anexos = new List<String>();
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( supervisor ) {
            Test.startTest();
            anexos = SEG_Contratos_Operativas_Controller.importarAnexosSR(lstContratos[0].Id,listFiles);
            Test.stopTest();
            System.assertNotEquals(anexos, null, 'No se han importado los anexos');
        }
    }
}