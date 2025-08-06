/**********************************************************************************************************************
Name:	  CIBE_CustomCalendar_Controller
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_CustomCalendar
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US593161		Luis Fernández 	    15/04/2023		Init version added retrieveEvents
***********************************************************************************************************************/

public without sharing class CIBE_CustomCalendar_Controller {
  
   	/**
	 * Get events for the selected date and user
	 * @param eventDate	-> selected date
	 * @param userId	-> selected employee
	 * @return			-> return string json with existing events
     * 
	 */
	@AuraEnabled
	public static List<Event> retrieveEvents(String userId,String dateDay) {
		if(String.isNotBlank(userId)) {
				String[] dateNumbers = dateDay.split('-');
				Integer year = Integer.valueOf(dateNumbers[0]);
				Integer month = Integer.valueOf(dateNumbers[1]);
				Integer day = Integer.valueOf(dateNumbers[2]);
				Date parsedDate = date.newInstance(year, month, day);
				Date startWeek = parsedDate.toStartOfWeek();
				Date endWeek = startWeek.addDays(4);
				Set<String> rts = new Set<String>{
                CIBE_AppConstants.EVENT_CLIENTE_RT,
                CIBE_AppConstants.EVENT_GESTOR_RT
            };    
                
            List<Event> evtList = [SELECT Subject, StartDateTime, EndDateTime, RecordType.DeveloperName, Account.Name
                                    FROM Event WHERE OwnerId = :userId 
                                    AND RecordType.DeveloperName In :rts
                                    AND ActivityDate >= :startWeek AND ActivityDate <= :endWeek];
			return evtList;
		}
		return null;
	}


	/**
	 * Get events for the selected date and user
	 * @param eventDate	-> selected date
	 * @param userId	-> selected employee
	 * @return			-> return string json with existing events
     * 
	 */
	@AuraEnabled
	public static List<Event> retrieveEventsCIB(String userId,String dateDay) {
		if(String.isNotBlank(userId)) {
				String[] dateNumbers = dateDay.split('-');
				Integer year = Integer.valueOf(dateNumbers[0]);
				Integer month = Integer.valueOf(dateNumbers[1]);
				Integer day = Integer.valueOf(dateNumbers[2]);
				Date parsedDate = date.newInstance(year,month,day);
				Date startWeek = parsedDate.toStartOfWeek();
				Date endWeek = startWeek.addDays(4);
				Set<String> rts = new Set<String>{
					CIBE_AppConstants.EVENT_CLIENTE_CIB_RT,
                	CIBE_AppConstants.EVENT_GESTOR_CIB_RT,
					CIBE_AppConstants.EVENT_GESTOR_RT
        };    
                
		List<Event> evtList = [SELECT Subject, StartDateTime, EndDateTime, RecordType.DeveloperName, Account.Name
								FROM Event WHERE OwnerId = :userId 
								AND RecordType.DeveloperName In :rts
								AND ActivityDate >= :startWeek AND ActivityDate <= :endWeek];
		return evtList;
		}
		return null;
	}

	/**
	* Get events for the selected date and user
	* @param eventDate		-> selected date
	* @param userId			-> selected employee
	* @return				-> return string json with existing events
	* 
	*/
	@AuraEnabled
	public static List<Event> retrieveEventsWeek(String userId,String dateDay) {
		if(String.isNotBlank(userId)) {
				String[] dateNumbers = dateDay.split('-');
				Integer year = Integer.valueOf(dateNumbers[0]);
				Integer month = Integer.valueOf(dateNumbers[1]);
				Integer day = Integer.valueOf(dateNumbers[2]);
				Date parsedDate = date.newInstance(year,month,day);
				Date startWeek = parsedDate.toStartOfWeek();
				Date endWeek = startWeek.addDays(6);
				Set<String> rts = new Set<String>{
				CIBE_AppConstants.EVENT_CLIENTE_RT,
				CIBE_AppConstants.EVENT_GESTOR_RT
			};    
				
			List<Event> evtList = [SELECT Subject, StartDateTime, EndDateTime, RecordType.DeveloperName, Account.Name
									FROM Event WHERE OwnerId = :userId 
									AND RecordType.DeveloperName In :rts
									AND ActivityDate >= :startWeek AND ActivityDate <= :endWeek];
			return evtList;
		}
		return null;
	}

	/**
	* Get events for the selected date and user
	* @param eventDate		-> selected date
	* @param userId			-> selected employee
	* @return				-> return string json with existing events
    * 
	*/
	@AuraEnabled
	public static List<Event> retrieveEventsMonth(String userId,String dateDay) {
		if(String.isNotBlank(userId)) {
				String[] dateNumbers = dateDay.split('-');
				Integer year = Integer.valueOf(dateNumbers[0]);
				Integer month = Integer.valueOf(dateNumbers[1]);
				Integer day = Integer.valueOf(dateNumbers[2]);
				Date parsedDateStart = date.newInstance(year,month,1);
				Date parsedDateEnd = date.newInstance(year,month +1 , 1);
				/*Date startWeek = parsedDate.toStartOfWeek();
				Date endWeek = startWeek.addDays(4);*/
				Set<String> rts = new Set<String>{
                CIBE_AppConstants.EVENT_CLIENTE_RT,
                CIBE_AppConstants.EVENT_GESTOR_RT
            };    
                
            List<Event> evtList = [SELECT Subject, StartDateTime, EndDateTime, RecordType.DeveloperName, Account.Name
                                    FROM Event WHERE OwnerId = :userId 
                                    AND RecordType.DeveloperName In :rts
                                    AND ActivityDate >= :parsedDateStart AND ActivityDate < :parsedDateEnd];
			return evtList;
		}
		return null;
	}

}