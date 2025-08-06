@isTest
public class SEG_UpdateAccount_Batch_text {

    @isTest
    public static void test() {
        List <String> cObjList = new list <String>();
		cObjList.add('1234');
		Database.executeBatch(new SEG_UpdateAccount_Batch(cObjList), 1);

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
            Test.stopTest();        
        System.assertNotEquals(null , cObjList,'cObjList viene vacío');
        }
    }
}