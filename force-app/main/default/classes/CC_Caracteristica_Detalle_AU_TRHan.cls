public with sharing class CC_Caracteristica_Detalle_AU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		  process((Map<Id, CC_Caracteristica_Detalle__c>)tp.newMap, (Map<Id, CC_Caracteristica_Detalle__c>)tp.oldMap);
	}

	private void process(Map<Id, CC_Caracteristica_Detalle__c> newMap, Map<Id, CC_Caracteristica_Detalle__c> oldMap) {
        updateContactOrAccountRelated(newMap, oldMap);
	}

    private void updateContactOrAccountRelated(Map<Id, CC_Caracteristica_Detalle__c> newMap, Map<Id, CC_Caracteristica_Detalle__c> oldMap) {
        Map<Id,Contact> mapContactsToUpdateById = new Map<Id,Contact>();
        Map<Id,Account> mapAccountsToUpdateById = new Map<Id,Account>();
        Set<Id> detailsToReview = new Set<Id>();
        Set<Id> oldContacts = new Set<Id>();
        Set<Id> oldAccounts = new Set<Id>();

        Map<Id, CC_Caracteristica_Detalle__c> detallesNegocio = new Map<Id, CC_Caracteristica_Detalle__c>([SELECT Id,CC_Caracteristica__r.OS_Negocio__c FROM CC_Caracteristica_Detalle__c  WHERE Id IN :newMap.keySet()]); 

        //filtro para quedarme solo los que hayan tenido un update de Contact o de Account o de Caracteristica
        for(CC_Caracteristica_Detalle__c detalle : newMap.values()) {
            if(oldMap.containsKey(detalle.Id) && detallesNegocio.containskey(detalle.Id) && detallesNegocio.get(detalle.Id).CC_Caracteristica__r.OS_Negocio__c == 'CC') {
                CC_Caracteristica_Detalle__c oldDetalle = oldMap.get(detalle.Id);
                if (detalle.CC_Cliente__c != null && (oldDetalle == null || oldDetalle.CC_Cliente__c != detalle.CC_Cliente__c)) {
                    detailsToReview.add(detalle.Id);
                    oldContacts.add(oldDetalle.CC_Cliente__c);
                }
                if (detalle.CC_Empleado__c != null && (oldDetalle == null || oldDetalle.CC_Empleado__c != detalle.CC_Empleado__c)) {
                    detailsToReview.add(detalle.Id);
                    oldContacts.add(oldDetalle.CC_Empleado__c);
                }
                if (detalle.CC_Cuenta__c != null && (oldDetalle == null || oldDetalle.CC_Cuenta__c != detalle.CC_Cuenta__c)) {
                    detailsToReview.add(detalle.Id);
                    oldAccounts.add(oldDetalle.CC_Cuenta__c);
                }
                if (detalle.CC_Centro_CaixaBank__c != null && (oldDetalle == null || oldDetalle.CC_Centro_CaixaBank__c != detalle.CC_Centro_CaixaBank__c)) {
                    detailsToReview.add(detalle.Id);
                    oldAccounts.add(oldDetalle.CC_Centro_CaixaBank__c);
                }
                if(detalle.CC_Caracteristica__c != null && (oldDetalle == null || oldDetalle.CC_Caracteristica__c != detalle.CC_Caracteristica__c)) {
                    detailsToReview.add(detalle.Id);
                }
            }

        }
        if(!detailsToReview.isEmpty()) {
            //Extraigo solo los que he filtrado junto con los campos CC_Tiene_Caracteristica_Detalle__c de contact y account, 
            //junto con los que queden sobre los antiguas contacts y account
             List<CC_Caracteristica_Detalle__c> lstCaracteristicaDetalle = [SELECT Id, CC_Caracteristica__c, CC_Caracteristica__r.CC_Activo__c,
                                                                            CC_Cliente__c, CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c, 
                                                                            CC_Empleado__c, CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c,
                                                                            CC_Cuenta__c, CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c,
                                                                            CC_Centro_CaixaBank__c , CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c
                                                                        FROM CC_Caracteristica_Detalle__c 
                                                                        WHERE CC_Caracteristica__r.CC_Activo__c = true AND CC_Caracteristica__r.OS_Negocio__c = 'CC'
                                                                             AND (Id IN :detailsToReview OR
                                                                              CC_Cliente__c IN :oldContacts OR CC_Empleado__c IN :oldContacts OR 
                                                                               CC_Cuenta__c IN :oldAccounts OR CC_Centro_CaixaBank__c IN :oldAccounts)
                                                                        ];

            
            // Recorro los detalles y actualizo los contactos y cuentas que no tengan ya el valor a true
            for(CC_Caracteristica_Detalle__c detalle : lstCaracteristicaDetalle) {
                //Control de que las nuevas cuentas o contactos tengan el campo CC_Tiene_Caracteristica_Detalle__c a true, sino los actualizo
                    if (detalle.CC_Cliente__c != null && !detalle.CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c) {
                        Contact c = new Contact(Id = detalle.CC_Cliente__c);
                        c.CC_Tiene_Caracteristica_Detalle__c = true;
                        mapContactsToUpdateById.put(detalle.CC_Cliente__c,c);
                    }
                    if (detalle.CC_Empleado__c != null && !detalle.CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c) {
                        Contact c = new Contact(Id = detalle.CC_Empleado__c);
                        c.CC_Tiene_Caracteristica_Detalle__c = true;
                        mapContactsToUpdateById.put(detalle.CC_Empleado__c,c);
                    }
                    if (detalle.CC_Cuenta__c != null && !detalle.CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c) {
                        Account a = new Account(Id = detalle.CC_Cuenta__c);
                        a.CC_Tiene_Caracteristica_Detalle__c = true;
                        mapAccountsToUpdateById.put(detalle.CC_Cuenta__c,a);
                    }
                    if (detalle.CC_Centro_CaixaBank__c != null && !detalle.CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c) {
                        Account a = new Account(Id = detalle.CC_Centro_CaixaBank__c);
                        a.CC_Tiene_Caracteristica_Detalle__c = true;
                        mapAccountsToUpdateById.put(detalle.CC_Centro_CaixaBank__c,a);
                    }
                    //Control de que las antiguas cuentas o contactos aun tengan Detalles Caracteristicas asociadas, si es asi las quito de los sets para no actualizarles el CC_Tiene_Caracteristica_Detalle__c
                    if(detalle.CC_Cliente__c != null && oldContacts.contains(detalle.CC_Cliente__c)){
                        oldContacts.remove(detalle.CC_Cliente__c);
                    }
                    if(detalle.CC_Empleado__c != null && oldContacts.contains(detalle.CC_Empleado__c)){
                        oldContacts.remove(detalle.CC_Empleado__c);
                    }
                    if(detalle.CC_Cuenta__c != null && oldAccounts.contains(detalle.CC_Cuenta__c)){
                        oldAccounts.remove(detalle.CC_Cuenta__c);
                    }
                    if(detalle.CC_Centro_CaixaBank__c != null && oldAccounts.contains(detalle.CC_Centro_CaixaBank__c)){
                        oldAccounts.remove(detalle.CC_Centro_CaixaBank__c);
                    }
            }
            //Reviso si aun hay registros en los sets de oldContact y oldAccount, si es asi, 
            //significa que ya no tienen Detalles Caracteristicas aociados que cumplan por lo que hay que ponerles el campo CC_Tiene_Caracteristica_Detalle__c a false
            if(!oldContacts.isEmpty()) {
                for(Id oldContactId : oldContacts) {
                    Contact c = new Contact(Id = oldContactId);
                    c.CC_Tiene_Caracteristica_Detalle__c = false;
                    mapContactsToUpdateById.put(oldContactId,c);
                }
            }
            if(!oldAccounts.isEmpty()) {
                for(Id oldAccountId : oldAccounts) {
                    Account a = new Account(Id = oldAccountId);
                    a.CC_Tiene_Caracteristica_Detalle__c = false;
                    mapAccountsToUpdateById.put(oldAccountId,a);
                }
            }
            //Si hay Contactos o Accounts a Actualizar los actualizo
            if(!mapContactsToUpdateById.isEmpty()) {
                update mapContactsToUpdateById.values();
            }
            if(!mapAccountsToUpdateById.isEmpty()) {
                update mapAccountsToUpdateById.values();
            }
        }
	}
}