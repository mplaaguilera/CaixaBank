/**********************************************************************************************************************
 Name:      AV_LookUpFlow_Controller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for AV_LookUpFlow LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				DATE        Description
   	1.0      Initial				Sandra Gómez		29/09/2022  Init version
    1.1      Fix                    Elisabeth R.        27/01/2023  Fix listIds error
	1.2      US584626               Elisabeth R         05/05/2023  Delete 'OTROS' Contact from getContact result
	1.3      US609339               Oscar Moreno        16/10/2023  Parameters title,subtitle,objectName,icon and condition of the search method are deteled

***********************************************************************************************************************/
public with sharing class AV_LookUpFlow_Controller {

	private final static Integer MAX_RESULTS 	= 10;

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> search(String searchTerm, List<String> selectedIds, String idAcc) {
		String methodName = 'search';

		List<String> listIds = new List<String>();
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		String avQuery;
		
		if(searchTerm != null && searchTerm != '') {
			searchTerm += '*';
			if(!selectedIds.isEmpty()){	
				avQuery='FIND {'+String.escapeSingleQuotes(searchTerm)+'} IN ALL FIELDS RETURNING Contact (Id,Name,CC_CargoRepresentante__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = \'CC_Representante\' and AccountId = \''+idAcc+'\' ) LIMIT :MAX_RESULTS';
				AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
				searchResults = search.query(avQuery);
			}
			else{
				avQuery='FIND {'+String.escapeSingleQuotes(searchTerm)+'} IN ALL FIELDS RETURNING Contact(Id,Name,CC_CargoRepresentante__c WHERE RecordType.DeveloperName = \'CC_Representante\' and AccountId = \''+idAcc+'\') LIMIT :MAX_RESULTS';
				AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
				searchResults = search.query(avQuery); 
				
		}
		
        if(searchResults!=null) {
            SObject[] listProduct = (List<SObject>) searchResults[0];
            for (SObject p : listProduct) {
				if (p.get('CC_CargoRepresentante__c')!= null) {
					results.add(new AV_LookupSearchResult(p.Id,'Contact','standard:contact',p.get('Name').toString(),p.get('CC_CargoRepresentante__c').toString()));
				}else {
					results.add(new AV_LookupSearchResult(p.Id,'Contact','standard:contact',p.get('Name').toString(),''));
				}
				listIds.add(p.Id);
            }
            results.sort();
        }
		
	}else{

		String contactAccount ='Select Id, Name,CC_CargoRepresentante__c FROM Contact WHERE (RecordType.DeveloperName = \'CC_Representante\' and AccountId = \''+idAcc+'\')';
		

		List<SObject> listContact=(List<SObject>) capsulateQuery(contactAccount);
		if(!listContact.isEmpty()) {
            for (SObject p : listContact) {
				if (p.get('CC_CargoRepresentante__c')!= null) {
					results.add(new AV_LookupSearchResult(p.Id,'Contact','standard:contact',p.get('Name').toString(),p.get('CC_CargoRepresentante__c').toString()));
				}else {
					results.add(new AV_LookupSearchResult(p.Id,'Contact','standard:contact',p.get('Name').toString(),''));
				}
            }
        }
	}
	
		return results;
	}
	private static List<SObject> capsulateQuery(String q) {
		return (List<SObject>) Database.query(q);
	}
}