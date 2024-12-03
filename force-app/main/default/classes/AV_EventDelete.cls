/**********************************************************************************************************************
 Name: AV_EventDelete
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Propósito: Clase llamada desde el Flow AV_Delete_Event para eliminar eventos
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            -                Jash             -                   Init version
   1.1            Fix Sync Events  Víctor Santiago  21/10/2021          Added delete event functionality
   1.2            Fix IOP Diciem   Víctor Santiago  14/12/2021          Recovered old code
   1.3		      AV_Query IT	   Daniel Rodríguez    03/03/2022	    Change AV_Query to SOQL for User, Account, Contact
   1.4            US385113         Alex Cubells     30/05/2022          Remove method deleteEventQueues 
   1.5		      FIX11070844	   Ángel Medina		11/07/2024			Fix error The Global modifier should be avoided.
***********************************************************************************************************************/
public with sharing class AV_EventDelete {

    @InvocableMethod(label='DeleteEvent')
    public static List<String> eventDeleteFromGCF(List<String> recId){
        String methodName = 'eventDeleteFromGCF';
        String recordId = recId.get(0).split(',')[0];
        List<Event> events = new List<Event>();
        Event e = [
            Select Id, OwnerId, WhatId, AV_ExternalID__c, AV_origenApp__c, RecordTypeId, Subject, Recurrence2PatternStartDate, IsRecurrence2
            From Event
            where Id = :recordId limit 1
        ];
        if (deleteSeries(recId)) {
            events = [
                Select Id, OwnerId, WhatId, AV_ExternalID__c, AV_origenApp__c, RecordTypeId, Subject, Recurrence2PatternStartDate,IsRecurrence2
                From Event where Subject = :e.Subject 
                and Recurrence2PatternStartDate = : e.Recurrence2PatternStartDate 
                and OwnerId = :e.OwnerId and WhatId =:e.WhatId
                and AV_origenApp__c = :e.AV_origenApp__c and RecordTypeId = :e.RecordTypeId
                FOR UPDATE
            ];
        } else {
            
            events.add(e);
        }
        Database.DeleteResult[] drList = Database.delete(events,false);
        if (drList[0].isSuccess()) {
            return new List<String>{'OK'};
        } else {
            return new List<String>{'KO'};
        }
    }

    /**
	 * @description		Checks whether the user wants to delete the whole series or just the event targeted
	 * @param flowInput	Input that arrives from the flow with the following format:
	 * 					'event_id,single_character' where single_character can be:
	 * 						- Y --> Delete the whole series
	 * 						- N --> Delete just the event targeted 
	 */
	private static Boolean deleteSeries(List<String> flowInput) {
        String[] input = flowInput.get(0).split(',');
        if (input.size() > 1 && 'Y'.equals(input[1])) {
            return true;
        } else {
            return false;
        }
    }
}