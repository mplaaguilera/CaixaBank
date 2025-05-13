public with sharing class SEG_MarcaServiciosCSO_BU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_MarcasCSO__c>)tp.newList, (Map<Id, SEG_MarcasCSO__c>)tp.newMap, (Map<Id, SEG_MarcasCSO__c>)tp.oldMap);
    }

    private void process(List<SEG_MarcasCSO__c> listNewObj, Map<Id, SEG_MarcasCSO__c> mapNewObj, Map<Id, SEG_MarcasCSO__c> mapOldObj) {
        activacionMarca(listNewObj, mapNewObj, mapOldObj);
        concatenacionMarcaServicio(listNewObj, mapOldObj);
    }

    public static void activacionMarca(List<SEG_MarcasCSO__c> listNewObj, Map<Id, SEG_MarcasCSO__c> mapNewObj, Map<Id, SEG_MarcasCSO__c> mapOldObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_MarcasCSO__c marca : listNewObj) {              
            // Verificar si el campo SEG_Activo__c esta cambiando 
            if (mapNewObj.get(marca.Id).SEG_Activo__c != mapOldObj.get(marca.Id).SEG_Activo__c) {
                // comprobamos si activo esta en true
                if(mapNewObj.get(marca.Id).SEG_Activo__c){
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

    public static void concatenacionMarcaServicio(List<SEG_MarcasCSO__c> listNewObj, Map<Id, SEG_MarcasCSO__c> mapOldObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_MarcasCSO__c marca : listNewObj) {
            String valorFinal = '';
            if (marca.SEG_Marca__c != mapOldObj.get(marca.Id).SEG_Marca__c || marca.SEG_ServiciosCSO__c != mapOldObj.get(marca.Id).SEG_ServiciosCSO__c) {
                if (marca.SEG_Marca__c != null) {
                    valorFinal = valorFinal + String.valueOf(marca.SEG_Marca__c);
                }
                if (marca.SEG_ServiciosCSO__c != null) {
                    valorFinal = valorFinal + String.valueOf(marca.SEG_ServiciosCSO__c);
                }
                marca.SEG_MarcasCSO__c = valorFinal;
            }
        }
    }
}