/**********************************************************************************************************************
 Name:      CIBE_IntegrationUtilities
 Copyright © 2023  CaixaBank
=======================================================================================================================
Proposito: Clase de métodos útiles para las integraciones
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            Integrations     Jose Maria       26/01/2023          Init version (Copy from retail)
   2.0                             Alexandre Perez  20/07/2023          Adding update object maped
   3.0            Refactoring      Borja Lavesiera  07/05/2024          Refactoring to acomplish with QC Clouds rules
***********************************************************************************************************************/
public with sharing class CIBE_IntegrationUtilities {


    /**
     * @description             Retrieve the metadata of the interface
     * @param apiMetadataName   -> API name of the metadata callout
     * @return                  null if the metadata is not found or metadata found more than 1 element
     */
    public static CC_InterfaceSettings__mdt fetchMetadataInterface(String apiMetadataName){

        List<CC_InterfaceSettings__mdt> listDataC2C = [SELECT 
        Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CC_Activa__c, CC_Body__c, 
        CC_Certificado__c, CC_CharSet__c, CC_ContentType__c, CC_DiasRef__c, CC_EndPoint__c, CC_HttpRequest__c, CC_SoapAction__c,
        CC_TimeOut__c, CC_TipoPeticion__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_TrazaSalida__c, CC_ALF_CliConf__c,
        CC_CliConfiErr__c, CC_ACTION__c, CC_AFFECTEDEMAIL__c, CC_AFFECTEDPHONE__c, CC_CLASS__c, CC_ConvAmbito__c,
        CC_EXTERNALSYSTEM__c, CC_ITD_ITNINCIDENTINCI__c, CC_ITNESCENARIO__c, CC_ITNEVENTO__c, CC_ITNINCTYPE__c, 
        CC_ITNRELEVANTE__c, CC_ITNROL__c, CC_ORGID__c, CC_REPORTEDEMAIL__c, CC_REPORTEDPHONE__c, CC_SITEID__c, 
        CC_WORKLOG_ACTION__c, CC_WORKLOG_LOGTYPE__c, AV_Username__c, AV_Password__c
        FROM CC_InterfaceSettings__mdt 
        WHERE DeveloperName = :apiMetadataName ];
        CC_InterfaceSettings__mdt dataC2C = null;
        if (listDataC2C!=null && !listDataC2C.isEmpty() && listDataC2C.size()==1) {
            dataC2C = listDataC2C.get(0);
        }

        return dataC2C;
    }

    
    /**
     * @description             Update object maped in the integration
     * @param mapObjectFields -> field map to update
     * @param objectName -> object name to update
     * @return string -> string of error; null if there isn't error
     */
    public static String updateObject(map<string, object> mapObjectFields, string objectName) {

        sObject obj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
        // Modify the fields of the Account record using the map of field names and values
        for (String fieldName : mapObjectFields.keySet()) { 
            if(mapObjectFields.get(fieldName) != null){
                System.debug('fieldName: ' + fieldName);
                System.debug('value: ' + mapObjectFields.get(fieldName));
                obj.put(fieldName, mapObjectFields.get(fieldName));
            }
        
        }
    
        // Save the changes to the Account record in the database
        Database.saveResult srList = Database.update(obj, false);
        if (srList.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully updated. ID: ' + srList.getId());
            return null;
        }
        else {
            String errors = '';
            // Operation failed, so get all errors                
            for(Database.Error err : srList.getErrors()) {                
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                errors = errors + err.getStatusCode() + ': ' + err.getMessage() + ' Account fields that affected this error: ' + err.getFields();
            }
            if(!string.isBlank(errors)){
                CBK_Log.error(errors);
            }
            return errors;
        }
	}

    /**
     * @description             Update object maped in the integration that eliminates data when field is null
     * @param mapObjectFields -> field map to update
     * @param objectName -> object name to update
     * @return string -> string of error; null if there isn't error
     */
    public static String updateObjectNull(map<string, object> mapObjectFields, string objectName) {

        sObject obj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
        // Modify the fields of the Account record using the map of field names and values
        for (String fieldName : mapObjectFields.keySet()) { 
            obj.put(fieldName, mapObjectFields.get(fieldName));
        }
        // Save the changes to the Account record in the database
        Database.saveResult srList = Database.update(obj, false);
        if (srList.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully updated. ID: ' + srList.getId());
            return null;
        }
        else {
            String errors = '';
            // Operation failed, so get all errors                
            for(Database.Error err : srList.getErrors()) {             
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                errors = errors + err.getMessage();
            }
            if(!string.isBlank(errors)){
                CBK_Log.error(errors);
            throw new DmlException(errors);
            }
            return errors;
        }
	}
}