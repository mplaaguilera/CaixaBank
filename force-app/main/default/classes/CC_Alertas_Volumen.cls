public with sharing class CC_Alertas_Volumen {
	@InvocableMethod
    public static void contadorAsset(List<Id> idsCasos) {
        
        Set<Id> idsCasosSet = new Set<Id>(idsCasos);
        //el id de asset // '02i5E000003MG46QAG'
        //recuperar el id del activo
        Id assetId =[SELECT AssetId FROM Case WHERE Id in :idsCasosSet].AssetId;

        Asset asset=[SELECT CC_Familia_Activo__c, CC_Tipo_Activo__c FROM Asset WHERE Id= :assetId WITH SECURITY_ENFORCED];
        
        //para recuperar los 3 valores de cada activo.
        String reiteraciones = '%'+asset.CC_Familia_Activo__c+'-'+asset.CC_Tipo_Activo__c+' - Reiteraciones%';        
        String periodoEvaluacion = '%'+asset.CC_Familia_Activo__c+'-'+asset.CC_Tipo_Activo__c+' - Periodo de evaluacion%';        
        String cadenaDest = '%'+asset.CC_Familia_Activo__c+'-'+asset.CC_Tipo_Activo__c+' - Destinatarios%';

        Datetime d = datetime.now().addhours(-Integer.valueOf([SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :periodoEvaluacion].CC_Valor__c));
        Integer numeroCasos=[SELECT COUNT() FROM Case WHERE AssetId= :assetId and createdDate > :d WITH SECURITY_ENFORCED];
        Integer numReiteraciones = Integer.valueOf([SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :reiteraciones].CC_Valor__c);
        Integer calculoResto = math.mod(numeroCasos, numReiteraciones);

        String destinatarios= [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :cadenaDest].CC_Valor__c;
        if(calculoResto==0){
            notificaEmail(idsCasosSet, destinatarios);
        }
    }

    public static void notificaEmail(Set<Id> idsCasosSet, String destinatarios){
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'CC_TestPlantilla';
        template.DeveloperName = 'CC_TestPlantilla';
        template.TemplateType = 'Text';
        
        
		List<Case> casos = [SELECT CC_Idioma__c, CC_Canal_Procedencia__c, Contact.Id FROM Case WHERE Id IN :idsCasosSet WITH SECURITY_ENFORCED]; 
        if(!casos.isEmpty()){

            Set<String> setCanales = new Set<String>();
            Set<String> setIdiomas = new Set<String>();
            Set<String> setDirecciones = new Set<String>();
            Map<String, Id> mapRemitentes = new Map<String, Id>();
            CC_Buzones_Por_Defecto__mdt buzonDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true WITH SECURITY_ENFORCED LIMIT 1];
            setDirecciones.add(buzonDefecto.CC_Direccion_Correo__c);

            for(Case caso : casos){
                setCanales.add(caso.CC_Canal_Procedencia__c);
                setIdiomas.add(caso.CC_Idioma__c);
            }

            List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c, CC_Canal_Procedencia__c, CC_Idioma__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c IN :setCanales AND CC_Idioma__c IN :setIdiomas WITH SECURITY_ENFORCED];
            
            for (CC_Buzones_Por_Defecto__mdt buzon : buzones) {
                setDirecciones.add(buzon.CC_Direccion_Correo__c);
            }

            List<OrgWideEmailAddress> remitentes = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN :setDirecciones WITH SECURITY_ENFORCED];
            
            for (OrgWideEmailAddress remitente : remitentes) {
                mapRemitentes.put(remitente.Address, remitente.Id);
            }

            for(Case caso : casos){
                String correo = destinatarios;
                String casoId = caso.Id;
                String remitente = buzonDefecto.CC_Direccion_Correo__c;


                //Plantilla para enviar correo con Template
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                
                for (CC_Buzones_Por_Defecto__mdt buzon : buzones) {
                    if(buzon.CC_Canal_Procedencia__c == caso.CC_Canal_Procedencia__c && buzon.CC_Idioma__c == caso.CC_Idioma__c){
                        remitente = buzon.CC_Direccion_Correo__c;
                        break;
                    }
                }

                if (!buzones.isEmpty()) {
                    
                    Id remitenteId = mapRemitentes.get(remitente);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(template.Id);
                    mail.setSaveAsActivity(true);
                    mail.setWhatId(casoId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    String[] toAddresses = new String[] {correo};
                    mail.setToAddresses(toAddresses);
                    mail.setOrgWideEmailAddressId(remitenteId);
                    allmsg.add(mail);
                    
                    if (!allmsg.isEmpty()){
                        //Enviamos el email
                        Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);
                    }  
                }   
            }
        }
    }
}