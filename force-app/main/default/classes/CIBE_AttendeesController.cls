/**********************************************************************************************************************
Name:	  CIBE_AttendeesController
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_AttendeesController_Test"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Alex Campos			11/08/2022		Init version
	2.0			Test Class		Jose Maria			10/11/2022		Contact Query change
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
public with sharing class CIBE_AttendeesController {
    
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
					Contact(Id, Name, CC_Matricula__c,CC_EmpleadoGestorId__c WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName = 'CC_Empleado')
				LIMIT :MAX_RESULTS
			];
		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
                    Contact(Id, Name, CC_Matricula__c,CC_EmpleadoGestorId__c WHERE RecordType.DeveloperName = 'CC_Empleado')
				LIMIT :MAX_RESULTS
			];

		}
		String contactIcon = 'standard:contact';
		Contact[] listContacts = (List<Contact>) searchResults[0];
		for (Contact c : listContacts) {
			results.add(
				new AV_LookupSearchResult(
					c.Id,
					'Contact',
					contactIcon,
					c.Name,
					'Matrícula • ' + c.CC_Matricula__c
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