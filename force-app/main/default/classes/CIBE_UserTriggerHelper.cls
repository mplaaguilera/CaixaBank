/**********************************************************************************************************************
 Name:	  CIBE_UserTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase handler para Trigger de User
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US394910		Alex Campos			27/06/2022			Init version
	1.1			US394910		Luis Martínez		15/02/2023			Lógica para rellenar el Permision Set Group
	1.2			US542103		Lucía Muñoz			22/02/2023			Nuevo método userRol
	1.3			US639303		Bea					21/07/2023			Nuevo método automaticProcessOwner

***********************************************************************************************************************/
public with sharing class CIBE_UserTriggerHelper {
    
    private final static String CIBE_PROFILE_NAME = 'CIBE_Gestor';
    private static Set<String> listProfiles = new Set<String>{CIBE_PROFILE_NAME};
    
    /**
     * Get the users to check by profile
     */
    public static List<User> checkByProfile(List<User> listNewObj){
        
        List<User> result = new List<User>();
        for(User us : listNewObj){
			if (listProfiles.contains(us.AV_ProfileName__c)) {
                if (String.isNotBlank(us.Username)){
                    result.add(us);    
                }
			}
		}
        return result;
    }

	/**
	 * @description		 		Update the role field of the user
	 * @param  listNewObj  		list of user data that execute the process
	 */
	public static void updatePermission(List<User> listNewObj, Map<Id,User> mapOld){
        if (!System.isFuture() && !System.isBatch()){
            List<String> nombreRoles = new List<String>{CIBE_AppConstants.CIBE_ROLECIB,CIBE_AppConstants.CIBE_ROLEMP};
			List<String> nombreGrupos = new List<String>{CIBE_AppConstants.CIBE_GESTORCIB,CIBE_AppConstants.CIBE_GESTOREMP,CIBE_AppConstants.CIBE_GESTORINTERNO,CIBE_AppConstants.GESTORINTERNO};
			Set<Id> setUsers = new Set<Id>();
			List<PermissionSetAssignment> listPermisoUser = new List<PermissionSetAssignment>();
			String grupoAux;
			List<User> lstUser = validaUsusariosPermisos(listNewObj, mapOld);
			if(!lstUser.isEmpty()){
				Map<Id,UserRole> mapRoles = new Map<Id,UserRole>([SELECT Id, Name FROM UserRole WHERE Name IN:nombreRoles]);
				Map<String,PermissionSetGroup> mapPermGr = new Map<String,PermissionSetGroup>();
				for(PermissionSetGroup mpg : [SELECT Id, DeveloperName  FROM PermissionSetGroup WHERE DeveloperName IN :nombreGrupos]){
					mapPermGr.put(mpg.DeveloperName,mpg);
				}

				if(mapRoles!=null && mapPermGr!=null){
					for(User user: lstUser){
						if(mapRoles.containsKey(user.UserRoleId) && mapRoles.get(user.UserRoleId).name.equalsIgnoreCase(CIBE_AppConstants.CIBE_ROLECIB) &&
							mapPermGr.containsKey(CIBE_AppConstants.CIBE_GESTORCIB) && isCaixaEmployee(user.Email)){
							listPermisoUser.add(new PermissionSetAssignment(PermissionSetGroupId =  mapPermGr.get(CIBE_AppConstants.CIBE_GESTORCIB).Id, AssigneeId = user.id));
							setUsers.add(user.id);
							grupoAux = mapPermGr.get(CIBE_AppConstants.CIBE_GESTORCIB).Id;
						}else if(mapRoles.containsKey(user.UserRoleId) && mapRoles.get(user.UserRoleId).name.equalsIgnoreCase(CIBE_AppConstants.CIBE_ROLEMP) &&
							mapPermGr.containsKey(CIBE_AppConstants.CIBE_GESTOREMP) && isCaixaEmployee(user.Email)){
							listPermisoUser.add(new PermissionSetAssignment(PermissionSetGroupId =  mapPermGr.get(CIBE_AppConstants.CIBE_GESTOREMP).Id, AssigneeId = user.id));
							setUsers.add(user.id);
							grupoAux = mapPermGr.get(CIBE_AppConstants.CIBE_GESTOREMP).Id;
						}else if(isCaixaBankTechEmployee(user.Email) && mapPermGr.containsKey(CIBE_AppConstants.GESTORINTERNO)){
							listPermisoUser.add(new PermissionSetAssignment(PermissionSetGroupId =  mapPermGr.get(CIBE_AppConstants.GESTORINTERNO).Id, AssigneeId = user.id));
							setUsers.add(user.id);
							grupoAux = mapPermGr.get(CIBE_AppConstants.GESTORINTERNO).Id;
						}
				}
				if(grupoAux !=null && mapPermGr.containsKey(CIBE_AppConstants.GESTORINTERNO) && grupoAux.equals(mapPermGr.get(CIBE_AppConstants.GESTORINTERNO).Id)){
					permisosDuplicados(setUsers,grupoAux,listPermisoUser);
				}else if(grupoAux !=null){
					borraListaPermisos(setUsers);
					permisosDuplicados(setUsers,grupoAux,listPermisoUser);
				}
				}
			}
		}
	}

	/**
	 * Validate Users change Permisos CIBE.
	 */

	private static List<User> validaUsusariosPermisos(List<User> listNewObj,Map<Id,User> mapOld){
		List<User> lstUser = new List<User>();
		for(User user: listNewObj){
			if(user.email!=null && user.isActive && Schema.sObjectType.User.isAccessible()&& Schema.sObjectType.UserRole.isAccessible()&&
			Schema.sObjectType.PermissionSetAssignment.isAccessible()&&Schema.sObjectType.PermissionSetGroup.isAccessible()){
				if(mapOld !=null && mapOld.containsKey(user.Id) && (mapOld.get(user.Id).UserRoleId != user.UserRoleId && isCaixaEmployee(user.Email)||
				isCaixaBankTechEmployee(user.email))) {
					lstUser.add(user);
				}else if(mapOld == null && (isCaixaEmployee(user.Email) ||isCaixaBankTechEmployee(user.email))){
					lstUser.add(user);
				}
			}
		}
		return lstUser;
	}

	/**
	 * Delete PermissionSetAssigment if User CIBE.
	 */

	private static void permisosDuplicados(Set<Id> setUsers, Id grupo, List<PermissionSetAssignment> listPermisoUser){
		List<PermissionSetAssignment> listPSA = [SELECT Id FROM PermissionSetAssignment 
												WHERE AssigneeId IN:setUsers AND Assignee.Profile.name =:CIBE_AppConstants.CIBE_GESTOR
												AND PermissionSetGroupId=:grupo];

		if(listPSA.isEmpty()){Database.insert(listPermisoUser, true);}
	}

	/**
	 * Delete PermissionSetAssigment if User CIBE.
	 */

	private static void borraListaPermisos(Set<Id> setUsers){
		List<PermissionSetAssignment> listPSA = [SELECT Id	FROM PermissionSetAssignment 
												WHERE AssigneeId IN:setUsers AND Assignee.Profile.name =:CIBE_AppConstants.CIBE_GESTOR
												AND PermissionSetGroupId!=null];
		if(!listPSA.isEmpty()){
			Database.DeleteResult[] drDels = Database.delete(listPSA, false);
			// Iterate through each returned result
			for (Database.DeleteResult dr : drDels) {
				if (!dr.isSuccess()) {
					for(Database.Error err : dr.getErrors()) {
						system.debug('## The following error has occurred.'+ err.getStatusCode() + ': ' + err.getMessage()+' : '+LoggingLevel.ERROR);                  
					}						
				}
			}
		}
	}

    /**
	 * Return true if the user email ends with emplooyes domine.
	 */

	private static Boolean isCaixaEmployee(String email){
		return (email.endsWith('caixabank.com')
			||	email.endsWith('caixabankbi.com'));
	}

	/**
	 * Return true if the user email ends with emplooyes domine.
	 */

	private static Boolean isCaixaBankTechEmployee(String email){
		return (email.endsWith('caixabanktech.com'));
	}


	/**
	 * Si el rol del usuario es CIB, en su registro de contact, el campo CIBE_EmpleadoCIB__c debe estar marcado.
	 */
	public static void userRol(List<User> listUser){
		List<String> role = new List<String>{CIBE_AppConstants.CIBE_ROLECIB};
		Map<Id, UserRole> mapRole = new Map<Id,UserRole>([SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN :role]);

		List<String> matriculas = new List<String>();
        if(!mapRole.isEmpty()) {
            for (User usuario : listUser) {
                if(mapRole.containsKey(usuario.UserRoleId) && String.isNotBlank(usuario.AV_ExternalID__c)){
					matriculas.add(usuario.AV_ExternalID__c);
                }
            }
        }
        
		if(!matriculas.isEmpty()) {
			isEmpleadoCIB(matriculas);
        }
	}

	@future
	public static void isEmpleadoCIB(List<String> matriculas){
        
		if(!matriculas.isEmpty()) {
			List<Contact> contacts = new List<Contact>();
            if(Schema.sObjectType.Contact.isAccessible() && Schema.SObjectType.Contact.fields.CIBE_EmpleadoCIB__c.isAccessible() && Schema.SObjectType.Contact.fields.CC_Matricula__c.isAccessible()) {
                contacts = [SELECT Id, CIBE_EmpleadoCIB__c FROM Contact WHERE CC_Matricula__c IN :matriculas];
            }
            
            for(Contact empleado : contacts){
                empleado.CIBE_EmpleadoCIB__c = true; 
            }
            
            if(!contacts.isEmpty() && Schema.sObjectType.Contact.isUpdateable()) {
				update contacts;
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
			//Extract the External ID values (CRM)
			Set<String> setExternalIdsUser = getSetExternalIds(listNewObj);
			if (setExternalIdsUser.isEmpty()){
				return;
			}
	
			//Search the employees with the external Id of the CRM
			List<Contact> listEmployees= [Select Id, AV_UsuarioAsociado__c, CC_Matricula__c, AccountId, Account.CC_Numero_Oficina_Empresa__c, AV_JobLevels__c, AV_TipoCentro__c From Contact Where RecordType.DeveloperName = 'CC_Empleado' and CC_Matricula__c in :setExternalIdsUser];
			
			if (listEmployees!=null && !listEmployees.isEmpty()) {
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
        List<id> contactIdList = new List<id>();
		Type typeClass = Type.forName('Contact');
		for(String jsonContact : listJsonContacts){
			Contact contact = (Contact)System.JSON.deserializeStrict(jsonContact, typeClass);
			listUpdateEmployees.add(contact);
            contactIdList.add(contact.Id);
		}

		AV_LogDebug.printLogDebug(methodName, 'listUpdateEmployees: ' + listUpdateEmployees.size());
		if (!listUpdateEmployees.isEmpty()) {
			List<Database.SaveResult> listResult = Database.update(listUpdateEmployees);
			AV_AppUtilities.displayErrors(methodName, listResult);
            map<String,Object> params = New map<String,Object>();
            // parWra.contactCarteraList = conCar;
            //string str = JSON.serialize(parWra);
            params.put('contactIdList',contactIdList);
            CBK_BatchJob.executeBatch('CIBE_PortfolioEmployee_Batch', 100, params,1);
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

	/**
	 * @description		 		Run proccesOwner if isActive true
	 * @param  listNewObj  		list of user data that execute the process
	 * @param  mapOldObj 		map of old user records
	 */
	public static void automaticProcessOwner (List<User> listNewObj, Map<Id, User> mapOlds) {

		if (!System.isFuture() && !System.isBatch()) {
			Set<String> listToProcess = new Set<String>();
			//System.debug('segunda condicion del if '+ !mapOlds.isEmpty());
			if(mapOlds != null && !mapOlds.isEmpty()) {
				for (User us : listNewObj) {
					if ((us.IsActive && us.IsActive != mapOlds.get(us.Id).IsActive) || us.AV_ExternalID__c != mapOlds.get(us.Id).AV_ExternalID__c){

						listToProcess.add(us.Id);
					}
				}
			} else {
				for (User us : listNewObj) {
					if (us.IsActive) {
						listToProcess.add(us.Id);
					}
				}
			}
			if (!listToProcess.isEmpty()) {
				AV_ScheduleBatch__mdt proccessBatch = [SELECT AV_Limit__c FROM AV_ScheduleBatch__mdt WHERE DeveloperName = 'CIBE_ProccessAccountsOwnersBatch'];
				map<String,Object> params = new map<String,Object>();
				params.put('limitBatch','100');
				params.put('setUserIds',listToProcess);
				String paramStr = JSON.serialize(params); 
				
				CBK_BatchJob.executeBatchFuture('CIBE_ProccessAccountsOwnersBatch', 100 ,paramStr);
				//Database.executeBatch(new CIBE_ProccessAccountsOwnersBatch('200', listToProcess));
				
			}
		}
	}
}