public with sharing class SAC_Contratos_Controller {


    public class ResponseData{
        @AuraEnabled
        public String customerId;
        @AuraEnabled
        public String statusCode; 
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public List<CustomerContrato> lstContratos;
    }

    public class CustomerContrato{
        @AuraEnabled
        public String codProduct;
        @AuraEnabled
        public String nameProduct;
        @AuraEnabled
        public String statusProducto;
    }

    public class ResponseDataProduct{
        @AuraEnabled
        public String customerId;
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public List<CustomerProduct> lstProducts;
    }

    public class CustomerProduct{
        @AuraEnabled
        public Integer codProduct;
        @AuraEnabled
        public String nameProduct;
        @AuraEnabled
        public String statusProducto;
        @AuraEnabled
        public List<DetallesContratosProducto> lstContratos;
    }

    public class DetallesContratosProducto {
		@AuraEnabled
		public Long id;	
		@AuraEnabled
		public String description;	
		@AuraEnabled
		public String balance;	
        @AuraEnabled
		public String cancelDate;
        @AuraEnabled
		public String openDate;
	}


    public class ResponseDataDetail{
        
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
		public String description;	
		@AuraEnabled
		public String state;
		@AuraEnabled
		public Integer preconceived;	
		@AuraEnabled
		public String revDate;	
		@AuraEnabled
		public String openingDate;	
		@AuraEnabled
		public Boolean isPotential;
		@AuraEnabled
		public Double totalBalance;	
		@AuraEnabled
		public List<DetallesContratos> contratos;
    }

    public class DetallesContratos {
		@AuraEnabled
		public Long id;	
		@AuraEnabled
		public String description;	
		@AuraEnabled
		public String balance;	
	}



    @AuraEnabled
    public static ResponseData obtenerContratos(String idRegistro) {

        ResponseData response = new ResponseData();
        List<CustomerContrato> lstContratosMostrar = new List<CustomerContrato>();
        List<String> lstCodProductos = new List<String>();

        Case reclamacion = [Select Account.CC_NumPerso__c from Case where id = :idRegistro limit 1];

        if(reclamacion != null && reclamacion.Account.CC_NumPerso__c != null){
            String numPerso = reclamacion.Account.CC_NumPerso__c;

            response.customerId = numPerso;
            SAC_Contratos_Integration.ProductResponse responseIntegration = SAC_Contratos_Integration.getCommercialProduct(numPerso);

            response.statusCode = responseIntegration.statusCode;
            if(responseIntegration.statusCode.equalsIgnoreCase('200')){
                //Integración devuelve un 200, extraemos los contratos
                
                //Obtenemos el customer business
                if(responseIntegration.data != null){
                    SAC_Contratos_Integration.ProductData productData = responseIntegration.data;
                    List<SAC_Contratos_Integration.ClassCustomerBusiness> lstBusiness = productData.customerBusiness;
                    for(SAC_Contratos_Integration.ClassCustomerBusiness customerBusiness : lstBusiness){
                        List<SAC_Contratos_Integration.ClassExperiences> lstExperiences = customerBusiness.experiences;
                        for(SAC_Contratos_Integration.ClassExperiences experience : lstExperiences){
                            List<SAC_Contratos_Integration.ClassProducts> lstProductos = experience.products;
                            for(SAC_Contratos_Integration.ClassProducts producto : lstProductos){
                                CustomerContrato cont = new CustomerContrato();
                                cont.codProduct = producto.productCode.key; 
                                if(!lstCodProductos.contains(cont.codProduct)){
                                    cont.nameProduct = producto.productCode.value;
                                    cont.statusProducto = producto.state.value; 
                                    if(producto.state.key == '2') {
                                        lstCodProductos.add(cont.codProduct);
                                        lstContratosMostrar.add(cont);
                                    }
                                }
                            }  
                        }   
                    }
                    response.lstContratos = lstContratosMostrar;
                }
                
            }else{
                //Mapeo el error
                response.errorMessage = responseIntegration.errorMessage;
            }

        }
        
       
        return response;
    }

    @AuraEnabled
    public static ResponseDataProduct showAllContracts(String idRegistro){
        ResponseDataProduct response = new ResponseDataProduct();
        List<CustomerProduct> lstProductsMostrar = new List<CustomerProduct>();
        SAC_Contratos_Integration.TicketResponse responseIntegration = new SAC_Contratos_Integration.TicketResponse();
        SAC_Contratos_Integration.ContractResponse responseData = new SAC_Contratos_Integration.ContractResponse();
        List<CC_TrazaInt__c> lstTrazas = new List<CC_TrazaInt__c>();
        
        Id profileId=userinfo.getProfileId();
        String profileName = [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;

        Case reclamacion = [Select Account.CC_NumPerso__c from Case where id = :idRegistro limit 1];

        if(reclamacion != null && reclamacion.Account.CC_NumPerso__c != null ){
            String numPerso = reclamacion.Account.CC_NumPerso__c;
            response.customerId = numPerso;
            responseIntegration = SAC_Contratos_Integration.getTicket(numPerso, profileName);
            response.statusCode = responseIntegration.statusCode;

            if(responseIntegration.ticketCode != null && responseIntegration.statusCode.equalsIgnoreCase('200')){
               
                String codTicket = responseIntegration.ticketCode;
                String numTicket = 'N'+codTicket.substringAfter('N');
                numTicket = numTicket.substring(0, numTicket.length() -2);
                
                responseData = SAC_Contratos_Integration.getContract(numTicket, profileName);
                
                if(responseData.data != null && responseData.statusCode.equalsIgnoreCase('200')){
                    
                    List<SAC_Contratos_Integration.ClsProducts> lstProducts = responseData.data.Products;
                    for(SAC_Contratos_Integration.ClsProducts product : lstProducts){
                        List<DetallesContratosProducto> lstContracts = new List<DetallesContratosProducto>();
                        CustomerProduct prod = new CustomerProduct();
                        if(product.productId != 0){
                        	prod.codProduct = product.productId;
                            prod.nameProduct = product.productDescription;
                            for (SAC_Contratos_Integration.ClsContracts contrato : product.Contracts) {
                                DetallesContratosProducto detallesContrato = new DetallesContratosProducto();
                                if (contrato.balance != null && contrato.balance.size() > 0) {
                                    SAC_Contratos_Integration.ClassBalance balance = contrato.balance[0];
                                    detallesContrato.balance = String.valueOf(balance.amount);
                                }
                                detallesContrato.cancelDate = (contrato.cancelDate == '0') ? '' : contrato.cancelDate;
                                detallesContrato.description = contrato.description;
                                String idDelContrato = String.valueOf(contrato.contractId);
                                String digitoDeControl = String.valueOf(contrato.controlDigit);
                                //controlar si el digito de control viene solo con un numero. Si solo tiene uno, añadir un 0 delante
                                if (digitoDeControl.length() == 1) {
                                    digitoDeControl = '0' + digitoDeControl;
                                }
                                String contratoCompleto = idDelContrato+digitoDeControl;
                                Long idContratoLong = Long.valueOf(contratoCompleto);
                                detallesContrato.id = idContratoLong;
                                detallesContrato.openDate = contrato.openingDate; 
                                lstContracts.add(detallesContrato);
                            }
                            prod.lstContratos = lstContracts;
                            lstProductsMostrar.add(prod);    
                        }
                        
                    }
                    response.lstProducts = lstProductsMostrar;
                }else {
                	response.errorMessage = responseData.errorMessage;
            	} 
            }else {
                response.errorMessage = responseIntegration.errorMessage;
            }    
        }

        if(responseIntegration != null && responseIntegration.trazaTicket != null){
            lstTrazas.add(responseIntegration.trazaTicket);
        }
        
        if(responseData != null && responseData.trazaContrato != null){
            lstTrazas.add(responseData.trazaContrato);
        }
        
        if(!lstTrazas.isEmpty()){
        
            String jsonTrazas = JSON.serialize(lstTrazas);
            SAC_Utils.insertTrazas(jsonTrazas);
        }
        

        return response;
    }

    @AuraEnabled
    public static ResponseDataDetail obtenerDetalleContrato(String numPerso, String codProducto) {

        ResponseDataDetail response = new ResponseDataDetail();
        List<DetallesContratos> lstContratos = new List<DetallesContratos>();

        if(numPerso != null && codProducto != null){

            SAC_Contratos_Integration.ProductDetailResponse responseIntegration = SAC_Contratos_Integration.getCommercialProductDetail(numPerso, codProducto);
            
            response.statusCode = responseIntegration.statusCode;
            
            if(responseIntegration.statusCode.equalsIgnoreCase('200')){
                //Integración devuelve un 200, extraemos los contratos
                response.description = responseIntegration.data.description;
                response.state = responseIntegration.data.state.value;
                response.preconceived = responseIntegration.data.preconceived;
                response.revDate = responseIntegration.data.revDate;
                response.openingDate = responseIntegration.data.openingDate;
                response.isPotential = responseIntegration.data.isPotential;
                response.totalBalance = responseIntegration.data.totalBalance;
                if(responseIntegration.data.Contracts != null && !responseIntegration.data.Contracts.isEmpty()){
                    for(SAC_Contratos_Integration.ClassContracts contrato :responseIntegration.data.Contracts){
                        DetallesContratos detalle = new DetallesContratos();
                        detalle.id = contrato.id;
                        detalle.description = contrato.description;
                        detalle.balance = contrato.balance;
                        lstContratos.add(detalle);
                    }
                    
                }
                if(!lstContratos.isEmpty()){
                    response.contratos = lstContratos;
                }
                
                
            }else{
                //Mapeo el error
                response.errorMessage = responseIntegration.errorMessage;
            }

        }
        
        
        return response; 
    }
    

    @AuraEnabled
    public static void linkarContrato(String idRecord, String tipo, String numContrato, String descripcion) {
        SAC_ProductCase__c producto = new SAC_ProductCase__c();
        producto.SAC_Pretension__c = idRecord;
        producto.SAC_Tipo__c = tipo;
        producto.N_Contrato__c = numContrato;
        producto.SAC_Descripcion__c = descripcion;

        Database.insert(producto);
    }    
}