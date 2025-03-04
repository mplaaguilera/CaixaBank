public with sharing class SEG_GruposServiciosCSO_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_GruposServiciosCSO__c>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }

    private void process(List<SEG_GruposServiciosCSO__c> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        activacionGrupo(listNewObj);
     }

    public static void activacionGrupo(List<SEG_GruposServiciosCSO__c> listNewObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_GruposServiciosCSO__c grupo : listNewObj) {
                
            // Verificar si el campo SEG_Activo__c esta Activo
            if (grupo.SEG_Activo__c) {                 
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