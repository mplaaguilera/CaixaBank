@isTest
public class CBK_LogEventTrigger_Test {
    @isTest
    public static void Test01() {
        string txtError='Class.CC_Log.emit: line 73, column 1\nClass.CBK_Log.error: line 64, column 1\nClass.CBK_Log.error: line 48, column 1\nAnonymousBlock: line 2, column 1\nAnonymousBlock: line 2, column 1\nClass.CBK_Log.error: line 48, column 1\nAnonymousBlock: line 2, column 1\nAnonymousBlock: line 2, column 1';
        List<Object> values = new List<Object> {'Objeto detalle 1','Objeto detalle 2','Objeto detalle 3'};
        CBK_LogEvent__e currentEvent = new CBK_LogEvent__e();
        currentEvent.txt_User__c = UserInfo.getUserId();
        currentEvent.txt_Message__c = txtError;
        currentEvent.txt_ErrType__c = 'xxxxxx';
        currentEvent.txt_Level__c = 'ERROR';
        currentEvent.txt_Context__c = null;
        currentEvent.txt_stacktrace__c = 'xxxxxxx'; 
        currentEvent.txt_Detail__c = string.join(values,'@Det@')?.left(32000);
        currentEvent.CBK_Category__c = 'test';
        currentEvent.CBK_ApexClass__c = 'CBK_Test';
        
        Test.startTest();
    	Database.SaveResult sr = EventBus.publish(currentEvent);
    	System.assertEquals(true, sr.isSuccess());
    	Test.getEventBus().deliver();
    	Test.stopTest();
    }

}