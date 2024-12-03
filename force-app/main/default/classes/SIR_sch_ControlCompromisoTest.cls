/*****************************************************************
 Name: SIR_sch_ControlCompromiso
 Copyright © 2021 CaixaBank
============================================================
Proposito: Clase de test de SIR_sch_ControlCompromisoTest                                                                                                               
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         21/12/2021     	 Created    

*****************************************************************/
@isTest
public with sharing class SIR_sch_ControlCompromisoTest {
    @isTest
    public static void controlCompromisoTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Test.startTest();
            SIR_sch_ControlCompromiso myClass = new SIR_sch_ControlCompromiso ();   
            String year = String.valueOf(Date.today().year() + 1);
            String chron = '0 0 0 3 9 ? '+ year;        
            String jobId = System.schedule('Test Sched', chron, myClass);      
            Test.stopTest();  
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
            System.assertEquals(0, ct.TimesTriggered); 
            System.assertEquals(year +'-09-03 00:00:00', String.valueOf(ct.NextFireTime));  
        } 
    }
}