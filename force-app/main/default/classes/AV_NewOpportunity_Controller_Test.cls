/**********************************************************************************************************************
 Name:	  AV_NewOpportunity_Controller_Test
 Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase AV_NewOpportunity_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US167583		Álvaro López	   	04/03/2021		  	Init version
	1.1			US167583		Sandra Gómez	   	05/03/2021		  	Add methods saveOppRecordsInsertOppTest and
																				saveOppRecordsUpdateOppTasksTest
	1.2			FIX				David Rufo			15/07/2021			Fix problems with check on/off priorizador
    1.3 		FIX				Víctor Santiago		22/07/2021			Fixed decimal number problem
	1.3 		FIX				Sandra Gómez		02/12/2021			Fix Coverage
	1.4			US268502		Daniel Rodríguez	31/01/2022			Add createReportOppTaskTest method
	1.5			US481572		Patricia Solano 	27/01/2023	        Add searchByProductTest method and add runAs at all test methods
***********************************************************************************************************************/
@isTest
public with sharing class AV_NewOpportunity_Controller_Test {
    /**
	 * get value status field
	 */
    @TestSetup
    static void setup(){
        
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        
        System.runAs(usuario) {
			Pricebook2 pbTest = AV_TestHelper.createPricebook2();
            RecordType rt = [SELECT ID FROM RecordType where DeveloperName = 'AV_PF'and SobjectType = 'Product2'];
            Account accTest= AV_TestHelper.createCustomer();
            Product2 proTest =AV_TestHelper.createProduct2(null, '50033');
            Task tarea = AV_TestHelper.createTareaExternalIdWithCustomer(null,null,accTest);
            Product2 proTest2 =AV_TestHelper.createProduct2(null, '50032');
            proTest2.Name = 'prod test';
            proTest2.AV_Visible__c = true;
            proTest2.RecordTypeId = rt.Id;
            proTest2.AV_Nivel__c=null;
            update(proTest2);
        }
    }
    
    /**
	 * get value status field new opp
	 */
	@isTest
	public static void getStatusValuesNewOppTest() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            List<Map<String, String>> listMapValue = AV_NewOpportunity_Controller.getStatusValuesNewOpp('Opportunity', 'StageName');
            Test.stopTest(); 
            if(!listMapValue.isEmpty()){
                System.assert(listMapValue != Null); 
            }
        }
    }

    /**
	 * get entity field
	 */
	@isTest
	public static void getEntityFieldsTest() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            Product2 prod=[SELECT id from Product2 WHERE AV_ExternalID__c = '50033'];
            AV_OtherEntitiesProducts__c entityProd = new AV_OtherEntitiesProducts__c(Name = 'entity test 01', AV_ExternalId__c = '50033', AV_Share__c = true, AV_Entity__c = true, AV_Amount__c = true, AV_Enrollment__c = true, AV_InterestRate__c = true, AV_Expiration__c = true);
            Database.insert(entityProd);
            List<AV_NewOpportunity_Controller.ProdEntityField> listProdEntityFields = AV_NewOpportunity_Controller.getEntityFields(prod.Id);
            Test.stopTest();
            System.assertEquals(true, listProdEntityFields.size() > 0, 'No se han encontrado campos de otra entidad.'); 
        }    
	}
    
    /**
	 * insert new opp
	 */
    @isTest
	public static void saveOppRecordsInsertOppTest() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            Account acc=[SELECT ID FROM ACCOUNT LIMIT 1];
            Product2 prod=[SELECT id from Product2 WHERE AV_ExternalID__c = '50033'];
            Task  tarea= [SELECT id from Task where Priority = 'Normal'];
            Date fechaGestion= Date.today();
            Date fechaVencimineto= Date.today()+1;
            Map<String, Object> mapDato= new Map<String, Object>();
            mapDato.put('id',null);
            mapDato.put('taskid',tarea.id);
            mapDato.put('path','En gestión/insistir');
            mapDato.put('fechagestion',fechaGestion);
            mapDato.put('incluir',false);
            mapDato.put('fechavencimiento',fechaVencimineto);
            mapDato.put('entidad',null);
            mapDato.put('comentario','Prueba comentario');
            mapDato.put('importe','6,2');
            mapDato.put('interes','6,2');
            mapDato.put('producto',prod.id);
            mapDato.put('oportunidad','Nombre oportunidad');
            mapDato.put('cuota','6,2');
            mapDato.put('matricula',null);
            mapDato.put('otraentidadpick',null);
            List<Map<String, Object>> listDato= new List<Map<String, Object>> ();
            listDato.add(mapDato);
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            String result =AV_NewOpportunity_Controller.saveOppRecords(listDato);
            Test.stopTest();
            System.assertEquals('OK', result, 'No se ha insertado la oportunidad.');     
        }
	}
    
    /**
	 * insert new opp error El estado de la oportunidad no permite incluirla en "clientes priorizados".
	 */
    @isTest
	public static void saveOppRecordsInsertOppTestError() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            Account acc=[SELECT ID FROM ACCOUNT LIMIT 1];
            Product2 prod = [SELECT id FROM Product2 WHERE AV_ExternalID__c = '50033'];
            Task tarea = AV_TestHelper.createTareaExternalIdWithCustomer(null,null,acc);
            Date fechaGestion= Date.today();
            Date fechaVencimineto= Date.today()+1;
            Map<String, Object> mapDato= new Map<String, Object>();
            mapDato.put('id',null);
            mapDato.put('taskid',tarea.id);
            mapDato.put('path','No apto');
            mapDato.put('fechagestion',fechaGestion);
            mapDato.put('incluir',true);
            mapDato.put('fechavencimiento',fechaVencimineto);
            mapDato.put('entidad',null);
            mapDato.put('comentario','Prueba comentario');
            mapDato.put('importe','6,2');
            mapDato.put('interes','6,2');
            mapDato.put('producto',prod.id);
            mapDato.put('oportunidad','Nombre oportunidad');
            mapDato.put('cuota','6,2');
            mapDato.put('matricula',null);
            mapDato.put('otraentidadpick',null);
            List<Map<String, Object>> listDato= new List<Map<String, Object>> ();
            listDato.add(mapDato);
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            String result =AV_NewOpportunity_Controller.saveOppRecords(listDato);
            Test.stopTest();
            System.assertNotEquals('OK', result, 'El estado de la oportunidad no permite incluirla en "clientes priorizados".');  
        }   
	}
    
    /**
	 * insert new opp
	 */
    @isTest
	public static void createReportOppTaskTest() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            Account acc=[SELECT ID FROM ACCOUNT LIMIT 1];
            Product2 prod = [SELECT id FROM Product2 WHERE AV_ExternalID__c = '50033'];
            Task tarea = AV_TestHelper.createTareaExternalIdWithCustomer(null,'#1667225757164',acc);
            Opportunity oppNew=AV_TestHelper.createOpportunity(acc);
            Opportunity opp = [SELECT Id,Description FROM Opportunity LIMIT 1];
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            Task oppResult =AV_NewOpportunity_Controller.createOppTasks(String.valueof(opp.Id));
            string tareaResult =AV_NewOpportunity_Controller.deleteReportOpp(String.valueof(tarea.Id));
            Test.stopTest();
            System.assertEquals('OK', tareaResult, 'OK'); 
        }    
	}
    
    /**
	 * update opp error incluir
	 */
    @isTest
	public static void saveOppRecordsUpdateOppTasksTestError() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            
        Test.startTest();
        CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
        AV_Bypass__c bypass = new AV_Bypass__c(AV_ForbiddenWords__c = true);
        Database.insert(word, false);
        Database.insert(bypass, false);
        Account acc=[SELECT ID FROM ACCOUNT LIMIT 1];
        Task tarea = AV_TestHelper.createTareaExternalIdWithCustomer(null,null,acc);
        Opportunity opp=AV_TestHelper.createOpportunity(acc);
        AV_CustomActivityOpportunity__c tareaOportunidad = AV_TestHelper.createTareaOportunidad(opp,tarea.AV_Task__c);
        Product2 prod = [SELECT id FROM Product2 WHERE AV_ExternalID__c = '50033'];
        Date fechaGestion= Date.today();
        Date fechaVencimineto= Date.today()+1;
        Map<String, Object> mapDato= new Map<String, Object>();
        mapDato.put('id',tareaOportunidad.id);
        mapDato.put('taskid',tarea.id);
        mapDato.put('path','Potencial');
        mapDato.put('fechagestion',fechaGestion);
        mapDato.put('incluir',true);
        mapDato.put('fechavencimiento',fechaVencimineto);
        mapDato.put('entidad',null);
        mapDato.put('comentario','Prueba comentario');
        mapDato.put('importe','6,2');
        mapDato.put('interes','6,2');
        mapDato.put('producto',prod.id);
        mapDato.put('oportunidad','Nombre oportunidad');
        mapDato.put('cuota','6,2');
        mapDato.put('matricula',null);
        mapDato.put('otraentidadpick',null);
        List<Map<String, Object>> listDato= new List<Map<String, Object>> ();
        listDato.add(mapDato);
		String result =AV_NewOpportunity_Controller.saveOppRecords(listDato);
        Test.stopTest();
		System.assertNotEquals('OK', result, 'No es posible realizar el cambio de etapa. Las etapas Potencial, Vencida y Con venta son etapas automáticas.');     
        }
	}
    
    /**
	 * update opp error Para la etapa seleccionada es obligatorio informar fecha de próxima gestión.
	 */
    @isTest
	public static void saveOppRecordsUpdateOppTasksTestError2() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            Account acc=[SELECT ID FROM ACCOUNT LIMIT 1];
            Task tarea = AV_TestHelper.createTareaExternalIdWithCustomer(null,null,acc);
            Opportunity opp=AV_TestHelper.createOpportunity(acc);
            AV_CustomActivityOpportunity__c tareaOportunidad = AV_TestHelper.createTareaOportunidad(opp,tarea.AV_Task__c);
            Product2 prod = [SELECT id FROM Product2 WHERE AV_ExternalID__c = '50033'];
            Date fechaGestion= Date.today();
            Date fechaVencimineto= Date.today()+1;
            
            Map<String, Object> mapDato= new Map<String, Object>();
            mapDato.put('id',tareaOportunidad.id);
            mapDato.put('taskid',tarea.id);
            mapDato.put('path','En gestión/insistir');
            mapDato.put('fechagestion',null);
            mapDato.put('incluir',true);
            mapDato.put('fechavencimiento',fechaVencimineto);
            mapDato.put('entidad',null);
            mapDato.put('comentario','Prueba comentario');
            mapDato.put('importe','6,2');
            mapDato.put('interes','6,2');
            mapDato.put('producto',prod.id);
            mapDato.put('oportunidad','Nombre oportunidad');
            mapDato.put('cuota','6,2');
            mapDato.put('matricula',null);
            mapDato.put('otraentidadpick',null);
            List<Map<String, Object>> listDato= new List<Map<String, Object>> ();
            listDato.add(mapDato);
            String result =AV_NewOpportunity_Controller.saveOppRecords(listDato);
            Test.stopTest();
            System.assertNotEquals('OK', result, 'Para la etapa seleccionada es obligatorio informar fecha de próxima gestión.'); 
        }    
	}
    
    /**
	 * update opp error El estado de la oportunidad no permite incluirla en "clientes priorizados".
	 */
    @isTest
	public static void saveOppRecordsUpdateOppTasksTestError3() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            Account acc=[SELECT ID FROM ACCOUNT LIMIT 1];
            Task tarea = AV_TestHelper.createTareaExternalIdWithCustomer(null,null,acc);
            Opportunity opp=AV_TestHelper.createOpportunity(acc);
            AV_CustomActivityOpportunity__c tareaOportunidad = AV_TestHelper.createTareaOportunidad(opp,tarea.AV_Task__c);
            Product2 prod = [SELECT id FROM Product2 WHERE AV_ExternalID__c = '50033'];
            Date fechaGestion= Date.today();
            Date fechaVencimineto= Date.today()+1;
            Map<String, Object> mapDato= new Map<String, Object>();
            mapDato.put('id',tareaOportunidad.id);
            mapDato.put('taskid',tarea.id);
            mapDato.put('path','No apto');
            mapDato.put('fechagestion',null);
            mapDato.put('incluir',true);
            mapDato.put('fechavencimiento',fechaVencimineto);
            mapDato.put('entidad',null);
            mapDato.put('comentario','Prueba comentario');
            mapDato.put('importe','6,2');
            mapDato.put('interes','6,2');
            mapDato.put('producto',prod.id);
            mapDato.put('oportunidad','Nombre oportunidad');
            mapDato.put('cuota','6,2');
            mapDato.put('matricula',null);
            mapDato.put('otraentidadpick',null);
            List<Map<String, Object>> listDato= new List<Map<String, Object>> ();
            listDato.add(mapDato);
            String result =AV_NewOpportunity_Controller.saveOppRecords(listDato);
            Test.stopTest();
            System.assertNotEquals('OK', result, 'El estado de la oportunidad no permite incluirla en "clientes priorizados".');   
        }  
	}
     
    /**
	 * update opp
	 */
    @isTest
	public static void saveOppRecordsUpdateOppTasksTest() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            Account acc=[SELECT ID FROM ACCOUNT LIMIT 1];
            Task tarea = AV_TestHelper.createTareaExternalIdWithCustomer(null,null,acc);
            Opportunity opp=AV_TestHelper.createOpportunity(acc);
            AV_CustomActivityOpportunity__c tareaOportunidad = AV_TestHelper.createTareaOportunidad(opp,tarea.AV_Task__c);
            Product2 prod = [SELECT id FROM Product2 WHERE AV_ExternalID__c = '50033'];
            Date fechaGestion= Date.today();
            Date fechaVencimineto= Date.today()+1;
            Map<String, Object> mapDato= new Map<String, Object>();
            mapDato.put('id',tareaOportunidad.id);
            mapDato.put('taskid',tarea.id);
            mapDato.put('path','En gestión/insistir');
            mapDato.put('fechagestion',fechaGestion);
            mapDato.put('incluir',false);
            mapDato.put('fechavencimiento',fechaVencimineto);
            mapDato.put('entidad',null);
            mapDato.put('comentario','Prueba comentario');
            mapDato.put('importe','6,2');
            mapDato.put('interes','6,2');
            mapDato.put('producto',prod.id);
            mapDato.put('oportunidad','Nombre oportunidad');
            mapDato.put('cuota','6,2');
            mapDato.put('matricula',null);
            mapDato.put('otraentidadpick',null);
            mapDato.put('origenapp',null);
            mapDato.put('potencial',null);
            mapDato.put('resolucion',null);
            mapDato.put('byProduct',opp.AV_ByProduct__c);
            mapDato.put('amount','6,2');
            mapDato.put('margin','6,2');
            List<Map<String, Object>> listDato= new List<Map<String, Object>> ();
            listDato.add(mapDato);
            String result =AV_NewOpportunity_Controller.saveOppRecords(listDato);
            Test.stopTest();
            System.assertEquals('OK', result, 'No se ha insertado la oportunidad.');   
        }  
	}

    /**
	 * search product 
	 */
    @isTest
	public static void searchProductTest(){
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
            List<AV_LookupSearchResult> results2 = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
            List<String> listaNoEmpty = new List<String>();
            listaNoEmpty.add('rdmString');
            Product2 seeProd = [SELECT ID,Name,AV_ExternalId__c,AV_Nivel__c,AV_Visible__c,RecordType.DeveloperName FROM Product2 WHERE AV_ExternalID__c = '50032' LIMIT 1];
            results = AV_NewOpportunity_Controller.searchProduct(seeProd.Name,lista);
            results2 = AV_NewOpportunity_Controller.searchProduct('prod test',listaNoEmpty);
            Test.stopTest();
            System.assertEquals(true,results.isEmpty(), 'searchProductTest');
        }
    }

    /**
	 * search employee
	 */
    @isTest 
    public static void getEmployeeTest(){
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
            List<AV_LookupSearchResult> results2 = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
            List<String> listaNoEmpty = new List<String>();
            listaNoEmpty.add('rdmString');
            User u = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
            User u2 = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
            u2.AV_NumeroOficinaEmpresa__c= '12';
            List<User> toUpdate = new List<User>{u,u2};
            Database.update(toUpdate);
            results = AV_NewOpportunity_Controller.getEmployees(u.Name,lista);
            results2 = AV_NewOpportunity_Controller.getEmployees(u.Name,listaNoEmpty);
            String idContact = AV_NewOpportunity_Controller.getContact(u.Id);
            Test.stopTest();
            System.assertEquals(true,results.isEmpty(),'Algo ha salido mal');
            System.assertEquals(null,idContact,'Algo ha salido mal');
        }
    }

    /**
	 * search by-product 
	 */
    @isTest
	public static void searchByProductTest(){
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            Test.startTest();
            List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
            List<AV_LookupSearchResult> results2 = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
            List<String> listaNoEmpty = new List<String>();
            listaNoEmpty.add('rdmString');
            Product2 seeProd = [SELECT ID,Name,AV_ExternalId__c,AV_Nivel__c,AV_Visible__c,RecordType.DeveloperName FROM Product2 WHERE AV_ExternalID__c = '50032' LIMIT 1];
            results = AV_NewOpportunity_Controller.searchByProduct(seeProd.Name, lista, seeProd.Name);
            results2 = AV_NewOpportunity_Controller.searchByProduct('prod test', listaNoEmpty, seeProd.Name);
            Test.stopTest();
            System.assertEquals(true,results.isEmpty(), 'searchByProductTest');
        }
    }
}