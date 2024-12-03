/**********************************************************************************************************************
 Name:	  AV_NewEventCalendar_Controller_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Test class for AV_NewEventCalendar_Controller
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US135429			Álvaro López		11/12/2020			Init version
	1.1 		FIX					Luis Fernández		12/07/2022			Changed AV_Query to SOQL query

***********************************************************************************************************************/
@isTest
public with sharing class AV_NewEventCalendar_Controller_Test {

	@TestSetup
	static void makeData(){
		Account dummyAcc = AV_TestHelper.createCustomer();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        User dummyUser = AV_TestHelper.createUser(null);
        Account dummyCenter = AV_TestHelper.createCaixaCenter();
        Contact dummyCon = AV_TestHelper.createEmployee(dummyCenter, dummyUser);
        Event dummyEv = AV_TestHelper.createEvent(dummyUser, System.now().addHours(1), dummyAcc);
	}
    
    @isTest
	public static void getSelectionTime() {
		Test.startTest();
		List<Map<String, String>> listRes = (List<Map<String, String>>)JSON.deserialize(AV_NewEventCalendar_Controller.getSelectionTime(), List<Map<String, String>>.class);
		Test.stopTest();
		System.assertEquals(false, listRes.isEmpty(), 'La lista de horas está vacía.');
	}

	@isTest
	public static void getWorkingTimeTest() {
		Test.startTest();
		List<Map<String, String>> listRes = (List<Map<String, String>>)JSON.deserialize(AV_NewEventCalendar_Controller.getWorkingTime(30), List<Map<String, String>>.class);
		Test.stopTest();
		System.assertEquals(false, listRes.isEmpty(), 'La lista de horas está vacía.');
	}

	@isTest
	public static void getCalendarHalfHourRangeTest() {
		Test.startTest();
		List<String> listRes = (List<String>)JSON.deserialize(AV_NewEventCalendar_Controller.getCalendarHalfHourRange(), List<String>.class);
		Test.stopTest();
		System.assertEquals(false, listRes.isEmpty(), 'La lista de horas está vacía.');
	}

	@isTest
	public static void formatStartAndEndTimesTest() {

		String startTime = '10:00';
		String endTime = '11:00';
		String eventDate = '2020-11-12';

		Test.startTest();
		Map<String, DateTime> mapRes = (Map<String, DateTime>)JSON.deserialize(AV_NewEventCalendar_Controller.formatStartAndEndTimes(eventDate, startTime, endTime), Map<String, DateTime>.class);
		Test.stopTest();

		String[] sTimeSplit = startTime.split(':');
		Time sTime = Time.newInstance(Integer.valueOf(sTimeSplit[0]), Integer.valueOf(sTimeSplit[1]), 0, 0);
		Date evDate = Date.valueOf(eventDate);
		DateTime eventStartDate = DateTime.newInstance(evDate, sTime);
		System.assertEquals(eventStartDate, mapRes.get('sTime'), 'El formato de fecha/hora no es correcto.');
	}

	@isTest
	public static void retrieveEventsTest() {
		String eventDate = '2020-11-12';

		// Event ev = (Event)new AV_Query('Event').selectFields('DurationInMinutes, ActivityDate, StartDateTime, EndDateTime, Subject, Description, Account.Name, OwnerId')
		// 								.setLimit(1)
		// 								.fetch();
		Event ev = [SELECT DurationInMinutes, ActivityDate, StartDateTime, EndDateTime, Subject, Description, Account.Name, OwnerId 
		FROM Event LIMIT 1];
		
		Test.startTest();
		List<AV_NewEventCalendar_Controller.CalendarEvent> listRes = (List<AV_NewEventCalendar_Controller.CalendarEvent>)JSON.deserialize(AV_NewEventCalendar_Controller.retrieveEvents(String.valueOf(ev.ActivityDate), ev.OwnerId), List<AV_NewEventCalendar_Controller.CalendarEvent>.class);
		Test.stopTest();

		System.assertEquals(ev.Subject, listRes[0].subject, 'El asunto de los eventos no es el mismo.');
	}
}