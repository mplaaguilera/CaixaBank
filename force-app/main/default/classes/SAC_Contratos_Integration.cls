public with sharing class SAC_Contratos_Integration{
    
    private static final String SAC_CONTRATOS_CLIENTE   = 'SAC_Contratos_Cliente';
    private static final String SAC_CONTRATOS_DETALLE   = 'SAC_Contratos_Detalle';
    private static final String SAC_CONTRATOS_TICKET    = 'SAC_Contratos_Ticket';
    private static final String SAC_CONTRATOS_CONTRATO  = 'SAC_Contratos_Contrato';
    private static final String SPV_CONTRATOS_TICKET    = 'SPV_Contratos_Ticket';
    private static final String SPV_CONTRATOS_CONTRATO  = 'SPV_Contratos_Contrato';
    public static final String HEADER_CONTENT_TYPE 		= 'Content-Type';
    public static final String HEADER_CUSTOMERID 		= 'x-absis-customerInternalId';
    
    public class ProductResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public ProductData data;
    }
    public class ContractResponse{
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public ContractData data;
        @AuraEnabled
        public CC_TrazaInt__c trazaContrato;
        
    }
    
    public class TicketResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public String ticketCode;
        @AuraEnabled
        public CC_TrazaInt__c trazaTicket;
        
    }
    
    public class ContractData{
        @AuraEnabled
        public Double passiveBalance;
        @AuraEnabled	
        public Double activeBalance;
        @AuraEnabled	
        public boolean isOnline;
        @AuraEnabled
        public ClassPagination pagination;
        @AuraEnabled
        public List<ClsProducts> products;
        
    }
    
    public class ClassPagination{
        @AuraEnabled
        public Integer pageKey;	
        @AuraEnabled
        public Integer pageSize;	
        @AuraEnabled
        public ClassLinks links;
    }
    public class Classlinks {
        @AuraEnabled
        public String first;	
        @AuraEnabled
        public String last;	
        @AuraEnabled
        public String prev;	
        @AuraEnabled
        public String next;	
    }    
    
    public class ClsProducts {
        @AuraEnabled
        public Integer productId;	
        @AuraEnabled
        public String productDescription;	
        @AuraEnabled
        public Double productBalance;	
        @AuraEnabled
        public List<ClsContracts> contracts;
    }
    
    public class ClsContracts {
        @AuraEnabled
        public Long contractId;	
        @AuraEnabled
        public Integer area;	 
        @AuraEnabled
        public Integer modality;	
        @AuraEnabled
        public Integer office;	
        @AuraEnabled
        public String alias;
        @AuraEnabled
        public String iban;	
        @AuraEnabled
        public Integer controlDigit;	
        @AuraEnabled
        public String ownerName;
        @AuraEnabled
        public String riskLine;
        @AuraEnabled
        public Long CGEline;	
        @AuraEnabled                                                   
        public String aplication;	
        @AuraEnabled
        public String returnCode;	
        @AuraEnabled
        public String description;	
        @AuraEnabled
        public Integer descriptionId;	
        @AuraEnabled
        public String ownerType;	
        @AuraEnabled
        public String currencyId;	
        @AuraEnabled
        public Integer branchId;
        @AuraEnabled
        public Integer issuingBranchId;
        @AuraEnabled
        public String country;	
        @AuraEnabled
        public String cancelDate;	
        @AuraEnabled
        public String openingDate;	
        @AuraEnabled
        public String policyStatus;	
        @AuraEnabled
        public List<ClassIndicators> indicators;
        @AuraEnabled
        public List<ClassBalance> balance;
        @AuraEnabled
        public ClassContractPack contractPack;
    }
    
    public class ClassIndicators{
        @AuraEnabled
        public String key;	
        @AuraEnabled
        public String value;	
    }
    
    public class ClassBalance {
        @AuraEnabled
        public String type;	//Available
        @AuraEnabled
        public Double amount;	//6.01
        @AuraEnabled
        public String currencyId;	//EUR
    }
    
    public class ClassContractPack {
        @AuraEnabled
        public Integer id;	
        @AuraEnabled
        public Integer area;	
        @AuraEnabled
        public Integer modality;	
        @AuraEnabled
        public Integer office;	
    }
    
    public class ProductData {
        @AuraEnabled
        public List<ClassCustomerBusiness> customerBusiness;
    }
    
    public class ClassCustomerBusiness {
        @AuraEnabled
        public ClassBusiness business;
        @AuraEnabled
        public List<ClassExperiences> experiences;
    }
    
    public class ClassBusiness {
        @AuraEnabled
        public String key;	//BPA
        @AuraEnabled
        public String value;	//Banca particulares
    }
    
    public class ClassExperiences {
        @AuraEnabled
        public ClassExperience experience;
        @AuraEnabled
        public Integer globalExperience;	//1
        @AuraEnabled
        public Integer order;	//1
        @AuraEnabled
        public boolean isMyBox;
        @AuraEnabled
        public List<ClassProducts> products;
    }
    
    public class ClassExperience {
        @AuraEnabled
        public String key;	//BPA001
        @AuraEnabled
        public String value;	//Dia a dia
    }
    
    public class ClassProducts {
        @AuraEnabled
        public ClassProductCode productCode;
        @AuraEnabled
        public ClassState state;
        @AuraEnabled
        public Integer order;	//1
        @AuraEnabled
        public boolean isProfessional;
        @AuraEnabled
        public Integer preconceived;	//0
        @AuraEnabled
        public boolean isTarget;
        @AuraEnabled
        public boolean isPotential;
        @AuraEnabled
        public ClassProductCode oportunity;
    }
    
    public class ClassProductCode {
        @AuraEnabled
        public String key;	//50070
        @AuraEnabled
        public String value;	//Nómina
    }
    
    public class ClassState {
        @AuraEnabled
        public String key;	//14
        @AuraEnabled
        public String value;	//No apto/Rechazado, tiene en 	otras entidades
    }
    
    public class ProductDetailResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public ProductDetailData data;
    }
    
    public class ProductDetailData {
        @AuraEnabled
        public String description;	//Tarjeta crédito
        @AuraEnabled
        public ClassState state;
        @AuraEnabled
        public Integer preconceived;	//0
        @AuraEnabled
        public boolean isTarget;
        @AuraEnabled
        public ClassOportunity oportunity;
        @AuraEnabled
        public String revDate;	//2021-10-07
        @AuraEnabled
        public String openingDate;	//2021-10-06
        @AuraEnabled
        public boolean isPotential;
        @AuraEnabled
        public boolean hasOtherEnt;
        @AuraEnabled
        public String cancelDate;	//99.9
        @AuraEnabled
        public Double totalBalance;	//99.9
        @AuraEnabled
        public List<ClassContracts> contracts;
        @AuraEnabled
        public String otherEntDesc;
        @AuraEnabled
        public String commentary;
    }
    
    public class ClassOportunity {
    }
    
    public class ClassContracts {
        @AuraEnabled
        public Long id;	//9612140272795
        @AuraEnabled
        public String description;	//Visa Classic
        @AuraEnabled
        public String balance;	//0
    }
    
    /**
* @description			 Método para obtener los códigos de contratos desde un cliente. DEPRECADA
* @param customerId		 -> Numperso del cliente
*/
    @AuraEnabled
    public static ProductResponse getCommercialProduct(String customerId){
        
        ProductResponse responseData = new ProductResponse();
        CC_InterfaceSettings__mdt confInterfaz   = SAC_Utils.getInterfazConfigBody(SAC_CONTRATOS_CLIENTE);
        
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        Map<String, String> mapHeader = new Map<String, String>();
        
        Long customerIdLong = long.valueOf(customerId);
        
        String customerIdHex = SAC_Utils.convertToHexadecimal(customerIdLong); //numperso del cliente en hexadecimal
        mapHeader.put(HEADER_CUSTOMERID,customerIdHex);
        mapHeader.put(HEADER_CONTENT_TYPE, confInterfaz.CC_ContentType__c);
        
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = '';
        reqWap.intSetting = SAC_CONTRATOS_CLIENTE;
        reqWap.method = confInterfaz.CC_TipoPeticion__c;
        reqWap.mHeaders = mapHeader;
        
        HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);
        
        String dataMockup = '';
        if(Test.isRunningTest()){
        dataMockup = '{"customerBusiness":[{"business":{"key":"BPA","value":"Banca particulares"},"experiences":[{"experience":{"key":"BPA001","value":"Dia a dia"},"globalExperience":1,"order":1,"isMyBox":false,"products":[{"productCode":{"key":"50070","value":"Nómina"},"state":{"key":"14","value":"No apto/Rechazado, tiene en \totras entidades"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50072","value":"Pensión"},"state":{"key":"2","value":"Tiene"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":true},{"productCode":{"key":"50117","value":"ServiCuentas"},"state":{"key":"2","value":"Tiene"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50119","value":"Domicil. recibos"},"state":{"key":"2","value":"Tiene"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50080","value":"Tributos"},"state":{"key":"3","value":"Tuvo"},"order":1,"isProfessional":true,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50076","value":"TPV"},"state":{"key":"2","value":"Tiene"},"order":1,"isProfessional":true,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50079","value":"Seguros sociales"},"state":{"key":"2","value":"Tiene"},"order":1,"isProfessional":true,"preconceived":0,"isTarget":false,"isPotential":true},{"productCode":{"key":"50071","value":"Paro"},"state":{"key":"1","value":"No tiene"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50077","value":"Caixabank Now"},"state":{"key":"1","value":"No tiene"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false}]},{"experience":{"key":"BPA002","value":"Disfrutar de la vida"},"globalExperience":2,"order":2,"isMyBox":false,"products":[{"productCode":{"key":"50030","value":"Hipoteca"},"state":{"key":"4","value":"No apto/Rechazado"},"order":2,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50033","value":"Préstamo Prof."},"state":{"key":"4","value":"No apto/Rechazado"},"order":2,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50046","value":"Tarjeta crédito"},"state":{"key":"2","value":"Tiene"},"order":2,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":true},{"productCode":{"key":"50032","value":"Préstamo"},"state":{"key":"2","value":"Tiene"},"order":2,"isProfessional":false,"preconceived":15000,"isTarget":false,"isPotential":true}]},{"experience":{"key":"BPA003","value":"Pensar en el futuro"},"globalExperience":3,"order":3,"isMyBox":true,"products":[{"productCode":{"key":"50002","value":"Cuenta divisa"},"state":{"key":"1","value":"No tiene"},"order":3,"isProfessional":false,"preconceived":2,"isTarget":false,"isPotential":false},{"productCode":{"key":"50012","value":"Valores Renta Fija"},"state":{"key":"11","value":"No tiene, tiene en otras \tentidades"},"order":3,"isProfessional":false,"preconceived":4,"isTarget":false,"isPotential":false},{"productCode":{"key":"50011","value":"Tesorería - Pasivo"},"state":{"key":"2","value":"Tiene"},"order":3,"isProfessional":false,"preconceived":3,"isTarget":false,"isPotential":false},{"productCode":{"key":"50004","value":"Vista y plazo"},"state":{"key":"2","value":"Tiene"},"order":3,"isProfessional":false,"preconceived":1,"isTarget":false,"isPotential":false},{"productCode":{"key":"50008","value":"Seguros ahorro"},"state":{"key":"1","value":"No tiene"},"order":3,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false}]},{"experience":{"key":"BPA004","value":"Dormir tranquilo"},"globalExperience":4,"order":4,"isMyBox":false,"products":[{"productCode":{"key":"50094","value":"Seg. Comunidad"},"state":{"key":"11","value":"No tiene, tiene en otras \tentidades"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":true,"isPotential":false},{"productCode":{"key":"50091","value":"Caixagiros"},"state":{"key":"3","value":"Tuvo"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50095","value":"Auto"},"state":{"key":"11","value":"No tiene, tiene en otras \tentidades"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":true},{"productCode":{"key":"50104","value":"Seviam"},"state":{"key":"1","value":"No tiene"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50108","value":"Accidentes"},"state":{"key":"1","value":"No tiene"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50099","value":"Seguros agrarios"},"state":{"key":"1","value":"No tiene"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50100","value":"Seg. de compras"},"state":{"key":"1","value":"No tiene"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":true}]}]},{"business":{"key":"BPE","value":"Banca Personal"},"experiences":[{"experience":{"key":"BPE001","value":"Dia a dia"},"globalExperience":1,"order":1,"isMyBox":false,"products":[{"productCode":{"key":"50070","value":"Nómina"},"state":{"key":"14","value":"No apto/Rechazado, tiene en \totras entidades"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50071","value":"Paro"},"state":{"key":"1","value":"No tiene"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50077","value":"Caixabank Now"},"state":{"key":"1","value":"No tiene"},"order":1,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false}]},{"experience":{"key":"BPE002","value":"Disfrutar de la vida"},"globalExperience":2,"order":2,"isMyBox":false,"products":[{"productCode":{"key":"50030","value":"Hipoteca"},"state":{"key":"2","value":"Tiene"},"order":2,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50032","value":"Préstamo"},"state":{"key":"2","value":"Tiene"},"order":2,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":true}]},{"experience":{"key":"BPE003","value":"Pensar en el futuro"},"globalExperience":3,"order":3,"isMyBox":false,"products":[{"productCode":{"key":"50010","value":"Planes de pensiones"},"state":{"key":"1","value":"No tiene"},"order":3,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50012","value":"Valores Renta Fija"},"state":{"key":"11","value":"No tiene, tiene en otras \tentidades"},"order":3,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50011","value":"Tesorería - Pasivo"},"state":{"key":"2","value":"Tiene"},"order":3,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50004","value":"Vista y plazo"},"state":{"key":"2","value":"Tiene"},"order":3,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50008","value":"Seguros ahorro"},"state":{"key":"1","value":"No tiene"},"order":3,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false}]},{"experience":{"key":"BPE004","value":"Dormir tranquilo"},"globalExperience":4,"order":4,"isMyBox":false,"products":[{"productCode":{"key":"50104","value":"Seviam"},"state":{"key":"1","value":"No tiene"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50108","value":"Accidentes"},"state":{"key":"1","value":"No tiene"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50099","value":"Seguros agrarios"},"state":{"key":"1","value":"No tiene"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":false},{"productCode":{"key":"50100","value":"Seg. de compras"},"state":{"key":"1","value":"No tiene"},"order":4,"isProfessional":false,"preconceived":0,"isTarget":false,"isPotential":true}]}]}]}';
        }
        
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.multiCallHttpService(request, customerId, SAC_CONTRATOS_CLIENTE);
        String statusCode = String.valueOf(resp.getStatusCode());
        
        if(statusCode.equalsIgnoreCase('200')){
            String replaceIllegal= resp.getbody().replaceAll('\b','').replaceAll('\f','').replaceAll('\n','').replaceAll('\r','').replaceAll('\t','');
            responseData.data = (SAC_Contratos_Integration.ProductData)getBodyResponse(replaceIllegal, 'SAC_Contratos_Integration.ProductData');
            responseData.statusCode = statusCode;
        }else{
            responseData.statusCode = statusCode;
            responseData.errorCode = 'Error en el servicio.';
            responseData.errorMessage = resp.getStatus(); 
        } 
        
        
        return responseData;
        
    }
    
    
    /**
* @description			 Método para obtener el detalle del contrato. DEPRECADA
* @param customerId		 -> Numperso del cliente
* @param productId			 -> Id del contrato
* @param numTicket
*/
    @AuraEnabled
    public static ProductDetailResponse getCommercialProductDetail(String customerId, String productId){
        
        ProductDetailResponse responseData = new ProductDetailResponse();
        CC_InterfaceSettings__mdt confInterfaz   = SAC_Utils.getInterfazConfigBody(SAC_CONTRATOS_DETALLE);
        
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        Map<String, String> mapHeader = new Map<String, String>();
        Long customerIdLong = Long.valueOf(customerId);
        
        String customerIdHex = SAC_Utils.convertToHexadecimal(customerIdLong); //numperso del cliente en hexadecimal
        mapHeader.put(HEADER_CUSTOMERID,customerIdHex);
        mapHeader.put(HEADER_CONTENT_TYPE, confInterfaz.CC_ContentType__c);
        
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = '';
        reqWap.intSetting = SAC_CONTRATOS_DETALLE;
        reqWap.method = confInterfaz.CC_TipoPeticion__c;
        reqWap.mHeaders = mapHeader;
        
        HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);
        String endpoint = request.getEndpoint().replace('{commercialProductId}', productId);
        request.setEndpoint(endpoint);
        
        String dataMockup = '';
        if(Test.isRunningTest()){
        dataMockup = '{"description":"Tarjeta crédito","state":{"key":"2","value":"Tiene"},"preconceived":0,"isTarget":false,"oportunity":{},"revDate":"2021-10-07","openingDate":"2021-10-06","isPotential":true,"hasOtherEnt":false,"totalBalance":99.9,"Contracts":[{"id":9612140272795,"description":"Visa Classic","balance":0},{"id":5053023396791,"description":"","balance":3.5},{"id":5053026358471,"description":"","balance":96.4}]}';
        }
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.multiCallHttpService(request, customerId, SAC_CONTRATOS_DETALLE);
        String statusCode = String.valueOf(resp.getStatusCode());
        if(statusCode.equalsIgnoreCase('200')){
            String replaceIllegal= resp.getbody().replaceAll('\b','').replaceAll('\f','').replaceAll('\n','').replaceAll('\r','').replaceAll('\t','');
            responseData.data = (SAC_Contratos_Integration.ProductDetailData)getBodyResponse(replaceIllegal, 'SAC_Contratos_Integration.ProductDetailData');
            responseData.statusCode = statusCode;
        }else{
            responseData.statusCode = statusCode;
            responseData.errorCode = 'Error en el servicio.';
            responseData.errorMessage = resp.getStatus(); 
        } 
        
        
        return responseData;
        
    }
    @AuraEnabled
    public static TicketResponse getTicket(String customerId, String perfilUser){
        
        TicketResponse responseTicket = new TicketResponse ();
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        Map<String, String> mapHeader = new Map<String, String>();
        String contratoTicket = '';
        
        if(perfilUser == 'SPV_General'){
            contratoTicket = SPV_CONTRATOS_TICKET;
        }else{
            contratoTicket = SAC_CONTRATOS_TICKET;
        
        }
        CC_InterfaceSettings__mdt confInterfaz   = SAC_Utils.getInterfazConfigBody(contratoTicket);

        Long customerIdLong = long.valueOf(customerId);
        if (confInterfaz.CC_TrazaActiva__c || Test.isRunningTest()){
            traza.Name = contratoTicket;
            traza.CC_Identificador__c = customerId;
            traza.CC_FechaInicio__c = datetime.now();
        }
        String customerIdHex = SAC_Utils.convertToHexadecimal(customerIdLong); //numperso del cliente en hexadecimal
        mapHeader.put(HEADER_CUSTOMERID,customerIdHex);
        mapHeader.put(HEADER_CONTENT_TYPE, confInterfaz.CC_ContentType__c);
        
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = confInterfaz.CC_Body__c;
        reqWap.intSetting = contratoTicket;
        reqWap.method = confInterfaz.CC_TipoPeticion__c;
        reqWap.mHeaders = mapHeader;
        
        HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);
        traza.CC_MensajeEntrada__c = request.toString();
        String dataMockup = '';
        if(Test.isRunningTest()){
            dataMockup = '{"ticket":"N0000000000000000118900005"}';
        }
        //request.setClientCertificateName('cert_pre_supvsf');
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.multiCallHttpService(request, customerId, contratoTicket);
        String statusCode = String.valueOf(resp.getStatusCode());
        String ticketCode = String.valueOf(resp.getBody());
        
        if (confInterfaz.CC_TrazaSalida__c || Test.isRunningTest()){
            traza.CC_FechaFin__c = datetime.now();
            traza.CC_MensajeSalida__c = resp.getBody();
        }
        
        if(statusCode.equalsIgnoreCase('200')){
            traza.CC_FinOK__c = true;
            responseTicket.ticketCode = ticketCode;
            responseTicket.statusCode = statusCode;
        }else{
            traza.CC_FinOK__c = false;
            responseTicket.statusCode = statusCode;
            responseTicket.errorCode = 'Error en el servicio.';
            responseTicket.errorMessage = resp.getStatus(); 
        } 
        
        responseTicket.trazaTicket = traza;
        
        return responseTicket;
        
    }
    
    @AuraEnabled
    public static ContractResponse getContract(String numTicket, String perfilUser){
        
        ContractResponse responseContract = new ContractResponse();
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        String contratoDetalle = '';
        
        if(perfilUser == 'SPV_General'){
            contratoDetalle = SPV_CONTRATOS_CONTRATO;
        }else{
            contratoDetalle = SAC_CONTRATOS_CONTRATO;
        
        }

        CC_InterfaceSettings__mdt confInterfaz   = SAC_Utils.getInterfazConfigBody(contratoDetalle);

        if (confInterfaz.CC_TrazaActiva__c || Test.isRunningTest()){
            traza.Name = contratoDetalle;
            traza.CC_Identificador__c = numTicket;
            traza.CC_FechaInicio__c = datetime.now();
        }
        Map<String, String> mapHeader = new Map<String, String>();        
        mapHeader.put(HEADER_CONTENT_TYPE, confInterfaz.CC_ContentType__c);
        
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = '';
        reqWap.intSetting = contratoDetalle;
        reqWap.method = confInterfaz.CC_TipoPeticion__c;
        reqWap.mHeaders = mapHeader;
        
        HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);

        String endpoint = request.getEndpoint().replace('{numTicket}', numTicket);
        request.setEndpoint(endpoint);
        
        traza.CC_MensajeEntrada__c = request.toString();
        String dataMockup = '';
        if(Test.isRunningTest()){
            dataMockup = '{"PassiveBalance":144531.84,"ActiveBalance":1303.99,"isOnline":false,"pagination":{"pageKey":1,"pageSize":200,"links":{"first":"/partyReference/customers/contracts?ticket=N0000000000000000020600527&fullData=false&cancelledContracts=false&pageKey=1&pageSize=200","last":"/partyReference/customers/contracts?ticket=N0000000000000000020600527&fullData=false&cancelledContracts=false&pageKey=1&pageSize=200"}},"Products":[{"productId":10158,"productDescription":"Cuentas a la vista","productBalance":206396.16999999998,"Contracts":[{"contractId":180020002194,"area":1,"modality":2,"office":180,"iban":"ES1521000180810200219491","controlDigit":91,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Cuenta corriente","descriptionId":10613,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"1995-05-18","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Available","amount":6.01,"currencyId":"EUR"}]},{"contractId":555020013374,"area":1,"modality":2,"office":555,"iban":"ES2221000555320201337431","controlDigit":31,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Cuenta corriente","descriptionId":10644,"ownerType":"12","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2010-05-10","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Available","amount":59873.27,"currencyId":"EUR"}]},{"contractId":555020013375,"area":1,"modality":2,"office":555,"iban":"ES5621000555370201337544","controlDigit":44,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Cuenta corriente","descriptionId":10644,"ownerType":"12","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2010-05-10","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Available","amount":-300,"currencyId":"EUR"}]},{"contractId":555020013376,"area":1,"modality":2,"office":555,"iban":"ES9321000555310201337657","controlDigit":57,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Cuenta corriente","descriptionId":10644,"ownerType":"12","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2010-05-10","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Available","amount":0,"currencyId":"EUR"}]},{"contractId":555020013377,"area":1,"modality":2,"office":555,"iban":"ES0321000555380201337770","controlDigit":70,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Cuenta corriente","descriptionId":10644,"ownerType":"12","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2010-05-10","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Available","amount":0,"currencyId":"EUR"}]},{"contractId":555020013378,"area":1,"modality":2,"office":555,"iban":"ES4021000555320201337883","controlDigit":83,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Cuenta corriente","descriptionId":10644,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2010-05-10","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Available","amount":-204.09,"currencyId":"EUR"}]},{"contractId":1199020001614,"area":1,"modality":2,"office":1199,"iban":"ES5121001199820200161442","controlDigit":42,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Cuenta corriente","descriptionId":10644,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-07-15","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Available","amount":119891.82,"currencyId":"EUR"}]},{"contractId":4746010000441,"area":1,"modality":1,"office":4746,"iban":"ES8521004746580100044101","controlDigit":1,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Libreta joven","descriptionId":10683,"ownerType":"10","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2001-12-27","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Available","amount":8112.04,"currencyId":"EUR"}]},{"contractId":4746010000843,"area":1,"modality":1,"office":4746,"iban":"ES3421004746530100084355","controlDigit":55,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Libreta estrella","descriptionId":10682,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2004-04-28","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Available","amount":18964.68,"currencyId":"EUR"}]},{"contractId":5454020002419,"area":1,"modality":2,"office":5454,"iban":"ES9121005454460200241900","controlDigit":0,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Cuenta estrella","descriptionId":10606,"ownerType":"12","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-03-14","Indicators":[{"key":"ARC","value":"N"},{"key":"CAN","value":"N"},{"key":"EMP","value":"N"},{"key":"RST","value":"N"},{"key":"VIN","value":"N"},{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Available","amount":48.86,"currencyId":"EUR"}]},{"contractId":5053011644799,"area":99,"modality":1,"office":5053,"iban":"ES8421005053540164479936","controlDigit":92,"ownerName":"00000010026001250121","aplication":"CLI","returnCode":"1","description":"BK Vista","descriptionId":25093,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2018-08-03","Indicators":[{"key":"CAN","value":"N"},{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Available","amount":3.58,"currencyId":"EUR"}]}]},{"productId":10060,"productDescription":"Fondos inversión","productBalance":1117.22,"Contracts":[{"contractId":5053029296494,"area":99,"modality":2,"office":5053,"iban":"ES1821005053580229649408","controlDigit":14,"ownerName":"00000000366000028130","aplication":"CLI","returnCode":"1","description":"BK Fdos.inversión","descriptionId":25099,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2020-11-06","Indicators":[{"key":"CAN","value":"N"},{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Available","amount":1117.22,"currencyId":"EUR"}]}]},{"productId":10062,"productDescription":"Seguros de Ahorro","productBalance":4435.42,"Contracts":[{"contractId":5053031964969,"area":99,"modality":3,"office":5053,"iban":"ES4221005053510396496982","controlDigit":4,"ownerName":"00010010021800001136","aplication":"CLI","returnCode":"1","description":"BK Seg.Ahorro","descriptionId":25103,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2011-08-22","Indicators":[{"key":"CAN","value":"N"},{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Available","amount":4435.42,"currencyId":"EUR"}]}]},{"productId":15890,"productDescription":"Renta variable","productBalance":113.11,"Contracts":[{"contractId":5053028460514,"area":99,"modality":2,"office":5053,"iban":"ES4021005053550246051471","controlDigit":9,"ownerName":"00000000060512605692","aplication":"CLI","returnCode":"1","description":"BK Valores","descriptionId":25107,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-01-24","Indicators":[{"key":"CAN","value":"N"},{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Available","amount":113.11,"currencyId":"EUR"}]}]},{"productId":10012,"productDescription":"Descubierto","productBalance":0,"Contracts":[{"contractId":555020013375,"area":1,"modality":2,"office":555,"iban":"ES5621000555370201337544","controlDigit":44,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Descubierto","descriptionId":4167,"ownerType":"12","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2010-05-10","Indicators":[{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":555020013378,"area":1,"modality":2,"office":555,"iban":"ES4021000555320201337883","controlDigit":83,"ownerName":"","aplication":"TLE","returnCode":"1","description":"Descubierto","descriptionId":4167,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2010-05-10","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]}]},{"productId":10006,"productDescription":"Préstamos","productBalance":0,"Contracts":[{"contractId":1199010000041,"area":16,"modality":1,"office":1199,"iban":"ES8321001199870100004144","controlDigit":44,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-07-04","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199010000048,"area":16,"modality":1,"office":1199,"iban":"ES3421001199810100004835","controlDigit":35,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-07-04","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199010000165,"area":16,"modality":1,"office":1199,"iban":"ES2321001199860100016525","controlDigit":25,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2016-07-12","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199010000169,"area":16,"modality":1,"office":1199,"iban":"ES4121001199860100016977","controlDigit":77,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2016-07-13","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199010000172,"area":16,"modality":1,"office":1199,"iban":"ES6921001199870100017297","controlDigit":97,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2016-07-13","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199010000175,"area":16,"modality":1,"office":1199,"iban":"ES0221001199810100017536","controlDigit":36,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2016-07-14","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199010000179,"area":16,"modality":1,"office":1199,"iban":"ES2021001199810100017988","controlDigit":88,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2016-07-14","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199010000185,"area":16,"modality":1,"office":1199,"iban":"ES3221001199830100018547","controlDigit":47,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2016-10-04","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199010000212,"area":16,"modality":1,"office":1199,"iban":"ES0921001199880100021238","controlDigit":38,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2017-04-19","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":3060010205574,"area":16,"modality":1,"office":3060,"iban":"ES4821003060520120557464","controlDigit":55,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2016-10-11","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":3060010205584,"area":16,"modality":1,"office":3060,"iban":"ES5821003060510120558497","controlDigit":66,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2017-04-19","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":9710010213762,"area":16,"modality":1,"office":9710,"iban":"ES3621009710510121376231","controlDigit":31,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo personal","descriptionId":413,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2016-01-07","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]}]},{"productId":10007,"productDescription":"Cuentas de crédito","productBalance":0,"Contracts":[{"contractId":1199020000009,"area":16,"modality":2,"office":1199,"iban":"ES4421001199840200000935","controlDigit":35,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Cuenta de crédito","descriptionId":421,"ownerType":"2","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2015-04-30","Indicators":[{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]}]},{"productId":10015,"productDescription":"Renting","productBalance":0,"Contracts":[{"contractId":5316230177011,"area":16,"modality":23,"office":5316,"iban":"ES0521005316032317701151","controlDigit":51,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Renting","descriptionId":11822,"ownerType":"44","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2020-01-20","Indicators":[{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]}]},{"productId":10010,"productDescription":"Tarjetas","productBalance":3200,"Contracts":[{"contractId":9612140272795,"area":17,"modality":14,"office":9612,"iban":"ES6521009612091427279505","controlDigit":5,"ownerName":"","aplication":"TCR","returnCode":"1","description":"Visa Classic","descriptionId":2047,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2015-01-27","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":9612140272795,"area":17,"modality":14,"office":9612,"iban":"ES6521009612091427279505","controlDigit":5,"ownerName":"","aplication":"TCR","returnCode":"1","description":"Visa Classic","descriptionId":2047,"ownerType":"3","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2015-01-27","Indicators":[{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":9612140272795,"area":17,"modality":14,"office":9612,"iban":"ES6521009612091427279505","controlDigit":5,"ownerName":"","aplication":"TCR","returnCode":"1","description":"Visa Classic","descriptionId":2047,"ownerType":"3","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2015-01-27","Indicators":[{"key":"NAC","value":"N"},{}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":5053023396791,"area":99,"modality":2,"office":5053,"iban":"ES3821005053510239679191","controlDigit":11,"ownerName":"00004245866122786164","riskLine":"0","aplication":"CLI","returnCode":"1","description":"BK Tarjeta","descriptionId":25121,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2018-11-14","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":1000,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":5053026358471,"area":99,"modality":2,"office":5053,"iban":"ES6921005053590235847129","controlDigit":57,"ownerName":"00005417630155730187","riskLine":"0","aplication":"CLI","returnCode":"1","description":"BK Tarjeta","descriptionId":25121,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2018-11-22","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":2200,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]}]},{"productId":10171,"productDescription":"Avales/Cred. Doc.","productBalance":1000,"Contracts":[{"contractId":9340032000055,"area":12,"modality":3,"office":9340,"iban":"ES6321009340220300005549","controlDigit":49,"ownerName":"","riskLine":"0","aplication":"AVM","returnCode":"1","description":"Aval técnico","descriptionId":3096,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2015-09-18","Indicators":[{"key":"NAC","value":"S"},{}],"Balance":[{"type":"Limit","amount":1000,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]}]},{"productId":0,"productDescription":"","productBalance":0,"Contracts":[{"contractId":1199010000098,"area":16,"modality":1,"office":1199,"iban":"ES2821001199810100009890","controlDigit":90,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Préstamo","descriptionId":0,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2015-04-30","Indicators":[{"key":"NAC","value":"N"}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199030000010,"area":16,"modality":3,"office":1199,"iban":"ES6521001199800300001060","controlDigit":60,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Avales - Preavales","descriptionId":0,"ownerType":"3","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-11-17","Indicators":[{"key":"NAC","value":"N"}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199030000031,"area":16,"modality":3,"office":1199,"iban":"ES1121001199820300003195","controlDigit":95,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Avales - Preavales","descriptionId":0,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2017-01-13","Indicators":[{"key":"NAC","value":"N"}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199060000005,"area":16,"modality":6,"office":1199,"iban":"ES3121001199810600000507","controlDigit":7,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Crédito abierto","descriptionId":0,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-07-04","Indicators":[{"key":"NAC","value":"N"}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":1199060000006,"area":16,"modality":6,"office":1199,"iban":"ES6521001199860600000620","controlDigit":20,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Crédito abierto","descriptionId":0,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-07-04","Indicators":[{"key":"NAC","value":"N"}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]},{"contractId":8671300000001,"area":16,"modality":30,"office":8671,"iban":"ES8621008671883000000184","controlDigit":84,"ownerName":"","aplication":"SIA","returnCode":"1","description":"Línea riesgos","descriptionId":0,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2014-10-08","Indicators":[{"key":"NAC","value":"N"}],"Balance":[{"type":"Limit","amount":0,"currencyId":"EUR"},{"type":"Granted","amount":0,"currencyId":"EUR"}]}]},{"productId":0,"productDescription":"","productBalance":0,"Contracts":[{"contractId":9736051552795,"area":28,"modality":5,"office":9736,"iban":"ES6521009736750555279550","controlDigit":50,"ownerName":"","returnCode":"7","description":"CaixaProtect","descriptionId":0,"ownerType":"1","branchId":1,"country":"11","cancelDate":"0"},{"contractId":9880510000029,"area":61,"modality":51,"office":9880,"iban":"ES5001339880605100002934","controlDigit":34,"ownerName":"","returnCode":"7","description":"Host to Host","descriptionId":0,"ownerType":"1","branchId":1,"country":"11","cancelDate":"0"},{"contractId":9880510000090,"area":61,"modality":51,"office":9880,"iban":"ES3101339880645100009094","controlDigit":94,"ownerName":"","returnCode":"7","description":"Host to Host","descriptionId":0,"ownerType":"1","branchId":1,"country":"11","cancelDate":"0"},{"contractId":9725024354334,"area":96,"modality":2,"office":9725,"iban":"ES6221009725510235433433","controlDigit":33,"ownerName":"","aplication":"CLO","returnCode":"7","description":"Cliente CaixabankNow","descriptionId":0,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0"},{"contractId":9725029521253,"area":96,"modality":2,"office":9725,"iban":"ES7721009725540252125358","controlDigit":58,"ownerName":"","aplication":"CLO","returnCode":"7","description":"Cliente CaixabankNow","descriptionId":0,"ownerType":"10","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0"}]},{"productId":10316,"productDescription":"Seguros Personales","productBalance":0,"Contracts":[{"contractId":5053031238765,"area":99,"modality":3,"office":5053,"iban":"ES4721005053530323876580","controlDigit":2,"ownerName":"00010010021800000879","aplication":"CLI","returnCode":"1","description":"BK Seguro vida","descriptionId":25178,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2012-06-11","Indicators":[{"key":"OCS","value":"Servicios"}]}]},{"productId":10315,"productDescription":"Seguros Patrimonio","productBalance":0,"Contracts":[{"contractId":5053032080319,"area":99,"modality":3,"office":5053,"iban":"ES1721005053590308031973","controlDigit":53,"ownerName":"00010010021800000432","aplication":"CLI","returnCode":"1","description":"BK Seguro de hogar","descriptionId":25177,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2010-12-22","Indicators":[{"key":"OCS","value":"Servicios"}]},{"contractId":5053032758505,"area":99,"modality":3,"office":5053,"iban":"ES8221005053550375850586","controlDigit":48,"ownerName":"00003810021900000144","aplication":"CLI","returnCode":"1","description":"BK Seguro de hogar","descriptionId":25177,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2019-02-21","Indicators":[{"key":"OCS","value":"Servicios"}]},{"contractId":5053032758610,"area":99,"modality":3,"office":5053,"iban":"ES9421005053570375861039","controlDigit":41,"ownerName":"00003810022000000320","aplication":"CLI","returnCode":"1","description":"BK Seguro de hogar","descriptionId":25177,"ownerType":"1","currencyId":"EUR","branchId":1,"country":"11","cancelDate":"0","openingDate":"2020-05-01","Indicators":[{"key":"OCS","value":"Servicios"}]}]}]}';
                }
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.multiCallHttpService(request, numTicket, contratoDetalle);
        String statusCode = String.valueOf(resp.getStatusCode());
        if(statusCode.equalsIgnoreCase('200')){
            String replaceIllegal= resp.getbody().replaceAll('\b','').replaceAll('\f','').replaceAll('\n','').replaceAll('\r','').replaceAll('\t','').replaceAll('\"currency\"','\"currencyId\"');
            responseContract.data = (SAC_Contratos_Integration.ContractData)getBodyResponse(replaceIllegal, 'SAC_Contratos_Integration.ContractData');
            responseContract.statusCode = statusCode;
            traza.CC_FinOK__c = true;
        }else{
            traza.CC_FinOK__c = false;
            responseContract.statusCode = statusCode;
            responseContract.errorCode = 'Error en el servicio.';
            responseContract.errorMessage = resp.getStatus(); 
        } 
        
        if (confInterfaz.CC_TrazaSalida__c || Test.isRunningTest()){
            traza.CC_FechaFin__c = datetime.now();
            traza.CC_MensajeSalida__c = resp.getBody();
        }
        
        responseContract.trazaContrato = traza;
        
        return responseContract;
        
    }
    
    /**
* @description Generate the response for the mockup data
*/
    private static HTTPResponse getDataMockup(String dataMockup){
        
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(Integer.valueOf('200'));
        res.setStatus('OK');
        res.setBody(dataMockup);
        return res;
    }
    
    /**
* @description Convertir en objeto el json de la response
*/
    private static Object getBodyResponse(String response, String clazzName){
        
        Object result = parseJsonToObject(response, clazzName);
        return result;
        
    }
    
    /**
* @description Convertir en objeto el json de la response
*/
    private static Object parseJsonToObject(String jsonData, String jsonType){
        Type typeClass = Type.forName(jsonType);
        return System.JSON.deserializeStrict(jsonData, typeClass);
    }
}