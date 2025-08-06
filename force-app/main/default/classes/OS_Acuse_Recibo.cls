public with sharing class OS_Acuse_Recibo {

    static public void enviarAcuse(Case caso, String fromAddress, String direccionBuzon, String nombreBuzon, String eBody){
        
        Boolean enviarAcuse = false;
        String correoEnviar;
        List<EmailTemplate> eTemplates = new List<EmailTemplate>();
        List<Case> lstCaso = new List<Case>([SELECT CC_Idioma__c FROM Case WHERE id = :caso.id]);
        List<CC_Lista_Valores__c> listaEnvio = new List<CC_Lista_Valores__c>();
        List<String> listaBuzones = new List<String>();
        List<CC_Lista_Valores__c> clasificacionesLV = [SELECT Id, Name, CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c
                                                                            WHERE CC_Lista__r.Name = 'COPS: Acuse de recibo por Buzones' AND CC_Activa__c = TRUE
                                                               AND Name = :caso.CC_Canal_Procedencia__c ];
        String buzon =[SELECT CC_Canal_Procedencia__c,CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Direccion_Correo__c =:direccionBuzon LIMIT 1][0].CC_Canal_Procedencia__c;
        if(buzon != null){

            if(!clasificacionesLV.isEmpty()){
                for(CC_Lista_Valores__c lv : clasificacionesLV){
                    if(!lstCaso.isEmpty() && !(buzon == lv.Name && fromAddress == lv.CC_Valor__c)){
                        listaEnvio.add(lv);
                        listaBuzones.add(lv.Name);
                        enviarAcuse = true;
                    }
                }
                for(CC_Lista_Valores__c lv : clasificacionesLV){
                    if(buzon == lv.Name && lv.CC_Valor__c == fromAddress){
                        enviarAcuse=false;
                    }
                }
                if(lstCaso[0].CC_Idioma__c != null && !listaEnvio.isEmpty())
                {
                    //Filtrar plantilla por idioma del caso y buzón de procedencia 
                    String idiomaCaso = lstCaso[0].CC_Idioma__c;
                    String idioma = idiomaCaso.toUpperCase();
                    String eTempName = 'Acuse recibo ' + idioma;
        
                    eTemplates = new List<EmailTemplate>([SELECT id, Subject FROM EmailTemplate WHERE Name = :eTempName AND Folder.Name IN :listaBuzones]);                
                }
    
                if(eTemplates.isEmpty())
                {
                    eTemplates = new List<EmailTemplate>([SELECT id, Subject FROM EmailTemplate WHERE Name = 'Acuse recibo ES' AND Folder.Name IN :listaBuzones]);
                }
            }
        }
        

        
        /*if(lstCaso.size() > 0 && clasificacionesLV != null && !(buzon == clasificacionesLV.Name && fromAddress == clasificacionesLV.CC_Valor__c){
            enviarAcuse = true;
        
            if(lstCaso[0].CC_Idioma__c != null)
            {
                //Filtrar plantilla por idioma del caso y buzón de procedencia 
                String idiomaCaso = lstCaso[0].CC_Idioma__c;
                String idioma = idiomaCaso.toUpperCase();
                String eTempName = 'Acuse recibo ' + idioma;
    
                eTemplates = new List<EmailTemplate>([SELECT id FROM EmailTemplate WHERE Name = :eTempName AND Folder.Name = :clasificacionesLV.Name]);                
            }

            if(eTemplates.size() == 0)
            {
                eTemplates = new List<EmailTemplate>([SELECT id FROM EmailTemplate WHERE Name = 'Acuse recibo ES' AND Folder.Name = :clasificacionesLV.Name]);
            }
        } */
        
        //Envio acuse
        if(enviarAcuse)
        {
            OrgWideEmailAddress[] owea;
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            if(!listaEnvio.isEmpty())
            {
                owea = [select Id from OrgWideEmailAddress where Address = :direccionBuzon];
            }
            
            
            List<String> address = new List<String>();
            address.add(fromAddress);
            
            if(!eTemplates.isEmpty())
            {
                email = Messaging.renderStoredEmailTemplate(eTemplates[0].id, null, caso.id);
                message.setToAddresses(address);
                message.setSubject(eTemplates[0].Subject);
            }
            
            
            //Generar semilla 
            String nuevaReferencia = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id);
            String mensajeSemilla = '';
            
            mensajeSemilla += '<br/><br/><font color="gray">';
            mensajeSemilla += 'Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@' + nuevaReferencia + '#.';
            mensajeSemilla += '</font>';
            //Mostrar cuerpo del correo y el histórico             
            String body = email.htmlbody; // + '<br><br>_________________________________________________________________________________________________________________________________<br><br>' 
            //+ 'de: ' + fromAddress + '<br><br>' + eBody + '<br><br><br><br>' + mensajeSemilla; 
            
            for(EmailMessage eM : [SELECT TextBody, FromName FROM EmailMessage WHERE ParentId = :caso.id ORDER BY MessageDate DESC])
            {
                body = body + '<br><br>_________________________________________________________________________________________________________________________________<br><br>'
                + 'de: ' + eM.FromName + '<br><br>' + eM.TextBody + '<br><br><br><br>' + mensajeSemilla;
            }
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(true);
            message.setWhatId(caso.id);
            message.setHtmlBody(body);         
                if(!owea.isEmpty()){
                  message.setOrgWideEmailAddressId(owea.get(0).Id);
                //Omitir validación trigger
                CSBD_Bypass_Trigger.bypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
                try {
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                }
                finally {
                    CSBD_Bypass_Trigger.undoBypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
                }  
                }
                  
            //} 
            
            //Insertar actividad con la semilla en el caso
            Task nuevaTarea = new Task();
            Date todaysDate = system.today();
            nuevaTarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            nuevaTarea.WhatId = caso.id;
            nuevaTarea.Type = 'Acuse de recibo';
            nuevaTarea.Subject = 'Acuse de recibo';
            nuevaTarea.Status = 'Completed';
            nuevaTarea.ActivityDate = todaysDate;
            nuevaTarea.CC_Fecha_Inicio__c = Datetime.valueOf(System.now());
            nuevaTarea.CC_Fecha_Fin__c = Datetime.valueOf(System.now());
            nuevaTarea.Description = 'Caso principal: ' + caso.id;
            nuevaTarea.CC_Referencia_Correo_Saliente__c = nuevaReferencia;
            
            insert nuevaTarea;
            
        }                      
    }
}