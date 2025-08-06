public class SEG_PropietarioAnterior_Controller {
    public List<Case> selCaseList;
      public Set<Id> caseIds;

      // Constructor
      public SEG_PropietarioAnterior_Controller(ApexPages.StandardSetController cntlr){
           selCaseList = cntlr.getSelected(); //get selected records from account list view
           caseIds = new Set<Id>();
           for(Case caso : selCaseList){
               Id add = caso.Id;
               caseIds.add(add);//build list of ids string concatenated with comma                         
            }
        	
      } 
   
    public void main(){
        
        List<Case> caseFields = getCaseFields(this.caseIds);
        SEG_PropietarioAnterior_Controller.changeOwner(caseFields);
		        
    }
    public static List<Case> getCaseFields(Set<Id> caseIds ){
       return[SELECT Id,OwnerId, CC_Owner_Anterior__c FROM Case WHERE Id IN :caseIds];
    }
    
    public static void changeOwner(List<Case> caseFields){
        for(Case caso : caseFields){
            if(caso.CC_Owner_Anterior__c != null)     {
                caso.OwnerId = caso.CC_Owner_Anterior__c;
           		 }            
            }
        update(caseFields);
    }
	
}