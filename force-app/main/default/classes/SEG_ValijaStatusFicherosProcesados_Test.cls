@isTest
public class SEG_ValijaStatusFicherosProcesados_Test {
    
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
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        // Crear MCC.
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        // Crear MCC.
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

        // Crear MCC.
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
               
        Case casoFicherosProcesados = new Case();
        casoFicherosProcesados.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        casoFicherosProcesados.AccountId = cuentaSEG1.Id;
        casoFicherosProcesados.ContactId = contactoSEG1.Id;
        casoFicherosProcesados.CC_MailTelfNotif__c = contactoSEG1.Email;
        casoFicherosProcesados.SEG_Idioma__c = 'es';
        casoFicherosProcesados.CC_AcuseRecibo__c ='1';
        casoFicherosProcesados.CC_MCC_Tematica__c = mccTematica.Id;
        casoFicherosProcesados.CC_MCC_ProdServ__c = mccProducto.Id;
        casoFicherosProcesados.CC_MCC_Motivo__c = mccMotivo.Id;
        casoFicherosProcesados.Status = 'Activo';
        casoFicherosProcesados.Subject = 'casoFicherosProcesados';
        casoFicherosProcesados.SEG_Organizacion__c = 'Banca Corporativa';
        casoFicherosProcesados.OS_Referencia_Valija__c = '0012345';
        casoFicherosProcesados.SEG_RefSalienteValija__c = '0012345';
        casoFicherosProcesados.SEG_Zona__c = 'Corporativa';
        casoFicherosProcesados.Origin = 'Paquetería';
        casoFicherosProcesados.SEG_EstadoTrasladoValija__c = 'Ficheros descargados';
        casoFicherosProcesados.SEG_N_operaciones_del_caso__c = 1;
		insert casoFicherosProcesados; 
              
        // Crear fichero asociado a la cuenta SEG.
        ContentVersion ficheroValija2 = new ContentVersion();
        ficheroValija2.ContentLocation = 'S';
        ficheroValija2.SEG_ValijaId__c = '0054321';
        ficheroValija2.Description = 'fichero_SEG_2';
        ficheroValija2.PathOnClient = 'fichero_SEG_2.txt';
        ficheroValija2.Title = 'fichero_SEG_2';
        ficheroValija2.VersionData = Blob.valueOf('test');
        ficheroValija2.IsMajorVersion = true;
        ficheroValija2.SEG_Tipo__c = 'JUSTIFICANTES';
        ficheroValija2.SEG_EnviadoValija__c = true;
        insert ficheroValija2;

        ContentVersion ficheroAdjuntado2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ficheroValija2.Id];

        ContentDocumentLink linkFichero = new ContentDocumentLink();
        linkFichero.ContentDocumentId = ficheroAdjuntado2.ContentDocumentId;
        linkFichero.LinkedEntityId = casoFicherosProcesados.Id;
        linkFichero.Visibility = 'AllUsers'; 
        
        insert linkFichero;
    }
    
    @isTest
    public static void informarEstado_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c FROM Case WHERE Subject = 'casoFicherosProcesados'];
        ContentVersion conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];
        
        List<String> lstFile = new List<String>{conVer.id};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_PROCESADOS';
        input.caseId = caso.id;
        input.valijaId = caso.OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = '';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = lstFile;
        input.emails = lstEmails;

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosProcesados.informarEstado(input);       
        Test.stopTest();

		System.assert(output.resultado == 'OK');
    }    
    
    @isTest
    public static void informarEstadoValijaKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c FROM Case WHERE Subject = 'casoFicherosProcesados'];
        ContentVersion conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];
        
        List<String> lstFile = new List<String>{conVer.id};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_PROCESADOS';
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
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosProcesados.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0002');
    }
    
    @isTest
    public static void informarEstadoCaseKO_Test()
    {
                     
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_PROCESADOS';
        input.caseId = '0000';
        input.valijaId = '0000';
        input.status = 'OK';
        input.detalleProceso = '';
        input.requiereJustificantes = '';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = '';

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosProcesados.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0001');
    }
    
    @isTest
    public static void informarEstadoTrasladoValijaKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c, SEG_EstadoTrasladoValija__c FROM Case WHERE Subject = 'casoFicherosProcesados'];
        caso.SEG_EstadoTrasladoValija__c = 'Iniciado';
        update caso;
        
        ContentVersion conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];
        
        List<String> lstFile = new List<String>{conVer.id};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_PROCESADOS';
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
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosProcesados.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0006');
    }
    
    @isTest
    public static void informarEstadoStatusKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c, SEG_EstadoTrasladoValija__c FROM Case WHERE Subject = 'casoFicherosProcesados'];
        
        ContentVersion conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];
        
        List<String> lstFile = new List<String>{conVer.id};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_PROCESADOS';
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
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosProcesados.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0003');
    }
    
    @isTest
    public static void informarEstadoFicherosKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c, SEG_EstadoTrasladoValija__c FROM Case WHERE Subject = 'casoFicherosProcesados'];
                
        List<String> lstFile = new List<String>{'file1, file2'};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_PROCESADOS';
        input.caseId = caso.id;
        input.valijaId = caso.OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = '';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 2;
        input.fechaValorSLA = '';
        input.fileList = lstFile;
        input.emails = lstEmails;

        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosProcesados.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '0004');
    }
    
    @isTest
    public static void informarEstadoJustificantesKO_Test()
    {
        
        Case caso = [SELECT Id, OS_Referencia_Valija__c, SEG_EstadoTrasladoValija__c FROM Case WHERE Subject = 'casoFicherosProcesados'];
                
        List<String> lstFile = new List<String>{'file1, file2'};
        List<String> lstEmails = new List<String>{'email1','email2'};
        
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'FICHEROS_PROCESADOS';
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
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosProcesados.informarEstado(input);       
        Test.stopTest();

		System.assert(output.codigo == '007'); 
    }
    
    @isTest
    public static void informarEstadoNull_Test()
    {        
        Test.startTest();      
        	SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput output = SEG_ValijaStatusFicherosProcesados.informarEstado(null);       
        Test.stopTest();

		System.assert(output.resultado == 'NOK');
    }
}