/**********************************************************************************************************************
Name:	  AV_CallSDGHomeSDGHome_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Llamadas de la Home page
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY	  	AUTHOR		   		DATE				Description
	1.1			-	      		Bea y Ali  			21/06/2024		  	Init version
	
***********************************************************************************************************************/
public with sharing class AV_CallSDGHomeSDGHome_Controller {

	@AuraEnabled(cacheable = true) 
    public static List<Wrapper> getCalls() {
		
		Datetime currentDate = Datetime.now();

		// Obtener el día de la semana
		String dayOfWeek = currentDate.format('E'); // Esto te dará el día de la semana abreviado (por ejemplo, "Mon" para lunes)
		Integer lastNday;

		// Calcular el día hábil anterior
		if (dayOfWeek == 'Mon') { // 1 = lunes
			lastNday = 3; // Si es lunes, el día hábil anterior es el viernes pasado
		} else if (dayOfWeek == 'Sun') { // 7 = domingo
			lastNday = 2; // Si es domingo, el día hábil anterior es el viernes pasado
		} else {
			lastNday = 1; // En otros casos, el día hábil anterior es el día anterior
		}

		String query = 'SELECT Id, Name, AV_Account__c, AV_Account__r.Name, TOLABEL (CC_Tipo__c), CC_Fecha_Inicio__c, AV_Duration__c, OB_Telefono__c, TOLABEL (AV_State__c), AV_FirstEmployee__c, AV_FirstEmployee__r.Name '+
					+ ' FROM CC_Llamada__c '
					+ ' WHERE OwnerId = \'' + userInfo.getUserId() + '\''
					+ ' AND RecordType.DeveloperName = \'AV_CallLog\' '
					+ ' AND CC_Tipo__c = \'Entrante\' '
					+ ' AND AV_State__c = \'Perdida\' '
					+ ' AND (CC_Fecha_Inicio__c = TODAY OR CC_Fecha_Inicio__c = LAST_N_DAYS:' + lastNday +'  ) ';

		// List<CC_Llamada__c> callList = new List<CC_Llamada__c>();
        List<CC_Llamada__c> callList = capsulateQuery(query);
		// try {
		// 	callList = Database.query(query);
		// } catch (QueryException e) {
		// 	System.debug('Error al ejecutar la consulta: ' + e.getMessage());
		// }

        Map<String, String> pickListValuesMap = new Map<String, String>();
		for (Schema.PicklistEntry pickListVal : CC_Llamada__c.CC_Tipo__c.getDescribe().getPicklistValues()) {
            pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
		}
		for (Schema.PicklistEntry pickListVal : CC_Llamada__c.AV_State__c.getDescribe().getPicklistValues()) {
            pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
		}


        Set<String> phoneNumbers = new Set<String>();

        for (CC_Llamada__c call : callList) {
            if (call.OB_Telefono__c != null) {
                phoneNumbers.add(call.OB_Telefono__c);
            }
        }

        Set<String> setPhoneNumbersForQuery = new Set<String>();
        for (String phone : phoneNumbers){
            setPhoneNumbersForQuery.addAll(formatPhone(phone));
        }
        
        List<Account> accountList = new List<Account>();
    
        if (!phoneNumbers.isEmpty()) {
            accountList = [SELECT Id, Name, Phone, PersonMobilePhone FROM Account WHERE Phone IN :setPhoneNumbersForQuery OR PersonMobilePhone IN :setPhoneNumbersForQuery];
        }

        Map<String, Account> phoneToAccountMap = new Map<String, Account>();
        for (Account acc : accountList) {
            if (acc.Phone != null) {
                for (String formattedPhone : formatPhone(acc.Phone)) {
                    phoneToAccountMap.put(formattedPhone, acc);
                }
            }
            if (acc.PersonMobilePhone != null) {
                for (String formattedPhone : formatPhone(acc.PersonMobilePhone)) {
                    phoneToAccountMap.put(formattedPhone, acc);
                }
            }
        }

        List<Wrapper> listWrap = new List<Wrapper>();
        if(!callList.isEmpty() && !accountList.isEmpty()){

        List<Wrapper> listReturn = new List<Wrapper>();
        for (CC_Llamada__c call : callList) {
            if (call.OB_Telefono__c != null && phoneToAccountMap.containsKey(call.OB_Telefono__c)) {
                Account relatedAccount = phoneToAccountMap.get(call.OB_Telefono__c);
                listWrap.add(
                    new Wrapper(
                        call.Id,
                        call.Name,
                        call.AV_Account__c,
                        call.AV_Account__r.Name,
                        pickListValuesMap.containsKey(call.CC_Tipo__c) ? pickListValuesMap.get(call.CC_Tipo__c) : call.CC_Tipo__c,
                        call.CC_Fecha_Inicio__c,
                        call.AV_Duration__c,
                        call.OB_Telefono__c,
                        pickListValuesMap.containsKey(call.AV_State__c) ? pickListValuesMap.get(call.AV_State__c) : call.AV_State__c,
                        call.AV_FirstEmployee__c,
                        call.AV_FirstEmployee__r.Name
                    )
                );
            }
        }
            listWrap.sort();
            
            // Agrupar por accountName y ordenar por fecha
            Map<String, List<Wrapper>> groupedCalls = new Map<String, List<Wrapper>>();
            for (Wrapper wrapper : listWrap) {
                if (!groupedCalls.containsKey(wrapper.accountName)) {
                    groupedCalls.put(wrapper.accountName, new List<Wrapper>());
                }
                groupedCalls.get(wrapper.accountName).add(wrapper);
            }

            for (String accountName : groupedCalls.keySet()) {
                List<Wrapper> calls = groupedCalls.get(accountName);
                calls.sort();
                listReturn.addAll(calls);
            }

            return listReturn;
        }else {
            return new List<Wrapper>();
        }
    }

    /**
	* @description 		method to query with string
	* @param q 			query to execute
	* @return 			list call of return query
	*/
	private static List<CC_Llamada__c> capsulateQuery(String q) {
		return (List<CC_Llamada__c>) Database.query(q);
	}


    public static Set <String> formatPhone(String phoneNumber) {

        Set <String> setPhoneNumbers = new Set<String>();
            if (phoneNumber.startsWith('34')) {
                setPhoneNumbers.add(phoneNumber.substring(2));
                setPhoneNumbers.add('+' + phoneNumber);
                setPhoneNumbers.add('+34 ' + phoneNumber.substring(2));
                setPhoneNumbers.add(phoneNumber);
            } else if(phoneNumber.startsWith('+346') || phoneNumber.startsWith('+347')){
                setPhoneNumbers.add(phoneNumber.substring(3));
                setPhoneNumbers.add(phoneNumber.substring(1));
                setPhoneNumbers.add(phoneNumber.substring(0, 3) + ' ' + phoneNumber.substring(3));
                setPhoneNumbers.add(phoneNumber);
            } else if(phoneNumber.startsWith('+34 ')){
                setPhoneNumbers.add(phoneNumber.replace(' ', ''));
                setPhoneNumbers.add(phoneNumber.replace(' ', '').substring(3));
                setPhoneNumbers.add(phoneNumber.replace(' ', '').substring(1));
                setPhoneNumbers.add(phoneNumber);
            } else if(phoneNumber.startsWith('91') || phoneNumber.startsWith('+3491') || phoneNumber.startsWith('+34 91')){
                setPhoneNumbers.add(phoneNumber);
            }
            else{
                setPhoneNumbers.add('+34' + phoneNumber);
                setPhoneNumbers.add('+34 ' + phoneNumber);
                setPhoneNumbers.add('34' + phoneNumber);
                setPhoneNumbers.add(phoneNumber);
            }
    
            return setPhoneNumbers;
    }

    public class Wrapper implements Comparable {

        @AuraEnabled 
        public String idCall {get;set;}

        @AuraEnabled 
        public String callName {get;set;}

        @AuraEnabled 
        public String accountId {get;set;}

        @AuraEnabled 
        public String accountName {get;set;}

        @AuraEnabled 
        public String tipo {get;set;}

        @AuraEnabled 
        public Datetime fechaInicio {get;set;}

        @AuraEnabled 
        public String duracion {get;set;}

        @AuraEnabled 
        public String telefono {get;set;}

        @AuraEnabled 
        public String estado {get;set;}

		@AuraEnabled 
        public String idFirstEmployee {get;set;}

		@AuraEnabled 
        public String firstEmployee {get;set;}
        
        public Wrapper(String idCall, String callName, String accountId, String accountName, String tipo, Datetime fechaInicio, String duracion, String telefono, String estado, String idFirstEmployee, String firstEmployee ) {
            
            this.idCall = '/' + idCall;
            this.callName = callName;
            this.accountId = (accountId != null) ? '/' + accountId : '';
            this.accountName = (accountName != null) ? accountName : '';
            this.tipo = tipo;
            this.fechaInicio = fechaInicio;
            this.duracion = duracion;
            this.telefono = telefono;
            this.estado = estado;
			this.idFirstEmployee = (idFirstEmployee != null) ? '/' + idFirstEmployee : '';
            this.firstEmployee = (firstEmployee != null) ? firstEmployee : '';
        }		
		
		// Implementación del método compareTo para comparar por fechaInicio y luego por accountName
        public Integer compareTo(Object compareTo) {
            Wrapper other = (Wrapper) compareTo;

            // Comparar por fechaInicio
            if (this.fechaInicio == null && other.fechaInicio == null) {
                return 0;
            } else if (this.fechaInicio == null) {
                return -1;
            } else if (other.fechaInicio == null) {
                return 1;
            }

            Long thisTime = this.fechaInicio.getTime();
            Long otherTime = other.fechaInicio.getTime();

            if (thisTime < otherTime) {
                return -1;
            } else if (thisTime > otherTime) {
                return 1;
            }

            // Si las fechas son iguales, comparar por accountName
            if (this.accountName == null && other.accountName == null) {
                return 0;
            } else if (this.accountName == null) {
                return -1;
            } else if (other.accountName == null) {
                return 1;
            }

            Integer accountNameComparison = this.accountName.toLowerCase().compareTo(other.accountName.toLowerCase());

            return accountNameComparison;
        }
		
    }

	@AuraEnabled(cacheable = true)
	public static List<String> getUserPermissions() {

		String userId = UserInfo.getUserId();
		User currentUser = [SELECT AV_ExternalId__c FROM User WHERE Id = :userId];
		List<PermissionSetAssignment> assignments = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
		List<String> permissionSetNames = new List<String>();
		for (PermissionSetAssignment psa : assignments) {
			permissionSetNames.add(psa.PermissionSet.Name);
		}
		return permissionSetNames;
	}

    @AuraEnabled
    public static void discardCalls(List<String> callsList) {
        try {
            List<Wrapper> listReturn = new List<Wrapper>();
            List <CC_Llamada__c> callQuery = [SELECT Id, TOLABEL (AV_State__c) FROM CC_Llamada__c WHERE Id IN :callsList];
            if (!callsList.isEmpty()){
                for (CC_Llamada__c call : callQuery){
                    call.AV_State__c = 'Descartada';
                }
                update callQuery;
            }
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error al descartar llamadas.');
        }
    }

}