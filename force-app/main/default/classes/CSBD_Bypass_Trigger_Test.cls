@isTest
public with sharing class CSBD_Bypass_Trigger_Test {

    @isTest
    public static void test() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            CSBD_Bypass_Trigger.bypass('nombreTrigger');
            System.assertEquals(true, CSBD_Bypass_Trigger.isBypassed('nombreTrigger'), 'error activando bypass');
            CSBD_Bypass_Trigger.undoBypass('nombreTrigger');
            System.assertEquals(false, CSBD_Bypass_Trigger.isBypassed('nombreTrigger'), 'error desactivando bypass');
            Test.stopTest();
        }
    }
}