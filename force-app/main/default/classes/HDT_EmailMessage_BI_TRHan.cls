public with sharing class HDT_EmailMessage_BI_TRHan extends CC_TriggerHandlerBase {
    private static String handlerClass = 'HDT_EmailMessage_BI_TRHan';
    private static String vEventType = 'beforeInsert';

    public override void mainEntry(CC_TriggerParameters tp) {
        List<SObject> lstSO = CBK_EmailMessageTriggerHelper.filterEmailsHandlers(tp,handlerClass, vEventType);
        tp.newList = lstSO.size() > 0 ? lstSO : tp.newList;
        process((List<EmailMessage>) tp.newList);
    }

    private static void process(List<EmailMessage> listNewObj) {
        List<EmailMessage> correosCc = filtrarCorreosNoCc(listNewObj);
        validarCorreo(correosCc);
        informarInterno(correosCc);
        informarOperativa(correosCc);
        comprobarContactos(correosCc);

    }

    private static void validarCorreo(List<EmailMessage> listNewObj) {
        Set<String> setEmailNames = new Set<String>();
        List<String> lstGroupNames = new List<String>();
        for (EmailMessage correo : listNewObj) {
            if(correo.CC_Grupo_Colab__c != null && correo.CC_Grupo_Colab__c != ''){
                setEmailNames.add(correo.CC_Grupo_Colab__c);
            }
        }

        for (CC_Grupo_Colaborador__c grupo : [SELECT Name FROM CC_Grupo_Colaborador__c WHERE Name IN :setEmailNames ]) {
            lstGroupNames.add(grupo.Name);
        }

        for (EmailMessage correo : listNewObj) {
            //Validación del valor del campo Grupo colaborador
            if (!correo.Incoming && (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador')) {
                if (correo.CC_Grupo_Colab__c == '' || !lstGroupNames.contains(correo.CC_Grupo_Colab__c)) {
                    correo.addError('El grupo colaborador indicado (' + correo.CC_Grupo_Colab__c + ') no existe.', false);
                }
            }
        }
    }

    private static void informarInterno(List<EmailMessage> listNewObj) {
        for (EmailMessage correo : listNewObj) {
            if (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador') {
                correo.CC_Interno__c = true;
            }
        }
    }

    private static void informarOperativa(List<EmailMessage> listNewObj) {
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
        if (!referencias.isEmpty()){
            List<Task> tareasOrigen = [SELECT Type, WhatId FROM Task WHERE WhatId IN :idsCasos AND CC_Referencia_Correo_Saliente__c IN :referencias ];
            Map<Id, String> mapaTipoTareaDelCorreo = new Map<Id, String>();
            for (Task tarea : tareasOrigen) {
                mapaTipoTareaDelCorreo.put(tarea.WhatId, tarea.Type);
            }

            for (EmailMessage correo : nuevoListadoCorreos) {
                if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Traslado Colaborador') {
                    //Respuesta entrante de grupo colaborador
                    correo.CC_Procedencia__c = 'Traslado Colaborador';
                    correo.CC_Interno__c = true;
                } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Solicitud Información') {
                    //Respuesta entrante de solicitud de información de cliente
                    correo.CC_Procedencia__c = 'Solicitud Información';
                    correo.CC_Interno__c = false;
                } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Remitir Colaborador') {
                    //Respuesta entrante de remisión del caso a grupo colaborador
                    correo.CC_Procedencia__c = 'Remitir Colaborador';
                    correo.CC_Interno__c = true;
                }
            }
        }

    }

    private static void comprobarContactos(List<EmailMessage> listNewObj) {

        //Empleado inactivo y cliente activo.
        Boolean mostrarError = false;
        String userProfileId = userInfo.getProfileId();
        Id idUsuario =UserInfo.getUserId();
        List<String> direccionesPara = new List<String>();
        List<String> direccionesCC = new List<String>();
        Set<String> direcciones = new Set<String>();
        Boolean mostrarErrorSinOperativa = false;
        for (EmailMessage correo : listNewObj) {
            if ((correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador') && !correo.Incoming && correo.toAddress != null) {
                direccionesPara = correo.toAddress.deleteWhitespace().split(',');
            }
            if ((correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador') && !correo.Incoming && correo.CcAddress != null) {
                direccionesCC = correo.CcAddress.deleteWhitespace().split(',');
            }
            if ((!correo.Incoming) && ((correo.CC_Procedencia__c == null || correo.CC_Procedencia__c == ''))) {
                mostrarErrorSinOperativa = true;
            }
            if ((!correo.Incoming) && (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador') &&
                                        (correo.CC_Grupo_Colab__c == null || correo.CC_Grupo_Colab__c == '')) {
                mostrarErrorSinOperativa = true;
            }
        }

        if (mostrarErrorSinOperativa) {
            Boolean puedeModificar = false;
            String profileName=[Select Id,Name from Profile where Id=:userProfileId].Name;
            List<PermissionSetAssignment> permisosAsignados =[SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId
                                                   FROM PermissionSetAssignment where assigneeId =:idUsuario];

            for(PermissionSetAssignment permisoAsignado : permisosAsignados){
                if(permisoAsignado.PermissionSet.Name=='SDocs_User' || permisoAsignado.PermissionSet.Name=='SDocs_Administrator'){
                    puedeModificar = true;
                }
            }
			/*
            if(profileName!='System Administrator' && profileName!='Administrador del Sistema' && puedeModificar == false) {

                for (EmailMessage correo : listNewObj) {
                    correo.addError('No se pueden enviar correos desde esta sección.', false);
                }
            }*/
        }


        direcciones = new Set<String>(direccionesPara);
        if (direcciones.isEmpty() && !direccionesCC.isEmpty()) {
            direcciones = new Set<String>(direccionesCC);
        }
        if (!direcciones.isEmpty()) {
            if (!direccionesCC.isEmpty()) {
                for (String direccionCC : direccionesCC) {
                    if (!direcciones.contains(direccionCC)) {
                        direcciones.add(direccionCC);
                    }
                }
            }

            List<String> emailsCliente = new List<String>();
            List<Contact> listadoContactosCliente = [SELECT Id, Email FROM Contact WHERE Email IN :direcciones AND ((RecordType.DeveloperName = 'CC_Cliente' AND Account.RecordType.DeveloperName = 'CC_Cliente') OR Account.RecordType.DeveloperName = 'CC_ClientePA') ];
            if (!listadoContactosCliente.isEmpty()) {
                for (Contact contacto : listadoContactosCliente) {
                    if (!emailsCliente.contains(contacto.Email)) {
                        emailsCliente.add(contacto.Email);
                    }
                }
                if (!emailsCliente.isEmpty()) {
                    Map<String,List<Boolean>> listadoEmailsInactivo = new Map<String,List<Boolean>>();
                    //Buscamos si los contactos de cliente existen como contactos de empleado o de colaborador
                    List<Contact> listadoContactosClienteSonEmpleadoSonColaborador = [SELECT Id, Email, CC_Inactivo__c FROM Contact WHERE Email IN :emailsCliente AND (RecordType.DeveloperName = 'CC_Empleado' OR RecordType.DeveloperName = 'CC_Colaborador') ];
                    if (!listadoContactosClienteSonEmpleadoSonColaborador.isEmpty()) {
                        for (Contact contacto : listadoContactosClienteSonEmpleadoSonColaborador) {
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


    private static List<EmailMessage> filtrarCorreosNoCc(List<EmailMessage> correos) {
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
            for (Case casoCc : [SELECT Id FROM Case WHERE Id IN :idsPadre AND RecordType.DeveloperName LIKE 'HDT_%' ]) {
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
}