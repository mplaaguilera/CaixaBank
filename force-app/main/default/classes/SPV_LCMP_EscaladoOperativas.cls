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

    private static final Id RECTYPEFORMULARIO = mapRTsObjects.get('SPV_Formulario__c').get('SPV_Formulario').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();

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
            SAC_Interaccion__c escalado = [SELECT Id, SAC_CasoEscalado__c, Name, CreatedById FROM SAC_Interaccion__c WHERE RecordTypeId = :RECTYPEESCALADO AND Id = :escaladoId LIMIT 1];

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
                mensajeError = validarFormulario(listaFormulario[0], mensajeError);
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
    public static void responderEscalado(String escaladoId, String tipoRespuesta, String comentarios, String motivoRechazo, String creadorEscaladoId, String casoId) {
        try {
            SAC_Interaccion__c escalado = new SAC_Interaccion__c();
            escalado.Id = escaladoId;
            
            //Asignar el Id de la reclamación afectada
            Case reclamacion = new Case();
            reclamacion.Id = casoId;



            //Comprobar que campos hay que rellenar
            if (tipoRespuesta == 'SPV_Aceptado') {
                escalado.SPV_TipoRespuesta__c = tipoRespuesta;
                escalado.SPV_MotivoRechazo__c = null;
                escalado.SAC_Respuesta__c = null;

                //Cambiar el estado a respondido
                escalado.SAC_Estado__c = 'SAC_Resuelta';
                escalado.SAC_FechaRespuesta__c = System.now();                          //Añadido
            }
            else if (tipoRespuesta == 'SPV_AceptadoConModificaciones') {
                escalado.SPV_TipoRespuesta__c = tipoRespuesta;
                escalado.SAC_Respuesta__c = comentarios;
                escalado.SPV_MotivoRechazo__c = null;

                //Se devuelve el escalado al creador y se vuelve a poner en pendiente enviar
                escalado.OwnerId = creadorEscaladoId;
                escalado.SAC_Estado__c = 'SPV_PendienteEnviar';
            }
            else if (tipoRespuesta == 'SPV_Rechazado') {
                escalado.SPV_TipoRespuesta__c = tipoRespuesta;
                escalado.SPV_MotivoRechazo__c = motivoRechazo;
                escalado.SAC_Respuesta__c = comentarios;

                //Cambiar el estado a respondido
                escalado.SAC_Estado__c = 'SAC_Resuelta';
                escalado.SAC_FechaRespuesta__c = System.now();                          //Añadido
            }
            
            if(Schema.sObjectType.SAC_Interaccion__c.isUpdateable()){   
                // Database.update(escalado);
                SPV_DatabaseDML.updateDML(escalado, true);
            
                //Record type accion responder spv
                Id recordTypeTareaResponder = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_AccionResponderEsc').getRecordTypeId();
                //Valores picklist SPV_TipoRespuesta__c
                Schema.DescribeFieldResult fieldResult = SAC_Interaccion__c.SPV_TipoRespuesta__c.getDescribe();
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
                respuestaEsc.SPV_TipoRespuesta__c = apiNameToLabelMap.get(escalado.SPV_TipoRespuesta__c);
                respuestaEsc.SAC_RespuestaEscalado__c = escaladoId;
                respuestaEsc.SAC_Estado__c = 'SAC_Finalizada';
                // Database.insert(respuestaEsc);
                SPV_DatabaseDML.insertDML(respuestaEsc, true);

                // Rellenar el campo SPV_TipoRespuesta__c del formulario de la reclamación con la respuesta del escalado
                List<SPV_Formulario__c> listaFormulario = [SELECT Id, SPV_TipoRespuesta__c FROM SPV_Formulario__c WHERE RecordTypeId = :RECTYPEFORMULARIO AND SPV_Caso__c = :casoId LIMIT 1];
                listaFormulario[0].SPV_TipoRespuesta__c = apiNameToLabelMap.get(escalado.SPV_TipoRespuesta__c);
                listaFormulario[0].SPV_MotivoRechazo__c = apiNameToLabelMap2.get(escalado.SPV_MotivoRechazo__c);
                listaFormulario[0].SPV_ObservacionesAJ__c = escalado.SAC_Respuesta__c;
                // Database.update(listaFormulario[0]);
                SPV_DatabaseDML.updateDML(listaFormulario[0], true);
            }else{
                throw new AuraHandledException('No tienes permisos para actualizar el escalado');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
}