/***************************************************************** 
 * Name: SPV_LCMP_EscaladoOperativas
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Controlador del componente spv_EscaladoOperativas
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US938351         CS             06/06/2024   Creación
*****************************************************************/
public with sharing class SPV_LCMP_EscaladoOperativas {
    private static Set<String> objetos = new Set<String>{'SPV_Formulario__c', 'SAC_Interaccion__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEFORMULARIO = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioAnalisisDecision').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPEREESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Reescalado').getRecordTypeId();

    // Get the Id for our custom notification type
    private static CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                                FROM CustomNotificationType 
                                                                WHERE DeveloperName='SAC_EscaladoAtendido'];
    /*****************************************************************
     * Proposito: Tomar en propiedad el escalado. Solo puede tomarse en propiedad si
     * el usuario pertenece a el grupo del escalado.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US938351         CS             06/06/2024   Creación
    *****************************************************************/
    @AuraEnabled
    public static void tomarPropiedadEscalado(String escaladoId, String grupoEscalado, String usuarioActualId) {
        String mensajeError = '';
        try {
            //Asignar id escalado
            SAC_Interaccion__c escalado = new SAC_Interaccion__c();
            escalado.Id = escaladoId;

            //Buscar si el usuario que ejecuta la interacción pertenece al mismo grupo al que pertenece la interacción
            List<CC_Grupo_Colaborador_Contact__c> colabContact = [SELECT Id
                                                                    FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :grupoEscalado
                                                                    AND CC_Usuario__c = :usuarioActualId LIMIT 1];

            //Si pertenece al grupo, actualizar el registro. De lo contrario mostrar error.
            if (!colabContact.isEmpty()) {
                escalado.OwnerId = usuarioActualId;
                if(Schema.sObjectType.SAC_Interaccion__c.isUpdateable()){   
                    // Database.update(escalado);
                    SPV_DatabaseDML.updateDML(escalado, true);
                }else{
                    mensajeError = 'No tienes permisos para actualizar el escalado';
                    throw new AuraHandledException(mensajeError);
                }
            } else {
                mensajeError = 'No perteneces al grupo del escalado';
                throw new AuraHandledException(mensajeError);
            }
        } catch (Exception e) {
            if (String.isNotBlank(mensajeError)) { e.setMessage(mensajeError); }
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************
     * Proposito: Devuelve el escalado a la cola pendiente de asignar.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US938351         CS             06/06/2024   Creación
    *****************************************************************/
    @AuraEnabled
    public static void devolverEscaladoAlGrupo(String escaladoId) {
        try {
            //Asignar id de escalado
            SAC_Interaccion__c escalado = [SELECT Id, SAC_CasoEscalado__c, Name, CreatedById FROM SAC_Interaccion__c WHERE (RecordTypeId = :RECTYPEESCALADO OR RecordTypeId = :RECTYPEREESCALADO)AND Id = :escaladoId LIMIT 1];

            //Buscar la cola
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            //Si se ha encontrado la cola, cambiar el owner por la cola y updatear el escalado
            if(!cola.isEmpty()){
                escalado.OwnerId = cola[0].id;
                if(Schema.sObjectType.SAC_Interaccion__c.isUpdateable()){   
                    // Database.update(escalado);
                    SPV_DatabaseDML.updateDML(escalado, true);

                    //Preparar una alerta
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(escalado.SAC_CasoEscalado__c,
                                                                        'SPV_008',
                                                                        'El escalado ' + escalado.Name + ' ha sido devuelto.',
                                                                        escalado.CreatedById,
                                                                        '',
                                                                        '',
                                                                        escalado.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.Id;
                                                                        wrapAlerta.proyecto = 'SPV';

                    //Añadirla a la lista para posteriormente llamar al método
                    List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
                    listaWrapperAlerta.add(wrapAlerta);

                    //Si tenemos alertas que enviar, se llama al método que las envía
                    if (!listaWrapperAlerta.isEmpty()) {
                        SAC_Alertas.generarAlertas(listaWrapperAlerta);
                    }
                }else{
                    throw new AuraHandledException('No tienes permisos para actualizar el escalado');
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    /*****************************************************************
     * Proposito: Comprueba que el formulario de la reclamación tenga todos los campos informados.
     * De lo contrario, envia un mensaje de error informando de los campos que quedan por rellenar en el formulario.
     * Si la validación ha sido correcta, envía el escalado, cambiando el estado a pendiente respuesta y
     * poniendo como owner la cola pendiente de asignar.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US938768         CS             06/06/2024   Creación
    *****************************************************************/
    @AuraEnabled
    public static void enviarEscalado(String escaladoId, String casoId, String motivo) {
        String mensajeError = '';
        try {
            //Asignar id de escalado
            SAC_Interaccion__c escalado = new SAC_Interaccion__c();
            escalado.Id = escaladoId;

            //Asignar el Id de la reclamación a la que le corresponde el escalado
            Case reclamacion = new Case();
            reclamacion.Id = casoId;


            //Comprobar validaciones del formulario antes de pasar a enviado el escalado
            List<SPV_Formulario__c> listaFormulario = [SELECT Id, SPV_Reclamante__c, SPV_LetradoSPV__c, SPV_LetradoRevisor__c, SPV_Importe__c, SPV_ResumenResolucion__c,
                                                                SPV_ResolucionRemitidaEnPlazo__c, SPV_ReclamacionMalFuncionamiento__c, SPV_ObservacionesMalFuncionamiento__c, SPV_ActuacionCumpleCriterios__c,
                                                                SPV_ObservacionesCriteriosBDE__c, SPV_DisponeDocumentacion__c, SPV_ObservacionesDocumentacion__c, SPV_DocumentacionNecesaria__c, SPV_InformacionPrecontractual__c,
                                                                SPV_CambiosDeCondiciones__c, SPV_ComunicacionLiquidaciones__c, SPV_JustificantesOperaciones__c, SPV_ComunicacionOficinaCliente__c,
                                                                SPV_AntecedentesCumplimiento__c, SPV_CumplimientoCondicionesPactadas__c, SPV_InformeOficina__c, SPV_ExisteDefensaJuridicaSuficiente__c,
                                                                SPV_ObservacionesDefensaJuridica__c, SPV_ConllevaRiesgoReputacional__c, SPV_ObservacionesRiesgoReputacional__c, SPV_ExisteCriterioRespectoTipologia__c,
                                                                SPV_ObservacionesExisteCriterio__c, SPV_RiesgoInformeDesfavorable__c, SPV_ObservacionesInformeDesfavorable__c, SPV_PropuestaLetradoAlegaciones__c,
                                                                SPV_PropuestaLetradoAllanamiento__c, SPV_TipoRespuesta__c, SPV_ObservacionesAJ__c
                                                                FROM SPV_Formulario__c
                                                                WHERE RecordTypeId = :RECTYPEFORMULARIO AND SPV_Caso__c = :casoId LIMIT 1];
            if (!listaFormulario.isEmpty()) {
                //mensajeError = validarFormulario(listaFormulario[0], mensajeError);
                if (String.isNotBlank(mensajeError)) {
                    throw new AuraHandledException(mensajeError);
                }
            } else {
                mensajeError = 'Debe crear el formulario antes de enviar el escalado';
                throw new AuraHandledException(mensajeError);
            }

            if (!String.isBlank(escaladoId) && motivo == 'SPV_Allanamiento') {
                mensajeError = validarCamposAllananiento(escaladoId, mensajeError);
                if (String.isNotBlank(mensajeError)) {
                    throw new AuraHandledException(mensajeError);
                }
            } 

            //Si se han pasado las validaciones, enviar el escalado
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            if(!cola.isEmpty()){
                //Poner la cola como owner
                escalado.OwnerId = cola[0].id;
                //Cambiar el estado a pendiente respuesta
                escalado.SAC_Estado__c = 'SAC_PendienteRespuesta';

                //Añadido: Rellenar la fecha de envío del escalado
                escalado.SPV_FechaEscalado__c = System.now();
                if(Schema.sObjectType.SAC_Interaccion__c.isUpdateable()){   
                    // Database.update(escalado);
                    SPV_DatabaseDML.updateDML(escalado, true);

                    //Rellenar la fecha de propuesta letrado del formulario a partir de la fecha de envío del escalado
                    if(Schema.sObjectType.SPV_Formulario__c.isUpdateable()){   
                        listaFormulario[0].SPV_FechaPropuesta__c = System.now();
                        // Database.update(listaFormulario[0]);
                        SPV_DatabaseDML.updateDML(listaFormulario[0], true);
                    }
                }else{
                    mensajeError = 'No tienes permisos para actualizar el escalado';
                    throw new AuraHandledException(mensajeError);
                }
            }
        } catch (Exception e) {
            if (String.isNotBlank(mensajeError)) { e.setMessage(mensajeError); }
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************
     * Proposito: Comprueba que los campos del formulario están informados. De lo
     * contrario, devuelve un mensaje de error.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US938768         CS             18/06/2024   Creación
    *****************************************************************/
    public static String validarFormulario(SPV_Formulario__c formulario, String mensajeError) {
        //Lista con los campos que hay que validar
        List<String> listaCamposValidar = new List<String>();
        listaCamposValidar.add('SPV_LetradoRevisor__c');
        listaCamposValidar.add('SPV_Importe__c');
        listaCamposValidar.add('SPV_ResumenResolucion__c');
        listaCamposValidar.add('SPV_ResolucionRemitidaEnPlazo__c');
        listaCamposValidar.add('SPV_ReclamacionMalFuncionamiento__c');
        listaCamposValidar.add('SPV_ObservacionesMalFuncionamiento__c');
        listaCamposValidar.add('SPV_ActuacionCumpleCriterios__c');
        listaCamposValidar.add('SPV_ObservacionesCriteriosBDE__c');
        listaCamposValidar.add('SPV_DisponeDocumentacion__c');
        listaCamposValidar.add('SPV_ObservacionesDocumentacion__c');
        //listaCamposValidar.add('SPV_DocumentacionNecesaria__c');
        listaCamposValidar.add('SPV_InformacionPrecontractual__c');
        listaCamposValidar.add('SPV_CambiosDeCondiciones__c');
        listaCamposValidar.add('SPV_ComunicacionLiquidaciones__c');
        listaCamposValidar.add('SPV_JustificantesOperaciones__c');
        listaCamposValidar.add('SPV_ComunicacionOficinaCliente__c');
        listaCamposValidar.add('SPV_AntecedentesCumplimiento__c');
        listaCamposValidar.add('SPV_CumplimientoCondicionesPactadas__c');
        listaCamposValidar.add('SPV_InformeOficina__c');
        listaCamposValidar.add('SPV_ExisteDefensaJuridicaSuficiente__c');
        listaCamposValidar.add('SPV_ObservacionesDefensaJuridica__c');
        listaCamposValidar.add('SPV_ConllevaRiesgoReputacional__c');
        listaCamposValidar.add('SPV_ObservacionesRiesgoReputacional__c');
        listaCamposValidar.add('SPV_ExisteCriterioRespectoTipologia__c');
        listaCamposValidar.add('SPV_ObservacionesExisteCriterio__c');
        listaCamposValidar.add('SPV_RiesgoInformeDesfavorable__c');
        listaCamposValidar.add('SPV_ObservacionesInformeDesfavorable__c');
        //listaCamposValidar.add('SPV_PropuestaLetradoAllanamiento__c');
        //listaCamposValidar.add('SPV_PropuestaLetradoAlegaciones__c');
        //listaCamposValidar.add('SPV_TipoRespuesta__c');
        //listaCamposValidar.add('SPV_ObservacionesAJ__c');

        for (String campoApiName : listaCamposValidar) {
            Object valorCampo = formulario.get(campoApiName);
    
            if (valorCampo == null || (valorCampo instanceof String && String.isBlank((String)valorCampo))) {
                String label = getLabel(campoApiName);
                mensajeError = 'Debe informar el campo ' + label + ' del formulario';
                return mensajeError;
            }
        }
    
        return null; //No se encontraron errores
    }

    /*****************************************************************
     * Proposito: Devuelve la label del campo introducido del objeto SPV_Formulario__c
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US938768         CS             18/06/2024   Creación
    *****************************************************************/
    public static String getLabel(String campoApiName) {
        Map<String,Schema.SObjectField> mfields = Schema.SPV_Formulario__c.SObjectType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = mfields.get(campoApiName).getDescribe();
        return fieldResult.getLabel();
    }

    /*****************************************************************
     * Proposito: Comprueba que los campos del del escalado de allanamiento están informados.
     *  De lo contrario, devuelve un mensaje de error.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE         Description
     * 1.0            US938802       Sergio Martín   11/07/2024      Creación
    *****************************************************************/
    public static String validarCamposAllananiento(String escaladoId, String mensajeError) {
        List<SAC_Interaccion__c> listaEscalado = [SELECT Id, SAC_MotivoEscalado__c, SPV_TipoAllanamiento__c, SPV_MotivoAllanamiento__c, SPV_AnalisisAllanamiento__c, SPV_VerificacionesLetrado__c, 
                                SAC_Propuesta__c, SPV_TipoActuacion__c, SPV_Importe__c, SPV_Imputable__c FROM SAC_Interaccion__c WHERE RecordTypeId = :RECTYPEESCALADO AND id = :escaladoId LIMIT 1];
        //Lista con los campos que hay que validar
        List<String> listaCamposValidar = new List<String>();
        listaCamposValidar.add('SPV_TipoAllanamiento__c');
        listaCamposValidar.add('SPV_MotivoAllanamiento__c');
        listaCamposValidar.add('SPV_AnalisisAllanamiento__c');
        listaCamposValidar.add('SPV_VerificacionesLetrado__c');
        listaCamposValidar.add('SAC_Propuesta__c');
        listaCamposValidar.add('SPV_TipoActuacion__c');
        listaCamposValidar.add('SPV_Importe__c');
        listaCamposValidar.add('SPV_Imputable__c');

        for (String campoApiName : listaCamposValidar) {
            Object valorCampo = listaEscalado[0].get(campoApiName);
            if (valorCampo == null || (valorCampo instanceof String && String.isBlank((String)valorCampo))) {
                String label = getLabelEscalado(campoApiName);
                mensajeError = 'Debe informar el campo ' + label + ' del escalado antes de enviarlo.';
                return mensajeError;
            }
        }
    
        return null; //No se encontraron errores
    }

    /*****************************************************************
     * Proposito: Devuelve la label del campo introducido del objeto SAC_Interaccion__c
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US938802       Sergio Martín   11/07/2024      Creación
    *****************************************************************/
    public static String getLabelEscalado(String campoApiName) {
        Map<String,Schema.SObjectField> mfields = Schema.SAC_Interaccion__c.SObjectType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = mfields.get(campoApiName).getDescribe();
        return fieldResult.getLabel();
    }


    /*****************************************************************
     * Proposito: Al pulsar cancelar escalado, se modifica su estado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1277284       Álex Polo     18/06/2025      Creación
    *****************************************************************/
    @AuraEnabled
    public static void cancelarEscalado(Id escaladoId){
        try {
            List<SAC_Interaccion__c> listaEscaladosUpdatear = new List<SAC_Interaccion__c>();
            SAC_Interaccion__c interaccion = recuperarInteraccion(escaladoId);
            interaccion.SAC_Estado__c = 'SAC_Cancelado';
            listaEscaladosUpdatear.add(interaccion);

            SAC_DatabaseDML.updateListDML(listaEscaladosUpdatear, true);

            //Mandar una notificación de campanita al letrado de la pretensión.
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            String recipientId= '';
            String targetId = escaladoId;
            String titulo = 'Escalado cancelado.';
            String contenidoMensaje = 'El escalado ' + interaccion.Name + ' ha sido cancelado.';
            if (String.isNotBlank(interaccion.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId) && interaccion.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId != cola[0].Id) {
                recipientId = interaccion.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId;
            } else if (String.isNotBlank(interaccion.SAC_CasoEscalado__r.OwnerId) && interaccion.SAC_CasoEscalado__r.OwnerId != cola[0].Id) {
                recipientId = interaccion.SAC_CasoEscalado__r.OwnerId;
            }
            if (String.isNotBlank(recipientId)) {
                // Create a new custom notification
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                
                // Set the contents for the notification
                notification.setTitle(titulo);
                notification.setBody(contenidoMensaje);

                // Set the notification type and target
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(targetId);

                // Actually send the notification
                Set<String> setRecipientId = new Set<String>();
                setRecipientId.add(recipientId);

                notification.send(setRecipientId);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static SAC_Interaccion__c recuperarInteraccion(Id interaccionId){
        Id recTypeEscalado = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SPV_Escalado').getRecordTypeId();
        SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
        interaccion = [SELECT Id, OwnerId, SAC_GrupoColaborador__c, SAC_Estado__c, SAC_GrupoVolverEscalar__c, Name, SAC_CasoEscalado__r.OwnerId, SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId
                    FROM SAC_Interaccion__c
                    WHERE (RecordTypeId = :recTypeEscalado OR RecordTypeId = :RECTYPEREESCALADO)
                    AND Id = :interaccionId LIMIT 1];
        return interaccion;
    }
    /*****************************************************************
     * Proposito: Responde el escalado. Dependiendo del tipo de respuesta dado, modificamos el estado:
     * SPV_Aceptado: El estado pasa a resuelta.
     * SPV_AceptadoConModificaciones: El estado pasa a pendiente de enviar y se devuelve al creador del escalado.
     * SPV_Rechazado: El estado pasa a resulta.
     * 
     * Además, crea un registro para el historico de respuestas del escalado.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US926239         CS             06/06/2024   Creación
    *****************************************************************/
    @AuraEnabled
    public static void responderEscalado(String escaladoId, String conclusionEscalado, String comentarios, String motivoRechazo, String creadorEscaladoId, String casoId) {
        try {
            SAC_Interaccion__c escalado = new SAC_Interaccion__c();
            escalado.Id = escaladoId;
            
            //Asignar el Id de la reclamación afectada
            Case reclamacion = new Case();
            reclamacion.Id = casoId;


            List<SAC_Interaccion__c> listaEscaladosActualizar = new List<SAC_Interaccion__c>();
            //Comprobar que campos hay que rellenar
            if (conclusionEscalado == 'SPV_Aceptado') {
                escalado.SAC_Conclusion__c = conclusionEscalado;
                escalado.SPV_MotivoRechazo__c = null;
                escalado.SAC_Respuesta__c = null;

                //Cambiar el estado a respondido
                escalado.SAC_Estado__c = 'SAC_Atendida';
                escalado.SAC_FechaRespuesta__c = System.now();                          //Añadido
                listaEscaladosActualizar.add(escalado);
            }
            else if (conclusionEscalado == 'SPV_AceptadoConModificaciones') {
                escalado.SAC_Conclusion__c = conclusionEscalado;
                escalado.SAC_Respuesta__c = comentarios;
                escalado.SPV_MotivoRechazo__c = null;

                //Se devuelve el escalado al creador y se vuelve a poner en pendiente enviar
                escalado.OwnerId = creadorEscaladoId;
                escalado.SAC_Estado__c = 'SPV_PendienteEnviar';
                listaEscaladosActualizar.add(escalado);
            }
            else if (conclusionEscalado == 'SPV_Rechazado') {
                escalado.SAC_Conclusion__c = conclusionEscalado;
                escalado.SPV_MotivoRechazo__c = motivoRechazo;
                escalado.SAC_Respuesta__c = comentarios;

                //Cambiar el estado a respondido
                escalado.SAC_Estado__c = 'SAC_Atendida';
                escalado.SAC_FechaRespuesta__c = System.now();                          //Añadido
                listaEscaladosActualizar.add(escalado);
            }else if(conclusionEscalado == 'SAC_DevolverNivelAnterior'){
                escalado.SAC_Conclusion__c = conclusionEscalado;
                escalado.SAC_Estado__c = 'SAC_Devuelto';
                listaEscaladosActualizar = devolverEscalado(escalado.Id, conclusionEscalado);
            }

            if(Schema.sObjectType.SAC_Interaccion__c.isUpdateable()){   
                // Database.update(escalado);
                //SPV_DatabaseDML.updateDML(escalado, true);
                if(!listaEscaladosActualizar.isEmpty()){
                    SPV_DatabaseDML.updateListDML(listaEscaladosActualizar, true);
                }
            
                //Record type accion responder spv
                Id recordTypeTareaResponder = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_AccionResponderEsc').getRecordTypeId();
                //Valores picklist SAC_Conclusion__c
                Schema.DescribeFieldResult fieldResult = SAC_Interaccion__c.SAC_Conclusion__c.getDescribe();
                List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
                //Mapa de valores de API Name a label
                Map<String, String> apiNameToLabelMap = new Map<String, String>();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    apiNameToLabelMap.put(entry.getValue(), entry.getLabel());
                }

                //Valores picklist SPV_MotivoRechazo__c
                Schema.DescribeFieldResult fieldResult2 = SAC_Interaccion__c.SPV_MotivoRechazo__c.getDescribe();
                List<Schema.PicklistEntry> picklistEntries2 = fieldResult2.getPicklistValues();
                //Mapa de valores de API Name a label
                Map<String, String> apiNameToLabelMap2 = new Map<String, String>();
                for (Schema.PicklistEntry entry : picklistEntries2) {
                    apiNameToLabelMap2.put(entry.getValue(), entry.getLabel());
                }
                
                //Historial respuestas
                SAC_Accion__c respuestaEsc = new SAC_Accion__c();
                respuestaEsc.RecordTypeId = recordTypeTareaResponder;
                respuestaEsc.SAC_Comentarios__c = escalado.SAC_Respuesta__c;
                respuestaEsc.OwnerId =  UserInfo.GetUserId();
                respuestaEsc.SPV_TipoRespuesta__c = apiNameToLabelMap.get(escalado.SAC_Conclusion__c);
                respuestaEsc.SAC_RespuestaEscalado__c = escaladoId;
                respuestaEsc.SAC_Estado__c = 'SAC_Finalizada';
                // Database.insert(respuestaEsc);
                SPV_DatabaseDML.insertDML(respuestaEsc, true);
                // Rellenar el campo SPV_TipoRespuesta__c del formulario de la reclamación con la respuesta del escalado
                List<SPV_Formulario__c> listaFormulario = [SELECT Id, SPV_TipoRespuesta__c FROM SPV_Formulario__c WHERE RecordTypeId = :RECTYPEFORMULARIO AND SPV_Caso__c = :casoId LIMIT 1];
                if(!listaFormulario.isEmpty()) {
                    listaFormulario[0].SPV_TipoRespuesta__c = apiNameToLabelMap.get(escalado.SAC_Conclusion__c);
                    listaFormulario[0].SPV_MotivoRechazo__c = apiNameToLabelMap2.get(escalado.SPV_MotivoRechazo__c);
                    listaFormulario[0].SPV_ObservacionesAJ__c = escalado.SAC_Respuesta__c;
                    // Database.update(listaFormulario[0]);
                    SPV_DatabaseDML.updateDML(listaFormulario[0], true);
                }
            }else{
                throw new AuraHandledException('No tienes permisos para actualizar el escalado');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    /*****************************************************************
     * Proposito: Si se ha respondido el escalado con "Devolver...", se modifica su Owner y Grupo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1277284       Álex Polo     18/06/2025      Creación
    *****************************************************************/
    //Si es un re escalado -> Se devuelve al escalado principal, el re escalado pasa a devuelta y el escalado vuelve a abrirse
    //Si es el escalado principal, se devuelve al letrado, grupo y owner de la pretensión
    private static List<SAC_Interaccion__c> devolverEscalado(String escaladoId, String conclusion){
        
        List<SAC_Interaccion__c> listaEscaladosActualizar = new List<SAC_Interaccion__c>();
        SAC_Interaccion__c escalado = [SELECT Id, SAC_Estado__c, RecordTypeId, SAC_GrupoVolverEscalar__c, OwnerId, SAC_GrupoColaborador__c, SAC_EscaladoNV2__c, SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId, SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c FROM SAC_Interaccion__c WHERE Id = :escaladoId];
        if (escalado.RecordTypeId == RECTYPEESCALADO) {
        //Pasar escalado a devuelto y poner el owner y el grupo de la pretension y guardar el grupo que tenía en el campo SAC_GrupoVolverEscalar__c
            escalado.SAC_Estado__c = 'SAC_Devuelto';
            escalado.SAC_Conclusion__c = conclusion;
            escalado.SAC_GrupoVolverEscalar__c = escalado.SAC_GrupoColaborador__c;
            escalado.OwnerId = escalado.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId;
            escalado.SAC_GrupoColaborador__c = escalado.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c;
            listaEscaladosActualizar.add(escalado);

        }else if(escalado.RecordTypeId == RECTYPEREESCALADO){
            //Si es el rescalado:

            escalado.SAC_Estado__c = 'SAC_Devuelto';
            escalado.SAC_GrupoVolverEscalar__c = escalado.SAC_GrupoColaborador__c;
            listaEscaladosActualizar.add(escalado);

            //Comprobar que tiene un escalado de nivel 2 (el que se ha reescalado), y si lo tiene, pasarlo a estado pendiente respuesta
            if (String.isNotBlank(escalado.SAC_EscaladoNV2__c)) {
                SAC_Interaccion__c escaladoNV2 = new SAC_Interaccion__c();
                escaladoNV2.Id = escalado.SAC_EscaladoNV2__c;
                escaladoNV2.SAC_Estado__c = 'SAC_PendienteRespuesta';
                listaEscaladosActualizar.add(escaladoNV2);
                
            }else{
                //Pasar escalado a devuelto y poner el owner y el grupo de la pretension
                listaEscaladosActualizar[0].SAC_Conclusion__c = conclusion;
                //escalado.SAC_ImporteAutorizado__c = importe;
                listaEscaladosActualizar[0].SAC_GrupoVolverEscalar__c = listaEscaladosActualizar[0].SAC_GrupoColaborador__c;
                listaEscaladosActualizar[0].SAC_Estado__c = 'SAC_Devuelto';
                listaEscaladosActualizar[0].OwnerId = escalado.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.OwnerId;
                listaEscaladosActualizar[0].SAC_GrupoColaborador__c = escalado.SAC_CasoEscalado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c;
            }
        }

        return listaEscaladosActualizar;

    }

    /*****************************************************************
     * Proposito: Obtener el RecordType DeveloperName del escalado y del
     * grupo asociado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1277284       Álex Polo     18/06/2025      Creación
    *****************************************************************/
    @AuraEnabled(Cacheable = true)
    public static SAC_Interaccion__c obtenerEscalado(String escaladoId){
        SAC_Interaccion__c escalado = [SELECT Id, RecordType.DeveloperName, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.RecordType.DeveloperName FROM SAC_Interaccion__c WHERE Id = :escaladoId];
        return escalado;
    }

    /*****************************************************************
     * Proposito: Botón volver a escalar. Está disponible para el letrado cuando se le ha devuelto el escalado
    * nivel 2 y el estado del escalado es devuelto.
    * Vuelve a poner el escalado con el grupo que tenia el escalado en el momento de devolverla.
    * Pone como owner la cola pendiente de asignar. Pone el estado en pendiente respuesta.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1277284       Álex Polo     18/06/2025      Creación
    *****************************************************************/
    @AuraEnabled
    public static void volverAEscalar(Id interaccionId, String propuestaLet){
        try {
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            SAC_Interaccion__c interaccion = recuperarInteraccion(interaccionId);

            //Se devuelve al grupo que tenía el escalado y se vuelve a poner en estado pendiente de respuesta y owner la cola pendiente de respuesta.
            interaccion.SAC_Estado__c = 'SAC_PendienteRespuesta';
            interaccion.SAC_Propuesta__c = propuestaLet;
            interaccion.SAC_GrupoColaborador__c = interaccion.SAC_GrupoVolverEscalar__c;
            interaccion.SAC_Conclusion__c = null;

            if (!cola.isEmpty()) {
                interaccion.OwnerId = cola[0].Id;
            }

            SPV_DatabaseDML.updateDML(interaccion, false);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}