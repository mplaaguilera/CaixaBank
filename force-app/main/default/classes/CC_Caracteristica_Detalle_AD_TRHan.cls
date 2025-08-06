public with sharing class CC_Caracteristica_Detalle_AD_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		  process((Map<Id, CC_Caracteristica_Detalle__c>)tp.oldMap);
	}

	private void process(Map<Id, CC_Caracteristica_Detalle__c> oldMap) {
        updateContactOrAccountOldRelated(oldMap);
	}

    private void updateContactOrAccountOldRelated(Map<Id, CC_Caracteristica_Detalle__c> oldMap){
        Map<Id,Contact> mapContactsToUpdateById = new Map<Id,Contact>();
        Map<Id,Account> mapAccountsToUpdateById = new Map<Id,Account>();
        Set<Id> contacts = new Set<Id>();
        Set<Id> accounts = new Set<Id>();
        Set<Id> caracteristicas = new Set<Id>();
        for(CC_Caracteristica_Detalle__c detalle : oldMap.values()){
            if(detalle.CC_Caracteristica__c != null){
               caracteristicas.add(detalle.CC_Caracteristica__c); 
            }
        }
        Map<Id, CC_Caracteristica__c> mapCaracteristicas = new Map<Id, CC_Caracteristica__c>([SELECT Id, OS_Negocio__c FROM CC_Caracteristica__c WHERE Id IN :caracteristicas]);

        
        //Recorro los detalles borrados para recoger sus contactos y cuentas
        for(CC_Caracteristica_Detalle__c detalle : oldMap.values()) {
            if(mapCaracteristicas.containskey(detalle.CC_Caracteristica__c) && mapCaracteristicas.get(detalle.CC_Caracteristica__c).OS_Negocio__c == 'CC') {
                if (detalle.CC_Cliente__c != null) {
                    contacts.add(detalle.CC_Cliente__c);
                }
                if (detalle.CC_Empleado__c != null) {
                    contacts.add(detalle.CC_Empleado__c);
                }
                if (detalle.CC_Cuenta__c != null) {
                    accounts.add(detalle.CC_Cuenta__c);
                }
                if (detalle.CC_Centro_CaixaBank__c != null) {
                    accounts.add(detalle.CC_Centro_CaixaBank__c);
                }
            }
        }
        if(!contacts.isEmpty() || !accounts.isEmpty()) {
            //Extraigo los detalles junto con los campos CC_Tiene_Caracteristica_Detalle__c de contact y account relacionados, pero solo si la Caracteristica está activa
            List<CC_Caracteristica_Detalle__c> lstCaracteristicaDetalle = [SELECT Id, CC_Caracteristica__c, 
                                                                            CC_Cliente__c, CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c, 
                                                                            CC_Empleado__c, CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c,
                                                                            CC_Cuenta__c, CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c,
                                                                            CC_Centro_CaixaBank__c , CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c
                                                                        FROM CC_Caracteristica_Detalle__c 
                                                                        WHERE (CC_Cliente__c IN :contacts 
                                                                            OR CC_Empleado__c IN :contacts 
                                                                            OR CC_Cuenta__c IN :accounts 
                                                                            OR CC_Centro_CaixaBank__c IN :accounts)
                                                                            AND CC_Caracteristica__r.CC_Activo__c = true AND CC_Caracteristica__r.OS_Negocio__c = 'CC'];
            // Recorro los detalles y extraigo los contactos y las cuentas que aparezcan, ya que aun tienen detalles asociados con caracteristicas activas
            for(CC_Caracteristica_Detalle__c detalle : lstCaracteristicaDetalle){
                if(detalle.CC_Cliente__c != null && contacts.contains(detalle.CC_Cliente__c)){
                    contacts.remove(detalle.CC_Cliente__c);
                }
                if(detalle.CC_Empleado__c  != null && contacts.contains(detalle.CC_Empleado__c)){
                    contacts.remove(detalle.CC_Empleado__c);
                }
                if(detalle.CC_Cuenta__c  != null && accounts.contains(detalle.CC_Cuenta__c)){
                    accounts.remove(detalle.CC_Cuenta__c);
                }
                if(detalle.CC_Centro_CaixaBank__c  != null && accounts.contains(detalle.CC_Centro_CaixaBank__c)){
                    accounts.remove(detalle.CC_Centro_CaixaBank__c);
                }
            }
            //Reviso si quedan contactos o cuentas en los sets, de ser asi hay que actualizarles el campo CC_Tiene_Caracteristica_Detalle__c a false
            if(!contacts.isEmpty()) {
                for(Id contactId : contacts) {
                    Contact c = new Contact(Id = contactId);
                    c.CC_Tiene_Caracteristica_Detalle__c = false;
                    mapContactsToUpdateById.put(contactId, c);
                }
            }
            if(!accounts.isEmpty()) {
                for(Id accountId : accounts) {
                    Account a = new Account(Id = accountId);
                    a.CC_Tiene_Caracteristica_Detalle__c = false;
                    mapAccountsToUpdateById.put(accountId, a);
                }
            }
            // Actualizo los contactos y cuentas en caso de que haya alguna
            if(!mapContactsToUpdateById.isEmpty()) {
                update mapContactsToUpdateById.values();
            }
            if(!mapAccountsToUpdateById.isEmpty()) {
                update mapAccountsToUpdateById.values();
            }
        }
        
    }
}