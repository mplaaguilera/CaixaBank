/**********************************************************************************************************************
 Name:	  AV_UserEventsHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Helper for class AV_NewEventCalendar_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			DE41791			Álvaro López		01/12/2020			Init version
	1.1         US592987		Ángel Medina		30/05/2023			Changed AV_Query to SOQL queries
***********************************************************************************************************************/
public without sharing class AV_UserEventsHelper {

	/**
	 * Get events for the selected date and user
	 * @param eventDate	-> selected date
	 * @param userId	-> selected employee
	 * @return		-> return list of existing events
	 */
	public static List<Event> getUserEvents(String eventDate, String userId) {
		List<Event> listEvents = [SELECT DurationInMinutes, ActivityDate, StartDateTime, EndDateTime, Subject, Description, Account.Name FROM Event WHERE OwnerId = :userId AND ActivityDate = :Date.valueOf(eventDate)];
		
		return listEvents;
	}
}