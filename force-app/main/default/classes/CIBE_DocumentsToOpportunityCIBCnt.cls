/**********************************************************************************************************************
Name:	  CIBE_DocumentsToOpportunityCIBCnt
Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Task.
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			US430953		    Luis Martínez 	    26/08/2022		    Init version
***********************************************************************************************************************/
public with sharing class CIBE_DocumentsToOpportunityCIBCnt {
    
    private static CIBE_AppUtilities.SearchRT rtINICIATIVACIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtSUGERENCIACIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtALERTACOMERCIALCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtACCIONCOMERCIALCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONCIB_RT);
	public static Set<Id> setRtOppCIB   = getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtINICIATIVACIB, rtSUGERENCIACIB, rtALERTACOMERCIALCIB, rtACCIONCOMERCIALCIB});
    
    public static Set<Id> getIdsRT(Set<CIBE_AppUtilities.SearchRT> setRT){
        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getDocuments(){
        List<ContentDocument> lstContDocument = new List<ContentDocument>();
        List<CBK_Log__c> lstCBKLog = new List<CBK_Log__c>();
        Set<Id> setDocus = new Set<Id>();
        lstCBKLog = [SELECT Id, Transaction_ID__c, Apex_Class__c, state__c 
                    FROM CBK_Log__c
                    WHERE Transaction_ID__c =:UserInfo.getUserId() AND RecordType.Developername='Apex_Log' AND state__c ='Pendiente'];

                    if(!lstCBKLog.IsEmpty()){
                        for(CBK_Log__c log: lstCBKLog){
                            setDocus.add(log.Apex_Class__c);
                        }
                    }
        lstContDocument = [SELECT Id, Title, FileType, CreatedDate  FROM ContentDocument WHERE Id IN:setDocus ORDER BY CreatedDate DESC];
        return lstContDocument;
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String accountName, String opportunityName){
        List<Opportunity> lstOppor =  new List<Opportunity>();

        String query = 'SELECT Id, Name, AccountId, Account.Name, TOLABEL(StageName), AV_ProductName__c, CIBE_pais__c, Owner.Name '+
                        'FROM Opportunity '+ 
                        'WHERE RecordTypeId IN :setRtOppCIB ';

                        if(!String.IsBlank(opportunityName) ){
                            query +=' AND Name LIKE \'%'+String.escapeSingleQuotes(opportunityName) +'%\'';
                        }

        List<Opportunity> lstOpporQ = Database.query(query);
        if(!lstOpporQ.IsEmpty()){
            for(Opportunity oppo: lstOpporQ){
                if(!String.IsBlank(accountName) && oppo.AccountId != null && oppo.Account.Name.containsIgnoreCase(accountName)){
                    lstOppor.add(oppo);
                }else if(String.IsBlank(accountName)){
                    lstOppor.add(oppo);
                }
            }
        }
        return lstOppor;
    }

    @AuraEnabled
    public static String updateState(List<String> documentId){
        String result = '';
        List<CBK_Log__c> lstCBKLogF = new List<CBK_Log__c>();
        List<CBK_Log__c> lstCBKLogQ = [SELECT Id, Transaction_ID__c, Apex_Class__c, state__c FROM CBK_Log__c WHERE Transaction_ID__c =:UserInfo.getUserId() AND RecordType.Developername='Apex_Log'AND Apex_Class__c in :documentId];
        if(!lstCBKLogQ.IsEmpty()){
            for(CBK_Log__c log: lstCBKLogQ){
                log.Id = log.Id;
                log.state__c = 'Descartado';
                lstCBKLogF.add(log);
            }
            List<Database.SaveResult> listUpdateResult = Database.Update(lstCBKLogF,FALSE);
            for (Database.SaveResult sr : listUpdateResult) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        result = result+':: Error: '+err.getMessage()+'Field: '+err.getFields();
                    }
                }
            }
        }
        return result;
    }

    @AuraEnabled
    public static String vincDocusOpp(List<String> lstDocumentId, String opportunityId){
        String result = '';
        List<ContentDocumentLink> lstDoc = new List<ContentDocumentLink>();
        for(String doc : lstDocumentId){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = doc;
            cdl.LinkedEntityId = opportunityId;
            lstDoc.add(cdl);
        }
        List<Database.SaveResult> listUpdateResult = Database.Insert(lstDoc,FALSE);
        for (Database.SaveResult sr : listUpdateResult) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    result = result+':: Error: '+err.getMessage()+'Field: '+err.getFields();
                }
            }
        }
        List<CBK_Log__c> lstCBKLogF = new List<CBK_Log__c>();
        List<CBK_Log__c> lstCBKLogQ = [SELECT Id, Transaction_ID__c, Apex_Class__c, state__c FROM CBK_Log__c WHERE Transaction_ID__c =:UserInfo.getUserId() AND RecordType.Developername='Apex_Log'AND Apex_Class__c in :lstDocumentId];
        if(!lstCBKLogQ.IsEmpty()){
            for(CBK_Log__c log: lstCBKLogQ){
                log.Id = log.Id;
                log.state__c = 'Completado';
                lstCBKLogF.add(log);
            }
            List<Database.SaveResult> listUpdateResult2 = Database.Update(lstCBKLogF,FALSE);
            for (Database.SaveResult sr : listUpdateResult2) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        result = result+':: Error: '+err.getMessage()+'Field: '+err.getFields();
                    }
                }
            }
        }
        return result;
    }
}