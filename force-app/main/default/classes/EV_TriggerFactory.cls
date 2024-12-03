public with sharing class EV_TriggerFactory
{
    /*
    * Clase EV_TriggerFactory, con 2 funciones principales:
    * 1. Creación del Dispatcher del objeto
    * 2. Invocar el método adecuado del Dispatcher en función del evento recibido
    */

    /* 
    * Este es el método de entrada a la TriggerFactory
    * Comprueba si la ejecución del trigger está activa.
    * Creación del dispatcher para cada objeto.
    * Ejecución del dispatcher para ejecutar la lógica de negocio del trigger.
    */
    public static void createTriggerDispatcher(Schema.sObjectType soType)
    {
        /*
        * Buscar configuración para ejecutar o no el trigger.
        */
        Boolean bActivo = getTriggerActive(soType);

        if (bActivo)
        {
            CC_ITriggerDispatcher dispatcher = getTriggerDispatcher(soType);
            if (dispatcher == null)
                throw new CC_TriggerException('No se ha encontrado un Trigger dispatcher para el objeto: ' + soType);
            execute(dispatcher);
        }
    }

    /*
    * Este método se encarga de buscar en la configuración general de Triggers, si el Trigger instanciado está activo
    * para ejecutarse.
    */
    public static Boolean getTriggerActive(Schema.sObjectType soType)
    {
        Boolean bActivo = false;
        String originalTypeName = soType.getDescribe().getName();
        
        if (originalTypeName.toLowerCase().endsWith('__c')) {
        	Integer index = originalTypeName.toLowerCase().indexOf('__c');
            originalTypeName = originalTypeName.substring(0, index);
        }
        
        String sNameCfgTrigger = 'EV_Trigger_' + originalTypeName;

        List<CC_Trigger_Settings__mdt> oConfig = [SELECT Id,CC_Trigger_Activo__c FROM CC_Trigger_Settings__mdt WHERE DeveloperName = :sNameCfgTrigger];
        if (oConfig.size()==1)
        {
            bActivo = oConfig[0].CC_Trigger_Activo__c;
        }        

        return bActivo;
    }
 
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
    private static void execute(CC_ITriggerDispatcher dispatcher)
    {
        CC_TriggerParameters tp = new CC_TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap,
                                    Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, 
                                    Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete, Trigger.isExecuting);
         
        if (Trigger.isBefore) {
 
            //Tratamiento del bulk y ejecución de funciones transversales 
            dispatcher.bulkBefore();
             
            if (Trigger.isDelete)
            {
                dispatcher.beforeDelete(tp);
            }else if (Trigger.isInsert){
                dispatcher.beforeInsert(tp);
            }else if (Trigger.isUpdate){
                dispatcher.beforeUpdate(tp);
            }
        }
        else    // After trigger events
        {
            //Tratamiento del bulk y ejecución de funciones transversales
            dispatcher.bulkAfter();
             
            if (Trigger.isDelete){
                dispatcher.afterDelete(tp);
            }else if (Trigger.isInsert){
                dispatcher.afterInsert(tp);
            }else if (Trigger.isUpdate){
                dispatcher.afterUpdate(tp);
            }
        }
 
        //Función de Housekeeping
        dispatcher.andFinally();
    } 
 
    /*
    * Características:
    * 1. Utiliza una convención de nombres para invocar las clases Dispatcher 
    * 2. Con esta convención y con las capacidades de Apex de instanciar clases mediante el nombre, se crean los Dispatcher
    * y se desacopla por completo la TriggerFactory del Dispatcher 
    */
    private static CC_ITriggerDispatcher getTriggerDispatcher(Schema.sObjectType soType)
    {
        String originalTypeName = soType.getDescribe().getName();
        String dispatcherTypeName = null;
        
        if (originalTypeName.toLowerCase().endsWith('__c')) {
            Integer index = originalTypeName.toLowerCase().indexOf('__c');
            dispatcherTypeName = originalTypeName.substring(0, index);
        }
        else
           	dispatcherTypeName = originalTypeName;
 
        // Preparar el nombre final de la clase dispatcher.
        dispatcherTypeName = 'EV_' + dispatcherTypeName + '_TRDisp';
        
        //Instanciación mediante el nombre de la clase, que se obtiene en tiempo de ejecución
        //Observar la creación de tipo y la creación de la instancia con el cast 
        Type obType = Type.forName(dispatcherTypeName);
        CC_ITriggerDispatcher dispatcher = (obType == null) ? null : (CC_ITriggerDispatcher)obType.newInstance();
        return dispatcher;
    }
}