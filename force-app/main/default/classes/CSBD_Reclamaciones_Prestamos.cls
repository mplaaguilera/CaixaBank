public with sharing class CSBD_Reclamaciones_Prestamos {
    
    //@InvocableMethod(label='CSBD - Enviar reclamación a cliente')
    public static void enviarReclamacion(List<ReclamacionClienteCsbd> input) {
        
        Map<Integer, CSBD_Reclamacion_Cliente__mdt> configsReclamacionesCliente = obtenerConfigsReclamacionesCliente();
        Map<Id, Opportunity> oportunidades = obtenerOportunidades(input);
        Map<Id, String> mapaOportunidadesAsuntos = obtenerAsuntosCorreoOrigen(oportunidades.keySet());

        for (ReclamacionClienteCsbd reclamacion : input) {

            System.debug('Entro en reclamación input numero::: '+reclamacion.numeroReclamacion);

            CSBD_Reclamacion_Cliente__mdt configReclamacion = configsReclamacionesCliente.get(reclamacion.numeroReclamacion);
            Opportunity oportunidad = oportunidades.get(reclamacion.idOportunidad);
            if (oportunidad.CSBD_Estado__c == 'Pendiente Cliente') {
                if (configReclamacion.CSBD_Tipo__c == 'Enviar correo electrónico') {
                    enviarCorreoReclamacion(
                        oportunidad.Id,
                        oportunidad.CSBD_Empresa_Proveedora__c,
                        oportunidad.CSBD_Email_Solicitud__c,
                        mapaOportunidadesAsuntos.get(oportunidad.Id),
                        plantillaParaOportunidad(oportunidad, configReclamacion)
                    );

                    CSBD_Activity.crearActividad(
                        oportunidad.Id,
                        'Reclamación a cliente',
                        'Completed',
                        reclamacion.numeroReclamacion + 'a reclamación (Correo)',
                        null
                    );
                } else if (configReclamacion.CSBD_Tipo__c == 'Enviar SMS') {
                    enviarSmsReclamacion(
                        oportunidad.Id,
                        oportunidad.CSBD_Telefono_Solicitud__c,
                        plantillaParaOportunidad(oportunidad, configReclamacion)
                    );

                    CSBD_Activity.crearActividad(
                        oportunidad.Id,
                        'Reclamación a cliente',
                        'Completed',
                        reclamacion.numeroReclamacion + 'a reclamación (SMS)',
                        null
                    );
                } else if (configReclamacion.CSBD_Tipo__c == 'Cerrar oportunidad') {
                    CSBD_Opportunity.cerrarOportunidad(oportunidad.Id, 'Perdida', 'Desistido cliente/Documentación no recibida');
                    
                    CSBD_Activity.crearActividad(
                        oportunidad.Id,
                        'Cerrada automáticamente por falta de respuesta',
                        'Completed',
                        'Cerrada automáticamente por falta de respuesta',
                        null
                    );

                    enviarCorreoCierre(
                        oportunidad.Id,
                        oportunidad.CSBD_Empresa_Proveedora__c,
                        oportunidad.CSBD_Contact__c,
                        oportunidad.CSBD_Email_Solicitud__c,
                        plantillaParaOportunidad(oportunidad, configReclamacion)
                    );
                }
            }
        }
    }

    private static void enviarCorreoReclamacion(Id idOportunidad, String empresaProveedora, String destinatario, String asunto, String nombrePlantilla) {
        //No realiza substituciones en el cuerpo del correo (si se usa setSubject no es posible)
        if (String.isNotBlank(destinatario) && String.isNotBlank(asunto) && String.isNotBlank(nombrePlantilla)) {
            String nombreBuzonSalida = empresaProveedora == 'imaginBank' ? 'CSBD - ImaginBank' : 'CSBD - CaixaBank';
            String cuerpoPlantilla = '';
            if (Test.isRunningTest()) {
                cuerpoPlantilla = [SELECT HtmlValue FROM EmailTemplate WHERE Name = :nombrePlantilla LIMIT 1].HtmlValue;
            } else {
                cuerpoPlantilla = [SELECT HtmlValue FROM EmailTemplate WHERE Name = :nombrePlantilla
                                    AND Folder.DeveloperName = 'CSBD_Reclamaciones_Cliente' LIMIT 1].HtmlValue;
            }
            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
            correo.setWhatId(idOportunidad);
            correo.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :nombreBuzonSalida].Id);
            correo.setToAddresses(new List<String>{destinatario});
            correo.setSubject(asunto);
            correo.setHtmlBody(cuerpoPlantilla);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
        }
    }

    private static void enviarCorreoCierre(Id idOportunidad, String empresaProveedora, String idContacto, String destinatario, String nombrePlantilla) {
        if (String.isNotBlank(destinatario) && String.isNotBlank(nombrePlantilla)) {
            String nombreBuzonSalida = empresaProveedora == 'imaginBank' ? 'CSBD - ImaginBank' : 'CSBD - CaixaBank';
            Id idPlantilla;
            if (Test.isRunningTest()) {
                idPlantilla = [SELECT Id FROM EmailTemplate WHERE Name = :nombrePlantilla LIMIT 1].Id;
            } else {
                idPlantilla = [SELECT Id FROM EmailTemplate WHERE Name = :nombrePlantilla AND Folder.DeveloperName = 'CSBD_Reclamaciones_Cliente' LIMIT 1].Id;
            }
            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
            correo.setWhatId(idOportunidad);
            correo.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :nombreBuzonSalida].Id);
            correo.setTargetObjectId(idContacto);
            correo.setTreatTargetObjectAsRecipient(false);
            correo.setToAddresses(new List<String>{destinatario});
            correo.setTemplateId(idPlantilla);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
        }
    }

    @future(callout=true)
    private static void enviarSmsReclamacion(Id idOportunidad, String destinatario, String nombrePlantilla) {
        if (String.isNotBlank(destinatario) && String.isNotBlank(nombrePlantilla)) {
            String cuerpoSms = '';
            if (Test.isRunningTest()) {
                cuerpoSms = [SELECT HtmlValue FROM EmailTemplate
                                WHERE Name = :nombrePlantilla LIMIT 1].HtmlValue.stripHtmlTags();
            } else {
                cuerpoSms = [SELECT HtmlValue FROM EmailTemplate
                                WHERE Folder.DeveloperName = 'CSBD_Reclamaciones_Cliente'
                                AND Name = :nombrePlantilla].HtmlValue.stripHtmlTags();
            }
            CC_Push_SMS.CC_Push_SMS_Mensaje mensaje = new CC_Push_SMS.CC_Push_SMS_Mensaje();
            mensaje.sObjectId = idOportunidad;
            mensaje.destinatario = destinatario;
            mensaje.texto = cuerpoSms;
            mensaje.asuntoTarea = 'Reclamación a cliente por SMS';
            CC_Push_SMS.enviarNotificacionPush(mensaje);
        }
    }

    private static Map<Integer, CSBD_Reclamacion_Cliente__mdt> obtenerConfigsReclamacionesCliente() {
        Map<Integer, CSBD_Reclamacion_Cliente__mdt> configsReclamacionesCliente = new Map<Integer, CSBD_Reclamacion_Cliente__mdt>();
        for (CSBD_Reclamacion_Cliente__mdt config : [SELECT CSBD_Numero_Reclamacion__c, CSBD_Tipo__c, CSBD_Plantilla_CBK_Castellano__c,
                                                        CSBD_Plantilla_CBK_Catalan__c, CSBD_Plantilla_IMG_Castellano__c, CSBD_Plantilla_IMG_Catalan__c
                                                        FROM CSBD_Reclamacion_Cliente__mdt ORDER BY CSBD_Numero_Reclamacion__c ASC]) {
            configsReclamacionesCliente.put(Integer.valueOf(config.CSBD_Numero_Reclamacion__c), config);
        }
        return configsReclamacionesCliente;
    }

    private static Map<Id, Opportunity> obtenerOportunidades(List<ReclamacionClienteCsbd> input) {
        List<Id> idOportunidades = new List<Id>();
        for (ReclamacionClienteCsbd reclamacionCliente : input) {
            idOportunidades.add(reclamacionCliente.idOportunidad);
        }
        return new Map<Id, Opportunity>(
            [SELECT CSBD_Estado__c, CSBD_Empresa_Proveedora__c, CSBD_Contact__c,
                CSBD_Idioma_Solicitud__c, CSBD_Email_Solicitud__c, CSBD_Telefono_Solicitud__c
                FROM Opportunity WHERE Id IN :idOportunidades]
        );
    }

    private static Map<Id, String> obtenerAsuntosCorreoOrigen(Set<Id> idOportunidades) {
        Map<Id, String> mapaCorreosPendClienteOportunidades = new Map<Id, String>();
        for (Task tareaPendienteCliente : [SELECT WhatId, CSBD_Email_Pendiente_Cliente__c FROM Task
                                            WHERE WhatId IN :idOportunidades AND Type = 'Pendiente Cliente'
                                            AND Status = 'Open' ORDER BY CreatedDate DESC]) {
            mapaCorreosPendClienteOportunidades.put(
                tareaPendienteCliente.CSBD_Email_Pendiente_Cliente__c,
                tareaPendienteCliente.WhatId
            );
        }

        Map<Id, String> mapaOportunidadesAsuntos = new Map<Id, String>();
        for (EmailMessage correoPendCliente : [SELECT RelatedToId, Subject FROM EmailMessage
                                                WHERE Id IN :mapaCorreosPendClienteOportunidades.keySet()]) {
            mapaOportunidadesAsuntos.put(correoPendCliente.RelatedToId, correoPendCliente.Subject);
        }
        return mapaOportunidadesAsuntos;
    }

    private static String plantillaParaOportunidad(Opportunity oportunidad, CSBD_Reclamacion_Cliente__mdt configReclamacion) {
        String empresaIdioma = oportunidad.CSBD_Empresa_Proveedora__c + '.' + oportunidad.CSBD_Idioma_Solicitud__c;
        switch on empresaIdioma {
            when 'CaixaBank.Castellano' {
                return configReclamacion.CSBD_Plantilla_CBK_Castellano__c;
            }
            when 'CaixaBank.Catalán' {
                return configReclamacion.CSBD_Plantilla_CBK_Catalan__c;
            }
            when 'imaginBank.Castellano' {
                return configReclamacion.CSBD_Plantilla_IMG_Castellano__c;
            }
            when 'imaginBank.Catalán' {
                return configReclamacion.CSBD_Plantilla_IMG_Catalan__c;
            }
            when else {
                return configReclamacion.CSBD_Plantilla_CBK_Castellano__c;
            }
        }
    }

    public class ReclamacionClienteCsbd {
        public Integer numeroReclamacion;

        public Id idOportunidad;
    }
}