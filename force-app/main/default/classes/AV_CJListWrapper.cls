/**********************************************************************************************************************
Name:	  AV_CJListWrapper
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Wrapper of list of customer journeys
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			CJ			   Jashanpreet Singh  	03/02/2021		Init version
***********************************************************************************************************************/
public class AV_CJListWrapper {

	public Envelope Envelope; 
	
	public class FK_LookUpCJs_Boap {
		public String productGroupName; 
	}
	
	public class FK_BriefOnPage_ProductGroup {
		public FK_Recipient_LookUpCJs FK_Recipient_LookUpCJs; 
	}
	
	public class FK_Recipient_LookUpCJs {
		public FK_LookUpCJs_Boap FK_LookUpCJs_Boap; 
	}
	
	public class Recipient {
		public FK_LookUpCJs_Boap_X FK_LookUpCJs_Boap; 
		public String boapId; 
		public String status; 
	}
	
	public class Acresults {
		public Global_Z global_Z; // in json: global
		public Acresult acresult; 
	}
	
	public class Acresults_Z {
		public Acresults acresults; 
		public String type_Z; // in json: type
		public String encodingStyle; 
	}
	
	public class FK_BriefOnPage_ProductSubGroup {
		public FK_Recipient_LookUpCJs_Z FK_Recipient_LookUpCJs; 
	}
	
	public class Envelope {
		public Body Body; 
	}
	
	public class Global_Z {
		public String code; 
		public String message; 
	}
	
	public class Result {
		public List<Recipient> recipient; 
		public String id; 
		public String numperso; 

	}
	
	public class FK_Recipient_LookUpCJs_Z {
		public FK_LookUpCJs_Boap_Z FK_LookUpCJs_Boap; 
	}
	
	public class FK_Recipient_LookUpCJs_Y {
		public FK_LookUpCJs_Boap_Y FK_LookUpCJs_Boap; 
    }
	
	public class FK_LookUpCJs_Boap_X {
		public FK_BriefOnPage_ProductGroup FK_BriefOnPage_ProductGroup; 
		public FK_BriefOnPage_ProductSubGroup FK_BriefOnPage_ProductSubGroup; 
		public FK_BriefOnPage_Product FK_BriefOnPage_Product; 
		public String document; 
		public String duration; 
		public String id; 
		public String label; 
	}
	
	public class FK_LookUpCJs_Boap_Y {
		public String productName; 
	}
	
	public class FK_LookUpCJs_Boap_Z {
		public String productSubGroupName; 
	}
	
	public class LookUpCJResponse {
		public Acresults_Z acresults; 
		public String encodingStyle; 
	}
	
	public class FK_BriefOnPage_Product {
		public FK_Recipient_LookUpCJs_Y FK_Recipient_LookUpCJs; 
	}
	
	public class Acresult {
		public String code; 
		public String message; 
		public Result result; 
	}
	
	public class Body {
		public LookUpCJResponse lookUpCJResponse; 
	}
}