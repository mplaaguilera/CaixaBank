@isTest
public class SEG_Contratos_TRHan_Test {
    /**
     * @description   Preparación de los datos.
     */
    @testSetup
    public static void testSetup() 
    {
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        // Creación cuentas a tratar.
        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG2.Name = 'Empresa numero2';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG2.CC_Numero_Documento__c = '11111112H';
        insert cuentaSEG2;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG2 = new Contact();
        contactoSEG2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG2.LastName = 'Contacto SEG 2';
        contactoSEG2.AccountId = cuentaSEG2.Id;
        contactoSEG2.Email = 'test2@test.com';
        insert contactoSEG2;



        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();

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
        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
		mccTematicaSEG.Name = 'Tematica1SEG';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000007';
        insert mccTematicaSEG;
        
        CC_MCC__c mccProductoSEG = new CC_MCC__c();
        mccProductoSEG.Name = 'Producto1SEG';
        mccProductoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG.RecordTypeId = recordTypeIdProducto;
        mccProductoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccProductoSEG.CC_Codigo_Externo__c = 'PR-000007'; 
        insert mccProductoSEG; 
        
       	CC_MCC__c mccMotivoSEG = new CC_MCC__c();
        mccMotivoSEG.Name = 'Motivo1SEG';
        mccMotivoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccMotivoSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccMotivoSEG.CC_Codigo_Externo__c = 'MO-000007';
        insert mccMotivoSEG;

       	CC_MCC__c mccDetalleSEG = new CC_MCC__c();
        mccDetalleSEG.Name = 'Detalle1SEG';
        mccDetalleSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccDetalleSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccDetalleSEG.CC_Motivo__c = mccMotivoSEG.Id;
        mccDetalleSEG.CC_Codigo_Externo__c = 'DE-000007';
        insert mccDetalleSEG;
        
        SEG_ClasificacionRapida__c regla3 = new SEG_ClasificacionRapida__c();
        regla3.Name = 'CR3';
        regla3.SEG_Tematica__c = mccTematicaSEG.Id;
        regla3.SEG_Producto__c = mccProductoSEG.Id;
        regla3.SEG_Motivo__c = mccMotivoSEG.Id;
        regla3.SEG_Detalle__c = mccDetalleSEG.Id;
        regla3.SEG_ReclamacionesContratos__c = recl.Id;
        regla3.SEG_CRContratos__c  = true;
        regla3.CBK_Negocio__c = 'Segmentos';
        insert regla3;


        //Caso de seguimiento
        Case caso3 = new Case();
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso3.AccountId = cuentaSEG1.Id;
        caso3.ContactId = contactoSEG1.Id;
        caso3.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso3.SEG_Idioma__c = 'es';
        caso3.CC_AcuseRecibo__c ='1';
        caso3.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso3.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso3.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso3.Status = 'Activo';
        caso3.Subject = 'test Seguimiento';
        caso3.SEG_ClasificacionRapida__c = regla3.Id;
        caso3.SEG_Organizacion__c = 'Instituciones';
		caso3.SEG_Zona__c = 'Instituciones Catalunya';

        insert caso3;
        
        //Caso de seguimiento
        Case caso4 = new Case();
        caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso4.AccountId = cuentaSEG2.Id;
        caso4.ContactId = contactoSEG2.Id;
        caso4.CC_MailTelfNotif__c = contactoSEG2.Email;
        caso4.SEG_Idioma__c = 'es';
        caso4.CC_AcuseRecibo__c ='1';
        caso4.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso4.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso4.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso4.Status = 'Activo';
        caso4.Subject = 'test Seguimiento';
        caso4.SEG_ClasificacionRapida__c = regla3.Id;
        caso4.SEG_Organizacion__c = 'Instituciones';
		caso4.SEG_Zona__c = 'Instituciones Catalunya';

        insert caso4;
        
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        caracteristica.Name = 'Reclamaciones Agotadas';
        caracteristica.CC_Descripcion__c = 'descripción';
        insert caracteristica;
        
        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c();
        caracteristica2.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        caracteristica2.Name = 'Errores22';
        caracteristica2.CC_Descripcion__c = 'test';
        insert caracteristica2;
        
        SEG_Marca_de_un_cliente__c marca1 = new SEG_Marca_de_un_cliente__c();
        marca1.SEG_Cliente__c = cuentaSEG2.Id;
        marca1.SEG_Caracteristica__c = caracteristica.Id;
        insert marca1;
        
        SEG_Marca_de_un_cliente__c marca2 = new SEG_Marca_de_un_cliente__c();
        marca2.SEG_Cliente__c = cuentaSEG1.Id;
        marca2.SEG_Caracteristica__c = caracteristica2.Id;
        insert marca2;
        
        //Crear contratos
        List<SEG_Contratos__c> listadoContratos = new List<SEG_Contratos__c>();
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso4.Id;
        contrato1.SEG_Estado__c = 'No Firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        listadoContratos.add(contrato1);

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato2.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato2.SEG_SR_Seguimiento__c=caso3.Id;
        contrato2.SEG_Estado__c = 'No Firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();
        listadoContratos.add(contrato2);
        
       	SEG_Contratos__c contrato3 = new SEG_Contratos__c();
        contrato3.Name = 'Number3';
        contrato3.SEG_NombreCliente__c = contactoSEG2.Id;
        contrato3.SEG_NombreCuenta__c = cuentaSEG2.Id;
        contrato3.SEG_SR_Seguimiento__c=caso3.Id;
        contrato3.SEG_Estado__c = 'Reclamaciones Agotadas';
        contrato3.SEG_Fecha_2_Reclamacion__c = date.Today();
        listadoContratos.add(contrato3);
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
        
        cdl.Visibility= 'InternalUsers';
        update cdl;

    }
    @isTest
    private static void test() {
        
        SEG_Contratos__c contratUpd = [SELECT Id, SEG_Estado__c FROM SEG_Contratos__c WHERE Name ='Number2'];
        
        Test.startTest();
        contratUpd.SEG_Estado__c = 'Reclamaciones Agotadas';
        update contratUpd;
        Test.stopTest();
    }
    
    @isTest
    private static void test2() {
        
        SEG_Contratos__c contratUpd = [SELECT Id, SEG_Estado__c FROM SEG_Contratos__c WHERE Name ='Number1'];
        
        Test.startTest();
        contratUpd.SEG_Estado__c = 'Reclamaciones Agotadas';
        update contratUpd;
        Test.stopTest();
        
        
    }

    
}