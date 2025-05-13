public with sharing class SEG_GrupoColaborador_BI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador__c>)tp.newList); 
    }
    
    private void process(List<CC_Grupo_Colaborador__c> listNewObj) {
        grupoSegmentos(listNewObj);	       
	}   

    public static void grupoSegmentos(List<CC_Grupo_Colaborador__c> listNewObj) {
        
        Id profileId = UserInfo.getProfileId();
        String profileName= [SELECT Id,Name from Profile where Id=:profileId].Name;

        if (profileName == 'SEG_Usuario_CaixaBank') {
            for (CC_Grupo_Colaborador__c grupoSegmentos : listNewObj) {
                grupoSegmentos.SEG_GrupoSegmentos__c = true;
                grupoSegmentos.OS_Negocio__c = 'SEGMENTOS';
            }
        }
    }
}