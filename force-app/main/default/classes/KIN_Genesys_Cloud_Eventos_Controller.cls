public with sharing class KIN_Genesys_Cloud_Eventos_Controller {

	@AuraEnabled
	public static Map<String, Object> registrarLlamadaEntrante(String llamadaJson) {
		CC_Llamada_Input input = parseJson(llamadaJson);
		String negocioServicioGenesys = negocioServicioGenesys(input.servicio);
		if (negocioServicioGenesys == 'HDT') {
			return HDT_Llamada_GC.registrarLlamadaEntrante(input);
		} else if (negocioServicioGenesys == 'CSBD') {
			return CSBD_Llamada_GC.registrarLlamadaEntrante(input);
		} else if (negocioServicioGenesys == 'SACH') {
			return SACH_Llamada_GC.registrarLlamadaEntrante(input);
		} else if (negocioServicioGenesys == 'CC') {
			return CC_Llamada_GC.registrarLlamadaEntrante(input);
		} else if (negocioServicioGenesys == 'CAM') {
			return AM_Llamada_GC.registrarLlamadaEntrante(input);
		} else {
			throw new AuraHandledException('No es posible determinar la aplicación Salesforce correspondiente al servicio Genesys con código "' + input.servicio + '"');
		}
	}

	@AuraEnabled
	public static Map<String, Object> registrarLlamadaSaliente(String llamadaJson) {
		CC_Llamada_Input input = parseJson(llamadaJson);
		String prefijoRecordType = prefijoRecordType(input.casoId);
		if (prefijoRecordType == 'HDT') {
			return HDT_Llamada_GC.registrarLlamadaSaliente(input);
		} else if (prefijoRecordType == 'CSBD') {
			return CSBD_Llamada_GC.registrarLlamadaSaliente(input);
		} else if (prefijoRecordType == 'SACH') {
			return SACH_Llamada_GC.registrarLlamadaSaliente(input);
		} else if (prefijoRecordType == 'CAM') {
			return AM_Llamada_GC.registrarLlamadaSaliente(input);
		} else {
			return CC_Llamada_GC.registrarLlamadaSaliente(input);
		}
	}

	@AuraEnabled
	public static Map<String, Object> iniciarLlamadaSalienteClickToDial(String llamadaJson) {
		CC_Llamada_Input input = parseJson(llamadaJson);
		String prefijoRecordType = prefijoRecordType(input.casoId);
		if (prefijoRecordType == 'CSBD') {
			return CSBD_Llamada_GC.iniciarLlamadaSalienteClickToDial(input);
		} else {
			return null;
		}
	}

	@AuraEnabled
	public static Map<String, Object> registrarConsulta(String consultaJson) {
		CC_Llamada_Input input = parseJson(consultaJson);
		String prefijoRecordType = prefijoRecordType(input.casoId);

		if (prefijoRecordType == 'HDT') {
			//if (String.isEmpty(input.salesforceParentId)) {
				//return HDT_Llamada_GC.registrarConsultaExterna(input);
			//} else {
				return HDT_Llamada_GC.registrarConsulta(input);
			//}

		//} else if (prefijoRecordType == 'SACH') {
			//return SACH_Llamada_GC.registrarConsulta(input);

		} else if (prefijoRecordType == 'CC') {
			//if (String.isEmpty(input.salesforceParentId)) {
				//return CC_Llamada_GC.registrarConsultaExterna(input);
			//} else {
				return CC_Llamada_GC.registrarConsulta(input);
			//}
		} else {
			throw new AuraHandledException('No es posible determinar la aplicación Salesforce correspondiente al caso con Id "' + input.casoId + '"');
		}
	}

	/*
	@AuraEnabled
	public static Id registrarConsultaNoAtendida(String llamadaJson, String consultaJson) {
		return CC_Llamada_GC.registrarConsultaNoAtendida(parseJson(llamadaJson), parseJson(consultaJson));
	}
	*/

	@AuraEnabled
	public static Map<String, Object> registrarEncuesta(String llamadaJson) {
		CC_Llamada_Input input = parseJson(llamadaJson);
		if (String.isBlank(input.llamadaId)) {
			throw new AuraHandledException('No se ha podido recuperar la información de la llamada');
		} else {
			String prefijoRecordType = prefijoRecordType(input.casoId);
			if (prefijoRecordType == 'CSBD') {
				return CSBD_Llamada_GC.registrarEncuesta(input);
				//return new Map<String, Object>{'className' => 'N/A', 'nombreEncuesta' => 'N/A'};
			} else {
				return CC_Llamada_GC.registrarEncuesta(input);
			}
		}
	}

	@AuraEnabled
	public static Map<String, Object> finalizarLlamada(String llamadaJson, String tipoCierre) {
		CC_Llamada_Input input = parseJson(llamadaJson);
		if (String.isBlank(input.llamadaId)) {
			throw new AuraHandledException('No se ha podido recuperar el id del registro de llamada por lo que no es posible finalizarla');
		} else {
			String prefijoRecordType = prefijoRecordType(input.llamadaId);
			if (prefijoRecordType == 'HDT') {
				return HDT_Llamada_GC.finalizarLlamada(input, tipoCierre);
			} else if (prefijoRecordType == 'CSBD') {
				return CSBD_Llamada_GC.finalizarLlamada(input, tipoCierre);
			} else if (prefijoRecordType == 'SACH') {
				return SACH_Llamada_GC.finalizarLlamada(input, tipoCierre);
			} else if (prefijoRecordType == 'CAM') {
				return AM_Llamada_GC.finalizarLlamada(input, tipoCierre);
			} else {
				return CC_Llamada_GC.finalizarLlamada(input, tipoCierre);
			}
		}
	}

	@AuraEnabled
	public static Boolean finalizarConsulta(String consultaJson, String tipoCierre) {
		CC_Llamada_Input input = parseJson(consultaJson);
		String prefijoRecordType = prefijoRecordType(input.casoId);
		if (prefijoRecordType == 'HDT') {
			return HDT_Llamada_GC.finalizarConsulta(input, tipoCierre);
		} else if (prefijoRecordType == 'CC') {
			return CC_Llamada_GC.finalizarConsulta(input, tipoCierre);
		} else {
			throw new AuraHandledException('No es posible determinar la aplicación Salesforce correspondiente al caso con Id "' + input.casoId + '"');
		}
	}

	/*
	@AuraEnabled
	public static void finalizarConsultaExterna(String consultaJson, String tipoCierre) {
		CC_Llamada_GC.finalizarConsultaExterna(parseJson(consultaJson), tipoCierre);
	}
	*/

	/*
	@AuraEnabled
	public static Boolean cancelarConsulta(String consultaJson) {
		return CC_Llamada_GC.cancelarConsulta(parseJson(consultaJson));
	}
	*/

	@AuraEnabled
	public static void completarConsulta(String servicio, String connIdConsulta, Id idNuevoOwner) {
		String negocioServicioGenesys = negocioServicioGenesys(servicio);
		if (negocioServicioGenesys == 'HDT') {
			HDT_Llamada_GC.completarConsulta(connIdConsulta, idNuevoOwner);
		} else if (negocioServicioGenesys == 'CC') {
			CC_Llamada_GC.completarConsulta(connIdConsulta, idNuevoOwner);
		} else {
			throw new AuraHandledException('No es posible determinar la aplicación Salesforce correspondiente al servicio Genesys con código "' + servicio + '"');
		}
	}

	/*
	@AuraEnabled
	public static String enviarInteraccion(String interaccionJson) {
		CC_InteraccionInput interaccion = (CC_InteraccionInput)JSON.deserialize(interaccionJson, CC_InteraccionInput.class);
		if (interaccion.medio != null && !interaccion.medio.equals('CHAT')) {
			return CSBD_Opportunity.asignacionIWD(interaccion.externalId, interaccion.interactionId);
		} else {
			return CC_WS_Routing.CC_AgentWork(interaccion.pendingServiceRoutingId, interaccion.ticketId, interaccion.proxyClientId, interaccion.interactionId, interaccion.usuario, interaccion.extension);
		}
	}

	private class CC_InteraccionInput {
		public String externalId {get;} //Id de la oportunidad por ejemplo
		public String interactionId {get;} //Id en Genesys/iWD
		public String ticketId {get;}
		public String proxyClientId {get;}
		public String medio {get;}
		public String usuario {get;}
		public String extension {get;}
		public String workItemId {get;}
		public String pendingServiceRoutingId {get;}
	}
	*/

	private static CC_Llamada_Input parseJson(String inputJson) {
		return (CC_Llamada_Input)JSON.deserialize(inputJson, CC_Llamada_Input.class);
	}

	@AuraEnabled
	public static Map<String, Object> purecloudConversationApi(String interactionId) {
		if (!Test.isRunningTest()) {
			HttpResponse response = purecloud.SDK.Rest.get('/platform/api/v2/conversations/calls/' + interactionId);
			return new Map<String, Object>{
				'statusCode' => response.getStatusCode(),
				'status' => response.getStatus(),
				'body' => JSON.deserializeUntyped(response.getBody())
			};
		} else {
			return new Map<String, Object>{
				'statusCode' => '200',
				'status' => 'OK',
				'body' => '{"participants":[{"attributes":{"casoId":"5005E00000HdCPFQA3","agenteDestinoId":"0053Y00000ALRTSQA5"}}]}'
			};
		}
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, Object> atributosLlamadaInicial(String interactionId) {
		if (String.isBlank(interactionId)) {
			return null;
		} else {
			List<CC_Llamada__c> llamadasIniciales = [SELECT CC_ANI__c, CC_DNIS__c, CC_Servicio_Genesys__r.CC_Codigo__c, CC_Asunto__c,
														CC_NumPerso__c, CC_Llamada_Padre__c, CC_Idioma__c, CC_ConnId_Cognitivo__c,
														CC_Canal_del_Empleado__c, KIN_Genesys_Cloud_URL_Grabacion__c, CC_Datos_Genesys__c
														FROM CC_Llamada__c WHERE CC_ConnId__c = :interactionId AND KIN_Llamada_Origen__c = TRUE LIMIT 1];
			if (llamadasIniciales.isEmpty()) {
				return null;
			} else {
				CC_Llamada__c llamadaInicial = llamadasIniciales[0];

				Id idCaso;
				List<Task> tareasLlamada = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaInicial.Id AND WhatId != NULL
											AND RecordType.DeveloperName IN ('CC_Task', 'OS_Task', 'SACH_Task', 'HDT_Task', 'CSBD_Task', 'AM_Task') LIMIT 1];
				if (!tareasLlamada.isEmpty()) {
					idCaso = tareasLlamada[0].WhatId;
				}

				return new Map<String, Object>{
					'usuario' => null,
					'extension' => null,
					'connId' => interactionId,
					'ani' => llamadaInicial.CC_ANI__c,
					'dnis' => llamadaInicial.CC_DNIS__c,
					'servicio' => llamadaInicial.CC_Servicio_Genesys__r.CC_Codigo__c,
					'asunto' => llamadaInicial.CC_Asunto__c,
					'numPerso' => llamadaInicial.CC_NumPerso__c,
					'idioma' => llamadaInicial.CC_Idioma__c,
					'datos' => llamadaInicial.CC_Datos_Genesys__c,
					'connIdCognitivo' => llamadaInicial.CC_ConnId_Cognitivo__c,
					'casoId' => idCaso, //PENDENT!
					//'salesforceParentId' => llamadaInicial.CC_Llamada_Padre__c,
					'salesforceParentId' => llamadaInicial.Id,
					'llamadaId' => llamadaInicial.Id,
					'CC_Canal_del_Empleado__c' => llamadaInicial.CC_Canal_del_Empleado__c,
					'urlGrabacion' => llamadaInicial.KIN_Genesys_Cloud_URL_Grabacion__c
				};
			}
		}
	}

	private static String negocioServicioGenesys(String codigoServicio) {
		List<CC_Servicio_Genesys__c> serviciosGenesys = [SELECT CBK_Negocio__c FROM CC_Servicio_Genesys__c
														WHERE CC_Codigo__c = :codigoServicio LIMIT 1];
		if (serviciosGenesys.isEmpty()) {
			throw new AuraHandledException('No existe el servicio Genesys con código "' + codigoServicio + '"');
		} else {
			String negocio = serviciosGenesys[0].CBK_Negocio__c;
			return String.isBlank(negocio) ? 'CC' : negocio;
		}
	}

	private static String prefijoRecordType(Id recordId) {
		String sObjectName = recordId.getSObjectType().getDescribe().getName();
		String prefijoRecordType = '';
		if (sObjectName == 'Case') {
			prefijoRecordType = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :recordId].RecordType.DeveloperName;
		} else if (sObjectName == 'Opportunity') {
			prefijoRecordType = [SELECT RecordType.DeveloperName FROM Opportunity WHERE Id = :recordId].RecordType.DeveloperName;
		} else if (sObjectName == 'CC_Llamada__c') {
			prefijoRecordType = [SELECT RecordType.DeveloperName FROM CC_Llamada__c WHERE Id = :recordId].RecordType.DeveloperName;
		}
		return prefijoRecordType.substringBefore('_');
	}
}