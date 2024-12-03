/**********************************************************************************************************************
 Name:	  EV_Utilities_Test
 Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase para test de EV_Utilities
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  Daniel Rodriguez    27/09/2022			Init version

***********************************************************************************************************************/

@isTest
public with sharing class EV_Utilities_Test {

    @isTest
	public static void testGenerateSecureId() {
        String key = '';
        key = EV_Utilities.generateSecureId('dsafdsafdsaewrew');
        system.debug('@key '+ key);
        system.assertEquals(String.isNotBlank(key), key != '');
        
    }
    
    @isTest
	public static void testSetId() {
        set<String> setIds = new set<String>{'000033033303', '24324325345'};
        String listIds = '';
        listIds = EV_Utilities.setToStringIn(setIds);
        system.assertEquals(String.isNotBlank(listIds), listIds != '');
        
    }
    @isTest
	public static void testGenerateRandomString() {
        String codigo = '';
        codigo = EV_Utilities.generateRandomString(4);
        system.assertEquals(String.isNotBlank(codigo), codigo != '');
        
    }
}