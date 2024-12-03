public with sharing class CBK_DataManagerCreateFields_Apex {

	@AuraEnabled(cacheable=true)
	public static List<String> getProyectos() {
		List<String> retorno = new List<String>();
		Schema.DescribeFieldResult proyectos = CBK_DataManager__c.sObjectType.getDescribe().fields.getMap().get('Proyectos__c').getDescribe();
		for (Schema.PicklistEntry proyecto : proyectos.getPicklistValues()) {
			retorno.add(proyecto.getValue());
		}
		return retorno;
	}

	@AuraEnabled(cacheable=true)
	public static List<copado__Release__c> getReleases() {
		return [SELECT Name, copado__Completion_Date__c FROM copado__Release__c
				WHERE copado__Completion_Date__c < NEXT_N_DAYS:60
				OR copado__Completion_Date__c > LAST_N_DAYS:60
				ORDER BY copado__Completion_Date__c ASC];
	}

	@AuraEnabled
	public static List<CBK_DataManager__c> getSolicitudes() {
		return [SELECT Name, RecordType.DeveloperName, RecordType.Name, Object__c, Object__r.API_Name__c,
						API_Name__c, Proyectos__c, Status__c, Field_Type__c, RecordTypeName__c, Release__c,
						Release__r.Name, Release__r.CBK_Fecha_de_Cierre__c, Data_Type__c, Length__c, FK_PK__c,
						External_ID__c, Description__c, Comments__c, CreatedDate, LastModifiedDate
				FROM CBK_DataManager__c WHERE OwnerId = :UserInfo.getUserId() ORDER BY CreatedDate DESC];
	}
}