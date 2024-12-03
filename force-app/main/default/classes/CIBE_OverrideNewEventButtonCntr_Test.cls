/**********************************************************************************************************************
 Name:	  CIBE_OverrideNewEventButtonCntr_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de CIBE_OverrideNewEventButtonController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0			DE79495				Lucía Muñoz 	    17/10/2023			Init version

***********************************************************************************************************************/
@IsTest
public with sharing class CIBE_OverrideNewEventButtonCntr_Test {

    @TestSetup
    static void setUp(){
        CIBE_TestInitialSetup.setupInitialDataEMP();
    }

    @IsTest
    static void getRoleUser(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today];

        System.runAs(usuario){
            String record = [SELECT Id,DeveloperName, Name  FROM RecordType WHERE SobjectType = 'Event' AND  DeveloperName = 'CIBE_EventodelGestor'].Id;
            String value =  CIBE_OverrideNewEventButtonController.getRoleUser(record);
            System.assertEquals('altaEMP', value);
        }
    }

}