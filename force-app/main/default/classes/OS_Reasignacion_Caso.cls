public with sharing class OS_Reasignacion_Caso {
	
    @InvocableMethod
    public static void reasignacionCaso(List<Id> idCaso) {
    	List<Case> listaCasos= [SELECT Id, OwnerId, CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c FROM Case WHERE Id IN :idCaso];
        if (!listaCasos.isEmpty()) {
            for	(Case caso : listaCasos) {
                if (caso.OwnerId != System.UserInfo.getUserId()) {
                	caso.CC_Ultima_Interaccion__c = 'Reasignación del caso';
                    caso.CC_Fecha_Ultima_Interaccion__c = System.now();
                }
            }
            update listaCasos;
        }
        
        
    }
}