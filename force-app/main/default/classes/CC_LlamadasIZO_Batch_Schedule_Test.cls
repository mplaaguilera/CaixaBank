@isTest
public class CC_LlamadasIZO_Batch_Schedule_Test {

	@isTest static void test() {
        SchedulableContext sc = null;
        CC_LlamadasIZO_Batch_Schedule lbs = new CC_LlamadasIZO_Batch_Schedule();
        lbs.execute(sc);
    }
}