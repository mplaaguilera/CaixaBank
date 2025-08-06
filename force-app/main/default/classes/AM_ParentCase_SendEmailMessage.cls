public with sharing class AM_ParentCase_SendEmailMessage implements Queueable{
    
    public List<Case> casosHijos = new List<Case>();
    public Map<String, Id> mapaOWA = new Map<String, Id>();
    public String operativa = '';
    public Map<Id, List<EmailMessage>> listaEmailMessageCasoHijo = new Map<Id, List<EmailMessage>> ();
    public List<EmailServicesAddress> emailServiceAddressCAM = new List<EmailServicesAddress>();
    public List<AM_Correos_Buzones_Entrada__mdt> emailServiceAddresMetadataCAM = new List<AM_Correos_Buzones_Entrada__mdt>();
    public String cuerpoPlantilla = '';
    public String subjectPlantilla = '';
    public List<String> destinatariosPara = new List<String>();
    public List<String> destinatariosCC = new List<String>();
    public Integer iteracionesMaximas;

    public AM_ParentCase_SendEmailMessage(AM_Parent_Case_Controller.ValoresEmailWrapper envioEmailQueueable) {
        this.casosHijos = envioEmailQueueable.casosHijos;
        this.mapaOWA = envioEmailQueueable.mapaOWA;
        this.operativa = envioEmailQueueable.operativa;
        this.listaEmailMessageCasoHijo = envioEmailQueueable.listaEmailMessageCasoHijo;
        this.emailServiceAddressCAM = envioEmailQueueable.emailServiceAddressCAM;
        this.emailServiceAddresMetadataCAM = envioEmailQueueable.emailServiceAddresMetadataCAM;
        this.cuerpoPlantilla = envioEmailQueueable.cuerpoPlantilla;
        this.subjectPlantilla = envioEmailQueueable.subjectPlantilla;
        this.destinatariosPara = envioEmailQueueable.destinatariosPara;
        this.destinatariosCC = envioEmailQueueable.destinatariosCC;
        this.iteracionesMaximas = envioEmailQueueable.iteracionesMaximas;
    }

    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();
        List<Case> casosIterados = new List<Case>();
        Integer iteracion = 0;

        for (Case casoHijo : casosHijos) {
            //Solo si la operativa es Sol Info o Responder a cliente:
            if(operativa == 'solicitar' || operativa == 'responderCliente'){
                List<EmailMessage> listaMessageCasoHijo = new List<EmailMessage>();
                if(listaEmailMessageCasoHijo.containsKey(casoHijo.Id)){
                    listaMessageCasoHijo = listaEmailMessageCasoHijo.get(casoHijo.Id);
                }
                Map<String, List<String>> paraCC = new Map<String, List<String>> (AM_Parent_Case_Controller.correoCaso(casoHijo, listaMessageCasoHijo, emailServiceAddressCAM, emailServiceAddresMetadataCAM));
                destinatariosPara = paraCC.get('Para');
                destinatariosCC = paraCC.get('Cc');
            }
            
            String textoSemilla = '<br/><br/><span style="font-family: \'Arial\'; font-size: 12px; color: gray;">';
            textoSemilla += 'Por favor, mantenga la siguiente referencia al responder a este correo electrónico: #@' + casoHijo.CC_Referencia_Correo_Saliente__c + '#.';
            textoSemilla += '</span>';
            String cuerpoPlantillaCaso = cuerpoPlantilla + textoSemilla;
            
            List<Messaging.RenderEmailTemplateBodyResult> renderedEmailTemplateLista = Messaging.renderEmailTemplate(casoHijo.ContactId, casoHijo.Id, new List<String>{cuerpoPlantillaCaso});
            if (!renderedEmailTemplateLista.isEmpty()) {
                cuerpoPlantillaCaso = renderedEmailTemplateLista[0].getMergedBody();
            }

            String subjectPlantillaCaso = '';
            List<Messaging.RenderEmailTemplateBodyResult> renderedEmailSubjectLista = Messaging.renderEmailTemplate(casoHijo.ContactId, casoHijo.Id, new List<String>{subjectPlantilla});
            if (!renderedEmailSubjectLista.isEmpty()) {
                subjectPlantillaCaso = renderedEmailSubjectLista[0].getMergedBody();
            }

            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
            correo.setTargetObjectId(casoHijo.ContactId);
            correo.setWhatId(casoHijo.Id);
            if(mapaOWA.containsKey(casoHijo.CC_Canal_Procedencia__c)){
                correo.setOrgWideEmailAddressId(mapaOWA.get(casoHijo.CC_Canal_Procedencia__c));
            }
            correo.setToAddresses(destinatariosPara);
            if(!destinatariosCC.isEmpty()){
                correo.setCcAddresses(destinatariosCC);
            }
            if (String.isNotEmpty(subjectPlantillaCaso)) {
                correo.setSubject(subjectPlantillaCaso);
            }
            if (String.isNotEmpty(cuerpoPlantillaCaso)) {
                correo.setHtmlBody(cuerpoPlantillaCaso);
            }
            correos.add(correo);
            casosIterados.add(casoHijo);

            iteracion += 1;
            if(iteracion == iteracionesMaximas) {
                break;
            }
        }
        if(!correos.isEmpty()) {      
            List<Messaging.SendEmailResult> resultadoEnvios = Messaging.sendEmail(correos,false);
            CBK_log.debug('resultadoEnvios: ' + resultadoEnvios);

            for(Case caso: casosIterados) {
                casosHijos.remove(0);
            }
            if(!casosHijos.isEmpty()) {
                AM_Parent_Case_Controller.ValoresEmailWrapper valoresEmail = new AM_Parent_Case_Controller.ValoresEmailWrapper();
                valoresEmail.casosHijos = casosHijos;
                valoresEmail.mapaOWA = mapaOWA;
                valoresEmail.operativa = operativa;
                valoresEmail.listaEmailMessageCasoHijo = listaEmailMessageCasoHijo;
                valoresEmail.emailServiceAddressCAM = emailServiceAddressCAM;
                valoresEmail.emailServiceAddresMetadataCAM = emailServiceAddresMetadataCAM;
                valoresEmail.cuerpoPlantilla = cuerpoPlantilla;
                valoresEmail.subjectPlantilla = subjectPlantilla;
                valoresEmail.destinatariosPara = destinatariosPara;
                valoresEmail.destinatariosCC = destinatariosCC;
                valoresEmail.iteracionesMaximas = iteracionesMaximas;
                if(!test.isRunningTest()) {
                	AM_ParentCase_SendEmailMessage envioEmailQueueable = new AM_ParentCase_SendEmailMessage(valoresEmail);
                	ID jobID = System.enqueueJob(envioEmailQueueable);
                }
            }
        }
    }
}