/**********************************************************************************************************************
 Name:	  CIBE_ForbiddenWords
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class for checking forbidden words
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            AUTHOR		   		DATE				Description
	1.0			SF - Palabras prohibidas.		    Luis Martínez	   	    05/06/2024		    Init version

***********************************************************************************************************************/
public with sharing class CIBE_ForbiddenWords {
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
		
		if(Schema.sObjectType.CBK_ForbiddenWord__c.isAccessible()) {
			listAllWords = [SELECT 	CBK_EXPRES__c 
							FROM CBK_ForbiddenWord__c 
							WHERE 	CBK_IsActive__c = true AND CBK_EXPRES__c != null AND CBK_TIPAVI__c != null];
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
	* @param oppoWrappedList Oportunity Object map to validate 
	* @param setFields field set to validate Opportunity
	* @param taskWrappedList Task Object map list to validate
	* @param setFieldsTask field set to validate Task
	*/
    @AuraEnabled
	public static String validateRecords(Map<String,Map<String,Object>> oppoWrappedList,Map<String,Map<String,Object>> taskWrappedList, List<String> setFields, List<String> setFieldsTask) {
        List<Opportunity> listRecordsOpp = new List<Opportunity>();
		List<Task> listRecordsTask = new List<Task>();
		String respuesta = 'Error: ' + Label.AV_ForbiddenWordsErrorMessage + ' ';

		Map<String, CBK_ForbiddenWord__c> mapForbiddenWords = fetchForbiddenWords();
		Map<String, List<CBK_ForbiddenWord__c>> mapRecWords = new Map<String, List<CBK_ForbiddenWord__c>>();
		if(oppoWrappedList!=null && !oppoWrappedList.isEmpty()){
			for(Map<String,Object> wrappedOppo : oppoWrappedList.Values()){
					Opportunity nextOpp = new Opportunity();
					nextOpp.Name = (String) wrappedOppo.get('Name');
					if( (String) wrappedOppo.get('comentario') != ''){
						nextOpp.AV_Comentarios__c =  (String) wrappedOppo.get('comentario');
					}
					listRecordsOpp.add(nextOpp);
			}
			if( !listRecordsOpp.isEmpty()){
				for(Opportunity rec : listRecordsOpp) {
					String result = '';
					for(String field : setFields) {
						String fieldValue = (String)rec.get(field);
						if(String.isNotBlank(fieldValue)) {
							result += transformWords(fieldValue) + ' ';
						}
					}
					if(String.isNotBlank(result) && mapForbiddenWords != null && !mapForbiddenWords.values().isEmpty()){
						List<CBK_ForbiddenWord__c> listFW = validateExpr(result, mapForbiddenWords/*listAllFW*/);
						if(!listFW.isEmpty()) {
							mapRecWords.put(rec.Name, listFW);
						}
					}
				}
			}
		}

		if(taskWrappedList!=null && !taskWrappedList.isEmpty()){
			for(Map<String,Object> wrapped : taskWrappedList.Values()){
					Task nextTask = new Task();
					nextTask.subject = (String) wrapped.get('subject');
					nextTask.Description = (String) wrapped.get('comentario');
					listRecordsTask.add(nextTask);
			}

			if(!listRecordsTask.isEmpty()){
				for(Task rec : listRecordsTask) {
					String result = '';
					for(String field : setFieldsTask) {
						String fieldValue = (String)rec.get(field);
						if(String.isNotBlank(fieldValue)) {
							result += transformWords(fieldValue) + ' ';
						}
					}
					if(String.isNotBlank(result) && mapForbiddenWords != null && !mapForbiddenWords.values().isEmpty()){
						List<CBK_ForbiddenWord__c> listFW = validateExpr(result, mapForbiddenWords/*listAllFW*/);
						if(!listFW.isEmpty()) {
							mapRecWords.put(rec.subject, listFW);
						}
					}
				}
			}
		}

		if(mapRecWords != null && !mapRecWords.values().isEmpty()) {
			//Loop for building message
			for(String recId : mapRecWords.keySet()) {
				for(Integer i=0; i<mapRecWords.get(recId).size(); i++) {
					respuesta += mapRecWords.get(recId)[i].CBK_EXPRES__c + ' , ';
				}	
			}
			return respuesta.removeEnd(', ');
		}
		return 'OK';
	}
}