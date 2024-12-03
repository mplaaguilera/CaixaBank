public with sharing class TMS_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}

    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        List<EmailMessage> correosTMS = filtrarcorreosTMS(listNewObj);
        if (!correosTMS.isEmpty()) {
            //validarBuzonSalida(correosTMS);
            comprobarAnexosPermitidos(correosTMS, mapNewObj);
            enviarCorreo(correosTMS);
        }
	}

    public static void enviarCorreo(List<EmailMessage> correosTMS){
        Set<Id> idCasos = new Set<Id>();
        List<Task> tareas = new List<Task>();
        List<Case> casosList = new List<Case>();

        for(EmailMessage correoTMS : correosTMS){
            idCasos.add(correoTMS.ParentId);
        }
        
        Map<Id, Case> casos = new Map<Id, Case>([SELECT Status, CC_Referencia_Correo_Saliente__c, OS_Cerrado_Operativa__c, CC_Cola_Procedencia__c, TMS_Servicio_Premium__c, CC_Buzon_Salida__c
                                                    FROM Case WHERE Id IN :idCasos]);

        validarBuzonSalida(correosTMS, casos);

        for (EmailMessage correo : correosTMS) {
            if (!correo.Incoming && correo.Status != '5' && correo.ParentId != null && casos.get(correo.ParentId).Status != 'Rechazado email'){//0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
       		
                Case caso = casos.get(correo.ParentId);

                Task tareaEnvioCorreo = new Task();
                tareaEnvioCorreo.recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
                tareaEnvioCorreo.Type = 'Envio correo';
                tareaEnvioCorreo.Subject = 'Envio correo';
                tareaEnvioCorreo.WhatId = correo.ParentId;
                if(caso.TMS_Servicio_Premium__c){
                    tareaEnvioCorreo.Status = 'Pendiente';
                } else {
                    tareaEnvioCorreo.Status = 'Completed';
                }
                tareaEnvioCorreo.Description = correo.TextBody.left(32000);
                tareaEnvioCorreo.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
                tareas.add(tareaEnvioCorreo);
                
                caso.CC_Referencia_Correo_Saliente__c = null;
                casosList.add(caso);
            }
        }

        if(!tareas.isEmpty()){
            insert tareas;
        }

        if(!casosList.isEmpty()){
            update casosList;
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

    public static List<EmailMessage> filtrarcorreosTMS(List<EmailMessage> correos) {
        List<EmailMessage> correosTMS = new List<EmailMessage>();
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

            Set<Id> idCasosTMS = new Set<Id>();
            Id caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();

            for (Case casoTMS : [SELECT Id FROM Case WHERE Id IN :idsPadre AND RecordTypeId =  :caseRT]) {
                idCasosTMS.add(casoTMS.Id);
            }

            for (EmailMessage correo : correos) {
                if (idCasosTMS.contains(correo.ParentId) || idCasosTMS.contains(correo.RelatedToId)) {
                    correosTMS.add(mapaCorreos.get(correo.Id));
                }
            }
        }
        return correosTMS;
    }

    private static void validarBuzonSalida(List<EmailMessage> listNewObj, Map<Id, Case> casos) {
        if (!listNewObj.isEmpty()) {
            //Se obtiene de CC_Buzones_Por_Defecto__mdt la lista de buzones de salida válidos
            List<String> buzonesSalidaValidos = new List<String>();
            for (CC_Buzones_Por_Defecto__mdt buzonPorDefecto : [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt]) {
                buzonesSalidaValidos.add(buzonPorDefecto.CC_Direccion_Correo__c);
            }
            
            //Si el correo saliente tiene un buzón de salida que no está en la lista o que no se corresponda con el buzón guardado en el Caso (CC_Buzon_Salida__c), se muestra un error
            for (EmailMessage correo : listNewObj) {
                if (!correo.Incoming && String.isNotEmpty(correo.FromAddress) && (!buzonesSalidaValidos.contains(correo.FromAddress) || correo.FromAddress != casos.get(correo.ParentId).CC_Buzon_Salida__c)) {
                    correo.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
                }
            }
        }
    }
}