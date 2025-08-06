/**********************************************************************************************************************
 Name:	  AV_BookMemberTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Cartera Cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US168560            Eric Vázquez		12/02/2021			Init version

	1.1			US168560            David Rufo			03/03/2021			Fix "Catera Activa"
    1.2			DE52465			    Sandra Gómez		30/09/2021			add EAP/Gestor

	1.3			DE52465			    Sandra Gómez		30/09/2021			add EAP/Gestor
	1.4			USXXXXXX 		    Daniel Rodríguez	09/12/2021			add CBK_log in updateOwnerIdFromClient method
	1.5		    AV_Query IT	        Daniel Rodríguez	04/02/2022	        Change AV_Query to SOQL for User and Account
    1.6			Fix					Gonzalo Ávila		27/09/2023			Fix CBK_Log Error
***********************************************************************************************************************/
public with sharing class AV_BookMemberTriggerHelper {
    
    /**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
    public static List<AV_BookMember__c> checkGeneralRT(List<AV_BookMember__c> listNews){
        Set<Id> setIdsRt = getAllRT();
        
        List<AV_BookMember__c> listData = new List<AV_BookMember__c>();
        for(AV_BookMember__c dataNew : listNews){
            if((setIdsRt).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
            }
        }
        return listData;
    }
    
    /**
	 * @description		 	Get all the ID's of the RT
	 */
    public static Set<Id> getAllRT(){
        Set<String> setLabelsRt = new Set<String>{'AV_CarteraCliente'};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
    }
        
    /**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
    public static Set<Id> getIdsRT(Set<String> setRT){
        return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
    }
    
    
    /**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param listNews		update the owners of the customers
	 */
    public static void updateOwnerIdFromClient(List<AV_BookMember__c> listNews){

        String methodName = 'updateOwnerIdFromClient';

        Map<String, AV_BookMember__c> mapCarteraCliente = new Map<String, AV_BookMember__c>();
        Map<String, AV_BookManagementMember__c> mapCarteraGestor = new Map<String, AV_BookManagementMember__c>();
        List<AV_BookManagementMember__c> listBookGestor = new List<AV_BookManagementMember__c>();
        List<Account> listAccount = new List<Account>();
        List<Account> listAccountUpdate = new List<Account>();


		Set<String> setIdsCarterasActive = new Set<String>();
        Set<String> setIdsCarteras = new Set<String>();
        Set<String> setIdsAccount = new Set<String>();
        
        for(AV_BookMember__c bkmember : listNews){
			if (!bkmember.AV_ToDelete__c) {
            setIdsCarterasActive.add(bkmember.AV_Cartera__c);
        }
		}
		if (!setIdsCarterasActive.isEmpty()) {
			List<AV_Book__c> listBookActive = [Select Id, AV_Activa__c From AV_Book__c where AV_Activa__c = 'S' and Id in :setIdsCarterasActive];
        Map<Id, AV_Book__c> mapBookActive = new Map<Id, AV_Book__c>(listBookActive);
        
		for(AV_BookMember__c bkmember : listNews){
            AV_Book__c book = mapBookActive.get(bkmember.AV_Cartera__c);
			if(bkmember.AV_CarteraPrincipal__c && book != null){
                mapCarteraCliente.put(bkmember.AV_Cliente__c, bkmember);
                setIdsAccount.add(bkmember.AV_Cliente__c);
                setIdsCarteras.add(bkmember.AV_Cartera__c);
            }
        }
        

        AV_LogDebug.printLogDebug(methodName, 'mapCarteraCliente: ' + mapCarteraCliente);
		}
        

        //Get the "cartera gestor" of the "cartera cliente"
        if(setIdsCarteras != null && !setIdsCarteras.isEmpty()){
			listBookGestor = [Select Id, AV_EmpleadoGestor__c, AV_EmpleadoGestor__r.AV_UsuarioAsociado__c, AV_Cartera__c From AV_BookManagementMember__c where AV_Cartera__c in :setIdsCarteras];
        }
		AV_LogDebug.printLogDebug(methodName, 'listBookGestor: ' + listBookGestor);
        //Gest the list of the account's
        if(setIdsAccount != null && !setIdsAccount.isEmpty() && listBookGestor!=null && !listBookGestor.isEmpty()){
			listAccount= [Select Id, OwnerId, AV_EAPGestor__c From Account Where Id in :setIdsAccount];
            User userCli = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' limit 1];
            for(AV_BookManagementMember__c bkmanage: listBookGestor){
                mapCarteraGestor.put(bkmanage.AV_Cartera__c, bkmanage);
            }
            
            for(Account acc: listAccount){
                AV_BookMember__c carteraCliente = mapCarteraCliente.get(acc.Id);
                AV_BookManagementMember__c carteraGestor = mapCarteraGestor.get(carteraCliente.AV_Cartera__c);
                if (carteraGestor!=null && carteraGestor.AV_EmpleadoGestor__c!=null && acc.OwnerId != carteraGestor.AV_EmpleadoGestor__r.AV_UsuarioAsociado__c){
                    if (carteraGestor.AV_EmpleadoGestor__r.AV_UsuarioAsociado__c!=null) {
                        acc.OwnerId = carteraGestor.AV_EmpleadoGestor__r.AV_UsuarioAsociado__c;
                    } else {
                        acc.OwnerId = userCli.Id;
                    } 
                    acc.AV_EAPGestor__c = carteraGestor.AV_EmpleadoGestor__c;
                    listAccountUpdate.add(acc);
                }
            }
        }

		
		AV_LogDebug.printLogDebug(methodName, 'listAccountUpdate size: ' + listAccountUpdate.size());
        List<String> listErrorsUpdateResults = new List<String>();
        List<String> listSuccessUpdateResults = new List<String>();
		List<Database.SaveResult> updateResults = Database.update(listAccountUpdate, false);
		List<Id> successIds = new List<Id>();
        Integer i = 0;

		for (Database.SaveResult sr : updateResults) {
		if (sr.isSuccess()) { 
            successIds.add(sr.getId());
            listSuccessUpdateResults.add(methodName +'Update Account: ' + sr.getId());
        }
		else {
			for(Database.Error err : sr.getErrors()) {
                listErrorsupdateResults.add('Error: ' + err.getMessage() + ' -> Id: ' + listAccountUpdate.get(i).Id);	 
			}
            i++;
        }
            
        }
        if(!listErrorsupdateResults.isEmpty()){
            CBK_log.error('Metodo: '+methodName+' listErrorsupdateResults: '+listErrorsupdateResults,listErrorsupdateResults);
        }

        if(!listSuccessUpdateResults.isEmpty()){
            CBK_log.debug('Metodo: '+methodName+' listErrorsupdateResults: '+listErrorsupdateResults,listErrorsupdateResults,LoggingLevel.DEBUG);
        }
				
    }

	
}