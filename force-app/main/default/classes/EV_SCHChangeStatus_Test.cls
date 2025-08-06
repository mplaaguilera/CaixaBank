/**********************************************************************************************************************
 Name:	  EV_SCHChangeStatus_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test encargada de cambiar los estados de las campañas
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                   	Daniel Rodriguez	23/01/2023			Init version
	1.1			US555430			Daniel Rodriguez	14/03/2023			Modify all method to new schedule class
	1.2			US567177			Daniel Rodriguez 	12/04/2023			Add method testChangeStatusPublicoValidado
    1.3         US738818            Mamen Arias         19/10/2023          Modify all methods replacing datetime.now() for concret hours
***********************************************************************************************************************/
@isTest
public with sharing class EV_SCHChangeStatus_Test {
    @testSetup 
    static void methodName() {
        Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
        User user = EV_TestHelper.createUser('EV_Eventos');
        Time now = datetime.now().time();
			Campaign c1 = new Campaign(
				Name = 'TestCampaign',
				RecordTypeId = rtEvento,
				EV_ExternalId__c = '1234567895',
                Status = '008',
				/*StartDate = Date.today(),
                EV_DiaHora_evento__c = datetime.now(),
        		EV_HoraInicio__c = Time.newInstance(now.hour(), now.minute(), 00, 00),
        		EV_HoraFin__c = Time.newInstance(Integer.valueof(now.hour()+1), now.minute(), 00, 00),
        		EV_FechaHoraFin__c = datetime.now().addhours(+2)*/
                StartDate = Date.newInstance(2022, 10, 19),
                EV_DiaHora_evento__c = Datetime.newInstance(2022, 10, 19, 10, 00, 0),
                EV_HoraInicio__c = Time.newInstance(10, 00, 00, 00),
        		EV_HoraFin__c = Time.newInstance(11, 00, 00, 00),
                EV_FechaHoraFin__c = Datetime.newInstance(2022, 10, 19, 12, 00, 0)
			); 
			insert c1;

            Campaign cmp = [SELECT Id, EV_DiaHora_evento__c, Status FROM Campaign LIMIT 1];
            System.assertEquals(cmp != null, true,'Test');
    }

    @isTest
	private static void testChangeStatusInvitacionesEnviadas() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        
		Test.startTest();
        Campaign cmp = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c,EV_Notification__c, Status FROM Campaign LIMIT 1];
        Time now = datetime.now().time();
        
		cmp.Status = '003';
        /*cmp.EV_DiaHora_evento__c = datetime.now();
        cmp.EV_HoraInicio__c = Time.newInstance(now.hour(), now.minute()+15, 00, 00);
        cmp.EV_HoraFin__c = Time.newInstance(Integer.valueof(now.hour()+1), now.minute(), 00, 00);
        cmp.EV_FechaHoraFin__c = datetime.now().addhours(+2);*/
        
        cmp.EV_HoraInicio__c = Time.newInstance(10, 15, 00, 00);
        cmp.EV_HoraFin__c = Time.newInstance(11, 00, 00, 00);
        cmp.EV_DiaHora_evento__c = Datetime.newInstance(2022, 10, 19, 10, 00, 0);
        cmp.EV_FechaHoraFin__c = Datetime.newInstance(2022, 10, 19, 12, 00, 0);
		cmp.EV_Notification__c = '003';
		update cmp;
        
		System.assertEquals('003', cmp.Status);
        
        Campaign cmp3 = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c, Status, EV_DiaHora_eventoAE__c FROM Campaign LIMIT 1];
        Datetime inicio = datetime.now().addHours(+1);
        String strSchedule = '0 ' + inicio.minute() + ' ' + inicio.hour() + ' ' + inicio.day() + ' ' + inicio.month() + ' ?' + ' ' + inicio.year();
         System.runAs(user)
        {  
        try{
            Campaign cmp2 = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c, Status FROM Campaign LIMIT 1];
        	System.schedule('Job Schedule', strSchedule, new EV_SCHChangeStatus());
		}catch (Exception e){
            Test.stopTest();
			System.assertEquals(e.getMessage()==null, true, 'Test');
		}
        }
    }
    
    
    @isTest
	private static void testChangeStatusEnCurso() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
		Test.startTest();
        Campaign cmp = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c,EV_Notification__c, Status FROM Campaign LIMIT 1];
        //Time now = datetime.now().time();
        
		cmp.Status = '004';
        //cmp.EV_DiaHora_evento__c = datetime.now();
        cmp.EV_DiaHora_evento__c = Datetime.newInstance(2022, 10, 19, 11, 00, 0);
        //cmp.EV_HoraInicio__c = Time.newInstance(now.hour(), now.minute()-30, 00, 00);
        //cmp.EV_HoraFin__c = Time.newInstance(now.hour(), now.minute()-5, 00, 00);
        //cmp.EV_FechaHoraFin__c = datetime.now().addhours(+2);
        cmp.EV_HoraInicio__c = Time.newInstance(09, 30, 00, 00);
        cmp.EV_HoraFin__c = Time.newInstance(10, 55, 00, 00);
        cmp.EV_FechaHoraFin__c = Datetime.newInstance(2022, 10, 19, 13, 00, 0);
		cmp.EV_Notification__c = '003';
		update cmp;
            
		System.assertEquals('004', cmp.Status);
        
        Datetime inicio = datetime.now().addhours(+1);
        String strSchedule = '0 ' + inicio.minute() + ' ' + inicio.hour() + ' ' + inicio.day() + ' ' + inicio.month() + ' ?' + ' ' + inicio.year();
           System.runAs(user)
        {  
        try{
            Campaign cmp2 = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c, Status FROM Campaign LIMIT 1];
        	System.schedule('Job Schedule', strSchedule, new EV_SCHChangeStatus());
		}catch (Exception e){
            Test.stopTest();
			System.assertEquals(e.getMessage()==null, true, 'Test');
		}
        }
    
    }
    @isTest
	private static void testChangeStatusApuntoEmpezar() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];

		Test.startTest();
        Campaign cmp = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c,EV_Notification__c, Status FROM Campaign LIMIT 1];
        Time now = datetime.now().time();
        
		cmp.Status = '012';
        //cmp.EV_DiaHora_evento__c = datetime.now();
        cmp.EV_DiaHora_evento__c = Datetime.newInstance(2022, 10, 19, 10, 55, 0);
        //cmp.EV_HoraInicio__c = Time.newInstance(now.hour(), now.minute()-5, 00, 00);
        //cmp.EV_HoraFin__c = Time.newInstance(Integer.valueof(now.hour()+1), now.minute(), 00, 00);
        //cmp.EV_FechaHoraFin__c = datetime.now().addhours(+2);
        cmp.EV_HoraInicio__c = Time.newInstance(09, 55, 00, 00);
        cmp.EV_HoraFin__c = Time.newInstance(11, 00, 00, 00);
        cmp.EV_FechaHoraFin__c = Datetime.newInstance(2022, 10, 19, 13, 55, 0);
		cmp.EV_Notification__c = '003';
		update cmp;
        
		System.assertEquals('012', cmp.Status);
        
        Datetime inicio = datetime.now().addminutes(15);
        String strSchedule = '0 ' + inicio.minute() + ' ' + inicio.hour() + ' ' + inicio.day() + ' ' + inicio.month() + ' ?' + ' ' + inicio.year();
        System.runAs(user)
        {  
        try{
            Campaign cmp2 = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c, Status FROM Campaign LIMIT 1];
        	System.schedule('Job Schedule', strSchedule, new EV_SCHChangeStatus());
		}catch (Exception e){
            Test.stopTest();
			System.assertEquals(e.getMessage()==null, true, 'Test');
		}
        }
    }
    
    @isTest
	private static void testChangeStatusPublicoValidado() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];

		Test.startTest();
        Campaign cmp = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c,EV_Notification__c, Status FROM Campaign LIMIT 1];
        Time now = datetime.now().time();
        
		cmp.Status = '008';
        //cmp.EV_DiaHora_evento__c = datetime.now();
        cmp.EV_DiaHora_evento__c = Datetime.newInstance(2022, 10, 19, 09, 55, 0);
        //cmp.EV_HoraInicio__c = Time.newInstance(now.hour()-2, now.minute()-5, 00, 00);
        //cmp.EV_HoraFin__c = Time.newInstance(Integer.valueof(now.hour()-1), now.minute(), 00, 00);
        //cmp.EV_FechaHoraFin__c = datetime.now().addhours(+2);
        cmp.EV_HoraInicio__c = Time.newInstance(08, 55, 00, 00);
        cmp.EV_HoraFin__c = Time.newInstance(10, 00, 00, 00);
        cmp.EV_FechaHoraFin__c = Datetime.newInstance(2022, 10, 19, 12, 00, 0);
		cmp.EV_Notification__c = '003';
		update cmp;
        
		System.assertEquals('008', cmp.Status);
        
        Datetime inicio = datetime.now().addminutes(15);
        String strSchedule = '0 ' + inicio.minute() + ' ' + inicio.hour() + ' ' + inicio.day() + ' ' + inicio.month() + ' ?' + ' ' + inicio.year();
        System.runAs(user)
        {  
        try{
            Campaign cmp2 = [SELECT Id, EV_DiaHora_evento__c,EV_FechaHoraFin__c, Status FROM Campaign LIMIT 1];
        	System.schedule('Job Schedule', strSchedule, new EV_SCHChangeStatus());
		}catch (Exception e){
            Test.stopTest();
			System.assertEquals(e.getMessage()==null, true, 'Test');
		}
        }
    }
}