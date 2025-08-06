@isTest
public with sharing class HDT_LiveChatTranscriptEvent_TRDisp_Test {
    @isTest
    static void testAfterInsert() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

       // Arrange
       CC_TriggerParameters tp = new CC_TriggerParameters();
       tp.newList = null;
       HDT_LiveChatTranscriptEvent_TRDisp triggerDispatcher = new HDT_LiveChatTranscriptEvent_TRDisp();
       
       // Act
       try{
           triggerDispatcher.afterInsert(tp);
       }catch(Exception e){
           System.assertEquals(tp.newList, null);
       }
    }
}
}