@isTest
public class SEG_ValijaStatusFicherosRecibidos_Test {
    
    @testSetup
    static void datosIniciales ()
    { 
        // RT utilizados.
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        cuentaSEG1.SEG_Organizacion__c = 'Banca Corporativa';
        cuentaSEG1.SEG_Zona__c = 'Corporativa';
        cuentaSEG1.CBK_Negocio__c = 'Segmentos';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
                               
        // Crear MCC.
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        // Crear MCC.
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        // Crear MCC.
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        // Crear MCC.
        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
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
        
		// Crear casos de los clientes.
        List<Case> listadoCasos = new List<Case>();
        
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso.AccountId = cuentaSEG1.Id;
        caso.ContactId = contactoSEG1.Id;
        caso.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso.SEG_Idioma__c = 'es';
        caso.CC_AcuseRecibo__c ='1';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.Status = 'Activo';
        caso.Subject = 'test 2';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.OS_Referencia_Valija__c = '0054321';
        caso.SEG_RefSalienteValija__c = '0054321';
        caso.SEG_Zona__c = 'Corporativa';
        caso.Origin = 'Paquetería';
        caso.SEG_EstadoTrasladoValija__c = 'Iniciado';
        caso.SEG_N_operaciones_del_caso__c = 1;
		insert caso; 
        
        // Crear fichero asociado a la cuenta SEG.
        ContentVersion ficheroValija1 = new ContentVersion();
        ficheroValija1.ContentLocation = 'S';
        ficheroValija1.SEG_ValijaId__c = '0054321';
        ficheroValija1.Description = 'fichero_SEG_1';
        ficheroValija1.PathOnClient = 'fichero_SEG_1.txt';
        ficheroValija1.Title = 'fichero_SEG_1';
        ficheroValija1.VersionData = Blob.valueOf('test');
        ficheroValija1.IsMajorVersion = true;
        ficheroValija1.SEG_Tipo__c = 'PAQUETERIA';
        ficheroValija1.SEG_EnviadoValija__c = true;
        insert ficheroValija1;

        ContentVersion ficheroAdjuntado1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ficheroValija1.Id];

        ContentDocumentLink linkFichero1 = new ContentDocumentLink();
        linkFichero1.ContentDocumentId = ficheroAdjuntado1.ContentDocumentId;
        linkFichero1.LinkedEntityId = caso.Id;
        linkFichero1.Visibility = 'AllUsers'; 
        
        insert linkFichero1;
        
    }
    
    @isTest
    public static void informarEstado_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c FROM Case WHERE Subject = 'test 2'];
        ContentVersion conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_1'];
        
        List<String> lstFile = new List<String>{conVer.id};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_RECIBIDOS';
        input.caseId = caso.id;
        input.valijaId = caso.OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = '';
        input.requiereJustificantes = '';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = '';
        input.fileList = lstFile;
        input.emails = lstEmails;

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosRecibidos.informarEstado(input);       
        Test.stopTest();

		System.assert(output.resultado == 'OK');
    }
    
    @isTest
    public static void informarEstadoValijaKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c FROM Case WHERE Subject = 'test 2'];
        ContentVersion conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_1'];
        
        List<String> lstFile = new List<String>{conVer.id};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_RECIBIDOS';
        input.caseId = caso.id;
        input.valijaId = '0000';
        input.status = 'OK';
        input.detalleProceso = '';
        input.requiereJustificantes = '';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = '';
        input.fileList = lstFile;
        input.emails = lstEmails;

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosRecibidos.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0002');
    }
    
    @isTest
    public static void informarEstadoCaseKO_Test()
    {
                     
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_RECIBIDOS';
        input.caseId = '0000';
        input.valijaId = '0000';
        input.status = 'OK';
        input.detalleProceso = '';
        input.requiereJustificantes = '';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = '';

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosRecibidos.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0001');
    }
    
    @isTest
    public static void informarEstadoTrasladoValijaKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c, SEG_EstadoTrasladoValija__c FROM Case WHERE Subject = 'test 2'];
        caso.SEG_EstadoTrasladoValija__c = 'Justificantes recibidos';
        update caso;
        
        ContentVersion conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_1'];
        
        List<String> lstFile = new List<String>{conVer.id};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_RECIBIDOS';
        input.caseId = caso.id;
        input.valijaId = caso.OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = '';
        input.requiereJustificantes = '';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = '';
        input.fileList = lstFile;
        input.emails = lstEmails;

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosRecibidos.informarEstado(input);       
        Test.stopTest();

        // FIX. Se quita la validación.
		System.assert(output.codigo == '0000');
    }
    
    @isTest
    public static void informarEstadoStatusKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c, SEG_EstadoTrasladoValija__c FROM Case WHERE Subject = 'test 2'];
        
        ContentVersion conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_1'];
        
        List<String> lstFile = new List<String>{conVer.id};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_RECIBIDOS';
        input.caseId = caso.id;
        input.valijaId = caso.OS_Referencia_Valija__c;
        input.status = 'FUCKED';
        input.detalleProceso = '';
        input.requiereJustificantes = '';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = '';
        input.fileList = lstFile;
        input.emails = lstEmails;

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosRecibidos.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0003');
    }
    
    @isTest
    public static void informarEstadoFicherosKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c, SEG_EstadoTrasladoValija__c FROM Case WHERE Subject = 'test 2'];
                
        List<String> lstFile = new List<String>{'file1, file2'};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_RECIBIDOS';
        input.caseId = caso.id;
        input.valijaId = caso.OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = '';
        input.requiereJustificantes = '';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = '';
        input.fileList = lstFile;
        input.emails = lstEmails;

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosRecibidos.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0004');
    }
    
    @isTest
    public static void informarEstadoNull_Test()
    {        
        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosRecibidos.informarEstado(null);       
        Test.stopTest();

		System.assert(output.resultado == 'NOK');
    }
}