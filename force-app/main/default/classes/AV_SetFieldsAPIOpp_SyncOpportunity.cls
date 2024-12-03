/**********************************************************************************************************************
 Name:	  AV_SetFieldsAPIOpp_SyncOpportunity
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Sync the opp data with GCF
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US117506 		Eric Vázquez        22/10/2020			Init version
    1.1			US117506 		David Rufo          29/10/2020			Update class with fix problems
    1.2			US117506 		Álvaro López        13/11/2020			Update client in order to refresh the product map
	1.3			FIX 			David Rufo          29/10/2020			Update class with fix problems
    1.4			AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account
    1.5         US592987		Ángel Medina		30/05/2023		    Changed AV_Query to SOQL queries
    1.6         US662921	    Sandra Gómez		19/09/2023          add condition startsWith

***********************************************************************************************************************/
public with sharing class AV_SetFieldsAPIOpp_SyncOpportunity {

    public class DataRequest {
        public User user;
        public Opportunity oppSF;
        public AV_AsesorVentasOpp_Integration.Opportunity oppGCF;
    }

    public class DataResponse{
        public Id idOpp;
        public String externalIdOpp;
        public String statusCode;
        public String errorMessage;
    }

    /**
     * @description         Send the update data to GCF (insert when the AV_ExternalID__c is empty)
     * @param jsonString    list the data of the opportunities that need to be insert in GCF
     */
    @Future(callout=true)
    public static void sendToGCF(String jsonString){
        String methodName = 'sendToGCF';
        List<DataResponse> listResponses = new List<DataResponse>();
        List<Opportunity> listNewOpportunity = (List<Opportunity>)Json.deserialize(jsonString,List<Opportunity>.class);
        List<DataRequest> listDataRequests = fillData(jsonString);

        //Send all the opp's to GCF
        for (DataRequest dataReq : listDataRequests){
            DataResponse dataRes = null;
            if (String.isBlank(dataReq.oppSF.AV_ExternalId__c) || dataReq.oppSF.AV_ExternalId__c.startsWith('Opp-')){
                dataRes = sendNewGCF(dataReq);
            }else{
                dataRes = sendUpdateGCF(dataReq);
            }
            if (dataRes!=null){
                listResponses.add(dataRes);
            }
        }

        //Save the responses in DB
        insertIntegrationResponses(listResponses);
    }

    /**
     * @description         Create new opportunity in GCF
     * @param dataReq       request content
     * @return              Response of the API
     */
    @TestVisible
    private static DataResponse sendNewGCF(DataRequest dataReq){
        String methodName = 'sendNewGCF';
        DataResponse dataRes = new DataResponse();
        AV_AsesorVentasOpp_Integration.AltaOppResponse response = null;
        try {
            AV_LogDebug.printLogDebug(methodName, 'Data request: ' + dataReq);
            response = AV_AsesorVentasOpp_Integration.altaOportunidad(dataReq.oppGCF, dataReq.oppSF.Account.AV_Numperso__c, dataReq.user.AV_ExternalId__c);
        }catch (Exception e){
            AV_LogDebug.printException(methodName, e);
        } finally {
            dataRes.idOpp = dataReq.oppSF.Id;
            dataRes.statusCode = '500';
            if (response!=null){
                dataRes.statusCode = response.StatusCode;
                if (!'201'.equalsIgnoreCase(response.StatusCode)){
                    dataRes.errorMessage = response.errorCode + ' - ' + response.errorMessage;
                }else{
                    dataRes.externalIdOpp = response.responseGCF.opportunityId;
                    dataRes.errorMessage = null;
                }
            }
        }
        
        return dataRes;
    }

    /**
     * @description         Update the opportunity in GCF
     * @param dataReq       request content
     * @return              Response of the API
     */
    @TestVisible
    private static DataResponse sendUpdateGCF(DataRequest dataReq){
        String methodName = 'sendUpdateGCF';
        DataResponse dataRes = new DataResponse();
        AV_AsesorVentasOpp_Integration.ModOppResponse response = null;
        try {
            AV_LogDebug.printLogDebug(methodName, 'Data request: ' + dataReq);
            response = AV_AsesorVentasOpp_Integration.modOportunidad(dataReq.oppGCF, dataReq.oppSF.Account.AV_Numperso__c, dataReq.user.AV_ExternalId__c, dataReq.oppSF.AV_ExternalId__c);
        }catch (Exception e){
            AV_LogDebug.printException(methodName, e);
        } finally {
            dataRes.idOpp = dataReq.oppSF.Id;
            dataRes.statusCode = '500';
            if (response!=null){
                dataRes.statusCode = response.StatusCode;
                if (!'200'.equalsIgnoreCase(response.StatusCode)){
                    dataRes.errorMessage = response.errorCode + ' - ' + response.errorMessage;
                }else{
                    dataRes.errorMessage = null;
                }
            }
        }
        return dataRes;
    }

    /**
     * @description     get info of the user logged: field Matricula (AV_ExternalId__c)
     */
    private static User getUser(){
        User user = [Select AV_ExternalId__c From User Where Id = :UserInfo.getUserId() limit 1];
        return user;
    }

    /**
     * @description     Fill the data to send
     * @param oppJsonString List of opportunities
     * @param user          User info
     * @return  map with the mapping where the ID could be ID opportunity for insert and ExternalID for update
     */
    @TestVisible
    private static List<DataRequest> fillData(String oppJsonString){
        String methodName = 'fillData';
        List<DataRequest> listOppToSend = new List<DataRequest>();
        List<Opportunity> opportunityList = (List<Opportunity>)JSON.deserialize(oppJsonString,List<Opportunity>.class);
        Set<String> listIds = new Set<String>();
        for(Opportunity opp : opportunityList) {
            listIds.add(opp.Id);
        }
        User user = getUser();

        List<Opportunity> listModOpp = [SELECT  Id, AV_ExternalID__c, Account.AV_NumPerso__c, AV_PF__c, StageName, 
        AV_PF__r.AV_ExternalId__c, AV_FechaProximoRecordatorio__c, 
        AV_Potencial__c, AV_Tenencia__c, AV_Entidad__c, Amount, 
        CloseDate, AV_Comentarios__c, AV_NoOfrecerHasta__c, AV_Cuota__c FROM Opportunity WHERE Id IN :listIds];
        for(Opportunity opp : listModOpp){
            try {
                AV_AsesorVentasOpp_Integration.Opportunity oppGCF = new AV_AsesorVentasOpp_Integration.Opportunity();
                if (opp.AV_PF__c != null) {
                    oppGCF.opportunityId = Integer.valueOf(opp.AV_PF__r.AV_ExternalId__c);
                }
                if (String.isNotBlank(user.AV_ExternalId__c) && !test.isRunningTest()) {
                    oppGCF.employeeId = Integer.valueOf(user.AV_ExternalId__c.remove('U01'));
                }
                oppGCF.offerUntil = opp.AV_FechaProximoRecordatorio__c;
                //En gestión/insistir 	-> Oportunidad Comercial (S)
                //Cerrado positivo 		-> B
                //No interesado 		-> C
                //No apto 				-> N
                //Con venta 			-> E
                //Vencido				-> F
                if (AV_AppConstants.OPP_STATUS_ENGESTION.equalsIgnoreCase(opp.StageName)){
                	oppGCF.potential = 'S';
                }
                else if (AV_AppConstants.OPP_STATUS_CERRPOST.equalsIgnoreCase(opp.StageName) || AV_AppConstants.OPP_STATUS_PROD_CONTR.equalsIgnoreCase(opp.StageName)){
                	oppGCF.potential = 'B';
                }
                else if (AV_AppConstants.OPP_STATUS_NOINTERE.equalsIgnoreCase(opp.StageName) || AV_AppConstants.OPP_STATUS_PROD_RECH.equalsIgnoreCase(opp.StageName)){
                	oppGCF.potential = 'C';
                }
               
                else if (AV_AppConstants.OPP_STATUS_CONVENTA.equalsIgnoreCase(opp.StageName)){
                	oppGCF.potential = 'E';
                }
                else if (AV_AppConstants.OPP_STATUS_VENCIDO.equalsIgnoreCase(opp.StageName) || AV_AppConstants.OPP_STATUS_NO_GESTIONADA.equalsIgnoreCase(opp.StageName)){
                	oppGCF.potential = 'F';
                }
                
                oppGCF.holdingOtherEntities = opp.AV_Tenencia__c;
                oppGCF.entityName = opp.AV_Entidad__c;
                oppGCF.amountOtherEntities = opp.Amount;
                oppGCF.dueDate = opp.CloseDate;
                oppGCF.commentary = opp.AV_Comentarios__c;
                if (opp.Account != null && String.isNotBlank(opp.Account.AV_NumPerso__c)) {
                    oppGCF.userId = Integer.valueOf(opp.Account.AV_NumPerso__c);
                }
                if (opp.AV_NoOfrecerHasta__c != null) {
                    oppGCF.noOfferUntil = String.valueOf(opp.AV_NoOfrecerHasta__c);
                }
                oppGCF.monthlyFee = opp.AV_Cuota__c;
                oppGCF.warningIndicator = 'N';

                //Include in the map
                DataRequest dataRequest = new DataRequest();
                dataRequest.user = user;
                dataRequest.oppSF = opp;
                dataRequest.oppGCF = oppGCF;
                listOppToSend.add(dataRequest);
            }catch (Exception e){
                AV_LogDebug.printException(methodName, e);
            }
        }

        return listOppToSend;
    }


    /**
     * @description         Update the opp records to inform the status of the response
     * @param listResponses list of the data to save in the DB
     */
    @TestVisible
    private static void insertIntegrationResponses(List<DataResponse> listResponses){
        String methodName = 'insertIntegrationResponses';
        Boolean checkClientPriorize = false;
        Set<String> listIds = new Set<String>();
        List<Database.SaveResult> ur = new List<Database.SaveResult>();
        for(DataResponse data : listResponses) {
            listIds.add(data.idOpp);
        }

        List<Opportunity> listModOpp = [SELECT Id, AV_ExternalID__c, AV_ApiGCF_ResponseStatusCode__c, AV_ApiGCF_ResponseBody__c, AV_ApiGCF_DateSend__c, AccountId, AV_IncludeInPrioritizingCustomers__c
        FROM  Opportunity WHERE Id IN :listIds];
       
        Map<Id, Opportunity> mapModOpp = new Map<Id, Opportunity>(listModOpp);
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        Set<Id> setAccountIds = new Set<Id>();

        for(DataResponse dataResponse : listResponses){
            Opportunity opp = mapModOpp.get(dataResponse.idOpp);
            if (String.isBlank(opp.AV_ExternalID__c) || opp.AV_ExternalID__c.startsWith('Opp-')) {
                opp.AV_ExternalID__c = dataResponse.externalIdOpp;
            }
            opp.AV_ApiGCF_ResponseStatusCode__c = dataResponse.statusCode;
            opp.AV_ApiGCF_ResponseBody__c = dataResponse.errorMessage;
            opp.AV_ApiGCF_DateSend__c = System.Now();
            if(opp.AV_IncludeInPrioritizingCustomers__c){
                checkClientPriorize = true;
            }
            listOppToUpdate.add(opp);
            setAccountIds.add(opp.AccountId);
        }
        
        if(!listOppToUpdate.isEmpty()) {
            //if (!checkClientPriorize) {
                ur = Database.update(listOppToUpdate, false);
                AV_AppUtilities.displayErrors(methodName, ur);
            //}
            //Clean refresh date and json fields for product map in account records
            List<Account> listAccToUpd = new List<Account>();
            for(Id accId : setAccountIds) {
                Account acc = new Account(Id = accId, AV_JSONMapaProducto__c = null, AV_RefreshProductMapDate__c = null);
                listAccToUpd.add(acc);
            }
            if(!listAccToUpd.isEmpty()) {
                Database.update(listAccToUpd, false);
            }
        }
        
        AV_LogDebug.printLogDebug(methodName, 'Responses updated');
    }

}