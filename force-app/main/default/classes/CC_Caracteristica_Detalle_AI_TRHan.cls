public with sharing class CC_Caracteristica_Detalle_AI_TRHan  extends CC_TriggerHandlerBase{
    
    public override void mainEntry(CC_TriggerParameters tp) {
		  process((List<CC_Caracteristica_Detalle__c>)tp.newList, (Map<Id, CC_Caracteristica_Detalle__c>)tp.newMap);
	}

	private void process(List<CC_Caracteristica_Detalle__c> listNewObj, Map<Id, CC_Caracteristica_Detalle__c> mapNewObj) {
        updateContactOrAccountRelated(mapNewObj);
	}

    private void updateContactOrAccountRelated(Map<Id, CC_Caracteristica_Detalle__c> mapNewObj) {
		Map<Id,Contact> mapContactsToUpdateById = new Map<Id,Contact>();
        Map<Id,Account> mapAccountsToUpdateById = new Map<Id,Account>();
        //Exraigo los detalles junto con los campos CC_Tiene_Caracteristica_Detalle__c de contact y account relacionados, pero solo si la Caracteristica está activa
        List<CC_Caracteristica_Detalle__c> lstCaracteristicaDetalle = [SELECT Id, CC_Caracteristica__c, 
                                                                        CC_Cliente__c, CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c, 
                                                                        CC_Empleado__c, CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c,
                                                                        CC_Cuenta__c, CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c,
                                                                        CC_Centro_CaixaBank__c , CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c
                                                                      FROM CC_Caracteristica_Detalle__c 
                                                                      WHERE Id IN :mapNewObj.keySet() 
                                                                      AND CC_Caracteristica__r.CC_Activo__c = true AND CC_Caracteristica__r.OS_Negocio__c = 'CC'];
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
              
        }
        // Actualizo los contactos y cuentas que no tengan ya el valor a true
        if(!mapContactsToUpdateById.isEmpty()) {
            update mapContactsToUpdateById.values();
        }
        if(!mapAccountsToUpdateById.isEmpty()) {
            update mapAccountsToUpdateById.values();
        }
	}
}