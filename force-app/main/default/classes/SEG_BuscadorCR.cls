public with sharing class SEG_BuscadorCR {

	@AuraEnabled(cacheable = true)
	public static List<sObject> querySalesforceRecord(String queryString, String dateValidCache)
	{
		List<sObject> retornoObjetos = new List<sObject>();

		if (String.isNotBlank(queryString))
		{
			retornoObjetos = Database.query(queryString);
		}

		return retornoObjetos;
	}

	@AuraEnabled
	public static void updateCaseCR(String caseId, String crId){
		try {
			Case caseUpdate = new Case();
			caseUpdate.Id = caseId;
			caseUpdate.SEG_ClasificacionRapida__c = crId;
			update caseUpdate;			
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}