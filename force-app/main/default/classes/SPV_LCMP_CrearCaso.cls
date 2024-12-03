public with sharing class SPV_LCMP_CrearCaso {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    
    @AuraEnabled
    public static String comprobarExpDuplicado(String numeroExpediente, String entidadAfectada) {

        if(Schema.sObjectType.Case.isAccessible()){
            List<Case> listaCasos = [SELECT Id, CaseNumber FROM Case WHERE RecordTypeId = :RECORDTYPERECLAMACION AND SPV_NumExpediente__c = :numeroExpediente AND SAC_Entidad_Afectada__c = :entidadAfectada LIMIT 1];

            if(!listaCasos.isEmpty()){
                return listaCasos[0].CaseNumber;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
}