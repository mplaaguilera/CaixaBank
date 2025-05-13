public with sharing class SEG_ReglasDeClasificacion_BI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_Regladeclasificacion__c>)tp.newList);
    }
    
    private void process(List<SEG_Regladeclasificacion__c> listNewObj) {
        grupoSegmentos(listNewObj);	       
	}   
    
    public static void grupoSegmentos(List<SEG_Regladeclasificacion__c> listNewObj) {
        
        Id profileId = UserInfo.getProfileId();
        String profileName= [SELECT Id,Name from Profile where Id=:profileId].Name;
        if (profileName == 'SEG_Usuario_CaixaBank') {
            for (SEG_Regladeclasificacion__c grupoSegmentos : listNewObj) {
                grupoSegmentos.CBK_Negocio__c = 'Segmentos';
            }
        }
    }
}