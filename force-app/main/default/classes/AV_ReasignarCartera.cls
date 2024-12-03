/**********************************************************************************************************************
 Name:	  AV_ReasignarCartera
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY	         AUTHOR		   		DATE				Description
	1.0			US104113		     Eric Vázquez	   	19/10/2020		    Init version
	1.2			FIX					 Carolina Alonso	14/12/2020		    Modify customerPortfolioId from AV_ExternalId to Name
																			Add filter by Active Book in codCarteraList query
	2.0			US133310			 Eric Vázquez		03/12/2020			Add method sendPurseFromTaskToAPI which response from lwc	
	2.1			US133310			 Eric Vázquez		15/12/2020			Fix and add methods getPurseFromContact and controlVisibilityTask for treatments data
	3.0         Hotfix         		 Eric Vázquez       26/01/2021          Fix the call API to purse
	4.0			US168560			 Eric Vázquez		11/02/2021			Add method changeOwnerFromClient that change owner from account
	4.1			AV_Query IT		     Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User, Account, Contact
	4.5 		US592987			 Ángel Medina		30/05/2023			Changed AV_Query to SOQL queries
	4.6			Fix PMD Errors       Daniel Rodriguez   05/10/2023			Add WITH SECURITY_ENFORCED in queries and add isCreatable, isUpdateable in database
***********************************************************************************************************************/
public with sharing class AV_ReasignarCartera {
	/**
	* Description 	This method send the data to API Carterización from the flow
	*
	* @param lstIds retrieve ids account, contact and book
	*/
	@invocableMethod(label='reassignPurse')
	public static List<String> reassignPurse(List<List<String>> lstIds) {
		List<string> recordId = new List<String>();
		String message = null;

		for(List<String> lstString : lstIds){
			recordId.addAll(lstString);
		}
		Account acc = [Select Id, AV_NumPerso__c From Account Where Id = :recordId[0] WITH SECURITY_ENFORCED limit 1];

		User usr = [Select Id, AV_NumeroOficinaEmpresa__c, AV_ExternalID__c From User where Id = :recordId[1] WITH SECURITY_ENFORCED limit 1];
		
		AV_Book__c bk = [SELECT Id, Name, AV_Activa__c FROM AV_Book__c WHERE Id = :recordId[2] WITH SECURITY_ENFORCED];							
		

		CBK_Activity_Extension__c updateCRMTarea = new CBK_Activity_Extension__c();
		List<String> listFields = new List<String>();
		AV_AsesorVentas_Integration.CambiarGestorRequest dataReassignPurse = new AV_AsesorVentas_Integration.CambiarGestorRequest();
		AV_AsesorVentas_Integration.CambiarGestorResponse response = new  AV_AsesorVentas_Integration.CambiarGestorResponse();

		//Fill the request to API
		dataReassignPurse.typeOperation = 'C';
        Integer bkName=Integer.valueOf(bk.Name);
		if(String.isNotBlank(bk.Name)){
			dataReassignPurse.customerPortfolioId = bkName;
		}
		dataReassignPurse.isNextYear = false;
		try{
			response = AV_AsesorVentas_Integration.cambiarGestorCli(dataReassignPurse, acc.AV_NumPerso__c, usr.AV_NumeroOficinaEmpresa__c, usr.AV_ExternalID__c);
			if(response!=null && '200'.equalsIgnoreCase(response.StatusCode)){
				String accId = acc.Id;
				changeOwnerFromClient(accId, usr);
				message = 'La asignación del cliente se ha realizado correctamente';
			}else{
				message = 'Se ha producido un error en la reasignación del cliente. \r\n' + (String.isNotBlank(response.errorMessage) ? response.errorMessage : '');
			}
		}catch(Exception e){
            AV_LogDebug.printException('reassignPurse', e);
            message = Label.AV_UnknownError;
		}
		 
		//Fill the fields from object CBK_Activity_Extension__c
		List<CBK_Activity_Extension__c> lstCRMTarea = [SELECT AV_ReasignarCartera_Id_Cliente__c, AV_ReasignarCartera_JSONAPI__c, AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c 
		WHERE AV_ReasignarCartera_Id_Cliente__c = :acc.Id WITH SECURITY_ENFORCED];

		if(!lstCRMTarea.isEmpty()){
			lstCRMTarea[0].AV_ReasignarCartera_Id_Cliente__c = acc.Id;
			lstCRMTarea[0].AV_ReasignarCartera_JSONAPI__c = JSON.serialize(response);
			lstCRMTarea[0].AV_StatusCodeAPI__c = response.StatusCode;
			if(Schema.sObjectType.CBK_Activity_Extension__c.isUpdateable()){
				Database.update(lstCRMTarea);
			}
			
		}else{
			//Fill the fields from object CBK_Activity_Extension__c
			updateCRMTarea.AV_ReasignarCartera_Id_Cliente__c = acc.Id;
			updateCRMTarea.AV_ReasignarCartera_JSONAPI__c = JSON.serialize(response);
			updateCRMTarea.AV_StatusCodeAPI__c = response.StatusCode;
			if(Schema.sObjectType.CBK_Activity_Extension__c.isCreateable()){
				Database.insert(updateCRMTarea);
			}
		}
        
		listFields.add(message);

		return listFields;
	}
	
	@future(callout=true)
	public static void assignBook(String jsonString) {
		Set<Id> idsAccount = new Set<Id>();
		Set<Id> idsOwner = new Set<Id>();
		Map<Id,Account> mapCustomer = new Map<Id,Account>();
		Map<Id,User> mapEmployee = new Map<Id,User>();
		List<String> employeeCodeList = new List<String>();
		List<Task> taskToUpdate = new List<Task>();
		List<CBK_Activity_Extension__c> crmTareas = new List<CBK_Activity_Extension__c>();
		Map<String,AV_BookManagementMember__c> mapCarteraList = new Map<String,AV_BookManagementMember__c>();
		List<Task> taskList = (List<Task>)Json.deserialize(jsonString,List<Task>.class);
		for(Task tarea : taskList){
			idsAccount.add(tarea.WhatId);
			idsOwner.add(tarea.OwnerId);
		}
		List<User> employeeList = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User where Id in :idsOwner WITH SECURITY_ENFORCED];
								
		for(User usuario : employeeList){
			mapEmployee.put(usuario.Id,usuario);
			employeeCodeList.add(usuario.AV_ExternalID__c);
		}
		List<Account> customer= [Select Id, AV_NumPerso__c, FirstName, LastName From Account Where Id in :idsAccount WITH SECURITY_ENFORCED];

		for(Account cliente : customer){
			mapCustomer.put(cliente.Id,cliente);
		}
		
		List<AV_BookManagementMember__c> codCarteraList = [SELECT AV_Cartera__r.Name,AV_EmpleadoGestor__r.CC_Matricula__c FROM AV_BookManagementMember__c WHERE AV_EmpleadoGestor__r.CC_Matricula__c IN :employeeCodeList
		AND AV_Cartera__r.AV_Activa__c = 'S' WITH SECURITY_ENFORCED];
	
		for(AV_BookManagementMember__c b : codCarteraList){
			mapCarteraList.put(b.AV_EmpleadoGestor__r.CC_Matricula__c,b);
		}


		for(Task tarea : taskList) {
			AV_AsesorVentas_Integration.CambiarGestorRequest parametros= new AV_AsesorVentas_Integration.CambiarGestorRequest();
			parametros.typeOperation = 'C';
			if(mapCarteraList.containsKey(mapEmployee.get(tarea.OwnerId).AV_ExternalID__c)) {
				parametros.customerPortfolioId = Integer.valueOf(mapCarteraList.get(mapEmployee.get(tarea.OwnerId).AV_ExternalID__c).AV_Cartera__r.Name);
			}
			parametros.isNextYear=false;
			AV_AsesorVentas_Integration.CambiarGestorResponse resCartera = AV_AsesorVentas_Integration.cambiarGestorCli(
																				parametros,
																				mapCustomer.containsKey(tarea.WhatId) ? mapCustomer.get(tarea.WhatId).AV_NumPerso__c : null,
																				mapEmployee.containsKey(tarea.OwnerId) ? mapEmployee.get(tarea.OwnerId).AV_NumeroOficinaEmpresa__c : null,
																				mapEmployee.containsKey(tarea.OwnerId) ? mapEmployee.get(tarea.OwnerId).AV_ExternalID__c : null);
			if(resCartera.StatusCode != '200'){
				CBK_Activity_Extension__c crmTarea = new CBK_Activity_Extension__c();
				crmTarea.AV_ReasignarCartera_Id_Cliente__c = tarea.WhatId;
				crmTarea.AV_Reasignar_cartera_Owner__c = tarea.OwnerId;
				crmTarea.AV_ReasignarCartera_JSONAPI__c = JSON.serialize(resCartera);
				crmTareas.add(crmTarea);
			}
			
		}	
		
		if(crmTareas.size()>0){
			Database.insert(crmTareas);
		}
	}

	/**
	* Description 	This method send the data to API Carterización from the lwc
	*
	* @param lstIds retrieve ids contact, book and task
	*/
	@AuraEnabled
	public static List<String> sendPurseFromTaskToAPI(List<String> lstIds){
		String message = null;
		List<String> sendMessage = new List<String>();
		User usr = [Select Id, AV_NumeroOficinaEmpresa__c, AV_ExternalID__c From User where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
	
		AV_Book__c bk = [SELECT Id, Name, AV_Activa__c FROM AV_Book__c WHERE Id = :lstIds[0] WITH SECURITY_ENFORCED];							
		
		Task tsk = [SELECT Id, WhatId, Account.AV_NumPerso__c FROM Task WHERE Id = :lstIds[1] WITH SECURITY_ENFORCED];

		//Call API Carterización
		AV_AsesorVentas_Integration.CambiarGestorRequest dataReassignPurse = new AV_AsesorVentas_Integration.CambiarGestorRequest();
		AV_AsesorVentas_Integration.CambiarGestorResponse response = new  AV_AsesorVentas_Integration.CambiarGestorResponse();

		//Fill the request to API
		dataReassignPurse.typeOperation = 'C';
		if(String.isNotBlank(bk.Name)){ 
			dataReassignPurse.customerPortfolioId = Integer.valueOf(bk.Name);
		}
		dataReassignPurse.isNextYear = false;

		try{
			response = AV_AsesorVentas_Integration.cambiarGestorCli(dataReassignPurse, tsk.Account.AV_NumPerso__c, usr.AV_NumeroOficinaEmpresa__c, usr.AV_ExternalID__c);
		
			//Comprove status response
			if(response!=null && '200'.equalsIgnoreCase(response.StatusCode)){
				String accId = tsk.WhatId;
				changeOwnerFromClient(accId, usr);
				message = 'La asignación del cliente se ha realizado correctamente';
			}else{
				message = 'Se ha producido un error en la reasignación del cliente. \r\n' + (String.isNotBlank(response.errorMessage) ? response.errorMessage : '');
			}
		}catch(Exception e){
			AV_LogDebug.printException('reassignPurse', e);
            message = Label.AV_UnknownError;
		}
		
		
		//Fill the fields from object CBK_Activity_Extension__c
		List<CBK_Activity_Extension__c> lstCRMTarea = [SELECT AV_ReasignarCartera_Id_Cliente__c, AV_ReasignarCartera_JSONAPI__c, AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c
		WHERE AV_ReasignarCartera_Id_Task__c = :tsk.Id WITH SECURITY_ENFORCED];
	
		if(!lstCRMTarea.isEmpty()){
			lstCRMTarea[0].AV_ReasignarCartera_Id_Cliente__c = tsk.WhatId;
			lstCRMTarea[0].AV_ReasignarCartera_JSONAPI__c = JSON.serialize(response);
			lstCRMTarea[0].AV_StatusCodeAPI__c = response.StatusCode;

			Database.update(lstCRMTarea);
		}else{
			CBK_Activity_Extension__c updateCRMTarea = new CBK_Activity_Extension__c();
		
			updateCRMTarea.AV_ReasignarCartera_Id_Cliente__c = tsk.WhatId;
			updateCRMTarea.AV_ReasignarCartera_JSONAPI__c = JSON.serialize(response);
			updateCRMTarea.AV_StatusCodeAPI__c = response.StatusCode;
			updateCRMTarea.AV_ReasignarCartera_Id_Task__c = tsk.Id;

			Database.insert(updateCRMTarea);
		}
        
		sendMessage.add(response.StatusCode);
		sendMessage.add(message);
		return sendMessage;
	}

	/**
	* Description 	   This method retrieve purses from the contact
	*
	* @param contactId retrieve id from contact
	*/
	@AuraEnabled
	public static Map<Id, String> getPurseFromContact(String contactId){
		Map<Id, String> retrieveBook = new Map<Id, String>();
		List<String> lstManageBookId = new List<String>();

		List<AV_BookManagementMember__c> bookMember = new List<AV_BookManagementMember__c>();
		List<AV_Book__c> book = new List<AV_Book__c>();

		if(contactId!=null){
			bookMember = [SELECT AV_Cartera__c FROM AV_BookManagementMember__c WHERE AV_EmpleadoGestor__c = :contactId AND AV_Cartera__r.AV_Activa__c = 'S' WITH SECURITY_ENFORCED];
		}

		if(!bookMember.isEmpty()){
			for(AV_BookManagementMember__c bm : bookMember){
				lstManageBookId.add(bm.AV_Cartera__c);
			}
			book = [SELECT Id, AV_ExternalID__c FROM AV_Book__c WHERE Id = :lstManageBookId WITH SECURITY_ENFORCED];
		}
		if(!book.isEmpty()){
			for(AV_Book__c b : book){
				retrieveBook.put(b.Id, b.AV_ExternalID__c);
			}
			
		}

		return retrieveBook;
	}

	/**
	* Description 	This method control visibility from the component lwc
	*
	* @param taskId retrieve id from task
	*/
	@AuraEnabled
	public static Boolean controlVisibilityTask(String taskId){
		List<CBK_Activity_Extension__c> lstCRMTask = new List<CBK_Activity_Extension__c>();
		Boolean taskConnectedAPI = true;
		
		lstCRMTask = [SELECT AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c WHERE AV_ReasignarCartera_Id_Task__c = :taskId WITH SECURITY_ENFORCED];
	
		if(!lstCRMTask.isEmpty()){
			for(CBK_Activity_Extension__c crmTask : lstCRMTask){
				if(crmTask.AV_StatusCodeAPI__c!=null){
					if(!crmTask.AV_StatusCodeAPI__c.contains('200')){
						taskConnectedAPI = true;
					}else{
						taskConnectedAPI = false;
					}
				}
				
			}
		}

		return taskConnectedAPI;
	}

	/**
	* Description 	This method update owner from account when response is 200
	*
	* @param accId retrieve id from account
	* @param usr retrieve user
	*/
	private static void changeOwnerFromClient(String accId, User usr) {
		Contact emp = [Select Id From Contact Where AV_UsuarioAsociado__c = :usr.Id and AV_UsuarioAsociado__r.IsActive = true WITH SECURITY_ENFORCED limit 1];
		
		Account acc = [Select Id, OwnerId, AV_EAPGestor__c From Account Where Id = :accId WITH SECURITY_ENFORCED limit 1];								
       
		acc.OwnerId = usr.Id;
		if(emp != null){
			acc.AV_EAPGestor__c = emp.Id;
		}


		if(acc!=null && Schema.sObjectType.Account.isUpdateable()){
			Database.update(acc);
		}
		
    }
}