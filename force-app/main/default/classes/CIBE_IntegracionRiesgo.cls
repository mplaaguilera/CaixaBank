/**********************************************************************************************************************
Name:	  IntegracionRiesgo
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR                      DATE			Description
    1.0         SF - Integración con API's de Riesgo                Jose Maria Fernandez        26/10/2022		Init version
    1.1         US470406                                            Alexandre Pérez             8/2/2023        Adaptación cambios
    1.2         DE88694                                             Borja Lavesiera             18/03/2024      Adaptación cambios 
***********************************************************************************************************************/
public with sharing class CIBE_IntegracionRiesgo {
  
    /**
     * @description   : Wrapper para poder manejar de forma óptima la respuesta de la llamada GET al servicio de Riesgo
    */
    public class Response{
        @AuraEnabled
        public ContractsWrapper responseDetalle;
        @AuraEnabled
        public TotalBalanceWrapperData responseAcumulado;
        @AuraEnabled
        public HoldingWrapper responseHolding;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String jsonResponse;
        @AuraEnabled
        public String jsonResponseDetalle;
        @AuraEnabled
        public Date fechaRefresco;
        @AuraEnabled
        public Integer errorCode;
        @AuraEnabled
        public Integer statusCode;
        @AuraEnabled
        public boolean comunicacionAgrupado=false;
        @AuraEnabled
        public boolean comunicacionDetalle=false;

    }


    
    /**
     * @description Cuerpo del JSON de la integración de Riesgo de Acumulado/Agrupado
     */
    public class TotalBalanceWrapperData {
        @AuraEnabled
        public List<TotalBalanceWrapper> totalBalance;
        
      
    }
    

    public class TotalBalanceWrapper {
        @AuraEnabled
        public BalanceWrapperList balance;
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public List<ProductWrapperAcumulado> products;
    }


    
  
    public class ProductWrapperAcumulado {
        @AuraEnabled
        public Integer productLevel;
        @AuraEnabled
        public Integer productId;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String productDetail;
        @AuraEnabled
        public List<BalanceWrapper> balance;
    }
    
    public class BalanceWrapper{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Double amount;
        @AuraEnabled
        public String ccy;
    }

    public class BalanceWrapperList{
        @AuraEnabled
        public list<BalanceWrapper> Balance;
    }
    
    

    /**
     * @description Cuerpo del JSON de la integración de Riesgo de Detalle
     */
   
    
    public class PaginationWrapper {
        @AuraEnabled
        public Integer pageKey;
        @AuraEnabled
        public Integer pageSize;
        @AuraEnabled
        public Map<String, String> links;
    }

    public class PaginationLinksWrapper {
        @AuraEnabled
        public String first;
        @AuraEnabled
        public String last;
        @AuraEnabled
        public String prev;
        @AuraEnabled
        public String next;
       
    
    }
    public class ContractsWrapper {
        @AuraEnabled
        public String ticketId;
        @AuraEnabled
        public String lastUpdated;
        @AuraEnabled
        public Double passiveBalance;
        @AuraEnabled
        public Double activeBalance;
        @AuraEnabled
        public Boolean isOnline;
        @AuraEnabled
        public List<ProductWrapperDetalle> Products;
        @AuraEnabled
        public List<PaginationWrapper> pagination;
        @AuraEnabled
        public List<OperativeServicesWrapper> operativeServices;  
    }
    
    public class ProductWrapperDetalle {
        @AuraEnabled
        public Integer productId;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public Double productBalance;
        @AuraEnabled
        public String productDetail;
        @AuraEnabled
        public List<ContractWrapperDetalle> Contracts;
    }
    
    public class ContractWrapperDetalle {
        @AuraEnabled
        public Integer contractId;
        @AuraEnabled
        public String internationalContract;
        @AuraEnabled
        public Integer area;
        @AuraEnabled
        public Integer modality;
        @AuraEnabled
        public Integer office;
        @AuraEnabled
        public String riskLine;
        @AuraEnabled
        public String CGEline;
        @AuraEnabled
        public String aplication;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Integer descriptionId;
        @AuraEnabled
        public String ccy;
        @AuraEnabled
        public String cancelDate;
        @AuraEnabled
        public String openingDate;
        @AuraEnabled
        public String dueDate;
        @AuraEnabled
        public String contractDescription;
        @AuraEnabled
        public Double risk;
        @AuraEnabled
        public Double unpaidAmount;
        @AuraEnabled
        public String expirationDate;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public list<wrapperIndicators> Indicators;
        @AuraEnabled
        public list<BalanceWrapper> Balance;
    }
    
    
    public class WrapperIndicators {
        string key;
        string value;
    }
    
    
    /**
     * @description Cuerpo del JSON de la integración de Riesgo de Holding
     */
   
     public class HoldingWrapper {
        @AuraEnabled
        public Integer customerId;
        @AuraEnabled
        public String customerName;
        @AuraEnabled
        public  List<HoldingBalanceWrapper> totalBalance;
        @AuraEnabled
        public List<HoldingCustomerWrapper> holdingCustomers;
     }
     
    public class HoldingBalanceWrapper {
        @AuraEnabled
        public List<BalanceWrapperRisk> balance;
        @AuraEnabled
        public Double cirbe;
        @AuraEnabled
        public Double guarantorRisk;
        @AuraEnabled
        public Double debtorRisk;
        @AuraEnabled
        public Double applications;
        @AuraEnabled
        public Double interdependence;
    }
    
    public class HoldingCustomerWrapper {
        @AuraEnabled
        public Integer customerId;
        @AuraEnabled
        public String customerName;
        @AuraEnabled
        public List<BalanceWrapperRisk> balanceDetail;
        @AuraEnabled
        public Double cirbe;
        @AuraEnabled
        public Double guarantorRisk;
        @AuraEnabled
        public Double debtorRisk;
        @AuraEnabled
        public Double applications;
        @AuraEnabled
        public Double interdependence;
        @AuraEnabled
        public List<HoldingProductWrapper> products;
    }
    
    public class HoldingProductWrapper {
        @AuraEnabled
        public Integer productLevel;
        @AuraEnabled
        public Integer productId;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public List<BalanceWrapperRisk> balance;
        @AuraEnabled
        public Double cirbe;
        @AuraEnabled
        public Double guarantorRisk;
        @AuraEnabled
        public Double debtorRisk;
        @AuraEnabled
        public Double applications;
        @AuraEnabled
        public Double interdependence;
    }

    public class BalanceWrapperRisk{
        @AuraEnabled
        public Double balance;
        @AuraEnabled
        public Double riskLine;
        @AuraEnabled
        public Double unpaid;
    }

    public class HttpRespError{
        @AuraEnabled
        public string code;
        @AuraEnabled
        public string codeDescription;
    }

    public class OperativeServicesWrapper{
        @AuraEnabled
        public integer id;
        @AuraEnabled
        public string serviceDescription;
        @AuraEnabled
        public string detail;
    }


    
    private static final String PARAM_CUSTOMERINTERNALID  = 'x-absis-customerInternalId';
    public static final String PARAM_RIESGO_AGRUPADO  = 'getProductsAgrupado';
    public static final String PARAM_RIESGO_DETALLADO  = 'getProductsDetalle';

    //public static final String PARAM_RIESGO_AGRUPADO  = 'Mock_Cuspos_Agrupado';
    //public static final String PARAM_RIESGO_DETALLADO  = 'Mock_Cuspos_Detalle';


    public static final String PARAM_RIESGO_TODOS  = 'Todos';

    public static final String RESPONSE_PRODUCTS_GROUPED =	'{"totalBalance":[{"balance":{},"productType":"S","products":[{"productLevel":35,"productId":10214,"productDescription":"Tarjetaprepago","balance":[]}]},{"balance":{"balance":[{"type":"Balance","amount":24941.2,"ccy":"200"},{"type":"Var","amount":900,"ccy":"200"},{"type":"Withheld","amount":600,"ccy":"200"}]},"productType":"R","products":[{"productLevel":35,"productId":15890,"productDescription":"Renta variable","balance":[{"type":"Balance","amount":8534.61,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"},{"type":"Withheld","amount":200,"ccy":"200"}]},{"productLevel":35,"productId":10158,"productDescription":"Cuentas a la vista","balance":[{"type":"Balance","amount":24941.2,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"},{"type":"Withheld","amount":200,"ccy":"200"}]},{"productLevel":35,"productId":10063,"productDescription":"Planes Pensiones","balance":[{"type":"Balance","amount":28174.12,"ccy":"200"}]}]},{"balance":{"balance":[{"type":"Disposed","amount":154.5,"ccy":"200"},{"type":"Risk","amount":1800.51,"ccy":"200"},{"type":"Unpaid","amount":0,"ccy":"200","passiveBalance":0},{"type":"Var","amount":300,"ccy":"200"}]},"productType":"I","products":[{"productLevel":35,"productId":10012,"productDescription":"Descubierto","balance":[{"type":"Disposed","amount":0,"ccy":"200"},{"type":"Risk","amount":300.51,"ccy":"200"},{"type":"Unpaid","amount":0,"ccy":"200","passiveBalance":0},{"type":"Var","amount":300,"ccy":"200"}]},{"productLevel":35,"productId":10010,"productDescription":"Tarjetas","balance":[{"type":"Disposed","amount":154.5,"ccy":"200"},{"type":"Risk","amount":1500,"ccy":"200"},{"type":"Unpaid","amount":0,"ccy":"200","passiveBalance":0},{"type":"Var","amount":300,"ccy":"200"}]}]}]}';
	public static final String RESPONSE_PRODUCTS_DETAIL = '{"passiveBalance":24941.2,"activeBalance":154.5,"Products":[{"productId":15890,"productDescription":"Renta variable","productN20Id":0,"productN20Description":"","productBalance":8534.61,"Contracts":[]},{"productId":10214,"productDescription":"Tarjeta prepago","productN20Id":0,"productN20Description":"","productBalance":2.85,"Contracts":[]},{"productId":10158,"productDescription":"Cuentas a la vista","productN20Id":0,"productN20Description":"Cuenta corriente","productBalance":24941.2,"Contracts":[{"contractId":843,"area":1,"modality":1,"office":4746,"aplication":"1","descriptionId":10682,"ccy":"200","country":"ES","openingDate":"2004-04-28","risk":0,"unpaidAmount":0,"Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":18004.39,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"},{"type":"Withheld","amount":200,"ccy":"200"}]},{"contractId":2194,"area":1,"modality":2,"office":180,"aplication":"1","descriptionId":10606,"ccy":"200","country":"ES","openingDate":"1995-05-18","risk":0,"unpaidAmount":0,"Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"N"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":0,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"},{"type":"Withheld","amount":200,"ccy":"200"}]}]},{"productId":10063,"productDescription":"Planes Pensiones","productN20Id":0,"productN20Description":"","productBalance":28174.12,"Contracts":[]},{"productId":10012,"productDescription":"Descubierto","productN20Id":0,"productN20Description":"","productBalance":0,"Contracts":[]},{"productId":10010,"productDescription":"Tarjetas","productN20Id":0,"productN20Description":"","productBalance":154.5,"Contracts":[{"contractId":272795,"area":17,"modality":14,"office":9612,"aplication":"121","descriptionId":2047,"ccy":"200","country":"ES","openingDate":"2015-01-27","risk":1500,"unpaidAmount":0,"expirationDate":"2020-02-07","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"30"}],"Balance":[{"type":"Limit","amount":1500,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":321.47,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"}]}]},{"productId":10158,"productDescription":"Cuentas a la vista","productN20Id":10149,"productN20Description":"Cuenta Corriente","productBalance":288.57,"Contracts":[{"contractId":2100790350000189700,"area":0,"modality":20,"office":7900,"aplication":"0","descriptionId":24002,"ccy":"200","country":"MA","openingDate":"2015-01-27","risk":4562.22,"unpaidAmount":200,"expirationDate":"2020-02-07","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"30"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":4562.22,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"}]}]}]}';
	

    /*****************************************************************   
  * Proposito:  Obtención del Record Id desde el componente LWC y preparación de la llamada                                                           
    Parameters: [String numPerson, fechaRefresci, jsonBody]   
    Returns: [Wrapper Response]   
    Throws [Exceptions]: [optional]                                                          
    Historial
    --------    
    VERSION        USER_STORY           AUTHOR                         DATE           Description   
    1.0             US Id               Jose María Fernandez           26-10-2022     Created
    1.1             US470406            Alexandre Pérez                8/2/2023       Adaptación cambios 
    1.2             mejoras(Sin US)     Alexandre Pérez                6/7/2023       Ajustes para jsons grandes
    1.3             US913542            Borja Lavesiera                25/06/2024     Restyling LWC detalle por producto con paginación
    *****************************************************************/
	@AuraEnabled
	public static Response getRiesgoController(Id recordId,String tipoDeRiesgo, String productId, String pageKey) {
        CBK_log.debug('Entering <Method getRiesgoController>: '+ 'Parameter recordId: ' + recordId+ 'Parameter tipoDeRiesgo: ' + tipoDeRiesgo+ ' Parameter productId: ' + productId +' Parameter pageKey: ' + pageKey,LoggingLevel.DEBUG);
        Response responseFromRequest = new Response();
        Account accForRiesgos = new Account();
        List<Object> detalle = new List<Object> {'Detalle ', DateTime.now() };
        Map<String, String> mapError = new Map<String, String>();
        String jsonResponse = '';
       
		if (recordId != null) {
            try {
                accForRiesgos = [SELECT AV_NumPerso__c, CIBE_FechaRefrescoRiesgoAgrupado__c, CIBE_JsonRiesgoAgrupado__c, 
                                    CIBE_FechaRefrescoRiesgoDetallado__c, CIBE_JsonRiesgoDetallado__c
                                FROM Account Where Id = :recordId];
                if(tipoDeRiesgo==PARAM_RIESGO_AGRUPADO || tipoDeRiesgo==PARAM_RIESGO_TODOS){
                    //Obtenemos la cuenta con la que llamaremos a la integraciónd de Riesgos para obtener los balances y el riesgo del terminal financiero.
                    responseFromRequest = retrieveCustomerRisk(accForRiesgos, accForRiesgos.CIBE_FechaRefrescoRiesgoAgrupado__c,PARAM_RIESGO_AGRUPADO);
 
                }
                if(tipoDeRiesgo==PARAM_RIESGO_DETALLADO && productId != null && pageKey!=null){
                    // Llamada específica para obtener contratos de un producto particular y paginado
                    responseFromRequest = retrieveContractsForProduct(accForRiesgos.AV_NumPerso__c, productId, pageKey);
                }
            }catch(Exception e){
                mapError.put('msg','Error al obtener la cuenta con el recordId: ' + recordId); 
                mapError.put('type','QueryException'); 
                CBK_Log.error(recordId, e, mapError, detalle);
                responseFromRequest.errorMessage = 'Error al obtener los datos de la cuenta';
            }

            if(responseFromRequest.errorMessage == null && (responseFromRequest.comunicacionAgrupado || responseFromRequest.comunicacionDetalle)) {
                if((tipoDeRiesgo==PARAM_RIESGO_AGRUPADO || tipoDeRiesgo == PARAM_RIESGO_TODOS) && responseFromRequest.comunicacionAgrupado){
                    //si supera el tamaño máximo no guardamos fecha para que refresque siempre que entre ya que no tendremos los datos necesarios para mostrar sin integrarnos y truncamos 
                    if(responseFromRequest.jsonResponse.length() <= 131072){
                        accForRiesgos.CIBE_FechaRefrescoRiesgoAgrupado__c = Date.today();
                        //Blanqueamos campo para posterior integración por producto
                        accForRiesgos.CIBE_FechaRefrescoRiesgoDetallado__c = null;
                        accForRiesgos.CIBE_JsonRiesgoDetallado__c = '';
                        accForRiesgos.CIBE_JsonRiesgoAgrupado__c =responseFromRequest.jsonResponse;
                    } else {
                        accForRiesgos.CIBE_JsonRiesgoAgrupado__c = responseFromRequest.jsonResponse.subString(0, 131072);
                    }
                    
                }
                if((tipoDeRiesgo==PARAM_RIESGO_DETALLADO || tipoDeRiesgo == PARAM_RIESGO_TODOS) && responseFromRequest.comunicacionDetalle){
                    if(responseFromRequest.jsonResponseDetalle.length() <= 131072){
                        accForRiesgos.CIBE_FechaRefrescoRiesgoDetallado__c = Date.today();
                        accForRiesgos.CIBE_JsonRiesgoDetallado__c = responseFromRequest.jsonResponseDetalle;
                    } else {
                        accForRiesgos.CIBE_JsonRiesgoDetallado__c = responseFromRequest.jsonResponseDetalle.subString(0, 131072);
                    }
              
                }
                update accForRiesgos;
            } else if(responseFromRequest.errorMessage != null) {
                //Si la llamada al servicio no es correcta, se lanza una excepción para que el usuario pueda verla en el componente.
                throw new AuraHandledException('Error: ' + responseFromRequest.errorMessage);
            }
        }
        CBK_log.debug('Exiting <Method getRiesgosProducts>: '+ responseFromRequest,LoggingLevel.DEBUG);
		return responseFromRequest;	
	}
     /*****************************************************************   
  * Proposito:  Llamada al servicio de Riesgo (Agrupado) usando el numPerson del Cliente                                                           
    Parameters: [String numPerson, fechaRefresci, jsonBody]   
    Returns: [Wrapper Response]   
    Throws [Exceptions]: [optional]                                                          
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0             US Id           Jose María Fernandez           26-10-2022     Created    
    1.1             US470406        Alexandre Pérez                8/2/2023       Adaptación cambios
    1.2             US              Borja Lavesiera                19/12/2023     Cambios body y Framework Integration
    1.3             US913542        Borja Lavesiera                25/06/2024     Restyling LWC detalle por producto con paginación
    *****************************************************************/
	public static Response retrieveCustomerRisk(Account accForRiesgos, DateTime fechaRefresco, String tipoDeRiesgo){
        Response wrapper = new Response();
		if(accForRiesgos.AV_NumPerso__c != null){
            Map<String, String> mapError = new Map<String, String>();
        
			if(fechaRefresco == null 
            || AV_AppUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24){
				Map<String,string> mHeaders =  new  Map<String,string>();
				mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
				Long longUser = long.valueOf(accForRiesgos.AV_NumPerso__c);
				String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
				mHeaders.put(PARAM_CUSTOMERINTERNALID,hexDigest);
                string metodo = 'GET';
                CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                        reqWrapper.intSetting = PARAM_RIESGO_AGRUPADO;
                        reqWrapper.method = metodo;
                        reqWrapper.mHeaders =  mHeaders;
                        reqWrapper.mUriParams = new  Map<String,string>();
                        reqWrapper.mQueryParams = new  Map<String,string>();

                HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);
                HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req,accForRiesgos.AV_NumPerso__c,PARAM_RIESGO_AGRUPADO);

                if(res.getStatusCode() == 200) {
                TotalBalanceWrapperData resp = (TotalBalanceWrapperData)JSON.deserialize(res.getBody(),TotalBalanceWrapperData.class);
                wrapper.responseAcumulado = resp;
                wrapper.comunicacionAgrupado = true;
                wrapper.jsonResponse = res.getBody();
                CBK_log.debug('Json Response Agrupado:'+wrapper.jsonResponse, logginglevel.DEBUG);
                } else if(res.getStatusCode() == 204){
                    wrapper.errorMessage = 'El cliente no tiene datos';
                } else {
                    wrapper.errorMessage = 'Ha ocurrido un error inesperado, contacte con su administrador';
                }
			} else  {
                    TotalBalanceWrapperData resp = (TotalBalanceWrapperData)JSON.deserialize(accForRiesgos.CIBE_JsonRiesgoAgrupado__c,TotalBalanceWrapperData.class);
                    wrapper.responseAcumulado = resp;
                    wrapper.jsonResponse = accForRiesgos.CIBE_JsonRiesgoAgrupado__c;
                    //para evitar que vuelva a escribir en BBDD si está ya recuperando los datos sin la integracion
                    wrapper.comunicacionAgrupado = false;
                    }
		} else {
            wrapper.errorMessage = 'El cliente no tiene NumPerso AV';
        }
		return wrapper;
	}
    /*****************************************************************   
  * Proposito:  Llamada al servicio de Riesgo (Detalle) a través del productId y Pagekey recuperado en LWC                                                        
    Parameters: [String numPerson, productId, pageKey]   
    Returns: [Wrapper Response]   
    Throws [Exceptions]: [optional]                                                          
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0             US913542        Borja Lavesiera                25/06/2024     Restyling LWC detalle por producto con paginación
    *****************************************************************/

    @AuraEnabled
    public static Response retrieveContractsForProduct(String numPerso, String productId, String pageKey) {
        //Account accForRiesgos, DateTime fechaRefresco, String tipoDeRiesgo
        Response wrapper = new Response();
        if(numPerso != null && productId != null){
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

            Long longUser = long.valueOf(numPerso);
            String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
            mHeaders.put(PARAM_CUSTOMERINTERNALID, hexDigest);
            
            String body ='{"isCancelledContracts":false,"pageKey":"[PAGEKEY]","pageSize":"200","userType":"N","productId":"[PRODUCT]","international":"S","numper":"[NUMPER]"}';
            body = body.replace('[NUMPER]', hexDigest);
            body = body.replace('[PRODUCT]', productId);
            body = body.replace('[PAGEKEY]', pageKey);

            CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                        reqWrapper.body = body;
                        reqWrapper.intSetting = PARAM_RIESGO_DETALLADO;
                        reqWrapper.method = 'POST';
                        reqWrapper.mHeaders =  mHeaders;
                        reqWrapper.mUriParams = new  Map<String,string>();
                        reqWrapper.mQueryParams = new  Map<String,string>();

            HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);
            HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, numPerso,PARAM_RIESGO_DETALLADO);
            if(res.getStatusCode() == 200) {
                ContractsWrapper resp = (ContractsWrapper)JSON.deserialize(res.getBody(), ContractsWrapper.class);
                wrapper.responseDetalle = resp;
                wrapper.comunicacionDetalle = true;
                wrapper.jsonResponseDetalle = res.getBody();
                if (resp.products == null || resp.products.isEmpty()) {
                    wrapper.errorMessage = 'No se han encontrado contratos para el producto solicitado.';
                }
                CBK_log.debug('Json Response Detalle:'+wrapper.jsonResponseDetalle, LoggingLevel.INFO);
            } else if(res.getStatusCode() == 204){
                wrapper.errorMessage = 'El cliente no tiene datos';
            } else {
                wrapper.errorMessage = 'Ha ocurrido un error inesperado, contacte con su administrador';
            }
        } else {
            wrapper.errorMessage = 'El cliente no tiene NumPerso AV';
        }
        return wrapper;
    }
}