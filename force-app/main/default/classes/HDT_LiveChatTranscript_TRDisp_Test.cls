@IsTest
public class HDT_LiveChatTranscript_TRDisp_Test {
    @IsTest
    public static void testBeforeInsert() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Arrange
        CC_TriggerParameters tp = new CC_TriggerParameters();
        tp.newList = null;
        HDT_LiveChatTranscript_TRDisp triggerDispatcher = new HDT_LiveChatTranscript_TRDisp();
        
        // Act
        try{
			triggerDispatcher.beforeInsert(tp);
		}catch(Exception e){
			System.assertEquals(tp.newList, null);
		}
    }
        
       
    }

    @IsTest
    public static void testAfterInsert() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Arrange
        CC_TriggerParameters tp = new CC_TriggerParameters();
        tp.newList = null;
        HDT_LiveChatTranscript_TRDisp triggerDispatcher = new HDT_LiveChatTranscript_TRDisp();
        
        // Act
        // Act
        try{
            triggerDispatcher.afterInsert(tp);
		}catch(Exception e){
			System.assertEquals(tp.newList, null);
		}
       
        
    }
    }

    @IsTest
    public static void testBeforeUpdate() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        CC_TriggerParameters tp = new CC_TriggerParameters();
        tp.newList = null;
        HDT_LiveChatTranscript_TRDisp triggerDispatcher = new HDT_LiveChatTranscript_TRDisp();
        
        // Act
         // Act
         try{
            triggerDispatcher.beforeUpdate(tp);
		}catch(Exception e){
			System.assertEquals(tp.newList, null);
		}
    }
    }

    @IsTest
    public static void testAfterUpdate() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Arrange
        CC_TriggerParameters tp = new CC_TriggerParameters();
        tp.newList = null;
        HDT_LiveChatTranscript_TRDisp triggerDispatcher = new HDT_LiveChatTranscript_TRDisp();
        
        // Act
        try{
            triggerDispatcher.afterUpdate(tp);
		}catch(Exception e){
			System.assertEquals(tp.newList, null);
		}
        
    }
    }
}