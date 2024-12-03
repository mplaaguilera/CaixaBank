public  without sharing class SEG_ListadoCasosUpdate_Controller {

   
    @AuraEnabled
    static public String getCurrentUser(){
        
       Id currentUser =  UserInfo.getUserId();
        String user = currentUser;
        return user;
    }
    @AuraEnabled
    static public List<Case> getCaseList(){
        
      	List<Case> lista = new list<Case>();
        Id user =  UserInfo.getUserId();
 		List<EntitySubscription> aux = new List<EntitySubscription>([SELECT ParentId FROM EntitySubscription WHERE subscriberid =:user]);
        Set<Id> subId = new Set<Id>();
        for(EntitySubscription sub : aux){
            Id add = sub.ParentId;
            subId.add(add);

        }
        
        lista = [SELECT Id, caseNumber, status FROM Case WHERE Id IN:subId];
        return lista;
    }
}