public with sharing class CSBD_CALL_WS_Adobe_DTO {
    //REQUEST
    public class RequestDTO {
        public HeaderDTO header {get;set;}
        public BodyDTO body {get;set;}

        public RequestDTO(HeaderDTO header, BodyDTO body) {
            this.header = header;
            this.body = body;
        }
	}

    //header
    public class HeaderDTO {
        public SchemaRefDTO schemaRef {get;set;}
		public String flowId {get;set;}
        public String datasetId {get;set;}

        public HeaderDTO(SchemaRefDTO schemaRef, String flowId, String datasetId) {
            this.schemaRef = schemaRef;
            this.flowId = flowId;
            this.datasetId = datasetId;
        }
	}

    //Body
    public class BodyDTO {
		public XdmMetaDTO xdmMeta {get;set;}
        public XdmEntityDTO xdmEntity {get;set;}

        public BodyDTO(XdmMetaDTO xdmMeta, XdmEntityDTO xdmEntity) {
            this.xdmMeta = xdmMeta;
            this.xdmEntity = xdmEntity;
        }
	}

    public class XdmMetaDTO {
		public SchemaRefDTO schemaRef {get;set;}

        public XdmMetaDTO(SchemaRefDTO schemaRef) {
            this.schemaRef = schemaRef;
        }
	}

    //xdmEntity
    public class XdmEntityDTO {
		public CaixaDTO v_caixa {get;set;}
        public String v_id {get;set;}
        public String eventMergeId {get;set;}
        public String eventType {get;set;}
        public NumperDTO identityMap {get;set;}
        public String producedBy {get;set;}
        public String timestamp {get;set;}

        public XdmEntityDTO(CaixaDTO v_caixa, String v_id, String eventMergeId, String eventType, NumperDTO identityMap, String producedBy, String timestamp) {
            this.v_caixa = v_caixa;
            this.v_id = v_id;
            this.eventMergeId = eventMergeId;
            this.eventType = eventType;
            this.identityMap = identityMap;
            this.producedBy = producedBy;
            this.timestamp = timestamp;
        }
    }

        //_caixa
        public class CaixaDTO {
        public MessageDeliveryFeedbackObjDTO messageDeliveryfeedbackObj {get;set;}
        public MessageExclusionObjDTO messageExclusionObj {get;set;}
        public MessageExecutionObjDTO messageExecutionObj {get;set;}
        public MessageFailureObjDTO messageFailureObj {get;set;}
        public MessageProfileObjDTO messageProfileObj {get;set;}

        public CaixaDTO(MessageDeliveryFeedbackObjDTO messageDeliveryfeedbackObj, MessageExclusionObjDTO messageExclusionObj, MessageExecutionObjDTO messageExecutionObj, MessageFailureObjDTO messageFailureObj, MessageProfileObjDTO messageProfileObj) {
            this.messageDeliveryfeedbackObj = messageDeliveryfeedbackObj;
            this.messageExclusionObj = messageExclusionObj;
            this.messageExecutionObj = messageExecutionObj;
            this.messageFailureObj = messageFailureObj;
            this.messageProfileObj = messageProfileObj;
        }
	}

    public class MessageDeliveryFeedbackObjDTO {
		public String agencyFeedback {get;set;}
        public String deliverynInternalName {get;set;}
        public String eventDateTime {get;set;}
        public String experienceChannelType {get;set;}
        public String feedbackStatus {get;set;}
        public String origin {get;set;}

        public MessageDeliveryFeedbackObjDTO(String agencyFeedback, String deliverynInternalName, String eventDateTime, String experienceChannelType, String feedbackStatus, String origin) {
            this.agencyFeedback = agencyFeedback;
            this.deliverynInternalName = deliverynInternalName;
            this.eventDateTime = eventDateTime;
            this.experienceChannelType = experienceChannelType;
            this.feedbackStatus = feedbackStatus;
            this.origin = origin;
        }
	}

    public class MessageExclusionObjDTO {
		public String code {get;set;}
        public String reason {get;set;}

        public MessageExclusionObjDTO(String code, String reason) {
            this.code = code;
            this.reason = reason;
        }
	}

    public class MessageExecutionObjDTO {
		public String batchInstanceID {get;set;}
        public String campaignActionID {get;set;}
        public String campaignID {get;set;}
        public String campaignVersionID {get;set;}
        public String journeyActionID {get;set;}
        public String journeyVersionID {get;set;}
        public String journeyVersionInstanceID {get;set;}
        public String journeyVersionNodeID {get;set;}
        public String messageExecutionID {get;set;}
        public String messageID {get;set;}
        public String messagePublicationID {get;set;}
        public String messageType {get;set;}

        public MessageExecutionObjDTO(
            String batchInstanceID, String campaignActionID, String campaignID, String campaignVersionID, String journeyActionID, String journeyVersionID, String journeyVersionInstanceID, String journeyVersionNodeID, String messageExecutionID, String messageID, String messagePublicationID, String messageType) {
            this.batchInstanceID = batchInstanceID;
            this.campaignActionID = campaignActionID;
            this.campaignID = campaignID;
            this.campaignVersionID = campaignVersionID;
            this.journeyActionID = journeyActionID;
            this.journeyVersionID = journeyVersionID;
            this.journeyVersionInstanceID = journeyVersionInstanceID;
            this.journeyVersionNodeID = journeyVersionNodeID;
            this.messageExecutionID = messageExecutionID;
            this.messageID = messageID;
            this.messagePublicationID = messagePublicationID;
            this.messageType = messageType;
        }
	}

    public class MessageFailureObjDTO {
		public String category {get;set;}
        public String code {get;set;}
        public String type {get;set;}

        public MessageFailureObjDTO(String category, String code, String type) {
            this.category = category;
            this.code = code;
            this.type = type;
        }
	}

    public class MessageProfileObjDTO {
		public String email {get;set;}
        public Boolean isCG {get;set;}
        public Boolean isSeedMember {get;set;}
        public Boolean isTestExecution {get;set;}
        public String messageProfileID {get;set;}
        public String numperso {get;set;}

        public MessageProfileObjDTO(String email, Boolean isCG, Boolean isSeedMember, Boolean isTestExecution, String messageProfileID, String numperso) {
            this.email = email;
            this.isCG = isCG;
            this.isSeedMember = isSeedMember;
            this.isTestExecution = isTestExecution;
            this.messageProfileID = messageProfileID;
            this.numperso = numperso;
        }
	}

    public class NumperDTO {
        public List<NumperInfoDTO> numper {get;set;}

        public NumperDTO(List<NumperInfoDTO> numper) {
            this.numper = numper;
        }
	}

    public class NumperInfoDTO {
        public String authenticatedState {get;set;}
        public String id {get;set;}
        public Boolean primary {get;set;}

        public NumperInfoDTO(String authenticatedState, String id, Boolean primary) {
            this.authenticatedState = authenticatedState;
            this.id = id;
            this.primary = primary;
        }
	}

    //schemaRef
    public class SchemaRefDTO {
		public String id {get;set;}
        public String contentType {get;set;}

        public SchemaRefDTO(String id, String contentType) {
            this.id = id;
            this.contentType = contentType;
        }
	}

    /*
    //RESPONSE
    public class ResponseOKDTO {
		public String inletId {get;set;}
        public String xactionId {get;set;}
        public String flowId {get;set;}
        public String receivedTimeMs {get;set;}
	}
    */
}