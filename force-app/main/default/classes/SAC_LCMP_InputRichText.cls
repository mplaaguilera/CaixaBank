public with sharing class SAC_LCMP_InputRichText {
    
    /**
	 * @description Raúl Santos - 08/04/2025 - Método para actualizar el campo SAC_BloqueoTotalVisibilidad__c a true en las imagenes insertadas
     *                                         para que no aparezcan en el cmp de adjuntos
	 * @param idCV id del nuevo CV
	*/
    @AuraEnabled
	public static void actualizarCV(String idCV) {

        LIst<ContentVersion> listCV = [SELECT Id FROM ContentVersion WHERE Id = :idCV LIMIT 1];

        if(!listCV.isEmpty()){
            listCV[0].SAC_BloqueoTotalVisibilidad__c = true;
            SAC_DatabaseDML.updateListDML(listCV, true);
        }

    }
}