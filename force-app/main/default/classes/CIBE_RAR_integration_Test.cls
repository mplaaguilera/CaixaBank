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
    1.2                                                             Borja Lavesiera	        03/04/2024      Cambios Refresh Button
***********************************************************************************************************************/

@isTest
public with sharing class CIBE_RAR_integration_Test {
    @TestSetup
    static void makeData(){
        User adminCIBE = CIBE_TestHelper.createUserSinInsert('System Administrator');
        Test.startTest();   
        user cIBUser;
        System.runAs(adminCIBE) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', CIBE_AppConstants.CIBE_ROLECIB, 'cibeTest1234', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics','CIBE_Integracion'});
        }  
        Test.stopTest();                                                                                       
        Account acc;
		Opportunity opp;
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
            opp.AV_IncludeInPrioritizingCustomers__c = true;
            opp.AV_FechaProximoRecordatorio__c = system.today();
            opp.AV_PF__c = prodPF.Id;
        	insert opp;
        }       
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
		System.debug('FINAL' +Limits.getcputime());

    }

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
    private static void testGetSimulationRefEmpresa() {
		CIBE_RAR_Integration.SimulationResponse simulationResponse = new CIBE_RAR_Integration.SimulationResponse();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RAR','OK'));
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        
        Test.StartTest();
            System.runAs(usrTest) {      
                simulationResponse = CIBE_RAR_Integration.getSimulation('123456','CIBE_GetRARSimulation',opp.Id);
            }
        Test.StopTest();

        system.assert(simulationResponse.empresaResponse != null, 'no ha devuelto objeto de integración rar con empresas');
    }
    @isTest
    private static void testGetSimulationRefEmpresaJsonFilled() {
		CIBE_RAR_Integration.SimulationResponse simulationResponse = new CIBE_RAR_Integration.SimulationResponse();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RAR','OK'));
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        opp.CIBE_JSONRAROperations__c = CIBE_MockCallout_Test.RESPONSE_RAR;
        opp.CIBE_Numero_de_Simulador__c = 123456;
        opp.CIBE_Tipo_de_simulacion__c = 'Empresa';
        update opp;
        Test.StartTest();
            System.runAs(usrTest) {     
                simulationResponse = CIBE_RAR_Integration.getSimulation('123456','CIBE_GetRARSimulation',opp.Id);
            }
        Test.StopTest();

        system.assert(simulationResponse.empresaResponse != null, 'no ha devuelto objeto de integración rar con empresas');
    }
    @isTest
    private static void testGetSimulationRefGrupo() {

        CIBE_RAR_Integration.SimulationResponse simulationResponse = new CIBE_RAR_Integration.SimulationResponse();
		Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RARGrupo','OK'));
		Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.StartTest();
            System.runAs(usrTest) {
                simulationResponse = CIBE_RAR_Integration.getSimulation('123456','CIBE_getRARSimuGroup',opp.Id);
            }
        Test.StopTest();

        system.assert(SimulationResponse.grupoResponse != null, 'no ha devuelto objeto de integración rar con grupos');
    }/*
    @isTest
    private static void testGetSimulationRefGrupoJsonFilled() {
		CIBE_RAR_Integration.SimulationResponse simulationResponse = new CIBE_RAR_Integration.SimulationResponse();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RARGrupo','OK'));
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        opp.CIBE_JSONRAROperations__c = CIBE_MockCallout_Test.RESPONSE_RAR_GRUPO;
        opp.CIBE_Numero_de_Simulador__c = 123456;
        opp.CIBE_Tipo_de_simulacion__c = 'Grupo';
        update opp;
        Test.StartTest();
            System.runAs(usrTest) {     
                simulationResponse = CIBE_RAR_Integration.getSimulation('123456','CIBE_getRARSimuGroup',opp.Id);
            }
        Test.StopTest();

        system.assert(simulationResponse.grupoResponse != null, 'no ha devuelto objeto de integración rar con empresas');
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
    private static void testGetURLSimulEmpresa() {
        String simulationId = '37582';
        string simulationType = 'Empresa';

        Test.StartTest();
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        string getURL;
            System.runAs(usrTest) {
                getURL= CIBE_RAR_Integration.getUrl(simulationId,simulationType);
            }
        Test.StopTest();

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
    private static void testGetUrlGrupo() {
        String simulationId = '37582';
        string simulationType = 'Grupo';

        Test.StartTest();
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        string getURL;
            System.runAs(usrTest) {
                getURL= CIBE_RAR_Integration.getUrl(simulationId,simulationType);  
            }
        Test.StopTest();

        system.assert(getURL != '', 'no ha devuelto url de grupo');
    }
     @isTest
    private static void testSaveOperation(){
		CIBE_RAR_Integration.SimulationResponse simulationResponse = new CIBE_RAR_Integration.SimulationResponse();
        CIBE_RAR_Integration.RARresponse simulation = new CIBE_RAR_Integration.RARresponse();

        Test.StartTest();
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RAR','OK'));
        simulationResponse = CIBE_RAR_Integration.getSimulation('123456','CIBE_GetRARSimulation',opp.Id);
        
            System.runAs(usrTest) {    		
                CIBE_RAR_Integration.saveOperation(JSON.serialize(simulationResponse.empresaResponse), opp.id);
            }
        Opportunity oppres = [SELECT ID, CIBE_RAROperationNumber__c FROM Opportunity LIMIT 1];
        Test.StopTest();
        
        system.assertEquals(oppres.CIBE_RAROperationNumber__c, simulationResponse.empresaResponse.operations[0].operationNumber, 'No coinciden los operation Number');
    }
    @isTest
    private static void testSaveOperationKO(){
        boolean error = false;

        Test.StartTest();
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            System.runAs(usrTest) {
                try{
                    CIBE_RAR_Integration.saveOperation('{}\n}', usrTest.id);
                }catch(Exception e){
                    error = true;
                }
            }
        Test.StopTest();

        system.assert(error, 'debería haber saltado la excepción');
    }
    @isTest
    private static void testGetSimulationKO(){

        boolean error = false;
        Test.StartTest();
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
            System.runAs(usrTest) {
                try{
                    Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RAR','NOT OK'));
                CIBE_RAR_Integration.getSimulation('123456','CIBE_GetRARSimulation',opp.id);
                }catch(Exception e){
                    error = true;
                }
            }
        Test.StopTest();

        system.assert(error, 'debería haber saltado la excepción');
    }
    @isTest
    private static void testGetSimulationId(){

        boolean error = false;
        Test.StartTest();
		Opportunity oppTest = [SELECT Id FROM Opportunity WHERE name = 'Test Alerta Comercial 1'];
        User usrTest = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            System.runAs(usrTest) {
                try {
                Opportunity resultOpp = CIBE_RAR_Integration.getSimulationId(oppTest.Id);
                System.assertEquals(null, resultOpp.CIBE_Numero_de_Simulador__c);
                } catch (AuraHandledException e) {
                    error = true;
                }
           }
        Test.StopTest();
        System.assertEquals(false, error, 'No se debería haber lanzado una excepción');

    }
}