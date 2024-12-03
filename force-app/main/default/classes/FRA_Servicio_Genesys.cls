public with sharing class FRA_Servicio_Genesys {
    public static List<CC_Servicio_Genesys__c> obtenerInfoServicioGenesys(String registroId) {
        
        List<Case> casos = [SELECT CC_Canal_Procedencia__c, Recordtype.DeveloperName FROM Case WHERE Id = :registroId];
        List<CC_Servicio_Genesys__c> servicios = [SELECT KIN_Cola_Id_GC__c,CC_Codigo__c,CC_Canal_Procedencia__c FROM CC_Servicio_Genesys__c
                                                      WHERE CC_Canal_Procedencia__c = :casos[0].CC_Canal_Procedencia__c LIMIT 1];
            
        return servicios;
    }
		
}