public class CC_Aviso_Cierre_GestorInTouch {
	@InvocableMethod
    public static void avisoGestor(List<Id> idsCasos) {
        avisoGestorFuture(idsCasos);
    }
    @future
    public static void avisoGestorFuture(List<Id> idsCasos)
    {
        if (idsCasos == null || idsCasos.isEmpty())
        {
            return;
        }

        Id plantillaId;
        List<EmailTemplate> plantillaSFDC = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Comunicacion_Gestor_Intouch_Cierre_Caso_CAS_Informal'];
        if (plantillaSFDC.isEmpty())
        {
            return;
        }else{
            plantillaId = plantillaSFDC[0].Id;
        }

        // Preparar mapa con los remitentes a enviar correo.
        List<String> todosBuzones = new List<String>();
        Map<String,String> buzonesConfigurados = new Map<String,String>();
        Map<String,String> remitentesIds = new Map<String,String>();
        for (CC_Buzones_Por_Defecto__mdt buzonMDT : [SELECT Id, CC_Canal_Procedencia__c, CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt])
        {
            buzonesConfigurados.put(buzonMDT.CC_Canal_Procedencia__c, buzonMDT.CC_Direccion_Correo__c);
            todosBuzones.add(buzonMDT.CC_Direccion_Correo__c);
        }

        if (!todosBuzones.isEmpty())
        {
            for(OrgWideEmailAddress remitenteOWA : [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address IN :todosBuzones])
            {
                remitentesIds.put(remitenteOWA.Address, remitenteOWA.Id);
            }
        }

        String remitenteDefault = '';
        List<CC_Buzones_Por_Defecto__mdt> buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                            WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano'
                                                            AND CC_Activo__c = true];
        if (!buzonDefault.isEmpty())
        {
            List<OrgWideEmailAddress> emailDefault = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address = :buzonDefault[0].CC_Direccion_Correo__c];
            if (!emailDefault.isEmpty())
            {
                remitenteDefault = emailDefault[0].Id;
            }
        }

        for(Case caso : [SELECT Id, CC_Canal_Procedencia__c, ContactId, AccountId, Account.CC_Centro_Gestor_InTouch__c,
                            Account.CC_Centro_Gestor_InTouch__r.CC_Email__c,
                            Account.CC_Centro_Gestor_InTouch__r.CC_Tipo_Centro__c,
                            Account.RecordType.DeveloperName
                            FROM Case WHERE Id IN :idsCasos])
        {
            if (caso.AccountId != null && caso.Account.CC_Centro_Gestor_InTouch__r.CC_Tipo_Centro__c == 'OF' &&
            caso.Account.CC_Centro_Gestor_InTouch__r.CC_Email__c != null && (
                caso.Account.RecordType.DeveloperName == 'CC_Cliente' || caso.Account.RecordType.DeveloperName == 'CC_ClientePA'
            ))
            {
                String correo = caso.Account.CC_Centro_Gestor_InTouch__r.CC_Email__c;
                String casoId = caso.Id;
                String contactId = caso.ContactId;
                String canalProcedencia = caso.CC_Canal_Procedencia__c; 

                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

                // Recuperar buzón de correo.
                String remitenteCorreo = '';
                if (buzonesConfigurados.get(canalProcedencia) != null)
                {
                    if (remitentesIds.get(buzonesConfigurados.get(canalProcedencia)) != null)
                    {
                        remitenteCorreo = remitentesIds.get(buzonesConfigurados.get(canalProcedencia));
                    }
                }

                if (String.isBlank(remitenteCorreo))
                {
                    remitenteCorreo = remitenteDefault;
                }

                if (String.isNotBlank(remitenteCorreo)) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(plantillaId);
                    mail.setSaveAsActivity(true);
                    mail.setWhatId(casoId);
                    mail.setTargetObjectId(contactId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    String[] toAddresses = new String[] {correo};
                        mail.setToAddresses(toAddresses);
                    mail.setOrgWideEmailAddressId(remitenteCorreo);
                    allmsg.add(mail);
                    
                    if (!allmsg.isEmpty())
                    {
                        List<Messaging.SingleEmailmessage> oMaxEnvios = new List<Messaging.SingleEmailmessage>();
                        Integer iMensaje = 0;
                        Integer iTotalMsj = allmsg.size();

                        for (Integer iMens = 0; iMens < iTotalMsj; iMens++) {
                            oMaxEnvios.add(allmsg[iMens]);
                            iMensaje = iMensaje + 1;

                            if (iMensaje == 10 || iMens == iTotalMsj-1)
                            {
                                // Enviar bloques de 10 mensajes máximo.

                                List<Messaging.SendEmailResult> result = Messaging.sendEmail(oMaxEnvios, false);

                                // Resetear variable de conteo y lista de envíos.
                                oMaxEnvios.clear();
                                iMensaje = 0;

                            }
                        }                        
                    }  
                } 
            }
        }
    }
}