@isTest
public class CC_ContentDocumentLink_TRHan_Test {
 
   
    @isTest
    public static void enviarCorreo(){
    	
        EmailTemplate plantilla = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'OS_Servicio_Bastanteo' LIMIT 1];
        if (plantilla == null) {
            plantilla = new EmailTemplate();
            plantilla.FolderId = UserInfo.getUserId();
            plantilla.Name = 'Test Plantilla';
            plantilla.DeveloperName = 'OS_Servicio_Bastanteo';
            plantilla.TemplateType = 'Text';
            plantilla.Subject = 'Test Subject';
            plantilla.HtmlValue = 'Body Subject';
            plantilla.IsActive = true;
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            	insert plantilla;
        	}
        }
             
		
        Account cuenta1 = new Account();
        cuenta1.Name = 'Cuenta Test Cliente';
        cuenta1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert cuenta1;
        
		Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypeContacto;
        contacto.Email = 'servicio.bastanteo@caixabank.com';
        contacto.LastName = 'Pruebas';
        contacto.AccountId = cuenta1.Id;
        insert contacto;
        
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

        CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
        grupoColaborador.Name = 'Servicio bastanteo';
        grupoColaborador.OS_Negocio__c = 'COPS';
        insert grupoColaborador;
        
        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Contacto__c = contacto.Id;
        colaborador.CC_Grupo_Colaborador__c=grupoColaborador.Id;
		insert colaborador;   
        
        CC_Grupo_Colaborador_Plantilla__c grupoPlantilla = new CC_Grupo_Colaborador_Plantilla__c();
        grupoPlantilla.CC_Grupo_Colaborador__c = grupoColaborador.Id;
        grupoPlantilla.CC_Plantilla_DeveloperName__c = 'OS_Servicio_Bastanteo';
        grupoPlantilla.CC_Operativa__c = 'Trasladar';
        insert grupoPlantilla;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        insert cuenta;
        
        Contact empleado = new Contact();
        empleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        empleado.FirstName = 'Empleado';
        empleado.LastName = 'Pruebas';
        empleado.AccountId = cuenta.Id;
        empleado.CC_Num_Empleado__c = '12345';
        insert empleado;
        
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
        mccTematica.OS_Departamento__c = 'UAFE';
		mccTematica.OS_Buzon_Salida__c = [SELECT displayname FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón de pruebas COPS' OR DISPLAYNAME = 'Buzón KYC Renewal' OR DISPLAYNAME = 'Buzón Service Desk' OR DISPLAYNAME = 'Buzón Comercio Exterior' OR DISPLAYNAME = 'Buzón Export Online' OR DISPLAYNAME = 'Buzón International Support'OR DISPLAYNAME = 'Buzón Contact Center International' LIMIT 1].displayname;
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert mccProducto; 
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'Apertura sin autorización';
        motivo.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = mccTematica.Id;
        motivo.CC_Producto_Servicio__c = mccProducto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;
        
        CC_MCC__c motivo2 = new CC_MCC__c();
        motivo2.Name = 'Pruebas bastanteo';
        motivo2.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        motivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo2.CC_Tematica__c = mccTematica.Id;
        motivo2.CC_Producto_Servicio__c = mccProducto.Id;
        motivo2.CC_Codigo_Externo__c = 'MOC-000002';
        insert motivo2;
        
        //Lista de valores para clasificación automática
        CC_Lista_Valores__c clasificacionesAutomaticas = new CC_Lista_Valores__c();
        clasificacionesAutomaticas.Name = 'COPS: Clasificaciones automáticas para valija digital';
        clasificacionesAutomaticas.CC_Activa__c = true;
        clasificacionesAutomaticas.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert clasificacionesAutomaticas;

        CC_Lista_Valores__c clasificacionAutomatica2 = new CC_Lista_Valores__c();
        clasificacionAutomatica2.Name = 'Bastanteo Analizar';
        clasificacionAutomatica2.CC_Activa__c = true;
        clasificacionAutomatica2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        clasificacionAutomatica2.CC_Lista__c = clasificacionesAutomaticas.Id;
        clasificacionAutomatica2.CC_Valor__c = motivo2.Id;
        insert clasificacionAutomatica2;
        
        
        OS_WS_AltaCasoValija.Output output = OS_WS_AltaCasoValija.altaCasoValija();
        Case caso = [SELECT CC_Buzon_Salida__c FROM Case WHERE ID = :output.caseId LIMIT 1];
        caso.CC_Buzon_Salida__c = [SELECT address FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón de pruebas COPS' OR DISPLAYNAME = 'Buzón KYC Renewal' OR DISPLAYNAME = 'Buzón Service Desk' OR DISPLAYNAME = 'Buzón Comercio Exterior' OR DISPLAYNAME = 'Buzón Export Online' OR DISPLAYNAME = 'Buzón International Support'OR DISPLAYNAME = 'Buzón Contact Center International' LIMIT 1].address;
		update caso;
        
        
    	Test.startTest();
    
    	Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        
        List<ContentVersion> listCVs = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content pdf';
        cv.PathOnClient = 'Test_Pdf.pdf';
        cv.VersionData = beforeblob;
        listCVs.add(cv);
        
        ContentVersion cv2 = new ContentVersion();
        cv2.title = 'test content image';
        cv2.PathOnClient = 'Test_Image.jpg';
        cv2.VersionData = beforeblob;
        listCVs.add(cv2);
        
        insert listCVs; 
        
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentVersion testContent2 = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv2.Id];
        
        List<ContentDocumentLink> listContentLink = new List<ContentDocumentLink>();
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentlink.LinkedEntityId = output.caseId;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        listContentLink.add(contentLink);
        
        ContentDocumentLink contentLink2 = new ContentDocumentLink();
        contentLink2.LinkedEntityId = output.caseId;
        contentLink2.ShareType = 'V';
        contentLink2.ContentDocumentId = testcontent2.ContentDocumentId;
        listContentLink.add(contentLink2);
        
        insert listContentLink;
        Test.stopTest();


    }
}