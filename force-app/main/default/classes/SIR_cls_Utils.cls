public with sharing class SIR_cls_Utils {

    public static Set<Id> getAppRtIds(String appDevName,String obj){
        
        Set<Id> setRtIds = new Set<Id>();
        if(appDevName == SIR_Constantes.APP_EMPRESA_DEVELOPERNAME){
            switch on obj {
                when 'SIREC__SIREC_obj_proceso__c' {
                    Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
                    setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_EMP_FLUJO).getRecordTypeId());
                    setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId());  
                }
                when 'SIREC__SIREC_obj_acciones__c' {
                    Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
                    setRtIds.add(mapRT.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_EMPRESA).getRecordTypeId());
                }
            }
        }
        else if(appDevName == SIR_Constantes.APP_RETAIL_DEVELOPERNAME){
            switch on obj {
                when 'SIREC__SIREC_obj_proceso__c' {
                    Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
                    setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId());
                    setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA).getRecordTypeId());  
                }
                when 'SIREC__SIREC_obj_acciones__c' {
                    Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
                    setRtIds.add(mapRT.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_WORKFLOW).getRecordTypeId());
                    setRtIds.add(mapRT.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId());
                    setRtIds.add(mapRT.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO).getRecordTypeId());
                }
            }
        }
        return setRtIds;
    }
   // Devuelve el prefijo que se debe incorporar en las llamadas a WS segun la app en la que esté conetada el gestor
   public static String getActorPrefix(){
                                                
        List<UserAppInfo> userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() AND FormFactor !='Small' ORDER BY LastModifiedDate DESC LIMIT 1 ];            
        return userAppInfo.size()>0 ? getActorPrefix(userAppInfo[0].AppDefinitionId): '';                 
   }

    public static String getActorPrefix(String appDefinitionId){
        try {
            String appDeveloperName;
            if(Test.isRunningTest() && appDefinitionId == 'mcsolutions'){                
                appDeveloperName = 'SIR_misClientesSolutions';
            }else if(Test.isRunningTest() && appDefinitionId == 'mcsolutionsEmp'){                
                appDeveloperName = 'SIRE_MisClientesSolucionesEMP';
            }else{
                appDeveloperName = [SELECT DurableId, DeveloperName FROM AppDefinition Where DurableId = :appDefinitionId LIMIT 1].DeveloperName;
            }
            String prefix='';
            if (appDeveloperName != null){
                switch on appDeveloperName {
                when 'SIR_misClientesSolutions' {
                    prefix = SIR_Constantes.APP_ACT_MCSOL_PREFIX;
                }
                when 'SIRE_MisClientesSolucionesEMP' {
                    prefix = SIR_Constantes.APP_ACT_MCSOLEMP_PREFIX;
                }
                when else {
                    prefix = '';
                  }
               }     
           } 
           return prefix;
        } catch (Exception ex) {
            throw new SIRECallException('SIR_cls_Utils - La aplicación que se está usando no tiene acceso al Sistema SIREC');
        }        
    }

     public class SIRECallException extends Exception {}
}