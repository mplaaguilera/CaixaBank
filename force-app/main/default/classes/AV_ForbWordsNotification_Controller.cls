/**********************************************************************************************************************
Name:		AV_ForbWordsNotification_Controller
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Controller class of "Av_Forb_Words_Notification" lwc
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY								AUTHOR				DATE			Description
1.0			Palabras prohibidas						Álvaro López		16/11/2020		Init version
1.1		    AV_Query IT	        					Daniel Rodríguez    07/03/2022	    Change AV_Query to SOQL for User, Account, Contact
***********************************************************************************************************************/
public with sharing class AV_ForbWordsNotification_Controller {

	/**
	* Method that validates if the record has forbidden words and returns the the warning message if true
	*
	* @param recordId recordId
	* @param objectName object api name for query
	* @return String warning message
	*/
	@AuraEnabled
	public static String retrieveMessage(String recordId, String objectName){
		if(String.isNotBlank(recordId) && String.isNotBlank(objectName)) {
			String IdRecord = '\''+recordId+'\'';
			String query = 'Select Id,CBK_ForbiddenWords__c from ' +objectName +' where id = '+IdRecord +' limit 1';
			String fieldName = 'CBK_ForbiddenWords__c';
			SObject so = Schema.getGlobalDescribe().get(objectName).newSObject();
			so = Database.query(query);
			String words = so != null ? (String) so.get(fieldName) : 'null'; 			
			system.debug('@@words '+ words);
			//String words = so.CBK_ForbiddenWords__c;
			/*String words = (String) new AV_Query(objectName)
											.selectField('CBK_ForbiddenWords__c')
											.addConditionEq('Id', recordId)
											.fetch()
											.get('CBK_ForbiddenWords__c');*/
			
			if(String.isNotBlank(words)) {
				Id recId = Id.valueOf(recordId);
				SObject rec = recId.getSObjectType().newSObject(recId);
				rec.put('CBK_ForbiddenWords__c', null);

				//Cleaning CBK_ForbiddenWords__c field for the next validation
				Database.SaveResult srRec = Database.update(rec, false);
				if (!srRec.isSuccess()) {
					// Operation failed, so get all errors         
					for(Database.Error err : srRec.getErrors()) {
						AV_LogDebug.printLogDebug('retrieveMessage', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
					}
				}
				//Building and returning message
				return Label.AV_ForbiddenWordsMessage1 + ' ' + words + Label.AV_ForbiddenWordsMessage2;
			}
		}
		return 'KO';
	}
}