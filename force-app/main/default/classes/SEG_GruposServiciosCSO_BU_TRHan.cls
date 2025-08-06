public with sharing class SEG_GruposServiciosCSO_BU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_GruposServiciosCSO__c>)tp.newList, (Map<Id, SEG_GruposServiciosCSO__c>)tp.newMap, (Map<Id, SEG_GruposServiciosCSO__c>)tp.oldMap);
    }

    private void process(List<SEG_GruposServiciosCSO__c> listNewObj, Map<Id, SEG_GruposServiciosCSO__c> mapNewObj, Map<Id, SEG_GruposServiciosCSO__c> mapOldObj) {
        activacionGrupo(listNewObj, mapNewObj, mapOldObj);
        grupoServicioCSO(listNewObj, mapNewObj, mapOldObj);
    }

    public static void activacionGrupo(List<SEG_GruposServiciosCSO__c> listNewObj, Map<Id, SEG_GruposServiciosCSO__c> mapNewObj, Map<Id, SEG_GruposServiciosCSO__c> mapOldObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_GruposServiciosCSO__c grupo : listNewObj) {              
            // Verificar si el campo SEG_Activo__c esta cambiando 
            if (mapNewObj.get(grupo.Id).SEG_Activo__c != mapOldObj.get(grupo.Id).SEG_Activo__c) {
                // comprobamos si activo esta en true
                if(mapNewObj.get(grupo.Id).SEG_Activo__c){
                    // Actualizar el campo SEG_FechaActivacion__c con la fecha actual datetime
                    grupo.SEG_FechaActivacion__c = datetime.now();
                } else {
                    // Si el campo SEG_Activo__c esta Inactivo
                    // Actualizar el campo SEG_FechaDesactivacion__c con la fecha actual
                    grupo.SEG_FechaDesactivacion__c = datetime.now();
                }           
            }
        }
    }

    //Se concatenan los campos de SEG_GrupoCSO__c y SEG_ServiciosCSO__c siempre que se detecte un cambio en los mismos
    public static void grupoServicioCSO(List<SEG_GruposServiciosCSO__c> listNewObj, Map<Id, SEG_GruposServiciosCSO__c> mapNewObj, Map<Id, SEG_GruposServiciosCSO__c> mapOldObj){

        for (SEG_GruposServiciosCSO__c grupoServicio : listNewObj) {
            if(mapNewObj.get(grupoServicio.Id).SEG_GrupoCSO__c != mapOldObj.get(grupoServicio.Id).SEG_GrupoCSO__c ||  mapNewObj.get(grupoServicio.Id).SEG_ServiciosCSO__c != mapOldObj.get(grupoServicio.Id).SEG_ServiciosCSO__c){
                String valorFinal = '';
                if(grupoServicio.SEG_GrupoCSO__c != null){
                    valorFinal = String.valueOf(grupoServicio.SEG_GrupoCSO__c);
                }
                if(grupoServicio.SEG_ServiciosCSO__c != null){
                    valorFinal = valorFinal + String.valueOf(grupoServicio.SEG_ServiciosCSO__c);
                }
                grupoServicio.SEG_GruposServiciosCSO__c = valorFinal;
            }                      
        } 
    }
}