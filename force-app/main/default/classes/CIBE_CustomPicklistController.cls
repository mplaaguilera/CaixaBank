/**********************************************************************************************************************
Name:	  CIBE_CustomPicklistController
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del componenente cibe_picklistJerarquiaContact_CIB
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	    AUTHOR		   	    DATE				Description
	1.0			US542103	    Lucía Muñoz		    28/02/2023			Init version
    1.1			US588383	    Lucía Muñoz		    18/05/2023			Nuevos metodos insertHierarchy, deleteHierarchy,isEditable
    1.2			US616749	    Bea     		    26/06/2023			Nuevo método getEmpleados
    1.3			DE80364	        Lucía Muñoz		    22/08/2023			Mover el metodo deleteHierarchy a la clase CIBE_DeleteHierarchy


***********************************************************************************************************************/
public with sharing class CIBE_CustomPicklistController {

    private static final String PROJECT = 'CIBE';

    @AuraEnabled(cacheable = true)
	public static List<PicklistItems> picklistValues(String inputField, String inputObj) {
		PicklistItems pickItem;
		List<PicklistItems> lstpickItem = new list<PicklistItems> ();
		Map<String, String> values = new Map<String, String> { };

		List<CBK_PicklistValues__c> pickObj = [SELECT Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name
		                                       FROM CBK_PicklistValues__c WHERE CBK_Picklist__r.Name = :inputField AND CBK_Picklist__r.CBK_Object__c =:inputObj AND Recordtype.DeveloperName = 'CBK_PicklistValue'];
        
		if (pickObj != null && pickObj.size() > 0) {
			for (CBK_PicklistValues__c pv : pickObj) {
				pickItem = new PicklistItems();
				pickItem.label = pv.Name;
				pickItem.value = pv.Id;
				lstpickItem.add(pickItem);
			}
		}
		return lstpickItem;
	}

    @AuraEnabled(cacheable = true)
	public static List<PicklistItems> picklistValuesDependency(String inputField, String inputValue, String inputObj) {
		PicklistItems pickItem;
		List<PicklistItems> lstpickItem = new list<PicklistItems> ();
		Map<String, String> values = new Map<String, String> { };
        set<string> sIdsAll = new Set<string> ();
        set<string> parentId = new Set<string> ();
		List<CBK_PicklistValues__c> pickObj = [ SELECT  Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name
                                                FROM CBK_PicklistValues__c 
                                                WHERE CBK_Picklist__r.Name = :inputField AND Name = :inputValue AND CBK_Picklist__r.CBK_Object__c =:inputObj AND Recordtype.DeveloperName = 'CBK_PicklistValue'];

		
		for (CBK_PicklistValues__c pv : pickObj) {
			if (String.isNotBlank(pv.CBK_Dependencies__c)){
			    sIdsAll.addAll(pv.CBK_Dependencies__c.split(';'));
                parentId.add(pv.CBK_Picklist__c);
            }
		}

        List<CBK_PicklistValues__c> pickObjDepend = [SELECT Id, OwnerId,  Name, RecordTypeId , CBK_Dependencies__c, CBK_HasDependency__c, CBK_Object__c, CBK_ParentId__c, CBK_Picklist__c, CBK_Picklist__r.Name, CBK_Project__c, CBK_RecordId__c  FROM CBK_PicklistValues__c WHERE Name IN : sIdsAll AND Recordtype.DeveloperName = 'CBK_PicklistValue' AND CBK_ParentId__c IN :parentId];


        for(CBK_PicklistValues__c pv : pickObjDepend){
            pickItem = new PicklistItems();
			pickItem.label = pv.Name;
			pickItem.value = pv.Id;
			lstpickItem.add(pickItem);
        }
		
    return lstpickItem;
        
	}

    @AuraEnabled
    public static List<CIBE_Hierarchy__c> insertHierarchy(List<CIBE_Hierarchy__c> listaInsert) {
        string rtHierarchy = Schema.getGlobalDescribe().get('CIBE_Hierarchy__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CIBE_Employee').getRecordTypeId();

        if(!listaInsert.isEmpty() && listaInsert != null){

            for(CIBE_Hierarchy__c lista : listaInsert){
                lista.RecordTypeId = rtHierarchy;
            }
            Database.insert(listaInsert, false);
        }
        return listaInsert;
    }

    public static Map<String, List<String>> getDependencie(String inputField) {
        List<CBK_PickListValues__c> values = [  SELECT Id, Name, CBK_Dependencies__c, CBK_Picklist__r.Name
                                                FROM CBK_PickListValues__c 
                                                WHERE RecordType.DeveloperName = 'CBK_PicklistValue' 
                                                    AND CBK_Project__c = :PROJECT
                                                    AND CBK_Picklist__r.Name = :inputField];

        Map<String, List<String>> dependencies = new Map<String, List<String>>();
        for(CBK_PickListValues__c value : values) {
            dependencies.put(
                value.Name, 
                String.isNotBlank(value.CBK_Dependencies__c) ? value.CBK_Dependencies__c.split(';') : new List<String>()
            );
        }
        return dependencies;
    }

    @AuraEnabled(cacheable = true)
    public static Boolean isEditable() {
        List<GroupMember> userGroup = new List<GroupMember>();
        if(GroupMember.SObjectType.getDescribe().isAccessible()) {
            userGroup = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE Group.DeveloperName = 'CIBE_EditHierarchy'];
        }

        Set<Id> userId = new Set<Id>();
        for (GroupMember uId : userGroup) {
            userId.add(uId.UserOrGroupId);
        }

        return userId.contains(UserInfo.getUserId());
    }

    @AuraEnabled(cacheable = true)
    public static List<CIBE_Hierarchy__c> getHierarchies(String recordId, Boolean forceUpdate) {
        List<CIBE_Hierarchy__c> hierarchies = new List<CIBE_Hierarchy__c>();
        if(Schema.CIBE_Hierarchy__c.sObjectType.getDescribe().isAccessible()) {
            hierarchies = [SELECT   Id, 
                                    CIBE_Negocios__c, 
                                    CIBE_Negocios__r.Name, 
                                    CIBE_RedesSegmentos__c, 
                                    CIBE_RedesSegmentos__r.Name, 
                                    CIBE_SectoresPaises__c, 
                                    CIBE_SectoresPaises__r.Name, 
                                    CIBE_CentrosCarteras__c, 
                                    CIBE_CentrosCarteras__r.Name 
                            FROM CIBE_Hierarchy__c 
                            WHERE   RecordType.DeveloperName = 'CIBE_Employee' AND
                                     CIBE_Contact__c = :recordId 
                            ORDER BY CIBE_Negocios__r.Name, CIBE_RedesSegmentos__r.Name, CIBE_SectoresPaises__r.Name, CIBE_CentrosCarteras__r.Name ASC];
        }
        return hierarchies;
    }
    @AuraEnabled (cacheable = true)
    public static List<Contact> getEmpleados(String recordId) {

        List<Contact> empleados = new List<Contact>();
        if(Contact.sObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.Contact.fields.Id.isAccessible()
            && Schema.SObjectType.Contact.fields.CIBE_Manager__c.isAccessible()) {
                empleados = [SELECT Id, CIBE_Manager__c FROM Contact 
                                WHERE RecordType.DeveloperName = 'CC_Empleado' AND Id = :recordId ];
        }
        
        return empleados;
    }

    public class PicklistItems {
		@AuraEnabled public String value { get; set; }
		@AuraEnabled public string label { get; set; }
	}

}