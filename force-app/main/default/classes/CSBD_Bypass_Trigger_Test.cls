@isTest
public with sharing class CSBD_Bypass_Trigger_Test {

    @isTest
    public static void test() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        System.runAs (usuarioGestor) {
            CSBD_Bypass_Trigger.bypass('nombreTrigger');
            System.assertEquals(true, CSBD_Bypass_Trigger.isBypassed('nombreTrigger'), 'error activando bypass');
            CSBD_Bypass_Trigger.undoBypass('nombreTrigger');
            System.assertEquals(false, CSBD_Bypass_Trigger.isBypassed('nombreTrigger'), 'error desactivando bypass');
        }
    }
}