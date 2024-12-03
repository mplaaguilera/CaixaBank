/**********************************************************************************************************************
Name:	  AV_FichaCliente_Integration
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con CLI para la ficha de cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY							    AUTHOR			  	DATE			Description
1.0			SF - Integración con API's de CLI		Esperanza Conde	  	27/07/2020		Init version
1.1			SF - Integración con API's de CLI		David Rufo		  	10/09/2020		Update content
1.2			SF - Integración con API's de CLI		Carolina Alonso	  	14/09/2020		Update content
1.3			SF - Integración con API's de CLI		Esperanza Conde	  	28/09/2020		Update content
1.4			SF - Integración con API's de CLI		Esperanza Conde	  	16/10/2020		try cacth para el mapa del producto
1.5			SF - Integración con API's de CLI		Álvaro López		19/10/2020		Changes in CustomerData
1.6			SF - Integración con API's de CLI		Álvaro López		05/11/2020		Experience myBox changes
1.7			SF - Integración con API's de CLI		Eric Vázquez		05/11/2020		Add conditional for call API Products
1.8			SF - Integración con API's de CLI		Álvaro López		06/11/2020		Fix null object in CustomerData
1.9			SF - Integración con API's de CLI		Sandra Gómez		14/07/2021		New Version AV_FichaCliente and AV_FichaCliente_Alertas
2.0			SF - Integración con API's de CLI		Sandra Gómez		16/08/2021		New Version AV_FichaCliente_MapaProductos, AV_FichaCliente and AV_FichaCliente_Alertas
2.1		    AV_Query IT	       						Daniel Rodríguez    07/03/2022	    Change AV_Query to SOQL for User, Account, Contact
2.2			Fix Aplication							Sandra	Gómez		06/02/2023		else app AV_CRM_Intouch


***********************************************************************************************************************/
public with sharing class AV_FichaCliente_Integration {

	private static final String AV_APP		= 'AV_CRM_Intouch';
	private static final String CIBE_APPCIB	= 'CIBE_MisClientesCIB';
	private static final String CIBE_APPEMP	= 'CIBE_MisClientesEMP';
	
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
	public static final Map<String, List<Products>> MAPEXPERIENCELISTPRODUCT = new Map<String, List<Products>>();
	public static final Map<String, Boolean> MAPEXPERIENCEMYBOX = new Map<String, Boolean>();
	
	public class ProductsResponse {
		public String statusCode;
		public String errorMessage;
		public String errorCode;
	} 

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
		public String birthDate;
		@AuraEnabled
		public String constitutionDate;
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
        public Double cirbeFee;
        @AuraEnabled
        public String qualification;
        @AuraEnabled
        public Double pctRar;
        @AuraEnabled
        public Double addedValue;
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
	}

	public class Balance {
		@AuraEnabled
		public Map<String, String> type;
		@AuraEnabled
		public Decimal amount;	
	}

	public class LoyaltyLink {
		@AuraEnabled
		public Boolean isCompilance;
		@AuraEnabled
		public Integer indicators;
		@AuraEnabled
		public Integer financialIndicator;
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
        public Double value;
    }
    
    public class Scoring {
        @AuraEnabled
		public DataKeyValue status;
        @AuraEnabled
        public Double value;
	}

	public class SignalsResponse {
		public String statusCode;
		public String errorMessage;
		public String errorCode;
	} 


	public class CommercialProductsResponse {
		@AuraEnabled
		public String statusCode;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
		@AuraEnabled
		public List<CustomerBusiness> listData;
	}

	public class CustomerBusinessData {
		@AuraEnabled
		public List<CustomerBusiness> customerBusiness;
	}

	public class CustomerBusiness {
		@AuraEnabled
		public DataKeyValue business;
		@AuraEnabled
		public List<Experiences> experiences;
	}

	public class Experiences {
		@AuraEnabled
		public DataKeyValue experience;
		@AuraEnabled
		public Integer globalExperience;
		@AuraEnabled
		public Integer order; 
		@AuraEnabled
		public boolean isMyBox;
		@AuraEnabled
		public List<Products> products;
	}

	public class Products {
		@AuraEnabled
		public DataKeyValue productCode;
		@AuraEnabled
		public DataKeyValue state;
		@AuraEnabled
		public Integer order; 
		@AuraEnabled
		public boolean isProfessional;
		@AuraEnabled
		public Integer preconceived; 
		@AuraEnabled
		public boolean isTarget;
		@AuraEnabled
		public boolean isPotential;
		@AuraEnabled
		public DataKeyValue oportunity;
	}


	public class CommercialProductsDataResponse{
		@AuraEnabled
		public CommercialProductsIdResponse data;
		@AuraEnabled
		public List<Contract> contractsToShow;
		@AuraEnabled
		public Integer numberOfContractsNotShown;
		@AuraEnabled
		public Integer totalNumberOfContracts;
		@AuraEnabled
		public String totalBalance;
	}

	public class CommercialProductsIdResponse {
		@AuraEnabled
		public String statusCode;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
		@AuraEnabled
		public CommercialProductsIdData data;
	}

	public class CommercialProductsIdData {
		@AuraEnabled
		public String description;
		@AuraEnabled
		public Map<String, String> state;
		@AuraEnabled
		public List<DataKeyValue> stateParse;
		@AuraEnabled
		public Integer preconceived;
		@AuraEnabled
		public Boolean isTarget;
		@AuraEnabled
		public Map<String, String> oportunity;
		@AuraEnabled
		public List<DataKeyValue> oportunityParse;
		@AuraEnabled
		public String cancelDate;
		@AuraEnabled
		public String revDate;
		@AuraEnabled
		public String rejectionDate;
		@AuraEnabled
		public String openingDate;
		@AuraEnabled
		public String modDate;
		@AuraEnabled
		public Boolean isPotential;
		@AuraEnabled
		public Boolean hasOtherEnt;
		@AuraEnabled
		public String otherEntDesc;
		@AuraEnabled
		public String commentary;
		@AuraEnabled
		public List<Contract> contracts;
		@AuraEnabled
		public String totalBalance;
		@AuraEnabled
		public String ticket;

		public CommercialProductsIdData(){
			stateParse = new List<DataKeyValue>();
			oportunityParse = new List<DataKeyValue>();
		}
	}

	public class Contract implements Comparable {
		@AuraEnabled
		public Long id;
		@AuraEnabled
		public String description;
		@AuraEnabled
		public Double balance;
        
        public Integer compareTo(Object compareTo) {
			Contract compareToEmp = (Contract)compareTo;
			Double contractBalance = Double.valueOf(balance);
			Double compareToBalance = Double.valueOf(compareToEmp.balance);
			if (contractBalance == compareToBalance) {
				return 0;
			} 
			if (contractBalance > compareToBalance) {
				return -1;
			} 
			return 1;
		}
	}

	public class WarningsResponse {
		@AuraEnabled
		public String statusCode;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
		@AuraEnabled
		public WarningsData listWarnings;
	}

	public class WarningsData {
		@AuraEnabled
		public List<DataKeyValue> warnings;
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

	/**
	 * @description			 Recupera la información de producto de un cliente.
	 * @param userId		 -> Identificación de cliente header
	 * @param ownerType	  -> Tipo de titularidad que se quiere recuperar
	 * @param productType	-> Tipo de consulta
	 * @param ticket		 -> Identificador de consulta
	 * @param key			-> Pagina a la que se va acceder
	 * @param pageSize	   -> Numbero de registros por pagina
	 */
	public static ProductsResponse getProducts(String userId, String ownerType, String productType, String ticket, String key, String pageSize, String customerType){

		ProductsResponse resultMethod = new ProductsResponse();
		String methodName = 'getProducts';

		CC_InterfaceSettings__mdt dataInterface = null;
		if(AV_AppUtilities.getCurrentSFApplication() == CIBE_APPCIB || AV_AppUtilities.getCurrentSFApplication() == CIBE_APPEMP) {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(CIBE_FICHACLIENTE_PRODUCTOS);
		} else {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_FICHACLIENTE_PRODUCTOS);
		}

		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');

		Map<String, String> mapHeader = new Map<String, String>();
		Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put(PARAM_USERID_OLD,hexDigest);
		String endpoint = dataInterface.CC_EndPoint__c;
		if(ownerType != Null || productType != Null || ticket != Null || key != Null ||
				pageSize != Null || customerType != Null){
			endpoint = endpoint+'?';
			endpoint = endpointDynamic(endpoint, ownerType, productType, ticket, key, pageSize, customerType);
		}
		
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endpoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.addContentTypeJsonHeader()
			.setHeaders(mapHeader)
			.debugMode()
			.runCallout();
			
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		
		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		AV_LogDebug.printLogDebug(methodName, 'Request status: ' + +reqStatusOK);

		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();

		return resultMethod;
	}

	/**
	 * @description			 Recupera la información general de un cliente.
	 * @param userId		 -> Identificación de cliente
	 */
	public static CustomerResponse getDataCustomer(String userId){

		CustomerResponse resultMethod = new CustomerResponse();
		String methodName = 'getDataCustomer';

		CC_InterfaceSettings__mdt dataInterface = null;
		if(AV_AppUtilities.getCurrentSFApplication() == CIBE_APPCIB || AV_AppUtilities.getCurrentSFApplication() == CIBE_APPEMP) {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(CIBE_FICHACLIENTE);
		} else {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_FICHACLIENTE);
		}

		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');

		Map<String, String> mapHeader = new Map<String, String>();
		Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put(PARAM_CUSTOMERINTERNALID,hexDigest);

		//String mockString = '{"customerInternalId":13550,"customerName":"VICTOR","customerLastName":"SAULER  PORTALÑ","customerDocId":{"NIF":"59898909D"},"birthDate":"1979-6-5","language":"2","mobilePhone":646418238,"phone":948266127,"email":"saulerPortal@lacaixa.es","employeeId":"U01U0146524","employeeName":"OLGA ROBLES GEA                                     ","interlocId":16849239,"principaBranch":9712,"relatedBranch":[],"compilance":false},{"program":{"PSU":"Día a Día"},"compilance":true,"complianceValue":"100%"},{"program":{"PSU":"Día a Día"},"compilance":true,"complianceValue":"0%"}],"balance":[{"type":{"P":"LIABILITIES"},"amount":0.0},{"type":{"A":"ASSETS"},"amount":101.59},{"type":{"N":"PENSION INCOME"},"amount":5252.66},{"type":{"F":"PROFESSIONAL INCOME"},"amount":1111.0},{"type":{"L":"PERSONAL INCOME"},"amount":2703.16}],"wall":true,"loyaltyLink":[{"compilance":false,"indicators":3,"financialIndicator":0},{"compilance":true,"indicators":1,"financialIndicator":0},{"compilance":true,"indicators":1,"financialIndicator":0}],"segment":{"RPF":"Resta Perones Físiquies"},"isConfidential":false,"confidentialBranch":0,"customerType":{"F":"Físico"},"isEmployee":false,"loyaltySignals":[{"12":"Real State"},{"3":"Ent. social solidaria"}],"contactPerson":"","contactNumber":0,"realContactNumber":0,"cnaeCode":"0","postalCode":31007,"country":"11","contactTime":{"timePeriod":{"M":"Mañana"}},"colectives":[922,16232,19394,30565,30723],"isClient":false,"clientExperience":2}';

		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(dataInterface.CC_EndPoint__c) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.addContentTypeJsonHeader()
			.setHeaders(mapHeader)
			.debugMode()
			//.setDataMockup(mockString)
			.runCallout();

		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();

		AV_LogDebug.printLogDebug(methodName, 'Request status: ' + +reqStatusOK);

		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();

		if (reqStatusOK){
			CustomerData bodyResponse = (AV_FichaCliente_Integration.CustomerData)apiCallout.getBodyResponse('AV_FichaCliente_Integration.CustomerData');
			
			resultMethod.data = bodyResponse;
		}

		AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		return resultMethod;
	}

	/**
	 * @description			 Recupera la información del mapa de productos ficha de un cliente.
	 * @param userId		 -> Identificación de cliente
	*/ 
	public static SignalsResponse getSignals(String userId){

		SignalsResponse resultMethod = new SignalsResponse();
		String methodName = 'getSignals';

		CC_InterfaceSettings__mdt dataInterface = null;
		if(AV_AppUtilities.getCurrentSFApplication() == CIBE_APPCIB || AV_AppUtilities.getCurrentSFApplication() == CIBE_APPEMP) {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(CIBE_FICHACLIENTE_SENALES);
		} else {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_FICHACLIENTE_SENALES);
		}

		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		
		Map<String, String> mapHeader = new Map<String, String>();
		Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put(PARAM_USERID_OLD,hexDigest);
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(dataInterface.CC_EndPoint__c) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.addContentTypeJsonHeader()
			.setHeaders(mapHeader)
			.debugMode()
			.runCallout();
			
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		
		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		
		AV_LogDebug.printLogDebug(methodName, 'Request status: ' + +reqStatusOK);

		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();

		return resultMethod;
	}

	/**
	 * @description			 Recupera la información del mapa de productos ficha de un cliente.
	 * @param userId		 -> Identificación de cliente
	*/ 
	public static CommercialProductsResponse getCommercialProducts(String userId){

		CommercialProductsResponse resultMethod = new CommercialProductsResponse();
		String methodName = 'getCommercialProducts';
		try{
			CC_InterfaceSettings__mdt dataInterface = null;
			if(AV_AppUtilities.getCurrentSFApplication() == CIBE_APPCIB || AV_AppUtilities.getCurrentSFApplication() == CIBE_APPEMP) {
				dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(CIBE_FICHACLIENTE_MAPAPROD);
			} else {
				dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_FICHACLIENTE_MAPAPROD);
			}

			AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
			AV_LogDebug.printLogDebug(methodName, '*****************************************');
			
			Map<String, String> mapHeader = new Map<String, String>();
			Long longUser = long.valueOf(userId);
			String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
			mapHeader.put(PARAM_CUSTOMERINTERNALID,hexDigest);

			AV_ApiCallout apiCallout = new AV_ApiCallout()
				.setIsActive(dataInterface.CC_Activa__c)
				.setMethod(dataInterface.CC_TipoPeticion__c)
				.setEndpoint(dataInterface.CC_EndPoint__c) 
				.setCertificate(dataInterface.CC_Certificado__c)
				.addContentTypeJsonHeader()
				.setHeaders(mapHeader)
				.debugMode()
				//.setDataMockup('{"customerBusiness":[{"business":{"BPA":"Banca particulares"},"experiences":[{"experience":{"BPA001":"Dia a dia"},"globalExperience":1,"order":1,"isMyBox":false,"products":[{"productCode":{"50046":"Tarjeta crédito"},"state":{"2":"Tiene"},"order":1,"isProfesional":false,"preconceived":50,"isTarget":false,"isPotential":false},{"productCode":{"50077":"Caixabank Now"},"state":{"1":"No tiene"},"order":1,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50117":"ServiCuentas"},"state":{"1":"No tiene"},"order":1,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false}]},{"experience":{"BPA002":"Disfrutar de la vida"},"globalExperience":2,"order":2,"isMyBox":false,"products":[{"productCode":{"50030":"Hipoteca"},"state":{"1":"No tiene"},"order":2,"isProfesional":false,"preconceived":50,"isTarget":false,"isPotential":false},{"productCode":{"50047":"Tarjeta revolving"},"state":{"1":"No tiene"},"order":2,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false}]},{"experience":{"BPA003":"Pensar en el futuro"},"globalExperience":3,"order":3,"isMyBox":false,"products":[{"productCode":{"50003":"Libreta infantil"},"state":{"2":"Tiene"},"order":3,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50004":"Vista y plazo"},"state":{"2":"Tiene"},"order":3,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50008":"Seguros jubilación"},"state":{"1":"No tiene"},"order":3,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50010":"Planes de pensiones"},"state":{"1":"No tiene"},"order":3,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false}]},{"experience":{"BPA004":"Dormir tranquilo"},"globalExperience":4,"order":4,"isMyBox":false,"products":[{"productCode":{"50093":"Seguros de hogar"},"state":{"1":"No tiene"},"order":4,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50095":"Auto"},"state":{"1":"No tiene"},"order":4,"isProfesional":false,"preconceived":0,"isTarget":true,"isPotential":false},{"productCode":{"50106":"Salud"},"state":{"1":"No tiene"},"order":4,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50112":"Dental"},"state":{"1":"No tiene"},"order":4,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50102":"Vida"},"state":{"1":"No tiene"},"order":4,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50111":"Decesos"},"state":{"1":"No tiene"},"order":4,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"50123":"Sistemas seguridad"},"state":{"1":"No tiene"},"order":4,"isProfesional":false,"preconceived":0,"isTarget":false,"isPotential":false}]}]}]}')
				.runCallout();
				
			AV_LogDebug.printLogDebug(methodName, '*****************************************');
			AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
			
			//Check errors:
			boolean reqStatusOK = apiCallout.checkErrorStatusCode();
			resultMethod.statusCode = apiCallout.getStatusCodeResponse();
			resultMethod.errorMessage = apiCallout.getErrorResponse();
			resultMethod.errorCode = apiCallout.getStatusCodeResponse();

			if (reqStatusOK){
				CustomerBusinessData bodyResponse = (AV_FichaCliente_Integration.CustomerBusinessData)apiCallout.getBodyResponse('AV_FichaCliente_Integration.CustomerBusinessData');
				List<CustomerBusiness> customerBusinesslist = bodyResponse.customerBusiness;
				resultMethod.listData= customerBusinesslist;
				CustomerBusiness customerBusiness = customerBusinesslist.get(0);
				List<Experiences> experienceslist =  customerBusiness.experiences;
				for(Experiences experiencia : experienceslist){
					List<Products> productsList = experiencia.products;
					MAPEXPERIENCELISTPRODUCT.put(experiencia.experience.key, productsList);
					MAPEXPERIENCEMYBOX.put(experiencia.experience.key.remove('{').remove('}'), experiencia.isMyBox);
				}
			}

			AV_LogDebug.printLogDebug(methodName, 'Mapa productos por experiencia: ' + MAPEXPERIENCELISTPRODUCT);
			AV_LogDebug.printLogDebug(methodName, 'Mapa mybox por experiencia: ' + MAPEXPERIENCEMYBOX);
			AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		}catch(Exception e){
			AV_LogDebug.printException(methodName, e);
			resultMethod.errorMessage = e.getMessage();
		}
		return resultMethod;
	}

	/**
	 * @description			 Recupera la información del mapa de productos ficha de un cliente.
	 * @param userId		 -> Identificación de cliente
	*/ 
	public static WarningsResponse getWarnings(String userId){

		WarningsResponse resultMethod = new WarningsResponse();
		String methodName = 'getWarnings';

		CC_InterfaceSettings__mdt dataInterface = null;
		if(AV_AppUtilities.getCurrentSFApplication() == CIBE_APPCIB || AV_AppUtilities.getCurrentSFApplication() == CIBE_APPEMP) {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(CIBE_FICHACLIENTE_ALERTAS);
		} else {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_FICHACLIENTE_ALERTAS);
		}

		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		
		Map<String, String> mapHeader = new Map<String, String>();
		Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put(PARAM_CUSTOMERINTERNALID,hexDigest);

		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(dataInterface.CC_EndPoint__c) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.addContentTypeJsonHeader()
			.setHeaders(mapHeader)
			.debugMode()
			//.setDataMockup('{"Warnings":[{"17":"Contrato marco"},{"25":"Cliente con reclamaciones históricas"},{"11":"Información de seguimiento"},{"4":"Cobros pendientes"},{"10":"Cliente con alertas de seguimiento"}]}')
			.runCallout();
			
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		
		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();

		if (reqStatusOK){
			WarningsData bodyResponse = (AV_FichaCliente_Integration.WarningsData)apiCallout.getBodyResponse('AV_FichaCliente_Integration.WarningsData');
			resultMethod.listWarnings = bodyResponse;
		}

		AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		return resultMethod;
	}

	/**
	 * @description			 Get the detail of the product
	 * @param userId		 -> Numper
	 * @param commercialProductId		 -> ExternalID of the product (PF)
	 */
	@AuraEnabled
	public static CommercialProductsIdResponse getCommercialProductById(String userId, String commercialProductId){

		CommercialProductsIdResponse resultMethod = new CommercialProductsIdResponse();
		String methodName = 'getCommercialProductById';

		CC_InterfaceSettings__mdt dataInterface = null;
		if(AV_AppUtilities.getCurrentSFApplication() == CIBE_APPCIB || AV_AppUtilities.getCurrentSFApplication() == CIBE_APPEMP) {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(CIBE_FICHACLIENTE_DETALLEPF);
		} else {
			dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_FICHACLIENTE_DETALLEPF);
		}

		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');

		Map<String, String> mapHeader = new Map<String, String>();
		Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put(PARAM_USERID_OLD,hexDigest);
		AV_LogDebug.printLogDebug(methodName, 'Headers: ' + mapHeader);
        
		String endpoint = dataInterface.CC_EndPoint__c.replace('{commercialProductId}', commercialProductId);

		AV_ApiCallout apiCallout = new AV_ApiCallout()
				.setIsActive(dataInterface.CC_Activa__c)
				.setMethod(dataInterface.CC_TipoPeticion__c)
				.setEndpoint(endpoint)
				.setCertificate(dataInterface.CC_Certificado__c)
				.addContentTypeJsonHeader()
				.setHeaders(mapHeader)
				.debugMode()
				//.setDataMockup('{"description": "Tesorería - Pasivo","state": {"1": "No tiene"},"preconceived": 0,"isTarget": false,"oportunity": {},"revDate" : "2020-10-12","modDate" : "2020-05-03","hasOtherEnt" : true,"otherEntDesc" : "Tiene su Nómina en el BBVA","commentary" : "Esta pensando en moverla","contracts":[{"id" : 96203031461433434,"description" : "Nomina","balance" : 1300.00},{"id" : 96203031461433435,"description" : "Nomina","balance" : 500.50},{"id" : 96203031461433436, "description" : "Nomina","balance" : 1300.27},{"id" : 96203031461433437, "description" : "Nomina","balance" : 320.00},{"id" : 96203031461433438, "description" : "Nomina","balance" : 325.00}],"totalBalance" : "1000.00","ticket" : "N0000000000000001355000114"}')
				.runCallout();

		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();

		if (reqStatusOK){
			CommercialProductsIdData bodyResponse = (AV_FichaCliente_Integration.CommercialProductsIdData)apiCallout.getBodyResponse('AV_FichaCliente_Integration.CommercialProductsIdData');
			List<DataKeyValue> listDataKeyValues = getListKeyValue(apiCallout.getBodyResponse(), 'state');
			if (!listDataKeyValues.isEmpty()) {
				bodyResponse.stateParse = new List<DataKeyValue>();
				bodyResponse.stateParse.addAll(listDataKeyValues);
			}
			List<DataKeyValue> listDataKeyValues2 = getListKeyValue(apiCallout.getBodyResponse(), 'oportunity');
			if (!listDataKeyValues2.isEmpty()) {
				bodyResponse.oportunityParse = new List<DataKeyValue>();
				bodyResponse.oportunityParse.addAll(listDataKeyValues2);
			}
			resultMethod.data = bodyResponse;
		}

		AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		return resultMethod;
	}

	private static String endpointDynamic(String endpoint, String ownerType, String productType, String ticket, String key, String pageSize, String customerType){
		List<String> urlCondList = new List<String>{'customerType', 'ownerType', 'productType', 'ticket', 'key', 'pageSize'};
		Map<String, String> mapUrlCondList = new Map<String,String>();
		if(customerType != Null){
			mapUrlCondList.put('customerType',customerType);
		}
		if(ownerType != Null){
			mapUrlCondList.put('ownerType',ownerType);
		}
		if(productType != Null){
			mapUrlCondList.put('productType',productType);
		}
		if(ticket != Null){
			mapUrlCondList.put('ticket', ticket);
		}
		if(key != Null){
			mapUrlCondList.put('key', key);
		}
		if(pageSize != Null){
			mapUrlCondList.put('pageSize', pageSize);
		}
		for(Integer i = 0; i < urlCondList.size(); i++){
			if(mapUrlCondList.get(urlCondList.get(i)) != Null){
				endpoint = endpoint +urlCondList.get(i)+'='+mapUrlCondList.get(urlCondList.get(i))+'&';
			}
		}
		if(endpoint.endsWith('&')){
			endpoint = endpoint.removeEnd('&'); 
		}

		return endpoint;
	}

	private static List<DataKeyValue> getMapKeyValue(String content, String mainKey){
		String methodName = 'getMapKeyValue';
		List<DataKeyValue> listDataKeyValues = new List<DataKeyValue>();

		Map<String, Object> contentResponse = (Map<String, Object>)JSON.deserializeUntyped(content);
		AV_LogDebug.printLogDebug(methodName, 'contentResponse: ' + contentResponse);
		if(contentResponse.containsKey(mainKey)){
			List<Object> listObject = (List<Object>)contentResponse.get(mainKey);
			AV_LogDebug.printLogDebug(methodName, 'listObject: ' + listObject);
			for (Object obj : listObject){
				AV_LogDebug.printLogDebug(methodName, 'obj: ' + obj);
				Map<String, Object> contentObj = (Map<String, Object>)obj;
				String key = null;
				Object value = null;
				AV_LogDebug.printLogDebug(methodName, 'contentObj: ' + contentObj);
				for (String auxKey : contentObj.keySet()){
					key = auxKey;
					value = contentObj.get(key);
					break;
				}
				DataKeyValue dataKV = new DataKeyValue(key, value.toString());
				listDataKeyValues.add(dataKV);
			}
		}

		return listDataKeyValues;
	}

	private static List<DataKeyValue> getListKeyValue(String content, String mainKey){
		//String methodName = 'getListKeyValue';
		List<DataKeyValue> listDataKeyValues = new List<DataKeyValue>();

		Map<String, Object> contentResponse = (Map<String, Object>)JSON.deserializeUntyped(content);
		for (String auxKey : contentResponse.keySet()){
			if (mainKey.equalsIgnoreCase(auxKey)) {
				Map<String, Object> contentObj = (Map<String, Object>)contentResponse.get(auxKey);
				DataKeyValue dataKV = null;
				for (String auxKey2 : contentObj.keySet()){
					Object value = contentObj.get(auxKey2);
					if(value != null) {
						dataKV = new DataKeyValue(auxKey2, value.toString());
					}
					else {
						dataKV = new DataKeyValue(auxKey2, '');
					}					
					break;
				}
				listDataKeyValues.add(dataKV);
				break;
			}
		}
		return listDataKeyValues;
	}

	/**
	 * @description			 Get the detail of the product
	 * @param recordId		 -> ProductClient ID
	 */
	@AuraEnabled
	public static CommercialProductsDataResponse getCommercialProductResponse(String recordId){
		AV_ProductClient__c pfCliente  = [Select Id, AV_Cliente__r.AV_NumPerso__c, AV_ProductoFicha__r.AV_ProductoFicha__r.AV_ExternalID__c, AV_TenenciaProducto__c From AV_ProductClient__c where Id = :recordId limit 1]; 
		/*AV_ProductClient__c pfCliente = (AV_ProductClient__c) new AV_Query('AV_ProductClient__c')
											.selectFields('Id, AV_Cliente__r.AV_NumPerso__c, AV_ProductoFicha__r.AV_ProductoFicha__r.AV_ExternalID__c, AV_TenenciaProducto__c')
											.addConditionEq('Id', recordId)
											.fetch();*/

		CommercialProductsDataResponse resultMethod = new CommercialProductsDataResponse();

		if(pfCliente.AV_TenenciaProducto__c.contains('2')){
			resultMethod.data = getCommercialProductById(pfCliente.AV_Cliente__r.AV_NumPerso__c,pfCliente.AV_ProductoFicha__r.AV_ProductoFicha__r.AV_ExternalID__c);
			List<Contract> contractList = new List<Contract>();
			
			if(resultMethod.data.data != null ){
				List<Contract> contractListSorted = resultMethod.data.data.contracts;
				String totalBalance;
				Decimal totalBalanceDouble = 0;
				Integer count = 0;
				if(contractListSorted != null && !contractListSorted.isEmpty()){
					//SORT LIST BY BALANCE DESC
					contractListSorted.sort();
					//GET THE FIRST 4 CONTRACTS WHIT MORE IMPORT					
					for(Contract listaContratos : contractListSorted){
						if(count < 4){					
							contractList.add(listaContratos);
							count++;
						}
						//Add balance to total
						totalBalanceDouble += Decimal.valueOf(listaContratos.balance);
						//Format Balance
						//Decimal doubleContractBalance = Decimal.valueOf(listaContratos.contract.balance);
						Decimal contractBalance = Decimal.valueOf(listaContratos.balance);
						String strContractBalance = null;
						if (contractBalance!=null){
							strContractBalance = String.valueOf(contractBalance).replace('.',',');
							strContractBalance = contractBalance.setScale(2).format();
							if(!strContractBalance.contains(',')){
								//listaContratos.contract.balance = strContractBalance + ',00 €';
								strContractBalance = strContractBalance + ',00 €';
							} else{
								strContractBalance = strContractBalance  + ' €';
							}
						}
					}
					//CHECK HOW MANY MORE CONTRACT THERE ARE
					resultMethod.numberOfContractsNotShown = contractListSorted.size()-count;
					//SET TOTAL NUMBER OF CONTRACTS
					resultMethod.totalNumberOfContracts = contractListSorted.size();
					
					totalBalance = totalBalanceDouble.setScale(2).format();
					if(!totalBalance.contains(',')){
						totalBalance = totalBalance + ',00 €';
					} else{
						totalBalance = totalBalance + ' €';
					}
					//SET TOTAL BALANCE OF CONTRACTS
					resultMethod.totalBalance = totalBalance;
	
				}
				if(contractList != null && !contractList.isEmpty()){
					resultMethod.contractsToShow = contractList;
				}
			}
		}
		
				
		return resultMethod;
	} 

}