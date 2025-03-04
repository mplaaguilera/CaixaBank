public with sharing class SEG_MarcaServiciosCSO_BI_TRHan extends CC_TriggerHandlerBase{
       public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_MarcasCSO__c>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }
    private void process(List<SEG_MarcasCSO__c> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        activacionMarca(listNewObj);
     }

    public static void activacionMarca(List<SEG_MarcasCSO__c> listNewObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_MarcasCSO__c marca : listNewObj) {
                
            // Verificar si el campo SEG_Activo__c esta Activo
            if (marca.SEG_Activo__c) {                 
                // Actualizar el campo SEG_FechaActivacion__c con la fecha actual datetime
                marca.SEG_FechaActivacion__c = datetime.now();
            } else {
                // Si el campo SEG_Activo__c esta Inactivo
                // Actualizar el campo SEG_FechaDesactivacion__c con la fecha actual
                marca.SEG_FechaDesactivacion__c = datetime.now();                   
            }
        }
    }
}