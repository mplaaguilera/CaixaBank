@isTest
public class CC_SDOCS_MCC_Batch_Schedule_Test {
	@isTest static void test() {
        SchedulableContext sc = null;
        CC_SDOCS_MCC_Batch_Schedule smbs = new CC_SDOCS_MCC_Batch_Schedule();
        smbs.execute(sc);
    }
}