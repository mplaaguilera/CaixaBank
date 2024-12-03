/**********************************************************************************************************************
Name:	  CIBE_UpdateCliPremium_Controller
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
	2.3         eliminacion adobe campaign							Alex Perez			20/06/2023
***********************************************************************************************************************/




public with sharing class CIBE_UpdateCliPremium_Controller {
	
	private static final String AV_FICHACLIENTE			 	= 'AV_FichaCliente';
	private static final String AV_FICHACLIENTE_ALERTAS	 	= 'AV_FichaCliente_Alertas';
	private static final String AV_FICHACLIENTE_PRODUCTOS   = 'AV_FichaCliente_Productos';
	private static final String AV_FICHACLIENTE_SENALES	 	= 'AV_FichaCliente_Senales';
	private static final String AV_FICHACLIENTE_MAPAPROD	= 'AV_FichaCliente_MapaProductos';
	private static final String AV_FICHACLIENTE_DETALLEPF   = 'AV_FichaCliente_DetalePF';
	private static final String CIBE_FICHACLIENTE			= 'CIBE_FichaCliente';
	private static final String CIBE_FICHACLIENTE_ALERTAS	= 'CIBE_FichaCliente_Alertas';
	private static final String CIBE_FICHACLIENTE_PRODUCTOS = 'CIBE_FichaCliente_Productos';
	private static final String CIBE_FICHACLIENTE_SENALES	= 'CIBE_FichaCliente_Senales';
	private static final String CIBE_FICHACLIENTE_MAPAPROD	= 'CIBE_FichaCliente_MapaProductos';
	private static final String CIBE_FICHACLIENTE_DETALLEPF = 'CIBE_FichaCliente_DetalePF';

	private static final String PARAM_USERID_OLD   = 'x-userId';
	private static final String PARAM_CUSTOMERINTERNALID  = 'x-absis-customerInternalId';
	private static final String PARAM_PROFILEIDSAP = 'x-absis-profile-from-idsap';
	private static final String PARAM_USERID   = 'X-ABSIS-HEADER-SESSION-numperso';

	//public static final Map<String, List<Products>> MAPEXPERIENCELISTPRODUCT = new Map<String, List<Products>>();
	//public static final Map<String, Boolean> MAPEXPERIENCEMYBOX = new Map<String, Boolean>();


	public class CustomerResponse {
		@AuraEnabled
		public String statusCode;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
		@AuraEnabled
		public CustomerData data;
	}

	public class CustomerData {
		@AuraEnabled
		public Integer customerInternalId;
		@AuraEnabled
		public String customerName;
		@AuraEnabled
		public String customerLastName;
		@AuraEnabled
		public DataKeyValue customerDocId;
		@AuraEnabled
		public Date birthDate;
		@AuraEnabled
		public Date constitutionDate;
		@AuraEnabled
		public String language;
		@AuraEnabled
		public String email;
		@AuraEnabled
		public String employeeId;
		@AuraEnabled
		public String employeeName;
		@AuraEnabled
		public Integer interlocId;
		@AuraEnabled
		public String interlocName;
		@AuraEnabled
		public List<Integer> relatedBranch;
		@AuraEnabled
		public List<LoyaltyProgram> loyaltyPrograms;
		@AuraEnabled
		public List<Balance> balance;
		@AuraEnabled
		public Boolean wall;
		@AuraEnabled
		public List<LoyaltyLink> loyaltyLink;
		@AuraEnabled
		public DataKeyValue segment;
		@AuraEnabled
		public Boolean isConfidential;
		@AuraEnabled
		public Integer confidentialBranch; 
		@AuraEnabled
		public DataKeyValue customerType;
		@AuraEnabled
		public Boolean isEmployee;
		@AuraEnabled
		public List<DataKeyValue> loyaltySignals;
        @AuraEnabled
        public Rating rating;
        @AuraEnabled
        public Scoring scoring;
        @AuraEnabled
        public String cirbeFee;
        @AuraEnabled
        public String qualification;
        @AuraEnabled
        public String pctRar;
        @AuraEnabled
        public String addedValue;
		@AuraEnabled
        public String contactPerson;
        @AuraEnabled
		public DataKeyValue attentionModel;
		@AuraEnabled
		public Integer contactNumber; 
		@AuraEnabled
		public Integer realContactNumber;
		@AuraEnabled
        public String cnaeCode;
        @AuraEnabled
		public String locality;
		@AuraEnabled
		public String country;
		@AuraEnabled
		public String comercialGroup;
		@AuraEnabled
        public ContactTime contactTime;
        @AuraEnabled
		public DataKeyValue preferedChanel;
		@AuraEnabled
		public List<Integer> colectives;
		@AuraEnabled
		public Boolean isClient;
		@AuraEnabled
        public Integer clientExperience;
        @AuraEnabled
		public Boolean isPreconceived;
		//new fields API v2
		@AuraEnabled
		public DataKeyValue subBusiness;
		@AuraEnabled
		public List<DataKeyValue> relatedEntities;
		@AuraEnabled
        public String adressNumber;
		@AuraEnabled
        public Integer postCode;
		@AuraEnabled
		public String attentionModelType;
		@AuraEnabled
		public Integer attentionModelCompilance;
		@AuraEnabled
		public Boolean isCompilanceAttentionModel;
		@AuraEnabled
		public Boolean isMustCompilanceAttentionModel;
		@AuraEnabled
		public Integer globalCompilancePercentage;
		@AuraEnabled
		public String compilanceDateLimit;
		@AuraEnabled
		public String subAttentionModel;
		@AuraEnabled
		public Integer mobilePhoneNumber;
		@AuraEnabled
		public String phoneNumber;
		@AuraEnabled
		public Integer principalBranch;
		@AuraEnabled
		public List<DataKeyValue> customerBusiness;
		@AuraEnabled
		public Integer riskMatrix;
		@AuraEnabled
		public String phonePrefix;
		@AuraEnabled
		public String mobilePhonePrefix;
		@AuraEnabled
		public String advisedClient;
		@AuraEnabled
		public Integer preconceived;
		@AuraEnabled
		public String myBox;
		@AuraEnabled
		public String targetAuto;
		@AuraEnabled
		public Boolean isAdvised;
		@AuraEnabled
		public String prevalence;
		@AuraEnabled
		public DataKeyValue sectorCountable;
		@AuraEnabled
		public DataKeyValue  sectorReporting;
		@AuraEnabled
		public String LEXDate;
		@AuraEnabled
		public Extended Extended;
		
	}

	public class Extended {
		@AuraEnabled
		public Integer groupProfitabilityPct;
		
	}

	public class Balance {
		@AuraEnabled
		public Map<String, String> type;
		@AuraEnabled
		public Double amount;	
	}

	public class LoyaltyLink {
		@AuraEnabled
		public Boolean isCompilance;
		@AuraEnabled
		public String indicators;
		@AuraEnabled
		public String financialIndicator;
	}

	public class LoyaltyProgram {
		@AuraEnabled
		public Map<String, String> program;
		@AuraEnabled
		public Boolean isCompilance;
		@AuraEnabled
		public String compilanceValue;
	}

	public class ContactTime {
		@AuraEnabled
        public Map<String, String> timePeriod;
        @AuraEnabled
        public String initialTime;
        @AuraEnabled
        public String finalTime;
    }
    
    public class Rating {
		@AuraEnabled
		public DataKeyValue status;
        @AuraEnabled
        public String value;
    }
    
    public class Scoring {
        @AuraEnabled
		public DataKeyValue status;
        @AuraEnabled
        public String value;
	}


	public class WrapperResponse {
        @AuraEnabled
		public Map<String,Object> eventResponse;
        @AuraEnabled
        public String responseFromUpdateAccount;
		@AuraEnabled
        public CustomerData customerData;
	}



	public class DataKeyValue {
		@AuraEnabled
		public String key;
		@AuraEnabled
		public String value;

		public DataKeyValue(String key, String value){
			this.key = key;
			this.value = value;
		}
	}
	
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
	public static WrapperResponse retrieveCustomerData(String numPerson, DateTime fechaRefresco, String jsonBody){
		WrapperResponse wrapper = new WrapperResponse();

		if(numPerson != null){
			Http http = new Http();

			if(jsonBody == null || (fechaRefresco != null && AV_APPUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24)){

				Map<String,string> mHeaders =  new  Map<String,string>();
				mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
				Long longUser = long.valueOf(numPerson);
				String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
				mHeaders.put('x-absis-customerInternalId',hexDigest);

				HttpRequest req = CBK_HttpServiceIntegration.getRequest('', 'getCustomers', 'GET', mHeaders);
				HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req);
				System.debug('Response: ' + res.getBody());
				if(res.getStatusCode() == 200){
					CustomerData resp = (CustomerData)JSON.deserialize(res.getBody(),CustomerData.class);     
					System.debug('resp wrapper: ' +resp);

					wrapper.responseFromUpdateAccount = updateAccount(resp);
					wrapper.eventResponse = retrieveLastEvent(numPerson);
					wrapper.customerData = resp;
					System.debug( 'wrapper.eventResponse: ' + wrapper);
					return wrapper;
				} else {
					string sError = 'NumPerso: ' + numPerson + '. Response Error: ' + res.getStatusCode() + ' ' + res.getBody();
                    //quitar el cbk log cuando el tratamiento de errores por status code funcione correctamente a nivel de fwk
                    cbk_log.error(sError);
				}
			}
		}
		return wrapper;
	}

	/*@AuraEnabled
	public static String getCustomerJourney(String recordId) {
		String methodName = 'getCustomerJourney';
		Datetime fechaRefresco = null;
		String numPerson = null;
		if (recordId != null) {
			Account acc = [Select Id, AV_FechaRefrescoCustomerJourney__c, AV_NumPerso__c From Account Where Id = :recordId limit 1];*/
			/*Account acc = (Account) new AV_Query('Account')
										.selectFields('Id, AV_FechaRefrescoCustomerJourney__c, AV_NumPerso__c' )
										.addConditionEq('Id', recordId)
										.fetch();*/
		/*	if (acc != null) {
				numPerson = acc.AV_NumPerso__c;
				fechaRefresco = acc.AV_FechaRefrescoCustomerJourney__c;
			}
			if(String.isNotBlank(numPerson)) {
				if (fechaRefresco == null || AV_APPUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24) {
					String result = AV_AdobeCampaingnCJ_Integration.syncCJ(numPerson);
					AV_LogDebug.printLogDebug(methodName, 'Integration result: ' + result);
					return result;
				}
			}
		}

		return null;
	}*/

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
	 */
	@AuraEnabled
	public static WrapperResponse getCliPremiumData(String recordId) {
		//Account acc;
		String syncResult;
		WrapperResponse wrapper = new WrapperResponse();
		if (recordId != null) {
			Account acc = [Select AV_NumPerso__c,IsPersonAccount, AV_FechaRefrescoClientePremium__c, AV_JSONClientePremium__c From Account Where Id = :recordId];
			/*AV_Query query = new AV_Query('Account')
							.selectFields('AV_NumPerso__c, AV_FechaRefrescoClientePremium__c, AV_JSONClientePremium__c')
							.addConditionEq('Id', recordId);
			acc = (Account) query.fetch();*/
			wrapper = retrieveCustomerData(acc.AV_NumPerso__c, acc.AV_FechaRefrescoClientePremium__c, acc.AV_JSONClientePremium__c);
		  
			
			return wrapper;
		}
		return wrapper;
	}

	/**
	* Method that map the body response info with account fields
	*
	* @param data API Premium response structure for mapping with account fields
	* @return Map<String, Object> with the account fields for updating record from component
	*/
	private static Map<String, Object> getMapAccountFields(CustomerData data,Boolean personAccount){

		Map<String, Object> mapAccountFields = new Map<String, Object>();

		mapAccountFields.put('AV_JSONClientePremium__c', JSON.serialize(data));
		mapAccountFields.put('AV_FechaRefrescoClientePremium__c', System.now());
		//customerInternalId
		String customerInternalId = (String)validateNull(data.customerInternalId, 'convertString');
		mapAccountFields.put('AV_NumPerso__c', customerInternalId);
        
        //Juridico
        //AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> customerType: ' + data.customerType.key);
        if ('J'.equalsIgnoreCase(data.customerType.key)){
            //customerName
            mapAccountFields.put('Name', (String)validateNull(data.customerLastName));
            //email (no hay campo en SF)
            //mapAccountFields.put('Email', (String)validateNull(data.email));
			
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
			/*if(personAccount == true) {
				mapAccountFields.put('CC_Email__c', (String)validateNull(data.email));
			} else {
            mapAccountFields.put('PersonEmail', (String)validateNull(data.email));
			}*/
            //mobilePhone
            /*String mobilePhone = (String)validateNull(data.mobilePhoneNumber, 'convertString');
            mapAccountFields.put('PersonMobilePhone', mobilePhone);*/
            //birthDate
			Date birthDate=(Date)validateNull(data.birthDate);
			mapAccountFields.put('PersonBirthdate', birthDate);
        }
        
		
		//customerDocId
		if(data.customerDocId != null) {
            //AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> customerDocId: ' + data.customerDocId.key);
			mapAccountFields.put('CC_TipoDocumento__c', data.customerDocId.key);
			mapAccountFields.put('CC_Numero_Documento__c', data.customerDocId.value);
		} else {
			mapAccountFields.put('CC_TipoDocumento__c', null);
			mapAccountFields.put('CC_Numero_Documento__c', null);
		}
		
		//constitutionDate
		mapAccountFields.put('AV_ConstitutionDate__c', (Date)validateNull(data.constitutionDate));
		//language
		String language = (String)validateNull(data.language);
		language = language != null ? AV_IntegrationUtilities.leftPadZero(language, 3) : null;
		mapAccountFields.put('AV_Idioma__c', language);
        //phone & email
		if(personAccount) {
			mapAccountFields.put('PersonMobilePhone', (String)validateNull(data.MobilephoneNumber, 'convertString'));
			mapAccountFields.put('PersonEmail', (String)validateNull(data.email));

		} else {
			mapAccountFields.put('CIBE_Movil__c', (String)validateNull(data.MobilephoneNumber, 'convertString'));
			mapAccountFields.put('CC_Email__c', (String)validateNull(data.email));
		}
	
		//interlocId
		String interlocId = (String)validateNull(data.interlocId, 'convertString');
		mapAccountFields.put('AV_NumPersoInterloc__c', interlocId);
		if(String.isNotBlank(String.valueOf(data.interlocId))){
			List<Account> listAcc= [Select Id, Name From Account Where AV_NumPerso__c = :String.valueOf(data.interlocId) limit 1];
			//List<Account> listAcc = new AV_Query('Account').selectFields('Name').addConditionEq('AV_NumPerso__c', String.valueOf(data.interlocId)).setLimit(1).run();
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
			List<Contact> listEmployee= [Select Id From Contact Where CC_Matricula__c = :data.employeeId limit 1];
			//List<Contact> listEmployee = new AV_Query('Contact').selectFields('Id').addConditionEq('CC_Matricula__c', data.employeeId).setLimit(1).run();
			if(!listEmployee.isEmpty()){
				mapAccountFields.put('AV_EAPGestor__c', listEmployee[0].Id);
			} else {
				mapAccountFields.put('AV_EAPGestor__c', null);
			}
		}
		//principaBranch -> CC_Numero_Oficina_Empresa__c de Account
		if(data.principalBranch != null){
			String branchNum = BRANCH_PREFIX + AV_IntegrationUtilities.leftPadZero(String.valueOf(data.principalBranch), 5);
			//AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> branchNum: ' + branchNum);
			List<Account> listPrincipalBranch= [Select Id From Account Where CC_Numero_Oficina_Empresa__c = :branchNum limit 1];
			//List<Account> listPrincipalBranch = new AV_Query('Account').selectFields('Id').addConditionEq('CC_Numero_Oficina_Empresa__c', branchNum).setLimit(1).run();
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
		CIBE_UpdateCliPremium_Controller.DataKeyValue mapSegmentValue = (CIBE_UpdateCliPremium_Controller.DataKeyValue)validateNull(data.segment);
		if(mapSegmentValue != null && data.segment != null) {
			String segmentValue = data.segment!= null ? data.segment.value : null;
			mapAccountFields.put('AV_Segmento__c', segmentValue);
            //AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> segment: ' + segmentValue);
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
            //AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> scoring: ' + data.scoring.value);
            //AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> scoring: ' + data.scoring.status.key);
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
		CIBE_UpdateCliPremium_Controller.DataKeyValue mapAttentionModel = (CIBE_UpdateCliPremium_Controller.DataKeyValue)validateNull(data.attentionModel);
		if(mapAttentionModel != null && data.attentionModel != null) {
			String attentionModel = data.attentionModel!= null ? data.attentionModel.key : null;
			mapAccountFields.put('AV_AttentionModel__c', attentionModel);
            //AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> attentionModel: ' + attentionModel);
		} else {
			mapAccountFields.put('AV_AttentionModel__c', null);
		}
		//attentionLevel
		CIBE_UpdateCliPremium_Controller.DataKeyValue mapAttentionLevel = (CIBE_UpdateCliPremium_Controller.DataKeyValue)validateNull(data.attentionModel);
		if(mapAttentionLevel != null && data.attentionModel != null) {
			String attentionLevel = data.attentionModel!= null && (data.attentionModel.key.equalsIgnoreCase('1') || data.attentionModel.key.equalsIgnoreCase('2') || data.attentionModel.key.equalsIgnoreCase('3')) ? data.attentionModel.key : null;
			mapAccountFields.put('AV_AttentionLevel__c', attentionLevel);
            //AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> attentionLevel: ' + attentionLevel);
		} else {
			mapAccountFields.put('AV_AttentionLevel__c', null);
		}
		//contactPerson
		mapAccountFields.put('AV_ContactPerson__c', (String)validateNull(data.contactPerson));
		//contactNumber
		Integer contactNumber = (Integer)validateNull(data.contactNumber);
		mapAccountFields.put('AV_ContactNumber__c', contactNumber);
		//realContactNumber
		Integer realContactNumber = (Integer)validateNull(data.realContactNumber);
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
                //AV_LogDebug.printLogDebug('getMapAccountFields', 'Data -> customerBussines: ' + customerBussines);
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
                    //AV_LogDebug.printLogDebug('getMapAccountFields', 'type value: ' + data.balance[i].type);
                    //AV_LogDebug.printLogDebug('getMapAccountFields', 'key: ' + data.balance[i].type.get('key'));
                    //AV_LogDebug.printLogDebug('getMapAccountFields', 'amount: ' + data.balance[i].amount);
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
					else if(data.balance[i].type.get('key').equalsIgnoreCase('X')){
						// LEX Aprobado Extended
                        mapAccountFields.put('CIBE_LEXAprobado__c', data.balance[i].amount);
						mapBalanceKeys.remove('X');
					}
                    else if(data.balance[i].type.get('key').equalsIgnoreCase('P')){
						//mapAccountFields.put('AV_Preconcedidos__c', data.balance[i].amount.setScale(2).format().contains(',') ? (data.balance[i].amount.setScale(2).format() + ' €') : (data.balance[i].amount.setScale(2).format() + ',00 €'));
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
		CIBE_UpdateCliPremium_Controller.DataKeyValue mapPreferedChannel = (CIBE_UpdateCliPremium_Controller.DataKeyValue)validateNull(data.preferedChanel);
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
				List<AV_Collective__c> listCollectives = [SELECT AV_ExternalID__c,AV_Description__c FROM AV_Collective__c WHERE AV_ExternalID__c = :listStringColectives];
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
		List<AV_ProductClient__c> listProductoCliente = [SELECT AV_ImportePreconcedido__c FROM AV_ProductClient__c WHERE AV_Cliente__r.AV_NumPerso__c = :customerInternalId AND AV_ImportePreconcedido__c != null AND AV_ImportePreconcedido__c != 0 ORDER BY AV_ImportePreconcedido__c DESC LIMIT 1];		if (listProductoCliente!=null && !listProductoCliente.isEmpty()) {
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
		//MyBox
		mapAccountFields.put('AV_MyBox__c', data.myBox);
		//Target Auto
		mapAccountFields.put('AV_TargetAuto__c', data.targetAuto);

		//Fecha Lex  Extended
		
		/*if(data.lEXDate!='0.0'){
		/	String lexDateString = (String)validateNull(data.lEXDate);
			DAte lexDate = Date.valueOf(lexDateString);
			mapAccountFields.put('CIBE_LEXFechaFinVigencia__c', lexDate);
		//}*/
		//si la fecha no tiene un formato reconocido('YYYY-MM-DD') el casteo fallará pero solo afectará al campo
		try {
			DAte lexDate = Date.valueOf(data.lEXDate);
			mapAccountFields.put('CIBE_LEXFechaFinVigencia__c', lexDate);
		} catch (Exception e) {
			CBK_Log.error(e, 'NumPerso: ' + customerInternalId + ' ' + e.getMessage() + ' ' + e.getCause() );
		}
				
		
		//RAR Grupo  Extended
		String pctRar = (String)validateNull(data.pctRar);
		mapAccountFields.put('CIBE_RAR_Grupo__c', pctRar);

		//Rentabilidad Grupo Extended
		Integer groupProfitabilityPct = (Integer)validateNull(data.Extended.groupProfitabilityPct);
		mapAccountFields.put('CIBE_Rentabilidad__c', groupProfitabilityPct);
		
		
		AV_LogDebug.printLogDebug('getMapAccountFields', 'mapAccountFields: ' + mapAccountFields);
		return mapAccountFields	;
	}


	private static String updateAccount(CustomerData data) {
		// Retrieve the Account record that you want to update
		String customerInternalId = (String)validateNull(data.customerInternalId, 'convertString');

		Account account = [SELECT Id,IsPersonAccount FROM Account WHERE AV_NumPerso__c = :customerInternalId LIMIT 1];
	  
		// Modify the fields of the Account record using the map of field names and values
		Map<String, Object> mapAccountFields = getMapAccountFields(data,account.IsPersonAccount);
		for (String fieldName : mapAccountFields.keySet()) { 
			if(mapAccountFields.get(fieldName) != null){
				System.debug('fieldName: ' + fieldName);
				account.put(fieldName, mapAccountFields.get(fieldName));
			}
		
		}
	  
		// Save the changes to the Account record in the database
		Database.UpsertResult srList = Database.upsert(account, false);
		if (srList.isSuccess()) {
			// Operation was successful, so get the ID of the record that was processed
			System.debug('Successfully updated account. Account ID: ' + srList.getId());
			return null;
		}
		else {
			String errors = '';
			// Operation failed, so get all errors                
			for(Database.Error err : srList.getErrors()) {
				System.debug('The following error has occurred.');                    
				System.debug(err.getStatusCode() + ': ' + err.getMessage());
				System.debug('Account fields that affected this error: ' + err.getFields());
				errors = errors + err.getStatusCode() + ': ' + err.getMessage() + ' Account fields that affected this error: ' + err.getFields();
			}
			return errors;
		}
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

}