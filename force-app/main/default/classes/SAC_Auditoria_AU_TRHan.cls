public with sharing class SAC_Auditoria_AU_TRHan extends CC_TriggerHandlerBase {
    private static Set<String> objetos = new Set<String>{'SEG_Auditoria__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RECORDTYPEAUDITORIA = mapRTsObjects.get('SEG_Auditoria__c').get('SAC_Auditoria').getRecordTypeId();
    private final static Id RECORDTYPEAUDITORIAGENERAL = mapRTsObjects.get('SEG_Auditoria__c').get('SAC_AuditoriaGeneral').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_Auditoria__c>) tp.newList, (Map<Id, SEG_Auditoria__c>) tp.newMap, (List<SEG_Auditoria__c>) tp.oldList, (Map<Id, SEG_Auditoria__c>) tp.oldMap);
    }    
    private void process(List<SEG_Auditoria__c> listNewObj, Map<Id, SEG_Auditoria__c> mapNewObj, List<SEG_Auditoria__c> listOldObj, Map<Id, SEG_Auditoria__c> mapOldObj){

        List<SEG_Auditoria__c> listAuditSACCompletada = new List<SEG_Auditoria__c>();
       
        //Recorremos la lista de auditorias
        for (SEG_Auditoria__c auditoria : listNewObj) {
            
            if (auditoria.RecordTypeId == RECORDTYPEAUDITORIA || auditoria.RecordTypeId == RECORDTYPEAUDITORIAGENERAL) {

                //Cuando una auditoria pasa a estado completado, debemos comprobar el resto de auditorias hijas de la auditoria general para actualizar el estado de esta
                if (mapOldObj.get(auditoria.id).SAC_Estado__c != auditoria.SAC_Estado__c && auditoria.SAC_Estado__c == 'SAC_Completada' && String.isNotBlank(auditoria.SAC_AuditoriaGeneral__c)) {
                    listAuditSACCompletada.add(auditoria);
                }      
            }
        }

        if (!listAuditSACCompletada.isEmpty()) {
            SAC_LCMP_AuditoriasController.actualizarAuditoriaPadre(listAuditSACCompletada);
        }
    }
}