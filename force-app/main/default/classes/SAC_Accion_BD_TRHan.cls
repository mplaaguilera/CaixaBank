public with sharing class SAC_Accion_BD_TRHan extends CC_TriggerHandlerBase{

    private static Set<String> objetos = new Set<String>{'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private final static Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private final static Id RECTYPEACCIONRESPONDERESC = mapRTsObjects.get('SAC_Accion__c').get('SAC_AccionResponderEsc').getRecordTypeId();


    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__c>)tp.oldList, (Map<Id, SAC_Accion__c>)tp.oldMap);
    }

    private void process(List<SAC_Accion__c> listOldObj, Map<Id, SAC_Accion__c> mapOldObj) {

        List<SAC_Accion__c> listOldObjSAC = new List<SAC_Accion__c>();
        Map<Id, SAC_Accion__c> mapOldObjSAC = new Map<Id, SAC_Accion__c>();

        for(SAC_Accion__c accion : listOldObj){
            if (accion.RecordTypeId == RECTYPEMAESTROTAREAS || accion.RecordTypeId == RECTYPEOTRASTAREAS || accion.RecordTypeId == RECTYPEACCIONRESPONDERESC) {
                listOldObjSAC.add(accion);
            }
        }

        for(SAC_Accion__c accion : mapOldObj.values()){
            if (accion.RecordTypeId == RECTYPEMAESTROTAREAS || accion.RecordTypeId == RECTYPEOTRASTAREAS || accion.RecordTypeId == RECTYPEACCIONRESPONDERESC) {
                mapOldObjSAC.put(accion.Id, accion);
            }
        }

        if (!listOldObjSAC.isEmpty()) {
            processSAC(listOldObjSAC, mapOldObjSAC);
        }
    }

    private void processSAC(List<SAC_Accion__c> listOldbj, Map<Id, SAC_Accion__c> mapOldObj){
        preventTareaDeletion(listOldbj);
    }

    public static void preventTareaDeletion(List<SAC_Accion__c> oldList) {
        // Check permission set
        Boolean hasPermissionSet = false;
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'SAC_SystemAdmin' LIMIT 1];
        if(!psa.isEmpty()){
            hasPermissionSet = true;
        }
        // Prevent deletion
        for(SAC_Accion__c tarea: oldList){
            if(!hasPermissionSet){
                tarea.addError('No se puede eliminar la tarea.');
            }
        }
    }
}