/**********************************************************************************************************************
Name:	  CIBE_TabManagementTask_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC cibe_TaskTabs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US420186    	Jose Maria	  	    20/10/2021		Init version copy retail methods 
	
***********************************************************************************************************************/
public with sharing class CIBE_Path_Opportunity_Controller {

    public static final  String ACCIONCOMERCIALCIB = 'CIBE_AccionComercialCIB';
    public static final  String INICIATIVACIB = 'CIBE_IniciativaEmpleadoCIB';
    public static final  String SUGERENCIACIB = 'CIBE_SugerenciaCIB';
    public static final  String ALERTACOMERCIALCIB = 'CIBE_AlertaComercialCIB';

    /**
     * 
     * @param recordId
     * @return
     * @description Method to verify the record type of the opportunity
    */
    @AuraEnabled
    public static Boolean getRecordTypeVerification(String recordId) { 
        //Verify if the record id is not null
        try {
            //Get the opportunity
            Opportunity currentOpportunity = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id = :recordId];
            //Verify if the record type is one of the record types that have the tabs
            if(currentOpportunity.RecordType.DeveloperName == ACCIONCOMERCIALCIB || currentOpportunity.RecordType.DeveloperName == INICIATIVACIB || currentOpportunity.RecordType.DeveloperName == SUGERENCIACIB || currentOpportunity.RecordType.DeveloperName == ALERTACOMERCIALCIB) {
                //If the record type is one of the record types that have the tabs, return true
                return true;
            } else {
                //If the record type is not one of the record types that have the tabs, return false
                return false;
            }
           
        } catch (Exception e) {

            System.debug('Error getRecordTypeVerification: ' + e);
            return null;
        }

    }

   

}