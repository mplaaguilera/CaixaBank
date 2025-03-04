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
			return tarea;
		}
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

}