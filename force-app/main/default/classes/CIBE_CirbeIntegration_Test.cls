/**********************************************************************************************************************
Name:	  CIBE_CirbeIntegration_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: clase test del CIBE_CirbeIntegration
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR                  DATE            COMMENTS  
    1.0                                                             Alexandre Perez          01/08/2023     Created
   
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_CirbeIntegration_Test {
    @TestSetup
    static void makeData(){
       
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
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
        insert endpointConf;

    }

    @isTest
    private static void CustomerWithoutDoc(){

        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234']; 
        CIBE_cirbeIntegration.ResponseData eventResponse = new CIBE_cirbeIntegration.ResponseData();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('CIRBE','OK'));
        boolean bError = false;
        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123'];

            try {
                Test.StartTest();
                eventResponse= CIBE_CirbeIntegration.getCirbeRisk(accTest.Id);
                Test.StopTest();
            } catch (Exception e) {
                bError = true;
            }
            system.assert(bError);
        }
    }

    @isTest
    private static void KOResponse(){

        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        CIBE_cirbeIntegration.ResponseData eventResponse = new CIBE_cirbeIntegration.ResponseData();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('CIRBE','KO'));
        boolean bError = false;
        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123456'];

            try {
                Test.StartTest();
                eventResponse= CIBE_CirbeIntegration.getCirbeRisk(accTest.Id);
                Test.StopTest();
            } catch (Exception e) {
                bError = true;
            }
            system.assert(bError);
        }

    }

    @isTest
    private static void KOJson(){

        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        CIBE_cirbeIntegration.ResponseData eventResponse = new CIBE_cirbeIntegration.ResponseData();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('CIRBE','JsonKO'));
        boolean bError = false;
        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123456'];

            try {
                Test.StartTest();
                eventResponse= CIBE_CirbeIntegration.getCirbeRisk(accTest.Id);
                Test.StopTest();
            } catch (Exception e) {
                bError = true;
            }
            system.assert(bError);
        }
    }

    @isTest
    private static void responseOk(){

        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        CIBE_cirbeIntegration.ResponseData eventResponse = new CIBE_cirbeIntegration.ResponseData();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('CIRBE','OK'));

        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123456'];

            Test.StartTest();
            eventResponse= CIBE_CirbeIntegration.getCirbeRisk(accTest.Id);
            Test.StopTest();
        }

        system.assert(eventResponse.DirectRiskData.dataTableDirectRisk.size() == 10 &&
        eventResponse.IndirectRiskData.DataTableIndirectRisk.size() == 3 &&
        eventResponse.EvolutionDataCLI.EvolutionDataTableDirectRisk.size() == 15);

    }

    @isTest
    private static void getURLVacia(){

        
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        string getURL;

        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123'];

            Test.StartTest();
            getURL= CIBE_CirbeIntegration.getUrl(accTest.Id);
            Test.StopTest();
        }
        system.debug('vacia ' + getURL.split('pea=').get(1));
        system.assertEquals('CA.OFI.RiesgosBEConPersonas.UltimosDatosCli&origen=salesforce&_vmcNewTab=true&params=numPersona%3D{numPersona}%26dni%3D{dni}%26codEmpresa%3D{codEmpresa}',
        getURL.split('pea=').get(1));   

    }

    @isTest
    private static void getURL(){
        
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234'];
        string getURL;

        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123456'];
            
            Test.StartTest();
            getURL= CIBE_CirbeIntegration.getUrl(accTest.Id);
            Test.StopTest();
        }
        system.debug('url ' + getURL);
        system.assertEquals('CA.OFI.RiesgosBEConPersonas.UltimosDatosCli&origen=salesforce&_vmcNewTab=true&params=numPersona%3D123456%26dni%3D9446386T%26codEmpresa%3D001',
        getURL.split('pea=').get(1));

    }
}