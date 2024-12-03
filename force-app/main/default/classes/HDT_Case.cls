public with sharing class HDT_Case {

    public static Case crearCaso(String recordTypeDeveloperName) {
        return crearCaso(recordTypeDeveloperName, new Map<String, Object>());
    }

    public static Case crearCaso(String recordTypeDeveloperName, Map<String, Object> campos) {
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', recordTypeDeveloperName);
        for (String campo : campos.keySet()) {
            caso.put(campo, campos.get(campo));
        }
        insert caso;
        return caso;
    }

    public static Case reapertura(Id idCaso, String descripcionTarea, Boolean cambiarPropietario, Boolean sinUpdate) {

        //Reapertura caso por respuesta (el estado pasa a Activo y se registra el motivo de reapertura en una nueva actividad)
        Case caso = [SELECT ContactId,Status,CC_Canal_Procedencia__c,IsClosed,ClosedDate FROM Case WHERE Id = :idCaso WITH SECURITY_ENFORCED];

        if (caso.Status != 'Activo') {
			
            Task tareaReactivacion = new Task();
            tareaReactivacion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
            tareaReactivacion.WhatId = idCaso;
            tareaReactivacion.Status = 'Completed';
            tareaReactivacion.Type = 'Reactivación';
            tareaReactivacion.Subject = 'Reactivación';
            tareaReactivacion.Description = descripcionTarea;
            tareaReactivacion.ActivityDate = System.today();
            tareaReactivacion.CC_Fecha_Inicio__c = System.now();
            insert tareaReactivacion;

            caso.Status = 'Activo';
            caso.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
            if (cambiarPropietario) {
                caso.OwnerId = UserInfo.getUserId();
            }

            if (!sinUpdate) {
                update caso;
            }
        }
        return caso;
    }

	/*
    private with sharing class CasosOrigen {
		List<CasoOrigen> lista {get;set;}

		public CasosOrigen(List<Case> casos) {
			this.lista = new List<CasoOrigen>();
			for (Case caso : casos) {
				this.lista.add(new CasoOrigen(caso));
			}
			this.calcularOrigenesIniciales();
		}

		public Id obtenerCaso(Id idContact, Id idTematica) {
			Id retorno = null;
			for (CasoOrigen casoOrigen : this.lista) {
				if (casoOrigen.idContact == idContact && casoOrigen.idTematica == idTematica) {
					retorno = casoOrigen.id;
					break;
				}
			}
			return retorno;
		}

		private List<Id> idCasosNoIniciales() {
			List<Id> retorno = new List<Id>();
			for (CasoOrigen casoOrigen : this.lista) {
				if (!casoOrigen.origenInicial) {
					retorno.add(casoOrigen.id);
				}
			}
			return retorno;
		}

		private void actualizarCaso(Id idContact, Id idTematica, Case caso) {
			for (CasoOrigen casoOrigen : this.lista) {
				if (casoOrigen.idContact == idContact && casoOrigen.idTematica == idTematica) {
					casoOrigen.id = String.isBlank(caso.CC_Caso_Origen__c) ? caso.Id : caso.CC_Caso_Origen__c;
					casoOrigen.origenInicial = String.isBlank(caso.CC_Caso_Origen__c);
				}
			}
		}

		private void calcularOrigenesIniciales() {
			List<Id> casosNoInicialesIds = new List<Id>(this.idCasosNoIniciales());
			if (!casosNoInicialesIds.isEmpty()) {
				List<Case> casos = [SELECT ContactId, CC_MCC_Tematica__c, CC_Caso_Origen__c
									FROM Case WHERE Id IN :casosNoInicialesIds];
				for (Case caso : casos) {
					this.actualizarCaso(caso.ContactId, caso.CC_MCC_Tematica__c, caso);
				}
			}
		}

		/* Original sin QC
		private void calcularOrigenesIniciales() {
			while (!this.idCasosNoIniciales().isEmpty()) {
				for (Case caso : [SELECT ContactId, CC_MCC_Tematica__c, CC_Caso_Origen__c
									FROM Case WHERE Id IN :this.idCasosNoIniciales()]) {
					this.actualizarCaso(caso.ContactId, caso.CC_MCC_Tematica__c, caso);
				}
			}
		}*/

		/* Comentado por Moises Cano
		private void calcularOrigenesIniciales() {
			List<Case> casos = new List<Case>();
			String query = [SELECT ContactId, CC_MCC_Tematica__c, CC_Caso_Origen__c FROM Case WHERE Id IN :this.idCasosNoIniciales()];
			while (!this.idCasosNoIniciales().isEmpty()) {
				List<Case> casosQuery = Database.query(query);
				casos.addAll(casosQuery);
				for (Case caso : casosQuery) {
					this.actualizarCaso(caso.ContactId, caso.CC_MCC_Tematica__c, caso);
				}
				casosQuery.clear();
			}
		}*/

	
		
		/*
		private void calcularOrigenesIniciales() {
			while (!this.idCasosNoIniciales().isEmpty()) {
				for (Case caso : [SELECT ContactId, CC_MCC_Tematica__c, CC_Caso_Origen__c
									FROM Case WHERE Id IN :this.idCasosNoIniciales()]) {
					this.actualizarCaso(caso.ContactId, caso.CC_MCC_Tematica__c, caso);
				}
			}
		}
	}*/

	/*
    private class CasoOrigen {
		Id id {get;set;}
		Boolean origenInicial {get;set;}
		Id idContact {get;set;}
		Id idTematica {get;set;}

		public CasoOrigen(Case caso) {
			this.origenInicial = String.isBlank(caso.CC_Caso_Origen__c);
			this.id = this.origenInicial ? caso.Id : caso.CC_Caso_Origen__c;
			this.idContact = caso.ContactId;
			this.idTematica = caso.CC_MCC_Tematica__c;
		}
	}*/

	/*
	@future
  	public static void vincularCasoOrigen(List<Id> idCasos) {
    //vincularCasoOrigenAux(idCasos);
    	System.enqueueJob(new JobToAvoidErrors(idCasos));
  	}

	public class JobToAvoidErrors implements Queueable {
		private List<Id> records;
		public JobToAvoidErrors(List<Id> records) {
			this.records = records;
		}
		public void execute(QueueableContext context) {
			// Realiza la actualización en los registros
			HDT_Case.vincularCasoOrigenAux(records);
		}
	}


  @TestVisible
  public static void vincularCasoOrigenAux(List<Id> idCasos) {
      List<Case> casos = [SELECT ContactId, CC_MCC_Tematica__c FROM Case WHERE Id IN :idCasos ];
    CasosOrigen posiblesCasosOrigen = new CasosOrigen([SELECT ContactId, CC_MCC_Tematica__c, CC_Caso_Origen__c
                              FROM Case WHERE IsClosed = FALSE AND RecordType.DeveloperName = 'HDT_Empleado'
                              AND ContactId IN :CC_MetodosUtiles.listaCampo(casos, 'ContactId')
                              AND CC_MCC_Tematica__c IN :CC_MetodosUtiles.listaCampo(casos, 'CC_MCC_Tematica__c')
                              AND Id NOT IN :CC_MetodosUtiles.listaCampo(casos, 'Id') ORDER BY CreatedDate ASC]);
    for (Case caso : casos) {
      caso.CC_Caso_Origen__c = posiblesCasosOrigen.obtenerCaso(caso.ContactId, caso.CC_MCC_Tematica__c);
    }
   		 update casos;
  	}
	*/
	/*
    @future
	public static void vincularCasoOrigen(List<Id> idCasos) {
		vincularCasoOrigenAux(idCasos);
	}

	@TestVisible
	private static void vincularCasoOrigenAux(List<Id> idCasos) {
	  	List<Case> casos = [SELECT ContactId, CC_MCC_Tematica__c FROM Case WHERE Id IN :idCasos ];
		CasosOrigen posiblesCasosOrigen = new CasosOrigen([SELECT ContactId, CC_MCC_Tematica__c, CC_Caso_Origen__c
															FROM Case WHERE IsClosed = FALSE AND RecordType.DeveloperName = 'HDT_Empleado'
															AND ContactId IN :CC_MetodosUtiles.listaCampo(casos, 'ContactId')
															AND CC_MCC_Tematica__c IN :CC_MetodosUtiles.listaCampo(casos, 'CC_MCC_Tematica__c')
															AND Id NOT IN :CC_MetodosUtiles.listaCampo(casos, 'Id') ORDER BY CreatedDate ASC]);
		for (Case caso : casos) {
			caso.CC_Caso_Origen__c = posiblesCasosOrigen.obtenerCaso(caso.ContactId, caso.CC_MCC_Tematica__c);
		}
		update casos;
	}*/

    public static Case reapertura(Id idCaso, String descripcionTarea) {
        return reapertura(idCaso, descripcionTarea, true, false);
    }

	private static String formatearFecha(Datetime fecha) {
		List<String> diasEN = new List<String>{'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
		List<String> diasES = new List<String>{'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'};

		List<String> mesesEN = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
		List<String> mesesES = new List<String>{'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};

		String retorno = diasES.get(diasEN.indexOf(fecha.format('EEE'))) + ', ' + fecha.day() + ' de ';
		retorno += mesesES.get(mesesEN.indexOf(fecha.format('MMM'))) + ' de ' + fecha.year() + ' ' + fecha.format('HH:mm');

		return retorno;
	}

	public static String historicoCorreosClienteCops(Id idCaso, Boolean incluirInternos) {
        String resultado = '';
        List<EmailMessage> correos = new List<EmailMessage>();
		//Aplicamos un LIMIT 8 para evitar una sobrecarga de datos a la hora de extraer todos los correos del caso
        if (incluirInternos) {
            correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
			  	WHERE ParentId = :idCaso WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 8];
        } else {
            correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
			  WHERE ParentId = :idCaso AND CC_Interno__c = false WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 8];
        }

        for (Integer i = 0; i < correos.size(); i++) {
            EmailMessage correo = correos[i];
            if (correo.HtmlBody != '' && correo.HtmlBody != null) {
                resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
                resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
                resultado += 'Para: ' + correo.ToAddress + '<br/>';
				if (correo.CcAddress != null) {
					resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
				}
                resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + correo.HtmlBody;
                if (i < correos.size() - 1) {
                    //Si no es el último correo incluye un separador
                    resultado += '<br/>__________<br/><br/>';
                }
            } else if (correo.TextBody != '' && correo.TextBody != null) {
                String nuevoTextoPlano = '';
                for (String s : correo.TextBody.split('\\n')) {
                    nuevoTextoPlano += s + '<br/>';
                }
                resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
                resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
                resultado += 'Para: ' + correo.ToAddress + '<br/>';
				if (correo.CcAddress != null) {
					resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
				}
                resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + nuevoTextoPlano;
                if (i < correos.size() - 1) {
                    //Si no es el último correo incluye un separador
                    resultado += '<br/>__________<br/><br/>';
                }
            }
		}
        if (resultado.length() >= 131072) {
            resultado = resultado.substring(0, 131072);
        }
		return resultado;
	}

	public static Id crearActividadRetipificacion(Id idCaso, String tematicaAnterior, String productoAnterior, String motivoAnterior) {
		Case caso = [SELECT CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso  WITH SECURITY_ENFORCED LIMIT 1];

	  if (motivoAnterior != null && motivoAnterior != '') {
		  //Crear actividad
		  String cuerpo = 'Se ha retipificado el caso.\n\n';
		  cuerpo += 'Clasificación anterior:\n· Temática: '+ tematicaAnterior + '\n· Producto/Servicio: '+ productoAnterior + '\n· Motivo: '+ motivoAnterior + '\n\n';
		  cuerpo += 'Clasificación nueva:\n· Temática: '+ caso.CC_MCC_Tematica__r.Name + '\n· Producto/Servicio: '+ caso.CC_MCC_ProdServ__r.Name + '\n· Motivo: '+ caso.CC_MCC_Motivo__r.Name + '\n';

		  Task task = new Task();
		  task.WhatId = idCaso;
		  task.Status = 'Completed';
		  task.ActivityDate = System.today();
		  task.Subject = 'Reclasificación del caso';
		  task.Type = 'Reclasificación';
		  task.Description = cuerpo;
		  //insert task;

	Task returnTask = HDT_Activity.crearActividad(task);
		  return returnTask.Id;
	  } else {
		  return null;
	  }
  }

	public static Case getDatosCaso(Id caseId) {
		return [SELECT Contact.Name, Subject, CC_Idioma__c, CC_Detalles_Consulta__c, CC_Tipo_Contacto__c, Status FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
  }


	public static String correoInicialCliente(Id idCaso) {
		String resultado = '';
		List<EmailMessage> correos = new List<EmailMessage>();
		correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody FROM EmailMessage
				WHERE ParentId = :idCaso AND Incoming = true AND CC_Interno__c = false AND CC_Procedencia__c = NULL  WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 1];

		if (!correos.isEmpty() && correos[0].HtmlBody != '' && correos[0].HtmlBody != null) {
			resultado += '<font color="gray">';
			resultado += 'De: ' + correos[0].FromAddress + '<br/>';
			resultado += 'Enviado el: ' + formatearFecha(correos[0].MessageDate) + '<br/>';
			resultado += 'Para: ' + correos[0].ToAddress + '<br/>' + 'Con copia a:' + correos[0].CcAddress + '<br/>';
			resultado += 'Asunto: ' + correos[0].Subject + '</font><br/><br/>' + correos[0].HtmlBody;
		}
		return resultado;
	}


	public static String historicoCorreosCliente(Id idCaso, Boolean incluirInternos) {
		String resultado = '';
		List<EmailMessage> correos = new List<EmailMessage>();
		if (incluirInternos) {
			correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
						WHERE ParentId = :idCaso ORDER BY CreatedDate DESC LIMIT 1];
		} else {
			correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
						WHERE ParentId = :idCaso AND CC_Interno__c = false ORDER BY CreatedDate DESC LIMIT 1];
		}

		for (Integer i = 0; i < correos.size(); i++) {
			EmailMessage correo = correos[i];
			if (correo.HtmlBody != '' && correo.HtmlBody != null) {
				resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
				resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
				resultado += 'Para: ' + correo.ToAddress + '<br/>';
				if (correo.CcAddress != null) {
					resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
				}
				resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + correo.HtmlBody;
				if (i < correos.size() - 1) {
					//Si no es el último correo incluye un separador
					resultado += '<br/>__________<br/><br/>';
				}
			} else if (correo.TextBody != '' && correo.TextBody != null) {
				String nuevoTextoPlano = '';
				for (String s : correo.TextBody.split('\\n')) {
					nuevoTextoPlano += s + '<br/>';
				}
				resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
				resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
				resultado += 'Para: ' + correo.ToAddress + '<br/>';
				if (correo.CcAddress != null) {
					resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
				}
				resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + nuevoTextoPlano;
				if (i < correos.size() - 1) {
					//Si no es el último correo incluye un separador
					resultado += '<br/>__________<br/><br/>';
				}
			}
		}

        return resultado;
    }



}