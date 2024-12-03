public with sharing class FRA_CaseTriggerHelper {

    public static List<Case> filtrarCasosFRA(List<Case> lstCasos) {
        List<Case> casosFRA = new List<Case>();
        Id fraCasoRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        for (Case caso : lstCasos) {
            if (caso.recordTypeId == fraCasoRTId) {
                casosFRA.add(caso);
            }
        } 
        return casosFRA;
    }

    public static void informarCanalResolucion(List<Case> lstCasos) {
        for (Case caso : lstCasos) {
            if(!String.isBlank(caso.CC_Canal_Procedencia__c) && String.isBlank(caso.CC_Canal_Resolucion__c)){
                caso.CC_Canal_Resolucion__c = caso.CC_Canal_Procedencia__c;
            }
        }
    }

}