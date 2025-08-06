public without sharing class OS_Case_Operativas_Controller {

    @AuraEnabled
    public static Case datosCaso(Id recordId) {
        return [SELECT RecordTypeId, RecordType.DeveloperName, OwnerId, CaseNumber, CC_Canal_Procedencia__c, Contact.Phone, Status, CC_Idioma__c, CC_Canal_Respuesta__c
                FROM Case WHERE Id = :recordId];
    }

    @AuraEnabled
    public static List<String> validarCamposCaso(Id recordId, String operativa) {
        Case caso = [SELECT CC_Detalles_Consulta__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, CC_No_Identificado__c,
                            CC_MCC_Tematica__r.CC_Activo__c, CC_MCC_ProdServ__r.CC_Activo__c, CC_MCC_Motivo__r.CC_Activo__c,
                            Origin, CC_Canal_Procedencia__c, CC_Idioma__c, CC_Tipo_Contacto__c, ContactId
                        FROM Case WHERE Id = :recordId];

        List<String> camposNoValidos = new List<String>();

        if (caso.CC_MCC_Tematica__c == null) {
            camposNoValidos.add('Temática');
        }
        if (caso.CC_MCC_ProdServ__c == null) {
            camposNoValidos.add('Producto/Servicio');
        }
        if (caso.CC_MCC_Motivo__c == null) {
            camposNoValidos.add('Motivo');
        }
        if (caso.Origin == null) {
            camposNoValidos.add('Canal de entrada');
        }
        if (caso.CC_Canal_Procedencia__c == null) {
            camposNoValidos.add('Canal de procedencia');
        }
        if (caso.CC_Idioma__c == null) {
            camposNoValidos.add('Idioma');
        }
        if (caso.CC_Tipo_Contacto__c == null) {
            camposNoValidos.add('Tipo de contacto');
        }
        /*if (caso.CC_Detalles_Consulta__c == null) {
            camposNoValidos.add('Detalles Consulta');
        }*/

        if (caso.ContactId == null && caso.CC_No_Identificado__c == false && (operativa == 'Solicitud Info Email' || operativa == 'botonResponder')) {
            camposNoValidos.add('Cuenta y Contacto');
        }
        //Si las claves foráneas a MCCs no son nulas, se mira además que los MCCs a los que apuntan estén activos
        if (caso.CC_MCC_Tematica__c != null && caso.CC_MCC_ProdServ__c != null && caso.CC_MCC_Motivo__c != null) {
            //Se preparan los Ids en una lista para poder la comprobación en una sola consulta
            List<Id> idsMCC = new List<Id>{caso.CC_MCC_Tematica__c, caso.CC_MCC_ProdServ__c, caso.CC_MCC_Motivo__c};
            List<CC_MCC__c> mccs = [SELECT CC_Activo__c, RecordType.DeveloperName FROM CC_MCC__c WHERE Id IN :idsMCC];

            for (CC_MCC__c mcc : mccs) {
                if (!mcc.CC_Activo__c) {
                    camposNoValidos.add('Clasificación inactiva');
                    break;
                }
            }
        }
        return camposNoValidos;
    }
    
    @AuraEnabled
    public static List<OT_Picklist.Item> getGruposMCC(Id recordId) {
        List<OT_Picklist.Item> items = new List<OT_Picklist.Item>();
        Case caso = [SELECT CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :recordId];

        String idsMCC = '';
        if (caso.CC_MCC_ProdServ__c != null) {
            idsMCC += '\'' + String.escapeSingleQuotes(caso.CC_MCC_ProdServ__c) + '\' ';
        }
        if (caso.CC_MCC_Motivo__c != null) {
            idsMCC += ', \'' + String.escapeSingleQuotes(caso.CC_MCC_Motivo__c) + '\'';
        }

        if (String.isBlank(idsMCC)) {
            return items;
        }
        String recrdTypeId = String.valueOf(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel'));
        String soqlQuery = 'SELECT CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.Name FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c IN (' + idsMCC + ') AND CC_Grupo_Colaborador__r.RecordTypeId != \'' + String.escapeSingleQuotes(recrdTypeId) + '\' GROUP BY CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.Name ORDER BY CC_Grupo_Colaborador__r.Name ASC';
        List<SObject> resultados = Database.query(soqlQuery);
        items = OT_Picklist.picklistSoql(resultados, 'Id', 'Name');
        return items;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> buscarGruposColaboradores(String cadenaBusqueda) {
        //Se buscan grupos de colaborador de tipo grupo colaborador o centro CaixaBank
        return [SELECT Name FROM CC_Grupo_Colaborador__c
                WHERE OS_Negocio__c = 'COPS' AND Name LIKE :('%' + cadenaBusqueda + '%') AND
                (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador')
                OR RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank'))
                LIMIT 30];
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> buscarPlantillas(String cadenaBusqueda) {
        //Se buscan todas las plantillas
        return [SELECT Name FROM EmailTemplate WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND Folder.DeveloperName LIKE 'OS_%'  LIMIT 30];
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
    public static void prepararCaso(Id idCaso, String plantilla, Boolean informarReferenciaCorreo, String operativa, Boolean cerradoOperativa, String emailSeleccionado, String tipoRespuesta) {

        Case caso = [SELECT Origin, RecordTypeId, CC_Canal_Procedencia__c, CC_Buzon_Salida__c, CC_MCC_Plantilla__c, CC_Ultima_Operativa_Correo__c, OS_Cerrado_Operativa__c, OS_Email_Seleccionado__c, CC_Referencia_Correo_Saliente__c, 
        CC_Tipo_Gestion__c, CC_URL_Encuesta_3N__c, CC_Idioma__c, CC_Matricula_Empleado__c, CC_MCC_Tematica__r.name, CC_MCC_Tematica__r.CC_idCognitivo__c, CaseNumber, CC_MCC_Tematica__c, CC_MCC_Tematica__r.OS_No_Enviar_Encuestas__c,
        CC_MCC_ProdServ__r.OS_No_Enviar_Encuestas__c, CC_MCC_Motivo__r.OS_No_Enviar_Encuestas__c
        FROM Case WHERE Id = :idCaso];

        caso.CC_MCC_Plantilla__c = plantilla;
        caso.CC_Ultima_Operativa_Correo__c = operativa;
        caso.OS_Cerrado_Operativa__c = cerradoOperativa;
        caso.OS_Email_Seleccionado__c = emailSeleccionado;
        if (caso.CC_Buzon_Salida__c == null) {
            caso.CC_Buzon_Salida__c = [SELECT OS_Canal_Procedencia__c, OS_Correo__c FROM OS_Correo__mdt WHERE OS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1].OS_Correo__c;
        }
        if (informarReferenciaCorreo) {
            caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(idCaso);
        }
        if(tipoRespuesta != '') {
            caso.CC_Tipo_Gestion__c = tipoRespuesta;
        }//Si es la primera vez que se hace un Responder a cliente que cierra el caso en COPS, se prepara la URL de la encuesta

        if (operativa == 'responderCliente' && caso.CC_URL_Encuesta_3N__c == null && cerradoOperativa){
            Id recordTypeEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Empleado');
            if(caso.Origin == 'Email' && caso.RecordTypeId == recordTypeEmpleado && (caso.CC_Idioma__c == 'es' || caso.CC_Idioma__c == 'ca') && caso.CC_Matricula_Empleado__c != null 
            && caso.CC_MCC_Tematica__c != null && caso.CC_MCC_Tematica__r.name != null && caso.CC_MCC_Tematica__r.CC_idCognitivo__c != null
            && !caso.CC_MCC_Tematica__r.OS_No_Enviar_Encuestas__c && !caso.CC_MCC_ProdServ__r.OS_No_Enviar_Encuestas__c && !caso.CC_MCC_Motivo__r.OS_No_Enviar_Encuestas__c){
                caso.CC_URL_Encuesta_3N__c = generarURLLimeSurvey(caso);
                if(caso.CC_URL_Encuesta_3N__c != null){
                    caso.CC_Ultima_Operativa_Correo__c = 'Cerrado con encuesta';
                }
            }
            
        }
        update caso;
    }

    @AuraEnabled
    public static Map<String, List<String>> correoCaso(Id idCaso) {
        //Marc Pla, octubre 2020

        try {
            List<String> direccionesCorreoPara = new List<String>();
            List<String> direccionesCorreoCc = new List<String>();
            
            //Dirección del cliente (siempre en el "Para")
            Case caso = [SELECT CC_Canal_Procedencia__c, OS_Remitente_Inicial__c, OS_Email_Seleccionado__c, OS_Email__c, Contact.Email, CC_Buzon_Salida__c, Account.OS_Especialista_MIC__c FROM Case WHERE Id = :idCaso]; 
            
            //si solo se responde a un correo, se coge las direcciones que haya en el correo al que se quiere responder
            if (caso.OS_Email_Seleccionado__c != null) {
                EmailMessage correoAnterior = [SELECT Incoming, FromAddress, ToAddress, CcAddress FROM EmailMessage
                                                WHERE ParentId = :idCaso AND Id = :caso.OS_Email_Seleccionado__c LIMIT 1];

                if (!correoAnterior.Incoming) {
                    if (String.isNotBlank(correoAnterior.ToAddress)) {
                        for (String direccionPara : correoAnterior.ToAddress.split(';')) {
                            if (!direccionPara.trim().equals(caso.CC_Buzon_Salida__c)) {
                                direccionesCorreoPara.add(direccionPara.trim());
                            }
                        }
                    }
                    if (String.isNotBlank(correoAnterior.CcAddress)) {
                        for (String direccionCc : correoAnterior.CcAddress.split(';')) {
                            if (!direccionCc.trim().equals(caso.CC_Buzon_Salida__c)) {
                                direccionesCorreoCc.add(direccionCc.trim());
                            }
                        }
                    }
                } else {
                    if (String.isNotBlank(correoAnterior.FromAddress)) {
                        for (String direccionPara : correoAnterior.FromAddress.split(';')) {
                            if (!direccionPara.trim().equals(caso.CC_Buzon_Salida__c)) {
                                direccionesCorreoPara.add(direccionPara.trim());
                            }
                        }
                    }
                    if (String.isNotBlank(correoAnterior.CcAddress)) {
                        for (String direccionCc : correoAnterior.CcAddress.split(';')) {
                            if (!direccionCc.trim().equals(caso.CC_Buzon_Salida__c)) {
                                direccionesCorreoCc.add(direccionCc.trim());
                            }
                        }
                    }
                    if (String.isNotBlank(correoAnterior.ToAddress)) {
                        for (String direccionPara : correoAnterior.ToAddress.split(';')) {
                            if (!direccionPara.trim().equals(caso.CC_Buzon_Salida__c)) {
                                direccionesCorreoPara.add(direccionPara.trim());
                            }
                        }
                    }

                }
                
                //Quitar duplicados + Si una dirección está en el "FROM" se descarta del "PARA"
                for (Integer i = direccionesCorreoPara.size() - 1; i >= 0; i--) {
                    if (caso.CC_Buzon_Salida__c == direccionesCorreoPara[i]) {
                        direccionesCorreoPara.remove(direccionesCorreoPara.indexOf(direccionesCorreoPara[i]));
                    }
                }
            } else {
                if (!String.isEmpty(caso.OS_Email__c)) {
                    direccionesCorreoPara.add(caso.OS_Email__c);
                } else {
                    direccionesCorreoPara.add(caso.Contact.Email);
                }
                if (!String.isEmpty(caso.OS_Remitente_Inicial__c)) {
                    direccionesCorreoPara.add(caso.OS_Remitente_Inicial__c);
                }
                //Direcciones de los correos anteriores (respetando si estaban en el "Para" o en "Copia")
                for (EmailMessage correoAnterior : [SELECT ToAddress, CcAddress FROM EmailMessage
                                                    WHERE ParentId = :idCaso AND CC_Interno__c = false
                                                    ORDER BY CreatedDate ASC]) {
                                                        
                    if (String.isNotBlank(correoAnterior.ToAddress)) {
                        for (String direccionPara : correoAnterior.ToAddress.split(';')) {
                            if (!direccionPara.trim().equals(caso.CC_Buzon_Salida__c)) {
                                direccionesCorreoPara.add(direccionPara.trim());
                            }
                        }
                    }
                    if (String.isNotBlank(correoAnterior.CcAddress)) {
                        for (String direccionCc : correoAnterior.CcAddress.split(';')) {
                            if (!direccionCc.trim().equals(caso.CC_Buzon_Salida__c)) {
                                direccionesCorreoCc.add(direccionCc.trim());
                            }
                        }
                    }
                }
            }
            //INI LMG - US565916
            if(String.isNotBlank(caso.Account.OS_Especialista_MIC__c) && 
            (caso.CC_Canal_Procedencia__c == 'Buzón Contact Center Confirming' || 
             caso.CC_Canal_Procedencia__c == 'Buzón UAFE' || 
             caso.CC_Canal_Procedencia__c == 'Buzón UAFE Express' || 
             caso.CC_Canal_Procedencia__c == 'Buzón Crédito Stock' || 
             caso.CC_Canal_Procedencia__c == 'Buzón Factoring Sindicados' || 
             caso.CC_Canal_Procedencia__c == 'Buzón Inditex Suppliers')){
                OS_Cartera__c carteraUAFE = [SELECT Id, OS_Email__c FROM OS_Cartera__c WHERE Id =: caso.Account.OS_Especialista_MIC__c LIMIT 1];
                if(String.isNotBlank(carteraUAFE.OS_Email__c)){
                    direccionesCorreoCc.add(carteraUAFE.OS_Email__c);
                }
            }
            //FIN LMG - US565916
            
            //Quitar duplicados + Si una dirección está en el "Para" se descarta del "CC"
            direccionesCorreoPara = CC_MetodosUtiles.descartarDuplicadosLista(direccionesCorreoPara);
            direccionesCorreoCc = CC_MetodosUtiles.descartarDuplicadosLista(direccionesCorreoCc);

            for (Integer i = direccionesCorreoCc.size() - 1; i >= 0; i--) {
                if (direccionesCorreoPara.contains(direccionesCorreoCc[i])) {
                    direccionesCorreoCc.remove(direccionesCorreoCc.indexOf(direccionesCorreoCc[i]));
                }
            }
            //Quitar direcciones de los propios buzones de COPS 
            for (EmailServicesAddress emailServiceAddress : [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress
                                                        WHERE Function.FunctionName = 'OS_EmailService']) {
                String direccionBuzonCOPS = emailServiceAddress.LocalPart + '@' + emailServiceAddress.EmailDomainName;
                if (direccionesCorreoPara.contains(direccionBuzonCOPS)) {
                    direccionesCorreoPara.remove(direccionesCorreoPara.indexOf(direccionBuzonCOPS));
                }
                if (direccionesCorreoCc.contains(direccionBuzonCOPS)) {
                    direccionesCorreoCc.remove(direccionesCorreoCc.indexOf(direccionBuzonCOPS));                
                }
            }
            Map<String, List<String>> retorno = new Map<String, List<String>>();
            retorno.put('Para', direccionesCorreoPara);
            retorno.put('Cc', direccionesCorreoCc);
            return retorno;

        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean existeCarpeta(String carpetaDeveloperName) {
        List<Folder> carpetaPrincipal = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName];
        return (!carpetaPrincipal.isEmpty() ? true : false);
    }

    @AuraEnabled(cacheable=true)
    public static List<Folder> getCarpetas(String carpetaDeveloperName) {
        List<Folder> carpetas = new List<Folder>();
        Id parentId = null;
        if (carpetaDeveloperName == null) {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'OS_Operativas' LIMIT 1].Id;
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
    public static List<EmailTemplate> plantillas(String rutaDevName) {
        //Devuelve la lista de plantillas dentro de la carpeta indicada
        List<EmailTemplate> retorno = new List<EmailTemplate>();

        List<Folder> directorios = [SELECT Id FROM Folder WHERE DeveloperName = :rutaDevName];
        if (!directorios.isEmpty()) {
            for (EmailTemplate plantilla : [SELECT Name, DeveloperName FROM EmailTemplate WHERE FolderId = :directorios[0].Id]) {
                retorno.add(plantilla);
            }
        }
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static String plantillaCuerpo(String developerName, Boolean convertirATextoPlano) {
        //Devuelve el cuerpo de la plantilla indicada
        String cuerpo = [SELECT HtmlValue FROM EmailTemplate WHERE developerName = :developerName].HtmlValue;

        //Si se ha indicado que se devuelva en texto plano se quitan los tags HTML
        if (convertirATextoPlano) {
            cuerpo = cuerpo.stripHtmlTags();
        }
        return cuerpo;
    }

    @AuraEnabled
    public static String enviarNotificacinPushSMS(Id sObjectId, String destinatario, String texto) {
        return CC_Push_SMS.enviarNotificacionPush(sObjectId, destinatario, texto);
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

    @AuraEnabled
    public static void programarAlerta(Id caseId, Datetime fechaHora, Id ownerId, String descripcion) {
        OS_Activity.crearEvento(caseId, fechaHora, ownerId, descripcion);
    }

    @AuraEnabled
    public static void desprogramarAlerta(Id caseId, Datetime fechaHora) {
        OS_Activity.borrarEvento(caseId, fechaHora);
    }

    @AuraEnabled
    public static Case duplicarCaso(Case caso) {
        return OS_Case.duplicarCaso(caso);
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
    public static String vincularLlamada(Id idCaso) {
        List<Id> recordTypesLlamadasCOPS = new List<Id>{
            CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Cliente'),
            CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Empleado')
        };

        List<CC_Llamada__c> llamadas = [SELECT Name, CC_Tipo__c FROM CC_Llamada__c
                                        WHERE RecordTypeId IN :recordTypesLlamadasCOPS
                                        AND OwnerId = :UserInfo.getUserId() AND CC_Fecha_Fin__c = NULL];
        if (!llamadas.isEmpty()) {

            //Vincular caso con llamada

            //Validar que el caso no está vinculado ya con la llamada
            if ([SELECT Count() FROM Task WHERE WhatId = :idCaso AND CC_Llamada_Id__c = :llamadas[0].Id] > 0) {
                //El caso ya estaba vinculado con la llamada, se muestra mensaje informativo
                throw new AuraHandledException('El caso ya se encuentra vinculado con la llamada actualmente en curso.');
            } else {
                //Vincular caso con llamada a través de una nueva tarea
                String tipo = llamadas[0].CC_Tipo__c == 'Entrante' ? 'Llamada entrante' : 'Llamada saliente';

                Task tarea = new Task();
                tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
                tarea.WhatId = idCaso;
                tarea.CC_Llamada_Id__c = llamadas[0].Id;
                tarea.ActivityDate = System.today();
                tarea.CC_Fecha_Inicio__c = System.now();
                tarea.Type = tipo;
                tarea.Subject = tipo;
                tarea.Status = 'Open';
                insert tarea;

                return llamadas[0].Name;
            }
        } else {
            throw new AuraHandledException('No se ha encontrado ninguna llamada en curso que vincular al caso.');
        }
    }

    @AuraEnabled
    public static String cambiarRecordType(Id idCaso) {
        try {
            Case caso = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :idCaso];
            String nuevoRecordTypeDevName;
            if (caso.RecordType.DeveloperName == 'OS_Cliente') {
                nuevoRecordTypeDevName = 'OS_Empleado';
            } else if (caso.RecordType.DeveloperName == 'OS_Empleado') {
                nuevoRecordTypeDevName = 'OS_Cliente';
            }
            
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', nuevoRecordTypeDevName);
            caso.ContactId = null;
            caso.AccountId = null;
            update caso;

            String nuevoRecordTypeName = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Case', nuevoRecordTypeDevName);
            OS_Activity.crearActividad(idCaso, 'Cambio de tipo del caso', 'Cambio de tipo del caso a "' + nuevoRecordTypeName + '"');

            return nuevoRecordTypeName;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description método para guardar el valor del campo OS_Cerrado_Operativa__c para cerrar el caso despues de la operativa responderCliente 
     * @param idCaso
     * @param cerradoOperativa
     */
    @AuraEnabled
    public static void actualizarCampoCerradoOperativa(Id idCaso, Boolean cerradoOperativa) {
        try {
            if (cerradoOperativa) {
                Case caso = [SELECT OS_Cerrado_Operativa__c FROM Case WHERE Id = :idCaso];
                caso.OS_Cerrado_Operativa__c = true;
                update caso;
            }            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description método para obtener una lista de casos, con el mismo contacto vinculado, para la operativa de fusionar
     * @param contactId
     * @param recordId
     * @return listaCasos
     */
    @AuraEnabled
    public static List<Case> getCasosContacto(String contactId, String recordId) {
        List<Case> casosContacto = new List<Case>();
        if (String.isNotBlank(contactId)) {
            return [SELECT Status, CaseNumber, Subject, Description, CreatedDate FROM Case
                    WHERE ContactId = :contactId AND Id != :recordId AND Status NOT IN ('Pendiente Cliente', 'Pendiente Colaborador', 'Pendiente Alerta') AND CreatedDate = LAST_N_DAYS:30 ORDER BY CreatedDate DESC];
        }
        return casosContacto;
    }

    /**
     * @description método para obtener una lista de casos, con el mismo asunto, para la operativa de fusionar
     * @param asunto
     * @param recordId
     * @return listaCasos
     */
    @AuraEnabled
    public static List<Case> getCasosAsunto(String Asunto, String recordId) {
        List<Case> casosAsunto = new List<Case>();
        if (String.isNotBlank(Asunto)) {
            return [SELECT Status, CaseNumber, Subject, Description, CreatedDate FROM Case
                    WHERE Subject LIKE : '%' + Asunto  + '%' AND Id != :recordId AND Status NOT IN ('Pendiente Cliente', 'Pendiente Colaborador', 'Pendiente Alerta') AND CreatedDate = LAST_N_DAYS:30 ORDER BY CreatedDate DESC];
        }
        return casosAsunto;
    }

    /**
     * @description método para obtener el caso y los campos necesarios para realizar la fusión
     * @param recordId
     * @return map
     */
    @AuraEnabled
    public static Map<String, Object> getCaso(Id recordId) {

        Map<String, Object> retorno = new Map<String, Object>();

        Boolean operativaHabilitada = false;
        String mensaje = 'Este caso no puede ser asociado a otro.';

        Case caso = [SELECT Status, CaseNumber, ContactId, RecordType.DeveloperName, CC_CasoRelacionado__c, CC_ContactoRelacionado__c, CC_Canal_Procedencia__c, Subject, Description, CC_Cola_Procedencia__c, OwnerId, Origin
                    FROM Case WHERE Id = :recordId];

        if (caso.CC_ContactoRelacionado__c == null) {
            caso.CC_ContactoRelacionado__c = caso.ContactId;
        }
        if (caso.Status != 'Activo') {
            operativaHabilitada = false;
            mensaje = 'Solo se pueden fusionar casos activos.';
        }
        if (caso.CC_Cola_Procedencia__c != '') {
            List<CC_Fusion_Casos__mdt> procedencias = [SELECT Id FROM CC_Fusion_Casos__mdt WHERE MasterLabel = :caso.CC_Cola_Procedencia__c];
            operativaHabilitada = !procedencias.isEmpty();
        }
        if(caso.Origin == 'Phone') {
            operativaHabilitada = True;
        }
        if (String.valueOf(caso.OwnerId).startsWith('00G')) {  operativaHabilitada = false;   mensaje = 'Para poder fusionar este caso acepte primero su propiedad.';
        }

        retorno.put('CASOSCONTACTO', getCasosContacto(caso.CC_ContactoRelacionado__c, caso.Id));
        retorno.put('CASO', caso);
        retorno.put('HABILITADO', operativaHabilitada);
        retorno.put('MENSAJE', mensaje);
        retorno.put('CASOSASUNTO', getCasosAsunto(caso.Subject, caso.Id));
        return retorno;
    }

    /**
     * @description método para fusionar los correos, actividades, adjuntos de los casos.
     * @param masterCaseId
     * @param listaIds
     * @return String 
     */
    @AuraEnabled
    public static String mergeCase(Id masterCaseId, List<String> listaIds) {
        try {
            String resultado;
            //Buscamos los casos con los que vamos a fusionar el caso master
            List<Case> listaCasos = [SELECT ID, SUBJECT, Status, RecordType.DeveloperName FROM Case WHERE id IN :listaIds];

            //Recuperamos el caso master
            Case casoMaster = [SELECT ID, SUBJECT FROM Case WHERE Id = :masterCaseId LIMIT 1 ];

            //Validamos que los casos que vamos a fusionar sean casos de Cops
            List<Case> listaCasosParaFusionar = new List<Case>();
            Set<Id> listaCasosIds = new Set<Id>();
            for (Case caso : listaCasos) {
                if (caso.RecordType.DeveloperName.startsWith('OS_')) {
                    listaCasosIds.add(caso.Id);
                    if (caso.Status != 'Cerrado'){
                        caso.Status = 'Rechazado';
                    }
                    listaCasosParaFusionar.add(caso);
                } 
            }
            if (!listaCasosIds.isEmpty()) {

                //Guardamos en esta variable los ids de los contentdocument vinculados a los nuevos Emails del caso master
                List<Id> idsContentDocumentVinculadosAlCasoMaster = new List<Id>();


                //Buscamos los correos asociados a los casos con los que vamos a fusionar el caso master
                List<EmailMessage> correosCasosFusionados = [SELECT Id, subject, htmlbody, textbody, RelatedToId, ParentId, CC_Grupo_Colab__c,
                                                            CC_Interno__c, CC_Procedencia__c, CC_Rechazado__c, CcAddress, BccAddress, CreatedDate,
                                                            fromaddress, FromName, HasAttachment, Headers, Incoming, MessageDate, LastModifiedDate,
                                                            LastModifiedById,ReplyToEmailMessageId, Status, SystemModstamp, ToAddress, EmailTemplateId,
                                                            OS_Email_Fusionado__c FROM EmailMessage WHERE parentId IN :listaCasosIds ];

                List<EmailMessage> correosCasosModificar  = new List<EmailMessage>();
                List<Id> idsCorreoVinculadosAdjuntos = new List<Id>();
                if (!correosCasosFusionados.isEmpty()) {
                     
                    //Iteramos por primera vez la lista para crear los nuevos correos vinculados al caso master
                    for (EmailMessage eMessage : correosCasosFusionados) {
                        EmailMessage clonEmailMessage = eMessage.clone(false, true, true, false);
                        clonEmailMessage.RelatedToId = masterCaseId;
                        clonEmailMessage.ParentId = masterCaseId;
                        clonEmailMessage.OS_Email_Fusionado__c = true;
                        correosCasosModificar.add(clonEmailMessage);
                        idsCorreoVinculadosAdjuntos.add(eMessage.Id);
                    }
                    insert correosCasosModificar;
                    delete correosCasosFusionados; 
                }                
                //TAREAS ABIERTAS 
                //NO APLICA, NO SE PERMITEN FUSIONAR CASOS QUE ESTEN EN ESTADO PENDIENTE 'LOQUESEA'
                
                //TAREAS CERRADAS 
                List<Task> listaTareasCerradas = [SELECT Type FROM Task WHERE WhatId IN :listaCasosIds AND Status <> 'Open'];
                if (!listaTareasCerradas.isEmpty()) {
                    for (Task tarea : listaTareasCerradas) {  tarea.WhatId = casoMaster.Id; }
                    update listaTareasCerradas;
                }
                //ADJUNTOS vinculados al Email
                /*Map<String, Object> inputs = new Map<String, Object>();
                inputs.put('listaIdsFusionar', listaCasosIds);
                inputs.put('idMaster', casoMaster.Id);
                */
                //ADJUNTOS vinculados al caso

                List<ContentDocumentLink> listaAdjuntosVinculadosCaso = [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :listaCasosIds];
                if (!listaAdjuntosVinculadosCaso.isEmpty()) {
                    List<ContentDocumentLink> listaArchivosCasoMaster = new List<ContentDocumentLink>();
                    for (ContentDocumentLink cdl : listaAdjuntosVinculadosCaso) {
                        ContentDocumentLink nuevoCdl = cdl.clone();
                        nuevoCdl.LinkedEntityId = casoMaster.Id;
                        listaArchivosCasoMaster.add(nuevoCdl);
                    }
                    delete listaAdjuntosVinculadosCaso;              
                    insert listaArchivosCasoMaster;
                }  
            }            
            resultado = 'Ok';
            delete listaCasosParaFusionar;

            Task createTask = new Task();
            createTask.Type = 'Fusionado';
            createTask.Subject = 'Fusión de caso';
            createTask.ActivityDate = System.today();
            createTask.Status = 'Completed';
            createTask.Description = '';
            createTask.WhatId = casoMaster.Id;
            insert createTask;

            return resultado;
        
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());
        }
    }

    //CORREOS ELECTRONICOS DEL CASO

    @AuraEnabled(cacheable = true)
    public static List<CorreoElectronico> getEmailsCaso (Id caseId, String campo, String orden){
        
        switch on campo {
            when 'nameUrl' {
                campo = 'Subject';
            }
            when 'de' {
                campo = 'FromAddress';
            }
            when 'para' {  campo = 'ToAddress';
            }
            when 'cc' {  campo = 'CcAddress';
            }
            when 'fecha' {
                campo = 'MessageDate';
            }
            when 'estado' {
                campo = 'Status';
            }
            when 'hasAttachment' {
                campo = 'hasAttachment';
            }
            when 'cuerpo' {
                campo = 'TextBody';
            }                      
        }
        List<EmailMessage> correosElectronicos = new List<EmailMessage>();
        List<EmailMessage> listaCorreos = new List<EmailMessage>();
        Map<Id,Boolean> mapaTieneAdjuntos = new Map<Id,Boolean>();

        if (campo == 'hasAttachment') {
            correosElectronicos = Database.query('SELECT Id, HasAttachment , Subject, TextBody, FromAddress, ToAddress, CcAddress, MessageDate, toLabel(Status) FROM EmailMessage WHERE ParentId = :caseId');

            Set<Id> idsCorreos = new Set<Id>();
            
            for (EmailMessage eMessage : correosElectronicos) {
                idsCorreos.add(eMessage.Id);
                mapaTieneAdjuntos.put(eMessage.Id, false);
            }
                
            for (ContentDocumentLink cdl : [SELECT LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId IN :idsCorreos]) {
                mapaTieneAdjuntos.put(cdl.LinkedEntityId,true);                                
            }
            if (orden == 'desc') {
                //Primero los que tienen adjuntos
                for (EmailMessage eMessage : correosElectronicos) {
                    if (mapaTieneAdjuntos.get(eMessage.Id)) {
                        listaCorreos.add(eMessage);
                    }       
                }
                //luego los que no tienen
                for (EmailMessage eMessage : correosElectronicos) {
                    if (!mapaTieneAdjuntos.get(eMessage.Id)) {
                        listaCorreos.add(eMessage);
                    }       
                }
            } else {
                //primero los que no tienen adjuntos
                for (EmailMessage eMessage : correosElectronicos) {
                    if (!mapaTieneAdjuntos.get(eMessage.Id)) {
                        listaCorreos.add(eMessage);
                    }       
                }
                //luego los que tienen 
                for (EmailMessage eMessage : correosElectronicos) {
                    if (mapaTieneAdjuntos.get(eMessage.Id)) {
                        listaCorreos.add(eMessage);
                    }       
                }
            }
            correosElectronicos.clear();
            correosElectronicos = listaCorreos;
        } else{
            listaCorreos = Database.query('SELECT Id, HasAttachment , Subject, TextBody, FromAddress, ToAddress, CcAddress, MessageDate, toLabel(Status) FROM EmailMessage WHERE ParentId = :caseId ORDER BY ' +String.escapeSingleQuotes(campo)+' '+String.escapeSingleQuotes(orden));  
            
            Set<Id> idsCorreos = new Set<Id>();
            
            for (EmailMessage eMessage : listaCorreos) {
                idsCorreos.add(eMessage.Id);
                mapaTieneAdjuntos.put(eMessage.Id, false);
            }
            
             if (!idsCorreos.isEmpty()){   
            for (ContentDocumentLink cdl : [SELECT LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId IN :idsCorreos]) {
                mapaTieneAdjuntos.put(cdl.LinkedEntityId,true);                                
            }
             }
            correosElectronicos = listaCorreos;
        }
        List<CorreoElectronico> correos = new List<CorreoElectronico>();
        if (!correosElectronicos.isEmpty()) {
            for (EmailMessage eMessage : correosElectronicos) {
                CorreoElectronico correo = new CorreoElectronico();
                correo.Id = eMessage.Id;
                
                //Nuevo, cuando llega un correo sin asunto en la lista personalizada sale el el id de la url, no el [No subject] de la vista standar. 
                correo.asunto = (eMessage.Subject != '' && eMessage.Subject != null) ? eMessage.Subject : '[Sin asunto]';
                correo.cuerpo = eMessage.TextBody;
                correo.de = eMessage.FromAddress;
                correo.para = eMessage.ToAddress;
                correo.cc = eMessage.CcAddress;
                correo.fecha = eMessage.MessageDate.format('dd/MM/yyyy HH:mm'); //ARREGLADO LA FECHA
                correo.nameUrl = '/'+eMessage.Id;
                correo.estado = eMessage.Status;
                
                if (mapaTieneAdjuntos.get(eMessage.Id)) {
                    correo.iconoAdjuntos = 'utility:attach';
                    correo.hasAttachment= ' ';
                }
                correos.add(correo);
            }
        }
        return correos;
    }

    /**
     * @description wrapperclass para la lista custom de correos del caso
     * @return CorreoElectronico
     */
    public class CorreoElectronico {
        @AuraEnabled public Id id{get;set;}
        @AuraEnabled public String asunto{get;set;}
        @AuraEnabled public String cuerpo{get;set;}
        @AuraEnabled public String de{get;set;}
        @AuraEnabled public String para{get;set;}
        @AuraEnabled public String cc{get;set;}
        @AuraEnabled public String fecha{get;set;}
        @AuraEnabled public String estado{get;set;}
        @AuraEnabled public String hasAttachment{get;set;}        
        @AuraEnabled public String iconoAdjuntos{get;set;}     
        @AuraEnabled public String nameUrl{get;set;}
    }

    @AuraEnabled
    public static Map<String,Object> getAdjuntosPlantilla(String nameTemplate) {
        Map<String,Object> mapaResponse = new Map<String,Object>();
        Set<Id> setIdDocuments = new Set<Id>();
        EmailTemplate e = [select id, Name from EmailTemplate where Id = :nameTemplate limit 1];
        String idTemplate = e.Id;
        List<ContentDocumentLink> lstContentDocumentlink = [Select ContentDocumentId from ContentDocumentLink where LinkedEntityId = :idTemplate];
        for(ContentDocumentLink documentLink : lstContentDocumentlink){
            setIdDocuments.add(documentLink.ContentDocumentId);
        }
        if(!setIdDocuments.isEmpty()){
            List<ContentDocument> listContentDocument = [select Title From ContentDocument Where Id in :setIdDocuments];
            mapaResponse.put('TEMPLATES', listContentDocument);
        }
        return mapaResponse;
    }

    @AuraEnabled
    public static String generarURLLimeSurvey(Case caso) {

        String url;

        Boolean buzonActivo = [SELECT CC_Activa__c FROM CC_Lista_Valores__c 
                            WHERE Name = :caso.CC_Canal_Procedencia__c 
                            AND CC_Lista__r.Name = 'COPS: Activar Encuesta por canal de procedencia'].CC_Activa__c;

        if(buzonActivo){

            List<OS_Envio_LimeSurvey__c> linkEncuestaEmpleado = [SELECT OS_LimeSurvey_Link__c FROM OS_Envio_LimeSurvey__c WHERE Name = 'OS_URL_Encuesta'];

            if(!linkEncuestaEmpleado.isEmpty()){

                url = (String)linkEncuestaEmpleado[0].OS_LimeSurvey_Link__c+'sid='+caso.CC_MCC_Tematica__r.CC_IdCognitivo__c+'&lang='+
                caso.CC_Idioma__c+'&userid='+caso.CC_Matricula_Empleado__c+'&ticketid='+caso.CaseNumber+'&idet='+caso.CC_MCC_Tematica__c+'&et='+ caso.CC_MCC_Tematica__r.name.replace(' ', '_')+'&newtest=Y';

            }
            
        }
        return url;
    }
}