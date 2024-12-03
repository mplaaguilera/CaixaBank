/**********************************************************************************************************************
Name:	  CIBE_BookMemberTriggerHelper
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Cartera Cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US392789            Jose Maria		    04/10/2022			Init version
    1.0                             Bea                 27/01/2023          Create setBookCenter method
***********************************************************************************************************************/
public with sharing class CIBE_BookMemberTriggerHelper {

    /**
     *  @param description: Check the record types, de field delete and if is active
     *  @param listNews: list of new records
     */
    public static List<AV_BookMember__c> checkGeneralRT(List<AV_BookMember__c> listNews){
        Set<Id> setIdsRt = getAllRT();
        Set<String> negocioValues = new Set<String>{'COR', 'CIB', 'INS', 'EMP', 'PRO', 'MIC', 'INT', 'MOR', 'FIN', 'TES', 'CMX', 'RIE'};
        Set<String> tipoNegValues = new Set<String>{'ETR'};
        List<AV_BookMember__c> listData = new List<AV_BookMember__c>();
        for(AV_BookMember__c dataNew : listNews){
            if((setIdsRt).contains(dataNew.RecordTypeId)
                && dataNew.AV_CarteraActiva__c == 'S'
                && (negocioValues.contains(dataNew.CIBE_NegocioCartera__c)
                || (!String.IsBlank(dataNew.AV_ExternalID__c) && tipoNegValues.contains(dataNew.AV_ExternalID__c.substring(16, 19))))) {
                listData.add(dataNew);
            }
        }
        return listData;
    }
    
    /**
     *  @param description: Get all the ID's of the RT
     */
    public static Set<Id> getAllRT(){
        Set<String> setLabelsRt = new Set<String>{'AV_CarteraCliente'};
        return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
    }

    /**
     *  @param description: Method that insert accountTeamMember if its necesary
     *  @param listBookMembers: get trigger insert values
     */
    public static void insertBookMember(List<AV_BookMember__c> listBookMembers) {
        Set<Id> setIdsClient = new Set<Id>();
        Set<String> setIdsCarteras = new Set<String>();
        for(AV_BookMember__c bm : listBookMembers){
            if(!bm.AV_ToDelete__c && String.isNotBlank(bm.AV_Cartera__c) && String.isNotBlank(bm.AV_Cliente__c)){
                setIdsCarteras.add(bm.AV_Cartera__c);
                setIdsClient.add(bm.AV_Cliente__c);
            }
        }

        if(!setIdsCarteras.isEmpty() && !setIdsClient.isEmpty()) {
            Map<String,String> mapBookMMB = new Map<String,String>();
            if(Schema.AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible()){
                for(AV_BookManagementMember__c bmm : [SELECT Id, Name, AV_Cartera__c, AV_ToDelete__c, AV_EmpleadoGestor__c FROM AV_BookManagementMember__c WHERE AV_Cartera__c IN :setIdsCarteras AND AV_CarteraActiva__c = 'S' AND AV_ToDelete__c = false]){
                    mapBookMMB.put(bmm.AV_Cartera__c, bmm.AV_EmpleadoGestor__c);
                }
            }

            if(!mapBookMMB.isEmpty()){
                Map<String, String> mapUser = new Map<String, String>();
                if(Schema.Contact.SObjectType.getDescribe().isAccessible()){
                    for(Contact cont : [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN :mapBookMMB.values()]){
                        mapUser.put(cont.Id, cont.AV_UsuarioAsociado__c);
                    }
                }
            
                if(!mapUser.isEmpty()){
                    Map<String, AccountTeamMember> mapAccTeamM = new Map<String, AccountTeamMember>();
                    if(Schema.AccountTeamMember.SObjectType.getDescribe().isAccessible()){
                        for(AccountTeamMember accTeamM : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId = :mapUser.values() AND AccountId = :setIdsClient]) {
                            mapAccTeamM.put((accTeamM.AccountId + '_' + accTeamM.UserId), accTeamM);
                        }
                    }

                    List<AccountTeamMember> listAccTM = new List<AccountTeamMember>();
                    for(AV_BookMember__c bm : listBookMembers){
                        if(String.isNotBlank(bm.AV_Cliente__c)
                            && mapBookMMB.containsKey(bm.AV_Cartera__c)
                            && mapUser.containsKey(mapBookMMB.get(bm.AV_Cartera__c))
                            && String.isNotBlank(mapUser.get(mapBookMMB.get(bm.AV_Cartera__c)))
                            && !mapAccTeamM.containsKey((bm.AV_Cliente__c + '_' + mapUser.get(mapBookMMB.get(bm.AV_Cartera__c))))) {
                            AccountTeamMember accTeamMember = new AccountTeamMember();
                            accTeamMember.UserId = mapUser.get(mapBookMMB.get(bm.AV_Cartera__c)); 
                            accTeamMember.AccountId = bm.AV_Cliente__c;
                            accTeamMember.AccountAccessLevel = CIBE_AppConstants.READ;
                            accTeamMember.OpportunityAccessLevel = CIBE_AppConstants.NONE;
                            accTeamMember.CaseAccessLevel = CIBE_AppConstants.READ;
                            accTeamMember.ContactAccessLevel = CIBE_AppConstants.EDIT;
                            accTeamMember.CIBE_IsAutomatic__c = true;
                            accTeamMember.TeamMemberRole = CIBE_AppConstants.PARTICIPANTE;
                            listAccTM.add(accTeamMember);
                        }
                    }

                    if(!listAccTM.isEmpty() && Schema.AccountTeamMember.SObjectType.getDescribe().isCreateable()){
                        Database.SaveResult [] inrs = Database.insert(listAccTM, false);

                        boolean hasError = false;
                        Map<String, String> msjs = new Map<String, String>();
                        List<Object> objs = new List<Object>();
                        for (Integer i = 0; i < listAccTM.size(); i++) {
                            Database.SaveResult sr = inrs[i];
                            if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                                msjs.put(listAccTM[i].AccountId + '_' + listAccTM[i].UserId, ((String)sr.getErrors()[0].getMessage()));
                                objs.add(listAccTM[i]);
                                hasError = true;
                            }
                        }
                        if(hasError) {
                            CBK_Log.error(msjs, objs);
                        }
                    }
                }
            }
        }
    }

    /**
     *  @param description: Method that de accountTeamMember if its necesary
     *  @param listNewBM: get trigger update values
	 */
    public static void updateBookMember(List<AV_BookMember__c> listNewBM) {
        Set<String> setIdsCartDelete = new Set<String>();
        Set<String> setIdsClientDelete = new Set<String>();
        for(AV_BookMember__c bm : listNewBM){
            if(bm.AV_ToDelete__c && String.isNotBlank(bm.AV_Cartera__c) && String.isNotBlank(bm.AV_Cliente__c)) {
                setIdsCartDelete.add(bm.AV_Cartera__c);
                setIdsClientDelete.add(bm.AV_Cliente__c);
            }
        }

        if(!setIdsCartDelete.isEmpty() && !setIdsClientDelete.isEmpty()) {
            Map<String,String> mapBookMMB = new Map<String,String>();
            if(Schema.AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible()){
                for(AV_BookManagementMember__c bmm : [SELECT Id, AV_Cartera__c, AV_EmpleadoGestor__c FROM AV_BookManagementMember__c WHERE AV_Cartera__c IN :setIdsCartDelete]){
                    mapBookMMB.put(bmm.AV_Cartera__c, bmm.AV_EmpleadoGestor__c);
                }
            }

            if(!mapBookMMB.isEmpty()){
                List<Id> listUser =new List<Id>();
                if(Schema.Contact.SObjectType.getDescribe().isAccessible()){
                    for(Contact cont : [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN :mapBookMMB.values() ANd AV_UsuarioAsociado__c != null]){
                        listUser.add(cont.AV_UsuarioAsociado__c);
                    }
                }

                if(!listUser.isEmpty()){
                    List<AccountTeamMember> listAccTeamM = new List<AccountTeamMember>();
                    if(Schema.AccountTeamMember.SObjectType.getDescribe().isAccessible()){
                        listAccTeamM = [SELECT Id FROM AccountTeamMember WHERE CIBE_IsAutomatic__c = true AND UserId = :listUser AND AccountId = :setIdsClientDelete];
                    }

                    if(!listAccTeamM.isEmpty() && Schema.AccountTeamMember.SObjectType.getDescribe().isDeletable()){
                        Database.DeleteResult[] dels = Database.delete(listAccTeamM, false);

                        boolean hasError = false;
                        Map<String, String> msjs = new Map<String, String>();
                        List<Object> objs = new List<Object>();
                        for (Integer i = 0; i < listAccTeamM.size(); i++) {
                            Database.DeleteResult dr = dels[i];
                            if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                                msjs.put(listAccTeamM[i].Id, ((String)dr.getErrors()[0].getMessage()));
                                objs.add(listAccTeamM[i]);
                                hasError = true;
                            }
                        }
                        if(hasError) {
                            CBK_Log.error(msjs, objs);
                        }
                    }
                }
            }
        }
    }

    public static void setBookCenter(List<AV_BookMember__c> listBookMembers) {
        Map<Id, Id> bookMemberToClient = new Map<Id, Id>();
        for (AV_BookMember__c bm : listBookMembers) {
            if(bm.AV_CarteraPrincipal__c && String.isNotBlank(bm.AV_Cliente__c)) {
                bookMemberToClient.put(bm.Id, bm.AV_Cliente__c);
            }
        }
        if(!bookMemberToClient.isEmpty()) {
            List<AV_BookMember__c> bookMembers = new List<AV_BookMember__c>();
            if(Schema.sObjectType.AV_BookMember__c.isAccessible()
                && Schema.SObjectType.AV_BookMember__c.fields.AV_Cliente__c .isAccessible()
                && Schema.SObjectType.AV_BookMember__c.fields.AV_Cartera__c .isAccessible()
                && Schema.SObjectType.AV_BookMember__c.fields.AV_CarteraPrincipal__c .isAccessible()) {
                bookMembers = [SELECT Id, AV_Cliente__c, AV_Cartera__c, AV_Cartera__r.AV_Centro__c FROM AV_BookMember__c WHERE Id = :bookMemberToClient.keySet() AND AV_Cliente__c != null AND AV_Cartera__c != null AND AV_CarteraPrincipal__c = true];
            }

            Map<Id, Account> clients = new Map<Id, Account>();
            if(Schema.sObjectType.Account.isAccessible()
                && Schema.SObjectType.Account.fields.CIBE_BookCenter__c .isAccessible()) {
                clients = new Map<Id, Account>([SELECT Id, CIBE_BookCenter__c FROM Account WHERE id IN :bookMemberToClient.values()]);
            }
            
            List<Account> toUpdate = new List<Account>();
            for(AV_BookMember__c bm : bookMembers) {   
                if(bm.AV_Cartera__r.AV_Centro__c != null && clients.containsKey(bm.AV_Cliente__c) && clients.get(bm.AV_Cliente__c).CIBE_BookCenter__c != bm.AV_Cartera__r.AV_Centro__c) {
                    clients.get(bm.AV_Cliente__c).CIBE_BookCenter__c = bm.AV_Cartera__r.AV_Centro__c;
                    if(!toUpdate.contains(clients.get(bm.AV_Cliente__c))){
                        toUpdate.add(clients.get(bm.AV_Cliente__c)); 
                    }
                }
            }
            if(!toUpdate.isEmpty() && Schema.sObjectType.Account.isUpdateable()) {
                Database.SaveResult [] inrs = Database.update(toUpdate, false);

                boolean hasError = false;
                Map<String, String> msjs = new Map<String, String>();
                List<Object> objs = new List<Object>();
                for (Integer i = 0; i < toUpdate.size(); i++) {
                    Database.SaveResult sr = inrs[i];
                    if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                        msjs.put(toUpdate[i].Id, ((String)sr.getErrors()[0].getMessage()));
                        objs.add(toUpdate[i]);
                        hasError = true;
                    }
                }
                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }
            }
        }
    } 
}