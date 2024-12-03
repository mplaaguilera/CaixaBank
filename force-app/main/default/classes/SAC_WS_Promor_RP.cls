/**
*   @author     	IBM
*   @since      	Jan, 2022
*   @description	Clase para generar la respuesta del servicio de antecedentes
*   @history    	Jan, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_Promor_RP{

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
		private String claimCode;
        private String affectedOffice;
        private String product;
        private String claimStatus;
        private List<ResolutionDocumentsWrapper> resolutionDocuments;
        private Decimal claimAmount;
        private String creationDate;
        private String dueDate;
		private CC_TrazaInt__c traza;

		public ClaimWrapper(CC_TrazaInt__c traza){
			this.traza = traza;
		}

		public ClaimWrapper( List<String> customerIds, List<String> contracts, String claimCode, String affectedOffice, String product, String claimStatus, List<ResolutionDocumentsWrapper> resolutionDocuments, Decimal claimAmount, String creationDate, String dueDate ){
			this.customerIds	= customerIds;
			this.contracts	= contracts;
            this.claimCode	= claimCode;
            this.affectedOffice = affectedOffice;
            this.product = product;
            this.claimStatus = claimStatus;
            this.resolutionDocuments = resolutionDocuments;
            this.claimAmount = claimAmount;
            this.creationDate = creationDate;
			this.dueDate = dueDate;
		}

		public List<String> getCustomerIds(){
			return this.customerIds;
		}

		public List<String> getContracts(){
			return this.contracts;
		}

        public String getClaimCode(){
			return this.claimCode;
		}

        public String getAffectedOffice(){
			return this.affectedOffice;
		}

		public String getProduct(){
			return this.product;
		}

		public String getClaimStatus(){
			return this.claimStatus;
		}

		public List<ResolutionDocumentsWrapper> getResolutionDocuments(){
			return this.resolutionDocuments;
		}

        public Decimal getClaimAmount(){
            return this.claimAmount;
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

	/**
	*   @author     	IBM
	*   @since      	Jan, 2022
	*   @description	Clase para generar el wrapper de los datos de la respuesta
	*   @history    	Jan, 2022 - IBM - Create Apex Class 
	*/
	public class ResolutionDocumentsWrapper{
		private String fileName;
		private String downloadLink;

		public ResolutionDocumentsWrapper( String fileName, String downloadLink ){
			this.fileName		= fileName;
			this.downloadLink	= downloadLink;
		}

		public String getFileName(){
			return this.fileName;
		}

		public String getDownloadLink(){
			return this.downloadLink;
		}
	}

}