/**********************************************************************************************************************
Name:      AV_XMLParser_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: test prueba subida
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
	1.0				Fix PMD Errors      	Daniel Rodriguez    05/10/2023			Created class by pass commented class


***********************************************************************************************************************/
@isTest
public with sharing class AV_XMLParser_Test {
    
    @isTest
	private static void pruebaTest(){
		AV_TestHelper.activateLogger();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Boolean check;
		System.runAs(userGcf){
            check = AV_XMLParser.prueba('xml');
        }
        System.assertEquals(true, check, 'Success');
    }
}