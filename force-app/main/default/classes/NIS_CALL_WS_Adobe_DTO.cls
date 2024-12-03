public  class NIS_CALL_WS_Adobe_DTO {
    //REQUEST
    public class RequestDTO {
        public HeaderDTO header { get; set; }
        public BodyDTO body { get; set; }
		
	}

    //header
    public class HeaderDTO {
        public SchemaRefDTO schemaRef { get; set; }
		public String flowId { get; set; }
        public String datasetId { get; set; }
	}

    //Body
    public class BodyDTO {
		public XdmMetaDTO xdmMeta { get; set; }
        public XdmEntityDTO xdmEntity { get; set; }
	}

    
    public class XdmMetaDTO {
		public SchemaRefDTO schemaRef { get; set; }
	}

    //xdmEntity
    public class XdmEntityDTO {
		public CaixaDTO v_caixa { get; set; }
        public String v_id { get; set; }
        public String eventMergeId { get; set; }
        public String eventType { get; set; }
        //public IdentityMapDTO identityMap { get; set; }
        public NumperDTO identityMap { get; set; }
        public String producedBy { get; set; }
        public String timestamp { get; set; }
	}

    //_caixa
    public class CaixaDTO {
        public MessageDeliveryFeedbackObjDTO messageDeliveryfeedbackObj { get; set; }
        public MessageExclusionObjDTO messageExclusionObj { get; set; }
        public MessageExecutionObjDTO messageExecutionObj { get; set; }
        public MessageFailureObjDTO messageFailureObj { get; set; }
        public MessageProfileObjDTO messageProfileObj { get; set; }
	}

    public class MessageDeliveryFeedbackObjDTO {
		public string agencyFeedback { get; set; }
        public string deliverynInternalName { get; set; }
        public string eventDateTime { get; set; }
        public string experienceChannelType { get; set; }
        public string feedbackStatus { get; set; }
        public string origin { get; set; }
	}
    public class MessageExclusionObjDTO {
		public string code { get; set; }
        public string reason { get; set; }  
	}
    public class MessageExecutionObjDTO {
		public string batchInstanceID { get; set; }
        public string campaignActionID { get; set; }
        public string campaignID { get; set; }
        public string campaignVersionID { get; set; }
        public string journeyActionID { get; set; }
        public string journeyVersionID { get; set; }
        public string journeyVersionInstanceID { get; set; }
        public string journeyVersionNodeID { get; set; }
        public string messageExecutionID { get; set; }
        public string messageID { get; set; }
        public string messagePublicationID { get; set; }
        public string messageType { get; set; }
	}
    public class MessageFailureObjDTO {
		public string category { get; set; }
        public string code { get; set; }
        public string type { get; set; } 
	}
    public class MessageProfileObjDTO {
		public string email { get; set; }
        public Boolean isCG { get; set; }
        public Boolean isSeedMember { get; set; }
        public Boolean isTestExecution { get; set; }
        public string messageProfileID { get; set; }
        public string numperso { get; set; } 
	}

    public class NumperDTO {
        public List<NumperInfoDTO> numper { get; set; } 
	}

    public class NumperInfoDTO {
        public string authenticatedState { get; set; }
        public string id { get; set; }
        public Boolean primary { get; set; }
	}
    
    //schemaRef
    public class SchemaRefDTO {
		public String id { get; set; }
        public String contentType { get; set; }
	}
}