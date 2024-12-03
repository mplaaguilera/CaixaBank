/**********************************************************************************************************************
 Name:	  CIBE_OpportunitySiaButtonController
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_OpportunitySiaButton"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
   1.0			Data access		    Ali y Bea	        09/11/2022		    Init version
   2.0          SIA/ENS             Borja Lavesiera     10/06/2024          Update PEA SIA and improve Test Class
***********************************************************************************************************************/

@IsTest
private class CIBE_OpportunitySiaButtonController_Test {

    @TestSetup
    static void setup() {
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
    }

    @IsTest
    static void testGetUrlEns() {
        User usrTest = [SELECT ID FROM USER LIMIT 1];
        System.runAs(usrTest) {
            String numberExpedient = '999912345678';
            Test.startTest();
            String url = CIBE_OpportunitySiaButtonController.getUrl(numberExpedient);
            Test.stopTest();
            System.assertEquals('https://l.tf7.lacaixa.es/CA.OFI/ContrataActivoConSol/resumenSolicitud.tf7?_flowId=resumenSolicitud-flow&tid=ResumenAdmisionActivo&origen=salesforce&idPeticion=999912345678', url);
        }
    }

    @IsTest
    static void testGetUrlSia() {
        User usrTest = [SELECT ID FROM USER LIMIT 1];
        System.runAs(usrTest) {
            String numberExpedient = '123456 789012';
            Test.startTest();
            String url = CIBE_OpportunitySiaButtonController.getUrl(numberExpedient);
            Test.stopTest();
            System.assertEquals('https://l.tf7.lacaixa.es/CA.OFI/ContrataActivoConSol/resumenSolicitud.tf7?_flowId=resumenSolicitud-flow&_tabGroupId=ResumenSolicitud&tid=ResumenAdmisionActivo&origen=salesforce&_tabIndex=0&menuSolicitudOffice=1234&menuSolicitudContract=789012&_subtabIndex=0&menuSolicitudModality=56&_propagateAuth=true', url);
        }
    }

    @IsTest
    static void testGetUrlInvalid() {
        User usrTest = [SELECT ID FROM USER LIMIT 1];
            System.runAs(usrTest) {
            String numberExpedient = '';
            Test.startTest();
            String url = CIBE_OpportunitySiaButtonController.getUrl(numberExpedient);
            Test.stopTest();
            System.assertEquals(null, url);
        }
    }
}