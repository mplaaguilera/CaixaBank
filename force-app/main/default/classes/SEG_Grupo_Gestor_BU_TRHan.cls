public with sharing class SEG_Grupo_Gestor_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_Gestor_Grupo__c>)tp.newList, (Map<Id, SEG_Gestor_Grupo__c>) tp.oldMap);
    }
    
    private void process(List<SEG_Gestor_Grupo__c> listNewObj, Map<Id, SEG_Gestor_Grupo__c> mapOldObj) {
        grupoGestor(listNewObj,mapOldObj);	       
	}   

    public static void grupoGestor(List<SEG_Gestor_Grupo__c> listNewObj, Map<Id, SEG_Gestor_Grupo__c> mapOldObj) {
        for (SEG_Gestor_Grupo__c grupoGestor : listNewObj) {
            if(grupoGestor.SEG_EmpleadoGestor__c != mapOldObj.get(grupoGestor.Id).SEG_EmpleadoGestor__c){
                if(grupoGestor.SEG_EmpleadoGestor__c != null){
                    grupoGestor.SEG_IDGestor__c = String.valueOf(grupoGestor.SEG_EmpleadoGestor__c).left(15);
                } else {
                    grupoGestor.SEG_IDGestor__c = null;
                }
            }
        }
    }
}