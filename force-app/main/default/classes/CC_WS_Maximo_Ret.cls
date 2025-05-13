@RestResource(urlMapping='/CC_Maximo/*')
global with sharing class CC_WS_Maximo_Ret extends CBK_HttpServiceIntegration_Abstract{


	global class CC_WS_Maximo_Input {
		global String TICKETID {get;set;}
		global String SIEBELID {get;set;}
		global String ESTADO {get;set;}
		global String REQUIEREATENCION {get;set;}
		global String AFFECTEDDATE {get;set;}
		global String ITNAFFECTEDFINDATE {get;set;}
		global String TARGETSTART {get;set;}
		global String TARGETFINISH {get;set;}
		global String ACTUALSTART {get;set;}
		global Datetime ACTUALFINISH {get;set;}
		global String CREATIONDATE {get;set;}
		global String FECHAOBJECTORESOLUCION {get;set;}
		global String FR2CODE_LONGDESCRIPTION {get;set;}
	}

	global class CC_WS_Maximo_Output {
		global String TICKETID {get;set;}
		global String sCodError {get;set;}
		global String sDetalleError {get;set;}
	}

	private static String validarDatosEntrada (CC_WS_Maximo_Ret.CC_WS_Maximo_Input oDatos)
	{
		if (oDatos != null)
		{
			if (oDatos.TICKETID == null)
			{
				return 'KO';
			}else if (oDatos.TICKETID.trim() == '') {
				return 'KO';
			}
		} else{
			return 'KO';
		}

		return 'OK';
	}


	@HttpPost
	global static List<CC_WS_Maximo_Ret.CC_WS_Maximo_Output> updMaximo(List<CC_WS_Maximo_Ret.CC_WS_Maximo_Input> oDataIn) {
		List<CC_WS_Maximo_Ret.CC_WS_Maximo_Output> oRes = new List<CC_WS_Maximo_Ret.CC_WS_Maximo_Output>();
		Map<String, CC_WS_Maximo_Ret.CC_WS_Maximo_Input> oMapMaximo = new Map<String, CC_WS_Maximo_Ret.CC_WS_Maximo_Input>();
		if (oDataIn != null) {
			for (CC_WS_Maximo_Ret.CC_WS_Maximo_Input oForm : oDataIn) {
				if (validarDatosEntrada(oForm) == 'OK') {
					//Registro para a crear datos.
					oMapMaximo.put(oForm.TICKETID.trim().unescapeHtml4(), oForm);
				} else {
					// Error validación datos entrada.
					String sCodErr = '1';
					CC_WS_Maximo_Ret.CC_WS_Maximo_Output oAux = new CC_WS_Maximo_Ret.CC_WS_Maximo_Output();
					oAux.TICKETID = oForm.TICKETID;
					oAux.sCodError = sCodErr;
					oAux.sDetalleError = 'Datos obligatorios no informados.';
					oRes.add(oAux);
				}
			}
			// Procesar los registros.
			Map<String, List<CC_Agrupador__c>> mapAgrupadores = new Map<String, List<CC_Agrupador__c>>();
			for (CC_Agrupador__c agrupador : [SELECT CC_Estado_Maximo__c, CC_Fecha_Resolucion__c, CC_Detalle_Solucion__c, CC_Estado__c, CC_Id_Maximo__c, CC_Motivo__r.CC_Tipo_Cliente__c
												FROM CC_Agrupador__c WHERE CC_Id_Maximo__c IN :oMapMaximo.keySet()]) {
				if (mapAgrupadores.containsKey(agrupador.CC_Id_Maximo__c)) {
					List<CC_Agrupador__c> agrupadorList = mapAgrupadores.get(agrupador.Id);
					agrupadorList.add(agrupador);
					mapAgrupadores.put(agrupador.CC_Id_Maximo__c, agrupadorList);
				} else {
					List<CC_Agrupador__c> agrupadorList = new List<CC_Agrupador__c>();
					agrupadorList.add(agrupador);
					mapAgrupadores.put(agrupador.CC_Id_Maximo__c, agrupadorList);
				}
			}

			Map<String, List<Case>> mapCases = new Map<String, List<Case>>();
			for (Case caso : [SELECT CC_Agrupador_Id__r.CC_Id_Maximo__c, CC_Detalles_Solucion__c, Status
								FROM Case WHERE Status NOT IN ('Cerrado', 'Rechazado')
								AND CC_Agrupador_Id__r.CC_Id_Maximo__c IN :mapAgrupadores.keySet()]) {
				if (mapCases.containsKey(caso.CC_Agrupador_Id__c)) {
					List<Case> caseList = mapCases.get(caso.CC_Agrupador_Id__c);
					caseList.add(caso);
					mapCases.put(caso.CC_Agrupador_Id__c, caseList);
				} else {
					List<Case> caseList = new List<Case>();
					caseList.add(caso);
					mapCases.put(caso.CC_Agrupador_Id__c, caseList);
				}
			}

			List<CC_Agrupador__c> agrupadorUpdate = new List<CC_Agrupador__c>();
			List<Case> casoUpdate = new List<Case>();
			String sCodErr = '';
			String sDescError = '';
			for (String codMaximo : oMapMaximo.keySet()) {
				try {
					//El maximo recibido no existe en SF
					if (!mapAgrupadores.containsKey(codMaximo)) {
						sCodErr = '2';
						sDescError = 'Maximo no localizado.';
						CC_WS_Maximo_Ret.CC_WS_Maximo_Output oAux = new CC_WS_Maximo_Ret.CC_WS_Maximo_Output();
						oAux.TICKETID = codMaximo;
						oAux.sCodError = sCodErr;
						oAux.sDetalleError = sDescError;
						oRes.add(oAux);
					} else {
						//Si que existe
						List<Id> idCasos = new List<Id>();
						CC_WS_Maximo_Ret.CC_WS_Maximo_Input inputMaximo = oMapMaximo.get(codMaximo);
						//Se realizan las actualizaciones del agrupador
						for (CC_Agrupador__c agrupador : mapAgrupadores.get(codMaximo)) {

							//MGT US1164720: Actualización del estado de los agrupadores de incidencias
							// Verificar si el agrupador es de HDT y si ya está cerrado o rechazado
							if (agrupador.CC_Motivo__r.CC_Tipo_Cliente__c == 'HDT Empleado' 
							&& (agrupador.CC_Estado__c == 'Cerrado' || agrupador.CC_Estado__c == 'Rechazado')) {
								// No actualizar el estado del agrupador si ya está cerrado o rechazado y es de HDT
								continue;
							}
							//MGT US1164720: Actualización del estado de los agrupadores de incidencias

							if (inputMaximo.ESTADO == 'RESOLV_REV_SOL') {
								agrupador.CC_Estado__c = 'Pendiente Revision';
								agrupador.CC_Detalle_Solucion__c = inputMaximo.FR2CODE_LONGDESCRIPTION;
								agrupador.CC_Fecha_Resolucion__c = inputMaximo.ACTUALFINISH;

								//Se realizan las actualizaciones de los casos
								List<Case> casosList = mapCases.get(agrupador.Id);
								if (casosList != null) {
									for (Case caso : casosList) {
										idCasos.add(caso.Id);
										caso.CC_Detalles_Solucion__c = inputMaximo.FR2CODE_LONGDESCRIPTION;
										casoUpdate.add(caso);
									}
								}

							} else if (inputMaximo.ESTADO == 'ACCEPTED') {
								agrupador.CC_Estado__c = 'Activo';
								agrupador.CC_Detalle_Solucion__c = inputMaximo.FR2CODE_LONGDESCRIPTION;
								agrupador.CC_Fecha_Resolucion__c = null;
								//Se realizan las actualizaciones del caso
								List<Case> casosList = mapCases.get(agrupador.Id);
								if (casosList != null) {
									for (Case caso : casosList) {
										caso.CC_Detalles_Solucion__c = '';
										casoUpdate.add(caso);
									}
								}
							}
							agrupador.CC_Estado_Maximo__c = inputMaximo.ESTADO;
							agrupadorUpdate.add(agrupador);
						}

						update agrupadorUpdate;
						update casoUpdate;

						//Envío de notificaciones por correo para casos de agrupador que pasa a Pendiente Revisión Solución
						if (!idCasos.isEmpty()) {
							enviarNotificacionesCasosPendRevSolucion(idCasos);
						}

						sCodErr = '0';
						sDescError = 'Maximo actualizado.';
						CC_WS_Maximo_Ret.CC_WS_Maximo_Output oAux = new CC_WS_Maximo_Ret.CC_WS_Maximo_Output();
						oAux.TICKETID = codMaximo;
						oAux.sCodError = sCodErr;
						oAux.sDetalleError = sDescError;
						oRes.add(oAux);
					}

					CC_TrazaInt__c traza = new CC_TrazaInt__c();
					traza.Name = 'MAXIMO_RETORNO';
					traza.CC_Identificador__c = codMaximo;
					traza.CC_FechaInicio__c = datetime.now();
					traza.CC_IdOrigen__c = codMaximo;
					traza.CC_FechaFin__c = datetime.now();
					traza.CC_FinOK__c = false;
					traza.CC_TipoError__c = sCodErr;
					traza.CC_DetalleError__c = sDescError;
					insert traza;

				} catch(Exception e) {
					sCodErr = '9';
					sDescError =  'Error en la ejecución del proceso. ' + e.getMessage();
					CC_WS_Maximo_Ret.CC_WS_Maximo_Output oAux = new CC_WS_Maximo_Ret.CC_WS_Maximo_Output();
					oAux.TICKETID = codMaximo;
					oAux.sCodError = sCodErr;
					oAux.sDetalleError = sDescError;
					oRes.add(oAux);
				}
			}
		}
		return oRes;
	}

	@TestVisible
	@future
	private static void enviarNotificacionesCasosPendRevSolucion(List<Id> idCasos) {
		List<Case> casos = [SELECT ContactId, Contact.Email, CC_Idioma__c FROM Case WHERE Id IN :idCasos
							AND RecordType.DeveloperName = 'HDT_Empleado'
							AND CC_MCC_Motivo__r.HDT_Notif_Pdte_Rev_Sol_Maximo__c = TRUE];
		if (!casos.isEmpty()) {

			//Modificado por Moisés Cano - 19/04/2024 para la recogida del buzón de salida sin el DisplayName
			//Id del buzón de salida y de las plantillas de correo
			//Id idBuzonHdt = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Empleados HDT CaixaBank'].Id;

			//Recogemos el Custom Setting para obtener las direcciones de correo de respuesta (Configuracion_1 : Castellano, Configuracion_2 : Catalan)
			HDT_Parametros__c emailRespuesta = [SELECT Id, HDT_Configuracion_1__c, HDT_Configuracion_2__c,HDT_Configuracion_3__c FROM HDT_Parametros__c WHERE Name = 'HDT_Email_Respuesta_Empleados_New'];
			//Recogemos los Ids del remitente ordenadas alfabeticamente por la direccion (0: Catalan, 1 Castellano,, 3 Inglés) en el caso de que existan los 3
			List <OrgWideEmailAddress> remitentesId = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (: emailrespuesta.HDT_Configuracion_1__c, : emailrespuesta.HDT_Configuracion_2__c, : emailrespuesta.HDT_Configuracion_3__c) ORDER BY Address];

			List<String> developerNamePlantillas = new List<String>{
				'Solucion_Incidencia_ES_Empleado_HDT', 'Solucion_Incidencia_CA_Empleado_HDT','Solucion_Incidencia_EN_Empleado_HDT'
			};
			Map<String, Id> idPlantillas = new Map<String, Id>();
			for (EmailTemplate plantilla : [SELECT DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'HDT_PlantillasNotificacin'
											AND DeveloperName IN :developerNamePlantillas LIMIT 3]) {
				idPlantillas.put(plantilla.DeveloperName, plantilla.Id);
			}

			//Preparación de los correos a enviar
			List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();
			for (Case caso : casos) {
				Id idPlantilla;
				if (Test.isRunningTest()) {
					idPlantilla = idPlantillas.get('Solucion_Incidencia_ES_Empleado_HDT');
				} else if (caso.CC_Idioma__c == 'ca') {
					idPlantilla = idPlantillas.get('Solucion_Incidencia_CA_Empleado_HDT');
				} else if (caso.CC_Idioma__c == 'en') {
					idPlantilla = idPlantillas.get('Solucion_Incidencia_EN_Empleado_HDT');
				} else {
					idPlantilla = idPlantillas.get('Solucion_Incidencia_ES_Empleado_HDT');
				}

				if (idPlantilla != null) {
					Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
					correo.setWhatId(caso.Id);
					//correo.setOrgWideEmailAddressId(idBuzonHdt);
					correo.setOrgWideEmailAddressId(remitentesId[0].Id);
					correo.setTemplateId(idPlantilla);
					correo.setTargetObjectId(caso.ContactId);
					correo.setTreatTargetObjectAsRecipient(false);
					correo.setToAddresses(new List<String>{caso.Contact.Email});
					correo.setSaveAsActivity(true);
					correos.add(correo);
				}
			}

			//Envío de los correos
			Messaging.sendEmail(correos);
		}
	}
}