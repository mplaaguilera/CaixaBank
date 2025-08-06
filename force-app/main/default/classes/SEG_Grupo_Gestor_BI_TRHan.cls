public with sharing class SEG_Grupo_Gestor_BI_TRHan extends CC_TriggerHandlerBase{

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_Gestor_Grupo__c>)tp.newList);
	}

    private void process(List<SEG_Gestor_Grupo__c> listNewObj) {
        grupoGestor(listNewObj);	       
	}   

    public static void grupoGestor(List<SEG_Gestor_Grupo__c> listNewObj) {
        for (SEG_Gestor_Grupo__c grupoGestor : listNewObj) {
            if(!String.isBlank(grupoGestor.SEG_EmpleadoGestor__c)){
                grupoGestor.SEG_IDGestor__c = String.valueOf(grupoGestor.SEG_EmpleadoGestor__c).left(15);
            }
        }
    }
}