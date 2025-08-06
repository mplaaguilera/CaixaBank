/**********************************************************************************************************************
 Name:      AV_LookUpFlow_Controller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for AV_LookUpFlow LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				DATE            Description
   	1.0      Initial				Alex Campos		    27/10/2022      Init version

***********************************************************************************************************************/
public with sharing class CIBE_LookUpFlow_Controller {

	private final static Integer MAX_RESULTS 	= 10;
	private final static Id RTAPODERADOS = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_Apoderado').getRecordTypeId();
	private final static Id RTCOMERCIAL = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();


	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> search(String searchTerm, List<String> selectedIds, String condition, String title, String subtitle, String objectName, String icon) {
		System.debug(searchTerm);
		System.debug(selectedIds);
		
		String methodName = 'search';
		searchTerm += '*';
		String avQuery;
		List<String> listIds = new List<String>();

		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		//if(searchTerm.equalsIgnoreCase('Null*')){
		if(!selectedIds.isEmpty()){
			if(condition != null){
				avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING '+objectName+'(Id,'+title+','+subtitle+' WHERE (RecordTypeId =:RTAPODERADOS OR  RecordTypeId =:RTCOMERCIAL) AND Id NOT IN :selectedIds and AccountId = :condition) LIMIT :MAX_RESULTS';
				AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
				searchResults = search.query(avQuery);
			}
			else{
				avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING '+objectName+'(Id,'+title+','+subtitle+' WHERE (RecordTypeId =:RTAPODERADOS OR  RecordTypeId =:RTCOMERCIAL) AND Id NOT IN :selectedIds) LIMIT :MAX_RESULTS';
				AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
				searchResults = search.query(avQuery);
			}
		}
		else{
			if(condition != null){
				avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING '+objectName+'(Id,'+title+','+subtitle+' WHERE (RecordTypeId =:RTAPODERADOS OR  RecordTypeId =:RTCOMERCIAL) AND AccountId = :condition) LIMIT :MAX_RESULTS';
				AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
				searchResults = search.query(avQuery); 
			}
			else{
				avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING '+objectName+'(Id,'+title+','+subtitle+' WHERE (RecordTypeId =:RTAPODERADOS OR  RecordTypeId =:RTCOMERCIAL)) LIMIT :MAX_RESULTS';
				AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
				searchResults = search.query(avQuery);
			}
		}
        if(searchResults!=null) {
            SObject[] listProduct = (List<SObject>) searchResults[0];
            for (SObject p : listProduct) {
                results.add(new AV_LookupSearchResult(p.Id,objectName,icon,p.get(title).toString(),''));
				listIds.add(p.Id);
            }
            results.sort();
        }
		//}

		String contactAccount ='Select Id, '+String.escapeSingleQuotes(title)+','+String.escapeSingleQuotes(subtitle)+' FROM '+String.escapeSingleQuotes(objectName);
		if(condition != null) {
			contactAccount ='Select Id, '+String.escapeSingleQuotes(title)+','+String.escapeSingleQuotes(subtitle)+' FROM '+String.escapeSingleQuotes(objectName)+' WHERE (RecordTypeId =:RTAPODERADOS OR  RecordTypeId =:RTCOMERCIAL) and AccountId = :condition';
		}
		if (!listIds.isEmpty()) {
            System.debug('listIds --> ' + listIds);
			if(condition != null){
				contactAccount ='Select Id, '+String.escapeSingleQuotes(title)+','+String.escapeSingleQuotes(subtitle)+' FROM '+String.escapeSingleQuotes(objectName)+' WHERE (RecordTypeId =:RTAPODERADOS OR  RecordTypeId =:RTCOMERCIAL) AND Id NOT IN :listIds and AccountId = :condition';
			} else {
				contactAccount ='Select Id, '+String.escapeSingleQuotes(title)+','+String.escapeSingleQuotes(subtitle)+' FROM '+String.escapeSingleQuotes(objectName)+' WHERE (RecordTypeId =:RTAPODERADOS OR  RecordTypeId =:RTCOMERCIAL) AND Id NOT IN :listIds';
			}
		}
		System.debug('contactAccount --> ' + contactAccount);

		List<SObject> listContact=(List<SObject>) Database.query(contactAccount);
		if(!listContact.isEmpty()) {
            for (SObject p : listContact) {
                results.add(new AV_LookupSearchResult(p.Id, objectName, icon, p.get(title).toString(), ''));
            }
        }

		return results;
	}
}