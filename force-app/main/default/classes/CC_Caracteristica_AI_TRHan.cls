public with sharing class CC_Caracteristica_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		  process((List<CC_Caracteristica__c>)tp.newList, (Map<Id, CC_Caracteristica__c>)tp.newMap);
	}

	private void process(List<CC_Caracteristica__c> listNewObj, Map<Id, CC_Caracteristica__c> mapNewObj) {
        notificarCaracteristicaDesuso(listNewObj, mapNewObj);
	}

	private void notificarCaracteristicaDesuso(List<CC_Caracteristica__c> listNewObj, Map<Id, CC_Caracteristica__c> mapNewObj) {
		Integer diasUltimaAsociacion = 180;
		Set<String> destinatarios = new Set<String>();
		Id grupoCoordinadores = [SELECT Id FROM Group WHERE DeveloperName = 'Coordinadores' LIMIT 1].Id;
		destinatarios.add(grupoCoordinadores.toString());
		String tipoNoficicacion = [SELECT Id from CustomNotificationType WHERE DeveloperName = 'CC_Marca_Desuso' LIMIT 1].Id;
		String tituloNotificacion = 'Marca en desuso';
		for (CC_Caracteristica__c caracteristica : listNewObj) {
			if (caracteristica.CC_Dias_ultima_asociacion__c > diasUltimaAsociacion && caracteristica.CC_Activo__c == true) {
				String textoNotificacion = 'La marca ' + caracteristica.Name + ' está en desuso.';
				Boolean haFallado = CC_Notificacion_Metodos.enviarNotificacion (destinatarios, caracteristica.Id, tituloNotificacion, tipoNoficicacion, textoNotificacion);
				if (!haFallado) {
					system.debug('Notificación enviada correctamente');
				}else{
					system.debug('Error al enviar la notificación');
				}
			}
		}
	}
}