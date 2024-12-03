public with sharing class CSBD_Infobip_Delivered_DTO {
   
    public DeliveryResult[] results;

	public class DeliveryResult {
		public String bulkId;	//string
		public PriceDTO price;
		public StatusDTO status;
		public ErrorDTO error;
		public String messageId;	//string
		public String to;	//string
		public String sender;	//string
		public String sentAt;	//2024-10-17T17:41:19Z
		public String doneAt;	//2024-10-17T17:41:19Z
		public Integer messageCount;	//00
		public String mccMnc;	//string
		public String callbackData;	//string
		public PlatformDTO platform;
		public String campaignReferenceId;	//string
	}
	public class PriceDTO {
		public String pricePerMessage;	//0
		public String priceCurrency;	//string
	}
	public class StatusDTO {
		public Integer groupId;	//0
		public String groupName;	//ACCEPTED
		public Integer id;	//0
		public String name;	//string
		public String description;	//string
		public String action;	//string
	}
	public class ErrorDTO {
		public Integer groupId;	//0
		public String groupName;	//OK
		public Integer id;	//0
		public String name;	//string
		public String description;	//string
		public boolean permanent;
	}
	class PlatformDTO {
		public String entityId;	//string
		public String applicationId;	//string
	}

	public static CSBD_Infobip_Delivered_DTO parse(String json){
		return (CSBD_Infobip_Delivered_DTO) System.JSON.deserialize(json, CSBD_Infobip_Delivered_DTO.class);
	}
}