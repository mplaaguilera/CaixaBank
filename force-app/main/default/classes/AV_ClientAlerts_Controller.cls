/**********************************************************************************************************************
Name:	  AV_ClientAlerts_Controller
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Clase controladora de los componentes "av_Client_Alerts"
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY							                       AUTHOR			DATE			Description
1.0			SF - Integrar API de Avisos de Clientes + Vista              Álvaro López	    29/09/2020		Init version	    
***********************************************************************************************************************/
public with sharing class AV_ClientAlerts_Controller {

    /**
	* Method that call to Client Warnings API and returns the json body response to the component
	*
    * @param numPerson String with the client's numPerson code
    * @param fechaRefresco last data refresh date
	* @param jsonBody last json body response
	* @return String with serialized API response
	*/
    @AuraEnabled(cacheable=true)
    public static String retrieveAlerts(String numPerson, DateTime fechaRefresco, String jsonBody){
        if(numPerson != null){
            // if(jsonBody == null || (fechaRefresco != null && AV_AppUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24)){
            if(fechaRefresco == null || (AV_AppUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24)){
                AV_FichaCliente_Integration.WarningsResponse result = AV_FichaCliente_Integration.getWarnings(numPerson);
                if('200'.equalsIgnoreCase(result.statusCode)){
                    // if(!result.listWarnings.warnings.isEmpty()){
                        return JSON.serialize(result.listWarnings.warnings);
                    // }
                    // else{
                    //     return result.errorMessage;
                    // }
                }else if('204'.equalsIgnoreCase(result.statusCode)){//Este if lo he metido de ultimas
                    return 'EMPTY';
                }
            }else{
                return 'UPDATED';
            }
        }
        return 'ERROR';
    }
}