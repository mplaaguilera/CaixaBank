/**********************************************************************************************************************
 Name:	  AV_ListViewComponentController_Test
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Test class of AV_ListViewComponentController
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Carolina Alonso		20/05/2020			Init version
	1.1								Carolina Alonso		18/09/2020			Add test classes for new functionality
	1.2			FIX					Sandra Gómez		27/08/2021			Fix product opportunity

***********************************************************************************************************************/
@isTest
public with sharing class AV_ListViewComponentController_Test {
	
    static final String CON_VENTA = 'Con venta';
    static final String VIGENTE = 'Vigentes';
	static final String HISTORICO = 'Historico';
	static final String ALL = 'All';
    
	/**
	 * Create Contact without an associated Supervisor.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
	}

	@isTest
	public static void testGetInitDataTask() {
		Account acc = AV_TestHelper.createCustomer();

		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);

		Task tarea  = AV_TestHelper.createTarea(null);
		String idCabeceraTarea = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
		AV_CustomActivityOpportunity__c tareaOpp= AV_TestHelper.createTareaOportunidad(opp, idCabeceraTarea);

		Test.startTest();		

		AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
		response = AV_ListViewComponentController.getInitData(tarea.Id, VIGENTE);
		//System.debug('response: ' + response.listRowData);
		String listRowData = 'listRowData';
		AV_ListViewComponentController.RowData[] setModel = response.listRowData;
		System.assertEquals(1, setModel.size());

		Test.stopTest();
	}

	@isTest
	public static void testGetInitDataEvent() {
		Account acc = AV_TestHelper.createCustomer();

		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);

		DateTime activityDate = Datetime.newInstance(2020, 5, 4);

		Event event  = AV_TestHelper.createEvent(null, activityDate, acc);
		String idCabeceraTarea = [SELECT AV_Task__c FROM Event WHERE AV_ExternalID__c = :event.AV_ExternalID__c LIMIT 1].AV_Task__c;
		AV_CustomActivityOpportunity__c tareaOpp= AV_TestHelper.createTareaOportunidad(opp, idCabeceraTarea);
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		Test.startTest();

		AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
		response = AV_ListViewComponentController.getInitData(event.Id, VIGENTE);
		//System.debug('response: ' + response.listRowData);
		String listRowData = 'listRowData';
		AV_ListViewComponentController.RowData[] setModel = response.listRowData;
		System.assertEquals(1, setModel.size());

		Test.stopTest();
	}

	@isTest
	public static void testGetInitDataPFClienteOppVigentes() {
		Account acc = AV_TestHelper.createCustomer();
        
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);
		//opp.CloseDate = System.today() +2;
		update opp;

		AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();

		AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperience();
		prodExp.AV_Activo__c = true;
		prodExp.AV_ProductoFicha__c = opp.AV_PF__c; 
		prodExp.AV_ExperienciaNegocio__c = exp.Id;
		update prodExp;
		
		AV_ProductClient__c prodCliente = AV_TestHelper.createPFCliente();
        prodCliente.AV_ProductoFicha__c = prodExp.Id;
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_TieneOportunidad__c = 'OPORT';
        prodCliente.AV_TenenciaProducto__c = '1';
        prodCliente.AV_Potencialidad__c = 'S';
		update prodCliente;

		Test.startTest();

		AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
		response = AV_ListViewComponentController.getInitData(prodCliente.Id, VIGENTE);
		System.debug('response: ' + response.listRowData);
		String listRowData = 'listRowData';
		AV_ListViewComponentController.RowData[] setModel = response.listRowData;

		Test.stopTest();
	}

	@isTest
	public static void testGetInitDataPFClienteOppHistorico() {
		Account acc = AV_TestHelper.createCustomer();
        
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);
		//opp.CloseDate = System.today() +2;
		update opp;

		AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();

		AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperience();
		prodExp.AV_Activo__c = true;
		prodExp.AV_ProductoFicha__c = opp.AV_PF__c; 
		prodExp.AV_ExperienciaNegocio__c = exp.Id;
		update prodExp;
		
		AV_ProductClient__c prodCliente = AV_TestHelper.createPFCliente();
        prodCliente.AV_ProductoFicha__c = prodExp.Id;
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_TieneOportunidad__c = 'OPORT';
        prodCliente.AV_TenenciaProducto__c = '1';
        prodCliente.AV_Potencialidad__c = 'S';
		update prodCliente;
        
		Test.startTest();

		AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
		response = AV_ListViewComponentController.getInitData(prodCliente.Id, HISTORICO);
		System.debug('response: ' + response.listRowData);
		String listRowData = 'listRowData';
		AV_ListViewComponentController.RowData[] setModel = response.listRowData;
		System.assertEquals(1, setModel.size());

		Test.stopTest();
	}

	@isTest
	public static void testGetInitDataPFClienteOppAll() {
		Account acc = AV_TestHelper.createCustomer();
        
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);
		//opp.CloseDate = System.today() +2;
		update opp;

		AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();

		AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperience();
		prodExp.AV_Activo__c = true;
		prodExp.AV_ProductoFicha__c = opp.AV_PF__c; 
		prodExp.AV_ExperienciaNegocio__c = exp.Id;
		update prodExp;
		
		AV_ProductClient__c prodCliente = AV_TestHelper.createPFCliente();
        prodCliente.AV_ProductoFicha__c = prodExp.Id;
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_TieneOportunidad__c = 'OPORT';
        prodCliente.AV_TenenciaProducto__c = '1';
        prodCliente.AV_Potencialidad__c = 'S';
		update prodCliente;

		Test.startTest();

		AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
		response = AV_ListViewComponentController.getInitData(prodCliente.Id, ALL);
		System.debug('response: ' + response.listRowData);
		String listRowData = 'listRowData';
		AV_ListViewComponentController.RowData[] setModel = response.listRowData;
		System.assertEquals(1, setModel.size());

		Test.stopTest();
	}

	@isTest
	public static void testgetInitData() {
		Account acc = AV_TestHelper.createCustomer();

		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);

		Task tarea  = AV_TestHelper.createTarea(null);
		String idCabeceraTarea = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
		AV_CustomActivityOpportunity__c tareaOpp= AV_TestHelper.createTareaOportunidad(opp, idCabeceraTarea);

		Test.startTest();		

		AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
		response = AV_ListViewComponentController.getInitData(tarea.Id, VIGENTE);
		//System.debug('response: ' + response.listRowData);
		String listRowData = 'listRowData';
		AV_ListViewComponentController.RowData[] setModel = response.listRowData;
		System.assertEquals(1, setModel.size());

		Test.stopTest();
	}
    
    @isTest
	public static void testgetInitDataMapProducts() {
		Account acc = AV_TestHelper.createCustomer();

		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);
        opp.StageName = CON_VENTA;
		opp.AV_OrigenApp__c = 'AV_SalesforceReport';
		update opp;

		Test.startTest();

		AV_ListViewComponentController.Response response = AV_ListViewComponentController.getInitDataMapProducts(acc.Id, pb.Id); // pb.Id == prodPF.Id?

		Test.stopTest();

		//System.assertEquals(true, !response.listRowData.isEmpty(), 'Empty list');
		//System.assertEquals(true, response.size > 0, 'Empty list');
	}
}