/**
*   @description SEG_ContactPendienteAsociar_P4_Batch  --> Paso 4: Borrado de cuentas sin caso y contacto
*/
public with sharing class SEG_ContactPendienteAsociar_P4_Batch  implements Database.Batchable<account> {
    public SEG_ContactPendienteAsociar_P4_Batch() {
        CBK_Log.debug('Contructor - SEG_ContactPendienteAsociar_P4_Batch',logginglevel.INFO);
    }


    /** 
     *  @description start
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Iterable<account> start(Database.BatchableContext bc)
    {
        CBK_Log.debug('Start - SEG_ContactPendienteAsociar_P4_Batch',logginglevel.INFO);
        list<account> lstAcc = new list<account>();

        for (account acc : [select Id,
                                   (select Id from contacts LIMIT 10),
                                   (select Id from cases LIMIT 10)
                              from account
                             where RecordType.DeveloperName like '%SEG%'
                              and Account.name ='CUENTA PENDIENTE ASOCIAR']){      
                if ((acc.contacts.size() ==0)&&(acc.cases.size() ==0)){
                    lstAcc.add(acc);          
            }       
        }       

        return lstAcc;
    }

    /**
     *  @description execute
     *  @param bc -> Objeto contexto
     *  @param scope -> Scope del batch
     */
    public void execute(Database.BatchableContext bc, List<account> scope)
    {
        if (scope.isEmpty()) 
        {
            // No hay registros, salir.
            return;
        }
        
        delete scope;
        
    }

    /**
     *  @description Proceso final del batch.
     *  @param bc -> Objeto contexto
     */
    public void finish(Database.BatchableContext bc)
    {
        CBK_Log.debug('Finalización - SEG_ContactPendienteAsociar_P4_Batch',logginglevel.INFO);
    }   
}