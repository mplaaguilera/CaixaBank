/**
*   @description SEG_ConciliacionAccount_SC
*/
public with sharing class SEG_ConciliacionAccount_SC implements Schedulable
{
    /**
     *  @description Programación del batch.
     *  @param sc -> Objeto contexto
     */
    public void execute(SchedulableContext sc)
    {
        SEG_ConciliacionAccount_Batch batch = new SEG_ConciliacionAccount_Batch();
        Database.executeBatch(batch,25);
    }
}