/**
*   @description SEG_ContactPendienteAsociar_P5_Batch  --> Paso 5: Borrado de Contactos CPA
*/
public with sharing class SEG_ContactPendienteAsociar_P5_Batch implements Database.Batchable<string> {
    
    public SEG_ContactPendienteAsociar_P5_Batch() {
        CBK_Log.debug('Contructor - SEG_ContactPendienteAsociar_P5_Batch', logginglevel.INFO);
    }

    /**
     *  @description start
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Iterable<String> start(Database.BatchableContext bc) {
        CBK_Log.debug('Start - SEG_ContactPendienteAsociar_P5_Batch', logginglevel.INFO);
    
        List<string> ini = new List<string>();
        for (Case caso : [SELECT Id
                            FROM Case 
                            WHERE Status = 'Descartado' 
                            AND Contact.CreatedDate = LAST_N_DAYS:7 
                          	AND RecordType.DeveloperName = 'SEG_Cliente'
                            AND (Account.Name = 'CUENTA PENDIENTE ASOCIAR' OR Contact.Account.Name = 'CUENTA PENDIENTE ASOCIAR')]){
        	ini.add(caso.Id);
        }

        return ini;
    }

    public void execute(Database.BatchableContext bc, List<String> scope) {
        if (scope.isEmpty())  {
            // No hay registros, salir.
            return;
        }

        List<Case> lstcaso = [SELECT Id, AccountId, ContactId, Account.Name, Contact.Account.Name
                            FROM Case 
                            WHERE Id IN :scope];

        List<Contact> contactsToDelete = new List<Contact>();
        List<Account> accountsToDelete = new List<Account>();

        List<Case> casesToUpdate = new List<Case>();

        for (Case caso : lstcaso) {
            if (caso.contactId != null && caso.Contact?.Account?.Name == 'CUENTA PENDIENTE ASOCIAR' && !contactsToDelete.contains(new Contact(Id=caso.ContactId))) {
                contactsToDelete.add(new Contact(Id = caso.ContactId));
            }
            if (caso.AccountId != null  && caso.Account.Name == 'CUENTA PENDIENTE ASOCIAR' && !accountsToDelete.contains(new Account(Id=caso.AccountId))) {
                accountsToDelete.add(new Account(Id = caso.AccountId));
            }
            caso.AccountId = null;
            caso.ContactId = null;
            casesToUpdate.add(caso);
        }

        // Actualizar casos
        if (!casesToUpdate.isEmpty()) {

            List<Database.SaveResult> updR = Database.update(casesToUpdate,false);
            for (Database.SaveResult resultado : updR) {
                if (!resultado.isSuccess()) {
                    for (Database.Error error : resultado.getErrors()) {
                        cbk_log.error(resultado.getId() + '  ' + error.getMessage());
                    }
                }
            }
        }

        if (!contactsToDelete.isEmpty()) {
            List <Database.DeleteResult> deleteResult = Database.delete(contactsToDelete, false);
        }

        if (!accountsToDelete.isEmpty()) {
            List <Database.DeleteResult> deleteResult = Database.delete(accountsToDelete, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('Finalización - SEG_ContactPendienteAsociar_P5_Batch', logginglevel.INFO);
    }
}