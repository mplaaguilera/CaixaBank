/**********************************************************************************************************************
Name:	  CIBE_CambioDivisas_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "cibe_cambioDivisas"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR                      DATE			Description
    1.0         SF - Integración con API's de Divisas               Jose Maria Fernandez        26/10/2022		Init version
    2.0         SF - Avoid Callout Constructor in Apex              Borja Lavesiera             07/03/2024		Second version
*******************************************************************************************************************/

public with sharing class CIBE_CambioDivisas_Controller {
  
    /**
     * @description   : Wrapper para poder manejar de forma óptima la respuesta de la llamada GET al servicio de Divisas
    */
    public class Response{
        @AuraEnabled
        public List<ResponseData> data;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public Integer statusCode;

    }

    /**
     * @description Cuerpo del JSON de la integración de Divisas
     */ 
    public class ResponseData{
        @AuraEnabled
        public CcyData ccyData;
        @AuraEnabled
        public ExchangeData exchangeData;
        @AuraEnabled
        public RangeData rangeData;
        @AuraEnabled
        public String decimalNumbers;	//2
        @AuraEnabled
        public String decimalRoundNumbers;	//4
        @AuraEnabled
        public String ccyGender;	//1
        @AuraEnabled
        public String correspondentBank;	//151
        @AuraEnabled
        public String ccyCountry;	//400
        @AuraEnabled
        public String isoCcyCode;	//840
        @AuraEnabled
        public String riskLetterCode;	//B
        @AuraEnabled
        public String validityDate;	//2022-04-25
        @AuraEnabled
        public String validityTime;	//2022-04-25
        @AuraEnabled
        public String validityHour;	//120000
        @AuraEnabled
        public String todayDate;	//2022-04-22
        @AuraEnabled
        public String tomorrowDate;	//2022-04-25
        @AuraEnabled
        public String dayAfterTomorrowDate;	//2022-04-26
        @AuraEnabled
        public String umeCcyIndicator;	//S
        @AuraEnabled
        public SignalsData signalsData;
    }

   
    /**
     * @description Cuerpo del JSON de la integración de Divisas
     */ 
    
    public class CcyData {
		public String ccyCode;	//103
		public String ccyDigits;	//46
		public String swiftCode;	//USD
		public String ccyCodeBE;	//840
		public String ccyShortName;	//DOL.USA.
		public String ccyLongName;	//DOLARES USA
	}


    
    /**
     * @description Cuerpo del JSON de la integración de Divisas
     */ 
    
	public class ExchangeData {
		public String fixingPurchaseExchange;	//1.0887
		public String fixingSaleExchange;	//1.0887
		public String fixingReutersExchange;	//1.0887
		public String standardPurchaseExchange;	//1.0887
		public String standardSaleExchange;	//1.0887
		public String exchangeOperator;	//D
		public String agreementIndicator;	//N
	}


    
    /**
     * @description Cuerpo del JSON de la integración de Divisas
     */ 
    
	public class RangeData {
		public String standardPurchaseRange;	//1
		public String standardSaleRange;	//1
		public String fixingPurchaseRange;	//1
		public String fixingSaleRange;	//1
	}


    
    /**
     * @description Cuerpo del JSON de la integración de Divisas
     */ 

	public class SignalsData {
		public String quotableSignal;	//N
		public String purchaseAllowedSignal;	//N
		public String saleAllowedSignal;	//N
		public String forcedExchangeSignal;	//N
		public String fx4cashCcySignal;	//N
	}

	

 /*****************************************************************   
  * Proposito:  Llamada al servicio de Divisas usando el numPerson del Cliente                                                           
    Parameters: [String numPerson, fechaRefresci, jsonBody]   
    Returns: [Wrapper Response]   
    Throws [Exceptions]: [optional]                                                          
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0             US Id           Jose María Fernandez           26-10-2022     Created    
    *****************************************************************/
    public static Response sendRequest(String jsonBody) {  
            Response responseWrapper = new Response();
        //Comprobamos que la llamada anterior al servicio y su respuesta con este identificador no tenga menos de 24 horas de diferencia.
            try {
                CBK_log.debug('Entering Parameter jsonBody:'+ jsonBody);     
                Map<String,String> mHeaders =  new  Map<String,String>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                reqWrapper.body = jsonBody;
                reqWrapper.intSetting = 'changeCurrency';
                reqWrapper.method = 'POST';
                reqWrapper.mHeaders =  mHeaders;
                reqWrapper.mUriParams = new  Map<String,string>();
                reqWrapper.mQueryParams = new  Map<String,string>();

                HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);                        
                HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, 'Int Divisas', 'changeCurrency');

                responseWrapper.statusCode = res.getStatusCode();
                responseWrapper.errorMessage = res.getStatus();

                if (responseWrapper.statusCode == 200) {
                    responseWrapper.data = (List<ResponseData>)JSON.deserialize(res.getBody(), List<ResponseData>.class);  
                } else{
				    throw new CBK_ServiceRestManager.BadResponseException(res.getBody(), res.getStatus(), res.getStatusCode());
                }
            }
            catch(DmlException e){
                responseWrapper.errorMessage = 'Ha habido un problema al ejecutar la integración';
            }
        return responseWrapper;
    }

 /*****************************************************************   
  * Proposito:  Obtención del Record Id desde el componente LWC y preparación de la llamada                                                           
    Parameters: [String numPerson, fechaRefresci, jsonBody]   
    Returns: [Wrapper Response]   
    Throws [Exceptions]: [optional]                                                          
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US Id            Jose María Fernandez           26-10-2022     Created 
    1.1            US841839         Borja Lavesiera                12/03/2024     Eliminar Http, HttpRequest y HttpResponse Constructor  
    *****************************************************************/
	@AuraEnabled
	public static List<CIBE_Divisas__c> getDivisas() {
        List<CIBE_Divisas__c> divisasList = new List<CIBE_Divisas__c>();
        Response responseFromRequest = new Response();
        String jsonResponse = 'jsonResponse';

        //Si la respuesta es correcta, actualizamos la fecha de refresco y el json de la cuenta.
        Map<String,Object> bodyPattern = new Map<String,Object>();
        bodyPattern.put('option',4);
        bodyPattern.put('requestType','D');
        String jsonSerialize = JSON.serialize(bodyPattern);
        responseFromRequest = sendRequest(jsonSerialize);

        if (responseFromRequest.data != null) {
            divisasList = jsonToDatabase(responseFromRequest.data);
        } else {
            //Si la llamada al servicio no es correcta, se lanza una excepción para que el usuario pueda verla en el componente.
            CBK_log.debug('Respuesta: ' + responseFromRequest.errorMessage);
            }
		return divisasList;
	}
    //Clase que contiene el cuerpo del JSON de la integración de Divisas
    public static List<CIBE_Divisas__c> jsonToDatabase(List<ResponseData> wrapperResponse){
        List<CIBE_Divisas__c> divisasList = new List<CIBE_Divisas__c>();     
        //Creamos un objeto de la clase ResponseData para poder deserializar el JSON de respuesta.
        //iteramos sobre el objeto ResponseData para obtener los datos de las divisas.
        for (ResponseData res : wrapperResponse ) { 
            //Creamos un objeto de la clase Divisas__c para poder insertarlo en la BBDD.
            CIBE_Divisas__c newDivisa = new CIBE_Divisas__c();
            if(res.ccyData.swiftCode!=null){newDivisa.CIBE_CodigoDivisa__c = res.ccyData.swiftCode;}
            if(res.ExchangeData.standardSaleExchange!=null){newDivisa.CIBE_DivisaBase__c = String.valueOf(res.ExchangeData.standardSaleExchange);}
            if(res.validityDate!=null){newDivisa.CIBE_FechaTipoCambio__c = Date.valueOf(res.validityDate);}
            if( res.ccyData.ccyShortName!=null){newDivisa.CIBE_NombreDivisa__c = res.ccyData.ccyShortName;}
            if(res.ExchangeData.fixingReutersExchange!=null){newDivisa.CIBE_TipoCambio__c = Decimal.valueOf(res.ExchangeData.fixingReutersExchange);}

            divisasList.add(newDivisa);
        }
        CBK_log.debug('Divisa a actualizar: ' + divisasList);
        return divisasList;
    }
}