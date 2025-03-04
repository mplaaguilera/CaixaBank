global with sharing class KIN_Genesys_Cloud_CTI_Extensions implements purecloud.CTIExtension.ClickToDial {

	public String onClickToDial(String data) {
        Map<String, Object> clickToDialData = (Map<String, Object>)JSON.deserializeUntyped(data);
		String sObjectType = String.valueOf(clickToDialData.get('object'));
		Id recordId = String.valueOf(clickToDialData.get('objectId'));

		if (sObjectType != 'Case' && sObjectType != 'Opportunity') {
			return ''; //Si no es caso u oportunidad se cancela el click to dial
		} else {
			clickToDialData.put('queueId', CC_Servicio_Genesys.obtenerQueueId(recordId, sObjectType));

			//Custom attributes
			//clickToDial y casoId
			Map<String, Object> interactionAttributes = new Map<String, Object>{
				'clickToDial' => false, 'casoId' => recordId //casoId puede ser un id de caso o de oportunidad
			};
			if (sObjectType == 'Opportunity') {
				Opportunity oportunidad = [SELECT RecordType.DeveloperName, CSBD_Contact__r.AV_NumPerso__c FROM Opportunity WHERE Id = :recordId];
				//clickToDial y llamadaRecordType
				interactionAttributes.put('clickToDial', true);
				interactionAttributes.put('llamadaRecordType', oportunidad.RecordType.DeveloperName);

				if (oportunidad.RecordType.DeveloperName.startsWith('CSBD_')) {
					//Numperso
					interactionAttributes.put('numPerso', oportunidad.CSBD_Contact__r.AV_NumPerso__c);

					//llamadaId
					CC_Llamada_Input inputLlamadaSaliente = new CC_Llamada_Input();
					inputLlamadaSaliente.casoId = recordId;
					inputLlamadaSaliente.dnis = String.valueOf(clickToDialData.get('number'));
					Map<String, Object> llamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
					interactionAttributes.put('llamadaId', ((CC_Llamada__c)llamadaSaliente.get('llamada')).Id);
				}
			}
			clickToDialData.put('interactionAttributes', interactionAttributes);
			return JSON.serialize(clickToDialData);
		}
	}

	/*
	public String onScreenPop(String data) {
		//help.mypurecloud.com/articles/use-the-extension-points-to-customize-screen-pop/
		purecloud.SDK.Logger.createPendingLog('SDK', 'SCREEN POPUP - ALERTING **********' , purecloud.Log.LogLevels.DEBUG);
		purecloud.SDK.Logger.savePendingLogs();
		return '';
	}

	public String onSaveLog(String data) {
		// Example: Save interaction log as Task record after interaction is disconnected.
		//help.mypurecloud.com/articles/use-the-extension-points-to-customize-saving-interaction-logs/

		Map<String, Object> saveLogData = (Map<String, Object>) JSON.deserializeUntyped(data);
		Map<String, Object> interaction = ( Map<String, Object>) saveLogData.get('interaction');
		Map<String, Object> callLog = ( Map<String, Object>) saveLogData.get('callLog');
		Boolean isDisconnected = (Boolean) interaction.get('isDisconnected');
		Boolean isconnected = (Boolean) interaction.get('isConnected');
		String state = (String) interaction.get('state');
		String eventName = (String) saveLogData.get('eventName');

		String callLogId = '';
		if (isDisconnected) {
			Task t = (Task) JSON.deserialize(JSON.serialize(callLog), Task.class);
			t.Description = 'tarea creada en evento onSaveLog por codigo';
			upsert t;
			callLogId = t.Id;
		}

		purecloud.SDK.Logger.createPendingLog('SDK', 'CONNECTED: ' + String.valueOf(isconnected) + '.    DISCONNECTED:' + String.valueOf(isDisconnected) + '.    STATE:' +  state   + '.  EVENT NAME: ' + eventName , purecloud.Log.LogLevels.DEBUG);
		purecloud.SDK.Logger.createPendingLog('SDK',data.substring(0,254),purecloud.Log.LogLevels.DEBUG);
		purecloud.SDK.Logger.createPendingLog('SDK',data.substring(254,2*254),purecloud.Log.LogLevels.DEBUG);
		purecloud.SDK.Logger.createPendingLog('SDK',data.substring(2*254,3*254),purecloud.Log.LogLevels.DEBUG);
		purecloud.SDK.Logger.createPendingLog('SDK',data.substring(3*254),purecloud.Log.LogLevels.DEBUG);
		purecloud.SDK.Logger.savePendingLogs();
		return callLogId;
	}
	*/
}