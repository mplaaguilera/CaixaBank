public with sharing class SEG_MCCServiciosCSO_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_MCCServiciosCSO__c>)tp.newList, (Map<Id, SEG_MCCServiciosCSO__c>)tp.newMap, (Map<Id, SEG_MCCServiciosCSO__c>)tp.oldMap);
    }

    private void process(List<SEG_MCCServiciosCSO__c> listNewObj, Map<Id, SEG_MCCServiciosCSO__c> mapNewObj, Map<Id, SEG_MCCServiciosCSO__c> mapOldObj) {
        activacionMCC(listNewObj, mapNewObj, mapOldObj);
        concatenacionMCCs(listNewObj, mapOldObj);
    }

    public static void activacionMCC(List<SEG_MCCServiciosCSO__c> listNewObj, Map<Id, SEG_MCCServiciosCSO__c> mapNewObj, Map<Id, SEG_MCCServiciosCSO__c> mapOldObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_MCCServiciosCSO__c mcc : listNewObj) {              
            // Verificar si el campo SEG_Activo__c esta cambiando 
            if (mapNewObj.get(mcc.Id).SEG_Activo__c != mapOldObj.get(mcc.Id).SEG_Activo__c) {
                // comprobamos si activo esta en true
                if(mapNewObj.get(mcc.Id).SEG_Activo__c){
                    // Actualizar el campo SEG_FechaActivacion__c con la fecha actual datetime
                    mcc.SEG_FechaActivacion__c = datetime.now();
                } else {
                    // Si el campo SEG_Activo__c esta Inactivo
                    // Actualizar el campo SEG_FechaDesactivacion__c con la fecha actual
                    mcc.SEG_FechaDesactivacion__c = datetime.now();
                }           
            }
        }
    }

    //Método que se ejecuta siempre en la creación para contactenar los campos del MCC asociados al servicio en el campo SEG_MCCServiciosCSO__c
    public static void concatenacionMCCs(List<SEG_MCCServiciosCSO__c> listNewObj, Map<Id, SEG_MCCServiciosCSO__c> mapOldObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_MCCServiciosCSO__c mcc : listNewObj) {
            String valorFinal = '';
            if (mcc.SEG_Tematica__c != mapOldObj.get(mcc.Id).SEG_Tematica__c || mcc.SEG_Producto__c != mapOldObj.get(mcc.Id).SEG_Producto__c ||
                mcc.SEG_Producto__c != mapOldObj.get(mcc.Id).SEG_Producto__c || mcc.SEG_Motivo__c != mapOldObj.get(mcc.Id).SEG_Motivo__c ||
                mcc.SEG_Detalle__c != mapOldObj.get(mcc.Id).SEG_Detalle__c || mcc.SEG_ServiciosCSO__c != mapOldObj.get(mcc.Id).SEG_ServiciosCSO__c) {
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
}