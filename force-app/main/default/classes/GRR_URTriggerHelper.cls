public with sharing class GRR_URTriggerHelper {

    public static Set<String> filtrarUrsGRRAD(List<GRR_UR__c> lstUrs) {
        Set<String> ursGRR = new Set<String>();
        Id grrURTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR');
        for (GRR_UR__c ur : lstUrs) {
            if (ur.recordTypeId == grrURTypeId) {
                ursGRR.add(ur.GRR_Id_UR__c);
            }
        } 
        return ursGRR;
    }

    public static void borrarLanzamientosUR(Set<String> listaUrsId){
        List<GRR_Lanzamiento__c> listaLanzamientos =[SELECT Id FROM GRR_Lanzamiento__c WHERE GRR_Codigo_UR__c IN :listaUrsId];
        if(!listaLanzamientos.isEmpty()){
            delete listaLanzamientos;
        }
    }

    public static List<GRR_UR__c> filtrarUrsGRRAU(List<GRR_UR__c> lstUrs) {
        List<GRR_UR__c> ursGRR = new List<GRR_UR__c>();
        Id grrURTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR');
        for (GRR_UR__c ur : lstUrs) {
            if (ur.recordTypeId == grrURTypeId) {
                ursGRR.add(ur);
            }
        } 
        return ursGRR;
    }

    public static void regularizarCambioURFechas(List<GRR_UR__c> listNewObj, Map<Id, GRR_UR__c> mapOldObj){
        Map<Id,String> mapaIdUrrNewName=new Map<Id,String>();
        for (GRR_UR__c ur : listNewObj) {
            if(ur.GRR_Id_UR__c!=null && ur.GRR_Id_UR__c!=mapOldObj.get(ur.Id).GRR_Id_UR__c){
                mapaIdUrrNewName.put(ur.Id,ur.GRR_Id_UR__c);
            }
        }
        
        if(!mapaIdUrrNewName.isEmpty()){
            Map<Id,GRR_UR__c> mapaUrs=new Map<Id,GRR_UR__c>([SELECT Id,(SELECT Id,GRR_Codigo_UR__c,GRR_Codigo_Lanzamiento__c,GRR_Fecha_Prevista_Posesion__c FROM Lanzamientos__r) FROM GRR_UR__c WHERE Id IN :mapaIdUrrNewName.keySet()]);
            List<GRR_Lanzamiento__c> listaLanzamientosToUpd= new List<GRR_Lanzamiento__c>();
            GRR_UR__c ur;
            for (Id urId : mapaUrs.keySet()) {
                ur=mapaUrs.get(urId);
                for(GRR_Lanzamiento__c lanzamiento : ur.Lanzamientos__r) { 
                    lanzamiento.GRR_Codigo_UR__c=mapaIdUrrNewName.get(urId);
                    lanzamiento.GRR_Codigo_Lanzamiento__c=mapaIdUrrNewName.get(urId)+'-'+lanzamiento.GRR_Fecha_Prevista_Posesion__c.format('yyyyMMdd');
                    listaLanzamientosToUpd.add(lanzamiento);
                }   
            }
            if(!listaLanzamientosToUpd.isEmpty()){
                update listaLanzamientosToUpd;
            }
        }   
    }

}