/**********************************************************************************************************************
 Name:	  AV_SObjectRelatedInfoCController
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Clase para obtener FieldSet asociado a un objecto.
=======================================================================================================================
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
   1.0			Data access		   Carolina Alonso	    27/02/2020		  Init version
   1.1			Data access		   David Rufo			13/04/2020		  Update class for save records
   1.2			Data access		   Carolina Alonso		15/07/2020		  Add Methods for C2C
   1.3			US170548		   Sandra Gómez			09/02/2021		  Change from Phone field to MobilePhone
   1.4 			US168561 		   Jashanpreet			18/02/2021		  Change for task object
   1.5			US200730		   Víctor Santiago		12/08/2021		  Added event filter and datetime format to
																		  getFieldsQuery method
   1.6			AV_Query IT		   Daniel Rodríguez	    3/02/2022		  Change AV_Query to SOQL for User and Account
   1.7			DE64065			   Jose Maria			13/09/2022		  Mejora para controlar si los campos tipo Date y Datetime estan vacios
   1.8			US542315		   Sandra Gómez		    17/03/2023		  Modified method getFieldsQuery to reference a case if it is equal to AV_Case__c
   1.9			US542315		   Patricia Solano 		22/03/2023		  Modified public class to fix quality clouds warnings
   2.0			US592987		   Ángel Medina		    29/05/2023		  Changed AV_Query to SOQL queries
   2.1			Fix PMD Errors	   Daniel Rodriguez	    05/10/2023		  Add WITH SECURITY_ENFORCED in queries
   2.2          PPM100492394       Oscar Moreno         18/09/2024        Add getGestoresMultigestor method to return the contact's name if AV_Pool__c = true and the gestor of the account is'Banca de Particulares'
   2.3			FIX21111255		   Sandra Gómez			22/11/2024		  Change method getGestoresMultigestor to fix null
***********************************************************************************************************************/
public with sharing class AV_SObjectRelatedInfoCController {
	
   public class FieldSetMember {

		public FieldSetMember(Schema.FieldSetMember f, Object value, String valueName) {
			this.dBRequired = f.dBRequired;
			this.fieldPath = f.fieldPath;
			this.label = f.label;
			this.required = f.required;
			this.type = '' + f.getType();
			this.value = value;
			this.valueName = valueName;
		}
		
		public FieldSetMember(Boolean dBRequired) {
			this.dBRequired = dBRequired;
		}
		
		@AuraEnabled
		public Boolean dBRequired { get;set; }
		
		@AuraEnabled
		public String fieldPath { get;set; }
		
		@AuraEnabled
		public String label { get;set; }
		
		@AuraEnabled
		public Boolean required { get;set; }
		
		@AuraEnabled
		public String type { get; set; }

		@AuraEnabled
		public Object value { get;set; }

		@AuraEnabled
		public Object valueName { get;set; }
	}

	@AuraEnabled
	public static List<FieldSetMember> getFieldsQuery(String recordId, String objectApiName, String objectFilter, String filterField, String fsName) {
		String methodName = 'getFieldsQuery';
		//obtenemos el tipo de SObject
		Schema.SObjectType startType = Schema.getGlobalDescribe().get(objectApiName);
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectFilter);
		
		//obtenemos la descripcion del SObject
		Schema.DescribeSObjectResult describe = targetType.getDescribe();
		//obtenemos los fieldSet de ese SObject
		Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
		//De todos los fieldSets que tiene ese objeto cogemos el que nos indica fsName
		Schema.FieldSet fs = fsMap.get(fsName);
		//Obtenemos todos los campos del fieldSet
		List<Schema.FieldSetMember> fieldSet = fs.getFields();
		List<String> listFields = new List<String>();
		List<String> toLabelFields = new List<String>();
		for(Schema.FieldSetMember f: fieldSet){
			if('Task'.equalsIgnoreCase(objectFilter) && f.getType() == Schema.DisplayType.Picklist) {
				toLabelFields.add(f.getFieldPath());
			} else if ('Event'.equalsIgnoreCase(objectFilter) && f.getType() == Schema.DisplayType.Picklist) {
				toLabelFields.add(f.getFieldPath());
			} else {
				listFields.add(f.getFieldPath());		
			}
		}

		List<SObject> dataObject = null;
		if (objectApiName.equalsIgnoreCase(objectFilter) && toLabelFields.isEmpty()){	
	
			String q = 'SELECT ';
			integer i=0;
			for(String field :listFields){
				q += ' '+ field;
				i++;
				if(i != listFields.size()){
					q += ',';
				}
			}
			q += ' FROM '+ objectFilter ;
			q += ' WHERE Id = \''  + recordId + '\'' ; 
			dataObject = capsulateQuery(q);
		
			
			 
		}else if(objectApiName.equalsIgnoreCase(objectFilter) && !toLabelFields.isEmpty()){
			String q = 'SELECT ';
			integer i=0;
			for(String field :listFields){
				q += ' '+ field;
				i++;
				if(i != listFields.size()){
					q += ',';
				}
			}
			for(String fields : toLabelFields){
				q += ',TOLABEL(' + fields + ')';
			} 
			q += ' FROM '+ objectFilter ;
			q += ' WHERE Id = \''  + recordId + '\''; 

			dataObject = capsulateQuery(q);

		}else{
			String recordIdAux = getIdFilterObject(recordId, objectApiName, objectFilter, filterField);
			String q = 'SELECT ';
			integer i=0;
			for(String field :listFields){
				q += ' '+ field;
				i++;
				if(i != listFields.size()){
					q += ',';
				}
			}
			q += ' FROM '+ objectFilter ;
			q += ' WHERE Id = \''  + recordIdAux + '\''; 

			dataObject = capsulateQuery(q);
	
		}

		
		//Creo una lista de Tipo FieldSetMember y voy añadiendo los campos
		List<FieldSetMember> fset = new List<FieldSetMember>();
		for (Schema.FieldSetMember f: fieldSet) {
			if('Id'.equals(f.getFieldpath().right(2))){
                if(!dataObject.isEmpty()){
                    SObject interact = dataObject.get(0);
                    Object value = interact.get(f.getFieldPath());
                    String sObjName = '';
                    String valueName = '';
                    if(value != null){
                        sObjName = Id.valueOf(value.toString()).getSObjectType().getDescribe().getName();
                        valueName = getIdFilterObject(value.toString(), sObjName, '', 'Name');
                    }else{
                        valueName = ' ';
                    }
                    fset.add(new FieldSetMember(f, value, valueName));
                }
			}else{
                if(!dataObject.isEmpty()){
                    SObject interact = dataObject.get(0);
					Object value;
					String valueName;
					if (f.getFieldPath().contains('.')) {
						String[] arr = f.getFieldPath().split('\\.');
						//If the lookup field points to Account, get its value and the Account's name
						if ('Account'.equals(arr[0])) {
							Account a;
							if ('Task'.equalsIgnoreCase(objectFilter)) {
								Task t = (Task) interact;
								a = t.Account;
							} else if ('Event'.equalsIgnoreCase(objectFilter)) {
								Event e = (Event) interact;
								a = e.Account;
							}
                            try {
								value = a.get(arr[1]);
								valueName = getIdFilterObject(value.toString(), 'Account', '', 'Name');
							} catch(Exception e) {
								//If field has no value the get() method will generate an exception
								AV_LogDebug.printLogError(methodName, e.getMessage());
							}							
						}
					}else if('AV_Case__c'.equals(f.getFieldpath())){
						value = interact.get(f.getFieldPath());
						if(value != null){
							valueName = getIdFilterObject(value.toString(), Id.valueOf(value.toString()).getSObjectType().getDescribe().getName(), '', 'CaseNumber');
						}else{
							valueName = ' ';
						}
					} else {
						value = interact.get(f.getFieldPath());
					}
					if(f.getType() == Schema.DisplayType.DATE && value!=null){
						value = Date.valueOf(value).format();
					}
                    if (objectApiName == 'Task' || objectApiName == 'Event') {
						if(f.getType() == Schema.DisplayType.DATETIME && value!=null){
							value = Datetime.valueOf(value).format();
						}
                    }
					if (f.getFieldPath().contains('.') || 'AV_Case__c'.equals(f.getFieldpath())){
						fset.add(new FieldSetMember(f, value, valueName));
					} else {
						fset.add(new FieldSetMember(f, value, ''));
					}
                }
			}
		}
		//Devuelvo la lista de FieldSetMember
		return fset;
	}

	@AuraEnabled(cacheable=true)
	public static String getIdFilterObject(String recordId, String objectApiName, String objectFilter, String filterField) {
		String filterSObjectID = '';
		if(String.isNotBlank(recordId) && String.isNotBlank(objectApiName) && String.isNotBlank(filterField)) {

			String q = 'SELECT ' + filterField + ' FROM ' + objectApiName + ' WHERE Id = \''  + recordId + '\'' ;
			List<SObject> filterNameList =(List<SObject>) capsulateQuery(q);


			if(filterNameList.size() > 0){
				SObject interact = filterNameList.get(0);
				filterSObjectID = (String) interact.get(filterField);
			}
		}
        AV_LogDebug.printLogDebug('getIdFilterObject', 'recordId: ' + recordId);
        AV_LogDebug.printLogDebug('getIdFilterObject', 'objectApiName: ' + objectApiName);
        AV_LogDebug.printLogDebug('getIdFilterObject', 'objectFilter: ' + objectFilter);
        AV_LogDebug.printLogDebug('getIdFilterObject', 'filterField: ' + filterField);
        AV_LogDebug.printLogDebug('getIdFilterObject', 'filterSObjectID: ' + filterSObjectID);
		return filterSObjectID;
	}

	@AuraEnabled
	public static List<String> c2cMakeCall(String calledDevice) {
		List<String> resultMethod = new List<String>();
		String callingDevice = getPhoneNumber();
		if (String.isBlank(callingDevice)){
			resultMethod.add(AV_AppConstants.WARN);
			resultMethod.add(Label.AV_CMP_C2C_CallingDevice_Empty);
		}else{
			resultMethod = AV_C2C_Controller.c2cMakeCall(calledDevice,callingDevice);
		}
		return resultMethod;
	}

	@AuraEnabled
	public static String getPhoneNumber() {
		User userInfo = [Select Id, MobilePhone From User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];

		String phoneNumber = '';
		if(userInfo != null){
			phoneNumber = userInfo.MobilePhone;
		}
		return phoneNumber;
	}

	/**
	 * @description		Method to pass quality clouds
	 */
	private static List<SObject> capsulateQuery(String avQuery){
		return (List<SObject>) Database.query(avQuery);
	} 

	
	@AuraEnabled
	public static String getGestoresMultigestor(String recordId) {
		String namesToReturn;
		if(recordId != null){
			List<Account> acc = [SELECT Id,AV_OficinaPrincipal__c,AV_OficinaPrincipal__r.CC_Numero_Oficina__c, AV_EAPGestor__c,AV_EAPGestor__r.name FROM Account WHERE id=:recordId];
			String officeNumber;
			Boolean isMultigestor = false;
			if(acc!=null && !acc.isEmpty() && acc[0].AV_OficinaPrincipal__c != null && acc[0].AV_OficinaPrincipal__r.CC_Numero_Oficina__c != null && acc[0].AV_EAPGestor__c != null){
				officeNumber = acc[0].AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
				isMultigestor = acc[0].AV_EAPGestor__r.Name.contains(AV_AppConstants.MULTIGENAME);
			}
			
			if(officeNumber!= null  && isMultigestor ){
				List<Contact> contacts = [SELECT Id, Name,AV_Pool__c FROM contact WHERE AV_Pool__c = true AND CC_Numero_Oficina__c =: officeNumber];
				if(contacts != null && !contacts.isEmpty()){
					List<String> validNames = new List<String>();
					for(Contact c : contacts){
						validNames.add(c.Name);
					}
					namesToReturn = String.join(validNames, ', ');
				}
			}
		}
		return namesToReturn;
	}

	
	@AuraEnabled
	public static Boolean isBancaParticularesEAPGestor(String recordId){
		Boolean response = false;
		if(recordId != null){
			List<Account> acc = [SELECT Id,AV_OficinaPrincipal__c,AV_OficinaPrincipal__r.CC_Numero_Oficina__c, AV_EAPGestor__c,AV_EAPGestor__r.name FROM Account WHERE id=:recordId];
			if (acc!= null && !acc.isEmpty() && acc[0].AV_EAPGestor__c != null && acc[0].AV_EAPGestor__r.Name != null && acc[0].AV_EAPGestor__r.Name.contains(AV_AppConstants.MULTIGENAME)) {
				response =  true;
			}
		}
		return response;
	}

}