/**********************************************************************************************************************
 Name:	  EV_ChangeStatus_AI_TRHan
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de prueba para el disparador EV_ChangeStatus_AI_TRHan
----------------------------------------------------------------------------------------------------------------------
Historial
----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		    DE75856             Carolina Lopez      21/02/2024			Init version
    1.1         FIX                 Carolina Lopez      11/04/2024          Modify method testChangeStatusCamp.
***********************************************************************************************************************/
@isTest
public with sharing class EV_ChangeStatus_AI_TRHan_Test {
   @isTest
    static void testChangeStatusCamp() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        EV_ByPass__c cSettingTokens = EV_ByPass__c.getOrgDefaults();
        String jobName = cSettingTokens.EV_ScheduleName__c + '_%';
        Test.startTest();
        System.runAs(newUser){
            Datetime vToday = datetime.now().addMinutes(3);
            String schedule = '0 ' + vToday.minute() + ' ' + vToday.hour() + ' ' + vToday.day() + ' ' + vToday.month() + ' ?' + ' ' + vToday.year();

            EV_ChangeStatus__e testEvent = new EV_ChangeStatus__e(
                EV_ScheduledTime__c = schedule, 
                EV_ExecutionDate__c = DateTime.now().addMinutes(3)
            );
            EventBus.publish(testEvent);

            EV_ChangeStatus_AI_TRHan.changeStatusCamp(new List<EV_ChangeStatus__e>{testEvent});
        }
        Test.stopTest();
        
        List<CronTrigger> cronTriggers = [SELECT Id, State, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name like:jobName LIMIT 1];
        System.assertNotEquals(0, cronTriggers.size(), 'Se esperaba que se creara un CronTrigger');
    }
}