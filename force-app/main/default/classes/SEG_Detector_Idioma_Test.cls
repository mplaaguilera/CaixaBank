@isTest
Global class SEG_Detector_Idioma_Test implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) 
    {   
        String sFakeRespuesta = '';

        sFakeRespuesta = '{"sr": "03934195", "model_name": "model-salesforce", "category": "Robot No Clasificado", "categories": [{"category": "Tarjetas", "ratio": "0.40430"}, {"category": "Tarjetas-Alta tarjeta/ VIA T", "ratio": "0.21459"}, {"category": "Robot No Clasificado", "ratio": "0.17570"}, {"category": "Transferencias-Devolución/retrocesión transferencia", "ratio": "0.08676"}, {"category": "Tarjetas-Baja tarjeta/VIA T", "ratio": "0.02030"}], "attributes": {"text_regex": [{"name": "cif_regex", "value": "A-28010791"}]}, "text_vector_words": [0.0]}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }
      
    @TestSetup
    public static void crearDatosPrueba() 
    {
        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        
        Id accountId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id contactId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        SEG_ClasificacionRapida__c classR = new SEG_ClasificacionRapida__c(
            Name = 'No procede'
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
            email= 'test@mensaje.com',
            RecordTypeId = contactId
        );
        insert contacto;
        
        Account account = new Account(
        	Name = 'acc',
            CC_Numero_Oficina__c = '001',
			SEG_CentroSegmento__c = acc.id,
            SEG_GestorOperativaNacional__c = contacto.id,
			SEG_GestorOperativaInternacional__c = contacto.id,
			SEG_GestorFinEstructurada__c = contacto.id,
            SEG_Organizacion__c = 'Banca Corporativa',
            SEG_Zona__c = 'Corporativa'
        );
        insert account;

        Contact contacto2 = new Contact(
        	AccountId = account.id,
            LastName = 'asda',
            email= 'test@mensaje.com',
            RecordTypeId = contactId
        );
        insert contacto2;
   
        Case caso = new Case(
            AccountId = account.id,
            Subject = 'case1',
            Description = 'Esto es un caso de prueba para Test',
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            SEG_Numero_de_centro__c = account.id,
            SEG_Idioma__c = 'es',
            RecordTypeId = rt,
            SEG_Grupo__c = grupoCol1.id,
            SEG_Grupo_Anterior__c = grupoCol2.id, 
            SEG_Organizacion__c = 'Banca Corporativa',
            SEG_Zona__c = 'Corporativa',
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            Status = 'Activo',
            SEG_Subestado__c = 'En curso'
        );
        insert caso; 
        
		EmailTemplate emailEs = new EmailTemplate();
		emailEs.DeveloperName = 'Reclamacion_1_1616749645917';
		emailEs.Encoding = 'ISO-8859-1';
		emailEs.FolderId = UserInfo.getUserId();
		emailEs.Subject = '[num_casos]';
		emailEs.IsActive = true;
		emailEs.Name = 'Reclamacion 1º';
		emailEs.TemplateType = 'custom';
		emailEs.TemplateStyle = 'none';
		emailEs.HtmlValue = '<html><head><title></title></head><body style="height: auto; min-height: auto;">1&ordm; reclamaci&oacute;n enviada con la SR de seguimiento&nbsp;{{{Case.CaseNumber}}}<style type="text/css">table {font-family: arial, sans-serif; border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;}tr:nth-child(even) { background-color: #dddddd;}</style><table><tr><th>N&uacute;mero Contrato</th><th>Fecha Contrato</th><th>Descripci&oacute;n Contrato</th></tr></table></body></html>';
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert emailEs;
		}

		SEG_Plantilla__c plantilla = new SEG_Plantilla__c();
		plantilla.Name = 'Acuse de recibo';
		plantilla.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		plantilla.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias';
		plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
		plantilla.SEG_Activa__c = true;
		plantilla.SEG_PlantillaCastellano__c = 'Firma BO';
		plantilla.SEG_PlantillaCatalan__c = 'Firma CAT';
		plantilla.SEG_PlantillaIngles__c = 'Firma IN';
		plantilla.SEG_PlantillaEuskera__c = 'Firma EUSK';
		plantilla.SEG_PlantillaGalego__c = 'Firma GAL';
		plantilla.SEG_PlantillaCastellanoID__c = emailEs.Id;
		insert plantilla;        

        CBK_IntegrationSetting__c csDETIDI = new CBK_IntegrationSetting__c();
        csDETIDI.Name = 'SEG_DETIDI';
        csDETIDI.NamedCredential__c = '	callout:API_GWT_PRE/detidi/predictscores';
        insert csDETIDI;
    }
    
 	@isTest 
    public static void getIdiomaES(){
     
        Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());        
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        List<Id> lstCaseIds = new List<Id>();
	    lstCaseIds.add(caso.id);
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
         
        Test.startTest();
            SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
        Test.stopTest();

        Case casoAfterUpdate = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        System.assertEquals('es', casoAfterUpdate.SEG_Idioma__c, 'El idioma del caso no se ha actualizado correctamente a español');
        
        }
    }  
    
    @isTest
    public static void getIdiomaForzarContact() {
        Case caso = new Case(Subject = 'case1', Description = 'Test case', CC_Idioma__c = 'en');
        insert caso;
        Contact contacto = new Contact(LastName = 'Fuentes', CC_Idioma__c = 'fr');
        insert contacto;

        contacto.CC_Idioma__c = 'ga';
        update contacto;
        
        caso.SEG_Idioma__c = null;
        caso.Description = '';
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        update caso;

        List<Id> lstCaseIds = new List<Id>();
        lstCaseIds.add(caso.Id);

        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();   
            Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());     
            SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email, subject, cuerpo);
            Test.stopTest();

            Case casoAfterUpdate = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
            System.assertEquals('es', casoAfterUpdate.SEG_Idioma__c, 'El idioma del caso no se ha forzado correctamente');
        }
    }
    
    @isTest 
    public static void getIdiomaForzarAccountES(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c, Description, ContactId, CC_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
        Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '002';
        update cuenta;
        
		contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = null;
        update contacto;

        caso.SEG_Idioma__c = null;
        caso.Description = '';
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        update caso;
        
        lstCaseIds.add(caso.Id);
        
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            Test.startTest();   
            Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());     
            SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
            Test.stopTest();
            
            Case casoAfterUpdate = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
            System.assertNotEquals(cuerpo, casoAfterUpdate.SEG_Idioma__c, 'El idioma del caso no se ha forzado correctamente');
        }
    } 
    
    @isTest 
    public static void getIdiomaForzarAccountCA(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c, Description, ContactId, CC_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
        Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '001';
        update cuenta;

        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = null;
        update contacto;
        
        caso.SEG_Idioma__c = null;
        caso.Description = '';
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        update caso;
        
        lstCaseIds.add(caso.Id);
        
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            Test.startTest();   
            Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());     
            SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
            Test.stopTest();
            
            Case casoAfterUpdate = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
            System.assertNotEquals(cuerpo, casoAfterUpdate.SEG_Idioma__c, 'El idioma del caso no se ha forzado correctamente');
        }
    }
    
    @isTest 
    public static void getIdiomaForzarAccountEU(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c, Description, ContactId, CC_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
        Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '003';
        update cuenta;

        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = null;
        update contacto;
        
        caso.SEG_Idioma__c = null;
        caso.Description = '';
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        update caso;
        
        lstCaseIds.add(caso.Id);
        
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            Test.startTest();   
            Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());     
            SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
            Test.stopTest();
            
            Case casoAfterUpdate = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
            System.assertNotEquals(cuerpo, casoAfterUpdate.SEG_Idioma__c, 'El idioma del caso no se ha forzado correctamente');
        }
    } 
    
    @isTest 
    public static void getIdiomaForzarAccountGA(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c, Description, ContactId, CC_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
         Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '004';
        update cuenta;
        
		contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = null;
        update contacto;
        
        caso.SEG_Idioma__c = null;
        caso.Description = '';
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        update caso;
        
        lstCaseIds.add(caso.Id);
        
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            Test.startTest();   
            Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());     
            SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
            Test.stopTest();

            Case casoAfterUpdate = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
            System.assertNotEquals(cuerpo, casoAfterUpdate.SEG_Idioma__c, 'El idioma del caso no se ha forzado correctamente');
        }
    } 
    
    @isTest 
    public static void getIdiomaForzarAccountEN(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c, Description, ContactId, CC_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
 		Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '010';
        update cuenta;
        
		contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = null;
        update contacto;
        
        caso.SEG_Idioma__c = null;
        caso.Description = '';
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        update caso;
        
        lstCaseIds.add(caso.Id);
        
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            Test.startTest();   
            Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());     
            SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
            Test.stopTest();

            Case casoAfterUpdate = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
            System.assertNotEquals(cuerpo, casoAfterUpdate.SEG_Idioma__c, 'El idioma del caso no se ha forzado correctamente');
        }
    } 
    
    @isTest 
    public static void getIdiomaGA(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c, Description FROM Case WHERE Subject = 'case1' LIMIT 1];
        caso.SEG_Idioma__c = 'ga';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
        Test.startTest();

        update caso;
        
        Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());               
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';
        lstCaseIds.add(caso.id);         
        SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);

        Test.stopTest();
        Case caso2 = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        System.assertNotEquals(caso2.SEG_Idioma__c, caso.SEG_Idioma__c, 'No se ha detectado el idioma');
        }
    } 

 	@isTest 
    public static void getIdiomaCA(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c, Description FROM Case WHERE Subject = 'case1' LIMIT 1];
        caso.SEG_Idioma__c = 'ca';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();

        update caso;
        
        Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());               
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';
        lstCaseIds.add(caso.id);         
        SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
     
        Test.stopTest();
        Case caso2 = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        System.assertNotEquals(caso2.SEG_Idioma__c, caso.SEG_Idioma__c, 'No se ha detectado el idioma');
        }
    }   

    @isTest 
    public static void getIdiomaEN(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        caso.SEG_Idioma__c = 'en';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();

        update caso;
        
        Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());               
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';
        lstCaseIds.add(caso.id);         
        SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
     
        Test.stopTest();
        Case caso2 = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        System.assertNotEquals(caso2.SEG_Idioma__c, caso.SEG_Idioma__c, 'No se ha detectado el idioma');
        }
    } 

    @isTest 
    public static void getIdiomaEU(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        caso.SEG_Idioma__c = 'eu';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();

        update caso;
        
        Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());               
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';
        lstCaseIds.add(caso.id);         
        SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
     
        Test.stopTest();
        Case caso2 = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        System.assertNotEquals(caso2.SEG_Idioma__c, caso.SEG_Idioma__c, 'No se ha detectado el idioma');
        }
    } 

    @isTest 
    public static void getIdiomaEmpty(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        caso.SEG_Idioma__c = '';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();

        update caso;
        
        Test.setMock(HttpCalloutMock.class, new SEG_Detector_Idioma_Test());               
        String cuerpo = 'Bon dia, això és una consulta de segments.';
        String subject = 'test ja aj aj ';
        String email = 'test@mensaje.com';
        lstCaseIds.add(caso.id);         
        SEG_Detector_Idioma.setIdiomaCaso(lstCaseIds, email , subject, cuerpo);
     
        Test.stopTest();
        Case caso2 = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        System.assertNotEquals(caso2.SEG_Idioma__c, caso.SEG_Idioma__c, 'No se ha detectado el idioma');
        }
    } 
    
    @isTest 
    public static void getIdPlantillaIdiomaCuentaGA(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
 		Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '004';
        update cuenta;
        
		contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = null;
        update contacto;
        
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.SEG_Idioma__c = '';
        update caso;
        

		Case casoCalcular = [SELECT id, SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();  
                Id idPlantilla = SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], casoCalcular);
            Test.stopTest();
            System.assertEquals(idPlantilla, null, 'No se ha encontrado plantilla');
        }
    } 
    
    @isTest 
    public static void getIdPlantillaIdiomaCuenta01(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
 		Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '001';
        update cuenta;
        
		contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = null;
        update contacto;
        
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.SEG_Idioma__c = '';
        update caso;
        

		Case casoCalcular = [SELECT id, SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();  
                Id idPlantilla = SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], casoCalcular);
            Test.stopTest();
            System.assertEquals(idPlantilla, null, 'No se ha encontrado plantilla');
        }
    } 
    
    @isTest 
    public static void getIdPlantillaIdiomaCuenta10(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
 		Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '010';
        update cuenta;
        
		contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = null;
        update contacto;
        
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.SEG_Idioma__c = '';
        update caso;

		Case casoCalcular = [SELECT id, SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();  
                Id idPlantilla = SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], casoCalcular);
            Test.stopTest();
            System.assertEquals(idPlantilla, null, 'No se ha encontrado plantilla');
        }
    }
    
    @isTest 
    public static void getIdPlantillaIdiomaCuenta03(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
 		Account cuenta = [SELECT id, AV_Idioma__c FROM Account LIMIT 1];
        cuenta.AV_Idioma__c = '003';
        update cuenta;
        
		contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = '';
        update contacto;
        
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.SEG_Idioma__c = '';
        update caso;

		Case casoCalcular = [SELECT id, SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();  
                Id idPlantilla = SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], casoCalcular);
            Test.stopTest();
            System.assertEquals(idPlantilla, null, 'No se ha encontrado plantilla');
        }
    }
    
        @isTest 
    public static void getIdPlantillaIdiomaContactoGA(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
        contacto.CC_Idioma__c = 'ga';
        update contacto;
        
        caso.ContactId = contacto.Id;
        caso.SEG_Idioma__c = '';
        update caso;

		Case casoCalcular = [SELECT id, SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();  
                Id idPlantilla = SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], casoCalcular);
            Test.stopTest();
            System.assertEquals(idPlantilla, null, 'No se ha encontrado plantilla');
        }
    } 
    
        @isTest 
    public static void getIdPlantillaIdiomaContactoCA(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
        contacto.CC_Idioma__c = 'ca';
        update contacto;
        
        caso.ContactId = contacto.Id;
        caso.SEG_Idioma__c = '';
        update caso;
		Case casoCalcular = [SELECT id, SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();  
                Id idPlantilla = SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], casoCalcular);
            Test.stopTest();
            System.assertEquals(idPlantilla, null, 'No se ha encontrado plantilla');
        }
    } 
    
        @isTest 
    public static void getIdPlantillaIdiomaContactoEN(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
        contacto.CC_Idioma__c = 'en';
        update contacto;
        
        caso.ContactId = contacto.Id;
        caso.SEG_Idioma__c = '';
        update caso;
        
		Case casoCalcular = [SELECT id, SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();  
                Id idPlantilla = SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], casoCalcular);
            Test.stopTest();
            System.assertEquals(idPlantilla, null, 'No se ha encontrado plantilla');
        }
    } 
    
        @isTest 
    public static void getIdPlantillaIdiomaContactoEU(){
        List<Id> lstCaseIds = new List<Id>();
        Case caso = [SELECT id, SEG_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Acuse de recibo');
        Contact contacto = [SELECT id,CC_Idioma__c, AccountId FROM Contact WHERE LastName = 'Fuentes' LIMIT 1];
        contacto.CC_Idioma__c = 'eu';
        update contacto;
        
        caso.ContactId = contacto.Id;
        caso.SEG_Idioma__c = '';
        update caso;
        
        Case casoCalcular = [SELECT id, SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Subject = 'case1' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();  
                Id idPlantilla = SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionesPlantilla.get(caso.Id)[0], casoCalcular);
            Test.stopTest();
            System.assertEquals(idPlantilla, null, 'No se ha encontrado plantilla');
        }
    } 
}