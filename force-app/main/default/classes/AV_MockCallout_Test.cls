/**********************************************************************************************************************
Name:	  AV_MockCallout_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de integraciones
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0			Test Class	   Esperanza Conde	   	30/07/2020		Init version
    1.1			Test Class	   Álvaro López		   	29/09/2020		Update content
    1.2			Test Class	   Esperanza Conde		30/09/2020		Update content
    1.3			Test Class	   Esperanza Conde		02/10/2020		Update content
    1.4			Test Class	   Eric Vazquez			14/10/2020		Update content
    1.5			Test Class	   Jashanpreet			21/10/2020		Update content
    1.6			Test Class	   Álvaro Lopez			06/11/2020		Change in RESPONSE_CLI_CUSTOMMERPRODDATA
    1.7			Test Class	   Víctor Santiago		05/02/2021		Added GCF_CAMBIOEMPLEADO
    1.8			Test Class	   Jashanpreet			05/02/2021		Added CJ
    1.9			Test Class	   Sandra Gómez			08/03/2021		Change in RESPONSE_CLI_CUSTOMMERDATA2
    2.0			Test Class	   Jashanpreet			23/03/2021		Added Delete event
	2.1			Test Class	   Víctor Santiago		29/04/2021		Added GCF_JOBLEVEL
	2.2			Test Class	   Sandra Gómez			16/08/2021		Change RESPONSE_CLI_WARNINGDATA, RESPONSE_CLI_CUSTOMMERPRODDATA,
																	RESPONSE_CLI_CUSTOMMERDATA and RESPONSE_CLI_CUSTOMMERDATA2
	2.3			Test Class	   Sandra Gómez			18/08/2021		Change RESPONSE_GDPR, RESPONSE_OTHER_GDPR_NEW and RESPONSE_OTHER_GDPR
	2.4			US268687	   Maria Martinez		27/09/2021		Add HGMSURVEYID, HGMCUSTOMER
	2.5			US284842	   Víctor Santiago		22/06/2022		Added RESPONSE_SURVEY_FC
	2.6			US414208	   Patricia Solano		20/09/2022		Added RESPONSE_TRACEABILITY
	2.7         US477490       Elisabeth Rodríguez  20/01/2023      Changed RESPONSE_CHANNELS and quality cloud changes
***********************************************************************************************************************/
@isTest
global class AV_MockCallout_Test implements HttpCalloutMock {
	
    /**
	 * Option 1: normal execution
	 * Option 2: exception in execution
	 * Option 3: return error message in body response
	*/
	private String option;
	private String status;
	
	/**
	  * MockCalloutESB   Mock for testing class ESB Abstract integration
	  * @param  option   Option 1: normal execution
	  *				  Option 2: exception in execution
	*/
	public AV_MockCallout_Test(String option, String status) {
		this.option = option;
		this.status = status;
	}

	public static final String RESPONSE_CHANNELS = '{"Metrics":[{"metricName":"webAccessLogins","metricValue":"999","metricTime":"6M+M","metricDescription":"Number of logins to now web in the last. 6m + current month"},{"metricName":"appNowLogins","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of logins to app now in the last. 6m + current month"},{"metricName":"cxbPayLogins","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of logins to CXB Pay in the last. 6m + current month"},{"metricName":"signLogins","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of logins to CXB Sign in the last. 6m + current month"},{"metricName":"officeAccessNumberDays","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of days with presence in office in the last. 6m + current month"},{"metricName":"videoConferenceNumberDays","metricValue":"4","metricTime":"12M+M","metricDescription":"Number of days with videoconference in the last. 6m + current month"},{"metricName":"wallMessagesFromClient","metricValue":"6","metricTime":"6M+M","metricDescription":"Number of Wall messages from the client in the last. 6m + current month"},{"metricName":"totalR2BMessages","metricValue":"3","metricTime":"12M+M","metricDescription":"Number of R2B messages received in the last. month + current month"},{"metricName":"appointmentNumberDays","metricValue":"0","metricTime":"12M+M","metricDescription":"Number of days with prior appointment use in the last. 6m + current month"},{"metricName":"visitorTag","metricValue":"3. SIN_CONTACTOS","metricTime":"6M","metricDescription":"Visits according to type of clients, physical, omnichannel or digital."},{"metricName":"nowUseIndicator","metricValue":"0","metricTime":"6M+M","metricDescription":"Indicate if uses digital channels in 6 months + current month (now web, mobile, apps, imagin, sign, etc ...)"},{"metricName":"webNumberDays","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of days with login to now web in the last. 6m + current month"},{"metricName":"webLastVisit","metricValue":"20190112","metricTime":"6M+M","metricDescription":"Last visit in the last 6m + current month"},{"metricName":"nowNumberDays","metricValue":"4","metricTime":"6M+M","metricDescription":"Number of days with login from the NOW app"},{"metricName":"nowLastVisit","metricValue":"20200324","metricTime":"6M+M","metricDescription":"Last visit in app now in the last 6m + current month"},{"metricName":"cxbPayUseIndicator","metricValue":"0","metricTime":"6M+M","metricDescription":"Cxbpay usage indicator"},{"metricName":"cxbPayNumberDays","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of days with login to CXB Pay in the last. 6m + current month"},{"metricName":"signUseIndicator","metricValue":"0","metricTime":"6M+M","metricDescription":"Sign usage indicator"},{"metricName":"signNumberDays","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of days with login to CXB Sign in the last. 6m + current month"},{"metricName":"nowAndroidLogins","metricValue":"3","metricTime":"6M+M","metricDescription":"Number of logins from Android device"},{"metricName":"nowAndroidNumberDays","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of days with login to app now in the last. 6m + current month"},{"metricName":"nowIosLogins","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of logins from iOS device"},{"metricName":"nowIosNumberDays","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of days with login from iOS device"},{"metricName":"nowOtherSOLogins","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of logins from another OS"},{"metricName":"nowOtherSOLastVisit","metricValue":"2","metricTime":"6M+M","metricDescription":"Last visit in the last 6m + current month"},{"metricName":"imaginbankLogins","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of logins to Imagin app in the last. 6m + current month"},{"metricName":"imaginbankNumberDays","metricValue":"8","metricTime":"6M+M","metricDescription":"Number of days with login to Imagin app in the last. 6m + current month"},{"metricName":"imaginbankLastVisit","metricValue":"20200816","metricTime":"6M+M","metricDescription":"Last visit in the last 6m + current month"},{"metricName":"imaginbankAndroidLogins","metricValue":"2","metricTime":"6M+M","metricDescription":"Number of logins from Android device"},{"metricName":"imaginbankAndroidNumberDays","metricValue":"6","metricTime":"6M+M","metricDescription":"Number of days with login from Android device"},{"metricName":"imaginbankIosLogins","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of logins from iOS device"},{"metricName":"imaginbankIosNumberDays","metricValue":"2","metricTime":"6M+M","metricDescription":"Number of days with login from iOS device"},{"metricName":"imaginbankOtherSOLogins","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of logins from another OS"},{"metricName":"imaginbankOtherSONumberDays","metricValue":"2","metricTime":"6M+M","metricDescription":"Number of days with login from another OS"},{"metricName":"lastOfficeVisit","metricValue":"20201002","metricTime":"6M+M","metricDescription":"Last visit in office presence"},{"metricName":"atmUse","metricValue":"3","metricTime":"6M+M","metricDescription":"Use of ATM in the last. 6m + current month"},{"metricName":"atmNumberDays","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of days with ATM use in the last 6 months + current month"},{"metricName":"atmLastVisit","metricValue":"20201217","metricTime":"6M+M","metricDescription":"Last ATM visit"},{"metricName":"wallMessagesFromManager","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of Wall messages from the manager in the last. 6m + current month"},{"metricName":"wallMessagesFromClientNumberDays","metricValue":"0","metricTime":"6M+M","metricDescription":"Number of days with Wall messages from the client in the last. 6m + current month"},{"metricName":"signedR2B","metricValue":"0","metricTime":"12M+M","metricDescription":"R2B signed last 12 months + more in progress"},{"metricName":"lastAppointment","metricValue":"20201128","metricTime":"12M+M","metricDescription":"Last appointment in the last 12m + current month"},{"metricName":"lastVideoConference","metricValue":"20201217","metricTime":"12M+M","metricDescription":"Last video call"},{"metricName":"mobileCardOperations","metricValue":"0","metricTime":"1M+M","metricDescription":"Rolled card previous month + current month"},{"metricName":"mobileOperations","metricValue":"0","metricTime":"6M+M","metricDescription":"Operations (purchases) with mobile wallets in 6m + current month"},{"metricName":"nowRegistryIndicator","metricValue":"0","metricTime":"6M+M","metricDescription":"Indicator = 1 if at the end of the previous year you do not use now (last 6m) and now you use now (last 6m + current month)"},{"metricName":"signRegistryIndicator","metricValue":"0","metricTime":"6M+M","metricDescription":"Indicator = 1 if at the end of the previous year it did not use sign (last 6m) and now it uses sign (last 6m + current month)"},{"metricName":"transferIndicator","metricValue":"1","metricTime":"6M+M","metricDescription":"Indicator = 1 if it operates. Make TRFs or pay receipts or taxes (last 6m + current month)"},{"metricName":"nowSalesIndicator","metricValue":"0","metricTime":"6M+M","metricDescription":"Indicator = 1 if you hire. Has signed a contract or new contribution to a savings product (last 6m + month in progress)"},{"metricName":"wallIndicator","metricValue":"-1","metricTime":"","metricDescription":"Indicator Not Active / Active"},{"metricName":"wallNowIndicator","metricValue":"-1","metricTime":"","metricDescription":"Sin Now indicator. He does not have a Now contract and therefore cannot have a wall"},{"metricName":"signIndicator","metricValue":"-1","metricTime":"","metricDescription":"Has / Has Not Indicator"},{"metricName":"cxbPayIndicator","metricValue":"-1","metricTime":"","metricDescription":"Has / Has Not Indicator"},{"metricName":"writeOnWallIndicator","metricValue":"-1","metricTime":"","metricDescription":"Indicator writes. Have you ever written in the last 12 months"},{"metricName":"readOnWallIndicator","metricValue":"-1","metricTime":"","metricDescription":"Indicator only reads. Has the wall but has never written in the last 12 months"},{"metricName":"biometricsIndicator","metricValue":"-1","metricTime":"","metricDescription":"Active Service or NO"},{"metricName":"biometricsUseLast6Months","metricValue":"-1","metricTime":"6M","metricDescription":"Biometrics use in the last 6 months"},{"metricName":"biometricsUseLast12Months","metricValue":"-1","metricTime":"12M","metricDescription":"Biometrics use in the last 12 months"}]}';
    public static final String RESPONSE_CHANNELS_KO = '{"Result":{"code":"404","description":"Numero de persona no existente"}}';

	public static final String RESPONSE_GDPR			= '{"treatmentId":"0001-A","isResult":false,"userId":12542,"consentList":[{"consentId":6,"isConsent":false}]}';
	public static final String RESPONSE_OTHER_GDPR_NEW	= '{"treatmentId":"0001-A","isResult":false,"userId":12542,"consentList":[{"consentId":4,"isConsent":false}]}';
	public static final String RESPONSE_OTHER_GDPR		= '{"treatmentId":"0001-A","isResult":true,"userId":12542,"consentList":[{"consentId":4,"isConsent":true}]}';
	
    public static final String RESPONSE_CLI_GETPRODUCTS 		= '{"key":1,"numPages":1,"total":1,"ticket":"N0000000000000001355000315","lastUpdated":"2020-09-21","Contracts":[{"id":9620303146143,"alias":"1","comercialType":{"10006":"Préstamos"},"financialType":{"50032":"Préstamo"},"ownerType":{"51":""},"currency":"200","branch":1,"country":"11.0","openingDate":"1997-10-22","descriptionId":413,"Balance":[{"type":"Limit","amount":0.0,"currency":"200"},{"type":"Granted","amount":1083119.2,"currency":"200"}]}]}';
	public static final String RESPONSE_CLI_COMMERCIALPRODUCTS 	= '{"description": "Tesorería - Pasivo","state": {"1": "No tiene"},"preconceived": 0,"isTarget": false,"oportunity": {},"revDate" : "2020-10-12","modDate" : "2020-05-03","hasOtherEnt" : true,"otherEntDesc" : "Tiene su Nómina en el BBVA","commentary" : "Esta pensando en moverla","Contracts":[{"id" : 96203031461433434,"description" : "Nomina","balance" : 1300.00},{"id" : 96203031461433435,"description" : "Nomina","balance" : 500.50},{"id" : 96203031461433436, "description" : "Nomina","balance" : 1300.27},{"id" : 96203031461433437, "description" : "Nomina","balance" : 320.00},{"id" : 96203031461433438, "description" : "Nomina","balance" : 325.00}],"totalBalance" : "1000.00","ticket" : "N0000000000000001355000114"}';
	public static final String RESPONSE_CLI_CUSTOMMERDATA 		= '{"customerInternalId":13550,"customerName":"VICTOR","customerLastName":"SAULER  PORTALÑ","customerDocId":{"key":"NIF","value":"59898909D"},"birthDate":"1979-6-5","constitutionDate":"1970-10-12","language":"2","mobilePhoneNumber":646418238,"phoneNumber":948266127,"email":"saulerPortal@lacaixa.es","employeeId":"U01U0146524","employeeName":"OLGA ROBLES GEA","interlocId":16849239,"interlocName":"","principalBranch":9712,"relatedBranch":[33,2931,8611],"loyaltyPrograms":[{"program":{"key":"AGRCT","value":"AgroBank"},"isCompilance":false},{"program":{"key":"PSU","value":"Día a Día"},"isCompilance":true,"compilanceValue":"100%"},{"program":{"key":"PSU","value":"Día a Día"},"isCompilance":true,"compilanceValue":"0%"}],"balance":[{"type":{"key":"P","value":"LIABILITIES"},"amount":0.0},{"type":{"key":"A","value":"ASSETS"},"amount":101.59},{"type":{"key":"F","value":"PROFESSIONAL INCOME"},"amount":0.0},{"type":{"key":"L","value":"PERSONAL INCOME"},"amount":0.0},{"type":{"key":"N","value":"PENSION INCOME"},"amount":0.0},{"type":{"key":"R","value":"PROFITABILITY"},"amount":0.0}],"wall":true,"segment":{"key":"RPF","value":"Resto Personas Físicas"},"isConfidential":false,"confidentialBranch":0,"customerType":{"key":"F","value":"Físico"},"isEmployee":false,"loyaltySignals":[{"key":"12","value":"Real State"},{"key":"3","value":"Ent. social solidaria"}],"contactPerson":"","contactNumber":0,"realContactNumber":0,"cnaeCode":"0","postCode":31007,"country":"11","comercialGroup":"","contactTime":{"timePeriod":{"key":"M","value":"Mañana"},"initialTime":"10:00:00","finalTime":"17:00:00"},"colectives":[922,16232,19394,30565,30723],"isClient":false,"clientExperience":2,"isPreconceived":false,"customerBusiness":[{"key":"test","value":"test"}],"preferedChanel":{"key":"M","value":"Muro"},"attentionModel":{"key":"1.0","value":"Cliente de alto valor"},"LoyaltyLink":[{"isCompilance":true,"indicators":1,"financialIndicator":2}],"cirbeFee":13,"qualification":"","pctRar":47,"addedValue":23,"subAttentionModel":"A","attentionModelType":"A","attentionModelCompilance":100,"isCompilanceAttentionModel":true,"isMustCompilanceAttentionModel":true,"globalCompilancePercentage":100,"compilanceDateLimit":"2022-12-10","adressNumber":"C/Gran via 201, 5º 1ª","locality":"31","subBusiness":{"key":"PAR","value":"Individuals"},"RelatedEntities":[{"key":"BNKPUR","value":"Bankia Puro"}],"riskMatrix":0}';
	public static final String RESPONSE_CLI_CUSTOMMERDATA2 		= '{"customerInternalId":13550,"customerName":"VICTOR","customerLastName":"SAULER  PORTALÑ","customerDocId":{"key":"NIF","value":"59898909D"},"birthDate":"1979-6-5","language":"2","mobilePhoneNumber":646418238,"phoneNumber":948266127,"email":"saulerPortal@lacaixa.es","employeeId":null,"employeeName":"OLGA ROBLES GEA","interlocId":13550,"principalBranch":null,"relatedBranch":null,"loyaltyPrograms":null,"balance":null,"wall":true,"segment":{},"isConfidential":false,"confidentialBranch":0,"customerType":{"key":"F","value":"Físico"},"isEmployee":false,"loyaltySignals":[{"key":"12","value":"Real State"},{"key":"3","value":"Ent. social solidaria"}],"contactPerson":"","contactNumber":0,"realContactNumber":0,"cnaeCode":"0","postCode":31007,"country":"11","comercialGroup":"","contactTime":null,"colectives":null,"isClient":false,"clientExperience":2,"isPreconceived":true,"customerBusiness":[{"key":"test","value":"test"}],"preferedChanel":{"key":"M","value":"Muro"},"rating":{"status":{"key":"E","value":"E"},"value":1.1},"scoring":{"status":{"key":"A","value":"A"},"value":2.3},"attentionModel":{"key":"A","value":"Alto potencial"},"isCompilanceAttentionModel":false,"isMustCompilanceAttentionModel":false}';
	public static final String RESPONSE_CLI_SIGNALDATA 			= '{"loyaltySignals":[{"12":"Real State"},{"3":"Ent. social solidaria"}]}';
	public static final String RESPONSE_CLI_WARNINGDATA 		= '{"warnings":[{"key":"17","value":"Contrato marco"},{"key":"25","value":"Cliente con reclamaciones históricas"},{"key":"11","value":"Información de seguimiento"},{"key":"4","value":"Cobros pendientes"},{"key":"10","value":"Cliente con alertas de seguimiento"}]}';
	public static final String RESPONSE_CLI_CUSTOMMERPRODDATA 	= '{"customerBusiness": [{"business": {"key":"BPA","value":"Banca particulares"},"experiences": [{"experience": {"key":"BPA001","value":"Dia a dia"},"globalExperience": 1,"order": 1,"isMyBox": false,"products": [{"productCode": {"key":"50046","value":"Tarjeta crédito"},"state": {"key":"2","value":"Tiene"},"order": 1,"isProfessional": false,"preconceived": 3,"isTarget": false,"isPotential": false,"oportunity": {"key":"OPORT","value":"Oportunidad"}},{"productCode": {"key":"50077","value":"Caixabank Now"},"state": {"key":"1","value":"No tiene"},"order": 1,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50117","value":"ServiCuentas"},"state": {"key":"1","value":"No tiene"},"order": 1,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null}]},{"experience": {"key":"BPA002","value":"Disfrutar de la vida"},"globalExperience": 2,"order": 2,"isMyBox": false,"products": [{"productCode": {"key":"50030","value":"Hipoteca"},"state": {"key":"1","value":"No tiene"},"order": 2,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50034","value":"Compra estrella"},"state": {"key":"1","value":"No tiene"},"order": 2,"isProfessional": false,"preconceived": 1500,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50047","value":"Tarjeta revolving"},"state": {"key":"1","value":"No tiene"},"order": 2,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null}]},{"experience": {"key":"BPA003","value":"Pensar en el futuro"},"globalExperience": 3,"order": 3,"isMyBox": false,"products": [{"productCode": {"key":"50003","value":"Libreta infantil"},"state": {"key":"2","value":"Tiene"},"order": 3,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50004","value":"Vista y plazo"},"state": {"key":"2","value":"Tiene"},"order": 3,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50008","value":"Seguros jubilación"},"state": {"key":"1","value":"No tiene"},"order": 3,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50010","value":"Planes de pensiones"},"state": {"key":"1","value":"No tiene"},"order": 3,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null}]},{"experience": {"key":"BPA004","value":"Dormir tranquilo"},"globalExperience": 4,"order": 4,"isMyBox": true,"products": [{"productCode": {"key":"50093","value":"Seguros de hogar"},"state": {"key":"1","value":"No tiene"},"order": 4,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50095","value":"Auto"},"state": {"key":"1","value":"No tiene"},"order": 4,"isProfessional": false,"preconceived": 0,"isTarget": true,"isPotential": false,"oportunity": null},{"productCode": {"key":"50106","value":"Salud"},"state": {"key":"1","value":"No tiene"},"order": 4,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50112","value":"Dental"},"state": {"key":"1","value":"No tiene"},"order": 4,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50102","value":"Vida"},"state": {"key":"1","value":"No tiene"},"order": 4,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50111","value":"Decesos"},"state": {"key":"1","value":"No tiene"},"order": 4,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null},{"productCode": {"key":"50123","value":"Sistemas seguridad"},"state": {"key":"1","value":"No tiene"},"order": 4,"isProfessional": false,"preconceived": 0,"isTarget": false,"isPotential": false,"oportunity": null}]}]}]}';
	
    public static final String RESPONSE_GCF_OPP 		= '{"Opportunity":{"opportunityId":34568,"employeeId":96827,"offerUntil":"2021-03-31","potential":"S","holdingOtherEntities":"S","entityName":"BBVA","amountOtherEntities":113243.50,"dueDate":"2021-09-21","commentary":"alta nueva pea","userId":13550,"interestRate":0.00,"noOfferUntil":"","monthlyFee":0.00,"warningIndicator":"S"}}';
	public static final String RESPONSE_GCF_NOTBODY 	= '{}';
	public static final String RESPONSE_GCF_CAMBIOEMPLEADO 	= '{"text":"value"}';
	public static final String RESPONSE_GCF_JOBLEVEL 	= '{"text":"value"}';
    public static final String RESPONSE_GCF_GESTORES 	= '{"EmployeeS":[{"employeeId": 52391,"firstName":"ANNA","surname":"ORRIOLS","secondSurname":"PEREZ"},{"employeeId":68044,"firstName":"DAVID","surname": "ROCA","secondSurname":"SALA"},{"employeeId":49224,"firstName":"GUILLEM","surname":"ZAMORA","secondSurname":"BARAT"}]}';
    public static final String RESPONSE_GCF_REASIGNARCARTERA = '{"warningMessage": "Debido al volumen de la cartera esta petición no puede procesarse en On-line. Ha sido registrada y mañana estará disponible."}';
	public static final String RESPONSE_CP_INTCNT 	= '{"statusCode": "201","eventPremiumId": "8911100000000001"}';
	public static final String RESPONSE_CP_MOCNT 	= '{"statusCode": "200"}';
    //public static final String RESPONSE_BODY_TEAMS = '{Body={"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=200, TimeElapsed=345}';			
    //public static final String RESPONSE_BODY_TEAMS = '{"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=200, TimeElapsed=345}';			
	//public static final String RESPONSE_BODY_TEAMS = '{"Body":{"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"},"Status":"OK","StatusCode":200,"TimeElapsed":345}';
	public static final String RESPONSE_BODY_TEAMS ='{"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}';
    
	public static final String RESPONSE_ERROR = '{"errorMessage": "Error en los parámetros de entrada","errorCode": "GCF43400"}';
	
	public static final String RESPONSE_CJLOGIN = '<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchem" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:xtk:session" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><LogonResponse xmlns="urn:xtk:session" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><pstrSessionToken xsi:type="xsd:string">___cde21359-385e-4ad6-b0fe-6e5c0d803033</pstrSessionToken><pSessionInfo xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><sessionInfo><serverInfo advisedClientBuildNumber="9032" allowSQL="false" buildNumber="9032" commitId="cee805c" databaseId="u0A7706282AAEBDAE" defaultNameSpace="cxb" fohVersion="2" instanceName="marketingdev" majNumber="6" minClientBuildNumber="8969" minNumber="7" minNumberTechnical="0" releaseName="19.1" securityTimeOut="86400" serverDate="2021-02-03 10:43:40.345Z" servicePack="0" sessionTimeOut="86400" useVault="false"/><userInfo datakitInDatabase="true" homeDir="" instanceLocale="en-GB" locale="en-GB" login="cxb_salesforce" loginCS="Salesforce API User (cxb_salesforce)" loginId="106099740" noConsoleCnx="true" orgUnitId="0" theme="" timezone="Europe/Madrid"><login-group id="1053"/><login-right right="admin"/><installed-package name="accWfTableInDelivery" namespace="acc"/><installed-package name="sftpPackage" namespace="ace"/><installed-package name="apiToolkit" namespace="acx"/><installed-package name="configurationManager" namespace="acx"/><installed-package name="core" namespace="acx"/><installed-package name="databaseUsage" namespace="acx"/><installed-package name="fileManager" namespace="acx"/><installed-package name="livestream" namespace="acx"/><installed-package name="connectors" namespace="crm"/><installed-package name="CJ_PensionPlan" namespace="cxb"/><installed-package name="CL_ConsumoRema" namespace="cxb"/><installed-package name="cxb_DataLoadingOptimisation" namespace="cxb"/><installed-package name="cxb_DeltaRule" namespace="cxb"/><installed-package name="cxb_PFS" namespace="cxb"/><installed-package name="cxb_PKG23" namespace="cxb"/><installed-package name="cxb_PKG4" namespace="cxb"/><installed-package name="cxb_PKG56" namespace="cxb"/><installed-package name="cxb_PKG57" namespace="cxb"/><installed-package name="cxb_PKG58" namespace="cxb"/><installed-package name="cxb_acc_NRTworkflows" namespace="cxb"/><installed-package name="cxb_acc_blacklistTest" namespace="cxb"/><installed-package name="cxb_acc_cp29_webapp" namespace="cxb"/><installed-package name="cxb_acc_cp401" namespace="cxb"/><installed-package name="cxb_acc_cp407" namespace="cxb"/><installed-package name="cxb_acc_cxb1303" namespace="cxb"/><installed-package name="cxb_acc_cxb213b" namespace="cxb"/><installed-package name="cxb_acc_cxb510" namespace="cxb"/><installed-package name="cxb_acc_cxb581" namespace="cxb"/><installed-package name="cxb_acc_cxb596" namespace="cxb"/><installed-package name="cxb_acc_cxb607" namespace="cxb"/><installed-package name="cxb_acc_cxb626" namespace="cxb"/><installed-package name="cxb_acc_cxb7" namespace="cxb"/><installed-package name="cxb_acc_cxb911" namespace="cxb"/><installed-package name="cxb_acc_cxbRegDelFD" namespace="cxb"/><installed-package name="cxb_acc_cxbWorkflowsLoading" namespace="cxb"/><installed-package name="cxb_typos" namespace="cxb"/><installed-package name="content" namespace="ncm"/><installed-package name="aamIntegration" namespace="nms"/><installed-package name="azuredw" namespace="nms"/><installed-package name="billing" namespace="nms"/><installed-package name="campaign" namespace="nms"/><installed-package name="campaignOptimization" namespace="nms"/><installed-package name="centralLocal" namespace="nms"/><installed-package name="core" namespace="nms"/><installed-package name="coreInteraction" namespace="nms"/><installed-package name="country" namespace="nms"/><installed-package name="federatedDataAccess" namespace="nms"/><installed-package name="folder" namespace="nms"/><installed-package name="heatmap" namespace="nms"/><installed-package name="hive" namespace="nms"/><installed-package name="interaction" namespace="nms"/><installed-package name="interactionControl" namespace="nms"/><installed-package name="japanLoc" namespace="nms"/><installed-package name="macIntegration" namespace="nms"/><installed-package name="messageCenter" namespace="nms"/><installed-package name="messageCenterControl" namespace="nms"/><installed-package name="midEmitter" namespace="nms"/><installed-package name="mobile" namespace="nms"/><installed-package name="mobileApp" namespace="nms"/><installed-package name="mrm" namespace="nms"/><installed-package name="neolap" namespace="nms"/><installed-package name="paper" namespace="nms"/><installed-package name="phone" namespace="nms"/><installed-package name="predictive" namespace="nms"/><installed-package name="report" namespace="nms"/><installed-package name="response" namespace="nms"/><installed-package name="ruleset" namespace="nms"/><installed-package name="simulation" namespace="nms"/><installed-package name="social" namespace="nms"/><installed-package name="survey" namespace="nms"/><installed-package name="systemStrings" namespace="nms"/><installed-package name="teradata" namespace="nms"/><installed-package name="webAnalytics" namespace="nms"/><installed-package name="core" namespace="xtk"/></userInfo></sessionInfo></pSessionInfo><pstrSecurityToken xsi:type="xsd:string">@hzc4Gmj2zicERg9NPA7EPpECUih-bp-_Vi6BRR292InLEdQgSkiGPhOX27AHPgYj636_4lJjFbDHRFVpGajqkqwkG1HvShsh8hcFMto2mBE=</pstrSecurityToken></LogonResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
	public static final String RESPONSE_CJLOOKUPLIST = '<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:nms:recipient" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><lookUpCJResponse xmlns="urn:nms:recipient" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><acresults xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><acresults><global><code>0</code><exception></exception><message>Success</message></global><acresult><code>0</code><exception></exception><message>Success</message><result>&lt;recipient id="11281162" numperso="22122"&gt;&lt;FK_Recipient_LookUpCJs boapId="112446273" status="1"&gt;&lt;FK_LookUpCJs_Boap document="" duration="365" id="112446273" label="TCR Test"&gt;&lt;FK_BriefOnPage_ProductGroup&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productGroupName="Planes Pensiones"/&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_ProductGroup&gt;'
		  + '&lt;FK_BriefOnPage_ProductSubGroup&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productSubGroupName="Planes Pensiones"/&gt;'
		  + ' &lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_ProductSubGroup&gt;'
		  + '&lt;FK_BriefOnPage_Product&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productName="Planes Pensiones"/&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_Product&gt;'
		  + '&lt;/FK_LookUpCJs_Boap&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_Recipient_LookUpCJs boapId="112447862" status="1"&gt;'
		  + '&lt;FK_LookUpCJs_Boap document="" duration="365" id="112447862" label="Test CGC"&gt;'
		  + '&lt;FK_BriefOnPage_ProductGroup&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productGroupName="Pagos/Cobros"/&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_ProductGroup&gt;'
		  + '&lt;FK_BriefOnPage_ProductSubGroup&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productSubGroupName="Nómina empresa"/&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_ProductSubGroup&gt;'
		  + '&lt;FK_BriefOnPage_Product&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productName="Nómina empresa"/&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_Product&gt;'
		  + '&lt;/FK_LookUpCJs_Boap&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_Recipient_LookUpCJs boapId="112446034" status="1"&gt;'
		  + '&lt;FK_LookUpCJs_Boap document="" duration="365" id="112446034" label="New Campaign"&gt;'
		  + '&lt;FK_BriefOnPage_ProductGroup&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productGroupName="Tarjetas"/&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_ProductGroup&gt;'
		  + '&lt;FK_BriefOnPage_ProductSubGroup&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productSubGroupName="Tarjeta débito"/&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_ProductSubGroup&gt;'
		  + '&lt;FK_BriefOnPage_Product&gt;'
		  + '&lt;FK_Recipient_LookUpCJs&gt;'
		  + '&lt;FK_LookUpCJs_Boap productName="Visa electron"/&gt;'
		  + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/FK_BriefOnPage_Product&gt;'
		  + '&lt;/FK_LookUpCJs_Boap&gt;'
	      + '&lt;/FK_Recipient_LookUpCJs&gt;'
		  + '&lt;/recipient&gt;</result></acresult></acresults></acresults></lookUpCJResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';

	public static final String RESPONSE_CJLOOKUP = '<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:nms:recipient" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><lookUpCJResponse xmlns="urn:nms:recipient" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><acresults xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><acresults><global><code>0</code><exception></exception><message>Success</message></global><acresult><code>0</code><exception></exception><message>Success</message><result><recipient id="11281611" numperso="22122">'
		+ '<FK_Recipient_LookUpCJs boapId="9510886" status="0">'
		+ '<FK_LookUpCJs_Boap document="" duration="0" id="9510886" label="CXB Campaign Demo">'
		+ '<desc>Brief for &amp;lt;STRONG&amp;gt;MRM Campaign Demo&amp;lt;/STRONG&amp;gt; on 29052018</desc>'
		+ '<FK_BriefOnPage_ProductGroup>'
		+ '<FK_Recipient_LookUpCJs>'
		+ '<FK_LookUpCJs_Boap productGroupName="Canales"/>'
		+ '</FK_Recipient_LookUpCJs>'
		+ '</FK_BriefOnPage_ProductGroup>'
		+ '<FK_BriefOnPage_ProductSubGroup>'
		+ '<FK_Recipient_LookUpCJs>'
		+ '<FK_LookUpCJs_Boap productSubGroupName="Canales"/>'
		+ '</FK_Recipient_LookUpCJs>'
		+ '</FK_BriefOnPage_ProductSubGroup>'
		+ '<FK_BriefOnPage_Product>'
		+ '<FK_Recipient_LookUpCJs>'
		+ '<FK_LookUpCJs_Boap productName="Canales"/>'
		+ '</FK_Recipient_LookUpCJs>'
		+ '</FK_BriefOnPage_Product>'
		+ '</FK_LookUpCJs_Boap>'
		+ '</FK_Recipient_LookUpCJs>'
		+ '</recipient></result></acresult></acresults></acresults></lookUpCJResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';

	public static final String RESPONSE_CJMARKETING = '<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:nms:recipient" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><marketing360Response xmlns="urn:nms:recipient" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><acresults xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><acresults><global><code>0</code><exception></exception><message>Success</message></global><acresult><code>0</code><exception></exception><message>Success</message><result><recipient id="11281162">' 
		+ '<recipientInfo created="2018-07-19 10:47:25.384Z" email="-1" firstName="MARIA BEGOÑA" gender="2" lastName="ALONSO" status="1"/>'
		+ '<country>'
		+ '<origin isoA2="ES"/>'
		+ '</country>'
		+ '<proposition eventDate="2021-03-09 11:47:01.821Z" offerStatus="0" productId="0" rank="0" weight="0">'
		+ '<offer>'
		+ '<url CAS="https://pre.loc1.caixabank.es/GPeticiones?PN=CAR&amp;amp;PE=142&amp;amp;CANAL=I&amp;amp;DEMO=2&amp;amp;IDIOMA=01IDIOMA2=02&amp;amp;E_OFFERIDDESIGN=0E_OFFERSPACE=r_dummy" CAT="https://pre.loc1.caixabank.es/GPeticiones?PN=CAR&amp;amp;PE=142&amp;amp;CANAL=I&amp;amp;DEMO=2&amp;amp;IDIOMA=01IDIOMA2=01&amp;amp;E_OFFERIDDESIGN=0E_OFFERSPACE=r_dummy"/>'
		+ '</offer>'
		+ '<offerSpace offerChannel="120"/>'
		+ '</proposition>'
		+ '<broadLog address="" broadLogId="6578783" eventDate="2020-11-17 17:19:12.808Z" id="6578783" status="">'
		+ '<delivery code="" deliveryId="52750451" label="Test_Retorno_AVE_2020_11" messageType="Agency">'
		+ '<content>'
		+ '<email>'
		+ '<mirrorPage url="https://caixa-mid-stage1.campaign.adobe.com/nl/jsp/m.jsp?c=%40%2BeeInivPY55ZUrER4XJ%2BrXel8JRUDPY%2B6yuK9aHt6I0%3D"/>'
		+ '</email>'
		+ '</content>'
		+ '<operation lookUpCJs_Boap_Id="112446034"/>'
		+ '</delivery>'
		+ '</broadLog>'
		+ '</recipient></result></acresult></acresults></acresults></marketing360Response></SOAP-ENV:Body></SOAP-ENV:Envelope>';

	public static String RESPONSE_CJLookUpError = '<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:nms:recipient" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><lookUpCJResponse xmlns="urn:nms:recipient" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><acresults xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><acresults><global><code>1</code><exception></exception><message>At least one action failed while managing recipient history</message></global><acresult><code></code><exception></exception><message>Target not exists</message><result>OK: no record found.</result></acresult></acresults></acresults></lookUpCJResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';

	//public static String RESPONSE_TEAMSAUTH = '{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6InN4NFE3NVV3bFlFWGs3cHA0MWliMDZ4VTBBSC1sZ0VZOEZ3UHh1bWR0X00iLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kN2I2NWYwMy0zNmEwLTQzOTUtOWQ4ZS01MjY5YmVhZGI1YzQvIiwiaWF0IjoxNjI0MzU2Mzc1LCJuYmYiOjE2MjQzNTYzNzUsImV4cCI6MTYyNDM2MDI3NSwiYWlvIjoiRTJaZ1lPRE1kWDVqWDJSODUyZlcxZElONWd2NkFBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTYWxlc2ZvcmNlIiwiYXBwaWQiOiIyMjdjMjQyMy00NGZjLTQ2ODEtOThiNi02NWZkMGI5NzBlOWQiLCJhcHBpZGFjciI6IjIiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kN2I2NWYwMy0zNmEwLTQzOTUtOWQ4ZS01MjY5YmVhZGI1YzQvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiI0ZDQzMTExMC1jMjZiLTQwMjAtYmFhMi1kMGJiMjRjOTEwMzgiLCJyaCI6IjAuQVRFQUExLTIxNkEybFVPZGpsSnB2cTIxeENNa2ZDTDhSSUZHbUxabF9RdVhEcDB4QUFBLiIsInJvbGVzIjpbIk9ubGluZU1lZXRpbmdzLlJlYWRXcml0ZS5BbGwiLCJVc2VyLlJlYWRXcml0ZS5BbGwiLCJEaXJlY3RvcnkuUmVhZFdyaXRlLkFsbCIsIkRpcmVjdG9yeS5SZWFkLkFsbCIsIlVzZXIuUmVhZC5BbGwiXSwic3ViIjoiNGQ0MzExMTAtYzI2Yi00MDIwLWJhYTItZDBiYjI0YzkxMDM4IiwidGVuYW50X3JlZ2lvbl9zY29wZSI6IkVVIiwidGlkIjoiZDdiNjVmMDMtMzZhMC00Mzk1LTlkOGUtNTI2OWJlYWRiNWM0IiwidXRpIjoiNVZoZUhKb0dTRU9zV2djNkFrNTFBQSIsInZlciI6IjEuMCIsIndpZHMiOlsiMDk5N2ExZDAtMGQxZC00YWNiLWI0MDgtZDVjYTczMTIxZTkwIl0sInhtc190Y2R0IjoxNTI2MDIxMjc3fQ.jp8WSU2w9FZWPzqrsEXpaQ5GWt-8xoXZoYj_bLEDvCROUjNOq_Ifq56rH4caPxBqoJLOS2zN4K6TtBVYRlwAKpJqXgt4493x9V9x1at65vLgog85UzeP8R8_lUkfl7V6BM4iJ6PzOyWIXHcjgc1Wj5OBgKFeMeXrmglJR8H3PVbbpyJ_WDtOke7SiAxvljcV_TX5SFiS-gw7zo_ltsQ3ICrbjbSn7pxbuUe0rf5q6Y5_8HjDhUu8WUBizaVhdQQUiYDdQ8m0l7xM6sQdZ_CerEnrrnosfGpkxvgAPnYw8k5jUbN5Dv63760RZRHHGN7UoSPO3zwRVP3OAvBdLDgEyw"}';
	public static String RESPONSE_TEAMSGETUSERID = '{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/$entity","businessPhones":["+34660440021"],"displayName":"CARLES LUNA BROSA","givenName":"CARLES","jobTitle":null,"mail":"cluna@caixabankpre.com","mobilePhone":"+34660440021","officeLocation":"07365","preferredLanguage":null,"surname":"LUNA BROSA","userPrincipalName":"U0190326@caixabankpre.com","id":"415b41e6-28ab-4ef1-9f46-13a6d53eb368"}';
	public static String RESPONSE_TEAMSGETURL = '{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users(\'415b41e6-28ab-4ef1-9f46-13a6d53eb368\')/onlineMeetings/$entity","id":"MSo0MTViNDFlNi0yOGFiLTRlZjEtOWY0Ni0xM2E2ZDUzZWIzNjgqMCoqMTk6bWVldGluZ19aRGhtTTJVeU1XTXRPV0ZtTmkwMFlqTmhMVGxsTmpjdFltUTFOREE0TVdNMU1UVmlAdGhyZWFkLnYy","creationDateTime":"2021-06-22T10:11:17.1153832Z","startDateTime":"2021-06-22T09:30:00Z","endDateTime":"2021-06-22T10:00:00Z","joinUrl":"https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZDhmM2UyMWMtOWFmNi00YjNhLTllNjctYmQ1NDA4MWM1MTVi%40thread.v2/0?context=%7b%22Tid%22%3a%22d7b65f03-36a0-4395-9d8e-5269beadb5c4%22%2c%22Oid%22%3a%22415b41e6-28ab-4ef1-9f46-13a6d53eb368%22%7d","joinWebUrl":"https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZDhmM2UyMWMtOWFmNi00YjNhLTllNjctYmQ1NDA4MWM1MTVi%40thread.v2/0?context=%7b%22Tid%22%3a%22d7b65f03-36a0-4395-9d8e-5269beadb5c4%22%2c%22Oid%22%3a%22415b41e6-28ab-4ef1-9f46-13a6d53eb368%22%7d","subject":"Test get Response","isBroadcast":false,"autoAdmittedUsers":"everyoneInCompany","outerMeetingAutoAdmittedUsers":null,"isEntryExitAnnounced":true,"allowedPresenters":"everyone","allowMeetingChat":"enabled","allowTeamworkReactions":true,"allowAttendeeToEnableMic":true,"allowAttendeeToEnableCamera":true,"capabilities":[],"videoTeleconferenceId":null,"externalId":null,"broadcastSettings":null,"audioConferencing":null,"meetingInfo":null,"meetingAttendanceReport":null,"registration":null,"participants":{"organizer":{"upn":"U0190326@caixabankpre.com","role":"presenter","identity":{"acsUser":null,"spoolUser":null,"phone":null,"guest":null,"encrypted":null,"onPremises":null,"acsApplicationInstance":null,"spoolApplicationInstance":null,"applicationInstance":null,"application":null,"device":null,"user":{"id":"415b41e6-28ab-4ef1-9f46-13a6d53eb368","displayName":null,"tenantId":"d7b65f03-36a0-4395-9d8e-5269beadb5c4","identityProvider":"AAD"}}},"attendees":[]},"lobbyBypassSettings":{"scope":"organization","isDialInBypassEnabled":true},"chatInfo":{"threadId":"19:meeting_ZDhmM2UyMWMtOWFmNi00YjNhLTllNjctYmQ1NDA4MWM1MTVi@thread.v2","messageId":"0","replyChainMessageId":null},"joinInformation":{"content":"data:text/html,%3cdiv+style%3d%22width%3a100%25%3bheight%3a+20px%3b%22%3e%0d%0a++++%3cspan+style%3d%22white-space%3anowrap%3bcolor%3a%235F5F5F%3bopacity%3a.36%3b%22%3e________________________________________________________________________________%3c%2fspan%3e%0d%0a%3c%2fdiv%3e%0d%0a+%0d%0a+%3cdiv+class%3d%22me-email-text%22+style%3d%22color%3a%23252424%3bfont-family%3a%27Segoe+UI%27%2c%27Helvetica+Neue%27%2cHelvetica%2cArial%2csans-serif%3b%22%3e%0d%0a++++%3cdiv+style%3d%22margin-top%3a+24px%3b+margin-bottom%3a+20px%3b%22%3e%0d%0a++++++++%3cspan+style%3d%22font-size%3a+24px%3b+color%3a%23252424%22%3eMicrosoft+Teams+meeting%3c%2fspan%3e%0d%0a++++%3c%2fdiv%3e%0d%0a++++%3cdiv+style%3d%22margin-bottom%3a+20px%3b%22%3e%0d%0a++++++++%3cdiv+style%3d%22margin-top%3a+0px%3b+margin-bottom%3a+0px%3b+font-weight%3a+bold%22%3e%0d%0a++++++++++%3cspan+style%3d%22font-size%3a+14px%3b+color%3a%23252424%22%3eJoin+on+your+computer+or+mobile+app%3c%2fspan%3e%0d%0a++++++++%3c%2fdiv%3e%0d%0a++++++++%3ca+class%3d%22me-email-headline%22+style%3d%22font-size%3a+14px%3bfont-family%3a%27Segoe+UI+Semibold%27%2c%27Segoe+UI%27%2c%27Helvetica+Neue%27%2cHelvetica%2cArial%2csans-serif%3btext-decoration%3a+underline%3bcolor%3a+%236264a7%3b%22+href%3d%22https%3a%2f%2fteams.microsoft.com%2fl%2fmeetup-join%2f19%253ameeting_ZDhmM2UyMWMtOWFmNi00YjNhLTllNjctYmQ1NDA4MWM1MTVi%2540thread.v2%2f0%3fcontext%3d%257b%2522Tid%2522%253a%2522d7b65f03-36a0-4395-9d8e-5269beadb5c4%2522%252c%2522Oid%2522%253a%2522415b41e6-28ab-4ef1-9f46-13a6d53eb368%2522%257d%22+target%3d%22_blank%22+rel%3d%22noreferrer+noopener%22%3eClick+here+to+join+the+meeting%3c%2fa%3e%0d%0a++++%3c%2fdiv%3e%0d%0a++++%0d%0a++++%0d%0a++++++%0d%0a++++%0d%0a++++%0d%0a++++%0d%0a++++%3cdiv+style%3d%22margin-bottom%3a+24px%3bmargin-top%3a+20px%3b%22%3e%0d%0a++++++++%3ca+class%3d%22me-email-link%22+style%3d%22font-size%3a+14px%3btext-decoration%3a+underline%3bcolor%3a+%236264a7%3bfont-family%3a%27Segoe+UI%27%2c%27Helvetica+Neue%27%2cHelvetica%2cArial%2csans-serif%3b%22+target%3d%22_blank%22+href%3d%22https%3a%2f%2faka.ms%2fJoinTeamsMeeting%22+rel%3d%22noreferrer+noopener%22%3eLearn+More%3c%2fa%3e++%7c+%3ca+class%3d%22me-email-link%22+style%3d%22font-size%3a+14px%3btext-decoration%3a+underline%3bcolor%3a+%236264a7%3bfont-family%3a%27Segoe+UI%27%2c%27Helvetica+Neue%27%2cHelvetica%2cArial%2csans-serif%3b%22+target%3d%22_blank%22+href%3d%22https%3a%2f%2fteams.microsoft.com%2fmeetingOptions%2f%3forganizerId%3d415b41e6-28ab-4ef1-9f46-13a6d53eb368%26tenantId%3dd7b65f03-36a0-4395-9d8e-5269beadb5c4%26threadId%3d19_meeting_ZDhmM2UyMWMtOWFmNi00YjNhLTllNjctYmQ1NDA4MWM1MTVi%40thread.v2%26messageId%3d0%26language%3den-US%22+rel%3d%22noreferrer+noopener%22%3eMeeting+options%3c%2fa%3e+%0d%0a++++++%3c%2fdiv%3e%0d%0a%3c%2fdiv%3e%0d%0a%3cdiv+style%3d%22font-size%3a+14px%3b+margin-bottom%3a+4px%3bfont-family%3a%27Segoe+UI%27%2c%27Helvetica+Neue%27%2cHelvetica%2cArial%2csans-serif%3b%22%3e%0d%0a%0d%0a%3c%2fdiv%3e%0d%0a%3cdiv+style%3d%22font-size%3a+12px%3b%22%3e%0d%0a%0d%0a%3c%2fdiv%3e%0d%0a%3cdiv+style%3d%22width%3a100%25%3bheight%3a+20px%3b%22%3e%0d%0a++++%3cspan+style%3d%22white-space%3anowrap%3bcolor%3a%235F5F5F%3bopacity%3a.36%3b%22%3e________________________________________________________________________________%3c%2fspan%3e%0d%0a%3c%2fdiv%3e","contentType":"html"}}';
    public static String RESPONSE_HGMSURVEYID = '{"surveyId": 842982,"name": "Momento - Visita all-in-one (simple)"}';
	public static String RESPONSE_HGMCUSTOMER =  '{"errorMessage":"OK","errorCode":"000"}';
    public static String responsehgmcustomerfw = '{"firstname": "Phinehas","lastname": "Asel","email": "phinehas.asel@gmail.com","prefix": "0034","phone": "693825714","language": "es","startDate": "2021-05-01","endDate": "2021-05-31","attributes": ["03386","U0138145","1"]}';
	public static String RESPONSE_CUSTOMERSURVEY =  '{"errorMessage":"OK","errorCode":"000"}';
	public static String RESPONSE_SURVEY_FC = '{"Surveys":[{"trigger": "3333","tabulatedComment": "txt com2","surveyId": 2222,"smiley": 1,"secondSurveyId": 777,"secondResponseDate": "2022-10-31","secondRating": "des  valiracion2","secondInvitationDate": "2022-10-26","secondChannel": "666","responseDate": "2022-10-20","rating": "desvaloracion","procedureStateDescription": "estado","procedureDate": "2022-12-28","loadDate": "2022-04-21","invitationDate": "2022-04-27","description": "777","date": null,"dataDate": "2023-06-14","customerInternalId": 13550,"customerAssociateEmployeeId": "81117","comment": "txt com1","channel": "444","branchManagementId": 555,"branchCheckinId": 9712,"associateEmployeeId": "81116","alertAssociateEmployeeId": "81118"}]}';
	public static String RESPONSE_TEAMSAUTH ='{"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=200, TimeElapsed=345}';			

	public static final String RESPONSE_TRACEABILITY = '{"moreElements": "S","petitionsList": [{ "petitionId": "97120012545544","petitionStatus": "A","processId": 33, "processDescriptionCat": "Procés dinformació","processDescriptionCas": "Proceso de información", "customerInternalId": 13550, "personName": "Silvia Martínez","branchId": 9712,"scopeId": 10,"scopeDescriptionCat": "Hipoteca","scopeDescriptionCas": "Hipoteca","startPetitionDate": "2020-01-25","endDatePetition": "2021-01-21","statusDescriptionCat": "Cita pendent","statusDescriptionCas": "Cita pendiente","stepNum": 1,"employeeId": "U0123456","stepList": [{"stepId": "22000001","stepNumber": 1,"stepDate": "2020-11-30","stepExpectedDate": "2020-12-31","stepRealDate": "2020-12-20","stepDescriptionCat": "Primer pas","stepDescriptionCas": "Primer paso"}]}, { "petitionId": "97120012545544","petitionStatus": "A","processId": 33, "processDescriptionCat": "Procés dinformació","processDescriptionCas": "Proceso de información", "customerInternalId": 13550, "personName": "Victor Sauler","branchId": 9712,"scopeId": 10,"scopeDescriptionCat": "Financiació","scopeDescriptionCas": "Financiación","startPetitionDate": "2020-09-25","endDatePetition": "2022-09-21","statusDescriptionCat": "Finalitzat","statusDescriptionCas": "Finalizado","stepNum": 3,"employeeId": "U0123456","stepList": [{"stepId": "22000001","stepNumber": 1,"stepDate": "2020-11-30","stepExpectedDate": "2020-12-31","stepRealDate": "2020-12-20","stepDescriptionCat": "Primer pas","stepDescriptionCas": "Primer paso"}]}, { "petitionId": "97120012545544","petitionStatus": "A","processId": 33, "processDescriptionCat": "Procés dinformació","processDescriptionCas": "Proceso de información", "customerInternalId": 13550, "personName": "Victor Sauler","branchId": 9712,"scopeId": 10,"scopeDescriptionCat": "Financiació","scopeDescriptionCas": "Financiación","startPetitionDate": "2022-09-10","endDatePetition": "2022-09-19","statusDescriptionCat": "Actiu","statusDescriptionCas": "Activo","stepNum": 2,"employeeId": "U0123456","stepList": [{"stepId": "22000001","stepNumber": 1,"stepDate": "2020-11-30","stepExpectedDate": "2021-12-31","stepRealDate": "2021-12-20","stepDescriptionCat": "Primer pas","stepDescriptionCas": "Primer paso"}]}]}';

	public static final String RESPONSE_COBROWSING_OK = 'System.HttpResponse[Status=null, StatusCode=204]';
    public static final String RESPONSE_COBROWSING_KO = 'System.HttpResponse[Status=Not Found, StatusCode=404]';

	global HTTPResponse respond(HTTPRequest request) {
		// Create a fake response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		if(option == 'CHANNELS' && status == 'OK'){
			response.setBody(RESPONSE_CHANNELS);
            response.setStatusCode(200); 
		} 
        else if(option == 'CHANNELS' && status == 'KO'){
			response.setBody(RESPONSE_CHANNELS_KO);
            response.setStatusCode(500); 
		}
		else if(option == 'GDPR' && status == 'OK'){
			response.setBody(RESPONSE_GDPR);
            response.setStatusCode(200); 
		}
		else if(option == 'GDPR_OTHER' && status == 'OK'){
			response.setBody(RESPONSE_OTHER_GDPR);
            response.setStatusCode(200);
		}
		else if(option == 'GDPR_OTHER_NEW' && status == 'OK'){
			response.setBody(RESPONSE_OTHER_GDPR_NEW);
            response.setStatusCode(200);
		}
		else if(option == 'CLI_PRODUCTS' && status == 'OK'){
			response.setBody(RESPONSE_CLI_GETPRODUCTS);
            response.setStatusCode(200);
		}
		else if(option == 'CLI_COMMERCIALPRODUCTS' && status == 'OK'){
			response.setBody(RESPONSE_CLI_COMMERCIALPRODUCTS);
            response.setStatusCode(200);
		}
		else if(option == 'CLI_CUSTOMMERDATA' && status == 'OK'){
			response.setBody(RESPONSE_CLI_CUSTOMMERDATA);
            response.setStatusCode(200);
		}
		else if(option == 'CLI_CUSTOMMERDATA2' && status == 'OK'){
			response.setBody(RESPONSE_CLI_CUSTOMMERDATA2);
            response.setStatusCode(200);
		}
		else if(option == 'CLI_SIGNALDATA' && status == 'OK'){
			response.setBody(RESPONSE_CLI_SIGNALDATA);
            response.setStatusCode(200);
		}
		else if(option == 'CLI_WARNINGDATA' && status == 'OK'){
			response.setBody(RESPONSE_CLI_WARNINGDATA);
            response.setStatusCode(200);
		}
		else if(option == 'CLI_CUSTOMMERPRODDATA' && status == 'OK'){
			response.setBody(RESPONSE_CLI_CUSTOMMERPRODDATA);
            response.setStatusCode(200);
		}
        else if(option == 'GCF_OPP' && status == 'OK'){
			response.setBody(RESPONSE_GCF_OPP);
            response.setStatusCode(200);
		} 
		else if(option == 'GCF_ALTAOPP' && status == 'OK'){
			response.setBody(RESPONSE_GCF_NOTBODY);
            response.setStatusCode(200);
		}
        else if(option == 'GCF_MODOPP' && status == 'OK'){
			response.setBody(RESPONSE_GCF_NOTBODY);
            response.setStatusCode(200);
		}
        else if(option == 'GCF_GESTORES' && status == 'OK'){
			response.setBody(RESPONSE_GCF_GESTORES);
            response.setStatusCode(200);
		}
        else if(option == 'GCF_REASIGNARCARTERA' && status == 'OK'){
			response.setBody(RESPONSE_GCF_REASIGNARCARTERA);
            response.setStatusCode(200);
		}
        else if(option == 'GCF_CAMBIARGESTOR' && status == 'OK'){
			response.setBody(RESPONSE_GCF_NOTBODY);
            response.setStatusCode(200);
		}
        else if(option == 'CP_INSCNT' && status == 'OK'){
			response.setBody(RESPONSE_CP_INTCNT);
            response.setStatusCode(201);
		}
        else if(option == 'CP_MOCNT' && status == 'OK'){
			response.setBody(RESPONSE_CP_MOCNT);
            response.setStatusCode(200);
		}
        else if(option == 'CP_DELCNT' && status == 'OK'){
			response.setBody(RESPONSE_GCF_NOTBODY);
            response.setStatusCode(200);
		}
		else if(option == 'GCF_CAMBIOEMPLEADO' && status == 'OK'){
			response.setBody(RESPONSE_GCF_CAMBIOEMPLEADO);
            response.setStatusCode(200);
		}
        else if(option == 'CJ_Login' && status == 'OK'){
			response.setBody(RESPONSE_CJLOGIN);
			response.setStatusCode(200);
		}
        else if(option == 'CJ_LookUpList' && status == 'OK'){
			response.setBody(RESPONSE_CJLOOKUPLIST);
			response.setStatusCode(200);
		}
        else if(option == 'CJ_LookUp' && status == 'OK' ){
			response.setBody(RESPONSE_CJLOOKUP);
			response.setStatusCode(200);
		}
        else if(option == 'CJ_LookUpError' && status == 'OK' ){
			response.setBody(RESPONSE_CJLookUpError);
			response.setStatusCode(200);
		}
        else if(option == 'CJ_Marketing360' && status == 'OK'){
			response.setBody(RESPONSE_CJMARKETING);
			response.setStatusCode(200);
		}
        else if(option == 'GCF_JOBLEVEL' && status == 'OK'){
			response.setBody(RESPONSE_GCF_JOBLEVEL);
            response.setStatusCode(200);
		}else if(option == 'TEAMS_LOGIN' && status == 'OK'){
			response.setBody(RESPONSE_TEAMSAUTH);
            response.setStatusCode(200);
		}else if(option == 'TEAMS_GETUSERID' && status == 'OK'){
			response.setBody(RESPONSE_TEAMSGETUSERID);
            response.setStatusCode(200);
		}else if(option == 'TEAMS_GETURL' && status == 'OK'){
			response.setBody(RESPONSE_TEAMSGETURL);
            response.setStatusCode(200);
		}else if(option == 'HGMSURVEYID' && status == 'OK'){
			response.setBody(RESPONSE_HGMSURVEYID);
			response.setStatusCode(200);
		}
        else if(option== 'HGMCUSTOMER' && status == 'OK'){
			response.setBody(RESPONSE_HGMCUSTOMER);
			response.setStatusCode(200);
		}
         else if(option== 'HGMCUSTOMER_FW' && status == 'OK'){
			response.setBody(responsehgmcustomerfw);
			response.setStatusCode(200);
		}
        else if(option== 'CUSTOMERSURVEY' && status == 'OK'){
			response.setBody(RESPONSE_CUSTOMERSURVEY);
			response.setStatusCode(200);
		}
		else if(option== 'SURVEY_FC' && status == 'OK'){
			response.setBody(RESPONSE_SURVEY_FC);
			response.setStatusCode(200);
		}else if(option== 'BODY_TEAMS' && status == 'OK'){
			response.setBody(RESPONSE_BODY_TEAMS);
			response.setStatusCode(200);
		}else if(option== 'COBROWSING' && status == 'OK'){
			response.setBody(RESPONSE_COBROWSING_OK);
			response.setStatusCode(204);
		}else if(option== 'COBROWSING' && status == 'KO'){
			response.setBody(RESPONSE_COBROWSING_KO);
			response.setStatusCode(404);
		}

		if(status == 'KO' && option != 'CHANNELS'){
			response.setBody(RESPONSE_ERROR);
			response.setStatusCode(500); 
		}
		if(option == 'TRACEABILITY' && status == 'OK'){
			response.setBody(RESPONSE_TRACEABILITY);
            response.setStatusCode(200); 
		} 
		
		return response; 
	}
}