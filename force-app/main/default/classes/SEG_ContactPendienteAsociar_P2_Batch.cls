/**
*   @description SEG_ContactPendienteAsociar_P2_Batch  --> Paso 2: Desvincular CUENTA PENDIENTE ASOCIAR Si tiene una cuenta ya asociada
*/
public with sharing class SEG_ContactPendienteAsociar_P2_Batch implements Database.Batchable<string> {
    public SEG_ContactPendienteAsociar_P2_Batch() {
        CBK_Log.debug('Contructor - SEG_ContactPendienteAsociar_P2_Batch',logginglevel.INFO);
    }

    /** 
     *  @description start
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Iterable<String> start(Database.BatchableContext bc)
    {
        CBK_Log.debug('Start - SEG_ContactPendienteAsociar_P2_Batch',logginglevel.INFO);

        list<string> ini = new list<string>();
        map<string,string> mapAccount = New map<string,string>();

        for (AccountContactRelation con :[select ContactId
                            from AccountContactRelation
                            where Account.Name='CUENTA PENDIENTE ASOCIAR'
                            and Account.RecordType.developername='CC_ClienteSEG']){
            ini.add(con.ContactId);
        }


        cbk_log.debug('ini: ' + ini.size());
        return ini;
    }

    /**
     *  @description execute
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
        list<string> ini2 = new list<string>();
        map<string,string> mapAccount = new map<string,string>();

        for (AggregateResult ar :[select ContactId,count(Id),min(AccountId)
                                    from AccountContactRelation
                                    where ContactId in :scope
                                    and Account.Name!='CUENTA PENDIENTE ASOCIAR'
                                    group by ContactId]){
            if (ar.get('expr0')==1){
                ini2.add((string)ar.get('ContactId'));
                mapAccount.put((string)ar.get('ContactId'),(string)ar.get('expr1'));
            }
        }

        cbk_log.debug('ini2: ' + ini2.size());        


        if (ini2.isEmpty()) 
        {
            // No hay registros, salir.
            return;
        }
        
        list<Contact> lstContact = [select Id,AccountId
                                      from Contact 
                                     where Id in :ini2];
        for (Contact c: lstContact){
            c.accountId=mapAccount.get(c.Id);
           
        }
        
        List<Database.SaveResult> updR=database.update(lstContact,false);        
        for (Database.SaveResult resultado : updR) {
            if (!resultado.isSuccess()) {
                for (Database.Error error : resultado.getErrors()) {
                   // cbk_log.error(resultado.getId() + '  ' + error.getMessage());
                    CBK_Log.DebugProcessConfigBuilder builder = new CBK_Log.DebugProcessConfigBuilder().setLogMessage('SEG_ContactPendienteAsociar_P2_Batch: error returned ' + error.getMessage()).setLevel(LoggingLevel.ERROR);
                    builder.addLog();
                }
            }
        }

        list<AccountContactRelation> eliminar = [select ContactId,IsDirect
                                                  from AccountContactRelation
                                                 where Account.Name='CUENTA PENDIENTE ASOCIAR'
                                                   and Account.RecordType.developername='CC_ClienteSEG'
                                                   and IsDirect=false
                                                   and ContactId in :ini2];
    
    
        List<Database.DeleteResult> delR=database.delete(eliminar,false);
        for (Database.DeleteResult resultado : delR) {
            if (!resultado.isSuccess()) {
                for (Database.Error error : resultado.getErrors()) {
                    // cbk_log.error(resultado.getId()+ '  ' + error.getMessage());
                    CBK_Log.DebugProcessConfigBuilder builder = new CBK_Log.DebugProcessConfigBuilder().setLogMessage('SEG_ContactPendienteAsociar_P2_Batch: error returned ' + error.getMessage()).setLevel(LoggingLevel.ERROR);
                    builder.addLog();
                }
            }
        }
        //Se insertan los CBK_Logs
        CBK_Log.insertDML();
        cbk_log.debug('eliminar: ' + eliminar.size());    
    }

    /**
     *  @description Proceso final del batch.
     *  @param bc -> Objeto contexto
     */
    public void finish(Database.BatchableContext bc)
    {
        CBK_Log.debug('Finalización - SEG_ContactPendienteAsociar_P2_Batch',logginglevel.INFO);
    }   
}