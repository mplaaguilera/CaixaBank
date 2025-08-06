/**
*   @author     	IBM
*   @since      	Jan, 2022
*   @description	Clase para generar la respuesta del servicio de antecedentes
*   @history    	Jan, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_Gescon_RP{

	/**
		* @description deserializar respuesta
		* @param jsonBody : contenido de la respuesta
		* @return wrapper con los datos de la respuesta
	*/
	public static List<ClaimWrapper> deserialize( String jsonBody ){
		return ( (List<ClaimWrapper>) JSON.deserialize( jsonBody, List<ClaimWrapper>.class ) );
	}

	/**
	*   @author     	IBM
	*   @since      	Jan, 2022
	*   @description	Clase para generar el wrapper de los datos de informacion
	*   @history    	Jan, 2022 - IBM - Create Apex Class 
	*/
	public class ClaimWrapper{

        private List<String> customerIds;
		private List<String> contracts;
		private String procCode;
        private String expedient;
        private String procPhase;
        private String procStatus;
        private String creationDate;
        private String dueDate;
		private CC_TrazaInt__c traza;

		public ClaimWrapper(CC_TrazaInt__c traza){
			this.traza = traza;
		}

		public ClaimWrapper( List<String> customerIds, List<String> contracts, String procCode, String expedient, String procPhase, String procStatus, String creationDate, String dueDate ){
			this.customerIds	= customerIds;
			this.contracts	= contracts;
            this.procCode = procCode;
            this.expedient = expedient;
			this.procPhase = procPhase;
            this.procStatus = procStatus;
            this.creationDate = creationDate;
			this.dueDate = dueDate;
		}

		public List<String> getCustomerIds(){
			return this.customerIds;
		}

		public List<String> getContracts(){
			return this.contracts;
		}

        public String getProcCode(){
			return this.procCode;
		}

		public String getExpedient(){
			return this.expedient;
		}

		public String getProcPhase(){
			return this.procPhase;
		}

		public String getProcStatus(){
			return this.procStatus;
		}

		public String getCreationDate(){
			return this.creationDate;
		}

		public String getDueDate(){
			return this.dueDate;
		}

		public CC_TrazaInt__c getTraza(){
			return this.traza;
		}

		public void setTraza(CC_TrazaInt__c traza){
			this.traza = traza;
		}

	}

}