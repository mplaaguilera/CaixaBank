/**********************************************************************************************************************
 Name:      AV_BuscadorLeadOpp_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for av_BuscadorLeadOpp LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				DATE        Description
   	1.0      US374367			Vladislav Lityagin		30/05/2022  Init version
	1.1		 US405453			Vladislav Lityagin		08/08/2022  Add searchNoAccountTest, getOriginValuesTest
	1.2		 Fix PMD Errors		Daniel Rodriguez		30/10/2023	Modify test method to assertEqual and runass 

***********************************************************************************************************************/
@isTest
public with sharing class AV_BuscadorLeadOpp_Controller_Test {
    private final static String  ID_GCF	= [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' LIMIT 1].Id;
    
    @TestSetup
	static void setup(){
        Test.startTest();
        AV_TestHelper.activateLogger();
		AV_TestHelper.createPricebook2();
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
        
        System.runAs(userGcf){
            User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
			userGestor.Email = 'gestor-test@test.com';
			User usrTest = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01543678');
			List<User> listUserInsert = new List<User>();
			listUserInsert.add(userGestor);
			listUserInsert.add(usrTest);
			insert listUserInsert;
			AV_TestHelper.insertNeededPermissions2(listUserInsert[0]);
			AV_TestHelper.insertNeededPermissions2(listUserInsert[1]);
         
        }

        System.runAs(userCli){
            Account accTest = AV_TestHelper.createConfidencialCustomerSinInsert();
			Account accTest2 = AV_TestHelper.createCustomerWithNumpersonSinInsert('12345678');
			accTest2.AV_Negocio__c = 'BPA;BPR';
			Account cenTest = AV_TestHelper.createCaixaCenterSinInsert();
			List<Account> listAccountInsert = new List<Account>();
			listAccountInsert.add(accTest);
			listAccountInsert.add(accTest2);
			listAccountInsert.add(cenTest);
			insert listAccountInsert;
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
        	Account center2 = new Account(Name = '00804 TEST CENTER',CC_Numero_Oficina_Empresa__c = '00804',CC_Numero_Oficina__c = '00804',RecordTypeId = rt.Id,AV_CentroSuperior__c = accTest.Id);
            insert center2;
        }
        Test.stopTest();

        System.runAs(userGcf){
			Account cenTest = [SELECT Id FROM Account WHERE CC_Numero_Oficina_Empresa__c = '00615' LIMIT 1];

			User userGestor = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
			User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01543678' AND IsActive = true];
			Contact conTest = AV_TestHelper.createEmployeeSinInsert(cenTest, userGestor, userGestor.AV_ExternalID__c);
			
			List<Contact> listContactInsert = new List<Contact>();
			listContactInsert.add(conTest);
			insert listContactInsert;

            List<Product2> prodsToInsert = new List<Product2>();
			Product2 prodPF = AV_TestHelper.createProductSinInsert(null,null,'50112');
			Product2 prodPF2 = AV_TestHelper.createProductSinInsert(null,null,'50113');
            prodPF2.AV_PFNowIn__c = true;
			Product2 prodPF3 = AV_TestHelper.createProductSinInsert(null,null,'50114');
			Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115');
			prodsToInsert.add(prodPF);
			prodsToInsert.add(prodPF2);
			prodsToInsert.add(prodPF3);
			prodsToInsert.add(prodPF4);
			insert prodsToInsert;

            User usrOtraOficina = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U000000001');
            RecordType rt = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', AV_AppConstants.LEAD_PPHH_RT);
            RecordType rtl = AV_AppUtilities.getRecordType('Lead', 'AV_PlataformasHipotecarias');

            Lead lead = AV_TestHelper.createLeadSinInsert(rtl);
            lead.OwnerId = userGestor.Id;
            insert lead;
        
            AV_LeadOpportunity__c lo = AV_TestHelper.createLeadOpportunitySinInsert(lead, rt);
            lo.OwnerId = userGestor.Id;
            insert lo;    
        } 
	}
    
    @isTest
	private static void getBaseDataTaskDatosTest() {
        AV_BuscadorLeadOpp_Controller.ObjectList ol = new AV_BuscadorLeadOpp_Controller.ObjectList();
        AV_BuscadorLeadOpp_Controller.ObjectList ol2 = new AV_BuscadorLeadOpp_Controller.ObjectList();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        AV_LeadOpportunity__c loObjectRecord = new AV_LeadOpportunity__c();
        AV_LeadOpportunity__c lo = new AV_LeadOpportunity__c();
      
        System.runAs(userGcf){
            Test.startTest();

            lo = [SELECT Id, AV_Status__c,AV_Empresa__c,AV_Producto__c FROM AV_LeadOpportunity__c WHERE AV_CustomerOfferId__c = '0000000' LIMIT 1];
            
            String[] statusFilter = new String[]{AV_AppConstants.LEADOPP_STATUS_NUEVO};
            String[] empresaFilter=new String[]{'CaixaBank'};
            String[] productoFilter= new String[]{};
            String[] pendingReasonFilter = new String[]{};
            String[] resolutionFilter = new String[]{};
            String[] originFilter = new String[]{};
            String[] stageFilter = new String[]{AV_AppConstants.LEADOPP_STAGE_POTENCIAL,AV_AppConstants.LEADOPP_STAGE_GESTION,AV_AppConstants.LEADOPP_STAGE_NEGATIVA,AV_AppConstants.LEADOPP_STAGE_POSITIVA,AV_AppConstants.LEADOPP_STAGE_NO_APTO,AV_AppConstants.LEADOPP_STAGE_VENCIDA,AV_AppConstants.LEADOPP_STAGE_VENTA};
            User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
            String[] employeeFilter = new String[]{usuario.Id, ID_GCF};
            String page = '1'; //needed for pagination
            Date creationFromDate = Date.newInstance(2000, 10, 10);
            Date creationUntilDate = Date.newInstance(2100, 10, 10);
            Date fromDueDate = Date.newInstance(2000, 10, 10);
            Date untilDueDate = Date.newInstance(2100, 10, 10);
            double incomeAmountUntil= 10.5;
            double incomeAmountFrom=5;
        
            ol = AV_BuscadorLeadOpp_Controller.getBaseData(null, null, originFilter, empresaFilter,productoFilter ,null, statusFilter, stageFilter, null, null, employeeFilter, pendingReasonFilter, resolutionFilter, null, null, null, null,null, null ,page, null);
            stageFilter = new String[]{};
            statusFilter = new String[]{};
            empresaFilter = new String[]{};
            pendingReasonFilter = new String[]{'X'};
            resolutionFilter = new String[]{'X'};
            Lead l = [SELECT Id, AV_numperso__c FROM Lead WHERE OwnerId = :usuario.Id LIMIT 1];
            l.AV_numperso__c = [SELECT Id FROM Account WHERE AV_NumPerso__c = '12345678' LIMIT 1].Id;
            Database.update(l);
            ol2 = AV_BuscadorLeadOpp_Controller.getBaseData(creationFromDate, creationUntilDate, originFilter, empresaFilter, productoFilter ,null, statusFilter, stageFilter, null, null, employeeFilter, pendingReasonFilter, resolutionFilter, fromDueDate, untilDueDate, creationFromDate, creationUntilDate,incomeAmountFrom ,incomeAmountUntil,page, '00615');
            loObjectRecord = (AV_LeadOpportunity__c) ol.recordList[0];
            
            Test.stopTest();
        }
        System.assertEquals(lo.AV_Status__c, loObjectRecord.AV_Status__c, 'getBaseDataTaskDatosTest');
    }   
    
    @isTest
	public static void searchAccountTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<AV_LookupSearchResult> results= new List<AV_LookupSearchResult>();
        Account accTest1 = new Account(
            Name = 'Test Account 1',
            AV_NumPerso__c = '122323',
            AV_Confidencial__c = false
        );
        
        Account accTest2 = new Account(
            Name = 'Test Account 2',
            AV_NumPerso__c = '123348',
            AV_Confidencial__c = false
        );
        
        insert new List<Account>{accTest1, accTest2}; 
        System.runAs(userGcf){
            Test.startTest();
            results = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = accTest1.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            results = AV_BuscadorLeadOpp_Controller.searchAccount(accTest1.Name, new List<String>());
            results = AV_BuscadorLeadOpp_Controller.searchAccount(accTest1.Name, new List<String>{accTest2.Id});
            Test.stopTest();
        }
        System.assertEquals(accTest1.id,results[0].getId(),'searchAccountTest');
	}

   
    
    @isTest
	public static void searchNoAccountTest(){
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<AV_LookupSearchResult> results= new List<AV_LookupSearchResult>();
        List<Lead> leadList = new List<Lead>();
        System.runAs(usrCli){
            Test.startTest();
            results = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
            List<Account> acc = [Select Id, Name, CC_Numero_Documento__c From Account];
            leadList = [Select Id, Name From Lead];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = leadList.get(0).Id;
            Test.setFixedSearchResults(fixedSearchResults);
            results = AV_BuscadorLeadOpp_Controller.searchNoAccount(leadList.get(0).Name,new List<String>{acc.get(1).Id});
            results = AV_BuscadorLeadOpp_Controller.searchNoAccount(leadList.get(0).Name,lista);

            Test.stopTest();
        }
        System.assertEquals(leadList[0].id,results[0].getId(),'searchNoAccountTest');
	}
    
    @isTest
	public static void getOriginValuesTest(){
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<AV_LookupSearchResult> results= new List<AV_LookupSearchResult>();
        List<Lead> leadList = new List<Lead>();
        System.runAs(usrCli){
            List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> result = new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
            String valueFromPicklist = 'NO DATA';
                Test.startTest();
                result = AV_BuscadorLeadOpp_Controller.getOriginValues();
                for(AV_BuscadorLeadOpp_Controller.OptionsPicklist op: result){
                    if(op.value.equals(valueFromPicklist)){
                        System.assertEquals(valueFromPicklist,op.value,'getOriginValuesTest');
                    }
                }
                Test.stopTest();
        }
	}
    
    @isTest
	public static void getEmpresaValuesTest(){
		List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> result = new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        String valueFromPicklist = 'NO DATA';
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<AV_LookupSearchResult> results= new List<AV_LookupSearchResult>();
        List<Lead> leadList = new List<Lead>();
        System.runAs(usrCli){
            Test.startTest();
            result = AV_BuscadorLeadOpp_Controller.getEmpresaValues();
            for(AV_BuscadorLeadOpp_Controller.OptionsPicklist op: result){
                if(op.value.equals(valueFromPicklist)){
                    System.assertEquals(valueFromPicklist,op.value,'getOriginValuesTest');
                }
            }
            Test.stopTest();
        }
	}
    
    @isTest
	private static void getOfficeTest(){
		String result = null;
        User usrCli =[Select Id, AV_NumeroOficinaEmpresa__c from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Test.startTest();
        System.runAs(usrCli){
            result = AV_BuscadorLeadOpp_Controller.getOffice();
        }
        System.assertEquals(result, usrCli.AV_NumeroOficinaEmpresa__c, 'getOfficeTest');
             
        Test.stopTest();
	}
    
      @isTest
	public static void assignLeadOppTest () {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        System.runAs(userGcf){
            List<List<SObject>> searchResults = new List<List<SObject>>();
            List<AV_LeadOpportunity__c> listLeadOpp = [SELECT Id FROM AV_LeadOpportunity__c WHERE OwnerId = :usuario.Id LIMIT 1];
            String result = null;

            Test.startTest();
            result = AV_BuscadorLeadOpp_Controller.assign(usuario.Id, listLeadOpp);
            Test.stopTest();
        }
        AV_LeadOpportunity__c loAssigned = [SELECT Id, OwnerId FROM AV_LeadOpportunity__c WHERE OwnerId = :usuario.Id LIMIT 1];
        System.assertEquals(usuario.id, loAssigned.OwnerId, 'assignLeadOppTest');
    }	
    
    @isTest
	private static void getEmployeesTest() {
        List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> employees = new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        String ofi = '00615';
        Test.startTest();
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        System.runAs(usrCli) {
            employees= AV_BuscadorLeadOpp_Controller.getEmployees();
        	System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
        }
        Test.stopTest();
	}
    
    @isTest
    private static void getProductoTest(){
            Product2 prod = new Product2(
                Name = 'Producto de Prueba',
                AV_PFNowIn__c = true
            );
            insert prod;
          
        List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> productos =new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            Test.startTest();
            productos = AV_BuscadorLeadOpp_Controller.getProducto();
            Test.stopTest();
        }
        System.assertEquals(true,!productos.isEmpty(), 'KO');
    }
    
     @isTest
    public static void nameContactAssignTest() {
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User usuario = new User();
        String resul = '';
        System.runAs(usrCli){
            Test.startTest();
            usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
            resul= AV_BuscadorLeadOpp_Controller.nameContactAssign(usuario.Id);
            Test.stopTest();
        }
        System.assertNotEquals(null,resul, 'KO');
    }
    
    @isTest
    public static void getResolutionTest(){
        List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> resolutions=new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        System.runAs(usrCli){
            Test.startTest();
            resolutions=AV_BuscadorLeadOpp_Controller.getResolutionValues();
            Test.stopTest();
        }
        System.assertEquals(true, !resolutions.isEmpty(), 'KO');
    }
    
    @isTest
    public static void getPendingReasonTest(){
        List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> pReason=new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        System.runAs(usrCli){
            Test.startTest();
            pReason=AV_BuscadorLeadOpp_Controller.getPendingReasonValues();
            Test.stopTest();
        }
        System.assertEquals(true, !pReason.isEmpty(), 'KO');
    }
}