/**********************************************************************************************************************
 Name:	  AV_NewEventCalendar_Controller
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for LWC Av_NewEventCalendar
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US135429			Álvaro López		01/12/2020			Init version
	1.1			DE41791				Álvaro López		16/02/2021			Changed retrieveEvents method
	1.2			Fix performance		Carolina Alonso		21/10/2021			Fix performance in the method retrieveEvents
***********************************************************************************************************************/
public with sharing class AV_NewEventCalendar_Controller {

	/**
	 * Build time ranges based on the selected event duration
	 * @param range	-> Event durantion in minutes
	 * @return		-> return the string json with all the available options
	 */
	@AuraEnabled
	public static String getWorkingTime(Integer range) {
		Integer timeRange = range;
		Time startTime = Time.newInstance(8, 0, 0, 0);
		Time endTime = Time.newInstance(18, 0, 0, 0);
		List<Map<String, String>> lstTime = new List<Map<String, String>>();
		while(startTime.addMinutes(timeRange) <= endTime){
			Time auxEndTime = startTime.addMinutes(timeRange);
			String startTimeText = formatTimeText(startTime, true, true);
			String auxEndTimeText = formatTimeText(auxEndTime, true, true);
			lstTime.add(new Map<String, String>{'startTime'=>startTimeText, 'endTime'=>auxEndTimeText});
			startTime = startTime.addMinutes(15);
			
		}
		return JSON.serialize(lstTime);
	}


	/**
	 * Build time ranges based on the selected event duration
	 * @param range	-> Event durantion in minutes
	 * @return		-> return the string json with all the available options
	 */
	@AuraEnabled
	public static String getSelectionTime() {
		Integer timeRange = 1;
		Time startTime = Time.newInstance(7, 0, 0, 0);
		Time endTime = Time.newInstance(22, 0, 0, 0);
		List<Map<String, String>> lstTime = new List<Map<String, String>>();
		while(startTime.addMinutes(timeRange) <= endTime){
			Time auxEndTime = startTime.addMinutes(timeRange);
			String startTimeText = formatTimeText(startTime, true, true);
			String auxEndTimeText = formatTimeText(auxEndTime, true, true);
			lstTime.add(new Map<String, String>{'startTime'=>startTimeText, 'endTime'=>auxEndTimeText});
			startTime = startTime.addMinutes(timeRange);
		}
		return JSON.serialize(lstTime);
	}

	/**
	 * Build table calendar with users business hours
	 * @param 	-> no params
	 * @return		-> return string json with the list of times every half hour
	 */
	@AuraEnabled
	public static String getCalendarHalfHourRange() {
		Time startTime = Time.newInstance(7, 0, 0, 0);
		Time endTime = Time.newInstance(22, 0, 0, 0);
		List<String> lstTime = new List<String>();
		while(startTime <= endTime){
			String timeText = formatTimeText(startTime, true, true);
			lstTime.add(timeText);
			startTime = startTime.addMinutes(30);
		}
		return JSON.serialize(lstTime);
	}

	/**
	 * Get events for the selected date and user
	 * @param eventDate	-> selected date
	 * @param userId	-> selected employee
	 * @return		-> return string json with existing events
	 */
	@AuraEnabled
	public static String retrieveEvents(String eventDate, String userId) {
		if(String.isNotBlank(eventDate) && String.isNotBlank(userId)) {
			List<Event> listEvents = AV_UserEventsHelper.getUserEvents(eventDate, userId);

			if(listEvents != null && !listEvents.isEmpty()) {
				List<CalendarEvent> listCalEv = new List<CalendarEvent>();
				for(Event ev : listEvents) {
					CalendarEvent calEv = new CalendarEvent();
					calEv.duration = ev.DurationInMinutes;
					calEv.subject = ev.Subject;
					calEv.startTime = ev.StartDateTime.format('kk:mm');
					calEv.endTime = ev.EndDateTime.format('kk:mm');
					calEv.clientName = ev.Account.Name;
					listCalEv.add(calEv);
				}
				return JSON.serialize(listCalEv);
			}
		}
		return null;
	}

	/**
	 * Format datetime selection in order to create event record throw the flow process
	 * @param eventDate	-> selected date
	 * @param startTime	-> string selected startdate
	 * @param endTime	-> string selected enddate
	 * @return		-> return json string with formated start and end datetime
	 */
	@AuraEnabled
	public static String formatStartAndEndTimes(String eventDate, String startTime, String endTime) {

		if(String.isNotBlank(eventDate) && String.isNotBlank(startTime) && String.isNotBlank(endTime)) {
			String[] sTimeSplit = startTime.split(':');
			String[] eTimeSplit = endTime.split(':');
			Time sTime = Time.newInstance(Integer.valueOf(sTimeSplit[0]), Integer.valueOf(sTimeSplit[1]), 0, 0);
			Time eTime = Time.newInstance(Integer.valueOf(eTimeSplit[0]), Integer.valueOf(eTimeSplit[1]), 0, 0);

			Date evDate = Date.valueOf(eventDate);

			DateTime eventStartDate = DateTime.newInstance(evDate, sTime);
			DateTime eventEndDate = DateTime.newInstance(evDate, eTime);

			Map<String, DateTime> mapDateTimes = new Map<String, DateTime>{'sTime' => eventStartDate, 'eTime' => eventEndDate};

			return JSON.serialize(mapDateTimes);
		}

		return null;
	}

	/**
	 * Format time strings with left zeros
	 * @param value	-> time value
	 * @param hs	-> boolean that determines if hours have to be formatted
	 * @param mins	-> boolean that determines if minutes have to be formatted
	 * @return		-> return the formatted time text
	 */
	private static String formatTimeText(Time value, Boolean hs, Boolean mins) {
		if(value != null) {
			String hours = hs ? AV_IntegrationUtilities.leftPadZero(String.valueOf(value.hour()), 2) : String.valueOf(value.hour());
			String minutes = mins ? AV_IntegrationUtilities.leftPadZero(String.valueOf(value.minute()), 2) : String.valueOf(value.minute());
			String timeText = hours + ':' + minutes;

			return timeText;
		}
		return null;
	}

	public class CalendarEvent {
		@AuraEnabled
		public Integer duration;
		@AuraEnabled
		public String startTime;
		@AuraEnabled
		public String endTime;
		@AuraEnabled
		public String subject;
		@AuraEnabled
		public String clientName;
	}
}