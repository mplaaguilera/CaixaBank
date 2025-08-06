Account cuenta = [SELECT Id FROM Account WHERE LastName = 'PLA AGUILERA' LIMIT 1] ?? null;
if (cuenta != null) {
	List<CC_Comunicaciones__c> autenticaciones = [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Cliente__c = :cuenta.Id];
	Database.delete(autenticaciones, false);
	System.debug(autenticaciones.size() + ' autenticaciones eliminadas');
} else {
	System.debug('No se encontró la cuenta');
}