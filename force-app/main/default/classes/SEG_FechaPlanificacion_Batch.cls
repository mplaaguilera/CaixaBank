/**
*   @description SEG_FechaPlanificacion_Batch
*/
public class SEG_FechaPlanificacion_Batch implements Database.Batchable<sObject> {

    /*
        @description Valor para limitar la query.
    */    
    public String limitQuery;
    
    /**
    *    @description Constructor por defecto
    */
    public SEG_FechaPlanificacion_Batch() {
        limitQuery = '';
    }

    /**
    *   @description Constructor con parámetro de LIMIT
    *   @param paramLimit -> limite de la query.
    */
    public SEG_FechaPlanificacion_Batch(String paramLimit) {
        /**
         * @return SEG_FechaPlanificacion_Batch
         */
        limitQuery = paramLimit;
    }

    /**
     *  @description Recuperar los clientes propios de Segmentos.
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        CBK_Log.debug('Start - Batch fecha de planificación',logginglevel.INFO);

        Datetime todayDatetime = Datetime.now();

        String query = 'SELECT Id, AccountId, OwnerId, Status, SEG_Subestado__c, SEG_Fecha_planificaci_n__c, SEG_Grupo__c, SEG_Grupo_Anterior__c, CC_Owner_Anterior__c';
        query = query + ' FROM Case';
        query = query + ' WHERE (SEG_Fecha_planificaci_n__c =: todayDatetime OR SEG_Fecha_planificaci_n__c <: todayDatetime)';
        query = query + ' ORDER BY CreatedDate DESC';

        if (String.isNotBlank(limitQuery))
        {
            query = query + ' LIMIT ' + limitQuery;
        }

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<Case> scope)
    {
        if (scope.isEmpty()) 
        {
            // No hay registros, salir.
            return;
        }

        // Indicar el número de registros a tratar en el lote.
        CBK_Log.debug('Execute - Batch fecha de planificación. Número registros lote: ' + scope.size(),logginglevel.INFO);

        System.debug(scope);

        for(Case c : scope){

            System.debug('caso ' +  c);
            SEG_MetodosComunes.devolverSegBO(c.Id);

        }



    }

    public void finish(Database.BatchableContext bc)
    {
        CBK_Log.debug('Finalización - Batch fecha planificación',logginglevel.INFO);
    }

}