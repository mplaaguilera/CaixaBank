public with sharing class SEG_GrupoColaborador_BU_TRHan extends CC_TriggerHandlerBase {

   
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador__c>) tp.oldMap);
    }
    
    private void process(List<CC_Grupo_Colaborador__c> listNewObj, Map<Id, CC_Grupo_Colaborador__c> mapOldObj) {
        grupoSegmentos(listNewObj,mapOldObj);	       
	}   
    
    public static void grupoSegmentos(List<CC_Grupo_Colaborador__c> listNewObj, Map<Id, CC_Grupo_Colaborador__c> mapOldObj) {
        
        Id profileId = UserInfo.getProfileId();
        String profileName= [SELECT Id,Name from Profile where Id=:profileId].Name;
        if (profileName == 'SEG_Usuario_CaixaBank') {
            for (CC_Grupo_Colaborador__c grupoSegmentos : listNewObj) {
                if(grupoSegmentos.SEG_GrupoSegmentos__c != mapOldObj.get(grupoSegmentos.Id).SEG_GrupoSegmentos__c && grupoSegmentos.SEG_GrupoSegmentos__c && grupoSegmentos.OS_Negocio__c != 'SEGMENTOS'){
                    grupoSegmentos.OS_Negocio__c = 'SEGMENTOS';
                }
            }
        }
    }
}