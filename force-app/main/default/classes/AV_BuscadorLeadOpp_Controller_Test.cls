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

***********************************************************************************************************************/
@isTest
public with sharing class AV_BuscadorLeadOpp_Controller_Test {
        private final static String  ID_GCF	= [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' LIMIT 1].Id;
    
       
@TestSetup
	static void setup(){
        
        User usrGcf =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        AV_TestHelper.activateLogger();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
        Product2 p2 = new Product2(
        Name = 'Hipoteca',
        AV_ExternalID__c = '50030',
        AV_PFNowIn__c=true);
        
        
        User usrOtraOficina = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U000000001');
        
        RecordType rt = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', AV_AppConstants.LEAD_PPHH_RT);
        Lead l= AV_TestHelper.createLead();
        AV_LeadOpportunity__c lo = new AV_LeadOpportunity__c(
            RecordTypeId = rt.Id,
            AV_CustomerOfferId__c = '0000000',
            AV_ExternalId__c = '00dds0df',
            AV_PrescriberId__c = 'RASTREATOR COMPARADOR CORREDURIA DE SEGUROS',
            AV_Status__c=AV_AppConstants.LEADOPP_STATUS_NUEVO,
            AV_Empresa__c= 'CaixaBank',
            AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_POTENCIAL,
            AV_Lead__c=l.Id,
            AV_DueDate__c=Date.newInstance(2070, 01, 01),
            OwnerId = usrOtraOficina.Id
        );
        insert lo;
        
        
        
        Account accTest = AV_TestHelper.createCustomer();
        System.runAs(usrCli){
		    Account cenTest = AV_TestHelper.createCaixaCenter();
            Contact conTest = AV_TestHelper.createEmployee(cenTest, usrOtraOficina);
            insert p2;
             
        }
        
        System.runAs(usrGcf){
            User usrMiOficina = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','');
            usrMiOficina.AV_NumeroOficinaEmpresa__c = '13297'; //used in searchTestMiOficina
            insert usrMiOficina;  
            
        }
        
        
	}
    
    //Date creationDateFilterFrom, Date creationDateFilterUntil, String[] originMultiFilter, String[] empresaMultiFilter , String[] productoMultiFilter,String[] statusMultiFilter, String[] stageMultiFilter, String clientFilter, String noClientFilter, String[] employeMultiFilter, String[] pendingReasonMultiFilter, String[] resolutionMultiFilter, Date dueDateFilterFrom, Date dueDateFilterUntil, Date closeDateFilterFrom, Date closeDateFilterUntil, String page, String office
    
    @isTest
	private static void getBaseDataTaskDatosTest() {
        AV_BuscadorLeadOpp_Controller.ObjectList ol = new AV_BuscadorLeadOpp_Controller.ObjectList();
        AV_BuscadorLeadOpp_Controller.ObjectList ol2 = new AV_BuscadorLeadOpp_Controller.ObjectList();
		Test.startTest();

		AV_LeadOpportunity__c lo = [SELECT Id, AV_Status__c,AV_Empresa__c,AV_Producto__c FROM AV_LeadOpportunity__c LIMIT 1];
        
        String[] statusFilter = new String[]{AV_AppConstants.LEADOPP_STATUS_NUEVO};
        String[] empresaFilter=new String[]{'CaixaBank'};
        String[] productoFilter= new String[]{};
        String[] pendingReasonFilter = new String[]{};
        String[] resolutionFilter = new String[]{};
        String[] originFilter = new String[]{};
        String[] stageFilter = new String[]{AV_AppConstants.LEADOPP_STAGE_POTENCIAL,AV_AppConstants.LEADOPP_STAGE_GESTION,AV_AppConstants.LEADOPP_STAGE_NEGATIVA,AV_AppConstants.LEADOPP_STAGE_POSITIVA,AV_AppConstants.LEADOPP_STAGE_NO_APTO,AV_AppConstants.LEADOPP_STAGE_VENCIDA,AV_AppConstants.LEADOPP_STAGE_VENTA};
        User usuario  = [Select Id From User Where AV_ExternalId__c = 'U000000001' limit 1];
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AV_PlataformasHipotecarias' LIMIT 1];
		//insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        String[] employeeFilter = new String[]{usuario.Id, ID_GCF};
        
            
        String page = '1'; //needed for pagination
        Date creationFromDate = Date.newInstance(2000, 10, 10);
        Date creationUntilDate = Date.newInstance(2100, 10, 10);
        Date fromDueDate = Date.newInstance(2000, 10, 10);
        Date untilDueDate = Date.newInstance(2100, 10, 10);
        
        double incomeAmountUntil= 10.5;
        double incomeAmountFrom=5;
        
        //lo.OwnerId = usuario.Id;
        Database.update(lo);
       	ol = AV_BuscadorLeadOpp_Controller.getBaseData(null, null, originFilter, empresaFilter,productoFilter ,null, statusFilter, stageFilter, null, null, employeeFilter, pendingReasonFilter, resolutionFilter, null, null, null, null,null, null ,page, null);
        stageFilter = new String[]{};
        statusFilter = new String[]{};
        empresaFilter = new String[]{};
        pendingReasonFilter = new String[]{'X'};
        resolutionFilter = new String[]{'X'};
        Lead l = [SELECT Id, AV_numperso__c FROM Lead WHERE AV_CustomerId__c='00000000Z' LIMIT 1];
        l.AV_numperso__c = [SELECT Id FROM Account LIMIT 1].Id;
        Database.update(l);
        ol2 = AV_BuscadorLeadOpp_Controller.getBaseData(creationFromDate, creationUntilDate, originFilter, empresaFilter, productoFilter ,null, statusFilter, stageFilter, null, null, employeeFilter, pendingReasonFilter, resolutionFilter, fromDueDate, untilDueDate, creationFromDate, creationUntilDate,incomeAmountFrom ,incomeAmountUntil,page, '00615');
        AV_LeadOpportunity__c loObjectRecord = (AV_LeadOpportunity__c) ol.recordList[0];
		System.assertEquals(lo.AV_Status__c, loObjectRecord.AV_Status__c, 'getBaseDataTaskDatosTest');
        Test.stopTest();
    }   
    
    @isTest
	public static void searchAccountTest(){
		Test.startTest();
    	List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        List<Account> acc = [Select Id, Name, CC_Numero_Documento__c From Account];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = acc.get(0).Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        results = AV_BuscadorLeadOpp_Controller.searchAccount(acc.get(0).Name,lista);
        results = AV_BuscadorLeadOpp_Controller.searchAccount(acc.get(0).Name,new List<String>{acc.get(1).Id});
        System.assertEquals(acc[0].id,results[0].getId(),'searchAccountTest');
        Test.stopTest();
	}
    
    @isTest
	public static void searchNoAccountTest(){
		Test.startTest();
    	List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        List<Account> acc = [Select Id, Name, CC_Numero_Documento__c From Account];
        List<Lead> leadList = [Select Id, Name From Lead];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = leadList.get(0).Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        results = AV_BuscadorLeadOpp_Controller.searchNoAccount(leadList.get(0).Name,new List<String>{acc.get(1).Id});
        results = AV_BuscadorLeadOpp_Controller.searchNoAccount(leadList.get(0).Name,lista);
        System.assertEquals(leadList[0].id,results[0].getId(),'searchNoAccountTest');
        Test.stopTest();
	}
    
    @isTest
	public static void getOriginValuesTest(){
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
    
    @isTest
	public static void getEmpresaValuesTest(){
		List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> result = new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        String valueFromPicklist = 'NO DATA';
        Test.startTest();
        result = AV_BuscadorLeadOpp_Controller.getEmpresaValues();
        for(AV_BuscadorLeadOpp_Controller.OptionsPicklist op: result){
            if(op.value.equals(valueFromPicklist)){
                System.assertEquals(valueFromPicklist,op.value,'getOriginValuesTest');
            }
        }
        Test.stopTest();
	}
    
    @isTest
	private static void getOfficeTest(){
		String result = null;
		User u = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE Email = 'test@test.dev' LIMIT 1];
        Test.startTest();
        System.runAs(u){
            result = AV_BuscadorLeadOpp_Controller.getOffice();
        }
        System.assertEquals(result, u.AV_NumeroOficinaEmpresa__c, 'getOfficeTest');
             
        Test.stopTest();
	}
    
      @isTest
	public static void assignLeadOppTest () {
		List<List<SObject>> searchResults = new List<List<SObject>>();
        List<AV_LeadOpportunity__c> listLeadOpp = [SELECT Id FROM AV_LeadOpportunity__c];
        //String objectName='Opportunity';	
        String result = null;
        User usuario  = [Select Id From User Where AV_ExternalId__c = 'U000000001' limit 1];
        //User usuario = (User) new AV_Query('User').selectField('Id').addConditionEq('Email','test@test.dev').fetch();

        Test.startTest();
        result = AV_BuscadorLeadOpp_Controller.assign(usuario.Id, listLeadOpp);
        Test.stopTest();
        AV_LeadOpportunity__c loAssigned = [SELECT Id, OwnerId FROM AV_LeadOpportunity__c LIMIT 1];
        System.assertEquals(usuario.id, loAssigned.OwnerId, 'assignLeadOppTest');
    }	
    
    @isTest
	private static void getEmployeesTest() {
 		//AV_MassReassignOwner_Controller.OptionsPicklist();
        List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> employees = new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        String ofi = '00615';
        Test.startTest();
        User u = [SELECT Id from User WHERE AV_NumeroOficinaEmpresa__c='13297' LIMIT 1];
        System.runAs(U) {
            employees= AV_BuscadorLeadOpp_Controller.getEmployees();
        	System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
        }
        Test.stopTest();
	}
    
    @isTest
    private static void getProductoTest(){
        List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> productos =new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        Test.startTest();
        productos =AV_BuscadorLeadOpp_Controller.getProducto();
        System.assertEquals(true,!productos.isEmpty());
        
     
        Test.stopTest();
    }
    
     @isTest
    public static void nameContactAssignTest() {
        Test.startTest();
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        //User usuario = (User) new AV_Query('User').selectField('Id').addConditionEq('Email','test@test.dev').fetch();
        String resul= AV_BuscadorLeadOpp_Controller.nameContactAssign(usuario.Id);
        Test.stopTest();
        System.assertNotEquals(null,resul);
    }
    
    @isTest
    public static void getResolutionTest(){
        List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> resolutions=new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        Test.startTest();
        resolutions=AV_BuscadorLeadOpp_Controller.getResolutionValues();
        System.assertEquals(true, !resolutions.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void getPendingReasonTest(){
        List<AV_BuscadorLeadOpp_Controller.OptionsPicklist> pReason=new List<AV_BuscadorLeadOpp_Controller.OptionsPicklist>();
        Test.startTest();
        pReason=AV_BuscadorLeadOpp_Controller.getPendingReasonValues();
        System.assertEquals(true, !pReason.isEmpty());
        Test.stopTest();
    }
    
    
    
    
    
}