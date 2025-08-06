public with sharing class CC_Case {

	public static Case reapertura(Id idCaso, String descripcionActividad) {
		//Reapertura caso (el estado pasa a Activo y se registra el motivo de reapertura en una nueva actividad)

	  	Case caso = [SELECT Status FROM Case WHERE Id = :idCaso ];
		if (caso.Status != 'Activo') {
			caso.Status = 'Activo';
			caso.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
			caso.CC_Tramo_TRZ__c = 'Resuelta - En redaccion';
            if(Schema.sObjectType.Case.fields.Status.isUpdateable()){
                update caso;
            }
	
			Task actividad = new Task();
			actividad.WhatId = idCaso;
			actividad.Type = 'Reapertura';
			actividad.Subject = 'Reapertura por respuesta a solicitud de información';
			actividad.Status = 'Open';
			actividad.ActivityDate = System.today();
			actividad.IsReminderSet = true;
			actividad.ReminderDateTime = Datetime.valueOf(System.now()).addMinutes(5);
			actividad.Description = descripcionActividad;
			//insert actividad;
			CC_Activity.crearActividad(actividad);

			//Trazabilidad en reapertura
			CC_Trazabilidad_Methods.reapretura('Resolucion', caso.Id);
			CC_Trazabilidad_Methods.reapretura('Asignacion', caso.Id);
		}
		return caso;
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

    public static String historicoCorreosClienteCops(Id idCaso, Boolean incluirInternos) {
        String resultado = '';
        List<EmailMessage> correos = new List<EmailMessage>();
		//Aplicamos un LIMIT 8 para evitar una sobrecarga de datos a la hora de extraer todos los correos del caso
        if (incluirInternos) {
            correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
			  	WHERE ParentId = :idCaso  ORDER BY CreatedDate DESC LIMIT 8];
        } else {
            correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
			  WHERE ParentId = :idCaso AND CC_Interno__c = false  ORDER BY CreatedDate DESC LIMIT 8];
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

	public static String correoInicialCliente(Id idCaso) {
		String resultado = '';
		List<EmailMessage> correos = new List<EmailMessage>();
		correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody FROM EmailMessage
				WHERE ParentId = :idCaso AND Incoming = true AND CC_Interno__c = false AND CC_Procedencia__c = NULL   ORDER BY CreatedDate ASC LIMIT 1];

		if (!correos.isEmpty() && correos[0].HtmlBody != '' && correos[0].HtmlBody != null) {
			resultado += '<font color="gray">';
			resultado += 'De: ' + correos[0].FromAddress + '<br/>';
			resultado += 'Enviado el: ' + formatearFecha(correos[0].MessageDate) + '<br/>';
			resultado += 'Para: ' + correos[0].ToAddress + '<br/>' + 'Con copia a:' + correos[0].CcAddress + '<br/>';
			resultado += 'Asunto: ' + correos[0].Subject + '</font><br/><br/>' + correos[0].HtmlBody;
		}
		return resultado;
	}

	public static Id crearActividadRetipificacion(Id idCaso, String tematicaAnterior, String productoAnterior, String motivoAnterior) {
	  	Case caso = [SELECT CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso LIMIT 1];

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

	  Task returnTask = CC_Activity.crearActividad(task);
			return returnTask.Id;
		} else {
			return null;
		}
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

	@InvocableMethod(label='CC_Case CambioPropietario' description='Modificar el propietario de las actividades abiertas')
	public static void actualizarPropietarioTareas(List<Id> oCasos) {
	  List<Task> listaTareas = new List<Task>();
	  List<Task> listaTareasUpd = new List<Task>();
	  Set<Id> setIdsCasos = new Set<Id>();
	  Map<Id, Id> mapCaseOwner = new Map<Id, Id>();
  
	  for (Task tarea : [SELECT WhatId, IsClosed FROM Task WHERE WhatId IN :oCasos AND IsClosed = FALSE ]) {
		if(tarea.WhatId != null && !setIdsCasos.contains(tarea.WhatId)){
		  listaTareas.add(tarea);
		  setIdsCasos.add(tarea.WhatId);
		}
	  }
  
	  if(!setIdsCasos.isEmpty()){
		
		List<Case> lstCasos = [SELECT Id, OwnerId FROM Case WHERE Id IN :setIdsCasos AND RecordType.Developername IN ('CC_Cliente','CC_Empleado') ];
		for (Case caso : lstCasos) {
		  mapCaseOwner.put(caso.Id, caso.OwnerId);
		}
	  }
	  for (Task tarea : listaTareas) {
		if(mapCaseOwner.containsKey(tarea.WhatId)){
		  tarea.OwnerId = mapCaseOwner.get(tarea.WhatId);
		  listaTareasUpd.add(tarea);
		}
	  }
	if (!listaTareasUpd.isEmpty() && Schema.sObjectType.Task.fields.OwnerId.isUpdateable()) {
		Database.update(listaTareasUpd);
	  }
	}

	public static Case getDatosCaso(Id caseId) {
    return [SELECT Contact.Name, Subject, CC_Idioma__c, CC_Detalles_Consulta__c, CC_Tipo_Contacto__c, Status,Origin FROM Case WHERE Id = :caseId AND RecordType.Developername IN ('CC_Cliente','CC_Empleado')];
  }

	//Método future para asignar el catálogo de facturación del CC al caso cerrado
  /*@future
  public static void creacionRelacionCatalogoFacturacionCaso (List<Id> caseFacturarIdList, List<Id> caseRefacturarIdList)
  {
    //Obtenemos una lista única con todos los ids de casos para obtener la información
    Set<Id> caseFacturarTotalList = new Set<Id>();
    List<String> gruposRefacturarList = new List<String>();

    if (!caseFacturarIdList.isEmpty())
    {
      caseFacturarTotalList.addAll(caseFacturarIdList);
    }

    if (!caseRefacturarIdList.isEmpty())
    {
      caseFacturarTotalList.addAll(caseRefacturarIdList);
    }

    if (!caseFacturarTotalList.isEmpty())
    {
      List<Case> casosActualizarList = new List<Case>();
      Map<Id,Case> casosActualizarMap = new Map<Id,Case>();
      List<CC_Facturacion_Caso__c> facturacionCasoCreateList = new List<CC_Facturacion_Caso__c>();
      List<CC_Facturacion_Caso__c> facturacionCasoUpdateList = new List<CC_Facturacion_Caso__c>();
      List<CC_Facturacion_Caso__c> facturacionCasoDeleteList = new List<CC_Facturacion_Caso__c>();
      Set<String> canalEntradaList = new Set<String>();
      Set<String> canalOperativoList = new Set<String>();

      //Obtenemos la información de los casos necesaria para asignar el catálogo correspondiente
      List<Case> casosFacturarList = [SELECT Id, Origin, CC_Canal_Operativo__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c,
                        CC_No_Facturable__c, CC_Facturado__c, CC_Grupo_Resolutor__c, CC_En_Tercer_Nivel__c, CC_GruposResolutores__c
                      FROM Case WHERE Id IN :caseFacturarTotalList AND CC_Grupo_Resolutor__c <> Null];

      if (!casosFacturarList.isEmpty())
      {
        for (Case casoFacturar : casosFacturarList)
        {
          canalEntradaList.add(casoFacturar.Origin);
          canalOperativoList.add(casoFacturar.CC_Canal_Operativo__c);
        }

        //Obtenemos todos los catálogos de facturación activos y que cumplan las condiciones de canalEntrada y canalOperativo
        List<CBK_CatalogoFacturacion__c> catalogoFacturacionList = [SELECT Id, CC_Margen__c, CC_Canal_de_Entrada__c, CC_Canal_Operativo__c,
                                        CC_Fecha_Fin_Vigencia__c, CC_Fecha_Inicio_Vigencia__c, CC_Grupo_Facturacion__c,
                                        CC_Precio_Unitario__c, CC_Producto__c, CC_Tematica__c
                                      FROM CBK_CatalogoFacturacion__c WHERE CC_Activo__c = true
                                      AND CC_Negocio__c = 'CC'
                                      AND CC_Canal_de_Entrada__c IN :canalEntradaList
                                      AND CC_Canal_Operativo__c IN :canalOperativoList];

        //Obtenemos todos los registros de facturacionCaso que estén asignados al caso para su posterior revisión
        List<CC_Facturacion_Caso__c> facturacionCasoGetUpdateList = [SELECT Id, CC_Caso__c, CC_Proveedor__c, CC_Catalogo_Facturacion__c , CC_Catalogo_Facturacion__r.CC_Grupo_Facturacion__c
                                      FROM CC_Facturacion_Caso__c WHERE CC_Caso__c IN :caseFacturarTotalList];

        if (!facturacionCasoGetUpdateList.isEmpty())
        {
          //Inicialmente, guardamos en una lista todos los registros de facturacionCaso que ya existen para eliminarlos
          //conforme se vayan metiendo en la lista de actualizar, los iremos sacando de la lista de eliminar
          facturacionCasoDeleteList.addAll(facturacionCasoGetUpdateList);
        }

        if (!catalogoFacturacionList.isEmpty() || !facturacionCasoGetUpdateList.isEmpty())
        {
          for (Case casoFacturar : casosFacturarList)
          {
            Set<String> gruposFacturacionList = new Set<String>();
            //Obtenemos todos los gruposResolutores del caso y los pasamos a una lista
            if (String.isNotBlank(casoFacturar.CC_GruposResolutores__c))
            {
              gruposRefacturarList = casoFacturar.CC_GruposResolutores__c.split(';');
            }

            if (!catalogoFacturacionList.isEmpty())
            {
              for (CBK_CatalogoFacturacion__c catalogoInfo : catalogoFacturacionList)
              {
                //Para comprobar que no existe de antes la relación
                Boolean relacionExistente = false;
                Boolean relacionACrear = false;
                //Creamos nuevos registros de CC_Facturacion_Caso__c si es nuevo proveedor
                if (!caseFacturarIdList.isEmpty() && caseFacturarIdList.contains(casoFacturar.Id))
                {
                  if (casoFacturar.Origin == catalogoInfo.CC_Canal_de_Entrada__c && casoFacturar.CC_Canal_Operativo__c == catalogoInfo.CC_Canal_Operativo__c
                    && casoFacturar.CC_MCC_Tematica__c == catalogoInfo.CC_Tematica__c && casoFacturar.CC_MCC_ProdServ__c == catalogoInfo.CC_Producto__c
                    && (casoFacturar.CC_Grupo_Resolutor__c != null && casoFacturar.CC_Grupo_Resolutor__c == catalogoInfo.CC_Grupo_Facturacion__c))
                  {
                    relacionACrear = true;
                    //Comprobamos que no exista de antes la facturación
                    if (!facturacionCasoGetUpdateList.isEmpty())
                    {
                      for(CC_Facturacion_Caso__c facturacionCaso :facturacionCasoGetUpdateList)
                      {
                        if (facturacionCaso.CC_Caso__c == casoFacturar.Id && facturacionCaso.CC_Catalogo_Facturacion__c == catalogoInfo.Id)
                        {
                          //Si existe de antes, no volvemos a generar el registro
                          relacionExistente = true;
                          //Quitamos de la lista a eliminar el registro que no se crea por existir la relación antes y que no se tiene que modificar
                          if (!facturacionCasoDeleteList.isEmpty() && facturacionCasoDeleteList.indexOf(facturacionCaso) > -1)
                          {
                            facturacionCasoDeleteList.remove(facturacionCasoDeleteList.indexOf(facturacionCaso));
                          }
                          //Quitamos de la lista de proveedores el registro que ya existe
                          if (!gruposRefacturarList.isEmpty() && gruposRefacturarList.indexOf(facturacionCaso.CC_Catalogo_Facturacion__r.CC_Grupo_Facturacion__c) > -1)
                          {
                            gruposRefacturarList.remove(gruposRefacturarList.indexOf(facturacionCaso.CC_Catalogo_Facturacion__r.CC_Grupo_Facturacion__c));
                          }
                        }
                      }
                    }
                  }
                  //Si no existe la relación, generamos un nuevo regitro relacionado
                  if (!relacionExistente && relacionACrear)
                  {
                    CC_Facturacion_Caso__c facturacionCasoCreate = new CC_Facturacion_Caso__c();
                    facturacionCasoCreate.CC_Caso__c = casoFacturar.Id;
                    facturacionCasoCreate.CC_Proveedor__c = catalogoInfo.CC_Grupo_Facturacion__c;
                    facturacionCasoCreate.CC_Catalogo_Facturacion__c = catalogoInfo.Id;
                    facturacionCasoCreateList.add(facturacionCasoCreate);

                    //Quitamos de la lista de proveedores el registro que se va va a crear
                    if (!gruposRefacturarList.isEmpty() && gruposRefacturarList.indexOf(facturacionCasoCreate.CC_Proveedor__c) > -1)
                    {
                      gruposRefacturarList.remove(gruposRefacturarList.indexOf(facturacionCasoCreate.CC_Proveedor__c));
                    }
                  }
                }

                //Actualizamos los registros de CC_Facturacion_Caso__c si se ha cambiado la clasificación
                if (!facturacionCasoGetUpdateList.isEmpty() && !caseRefacturarIdList.isEmpty() && caseRefacturarIdList.contains(casoFacturar.Id))
                {
                  //Recuperamos los registros ya creados y hay que modificarlos o eliminarlos
                  for (CC_Facturacion_Caso__c facturacionInfo : facturacionCasoGetUpdateList)
                  {
                    if (casoFacturar.Origin == catalogoInfo.CC_Canal_de_Entrada__c && casoFacturar.CC_Canal_Operativo__c == catalogoInfo.CC_Canal_Operativo__c
                      && casoFacturar.CC_MCC_Tematica__c == catalogoInfo.CC_Tematica__c && casoFacturar.CC_MCC_ProdServ__c == catalogoInfo.CC_Producto__c
                      && catalogoInfo.CC_Grupo_Facturacion__c == facturacionInfo.CC_Catalogo_Facturacion__r.CC_Grupo_Facturacion__c)
                    {
                      CC_Facturacion_Caso__c facturacionCasoUpdate = new CC_Facturacion_Caso__c();
                      facturacionCasoUpdate.Id = facturacionInfo.Id;
                      facturacionCasoUpdate.CC_Caso__c = casoFacturar.Id;
                      facturacionCasoUpdate.CC_Proveedor__c = catalogoInfo.CC_Grupo_Facturacion__c;
                      facturacionCasoUpdate.CC_Catalogo_Facturacion__c = catalogoInfo.Id;
                      facturacionCasoUpdateList.add(facturacionCasoUpdate);

                      //Quitamos de la lista a eliminar el registro que se va a actualizar
                      if (!facturacionCasoDeleteList.isEmpty() && facturacionCasoDeleteList.indexOf(facturacionInfo) > -1)
                      {
                        facturacionCasoDeleteList.remove(facturacionCasoDeleteList.indexOf(facturacionInfo));
                      }

                      //Quitamos de la lista de proveedores el registro que se va a actualizar
                      if (!gruposRefacturarList.isEmpty() && gruposRefacturarList.indexOf(facturacionCasoUpdate.CC_Proveedor__c) > -1)
                      {
                        gruposRefacturarList.remove(gruposRefacturarList.indexOf(facturacionCasoUpdate.CC_Proveedor__c));
                      }
                    }
                  }
                }
              }
            }
          }

          //Proveedores que no cumplían anteriormente los requisitos, se revisa si ahora los cumplen
          if (!gruposRefacturarList.isEmpty())
          {
            for (Case casoReFacturar : casosFacturarList)
            {
              if (!catalogoFacturacionList.isEmpty())
              {
                for (CBK_CatalogoFacturacion__c catalogoReInfo : catalogoFacturacionList)
                {
                  //Si al modificarse la clasificación, no existían registros del proveedor, si ahora cumplen los requisitos, se deben crear
                  for (String grupoFacturar : gruposRefacturarList)
                  {
                    Boolean relacionExistente = false;
                    if (grupoFacturar.trim() == catalogoReInfo.CC_Grupo_Facturacion__c)
                    {
                      if (casoReFacturar.Origin == catalogoReInfo.CC_Canal_de_Entrada__c && casoReFacturar.CC_Canal_Operativo__c == catalogoReInfo.CC_Canal_Operativo__c
                        && casoReFacturar.CC_MCC_Tematica__c == catalogoReInfo.CC_Tematica__c && casoReFacturar.CC_MCC_ProdServ__c == catalogoReInfo.CC_Producto__c)
                      {
                        if (!facturacionCasoGetUpdateList.isEmpty())
                        {
                          for(CC_Facturacion_Caso__c reFacturacionCaso :facturacionCasoGetUpdateList)
                          {
                            if (reFacturacionCaso.CC_Caso__c == casoReFacturar.Id && reFacturacionCaso.CC_Catalogo_Facturacion__c == catalogoReInfo.Id)
                            {
                              //Si existe de antes, no volvemos a generar el registro
                              relacionExistente = true;
                              //Quitamos de la lista a eliminar el registro que no se crea por existir la relación antes y que no se tiene que modificar
                              if (!facturacionCasoDeleteList.isEmpty() && facturacionCasoDeleteList.indexOf(reFacturacionCaso) > -1)
                              {
                                facturacionCasoDeleteList.remove(facturacionCasoDeleteList.indexOf(reFacturacionCaso));
                              }
                            }
                          }
                        }
                        if (!relacionExistente)
                        {
                          CC_Facturacion_Caso__c facturacionCasoCreate = new CC_Facturacion_Caso__c();
                          facturacionCasoCreate.CC_Caso__c = casoReFacturar.Id;
                          facturacionCasoCreate.CC_Proveedor__c = catalogoReInfo.CC_Grupo_Facturacion__c;
                          facturacionCasoCreate.CC_Catalogo_Facturacion__c = catalogoReInfo.Id;
                          facturacionCasoCreateList.add(facturacionCasoCreate);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        //Creamos los nuevos registros relacionados
        if (!facturacionCasoCreateList.isEmpty())
        {
          insert facturacionCasoCreateList;
        }

        //Actualizamos los registros existentes previamente
        if (!facturacionCasoUpdateList.isEmpty())
        {
          update facturacionCasoUpdateList;
        }

        //Eliminamos los registros que ya no cumplen la facturación
        if (!facturacionCasoDeleteList.isEmpty())
        {
          delete facturacionCasoDeleteList;
        }
      }
    }
  }*/

/*
  public static List<Case> vincularCasoOrigen(List<Id> idCasos, Boolean sinUpdate) {
    List<Case> casos = [SELECT ContactId, CC_MCC_Tematica__c FROM Case WHERE Id IN :idCasos];
    List<Case> casosAbiertosClientes = [SELECT ContactId, CC_MCC_Tematica__c FROM Case WHERE IsClosed = FALSE
                      AND RecordType.DeveloperName IN ('CC_Cliente', 'CC_Empleado')
                      AND ContactId IN :CC_MetodosUtiles.listaCampo(casos, 'ContactId')
                      AND CC_MCC_Tematica__c IN :CC_MetodosUtiles.listaCampo(casos, 'CC_MCC_Tematica__c')
                      AND Id NOT IN :idCasos
                      ORDER BY CreatedDate ASC];
    
    Map<String, Id> mapaCasosAbiertosClientes = new Map<String, Id>();
    for (Case casoAbiertoCliente : casosAbiertosClientes) {
      mapaCasosAbiertosClientes.put(casoAbiertoCliente.ContactId + '|' + casoAbiertoCliente.CC_MCC_Tematica__c, casoAbiertoCliente.Id);
    }
    for (Case caso : casos) {
      String claveMapa = caso.ContactId + '|' + caso.CC_MCC_Tematica__c;
      if (mapaCasosAbiertosClientes.containsKey(claveMapa)) {
        caso.CC_Caso_Origen__c = mapaCasosAbiertosClientes.get(claveMapa);
      }
    }
    if (!sinUpdate) {
      update casos;
    }
    return casos;
  }
  */
	//@future
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
        CC_Case.vincularCasoOrigenAux(records);
    }
}

	@TestVisible
	private static void vincularCasoOrigenAux(List<Id> idCasos) {
	  	List<Case> casos = [SELECT ContactId, CC_MCC_Tematica__c FROM Case WHERE Id IN :idCasos];
		CasosOrigen posiblesCasosOrigen = new CasosOrigen([SELECT ContactId, CC_MCC_Tematica__c, CC_Caso_Origen__c
															FROM Case WHERE IsClosed = FALSE AND RecordType.DeveloperName = 'CC_Cliente'
															AND ContactId IN :CC_MetodosUtiles.listaCampo(casos, 'ContactId')
															AND CC_MCC_Tematica__c IN :CC_MetodosUtiles.listaCampo(casos, 'CC_MCC_Tematica__c')
                                                           AND Id NOT IN :CC_MetodosUtiles.listaCampo(casos, 'Id') ORDER BY CreatedDate ASC]);
        for (Case caso : casos) {
            Id casoOrigen = posiblesCasosOrigen.obtenerCaso(caso.ContactId, caso.CC_MCC_Tematica__c);
            caso.CC_Caso_Origen__c = caso.Id != casoOrigen ? casoOrigen : null;
        }
		update casos;
	}
	

	private class CasosOrigen {
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
            List<Case> casosLista = new List<Case>();
			if(!this.idCasosNoIniciales().isEmpty()) {
                casosLista = [SELECT ContactId, CC_MCC_Tematica__c, CC_Caso_Origen__c FROM Case WHERE Id IN :this.idCasosNoIniciales()];
				for (Case caso : casosLista) {
					this.actualizarCaso(caso.ContactId, caso.CC_MCC_Tematica__c, caso);
				}
			}
		}
	}

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
	}
}