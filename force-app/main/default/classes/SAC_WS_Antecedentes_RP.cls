/**
*   @author     	IBM
*   @since      	Jan, 2022
*   @description	Clase para generar la respuesta del servicio de antecedentes
*   @history    	Jan, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_Antecedentes_RP{

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
		@AuraEnabled
		public List<String> customerIds;
		@AuraEnabled
		public String claimCode;
		@AuraEnabled
        public String expedient;
        @AuraEnabled
        public String affectedOffice;
        @AuraEnabled
        public String resolutionType;
        @AuraEnabled
        public String productService;
        @AuraEnabled
        public String causeDetail;
        @AuraEnabled
        public String claimStatus;
        @AuraEnabled
        public List<ClaimDocumentsWrapper> claimDocuments;
        @AuraEnabled
        public List<ResolutionDocumentsWrapper> resolutionDocuments;
        @AuraEnabled
        public Decimal claimAmount;
        @AuraEnabled
        public Decimal returnedAmount;
        @AuraEnabled
        public String creationDate;
		@AuraEnabled
        public String dueDate;
        @AuraEnabled
        public String claimType;
		@AuraEnabled
		public String responsibleParty;
        @AuraEnabled
		public String managementOffice;
		@AuraEnabled
		public String receptionDate;
		private CC_TrazaInt__c traza;

		public ClaimWrapper(CC_TrazaInt__c traza){
			this.traza = traza;
		}

		public ClaimWrapper( List<String> customerIds, String claimCode, String expedient, String affectedOffice, String resolutionType, String productService, String causeDetail, String claimStatus, List<ClaimDocumentsWrapper> claimDocuments, List<ResolutionDocumentsWrapper> resolutionDocuments, Decimal claimAmount, Decimal returnedAmount, String creationDate, String dueDate, String claimType, String responsibleParty, String managementOffice, String receptionDate){
			this.customerIds	= customerIds;
			this.claimCode	= claimCode;
            this.expedient = expedient;
			this.affectedOffice = affectedOffice;
            this.resolutionType = resolutionType;
            this.productService = productService;
            this.causeDetail = causeDetail;
            this.claimStatus = claimStatus;
            this.claimDocuments = claimDocuments;
            this.resolutionDocuments = resolutionDocuments;
            this.claimAmount = claimAmount;
            this.returnedAmount = returnedAmount;
            this.creationDate = creationDate;
			this.dueDate = dueDate;
            this.claimType = claimType;
			this.responsibleParty = responsibleParty;
            this.managementOffice = managementOffice;
			this.receptionDate = receptionDate;
		}

		public List<String> getCustomerIds(){
			return this.customerIds;
		}

		public String getClaimCode(){
			return this.claimCode;
		}

		public String getExpedient(){
			return this.expedient;
		}

		public String getAffectedOffice(){
			return this.affectedOffice;
		}

		public String getResolutionType(){
			return this.resolutionType;
		}

		public String getProductService(){
			return this.productService;
		}

		public String getCauseDetail(){
			return this.causeDetail;
		}

		public String getClaimStatus(){
			return this.claimStatus;
		}

		public List<ClaimDocumentsWrapper> getClaimDocuments(){
			return this.claimDocuments;
		}

		public List<ResolutionDocumentsWrapper> getResolutionDocuments(){
			return this.resolutionDocuments;
		}

		public Decimal getClaimAmount(){
			return this.claimAmount;
		}

		public Decimal getReturnedAmount(){
			return this.returnedAmount;
		}

		public String getCreationDate(){
			return this.creationDate;
		}

		public String getDueDate(){
			return this.dueDate;
		}

		public String getClaimType(){
			return this.claimType;
		}

		public CC_TrazaInt__c getTraza(){
			return this.traza;
		}

		public String getResponsibleParty(){
			return this.responsibleParty;
		}
        
        public String getManagementOffice(){
			return this.managementOffice;
		}

		public String getReceptionDate(){
			return this.receptionDate;
		}

		public void setTraza(CC_TrazaInt__c traza){
			this.traza = traza;
		}

	}

	/**
	*   @author     	IBM
	*   @since      	Jan, 2022
	*   @description	Clase para generar el wrapper de los datos del resultado
	*   @history    	Jan, 2022 - IBM - Create Apex Class 
	*/
	public class ClaimDocumentsWrapper{
		@AuraEnabled
        public String fileName;
		@AuraEnabled
        public String downloadLink;

		public ClaimDocumentsWrapper( String fileName, String downloadLink ){
			this.fileName			= fileName;
			this.downloadLink		= downloadLink;
		}

		public String getFileName(){
			return this.fileName;
		}

		public String getDownloadLink(){
			return this.downloadLink;
		}
    }
	/**
	*   @author     	IBM
	*   @since      	Jan, 2022
	*   @description	Clase para generar el wrapper de los datos de la respuesta
	*   @history    	Jan, 2022 - IBM - Create Apex Class 
	*/
	public class ResolutionDocumentsWrapper{
		@AuraEnabled
        public String fileName;
		@AuraEnabled
        public String downloadLink;

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