public with sharing class SEG_MostrarExcepciones {

	@AuraEnabled
	static public List<String> getExcepciones(String objectId) {

		List<String> lstText = new List<String>();
		String text;
		String userId = UserInfo.getUserId();
		List<SEG_Excepciones_Caso__c> lstExCaso = new List<SEG_Excepciones_Caso__c> ([SELECT CreatedById, LastModifiedById, SEG_Contratos__c, SEG_Case__c, SEG_ExcepcionesContrato__r.SEG_Texto__c, SEG_Excepciones__r.SEG_Texto__c FROM SEG_Excepciones_Caso__c Where Id =:objectId order by LastModifiedDate desc]);

		for (SEG_Excepciones_Caso__c exCaso : lstExCaso) {
			text = null;
			if (exCaso.SEG_Case__c != null)
			{
                
				if (exCaso.LastModifiedById == userId)
				{
					if (exCaso.SEG_Excepciones__r.SEG_Texto__c != null)
					{
						text = exCaso.SEG_Excepciones__r.SEG_Texto__c;
					}
					else if (exCaso.SEG_ExcepcionesContrato__r.SEG_Texto__c != null)
					{
						text = exCaso.SEG_ExcepcionesContrato__r.SEG_Texto__c;
					}
					else {
						text = 'Se ha creado una nueva excepción';
					}
				}


			} else if (exCaso.SEG_Contratos__c != null)
			{
                
				if (exCaso.CreatedById == userId)
				{
					if (exCaso.SEG_Excepciones__r.SEG_Texto__c != null) 
					{
						text = exCaso.SEG_Excepciones__r.SEG_Texto__c;
					}
					else if (exCaso.SEG_ExcepcionesContrato__r.SEG_Texto__c != null)
					{
						text = exCaso.SEG_ExcepcionesContrato__r.SEG_Texto__c;
					}
					else {
						text = 'Se ha creado una nueva excepción';
					}
				}

			}
			if(String.isNotBlank(text)){
				lstText.add(text);
			}
		}

		return lstText;
	}

    @AuraEnabled
	static public List<String> getExcepcionesCase(String CaseId,string Tipo) {

		List<String> lstText = new List<String>();
        List<String> lstTextUnique = new List<String>();
        String text;
		String userId = UserInfo.getUserId();
        String now = String.valueOfGmt(Datetime.now());

		List<SEG_Excepciones_Caso__c> lstExCaso =  ([SELECT CreatedById, LastModifiedById, SEG_Contratos__c, SEG_Case__c, SEG_ExcepcionesContrato__r.SEG_Texto__c, SEG_Excepciones__r.SEG_Texto__c,SEG_PopUp__c
                                                        FROM SEG_Excepciones_Caso__c 
                                                       WHERE ((SEG_Case__c =:CaseId AND SEG_Case__r.ownerId = :userId) OR
                                                              (SEG_contratos__r.SEG_SR_Seguimiento__c=:CaseId AND SEG_contratos__r.SEG_SR_Seguimiento__r.ownerId = :userId))
                                                        AND SEG_PopUp__c!=null AND SEG_PopUp__c!=''
                                                       ORDER BY LastModifiedDate desc]);
        
		for (SEG_Excepciones_Caso__c exCaso : lstExCaso) {
			text = null;
			if (exCaso.SEG_Case__c != null)
			{
					if (exCaso.SEG_Excepciones__r.SEG_Texto__c != null)
					{
						text = exCaso.SEG_Excepciones__r.SEG_Texto__c;
					}
					else if (exCaso.SEG_ExcepcionesContrato__r.SEG_Texto__c != null)
					{
						text = exCaso.SEG_ExcepcionesContrato__r.SEG_Texto__c;
					}
					else {
						text = 'Se ha creado una nueva excepción';
					}
			} else if (exCaso.SEG_Contratos__c != null)
			{
                
					if (exCaso.SEG_Excepciones__r.SEG_Texto__c != null) 
					{
						text = exCaso.SEG_Excepciones__r.SEG_Texto__c;
					}
					else if (exCaso.SEG_ExcepcionesContrato__r.SEG_Texto__c != null)
					{
						text = exCaso.SEG_ExcepcionesContrato__r.SEG_Texto__c;
					}
					else {
						text = 'Se ha creado una nueva excepción';
					}
			}
			if(String.isNotBlank(text)){
				lstText.add(text);
                exCaso.SEG_PopUp__c = null;
			}
		}
        
        update lstExCaso;
        lstTextUnique.addAll(lstText);
		return lstTextUnique;
	}

}