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
	

	public static final String RESPONSE_EEFF = '{"FinancialStatements":[{"stateId":18450436,"personId":"A03033164","company":1,"financialYear":20210630,"class":"I7","type":"AN","numberDays":365,"auditOpinion":1,"currency":"EUR","units":"0","numberEmployees":44,"state":"A","source":"C","movementNumer":0,"yearMonth":202106,"inconsistencyFlag":"","cnae":"","incoherent":"","balanceFlag":"S","incomeStatementFlag":"S","lastLetter":"4"}],"Settlements":[],"minorDate":20210630,"majorDate":20210630,"filterType":2,"minorEeff":18450436,"majorEeff":18450436,"nextFlag":"S","previousFlag":"N"}';
	public static final String RESPONSE_EEFF_KO = '{"detail":"Error de aplicacion GBR00006 - 00001","stackTrace":[],"type":"Finance/internal-server-error-exception","title":"Error de aplicacion","status":500}';

    public static final String RESPONSE_EEFF_DETAILS = '{"summary":{"financialStatement":{"stateId":18450436,"personId":"A03033164","financialYear":20210630,"class":"I7","type":"AN","numberDays":365,"auditOpinion":1,"currency":"EUR","units":"0","numberEmployees":44,"source":"C","yearMonth":202106,"cnae":"","descriptionCnae":"","incoherent":"N","balanceFlag":"S","incomeStatementFlag":"S","highDate":20220128,"highHour":"12:19:44","highOffice":9862,"highUser":0,"modificationDate":0,"modificationHour":"","modificationOffice":0,"modificationUser":0,"companyName":"INDUSTRIAS BLANCO TIO","inactiveCompany":"N","sourceCode":""},"nonCurrentAsset":4211948,"currentAsset":19587525,"totalAsset":31949184,"netWorth":8149711,"nonCurrentLiability":9007823,"currentLiability":22941361,"totalLiability":31949184,"sales":57301687,"balanceSheetResult":1166868,"resultIncomeStatement":1166868,"numberInhabitants":0},"summaryRSE":{"year":"2014","size":"Mas de 50 millones","cnaeDt":"G467","cnaeAlp":"467","cnaeLit":"Otro comercio al por mayor especializado"},"Inconsistencies":[],"BalanceSheetInconsistencies":[],"IncomeStatementInconsistencies":[],"Warnings":[],"BalanceSheets":[{"financialYear":20210630,"inconsistencyFlag":"","currency":"EUR","units":"0","cnae":"","descriptionCnae":"","numberDays":365,"numberEmployees":44,"source":"C","BalanceSheetItems":[{"code":"C0323000  I7        BL","amount":9405,"percentageFlag":"S","percentage":29},{"code":"C0312000  I7        BL","amount":3164,"percentageFlag":"S","percentage":9},{"code":"C0127000  I7        BL","amount":495,"percentageFlag":"S","percentage":15}]}],"SettlementSheets":[],"IncomeStatements":[{"financialYear":20210630,"inconsistencyFlag":"","currency":"EUR","units":"0","IncomeStatementItems":[{"code":"C0491000  I7        CR","amount":1576783,"percentageFlag":"S","percentage":2},{"code":"C0408000  I7        CR","amount":157,"percentageFlag":"S","percentage":2},{"code":"C0999401  I7        CR","amount":657,"percentageFlag":"S","percentage":2},{"code":"C0419000  I7        CR","amount":157,"percentageFlag":"S","percentage":2},{"code":"C0495000  I7        CR","amount":116,"percentageFlag":"S","percentage":2},{"code":"C0401000  I7        CR","amount":57301687,"percentageFlag":"S","percentage":100},{"code":"C0405000  I7        CR","amount":140036,"percentageFlag":"S","percentage":0}]}],"Remnants":[],"Ratios":[{"financialYear":20210630,"currency":"EUR","units":"2","RatioItems":[{"code":"RAT EDF   I7        RT","amount":3,"percentageFlag":"N"},{"code":"RAT SCH   I7        RT","amount":8,"percentageFlag":"S"}]}],"RatiosSE":[{"RatioSEItems":[]}]}';

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