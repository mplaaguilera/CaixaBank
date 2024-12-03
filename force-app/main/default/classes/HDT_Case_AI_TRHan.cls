public with sharing class HDT_Case_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
	}

	private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {

		Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        List<Case> lstCasesCC = new List<Case>();
        for (Case caso : listNewObj) {
            if (caso.RecordTypeId == rtEmpleado) {
                lstCasesCC.add(caso);
            }
        }


        if (!lstCasesCC.isEmpty()) {
			reactivacionOperativa(lstCasesCC);
			//Map<Id, CC_MCC__c> mapMCC = HDT_CaseTriggerHelper.obtencionMCCAplicacionesYServicios();
			HDT_CaseTriggerHelper.comprobacionContactoAI(lstCasesCC);
			//CC_CaseTriggerHelper.casosFaxAI(lstCasesCC);
			HDT_CaseTriggerHelper.estadoCerradoAI(lstCasesCC);
			CC_CaseTriggerHelperNoSharing.creacionCasoAI(JSON.serialize(lstCasesCC));
			HDT_CaseTriggerHelper.informarDireccionTerritorialAI(lstCasesCC);

			//Envio de acuse de recibo para llamadas
			//envioCorreoAcuseRecibo(lstCasesCC);
        }
	}
    
    /*
	 //Envío de correo Acuse de Recibo
	 private static void envioCorreoAcuseRecibo(List<Case> lstCasos){
        system.debug('Pasando por el crear de After Insert');

        Id rtTareaHDT = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        String apiNamePlantillas = 'HDT_Acuse_Recibo_Empleado_%';
        List <Case> casosAcuseRecibo = new List <Case>();
        List <Id> contactCasoId = new List <Id>();

        for (Case caso : lstCasos){ 
                casosAcuseRecibo.add(caso);
                contactCasoId.add(caso.ContactId);
        }

        //Buscamos si ya hay tasks de acuse de recibo asignadas al caso
        if(!casosAcuseRecibo.isEmpty()){

            //Recogemos las plantillas de correo ordenadas alfabeticamente (0: Catalan, 1: Castellano)
            List <EmailTemplate> plantillas = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE : apiNamePlantillas ORDER BY DeveloperName];

            //Recogemos el Custom Setting para obtener las direcciones de correo de respuesta (Configuracion_1 : Castellano, Configuracion_2 : Catalan)
            HDT_Parametros__c emailRespuesta = [SELECT Id, HDT_Configuracion_1__c, HDT_Configuracion_2__c FROM HDT_Parametros__c WHERE Name = 'HDT_Email_Respuesta_Empleados_New'];

            //Recogemos los Ids del remitente ordenadas alfabeticamente por la direccion (0: Catalan, 1 Castellano) en el caso de que existan los 2
            List <OrgWideEmailAddress> remitentesId = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (: emailrespuesta.HDT_Configuracion_1__c, : emailrespuesta.HDT_Configuracion_2__c) ORDER BY Address];

            List <Task> taskList = [SELECT Id FROM Task WHERE RecordTypeId = :rtTareaHDT AND Type = 'Acuse de recibo' AND WhatId IN : casosAcuseRecibo AND WhoId IN : contactCasoId];

            //Si no hay ninguna task de acuse de recibo asignada al caso y al contacto, se envía el correo y se crea la task de Acuse de recibo
            for(Case caso : casosAcuseRecibo){
                if(taskList.isEmpty()){
                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(remitentesId.size() == 2){
                        if(caso.CC_Idioma__c == 'ca'){
                            mail.setTemplateId(plantillas[0].Id);
                            mail.setOrgWideEmailAddressId(remitentesId[0].Id);
                        }else{
                            mail.setTemplateId(plantillas[1].Id);
                            mail.setOrgWideEmailAddressId(remitentesId[1].Id);
                        }
                    }else{
                        if(caso.CC_Idioma__c == 'ca'){
                            mail.setTemplateId(plantillas[0].Id);
                        }else{
                            mail.setTemplateId(plantillas[1].Id);
                        }
                        mail.setOrgWideEmailAddressId(remitentesId[0].Id);
                    }

                    mail.setSaveAsActivity(true);
                    mail.setWhatId(caso.Id);
                    mail.setTargetObjectId(caso.ContactId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    String[] toAddresses = new String[] {caso.ContactEmail};
                    mail.setToAddresses(toAddresses);
                    allmsg.add(mail);

                     try {
                        // Enviar el correo electrónico y manejar errores si los hay
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
                    } catch (Exception e) {
                        CBK_Log.error(e, 'Error en el envio de email');
                    }


                    // Crear Tarea
                    Task task = new Task();
                    task.ActivityDate = System.today();
                    task.Subject = 'Acuse de recibo';
                    task.Type = 'Acuse de recibo';
                    task.Status = 'Completed';
                    task.WhatId = caso.Id;
                    task.WhoId = caso.ContactId;
                    HDT_Activity.crearActividad(task);
                }
            }
        }
    }*/

	private void reactivacionOperativa(List<Case> listNewObj) {
		Id idTaskCC = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
		List<Task> tareasReactivacion = new List<Task>();
		for (Case caso : listNewObj) {
			if (caso.CC_Reactivado_Operativa__c != null && caso.Status != null) {
				Task tareaReactivacion = new Task();
				tareaReactivacion.CC_Fecha_Inicio__c = Datetime.now();
				tareaReactivacion.Description = caso.CC_Motivo_Reactivacion__c;
				tareaReactivacion.Priority = 'Normal';
				tareaReactivacion.Status = 'Completada';
				tareaReactivacion.Subject = 'Reactivación';
				tareaReactivacion.Type = 'Reactivación';
				tareaReactivacion.WhatId = caso.id;
				tareaReactivacion.RecordTypeId = idTaskCC;
				tareasReactivacion.add(tareaReactivacion);
			}
		}
		if (!tareasReactivacion.isEmpty()) {
			insert tareasReactivacion;
		}
	}
}