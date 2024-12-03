/**
*   @description SEG_ContactPendienteAsociar_P3_Batch  --> Paso 3: Cambiar Cuenta Caso
*/
public with sharing class SEG_ContactPendienteAsociar_P3_Batch  implements Database.Batchable<AggregateResult> {
    public SEG_ContactPendienteAsociar_P3_Batch() {
        CBK_Log.debug('Contructor - SEG_ContactPendienteAsociar_P3_Batch',logginglevel.INFO);
    }


    /** 
     *  @description start
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Iterable<AggregateResult> start(Database.BatchableContext bc)
    {
        CBK_Log.debug('Start - SEG_ContactPendienteAsociar_P3_Batch',logginglevel.INFO);
        list<string> ini = new list<string>();
        list<string> ini2 = new list<string>();

        AggregateResult[] groupedResults =  [select AccountId,count(Id),min(contactId)
                                            from AccountContactRelation
                                            where ContactId in (select contactId
                                                                    from Case
                                                                where RecordType.DeveloperName like '%SEG%' 
                                                                    and Account.RecordType.DeveloperName ='CC_ClienteSEG'
                                                                    and Account.name ='CUENTA PENDIENTE ASOCIAR'
                                                                    and contact.account.name!='CUENTA PENDIENTE ASOCIAR'
                                                                    and contactid!=null)
                                            group by AccountId
                                            Having count(Id)=1];


        return groupedResults;
    }

    /**
     *  @description execute
     *  @param bc -> Objeto contexto
     *  @param scope -> Scope del batch
     */
    public void execute(Database.BatchableContext bc, List<AggregateResult> scope)
    {
        if (scope.isEmpty()) 
        {
            // No hay registros, salir.
            return;
        }
        
        map<string,string> mapCase = New map<string,string>();

        for (AggregateResult ar : scope)  {
            if (ar.get('expr0')==1){
                mapCase.put((string)ar.get('expr1'),(string)ar.get('AccountId'));
            }
        }

        list<Case> lstCase = [select Id,contactId,AccountId
                                from Case
                            where RecordType.DeveloperName like '%SEG%'
                                and Account.RecordType.DeveloperName ='CC_ClienteSEG'
                                and Account.name ='CUENTA PENDIENTE ASOCIAR'
                                and contact.account.name!='CUENTA PENDIENTE ASOCIAR'
                                and contactid in :mapCase.Keyset()
                                LIMIT 20];


        for (case c : lstCase) {
            c.AccountId = mapCase.get(c.ContactId);
        }
        update lstCase;
        
    }

    /**
     *  @description Proceso final del batch.
     *  @param bc -> Objeto contexto
     */
    public void finish(Database.BatchableContext bc)
    {
        CBK_Log.debug('Finalización - SEG_ContactPendienteAsociar_P3_Batch',logginglevel.INFO);
    }   
}