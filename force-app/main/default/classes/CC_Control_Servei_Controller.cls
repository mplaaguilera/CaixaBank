public with sharing class CC_Control_Servei_Controller {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> init(Id idAgrupador, Datetime fechaInicio, Datetime fechaFin) {
        Map<String, Object> retorno = new Map<String, Object>();
        Boolean permiso = ![SELECT Id FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId()
                            AND PermissionSet.Name = 'CC_Control_Servei' LIMIT 1].isEmpty();
        retorno.put('permiso', permiso);

        if (permiso) {
            String nombrePlantilla = 'Plantilla_incidencia_masiva_comunicacion_informativa_afectados';
            retorno.put('htmlPlantilla', [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = :nombrePlantilla].HtmlValue);
            retorno.put('casos', getCasos(idAgrupador, fechaInicio, fechaFin, false));
        }
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getCasos(Id idAgrupador, Datetime fechaInicio, Datetime fechaFin, Boolean busquedaFechas) {
        fechaInicio = fechaInicio != null ? fechaInicio : System.now().addYears(-3);
        fechaFin = fechaFin != null ? fechaFin : System.now();

        if(busquedaFechas) {
            return [SELECT Subject, CaseNumber, FORMAT(CreatedDate), Contact.Email, RecordType.Name FROM Case
            WHERE CC_Agrupador_Id__c = :idAgrupador AND RecordType.DeveloperName IN ('CC_Empleado', 'HDT_Empleado')
            AND  CreatedDate > :fechaInicio AND CreatedDate < :fechaFin ORDER BY CreatedDate ASC LIMIT 500];
        } else {
            return [SELECT Subject, CaseNumber, FORMAT(CreatedDate), Contact.Email, RecordType.Name FROM Case
            WHERE CC_Agrupador_Id__c = :idAgrupador AND RecordType.DeveloperName IN ('CC_Empleado', 'HDT_Empleado')
            ORDER BY CreatedDate ASC LIMIT 500];
        }
    }

    @AuraEnabled
    public static void enviarComunicacion(String plantilla, List<Case> casos) {
        Id idBuzonSalida = getBuzonSalidaId();
        if (idBuzonSalida == null) {
            throw new AuraHandledException('El buzón de salida "CC_Control_Servei" no está configurado');
        }

        system.debug('El buzon recogido es : '+ idBuzonSalida);

        List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> listaCorreosInsert = new List<EmailMessage>();
        EmailTemplate plantillaSalesforce = [SELECT Subject, Id FROM EmailTemplate WHERE DeveloperName = 'Plantilla_incidencia_masiva_comunicacion_informativa_afectados'];
        //Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantillaSalesforce.Id, UserInfo.getUserId(), casos[0].Id);
        //String renderedSubject = renderStored.getSubject();
       
        EmailTemplate miplantilla = new EmailTemplate ();
        miplantilla = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Plantilla_incidencia_masiva_comunicacion_informativa_afectados' LIMIT 1];
        

        for (Case caso : casos) {
            if (caso.Contact.Email != null) {
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantillaSalesforce.Id, UserInfo.getUserId(), caso.Id);
                Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                correo.setHtmlBody(plantilla);
                //correo.setHtmlBody(miplantilla.HtmlValue);
                correo.setSaveAsActivity(true);
                correo.setWhatId(caso.Id);
                correo.setTargetObjectId(caso.contactId);
                correo.Subject = renderStored.getSubject();
                correo.setToAddresses(new List<String>{caso.Contact.Email});
                correo.setOrgWideEmailAddressId(idBuzonSalida);
                correos.add(correo);

            }
        }
        if (!correos.isEmpty()) {
            if (!Test.isRunningTest()){
            Messaging.sendEmail(correos, false);
            }else{
              EmailMessage correoOrigen = new EmailMessage();
                correoOrigen.Subject = 'Prueba de envío de correo';     
                correoOrigen.CC_Procedencia__c = 'Responder Cliente';
                correoOrigen.FromAddress = 'prueba@ibm.com';
                correoOrigen.ToAddress = 'prueba@ibm.com';
                correoOrigen.Incoming = true;
                correoOrigen.ParentId = casos[0].Id;
                correoOrigen.RelatedToId = casos[0].Id;
                correoOrigen.Headers = '[{"value": "","name": "X-SFDC-Original-RCPT"}]';
                correoOrigen.HtmlBody = 'Cuerpo<br/>';
                insert correoOrigen;
            }
        }
    }

    private static Id getBuzonSalidaId() {
        String buzonDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                WHERE Label = 'CC_Control_Servei' AND CC_Activo__c = TRUE LIMIT 1]?.CC_Direccion_Correo__c;
        return [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefecto LIMIT 1]?.Id;
    }
}