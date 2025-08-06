/**
*   @description SEG_UpdateAccount_Batch
*/
public class SEG_UpdateAccount_Batch implements Database.Batchable<string>, Database.AllowsCallouts {
    public List <string> accountsToParseSet = new List<string>();
    
    public SEG_UpdateAccount_Batch(List<string> accountsToParseGet) {
        accountsToParseSet = accountsToParseGet;         
    }

    /**
     *  @description Recuperar los clientes propios de Segmentos.
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Iterable<String> start(Database.BatchableContext bc)
    {
        CBK_Log.debug('Start - Batch UpdateAccount',logginglevel.INFO);
        return accountsToParseSet;
    }

    /**
     *  @description Tratamiento de los clientes.
     *  @param bc -> Objeto contexto
     *  @param scope -> Scope del batch
     */
    public void execute(Database.BatchableContext bc, List<String> scope)
    {
        if (scope.isEmpty()) 
        {
            // No hay registros, salir.
            return;
        }

        // Indicar el número de registros a tratar en el lote.
        CBK_Log.debug('Execute - Batch UpdateAccount. Número registros lote: ' + scope.size(),logginglevel.INFO);
        for (String numPerso : scope)
        {
            CC_IdentCliente_Future.IdentificarPersALFSync ('NP', numPerso);
        }
    }

    /**
     *  @description Proceso final del batch.
     *  @param bc -> Objeto contexto
     */
    public void finish(Database.BatchableContext bc)
    {
        CBK_Log.debug('Finalización - Batch UpdateAccount',logginglevel.INFO);
    }
}