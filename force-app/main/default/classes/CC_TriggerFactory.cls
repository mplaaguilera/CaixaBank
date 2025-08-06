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

        //Se buscan los TriggerSettings tanto del objeto a procesar como el general para comprobar si hace falta hacer bypass
        Boolean bBypass = false;
        CC_Trigger_Settings__mdt oTriggerSettingNoGlobal;
        List<CC_Trigger_Settings__mdt> listTriggerSettings = [SELECT DeveloperName, CC_Trigger_Activo__c, CBK_Custom_TRDisp_Name__c,
                                                              CBK_Bypass__c, CBK_BypassPermissionsList__c, CBK_ExecutionPermissionsList__c, CBK_PermissionOrder__c, CBK_PermissionPriority__c
                                                              FROM CC_Trigger_Settings__mdt
                                                              WHERE (DeveloperName = :sNameCfgTrigger OR DeveloperName = 'GlobalTriggerSettings')];
        if(!listTriggerSettings.isEmpty()){
            for(CC_Trigger_Settings__mdt oTriggerSetting : listTriggerSettings){
                //Se extrae el que no es 'GlobalTriggerSettings' para validarlo siempre al final
                if(oTriggerSetting.DeveloperName != 'GlobalTriggerSettings'){
                    oTriggerSettingNoGlobal = oTriggerSetting;
                }

                //Se comprueba si en el 'GlobalTriggerSettings' se debe hacer bypass o no, y se quita de la lista
                else{
                    bBypass = checkBypass(oTriggerSetting);
                }
            }
        }

        //En el caso de no haber encontrado bypass en 'GlobalTriggerSettings', se mira si se debe hacer bypass según el TriggerSettings específico del Trigger
        if(!bBypass){
            bBypass = checkBypass(oTriggerSettingNoGlobal);
        }

        if(bBypass){
            return new List<CC_Trigger_Settings__mdt>();
        }else{
            return new List<CC_Trigger_Settings__mdt>{oTriggerSettingNoGlobal};
        }
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

    //Función para comprobar si se debe hacer bypass o no dependiendo de los valores informados en un TriggerSetting
    public static Boolean checkBypass(CC_Trigger_Settings__mdt oTriggerSetting){
        //Boolean para guardar el valor de las validaciones
        Boolean bBypass = false;

        //Se comprueba si tiene el bypass activo
        if(oTriggerSetting != null && oTriggerSetting.CBK_Bypass__c){
            //Se inicializa el Boolean como true en el caso de que esté activo el Bypass
            bBypass = true;

            //Se comprueba qué debe comprobarse último, en el caso de tener los dos informados
            //En el caso de ser 'Bypass', se comprueba primero 'Execution' y después 'Bypass'
            if(oTriggerSetting != null && oTriggerSetting.CBK_PermissionPriority__c == 'Bypass'){
                //Se comprueba si tiene alguno de los Custom Permissions informados en ExecutionPermissions
                //En el caso de encontrar una coincidencia en ExecutionPermissions, se informa que no debe hacerse bypass
                if(String.isNotBlank(oTriggerSetting.CBK_ExecutionPermissionsList__c) && checkPermissionInBypassExecution(oTriggerSetting.CBK_ExecutionPermissionsList__c)){
                    bBypass = false;
                }

                //Se comprueba si tiene alguno de los Custom Permissions informados en BypassPermissions
                //En el caso de NO encontrar una coincidencia en BypassPermissions, se informa que no debe hacerse bypass
                if(String.isNotBlank(oTriggerSetting.CBK_BypassPermissionsList__c) && !checkPermissionInBypassExecution(oTriggerSetting.CBK_BypassPermissionsList__c)){
                    bBypass = false;
                }
            }

            //En el caso de ser 'Execution' o no tener preferencia informada, se comprueba primero 'Bypass' y después 'Execution'
            else{
                //Se comprueba si tiene alguno de los Custom Permissions informados en BypassPermissions
                //En el caso de NO encontrar una coincidencia en BypassPermissions, se informa que no debe hacerse bypass
                if(String.isNotBlank(oTriggerSetting.CBK_BypassPermissionsList__c) && !checkPermissionInBypassExecution(oTriggerSetting.CBK_BypassPermissionsList__c)){
                    bBypass = false;
                }

                //Se comprueba si tiene alguno de los Custom Permissions informados en ExecutionPermissions
                //En el caso de encontrar una coincidencia en ExecutionPermissions, se informa que no debe hacerse bypass
                if(String.isNotBlank(oTriggerSetting.CBK_ExecutionPermissionsList__c) && checkPermissionInBypassExecution(oTriggerSetting.CBK_ExecutionPermissionsList__c)){
                    bBypass = false;
                }
            }
      }

        //Retorno
        return bBypass;
    }

    //Función para comprobar si el usuario tiene un Permission en concreto en una lista de Permissions separada por ';'
    private static Boolean checkPermissionInBypassExecution(String sPermissions){
        //En el caso de encontrar una coincidencia, se devuelve true
        //En el caso de tener ninguno de los CustomPermissions informados, se devuelve false
        for(String sCustomPermission : sPermissions.split(';')){
            if(FeatureManagement.checkPermission(sCustomPermission)){
                return true;
            }
        }

        return false;
    }
}