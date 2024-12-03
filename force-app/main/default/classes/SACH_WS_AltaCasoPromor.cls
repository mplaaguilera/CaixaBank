@RestResource(urlMapping='/AltaCasoPromor/*')
global with sharing class SACH_WS_AltaCasoPromor extends CBK_HttpServiceIntegration_Abstract{
	
	 // Definimos las propiedades del json a recibir
	 @TestVisible
	 global class Input {
		 @TestVisible
		 global String demanda {get;set;}
		 global String iddemanda {get;set;}
		 global Long contrato {get;set;}
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
		 global String descripcion {get;set;}
		 global String caseId {get;set;}
		 global String codigo {get;set;}
 
		 Output(String resultado, String descripcion, String codigo, String caseId) {
			 this.resultado = resultado;
			 this.descripcion = descripcion;
			 this.codigo = codigo;
			 this.caseId = caseId;
		 }
	 }



	@HttpPost
	global static Output registrarCasoPromor() {

		String peticionRest = RestContext.request?.requestBody.toString();
		RestRequest req =  RestContext.request;
		Input input ;
		Output output = new Output('OK', '', '', '');
		RestResponse res = RestContext.response;
		Datetime dtStart = Datetime.now();
		String resultado;
		Case casoExistente;
		Contact contactoIdentificado;

		
		try {

			input = (Input)JSON.deserialize(peticionRest.toString(), Input.class);
			contactoIdentificado = SACH_Identificacion_Auto.identificarNUMPERSOsinCodificar(input.numperso);

			//Validaciones de entrada para la oficina gestora
			if (input.oficinagestora == null || input.oficinagestora.length() != 9) {
				throw new CustomException('Error! - El campo Oficina gestora tiene que tener este formato EEE-CCCCC. Realice las correciones oportunas');
			}

			Id idOficinaGestora;
			String numeroEmpresa = input.oficinagestora.substring(0, 3);
			String numeroOficina = input.oficinagestora.substring(input.oficinagestora.length() - 5);

			List<Account> oficinasGestoras = [SELECT Id FROM Account WHERE CC_Numero_Empresa__c =:numeroEmpresa AND CC_Numero_Oficina__c = :numeroOficina  AND RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];
			if (!oficinasGestoras.isEmpty()) {
				idOficinaGestora = oficinasGestoras[0].Id;
			}

			//Realizamos las comprobaciones necesarias para el proceso
			realizarValidacionesEntrada(input,contactoIdentificado,idOficinaGestora,peticionRest);

			//Buscamos el caso existente con este numperso
			try {
				casoExistente = [SELECT Status, CC_MCC_Solucion__c FROM Case WHERE RecordType.DeveloperName = 'SACH_Cliente' AND ContactId = :contactoIdentificado.Id LIMIT 1];
				
				String nombreSolucion = '';
                for (CC_MCC__c clasificacion : [SELECT Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Solucion'
                                                AND CC_Tipo_Cliente__c = 'Cliente (SACH)' AND CC_Activo__c = TRUE]) {
                    if (clasificacion.Id == casoExistente.CC_MCC_Solucion__c) {
                        nombreSolucion = clasificacion.Name;
                    }
                }
			} catch (QueryException e) {
				casoExistente = null;
			}

			//Ejecutamos la función principal del proceso del Web Service
			gestionPeticionPromor(input, output,peticionRest,casoExistente,contactoIdentificado,idOficinaGestora);
			handleWebServiceResponse(req, res, dtStart, output, 412);
			
			
		} catch (Exception e) {
			

			output.resultado = 'KO';
			output.codigo = e.getTypeName(); //'0000'
			output.descripcion = 'ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.');
			CBK_Log.error(e);

			//Registramos las trazas adecuadamente.
			//resultado = '{"Result":"KO","Description":"Datos obligatorios no informados."}';
			//String outputString = 'Resultado: ' + output.resultado + ', Descripción: ' + output.descripcion + ', Código: ' + output.codigo;
			handleWebServiceResponse(req, res, dtStart, output, 412);
		} finally {
			
			if (output.resultado != 'OK') {
				//resultado = '{"Result":"KO","Description":"No hay datos para retornar."}';
                output.codigo = '201';
                handleWebServiceResponse(req, res, dtStart, output, 201);

			} else {
				//resultado = '{"Result":"OK","Description":"Busqueda realizada."}';
                output.codigo = '200';
				//String outputString = 'Resultado: ' + output.resultado + ', Descripción: ' + output.descripcion + ', Código: ' + output.codigo;
				handleWebServiceResponse(req, res, dtStart, output, 200);
			}
		}
		return output; //Devolvemos el resultado obtenido
    }

	/**
     * @description Función para recoger y validar todos los campos de entrada del servicio
     * @param input Estructura de entrada del servicio REST
     * 
     */
	public static void realizarValidacionesEntrada(Input input,Contact contactoIdentificado,Id idOficinaGestora,String peticionRest){

		Case casoExistente;
		//Contact contactoIdentificado;

		//Comprobamos los campos obligatorios para la recepcion de datos
		if (String.isBlank(peticionRest)) {
			throw new CustomException('Petición vacía');
		}
		

		if (input.contrato == null || input.contrato <= 0) {
			throw new CustomException('Error! - Número de contrato NO informado. Este campo es OBLIGATORIO.');
		}

		if (input.actividades == null) {
			throw new CustomException('Error! - No se han incluido Actividades. Es necesario que al menos tenga una actividad la llamada.');
		}

		if (String.isBlank(input.demanda)) {
			throw new CustomException('Error! - La demanda NO está informada. Este campo es OBLIGATORIO.');
		}

		if (String.isBlank(input.iddemanda)) {
			throw new CustomException('Error! - El iddemanda NO está informado. Este campo es OBLIGATORIO.');
		}

		if (String.isBlank(input.numperso)) {
			throw new CustomException('Error! - NUMPERSO no está informado. Este campo es OBLIGATORIO.');
		}
		if (String.isBlank(input.oficinagestora)) {
			throw new CustomException('Error! - OFICINA GESTORA no informado. Este campo es OBLIGATORIO.');
		}

		//Comprobamos el pacto
		if (String.isnotBlank(input.pacto)) {
			if (!new Set<String>{'226', '224', '301', '327', '299'}.contains(input.pacto)) {
				throw new CustomException('El pacto que ha informado es incorrecto. Por favor revise el código del Pacto');   
			}
		} 

		//Validadciones para los archivos Adjuntos, tanto para cuando es un nuevo caso como uno existente
		if (input.actividades != null) {

			for (Actividad actividad : input.actividades) {
				//Manejo de los errores de la llegada de datos
				if (String.isBlank(actividad.codactividad)) {
					throw new CustomException('Error! - codactividad no informado. Este campo es OBLIGATORIO.');
				}


				//Manejo de los archivos adjuntos
				if (actividad.adjuntos != null) {
					//Insertar registros Content Version
			
					for (Adjunto adjunto : actividad.adjuntos) {
						//Manejo de los errores de la llegada de datos sobre los ficheros adjuntos
						if (String.isBlank(adjunto.iddocumento)) {
							throw new CustomException('Error! - iddocumento no está informado. Este campo es OBLIGATORIO.');
						}

						if (String.isBlank(adjunto.nombreadjunto)) {
							throw new CustomException('Error! - nombreadjunto no está informado. Este campo es OBLIGATORIO.');
						}

						if (String.isBlank(adjunto.tipodocumento)) {
							throw new CustomException('Error! - tipodocumento no está informado. Este campo es OBLIGATORIO.');
						}
					}
				}	
			}
		}
		

		//Validaciones con caso existente
		//Comprobaciones para casos existentes
		//contactoIdentificado = SACH_Identificacion_Auto.identificarNUMPERSOsinCodificar(input.numperso);

		if (contactoIdentificado == null) {
			throw new CustomException('NUMPERSO no existe o es incorrecto. Por favor revise el numpero enviado.');
		}

		//Buscamos el caso existente con este numperso
		try {
			casoExistente = [SELECT Status, CC_MCC_Solucion__c FROM Case WHERE RecordType.DeveloperName = 'SACH_Cliente' AND ContactId = :contactoIdentificado.Id LIMIT 1];
			
			String nombreSolucion = '';
			for (CC_MCC__c clasificacion : [SELECT Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Solucion'
											AND CC_Tipo_Cliente__c = 'Cliente (SACH)' AND CC_Activo__c = TRUE]) {
				if (clasificacion.Id == casoExistente.CC_MCC_Solucion__c) {
					nombreSolucion = clasificacion.Name;
				}
			}

			// Si el caso esta con codigo 715 y pendientes de colaborador --> reactivar el caso
			if (casoExistente.Status == 'Pendiente Colaborador' && nombreSolucion == 'Suspensión actuaciones por instrucción del SACH (715)') {

				if (String.isBlank(input.pacto)) {
					throw new CustomException('Error! - El campo pacto no está informado y es obligatorio. Al estar en Pendiente Colaborador y en solución 715.');
				}
			}

			// Si el campo pacto viene informado comprobar que envia el codigo correcto y guardar el campo
			if (String.isnotBlank(input.pacto)) {
				if (!new Set<String>{'226', '224', '301', '327', '299'}.contains(input.pacto)) {
					throw new CustomException('El pacto que ha informado es incorrecto. Por favor revise el código del Pacto');   
				}
			}

		} catch (QueryException e) {
			casoExistente = null;
		}

		//Id idOficinaGestora;
		//List<Account> oficinasGestoras = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = :input.oficinagestora AND RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];

		if (idOficinaGestora == null) {
				throw new CustomException('La Oficina Gestora que ha indicado no existe o es incorrecta.');	
		}
	}



     /**
     * @description Función core para la parte de SACH. 
     * @param input Estructura de entrada del servicio REST
     * @return retorno del servicio REST
     */
	public static void gestionPeticionPromor(Input input, Output output,String jsonString,Case casoExistente, Contact contactoIdentificado,Id idOficinaGestora) {
		
		/*
        //Case casoAntiguo;
		//Contact contactoIdentificado = SACH_Identificacion_Auto.identificarNUMPERSOsinCodificar(input.numperso);

		if (contactoIdentificado == null) {
			throw new CustomException('NUMPERSO no existe o es incorrecto. Por favor revise el numpero enviado.');
		}
		
        try {
            casoAntiguo = [SELECT Status, CC_MCC_Solucion__c FROM Case WHERE RecordType.DeveloperName = 'SACH_Cliente' AND ContactId = :contactoIdentificado.Id LIMIT 1];
        } catch (QueryException e) {
            casoAntiguo = null;
        }*/

        if (casoExistente != null) {

                // Para cada caso vamos a buscar que Solucion tiene el caso
                // Iterar sobre la lista original y filtrar por el ID de la solucion
                String nombreSolucion = '';
                for (CC_MCC__c clasificacion : [SELECT Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Solucion'
                                                AND CC_Tipo_Cliente__c = 'Cliente (SACH)' AND CC_Activo__c = TRUE]) {
                    if (clasificacion.Id == casoExistente.CC_MCC_Solucion__c) {
                        nombreSolucion = clasificacion.Name;
                    }
                }

                //Aqui viene la lógica para cuando exista un caso ya abierto para este cliente
                output.resultado = 'OK';
                output.codigo = '200';
                output.descripcion = 'Ya existe un caso asociado.';
                output.caseId = casoExistente.Id;
                Id idCasoAntiguo = casoExistente.Id;

                //Comprobar lógicas de Solución de caso
                //Si el caso esta cerrado se debe abrir con una nueva actividad y se le asigna a la cola sach-promor
                if (casoExistente.Status == 'Cerrado') {
                    casoExistente.Status = 'Activo';
                    casoExistente.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SACH_Promor'].Id;
                    update casoExistente;

                    //Creamos la tarea
                    Task tarea = new Task();
                    tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
                    tarea.WhatId = casoExistente.Id;
                    tarea.Type = 'Reapertura de caso desde PROMOR';
                    tarea.Description = 'Proceso Promor: ' + input.demanda + ' ' + input.contrato + ' ' + input.pacto;
                    tarea.Subject = 'Reapertura de caso desde PROMOR';
                    tarea.Status = 'Completed';
                    insert tarea;

					//Aqui viene la lógica para cuando exista un caso ya abierto para este cliente
					output.resultado = 'OK';
					output.codigo = '200';
					output.descripcion = 'Ya existe un caso asociado. Se ha reabierto el caso, y asignado a la cola PROMOR.';
					output.caseId = casoExistente.Id;

                }

                // Si el caso esta con codigo 715 y pendientes de colaborador --> reactivar el caso
                if (casoExistente.Status == 'Pendiente Colaborador' && nombreSolucion == 'Suspensión actuaciones por instrucción del SACH (715)') {
					
					/*
					if (String.isBlank(input.pacto)) {
						throw new CustomException('Error! - El campo pacto no está informado y es obligatorio. Al estar en Pendiente Colaborador y en solución 715.');
					}

					//Comprobamos el pacto
					if (String.isnotBlank(input.pacto)) {
						if (!new Set<String>{'226', '224', '301', '327', '299'}.contains(input.pacto)) {
							throw new CustomException('El pacto que ha informado es incorrecto. Por favor revise el código del Pacto');   
						}
					} */

                    casoExistente.Status = 'Activo';
                    casoExistente.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SACH_Promor'].Id;
                    casoExistente.SACH_Pacto__c = input.pacto;
                    update casoExistente;

					//Verificamos si ya existe alguna tarea de traslado Colaborador abierta para el Caso y si existe se cierra.
					List<Task> tareasTrasladoAbiertas = [SELECT Id FROM Task WHERE WhatId = :casoExistente.Id AND Type = 'Traslado Colaborador' AND IsClosed = FALSE WITH SECURITY_ENFORCED LIMIT 1];
					if (!tareasTrasladoAbiertas.isEmpty()) {
						tareasTrasladoAbiertas[0].Status = 'Completed';
                		update tareasTrasladoAbiertas;
					}

					//Aqui viene la lógica para cuando exista un caso ya abierto para este cliente
					output.resultado = 'OK';
					output.codigo = '200';
					output.descripcion = 'Ya existe un caso asociado. Se ha actualizado el campo pacto correctamente, puesto que se encontraba Pendiente Colaborador y en estado 715.';
					output.caseId = casoExistente.Id;
                }

				// Si el campo pacto viene informado comprobar que envia el codigo correcto y guardar el campo
				if (String.isnotBlank(input.pacto)) {			
						casoExistente.SACH_Pacto__c = input.pacto;
						update casoExistente;
                }

				//Gestionamos las actividades junto con los datos adjuntos que nos llegan.
				generarActividadesconAdjuntos(casoExistente,input);

		//Creación de un nuevo caso recibiendo datos desde PROMOR	
		} else {
			SACH_Parametros__c rutaRelativa = SACH_Parametros__c.getInstance('SACH_Promor');
			String rutaDefinitiva = '';
			//Recogida del Custom Setting para formar el Link del archivo
			//Recogemos el Custom Setting para obtener las direcciones de correo de respuesta
			
			/*
			Id idOficinaGestora;
			List<Account> oficinasGestoras = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = :input.oficinagestora AND RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];

			if (!oficinasGestoras.isEmpty()) {
				idOficinaGestora = oficinasGestoras[0].Id;
			} 
			else {
				throw new CustomException('La Oficina Gestora que ha indicado no existe o es incorrecta.');	
			}

			/*
			if (String.isnotBlank(input.pacto)) {
				if (!new Set<String>{'226', '224', '301', '327', '299'}.contains(input.pacto)) {
					throw new CustomException('El pacto que ha informado es incorrecto. Por favor revise el código del Pacto');   
				}
			} */

			//NUEVO CASO DE ENTRADA
			//Creación de un caso nuevo porque no hay antes nada relacionado con ninguún caso anterior.
			Case caso = new Case();
			caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
			caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SACH_Promor'].Id;
			caso.Origin = 'Solicitud de subasta';
			caso.Subject = 'Señalamiento de subasta';
			caso.CC_Tipo_Contacto__c = 'Solicitud de subasta';
			caso.SACH_Demanda__c = input.demanda;
			caso.SACH_IdDemanda__c = input.iddemanda;
			caso.OS_Contrato__c = input.contrato;
			caso.CC_NumPerso__c = input.numPerso;
			caso.SACH_Pacto__c = input.pacto;
			caso.ContactId = contactoIdentificado.Id;
			caso.SACH_Oficina_Gestora_Contrato__c = idOficinaGestora;
			insert caso;

			//Gestionamos las actividades junto con los datos adjuntos que nos llegan.
			generarActividadesconAdjuntos(caso,input);

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
			output.descripcion = '';
			output.codigo = 'El caso ha sido creado satisfactoriamente.';
			output.caseId = caso.Id;
		}
	}


	/*Función para generar las actividades que nos llegan junto con los adjuntos que estas traigan*/
	public static void generarActividadesconAdjuntos(Case caso,Input input){

		SACH_Parametros__c rutaRelativa = SACH_Parametros__c.getInstance('SACH_Promor');
		String rutaDefinitiva = '';

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

		//Se guarda el horario laboral dependiendo de si es la temporada de Verano o de Invierno
		BusinessHours horarioLaboral;
		if(CBK_UtilsDate.nowDT().month() >= 5 && CBK_UtilsDate.nowDT().month() <= 9){
			horarioLaboral = [SELECT Id FROM BusinessHours WHERE Name = 'SACH_Calendario_Verano'];
		}else{
			horarioLaboral = [SELECT Id, Name FROM BusinessHours WHERE Name = 'SACH_Calendario_Invierno'];
		}

		for (Actividad actividad : input.actividades) {

			/*
			//Manejo de los errores de la llegada de datos
			if (String.isBlank(actividad.codactividad)) {
				throw new CustomException('Error! - codactividad no informado. Este campo es OBLIGATORIO.');
			}*/

			//Recogemos las actividades segun la codificacion especificada
			String actividadDesc = '';
			if (codigodeactividades.containsKey(actividad.codactividad)) {
				actividadDesc = codigodeactividades.get(actividad.codactividad);
			}	

			//Verificamos que el caso no tenga ya esta actividad creada y por lo tanto no le adjuntamos los ficheros.
			//Verificamos si ya existe alguna tarea de traslado Colaborador abierta para el Caso y si existe se cierra.
			//List<Task> tareasActividades = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Automática' AND Subject = :actividadDesc WITH SECURITY_ENFORCED LIMIT 1];

			List<Task> tareasActividades = comprobarTareasExistentes(caso,actividadDesc);
			
			
			if (tareasActividades.isEmpty()) {
				
				// Crea la tarea correspondiente
				Task tareacomentario = new Task();
				tareacomentario.CC_Fecha_Fin__c = Datetime.now();
				tareacomentario.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
				tareacomentario.WhatId = caso.Id;
				tareacomentario.CC_Fecha_Inicio__c = Datetime.now();
				tareacomentario.Type = 'Automática';
				tareacomentario.Description = actividad.comentarios;
				tareacomentario.Subject = actividadDesc;
				tareacomentario.Status = 'Completed';
				//insert tareacomentario;
				//Comprobamos si la actividad es la 700
				if (actividad.codactividad == '700'){        
					DateTime dia = CBK_UtilsDate.nowDT();
					for (Integer i = 0; i < 7; i++) {
						dia = BusinessHours.nextStartDate(horarioLaboral.Id, dia.addDays(1));
					}
					
					Datetime fecha = BusinessHours.nextStartDate(horarioLaboral.Id, Datetime.newInstance(dia.year(), dia.month(), dia.day(), CBK_UtilsDate.nowDT().hour(), CBK_UtilsDate.nowDT().minute(), 0));
					
					tareacomentario.CC_Fecha_Vencimiento__c = fecha;
					tareacomentario.ActivityDate = fecha.date();
					tareacomentario.CC_Fecha_Fin__c = fecha;
				}
				listaActividades.add(tareacomentario);
			
				//Manejo de los archivos adjuntos
				if (actividad.adjuntos != null) {
					//Insertar registros Content Version
			
					for (Adjunto adjunto : actividad.adjuntos) {

					/*	
					//Manejo de los errores de la llegada de datos sobre los ficheros adjuntos
					if (String.isBlank(adjunto.iddocumento)) {
						throw new CustomException('Error! - iddocumento no está informado. Este campo es OBLIGATORIO.');
					}

					if (String.isBlank(adjunto.nombreadjunto)) {
						throw new CustomException('Error! - nombreadjunto no está informado. Este campo es OBLIGATORIO.');
					}

					if (String.isBlank(adjunto.tipodocumento)) {
						throw new CustomException('Error! - tipodocumento no está informado. Este campo es OBLIGATORIO.');
					}*/

					rutaDefinitiva = rutaRelativa.SACH_Parametro_1__c + '&idDocumento='+adjunto.iddocumento+'&referenciaExterna='+input.iddemanda; 		//emailrespuesta.HDT_Configuracion_1__c
					ContentVersion contentVersion = new ContentVersion();
					contentVersion.contentUrl = rutaDefinitiva;
					contentVersion.Description = adjunto.nombreadjunto + ' - ' + adjunto.tipodocumento + ' - ' + actividad.comentarios + ' - ' + actividadDesc;
					contentVersion.contentLocation = 'L';
					listaContentVersion.add(contentVersion);
				}
			}	
			}
		}

		if (!listaActividades.isEmpty()){
			insert listaActividades;
		}
		
		if (!listaContentVersion.isEmpty()){
			insert listaContentVersion;
			generarContentLinkVersionCaso(listaContentVersion,caso);
			generarContentLinkVersionTarea(listaContentVersion,listaActividades);
		}
		
	}


	public static List<Task> comprobarTareasExistentes(Case caso, String actividadDesc){

			List<Task> tareasActividades = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Automática' AND Subject = :actividadDesc WITH SECURITY_ENFORCED LIMIT 1];

			return tareasActividades;
	
                
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

	public static void handleWebServiceResponse(RestRequest req, RestResponse res, Datetime dtStart, Output resultado, Integer error){
        res.statusCode=error;
		res.responseBody = Blob.valueOf(JSON.serializePretty(resultado));
        //res.responseBody= Blob.valueOf(resultado);
        req.requestURI = '/AltaCasoPromor/*';
        Datetime dtEnd = Datetime.now();
        register(req,res,dtStart,dtEnd,'SACH_WS_AltaCasoPromor','SACH_WS_AltaCasoPromor');
    }
}