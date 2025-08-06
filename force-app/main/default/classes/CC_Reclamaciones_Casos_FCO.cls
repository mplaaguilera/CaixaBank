public class CC_Reclamaciones_Casos_FCO implements Database.Batchable<SObject>, Database.Stateful {
    @TestVisible
    private String templateName = 'Consultas Operativas Canal Formulario - Caso gestionado';

    public CC_Reclamaciones_Casos_FCO() {
        CBK_Log.debug('Iniciación - Batch CC_Reclamaciones_Casos_FCO',logginglevel.INFO);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, (SELECT Id FROM Resultados_de_encuesta__r), CC_Reclamacion_FCO__c, ContactId, Contact.Email FROM Case WHERE CC_Canal_Procedencia__c = \'Formulario Consultas Operativas\' AND CC_Fecha_Reapertura__c = null AND Status = \'Cerrado\' AND CC_Reclamacion_FCO__c = false ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> casos) {   
        try {
            List<Case> casosUpd = new List<Case>();
            Set<Id> idCasos = new Set<Id>();
            for (Case caso : casos) {
                idCasos.add(caso.Id);
            }
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Map <String,OrgWideEmailAddress> owasMap = new Map<String,OrgWideEmailAddress>();
            for (OrgWideEmailAddress owa : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                owasMap.put(String.valueOf(owa.Address), owa);
            }
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [
                SELECT CC_Direccion_Correo__c 
                FROM CC_Buzones_Por_Defecto__mdt 
                WHERE CC_Canal_Procedencia__c = 'Por defecto' 
                AND CC_Idioma__c = 'Castellano' 
                AND CC_Activo__c = true LIMIT 1
            ];
            //Plantilla que se usara en el correo
            String htmlBody = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Reclamacion_Encuesta_FCO_cas' LIMIT 1]?.HtmlValue;
            if (htmlBody == null) {
                return;
            }
            //Recuperamos el valor de CC_Settings para saber las horas que deben pasar para el correo automatico
            Integer horasCorreoAutomatico = Integer.valueOf([SELECT CC_Configuracion_1__c FROM CC_Settings__c WHERE Name = 'CC_FormularioConsultasOperativas' LIMIT 1].CC_Configuracion_1__c);

            if (!casos.isEmpty()) {
                //Comprobamos si los casos han sido gestionados
                List<EmailMessage> correos = [
                    SELECT HtmlBody, TextBody, ParentId, CreatedDate, ToAddress 
                    FROM EmailMessage 
                    WHERE Status = '3' 
                    AND CC_Plantilla__c =: templateName 
                    AND ParentId IN: idCasos
                ];
              
                Long hoy = CBK_UtilsDate.nowSYS().getTime(); 
                for (Case caso : casos) {   
                    if (caso.Resultados_de_encuesta__r.size() == 0) {
                        for (EmailMessage correo : correos) {
                            if (caso.Id == correo.ParentId) {
                                Long fechaCorreo = correo.CreatedDate.getTime();
                                Long horasDiff = ((((hoy - fechaCorreo) / 1000) / 60) / 60);
                                if (horasDiff > horasCorreoAutomatico) {                                
                                    String emailCorreoEntrante;
                                    if(correo.ToAddress.contains(';')){
                                        List<String> emailAddress = correo.ToAddress.split('; ');
                                        for(String email : emailAddress){
                                            if(owasMap.containsKey(email)){
                                                emailCorreoEntrante = email;
                                            }
                                        }
                                    } else {
                                        if(owasMap.containsKey(correo.ToAddress)){
                                            emailCorreoEntrante = correo.ToAddress;
                                        }
                                    }
                                    
                                    if(emailCorreoEntrante == null){
                                        emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
                                    }
                                    
                                    Id owaId = owasMap.get(emailCorreoEntrante)?.Id;
                                    
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                    email.setHtmlBody(htmlBody);
                                    email.setSaveAsActivity(true);
                                    email.setTreatBodiesAsTemplate(true);
                                    email.setWhatId(caso.Id);
                                    email.setTargetObjectId(caso.ContactId);
                                    email.setTreatTargetObjectAsRecipient(false);
                                    email.setOrgWideEmailAddressId(owaId);
                                    email.subject = email.Subject;
                                    List<String> toAddress = new List<String>();
                                    toAddress.add(caso.Contact.Email);
                                    email.setToAddresses(toAddress);
                                    allmsg.add(email);

                                    //Marcar flag reclamacion caso FCO en el caso
                                    caso.CC_Reclamacion_FCO__c = true;
                                    casosUpd.add(caso);
                                }
                            }
                        }
                    }
                }

                if (!casosUpd.isEmpty()) {
                    update casosUpd;
                }

                if (!allmsg.isEmpty()){
                    Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);
                }
            }
        } catch (Exception e) {
            CBK_Log.error(e);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('Finalización - Batch CC_Reclamaciones_Casos_FCO',logginglevel.INFO);
    }
}