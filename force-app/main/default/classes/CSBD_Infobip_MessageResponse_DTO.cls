public with sharing class CSBD_Infobip_MessageResponse_DTO {

    public String bulkId;	//a28dd97c-2222-4fcf-99f1-0b557ed381da
	public MessageDTO[] messages;
	class MessageDTO {
		public String messageId;	//a28dd97c-1ffb-4fcf-99f1-0b557ed381da
		public StatusDTO status;
		public String destination;	//441134960001
	}
	class StatusDTO {
		public Integer groupId;	//1
		public String groupName;	//PENDING
		public Integer id;	//26
		public String name;	//PENDING_ACCEPTED
		public String description;	//Message sent to next instance
	}
	public static CSBD_Infobip_MessageResponse_DTO parse(String json){
		return (CSBD_Infobip_MessageResponse_DTO) System.JSON.deserialize(json, CSBD_Infobip_MessageResponse_DTO.class);
	}
}

/*public class fromJSON{


	static testMethod void testParse() {
		String json=		'{'+
		'  "bulkId": "a28dd97c-2222-4fcf-99f1-0b557ed381da",'+
		'  "messages": ['+
		'    {'+
		'      "messageId": "a28dd97c-1ffb-4fcf-99f1-0b557ed381da",'+
		'      "status": {'+
		'        "groupId": 1,'+
		'        "groupName": "PENDING",'+
		'        "id": 26,'+
		'        "name": "PENDING_ACCEPTED",'+
		'        "description": "Message sent to next instance"'+
		'      },'+
		'      "destination": "441134960001"'+
		'    }'+
		'  ]'+
		'}';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}
}*/