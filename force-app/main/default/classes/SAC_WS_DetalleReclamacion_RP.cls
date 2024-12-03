/**
*   @author     	IBM
*   @since      	Jun, 2022
*   @description	Clase para generar la respuesta del servicio de detalle de la reclamación de ATR
*   @history    	Jun, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_DetalleReclamacion_RP{

	/**
		* @description deserializar respuesta
		* @param jsonBody : contenido de la respuesta
		* @return wrapper con los datos de la respuesta
	*/
	public static List<ResponseWrapper> deserialize( String jsonBody ){
		return ( (List<ResponseWrapper>) JSON.deserialize( jsonBody, List<ResponseWrapper>.class ) );
	}

	/**
	*   @author     	IBM
	*   @since      	Jun, 2022
	*   @description	Clase para generar el wrapper de los datos de informacion
	*   @history    	Jun, 2022 - IBM - Create Apex Class 
	*/
	public class ResponseWrapper{

        private String claimCode;
        private String expedient;
        private String claimType;
        private String affectedEntity;
        private String originCompany;
        private String affectedCompany;
        private String claimStatus;
        private String claimSource;
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
        private Customer customer;
        private Agent agent;
        private CC_TrazaInt__c traza;

		public ResponseWrapper(CC_TrazaInt__c traza){
			this.traza = traza;
		}

		public ResponseWrapper( String claimCode, String expedient, String claimType, String affectedEntity, String originCompany, String affectedCompany, String claimStatus, String claimSource, String entranceChannel, String claimFamily, String claimProductService, String claimFamilyCause, String causeDetail, List<String> contractNumber, List<String> contractType, String receptionDate, String creationDate, String resolutionDate, String dueDate, String resolutionType, Decimal amountClaimed, Decimal amountPaid, Customer customer, Agent agent){
			this.claimCode = claimCode;
            this.expedient = expedient;
            this.claimType = claimType;
            this.affectedEntity = affectedEntity;
            this.originCompany = originCompany;
            this.affectedCompany = affectedCompany;
            this.claimStatus = claimStatus;
            this.claimSource = claimSource;
            this.entranceChannel = entranceChannel;
            this.claimFamily = claimFamily;
            this.claimProductService = claimProductService;
            this.claimFamilyCause = claimFamilyCause;
            this.causeDetail = causeDetail;
            this.contractNumber = contractNumber;
            this.contractType = contractType;
            this.receptionDate = receptionDate;
            this.creationDate = creationDate;
            this.resolutionDate = resolutionDate;
            this.dueDate = dueDate;
            this.resolutionType = resolutionType;
            this.amountClaimed = amountClaimed;
            this.amountPaid = amountPaid;
            this.customer = customer;
            this.agent = agent;
		}

		public String getClaimCode(){
			return this.claimCode;
		}

		public String getExpedient(){
			return this.expedient;
		}

        public String getClaimType(){
			return this.claimType;
		}

        public String getaffectedEntity(){
			return this.affectedEntity;
		}

        public String getoriginCompany(){
			return this.originCompany;
		}

        public String getaffectedCompany(){
			return this.affectedCompany;
		}

        public String getclaimStatus(){
			return this.claimStatus;
		}

        public String getclaimSource(){
			return this.claimSource;
		}

        public String getentranceChannel(){
			return this.entranceChannel;
		}

        public String getclaimFamily(){
			return this.claimFamily;
		}

        public String getclaimProductService(){
			return this.claimProductService;
		}

        public String getclaimFamilyCause(){
			return this.claimFamilyCause;
		}

        public String getcauseDetail(){
			return this.causeDetail;
		}

        public List<String> getcontractNumber(){
			return this.contractNumber;
		}

        public List<String> getcontractType(){
			return this.contractType;
		}

        public String getreceptionDate(){
			return this.receptionDate;
		}

        public String getcreationDate(){
			return this.creationDate;
		}

        public String getresolutionDate(){
			return this.resolutionDate;
		}

        public String getdueDate(){
			return this.dueDate;
		}

        public String getresolutionType(){
			return this.resolutionType;
		}

        public Decimal getamountClaimed(){
			return this.amountClaimed;
		}

        public Decimal getamountPaid(){
			return this.amountPaid;
		}

        public Customer getCustomer(){
			return this.customer;
		}

        public Agent getAgent(){
			return this.agent;
		}

		public CC_TrazaInt__c getTraza(){
			return this.traza;
		}

		public void setTraza(CC_TrazaInt__c traza){
			this.traza = traza;
		}
	}

    public class Customer{

        private String customerTypeId;
        private String customerId;
        private String customerName;
        private String customerFirstSurname;
        private String customerSecondSurname;

        public Customer( String customerTypeId, String customerId, String customerName, String customerFirstSurname, String customerSecondSurname){
			this.customerTypeId = customerTypeId;
            this.customerId = customerId;
            this.customerName = customerName;
            this.customerFirstSurname = customerFirstSurname;
            this.customerSecondSurname = customerSecondSurname;
		}

        public String getcustomerTypeId(){
			return this.customerTypeId;
		}

		public String getcustomerId(){
			return this.customerId;
		}

        public String getcustomerName(){
			return this.customerName;
		}

        public String getcustomerFirstSurname(){
			return this.customerFirstSurname;
		}

        public String getcustomerSecondSurname(){
			return this.customerSecondSurname;
		}

    }

    public class Agent{

        private String agentId;
        private String agentName;
        private String agentFirstSurname;
        private String agentSecondSurname;

        public Agent( String agentId, String agentName, String agentFirstSurname, String agentSecondSurname){
			this.agentId = agentId;
            this.agentName = agentName;
            this.agentFirstSurname = agentFirstSurname;
            this.agentSecondSurname = agentSecondSurname;
		}

        public String getagentId(){
			return this.agentId;
		}

		public String getagentName(){
			return this.agentName;
		}

        public String getagentFirstSurname(){
			return this.agentFirstSurname;
		}

        public String getagentSecondSurname(){
			return this.agentSecondSurname;
		}

    }

}