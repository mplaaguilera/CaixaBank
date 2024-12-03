/**********************************************************************************************************************
Name:	  AV_CustomCalendar_Controller
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_CustomCalendar
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US593161		Luis Fernández 	    15/04/2023		Init version added retrieveEvents
	1.1			US723518		Sandra Gómez		10/11/2023		Add saturday in method retrieveEvents
***********************************************************************************************************************/

public without sharing class AV_CustomCalendar_Controller {
  
	/**
  * Get events for the selected date and user
  * @param eventDate	-> selected date
  * @param userId	-> selected employee
  * @return		-> return string json with existing events
  * 
  */
 @AuraEnabled
 public static List<Event> retrieveEvents(String userId,String dateDay) {
	 if(String.isNotBlank(userId)) {
			 String[] dateNumbers = dateDay.split('-');
			 Integer year = Integer.valueOf(dateNumbers[0]);
			 Integer month = Integer.valueOf(dateNumbers[1]);
			 Integer day = Integer.valueOf(dateNumbers[2]);
			 Date parsedDate = date.newInstance(year,month,day);
			 Date startWeek = parsedDate.toStartOfWeek();
			 Date endWeek = startWeek.addDays(5);
			 Set<String> rts = new Set<String>{
			 AV_AppConstants.EVENTCLIENTE_RT,
			 AV_AppConstants.EVENTGESTOR_RT
		 };
		 List<Event> evtList =  [SELECT Subject,StartDateTime,EndDateTime,RecordType.DeveloperName FROM Event WHERE OwnerId = :userId 
		 and RecordType.DeveloperName In :rts
		 AND ActivityDate >= :startWeek AND ActivityDate <= :endWeek ];
		 return evtList;
	 }
	 return null;
 }
}