public with sharing class CC_Gestion_Derivar_Onboarding {
    @AuraEnabled
    public static void envioCorreoAutomatico(String recordId) {
        List<Case> caso = [SELECT Status, ContactId, CBK_Case_Extension_Id__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c FROM Case WHERE Id = :recordId];
        if (!caso.isEmpty()) {
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Map<String,OrgWideEmailAddress> owasMap = new Map<String,OrgWideEmailAddress>();
            for (OrgWideEmailAddress owa : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                    owasMap.put(String.valueOf(owa.Address), owa);
            }
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
            List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
            owa.add(owasMap.get(emailCorreoEntrante));

            String htmlBody = '';
            String subject = '';
            List<EmailTemplate> plantilla = [SELECT HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'CC_CasoDerivadoBPO' LIMIT 1];
            if (plantilla != null) {
                    htmlBody = plantilla[0].HtmlValue;
                    subject = plantilla[0].Subject;
            }
            String toAddress = CC_Settings__c.getValues('CC_CodigosOnboarding')?.CC_Configuracion_1__c;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setHtmlBody(htmlBody);
            email.setSaveAsActivity(true);
            email.setTreatBodiesAsTemplate(true);
            email.setWhatId(caso[0].Id);
            email.setTargetObjectId(caso[0].ContactId);
            email.setTreatTargetObjectAsRecipient(false);
            email.setOrgWideEmailAddressId(owa[0].Id);
            email.setToAddresses(new List<String>{toAddress});
            email.subject = subject;
            allmsg.add(email);

            Task tarea = new Task();
            tarea.Subject = 'Derivación a BPO';
            tarea.Status = 'Completed';
            tarea.Priority = 'Normal';
            tarea.WhatId = caso[0].Id;
            tarea.Type = 'Derivación a BPO';
            insert tarea;

            if(!allmsg.isEmpty()) {
                try {
                    Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false); // Enviamos el correo
                    if (caso[0].CBK_Case_Extension_Id__c != null) {
                        List<CBK_Case_Extension__c> caseExtension = [SELECT CC_DerivadoBPO__c FROM CBK_Case_Extension__c WHERE Id = :caso[0].CBK_Case_Extension_Id__c LIMIT 1];
                        if (!caseExtension.isEmpty()) {
                                caseExtension[0].CC_DerivadoBPO__c = true;
                                update caseExtension;
                        }
                    }
                    if (caso[0].Status == 'Activo' && (caso[0].CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c == 'Desistir' || caso[0].CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c == 'Desistir')) {
                        caso[0].Status = 'Cerrado';
                        update caso;
                    }
                } catch(exception e) {
                    String exc = e.getMessage();
                    CBK_Log.error(e + '-' + exc);
                }
            }
        }
    }

    @AuraEnabled
    public static void cerrarCaso(String recordId) {
        List<Case> caso = [SELECT Status FROM Case WHERE Id = :recordId];
        if (!caso.isEmpty()) {
            caso[0].Status = 'Cerrado';
            update caso;
        }
    }
}