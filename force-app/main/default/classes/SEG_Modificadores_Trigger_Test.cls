@isTest
public with sharing class SEG_Modificadores_Trigger_Test {

    @isTest
    public static void test() {
        SEG_Modificadores_Trigger.activarModificador('modificador1');
        System.assertEquals(true, SEG_Modificadores_Trigger.modificadorActivo('modificador1'), 'error activando modificador');
        SEG_Modificadores_Trigger.desactivarModificador('modificador1');
        System.assertEquals(false, SEG_Modificadores_Trigger.modificadorActivo('modificador1'), 'error desactivando modificador');
    }
}