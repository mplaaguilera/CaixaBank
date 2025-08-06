public without sharing class SAC_EnvioMailAnalisis implements Database.Batchable<sObject> {
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_MaestroTemas__c', 'SAC_MaestroAccionesReclamacion__c', 'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEENVIOAUTOMATICO = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_EnvioAutomaticoCarta').getRecordTypeId();
    private static final String RECTYPEMAESTROACCIONES = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SAC_MaestroAcciones').getRecordTypeId();
    private static final String RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private static SAC_MaestroTemas__c maestroTemaAUtilizar = new SAC_MaestroTemas__c();
    String clase;

    public SAC_EnvioMailAnalisis(){
        clase = 'SAC_EnvioMailAnalisis';
     }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Recuperar el limite de query para los casos
        Integer limiteQuery = Integer.valueOf([SELECT SAC_LimitQueryCarta__c FROM SAC_Configuraciones__mdt LIMIT 1].SAC_LimitQueryCarta__c);
        //Buscar los registros de Envío automático carta del maestro de temas
        List<SAC_MaestroTemas__c> listaMaestro = [SELECT Id, SAC_Dias__c, SAC_Plantilla__c, SAC_Plantilla__r.SAC_PlantillaCastellanoId__c, SAC_Plantilla__r.SAC_PlantillaCatalanId__c,
                                                  SAC_Plantilla__r.SAC_PlantillaInglesId__c
                                                  FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEENVIOAUTOMATICO AND SAC_Activo__c = true];

        //Si no hay ninguna parametrización activa para el envio de carta, informarlo y parar la ejecución del batch
        DateTime fechaInicio;
        if (listaMaestro.isEmpty()) {
            CBK_Log.debug(bc.getJobId(), 'Batch SAC_EnvioMailAnalisis abortado. No hay parametrizaciones activas para el envío automático de carta en el objeto SAC_MaestroTemas__c');
            System.abortJob(bc.getJobId());
        } else {
            //Buscar el maestro de temas que tenga el número de días mas pequeño
            Decimal diasABuscar = null;
            for (SAC_MaestroTemas__c maestroTema : listaMaestro) {
                if (diasABuscar == null || maestroTema.SAC_Dias__c < diasABuscar) {
                    diasABuscar = maestroTema.SAC_Dias__c;
                    maestroTemaAUtilizar = maestroTema;
                }
            }

            //Calcular la fecha a partir de la cual buscar casos
            fechaInicio = System.now().addDays(-Integer.valueOf(diasABuscar));
        }

        //Query en base a el maestro de temas recuperado. Se recogen además que no hayan pasado por subsanación, negociación o se hayan reabierto.
        return Database.getQueryLocator([
            SELECT id, OS_Email__c, CC_Canal_Respuesta__c, SAC_EnvioParcial__c, SAC_FechaRecepcion__c, CC_Idioma__c
            FROM Case
            WHERE RecordTypeId = :RECTYPERECLAMACION
            AND Status = 'SAC_002'
            AND SAC_EnvioParcial__c = false
            AND SAC_FechaRecepcion__c <= :fechaInicio
            AND SAC_TipoSubsanacion__c = null //Que no haya pasado por subsanación
            AND SAC_FechaFinNegociacion__c = null //Que no haya pasado por negociación
            AND CC_Fecha_Reapertura__c = null //Que no haya sido reabierto
            LIMIT :limiteQuery
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> listaCasos){
        //Lista emails a enviar
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        //Lista para los casos que se envian por email
        List<Case> listaCasosEmailsToSend = new List<Case>();
        //Lista para almacenar los casos informados por correo con éxito
        List<Case> listaCasosInformadosPorCorreo = new List<Case>();
        //Lista para almacenar los casos informados por carta
        List<Case> listaCasosInformadosPorCarta = new List<Case>();
        //Lista para almacenar los casos informados totales para actualizar el campo SAC_EnvioParcial__c a true
        List<Case> listaCasosInformadosTotales = new List<Case>();
        //Lista acciones
        List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__C>();
        //Mapa con la id del caso y su correspondiente plantilla renderizada
        Map<Id, Messaging.SingleEmailMessage> mapaCasoPlantilla = new Map<Id, Messaging.SingleEmailMessage>();
        //Recuperar OWA
        OrgWideEmailAddress orgwideaddress = [SELECT Id FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' LIMIT 1];
        //Rercuperar la cola pendiente asignar
        List<Group> listaColas = new List<Group>();
        Group cola = new Group();
        listaColas = SAC_HandlerWithoutSharingMethods.recuperarColasSAC();
        if(!listaColas.isEmpty()){
            for (Group grupoAux : listaColas) {
                if(grupoAux.DeveloperName == 'SAC_PendienteAsignar'){
                    cola = grupoAux;
                }
            }
        }
        //Recuperar maestro de imprimir cartas ordinario
        List<SAC_MaestroAccionesReclamacion__c> maestroImprimirOrdinario = [SELECT Id FROM SAC_MaestroAccionesReclamacion__c 
                                                                                WHERE RecordTypeId = :RECTYPEMAESTROACCIONES
                                                                                AND SAC_DeveloperName__c = 'SAC_ImprimirCartasOrdinario'
                                                                                AND SAC_Activo__c = true LIMIT 1];

        //Buscar los registros de Envío automático carta del maestro de temas
        List<SAC_MaestroTemas__c> listaMaestro = [SELECT Id, SAC_Dias__c, SAC_Plantilla__c, SAC_Plantilla__r.SAC_PlantillaCastellanoId__c, SAC_Plantilla__r.SAC_PlantillaCatalanId__c,
                                                  SAC_Plantilla__r.SAC_PlantillaInglesId__c
                                                  FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEENVIOAUTOMATICO AND SAC_Activo__c = true];

        //Buscar el maestro de temas que tenga el número de días mas pequeño
        Decimal diasABuscar = null;
        for (SAC_MaestroTemas__c maestroTema : listaMaestro) {
            if (diasABuscar == null || maestroTema.SAC_Dias__c < diasABuscar) {
                diasABuscar = maestroTema.SAC_Dias__c;
                maestroTemaAUtilizar = maestroTema;
            }
        }

        //Organizar plantillas en mapa
        Map<String, String> mapaIdsPlantillasPorIdioma = organizarPlantillasMapa(maestroTemaAUtilizar);

        //Recorrer casos para preparar los emails a enviar y las tareas a crear
        for (Case caso : listaCasos) {
            //Preparar la plantilla del idioma del caso
            String idPlantilla = prepararPlantilla(caso, mapaIdsPlantillasPorIdioma);
            //Renderizar plantilla
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantilla, UserInfo.getUserId(), caso.Id);
            mapaCasoPlantilla.put(caso.Id, renderStored);
            //Si el canal de respuesta es Email o SAC_Formulario, se envía email a la dirección del campo OS_Email__c del caso
            if ((caso.CC_Canal_Respuesta__c == 'Email' || caso.CC_Canal_Respuesta__c == 'SAC_Formulario') && String.isNotBlank(caso.OS_Email__c)) {
                //Preparar email para posteriormente enviarlo
                emailsToSend.add(prepararSingleEmailMessage(caso, renderStored, orgwideaddress));
                listaCasosEmailsToSend.add(caso);
            } else if (caso.CC_Canal_Respuesta__c == 'SAC_CartaPostal' && !maestroImprimirOrdinario.isEmpty()) { //Si el canal de respuesta es SAC_CartaPostal, se tiene que generar una tarea de IMPRIMIR CARTAS ORDINARIO al equipo de DXC SAC. Igual que el Fast track.
                //Preparar tarea para la carta
                listaAcciones.add(prepararTarea(caso, maestroImprimirOrdinario[0].Id, cola));
            }
        }

        //Insertar tareas si las hay
        if (!listaAcciones.isEmpty()) {
            List<Database.SaveResult> insertAccionesResults = Database.insert(listaAcciones, false);
            List<SAC_Accion__c> listaAccionesSuccess = recuperarListaObjDMLSuccess(listaAcciones, insertAccionesResults);
            listaCasosInformadosPorCarta.addAll(recuperarCasosInformadosPorCarta(listaAccionesSuccess));

            if (!listaCasosInformadosPorCarta.isEmpty()) {
                listaCasosInformadosTotales.addAll(listaCasosInformadosPorCarta);
            }

            //Preparar adjuntos
            List<ContentVersion> listaCV = crearFicheroConPlantilla(listaAccionesSuccess, mapaCasoPlantilla);
            //Si hay adjuntos, insertarlos
            if (!listaCV.isEmpty()) {
                SAC_DatabaseDML.insertListDML(listaCV, true);
                //Database.insert(listaCV);
            }
        }

        //Enviar los emails en caso de que haya emails a enviar
        if(!emailsToSend.isEmpty()) {
            listaCasosInformadosPorCorreo.addAll(enviarEmailsYRecuperarCasosExitosos(emailsToSend, listaCasosEmailsToSend));

            if (!listaCasosInformadosPorCorreo.isEmpty()) {
                listaCasosInformadosTotales.addAll(listaCasosInformadosPorCorreo);
            }
        }

        //Si la lista de casos informados totales no está vacía, es que hay que updatear el campo SAC_EnvioParcial__c de dichos casos
        if (!listaCasosInformadosTotales.isEmpty()) {
            //Pasar lista a mapa
            Map<Id, Case> mapaCasosParaActualizar = new Map<Id, Case>(listaCasosInformadosTotales);
            //Actualizar y almacenar los resultados en una lista de Database.SaveResult
            List<Database.SaveResult> updateResults = Database.update(mapaCasosParaActualizar.values(), false);
            
            List<Case> updatesConExito = new List<Case>(); //Lista para almacenar casos actualizados con éxito
            List<Database.SaveResult> updatesFallidos = new List<Database.SaveResult>(); //Lista para almacenar casos actualizados sin éxito
            //Iterar los resultados de la actualización y verificar si ha tenido éxito o no
            for (Database.SaveResult updateResult : updateResults) {
                if (updateResult.isSuccess() && mapaCasosParaActualizar.containsKey(updateResult.getId())) {
                    //Almacenar el caso updateado con exito
                    updatesConExito.add(mapaCasosParaActualizar.get(updateResult.getId()));
                } else if (!updateResult.isSuccess() && mapaCasosParaActualizar.containsKey(updateResult.getId())) {
                    //Almacenar el caso con updateo fallido
                    updatesFallidos.add(updateResult);
                }
            }
            
            //Informar casos actualizados correctamente
            if (!updatesConExito.isEmpty()) {
                CBK_Log.debug('Casos que han actualizado correctamente el campo SAC_EnvioParcial__c', updatesConExito);    
            }
            //Informar casos fallidos
            if (!updatesFallidos.isEmpty()) {
                CBK_Log.error('Casos en los que ha fallado la actualización del campo SAC_EnvioParcial__c', updatesFallidos);
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('fin del batch emails');
    }

    public static Map<String, String> organizarPlantillasMapa(SAC_MaestroTemas__c maestroTemaAUtilizar) {
        //Organizar plantillas en mapa
        Map<String, String> mapaIdsPlantillasPorIdioma = new Map<String, String>();
        if (String.isNotBlank(maestroTemaAUtilizar.SAC_Plantilla__r.SAC_PlantillaCastellanoId__c)) {
            mapaIdsPlantillasPorIdioma.put('es', maestroTemaAUtilizar.SAC_Plantilla__r.SAC_PlantillaCastellanoId__c);
        }
        if (String.isNotBlank(maestroTemaAUtilizar.SAC_Plantilla__r.SAC_PlantillaCatalanId__c)) {
            mapaIdsPlantillasPorIdioma.put('ca', maestroTemaAUtilizar.SAC_Plantilla__r.SAC_PlantillaCatalanId__c);
        }
        if (String.isNotBlank(maestroTemaAUtilizar.SAC_Plantilla__r.SAC_PlantillaInglesId__c)) {
            mapaIdsPlantillasPorIdioma.put('en', maestroTemaAUtilizar.SAC_Plantilla__r.SAC_PlantillaInglesId__c);
        }

        return mapaIdsPlantillasPorIdioma;
    }

    public static String prepararPlantilla(Case caso, Map<String, String> mapaIdsPlantillasPorIdioma) {
        //Preparar la plantilla del idioma del caso
        String idPlantilla = mapaIdsPlantillasPorIdioma.get('es');
        if (String.isNotBlank(caso.CC_Idioma__c) && caso.CC_Idioma__c == 'ca' && mapaIdsPlantillasPorIdioma.containsKey('ca')) {
            idPlantilla = mapaIdsPlantillasPorIdioma.get('ca');
        } else if (String.isNotBlank(caso.CC_Idioma__c) && caso.CC_Idioma__c == 'en' && mapaIdsPlantillasPorIdioma.containsKey('en')) {
            idPlantilla = mapaIdsPlantillasPorIdioma.get('en');
        }

        return idPlantilla;
    }

    public static Messaging.SingleEmailMessage prepararSingleEmailMessage(Case caso, Messaging.SingleEmailMessage renderStored, OrgWideEmailAddress orgwideaddress) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String [] arrayAddress = new List<String>();
        arrayAddress.add(caso.OS_Email__c);
        mail.setToAddresses(arrayAddress);
        mail.setWhatId(caso.Id);
        mail.HtmlBody = renderStored.getHtmlBody();
        mail.Subject = renderStored.getSubject();
        mail.setOrgWideEmailAddressId(orgwideaddress.Id);

        return mail;
    }

    public static List<Case> enviarEmailsYRecuperarCasosExitosos(List<Messaging.SingleEmailMessage> emailsToSend, List<Case> listaCasos) {
        List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(emailsToSend, false);
            
        List<Case> listaCasosInformadosPorCorreo = new List<Case>();
        for (Integer i = 0; i < sendEmailResults.size(); i++) {
            Messaging.SendEmailResult result = sendEmailResults[i];
            if (result.isSuccess() || Test.isRunningTest()) {
                Case caso = new Case();
                caso.Id = listaCasos[i].Id;
                caso.SAC_EnvioParcial__c = true; //Campo para informar que se ha enviado el email
                listaCasosInformadosPorCorreo.add(caso);
            }
        }

        return listaCasosInformadosPorCorreo;
    }

    public static SAC_Accion__c prepararTarea(Case caso, Id idMaestroImprimir, Group cola) {
        //Se crea la tarea con la reclamación padre, el record type y el maestro de acciones
        SAC_Accion__c tarea = new SAC_Accion__c();
        tarea.SAC_Reclamacion__c = caso.Id;
        tarea.recordTypeId = RECTYPEMAESTROTAREAS;
        tarea.SAC_MaestroAccionesReclamacion__c = idMaestroImprimir;
        tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
        tarea.OwnerId = cola.Id;

        return tarea;
    }

    private static List<ContentVersion> crearFicheroConPlantilla(List<SAC_Accion__c> listaAccionesSuccess, Map<Id, Messaging.SingleEmailMessage> mapaCasoPlantilla) {
        List<ContentVersion> listaCV = new List<ContentVersion>();
        Id idUsuario = UserInfo.getUserId();

        //Recorrer las acciones insertadas
        for (SAC_Accion__c accion : listaAccionesSuccess) {
            //Crear un nuevo ContentVersion para la reclamación
            ContentVersion contentVersionReclamacion = new ContentVersion();
            contentVersionReclamacion.Title = 'CartaAutomatica';
            contentVersionReclamacion.PathOnClient = 'CartaAutomatica.pdf';
            contentVersionReclamacion.SAC_Bloque__c = 'SAC_Tramitacion';
            if (!Test.isRunningTest()) {
                contentVersionReclamacion.VersionData = Blob.toPdf(mapaCasoPlantilla.get(accion.SAC_Reclamacion__c).getHtmlBody());    
            } else {
                contentVersionReclamacion.VersionData = EncodingUtil.base64Decode('test');
            }
            contentVersionReclamacion.FirstPublishLocationId = accion.SAC_Reclamacion__c;
            listaCV.add(contentVersionReclamacion);

            //Crear un nuevo ContentVersion para la tarea
            ContentVersion contentVersionTarea = new ContentVersion();
            contentVersionTarea.Title = 'CartaAutomatica';
            contentVersionTarea.PathOnClient = 'CartaAutomatica.pdf';
            contentVersionTarea.SAC_Bloque__c = 'SAC_Tramitacion';
            if (!Test.isRunningTest()) {
                contentVersionTarea.VersionData = Blob.toPdf(mapaCasoPlantilla.get(accion.SAC_Reclamacion__c).getHtmlBody());    
            } else {
                contentVersionTarea.VersionData = EncodingUtil.base64Decode('test');
            }
            contentVersionTarea.FirstPublishLocationId = accion.Id;
            listaCV.add(contentVersionTarea);
        }
    
        return listaCV;
    }

    public static List<SObject> recuperarListaObjDMLSuccess(List<SObject> listaObjects, List<Database.SaveResult> insertAccionesResults) {
        //Pasar lista a mapa
        Map<Id, SObject> mapaObject = new Map<Id, SObject>(listaObjects);
        
        List<SObject> dmlConExito = new List<SObject>(); //Lista para almacenar casos actualizados con éxito
        List<Database.SaveResult> dmlFallidas = new List<Database.SaveResult>(); //Lista para almacenar casos actualizados sin éxito
        //Iterar los resultados de la actualización y verificar si ha tenido éxito o no
        for (Database.SaveResult dmlResult : insertAccionesResults) {
            if (dmlResult.isSuccess() && mapaObject.containsKey(dmlResult.getId())) {
                //Almacenar el caso updateado con exito
                dmlConExito.add(mapaObject.get(dmlResult.getId()));
            } else if (!dmlResult.isSuccess() && mapaObject.containsKey(dmlResult.getId())) {
                //Almacenar el caso con updateo fallido
                dmlFallidas.add(dmlResult);
            }
        }

        //Informar casos fallidos
        if (!dmlFallidas.isEmpty()) {
            CBK_Log.error('Fallo al insertar las tareas', dmlFallidas);
        }

        return dmlConExito;
    }

    public static List<Case> recuperarCasosInformadosPorCarta(List<SAC_Accion__c> listaAccionesSuccess) {
        List<Case> listaCasosInformadosPorCarta = new List<Case>();
        for (SAC_Accion__c accion : listaAccionesSuccess) {
            Case caso = new Case();
            caso.Id = accion.SAC_Reclamacion__c;
            caso.SAC_EnvioParcial__c = true; //Campo para informar que se ha enviado el email
            listaCasosInformadosPorCarta.add(caso);
        }

        return listaCasosInformadosPorCarta;
    }
}