public without sharing class SEG_MetodosWithoutSharing {

    public static List<CC_MCC__c> devolverMCCSEG() {
        
        List<CC_MCC__c> mccUAFE = [SELECT Id, CC_Producto_Servicio__c, CC_Producto_Servicio__r.CC_Tematica__c FROM CC_MCC__c 
            WHERE Name = 'Gestión UAFE' AND RecordType.DeveloperName = 'CC_Motivo' AND CC_Producto_Servicio__r.Name = 'Confirming' 
            AND CC_Producto_Servicio__r.CC_Tematica__r.Name = 'Segmentos' AND CC_Activo__c = true];

            if (!mccUAFE.isEmpty()) {
                return mccUAFE;
            }
            else{
                return null;
            }
    }
}