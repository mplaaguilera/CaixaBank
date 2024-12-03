/**
 * @description Procesamiento Static Analysis de código promocionado a Producción
 */
public class CBK_QA_runStaticAnalysis implements Database.Batchable<sObject>, Database.Stateful {


    /**
    * @description QueryLocator
    * @param bc 
    * @return Database.getQueryLocator(query)
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'select Id from copado__User_Story__c where Id not in (select copado__User_Story__c from copado__Static_Code_Analysis_Result__c ) and copado__Has_Apex_Code__c =true';
        if (!(Test.isRunningTest())) {
            query = query + ' and copado__Environment__r.name=\'Producción\'';
        }
        
        return Database.getQueryLocator(query);
    }

    /**
    * @description QueryLocator
    * @param bc
    * @param scope
    */
    public void execute(Database.BatchableContext bc, List<copado__User_Story__c> scope) {
        copado.RunUserStoryStaticCodeAnalysis.InvocableVariables invocableVariable = new copado.RunUserStoryStaticCodeAnalysis.InvocableVariables();
        invocableVariable.orgId = UserInfo.getOrganizationId();
        
        List<copado.RunUserStoryStaticCodeAnalysis.InvocableVariables> invocableVariables = new List<copado.RunUserStoryStaticCodeAnalysis.InvocableVariables>{invocableVariable};

        for (copado__User_Story__c item : scope){
          invocableVariable.storyId = item.id;
          invocableVariables = new List<copado.RunUserStoryStaticCodeAnalysis.InvocableVariables>{invocableVariable};
          if (!(Test.isRunningTest())) {
              copado.RunUserStoryStaticCodeAnalysis.execute(invocableVariables);
          } else {
              CBK_log.debug('Mode test');
          }
        }
    }   

    /**
    * @description finish
    * @param bc
    */
    public void finish(Database.BatchableContext bc) {
    
        copado.RunOrgStaticCodeAnalysis.InvocableVariables invocableVariable = new copado.RunOrgStaticCodeAnalysis.InvocableVariables();
        list<copado__Org__c> lst = [select Id from copado__Org__c  where Name='Producción'];
        if (!(Test.isRunningTest())) {
        }

        if (lst.size()==1){
            invocableVariable.orgId = lst[0].Id;
            List<copado.RunOrgStaticCodeAnalysis.InvocableVariables> invocableVariables = new List<copado.RunOrgStaticCodeAnalysis.InvocableVariables>{invocableVariable};
            if (!(Test.isRunningTest())) { 
                copado.RunOrgStaticCodeAnalysis.execute(invocableVariables);
            } else {
              CBK_log.debug('Mode test');
            }
               
        }
    } 
}