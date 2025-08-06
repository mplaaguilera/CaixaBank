@istest
public class CBK_QA_runStaticAnalysis_test { 
    
    static testmethod void test() {
        copado__User_Story__c us = New copado__User_Story__c();
		us.copado__User_Story_Title__c='Test';
		us.copado__Has_Apex_Code__c=true;
        insert us;
        
        list<copado__Org__c> lst = [Select Id from copado__Org__c where name='Producción'];
        if (lst.size()==0){
            copado__Org__c sfOorg = New copado__Org__c();
            sfOorg.Name  ='Producción';
            insert sfOorg;   
        }
        
        
        Test.startTest();
        CBK_QA_runStaticAnalysis uca = new CBK_QA_runStaticAnalysis();
        Id batchId = Database.executeBatch(uca,1);
        Test.stopTest();
        system.assertNotEquals(batchId, null);
    }

}