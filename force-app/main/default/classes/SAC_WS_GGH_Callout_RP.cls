/**
*   @author     	IBM
*   @since      	May, 2022
*   @description	Clase para generar la respuesta del servicio callout de GGH
*   @history    	May, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_GGH_Callout_RP{

	/**
		* @description deserializar respuesta
		* @param jsonBody : contenido de la respuesta
		* @return wrapper con los datos de la respuesta
	*/
	public static GGHResponse deserialize( String jsonBody ){
		return ( (GGHResponse) JSON.deserialize( jsonBody, GGHResponse.class ) );
	}

	/**
	*   @author     	IBM
	*   @since      	May, 2022
	*   @description	Clase para generar el wrapper de los datos de informacion
	*   @history    	May, 2022 - IBM - Create Apex Class 
	*/
	public class GGHResponse{

        private String idPretension {get;set;}
        private Boolean result {get;set;}
        private String error {get;set;}
        private String tipoGestion {get;set;}
        private CC_TrazaInt__c traza;

		public GGHResponse(CC_TrazaInt__c traza){
			this.traza = traza;
		}

		public GGHResponse( String idPretension, Boolean result, String error, String tipoGestion){
			this.idPretension	= idPretension;
			this.result	= result;
            this.error	= error;
            this.tipoGestion = tipoGestion;
		}

		public String getidPretension(){
			return this.idPretension;
		}

		public Boolean getResult(){
			return this.result;
		}

        public String gestError(){
			return this.error;
		}

        public String getTipoGestion(){
			return this.tipoGestion;
		}

		public CC_TrazaInt__c getTraza(){
			return this.traza;
		}

		public void setTraza(CC_TrazaInt__c traza){
			this.traza = traza;
		}
	}

}