public with sharing class CC_Activity {

	public static Task crearActividad(Task tarea) {
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
			return tarea;
		}
	}

	public static Task getActividad(Task tarea, Map<String, Object> campos) {
      	tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
		tarea.ActivityDate = CBK_UtilsDate.todaySYS();
		tarea.CC_Fecha_Inicio__c = CBK_UtilsDate.nowSYS();

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

			actividad.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();
			actividad.Status = 'Completed';

			if (tipo == 'Traslado Tercer Nivel' && tipoCierre == 'Rechazado por Tercer Nivel') {
				//Bell notification
				actividad.IsReminderSet = true;
				Datetime newDate = Datetime.valueOf(CBK_UtilsDate.nowSYS());
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
			actividad.CC_Fecha_Vencimiento__c = BusinessHours.add(idBusinessHours, CBK_UtilsDate.nowSYS(), Integer.valueOf(horasSLA) * 3600 * 1000); //en milisegundos}
		}
	}


	public static void createActivityTraslados(Id recordId, String comentario, String subject, String tipoTarea, String grupo3N, String grupoId, Id llamadaId, String estado) {
        //Crear actividad
        Task task = new Task();
        task.WhatId = recordId;
        task.Status = estado;
        task.ActivityDate = CBK_UtilsDate.todaySYS();
        task.Subject = subject;
        task.Type = tipoTarea;
        task.CallObject = grupo3N;
        task.Description = comentario;
        task.CC_Fecha_Inicio__c = Datetime.valueOf(CBK_UtilsDate.nowSYS());
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
            Datetime fechaVencimiento = BusinessHours.add(idBusinessHours, CBK_UtilsDate.nowSYS(), Integer.valueof(horasSLA) * 60 * 60 * 1000); //en milisegundos
            if (fechaVencimiento != null) {
                Task.CC_Fecha_Vencimiento__c = fechaVencimiento;
            }
        }
        //insert task;
        crearActividad(task);

    }
	
	public static Task crearActividadOportunidad(Id recordId, Case caso) {
		Task tarea = new Task();
		tarea.Subject = 'Creación oportunidad';
		tarea.Status = 'Completed';
		tarea.Priority = 'Normal';
		tarea.AV_OrigenAct__c = 'Contact Center';
		tarea.Type = 'Oportunidad CSBD';
		tarea.WhatId = recordId;
		tarea.OwnerId = caso.OwnerId;
		tarea.WhoId = caso.Contact.AccountId != null ? caso.ContactId : null;
		tarea.AV_Case__c = recordId;
		tarea = getActividad(tarea, null);	
		insert tarea;		
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
	String type = (String)respuesta.get('type') == null ? 'Tarea gestor' : (String)respuesta.get('type');

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
	
	public static Task crearActividadFraude(Id recordId, Case caso) {
		Task tarea = new Task();
		tarea.Subject = 'Creación caso a Fraude';
		tarea.Status = 'Completed';
		tarea.Priority = 'Normal';
		tarea.AV_OrigenAct__c = 'Contact Center';
		tarea.Type = 'Fraude';
		tarea.WhatId = recordId;
		tarea.OwnerId = caso.OwnerId;
		tarea.WhoId = caso.Contact.AccountId != null ? caso.ContactId : null;
		tarea.AV_Case__c = recordId;
		tarea = getActividad(tarea, null);	
		insert tarea;
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
		tarea.ActivityDate = CBK_UtilsDate.todaySYS();
        tarea.CC_Fecha_Inicio__c = CBK_UtilsDate.nowSYS();
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
			'WhoId' => caso.Contact.AccountId != null ? caso.ContactId : null,
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
									AND (RecordType.DeveloperName IN ('AV_AlertaComercial', 'CIBE_AlertaComercialEMP') OR Type IN ('Cita gestor', 'Cita rápida gestor','Oficina sin tarea')) 
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
        Case caso = [SELECT id, OwnerId, ContactId, Contact.AccountId
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
			'WhoId' => caso.Contact.AccountId != null ? caso.ContactId : null,
			'Description' => description,
			'AV_Case__c' => caso.Id
		};		
		tarea = getActividad(tarea,fields);	
		insert tarea;
		return tarea;
	}
	//MGT US1170446: Botón "Derivar" - Phising/Smishing/Malware

	//CSBD Telefono
	@AuraEnabled
	public static void crearActividadCSBDTelefonoNoCoincidente(Id recordId){
		Case caso = [SELECT id, OwnerId, ContactId, Contact.AccountId
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
				'WhoId' => caso.Contact.AccountId != null ? caso.ContactId : null,
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
		Case caso = [SELECT id, OwnerId
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
				'Type' => 'Cajeros',
				'Description' => 'Cajeros',
				'AV_Case__c' => caso.Id
			};		
			tarea = getActividad(tarea,fields);	
			insert tarea;
		}
	}
	//Cajeros
	
	//Mecanismo firma
	public static void crearActividadMecanismoFirma(Case caso, Id ownerId) {
		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Mecanismo de firma' LIMIT 1];
		if (tareaExistente.isEmpty()) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'Tarea mecanismo de firma', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'Type' => 'Mecanismo de firma',
				'WhatId' => caso.Id,
				'OwnerId' => ownerId,			
				'WhoId' => caso.ContactId,
				'Description' => 'Tarea mecanismo de firma',
				'AV_Case__c' => caso.Id
			};		
			
			tarea = getActividad(tarea,fields);	
			insert tarea;
		}
	}

	@AuraEnabled
	public static void crearActividadIdentificadorBloqueado(Id recordId){
		Case caso = [SELECT id, OwnerId, CC_Detalles_Consulta__c
			FROM Case 
			WHERE Id = :recordId 
			LIMIT 1];

		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Identificador bloqueado' LIMIT 1];
		if (tareaExistente.isEmpty()) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'Identificador bloqueado', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'WhatId' => caso.Id,
				'OwnerId' => caso.OwnerId,			
				'Type' => 'Identificador bloqueado',
				'Description' => 'Identificador bloqueado',
				'AV_Case__c' => caso.Id
			};		
			tarea = getActividad(tarea,fields);	
			insert tarea;
		}
	}
	//Mecanismo firma

	//Oficina sin tarea
	@AuraEnabled
	public static void crearActividadOficinaSinTarea(Id recordId){
		Case caso = [SELECT id, OwnerId, ContactId
			FROM Case 
			WHERE Id = :recordId 
			LIMIT 1];
		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Subject = 'Oficina sin tarea' LIMIT 1];
		if (tareaExistente.isEmpty()) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'Oficina sin tarea', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'WhatId' => caso.Id,
				'OwnerId' => caso.OwnerId,			
				'WhoId' => caso.ContactId,
				'Type' => 'Oficina sin tarea',
				'Description' => 'Oficina sin tarea',
				'AV_Case__c' => caso.Id
			};		
			tarea = getActividad(tarea,fields);	
			insert tarea;
		}
	}
	//Oficina sin tarea
	

	//Comunidades de propietarios
	@AuraEnabled
	public static void crearActividadComunidadesPropietarios(Id recordId, String detallesConsulta, String mensaje){
		Case caso = [SELECT id, OwnerId, CC_Detalles_Consulta__c
			FROM Case 
			WHERE Id = :recordId 
			LIMIT 1];
		if(!detallesConsulta.contains(mensaje)){
			caso.CC_Detalles_Consulta__c = caso.CC_Detalles_Consulta__c + '. '+ mensaje;
            update caso;
		}
		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Comunidades de propietarios' LIMIT 1];
		if (tareaExistente.isEmpty()) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'Comunidades de propietarios', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'WhatId' => caso.Id,
				'OwnerId' => caso.OwnerId,			
				'Type' => 'Comunidades de propietarios',
				'Description' => 'Comunidades de propietarios',
				'AV_Case__c' => caso.Id
			};		
			tarea = getActividad(tarea,fields);	
			insert tarea;
		}
	}

	//Comunidades de propietarios
	public static void crearActividadCobrowsing(List<String> casos){

		List<Task> tareas = new List<Task>();
		String urlUnblu  = CC_Settings__c.getValues('CC_Url_Unblu').CC_Configuracion_1__c;
		List<Case> casosCrearTarea = [SELECT id, OwnerId,Origin, unblusuite__Conversation_Id__c
		FROM Case 
		WHERE Id IN :casos];
		
		if (!casosCrearTarea.isEmpty()) {
			// Crear un mapa para acceder fácilmente a los casos por ID
			Map<Id, Case> casosMap = new Map<Id, Case>(casosCrearTarea);
			
			for(Case caso : casosCrearTarea){
				Task tarea = new Task();
				Map<String, Object> fields = new Map<String, Object>{
					'Subject' => 'Inicio sesión cobrowsing', 
					'Status' => 'Completed',
					'Priority' => 'Normal',
					'AV_OrigenAct__c' => 'Contact Center',
					'WhatId' => caso.Id,
					'OwnerId' => caso.OwnerId,			
					'Type' => 'Cobrowsing',
					'AV_Case__c' => caso.Id
				};

	
				tarea = getActividad(tarea,fields);	
				tareas.add(tarea);
			}

			if(!tareas.isEmpty()){
				insert tareas;
				List<CBK_Activity_Extension__c> extensiones = new List<CBK_Activity_Extension__c>();
				for(Task tarea : tareas){
					CBK_Activity_Extension__c extension = new CBK_Activity_Extension__c();
					extension.AV_ActivityId__c = tarea.Id;
					
					// SI es de tipo Chat obtiene el identificador de objeto LiveChatTranscript
					if(casosMap.get(tarea.WhatId).Origin == 'Chat'){
						if(tarea.WhatId != null && casosMap.containsKey(tarea.WhatId)){
							List<LiveChatTranscript> liveChats = [SELECT Id, unblusuite__Conversation_Id__c FROM LiveChatTranscript WHERE CaseId = :tarea.WhatId and unblusuite__Conversation_Id__c != null];
							if(!liveChats.isEmpty()){
								extension.CC_Grabacion_Unblu__c = urlUnblu + liveChats[0].unblusuite__Conversation_Id__c;
							}
						}
					}else{ // Si no es de tipo Chat obtiene el identificador de objeto Case
					if(tarea.WhatId != null && casosMap.containsKey(tarea.WhatId)){
						Case casoRelacionado = casosMap.get(tarea.WhatId);
						if(casoRelacionado.unblusuite__Conversation_Id__c != null){
							extension.CC_Grabacion_Unblu__c = urlUnblu + casoRelacionado.unblusuite__Conversation_Id__c;
						}
					}
					}
					
					extensiones.add(extension);
				}
				if(!extensiones.isEmpty()){
					insert extensiones;
				}
			}
		}
	}

	public static void crearActividadCobrowsing(List<Case> casos){
		List<Task> tareas = new List<Task>();
		String urlUnblu  = CC_Settings__c.getValues('CC_Url_Unblu').CC_Configuracion_1__c;
		if (!casos.isEmpty()) {
			// Crear un mapa para acceder fácilmente a los casos por ID
			Map<Id, Case> casosMap = new Map<Id, Case>(casos);
			
			for(Case caso : casos){
				Task tarea = new Task();
				Map<String, Object> fields = new Map<String, Object>{
					'Subject' => 'Inicio sesión cobrowsing', 
					'Status' => 'Completed',
					'Priority' => 'Normal',
					'AV_OrigenAct__c' => 'Contact Center',
					'WhatId' => caso.Id,
					'OwnerId' => caso.OwnerId,			
					'Type' => 'Cobrowsing',
					'AV_Case__c' => caso.Id
				};

	
				tarea = getActividad(tarea,fields);	
				tareas.add(tarea);
			}

			if(!tareas.isEmpty()){
				insert tareas;
				List<CBK_Activity_Extension__c> extensiones = new List<CBK_Activity_Extension__c>();
				for(Task tarea : tareas){
					CBK_Activity_Extension__c extension = new CBK_Activity_Extension__c();
					extension.AV_ActivityId__c = tarea.Id;
					
					// Si es de tipo Chat obtiene el identificador de objeto LiveChatTranscript
					if(casosMap.get(tarea.WhatId).Origin == 'Chat'){
						if(tarea.WhatId != null && casosMap.containsKey(tarea.WhatId)){
							List<LiveChatTranscript> liveChats = [SELECT Id, unblusuite__Conversation_Id__c FROM LiveChatTranscript WHERE CaseId = :tarea.WhatId and unblusuite__Conversation_Id__c != null];
							if(!liveChats.isEmpty()){
								extension.CC_Grabacion_Unblu__c = urlUnblu + liveChats[0].unblusuite__Conversation_Id__c;
							}
						}
					}else{ // Si no es de tipo Chat obtiene el identificador de objeto Case
					if(tarea.WhatId != null && casosMap.containsKey(tarea.WhatId)){
						Case casoRelacionado = casosMap.get(tarea.WhatId);
						if(casoRelacionado.unblusuite__Conversation_Id__c != null){
							extension.CC_Grabacion_Unblu__c = urlUnblu + casoRelacionado.unblusuite__Conversation_Id__c;
						}
					}
					}
					
					extensiones.add(extension);
				}
				if(!extensiones.isEmpty()){
					insert extensiones;
				}
			}
		}
	}

	@AuraEnabled
	public static void crearActividadGestionCitas(Id recordId) {
		Case caso = [SELECT OwnerId FROM Case WHERE Id = :recordId LIMIT 1];
		List<Task> tareas = new List<Task>();
		
		if (caso != null) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'Gestión de citas', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'WhatId' => caso.Id,
				'OwnerId' => caso.OwnerId,			
				'Type' => 'Gestión de citas',
				'AV_Case__c' => caso.Id
			};
			tarea = getActividad(tarea,fields);	
			tareas.add(tarea);
		}
		if(!tareas.isEmpty()){
			insert tareas;
		}
	}
	

	//Llamada transferida
	/*
	@AuraEnabled
	public static void crearActividadTransferirLLamadaFraude(Id recordId){
		Case caso = [SELECT id, OwnerId, ContactId
			FROM Case 
			WHERE Id = :recordId 
			LIMIT 1];
		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Subject = 'Llamada transferida online a Fraude' LIMIT 1];
		if (tareaExistente.isEmpty()) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'Llamada transferida online a Fraude', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'WhatId' => caso.Id,
				'OwnerId' => caso.OwnerId,			
				'WhoId' => caso.ContactId,
				'Type' => 'Llamada transferida online a Fraude',
				'Description' => 'Llamada transferida online a Fraude',
				'AV_Case__c' => caso.Id
			};		
			tarea = getActividad(tarea,fields);	
			insert tarea;
		}
	}

	@AuraEnabled
	public static void crearActividadTransferirLLamadaICP(Id recordId){
		Case caso = [SELECT id, OwnerId, ContactId
			FROM Case 
			WHERE Id = :recordId 
			LIMIT 1];
		List<Task> tareaExistente = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Subject = 'Llamada transferida online a ICP' LIMIT 1];
		if (tareaExistente.isEmpty()) {
			Task tarea = new Task();
			Map<String, Object> fields = new Map<String, Object>{
				'Subject' => 'Llamada transferida online a ICP', 
				'Status' => 'Completed',
				'Priority' => 'Normal',
				'AV_OrigenAct__c' => 'Contact Center',
				'WhatId' => caso.Id,
				'OwnerId' => caso.OwnerId,			
				'WhoId' => caso.ContactId,
				'Type' => 'Llamada transferida online a ICP',
				'Description' => 'Llamada transferida online a ICP',
				'AV_Case__c' => caso.Id
			};		
			tarea = getActividad(tarea,fields);	
			insert tarea;
		}
	}
	*/
	//Llamada transferida
}