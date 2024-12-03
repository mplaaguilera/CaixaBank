@isTest
public with sharing class SEG_TaskConnect_Test implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {   
        
        String sFakeRespuesta = '{"sr": "2-912076545","model_name": "model-001","category": "Credit Cards","categories": [{"category": "Credit Cards", "ratio": "0.52114"},{"category": "Credit Cards", "ratio": "0.22389"},{"category": "Credit Cards", "ratio": "0.20729"},{"category": "Credit Cards", "ratio": "0.02778"},{"category": "Credit Cards", "ratio": "0.01109"},{"category": "Credit Cards", "ratio": "0.00698"},{"category": "Credit Cards", "ratio": "0.00155"},{"category": "Robot no encontrado", "ratio": "0.00027"}]}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }
      
    @TestSetup
    public static void crearDatosPrueba()  {
        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        
        Id accountId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id contactId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c(
            name = 'Test CR',
            SEG_Nombre_CR_Cognitive__c = 'Credit Cards',
            SEG_Canaldeentrada__c = 'Email',
            CBK_Negocio__c = 'Segmentos'
        );
        insert clasRapida;  
        
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
            RecordTypeId = contactId
        );
        insert contacto;
        
        Account cuenta = new Account(
        	Name = 'acc',
            CC_Numero_Oficina__c = '001',
			SEG_CentroSegmento__c = acc.id,
            SEG_GestorOperativaNacional__c = contacto.id,
			SEG_GestorOperativaInternacional__c = contacto.id,
			SEG_GestorFinEstructurada__c = contacto.id
        );
        insert cuenta;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        e.AccountId = cuenta.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
   
        Case caso = new Case(
            AccountId = cuenta.id,
            Subject = 'case1',
            Description = 'Esto es un caso de prueba para Test',
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            SEG_Numero_de_centro__c = cuenta.id,
            RecordTypeId = rt,
            SEG_Grupo__c = grupoCol1.id,
            SEG_Grupo_Anterior__c = grupoCol2.id, 
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            Status = 'Activo',
            SEG_Subestado__c = 'En curso'
        );
        insert caso; 

        CBK_IntegrationSetting__c csTaskConnect = new CBK_IntegrationSetting__c();
        csTaskConnect.Name = 'SEG_Task_Connect';
        csTaskConnect.NamedCredential__c = 'callout:API_SEG_PRO/tech/orqcor/predict';
        insert csTaskConnect;
    }

    @isTest 
    public static void getTaskConnect(){ 
     
        Test.setMock(HttpCalloutMock.class, new SEG_MockHttpResponseGenerator(200, 'OK', '{"sr": "03934069", "model_name": "model-salesforce", "category": "Credit Cards", "categories": [{"category": "Tarjetas", "ratio": "0.57436"}, {"category": "Tarjetas-Alta tarjeta/ VIA T", "ratio": "0.26805"}, {"category": "Alfabético", "ratio": "0.06269"}, {"category": "Bastanteos", "ratio": "0.06056"}, {"category": "Tarjetas-Baja tarjeta/VIA T", "ratio": "0.01888"}], "attributes": {"text_regex": [{"name": "cif_regex", "value": "A-28010791"}]}, "text_vector_words": [0.0]}', null));
               
        Case caso = [SELECT id, Subject, Description, CreatedDate, SEG_Zona__c, SEG_Organizacion__c, CaseNumber FROM Case LIMIT 1];
     
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            SEG_TaskConnect.envioComunicacion(caso.id,'A');
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id FROM CC_TrazaInt__c LIMIT 1];

        System.AssertNotEquals(null, trazaInsertada, 'No se ha creado traza');
    }
    
}