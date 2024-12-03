public with sharing class SAC_LCMP_PretensionesRelacionController {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

        @AuraEnabled(cacheable=true)
        public static List<Case> getPretensiones(Id recordId) {
            List<Case> listaPrete = [SELECT Id, CaseNumber, Subject, toLabel(Status), CreatedDate, SAC_ValidacionMCC__c FROM Case WHERE RecordTypeId =: RECORDTYPEPRETENSION AND SAC_Reclamacion__c =: recordId]; 
            return listaPrete;
        }

        @AuraEnabled
        public static void validarPretension(Id recordId, boolean checkValidar){ 
            
            Case prete = [SELECT Id, SAC_ValidacionMCC__c FROM Case WHERE RecordTypeId =: RECORDTYPEPRETENSION AND Id =: recordId];

            if(prete.SAC_ValidacionMCC__c == false && checkValidar == true){
                prete.SAC_ValidacionMCC__c = true;
            }else if (prete.SAC_ValidacionMCC__c == true && checkValidar == false) {
                prete.SAC_ValidacionMCC__c = false;
            }
            if (Schema.sObjectType.Case.isUpdateable()){
                SAC_DatabaseDML.updateDML(prete, false);
            }            

        }
}