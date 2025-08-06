/**********************************************************************************************************************
 Name:	  AV_FichaProductosControllerWithoutShare
 Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para hacer el delete de AV_ProductClient__c 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				    DATE				Description
	1.0			IN1135469			Elisabeth Rodriguez		09/05/2024			Init version

***********************************************************************************************************************/
public without sharing class AV_FichaProductosControllerWithoutShare {


	/**
	 * Delete AV_ProductClient__c list
	 * @param listproductToUpdateInactive	-> list of AV_ProductClient__c to delete
	 */
	public static void deleteProductClient(List<AV_ProductClient__c> listproductToUpdateInactive){

		List<String> listErrorsProductClient = new List<String>();

		if(!listproductToUpdateInactive.isEmpty()){

			List<Database.DeleteResult> listResultDatabase = Database.delete(listproductToUpdateInactive);

			Integer i = 0;
			for(Database.DeleteResult sr : listResultDatabase){
				if (sr.getErrors()!=null) {
					for(Database.Error err : sr.getErrors()) {
						listErrorsProductClient.add('Error: ' + err.getMessage() + ' -> Id: ' + listproductToUpdateInactive.get(i).Id); 
					}
				}
				i++;
			}
	
			if(listErrorsProductClient != null && !listErrorsProductClient.isEmpty()) {
				CBK_log.error('Método deleteProductClient listErrorsProductClient: '+listErrorsProductClient,listErrorsProductClient);
			}

		}
	}

}