public with sharing class SEG_ContactTriggerHelper {

    public static void validarDuplicidad(List<Contact> lstContactos) {

        Set<Id> setAccounts = new Set<Id>();
        Map<Id, List<Contact>> mapAccountIdContacts = new Map<Id, List<Contact>>();

        for (Contact contacto : lstContactos) {
            if(contacto.AccountId != null){
                setAccounts.add(contacto.AccountId);
            }
        }

        if (!setAccounts.isEmpty()) {
            List<Contact> contactosCuentas = [SELECT Id, Email, AccountId FROM Contact WHERE AccountId IN : setAccounts AND Email != NULL AND RecordType.DeveloperName = 'CC_Cliente' AND (Account.RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClienteSEG')];

            for (Contact contactoExistentes : contactosCuentas) {
                if (mapAccountIdContacts.containsKey(contactoExistentes.AccountId)) {
                    List<Contact> lstContAux = mapAccountIdContacts.get(contactoExistentes.AccountId);
                    lstContAux.add(contactoExistentes);
                    mapAccountIdContacts.put(contactoExistentes.AccountId, lstContAux);
                } else {
                    List<Contact> lstContAux = new List<Contact>();
                    lstContAux.add(contactoExistentes);
                    mapAccountIdContacts.put(contactoExistentes.AccountId, lstContAux);
                }
            }

            for (Contact contacto : lstContactos) {
                if (mapAccountIdContacts.containsKey(contacto.AccountId)) {
                    for (Contact contactoExistente : mapAccountIdContacts.get(contacto.AccountId)) {
                        if (contactoExistente.Email.equalsIgnoreCase(contacto.Email)) {
                            contacto.addError('No se puede crear el contacto. Ya existe un contacto en la misma cuenta con el mismo email.');
                        }
                    }
                }
            }
        }
    }
}