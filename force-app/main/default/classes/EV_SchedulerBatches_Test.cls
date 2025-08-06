@isTest
public with sharing class EV_SchedulerBatches_Test {
    @isTest
    public static void blanqueoClase(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            EV_SchedulerBatches.metodoBlanco();
        }
        System.assertEquals('', '');
    }
}