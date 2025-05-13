public with sharing class CC_Activity {

	public static Task crearActividad(Task tarea) {
		//Task tarea = new Task();
		if (tarea == null) {
			return null;
		} else {
			if (tarea.WhatId != null && OT_Proyectos.registroProyecto(tarea.WhatId) == 'AM') {
				tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
			} else if (tarea.RecordTypeId != CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task')) {
				tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
			} else {
				tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
			}

			tarea.Description = (!String.isBlank(tarea.Description) ? tarea.Description.left(32000) : tarea.Description);
			insert tarea;
			List <Case> caso = [SELECT Id, SAC_EnvioParcial__c FROM Case WHERE Id = : tarea.WhatId LIMIT 1];
			if(caso[0].SAC_EnvioParcial__c){
				rellenarCalculoKPITareas(tarea.WhatId);
			}
			return tarea;
		}
	}

	public static Task getActividad(Task tarea, Map<String, Object> campos) {
      	tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
     	tarea.ActivityDate = System.today();
        tarea.CC_Fecha_Inicio__c = System.now();

        if (campos != null) {
            for (String campo : campos.keySet()) {	 
                tarea.put(campo, campos.get(campo));
            }
        }
        return tarea;
    }

	public static Database.SaveResult[] crearActividades(List<Task> tareas, Boolean allOrNone) {
		if (tareas.isEmpty()) {
			return null;
		} else {
			List<Task> actividades = new List<Task>();
			for (Task tarea : tareas) {
				if (tarea.WhatId != null && OT_Proyectos.registroProyecto(tarea.WhatId) == 'AM') {
					tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
				} else if (tarea.RecordTypeId != CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task')) {
					tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
				}else {
					tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
				}
				actividades.add(tarea);
			}
			return Database.insert(actividades, allOrNone);
		}
	}

	public static void llamadaQueueableCrearActividades(List<Task> tareas) {

		DateTime dt = DateTime.now();
		Long dateInMilliseconds = dt.getTime();
		
		AsyncOptions options = new AsyncOptions();
		options.DuplicateSignature = QueueableDuplicateSignature.Builder()
		.addId(UserInfo.getUserId())
						.addString(String.valueOf(dateInMilliseconds))
						.build();

		try {
			crearActividadesQueueable crearActividades = new crearActividadesQueueable();
			List<Task> idsTareas = tareas;
			crearActividades.setParams(idsTareas);
			System.enqueueJob(crearActividades, options);

		} catch (DuplicateMessageException ex) {
			//Exception is thrown if there is already an enqueued job with the same signature
			CBK_Log.error(ex);
		}

	}

    public class crearActividadesQueueable implements Queueable {

		private List<Task> idsTareas;
		
		public void setParams(List<Task> idsTareas) {
			this.idsTareas = idsTareas;
		}

		public void execute(QueueableContext context) {
        	crearActividades(idsTareas);
    	}
	}

	public static void crearActividades(List<Task> tareas) {
		List<Task> actividades = new List<Task>();
		if (!tareas.isEmpty()) {
			for (Task tarea : tareas) {
				tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
				actividades.add(tarea);
			}
		}
		insert actividades;
	}

	public static void crearActividades(List<Task> tareas, String recordTypeDevNamePorDefecto) {
		List<Task> actividades = new List<Task>();
		for (Task tarea : tareas) {
			if (!tarea.getPopulatedFieldsAsMap().containsKey('RecordTypeId') || String.isEmpty(tarea.RecordTypeId)) {
				//Se usa el recordType por defecto indicado
				tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', recordTypeDevNamePorDefecto);
                    //Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(recordTypeDevNamePorDefecto).getRecordTypeId();
			}
			actividades.add(tarea);
		}
		insert actividades;
	}

	public static Task finalizarActividad(Id idActividad) {
		Task actividad = new Task(Id = idActividad);
		actividad.Status = 'Completed';
		update actividad;
		return actividad;
	}

	public static void finalizarActividadCaso(Id idCaso, String tipo, String tipoCierre, String descripcion) {
		List<Task> actividades = [SELECT Status, CC_Tipo_Cierre__c, CC_Fecha_Fin__c, Description, IsReminderSet, ReminderDateTime,
									CC_Fecha_FinPlazo_SolInf__c, CC_Fecha_1_Reclamacion_Auto__c, CC_Fecha_2_Reclamacion_Auto__c,
									CC_Fecha_3_Reclamacion_Auto__c, WhatId
									FROM Task WHERE Status = 'Open' AND Type = :tipo AND WhatId = :idCaso ORDER BY CreatedDate DESC];
		List<Id> idCasos =  new List<Id>();
		List<Case> casosFCO = new List<case>();
		for (Task actividad : actividades) {
			//Si llega la respuesta de Sol. Inf. reseteamos la fecha fin plazo para que no se cierre el caso ni se envíe un mail
			if (actividad.CC_Fecha_FinPlazo_SolInf__c != null) {
				actividad.CC_Fecha_FinPlazo_SolInf__c = null;
			}
			if (tipoCierre != null) {
				actividad.CC_Tipo_Cierre__c = tipoCierre;
			}
			if (descripcion != null) {
				actividad.Description = descripcion;
			}
			if (tipo == 'Traslado Tercer Nivel') {
				idCasos.add(actividad.WhatId);
			}

			actividad.CC_Fecha_Fin__c = System.now();
			actividad.Status = 'Completed';

			if (tipo == 'Traslado Tercer Nivel' && tipoCierre == 'Rechazado por Tercer Nivel') {
				//Bell notification
				actividad.IsReminderSet = true;
				Datetime newDate = Datetime.valueOf(System.now());
				newDate = newDate.addMinutes(2); //Fix temporal!
				actividad.ReminderDateTime = newDate;
			}

			//Comentamos el blanqueo de las fechas para que se vuelvan a ejecutar las reclamaciones en el caso en el que se reabra la tarea
			/* else if (tipo == 'Traslado Colaborador') {
				actividad.CC_Fecha_1_Reclamacion_Auto__c = null;
				actividad.CC_Fecha_2_Reclamacion_Auto__c = null;
				actividad.CC_Fecha_3_Reclamacion_Auto__c = null;
			}*/
		}

		if (!idCasos.isEmpty()) {
			for (Case caso : [SELECT CC_Fin_Pendiente_Interno__c FROM Case WHERE Id IN :idCasos
								AND CC_Canal_Procedencia__c = 'Formulario Consultas Operativas'
								AND Recordtype.DeveloperName = 'CC_Empleado']) {
				caso.CC_Fin_Pendiente_Interno__c = DateTime.now();
				casosFCO.add(caso);
			}
		}
		update actividades;
		update casosFCO;
	}

	public static void informarFechaVencimientoSLA(String tipoGrupo, String grupo, Task actividad) {
		//Cálculo de la fecha límite SLA de la actividad
		String horasSLA;
		String nombreBusinessHours;

		if (tipoGrupo == 'Grupo colaborador') {
			horasSLA = CC_Listas_Valores.LookupValue('Configuración de SLA para traslados colaborador', grupo);
			nombreBusinessHours = CC_Listas_Valores.LookupValue('Configuración de horario de oficina para traslados colaborador', grupo);
		} else if (tipoGrupo == 'Grupo 3N') {
			horasSLA = CC_Listas_Valores.LookupValue('Configuración de SLA para 3N', grupo);
			nombreBusinessHours = CC_Listas_Valores.LookupValue('Configuración de horario de oficina para 3N', grupo);
		}

		if (horasSLA != null && nombreBusinessHours != null) {
			String idBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = :nombreBusinessHours LIMIT 1].Id;
			actividad.CC_Tiempo_Resolucion__c = Integer.valueOf(horasSLA);
			actividad.CC_Fecha_Vencimiento__c = BusinessHours.add(idBusinessHours, System.now(), Integer.valueOf(horasSLA) * 3600 * 1000); //en milisegundos}
		}
	}


	public static void createActivityTraslados(Id recordId, String comentario, String subject, String tipoTarea, String grupo3N, String grupoId, Id llamadaId, String estado) {
        //Crear actividad
        Task task = new Task();
        task.WhatId = recordId;
        task.Status = estado;
        task.ActivityDate = System.today();
        task.Subject = subject;
        task.Type = tipoTarea;
        task.CallObject = grupo3N;
        task.Description = comentario;
        task.CC_Fecha_Inicio__c = Datetime.valueOf(System.now());
        task.CC_Llamada_Id__c = llamadaId;
        task.CC_Grupo_Colaborador_Id__c = grupoId;
        task.CC_validacion_tarea_manual__c = true;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        //Cálculo de la fecha límite
        String horasSLA = CC_Listas_Valores.lookupValue('Configuración de SLA para 3N', grupo3N);
        String nombreBusinessHours = CC_Listas_Valores.lookupValue('Configuración de horario de oficina para 3N', grupo3N);

        if (horasSLA != null && nombreBusinessHours != null) {
            String idBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = :nombreBusinessHours LIMIT 1].Id;
            task.CC_Tiempo_Resolucion__c = Integer.valueof(horasSLA);
            Datetime fechaVencimiento = BusinessHours.add(idBusinessHours, System.now(), Integer.valueof(horasSLA) * 60 * 60 * 1000); //en milisegundos
            if (fechaVencimiento != null) {
                Task.CC_Fecha_Vencimiento__c = fechaVencimiento;
            }
        }
        //insert task;
        crearActividad(task);

    }
	
	public static Task crearActividadOportunidad(Id recordId, Id ownerId, Id contactId) {
		Task tarea = new Task();
		tarea.Subject = 'Creación oportunidad';
		tarea.Status = 'Completed';
		tarea.Priority = 'Normal';
		tarea.AV_OrigenAct__c = 'Contact Center';
		tarea.Type = 'Oportunidad CSBD';
		tarea.WhatId = recordId;
		tarea.OwnerId = ownerId;
		tarea.WhoId = contactId;
		tarea.AV_Case__c = recordId;
		tarea = getActividad(tarea, null);	
		insert tarea;		
		rellenarCalculoKPITareas(ownerId);
		return tarea;
	}

	public static Task crearActividadBaseDerivar(Id recordTypeTarea, String asunto,String comentarios, Date fechaActividad){
		Task tareaBase = new Task();
		tareaBase.recordTypeId = recordTypeTarea;
		tareaBase.Subject = asunto;
		tareaBase.Status = 'Open';
		tareaBase.Priority = 'Normal';
		tareaBase.Description = comentarios;
		tareaBase.AV_OrigenAct__c = 'Contact Center';
		tareaBase.ActivityDate = fechaActividad;

		return tareaBase;

	}

	public static Task crearTareaDirector(Map<String, Object> respuesta /*(Id recordTypeTarea, String asunto,String comentarios, Id recordId, Id accountId, String numeroOficina, Id gestorClienteId*/){
        Id recordTypeTarea = (Id)respuesta.get('recordTypeTarea');
        String asunto = (String)respuesta.get('asunto');
        String comentarios = (String)respuesta.get('comentarios');
        Id recordId = (Id)respuesta.get('recordId');
        Id accountId = (Id)respuesta.get('accountId');
        String numeroOficina = (String)respuesta.get('numeroOficina');
        Id gestorClienteId = (Id)respuesta.get('gestorClienteId');
		Date fechaActividad = Date.Today().addDays(7);

		Task tareaDirector = crearActividadBaseDerivar(recordTypeTarea, asunto, comentarios,fechaActividad);
		
		tareaDirector.AV_Case__c = recordId;
		tareaDirector.WhatId = accountId;
		tareaDirector.AV_Center__c = numeroOficina;
		tareaDirector.Type = 'Tarea gestor';
		tareaDirector.OwnerId = gestorClienteId;

		return tareaDirector;
	}

	public static Task crearTareaGestor(  Map<String, Object> respuesta /*Id recordTypeId, String asunto,String comentarios, Date fechaActividad, Id whatId, Id ownerId, Id avCaseId, String type*/) {
	Id recordTypeTarea = (Id)respuesta.get('recordTypeTarea');
	String asunto = (String)respuesta.get('asunto');
	String comentarios = (String)respuesta.get('comentarios');
	Date fechaActividad = (Date)respuesta.get('fechaActividad');
	Id whatId = (Id)respuesta.get('whatId');
	Id ownerId = (Id)respuesta.get('ownerId');
	Id avCaseId = (Id)respuesta.get('avCaseId');
	String type = (String)respuesta.get('type');

	Task tarea = crearActividadBaseDerivar(recordTypeTarea, asunto, comentarios, fechaActividad);
	
	
	if (avCaseId != null) {
		tarea.AV_Case__c = avCaseId;
	}
	
	if (type != null) {
		tarea.Type = type;
	}
	
	if (ownerId != null) {
		tarea.OwnerId = ownerId;
	}
	
	if (whatId != null) {
		tarea.WhatId = whatId;
	}

	return tarea;
	}
	
	public static Task crearActividadFraude(Id recordId, Id ownerId, Id contactId) {
		Task tarea = new Task();
		tarea.Subject = 'Creación caso a Fraude';
		tarea.Status = 'Completed';
		tarea.Priority = 'Normal';
		tarea.AV_OrigenAct__c = 'Contact Center';
		tarea.Type = 'Fraude';
		tarea.WhatId = recordId;
		tarea.OwnerId = ownerId;
		tarea.WhoId = contactId;
		tarea.AV_Case__c = recordId;
		tarea = getActividad(tarea, null);	
		insert tarea;
		rellenarCalculoKPITareas(recordId);
		return tarea;
	}

	public static Task crearTareaRellamadaCSBD(Opportunity opp, Case caso, String description) {
		Task tarea = new Task();
		tarea.Subject = 'Rellamada del Cliente al Contact Center'; 
		tarea.Status = 'Completed';
		tarea.Priority = 'Normal';
		tarea.Type = 'Rellamada CC';
		tarea.WhatId = opp.Id; 
		tarea.OwnerId = opp.OwnerId;  
		tarea.WhoId = opp.CSBD_Contact__c;
		tarea.AV_Case__c = caso.Id;
		tarea.Description = description;
		tarea.ActivityDate = System.today();
        tarea.CC_Fecha_Inicio__c = System.now();
		Id recordTypeCSBD = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CSBD_Task');
		tarea.RecordTypeId = recordTypeCSBD;	
		insert tarea;
		return tarea;
	}

	public static Task crearTareaRellamadaCC(Case caso, String description, String type) {
		Task tarea = new Task();
		Map<String, Object> fields = new Map<String, Object>{
			'Subject' => 'Rellamada cliente derivado CSBD', 
			'Status' => 'Completed',
			'Priority' => 'Normal',
			'AV_OrigenAct__c' => 'Contact Center',
			'Type' => type,
			'WhatId' => caso.Id,
			'OwnerId' => caso.OwnerId,			
			'WhoId' => caso.ContactId,
			'Description' => description,
			'AV_Case__c' => caso.Id
		};		
		tarea = getActividad(tarea,fields);	
		insert tarea;
		return tarea;
	}

	//US1156943 - Botón "Derivar" - No permitir crear oportunidad con citas y tareas en el caso
	public static Boolean identificarTareasCitasExistentes(Case caso,  CC_Lista_Valores__c listaValores){
		Boolean resultado;
		List<Task> listaDeTareas = [SELECT Id 
									FROM Task	
									WHERE (WhatId = :caso.Id OR (WhatId = :caso.AccountId AND AV_Case__c = :caso.Id)) 
									AND (RecordType.DeveloperName IN ('AV_AlertaComercial', 'CIBE_AlertaComercialEMP') OR Type IN ('Cita gestor', 'Cita rápida gestor')) 
									LIMIT 1];
		
		if (listaValores.CC_Activa__c  ) {
			if(listaDeTareas.isEmpty()){
				resultado = false;
			}else{
				resultado = true;
			}
		} else {
			resultado = false;
		}
		return resultado;
	}

	//MGT US1170446: Botón "Derivar" - Phising/Smishing/Malware
	@AuraEnabled
    public static void crearActividadPhishingSinRiesgo(String recordId, String descriptionTask) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('El recordId no puede ser nulo');
        }
        //else
        Case caso = [SELECT id, OwnerId, ContactId
            FROM Case 
            WHERE Id = :recordId 
            LIMIT 1];

		String description =  descriptionTask;
		Task tareaCC = CC_Activity.crearTaskPhishingSinRiesgo(caso, description, 'Phishing Sin Riesgo');                       
    }

	public static Task crearTaskPhishingSinRiesgo(Case caso, String description, String type) {
		// Comprobamos si ya existe una tarea con el mismo asunto y tipo para el mismo caso
		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Subject = 'Tarea Phishing Sin Riesgo' AND Type = :type LIMIT 1];
    
		if (!tareaExistente.isEmpty()) {
			// Si ya existe una tarea, no creamos una nueva
			return null;
		}
		Task tarea = new Task();
		Map<String, Object> fields = new Map<String, Object>{
			'Subject' => 'Tarea Phishing Sin Riesgo', 
			'Status' => 'Completed',
			'Priority' => 'Normal',
			'AV_OrigenAct__c' => 'Contact Center',
			'Type' => type,
			'WhatId' => caso.Id,
			'OwnerId' => caso.OwnerId,			
			'WhoId' => caso.ContactId,
			'Description' => description,
			'AV_Case__c' => caso.Id
		};		
		tarea = getActividad(tarea,fields);	
		insert tarea;
		rellenarCalculoKPITareas(caso.Id);
		return tarea;
	}
	//MGT US1170446: Botón "Derivar" - Phising/Smishing/Malware

	//CSBD Telefono
	@AuraEnabled
	public static void crearActividadCSBDTelefonoNoCoincidente(Id recordId){
		Case caso = [SELECT id, OwnerId, ContactId
			FROM Case 
			WHERE Id = :recordId 
			LIMIT 1];
		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Subject = 'CSBD Teléfono No Coincide' LIMIT 1];
		if (tareaExistente.isEmpty()) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'CSBD Teléfono No Coincide', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'WhatId' => caso.Id,
				'OwnerId' => caso.OwnerId,			
				'WhoId' => caso.ContactId,
				'Type' => 'CSBD Teléfono No Coincide',
				'Description' => 'CSBD Teléfono No Coincide',
				'AV_Case__c' => caso.Id
			};		
			tarea = getActividad(tarea,fields);	
			insert tarea;
		}
	}
	//CSBD Telefono

	//Cajeros
	@AuraEnabled
	public static void crearActividadCajeros(Id recordId){
		Case caso = [SELECT id, OwnerId, ContactId
			FROM Case 
			WHERE Id = :recordId 
			LIMIT 1];
		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Subject = 'Cajeros' LIMIT 1];
		if (tareaExistente.isEmpty()) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'Cajeros', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'WhatId' => caso.Id,
				'OwnerId' => caso.OwnerId,			
				'WhoId' => caso.ContactId,
				'Type' => 'Cajeros',
				'Description' => 'Cajeros',
				'AV_Case__c' => caso.Id
			};		
			tarea = getActividad(tarea,fields);	
			insert tarea;
			rellenarCalculoKPITareas(recordId);
		}
	}
	//Cajeros

	//KPI
	@AuraEnabled
	public static void rellenarCalculoKPITareas(Id recordId){
		if(recordId != null){
			//Recogemos el caso con sus ambitos
			List<Case> caso = [SELECT id, OwnerId, Account.AV_IndicadoresClientes__c, CC_Motivo_Derivacion__c , ContactId, 
								CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, SAC_EnvioParcial__c 
								FROM Case 
								WHERE Id = :recordId 
								LIMIT 1];
			if(!caso.isEmpty()){
				//Recogemos el ambito que necesitamos dependiendo de si es imagin o no
				String ambitoActivo = caso[0].Account.AV_IndicadoresClientes__c != null && caso[0].Account.AV_IndicadoresClientes__c.contains('28') ? caso[0].CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c : caso[0].CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c;
				String resultadoTareas = '';
				//String phisingSmishingMalware = 'Phising/Smishing/Malware';
				switch on ambitoActivo{
					when 'Argos Xpays' {
						resultadoTareas = buscadorTareas(new List<String>{'Traslado Colaborador'}, caso[0].Id);
						if(resultadoTareas == 'Traslado Colaborador'){
							caso[0].CC_Motivo_Derivacion__c = 'Gestionado con soporte';
						}
					}
					when 'Argos General' {
						resultadoTareas = buscadorTareas(new List<String>{'Traslado Colaborador', 'Remitir Colaborador'}, caso[0].Id);
						if(resultadoTareas == 'Traslado Colaborador'){
							caso[0].CC_Motivo_Derivacion__c = 'Gestionado con soporte';
						} else if (resultadoTareas == 'Remitir Colaborador'){
							caso[0].CC_Motivo_Derivacion__c = 'Fraude';
						}
					}
					when 'Bizum Fraude' {
						resultadoTareas = buscadorTareas(new List<String>{'Remitir Colaborador'}, caso[0].Id);
						if (resultadoTareas == 'Remitir Colaborador'){
							caso[0].CC_Motivo_Derivacion__c = 'Fraude';
						}
					}
					when 'CaixaBank Talks'{
						resultadoTareas = buscadorTareas(new List<String>{'Remitir Colaborador'}, caso[0].Id);
						if (resultadoTareas == 'Remitir Colaborador'){
							caso[0].CC_Motivo_Derivacion__c = 'CaixaBank Talks';
						}
					}
					//Mirar flow procesos, ultima tarea se crea con el type = Flow en Registrar Evento, registrado en el disconnected callback de operativa oficina
					when 'Cajeros Incidencias'{
						resultadoTareas = buscadorTareas(new List<String>{'Flow'}, caso[0].Id);
						if (resultadoTareas == 'Flow'){
							caso[0].CC_Motivo_Derivacion__c = 'Cajeros';
						}
					}
					//Cambio de oficina y cambio de gestor rellenados en CC_Gestion_Derivar_Tarea
					when 'Cambio de oficina'{
						resultadoTareas = buscadorTareas(new List<String>{'Tarea Cambio Oficina'}, caso[0].Id);
						if (resultadoTareas == 'Tarea Cambio Oficina'){
							caso[0].CC_Motivo_Derivacion__c = 'Oficina';
						}
					}					
					when 'Cambio de gestor'{
						resultadoTareas = buscadorTareas(new List<String>{'Tarea Cambio Gestor'}, caso[0].Id);
						if (resultadoTareas == 'Tarea Cambio Gestor'){
							caso[0].CC_Motivo_Derivacion__c = 'Oficina';
						}
					}
					when 'Caso a Fraude'{
						resultadoTareas = buscadorTareas(new List<String>{'Fraude'}, caso[0].Id);
						if (resultadoTareas == 'Fraude'){
							caso[0].CC_Motivo_Derivacion__c = 'Fraude';
						}
					}
					when 'CSBD 3N', 'CSBD Contratar', 'CSBD No Contratar'{
						resultadoTareas = buscadorTareas(new List<String>{'Oportunidad CSBD', 'Traslado Tercer Nivel'}, caso[0].Id);
						if (resultadoTareas == 'Oportunidad CSBD' || resultadoTareas == 'Traslado Tercer Nivel'){
							caso[0].CC_Motivo_Derivacion__c = 'CSBD';
						}
					}
					when 'Documentacion'{
						resultadoTareas = buscadorTareas(new List<String>{'Oportunidad CSBD', 'Tarea Hub Imagin'}, caso[0].Id);
						if (resultadoTareas == 'Oportunidad CSBD'){
							caso[0].CC_Motivo_Derivacion__c = 'CSBD';
						} else if (resultadoTareas == 'Tarea Hub Imagin'){
							caso[0].CC_Motivo_Derivacion__c = 'Tarea Hub Imagin';
						} else {
							caso[0].CC_Motivo_Derivacion__c = 'Gestionado Contact';
						}
					}
					// when phisingSmishingMalware{
					// 	resultadoTareas = buscadorTareas(new List<String>{'Fraude'}, caso[0].Id);
					// 	if (resultadoTareas == 'Fraude'){
					// 		caso[0].CC_Motivo_Derivacion__c = 'Fraude';
					// 	} else {
					// 		caso[0].CC_Motivo_Derivacion__c = 'Gestionado Contact';
					// 	}
					// }
					when 'Testamentaría'{
						resultadoTareas = buscadorTareas(new List<String>{'Remitir Colaborador'}, caso[0].Id);
						if (resultadoTareas == 'Remitir Colaborador'){
							caso[0].CC_Motivo_Derivacion__c = 'Testamentaría';
						}
					}
					when 'Vidacaixa'{
						resultadoTareas = buscadorTareas(new List<String>{'Remitir Colaborador'}, caso[0].Id);
						if (resultadoTareas == 'Remitir Colaborador'){
							caso[0].CC_Motivo_Derivacion__c = 'Vidacaixa';
						}
					}
					when 'Cajeros'{
						resultadoTareas = buscadorTareas(new List<String>{'Cajeros'}, caso[0].Id);
						if (resultadoTareas == 'Cajeros'){
							caso[0].CC_Motivo_Derivacion__c = 'Vidacaixa';
						}
					}
				}
				//AMBITO NULO rellenar tareas
				String resultadoTareasNull = buscadorTareas(new List<String>{'Cita Gestor', 'Tarea Gestor', 'Cita rápida gestor', 'Tarea oficina', resultadoTareas}, caso[0].Id);
				if(resultadoTareasNull != 'no encontrado' && resultadoTareasNull != resultadoTareas){
					caso[0].CC_Motivo_Derivacion__c = 'Oficina';
				}
			} else {
				throw new AuraHandledException('No se encuentra el caso');
			}
			caso[0].SAC_EnvioParcial__c = false;
			update caso;
		} else {
			throw new AuraHandledException('El recordId del caso y de la tarea no pueden ser nulos');
		}
	}

	public static String buscadorTareas(List<String> tipo, Id recordId){
		List<Task> tareas = [SELECT Id, Subject, Status, Type FROM Task WHERE WhatId = :recordId AND (Type IN :tipo OR Subject IN :tipo) Order by CreatedDate DESC LIMIT 1];
		if(!tareas.isEmpty()){
			return tareas[0].Type;
		} else {
			return 'no encontrado';
		}
	}
	//KPI

	//Mecanismo firma
	public static void crearActividadMecanismoFirma(Case caso, Boolean clienteExtranjero) {
    	String tipo;
		String subject;
		String description;
		//Obtener el custom setting con los circuitos
		CC_Settings__c configuracion = CC_Settings__c.getValues('CC_MecanismoFirmaCircuitos');
		String circuitoExtranjero = configuracion.CC_Configuracion_1__c;
		String circuitoCodigoFirma = configuracion.CC_Configuracion_2__c;
		//Miramos si el cliente está en el extranjero o no
		if (clienteExtranjero) {
			tipo= circuitoExtranjero;
			subject = 'Tarea mecanismo de firma - '+circuitoExtranjero;
			description = circuitoExtranjero;
		} else {
			tipo = circuitoCodigoFirma;
			subject = 'Tarea mecanismo de firma - '+circuitoCodigoFirma;
			description = circuitoCodigoFirma;
		}

		Task tarea = new Task();
		Map<String, Object> fields = new Map<String, Object>{
			'Subject' => subject, 
			'Status' => 'Completed',
			'Priority' => 'Normal',
			'AV_OrigenAct__c' => 'Contact Center',
			'Type' => tipo,
			'WhatId' => caso.Id,
			'OwnerId' => caso.OwnerId,			
			'WhoId' => caso.ContactId,
			'Description' => description,
			'AV_Case__c' => caso.Id
		};		

		System.debug('WhatId '+ caso.Id);
		System.debug('OwnerId '+ caso.OwnerId);
		System.debug('ContactId '+ caso.ContactId);
		System.debug('AV_Case__c '+ caso.Id);
		
		tarea = getActividad(tarea,fields);	
		insert tarea;	
	}
	//Mecanismo firma
}