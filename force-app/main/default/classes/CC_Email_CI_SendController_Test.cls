@IsTest
public class CC_Email_CI_SendController_Test {
    
    public static String emailTemplateName = 'Test';
    
    @testSetup static void methodName() {
		String developerNameCarpeta = 'CC_CI_Operativas';
        EmailTemplate emailTemp = new EmailTemplate();
        emailTemp.DeveloperName = emailTemplateName;
        emailTemp.Name = emailTemplateName;
        emailTemp.TemplateType = 'custom';
        emailTemp.IsActive = true;
        emailTemp.FolderId = UserInfo.getUserId();
        insert emailTemp;
	}

    @isTest
    static void getCarpetas_test(){
        
        Id sRecordType = Schema.getGlobalDescribe().get('CC_Agrupador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        String plantilla = 'Test';
        
        //Creación de los MCCs
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
    	mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
 
    	//Creación del Agrupador
        CC_Agrupador__c  agrupador = new CC_Agrupador__c ();
        agrupador.recordTypeId = sRecordType;
        agrupador.CC_Estado__c = 'Activo';
        agrupador.CC_Titulo__c = 'Test';
        agrupador.CC_Tematica_Id__c = mccTematica.Id;
        agrupador.CC_Producto_Servicio__c = mccProducto.Id;
        agrupador.CC_Motivo__c = mccMotivo.Id;
        
        insert agrupador;
        
        List<Folder> carpetaList = new List<Folder>();
        String developerNameCarpeta = 'CC_CI_Operativas';
        Test.startTest();
        List<Folder> respuestaCarpetas = new List<Folder>();
        String respuestaCarpetaDevName;
        EmailTemplate emailTemp1 = new EmailTemplate();
        
        Integer respuestaCarpetaSize;
        respuestaCarpetas = CC_Email_CI_SendController.getCarpetas(agrupador.Id);
        respuestaCarpetaDevName = respuestaCarpetas.get(0).DeveloperName;
        Id respuestaCarpetaId = respuestaCarpetas.get(0).Id;
        respuestaCarpetaSize = respuestaCarpetas.size();
        List <EmailTemplate> emailTemplates = new List<EmailTemplate>();
        List<EmailTemplate> getPlantillasResults = new List<EmailTemplate>();
        getPlantillasResults = CC_Email_CI_SendController.getPlantillas(respuestaCarpetaDevName);
        System.assertNotEquals(respuestaCarpetaSize, 0);
        Test.stopTest();
        
    } 
    
    @isTest
    static void actualizarAgrupador_test(){
        
        Id sRecordType = Schema.getGlobalDescribe().get('CC_Agrupador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        String plantilla = 'Test';
        
        //Creación de los MCCs
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
    	mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
         CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
 
    	//Creación del Agrupador
        CC_Agrupador__c  agrupador = new CC_Agrupador__c ();
        agrupador.recordTypeId = sRecordType;
        agrupador.CC_Estado__c = 'Activo';
        agrupador.CC_Titulo__c = 'Test';
        agrupador.CC_Tematica_Id__c = mccTematica.Id;
        agrupador.CC_Producto_Servicio__c = mccProducto.Id;
        agrupador.CC_Motivo__c = mccMotivo.Id;
        
        insert agrupador;
        
        Id agrupadorId = [Select Id from CC_Agrupador__c where CC_Titulo__c = 'Test' limit 1].Id;
        String emailTemplate = [Select Id, developerName from EmailTemplate where DeveloperName =: emailTemplateName limit 1].developerName;

        CC_Email_CI_SendController.actualizarAgrupador(agrupadorId,emailTemplate);
        
    }
    
    @isTest
    static void buscarColaborador_test(){
        
        String emailTest = 'test@test.com';
        Id recordTypeIdAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
    	Account cuenta = new Account();
        cuenta.RecordTypeId = recordTypeIdAccount;
        cuenta.Name = 'TestAccount';
        cuenta.CC_Email__c = emailTest;
		Insert cuenta;
        
        Id recordTypeIdGrupoColab = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c ();
        grupoColab.Name = 'Grupo Colaborador Test 10';
        grupoColab.CC_Cuenta__c = cuenta.Id;
        grupoColab.RecordtypeId = recordTypeIdGrupoColab;
        grupoColab.CC_External__c = 'GC-03001';
        Insert grupoColab;
        
        Id recordTypeIdContact = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.recordtypeId = recordTypeIdContact;
        contacto.LastName= 'Test';
        contacto.Email = 'test@test.com';
        
        Insert contacto;
        
        Test.startTest();
        CC_Grupo_Colaborador_Contact__c  grupoColabContact = new CC_Grupo_Colaborador_Contact__c ();
        grupoColabContact.CC_Grupo_Colaborador__c = grupoColab.Id;
        grupoColabContact.CC_Para_CC__c = 'Para';
        grupoColabContact.CC_Contacto__c = contacto.Id;
        
        Insert grupoColabContact;
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c ();
        agrupador.CC_CI_Id_GrupoColaborador_Interno__c = grupoColab.Id;
        agrupador.CC_Titulo__c = 'Test';
        
        Insert agrupador;
        Test.stopTest();
        
        Map<String, String> functionCall = new Map<String,String>();
        functionCall = CC_Email_CI_SendController.buscarColaborador(agrupador.Id);
        String email = functionCall.get('Para');
        System.assertNotEquals(email, emailTest);
    }
    
    
}