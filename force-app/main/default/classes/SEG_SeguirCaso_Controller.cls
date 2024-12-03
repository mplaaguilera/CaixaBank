public class SEG_SeguirCaso_Controller {
	public List<Case> selCaseList;
    public Set<Id> caseIds;
 
    
    
    
      // Constructor
      public SEG_SeguirCaso_Controller(ApexPages.StandardSetController cntlr){
          
           selCaseList = cntlr.getSelected(); //get selected records from account list view
           caseIds = new Set<Id>();
           for(Case caso : selCaseList){
               Id add = caso.Id;
               caseIds.add(add);//build list of ids string concatenated with comma                         
            }
          /**
        	lista = new list<Case>();
        Id user = UserInfo.getUserId();
 		List<EntitySubscription> aux = new List<EntitySubscription>([SELECT ParentId FROM EntitySubscription WHERE subscriberid =:user]);
        Set<Id> subId = new Set<Id>();
        for(EntitySubscription sub : aux){
            Id add = sub.ParentId;
            subId.add(add);

        }
        
        lista = [SELECT Id, caseNumber, status FROM Case WHERE Id IN:subId];
*/
      } 
     public void main(){
        
         for(Id caso: this.caseIds){
             if(!Test.isRunningTest()){
                 ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, 'me', caso);
             }
         }
      
    }
    

    
}