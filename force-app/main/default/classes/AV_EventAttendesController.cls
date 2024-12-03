/**********************************************************************************************************************
Name:	  AV_EventAttendesController
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Serving as Controller of the av_AttendesEvent LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			US336957	   Luis Fernández	   	01/09/2022		Init version
***********************************************************************************************************************/
public with sharing class AV_EventAttendesController {
    private final static Integer MAX_RESULTS 	= 10;

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchUser(String searchTerm, List<String> selectedIds) {
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE Id NOT IN :selectedIds and IsActive=true and Profile.Name='AV_Usuario_CaixaBank')
				LIMIT :MAX_RESULTS
			];
		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE IsActive=true and Profile.Name='AV_Usuario_CaixaBank')
				LIMIT :MAX_RESULTS
			];

		}

		String userIcon = 'standard:user';
		User[] listUser = (List<User>) searchResults[0];
		for (User u : listUser) {
			results.add(
				new AV_LookupSearchResult(
					u.Id,
					'User',
					userIcon,
					u.Name,
					u.AV_NumeroOficinaEmpresa__c
				)
			);
		}
		results.sort();

		return results;
	}


    @AuraEnabled
    public static User getUserEmployee(Id recordId) {
        if(User.SObjectType.getDescribe().isAccessible() && 
            Schema.SObjectType.User.fields.Id.isAccessible() &&
            Schema.SObjectType.User.fields.Name.isAccessible()) {
            return [SELECT Id, Name FROM User WHERE Id = :recordId LIMIT 1];
        } else {
            return null;
        }
    }

    
}