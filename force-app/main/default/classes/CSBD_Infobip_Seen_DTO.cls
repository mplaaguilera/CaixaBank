public with sharing class CSBD_Infobip_Seen_DTO {

    public SeenResult[] results;

    public class SeenResult {
        public String messageId;	//string
        public String fromAdd;	//string
        public String toAdd;	//string
        public String sentAt;	//2024-10-17T17:41:50Z
        public String seenAt;	//2024-10-17T17:41:50Z
        public String applicationId;	//string
        public String entityId;	//string
        public String campaignReferenceId;	//string
    }

    public static CSBD_Infobip_Seen_DTO parse(String json){
        return (CSBD_Infobip_Seen_DTO) System.JSON.deserialize(json, CSBD_Infobip_Seen_DTO.class);
    }

}