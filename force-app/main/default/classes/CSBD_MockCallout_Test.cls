/**********************************************************************************************************************
Name:	  CSBD_MockCallout_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de integraciones
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0			Test Class	   Esperanza Conde	   	24/02/2022		Init version
***********************************************************************************************************************/
@isTest
public class CSBD_MockCallout_Test implements HttpCalloutMock {
	
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
	public CSBD_MockCallout_Test(String option, String status) {
		this.option = option;
		this.status = status;
	}

	public static final String RESPONSE_COGNITIVO 	= '{"sr": "2-912076545","model_name": "model-001","category": "UAFE Confirming","categories": [{"category": "UAFE Confirming", "ratio": "0.52114"},{"category": "UAFE Factoring", "ratio": "0.22389"},{"category": "UAFE Grandes Clientes", "ratio": "0.20729"},{"category": "UAFE Sucursales Internacionales", "ratio": "0.02778"},{"category": "UAFE Export Finance", "ratio": "0.01109"},{"category": "UAFE Cartera de Efectos", "ratio": "0.00698"},{"category": "UAFE Clasificador", "ratio": "0.00155"},{"category": "Robot no encontrado", "ratio": "0.00027"}]}';
	public static final String RESPONSE_ERROR		= '{"mensaje": "Error","tipo": "XXXXX"}';	
	
    public HTTPResponse respond(HTTPRequest request) {
		// Create a fake response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		if(option == 'COGNITIVO' && status == 'OK'){
			response.setBody(RESPONSE_COGNITIVO);
            response.setStatusCode(200); 
		}
        
		if(status == 'KO'){
			response.setBody(RESPONSE_ERROR);
			response.setStatusCode(500); 
		}
		
		return response; 
	}
}