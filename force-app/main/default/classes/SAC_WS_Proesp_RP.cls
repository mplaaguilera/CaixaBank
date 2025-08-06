/**
*   @author     	IBM
*   @since      	Jan, 2022
*   @description	Clase para generar la respuesta del servicio de antecedentes
*   @history    	Jan, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_Proesp_RP{

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
		private List<String> subjects;
        private String procCode;
        private String expedient;
        private String product;
        private String procStatus;
        private List<procResponseDocumentsWrapper> procResponseDocuments;
        private List<ResolutionDocumentsWrapper> resolutionDocuments;
        private String creationDate;
        private String dueDate;
		private CC_TrazaInt__c traza;

		public ClaimWrapper(CC_TrazaInt__c traza){
			this.traza = traza;
		}

		public ClaimWrapper( List<String> customerIds, List<String> contracts, List<String> subjects, String procCode, String expedient, String product, String procStatus, List<procResponseDocumentsWrapper> procResponseDocuments, List<ResolutionDocumentsWrapper> resolutionDocuments, String creationDate, String dueDate ){
			this.customerIds	= customerIds;
			this.contracts	= contracts;
            this.subjects	= subjects;
            this.procCode = procCode;
            this.expedient = expedient;
            this.product = product;
            this.procStatus = procStatus;
            this.procResponseDocuments = procResponseDocuments;
            this.resolutionDocuments = resolutionDocuments;
            this.creationDate = creationDate;
			this.dueDate = dueDate;
		}

		public List<String> getCustomerIds(){
			return this.customerIds;
		}

		public List<String> getContracts(){
			return this.contracts;
		}

        public List<String> getSubjects(){
			return this.subjects;
		}

        public String getProcCode(){
			return this.procCode;
		}

		public String getExpedient(){
			return this.expedient;
		}

		public String getProduct(){
			return this.product;
		}

		public String getProcStatus(){
			return this.procStatus;
		}

        public List<ProcResponseDocumentsWrapper> getProcResponseDocuments(){
			return this.procResponseDocuments;
		}

		public List<ResolutionDocumentsWrapper> getResolutionDocuments(){
			return this.resolutionDocuments;
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
	*   @description	Clase para generar el wrapper de los datos del resultado
	*   @history    	Jan, 2022 - IBM - Create Apex Class 
	*/
	public class ProcResponseDocumentsWrapper{
		private String fileName;
		private String downloadLink;

		public ProcResponseDocumentsWrapper( String fileName, String downloadLink ){
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