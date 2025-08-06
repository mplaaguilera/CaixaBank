/**********************************************************************************************************************
 Name:	  AV_FrobiddenWords
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class for checking forbidden words
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            AUTHOR		   		DATE				Description
	1.0			SF - Palabras prohibidas. Error		    Álvaro López	   	05/10/2020		    Init version
	1.2			SF - Palabras prohibidas. Error			Álvaro López		10/11/2020			Change API names
	1.3			SF - Palabras prohibidas. Error			Álvaro López		10/11/2020			Added condition for CBK_TIPAVI__c null
	1.4			SF - Palabras prohibidas. Error			Álvaro López		16/11/2020			Change for not publishing platform events anymore
	1.5			Fix error								Álvaro López		29/01/2020			Fix error in bulk
	1.6		    AV_Query IT	        					Daniel Rodríguez    07/03/2022	        Change AV_Query to SOQL for User, Account, Contact
***********************************************************************************************************************/
public with sharing class AV_ForbiddenWords {
    
	/**
	* Method that returns a list of forbidden words based on a string
	*
	* @param str String to validate
	* @return CBK_ForbiddenWord__c records list
	*/
    public static List<CBK_ForbiddenWord__c> validateExpr(String str) {
		if(String.isBlank(str)) {
			return new List<CBK_ForbiddenWord__c>();
		}

        Map<String, CBK_ForbiddenWord__c> mapForbiddenWords = fetchForbiddenWords();

        List<CBK_ForbiddenWord__c> listResult = new List<CBK_ForbiddenWord__c>();
		if(!mapForbiddenWords.isEmpty()) {
			Set<String> setWords = new Set<String>(str.split(' '));
			for(String word : setWords) {
                if(mapForbiddenWords.containsKey(word)) {
                    listResult.add(mapForbiddenWords.get(word));
                }
            }
        }
		return listResult;
	}

	/**
	* Method that returns a list of forbidden words based on a string
	*
	* @param str String to validate
	* @param mapForbiddenWords Map<String, CBK_ForbiddenWord__c> Map of forbidden words
	* @return CBK_ForbiddenWord__c records list
	*/
    public static List<CBK_ForbiddenWord__c> validateExpr(String str, Map<String, CBK_ForbiddenWord__c> mapForbiddenWords) {
        if(String.isBlank(str) || mapForbiddenWords == null || mapForbiddenWords.isEmpty()) {
			return new List<CBK_ForbiddenWord__c>();
		}

        List<CBK_ForbiddenWord__c> listResult = new List<CBK_ForbiddenWord__c>();
		if(!mapForbiddenWords.isEmpty()) {
			Set<String> setWords = new Set<String>(str.split(' '));
			for(String word : setWords) {
                if(mapForbiddenWords.containsKey(word)) {
                    listResult.add(mapForbiddenWords.get(word));
                }
            }
        }
		return listResult;
	}

	/**
	* Method that returns a list of all active forbidden words in Salesforce
	*
	* @return CBK_ForbiddenWord__c records list
	*/
	public static Map<String, CBK_ForbiddenWord__c> fetchForbiddenWords() {
		List<CBK_ForbiddenWord__c> listAllWords = new List<CBK_ForbiddenWord__c>();
		if(CBK_ForbiddenWord__c.SObjectType.getDescribe().isAccessible()) {
			listAllWords = [SELECT 	CBK_EXPRES__c, 
									CBK_TIPAVI__c 
							FROM CBK_ForbiddenWord__c 
							WHERE 	CBK_IsActive__c = true
									AND CBK_EXPRES__c != null 
									AND CBK_TIPAVI__c != null];
		}

		Map<String, CBK_ForbiddenWord__c> mapForbiddenWords = new Map<String, CBK_ForbiddenWord__c>();
		for(CBK_ForbiddenWord__c fw : listAllWords) {
            mapForbiddenWords.put(fw.CBK_EXPRES__c, fw);
        }
		return mapForbiddenWords;
	}

	/**
	* Method that extracts accents and diacritics from the word and normalizes them
	* @param word
	* @return normal word
	*/
	public static String transformWords(String cadena) {
		String result = '';
		String upperString = cadena.toUpperCase();
		String substi = 'ABCÇDEFGHIJKLMNÑOPQRSTUVWXYZÁÀÄÉÈËÍÌÏÓÒÖÚÙÜ ';

		for (Integer i=0; i<upperString.length(); i++) {
			Boolean charOK = false;
			for (Integer j=0; j<substi.length(); j++) {
				if(upperString.substring(i, i+1) == substi.substring(j, j+1)){
					charOK = true;
				}
			}
			if(charOK) {
				result = result + upperString.substring(i, i+1);
			}else{
				result = result + ' ';
			}
		}

		String original = 'ÁÀÄÉÈËÍÌÏÓÒÖÚÙÜ';
		String ascii = 'AAAEEEIIIOOOUUU';
		String output = result;
				
		if (original.length()==15){ 
			for (Integer i=0; i<original.length(); i++) {
				output = output.replace(original.substring(i, i+1), ascii.substring(i, i+1));
			}
		} 			
	    return output;
    }

	/**
	* Method that validates a specific record field set and shows alerts according to the words found in those fields
	*
	* @param listRecords records list to validate
	* @param setFields field set to validate
	*/
	@invocableMethod(label='validateMessages')
	public static List<String> validateMessages(List<List<String>> listStrings) {
		String fullText = '';
		for(List<String> fields : listStrings) {
			for(String field : fields) {
				if(String.isNotBlank(field)) {
					fullText += (' ' + field);
				}
			}
		}

		List<String> result = new List<String>{'OK'};
		if(String.isNotBlank(fullText)) {
			fullText = AV_StripAccents.stripAccents(fullText).toUpperCase();

			List<CBK_ForbiddenWord__c> forbiddens = validateExpr(fullText);
			if(!forbiddens.isEmpty()) {
				result = new List<String>();
				Set<String> errors = new Set<String>();
				Set<String> warnings = new Set<String>();
				for(CBK_ForbiddenWord__c forbidden : forbiddens) {
					if(forbidden.CBK_TIPAVI__c.equalsIgnoreCase('E')) {
						errors.add(forbidden.CBK_EXPRES__c);
					} else if(forbidden.CBK_TIPAVI__c.equalsIgnoreCase('A')) {
						warnings.add(forbidden.CBK_EXPRES__c);
					}
				}

				if(!errors.isEmpty()) {
					result.add('Error: ' + Label.AV_ForbiddenWordsErrorMessage + ' ' + String.join(new List<String>(errors), ', ') + Label.AV_ForbiddenWordsMessage2);
				} else if(!warnings.isEmpty()) {
					result.add(Label.AV_ForbiddenWordsMessage1 + ' ' + String.join(new List<String>(warnings), ', ') + Label.AV_ForbiddenWordsMessage2);
				}
			}
		}
		System.debug(fullText);
		return result;
	}

	/**
	* Method that validates a specific record field set and shows alerts according to the words found in those fields
	*
	* @param listRecords records list to validate
	* @param setFields field set to validate
	*/
	public static void validateRecords(List<SObject> listRecords, Set<String> setFields) {
		Map<String, CBK_ForbiddenWord__c> mapForbiddenWords = AV_ForbiddenWords.fetchForbiddenWords();
		Map<String, SObject> mapRecords = new Map<String, SObject>();
		Map<String, List<CBK_ForbiddenWord__c>> mapRecWords = new Map<String, List<CBK_ForbiddenWord__c>>();
		
		for(SObject rec : listRecords) {
			String result = '';
			for(String field : setFields) {
				String fieldValue = (String)rec.get(field);
				if(String.isNotBlank(fieldValue)) {
					result += AV_ForbiddenWords.transformWords(fieldValue) + ' ';
				}
			}
			if(String.isNotBlank(result) && mapForbiddenWords != null && !mapForbiddenWords.values().isEmpty()){
				List<CBK_ForbiddenWord__c> listFW = AV_ForbiddenWords.validateExpr(result, mapForbiddenWords/*listAllFW*/);
				if(!listFW.isEmpty()) {
					mapRecords.put(rec.Id, rec);
					mapRecWords.put(rec.Id, listFW);
				}
			}
		}
		if(mapRecords != null && !mapRecords.values().isEmpty()) {
			List<ForbiddenWordMessage> listFWM = new List<ForbiddenWordMessage>();
			//Loop for building message
			for(String recId : mapRecords.keySet()) {
				String forbiddenWords = '';
				String warningMessage = '';
				
				for(Integer i=0; i<mapRecWords.get(recId).size(); i++) {
					if(String.isNotBlank(mapRecWords.get(recId)[i].CBK_TIPAVI__c)) {
						if(mapRecWords.get(recId)[i].CBK_TIPAVI__c.equalsIgnoreCase('E')) {
							if(i < mapRecWords.get(recId).size()-1) {
								forbiddenWords += mapRecWords.get(recId)[i].CBK_EXPRES__c + ', ';
							} else {
								forbiddenWords += mapRecWords.get(recId)[i].CBK_EXPRES__c;
							}
						} else if(mapRecWords.get(recId)[i].CBK_TIPAVI__c.equalsIgnoreCase('A')) {
							if(i < mapRecWords.get(recId).size()-1) {
								warningMessage += mapRecWords.get(recId)[i].CBK_EXPRES__c + ', ';
							} else {
								warningMessage += mapRecWords.get(recId)[i].CBK_EXPRES__c;
							}
						}
					}
				}
				ForbiddenWordMessage fwm = new ForbiddenWordMessage();
				fwm.errorRecord = mapRecords.get(recId);
				fwm.errorMessage = forbiddenWords;
				fwm.warningMessage = warningMessage;
				listFWM.add(fwm);				
			}
			
			if(!listFWM.isEmpty()) {
				//AV_LogDebug.printLogDebug('listFWM', 'Registros con palabras prohibidas: ' + listFWM.size());
				for(ForbiddenWordMessage fwm : listFWM) {
					AV_LogDebug.printLogDebug('Palabras prohibidas', 'Mensaje de error: ' + fwm.errorMessage + ' : ' + fwm.warningMessage);
					if(String.isNotBlank(fwm.errorMessage)) {
						fwm.errorRecord.addError(Label.AV_ForbiddenWordsErrorMessage + ' ' + fwm.errorMessage);
					} else if(String.isBlank(fwm.errorMessage) && String.isNotBlank(fwm.warningMessage)) {
						//Set 'CBK_ForbiddenWords__c' field in order to call the notification lwc
						fwm.errorRecord.put('CBK_ForbiddenWords__c', fwm.warningMessage);
					}
				}
			}
		}
	}

	private class ForbiddenWordMessage {
		private SObject errorRecord;
		private String errorMessage;
		private String warningMessage;
	}

}