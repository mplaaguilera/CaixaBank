public with sharing class EV_AccountTriggerHelper {
  
    /**
	 * @description		 Update the user and last modified date when the description is updated
	 * @param  listNews  list of new account records
     * @param mapOlds    map of old account records
	 */
    public static void updateLastModifiedDate(List<Account> listNews, Map<Id, Account> mapOlds){
        
        if(mapOlds != null && !mapOlds.isEmpty()){
            for(Account cliente : listNews){
                if( cliente.Name != mapOlds.get(cliente.Id).Name
                    || cliente.AV_NumPerso__c != mapOlds.get(cliente.Id).AV_NumPerso__c
                    || cliente.CC_NumPerso__c != mapOlds.get(cliente.Id).CC_NumPerso__c
                    || cliente.RecordTypeId != mapOlds.get(cliente.Id).RecordTypeId
                    || cliente.ParentId != mapOlds.get(cliente.Id).ParentId
                    || cliente.OwnerId != mapOlds.get(cliente.Id).OwnerId
                    || cliente.AV_Idioma__c != mapOlds.get(cliente.Id).AV_Idioma__c
                    || cliente.CC_Idioma__pc != mapOlds.get(cliente.Id).CC_Idioma__pc
                    || cliente.AV_EAPGestor__c != mapOlds.get(cliente.Id).AV_EAPGestor__c
                    || cliente.CC_Numero_Documento__c != mapOlds.get(cliente.Id).CC_Numero_Documento__c){
                    cliente.EV_LastModifiedDateAC__c = datetime.now();
                }
                              
            }    
        }	
    }
}