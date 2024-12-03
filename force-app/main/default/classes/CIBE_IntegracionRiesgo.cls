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
    1.1             US470406                                        Alexandre Pérez                8/2/2023       Adaptación cambios
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
        @AuraEnabled
        public list<operativeServicesWrapper> operativeServices;
      
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
        public list<BalanceWrapper> balance;
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
        public String description;
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
        public string productDetail;
    }


    
    private static final String PARAM_CUSTOMERINTERNALID  = 'x-absis-customerInternalId';
    public static final String PARAM_RIESGO_AGRUPADO  = 'getProductsAgrupado';
    public static final String PARAM_RIESGO_DETALLADO  = 'getProductsDetalle';

    //public static final String PARAM_RIESGO_AGRUPADO  = 'CIBE_getRiesgosAgrupado_Mock';
    //public static final String PARAM_RIESGO_DETALLADO  = 'CIBE_getRiesgosDetalle_Mock';


    public static final String PARAM_RIESGO_TODOS  = 'Todos';

    public static final String RESPONSE_PRODUCTS_GROUPED =	'{"totalBalance":[{"balance":{},"productType":"S","products":[{"productLevel":35,"productId":10214,"productDescription":"Tarjetaprepago","balance":[]}]},{"balance":{"balance":[{"type":"Balance","amount":24941.2,"ccy":"200"},{"type":"Var","amount":900,"ccy":"200"},{"type":"Withheld","amount":600,"ccy":"200"}]},"productType":"R","products":[{"productLevel":35,"productId":15890,"productDescription":"Renta variable","balance":[{"type":"Balance","amount":8534.61,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"},{"type":"Withheld","amount":200,"ccy":"200"}]},{"productLevel":35,"productId":10158,"productDescription":"Cuentas a la vista","balance":[{"type":"Balance","amount":24941.2,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"},{"type":"Withheld","amount":200,"ccy":"200"}]},{"productLevel":35,"productId":10063,"productDescription":"Planes Pensiones","balance":[{"type":"Balance","amount":28174.12,"ccy":"200"}]}]},{"balance":{"balance":[{"type":"Disposed","amount":154.5,"ccy":"200"},{"type":"Risk","amount":1800.51,"ccy":"200"},{"type":"Unpaid","amount":0,"ccy":"200","passiveBalance":0},{"type":"Var","amount":300,"ccy":"200"}]},"productType":"I","products":[{"productLevel":35,"productId":10012,"productDescription":"Descubierto","balance":[{"type":"Disposed","amount":0,"ccy":"200"},{"type":"Risk","amount":300.51,"ccy":"200"},{"type":"Unpaid","amount":0,"ccy":"200","passiveBalance":0},{"type":"Var","amount":300,"ccy":"200"}]},{"productLevel":35,"productId":10010,"productDescription":"Tarjetas","balance":[{"type":"Disposed","amount":154.5,"ccy":"200"},{"type":"Risk","amount":1500,"ccy":"200"},{"type":"Unpaid","amount":0,"ccy":"200","passiveBalance":0},{"type":"Var","amount":300,"ccy":"200"}]}]}]}';
	public static final String RESPONSE_PRODUCTS_DETAIL = '{"passiveBalance":24941.2,"activeBalance":154.5,"Products":[{"productId":15890,"productDescription":"Renta variable","productN20Id":0,"productN20Description":"","productBalance":8534.61,"Contracts":[]},{"productId":10214,"productDescription":"Tarjeta prepago","productN20Id":0,"productN20Description":"","productBalance":2.85,"Contracts":[]},{"productId":10158,"productDescription":"Cuentas a la vista","productN20Id":0,"productN20Description":"Cuenta corriente","productBalance":24941.2,"Contracts":[{"contractId":843,"area":1,"modality":1,"office":4746,"aplication":"1","descriptionId":10682,"ccy":"200","country":"ES","openingDate":"2004-04-28","risk":0,"unpaidAmount":0,"Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":18004.39,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"},{"type":"Withheld","amount":200,"ccy":"200"}]},{"contractId":2194,"area":1,"modality":2,"office":180,"aplication":"1","descriptionId":10606,"ccy":"200","country":"ES","openingDate":"1995-05-18","risk":0,"unpaidAmount":0,"Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"N"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":0,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"},{"type":"Withheld","amount":200,"ccy":"200"}]}]},{"productId":10063,"productDescription":"Planes Pensiones","productN20Id":0,"productN20Description":"","productBalance":28174.12,"Contracts":[]},{"productId":10012,"productDescription":"Descubierto","productN20Id":0,"productN20Description":"","productBalance":0,"Contracts":[]},{"productId":10010,"productDescription":"Tarjetas","productN20Id":0,"productN20Description":"","productBalance":154.5,"Contracts":[{"contractId":272795,"area":17,"modality":14,"office":9612,"aplication":"121","descriptionId":2047,"ccy":"200","country":"ES","openingDate":"2015-01-27","risk":1500,"unpaidAmount":0,"expirationDate":"2020-02-07","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"30"}],"Balance":[{"type":"Limit","amount":1500,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":321.47,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"}]}]},{"productId":10158,"productDescription":"Cuentas a la vista","productN20Id":10149,"productN20Description":"Cuenta Corriente","productBalance":288.57,"Contracts":[{"contractId":2100790350000189700,"area":0,"modality":20,"office":7900,"aplication":"0","descriptionId":24002,"ccy":"200","country":"MA","openingDate":"2015-01-27","risk":4562.22,"unpaidAmount":200,"expirationDate":"2020-02-07","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"30"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":4562.22,"ccy":"200"},{"type":"Var","amount":300,"ccy":"200"}]}]}]}';
	

 /*****************************************************************   
  * Proposito:  Llamada al servicio de Riesgo usando el numPerson del Cliente                                                           
    Parameters: [String numPerson, fechaRefresci, jsonBody]   
    Returns: [Wrapper Response]   
    Throws [Exceptions]: [optional]                                                          
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0             US Id           Jose María Fernandez           26-10-2022     Created    
    1.1             US470406        Alexandre Pérez                8/2/2023       Adaptación cambios
    *****************************************************************/
   
	public static Response retrieveCustomerRisk(Account accForRiesgos, DateTime fechaRefresco, String tipoDeRiesgo){
        Response wrapper = new Response();
		if(accForRiesgos.AV_NumPerso__c != null){
			Http http = new Http(); //Temporal hasta que se cambie el framework de integraciones
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();

            List<Object> detalle = new List<Object> {'Detalle ', DateTime.now() };
            Map<String, String> mapError = new Map<String, String>();
        
			if(fechaRefresco == null 
            || AV_AppUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24){
				Map<String,string> mHeaders =  new  Map<String,string>();
				mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
                
                //mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');

				Long longUser = long.valueOf(accForRiesgos.AV_NumPerso__c);
				String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
				mHeaders.put(PARAM_CUSTOMERINTERNALID,hexDigest);
                string metodo = tipoDeRiesgo == PARAM_RIESGO_DETALLADO ? 'POST' : 'GET';
                string body ='';
                if(tipoDeRiesgo != PARAM_RIESGO_AGRUPADO){
                    body = '{"userType":"N","productId":"","isCancelledContracts":true}';
                }
                try {
                req  = CBK_HttpServiceIntegration.getRequest(body,tipoDeRiesgo, metodo, mHeaders);
                res = CBK_HttpServiceIntegration.callHttpService(req);   
                //res = http.send(req);
                }catch(Exception e){
                    System.debug('Error: ' + e.getMessage());
                    system.debug(res);
                    mapError.put('msg','Error al obtener la respuesta HttpResponse'); 
                    mapError.put('type','RestException'); 
                    wrapper.errorMessage = 'Error al realizar la comunicación con CLI';
                    wrapper.errorCode = res.getStatusCode();
                    CBK_Log.error('', e, mapError, detalle);
                    return wrapper;
                }
             
                wrapper.statusCode = res.getStatusCode();
                if(res.getStatusCode() == 200) {
                    switch on tipoDeRiesgo{
                        when 'getProductsAgrupado'{
                            TotalBalanceWrapperData resp = (TotalBalanceWrapperData)JSON.deserialize(res.getBody(),TotalBalanceWrapperData.class);
                            wrapper.responseAcumulado = resp;
                            wrapper.comunicacionAgrupado = true;
                            wrapper.jsonResponse = res.getBody();
                            CBK_log.debug('Response OK:  Status = ' + res.getStatusCode() + ' Body = ' + res.getBody() , LoggingLevel.INFO);
                            
                        }
                        when 'getProductsDetalle'{
                            ContractsWrapper resp = (ContractsWrapper)JSON.deserialize(res.getBody(),ContractsWrapper.class);
                            wrapper.responseDetalle = resp;
                            wrapper.comunicacionDetalle = true;
                            wrapper.jsonResponseDetalle = res.getBody();
                            CBK_log.debug('Response OK:  Status = ' + res.getStatusCode() + ' Body = ' + res.getBody() , LoggingLevel.INFO);
                        }
                    }
                } else if(res.getStatusCode() == 204){
                    wrapper.errorMessage = 'El cliente no tiene datos';
                } else {
                    //httpRespError resp = (httpRespError)JSON.deserialize(res.getBody(),httpRespError.class);
                    //wrapper.errorMessage += ' task: ' + tipoDeRiesgo + ' code: ' + resp.code + ' description: ' + resp.codeDescription;
                    //wrapper.errorCode = res.getStatusCode();
                    CBK_log.error('Response KO:  Status = ' + res.getStatusCode() + ' Body = ' + res.getBody());
                }
			} else {
                switch on tipoDeRiesgo{
                    when 'getProductsAgrupado'{
                        TotalBalanceWrapperData resp = (TotalBalanceWrapperData)JSON.deserialize(accForRiesgos.CIBE_JsonRiesgoAgrupado__c,TotalBalanceWrapperData.class);
                        wrapper.responseAcumulado = resp;
                        wrapper.jsonResponse = accForRiesgos.CIBE_JsonRiesgoAgrupado__c;
                        //para evitar que vuelva a escribir en BBDD si está ya recuperando los datos sin la integracion
                        wrapper.comunicacionAgrupado = false;

                    }
                    when 'getProductsDetalle'{
                        ContractsWrapper resp = (ContractsWrapper)JSON.deserialize(accForRiesgos.CIBE_JsonRiesgoDetallado__c,ContractsWrapper.class);
                        wrapper.responseDetalle = resp;
                        wrapper.jsonResponseDetalle = accForRiesgos.CIBE_JsonRiesgoDetallado__c;
                        wrapper.comunicacionDetalle = false;
                    }
                }
                
            }
		} else {
            wrapper.errorMessage = 'El cliente no tiene NumPerso AV';
        }
		return wrapper;
	}


 
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
    *****************************************************************/
	@AuraEnabled
	public static Response getRiesgoProducts(Id recordId,String tipoDeRiesgo) {
        System.debug('Entering <Method getRiesgoProducts>: '+ 'Parameter recordId: ' + recordId+ 'Parameter tipoDeRiesgo: ' + tipoDeRiesgo);
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
                if(tipoDeRiesgo==PARAM_RIESGO_DETALLADO || tipoDeRiesgo==PARAM_RIESGO_TODOS){
                    //Obtenemos la cuenta con la que llamaremos a la integraciónd de Riesgos para obtener los balances y el riesgo del terminal financiero.
                        response responseFromRequestDetallado = retrieveCustomerRisk(accForRiesgos, accForRiesgos.CIBE_FechaRefrescoRiesgoDetallado__c,PARAM_RIESGO_DETALLADO);
                        responseFromRequest.responseDetalle = responseFromRequestDetallado.responseDetalle;
                        responseFromRequest.jsonResponseDetalle = responseFromRequestDetallado.jsonResponseDetalle;
                        responseFromRequest.comunicacionDetalle = responseFromRequestDetallado.comunicacionDetalle;
                        getContracts(responseFromRequest.responseDetalle.Products, recordId);

                }
            }catch(Exception e){
                System.debug('Error al obtener la cuenta con el recordId: ' + recordId);
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
                throw new AuraHandledException('Error al obtener los datos de Riesgos: ' + responseFromRequest.errorMessage);
            }
        }

        System.debug('Exiting <Method getRiesgosProducts>: '+ responseFromRequest);
		return responseFromRequest;	

	}

    /*****************************************************************   
  * Proposito: Se le pasa una lista de ContractWrapperDetalle y lo devuelve con su nombre al buscarlo en BBDD                                                           
    Parameters: [ContractWrapperDetalle]   
    Returns: []   
    Throws [Exceptions]: [optional]                                                          
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0             US470406           Alexandre Perez                30-01-2023     Created
    *****************************************************************/
	public static void getContracts(list<ProductWrapperDetalle> productos, string cliente) {

        map<integer, ContractWrapperDetalle> idContratosAV = new map<integer, ContractWrapperDetalle>();
        list<AV_Sales__c> saleList = new list<AV_Sales__c>();

        for(ProductWrapperDetalle product : productos) {
            for(ContractWrapperDetalle contrato : product.Contracts) {        
                //ponemos de nombre el contractId en caso de no disponer en nuestra BBDD del contrato con el nombre y comprobamos que no nos venga ya en la integracion
                if(contrato.description == null) {
                    contrato.description = string.valueOf(contrato.contractId);
                    idContratosAV.put(contrato.contractId, contrato);
                }
                
            }
        }
 
        //si el contrato ya ha sido localizado no vuelve a sobreescribir el dato
        list<string> contratoElegido = new list<string>();
        ContractWrapperDetalle contrato;
        if(!idContratosAV.isEmpty()) {
            for(AV_Sales__c sale : [SELECT Name, AV_Producto__r.Name, AV_NumeroContrato__c FROM AV_Sales__c WHERE AV_Cliente__c = : cliente ORDER BY CreatedDate DESC]) {
                if(sale.AV_NumeroContrato__c != null && idContratosAV.containsKey(integer.valueOf(sale.AV_NumeroContrato__c))){
                    if(!contratoElegido.contains(sale.AV_NumeroContrato__c)) {
                        //agregamos el nombre del producto asociado al contrato
                        contrato = idContratosAV.get(integer.valueOf(sale.AV_NumeroContrato__c));
                        contrato.description += ' ' + sale.AV_Producto__r.Name;
                        contratoElegido.add(sale.AV_NumeroContrato__c);
                    }
                }
            }
        }
    }

}