/**********************************************************************************************************************
Name:	  CIBE_MockMultiCallout_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de integraciones para multillamada
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   					DATE			Description
	1.0			US454676		Borja Lavesiera					04/10/2023		Init Version
***********************************************************************************************************************/
@isTest
public class CIBE_MockMultiCallout_Test implements HttpCalloutMock {
	
    /**
	 * Option 1: normal execution
	 * Option 2: exception in execution
	 * Option 3: return error message in body response
	*/
	private String option1;
	private String option2;
	private String req1;
	private String req2;
	private String status;
	
	
	public CIBE_MockMultiCallout_Test(String option1, String req1, String option2, String req2, String status) {
		this.option1 = option1;
		this.option2 = option2;
		this.req1 = req1;
		this.req2 = req2;
		this.status = status;
	}
	

	public static final String RESPONSE_EEFF = '{"FinancialStatements":[{"stateId":12360361,"personId":"P0301400H","company":1,"financialYear":2021,"class":"LI","type":"DF","numberDays":365,"auditOpinion":0,"currency":"EUR","units":"0","numberEmployees":0,"state":"A","source":"O","movementNumer":1,"yearMonth":2021,"inconsistencyFlag":"","cnae":"","incoherent":"S","balanceFlag":"N","incomeStatementFlag":"N","lastLetter":"H"}],"Settlements":[],"minorDate":2021,"majorDate":2021,"filterType":2,"minorEeff":10096292,"majorEeff":10096292,"nextFlag":"S","previousFlag":"N"}';
	public static final String RESPONSE_EEFF_KO = '{"detail":"Error de aplicacion GBR00006 - 00001","stackTrace":[],"type":"Finance/internal-server-error-exception","title":"Error de aplicacion","status":500}';

	public static final String RESPONSE_EEFF_DETAILS = '{"summary":{"financialStatement":{"stateId":12360361,"personId":"P0301400H","financialYear":20151231,"class":"I7","type":"PR","numberDays":365,"auditOpinion":0,"currency":"EUR","units":"0","numberEmployees":213,"source":"Fuente Test","yearMonth":201512,"cnae":"Test CNAE","descriptionCnae":"","incoherent":"N","balanceFlag":"S","incomeStatementFlag":"S","highDate":20160210,"highHour":"15:29:21","highOffice":8681,"highUser":36323,"modificationDate":0,"modificationHour":"","modificationOffice":0,"modificationUser":0,"companyName":"SERV.EXTINC.INCENDIOS,SALVAMEN AYTO.ALICANTE","inactiveCompany":"N","sourceCode":""},"nonCurrentAsset":14018375,"currentAsset":45796335,"totalAsset":103015131,"netWorth":43200420,"nonCurrentLiability":84541052,"currentLiability":18474078,"totalLiability":103015131,"sales":76658641,"balanceSheetResult":7238104,"resultIncomeStatement":7238104,"numberInhabitants":0},"summaryRSE":{"year":"","size":"","cnaeDt":"","cnaeAlp":"","cnaeLit":""},"Inconsistencies":[],"BalanceSheetInconsistencies":[],"IncomeStatementInconsistencies":[],"Warnings":[],"BalanceSheets":[{"financialYear":2020,"inconsistencyFlag":"S","currency":"EUR","units":"0","cnae":"","descriptionCnae":"","numberDays":365,"numberEmployees":0,"source":"O","BalanceSheetItems":[{"code":"C0491000  LI        BL","amount":1000,"percentageFlag":"N","percentage":0},{"code":"C0495000  LI        BL","amount":2000,"percentageFlag":"N","percentage":0},{"code":"C0401000  LI        BL","amount":7564457,"percentageFlag":"N","percentage":0},{"code":"C0405000  LI        BL","amount":4000,"percentageFlag":"N","percentage":0},{"code":"C0323000  LI        BL","amount":5000,"percentageFlag":"N","percentage":0},{"code":"C0312000  LI        BL","amount":6000,"percentageFlag":"N","percentage":0},{"code":"C0127000  LI        BL","amount":7000,"percentageFlag":"N","percentage":0}]}],"SettlementSheets":[],"IncomeStatements":[{"financialYear":2021,"inconsistencyFlag":"S","currency":"EUR","units":"0","IncomeStatementItems":[{"code":"NODATO01  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0301000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0302000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0303000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0304000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0305000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0306000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0307000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0308000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0309000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0310000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0311000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0312000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0313000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0314000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0315000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0316000  LI        CR","amount":0,"percentageFlag":"N","percentage":0}]},{"financialYear":2020,"inconsistencyFlag":"N","currency":"EUR","units":"0","IncomeStatementItems":[{"code":"NODATO01  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0301000  LI        CR","amount":127120844,"percentageFlag":"N","percentage":0},{"code":"C0302000  LI        CR","amount":71352042,"percentageFlag":"N","percentage":0},{"code":"C0303000  LI        CR","amount":29558445,"percentageFlag":"N","percentage":0},{"code":"C0304000  LI        CR","amount":41576763,"percentageFlag":"N","percentage":0},{"code":"C0305000  LI        CR","amount":216833,"percentageFlag":"N","percentage":0},{"code":"C0306000  LI        CR","amount":0,"percentageFlag":"N","percentage":0},{"code":"C0307000  LI        CR","amount":51134519,"percentageFlag":"N","percentage":0},{"code":"C0308000  LI        CR","amount":36877944,"percentageFlag":"N","percentage":0},{"code":"C0309000  LI        CR","amount":117265,"percentageFlag":"N","percentage":0},{"code":"C0310000  LI        CR","amount":14139309,"percentageFlag":"N","percentage":0},{"code":"C0311000  LI        CR","amount":-239132,"percentageFlag":"N","percentage":0},{"code":"C0312000  LI        CR","amount":147577499,"percentageFlag":"N","percentage":0},{"code":"C0313000  LI        CR","amount":51884463,"percentageFlag":"N","percentage":0},{"code":"C0314000  LI        CR","amount":16970101,"percentageFlag":"N","percentage":0},{"code":"C0315000  LI        CR","amount":78722934,"percentageFlag":"N","percentage":0},{"code":"C0316000  LI        CR","amount":-1,"percentageFlag":"N","percentage":0}]}],"Remnants":[],"Ratios":[{"financialYear":20151231,"currency":"EUR","units":"0","RatioItems":[{"code":"RAT EDF  I7        RT","amount":18700,"percentageFlag":"N"},{"code":"RAT SCH   I7        RT","amount":5678,"percentageFlag":"S"},{"code":"RAT DEF   I7        RT","amount":44,"percentageFlag":"S"}]}],"RatiosSE":[{"RatioSEItems":[]}]}';
	public static final String RESPONSE_EEFF_DETAILS_KO = '{"detail":"Error de aplicacion getDetalleEstadosFinancieros - An A2ConnectorCheckedException object has been received in the response: A2ConnectorError [errorCode=INVOCATION_ERROR, errorMessage=es.lacaixa.absis.arch20.service.as.http.exceptions.OpenServicesSIInvokerException, instance=SRV51_0301, requestId=b613cf7e-bd73-433b-89c4-6390b1ac3150, errorData=null]","stackTrace":[],"type":"Finance/internal-server-error-exception","title":"Error de aplicaci�n","status":500}';

	public HTTPResponse respond(HTTPRequest request) {
		//Response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		//Check Request to make different callout
		if (request.getEndpoint() == 'CIBE_getEeFF') {
			if(option1 == 'EEFF' && status == 'OK'){
				response.setBody(RESPONSE_EEFF);
				response.setStatusCode(200); 
			} else if(option1 == 'EEFF' && status == 'KO'){
				response.setBody(RESPONSE_EEFF_KO);
				response.setStatusCode(500); 
			}
		} else if (request.getEndpoint() == 'CIBE_getEeFF_Details') {
			if(option2 == 'EEFF_DETAILS' && status == 'OK'){
				response.setBody(RESPONSE_EEFF_DETAILS);
				response.setStatusCode(200); 
			} else if(option2 == 'EEFF_DETAILS' && status == 'KO'){
				response.setBody(RESPONSE_EEFF_DETAILS_KO);
				response.setStatusCode(500); 
			}
		}
	return response;
    }
}