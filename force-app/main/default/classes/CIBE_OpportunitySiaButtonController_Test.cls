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

***********************************************************************************************************************/

@isTest
public with sharing class CIBE_OpportunitySiaButtonController_Test {


    /***********************************************************************************************************/
    @isTest
	private static void getUrlTest(){
        
        String url = CIBE_OpportunitySiaButtonController.getUrl('5555');
        System.assert(String.isNotBlank(url));
        String url2 = CIBE_OpportunitySiaButtonController.getUrl(null);
    } 
}