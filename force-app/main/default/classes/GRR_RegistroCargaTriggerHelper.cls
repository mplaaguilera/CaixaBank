public with sharing class GRR_RegistroCargaTriggerHelper {

    public static List<GRR_RegistroCarga__c> filtrarRegistrosCargaActaComiteHist(List<GRR_RegistroCarga__c> lstRegistrosCarga) {
        List<GRR_RegistroCarga__c> registrosCargaActaComite = new List<GRR_RegistroCarga__c>();
        Id registroCargaActaComiteRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Acta_comite');
        Id registroCargaHistoricosRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Historico');
        for (GRR_RegistroCarga__c registroCarga : lstRegistrosCarga) {
            if (registroCarga.recordTypeId == registroCargaActaComiteRTId || registroCarga.recordTypeId == registroCargaHistoricosRTId) {
                registrosCargaActaComite.add(registroCarga);
            }
        } 
        return registrosCargaActaComite;
    }
    
    public static void crearNuevasURs(List<GRR_RegistroCarga__c> lstRegistrosCarga) {
        Set<Id> setIdsRegistrosInsertados = new Set<Id>();
        for (GRR_RegistroCarga__c registroCarga : lstRegistrosCarga) {
            if (registroCarga.GRR_CodigoUR__c != null) {
                setIdsRegistrosInsertados.add(registroCarga.Id);
            }
        }
        List<String> nombreURsExistentes = new List<String>();
        List<GRR_UR__c> ursAInsertar = new List<GRR_UR__c>();
        if (!setIdsRegistrosInsertados.isEmpty()) {
            List<GRR_UR__c> ursExistentes = new List<GRR_UR__c>([SELECT GRR_Id_UR__c FROM GRR_UR__c WHERE Id IN (SELECT GRR_UR__c FROM GRR_RegistroCarga__c WHERE  Id IN :setIdsRegistrosInsertados AND GRR_UR__c != null)]);
            for (GRR_UR__c ur : ursExistentes) {
                nombreURsExistentes.add(ur.GRR_Id_UR__c);
            }
            for (GRR_RegistroCarga__c registroCarga : lstRegistrosCarga) {
                if (!nombreURsExistentes.contains(registroCarga.GRR_CodigoUR__c)) {
                    GRR_UR__c ur = new GRR_UR__c();
                    ur.GRR_Id_UR__c = registroCarga.GRR_CodigoUR__c;
                    ursAInsertar.add(ur);
                }
            }
            Database.insert(ursAInsertar, false);   
        }        
    }

    public static void informarLookupUR(List<GRR_RegistroCarga__c> lstRegistrosCarga) {  
        List<String> nombreCodigoURs = new List<String>(); 
        for (GRR_RegistroCarga__c registroCarga : lstRegistrosCarga) {
            if (registroCarga.GRR_CodigoUR__c != null) {
                nombreCodigoURs.add(registroCarga.GRR_CodigoUR__c);
            }
        }           
        List<GRR_RegistroCarga__c> registrosCargaActualizar = new List<GRR_RegistroCarga__c>();      
        List<GRR_RegistroCarga__c> updateRegistros = [SELECT Id, GRR_UR__c, GRR_CodigoUR__c FROM GRR_RegistroCarga__c WHERE Id IN :lstRegistrosCarga]; 
        if (nombreCodigoURs != null) {
            Map<String, Id> mapaURIds = new Map<String, Id>();
            List<GRR_UR__c> listUR = new List<GRR_UR__c>([SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE GRR_Id_UR__c IN :nombreCodigoURs]);
            for (GRR_UR__c ur : listUR) {
                mapaURIds.put(ur.GRR_Id_UR__c, ur.Id);
            }
            for (GRR_RegistroCarga__c registroCarga : updateRegistros) {    
                if (mapaURIds.containsKey(registroCarga.GRR_CodigoUR__c)) {            
                    registroCarga.GRR_UR__c = mapaURIds.get(registroCarga.GRR_CodigoUR__c);
                    registrosCargaActualizar.add(registroCarga);
                }
            }       
            Database.update(registrosCargaActualizar, false);
        }              
    }

}