/**********************************************************************************************************************
Name:	  AV_UpdateGcfRepresentative_Controller
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "av_GcfRepresentative"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR              DATE			Description
    1.0         US408052                                            Patricia Solano     22/10/2020		Init version
***********************************************************************************************************************/
public with sharing class AV_UpdateGcfRepresentative_Controller {

	public static final String BRANCH_PREFIX = '001-';
	/**
	* Método para la llamada a la API de Representantes retornando un mapa con los nuevos valores para Account
	* @param numPerson String de numPerso de cliente
	* @param fechaRefresco última fecha de refresco del cliente
	* @return String con los valores de Account para actualizar a partir del componente Lightning Web Component
	*/
	@AuraEnabled(cacheable=true)
	public static String retrieveRepresentativeData(String numPerson, DateTime fechaRefresco, String idRecords) { 
		List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();
		List<Contact> oRepresentantesJuridicos = new List<Contact>();

		if(numPerson != null) {
			if((fechaRefresco == null || AV_AppUtilities.calculateTimeDifferences(fechaRefresco, System.now()) >= 24)){ 
				Map<String,Object> result = AV_GCF_Integration.getDataALFWS_RepresentantesJuridicos(numPerson,'');
				if(result != null) {
                    for (String sClaveRepJur : result.keySet()) {
                        if (sClaveRepJur == 'TRAZA') {
                            oTraza.add((CC_TrazaInt__c)result.get(sClaveRepJur));
                        } else if (sClaveRepJur == 'REPR_JURIDICO') {
                            if (!((List<Contact>)result.get(sClaveRepJur)).isEmpty()) {
                                oRepresentantesJuridicos.addAll((List<Contact>)result.get(sClaveRepJur));
                            }
                        }
                    }
					if (!oRepresentantesJuridicos.isEmpty()) {
           		 		Schema.SObjectField oCampoSearch = Contact.Fields.CC_NumPerso__c;
            			Database.UpsertResult[] oResUp = Database.upsert(oRepresentantesJuridicos, oCampoSearch, false);
						Account acc = new Account();
						acc.AV_FechaRefrescoApoderado__c = System.Now();
						acc.Id = idRecords;
						Database.update(acc, false);
						return 'OK';
        			}
					 // Insertar las trazas generadas
					if (oTraza.size() > 0) {
						Database.SaveResult[] oResUp = Database.insert(oTraza, false);
						Account acc = new Account();
						acc.AV_FechaRefrescoApoderado__c = System.Now();
						acc.Id = idRecords;
						Database.update(acc, false);
						return 'OK';
					}
				}
			} 
		}
		return null;
	}

	/**
	 * @description Obtener los datos del Cliente
	 */
	@AuraEnabled
	public static String getRepresentativeData(String recordId) {
		String result;
		if (recordId != null) {
			Account acc = [SELECT AV_NumPerso__c, AV_FechaRefrescoApoderado__c, Id FROM Account WHERE Id = :recordId];
			result = retrieveRepresentativeData(acc.AV_NumPerso__c, acc.AV_FechaRefrescoApoderado__c, acc.Id);
			return result;
		}
		return null;
	}
	
}