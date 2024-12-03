/**********************************************************************************************************************
 Name:	  AV_UserTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de User.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		04/05/2020			Init version
	1.1			App FSC			Carolina Alonso		09/06/2020			Change Database.update
	1.2			App FSC			Carolina Alonso		10/06/2020			Add condition to filter in query by the listNewObj's externalIds
	1.3			App FSC			David Rufo			21/07/2020			Fix problem with new users
	1.4			App FSC			David Rufo			24/08/2020			Add new function for update the user with the number of CAIXA office
	1.5			App FSC			David Rufo			09/09/2020			Fix problem with an update more than one user at the same time
	1.6			US170549		Sandra Gómez		09/02/2021			Add method permissionUser
	1.7			FIX				David Rufo			10/05/2021			Fix Automatic process owners
	1.8			FIX				Sandra Gómez		11/05/2021			Fix permissionUser
	1.9			FIX				David Rufo			19/05/2021			Fix flow to check users by Profile
	1.10		App FSC			David Rufo			09/06/2021			method to update the funcion field of the user
	1.11		DE49213			David Rufo			17/08/2021			update automatic PS for Onboarding Task
	1.12		DE49213			David Rufo			20/09/2021			Improve the limit query in Assigment PS
	2.0			Fix				Sandra Gómez		23/12/2021			Traza de AV_ExternalId__c
	2.1			Fix				Luis Fernández		28/01/2022			Condicion isActive en los users
	2.2		    AV_Query IT	    Daniel Rodríguez	15/02/2022	        Change AV_Query to SOQL for User, Account, Contact
	2.3			Fix Azure		Sandra Gómez		09/03/2022			add method userAzureId
	2.4			Fix Bank Teller	Sandra Gómez		28/03/2022			add logic PSG Bank Teller
	2.5         US394910        Alex Campos         27/06/2022          Added CIBE_Centro__c y CIBE_Cargo to updateFuncion
	2.6         US423397        Patricia Solano     03/11/2022          Added Method visibilityUser
	2.7			US373684		Vladislav Lityagin	07/11/2022			Modified Method permissionUser If the user is an Intouch manager, the necessary permissions are added to view the CSBD Intouch form
	2.8         US448874        Patricia Solano     20/12/2022          Created Method prepareDeleteInactiveUser and deleteInactiveUser to remove permissions granted when users become inactive 
	2.9			Fix - US373684	Sandra Gómez	    04/01/2023          Modify method permissionUser remove duplicates
	3.0			US485705		Luis Fernández		02/02/2023			Modified permissionUser and WraperPS constructor
	3.1			Fix				Patricia Solano		08/03/2023			Modified method deleteInactiveUser to unassign the inactive associated user in addition to the permissions granted 
	3.2 		US592987		Ángel Medina		30/05/2023			Changed AV_Query to SOQL queries
    3.3			US586011		Luis Fernández		07/06/2023			Added new permissions to WrapperPs and new logic for BPR Contacts in permissionUser method
    3.4	        Fix             Elisabeth R.        14/06/2023          Changed to a list of contacts query of prepareDeleteInactiveUser method
	3.5			DE82170		    Lucia Muñoz         19/09/2023		    Modified method updateFuncion
	3.6			Fix				Gonzalo Ávila		27/09/2023			Fix CBK_Log Error
	3.7			Fix				Gonzalo Ávila 		02/11/2023			The office number of the contact is stored in the AV_CompanyOfficeNumber__c field of the user object.
	3.8			Fix				Sandra Gómez		27/12/2023			Change updateFuncion numero od office correct
	3.9			Fix				Luis Martínez		24/01/2024			Change updateFuncion fix match user - employee
	4.0			DT03			Luis Fernández		17/04/2024			Added debugs in order to find mismatchings in User-Contact pairment in PROD
	4.1			IN1160717	    Manuel Ramos        02/07/2024          Isolate user deactivation methods in AV_UserHandlerWithoutSharing class

***********************************************************************************************************************/
public with sharing class AV_UserTriggerHelper {

	private final static String MC_PROFILE_NAME = 'AV_Usuario_CaixaBank';
	private static Set<String> listProfiles = new Set<String>{MC_PROFILE_NAME};

	/**
	 * Get the users to check by profile
	 */
	public static List<User> checkByProfile(List<User> listNewObj){
		List<User> result = new List<User>();
		for(User us : listNewObj){
			//Modified
			if (listProfiles.contains(us.AV_ProfileName__c)) {
				if (String.isNotBlank(us.Username)){
					result.add(us);    
				}
			}
		}

		return result;
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
	 * @description		 	Set the ID's of the user's
	 * @param  listNewObj  	list of user data that execute the process
	 * @return				Set the data with the ID's of the users to be process
	 */
	private static Set<String> getSetUserIds(List<User> listNewObj){
		Set<String> setData = new Set<String>();
		for(User user : listNewObj){
			if(user.isActive){	
				setData.add(user.Id);
			}
		}
		
		return setData;
	}
	
	/**
	 * @description		 		Update the function field of the user
	 * @param  listNewObj  		list of user data that execute the process
	 * @param  mapOldObj		map with the previous data of users
	 */
	public static void updateFuncion(List<User> listNewObj,  Map<Id, User> mapOldObj){
		if (!System.isFuture() && !System.isBatch()){
			//Extract the External ID values (CRM)
			Set<String> setExternalIdsUser = getSetExternalIds(listNewObj);
			if (setExternalIdsUser.isEmpty()){
				return;
			}

			Map<String, String> mapTipoCentroFuncion = AV_ContactTriggerHelper.getAllJobLevelFunctions();
	
			//Search the employees with the external Id of the CRM
			List<Contact> listEmployees = [SELECT Id, AV_JobLevels__c, AV_TipoCentro__c, CC_Matricula__c, Account.Name, AV_DescFuncion__c, Account.CC_Numero_Oficina_Empresa__c,AV_CodFuncion__c FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Matricula__c IN :setExternalIdsUser];  
			if (listEmployees!=null && !listEmployees.isEmpty()) {
				if(mapOldObj == null || mapOldObj.isEmpty()){
					//Modified
					for (User userAux : listNewObj) {
						if ( ( userAux.isActive && String.isNotBlank(userAux.AV_ExternalID__c) && (String.isBlank(userAux.AV_Funcion__c) || String.isBlank(userAux.CIBE_Centro__c) || String.isBlank(userAux.CIBE_FuncionEmpleado__c))) ||  (userAux.isActive && String.isNotBlank(userAux.AV_ExternalID__c) && (String.isNotBlank(userAux.AV_Funcion__c) || String.isNotBlank(userAux.CIBE_Centro__c) || String.isNotBlank(userAux.CIBE_FuncionEmpleado__c))))   {
							for (Contact employee : listEmployees) {
								//Update the function field of the user
								if (userAux.AV_ExternalID__c.equalsIgnoreCase(employee.CC_Matricula__c)) {
									String funcion = AV_ContactTriggerHelper.getUpdatedFuncion(employee.AV_JobLevels__c, employee.AV_TipoCentro__c, mapTipoCentroFuncion,employee.AV_CodFuncion__c);  
									if (String.isNotBlank(funcion)){
										userAux.AV_Funcion__c = funcion;
										userAux.AV_NumeroOficinaEmpresa__c = employee.Account.CC_Numero_Oficina_Empresa__c;
									}
								}
								if ((userAux.AV_ExternalID__c).equalsIgnoreCase(employee.CC_Matricula__c) && 
									String.isNotBlank(employee.AccountId) && String.isNotBlank(employee.AV_DescFuncion__c)) {
									userAux.CIBE_Centro__c = employee.AccountId;
									userAux.CIBE_FuncionEmpleado__c = employee.AV_DescFuncion__c;
								}
							}
						}
					}
				}else{
					for (User userAux : listNewObj) {
						if ((userAux.isActive && String.isNotBlank(userAux.AV_ExternalID__c) && (String.isBlank(userAux.AV_Funcion__c) || String.isBlank(userAux.CIBE_Centro__c) || String.isBlank(userAux.CIBE_FuncionEmpleado__c))) ||  (userAux.isActive && String.isNotBlank(userAux.AV_ExternalID__c) && (String.isNotBlank(userAux.AV_Funcion__c) || String.isNotBlank(userAux.CIBE_Centro__c) || String.isNotBlank(userAux.CIBE_FuncionEmpleado__c)))) {
							for (Contact employee : listEmployees) {
								//Update the function field of the user
								if ((userAux.AV_ExternalID__c).equalsIgnoreCase(employee.CC_Matricula__c) 
										&& userAux.AV_ExternalID__c != mapOldObj.get(userAux.Id).AV_ExternalID__c) {
									String funcion = AV_ContactTriggerHelper.getUpdatedFuncion(employee.AV_JobLevels__c, employee.AV_TipoCentro__c, mapTipoCentroFuncion,employee.AV_CodFuncion__c);  
									if (String.isNotBlank(funcion)){
										userAux.AV_Funcion__c = funcion;
										userAux.AV_NumeroOficinaEmpresa__c = employee.Account.CC_Numero_Oficina_Empresa__c;
									}
								}
								if ((userAux.AV_ExternalID__c).equalsIgnoreCase(employee.CC_Matricula__c) 
									&& (String.isNotBlank(employee.AccountId) || String.isNotBlank(employee.AV_DescFuncion__c))) {
									userAux.CIBE_Centro__c = employee.Account.Name;
									userAux.CIBE_FuncionEmpleado__c = employee.AV_DescFuncion__c;
								}
							}
						}
					}
				}
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
	
	public with sharing class WrapperPS {
		public List<PermissionSetAssignment> listInsertPS = new List<PermissionSetAssignment>();
		public List<String> listDeletePS = new List<String>();
		public List<GroupMember> listInsertPG = new List<GroupMember>();
		public List<String> listDeletePG = new List<String>();
		
		public Map<String, PermissionSetAssignment> mapAssignmentG = new Map<String, PermissionSetAssignment>();
		public Map<String, PermissionSetAssignment> mapAssignmentE = new Map<String, PermissionSetAssignment>();
		public Map<String, PermissionSetAssignment> mapAssignmentOnboarding = new Map<String, PermissionSetAssignment>();
		public Map<String, PermissionSetAssignment> mapAssignmentBankTeller = new Map<String, PermissionSetAssignment>();
		public Map<String, PermissionSetAssignment> mapAssignmentCSBDFormIntouch = new Map<String, PermissionSetAssignment>();
		public Map<String, PermissionSetAssignment> mapAssignmentA = new Map<String, PermissionSetAssignment>();  
		public Map<String, PermissionSetAssignment> mapAssignmentCambioGestorProcesos = new Map<String, PermissionSetAssignment>();  
		public Map<String, PermissionSetAssignment> mapAssignmentPrivateBanking = new Map<String, PermissionSetAssignment>();  
		public Map<String, GroupMember> userGroupMembers = new Map<String, GroupMember>();
		
		public SObject permissionGestor;
		public SObject permissionExterno;
		public SObject permissionOficinaOnboarding;
		public SObject permissionBankTeller;
		public SObject permissionCSBDFormIntouch;
		public SObject groupCSBDFormularioIntouch;
		public SObject permissionVisibilidadSolutions; 
		public SObject permissionCambioGestorProcesos; 
		public SObject permissionPrivateBanking;
		
		public WrapperPS(Set<String> setUserIds){
			
			String methodName = 'WrapperPS';
			Set<String> PSGNames = new Set<String>{AV_AppConstants.PS_GESTOR,
				AV_AppConstants.PS_Externo,
				AV_AppConstants.PS_BANKTELLER,
				AV_AppConstants.PS_VISIBILIDAD_MIS_CLIENTES_SOLUTIONS};
			Set<String> PSNames = new Set<String>{AV_AppConstants.PS_CUSTOMERINTOUCH,
				AV_AppConstants.CSBD_FORM_INTOUCH_RT,
				AV_AppConstants.PS_CAMBIO_GESTOR_PROCESOS,
				AV_AppConstants.PS_PRIVATEBANKING
			};
			Set<String> GROUPNames = new Set<String>{AV_AppConstants.CSBD_FORM_INTOUCH_RT};

			List<PermissionSetGroup> PSGWRAPPER = [SELECT Id,DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN :PSGNames ];
			for(PermissionSetGroup psg : PSGWRAPPER){
				if(psg.DeveloperName == AV_AppConstants.PS_GESTOR){
					permissionGestor = psg;
				}else if(psg.DeveloperName == AV_AppConstants.PS_EXTERNO){
					permissionExterno = psg;
				}else if(psg.DeveloperName == AV_AppConstants.PS_BANKTELLER){
					permissionBankTeller = psg;
				}else if(psg.DeveloperName == AV_AppConstants.PS_VISIBILIDAD_MIS_CLIENTES_SOLUTIONS){
					permissionVisibilidadSolutions = psg;
				}
			}
			
			List<PermissionSet> PSWRAPPER = [SELECT Id,Name FROM PermissionSet WHERE Name IN :PSNames ];
			for(PermissionSet psg : PSWRAPPER){
				if(psg.Name == AV_AppConstants.PS_CUSTOMERINTOUCH ){
					permissionOficinaOnboarding = psg;
				}else if(psg.Name == AV_AppConstants.CSBD_FORM_INTOUCH_RT){
					permissionCSBDFormIntouch = psg;
				}else if(psg.Name == AV_AppConstants.PS_CAMBIO_GESTOR_PROCESOS){
					permissionCambioGestorProcesos = psg;
				}else if(psg.Name == AV_AppConstants.PS_PRIVATEBANKING){
					permissionPrivateBanking = psg;
				}
			}
			
			List<Group> GROUPWRAPPER = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN :GROUPNames ];
			for(Group psg : GROUPWRAPPER){
				if(psg.DeveloperName == AV_AppConstants.CSBD_FORM_INTOUCH_RT){
					groupCSBDFormularioIntouch = psg;
				}
			}
			
			List<PermissionSetAssignment> listAssignment = [SELECT Id, 
			AssigneeId,
			PermissionSetGroup.DeveloperName,
			PermissionSet.Name
			FROM PermissionSetAssignment WHERE 
			 (PermissionSetGroup.DeveloperName IN :PSGNames
			 OR PermissionSet.Name IN :PSNames)
			AND AssigneeId IN :setUserIds];
			// AssigneeId IN :setUserIds];
			//Map the permission set's
			// mapAssignmentG = new Map<String,PermissionSetAssignment>();		
			// List<PermissionSetAssignment> listAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroupId = :permissionGestor.id AND AssigneeId IN :setUserIds];
			for (PermissionSetAssignment ass: listAssignment) {
				if(ass.PermissionSetGroupId != null){
					String psgDn = ass.PermissionSetGroup.DeveloperName;
					if(psgDn.equals(AV_AppConstants.PS_GESTOR)){
						mapAssignmentG.put(ass.AssigneeId, ass);
					}else if(psgDn.equals(AV_AppConstants.PS_EXTERNO)){
						mapAssignmentE.put(ass.AssigneeId,ass);	
					}else if(psgDn.equals(AV_AppConstants.PS_VISIBILIDAD_MIS_CLIENTES_SOLUTIONS)){
						mapAssignmentA.put(ass.AssigneeId,ass);
					}else if(psgDn.equals(AV_AppConstants.PS_BANKTELLER)){
						mapAssignmentBankTeller.put(ass.AssigneeId, ass);
					}
				}

				if(ass.PermissionSetId != null){
					String psn = ass.PermissionSet.Name;
					if(psn ==  AV_AppConstants.PS_CUSTOMERINTOUCH){
						mapAssignmentOnboarding.put(ass.AssigneeId, ass);
					}
					else if( psn == AV_AppConstants.CSBD_FORM_INTOUCH_RT){
						mapAssignmentCSBDFormIntouch.put(ass.AssigneeId, ass);
					}else if( psn == AV_AppConstants.PS_CAMBIO_GESTOR_PROCESOS){
						mapAssignmentCambioGestorProcesos.put(ass.AssigneeId, ass);
					}else if( psn == AV_AppConstants.PS_PRIVATEBANKING){
						mapAssignmentPrivateBanking.put(ass.AssigneeId,ass);
					} 
				}

			}
			userGroupMembers = new Map<String, GroupMember>();
			List<GroupMember> newGroupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = : groupCSBDFormularioIntouch.Id AND UserOrGroupId in :setUserIds];
			for (GroupMember members: newGroupMembers){
				userGroupMembers.put(members.UserOrGroupId, members);
			}
			AV_LogDebug.printLogDebug(methodName, 'userGroupMembers: ' + userGroupMembers);
			
		}
	}

	/**
	 * @description		Insert/Update PS for the users
	 * 					If function = 'Gestor' 								-> PS Gestor
	 * 					If function = 'Oficina', 'SSCC', 'DT', 'DAN', 'DC' 	-> PS Analytics
	 * @param  listNewObj  		list of user data that execute the process
	 */
	public static void permissionUser(List<User> listNewObj) {
		String methodName = 'permissionUser';
		String BPR = AV_AppConstants.BPRROL;
		if (!System.isFuture() && !System.isBatch()) {
			List<User> listNewObjFiltered = new List<User>();
			for(User us : listNewObj){
				if(!us.AV_NotGrantPermissionSet__c){
					listNewObjFiltered.add(us);
				}
			}
			if(listNewObjFiltered != null && !listNewObjFiltered.isEmpty()) {

			Set<String> setUserIds = getSetUserIds(listNewObjFiltered);
			WrapperPS dataPS = new WrapperPS(setUserIds);
			//Get Contact Data
			Set<String> setExternalIdsUser = getSetExternalIds(listNewObjFiltered);
			List<Contact> listEmployees= [Select Id, CC_Matricula__c, AV_EmpleadoIntouch__c,AV_Rol__c From Contact Where RecordType.DeveloperName = 'CC_Empleado' and CC_Matricula__c in :setExternalIdsUser];
			Map<String,Contact> mapEmployees = new Map<String,Contact>();
			for(Contact aux : listEmployees){
				mapEmployees.put(aux.CC_Matricula__c, aux);
			}  
			//Check the permission set of the user
			Boolean callFuture = false;
			for (User us : listNewObjFiltered) {

				Contact employee = mapEmployees.get(us.AV_ExternalId__c);
				//Modified
				if (us.isActive && !us.AV_DeactiveAutoPS__c && !dataPS.mapAssignmentBankTeller.containsKey(us.id)){
					//Manage PSG Gestor or Analytics
					if (String.isNotBlank(us.AV_Funcion__c)) {
						callFuture = true;
						if(isCaixaEmployee(us.Email)){
							if (!dataPS.mapAssignmentG.containsKey(us.id)) {
								dataPS.listInsertPS.add(new PermissionSetAssignment(PermissionSetGroupId = dataPS.permissionGestor.id, AssigneeId = us.id));
							}
							if(dataPS.mapAssignmentE.containsKey(us.id)){
								PermissionSetAssignment psa = dataPS.mapAssignmentE.get(us.id);
								dataPS.listDeletePS.add(psa.id);
							}
						}else{
							if (!dataPS.mapAssignmentE.containsKey(us.id)) {
								dataPS.listInsertPS.add(new PermissionSetAssignment(PermissionSetGroupId = dataPS.permissionExterno.id, AssigneeId = us.id));
							}
							if(dataPS.mapAssignmentG.containsKey(us.id)){
								PermissionSetAssignment psa = dataPS.mapAssignmentG.get(us.id);
								dataPS.listDeletePS.add(psa.id);
							}
								
						}

					}
					//Manage the onboarding task
					if (String.isNotBlank(us.AV_Funcion__c) && 'Oficina'.equalsIgnoreCase(us.AV_Funcion__c) && employee!=null && employee.AV_EmpleadoIntouch__c && !dataPS.mapAssignmentOnboarding.containsKey(us.id)) {
						callFuture = true;
						dataPS.listInsertPS.add(new PermissionSetAssignment(PermissionSetId = dataPS.permissionOficinaOnboarding.id, AssigneeId = us.id));
					}
					else if (String.isNotBlank(us.AV_Funcion__c) && !'Oficina'.equalsIgnoreCase(us.AV_Funcion__c) && employee!=null && employee.AV_EmpleadoIntouch__c  && dataPS.mapAssignmentOnboarding.containsKey(us.id)) {
						callFuture = true;
						PermissionSetAssignment psa = dataPS.mapAssignmentOnboarding.get(us.id);
						dataPS.listDeletePS.add(psa.id);
					}
					//Si es InTouch darle visibilidad al formulario CSBD InTouch
					if(String.isNotBlank(us.AV_Funcion__c) && employee!=null && employee.AV_EmpleadoIntouch__c){
						//Si es intouch habilitarle el Formulario Intouch
						if (!dataPS.mapAssignmentCSBDFormIntouch.containsKey(us.id)) {
							callFuture = true;
							dataPS.listInsertPS.add(new PermissionSetAssignment(PermissionSetId = dataPS.permissionCSBDFormIntouch.id, AssigneeId = us.id));
						}
						if (dataPS.userGroupMembers.get(us.Id) == null) {
							callFuture = true;
							GroupMember member = new GroupMember();
							member.GroupId = dataPS.groupCSBDFormularioIntouch.Id;
							member.UserOrGroupId = us.Id;
							dataPS.listInsertPG.add(member);
						}
					}else if(String.isNotBlank(us.AV_Funcion__c) && employee!=null && !employee.AV_EmpleadoIntouch__c){
						//Si no es intouch inhabilitarle el Formulario Intouch
						if (dataPS.mapAssignmentCSBDFormIntouch.containsKey(us.id)) {
							callFuture = true;
							PermissionSetAssignment psa = dataPS.mapAssignmentCSBDFormIntouch.get(us.id);
							dataPS.listDeletePS.add(psa.id);
						}
						//Quitar del grupo publico
						if (dataPS.userGroupMembers.get(us.Id) != null) {
							callFuture = true;
							GroupMember member = dataPS.userGroupMembers.get(us.Id);
							dataPS.listDeletePG.add(member.Id);
						}
					}
				}

				
				if(us.isActive  && us.AV_ProfileName__c == AV_AppConstants.AV_PROFILE){
					if(!dataPS.mapAssignmentA.containsKey(us.id)){
						callFuture=true;
						dataPS.listInsertPS.add(new PermissionSetAssignment(PermissionSetGroupId = dataPS.permissionVisibilidadSolutions.id, AssigneeId = us.id));
					}
					if(!dataPS.mapAssignmentCambioGestorProcesos.containsKey(us.id)){
						if(String.isNotBlank(us.AV_Funcion__c) && ('Oficina'.equalsIgnoreCase(us.AV_Funcion__c) || 'DAN'.equalsIgnoreCase(us.AV_Funcion__c))){
							callFuture=true;
							dataPS.listInsertPS.add(new PermissionSetAssignment(PermissionSetId = dataPS.permissionCambioGestorProcesos.id, AssigneeId = us.id));
						} 
					} else if(dataPS.mapAssignmentCambioGestorProcesos.containsKey(us.id)){
						if (String.isNotBlank(us.AV_Funcion__c) && us.AV_Funcion__c != 'Oficina' && us.AV_Funcion__c != 'DAN') {
							callFuture = true;
							PermissionSetAssignment psa = dataPS.mapAssignmentCambioGestorProcesos.get(us.id);
							dataPS.listDeletePS.add(psa.id);
						}
					}					
					if(employee != null){
						if(employee.AV_Rol__c != null){
							if(employee.AV_Rol__c.equalsIgnoreCase(BPR)){
								if(!dataPS.mapAssignmentPrivateBanking.keySet().contains(us.Id)){
									callFuture = true;
									dataPS.listInsertPS.add( new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = dataPS.permissionPrivateBanking.Id));
								}
							}else{
								if(dataPS.mapAssignmentPrivateBanking.keySet().contains(us.Id)){
									callFuture = true;
									dataPS.listDeletePS.add( dataPS.mapAssignmentPrivateBanking.get(us.Id).Id);
								}
							}
						}else{
							if(dataPS.mapAssignmentPrivateBanking.keySet().contains(us.Id)){
								callFuture = true;
								dataPS.listDeletePS.add( dataPS.mapAssignmentPrivateBanking.get(us.Id).Id);
							}
						}
					}else{
						if(dataPS.mapAssignmentPrivateBanking.keySet().contains(us.Id)){
							callFuture = true;
							dataPS.listDeletePS.add( dataPS.mapAssignmentPrivateBanking.get(us.Id).Id);
						}
					}
				}
			}
			if (callFuture){
				String strDataPS =  System.JSON.serialize(dataPS);
				updatePSGroups(strDataPS);
			}
			}
		}else{
			AV_LogDebug.printLogDebug(methodName, 'Future: ' + System.isFuture());
			AV_LogDebug.printLogDebug(methodName, 'Batch: ' + System.isBatch());
		}
	}
	
	@Future
	public static void updatePSGroups(String strDataPS) {
		String methodName = 'updatePSGroup';
		Type typeClass = Type.forName('AV_UserTriggerHelper.WrapperPS');
		WrapperPS dataPS = (WrapperPS)System.JSON.deserializeStrict(strDataPS, typeClass);
		//Delete PS
		if (dataPS.listDeletePS != null && !dataPS.listDeletePS.isEmpty()) {
			AV_LogDebug.printLogDebug(methodName, 'Delete  ******************************');
			AV_LogDebug.printLogDebug(methodName, 'listDeletePS: ' + dataPS.listDeletePS.size());
			List<Database.DeleteResult> listResult = Database.delete(dataPS.listDeletePS, false);
			AV_AppUtilities.displayErrors(methodName, listResult);
		}
		
		//Insert PS
		if (dataPS.listInsertPS != null && !dataPS.listInsertPS.isEmpty()) {
			AV_LogDebug.printLogDebug(methodName, 'Insert  ******************************');
			AV_LogDebug.printLogDebug(methodName, 'listInsertPS: ' + dataPS.listInsertPS.size());
			List<Database.SaveResult> listResult = Database.insert(dataPS.listInsertPS, false);
			AV_AppUtilities.displayErrors(methodName, listResult);
		}

		//Delete PG
		if (dataPS.listDeletePG != null && !dataPS.listDeletePG.isEmpty()) {
			AV_LogDebug.printLogDebug(methodName, 'Delete  ******************************');
			AV_LogDebug.printLogDebug(methodName, 'listDeletePG: ' + dataPS.listDeletePG.size());
			List<Database.DeleteResult> listResult = Database.delete(dataPS.listDeletePG, false);
			AV_AppUtilities.displayErrors(methodName, listResult);
		}
		
		//Insert PG
		if (dataPS.listInsertPG != null && !dataPS.listInsertPG.isEmpty()) {
			AV_LogDebug.printLogDebug(methodName, 'Insert  ******************************');
			AV_LogDebug.printLogDebug(methodName, 'listInsertPG: ' + dataPS.listInsertPG.size());
			List<Database.SaveResult> listResult = Database.insert(dataPS.listInsertPG, false);
			AV_AppUtilities.displayErrors(methodName, listResult);
		}
	}

	/**
	 * @description		 		Run proccesOwner if isActive true
	 * @param  listNewObj  		list of user data that execute the process
	 * @param  mapOldObj 		map of old user records
	 */
	public static void automiticProcessOwner (List<User> listNewObj, Map<Id, User> mapOlds) {
		if (!System.isFuture() && !System.isBatch()) {
			Set<String> listToProcess = new Set<String>();
			if(mapOlds != null && !mapOlds.isEmpty()) {
				for (User us : listNewObj) {
					if (us.IsActive && us.IsActive != mapOlds.get(us.Id).IsActive){
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
				AV_ScheduleBatch__mdt proccessBatch = [SELECT AV_Limit__c FROM AV_ScheduleBatch__mdt WHERE DeveloperName = 'AV_ProccessAccountsOwnersBatch'];
				map<String,Object> params = new map<String,Object>();
				params.put('limitBatch',proccessBatch.AV_Limit__c);
				params.put('setUserIds',listToProcess);
				String paramStr = JSON.serialize(params);  
				CBK_BatchJob.executeBatchFuture('AV_ProccessAccountsOwnersBatch', 200 ,paramStr);              
			}
		}
	}
	
	/**
	 * @description		 		Run reassignmentInactiveUser if isActive false
	 * @param  listNewObj  		list of user data that execute the process
	 * @param  mapOldObj 		map of old user records
	 */
	public static void reassignmentInactiveUser (List<User> listNewObj, Map<Id, User> mapOlds) {
		if (!System.isFuture() && !System.isBatch()) {
			Set<String> listToProcess = new Set<String>();
			if(mapOlds != null && !mapOlds.isEmpty()) {
				for (User us : listNewObj) {
					if (us.IsActive == false && us.IsActive != mapOlds.get(us.Id).IsActive){
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
				AV_ScheduleBatch__mdt proccessBatch = [SELECT AV_Limit__c FROM AV_ScheduleBatch__mdt WHERE DeveloperName = 'AV_ProcessInactiveUserAccountsBatch'];
				map<String,Object> params = new map<String,Object>();
				params.put('limitBatch',proccessBatch.AV_Limit__c);
				params.put('setUserIds',listToProcess);
				String paramStr = JSON.serialize(params);  
				CBK_BatchJob.executeBatchFuture('AV_ProcessInactiveUserAccountsBatch', 200 ,paramStr);              
			}
		}
	}

	/**
	 * @description		 		Traza del AV_ExternalId__c
	 * @param  listNewObj  		list of user data that execute the process
	 * @param  mapOldObj 		map of old user records
	 */
	public static void userExternalId (List<User> listNewObj, Map<Id, User> mapOlds) {
		String methodName = 'userExternalId';
		Set<User> listToProcess = new Set<User>();
		Set<User> listToProcessInsert = new Set<User>();
		if(mapOlds != null && !mapOlds.isEmpty()) {
			//Modified
			for (User us : listNewObj) {
				if (us.isActive && String.isNotBlank(us.AV_ExternalID__c) && us.AV_ExternalID__c != mapOlds.get(us.Id).AV_ExternalID__c){
					listToProcess.add(us);
				}
			}
		} else {
			for (User us : listNewObj) {
				if (us.isActive && String.isNotBlank(us.AV_ExternalID__c)) {
					listToProcessInsert.add(us);
				}
			}
		}
		List<String> listDebugListToProcess = new List<String>();
		if (!listToProcess.isEmpty()) {
				for (User us:listToProcess) {
					//Modified
					if(us.isActive){
						listDebugListToProcess.add('LastModifiedById: ' + us.LastModifiedById +' -> Id del usuario: '+ us.Id +' -> Valor nuevo: ' + us.AV_ExternalID__c + ' -> Valor antiguo: ' + mapOlds.get(us.Id).AV_ExternalID__c);
					}
				}
			if(!listDebugListToProcess.isEmpty()) {
				CBK_log.debug('Metodo: '+methodName+' listDebugListToProcess: '+listDebugListToProcess,listDebugListToProcess,LoggingLevel.DEBUG);
			}
		}
		List<String> listDebugListToProcessInsert = new List<String>();
		if (!listToProcessInsert.isEmpty()) {
				for (User us:listToProcessInsert) {
					if(us.isActive){
					listDebugListToProcessInsert.add('LastModifiedById: ' + us.LastModifiedById +' -> Id del usuario: '+ us.Id +' -> Valor nuevo: ' + us.AV_ExternalID__c + ' -> No tiene valor antiguo viene por insert');
				}
			}
			if(!listDebugListToProcessInsert.isEmpty()) {
				CBK_log.debug('Metodo: '+methodName+' listDebugListToProcessInsert: '+listDebugListToProcessInsert,listDebugListToProcessInsert,LoggingLevel.DEBUG);
			}
		}
	}

	/**
	 * @description		 		Insert/Update AV_AzureId__c
	 * @param  listNewObj  		list of user data that execute the process
	 * @param  mapOldObj 		map of old user records
	 */
	public static void userAzureId (List<User> listNewObj, Map<Id, User> mapOlds) {
		Set<User> listToProcess = new Set<User>();
		if(mapOlds != null && !mapOlds.isEmpty()) {
			for (User us : listNewObj) {
				if (us.IsActive && String.isBlank(us.AV_AzureId__c) && String.isNotBlank(us.FederationIdentifier)){
					listToProcess.add(us);
				}
			}
		} else {
			for (User us : listNewObj) {
				if (us.IsActive && String.isBlank(us.AV_AzureId__c) && String.isNotBlank(us.FederationIdentifier)) {
					listToProcess.add(us);
				}
			}
		}
	}

	/**
	 * @description		Insert/Update Sharing Rules for the users visibility
	 * @param  listNewObj  		list of user data that execute the process
	 * @param  mapOlds		    map with the previous data of users
	 */
	public static void visibilityUser(List<User> listNewObj, Map<Id, User> mapOlds) {
		// update
		Set<String> listIds = new Set <String>();
		for(User usr : listNewObj){
			listIds.add(usr.id);
		}
		Group newGroup = [SELECT Id FROM Group WHERE DeveloperName = 'AV_Confidencial' LIMIT 1];
		String methodName = 'visibilityUser';
		List<GroupMember> newGroupMembers = [SELECT id, UserOrGroupId FROM GroupMember WHERE GroupId = : newGroup.Id AND UserOrGroupId IN :listIds];
		Map<String, String> userGroupMembers = new Map<String, String>();
		List<GroupMember> listGroupMemberInsert = new List<GroupMember>();
		List<GroupMember> listGroupMemberDelete = new List<GroupMember>();

		for (GroupMember members: newGroupMembers){
			userGroupMembers.put(members.UserOrGroupId, members.Id);
		}

		if (mapOlds != null && !mapOlds.isEmpty()) {
			for (User user: listNewObj) {
				if (String.isNotBlank(user.AV_Funcion__c) && !'Gestor'.equalsIgnoreCase(user.AV_Funcion__c) && user.isActive) {   
					if (userGroupMembers.get(user.Id) == null) {
						GroupMember member = new GroupMember();
						member.GroupId = newGroup.Id;
						member.UserOrGroupId = user.Id;
						listGroupMemberInsert.add(member);
					}
				} else if (String.isNotBlank(user.AV_Funcion__c) && 'Gestor'.equalsIgnoreCase(user.AV_Funcion__c) && user.isActive) {
					if (userGroupMembers.get(user.Id) != null){
						GroupMember member = new GroupMember();
						member.Id = userGroupMembers.get(user.Id);
						listGroupMemberDelete.add(member);
					}
				}
			}
		// insert
		} else {
			for (User user: listNewObj) {
				if (String.isNotBlank(user.AV_Funcion__c) && !'Gestor'.equalsIgnoreCase(user.AV_Funcion__c) && user.isActive) {   
					GroupMember member = new GroupMember();
					member.GroupId = newGroup.Id;
					member.UserOrGroupId = user.Id;
					listGroupMemberInsert.add(member);
				} 
			}
		}

		if (!listGroupMemberInsert.isEmpty() && listGroupMemberInsert != null) {
			AV_LogDebug.printLogDebug(methodName, 'listGroupMemberInsert: ' + listGroupMemberInsert.size());
			database.insert(listGroupMemberInsert, false);
		}

		if (!listGroupMemberDelete.isEmpty() && listGroupMemberDelete != null) {
			AV_LogDebug.printLogDebug(methodName, 'listGroupMemberDelete: ' + listGroupMemberDelete.size());
			database.delete(listGroupMemberDelete, false);
		}
	}

	/**
	 * Return true if the user email ends with emplooyes domine.
	 */
	private static Boolean isCaixaEmployee(String email){
		return (email.endsWith('caixabank.com') 
		||	
		email.endsWith('caixabankbi.com') 
		);
	}
}