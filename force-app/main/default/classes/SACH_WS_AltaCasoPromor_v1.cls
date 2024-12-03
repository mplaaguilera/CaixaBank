@RestResource(urlMapping='/AltaCasoPromorv1/*')
global with sharing class SACH_WS_AltaCasoPromor_v1 extends CBK_HttpServiceIntegration_Abstract{

	@HttpPost
	global static Output registrarCasoPromor() {

		String peticionRest = RestContext.request?.requestBody.toString();
		RestRequest req =  RestContext.request;
		Input input ;
		Output output = new Output('OK', '', '', '');
		RestResponse res = RestContext.response;
		Datetime dtStart = Datetime.now();
		String resultado;

		try {
			if (String.isBlank(peticionRest)) {
				throw new CustomException('Petición vacía');
			}
			input = (Input)JSON.deserialize(peticionRest.toString(), Input.class);
			if (String.isBlank(input.numperso)) {
				throw new CustomException('NUMPERSO no informado');
			}
			
			gestionPeticionPromor(input, output,peticionRest);
			//Registramos las trazas adecuadamente.
			resultado = '{"Result":"OK","Description":"Datos obligatorios informados correctamente."}';
			registrarTraza(req, res, dtStart, resultado, 412);
			

		} catch (Exception e) {
			
			output.resultado = 'KO';
			output.codigo = e.getTypeName(); //'0000'
			output.error = 'ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.');
			CBK_Log.error(e);

			//Registramos las trazas adecuadamente.
			resultado = '{"Result":"KO","Description":"Datos obligatorios no informados."}';
			registrarTraza(req, res, dtStart, resultado, 412);
		} finally {
			
			if (output.resultado != 'OK') {
				resultado = '{"Result":"KO","Description":"No hay datos para retornar."}';
                output.codigo = '201';
                registrarTraza(req, res, dtStart, resultado, 201);

			} else {
				resultado = '{"Result":"OK","Description":"Busqueda realizada."}';
                output.codigo = '200';
                registrarTraza(req, res, dtStart, resultado, 200);
			}
		}
		return output; //Devolvemos el resultado obtenido
	}

	// Definimos las propiedades del json a recibir
	@TestVisible
	global class Input {
		@TestVisible
		global String demanda {get;set;}
		global String iddemanda {get;set;}
		global Integer contrato {get;set;}
		global String oficinagestora {get;set;}
		global String pacto {get;set;}
		global String numperso {get;set;}
		global List<Actividad> actividades {get;set;}

		global Input() {
			this.demanda = '';
			this.iddemanda = '';
			this.contrato = null;
			this.oficinagestora = '';
			this.pacto = '';
			this.numperso = '';
		}
	}

	global class Actividad {
		global String codactividad {get;set;}
		global String comentarios {get;set;}
		global List<Adjunto> adjuntos {get;set;}
		}

		global class Adjunto {
			global String nombreadjunto {get;set;}
			global String tipodocumento {get;set;}
			global String iddocumento {get;set;}
		}

	//Definimos los datos para la salida del resultado
	global class Output {
		global String resultado {get;set;}
		global String error {get;set;}
		global String caseId {get;set;}
		global String codigo {get;set;}

		Output(String resultado, String error, String codigo, String caseId) {
			this.resultado = resultado;
			this.error = error;
			this.codigo = codigo;
			this.caseId = caseId;
		}
	}

	/**
	* @description Función core para la parte de SACH.
	* @param input Estructura de entrada del servicio REST
	* @return retorno del servicio REST
	*/
	public static void gestionPeticionPromor(Input input, Output output,String jsonString) {
		
		Contact contactoIdentificado = SACH_Identificacion_Auto.identificarNUMPERSO(input.numperso);
		List<Case> casos = [SELECT Status, CC_MCC_Solucion__c FROM Case WHERE RecordType.DeveloperName = 'SACH_Cliente' AND ContactId = :contactoIdentificado.Id LIMIT 1];
		
		if (!casos.isEmpty()) {
	
			//CASO EXISTENTE
			Case casoAntiguo = casos[0];
			// Para cada caso vamos a buscar que Solucion tiene el caso
			// Iterar sobre la lista original y filtrar por el ID de la solucion
			String nombreSolucion = '';
			for (CC_MCC__c clasificacion : [SELECT Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Solucion'
											AND CC_Tipo_Cliente__c = 'Cliente (SACH)' AND CC_Activo__c = TRUE]) {
				if (clasificacion.Id == casoAntiguo.CC_MCC_Solucion__c) {
					nombreSolucion = clasificacion.Name;
				}
			}

             //Aqui viene la lógica para cuando exista un caso ya abierto para este cliente
             output.resultado = 'OK';
             output.codigo = '200';
             output.error = 'Ya existe un caso asociado.';
             output.caseId = casoAntiguo.Id;

			Id idCasoAntiguo = casoAntiguo.Id;

			//Comprobar lógicas de Solución de caso
			//Si el caso esta cerrado se debe abrir con una nueva actividad y se le asigna a la cola sach-promor
			if (casoAntiguo.Status == 'Cerrado') {
				casoAntiguo.Status = 'Activo';
				casoAntiguo.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SACH_Promor'].Id;
				update casoAntiguo;

				//Creamos la tarea
				Task tarea = new Task();
				tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
				tarea.WhatId = casoAntiguo.Id;
				tarea.Type = 'Reapertura de caso desde PROMOR';
				tarea.Description = 'Proceso Promor: ' + input.demanda + ' ' + input.contrato + ' ' + input.pacto;
				tarea.Subject = 'Reapertura de caso desde PROMOR';
				tarea.Status = 'Completed';
				insert tarea;
			}

			// Si el caso esta con codigo 715 y pendientes de colaborador --> reactivar el caso
			if (casoAntiguo.Status == 'Pendiente Colaborador'
			&& nombreSolucion == 'Suspensión actuaciones por instrucción del SACH (715)') {
				casoAntiguo.Status = 'Activo';
				casoAntiguo.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SACH_Promor'].Id;
				casoAntiguo.SACH_Pacto__c = input.pacto;
				update casoAntiguo;
			}
		
		//Creación de un nuevo caso recibiendo datos desde PROMOR	
		} else {
			
			//Recogida del Custom Setting para formar el Link del archivo
			//Recogemos el Custom Setting para obtener las direcciones de correo de respuesta
			SACH_Parametros__c rutaRelativa = SACH_Parametros__c.getInstance('SACH_Promor');
			String rutaDefinitiva = '';
			Id idOficinaGestora = null;
			if (input.oficinagestora != null) {
				idOficinaGestora = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = :input.oficinagestora
										AND RecordType.DeveloperName = 'CC_CentroCaixaBank'].Id;
			}

			


			//NUEVO CASO DE ENTRADA
			//Creación de un caso nuevo porque no hay antes nada relacionado con ninguún caso anterior.
			Case caso = new Case();
			caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
			caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SACH_Promor'].Id;
			caso.SACH_Demanda__c = input.demanda;
			caso.SACH_IdDemanda__c = input.iddemanda;
			caso.OS_Contrato__c = input.contrato;
			caso.CC_NumPerso__c = input.numPerso;
			caso.SACH_Pacto__c = input.pacto;
			caso.ContactId = contactoIdentificado.Id;
			caso.SACH_Oficina_Gestora_Contrato__c = idOficinaGestora;
			insert caso;

			Map<String, String> codigodeactividades = new Map<String, String>{
				'38' => 'Requerimiento de pago/notificación fiadores por edicto',
				'39' => 'Requerimiento de pago/notificación fiadores a través de Procurador',
				'58' => 'Requerimiento de pago/notificación fiadores por SCNE',
				'158' => 'Requerimiento de pago/notificación fiadores por exhorto',
				'164' => 'Requerimiento de pago/notificación por medios electrónicos',
				'165' => 'Requerimiento de pago/notificación por Tablón Edictal Judicial Único (TEJU)',
				'736' => 'Resolución Admº vulnerabilidad Ley 12/2023',
				'739' => 'Resolución Admº Intermediación/Conciliación ley 12/2023',
				'700' => 'Petición autorización solicitud subasta al SACH'
			};
			

			List<Task> listaActividades = new List<Task>();
			List<ContentVersion> listaContentVersion = new List<ContentVersion>();

			for (Actividad actividad : input.actividades) {
				//Recogemos las actividades segun la codificacion especificada
				String actividadDesc = '';
				if (codigodeactividades.containsKey(actividad.codactividad)) {
					actividadDesc = codigodeactividades.get(actividad.codactividad);
				}	
				
				// Crea la tarea correspondiente
					Task tareacomentario = new Task();
					tareacomentario.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
					tareacomentario.WhatId = caso.Id;
					tareacomentario.Type = 'Automática';
					tareacomentario.Description = actividad.comentarios;
					tareacomentario.Subject = actividadDesc;
					tareacomentario.Status = 'Completed';
					//insert tareacomentario;
					listaActividades.add(tareacomentario);
				
				//Manejo de los archivos adjuntos
				if (actividad.adjuntos != null) {
					//Insertar registros Content Version
				
					for (Adjunto adjunto : actividad.adjuntos) {

						rutaDefinitiva = rutaRelativa.SACH_Parametro_1__c + '&idDocumento='+adjunto.iddocumento+'&referenciaExterna='+input.iddemanda; 		//emailrespuesta.HDT_Configuracion_1__c
						ContentVersion contentVersion = new ContentVersion();
						contentVersion.contentUrl = rutaDefinitiva;
						contentVersion.Description = adjunto.nombreadjunto + ' - ' + adjunto.tipodocumento + ' - ' + actividad.comentarios + ' - ' + actividadDesc;
						contentVersion.contentLocation = 'L';
						listaContentVersion.add(contentVersion);
						
					}
				}
			}

			
			//Insertamos Listas
			insert listaActividades;
			insert listaContentVersion;
			generarContentLinkVersionCaso(listaContentVersion,caso);
			generarContentLinkVersionTarea(listaContentVersion,listaActividades);
				
			//Creamos la tarea para la creación del caso completo
			Task tarea = new Task();
			tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
			tarea.WhatId = caso.Id;
			tarea.Type = 'Apertura de caso desde PROMOR';
			tarea.Description = 'Proceso Promor: ' + 'Demanda: ' + input.demanda + ' - ' + 'Contrato: ' + input.contrato;
			tarea.Subject = 'Apertura de caso desde PROMOR';
			tarea.Status = 'Completed';
			insert tarea;
			
			//Devolvemos el resultado esperado.
			output.resultado = 'OK';
			output.error = '';
			output.codigo = 'El caso ha sido creado satisfactoriamente.';
			output.caseId = caso.Id;
		}
	}
	private class CustomException extends Exception {}

	public static void generarContentLinkVersionTarea(List<ContentVersion> listaContentVersion,List<Task> listaTareas) {

					List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
		
					//Recuperar ContentDocumentId de los registros Content Version insertados
					List<Id> listaContentVersionId = new List<Id>();
					for (ContentVersion cv : listaContentVersion) {
						listaContentVersionId.add(cv.Id);
					}

					listaContentVersion = [SELECT ContentDocumentId,Description FROM ContentVersion WHERE Id IN :listaContentVersionId];
                    
					for (Task tarea : listaTareas) {

						 //Insertar registros ContentDocumentLink
						// List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
						for (ContentVersion cv : listaContentVersion) {

							//adjunto.nombreadjunto + ' - ' + adjunto.tipodocumento;
							if (cv.Description.contains(tarea.Description) && cv.Description.contains(tarea.Subject)) {
								ContentDocumentLink cdLink2 = new ContentDocumentLink();
								cdLink2.LinkedEntityId = tarea.Id;	
								cdLink2.ContentDocumentId = cv.ContentDocumentId;
								cdLink2.ShareType = 'I';
								listaContentDocumentLink.add(cdLink2);
							}
				}
					}

		if (!listaContentDocumentLink.isEmpty()) {
			insert listaContentDocumentLink;
		}

	}

	public static void generarContentLinkVersionCaso(List<ContentVersion> listaContentVersion,Case caso) {

		List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
		
					//Recuperar ContentDocumentId de los registros Content Version insertados
					List<Id> listaContentVersionId = new List<Id>();
					for (ContentVersion cv : listaContentVersion) {
						listaContentVersionId.add(cv.Id);
					}

					listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId];
                        
                    //Insertar registros ContentDocumentLink
                   // List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
				   Integer numero = 0;
                    for (ContentVersion cv : listaContentVersion) {

                        ContentDocumentLink cdLink = new ContentDocumentLink();
                        cdLink.LinkedEntityId = caso.Id;
                        cdLink.ContentDocumentId = cv.ContentDocumentId;
                        cdLink.ShareType = 'V';
                        listaContentDocumentLink.add(cdLink);
                    }			
		if (!listaContentDocumentLink.isEmpty()) {
			insert listaContentDocumentLink;
		}

	}

	public static void registrarTraza(RestRequest req, RestResponse res, Datetime dtStart, String resultado, Integer error){
        res.statusCode=error;
        res.responseBody= Blob.valueOf(resultado);
        req.requestURI = '/AltaCasoPromorv1/*';
        Datetime dtEnd = Datetime.now();
        register(req,res,dtStart,dtEnd,'SACH_WS_AltaCasoPromor','SACH_WS_AltaCasoPromor');
    }
}