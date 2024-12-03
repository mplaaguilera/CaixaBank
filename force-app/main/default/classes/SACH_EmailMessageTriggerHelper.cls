public with sharing class SACH_EmailMessageTriggerHelper {

    public static list<SObject> filterEmailsHandlers(CC_TriggerParameters tp, string handlerClass, String vEventType) {
		Map<String, String> mhandlerClassName = getMapAssociatedHandlers(handlerClass, vEventType);
		string vEmails = mhandlerClassName.get(handlerClass);

		set<string> sEmailsCheck = new set<string> ();
		List<String> lstEmails = new List<String> ();
		List<SObject> lstSO = new List<SObject> ();

		if (string.isNotBlank(vEmails) && vEmails.indexOf(';') >= 0) {
			lstEmails = vEmails.split(';');
		} else if (string.isNotBlank(vEmails)) {
			lstEmails.add(vEmails);
		}

		if (lstEmails != null && lstEmails.size() > 0) {
			for (string sEmails : lstEmails) {
				sEmailsCheck.add(sEmails);
			}
		}

		String vExpr = '(^.*@*.apex.sandbox.salesforce.com)';
		string vExpr2 = '(^.*@)';
		List<string> strToadd = new List<string> ();
		for (SObject so : tp.newList) {
			string vkey = string.valueOf(so.get('FromAddress'));
			Boolean vIncom = Boolean.valueOf(so.get('Incoming'));

			if (!vIncom && String.isNotBlank(vkey) && sEmailsCheck.contains(vkey)) {
				lstSO.add(so);
			} else if (vIncom) {
				vkey = string.valueOf(so.get('ToAddress'));
				if (String.isNotBlank(vkey) && vkey.indexOf(';') >= 0)
				{
					strToadd = vkey.split(';');
					for (string str : strToadd)
					{
						if (sEmailsCheck.contains(str)) {
							lstSO.add(so);
						}
					}
				} else if (String.isNotBlank(vkey)){
					string vEmLong = searchEmailbyExpre(vExpr, vkey);

					if (string.isNotBlank(vEmLong)) {
						string vEmShort = searchEmailbyExpre(vExpr2, vkey);
						if (sEmailsCheck.contains(vEmShort)) {
							lstSO.add(so);
						}
					} else if (sEmailsCheck.contains(vkey)) {
						lstSO.add(so);
					}
				}
			}
		}
		CBK_log.debug(vEventType + 'filterEmailsHandlers - newList:' + lstSO, LoggingLevel.INFO);
		return lstSO;
	}

    public static string searchEmailbyExpre(String vExpr, String vText) {

		Pattern p = Pattern.compile(vExpr);
		Matcher pm = p.matcher(vText);
		string vEmail = pm.find() ? pm.group() : '';

		return vEmail;
	}

    public static Map<String, String> getMapAssociatedHandlers(String className, String triggerEvent) {

		Map<String, String> mHandlerClassNames = new Map<string, String> ();

		List<CBK_TriggerHandlerAssociation__mdt> triggerHandlerAssociations = [SELECT CBK_HandlerClassName__c, CBK_ValidationHandlerEmail__c, CBK_ValidationHandlerEmail__r.Emails__c FROM CBK_TriggerHandlerAssociation__mdt WHERE CBK_HandlerClassName__c = :className AND CBK_TriggerEvent__c = :triggerEvent];

		for (CBK_TriggerHandlerAssociation__mdt triggerHandlerAssociation : triggerHandlerAssociations) {
			mHandlerClassNames.put(triggerHandlerAssociation.CBK_HandlerClassName__c, triggerHandlerAssociation.CBK_ValidationHandlerEmail__r.Emails__c);
		}
		return mHandlerClassNames;
	}

    public static List<EmailMessage> filtrarCorreosSACH(List<EmailMessage> correos) {
        List<EmailMessage> correosCc = new List<EmailMessage>();
        Set<Id> idsPadre = new Set<Id>();
        for (EmailMessage correo : correos) {
            if (String.isNotBlank(correo.ParentId)) {
                idsPadre.add(correo.ParentId);
            } else if (String.isNotBlank(correo.RelatedToId)) {
                idsPadre.add(correo.RelatedToId);
            }
        }

        if (!idsPadre.isEmpty()) {
            Map<Id, EmailMessage> mapaCorreos = new Map<Id, EmailMessage>();
            for (EmailMessage correo : correos) {
                mapaCorreos.put(correo.Id, correo);
            }

            Set<Id> idCasosCc = new Set<Id>();
            for (Case casoCc : [SELECT Id FROM Case WHERE Id IN :idsPadre AND RecordType.DeveloperName LIKE 'SACH_%']) {
                idCasosCc.add(casoCc.Id);
            }

            for (EmailMessage correo : correos) {
                if (idCasosCc.contains(correo.ParentId) || idCasosCc.contains(correo.RelatedToId)) {
                    correosCc.add(mapaCorreos.get(correo.Id));
                }
            }
        }
        return correosCc;
    }

    public static void validarCorreo(List<EmailMessage> listNewObj) {
        for (EmailMessage correo : listNewObj) {
            //Validación del valor del campo Grupo colaborador
            if (!correo.Incoming
            && (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador')) {
                if (correo.CC_Grupo_Colab__c == '' || [SELECT Count() FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c] == 0) {
                    correo.addError('El grupo colaborador indicado (' + correo.CC_Grupo_Colab__c + ') no existe.', false);
                }
            }
        }
    }

    public static void informarInterno(List<EmailMessage> listNewObj) {
        for (EmailMessage correo : listNewObj) {
            if (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador') {
                correo.CC_Interno__c = true;
            }
        }
    }

    public static void informarOperativa(List<EmailMessage> listNewObj) {
        List<String> referencias = new List<String>();
        List<Id> idsCasos = new List<Id>();
        List<EmailMessage> nuevoListadoCorreos = new List<EmailMessage>();
        for (EmailMessage correo : listNewObj) {
            String referencia = CC_EmailMessage.referenciaCorreo(correo);
            if (referencia != null && correo.Incoming) {
                idsCasos.add(correo.ParentId);
                referencias.add(referencia);
                nuevoListadoCorreos.add(correo);
            }
        }
        if (!referencias.isEmpty()) {
            List<Task> tareasOrigen = [SELECT Type, WhatId FROM Task WHERE WhatId IN :idsCasos
                                        AND CC_Referencia_Correo_Saliente__c IN :referencias];
            Map<Id, String> mapaTipoTareaDelCorreo = new Map<Id, String>();
            for (Task tarea : tareasOrigen) {
                mapaTipoTareaDelCorreo.put(tarea.WhatId, tarea.Type);
            }

            for (EmailMessage correo : nuevoListadoCorreos) {
                if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Traslado Colaborador') {
                    //Respuesta entrante a traslado del caso a grupo colaborador
                    correo.CC_Procedencia__c = 'Traslado Colaborador';
                    correo.CC_Interno__c = true;
                } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Remitir Colaborador') {
                    //Respuesta entrante a remisión del caso a grupo colaborador
                    correo.CC_Procedencia__c = 'Remitir Colaborador';
                    correo.CC_Interno__c = true;
                }
            }
        }
    }

    public static void comprobarContactos(List<EmailMessage> listNewObj) {
        //Empleado inactivo y cliente activo.
        Boolean mostrarError = false;
        List<String> direccionesPara = new List<String>();
        List<String> direccionesCC = new List<String>();
        List<String> direcciones = new List<String>();
        for (EmailMessage correo : listNewObj) {
            if ((correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador') && correo.toAddress != null) {
                direccionesPara = correo.toAddress.split(',');
            }
            if ((correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador') && correo.CcAddress != null) {
                direccionesCC = correo.CcAddress.split(',');
            }
        }
        direcciones = direccionesPara;

        if (!direcciones.isEmpty()) {
            if (!direccionesCC.isEmpty()) {
                for (String direccionCC : direccionesCC) {
                    if (!direcciones.contains(direccionCC)) {
                        direcciones.add(direccionCC);
                    }
                }
            }
            List<String> emailsCliente = new List<String>();
            List<Contact> listadoContactosCliente = [SELECT Id, Email FROM Contact WHERE Email IN :direcciones AND (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA')];
            
            if (!listadoContactosCliente.isEmpty()) {
                for (Contact contacto : listadoContactosCliente) {
                    if (!emailsCliente.contains(contacto.Email)) {
                        emailsCliente.add(contacto.Email);
                    }
                }
                if (!emailsCliente.isEmpty()) {
                    Map<String,List<Boolean>> listadoEmailsInactivo = new Map<String,List<Boolean>>();
                    List<Contact> listadoContactosClienteSonEmpleado = [SELECT Id, Email, CC_Inactivo__c FROM Contact WHERE Email IN :emailsCliente AND RecordType.DeveloperName = 'CC_Empleado'];
                    if (!listadoContactosClienteSonEmpleado.isEmpty()) {
                        for (Contact contacto : listadoContactosClienteSonEmpleado) {
                            if (!listadoEmailsInactivo.containsKey(contacto.Email)) {
                                listadoEmailsInactivo.put(contacto.Email, new List<Boolean>{contacto.CC_Inactivo__c});
                            }else {
                                List<Boolean> campoInactivo = listadoEmailsInactivo.get(contacto.Email);
                                campoInactivo.add(contacto.CC_Inactivo__c);
                                listadoEmailsInactivo.put(contacto.Email, campoInactivo);
                            }
                        }
                        //si no hay ningún inactivo a false
                        for (String email : listadoEmailsInactivo.keySet()) {
                            List<Boolean> valorInactivo = listadoEmailsInactivo.get(email);
                            if (!valorInactivo.contains(false)) {
                                mostrarError = true;
                            }
                        }
                    } else {
                        mostrarError = true;
                    }
                }
                if (mostrarError) {
                    for (EmailMessage correo : listNewObj) {
                        correo.addError('No se puede enviar un correo de traslado/remitido con direcciones de cliente en el Para o en Copia', false);
                    }
                }
            }
        }
    }

	public static void validarBuzonSalida(List<EmailMessage> listNewObj) {
        if (!listNewObj.isEmpty()) {
            //Se obtiene de CC_Buzones_Por_Defecto__mdt la lista de buzones de salida válidos
            List<String> buzonesSalidaValidos = new List<String>();
            for (CC_Buzones_Por_Defecto__mdt buzonPorDefecto : [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt]) {
                buzonesSalidaValidos.add(buzonPorDefecto.CC_Direccion_Correo__c);
            }

            //Si el correo saliente tiene un buzón de salida que no está en la lista, se muestra un error
            for (EmailMessage correo : listNewObj) {
                if (!correo.Incoming && String.isNotEmpty(correo.FromAddress) && !buzonesSalidaValidos.contains(correo.FromAddress)) {
                    correo.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
                }
            }
        }
    }

	public static void comprobarAnexosPermitidos(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {

        if (!listNewObj.isEmpty()) {
            //Se obtienen las extensiones permitidas para un anexo
            List<String> extensionesPermitidas = new List<String>();
            for (CC_ConfiguracionAnexoPermitido__mdt extensionPermitida : [SELECT CC_Extension__c FROM CC_ConfiguracionAnexoPermitido__mdt]) {
                extensionesPermitidas.add(extensionPermitida.CC_Extension__c);
            }

            // Se recopilan los correos salientes que contienen anexo
            List<Id> correosSalientes = new List<Id>();
            for (EmailMessage correo : listNewObj) {
                if (!correo.Incoming) {
                    correosSalientes.add(correo.Id);
                }
            }

            if (!correosSalientes.isEmpty()) {
                // Se comprueban las extensiones de los anexos y se impide el envío del correo en caso de que contenga algún anexo con extensión no permitida.
                for (ContentDocumentLink contentDocumentLink : [SELECT LinkedEntityId FROM ContentDocumentLink
                                                                WHERE ContentDocument.FileExtension NOT IN :extensionesPermitidas
                                                                AND LinkedEntityId IN :correosSalientes]) {
                    EmailMessage correoSalienteConAnexoProhibido = mapNewObj.get(contentDocumentLink.LinkedEntityId);
                    correoSalienteConAnexoProhibido.addError('El correo tiene un adjunto con una extensión no petmitida.');
                }
            }
        }
    }

	public static void switchProcedencia(List<EmailMessage> correosSACH) {

        Map<Id, Case> casos = new Map<Id, Case>([SELECT Status, CC_Referencia_Correo_Saliente__c, OS_Cerrado_Operativa__c, CC_Cola_Procedencia__c
                                                    FROM Case WHERE Id IN :CC_MetodosUtiles.listaCampo(correosSACH, 'ParentId')]);

        Map<String, Id> mapaGrupos = new Map<String, Id>();
        for (CC_Grupo_Colaborador__c grupoColab : [SELECT Name FROM CC_Grupo_Colaborador__c WHERE Name IN :CC_MetodosUtiles.listaCampo(correosSACH, 'CC_Grupo_Colab__c')]) {
            mapaGrupos.put(grupoColab.Name, grupoColab.Id);
        }

        List<Task> tareas = new List<Task>();
        for (EmailMessage correo : correosSACH) {
            if (!correo.Incoming && correo.Status != '5' && correo.ParentId != null) { //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
                if (correo.CC_Procedencia__c == 'Traslado Colaborador') {
                    envioTrasladoColaborador(correo, mapaGrupos.get(correo.CC_Grupo_Colab__c), casos, tareas);
                } else if (correo.CC_Procedencia__c == 'Remitir Colaborador') {
                    envioRemitirColaborador(correo, mapaGrupos.get(correo.CC_Grupo_Colab__c), casos, tareas);
                }
            }
        }
        Database.update(casos.values(), false);
        Database.insert(tareas, false);
	}

	private static void envioTrasladoColaborador(EmailMessage correo, Id idGrupoColaborador, Map<Id, Case> casos, List<Task> tareas) {
        Case caso = casos.get(correo.ParentId);
        if (caso != null) {
            Task tareaTrasladar = new Task();
            tareaTrasladar.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
            tareaTrasladar.Type = 'Traslado Colaborador';
            tareaTrasladar.Subject = 'Traslado Colaborador';
            tareaTrasladar.WhatId = correo.ParentId;
            tareaTrasladar.Status = 'Open';
            tareaTrasladar.Description = correo.TextBody.left(32000);
            tareaTrasladar.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
            tareaTrasladar.CC_Grupo_Colaborador_Id__c = idGrupoColaborador;
            CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(tareaTrasladar);
            CC_Configuracion_Reclamaciones_Auto.fechasPendingProcess(caso, tareaTrasladar);

            tareaTrasladar.CC_Correo_Asociado_Id__c = correo.Id;
            tareaTrasladar.ActivityDate = System.today();
            tareas.add(tareaTrasladar);

            caso.Status = 'Pendiente Colaborador';
            caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());
            caso.CC_Grupo_Colaborador__c = correo.CC_Grupo_Colab__c;
            caso.CC_Referencia_Correo_Saliente__c = null;
		}
    }

	private static void envioRemitirColaborador(EmailMessage correo, Id idGrupoColaborador, Map<Id, Case> casos, List<Task> tareas) {
        Case caso = casos.get(correo.ParentId);
        if (caso != null) {
            Task tareaRemitir = new Task();
            tareaRemitir.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
            tareaRemitir.Type = 'Remitir Colaborador';
            tareaRemitir.Subject = 'Remitir Colaborador';
            tareaRemitir.WhatId = correo.ParentId;
            tareaRemitir.Subject = correo.CC_Procedencia__c;
            tareaRemitir.CC_Grupo_Colaborador_Id__c = idGrupoColaborador;
            tareaRemitir.Description = correo.TextBody.left(32000);
            tareaRemitir.Status = 'Completed';
            tareaRemitir.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
            tareaRemitir.CC_Correo_Asociado_Id__c = correo.Id;
            tareaRemitir.ActivityDate = System.today();
            tareas.add(tareaRemitir);

            caso.CC_Grupo_Colaborador__c = correo.CC_Grupo_Colab__c;
            caso.CC_Referencia_Correo_Saliente__c = null;
            caso.Status = 'Cerrado';
		}
    }
}