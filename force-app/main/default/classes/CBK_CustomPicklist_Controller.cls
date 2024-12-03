public with sharing class CBK_CustomPicklist_Controller {
	@AuraEnabled(cacheable = true)
	public static List<PicklistItems> picklistValues(String inputField, String inputObj) {
		PicklistItems pickItem;
		List<PicklistItems> lstpickItem = new list<PicklistItems> ();
		Map<String, String> values = new Map<String, String> { };

		List<CBK_PicklistValues__c> pickObj = [Select Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name
		                                       FROM CBK_PicklistValues__c where CBK_Picklist__r.Name = :inputField AND CBK_Picklist__r.CBK_Object__c =:inputObj];

		if (pickObj != null && pickObj.size() > 0) {
			for (CBK_PicklistValues__c pv : pickObj) {
				pickItem = new PicklistItems();
				pickItem.label = pv.Name;
				pickItem.value = pv.Name;
				lstpickItem.add(pickItem);
			}
		}
		return lstpickItem;
	}


	@AuraEnabled(cacheable = true)
	public static List<PicklistItems> picklistValuesDependency(String inputField, String inputValue, String inputObj) {

		PicklistItems pickItem;
		List<PicklistItems> lstpickItem = new list<PicklistItems> ();
		List<PicklistItems> lstpickItemAll = new list<PicklistItems> ();
		Map<String, String> values = new Map<String, String> { };

		List<CBK_PicklistValues__c> pickObj = [Select Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name
		                                       FROM CBK_PicklistValues__c where CBK_Picklist__r.Name = :inputField AND Name = :inputValue AND CBK_Picklist__r.CBK_Object__c =:inputObj];

		Map<String, CBK_PicklistValues__c> mDepPick = new Map<String, CBK_PicklistValues__c> ();
		set<string> sIds = new Set<string> ();
		set<string> sIdsAll = new Set<string> ();
		for (CBK_PicklistValues__c pv : pickObj) {
			if (String.isNotBlank(pv.CBK_Dependencies__c))
			sIdsAll.addAll(pv.CBK_Dependencies__c.split(';'));

			if (pv.CBK_HasDependency__c && String.isNotBlank(pv.CBK_Dependencies__c)) {
				sIds.addAll(pv.CBK_Dependencies__c.split(';'));
			}
		}
		if (sIdsAll.size() <= 0 && sIds.size() <= 0) {
			pickObj = getAllvaluesByField(inputField);

			for (CBK_PicklistValues__c pv : pickObj) {
				sIdsAll.add(pv.Name);
			}
		}

		for (string str : sIds) {
			pickItem = new PicklistItems();
			pickItem.label = str;
			pickItem.value = str;
			lstpickItem.add(pickItem);
		}

		for (string str : sIdsAll) {
			pickItem = new PicklistItems();
			pickItem.label = str;
			pickItem.value = str;
			lstpickItemAll.add(pickItem);
		}

		if (lstpickItem.size() > 0)
		return lstpickItem;
		else
		return lstpickItemAll;
	}

	public static List<CBK_PicklistValues__c> getAllvaluesByField(String inputField) {
		List<CBK_PicklistValues__c> pickObj = [Select Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name
		                                       FROM CBK_PicklistValues__c where CBK_Picklist__r.CBK_ParentId__r.Name = :inputField];
		return pickObj;
	}

	public class PicklistItems
	{
		@AuraEnabled
		public String value { get; set; }

		@AuraEnabled
		public string label { get; set; }

	}
}