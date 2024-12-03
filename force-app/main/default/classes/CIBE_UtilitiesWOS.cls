/**********************************************************************************************************************
Name:	  CIBE_UtilitiesWOS
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the methods that need without sharing
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US776107    	Alicia				08/01/2024		Init version
	1.1         IN1184391    	Lucia				12/07/2024      Add 'createTeamMember()', 'updateTeamMember()'

***********************************************************************************************************************/
public without sharing class CIBE_UtilitiesWOS {

	// Method of class CIBE_CXBVisualizacionGC_Controller
	@AuraEnabled
    public static void deleteTeamMember(String userId, List<String> accountIds) {
        if(Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()) {
			
                List<AccountTeamMember> deleteAccTeamMember = new List<AccountTeamMember>();
                deleteAccTeamMember = [SELECT Id,UserId FROM AccountTeamMember WHERE UserId = :userId AND AccountId IN :accountIds];
                if(deleteAccTeamMember.size() > 0){
                    delete deleteAccTeamMember;
                }
        } else {           
            throw new IllegalArgumentException('deleteTeamMember - El usuario no tiene permisos para eliminar el miembro.');
        }
    }

	// Method of class CIBE_TabManagementTask_Controller
	@AuraEnabled
	public static List<AV_LookupSearchResult> getContact(String searchTerm, List<String> selectedIds, String accountId){

		String methodName = 'getContact';
		String escrito = searchTerm;
		searchTerm = '*'+searchTerm+'*';
		String userIcon = 'standard:contact';

		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<String> setRecTypDevName = new Set<String>{'CIBE_ContactoComercial','CIBE_Apoderado'};
		if(!selectedIds.isEmpty()){
			searchResults = [FIND :searchTerm IN NAME FIELDS RETURNING
				Contact(Id, Name, CC_CargoRepresentante__c WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName IN : setRecTypDevName and AccountId = :AccountId)
				LIMIT 10];
				Contact[] listUsers = (List<Contact>) searchResults[0];		
				for (Contact u : listUsers) {
					results.add(new AV_LookupSearchResult(u.Id,'Contact',userIcon,u.Name,u.CC_CargoRepresentante__c));
				}
		}else{
			List<Contact> searchResultsContact = [SELECT Id, Name, FirstName, LastName, CC_CargoRepresentante__c FROM Contact WHERE RecordType.DeveloperName IN : setRecTypDevName AND AccountId = :accountId];
			for(Contact cont: searchResultsContact){
				if(cont.Name.containsIgnoreCase(escrito)){
					results.add(new AV_LookupSearchResult(cont.Id,'Contact',userIcon,cont.Name,cont.CC_CargoRepresentante__c));
				}
			}
		}
		results.sort();
		return results;
	}

	// Method of class CIBE_TabManagementTask_Controller
	/**
	* Get all the Oppos linked to the reported task and re-link them to the related Event
	* @param eventRelatedId The Id of the recently inserted Event
	* @param taskHeader Id of the AV_HeaderCustomActivity__c object stored in AV_Task__C field from reported task
	*/
	public static String reLinkOppToEvent(Id eventRelatedId, String taskHeader){
		Event headerField = [SELECT AV_Task__c FROM Event WHERE Id =: eventRelatedId LIMIT 1];
		List<AV_CustomActivityOpportunity__c> linkedOpps =[SELECT AV_Opportunity__c,AV_IsMain__C FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :taskHeader];
		List<AV_CustomActivityOpportunity__c> relatedOpp = new List<AV_CustomActivityOpportunity__c>();
		for(AV_CustomActivityOpportunity__c oppRelated : linkedOpps){
			
			relatedOpp.add( new AV_CustomActivityOpportunity__c(
				AV_Opportunity__c = oppRelated.AV_Opportunity__c,
				AV_Task__c = headerField.AV_Task__C,
				AV_IsMain__c = oppRelated.AV_IsMain__C
			));
		}

		List<Database.SaveResult> sr = Database.insert(relatedOpp,true);
		for(Database.SaveResult result : sr){
			if(!result.isSuccess()){
				return 'WARNEVENT';
			}
		}
		return 'OK';
	}



	@AuraEnabled
    public static void createTeamMember(List<String> accountIds, String userId, String rol) {
        if(String.isBlank(rol)) {
            throw new IllegalArgumentException('Error');
        }

        Map<String,AccountTeamMember> teamMembers = new   Map<String,AccountTeamMember>();
        if(Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
                for(AccountTeamMember act : [SELECT AccountId, TeamMemberRole, Id  FROM AccountTeamMember WHERE AccountId = :accountIds AND UserId = :userId]){
                    teamMembers.put(act.AccountId, act);
                }
        } else {
            throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para acceder a los miembros.');
        }

        if(rol == CIBE_AppConstants.GESTOR_PRINCIPAL || rol == CIBE_AppConstants.CONTACTO_CAIXABANK_RETAIL) {
            for (String accId : teamMembers.keySet()){
                teamMembers.get(accId).TeamMemberRole = rol;
            }

            List<AccountTeamMember> gestoresPrincipales = new List<AccountTeamMember>();
            if(Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
                && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
                && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
                && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
                    for(AccountTeamMember act : [SELECT AccountId, TeamMemberRole, Id  FROM AccountTeamMember WHERE AccountId = :accountIds AND UserId != :userId AND TeamMemberRole = :rol]){
                        act.TeamMemberRole = CIBE_AppConstants.PARTICIPANTE;
                        gestoresPrincipales.add(act); 
                    }

                    if(Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
                        && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
                            update gestoresPrincipales;
                            update teamMembers.values();
                    }
            } else {
                throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para acceder a los miembros.');
            }
        }

        List<AccountTeamMember> toInsert = new List<AccountTeamMember>();
        for (String accId : accountIds) {
            if(teamMembers.isEmpty() || (!teamMembers.isEmpty() && !teamMembers.containsKey(accId))){
                AccountTeamMember teamMember = new AccountTeamMember();
                teamMember.AccountId = accId;
                teamMember.UserId = userId;
                teamMember.TeamMemberRole = rol;
                teamMember.AccountAccessLevel = CIBE_AppConstants.EDIT;
                teamMember.OpportunityAccessLevel = CIBE_AppConstants.NONE;
                teamMember.CaseAccessLevel = CIBE_AppConstants.READ;
                teamMember.ContactAccessLevel = CIBE_AppConstants.EDIT;
                teamMember.CIBE_IsAutomatic__c = false;
                toInsert.add(teamMember);
            }
        }

        if(Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.OpportunityAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CaseAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()) {
                insert toInsert;
        } else {
            throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para insertar el miembro.');
        }
    }

    @AuraEnabled
    public static void updateTeamMember(String memberId, List<String> accountIds, String rol, String userId) {
        List<AccountTeamMember> changeTMRoles = new  List<AccountTeamMember>();
        if(Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && rol != 'Participante') {
                // changeTMRoles -> los accTMs con un account expecificos y un role diferente a Participante expecifico tb
                changeTMRoles = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accountIds AND TeamMemberRole = :rol AND UserId != :memberId];
        } else {
            throw new IllegalArgumentException('updateTeamMember - El usuario no tiene permisos para acceder a los AccountTeamMember.');
        }

        if(Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()) {
                List<AccountTeamMember> updateAccTeamMember = new List<AccountTeamMember>();
                updateAccTeamMember = [SELECT Id,UserId FROM AccountTeamMember WHERE UserId = :userId AND AccountId IN :accountIds];
                for(AccountTeamMember aTM : updateAccTeamMember) {               
                    aTM.TeamMemberRole = rol;
                }
                update updateAccTeamMember;
            

            if(Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
                && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
                && !changeTMRoles.isEmpty()) {
                    for(AccountTeamMember aTM : changeTMRoles) {
                        aTM.TeamMemberRole = 'Participante';
                    }
                    update changeTMRoles;
            }
        } else {
            throw new IllegalArgumentException('updateTeamMember - El usuario no tiene permisos para actualizar el miembro.');
        }
    }

}