global class SEG_FotoFacturacion_Batch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	
	
	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		CBK_Log.debug('Start - Batch Foto Facturación', logginglevel.INFO);

		Integer day = date.today().day();
		String query = 'SELECT Id, SEG_Estado__c, SEG_NumeroSR__c, SEG_NumeroSR__r.Status';
		query = query + ' FROM SEG_Fotosdefacturacion__c ';
		query = query + ' WHERE  SEG_NumeroSR__r.Status = \'Cerrado\' AND SEG_Estado__c = \'Vigente\'';
		query = query + ' ORDER BY CreatedDate DESC';

		return Database.getQueryLocator(query);
	}
	public void execute(Database.BatchableContext bc, List<SEG_Fotosdefacturacion__c> scope)
	{
		System.debug(scope.size());
		if (scope.isEmpty()) {
			return;
		}

		// Indicar el número de registros a tratar en el lote.
		CBK_Log.debug('Execute - Batch Foto Facturación. Número registros lote: ' + scope.size(), logginglevel.INFO);
		List<SEG_Fotosdefacturacion__c> lstFFUpd = new List<SEG_Fotosdefacturacion__c>();
		for (SEG_Fotosdefacturacion__c ff : scope) {
			ff.SEG_Estado__c = 'Cerrado';
			ff.SEG_FechaCierre__c = Date.today();
			lstFFUpd.add(ff);
		}
		update lstFFUpd;
	}

	global void execute(SchedulableContext sc) {
         Database.executeBatch(new SEG_FotoFacturacion_Batch());
     }

	public void finish(Database.BatchableContext bc)
	{
		CBK_Log.debug('Finalización - Batch Foto Facturación', logginglevel.INFO);
	}
}