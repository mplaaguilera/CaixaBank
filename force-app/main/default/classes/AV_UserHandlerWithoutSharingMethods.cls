/**********************************************************************************************************************
 Name:	  AV_UserHandlerWithoutSharingMethods
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para métodos derivados de User Trigger Handler que requieren Without Sharing
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			IN1160717		Manuel Ramos	    02/07/2024			Init version
	1.1        FIX040724844     Oscar Moreno        03/07/2024          Add updateUsuarioAsociado methods and getSetExternalIds method

***********************************************************************************************************************/
public without sharing class AV_UserHandlerWithoutSharingMethods {
    
    /**
	 * @description		 		Run prepareDeleteInactiveUser if isActive false
	 * @param  listNewObj  	    list of user data that execute the process
	 * @param  mapOldObj 		map of old user records
	 */
	public static void prepareDeleteInactiveUser (List<User> listNewObj, Map<Id, User> mapOlds) {
		Set<String> listToProcess = new Set<String>();
		if(mapOlds != null && !mapOlds.isEmpty()) {
			for (User us : listNewObj) {
				if (us.IsActive == false && us.IsActive != mapOlds.get(us.Id).IsActive){
					listToProcess.add(us.Id);
				}
			}
			if (listToProcess != null && !listToProcess.isEmpty()) {
				List<AV_OfficePermission__c> listUserPermission = [SELECT Id, AV_UsuarioCedido__c, AV_Assigner__c FROM AV_OfficePermission__c WHERE AV_UsuarioCedido__c IN :listToProcess OR AV_Assigner__c IN :listToProcess];
				List<Contact> contactToProcess = [SELECT AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c IN :listToProcess];
				if (listUserPermission != null && contactToProcess != null && !listUserPermission.isEmpty() && !contactToProcess.isEmpty()) {
					deleteInactiveUser(json.serialize(listUserPermission), json.serialize(contactToProcess));
				} else if (listUserPermission != null && !listUserPermission.isEmpty()) {
					deleteInactiveUser(json.serialize(listUserPermission), '');
				} else if (contactToProcess != null && !contactToProcess.isEmpty()) {
					deleteInactiveUser('', json.serialize(contactToProcess));
				}
			}
		}
	}

    /**
	 * @description		 		   	    Run deleteInactiveUser 
	 * @param  userPermissionString  	string with user data that execute the process
	 * @param  contactToProcessString  	string with contact data that execute the process
	 */
	@future
	private static void deleteInactiveUser (String userPermissionString, String contactToProcessString) {
		if (userPermissionString != '' && contactToProcessString != '') {
			List<AV_OfficePermission__c> listUserPermission = (List<AV_OfficePermission__c>)Json.deserialize(userPermissionString, List<AV_OfficePermission__c>.class);
			Database.delete(listUserPermission, true);
			List<Contact> contactAssociatedUser = (List<Contact>)Json.deserialize(contactToProcessString,List<Contact>.class);
			for(Contact c : contactAssociatedUser){
				c.AV_UsuarioAsociado__c = null;
			}
			Database.update(contactAssociatedUser, true);
		} else {
			if (userPermissionString != '') {
				List<AV_OfficePermission__c> listUserPermission = (List<AV_OfficePermission__c>)Json.deserialize(userPermissionString, List<AV_OfficePermission__c>.class);
				Database.delete(listUserPermission, true);
			}
			if (contactToProcessString != '') {
				List<Contact> contactAssociatedUser = (List<Contact>)Json.deserialize(contactToProcessString,List<Contact>.class);
				for(Contact c : contactAssociatedUser){
					c.AV_UsuarioAsociado__c = null;
				}
				Database.update(contactAssociatedUser, true);
			}
		}
	}


	/**
	 * @description		 		AfterProcess:
	 * 							Update AV_UsuarioAsociado__c in Contacts with the Id the associated User
	 * 							Update the center of the office associate with the user
	 * @param  isTriggerBefore  flag to indicate if the trigger that is executing is before or after
	 * @param  listNewObj  		list of user data that execute the process
	 * @param  mapOldObj		map with the previous data of users
	 */
	public static void updateUsuarioAsociado(Boolean isTriggerBefore, List<User> listNewObj,  Map<Id, User> mapOldObj){
		if (!System.isFuture() && !System.isBatch()){
			List<User> updatedUsers = new List<User>();
			CBK_Log.debug('updateUsuarioAsociado; Users to process : ' +listNewObj,listNewObj,LoggingLevel.DEBUG);
			//Extract the External ID values (CRM)
			Set<String> setExternalIdsUser = getSetExternalIds(listNewObj);
			CBK_Log.debug('updateUsuarioAsociado; Users extId => ' + setExternalIdsUser,new List<String>(setExternalIdsUser),LoggingLevel.DEBUG);
			if (setExternalIdsUser.isEmpty()){
				return;
			}
	
			//Search the employees with the external Id of the CRM
			List<Contact> listEmployees= [Select Id, AV_UsuarioAsociado__c, CC_Matricula__c, AccountId, Account.CC_Numero_Oficina_Empresa__c, AV_JobLevels__c, AV_TipoCentro__c From Contact Where RecordType.DeveloperName = 'CC_Empleado' and CC_Matricula__c in :setExternalIdsUser];
			CBK_Log.debug('updateUsuarioAsociado; Find matricula match contacts: '+listEmployees,listEmployees,LoggingLevel.DEBUG);
			if (listEmployees!=null && !listEmployees.isEmpty()) {
				CBK_Log.debug('updateUsuarioAsociado; Find matricula match contacts: '+listEmployees,listEmployees,LoggingLevel.DEBUG);
				List<Contact> listUpdateEmployees = new List<Contact>();
				if(mapOldObj == null || mapOldObj.isEmpty()){
					//Modified
					for (User userAux : listNewObj) {
						if (userAux.isActive && String.isNotBlank(userAux.AV_ExternalID__c)) {
							for (Contact employee : listEmployees) {
								//Update the contact associate to the user (only in after process)
								if (!isTriggerBefore && (userAux.AV_ExternalID__c).equalsIgnoreCase(employee.CC_Matricula__c)) {
									employee.AV_UsuarioAsociado__c = userAux.Id;
									listUpdateEmployees.add(employee);
								}
							}
						}
					}
					CBK_Log.debug('updateUsuarioAsociado; (InsertUser) Updated contact list => '+listUpdateEmployees,listUpdateEmployees,LoggingLevel.DEBUG);
				}else{
					for (User userAux : listNewObj) {
						if (userAux.isActive && String.isNotBlank(userAux.AV_ExternalID__c)) {
							for (Contact employee : listEmployees) {
								//Update the contact associate to the user (only in after process)
								if (!isTriggerBefore && (userAux.AV_ExternalID__c).equalsIgnoreCase(employee.CC_Matricula__c) 
								&& userAux.AV_ExternalID__c != mapOldObj.get(userAux.Id).AV_ExternalID__c) {
									employee.AV_UsuarioAsociado__c = userAux.Id;
									listUpdateEmployees.add(employee);
								}
							}
							CBK_Log.debug('updateUsuarioAsociado; (Updated User) Updated contact list => '+listUpdateEmployees,listUpdateEmployees,LoggingLevel.DEBUG);
						}
					}
				}

				
				//Update Contacts
				if (!listUpdateEmployees.isEmpty()){
					Set<String> listJsonContacts = new Set<String>();
					for(Contact employee : listUpdateEmployees){
						String jsonEmployee =  System.JSON.serialize(employee);
						listJsonContacts.add(jsonEmployee);
					}
					CBK_Log.debug('updateUsuarioAsociado; JSONED contact list => '+listJsonContacts,new List<String>(listJsonContacts),LoggingLevel.DEBUG);
					Map<String,Contact> listUpdateEmployeesDebug = new Map<String,Contact>();
					//DEBUG CODE
					Type typeClass = Type.forName('Contact');
					for(String jsonContact : listJsonContacts){
						Contact contact = (Contact)System.JSON.deserializeStrict(jsonContact, typeClass);
						listUpdateEmployeesDebug.put(contact.CC_Matricula__c,contact);
					}
					List<User> userWithNoMatch = new List<User>();
					for(User us : listNewObj){
						if(!listUpdateEmployeesDebug.containsKey(us.AV_ExternalId__c)){
							userWithNoMatch.add(us);
						}
					}

					if(userWithNoMatch.isEmpty()){
						CBK_Log.debug('updateUsuarioAsociado; (All users matched) ',LoggingLevel.DEBUG);
					}else{
						
						CBK_Log.debug('updateUsuarioAsociado; (Users with no match) => '+userWithNoMatch,userWithNoMatch,LoggingLevel.DEBUG);
						CBK_Log.debug('updateUsuarioAsociado; (Contacts with no match) => '+userWithNoMatch,userWithNoMatch,LoggingLevel.DEBUG);
					}

					//END DEBUG CODE
					updateUsuarioAsociado(listJsonContacts);
				}
			}
		}
	}

	/**
	 * @description		 Update AV_UsuarioAsociado__c in Contacts with the Id the associated User
	 * @param  listJsonContacts  list of Users
	 */
	@Future
	private static void updateUsuarioAsociado(Set<String> listJsonContacts) {
		String methodName = 'updateUsuarioAsociado';
		//Deserialize
		List<Contact> listUpdateEmployees = new List<Contact>();
		Type typeClass = Type.forName('Contact');
		for(String jsonContact : listJsonContacts){
			Contact contact = (Contact)System.JSON.deserializeStrict(jsonContact, typeClass);
			listUpdateEmployees.add(contact);
		}
		CBK_Log.debug('updateUsuarioAsociado; Unserialized json of contacts ready to be updated with new associated user => '+listUpdateEmployees,listUpdateEmployees,LoggingLevel.DEBUG);
		AV_LogDebug.printLogDebug(methodName, 'listUpdateEmployees: ' + listUpdateEmployees.size());
		if (!listUpdateEmployees.isEmpty()) {
			List<Database.SaveResult> listResult = Database.update(listUpdateEmployees);
			CBK_Log.debug('updateUsuarioAsociado; Update contact DML results => '+listResult,listResult,LoggingLevel.DEBUG);

			AV_AppUtilities.displayErrors(methodName, listResult);
		}
	}

	/**
	 * @description		 	Set the external ID's of the user's
	 * @param  listNewObj  	list of user data that execute the process
	 * @return		Set the data with the external ID's or null if the external ID of the user is empty
	 */
	private static Set<String> getSetExternalIds(List<User> listNewObj){
		Set<String> setExternalIdsUser = new Set<String>();
		for(User user : listNewObj){
			//Modified
			if(String.isNotBlank(user.AV_ExternalID__c)){
				setExternalIdsUser.add(user.AV_ExternalID__c);
			}
		}
		
		return setExternalIdsUser;
	}
}