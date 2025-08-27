public with sharing class CC_Gestion_Derivar_Emails_Auto {

    @AuraEnabled
    public static void createEmail(
        Case caso, 
        List<String> toAddress, 
        List<String> bccAddress, 
        List<String> ccAddress, 
        String nombrePlantilla,
        String grupoColaborador, 
        Map<String, String> parametrizacionesMensaje, 
        String nameOWA
    ) {
        // Validación de parámetros obligatorios
        if (caso == null || toAddress == null || toAddress.isEmpty() || String.isBlank(nombrePlantilla) || String.isBlank(nameOWA)) {
            throw new AuraHandledException('Parámetros obligatorios no informados.');
        }
        // Obtener plantilla
        //EmailTemplate plantilla = asignacionPlantillas(nombrePlantilla, parametrizacionesMensaje);
        EmailTemplate plantilla = obtenerPlantilla(nombrePlantilla);
        if (plantilla == null) {
            throw new AuraHandledException('No se encontró la plantilla de correo.');
        }
        // Obtener OrgWideEmailAddress
        List<OrgWideEmailAddress> owaList = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :nameOWA LIMIT 1];
        if (owaList.isEmpty()) {
            throw new AuraHandledException('No se encontró la dirección de correo OWA.');
        }
        // Eliminar lógica de grupo colaborador en BCC
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(toAddress);
        if (bccAddress != null && !bccAddress.isEmpty()) mail.setBccAddresses(bccAddress);
        if (ccAddress != null && !ccAddress.isEmpty()) mail.setCcAddresses(ccAddress);
        
        String referencia = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id);
        caso.CC_Referencia_Correo_Saliente__c = referencia;
        caso.CC_Grupo_Colaborador__c = grupoColaborador;

        Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantilla.Id, caso.ContactId, caso.Id);

        // Sincronizar el HTML renderizado con la plantilla en memoria para que inicializarCuerpoCorreo
        // añada la referencia sobre el HTML final (con merges ya aplicados)
        plantilla.HtmlValue = renderStored.getHtmlBody();

        Map<String, String> datosPlantilla = CC_MetodosUtiles.inicializarCuerpoCorreo(plantilla, caso);

        caso.CC_Ultima_Operativa_Correo__c = datosPlantilla.get('operativa');

        update caso;

        mail.setSaveAsActivity(true);
        mail.setTemplateId(plantilla.Id);
        mail.setHtmlBody(plantilla.HtmlValue);
        mail.setSubject(renderStored.getSubject());
        mail.setWhatId(caso.Id);
        mail.setTargetObjectId(caso.ContactId);
        mail.setTreatTargetObjectAsRecipient(false);
        String htmlMail = asignacionPlantillas(plantilla.HtmlValue, parametrizacionesMensaje);
        if(String.isNotBlank(htmlMail)){
            mail.setHtmlBody(htmlMail);
        }
        if(!Test.isRunningTest()){
            mail.setOrgWideEmailAddressId(owaList[0].Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public static EmailTemplate obtenerPlantilla(String nombrePlantilla){
        List<EmailTemplate> plantillas = [SELECT Id, Subject, Body, Name, HtmlValue, DeveloperName, FolderId, Folder.Name FROM EmailTemplate WHERE Name = :nombrePlantilla LIMIT 1];
        return plantillas.isEmpty() ? null : plantillas[0];
    }

    public static String asignacionPlantillas(String html, Map<String, String> parametrizacionesMensaje){
        try{
            if(parametrizacionesMensaje != null){
                for(String clave : parametrizacionesMensaje.keySet()){
                    html = html.replace(clave, parametrizacionesMensaje.get(clave));
                }
                return html;
            }
            return null;
        } catch (Exception e){
            throw new AuraHandledException('Error en la asignación de la plantilla: ' + e.getMessage());
        }
    }

    public static Map<String, List<String>> sendEmailGrupoCol(List<String> grupoColaborador){
        if(grupoColaborador == null || grupoColaborador.isEmpty()){
            throw new AuraHandledException('Error en la búsqueda del grupo colaborador asociado');
        }
        try{
            List<CC_Grupo_Colaborador_Contact__c> colaboradores = [SELECT Id, CC_Nombre__c, CC_Email__c, CC_Para_CC__c FROM CC_Grupo_Colaborador_Contact__c 
                WHERE CC_Grupo_Colaborador__r.Name IN :grupoColaborador];
            List<String> emails = new List<String>();
            List<String> emailsCC = new List<String>();
            Map<String, List<String>> emailsMap = new Map<String, List<String>>();
            for(CC_Grupo_Colaborador_Contact__c colaborador : colaboradores){
                if(!String.isBlank(colaborador.CC_Email__c)){
                    if(colaborador.CC_Para_CC__c == 'CC'){
                        emailsCC.add(colaborador.CC_Email__c);
                    } else if (colaborador.CC_Para_CC__c == 'Para'){
                        emails.add(colaborador.CC_Email__c);
                    }
                }
            }
            
            emailsMap.put('Para', emails);
            emailsMap.put('CC', emailsCC);

            return emailsMap;
        } catch (Exception e){
            throw new AuraHandledException('Error en la búsqueda del grupo colaborador asociado: ' + e.getMessage());
        }
    }
}