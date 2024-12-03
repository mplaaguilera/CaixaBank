@istest
public class CBK_QA_GitMetadata_test {
    
    static testmethod void test() {
        
        copado__User_Story__c us = New copado__User_Story__c();
		us.copado__User_Story_Title__c='Test';
		insert us;
        
        Blob b = Blob.valueOf('[{"t":"CustomField","n":"CBK_LogEvent__e.txt_stacktrace__c","b":"Developer 1","d":"2020-12-12","cb":"Developer 1","cd":"2020-10-19","r":false,"cmm":"updated","snapshotCommitId":"a1O3Y000005znECUAY"}]');
    	Attachment attachment = new Attachment();
    	attachment.ParentId = us.Id;
    	attachment.Name = 'Git MetaData';
    	attachment.Body = b;
    	insert(attachment);

        
        Test.startTest();
        CBK_QA_GitMetadata uca = new CBK_QA_GitMetadata();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        system.assertNotEquals(batchId, null);
    }

}