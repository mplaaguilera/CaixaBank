public with sharing class GRR_EmailMessageTriggerHelper {

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

    public static List<EmailMessage> filtrarCorreosGRR(List<EmailMessage> correos) {
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
            for (Case casoCc : [SELECT Id FROM Case WHERE Id IN :idsPadre AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente')]) {
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
        
        Set<String> nombresGrupos = new Set<String>();
        for (EmailMessage correo : listNewObj) {
            if (!correo.Incoming && (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador')) {
                nombresGrupos.add(correo.CC_Grupo_Colab__c);
            }
        }

        Set<String> gruposExistentes = new Set<String>();
        for (CC_Grupo_Colaborador__c grupo : [SELECT Name FROM CC_Grupo_Colaborador__c WHERE Name IN :nombresGrupos]) {
            gruposExistentes.add(grupo.Name);
        }

        for (EmailMessage correo : listNewObj) {
            //Validación del valor del campo Grupo colaborador
            if (!correo.Incoming && (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador')) {
                if (correo.CC_Grupo_Colab__c == '' || !gruposExistentes.contains(correo.CC_Grupo_Colab__c)) {
                    correo.addError('El grupo colaborador indicado (' + correo.CC_Grupo_Colab__c + ') no existe.', false);
                }
            }
        }
    }

    public static void informarInterno(List<EmailMessage> listNewObj) {
        for (EmailMessage correo : listNewObj) {
            //DIFERENCIAS ENTRE UN CORREO QUE ACABA DE ENTRAR Y UNO QUE SE ENVIA DE RECLAMACION:
            // El primer correo nunca tendra y el de las reclamaciones tiene la tarea de traslado abierta.
            // Incomming -> Uno entra (true) y otro sale (false)
            // messageidentifier el primero siempre tiene este campo blank
            if (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador' || (correo.CC_Procedencia__c == null && !correo.Incoming && correo.ActivityId != null && correo.MessageIdentifier != null)){
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
                // } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Responder a cliente') {
                //     correo.CC_Procedencia__c = 'Responder a cliente';
                } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Solicitud Información') {
                    correo.CC_Procedencia__c = 'Solicitud Información';
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
            // List<Contact> listadoContactosCliente = [SELECT Id, Email FROM Contact WHERE Email IN :direcciones AND (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact','CC_Cliente') OR Account.RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account','CC_ClientePA'))];
            List<Contact> listadoContactosCliente = [SELECT Id, Email FROM Contact WHERE Email IN :direcciones AND (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA')];
   
            if (!listadoContactosCliente.isEmpty()) {
                for (Contact contacto : listadoContactosCliente) {
                    if (!emailsCliente.contains(contacto.Email)) {
                        emailsCliente.add(contacto.Email);
                    }
                }
                
                if (!emailsCliente.isEmpty()) {
                    Map<String,List<Boolean>> listadoEmailsInactivo = new Map<String,List<Boolean>>();
                    // List<Contact> listadoContactosClienteSonEmpleado = [SELECT Id, Email, CC_Inactivo__c FROM Contact WHERE Email IN :emailsCliente AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact','CC_Empleado')];
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
            String userProfileId = userInfo.getProfileId();
            String profileName = [SELECT Id,Name FROM Profile WHERE Id = :userProfileId].Name;
            
            if(profileName != 'System Administrator' && profileName != 'Administrador del Sistema'){
                // Nueva validación que comprueba los grupos pertenecientes del usuario
                Set<String> groupNames = new Set<String>();
                Set<String> correosPermitidos = new Set<String>();
                
                for (GroupMember member : [SELECT Id, Group.DeveloperName FROM GroupMember WHERE (UserOrGroupId = :UserInfo.getUserId() AND Group.Type='Regular' AND Group.DeveloperName LIKE 'GRR_Buzon%')]) {
                    groupNames.add(member.Group.DeveloperName);
                }
    
                if (!groupNames.isEmpty()) {
                    for (GRR_Correos_Buzones_Entrada__mdt mdt: [SELECT GRR_Email_Destino__c FROM GRR_Correos_Buzones_Entrada__mdt WHERE GRR_Cola_Procedencia__c  IN :groupNames WITH SECURITY_ENFORCED]){
                        correosPermitidos.add(mdt.GRR_Email_Destino__c);
                    }
                }
                
                for (EmailMessage correo : listNewObj) { 
                    if (!correo.Incoming && String.isNotEmpty(correo.FromAddress) && !correosPermitidos.contains(correo.FromAddress)) {
                        correo.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
                    }
                }
            } else {
                // Validación ya existente que permite enviar las reclamaciones automáticas solo desde los buzones de GRR desde un perfil administrador.
                List<String> buzonesSalidaValidos = new List<String>();
                for (GRR_Correos_Buzones_Entrada__mdt buzonPorDefecto : [SELECT GRR_Email_Destino__c FROM GRR_Correos_Buzones_Entrada__mdt ]) {
                    buzonesSalidaValidos.add(buzonPorDefecto.GRR_Email_Destino__c );
                }

                //Si el correo saliente tiene un buzón de salida que no está en la lista, se muestra un error
                for (EmailMessage correo : listNewObj) {
                    if (!correo.Incoming && String.isNotEmpty(correo.FromAddress) && !buzonesSalidaValidos.contains(correo.FromAddress)) {
                        correo.addError('El buzón de salida indicado no es apto para el envío de correos desde un perfil de administrador.', false);
                    }
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
                    correoSalienteConAnexoProhibido.addError('El correo tiene un adjunto con una extensión no permitida.');
                }
            }
        }
    }

	public static void switchProcedencia(List<EmailMessage> correosGRR) {

        Map<Id, Case> casos = new Map<Id, Case>([SELECT Status, CC_Referencia_Correo_Saliente__c, OS_Cerrado_Operativa__c, CC_Cola_Procedencia__c
                                                    FROM Case WHERE Id IN :CC_MetodosUtiles.listaCampo(correosGRR, 'ParentId')]);

        Map<String, Id> mapaGrupos = new Map<String, Id>();
        Map<String, String> mapaGruposNegocio = new Map<String, String>();
        for (CC_Grupo_Colaborador__c grupoColab : [SELECT Name, OS_Negocio__c FROM CC_Grupo_Colaborador__c WHERE Name IN :CC_MetodosUtiles.listaCampo(correosGRR, 'CC_Grupo_Colab__c')]) {
            mapaGrupos.put(grupoColab.Name, grupoColab.Id);
            mapaGruposNegocio.put(grupoColab.Name, grupoColab.OS_Negocio__c);
        }

        List<Task> tareas = new List<Task>();
        for (EmailMessage correo : correosGRR) {
            if (!correo.Incoming && correo.Status != '5' && correo.ParentId != null) { //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
                if (correo.CC_Procedencia__c == 'Traslado Colaborador') {
                    envioTrasladoColaborador(correo, mapaGrupos.get(correo.CC_Grupo_Colab__c), casos, tareas, (String) mapaGruposNegocio.get(correo.CC_Grupo_Colab__c));
                } else if (correo.CC_Procedencia__c == 'Remitir Colaborador') {
                    envioRemitirColaborador(correo, mapaGrupos.get(correo.CC_Grupo_Colab__c), casos, tareas);
                } else if (correo.CC_Procedencia__c == 'Responder a cliente') {
                    envioResponderCliente(correo, casos, tareas);
                } else if (correo.CC_Procedencia__c == 'Solicitud Información') {
                    envioSolicitudInfo(correo, casos, tareas);
                }
            }
        }
        Database.update(casos.values(), false);
        Database.insert(tareas, false);
	}

	public static void envioTrasladoColaborador(EmailMessage correo, Id idGrupoColaborador, Map<Id, Case> casos, List<Task> tareas, String negocio) {
        Case caso = casos.get(correo.ParentId);
        if (caso != null) {
            Task tareaTrasladar = new Task();
            tareaTrasladar.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tareaTrasladar.Type = 'Traslado Colaborador';
            tareaTrasladar.Subject = 'Traslado Colaborador';
            tareaTrasladar.WhatId = correo.ParentId;
            tareaTrasladar.Status = 'Open';
            tareaTrasladar.Description = correo.TextBody.left(32000);
            tareaTrasladar.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
            tareaTrasladar.CC_Grupo_Colaborador_Id__c = idGrupoColaborador;
            
            if(negocio == 'GRR'){
                CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(tareaTrasladar);
                CC_Configuracion_Reclamaciones_Auto.fechasPendingProcess(caso, tareaTrasladar);
            }

            tareaTrasladar.CC_Correo_Asociado_Id__c = correo.Id;
            tareaTrasladar.ActivityDate = System.today();
            tareas.add(tareaTrasladar);

            caso.Status = 'Pendiente Colaborador';
            caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());
            caso.CC_Grupo_Colaborador__c = correo.CC_Grupo_Colab__c;
            caso.CC_Referencia_Correo_Saliente__c = null;
            caso.CC_Ultima_Interaccion__c = 'Nuevo'; //NEW
            caso.CC_Fecha_Ultima_Interaccion__c = System.now(); //NEW
		}
    }

	public static void envioRemitirColaborador(EmailMessage correo, Id idGrupoColaborador, Map<Id, Case> casos, List<Task> tareas) {
        Case caso = casos.get(correo.ParentId);
        if (caso != null) {
            Task tareaRemitir = new Task();
            tareaRemitir.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
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
            //caso.Status = 'Cerrado';
            caso.CC_Ultima_Interaccion__c = 'Nuevo'; 
            caso.CC_Fecha_Ultima_Interaccion__c = System.now(); 
		}
    }

    public static void envioResponderCliente(EmailMessage correo, Map<Id, Case> casos, List<Task> tareas) {
        Case caso = casos.get(correo.ParentId);
        if (caso != null) {
            Task tareaResponder = new Task();
            tareaResponder.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tareaResponder.Type = 'Responder a cliente';
            tareaResponder.Subject = 'Responder a cliente';
            tareaResponder.WhatId = correo.ParentId;
            tareaResponder.Description = correo.TextBody.left(32000);
            tareaResponder.Status = 'Completed';
            tareaResponder.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
            tareaResponder.CC_Correo_Asociado_Id__c = correo.Id;
            tareaResponder.ActivityDate = System.today();
            tareas.add(tareaResponder);

            caso.CC_Referencia_Correo_Saliente__c = null;
            caso.CC_Ultima_Interaccion__c = 'Nuevo';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();

            
            //OS_Cerrado_Operativa__c = true EN GRR_Case_Operativa
            if (caso.OS_Cerrado_Operativa__c) {
                caso = GRR_Case.responderCerrar(caso);
            }
        }
    }

    public static void envioSolicitudInfo(EmailMessage correo, Map<Id, Case> casos, List<Task> tareas) {
        Case caso = casos.get(correo.ParentId);

        if (caso != null) {
            //Nueva actividad de tipo "Solicitud Información"
            Task tareaSolicitar = new Task();
            tareaSolicitar.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tareaSolicitar.Type = 'Solicitud Información';
            tareaSolicitar.Subject = 'Solicitud Información';
            tareaSolicitar.WhatId = correo.ParentId;
            //tareaSolicitar.CC_Fecha_FinPlazo_SolInf__c = fechaFinPlazo;
            tareaSolicitar.Status = 'Open';
            tareaSolicitar.Description = correo.TextBody.left(32000);
            tareaSolicitar.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
            tareaSolicitar.ActivityDate = System.today();
            tareas.add(tareaSolicitar);
            
            caso.Status = 'Pendiente Cliente';
            //caso.CC_Fecha_Cierre_SolInf__c = fechaFinPlazo;
            caso.CC_Ultima_Interaccion__c = 'Nuevo';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.CC_Fecha_Solicitud_Informacion__c = System.today();
            caso.CC_Referencia_Correo_Saliente__c = null; //Se vacía la referencia de correo saliente del caso para evitar que se reuse por error

        }
    }

}