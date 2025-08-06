public with sharing class AM_Parent_Case_Controller {

    public class ValoresEmailWrapper {
        public List<Case> casosHijos {get;set;} 
        public Map<String, Id> mapaOWA {get;set;} 
        public String operativa {get;set;} 
        public Map<Id, List<EmailMessage>> listaEmailMessageCasoHijo {get;set;} 
        public List<EmailServicesAddress> emailServiceAddressCAM {get;set;} 
        public List<AM_Correos_Buzones_Entrada__mdt> emailServiceAddresMetadataCAM {get;set;} 
        public String cuerpoPlantilla {get;set;} 
        public String subjectPlantilla {get;set;} 
        public List<String> destinatariosPara {get;set;} 
        public List<String> destinatariosCC {get;set;} 
        public Integer iteracionesMaximas {get;set;} 
    }

    @AuraEnabled
    public static Case datosCaso(Id recordId) {
        return [SELECT RecordTypeId, RecordType.DeveloperName, OwnerId, CaseNumber, CC_Canal_Procedencia__c, Contact.Phone, Status, CC_Idioma__c, CC_Canal_Respuesta__c
                FROM Case WHERE Id = :recordId];
    }

    @AuraEnabled
    public static EmailTemplate plantillaCaso(String plantillaId) {
        return [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Id  = :plantillaId];
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> buscarGruposColaboradores(String cadenaBusqueda) {
        //Se buscan grupos de colaborador de tipo grupo colaborador o centro CaixaBank
        return [SELECT Name FROM CC_Grupo_Colaborador__c
                WHERE OS_Negocio__c = 'CAM' AND Name LIKE :('%' + cadenaBusqueda + '%') AND
                (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador')
                OR RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank'))
                LIMIT 30];
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> buscarPlantillas(String cadenaBusqueda) {
        //Se buscan todas las plantillas
        return [SELECT Name FROM EmailTemplate WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND Folder.DeveloperName LIKE 'AM_%'  LIMIT 30];
    }

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getPlantillaGrupoList(Id grupoId, String tipoOperativa) {
        List<String> nombresPlantilla = new List<String>();
        for (CC_Grupo_Colaborador_Plantilla__c plantilla : [SELECT CC_Plantilla_DeveloperName__c FROM CC_Grupo_Colaborador_Plantilla__c
                                                            WHERE CC_Grupo_Colaborador__c = :grupoId AND CC_Operativa__c = :tipoOperativa]) {
            nombresPlantilla.add(plantilla.CC_Plantilla_DeveloperName__c);
        }

        List<OT_Picklist.Item> opcionesPlantillas = new List<OT_Picklist.Item>();
        for (EmailTemplate plantilla : [SELECT Name, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :nombresPlantilla ORDER BY Name ASC]) {
            opcionesPlantillas.add(new OT_Picklist.Item(plantilla.Id, plantilla.Name));
        }
        return opcionesPlantillas;
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getPlantillasResponder(Id recordId, String carpeta) {
        Case caso = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c
                        FROM Case WHERE Id = :recordId];

        Set<String> idsMCC = new Set<String>();
        if (caso.CC_MCC_Tematica__c != null) {
            idsMCC.add(caso.CC_MCC_Tematica__c);
        }
        if (caso.CC_MCC_ProdServ__c != null) {
            idsMCC.add(caso.CC_MCC_ProdServ__c);
        }
        if (caso.CC_MCC_Motivo__c != null) {
            idsMCC.add(caso.CC_MCC_Motivo__c);
        }
        List<CC_MCC_Plantilla__c> plantillasMCC = [SELECT CC_MCC_Plantilla_DeveloperName__c
                                                    FROM CC_MCC_Plantilla__c WHERE CC_MCC__c IN :idsMCC];

        List<EmailTemplate> plantillasEmail = new List<EmailTemplate>();
        List<pickListWrapper> wrapPlantilla = new List<PickListWrapper>();

        if (!plantillasMCC.isEmpty()) {
            Set<String> opcionesPlantillaMCC = new Set<String>();
            for (CC_MCC_Plantilla__c plantillaMCC : plantillasMCC) {
                opcionesPlantillaMCC.add(plantillaMCC.CC_MCC_Plantilla_DeveloperName__c);
            }

            plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta AND DeveloperName IN :opcionesPlantillaMCC ORDER BY Name ASC];
            if (plantillasEmail.isEmpty()) {
                plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta ORDER BY Name ASC];
            }
        } else {
            plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta ORDER BY Name ASC];
        }

        for (EmailTemplate plantillaEmail : plantillasEmail) {
            PickListWrapper wrap = new PickListWrapper(plantillaEmail.Name, plantillaEmail.Id);
            wrapPlantilla.add(wrap);
        }

        return wrapPlantilla;
    }

    @AuraEnabled
    public static void prepararCaso(Id idCaso, String plantilla, Boolean informarReferenciaCorreo, String operativa, String colaboradorName) {
        List<Case> casosHijos = [SELECT Id, CaseNumber, CC_MCC_Plantilla__c, CC_Ultima_Operativa_Correo__c, CC_Referencia_Correo_Saliente__c, CC_Grupo_Colaborador__c FROM Case WHERE ParentId =: idCaso];

        for(Case casoHijo : casosHijos){
            casoHijo.CC_MCC_Plantilla__c = plantilla;
            casoHijo.CC_Ultima_Operativa_Correo__c = operativa;
            if (informarReferenciaCorreo) {
                casoHijo.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(casoHijo.Id);
            }
            if(operativa == 'trasladar'){
                casoHijo.CC_Grupo_Colaborador__c = colaboradorName;
            }
        }
        update casosHijos;
    }

    @AuraEnabled
    public static void envioCorreo(Id idCasoPadre, String cuerpoPlantilla, String subjectPlantilla, List<String> destinatariosPara, List<String> destinatariosCC, String operativa){
        List<Case> casosHijos = [SELECT Subject, CC_Referencia_Correo_Saliente__c, ContactId, OS_Email__c, Contact.Email, CC_Buzon_Salida__c, CC_Canal_Procedencia__c FROM Case WHERE ParentId = :idCasoPadre];
        Map<Id, List<EmailMessage>> listaEmailMessageCasoHijo = new Map<Id, List<EmailMessage>> ();
        List<EmailServicesAddress> emailServiceAddressCAM = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress
                                                            WHERE Function.FunctionName = 'AM_EmailService'];
        List<AM_Correos_Buzones_Entrada__mdt> emailServiceAddresMetadataCAM = [SELECT AM_Email_Destino__c FROM AM_Correos_Buzones_Entrada__mdt];

        //Solo si la operativa es Sol Info o Responder a cliente:
        if(operativa == 'solicitar' || operativa == 'responderCliente'){
            Set<Id> casosHijoIds = (new Map<Id, Case>(casosHijos)).keySet();
            List<EmailMessage> listaEmailMessageAux = new List <EmailMessage>([SELECT ParentId, ToAddress, CcAddress FROM EmailMessage WHERE ParentId IN :casosHijoIds AND CC_Interno__c = false ORDER BY CreatedDate ASC]);
            
            for(EmailMessage emailMsg : listaEmailMessageAux){
                if(listaEmailMessageCasoHijo.containsKey(emailMsg.ParentId)){
                    listaEmailMessageCasoHijo.get(emailMsg.ParentId).add(emailMsg);
                }
                else {
                    listaEmailMessageCasoHijo.put(emailMsg.ParentId, new list<EmailMessage> {emailMsg});
                }
            }
        }
        Set<String> namesOWA = new Set<String>();
        for(Case unCasoHijo : casosHijos){
            namesoWA.add(unCasoHijo.CC_Canal_Procedencia__c);
        }

        if (!casosHijos.isEmpty()) {
            List<OrgWideEmailAddress> idOrgWideAddresses = new List<OrgWideEmailAddress> ([SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName IN :namesOWA]);
            Map<String, Id> mapaOWA = new Map<String, Id>();

            for(OrgWideEmailAddress orgWideAddress : idOrgWideAddresses){
                mapaOWA.put(orgWideAddress.DisplayName, orgWideAddress.Id);
            }

            Integer iteracionesMaximasSetting = 2;
            List<AM_Iteraciones_envio_email__c> iteracionesSetting = [SELECT AM_Numero_iteraciones__c FROM AM_Iteraciones_envio_email__c WHERE Name = 'Parent Case Iteraciones'];
            if(!iteracionesSetting.isEmpty()) {
                iteracionesMaximasSetting = Integer.valueOf(iteracionesSetting[0].AM_Numero_iteraciones__c);
            }

            ValoresEmailWrapper valoresEmail = new ValoresEmailWrapper();
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
            valoresEmail.iteracionesMaximas = iteracionesMaximasSetting;

            AM_ParentCase_SendEmailMessage envioEmailQueueable = new AM_ParentCase_SendEmailMessage(valoresEmail);
            ID jobID = System.enqueueJob(envioEmailQueueable);
        }
    }

    @AuraEnabled
    public static Map<String, List<String>> correoCaso(Case caso, List<EmailMessage> correosAnteriores, List<EmailServicesAddress> emailServiceAddress, List<AM_Correos_Buzones_Entrada__mdt> emailServiceAddresMetadata) {

        List<String> direccionesCorreoPara = new List<String>();
        List<String> direccionesCorreoCc = new List<String>();
        
        if (!String.isEmpty(caso.OS_Email__c)) {
            direccionesCorreoPara.add(caso.OS_Email__c);
        } else {
            direccionesCorreoPara.add(caso.Contact.Email);
        }
        //Direcciones de los correos anteriores (respetando si estaban en el "Para" o en "Copia")
        if(!correosAnteriores.isEmpty()){
            for (EmailMessage correoAnterior : correosAnteriores) {
                
                if (String.isNotBlank(correoAnterior.ToAddress)) {
                    for (String direccionPara : correoAnterior.ToAddress.split(';')) {
                        if(!direccionPara.equals(caso.CC_Buzon_Salida__c)){
                            direccionesCorreoPara.add(direccionPara.trim());
                        }
                    }
                }
                if (String.isNotBlank(correoAnterior.CcAddress)) {
                    for (String direccionCc : correoAnterior.CcAddress.split(';')) {
                        if(!direccionCc.equals(caso.CC_Buzon_Salida__c)){
                            direccionesCorreoCc.add(direccionCc.trim());
                        }
                    }
                }
            }
        }
        //Quitar duplicados + Si una dirección está en el "Para" se descarta del "CC"
        direccionesCorreoPara = descartarDuplicadosLista(direccionesCorreoPara);
        direccionesCorreoCc = descartarDuplicadosLista(direccionesCorreoCc);
        for (Integer i = direccionesCorreoCc.size() - 1; i >= 0; i--) {
            if (direccionesCorreoPara.contains(direccionesCorreoCc[i])) {
                direccionesCorreoCc.remove(direccionesCorreoCc.indexOf(direccionesCorreoCc[i]));
            }
        }
        //Quitar direcciones de los propios buzones de CAM
        Set<String> emailDirecciones = new Set<String>();
        
        for (EmailServicesAddress email : emailServiceAddress) {
            String direccionBuzonCAM = email.LocalPart + '@' + email.EmailDomainName;
            emailDirecciones.add(direccionBuzonCAM);
        }
        
        for(AM_Correos_Buzones_Entrada__mdt email : emailServiceAddresMetadata)
        {
            String direccionBuzonCAM = email.AM_Email_Destino__c;
            emailDirecciones.add(direccionBuzonCAM);
        }
        
        for(string email : emailDirecciones)
        {
            if (direccionesCorreoPara.contains(email)) {
                direccionesCorreoPara.remove(direccionesCorreoPara.indexOf(email));
            }
            if (direccionesCorreoCc.contains(email)) {
                direccionesCorreoCc.remove(direccionesCorreoCc.indexOf(email));
            }
        }
        Map<String, List<String>> retorno = new Map<String, List<String>>();
        retorno.put('Para', direccionesCorreoPara);
        retorno.put('Cc', direccionesCorreoCc);
        return retorno;
    }
    
    public static List<String> descartarDuplicadosLista(List<String> lista) {

        if (lista == null) {
            return null;
        } else {
            Set<String> aux = new Set<String>();
            for (String item : lista) {
                aux.add(item);
            }
            return new List<String>(aux);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Folder> getCarpetas(String carpetaDeveloperName) {
        List<Folder> carpetas = new List<Folder>();
        Id parentId = null;
        if (carpetaDeveloperName == null) {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'AM_Operativas' LIMIT 1].Id;
        } else {
            //parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
            List<Folder> carpetaPrincipal = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName];
            if (!carpetaPrincipal.isEmpty()) {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
            }
        }
        for (Folder carpeta : [SELECT Name, DeveloperName FROM Folder WHERE Type = 'EmailTemplate' AND ParentId = :parentId]) {
            carpetas.add(carpeta);
        }
        return carpetas;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getPlantillas(Id recordId, String carpeta) {
        Case caso = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :recordId];

        Set<String> idsMCC = new Set<String>();
        if (caso.CC_MCC_Tematica__c != null) {
            idsMCC.add(caso.CC_MCC_Tematica__c);
        }
        if (caso.CC_MCC_ProdServ__c != null) {
            idsMCC.add(caso.CC_MCC_ProdServ__c);
        }
        if (caso.CC_MCC_Motivo__c != null) {
            idsMCC.add(caso.CC_MCC_Motivo__c);
        }

        List<EmailTemplate> plantillasEmail = new List<EmailTemplate>();
        List<OT_Picklist.Item> wrapPlantilla = new List<OT_Picklist.Item>();

        if (!idsMCC.isEmpty()) {
            Set<String> opcionesPlantillaMCC = new Set<String>();
            for (CC_MCC_Plantilla__c plantillaMCC : [SELECT CC_MCC_Plantilla_DeveloperName__c FROM CC_MCC_Plantilla__c WHERE CC_MCC__c IN :idsMCC]) {
                opcionesPlantillaMCC.add(plantillaMCC.CC_MCC_Plantilla_DeveloperName__c);
            }

            plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta AND DeveloperName IN :opcionesPlantillaMCC ORDER BY Name ASC];
            if (plantillasEmail.isEmpty()) {
                plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta ORDER BY Name ASC];
            }
        } else {
            plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta ORDER BY Name ASC];
        }

        for (EmailTemplate plantillaEmail : plantillasEmail) {
            OT_Picklist.Item wrap = new OT_Picklist.Item(plantillaEmail.Name, plantillaEmail.Id);
            wrapPlantilla.add(wrap);
        }
        return wrapPlantilla;
    }

    @AuraEnabled(cacheable=true)
    public static List<Folder> subdirectorios(String rutaDevName) {
        //Devuelve la lista de carpetas dentro de la carpeta indicada
        List<Folder> retorno = new List<Folder>();
        List<Folder> directorios = [SELECT Id FROM Folder WHERE DeveloperName = :rutaDevName];
        if (!directorios.isEmpty()) {
            for (Folder directorio : [SELECT Name, DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :directorios[0].Id]) {
                retorno.add(directorio);
            }
        }
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> destinatariosColaborador(Id idGrupoColaborador) {
        Map<String, String> idMapContacto = new Map<String, String>();
        //A nivel de grupo colaborador buscar si tiene el email informado, es otra query
        List<CC_Grupo_Colaborador__c> lstOfGrup = [SELECT CC_Cuenta__r.CC_Email__c FROM CC_Grupo_Colaborador__c WHERE Id = :idGrupoColaborador];
        for (CC_Grupo_Colaborador__c gcol : lstOfGrup) {
            if (gcol.CC_Cuenta__r.CC_Email__c != null && gcol.CC_Cuenta__r.CC_Email__c != '') {
                idMapContacto.put(gcol.CC_Cuenta__r.CC_Email__c, 'Para');
            }
        }
        List<CC_Grupo_Colaborador_Contact__c> contactosGrupoColab = [SELECT CC_Para_CC__c, CC_Email__c FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :idGrupoColaborador AND (CC_Contacto__c != null OR CC_Usuario__c != null)];
        for (CC_Grupo_Colaborador_Contact__c contactoGrupoColab : contactosGrupoColab) {
            idMapContacto.put(contactoGrupoColab.CC_Email__c, contactoGrupoColab.CC_Para_CC__c);
        }
        return idMapContacto;
    }

    public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        public PickListWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled
    public static void actualizarCampoCerradoOperativa(Id idCaso, Boolean cerradoOperativa) {
        try {
            if (cerradoOperativa) {
                List<Case> casos = [SELECT OS_Cerrado_Operativa__c FROM Case WHERE ParentId = :idCaso];
                for(Case caso : casos){
                    caso.OS_Cerrado_Operativa__c = true;
                }
                    
                update casos;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}