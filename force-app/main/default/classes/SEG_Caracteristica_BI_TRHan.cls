public with sharing class SEG_Caracteristica_BI_TRHan extends CC_TriggerHandlerBase {

    private static Id marca;
    private static Id caracteristicaCaso;

    public override void mainEntry(CC_TriggerParameters tp) {
        Set<String> objetos = new Set<String>{'CC_Caracteristica__c'};
        Map<String,Map<String,Schema.RecordTypeInfo>> rtObjetos = SEG_GetRT.getRecordTypesObjects(objetos);
        caracteristicaCaso = rtObjetos.get('CC_Caracteristica__c').get('SEG_Caracteristicacaso').getRecordTypeId();
        marca = rtObjetos.get('CC_Caracteristica__c').get('Marca').getRecordTypeId();
        process((List<CC_Caracteristica__c>)tp.newList);
    }
    
    private void process(List<CC_Caracteristica__c> listNewObj) {
        eligePicklist(listNewObj);	       
	}   

    public static void eligePicklist(List<CC_Caracteristica__c> listNewObj) {
        
        Id profileId = UserInfo.getProfileId();
        String profileName= [SELECT Id,Name from Profile where Id=:profileId].Name;

        for (CC_Caracteristica__c caracteristica : listNewObj) {
            if ((caracteristica.recordTypeId == marca || caracteristica.recordTypeId == caracteristicaCaso) && profileName == 'SEG_Usuario_CaixaBank') {
                caracteristica.OS_Negocio__c = 'SEGMENTOS';
            }
        }
    }
}