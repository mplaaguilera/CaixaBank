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
        
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        RecordType rtCenter = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account centroCaixa = new Account();
        centroCaixa.Name = 'Prueba Test';
        centroCaixa.CC_Numero_Oficina__c = '02615';
        centroCaixa.RecordTypeId = rtCenter.Id;
        centroCaixa.CC_Numero_Oficina_Empresa__c = '001-02615';
        centroCaixa.CC_Numero_Empresa__c = '001';
        centroCaixa.OwnerId = usrTest.id;
        insert centroCaixa;
        Account acc = new Account(
            Name = 'NameTest',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '123456',
            AV_Negocio__c = 'BPA',
            CC_Numero_Documento__c = 'P0301400H',
            CC_TipoDocumento__c = 'NIF',
            AV_OficinaPrincipal__c = centroCaixa.Id,
            OwnerId = usrTest.Id
        );
        insert acc;
        
        //Without Document and CIBE_FechaRefrescoEEFF__c
        Account acc2 = new Account(
            Name = 'NameTest',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '654321',
            AV_Negocio__c = 'BPA',
            CC_Numero_Documento__c = '',
            CC_TipoDocumento__c = 'NIF',
            AV_OficinaPrincipal__c = centroCaixa.Id,
            OwnerId = usrTest.Id,
            CIBE_FechaRefrescoEEFF__c = null
        );
        insert acc2;
        
        CBK_IntegrationSetting__c endpointConfReq = new CBK_IntegrationSetting__c(Name='CIBE_getEeFF', NamedCredential__c = 'CIBE_getEeFF');
        insert endpointConfReq;
        CBK_IntegrationSetting__c endpointConfDet = new CBK_IntegrationSetting__c(Name='CIBE_getEeFF_Details', NamedCredential__c = 'CIBE_getEeFF_Details');
        insert endpointConfDet;
        test.setCreatedDate(endpointConfDet.id, dateTime.newInstance(2023, 5, 1));
        update endpointConfDet;

    }

    @isTest
    private static void CustomerWithoutDoc(){

        User usrTest = [SELECT ID FROM USER LIMIT 1];
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

        User usrTest = [SELECT ID FROM USER LIMIT 1];
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
            system.assertEquals(true, bError);
        }
    }

    @isTest
    private static void KOResponse(){

        User usrTest = [SELECT ID FROM USER LIMIT 1];
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
            system.assertEquals(true, bError);
        }

    }

    @isTest
    private static void responseOk(){

        User usrTest = [SELECT ID FROM USER LIMIT 1];
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