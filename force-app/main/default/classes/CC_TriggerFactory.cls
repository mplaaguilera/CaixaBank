public with sharing class CC_TriggerFactory {

    //Instancia y ejecuta el dispatcher indicado si la Trigger Factory está activa para el sObjectType
    public static void createTriggerDispatcher(Schema.sObjectType soType, String dispatcherName) {
        List<CC_Trigger_Settings__mdt> oConfig = triggerActivo(soType);
        if(oConfig != null && !oConfig.isEmpty()){
            if (oConfig[0].CC_Trigger_Activo__c) {
                Type obType = Type.forName(dispatcherName);
                CC_ITriggerDispatcher dispatcher = (obType == null) ? null : (CC_ITriggerDispatcher)obType.newInstance();
                if (dispatcher == null) {
                    throw new CC_TriggerException('No se ha encontrado un Trigger dispatcher para el objeto: ' + soType);
                } else {
                    execute(dispatcher);
                }
            }
        }
    }

    //Instancia y ejecuta el dispatcher deducido a partir del sObjectType si la Trigger Factory está activa para el sObjectType
    public static void createTriggerDispatcher(Schema.sObjectType soType) {
        List<CC_Trigger_Settings__mdt> oConfig = triggerActivo(soType);
        Type obType;

        if(oConfig != null && !oConfig.isEmpty()){
            if (oConfig[0].CC_Trigger_Activo__c) {
                if(oConfig[0].CBK_Custom_TRDisp_Name__c != null){
                    obType = Type.forName(oConfig[0].CBK_Custom_TRDisp_Name__c);
                }else{
                    obType = Type.forName('CC_TriggerDispatcherBase');
                }
                CC_ITriggerDispatcher dispatcher = (obType == null) ? null : ((CC_ITriggerDispatcher)obType.newInstance());
                if (dispatcher == null) {
                    throw new CC_TriggerException('No se ha encontrado un Trigger dispatcher para el objeto: ' + soType);
                } else {
                    execute(dispatcher);
                }
            }
        }
    }

    //Busca configuración general de Triggers, si el Trigger instanciado está activo
    private static List<CC_Trigger_Settings__mdt> triggerActivo(Schema.sObjectType soType) {
        Boolean bActivo = false;
        String originalTypeName = soType.getDescribe().getName();

        if (originalTypeName.contains('__')){
            originalTypeName = originalTypeName.substring(0, originalTypeName.lastIndexOf('__'));
        }
        //Se elimina el doble _ del Namespace   
        originalTypeName=originalTypeName.replace('__','_');

        if (originalTypeName.toUpperCase().startsWith('CC_')) {
            originalTypeName = originalTypeName.substring(3);
        }

        String sNameCfgTrigger = 'CC_Trigger_' + originalTypeName;
		System.debug('sNameCfgTrigger: ' + sNameCfgTrigger);
        return [SELECT CC_Trigger_Activo__c, CBK_Custom_TRDisp_Name__c FROM CC_Trigger_Settings__mdt WHERE DeveloperName = :sNameCfgTrigger];
    }

    //Ejecución del dispatcher, pasando
    /*
    * Este método enruta hacia el método adecuado del Dispatcher
    * Toda la información del trigger (maps, lists y booleans) se almacena en una nueva instancia de clase que los métodos
    * enrutados reciben.
    *
    * Al inicio de cada bloque (before triggers y after triggers) se invocan métodos donde podremos llevar a cabo funciones
    * de carácter transversal (bulkBefore() y bulkAfter())
    *
    * Finalmente, tenemos un método de ejecución final (andFinally) donde realizar funciones de housekeeping, logging, etc.
    */
    private static void execute(CC_ITriggerDispatcher dispatcher) {
        CC_TriggerParameters tp = new CC_TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap,
                                    Trigger.isBefore, Trigger.isAfter, Trigger.isDelete,
                                    Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete, Trigger.isExecuting);

        if (Trigger.isBefore) {
            //Tratamiento del bulk y ejecución de funciones transversales
            dispatcher.bulkBefore();
            if (Trigger.isDelete) {
                dispatcher.beforeDelete(tp);
            } else if (Trigger.isInsert) {
                dispatcher.beforeInsert(tp);
            } else if (Trigger.isUpdate) {
                dispatcher.beforeUpdate(tp);
            }
        } else {
            //Tratamiento del bulk y ejecución de funciones transversales
            dispatcher.bulkAfter();
            if (Trigger.isDelete) {
                dispatcher.afterDelete(tp);
            } else if (Trigger.isInsert) {
                dispatcher.afterInsert(tp);
            } else if (Trigger.isUpdate) {
                dispatcher.afterUpdate(tp);
            }
        }
        //Función de Housekeeping
        dispatcher.andFinally();
    }
}