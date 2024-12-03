/**********************************************************************************************************************
 Name: AV_OfficeUtility_Controller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Propósito: Controller for LWC 'av_ChangeOffice'
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
   VERSION  USER_STORY          AUTHOR          DATE        Description
   1.0      US340902            Víctor Santiago	03/03/2022  Init version
   1.1      US371624            Víctor Santiago	03/05/2022  Added logic for apoderados, soporte and multicentro
   1.2      US377920            Víctor Santiago	20/05/2022  Added isNewSession and getOfficeData
   1.3      DE62440             Sandra Gómez	17/08/2022  Added more office visibility to special gestores and order
   1.4		US516775            Luis Fernández	31/01/2023	Deleted getOffices and added GetAllOffices and privates methods to optimize apex speed keeping old logics
   1.5		US486147            Patricia Solano	06/02/2023	Modify method getUserData, getAllOffices to add field for users with responsibility 'AGRO' 
   1.6      Fix PMD Errors 		Humberto Vilchez 23/10/2023 Add WITH SECURITY_ENFORCED to queries

***********************************************************************************************************************/
public with sharing class AV_OfficeUtility_Controller {

	public static String delimiter = '/';

	/**
	 * Type of object used to encapsulate the office-related data
	 */
	public class OfficeData {
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String numOficina;
		@AuraEnabled
		public String numOficinaEmpresa;
		@AuraEnabled
		public String centroSuperior;

		public officeData(String id, String name, String numOficina, String numOficinaEmpresa, String centroSuperior) {
			this.id = id;
			this.name = name;
			this.numOficina = numOficina;
			this.numOficinaEmpresa = numOficinaEmpresa;
			this.centroSuperior = centroSuperior;
		}
	}

	public class UserData {
		@AuraEnabled 
		public String id;
		@AuraEnabled
		public String name;
		@AuraEnabled 
		public String funcion;
		@AuraEnabled
		public String numOficina;
		@AuraEnabled 
		public String contact;
		@AuraEnabled 
		public String codFuncion;
		@AuraEnabled 
		public Boolean isEspecialGestor;
		@AuraEnabled 
		public Account officeAssociated;
		@AuraEnabled
		public Account originalOfficeAssociated;
		@AuraEnabled 
		public List<OfficeData> officesList;
		@AuraEnabled 
		public Boolean isMain;
		@AuraEnabled
		public Boolean respAgro = null;
	}

	private static  List<UserData> getUserData(List<AV_OfficePermission__c> permisos,List<AV_ChangeOfficeCode__mdt> employeeCodes){
		List<UserData> userDataInfo = new List<UserData>();
		List<OfficeData> officesList = new List<OfficeData>();
	
		for(AV_OfficePermission__c perm : permisos){
			Account accAssociated = new Account();
			accAssociated.Id = perm.AV_OficinaCedida__c;
			accAssociated.Name = perm.AV_OficinaCedida__r.Name;
			accAssociated.CC_Numero_Oficina_Empresa__c = perm.AV_OficinaCedida__r.CC_Numero_Oficina_Empresa__c;
			accAssociated.AV_CentroSuperior__c = perm.AV_OficinaCedida__r.AV_CentroSuperior__c;

			UserData input = new UserData();
			input.id =perm.AV_Assigner__c;
			input.name =perm.AV_Assigner__r.Name;
			input.funcion =perm.AV_Assigner__r.AV_Funcion__c;
			input.officeAssociated = accAssociated;
			input.contact = perm.AV_GestorPermiso__c;
			if(input.contact != null){
				input.codFuncion = perm.AV_GestorPermiso__r.AV_CodFuncion__c;
				if(String.isNotBlank(input.codFuncion)){
					input.isEspecialGestor = employeeCodes.toString().contains(input.codFuncion);
				}else{
					input.isEspecialGestor = false;
				}
				if(perm.AV_GestorPermiso__r.AV_Responsabilidad__c != null){
					input.respAgro = (perm.AV_GestorPermiso__r.AV_Responsabilidad__c.equals('Referente Agro'));
				}
			}else{
				input.isEspecialGestor = false;
			}
			input.officesList = new List<OfficeData>();
			input.isMain = false;
			
			userDataInfo.add(input);
		}

		return userDataInfo;
	}

	@AuraEnabled 
	public static List<UserData> getAllOffices(Map<String,String> userMap){
		Set<String> directores = new Set<String>{AV_AppConstants.FUNCION_DAN,AV_AppConstants.FUNCION_DT,AV_AppConstants.FUNCION_DC};
		List<AV_ChangeOfficeCode__mdt> employeeCodes = [
			SELECT DeveloperName, AV_CodFuncion__c
			FROM AV_ChangeOfficeCode__mdt
			WITH SECURITY_ENFORCED
		];
		Map<String,List<UserData>> mapFunctionUser = new Map<String,List<UserData>>();
		List<UserData> result = new List<UserData>();
		List<UserData> userDataInfo = new List<UserData>();
		String centerRt = AV_AppConstants.ACCOUNT_CTO_RT;
		String currentUserId = userMap.get('Id');
		//Llenamos por query el resto de informacion que necesitamos del usuario actual
		List<Contact> currentEmployee = [
			SELECT Id, AV_CodFuncion__c, AV_UsuarioAsociado__c, AV_Responsabilidad__c
			FROM Contact
			WHERE AV_UsuarioAsociado__c = :currentUserId
			WITH SECURITY_ENFORCED
		];
		Set<String> centrosNumber = new Set<String>();
		if(String.isNotBlank(userMap.get('OriginalNumber'))){
			centrosNumber.add(userMap.get('OriginalNumber').split(delimiter)[0]);
		}
		centrosNumber.add(userMap.get('NumeroOficina'));

        List<Account> centroUsuario = [
            SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c,CC_Numero_Oficina_Empresa__c
			FROM Account
			WHERE CC_Numero_Oficina_Empresa__c IN :centrosNumber AND RecordType.DeveloperName = :centerRt
			WITH SECURITY_ENFORCED
        ];
		UserData mainUser = new UserData();
		Account loggedOffice = null;
		Map<String,Account> numberOfficeAccount = new Map<String,Account>();
		if(centroUsuario.size()==2){
			for(Account centros :centroUsuario){
				numberOfficeAccount.put(centros.CC_Numero_Oficina_Empresa__c,centros);
			}
			mainUser.officeAssociated = numberOfficeAccount.get(userMap.get('OriginalNumber').split(delimiter)[0]);
			loggedOffice = numberOfficeAccount.get(userMap.get('NumeroOficina'));
		}else{
			mainUser.officeAssociated = centroUsuario[0];
		}
		
		mainUser.id =currentUserId;
		mainUser.name = userMap.get('Name');
		mainUser.funcion = userMap.get('Funcion');
		if(!currentEmployee.isEmpty()){
		mainUser.contact = currentEmployee[0].Id;
			mainUser.codFuncion = currentEmployee[0].AV_CodFuncion__c;
			if(String.isNotBlank(mainUser.codFuncion)){
				mainUser.isEspecialGestor = employeeCodes.toString().contains(mainUser.codFuncion);
			}else{
				mainUser.isEspecialGestor = false;
			}
			if(String.isNotBlank(currentEmployee[0].AV_Responsabilidad__c)){
				mainUser.respAgro = (currentEmployee[0].AV_Responsabilidad__c.equals('Referente Agro'));
			}else{
				mainUser.respAgro = null;
			}
		}else{
			mainUser.isEspecialGestor = false;
		}
		mainUser.officesList = new List<OfficeData>();
		mainUser.isMain = true;
		userDataInfo.add(mainUser);
		//Llenamos la lista de usuarios con los usuarios que han dado permiso
		List<AV_OfficePermission__c> permisos = AV_CesionPermisos_Controller.checkForPermissionGivenToMe(currentUserId);
		if(permisos != null && !permisos.isEmpty()){
			userDataInfo.addAll(getUserData(permisos,employeeCodes));
		}
		
		for(UserData user : userDataInfo){
			if(mapFunctionUser.keySet().contains(user.funcion)){
				mapFunctionUser.get(user.funcion).add(user);
			}else{
				mapFunctionUser.put(user.funcion,new List<UserData>{user});
			}
		}

		if(mapFunctionUser.keySet().contains(AV_AppConstants.FUNCION_GESTOR)){
			result.addAll(getGestorOffices(mapFunctionUser.get(AV_AppConstants.FUNCION_GESTOR),employeeCodes));
		}
		if(mapFunctionUser.keySet().contains(AV_AppConstants.FUNCION_OFICINA)){
			result.addAll(getOficinaFunctionOffices(mapFunctionUser.get(AV_AppConstants.FUNCION_OFICINA)));
		}
		
		if(mapFunctionUser.keySet().contains(AV_AppConstants.FUNCION_DT)){
			result.addAll(getDirectoresOffices(mapFunctionUser.get(AV_AppConstants.FUNCION_DT),AV_AppConstants.FUNCION_DT));
		}
		if(mapFunctionUser.keySet().contains(AV_AppConstants.FUNCION_DC)){
			result.addAll(getDirectoresOffices(mapFunctionUser.get(AV_AppConstants.FUNCION_DC),AV_AppConstants.FUNCION_DC));
		}
		if(mapFunctionUser.keySet().contains(AV_AppConstants.FUNCION_DAN)){
			result.addAll(getDirectoresOffices(mapFunctionUser.get(AV_AppConstants.FUNCION_DAN),AV_AppConstants.FUNCION_DAN));
		}
		if(mapFunctionUser.keySet().contains(AV_AppConstants.FUNCION_SSCC)){
			result.addAll(mapFunctionUser.get(AV_AppConstants.FUNCION_SSCC));

		}

		OfficeData originalOfficeData = getOfficeData(new List<Account>{mainUser.officeAssociated})[0];
		if(loggedOffice != null){
			OfficeData loggedOfficeData = getOfficeData(new List<Account>{loggedOffice})[0];
			for(Integer i=0;i<mainUser.officesList.size();i++){
				if(mainUser.officesList[i].numOficinaEmpresa.equals(loggedOfficeData.numOficinaEmpresa)){
					mainUser.officesList.remove(i);
					i--;
				} else if(mainUser.officesList[i].numOficinaEmpresa.equals(originalOfficeData.numOficinaEmpresa)){
					mainUser.officesList.remove(i);
					i--;
				}
			}
			if(!mainUser.officesList.isEmpty()){
				mainUser.officesList.add(0,loggedOfficeData);
				mainUser.officesList.add(1,originalOfficeData);
			}else{
				mainUser.officesList.add(loggedOfficeData);
				mainUser.officesList.add(originalOfficeData);
			}
		}else{
			for(Integer i=0;i<mainUser.officesList.size();i++){
				if(mainUser.officesList[i].numOficinaEmpresa.equals(originalOfficeData.numOficinaEmpresa)){
					mainUser.officesList.remove(i);
				}
			}
			if(!mainUser.officesList.isEmpty()){
				mainUser.officesList.add(0,originalOfficeData);
			}else{
				mainUser.officesList.add(originalOfficeData);
			}
		}
		return result;
	}

	private static List<UserData> getDirectoresOffices(List<UserData> users,String funcion){
		Map<String,List<Account>> accountUserMap = new Map<String,List<Account>>();
		List<UserData> result = new List<UserData>();
		List<Id> centersId = new List<Id>();
		Set<String> centerUserRelation = new Set<String>();
		String centerRt = AV_AppConstants.ACCOUNT_CTO_RT;
		for(UserData u : users){
			u.officesList.addAll(getOfficeData(new List<Account>{u.officeAssociated}));
			centersId.add(u.officeAssociated.Id);
			centerUserRelation.add(u.officeAssociated.Id + '-' + u.id);
		}
		List<Account> inferiorCenters;
		if(funcion.equals(AV_AppConstants.FUNCION_DT)){
			inferiorCenters = [
			SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
			FROM Account
			WHERE AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c IN :centersId AND RecordType.DeveloperName = :centerRt WITH SECURITY_ENFORCED];
		}
		if(funcion.equals(AV_AppConstants.FUNCION_DC)){
			inferiorCenters = [
				SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__r.AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
				FROM Account
				WHERE AV_CentroSuperior__r.AV_CentroSuperior__c IN :centersId AND RecordType.DeveloperName = :centerRt WITH SECURITY_ENFORCED];
		}
		if(funcion.equals(AV_AppConstants.FUNCION_DAN)){
			inferiorCenters = getInferiorCenters(centersId);
		}

		for(Account center : inferiorCenters){	
			String centerSupId; 
		if(funcion.equals(AV_AppConstants.FUNCION_DT)){
			centerSupId = center.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c;	
		}
		if(funcion.equals(AV_AppConstants.FUNCION_DC)){
			centerSupId = center.AV_CentroSuperior__r.AV_CentroSuperior__c;	
		}
		if(funcion.equals(AV_AppConstants.FUNCION_DAN)){
			centerSupId = center.AV_CentroSuperior__c;
		}
			if(accountUserMap.keySet().contains(centerSupId)){
				accountUserMap.get(centerSupId).add(center);
			}else{
				accountUserMap.put(centerSupId,new List<Account>{center});
			}
		}
		for(String center : new Set<Id>(centersId)){
			for(UserData user : users){
				String key = center+'-'+user.id;
				if(centerUserRelation.contains(key) && accountUserMap.get(center) != null ){
					user.officesList.addAll(getOfficeData(accountUserMap.get(center)));
				}
			}
		}
		return users;
	}

	private static List<UserData> getGestorOffices(List<UserData> gestores,List<AV_ChangeOfficeCode__mdt> employeeCodes){
		List<UserData> dataList = new List<UserData>();
		List<UserData> regularGestor = new List<UserData>();
		List<UserData> especialGestor = new List<UserData>();
		List<UserData> gestionClienteGestor = new List<UserData>();

		String centerRt = AV_AppConstants.ACCOUNT_CTO_RT;
		
		String gestorMulticentro = getSpecialEmployeeCode(employeeCodes, 'AV_GestionDeClientesII');
		for(UserData gestor : gestores){
			if(gestor.respAgro == null || (gestor.respAgro != null && !gestor.respAgro)){
				if(!gestor.isEspecialGestor){
					regularGestor.add(gestor);
				}else{
					if(gestorMulticentro.equals(gestor.codFuncion)){
						gestionClienteGestor.add(gestor);
					}else{
						especialGestor.add(gestor);
					}
				}
			}else {
				especialGestor.add(gestor);
			}
		}

		if(!regularGestor.isEmpty()){
			for(UserData gest : regularGestor){
				gest.officesList.addAll(getOfficeData(new List<Account>{gest.officeAssociated}));
				dataList.add(gest);
			}
		}

		if(!especialGestor.isEmpty()){
			Set<String> oficinasSuperiores = new Set<String>();
			Set<String> centerUserRelation = new Set<String>();
			Map<String,List<Account>> accountUserMap = new Map<String,List<Account>>();

			Map<UserData,List<OfficeData>> userListOfficesMap = new Map<UserData,List<OfficeData>>();
			Map<String,UserData> centroSuperiorUserMap = new Map<String,UserData>();

			for(UserData gest : especialGestor){

				oficinasSuperiores.add(gest.officeAssociated.AV_CentroSuperior__c);
				centroSuperiorUserMap.put(gest.officeAssociated.AV_CentroSuperior__c,gest);
				centerUserRelation.add(gest.officeAssociated.AV_CentroSuperior__c + '-' + gest.id);
			}

			List<Account> superiorCenter = [
				SELECT Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c, AV_CentroSuperior__c,
				AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c,
				AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c
				FROM Account
				WHERE (AV_CentroSuperior__c In :oficinasSuperiores
				OR AV_CentroSuperior__r.AV_CentroSuperior__c In :oficinasSuperiores)
				AND RecordType.DeveloperName = :centerRt
				WITH SECURITY_ENFORCED
			];

			for(Account center : superiorCenter){
				String centroSuperior1 =center.AV_CentroSuperior__c;
				String centroSuperior2 = center.AV_CentroSuperior__r.AV_CentroSuperior__c;
				String centroKey = (centroSuperiorUserMap.keySet().contains(centroSuperior1)) ? centroSuperior1 : centroSuperior2;
				UserData u = centroSuperiorUserMap.get(centroKey);			
				if(accountUserMap.keySet().contains(centroKey)){
					accountUserMap.get(centroKey).add(center);
				}else{
					accountUserMap.put(centroKey,new List<Account>{center});
				}
			}

			for(String center : oficinasSuperiores){
				for(UserData user : especialGestor){
					String key = center+'-'+user.id;
					if(centerUserRelation.contains(key) && accountUserMap.get(center) != null ){
						user.officesList.addAll(getOfficeData(accountUserMap.get(center)));
					}
				}
			}
			dataList.addAll(especialGestor);
		}
		
		if(!gestionClienteGestor.isEmpty()){
			Set<String> contactosId = new Set<String>();
			Set<String> oficinasId = new Set<String>();
			Set<String> centerUserRelation = new Set<String>();
			Map<String,List<AV_BookManagementMember__c>> accountUserMap = new Map<String,List<AV_BookManagementMember__c>>();

			Map<String,UserData> contactUserDataMap = new Map<String,UserData>();
			for(UserData gest : gestionClienteGestor){
				contactosId.add(gest.contact);
				oficinasId.add(gest.officeAssociated.Id);
				contactUserDataMap.put(gest.contact,gest);
				centerUserRelation.add(gest.officeAssociated.Id + '-' + gest.id);

			}
			String bookRT = AV_AppConstants.BOOKMANAGEMENT_RT;
			List<AV_BookManagementMember__c> bmm = [SELECT
			   Id, AV_Cartera__r.AV_Centro__r.Name, 
			   AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c,
			   AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina_Empresa__c,
			   AV_Cartera__r.AV_Centro__r.AV_CentroSuperior__c,AV_EmpleadoGestor__c
			FROM AV_BookManagementMember__c
			WHERE AV_EmpleadoGestor__c IN :contactosId
			AND AV_Cartera__r.AV_Centro__c NOT IN  :oficinasId
			AND RecordType.DeveloperName = :bookRT
			AND AV_Cartera__r.AV_Centro__r.RecordType.DeveloperName = :centerRt
			WITH SECURITY_ENFORCED
			];
			
			for(AV_BookManagementMember__c book : bmm){
				String centerSupId = book.AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina_Empresa__c;
				if(accountUserMap.keySet().contains(centerSupId)){
					accountUserMap.get(centerSupId).add(book);
				}else{
					accountUserMap.put(centerSupId,new List<AV_BookManagementMember__c>{book});
				}
			}
			for(String center : oficinasId){
				for(UserData user : gestionClienteGestor){
					String key = center+'-'+user.id;
					if(centerUserRelation.contains(key) && accountUserMap.get(center) != null ){
						user.officesList.addAll(getOfficeData(accountUserMap.get(center)));
					}
				}
			}
			dataList.addAll(gestionClienteGestor);
		}
		return dataList;
	}

	private static List<UserData> getOficinaFunctionOffices(List<UserData> oficinistas){
		Map<String,List<Account>> accountUserMap = new Map<String,List<Account>>();
		List<UserData> result = new List<UserData>();
		List<Id> centersId = new List<Id>();
		Set<String> centerUserRelation = new Set<String>();
		for(UserData u : oficinistas){
			u.officesList.addAll(getOfficeData(new List<Account>{u.officeAssociated}));
			centersId.add(u.officeAssociated.Id);
			centerUserRelation.add(u.officeAssociated.Id + '-' + u.id);
		}
			List<Account> inferiorCenters = getInferiorCenters(centersId);
			for(Account center : inferiorCenters){	
				
				String centerSupId = center.AV_CentroSuperior__c;
				if(accountUserMap.keySet().contains(centerSupId)){
					accountUserMap.get(centerSupId).add(center);
				}else{
					accountUserMap.put(centerSupId,new List<Account>{center});
				}
			}

			for(String center : new Set<Id>(centersId)){
				for(UserData user : oficinistas){
					String key = center+'-'+user.id;
					if(centerUserRelation.contains(key) && accountUserMap.get(center) != null ){
							user.officesList.addAll(getOfficeData(accountUserMap.get(center)));
					}
				}
			}
			return oficinistas;
	}

	/**
	 * @description      Updates the user's office with the office number passed in the parameter
	 * @param newOffice  newOffice 
	 */
	@AuraEnabled
	public static String updateUserOffice(String newOffice) {
		String methodName = 'updateUserOffice';
		if (String.isNotBlank(newOffice)) {
			User currentUser = [
				SELECT Id, AV_NumeroOficinaEmpresa__c, AV_OriginalOfficeNumber__c
				FROM User
				WHERE Id = :UserInfo.getUserId()
				WITH SECURITY_ENFORCED
			];
			String originalOfficeNumber;
			// Old office that will be reassigned when user logs in
			if (String.isBlank(currentUser.AV_OriginalOfficeNumber__c) && !newOffice.equals(currentUser.AV_NumeroOficinaEmpresa__c)) {
				currentUser.AV_OriginalOfficeNumber__c = currentUser.AV_NumeroOficinaEmpresa__c + delimiter + UserInfo.getSessionId();
			} else if (newOffice.equals(currentUser.AV_OriginalOfficeNumber__c.split(delimiter)[0])) {
				currentUser.AV_OriginalOfficeNumber__c = '';
			}
			currentUser.AV_NumeroOficinaEmpresa__c = newOffice;
			originalOfficeNumber = currentUser.AV_OriginalOfficeNumber__c;
			Database.SaveResult sr = Database.update(currentUser, false);
			if (!sr.isSuccess()) {
				for(Database.Error err : sr.getErrors()) {
					AV_LogDebug.printLogError(methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage());
					AV_LogDebug.printLogError(methodName, '----ERR fields: ' + err.getFields());
				}
			} else {
				return originalOfficeNumber;
			}
		}
		return 'KO';
	}
	

	/**
	 * @description             Gets the inferior centers from the immediately superior centers list
	 * @param superiorCenters   List of immediately superior centers
	 */
	public static List<Account> getInferiorCenters(List<Id> superiorCenters) {
		String centerRt = AV_AppConstants.ACCOUNT_CTO_RT;

		List<Account> inferiorCenters = [
			SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
			FROM Account
			WHERE AV_CentroSuperior__c IN :superiorCenters AND RecordType.DeveloperName = :centerRt WITH SECURITY_ENFORCED
		];
		return inferiorCenters;
	}

	/**
	 * @description     Gets the current office
	 */
	@AuraEnabled
	public static String getCurrentOffice() {
		String office;
		User currentUser = [
			SELECT Id, AV_Funcion__c, AV_NumeroOficinaEmpresa__c, AV_OriginalOfficeNumber__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
			WITH SECURITY_ENFORCED
		];
		if (String.isNotBlank(currentUser.AV_NumeroOficinaEmpresa__c)) {
			office = currentUser.AV_NumeroOficinaEmpresa__c.mid(4, 5);
		}
		return office;
	}

	/**
	 * @description     Gets the original office
	 */
	@AuraEnabled
	public static String getOriginalOffice() {
		String office;
		User currentUser = [
			SELECT Id, AV_OriginalOfficeNumber__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
			WITH SECURITY_ENFORCED
		];
		if (String.isNotBlank(currentUser.AV_OriginalOfficeNumber__c)) {
			office = currentUser.AV_OriginalOfficeNumber__c.mid(4, 5);
		}
		return office;
	}

	/**
	 * @description     Check if current user is in another session, if so restore
	 *                  original office
	 */
	@AuraEnabled
	public static Boolean isNewSession() {
		Boolean result = false;
		User currentUser = [
			SELECT Id, AV_NumeroOficinaEmpresa__c, AV_OriginalOfficeNumber__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
			WITH SECURITY_ENFORCED
		];
		String originalOffice;
		String sessionId;
		if (String.isNotBlank(currentUser.AV_OriginalOfficeNumber__c)) {
			String[] data = currentUser.AV_OriginalOfficeNumber__c.split(delimiter);
			originalOffice = data[0];
			sessionId = data.size() > 1 ? data[1] : null;
		}
		if (String.isNotBlank(currentUser.AV_NumeroOficinaEmpresa__c)) {
			if (String.isNotBlank(originalOffice) && !currentUser.AV_NumeroOficinaEmpresa__c.equals(originalOffice)) {
				if (!UserInfo.getSessionId().equals(sessionId)) {
					updateUserOffice(originalOffice);
					result = true;
				}
			}
		}
		return result;
	}

	/**
	 * @description     Get data that will be used in the LWC
	 * @param data      List of accounts or bookmanagementmembers
	 */
	@AuraEnabled
	public static List<OfficeData> getOfficeData(List<SObject> data) {
		List<OfficeData> result = new List<OfficeData>();
		if (!data.isEmpty()) {
			for (SObject so : data) {
				if ('AV_BookManagementMember__c'.equals(String.valueOf(so.Id.getSobjectType()))) {
					AV_BookManagementMember__c bmm = (AV_BookManagementMember__c) so;
					OfficeData od = new OfficeData(
						bmm.AV_Cartera__r.AV_Centro__c,
						bmm.AV_Cartera__r.AV_Centro__r.Name,
						bmm.AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c,
						bmm.AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina_Empresa__c,
						bmm.AV_Cartera__r.AV_Centro__r.AV_CentroSuperior__c
					);
					result.add(od);
				} else if ('Account'.equals(String.valueOf(so.Id.getSobjectType()))) {
					Account a = (Account) so;
					OfficeData od = new OfficeData(
						a.Id,
						a.Name,
						a.CC_Numero_Oficina__c,
						a.CC_Numero_Oficina_Empresa__c,
						a.AV_CentroSuperior__c
					);
					result.add(od);
				}
			}
		}
		return result;
	}

	/**
	 * @description     Get special employee code
	 * @param data      list of AV_ChangeOfficeCode__mdt
	 * @param devName   developerName
	 */
	public static String getSpecialEmployeeCode(List<AV_ChangeOfficeCode__mdt> data, String devName) {
		if (!data.isEmpty() && String.isNotBlank(devName)) {
			for (AV_ChangeOfficeCode__mdt coc : data) {
				if (devName.equals(coc.DeveloperName)) {
					return coc.AV_CodFuncion__c;
				}
			}
		}
		return null;
	}
}