/**********************************************************************************************************************
Name:	  AV_UpdateCliPremium_Controller
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "av_Update_Cli_Premium"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR              DATE			Description
    1.0         SF - Integración con API's de CLI, Colectivos       Álvaro López        22/10/2020		Init version
    1.1         Fix API Premium                                     Álvaro López        30/10/2020      Fix API
    1.2         Fix API Premium                                     Álvaro López        06/11/2020      Fix API nulls
    1.3         Fix API Premium                                     Álvaro López        26/11/2020      Format change for principaBranch API field
    1.4			SF - Cálculo preconcedido API de Clientes Premium	Sandra Gómez		30/11/2020		Add logic isPreconceived
    1.5			US157772											Sandra Gómez		08/03/2021		Add logic interlocId
    1.6			US246774/US169601									Sandra Gómez		16/08/2021		Change fields new version API Premium
    1.7			Fix													Víctor Santiago		17/09/2021		getCustomerJourney modified to update
                                                                                                        after Account.AV_FechaRefrescoCustomerJourney__c
	1.8			Fix													David Rufo			19/09/2021		error to retrieve the balance data
	1.9 		Fix Performance										Carolina Alonso		21/10/2021		Fix performance in the method getCliPremiumData
	2.0		    AV_Query IT	   										Daniel Rodríguez	07/02/2022	    Change AV_Query to SOQL for User, Account, Contact
	2.1			Fix - US329551										Sandra Gómez		24/03/2022		Add field AV_Interlocutor__c
	2.2 		Ampliación campos CIBE								Alejandro Campos	10/06/2022		Added fields which start with CIBE_
	2.3			US497003											Sandra Gómez		13/12/2022		Delete field AV_MyBox__c and AV_TargetAuto__c
	2.4			US485705											Luis Fernández		08/02/2023		Added updateRecordApex
	2.5			US592987											Ángel Medina		29/05/2023		Changed AV_Query to SOQL queries
	2.6         US478565                                            Oscar Moreno        09/06/2023      Add validateTreatmentData method
	2.7         US609232                                            Oscar Moreno        13/06/2023      The call to Adobe Campaingn is commented out because it is not working
	2.8      	Fix PMD Errors 										Humberto Vilchez 	23/10/2023 		Add WITH SECURITY_ENFORCED to queries

***********************************************************************************************************************/
public with sharing class AV_UpdateCliPremium_Controller {
	
	public static final String BRANCH_PREFIX = '001-';
	/**
	* Method that call to Cli Premium API and returns a map with the new values for account fields
	*
	* @param numPerson String with the client's numPerson code
	* @param fechaRefresco last data refresh date
	* @param jsonBody last json body response
	* @return String with the account fields for updating record from component
	*/
	@AuraEnabled(cacheable=true)
	public static String retrieveCustomerData(String numPerson, DateTime fechaRefresco, String jsonBody){
		if(numPerson != null){
			if(jsonBody == null || (fechaRefresco != null && AV_AppUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24)){
				AV_FichaCliente_Integration.CustomerResponse result = AV_FichaCliente_Integration.getDataCustomer(numPerson);
				if('200'.equalsIgnoreCase(result.statusCode)){
					Map<String, Object> mapAccountFields = getMapAccountFields(result.data);
					Map<String, Object> mapLastContact = retrieveLastEvent(numPerson);
					mapAccountFields.putAll(mapLastContact);
					return JSON.serialize(mapAccountFields);
				}
			}
		}
		return null;
	}

	/**
	* Method that get the value of AV_FechaRefrescoCustomerJourney__c of the record
	*
	* @param recordId Id of the record
	* @return null
	*/
	@AuraEnabled
	public static String getCustomerJourney(String recordId) {
		String methodName = 'getCustomerJourney';
		Datetime fechaRefresco = null;
		String numPerson = null;
		if (recordId != null) {
			Account acc = [Select Id, AV_FechaRefrescoCustomerJourney__c, AV_NumPerso__c From Account Where Id = :recordId WITH SECURITY_ENFORCED limit 1];
			if (acc != null) {
				numPerson = acc.AV_NumPerso__c;
				fechaRefresco = acc.AV_FechaRefrescoCustomerJourney__c;
			}
			/*---Do not delete the commented code in case you need to make the call again in the future ---
			if(String.isNotBlank(numPerson)) {
				if (fechaRefresco == null || AV_AppUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24) {
					String result = AV_AdobeCampaingnCJ_Integration.syncCJ(numPerson);
					AV_LogDebug.printLogDebug(methodName, 'Integration result: ' + result);
					return result;
				}
			}
			*/
		}

		return null;
	}

	/**
	* Method that gets via query the last contact info
	*
	* @param numPerson String with the client's numPerson code
	* @return Map<String, Object> with the account fields for updating record from component
	*/
	private static Map<String, Object> retrieveLastEvent(String numPerson){
		String query = 'SELECT  Id, StartDateTime, TOLABEL(AV_Tipo__c) ';
		query += ' FROM Event ';
		query += ' WHERE Account.AV_NumPerso__c = :numPerson ORDER BY StartDateTime DESC LIMIT 1 '; 


		List<Event> events = (List<Event>) Database.query(query);
		Map<String, Object> mapAccountFields = new Map<String, Object>();

		if(!events.isEmpty()){
			Event ev = events[0];
			mapAccountFields.put('AV_LastContactDate__c', ev.StartDateTime);
			mapAccountFields.put('AV_TypeEvent__c', ev.AV_Tipo__c);
		}

		return mapAccountFields; 
	}

	/**
	 * @description		Gets the Client Premium data for the requested client.
	 * @param recordId Id of the record
	 * @return String with the account fields for updating record
	 */
	@AuraEnabled
	public static String getCliPremiumData(String recordId) {
		String syncResult;
		String result;
		if (recordId != null) {
			Account acc = [Select AV_NumPerso__c, AV_FechaRefrescoClientePremium__c, AV_JSONClientePremium__c From Account Where Id = :recordId WITH SECURITY_ENFORCED];
			result = retrieveCustomerData(acc.AV_NumPerso__c, acc.AV_FechaRefrescoClientePremium__c, acc.AV_JSONClientePremium__c);
			
			
			if (result == null) {
				validateTreatmentData(recordId);
				result = JSON.serialize(acc);
			}
	
		
			return result;
		}
		return null;
	}

	/**
	* Method that map the body response info with account fields
	*
	* @param data API Premium response structure for mapping with account fields
	* @return Map<String, Object> with the account fields for updating record from component
	*/
	private static Map<String, Object> getMapAccountFields(AV_FichaCliente_Integration.CustomerData data){

		Map<String, Object> mapAccountFields = new Map<String, Object>();

		mapAccountFields.put('AV_JSONClientePremium__c', JSON.serialize(data));
		mapAccountFields.put('AV_FechaRefrescoClientePremium__c', System.now());
		//customerInternalId
		String customerInternalId = (String)validateNull(data.customerInternalId, 'convertString');
		mapAccountFields.put('AV_NumPerso__c', customerInternalId);
        
        //Juridico
        if ('J'.equalsIgnoreCase(data.customerType.key)){
            //customerName
            mapAccountFields.put('Name', (String)validateNull(data.customerLastName));
            //email (no hay campo en SF)
			
			mapAccountFields.put('CIBE_GrupoEconomico__c', (String)validateNull(data.comercialGroup));
			mapAccountFields.put('CIBE_DomicilioSocial__c', (String)validateNull(data.adressNumber));
        }
        //Fisico
        else{
            //customerName
            mapAccountFields.put('FirstName', (String)validateNull(data.customerName));
            //customerLastName
            mapAccountFields.put('LastName', (String)validateNull(data.customerLastName));
            //email
            mapAccountFields.put('PersonEmail', (String)validateNull(data.email));
            //mobilePhone
            String mobilePhone = (String)validateNull(data.mobilePhoneNumber, 'convertString');
            mapAccountFields.put('PersonMobilePhone', mobilePhone);
            //birthDate
			String birthDate=(String)validateNull(data.birthDate);
			mapAccountFields.put('PersonBirthdate', birthDate);
        }
        
		
		//customerDocId
		if(data.customerDocId != null) {
			mapAccountFields.put('CC_TipoDocumento__c', data.customerDocId.key);
			mapAccountFields.put('CC_Numero_Documento__c', data.customerDocId.value);
		} else {
			mapAccountFields.put('CC_TipoDocumento__c', null);
			mapAccountFields.put('CC_Numero_Documento__c', null);
		}
		
		//constitutionDate
		mapAccountFields.put('AV_ConstitutionDate__c', (String)validateNull(data.constitutionDate));
		//language
		String language = (String)validateNull(data.language);
		language = language != null ? AV_IntegrationUtilities.leftPadZero(language, 3) : null;
		mapAccountFields.put('AV_Idioma__c', language);
        //phone
		String phone = (String)validateNull(data.phoneNumber, 'convertString');
		mapAccountFields.put('Phone', phone);
		//interlocId
		String interlocId = (String)validateNull(data.interlocId, 'convertString');
		mapAccountFields.put('AV_NumPersoInterloc__c', interlocId);
		if(String.isNotBlank(String.valueOf(data.interlocId))){
			List<Account> listAcc= [Select Id, Name From Account Where AV_NumPerso__c = :String.valueOf(data.interlocId) WITH SECURITY_ENFORCED limit 1];

			if(!listAcc.isEmpty()){
				if (String.valueOf(data.interlocId) == customerInternalId){
					mapAccountFields.put('AV_Interloc__c', Label.AV_Interloc);
					mapAccountFields.put('AV_Interlocutor__c', null);
				}else {
					mapAccountFields.put('AV_Interlocutor__c', listAcc[0].Id);
					mapAccountFields.put('AV_Interloc__c', listAcc[0].Name);
				}
			} else {
				mapAccountFields.put('AV_Interlocutor__c', null);
				mapAccountFields.put('AV_Interloc__c', null);
			}
		}
		//interlocName
		mapAccountFields.put('AV_InterlocName__c', (String)validateNull(data.interlocName));
		//employeeId
		if(String.isNotBlank(data.employeeId)){
			List<Contact> listEmployee= [Select Id From Contact Where CC_Matricula__c = :data.employeeId WITH SECURITY_ENFORCED limit 1];
		
			if(!listEmployee.isEmpty()){
				mapAccountFields.put('AV_EAPGestor__c', listEmployee[0].Id);
			} else {
				mapAccountFields.put('AV_EAPGestor__c', null);
			}
		}
		//principaBranch -> CC_Numero_Oficina_Empresa__c de Account
		if(data.principalBranch != null){
			String branchNum = BRANCH_PREFIX + AV_IntegrationUtilities.leftPadZero(String.valueOf(data.principalBranch), 5);
			List<Account> listPrincipalBranch= [Select Id From Account Where CC_Numero_Oficina_Empresa__c = :branchNum limit 1];
			if(!listPrincipalBranch.isEmpty()){
				mapAccountFields.put('AV_OficinaPrincipal__c', listPrincipalBranch[0].Id);
			} else {
				mapAccountFields.put('AV_OficinaPrincipal__c', null);
			}
		} else {
			mapAccountFields.put('AV_OficinaPrincipal__c', null);
		}
		//relatedBranch -> AV_OficinasRelacionadas__c separado por ","
		if(data.relatedBranch != null) {
			if(!data.relatedBranch.isEmpty()){
				List<String> listStringRelatedBranch = new List<String>();
				String relatedBranchString = '';
				for(Integer i = 0; i<data.relatedBranch.size(); i++){
					listStringRelatedBranch.add(String.valueOf(data.relatedBranch[i]));
					if(i < data.relatedBranch.size() - 1){
						relatedBranchString += String.valueOf(data.relatedBranch[i]) + ', ';
					}else{
						relatedBranchString += String.valueOf(data.relatedBranch[i]);
					}
				}
				mapAccountFields.put('AV_OficinasRelacionadas__c', relatedBranchString);
			} else {
				mapAccountFields.put('AV_OficinasRelacionadas__c', null);
			}
		} else {
			mapAccountFields.put('AV_OficinasRelacionadas__c', null);
		}
		//wall
		Boolean wall = (Boolean)validateNull(data.wall) != null ? (Boolean)validateNull(data.wall) : false;
		mapAccountFields.put('AV_Muro__c', wall);
		//segment
		AV_FichaCliente_Integration.DataKeyValue mapSegmentValue = (AV_FichaCliente_Integration.DataKeyValue)validateNull(data.segment);
		if(mapSegmentValue != null && data.segment != null) {
			String segmentValue = data.segment!= null ? data.segment.value : null;
			mapAccountFields.put('AV_Segmento__c', segmentValue);
		} else {
			mapAccountFields.put('AV_Segmento__c', null);
		}
		//isConfidential
		Boolean isConfidential = (Boolean)validateNull(data.isConfidential) != null ? (Boolean)validateNull(data.isConfidential) : false;
		mapAccountFields.put('AV_Confidencial__c', isConfidential);
		//confidentialBranch
		String confidentialBranch = (String)validateNull(data.confidentialBranch, 'convertString');
		mapAccountFields.put('AV_ConfidentialBranch__c', confidentialBranch);
		//scoring
		if(data.scoring != null){
			mapAccountFields.put('AV_Scoring__c', String.valueOf(data.scoring.value));
			mapAccountFields.put('AV_ScoringStatus__c', String.valueOf(data.scoring.status.key));
		} else {
			mapAccountFields.put('AV_Scoring__c', null);
			mapAccountFields.put('AV_ScoringStatus__c', null);
		}
		//rating
		if(data.rating != null){
			mapAccountFields.put('AV_Rating__c', String.valueOf(data.rating.value));
			if(data.rating.status != null){
				mapAccountFields.put('CIBE_RatingLetra__c', String.valueOf(data.rating.status.key));
			} else {
				mapAccountFields.put('CIBE_RatingLetra__c', null);
			}
		} else {
			mapAccountFields.put('AV_Rating__c', null);
		}
		//cirbeFee
		mapAccountFields.put('AV_CirbeFee__c', (Double)validateNull(data.cirbeFee));
		//isEmployee
		Boolean isEmployee = (Boolean)validateNull(data.isEmployee) != null ? (Boolean)validateNull(data.isEmployee) : false;
		mapAccountFields.put('AV_Empleado__c', isEmployee);
		//qualification
		mapAccountFields.put('AV_Qualification__c', (String)validateNull(data.qualification));
		//pctRar
		mapAccountFields.put('AV_PctRar__c', (Double)validateNull(data.pctRar));
		//addedValue
		mapAccountFields.put('AV_AddedValue__c', (Double)validateNull(data.addedValue));
		//attentionModel
		AV_FichaCliente_Integration.DataKeyValue mapAttentionModel = (AV_FichaCliente_Integration.DataKeyValue)validateNull(data.attentionModel);
		if(mapAttentionModel != null && data.attentionModel != null) {
			String attentionModel = data.attentionModel!= null ? data.attentionModel.key : null;
			mapAccountFields.put('AV_AttentionModel__c', attentionModel);
		} else {
			mapAccountFields.put('AV_AttentionModel__c', null);
		}
		//attentionLevel
		AV_FichaCliente_Integration.DataKeyValue mapAttentionLevel = (AV_FichaCliente_Integration.DataKeyValue)validateNull(data.attentionModel);
		if(mapAttentionLevel != null && data.attentionModel != null) {
			String attentionLevel = data.attentionModel!= null && (data.attentionModel.key.equalsIgnoreCase('1') || data.attentionModel.key.equalsIgnoreCase('2') || data.attentionModel.key.equalsIgnoreCase('3')) ? data.attentionModel.key : null;
			mapAccountFields.put('AV_AttentionLevel__c', attentionLevel);
		} else {
			mapAccountFields.put('AV_AttentionLevel__c', null);
		}
		//contactPerson
		mapAccountFields.put('AV_ContactPerson__c', (String)validateNull(data.contactPerson));
		//contactNumber
		String contactNumber = (String)validateNull(data.contactNumber, 'convertString');
		mapAccountFields.put('AV_ContactNumber__c', contactNumber);
		//realContactNumber
		String realContactNumber = (String)validateNull(data.realContactNumber, 'convertString');
		mapAccountFields.put('AV_RealContactNumber__c', realContactNumber);
		//loyaltySignals -> Campo multipicklist
		if(data.loyaltySignals != null && !data.loyaltySignals.isEmpty() && data.loyaltySignals != null){
				String loyaltySignalsAux = '';
				String loyaltySignalsAux2 = '';
				for(Integer i=0; i<data.loyaltySignals.size(); i++){
					if(i<data.loyaltySignals.size() - 1){
						loyaltySignalsAux += data.loyaltySignals[i].value + '\r\n';
						loyaltySignalsAux2 += data.loyaltySignals[i].key + ';';
					}else {
						loyaltySignalsAux += data.loyaltySignals[i].value;
						loyaltySignalsAux2 += data.loyaltySignals[i].key;
					}
				}
				mapAccountFields.put('AV_LoyaltySignals__c', loyaltySignalsAux);
                AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> loyaltySignalsAux: ' + loyaltySignalsAux);
				mapAccountFields.put('AV_IndicadoresClientes__c', loyaltySignalsAux2);
		} else {
			mapAccountFields.put('AV_LoyaltySignals__c', null);
			mapAccountFields.put('AV_IndicadoresClientes__c', null);
		}
		//loyaltyPrograms
		if(data.loyaltyPrograms != null){
			if(!data.loyaltyPrograms.isEmpty()){
				String loyaltyPrograms = '';
				for(Integer i=0; i<data.loyaltyPrograms.size(); i++){
					for(String value : data.loyaltyPrograms[i].program.values()) {
						if(value.equalsIgnoreCase('Día a Día')) {
							if(i<data.loyaltyPrograms.size() - 1){
								loyaltyPrograms += value + ' (' + data.loyaltyPrograms[i].compilanceValue + ')' + '\r\n';
							}else {
								loyaltyPrograms += value + ' (' + data.loyaltyPrograms[i].compilanceValue + ')';
							}
						}
						else {
							String compilance = data.loyaltyPrograms[i].isCompilance == true ? ' (Cumple)' : ' (No cumple)';
							if(i<data.loyaltyPrograms.size() - 1){
								loyaltyPrograms += value + compilance + '\r\n';
							}else {
								loyaltyPrograms += value + compilance;
							}
						}
					}
				}
				mapAccountFields.put('AV_LoyaltyPrograms__c', loyaltyPrograms);
			} else {
				mapAccountFields.put('AV_LoyaltyPrograms__c', null);
			}
		} else {
			mapAccountFields.put('AV_LoyaltyPrograms__c', null);
		}
		//customerBussines
		if(data.customerBusiness != null && data.customerBusiness != null){
			if(!data.customerBusiness.isEmpty()){
				String customerBussines = '';
				for(Integer i=0; i<data.customerBusiness.size(); i++){
					if(i<data.customerBusiness.size() - 1){
						customerBussines += data.customerBusiness[i].key + ';';
					}else {
						customerBussines += data.customerBusiness[i].key;
					}
				}
				mapAccountFields.put('AV_Negocio__c', customerBussines);
			} else {
				mapAccountFields.put('AV_Negocio__c', 'BPA');
			}
		} else {
			mapAccountFields.put('AV_Negocio__c', 'BPA');
		}
		//cnaeCode
		mapAccountFields.put('AV_CNAE__c', (String)validateNull(data.cnaeCode));
		//balance
		Map<String, String> mapBalanceKeys = new Map<String, String>{'F' => 'AV_IngresosProfesionales__c', 
            						'L' => 'AV_IngresosPersonales__c', 'N' => 'AV_IngresosPension__c', 
            						'R' => 'AV_Rentabilidad__c', 'A' => 'AV_Financiacion__c', 'P' => 'AV_AhorroEInversion__c'};
		if(data.balance != null) {
			if(!data.balance.isEmpty()){
				for(Integer i=0; i<data.balance.size(); i++){
					if(data.balance[i].type.get('key').equalsIgnoreCase('F')){
                        mapAccountFields.put('AV_IngresosProfesionales__c', data.balance[i].amount);
						mapBalanceKeys.remove('F');
					}
                    else if(data.balance[i].type.get('key').equalsIgnoreCase('L')){
                        mapAccountFields.put('AV_IngresosPersonales__c', data.balance[i].amount);
						mapBalanceKeys.remove('L');
					}
                    else if(data.balance[i].type.get('key').equalsIgnoreCase('N')){
                        mapAccountFields.put('AV_IngresosPension__c', data.balance[i].amount);
						mapBalanceKeys.remove('N');
					}
                    else if(data.balance[i].type.get('key').equalsIgnoreCase('R')){
                        mapAccountFields.put('AV_Rentabilidad__c', data.balance[i].amount);
						mapBalanceKeys.remove('R');
					}
                    else if(data.balance[i].type.get('key').equalsIgnoreCase('A')){
                        mapAccountFields.put('AV_Financiacion__c', data.balance[i].amount);
						mapBalanceKeys.remove('A');
					}
                    else if(data.balance[i].type.get('key').equalsIgnoreCase('P')){
						mapAccountFields.put('AV_AhorroEInversion__c', data.balance[i].amount);
						mapBalanceKeys.remove('P');
					}
				}
                //Empty value fields if not exist in the response
				for(String nullField : mapBalanceKeys.values()) {
					mapAccountFields.put(nullField, null);
				}
			}
		} else {
			mapAccountFields.put('AV_IngresosProfesionales__c', null);
			mapAccountFields.put('AV_IngresosPersonales__c', null);
			mapAccountFields.put('AV_IngresosPension__c', null);
			mapAccountFields.put('AV_Rentabilidad__c', null);
			mapAccountFields.put('AV_AhorroEInversion__c', null);
			mapAccountFields.put('AV_Preconcedidos__c', '0 €');
		}
		//preferedChannel
		AV_FichaCliente_Integration.DataKeyValue mapPreferedChannel = (AV_FichaCliente_Integration.DataKeyValue)validateNull(data.preferedChanel);
		if(mapPreferedChannel != null && data.preferedChanel != null) {
			String preferedChannel = data.preferedChanel != null ? data.preferedChanel.key : null;
			mapAccountFields.put('AV_CanalDeContactoPreferente__c', preferedChannel);
		} else {
			mapAccountFields.put('AV_CanalDeContactoPreferente__c', null);
		}
		//contactTime
		if(data.contactTime != null){
			String initialTime = data.contactTime.initialTime;
			String finalTime = data.contactTime.finalTime;
			String horarioPreferencia;
			if(String.isNotBlank(initialTime) && String.isNotBlank(finalTime)){
				horarioPreferencia = initialTime + ' a ' + finalTime;
			}
			if(String.isNotBlank(horarioPreferencia)){
				mapAccountFields.put('AV_HorarioDeContactoPreferente__c', horarioPreferencia);
			} else {
				mapAccountFields.put('AV_HorarioDeContactoPreferente__c', null);
			}
		} else {
			mapAccountFields.put('AV_HorarioDeContactoPreferente__c', null);
		}
		//colectives
		if(data.colectives != null){
			if(!data.colectives.isEmpty()){
				Set<String> setFields = new Set<String>{'AV_ExternalID__c', 'AV_Description__c'};
				List<String> listStringColectives = new List<String>();
				String collectiveIds = '';
				for(Integer i = 0; i<data.colectives.size(); i++){
					listStringColectives.add(String.valueOf(data.colectives[i]));
					if(i < data.colectives.size() - 1){
						collectiveIds += String.valueOf(data.colectives[i]) + ', ';
					}else{
						collectiveIds += String.valueOf(data.colectives[i]);
					}
				}
				mapAccountFields.put('AV_Colectivos__c', collectiveIds);
				List<AV_Collective__c> listCollectives = [SELECT AV_ExternalID__c, AV_Description__c FROM AV_Collective__c WHERE AV_ExternalID__c IN :listStringColectives WITH SECURITY_ENFORCED];
	
				if(!listCollectives.isEmpty()){
					String collectiveNames = '';
					for(Integer i = 0; i<listCollectives.size(); i++){
						if(i < listCollectives.size() - 1){
							collectiveNames += listCollectives[i].AV_Description__c + '\r\n';
						}else{
							collectiveNames += listCollectives[i].AV_Description__c;
						}
					}
					mapAccountFields.put('AV_NombresColectivos__c', collectiveNames);
				}
			}
		} else {
			mapAccountFields.put('AV_Colectivos__c', null);
			mapAccountFields.put('AV_NombresColectivos__c', null);
		}
		//isClient
		Boolean isClient = (Boolean)validateNull(data.isClient) != null ? (Boolean)validateNull(data.isClient) : false;
		mapAccountFields.put('AV_Cliente__c', isClient);
		//clientExperience
		String clientExperience = (String)validateNull(data.clientExperience, 'convertString');
		mapAccountFields.put('AV_Satisfaccion__c', clientExperience);
		//isPreconceived
		Boolean isPreconceived = (Boolean)validateNull(data.isPreconceived) != null ? (Boolean)validateNull(data.isPreconceived) : false;
		mapAccountFields.put('AV_IsPreconceived__c', isPreconceived);
		List<AV_ProductClient__c> listProductoCliente = [SELECT AV_ImportePreconcedido__c FROM AV_ProductClient__c WHERE AV_Cliente__r.AV_NumPerso__c = :customerInternalId AND AV_ImportePreconcedido__c != null AND AV_ImportePreconcedido__c != 0 WITH SECURITY_ENFORCED ORDER BY  AV_ImportePreconcedido__c DESC LIMIT 1];
	
		if (listProductoCliente!=null && !listProductoCliente.isEmpty()) {
			Decimal importePreconcedido=listProductoCliente[0].AV_ImportePreconcedido__c;
			mapAccountFields.put('AV_Preconcedidos__c', importePreconcedido.setScale(2).format().contains(',') ? (importePreconcedido.setScale(2).format() + ' €') : (importePreconcedido.setScale(2).format() + ',00 €'));
		} else {
			mapAccountFields.put('AV_Preconcedidos__c',null);
		}
		//subAttentionModel
		mapAccountFields.put('AV_SubmodeloAtencion__c', (String)validateNull(data.subAttentionModel));
		//isCompilanceAttentionModel
		Boolean isCompilanceAttentionModel = (Boolean)validateNull(data.isCompilanceAttentionModel) != null ? (Boolean)validateNull(data.isCompilanceAttentionModel) : false;
		mapAccountFields.put('AV_CumpleModelo__c', isCompilanceAttentionModel);
		//isMustCompilanceAttentionModel
		Boolean isMustCompilanceAttentionModel = (Boolean)validateNull(data.isMustCompilanceAttentionModel) != null ? (Boolean)validateNull(data.isMustCompilanceAttentionModel) : false;
		mapAccountFields.put('AV_DebeCumplirModelo__c', isMustCompilanceAttentionModel);
		//attentionModelCompilance
		mapAccountFields.put('AV_PorCumplimiento__c', (Integer)validateNull(data.attentionModelCompilance));
		//globalCompilancePercentage
		mapAccountFields.put('AV_PorAtencionGlobal__c', (Integer)validateNull(data.globalCompilancePercentage));
		//compilanceDateLimit
		String compilanceDateLimit=(String)validateNull(data.compilanceDateLimit);
		mapAccountFields.put('AV_FechaPrevIncumple__c', compilanceDateLimit);
		//advisedClient
		mapAccountFields.put('AV_IndicadorAsesorado__c', (Integer)validateNull(data.advisedClient));
		
		//Preconcedido
		mapAccountFields.put('AV_Preconceived__c', data.preconceived);
		
		AV_LogDebug.printLogDebug('getMapAccountFields', 'mapAccountFields: ' + mapAccountFields);
		return mapAccountFields;
	}

	/**
	* Method that validates if response data is null
	*
	* @param data API Premium response data field
	* @return Object data or null
	*/
	private static Object validateNull(Object data) {
		if(data == null) {
			return null;
		}
		return data;
	}
	private static Object validateNull(Object data, String type) {
		if(data == null) {
			return null;
		}
		switch on type {
			when 'convertString' {
				return String.valueOf(data);
			}
		}
		return data;
	}

	/**
	* Method that update a record
	*
	* @param record String of the record
	* @param recordId Id of the record
	* @return boolean
	*/
	@AuraEnabled
	public static Boolean updateRecordApex(String record,String recordId){
		Account acc = (Account) JSON.deserializeStrict(record, Account.class);
		acc.Id = recordId;
		Database.SaveResult sr = Database.update(acc, false);
		
		return sr.isSuccess();
	
		
	}

	/**
	* Method that assign null to the following fields depending on the value of the AV_DataTreatment__c field
	*
	* @param recordId Id of teh record
	*/
	@AuraEnabled
	public static void validateTreatmentData(String recordId){
		if (recordId != null) {
			List<Account> acc = [Select Id,AV_DataTreatment__c,AV_TargetAuto__c,AV_MyBox__c from Account where Id = :recordId AND RecordType.DeveloperName =: AV_AppConstants.ACCOUNT_PA_RT WITH SECURITY_ENFORCED limit 1 ];
			if(acc!=null && !acc.isEmpty()){
				if(acc[0].AV_DataTreatment__c == '2'){
					acc[0].AV_Rentabilidad__c = null;				
					acc[0].AV_Preconceived__c = null;
					acc[0].AV_IngresosPension__c = null;
					acc[0].AV_IngresosPersonales__c = null;
					acc[0].AV_IngresosProfesionales__c = null;
					acc[0].AV_TargetAuto__c = null;
					acc[0].AV_Colectivos__c = null;
					acc[0].AV_LoyaltySignals__c = null;
				}
				if(acc[0].AV_DataTreatment__c == '3'){
					acc[0].AV_Rentabilidad__c = null;
					acc[0].AV_Preconceived__c = null;
					acc[0].AV_IngresosPension__c = null;
					acc[0].AV_IngresosPersonales__c = null;
					acc[0].AV_IngresosProfesionales__c = null;
					acc[0].AV_TargetAuto__c = null;
					acc[0].AV_MyBox__c = null;
					acc[0].AV_Colectivos__c = null;
					acc[0].AV_LoyaltySignals__c = null;
				}

			Database.update(acc);

			}
		}
		
	}

	

}