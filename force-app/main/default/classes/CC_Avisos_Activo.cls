public with sharing class CC_Avisos_Activo {
	@InvocableMethod
    public static void avisoActivos(List<Id> idsCasos) {
        avisoActivosFuture(idsCasos);
    }
    
    @future
    public static void avisoActivosFuture(List<Id> idsCasos) {
        
        Set<Id> idsCasosSet = new Set<Id>(idsCasos);
        
        Case caso =[SELECT AssetId, Asset.Name, CC_Oficina__r.Name FROM Case WHERE Id in :idsCasosSet  WITH SECURITY_ENFORCED];
        if(caso != null){
            Asset asset=[SELECT CC_Familia_Activo__c, CC_Tipo_Activo__c FROM Asset WHERE Id= :caso.AssetId  WITH SECURITY_ENFORCED];
            if(asset != null){
            
                //para recuperar los 3 valores de cada lista de valores 'Avisos sobre Activos'
                String cadena = asset.CC_Familia_Activo__c;
                
                
                if(![SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :('%' + cadena + '%') WITH SECURITY_ENFORCED].isEmpty()){
                    String reiteraciones = '%'+cadena+' - Reiteraciones%';        
                    String periodoEvaluacion = '%'+cadena+' - Periodo de evaluacion%';        
                    String cadenaDest = '%'+cadena+' - Destinatarios%';
                    if(![SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :periodoEvaluacion  WITH SECURITY_ENFORCED].isEmpty() && ![SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :reiteraciones  WITH SECURITY_ENFORCED].isEmpty() &&![SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :cadenaDest  WITH SECURITY_ENFORCED].isEmpty()){
                        
                        Integer hours = Integer.valueOf([SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :periodoEvaluacion].CC_Valor__c)*(-1);
        
                        Datetime d = datetime.now().addhours(hours);
                        Integer numeroCasos=[SELECT COUNT() FROM Case WHERE AssetId= :caso.assetId and createdDate > :d WITH SECURITY_ENFORCED];
                
                        Integer numReiteraciones = Integer.valueOf([SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :reiteraciones WITH SECURITY_ENFORCED].CC_Valor__c);
                
                        Integer calculoResto = Math.mod(numeroCasos, numReiteraciones);
                
                        String destinatarios= [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name LIKE :cadenaDest WITH SECURITY_ENFORCED].CC_Valor__c;

                        if(![SELECT Id FROM Case WHERE AssetId= :caso.assetId and createdDate > :d WITH SECURITY_ENFORCED].isEmpty()){
                            if(calculoResto==0){
                                notificaEmail(numeroCasos, d, caso.AssetId, caso.Asset.Name, caso.CC_Oficina__r.Name, idsCasosSet, destinatarios);
                            }
                        }
                    }
                }
            }
    	}
    }
    
    public static void notificaEmail(Integer numeroCasos, Datetime d, Id assetId, String nombreActivo, String nombreOficina, Set<Id> idsCasosSet, String destinatarios){

		List<Case> casos = [SELECT CC_Idioma__c, CC_Canal_Procedencia__c, Contact.Id FROM Case WHERE Id IN :idsCasosSet WITH SECURITY_ENFORCED]; 
		if(!casos.isEmpty()) {
            Set<String> setProcedencia = new Set<String>();
            Set<String> setIdioma = new Set<String>();
            Set<String> setDirecciones = new Set<String>();
            Map<String, Id> mapRemitentes = new Map<String, Id>();
            List<EmailTemplate> plantillaList = [SELECT Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'CC_Aviso_sobre_Activo' WITH SECURITY_ENFORCED LIMIT 1];
            String datosCasos = '';

            for(Case c : [SELECT ID, CreatedDate, CC_MCC_Tematica__r.Name, CC_MCC_Motivo__r.Name, CC_MCC_ProdServ__r.Name, CaseNumber  FROM Case WHERE AssetId = :assetId and createdDate > :d WITH SECURITY_ENFORCED]){
                datosCasos += c.CreatedDate+' - '+c.CaseNumber+': '+c.CC_MCC_Tematica__r.Name+' > '+c.CC_MCC_ProdServ__r.Name+' > '+c.CC_MCC_Motivo__r.Name+'<br><br>';
            }

            for(Case caso : casos) {
                setProcedencia.add(caso.CC_Canal_Procedencia__c);
                setIdioma.add(caso.CC_Idioma__c);
            }

            CC_Buzones_Por_Defecto__mdt buzonDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true WITH SECURITY_ENFORCED LIMIT 1];
            setDirecciones.add(buzonDefecto.CC_Direccion_Correo__c);

            List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c IN :setProcedencia AND CC_Idioma__c IN :setIdioma WITH SECURITY_ENFORCED];
            
            for (CC_Buzones_Por_Defecto__mdt buzon : buzones) {
                setDirecciones.add(buzon.CC_Direccion_Correo__c);
            }

            List<OrgWideEmailAddress> remitentes = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN :setDirecciones WITH SECURITY_ENFORCED];

            for (OrgWideEmailAddress remitente : remitentes) {
                mapRemitentes.put(remitente.Address, remitente.Id);
            }

            for(Case caso : casos) {
                
                String casoId = caso.Id;
                String templateSubject = plantillaList[0].Subject;
                String templateBody = plantillaList[0].HtmlValue;
                
                String emailSubject = templateSubject.replace('[num_casos]', String.valueOf(numeroCasos));
                templateBody = templateBody.replace('[num_casos]', String.valueOf(numeroCasos));
                templateBody = templateBody.replace('[nombre_activo]', nombreActivo);
                templateBody = templateBody.replace('[nombre_oficina]', nombreOficina);
                templateBody = templateBody.replace('[datos_casos]', datosCasos);
                
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                
                
                String remitente = buzonDefecto.CC_Direccion_Correo__c;
				if (!buzones.isEmpty()) {
                    for (CC_Buzones_Por_Defecto__mdt buzon : buzones) {
                        if(buzon.CC_Canal_Procedencia__c == caso.CC_Canal_Procedencia__c && buzon.CC_Idioma__c == caso.CC_Idioma__c){
                            remitente = buzon.CC_Direccion_Correo__c;
                            break;
                        }
                    }
                }  
                    
                    Id remitenteId = mapRemitentes.get(remitente);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //mail.setSaveAsActivity(true);
                    //mail.setWhatId(casoId);
                    mail.setTemplateId(null);
                    mail.setTargetObjectId(null);
                    mail.setTreatTargetObjectAsRecipient(false);
                    List<String> toAddresses = new List<String>();
                    if (!String.isEmpty(destinatarios)) {
                        if (destinatarios.contains(';')) {
                            toAddresses = destinatarios.split(';');
                        }
                        else {
                            toAddresses.add(destinatarios);
                        }
                    }
                    mail.setToAddresses(toAddresses);
                    mail.setOrgWideEmailAddressId(remitenteId);
                    
                    mail.setSubject(emailSubject);
                    mail.setHtmlBody(templateBody);
                    
                    allmsg.add(mail);
                    
                    if (!allmsg.isEmpty()){
                        //Enviamos el email
                        
                        Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);
                        
               }          
           }        
        }
    }
}