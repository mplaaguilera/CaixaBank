public with sharing class AV_ActivadeLeadOppController {
    
    @AuraEnabled
    public static boolean updateStatus(String leadOppId){
        String methodName = 'updateStatus';
        boolean desactivado = false;
        try{
			AV_LeadOpportunity__c lo = [SELECT Name, AV_Status__c, AV_StatusLeadOpp__c FROM AV_LeadOpportunity__c WHERE Id = :leadOppId LIMIT 1];
            //Si el estado está en 'Cerrado' y se da a activar que vuelva a la etapa anterior y se vuelva a quedar en activo
            if(lo.AV_Status__c.equals('Cerrado') || lo.AV_Status__c.equals('Nuevo') || lo.AV_Status__c.equals('Enviada oferta comercial')){
                lo.AV_StatusLeadOpp__c = 'En gestión/insistir';
                lo.AV_Status__c = 'Activo';
                lo.AV_FechaCierreGestion__c = null;
                try{
                    Database.SaveResult sr = database.update(lo); 
                    if(sr.isSuccess()){
                        desactivado = true;
                    }
                    return desactivado;
                }catch(DmlException e){
                    AV_LogDebug.printLogDebug(methodName, 'Error: ' + e.getMessage());
                    return false;
                }
            }
        }catch(QueryException e){
            AV_LogDebug.printLogDebug(methodName, 'Error: ' + e.getMessage());
            return false;
        }
        
        return desactivado;
    }
    
}