/**
*   @author     	IBM
*   @since      	Jun, 2022
*   @description	Clase del servicio de SAC para obtener el detalle de una reclamación de ATR
*   @history    	Jun, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_DetalleReclamacion{

	public class DetalleResponse {

        public String statusCode;
        public String errorMessage;
        public String errorCode;
        public List<Detalle> detalle;
    }

	public class Detalle{

        private String claimCode;
        private String expedient;
        private String claimType;
        private String affectedEntity;
        private String affectedOffice;
        private String originCompany;
        private String affectedCompany;
        private String claimTitle;
        private String claimStatus;
        private String claimSource;
        private String claimDiagnose;
        private String entranceChannel;
        private String claimFamily;
        private String claimProductService;
        private String claimFamilyCause;
        private String causeDetail;
        private List<String> contractNumber;
        private List<String> contractType;
        private String receptionDate;
        private String creationDate;
        private String resolutionDate;
        private String dueDate;
        private String resolutionType;
        private Decimal amountClaimed;
        private Decimal amountPaid;
        private Integer agencyAmountClaimed;	
		private Integer notaryAmountClaimed;	
		private Integer registerAmountClaimed;	
		private Integer agencyAmountPaid;	
		private Integer notaryAmountPaid;
        private Customer customer;
        private Agent agent;
	}

	public class Customer{

        private String customerTypeId;
        private String customerId;
        private String customerName;
        private String customerFirstSurname;
        private String customerSecondSurname;
        private CustomerPhone customerPhone;
	}
    public class CustomerPhone {
	}
	public class Agent{

        private String agentId;
        private String agentName;
        private String agentFirstSurname;
        private String agentSecondSurname;
	}

	public static DetalleResponse getDetalle(String claimCode){
		
		DetalleResponse responseDetalle = new DetalleResponse();
		CC_InterfaceSettings__mdt oConfig   = SAC_Utils.getInterfazConfigBody('SAC_WS_DetalleReclamacion');

		//HEADERS
		Map< String, String > mapHeaders	= new Map< String, String >();
		mapHeaders.put( 'x-absis-auto-profile', 'CBK;OFFICE' );
		mapHeaders.put( 'Content-Type', 'application/json' );
		
		//REQUEST
		HttpRequest request = CBK_HttpServiceIntegration.getRequest('', 'SAC_DetalleReclamacion', 'GET', mapHeaders);
		request.setClientCertificateName(oConfig.CC_Certificado__c);
		request.setEndpoint(oConfig.CC_EndPoint__c + '?claimCode=' + claimCode);

		//RESPONSE
		HTTPResponse response = CBK_HttpServiceIntegration.callHttpService(request, claimCode, 'SAC_DetalleReclamacion');
		String statusCode = String.valueOf(response.getStatusCode());

		if(statusCode.equalsIgnoreCase('200')){
			String responseBody = response.getbody();
            responseDetalle.detalle = (List<SAC_WS_DetalleReclamacion.Detalle>)getBodyResponse(responseBody, 'List<SAC_WS_DetalleReclamacion.Detalle>');
            responseDetalle.statusCode = statusCode;
        }else{
            responseDetalle.statusCode = statusCode;
            responseDetalle.errorCode = 'Error en el servicio.';
            responseDetalle.errorMessage = response.getStatus(); 
        } 
        return responseDetalle;	
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