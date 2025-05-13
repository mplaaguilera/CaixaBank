public with sharing class SEG_MCCServiciosCSO_BI_TRHan extends CC_TriggerHandlerBase{
       public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_MCCServiciosCSO__c>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }
    private void process(List<SEG_MCCServiciosCSO__c> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        activacionMCC(listNewObj);
        concatenacionMCCs(listNewObj);
     }

    public static void activacionMCC(List<SEG_MCCServiciosCSO__c> listNewObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_MCCServiciosCSO__c mcc : listNewObj) {
                
            // Verificar si el campo SEG_Activo__c esta Activo
            if (mcc.SEG_Activo__c) {                 
                // Actualizar el campo SEG_FechaActivacion__c con la fecha actual datetime
                mcc.SEG_FechaActivacion__c = datetime.now();
            } else {
                // Si el campo SEG_Activo__c esta Inactivo
                // Actualizar el campo SEG_FechaDesactivacion__c con la fecha actual
                mcc.SEG_FechaDesactivacion__c = datetime.now();                   
            }
        }
    }

    //Método que se ejecuta siempre en la creación para contactenar los campos del MCC asociados al servicio en el campo SEG_MCCServiciosCSO__c
    public static void concatenacionMCCs(List<SEG_MCCServiciosCSO__c> listNewObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_MCCServiciosCSO__c mcc : listNewObj) {
            String valorFinal = '';
            if (mcc.SEG_Tematica__c != null) {
                valorFinal = valorFinal + String.valueOf(mcc.SEG_Tematica__c);
            }
            if (mcc.SEG_Producto__c != null) {
                valorFinal = valorFinal + String.valueOf(mcc.SEG_Producto__c);
            }
            if (mcc.SEG_Motivo__c != null) {
                valorFinal = valorFinal + String.valueOf(mcc.SEG_Motivo__c);
            }
            if (mcc.SEG_Detalle__c != null) {
                valorFinal = valorFinal + String.valueOf(mcc.SEG_Detalle__c);
            }
            if (mcc.SEG_ServiciosCSO__c != null) {
                valorFinal = valorFinal + String.valueOf(mcc.SEG_ServiciosCSO__c);
            }
            mcc.SEG_MCCServiciosCSO__c = valorFinal;
        }
    }
}