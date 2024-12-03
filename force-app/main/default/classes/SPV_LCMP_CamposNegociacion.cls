public with sharing class SPV_LCMP_CamposNegociacion {
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();


    /*******************************************************************************
     * Proposito: Recuperar las pretensiones del caso que están en negociación
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     18/07/24        Creación
    *******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getPretensiones(String casoId){
        List<Case> pretensionesCaso = new List<Case>();
        List<Case> pretensionesMostrar = new List<Case>();

        try {
            pretensionesCaso = [SELECT Id, Status, SAC_Reclamacion__r.SEG_Subestado__c, SAC_CasoNegociado__c, CC_MCC_Tematica__r.name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.name, SEG_Detalle__r.Name FROM Case 
                                WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: casoId AND (Status = 'SAC_007' OR SAC_CasoNegociado__c = true)];

            for(Case pretension : pretensionesCaso) {
                if(pretension.SAC_Reclamacion__r.SEG_Subestado__c == 'Negociacion' && pretension.Status == 'SAC_007') {
                    pretensionesMostrar.add(pretension);
                } else if(pretension.SAC_Reclamacion__r.SEG_Subestado__c != 'Negociacion' && pretension.SAC_CasoNegociado__c == true) {
                    pretensionesMostrar.add(pretension);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return pretensionesMostrar;
    }
}