public with sharing class CSBD_Infobip_Message_DTO {

    public MessageDTO[] messages;

	public class MessageDTO{
		public String sender;	//441134960000
		public DestinationsDTO[] destinations;
		public ContentDTO content;
		public OptionDTO options;
		public WebhookDTO webhooks;
	}

	
	public class DestinationsDTO {
		public String to;	//441134960001
	}
	public class ContentDTO {	
		public String type;	//CARD
		public String orientation;	//VERTICAL
		public String alignment;	//LEFT
		public ContentInnerDTO content;		
	}

	public class ContentInnerDTO {
		public String title;	//Some title
		public String description;	//Some description
		public MediaDTO media;
	}

	public class MediaDTO {
		public FileDTO file;
		//public ThumbnailDTO thumbnail;
		public String height;	//TALL
	}
	public class FileDTO {
		public String url;	//https://www.example.com/video.mp4
	}

	public class OptionDTO {
		public SMSFailoverDTO smsFailover;
		public ValidityPeriodDTO validityPeriod;
	}
    
	public class SMSFailoverDTO {
		public String sender;
		public String text;
	}

	public class ValidityPeriodDTO{
		public Integer amount;
		public String timeUnit;
	}

	public class WebhookDTO{
		public String callbackData;
	}

	public CSBD_Infobip_Message_DTO(){
		this.messages = new List<MessageDTO>();
		MessageDTO message = new MessageDTO();

		message.destinations = new List<DestinationsDTO>();
		message.content = new ContentDTO();
		message.content.content = new ContentInnerDTO();
		message.content.content.media = new MediaDTO();
		message.content.content.media.file = new FileDTO();
		message.options = new OptionDTO();
		message.options.smsFailover = new SMSFailoverDTO();
		message.options.validityPeriod = new ValidityPeriodDTO();
		message.webhooks = new WebhookDTO();

		this.messages.add(message);
	}
}