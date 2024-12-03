/**********************************************************************************************************************
Name:	  CIBE_EEFFIntegrationService_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: clase test del CIBE_EEFFIntegrationService_Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR                  DATE            COMMENTS  
    1.0                                                             Borja Lavesiera         15/09/2023     Created
   
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_EEFFIntegrationService_Test {
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
            CC_Numero_Documento__c = 'P0301400H',
            CC_TipoDocumento__c = 'NIF',
            AV_OficinaPrincipal__c = centroCaixa.Id,
            OwnerId = cIBUser.Id
        );
        insert acc;
        //Without Document and CIBE_FechaRefrescoEEFF__c
        Account acc2 = new Account(
            Name = 'NameTest',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '654321',
            AV_Negocio__c = 'BPA',
            CC_Numero_Documento__c = 'P0301400H',
            CC_TipoDocumento__c = 'NIF',
            AV_OficinaPrincipal__c = centroCaixa.Id,
            OwnerId = cIBUser.Id,
            CIBE_FechaRefrescoEEFF__c = dateTime.now() + 12
        );
        insert acc2;
        
        System.runAs(cIBUser) {
            CIBE_TestHelper.createCustomer();
        }
        CBK_IntegrationSetting__c endpointConfReq = new CBK_IntegrationSetting__c(Name='CIBE_getEeFF', NamedCredential__c = 'CIBE_getEeFF');
        insert endpointConfReq;
        CBK_IntegrationSetting__c endpointConfDet = new CBK_IntegrationSetting__c(Name='CIBE_getEeFF_Details', NamedCredential__c = 'CIBE_getEeFF_Details');
        insert endpointConfDet;

    }

    @isTest
    private static void CustomerWithoutDoc(){

        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234']; 
        CIBE_EEFFIntegrationService.ResponseData eventResponse = new CIBE_EEFFIntegrationService.ResponseData();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockMultiCallout_Test('EEFF','request','EEFF_DETAILS','detail', 'OK'));
        boolean bError = false;
        System.runAs(usrTest) {

            account accTest = [SELECT Id, CC_Numero_Documento__c FROM Account WHERE AV_NumPerso__c = '654321'];
            accTest.AV_NumPerso__c = null;
			accTest.CC_Numero_Documento__c = '';
            accTest.CC_TipoDocumento__c = '';
            accTest.CIBE_FechaRefrescoEEFF__c = null;
            try {
                Test.StartTest();
                eventResponse= CIBE_EEFFIntegrationService.getCirbeEEFFdata(accTest.Id);
                Test.StopTest();
            } catch (Exception e) {
                bError = true;
            }
            system.assertEquals(true, bError);
        }
    }
    
     @isTest
    private static void CustomerFechaCirbe(){

        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = '1234']; 
        CIBE_EEFFIntegrationService.ResponseData eventResponse = new CIBE_EEFFIntegrationService.ResponseData();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockMultiCallout_Test('EEFF','request','EEFF_DETAILS','detail', 'OK'));
        boolean bError = false;
        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '654321'];

            try {
                Test.StartTest();
                eventResponse= CIBE_EEFFIntegrationService.getCirbeEEFFdata(accTest.Id);
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
        CIBE_EEFFIntegrationService.ResponseData eventResponse = new CIBE_EEFFIntegrationService.ResponseData();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockMultiCallout_Test('EEFF','request','EEFF_DETAILS','detail', 'KO'));
        boolean bError = false;
        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123456'];

            try {
                Test.StartTest();
                eventResponse= CIBE_EEFFIntegrationService.getCirbeEEFFdata(accTest.Id);
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
        CIBE_EEFFIntegrationService.ResponseData eventResponse = new CIBE_EEFFIntegrationService.ResponseData();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockMultiCallout_Test('EEFF','request','EEFF_DETAILS','detail', 'OK'));
        boolean bError = false;
        System.runAs(usrTest) {

            account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123456'];

            try {
                Test.StartTest();
                eventResponse= CIBE_EEFFIntegrationService.getCirbeEEFFdata(accTest.Id);
                Test.StopTest();
            } catch (Exception e) {
                bError = true;
            }
            system.assertEquals(false, bError);
        }
    }
}