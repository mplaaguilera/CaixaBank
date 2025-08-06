public class SEG_Casos_Por_Grupo_Queueable implements Queueable{
	private Set<Id> casesIds {get;set;} 

	public SEG_Casos_Por_Grupo_Queueable(Set <Id> casesIds) {
		this.casesIds = casesIds;
	}
	public void execute(QueueableContext context) {

		SEG_Case_BU_TRHan.procesado = true;
		SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
		SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');
		String idUser = UserInfo.getUserId();
		List<SEG_ClasificacionRapida__c> crNoProced = [SELECT id, Name FROM SEG_ClasificacionRapida__c WHERE Name = 'No procede'];
	
		List<Case> casos = new List<Case>();
		if (!crNoProced.isEmpty()){
			for (Id idCaso : casesIds) {
				Case caso = new Case(Id = idCaso);
				caso.OwnerId = idUser;
				caso.Status = 'Descartado';
				caso.SEG_Subestado__c = 'Rechazada';
				caso.SEG_ClasificacionRapida__c = crNoProced[0].id;
				casos.add(caso);
			}
		}

		if(!casos.isEmpty()){
			CBK_DMLUtility.updateRecords(casos, false);
		}
	}
}