public with sharing class AM_Case_Operativas_Controller {
    @AuraEnabled
    public static Case datosCaso(Id recordId) {
        return [SELECT RecordTypeId, RecordType.DeveloperName, OwnerId, CaseNumber, CC_Canal_Procedencia__c, Contact.Phone, Status, CC_Idioma__c, CC_Canal_Respuesta__c
                FROM Case WHERE Id = :recordId];
    }

    @AuraEnabled
    //OK
    public static List<String> validarCamposCaso(Id recordId, String operativa) {
        Case caso = [SELECT CC_Detalles_Consulta__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
                            CC_MCC_Tematica__r.CC_Activo__c, CC_MCC_ProdServ__r.CC_Activo__c, CC_MCC_Motivo__r.CC_Activo__c,
                            Origin, CC_Canal_Procedencia__c, CC_Idioma__c, CC_Tipo_Contacto__c, ContactId
                        FROM Case WHERE Id = :recordId];

        List<String> camposNoValidos = new List<String>();

        if ( (caso.CC_MCC_Tematica__c == null && operativa <>'botonDuplicar' ) || (caso.CC_MCC_Tematica__c == null && caso.CC_Canal_Procedencia__c <> 'Buzón Carteras' && caso.CC_Canal_Procedencia__c <> 'Buzón Fondos' && operativa == 'botonDuplicar')) {
            camposNoValidos.add('Temática');
        }
        if ( (caso.CC_MCC_ProdServ__c == null && operativa <>'botonDuplicar' ) || (caso.CC_MCC_ProdServ__c == null && caso.CC_Canal_Procedencia__c <> 'Buzón Carteras' && caso.CC_Canal_Procedencia__c <> 'Buzón Fondos' && operativa == 'botonDuplicar') ) {
            camposNoValidos.add('Producto/Servicio');
        }
        if ( (caso.CC_MCC_Motivo__c == null && operativa <>'botonDuplicar' ) || (caso.CC_MCC_Motivo__c == null &&  caso.CC_Canal_Procedencia__c <> 'Buzón Carteras' && caso.CC_Canal_Procedencia__c <> 'Buzón Fondos' && operativa == 'botonDuplicar') ) {
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
        if ( (caso.CC_Tipo_Contacto__c == null && operativa <>'botonDuplicar' ) || (caso.CC_Tipo_Contacto__c == null && caso.CC_Canal_Procedencia__c <> 'Buzón Carteras' && caso.CC_Canal_Procedencia__c <> 'Buzón Fondos' && operativa == 'botonDuplicar') ) {
            camposNoValidos.add('Tipo de contacto');
        }
        if (caso.CC_Detalles_Consulta__c == null && (caso.CC_Canal_Procedencia__c <> 'Buzón Carteras' && caso.CC_Canal_Procedencia__c <> 'Buzón Fondos') ) {
            camposNoValidos.add('Detalles Consulta');
        }
        if (caso.ContactId == null && (operativa == 'Solicitud Info Email' || operativa == 'botonResponder')) {
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
    public static List<String> validarCamposCasoOld(String recordId) {

        Case caso = [SELECT CC_Detalles_Consulta__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
                            CC_MCC_Tematica__r.CC_Activo__c, CC_MCC_ProdServ__r.CC_Activo__c, CC_MCC_Motivo__r.CC_Activo__c,
                            Origin, CC_Canal_Procedencia__c, CC_Idioma__c, CC_Tipo_Contacto__c
                        FROM Case WHERE Id = :recordId];

        //Validación de campos nulos
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
        if (caso.CC_Detalles_Consulta__c == null) {
            camposNoValidos.add('Detalles Consulta');
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
            idsMCC += '\'' + caso.CC_MCC_ProdServ__c + '\' ';
        }
        if (caso.CC_MCC_Motivo__c != null) {
            idsMCC += ', \'' + caso.CC_MCC_Motivo__c + '\'';
        }

        if (String.isBlank(idsMCC)) {
            return items;
        }

        String soqlQuery = 'SELECT CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.Name ';
        soqlQuery += 'FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c IN (' + idsMCC + ') ';
        soqlQuery += 'AND CC_Grupo_Colaborador__r.RecordTypeId != \'' + CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel') + '\' ';
        soqlQuery += 'GROUP BY CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.Name ORDER BY CC_Grupo_Colaborador__r.Name ASC';
        List<SObject> resultados = Database.query(soqlQuery);
        items = OT_Picklist.picklistSoql(resultados, 'Id', 'Name');
        return items;
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
    public static void prepararCaso(Id idCaso, String plantilla, Boolean informarReferenciaCorreo, String operativa) {
        Case caso = new Case(Id = idCaso);
        caso.CC_MCC_Plantilla__c = plantilla;
        caso.CC_Ultima_Operativa_Correo__c = operativa;
        if (informarReferenciaCorreo) {
            caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id);
        }
        update caso;
    }

    @AuraEnabled
    public static Map<String, List<String>> correoCaso(Id idCaso) {
        //Marc Pla, octubre 2020

        //try {
            List<String> direccionesCorreoPara = new List<String>();
            List<String> direccionesCorreoCc = new List<String>();
            
            //Dirección del cliente (siempre en el "Para")
            //Case caso = [SELECT OS_Remitente_Inicial__c, OS_Email__c, Contact.Email, CC_Buzon_Salida__c FROM Case WHERE Id = :idCaso]; IOP MARZO 2021

            Case caso = [SELECT OS_Email__c, Contact.Email, CC_Buzon_Salida__c FROM Case WHERE Id = :idCaso];

            if (!String.isEmpty(caso.OS_Email__c)) {
                direccionesCorreoPara.add(caso.OS_Email__c);
            } else {
                direccionesCorreoPara.add(caso.Contact.Email);
            }
            /* IOP MARZO 2021
            System.debug('1 para: '+direccionesCorreoPara);
            if (!String.isEmpty(caso.OS_Remitente_Inicial__c)) {
                direccionesCorreoPara.add(caso.OS_Remitente_Inicial__c);
            }*/

            //Direcciones de los correos anteriores (respetando si estaban en el "Para" o en "Copia")
            for (EmailMessage correoAnterior : [SELECT ToAddress, CcAddress FROM EmailMessage
                                                WHERE ParentId = :idCaso AND CC_Interno__c = false
                                                ORDER BY CreatedDate ASC]) {

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
            
            List<EmailServicesAddress> emailServiceAddress = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress
                                                        WHERE Function.FunctionName = 'AM_EmailService'];
            List<AM_Correos_Buzones_Entrada__mdt> emailServiceAddresMetadata = [SELECT AM_Email_Destino__c from AM_Correos_Buzones_Entrada__mdt];                                          

            for (EmailServicesAddress email : emailServiceAddress) {
                String direccionBuzonCAM = email.LocalPart + '@' + email.EmailDomainName;
                if(direccionBuzonCAM != null)
                {
                emailDirecciones.add(direccionBuzonCAM);
                }
            }

            for(AM_Correos_Buzones_Entrada__mdt email : emailServiceAddresMetadata)
            {
                String direccionBuzonCAM = email.AM_Email_Destino__c;
                if(direccionBuzonCAM != null)
                {
                emailDirecciones.add(direccionBuzonCAM);
                }
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

        //} 
        /*catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
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
    public static Boolean existeCarpeta(String carpetaDeveloperName) {
        List<Folder> carpetaPrincipal = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName];
        return (!carpetaPrincipal.isEmpty() ? true : false);
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

    /*@AuraEnabled
    public static String enviarNotificacinPushSMS(Id sObjectId, String destinatario, String texto) {
       return CC_Push_SMS.enviarNotificacionPush(sObjectId, destinatario, texto);
    }*/

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
    public static Case duplicarCaso(Case caso) {
        return AM_Case.duplicarCaso(caso);
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

       /* List<Id> recordTypesLlamadasCOPS = new List<Id>{
            CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Cliente'),
            CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Empleado')
        };

        List<CC_Llamada__c> llamadas = [SELECT Name, CC_Tipo__c FROM CC_Llamada__c
                                        WHERE RecordTypeId IN :recordTypesLlamadasCOPS
                                        AND OwnerId = :UserInfo.getUserId() AND CC_Fecha_Fin__c = NULL];
        if (llamadas.size() == 1) {

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
        }*/
        String returnvalue;
        return returnvalue;
    }

    @AuraEnabled
    public static String cambiarRecordType(Id idCaso) {
        try {
            Case caso = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :idCaso];
            String nuevoRecordTypeDevName;
            if (caso.RecordType.DeveloperName == 'AM_Cliente') {
                nuevoRecordTypeDevName = 'AM_Empleado';
            } else if (caso.RecordType.DeveloperName == 'AM_Empleado') {
                nuevoRecordTypeDevName = 'AM_Cliente';
            }
            
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', nuevoRecordTypeDevName);
            update caso;

            String nuevoRecordTypeName = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Case', nuevoRecordTypeDevName);
            AM_Activity.crearActividad(idCaso, 'Cambio de tipo del caso', 'Cambio de tipo del caso a "' + nuevoRecordTypeName + '"');

            return nuevoRecordTypeName;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    @AuraEnabled
    public static void actualizarCaseStatus(Id idCaso, String currentStatus, String detalleSolucion) {

        Case[] caseToUpdate = [SELECT Id, Status, CC_Detalles_Solucion__c FROM Case WHERE Id=:idCaso LIMIT 1];

        if(!caseToUpdate.isEmpty())
        {
            //If case Status = Pendiente Interno -- insert task
            if(currentStatus == 'Pendiente Interno')
            {
                AM_Activity.crearActividadPendiente(idCaso, 'Pendiente Interno', detalleSolucion);
                caseToUpdate[0].CC_Detalles_Solucion__c = detalleSolucion;

            }

            //If case Status == Activo -- close task
            if(currentStatus == 'Activo')
            {
                Task[] taskToClose = [SELECT Id, Status FROM Task WHERE WhatId =: idCaso AND Type = 'Pendiente Interno' AND Status='Open'];

                if(!taskToClose.isEmpty())
                {
                    for(Task taskClose: taskToClose)
                    {
                        CC_Activity.finalizarActividad(taskClose.Id);
                    }
                }
            }
            //Update case status to value = currentStatus
            caseToUpdate[0].Status=currentStatus;
            update caseToUpdate;
        }
    }

    //IOP MARZO 2021
    /*
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
}