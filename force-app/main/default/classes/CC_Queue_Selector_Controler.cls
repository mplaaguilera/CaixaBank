public class CC_Queue_Selector_Controler {
    
    @AuraEnabled
    public static List<GroupMember> getColas() {
        Id userId = UserInfo.getUserId();
        List<GroupMember> colas = [SELECT Id,Group.name,UserOrGroupId FROM GroupMember where Group.Type='Queue' and UserOrGroupId = :userId];
        return colas;
    }

    @AuraEnabled
    public static List<Case> getItems(String Cola) {
        List<Case> casos = [SELECT Id,CaseNumber,OwnerId,Flag__c, status,contact.name,Origin,createddate,subject
                              FROM Case where Owner.Name= :Cola and Status!='Cerrado'
                             ORDER BY createddate asc];
        return casos;
    }
    
    @AuraEnabled
    public static boolean acceptCase(Id CaseId, Id QueueId) {
        List<Case> caso = [Select Id,OwnerId from Case where Id = :CaseId and OwnerId = :QueueId and Status!='Cerrado' LIMIT 1];
        boolean resultado;
        if (caso.size()>0) {
            caso[0].OwnerId = UserInfo.getUserId();
            Update caso;           
            resultado=true;
        } else {
            resultado=false;
        }
        return resultado;
    }
}