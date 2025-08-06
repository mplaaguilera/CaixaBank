/**********************************************************************************************************************
Name:	  AV_LinkNotifyMeController_Test
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test class for AV_LinkNotifyMeController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			US190069    	Rubén Izquierdo 	18/03/2021		Init version
    1.1         FIX             Luis Fernández      11/07/2022      Changed AV_Query to SOQL queries   

***********************************************************************************************************************/
@isTest
public with sharing class AV_LinkNotifyMeController_Test {

    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
        String params = EncodingUtil.base64Encode(Blob.valueOf('idCliente=13350&nombre=VICTOR SAULER&nif=59595959D'));
    
        AV_NotifyMe__c notifyMe = new AV_NotifyMe__c(
            AV_PEAURL__c = 'CA.OFI.MuroConMiGestorMensajes.muro',
            AV_PEAParams__c = params
        );
        insert notifyMe;
    }


    @isTest
    public static void validateLinkNotifyMe(){
        Test.startTest();
        // AV_NotifyMe__c selectNotifyMe = (AV_NotifyMe__c) new AV_Query('AV_NotifyMe__c')
        //                                 .selectFields('Id')
        //                                 .setLimit(1)
        //                                 .fetch();
        AV_NotifyMe__c selectNotifyMe = [SELECT Id FROM AV_NotifyMe__c LIMIT 1];
        String result = AV_LinkNotifyMeController.getLink(selectNotifyMe.Id);
        Test.stopTest();

        System.assertNotEquals(result, 'KO');
    }

}