/**********************************************************************************************************************
Name:	  CIBE_DeleteHierarchy
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del componenente cibe_picklistJerarquiaContact_CIB
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	    AUTHOR		   	    DATE				Description
	1.0			DE80364	        Lucía Muñoz		    22/08/2023			Init version

***********************************************************************************************************************/

public without sharing class CIBE_DeleteHierarchy {


    @AuraEnabled
    public static List<CIBE_Hierarchy__c> deleteHierarchy(List<CIBE_Hierarchy__c> deleteList) {

        if(!deleteList.isEmpty()){
            Database.delete(deleteList, false);
        }

        return deleteList;
    }
}