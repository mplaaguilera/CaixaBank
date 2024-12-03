/**********************************************************************************************************************
Name:	  CIBE_RAR_Integration_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: clase test de CIBE_RAR_Integration
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR                  DATE            COMMENTS
    1.0                                                             David Ramos             20/09/2023      Created
	1.1															    Alexandre Perez			22/09/2023
***********************************************************************************************************************/

@isTest
public with sharing class CIBE_RAR_integration_Test {
    @TestSetup
    static void makeData(){

        /*RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        user cIBUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
           cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '1234', new List<String>{'CIBE_OperativaCIB', 'CIBE_OperativaEMP', 'CIBE_Integracion'});
        }

        RecordType rtCenter = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account centroCaixa = new Account();
        centroCaixa.Name = 'Prueba Test';
        centroCaixa.CC_Numero_Oficina__c = '02615';
        centroCaixa.RecordTypeId = rtCenter.Id;
        centroCaixa.CC_Numero_Oficina_Empresa__c = '001-02615';
        centroCaixa.CC_Numero_Empresa__c = '001';
        centroCaixa.OwnerId = cIBUser.id;
        insert centroCaixa;
        Account acc = new Account(
            Name = 'NameTest',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '123456',
            AV_Negocio__c = 'BPA',
            CC_Numero_Documento__c = '9446386T',
            AV_OficinaPrincipal__c = centroCaixa.Id,
            OwnerId = cIBUser.Id
        );
        insert acc;
        System.runAs(cIBUser) {
            CIBE_TestHelper.createCustomer();
        }
        CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(Name='CIBE_getCirbe', NamedCredential__c = 'CIBE_getCirbe');
        insert endpointConf;*/
        user cIBUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', CIBE_AppConstants.CIBE_ROLECIB, 'cibeTest1234', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }
        //Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001' AND ownerId =: u.id]; 

       /* user user = [SELECT Id, CIBE_RoleName__c FROM User WHERE Id = :cIBUser.Id LIMIT 1];
		List<String> listaTipoCartera;
		if (user.CIBE_RoleName__c == 'CIB' ){
			string carteraCIB = CIBE_Cartera__mdt.getInstance('CIBE_CarteraCIB').TipoCartera__c;
			listaTipoCartera = carteraCIB.split(',');
		}else if (user.CIBE_RoleName__c == 'EMP' || user.CIBE_RoleName__c == 'CIBE_CIBEmpresas') {
			string carteraEMP = CIBE_Cartera__mdt.getInstance('CIBE_CarteraEMP').CIBE_TestHelperTipoCartera__c;
			listaTipoCartera = carteraEMP.split(',');
		}
        system.debug(listaTipoCartera);*/
        Account center = CIBE_TestHelper.createCaixaCenter();
        
        Account acc;
		 Opportunity opp;
         contact empleado = CIBE_TestHelper.createEmployee(center, cIBUser);        
        System.runAs(cIBUser){
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            acc = CIBE_TestHelper.createCustomerWithNumperson('123456');
            RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        	opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'Test Alerta Comercial 1';
            opp.StageName = 'Potencial';
            opp.RecordTypeId = rtOpp.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.OwnerId = cIBUser.Id;
            //opp.AV_Gestor__c = empleado.Id;
            opp.AV_IncludeInPrioritizingCustomers__c = true;
            opp.AV_FechaProximoRecordatorio__c = system.today();
            opp.AV_PF__c = prodPF.Id;
        	insert opp;
        }
        opp.AV_Gestor__c = empleado.Id;
        update opp;
		//opp        
        list<CBK_IntegrationSetting__c> listSettings = new list<CBK_IntegrationSetting__c>();
        CBK_IntegrationSetting__c setting1 = new CBK_IntegrationSetting__c(Name='CIBE_GetRARSimulation', NamedCredential__c = 'CIBE_GetRARSimulation');
        CBK_IntegrationSetting__c setting2 = new CBK_IntegrationSetting__c(Name='CIBE_getRARSimuGroup', NamedCredential__c = 'CIBE_getRARSimuGroup');
        listSettings.add(setting1);
        listSettings.add(setting2);
        insert listSettings;
        CIBE_PD__c metadata = new CIBE_PD__c();
        metadata.CIBE_PDRating__c = 'AAA';
        metadata.CIBE_FechaCarga__c = date.today();
        metadata.CIBE_PDMin__c = 0;
        metadata.CIBE_PDMax__c = 100;
       	insert metadata;
    }

   /* public static Account createCenter(){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        Account centro = new Account();
        centro.Name = 'AAAAAAAAAAAAAAAAAAAAAA';
        centro.CC_Numero_Oficina_Empresa__c = '';
        centro.CC_Numero_Oficina__c = '0000000000000';
        centro.RecordTypeId = rt.Id;
        centro.CIBE_Negocios__c = '0000000000000';
        centro.CIBE_RedesSegmentos__c = '0000000000000';
        centro.CIBE_CentrosCarteras__c = '0000000000000';
        centro.CIBE_SectoresPaises__c = '0000000000000';
        insert centro;
        return centro;
    }*/

/*****************************************************************
    * Proposito:  Generación de una Account con una Opportunity que tenga los datos de Simulation
    introducidos como parametros.
    Parameters: [simulationId, operationNumber, simulationType]
    Returns: [public static Account]
    Historial
    --------
    VERSION        USER_STORY       AUTHOR                         DATE           Description
    1.0                             David Ramos                    20/09/2023     Created
*****************************************************************/
   /* public static Opportunity createSimulation(String simulationId,
                                            string operationNumber,
                                            string simulationType,
                                            User owner) {
        // Integer numAccount = 1;
        // Integer numOpportunity = 1;
        // Account acct = new Account(Name='TestAccount' + numAccount);
        // insert acct;
        System.debug('++++++++++++++ start createSimulation');
        Integer valueSimulationId = Integer.valueOf(simulationId);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        
        System.debug('++++++++++++++ start createCustomerWithNumperson');
        Account acc = CIBE_TestHelper.createCustomerWithNumperson('9999999');
        System.debug('++++++++++++++ start createCaixaCenter');
        Account center = createCenter();
        // Account center = CIBE_TestHelper.createCaixaCenter();
        System.debug('++++++++++++++ start createEmployee');
        contact empleado = CIBE_TestHelper.createEmployee(center, owner);
        System.debug('++++++++++++++ start createOpportunityWithEmpleado');
        Opportunity opp = CIBE_TestHelper.createOpportunityWithEmpleado(acc, empleado);
        opp.CIBE_Numero_de_Simulador__c = valueSimulationId; 
        opp.CIBE_RAROperationNumber__c = operationNumber; 
        opp.CIBE_Tipo_de_simulacion__c = simulationType;
        
        // Opportunity opp = new Opportunity(Name=acct.Name + ' Opportunity ' + numOpportunity,
        //                                StageName='Prospecting',
        //                                CloseDate=System.today().addMonths(1),
        //                                RecordType = rt,
        //                                AccountId=acct.Id,
        //                                CIBE_Numero_de_Simulador__c = valueSimulationId,
        //                                CIBE_RAROperationNumber__c = operationNumber,
        //                                CIBE_Tipo_de_simulacion__c = simulationType,
        //                                OwnerId = owner.Id);

        // Insert opportuninty with simulation
        insert opp;
        System.debug('++++++++++++++'+[SELECT Id FROM Opportunity]);
        return opp;
    }*/

/*****************************************************************
* Proposito:  Generación de una List<RARResponse> para hacer tests en updateRatingPD.
En updateRatingPD solo se usa RARResponse.pd para hacer comparaciones.
el resto de parametros tendra valores por defecto porque no los usa.
Parameters: [listPD]
Returns: [public static List<RARResponse>]
Historial
--------
VERSION        USER_STORY       AUTHOR                         DATE           Description
1.0                             David Ramos                    20/09/2023     Created
*****************************************************************/
   /* public static List<CIBE_RAR_Integration.RARResponse> createListNews(List<Decimal> listPD) {
        List<CIBE_RAR_Integration.RARResponse> rARResponses = new List<CIBE_RAR_Integration.RARResponse>();
        Integer numResp = listPD.size();

        //los valores que no se usaran
        CIBE_RAR_Integration.SimulationOperationsProfitabilities sOP = new CIBE_RAR_Integration.SimulationOperationsProfitabilities();
        CIBE_RAR_Integration.CustomerProfitability cP = new CIBE_RAR_Integration.CustomerProfitability();
        decimal lgd = 4;
        list<CIBE_RAR_Integration.Operations> operations = new list<CIBE_RAR_Integration.Operations>();
        CIBE_RAR_Integration.PriceNote priceNote = new CIBE_RAR_Integration.PriceNote();
        string operationNumber = '';
        string customerId = '';
        string customerName = '';
        string ratingInt = '';
        for (Integer i=0;i<numResp;i++) {
            //crear un RARResponse y ponerlo en la lista
            integer simId = i;
            decimal pdi = listPD[i];
            //para probar


            CIBE_RAR_Integration.RARResponse rARRespi = new CIBE_RAR_Integration.RARResponse();
            rARRespi.simulationId = simId;
            rARRespi.simulationOperationsProfitabilities = sOP;
            rARRespi.customerProfitability = cP;
            rARRespi.pd = pdi;
            rARRespi.lgd = lgd;
            rARRespi.operations = operations;
            rARRespi.priceNote = priceNote;
            rARRespi.operationNumber = operationNumber;
            rARRespi.customerId = customerId;
            rARRespi.customerName = customerName;
            rARRespi.ratingInt = ratingInt;
            rARResponses.add(rARRespi);

        }
        return rARResponses;
    }*/



/*****************************************************************
    * Proposito:  Probar getSimulation con refrescar, sin camaleon, tipo empresa
    Parameters: []
    Returns: []
    Historial
    --------
    VERSION        USER_STORY       AUTHOR                         DATE           Description
    1.0                             David Ramos                    20/09/2023     Created
*****************************************************************/

    @isTest
    private static void testGetSimulationRefEmpresa(){

		CIBE_RAR_Integration.SimulationResponse simulationResponse = new CIBE_RAR_Integration.SimulationResponse();
        test.startTest();
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'cibeTest1234'];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        
        
        System.runAs(usrTest) {
            Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RAR','OK'));
        	CIBE_RAR_Integration.getSimulation('123456',
                                                        'CIBE_GetRARSimulation',
                                                        opp.Id);
            simulationResponse = CIBE_RAR_Integration.getSimulation('123456',
                                                        'CIBE_GetRARSimulation',
                                                        opp.Id);
        }
        test.stopTest();
        
        system.assert(simulationResponse.empresaResponse != null, 'no ha devuelto objeto de integración rar con empresas');

    }
    
    @isTest
    private static void testGetSimulationRefGrupo(){

        CIBE_RAR_Integration.SimulationResponse simulationResponse = new CIBE_RAR_Integration.SimulationResponse();
        test.startTest();
       	User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'cibeTest1234'];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        
        
        System.runAs(usrTest) {
            Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RARGrupo','OK'));
        	CIBE_RAR_Integration.getSimulation('123456',
                                                        'CIBE_getRARSimuGroup',
                                                        opp.Id);
            simulationResponse = CIBE_RAR_Integration.getSimulation('123456',
                                                        'CIBE_getRARSimuGroup',
                                                        opp.Id);
        }
        test.stopTest();
        
        system.assert(SimulationResponse.grupoResponse != null, 'no ha devuelto objeto de integración rar con grupos');

    }

/*****************************************************************
    * Proposito:  Probar getSimulation con refrescar, sin camaleon, tipo grupo
    Parameters: []
    Returns: []
    Historial
    --------
    VERSION        USER_STORY       AUTHOR                         DATE           Description
    1.0                             David Ramos                    20/09/2023     Created
*****************************************************************/

/*@isTest
private static void testGetSimulationRefGrupo(){

    String simulationId = '37582';
    string operationNumber = '9998020004980';
    string simulationTypeOpp = 'Grupo';

    string simulationType = 'refrescar';

    User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
    CIBE_RAR_Integration.SimulationResponse result;

    Integer realId;
    Integer resultId;

    System.runAs(usrTest) {

        // Account accTest = createSimulation(simulationId, operationNumber, simulationTypeOpp);
        // Opportunity opp = accTest.Opportunities[0];
        
        Integer valueSimulationId = Integer.valueOf(simulationId);
        Opportunity opp = createSimulation(simulationId, operationNumber, simulationTypeOpp, usrTest);
        opp.CIBE_Numero_de_Simulador__c = valueSimulationId; 
        opp.CIBE_RAROperationNumber__c = operationNumber; 
        opp.CIBE_Tipo_de_simulacion__c = simulationTypeOpp;

        realId = Integer.valueOf(opp.CIBE_Numero_de_Simulador__c);

        Test.StartTest();
        result = CIBE_RAR_Integration.getSimulation(String.valueOf(opp.CIBE_Numero_de_Simulador__c),
                                                    simulationType,
                                                    opp.Id);
        Test.StopTest();
    }


    resultId = result.grupoResponse.simulationId;
    //copiar la URL real de la simualcion en realURL

    system.assertEquals(realId, resultId,'Same simulation ID');

}*/

/*****************************************************************
    * Proposito:  Probar que getURL funciona en el caso de Simulation tipo Empresa
    Parameters: []
    Returns: []
    Historial
    --------
    VERSION        USER_STORY       AUTHOR                         DATE           Description
    1.0                             David Ramos                    20/09/2023     Created
*****************************************************************/
    @isTest
    private static void testGetURLSimulEmpresa(){

        String simulationId = '37582';
        string simulationType = 'Empresa';
        Test.StartTest();
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'cibeTest1234'];
        string getURL;
     
        System.runAs(usrTest) {
			
            // account accTest = createSimulation(simulationId, operationNumber, simulationType);

            //Opportunity opp = createSimulation(simulationId, operationNumber, simulationType, usrTest);
	

            
            getURL= CIBE_RAR_Integration.getUrl(simulationId,simulationType);
            
        }
        Test.StopTest();
        //String realURL = 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.CalculadoraRARGestionSimCliente.consultaSimulacionCliente&origen=salesforce&_vmcNewTab=true&params=idsimcliente%3D37582';
        //copiar la URL real de la simualcion en realURL

        system.assert(getURL != '', 'no ha devuelto url de empresa');

    }

/*****************************************************************
    * Proposito:  Probar que getURL funciona en el caso de Simulation tipo Grupo
    Parameters: []
    Returns: []
    Historial
    --------
    VERSION        USER_STORY       AUTHOR                         DATE           Description
    1.0                             David Ramos                    20/09/2023     Created
*****************************************************************/
    @isTest
    private static void testGetUrlGrupo(){

        String simulationId = '37582';
        string simulationType = 'Grupo';

        Test.StartTest();
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'cibeTest1234'];
        string getURL;
        
        System.runAs(usrTest) {

            // account accTest = createSimulation(simulationId, operationNumber, simulationType);
            //Opportunity opp = createSimulation(simulationId, operationNumber, simulationType, usrTest);

            
            getURL= CIBE_RAR_Integration.getUrl(simulationId,simulationType);
            
        }
        Test.StopTest();
        //String realURL = 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.CalculadoraRARGestionSimGrupo.resumenSimulacionGrupo&origen=salesforce&_vmcNewTab=true&params=idsimgrupo%3D37582';
        //copiar la URL real de la simualcion en realURL

        system.assert(getURL != '', 'no ha devuelto url de grupo');

    }
    
    
     @isTest
    private static void testSaveOperation(){

        
		CIBE_RAR_Integration.SimulationResponse simulationResponse = new CIBE_RAR_Integration.SimulationResponse();
        CIBE_RAR_Integration.RARresponse simulation = new CIBE_RAR_Integration.RARresponse();
        test.startTest();
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'cibeTest1234'];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RAR','OK'));
        simulationResponse = CIBE_RAR_Integration.getSimulation('123456',
                                                                'CIBE_GetRARSimulation',
                                                                opp.Id);
        
        System.runAs(usrTest) {
    		
            CIBE_RAR_Integration.saveOperation(JSON.serialize(simulationResponse.empresaResponse), opp.id);
            
        }
        Opportunity oppres = [SELECT ID, CIBE_RAROperationNumber__c FROM Opportunity LIMIT 1];
        test.stopTest();
        
        system.assertEquals(oppres.CIBE_RAROperationNumber__c, simulationResponse.empresaResponse.operations[0].operationNumber, 'No coinciden los operation Number');

    }
    
    //forzar el error
    @isTest
    private static void testSaveOperationKO(){

        boolean error = false;
        test.startTest();
		User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'cibeTest1234'];
        
        System.runAs(usrTest) {
            try{
                CIBE_RAR_Integration.saveOperation('{}\n}', usrTest.id);
            }catch(Exception e){
                error = true;
            }
            
            
        }
     
        test.stopTest();
        
        system.assert(error, 'debería haber saltado la excepción');

    }
    
     //forzar el error
    @isTest
    private static void testGetSimulationKO(){

        boolean error = false;
        test.startTest();
		User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'cibeTest1234'];
        
        System.runAs(usrTest) {
            try{
                 Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RARGrupo','OK'));
        	CIBE_RAR_Integration.getSimulation('123456',
                                                        'CIBE_getRARSimuGroup',
                                                        usrTest.id);
            }catch(Exception e){
                error = true;
            }
            
            
        }
     
        test.stopTest();
        
        system.assert(error, 'debería haber saltado la excepción');

    }

/*****************************************************************
    * Proposito:  Probar que getURL captura una excepcion correctamente
    Parameters: []
    Returns: []
    Historial
    --------
    VERSION        USER_STORY       AUTHOR                         DATE           Description
    1.0                             David Ramos                    20/09/2023     Created
*****************************************************************/
    // @isTest
    // private static void testGetURLException(){

    //     String simulationId = '';
    //     string operationNumber = '';
    //     string simulationType = 'Grupo';

    //     User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
    //     string getURL;

    //     System.runAs(usrTest) {

    //         // account accTest = createSimulation(simulationId, operationNumber, simulationType);
    //         Opportunity opp = createSimulation(simulationId, operationNumber, simulationType);

    //         Test.StartTest();
    //         getURL= CIBE_RAR_Integration.getUrl(simulationId,simulationType);
    //         Test.StopTest();
    //     }

    //     CIBE_Link__mdt resultadoCMDT = CIBE_Link__mdt.getInstance('CIBE_RARGrupo');
    //     String urlVacia = resultadoCMDT.CIBE_URL__c;

    //     system.assertEquals(urlVacia, getURL,'Same URL');
    // }


/*****************************************************************
    * Proposito:  Probar UpdateRatingPD
    Parameters: []
    Returns: []
    Historial
    --------
    VERSION        USER_STORY       AUTHOR                         DATE           Description
    1.0                             David Ramos                    20/09/2023     Created
*****************************************************************/
    // @isTest
    // private static void testUpdateRatingPD(){

    //     List<Decimal> listPD = new List<Decimal>{4, 5, 6};
    //     List<RARResponse> RARResp = createListNews(listPD);


    //     User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];

    //     System.runAs(usrTest) {

    //         Test.StartTest();
    //         CIBE_RAR_Integration.updateRatingPD(RARResp);
    //         Test.StopTest();
    //     }


    //     // system.assertEquals(realURL, getURL);

    // }

}


//Tests:
//      getSimulation: en 184 - 292   if=true
//          if(opp.CIBE_JSONRAROperations__c == null || simulationType == 'refrescar' ||
//          string.valueOf(opp.CIBE_Numero_de_Simulador__c) != simulationId /*|| opp.CIBE_Tipo_de_simulacion__c != simulationType*/)

//      getSimulation: en 187 - 193   if=true
//          if(simulationType == 'refrescar')

//      getSimulation: en 188 - 190   if=true
//          if(opp.CIBE_Tipo_de_simulacion__c == 'Empresa'){

//      getSimulation: en 188   if=false
//          if(opp.CIBE_Tipo_de_simulacion__c != 'Empresa'){
//      190 - 192      else

//      getSimulation: en 196 - 198   if=true
//          if(wsc?.NamedCredential__c.contains('CAMALEON'))

//      getSimulation: en 200 - 202   if=true
//          if(simulationType == 'CIBE_GetRARSimulation')

//      getSimulation: en 200   if=false
//          if(simulationType != 'CIBE_GetRARSimulation')
//      202 - 204     else

//      getSimulation: en 218 - 284   if=true
//          if(res.getStatusCode() == 200) {

//      getSimulation: en 218   if=false
//          if(res.getStatusCode() != 200) {
//      284 - 290     else

//      getSimulation: en 223 - 240   if=true
//          if(simulationType == 'CIBE_GetRARSimulation'){

//      getSimulation: en 223   if=false
//          if(simulationType != 'CIBE_GetRARSimulation'){
//      240 - 253     else

//      getSimulation: en 184 - 292   if=false
//          if(opp.CIBE_JSONRAROperations__c == null || simulationType == 'refrescar' ||
//          string.valueOf(opp.CIBE_Numero_de_Simulador__c) != simulationId /*|| opp.CIBE_Tipo_de_simulacion__c != simulationType*/)
//      292 - 305
//          else if(simulationType == 'CIBE_GetRARSimulation') {

//      getSimulation: en 292       else if=false
//          else if(simulationType != 'CIBE_GetRARSimulation') {
//      305 - 330     else

//      315 if(operation.operationNumber == opp.CIBE_RAROperationNumber__c){

//      320 if(simulationResponse.grupoResponse.operationNumber != null){


    //Test: getSimulation catch Exception
    //lineas 333 - 344