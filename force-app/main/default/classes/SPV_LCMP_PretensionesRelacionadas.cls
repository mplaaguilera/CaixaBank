public with sharing class SPV_LCMP_PretensionesRelacionadas {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();

        @AuraEnabled(cacheable=true)
        public static List<Case> getPretensiones(Id recordId) {
            List<Case> listaPrete = [SELECT Id, CaseNumber, Subject, toLabel(Status), CreatedDate, SAC_ValidacionMCC__c, CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c, CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c,   
            CBK_Case_Extension_Id__r.SPV_DecisionFinal__c, CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionFinal__c         
                                    FROM Case WHERE RecordTypeId =: RECORDTYPEPRETENSION AND SAC_Reclamacion__c =: recordId]; 
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
                SPV_DatabaseDML.updateDML(prete, false);
            }            

        }
}