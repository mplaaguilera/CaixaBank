/**********************************************************************************************************************
 Name:	  CIBE_OpportunityComitePrecios_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_OpportunityComitePrecios"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
1.0			Data access		    Luis Martínez	        22/12/2022		    Init version

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_OpportunityComitePrecios_Test {
    @isTest
	private static void getUrlTest(){
        String url = CIBE_OpportunityComitePrecios.getUrl('SC123');
        System.assert(String.isNotBlank(url));
    }  
}