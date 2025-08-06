public with sharing class SPV_LCMP_FormularioReclamaciones {
    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c', 'Case','SPV_Formulario__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPEFORMULARIO = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioAnalisisDecision').getRecordTypeId();

    

    /*****************************************************************************
    * Proposito: Comprueba si hay algún formulario en la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US926182     Sergio Martín   18/06/24        Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getFormularioExistente(String casoId) {
        List<SPV_Formulario__c> listaFormularios = [
            SELECT Id FROM SPV_Formulario__c 
            WHERE SPV_Caso__c = :casoId
            AND RecordTypeId = :RECTYPEFORMULARIO
            ORDER BY LastModifiedDate DESC 
            LIMIT 1
        ];
        return !listaFormularios.isEmpty() ? listaFormularios[0].Id : null;
    }


    /*********************************************************************************
    * Proposito: Recupera los campos deseados de las pretensiones de la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US926182     Sergio Martín   19/06/24        Creación
    * 1.q             --------     Pablo  Natera   07/05/25        Añadidos campos 

    ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getPretensionesReclamacion(String casoId) {
        List<Case> listaPretensiones = new List<Case>();
        if(Schema.sObjectType.Case.isAccessible()) {
            listaPretensiones = [
                SELECT Id, CaseNumber, Subject, SPV_CriterioBDEMateriaFuente__c, 
                    SPV_DecisionAllanamiento__c,
                    SAC_ResumenManual__c,
                    CC_Importe_Reclamado__c,
                    // Campos de Case Extension
                    CBK_Case_Extension_Id__c,
                    CBK_Case_Extension_Id__r.Id, 
                    // Campos de MCC completo
                    CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name,
                    CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name,
                    CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name,
                    SEG_Detalle__c, SEG_Detalle__r.Name,
                    // Campos para Allanamiento
                    CBK_Case_Extension_Id__r.SPV_TipoAllanamiento__c, 
                    CBK_Case_Extension_Id__r.SPV_MotivoAllanamiento__c,
                    CBK_Case_Extension_Id__r.SPV_AnalisisAllanamiento__c, 
                    CBK_Case_Extension_Id__r.SPV_ImporteAllanamientoPropuesto__c,
                    CBK_Case_Extension_Id__r.SPV_ImputableAllanamiento__c, 
                    // Campos para Desistimiento
                    CBK_Case_Extension_Id__r.SPV_MotivoDesistimiento__c,
                    CBK_Case_Extension_Id__r.SPV_AnalisisDesistimiento__c,
                    CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c,
                    CBK_Case_Extension_Id__r.SPV_ImporteDesistimientoPropuesto__c,
                    CBK_Case_Extension_Id__r.SPV_ImputableDesistimiento__c,
                    // Otros campos existentes
                    CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c,
                    // Campos para Antecedentes SAC
                    CBK_Case_Extension_Id__r.SPV_EmisionSAC__c,
                    CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c,
                    CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c,
                    CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c,
                    CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c,
                    CBK_Case_Extension_Id__r.SPV_ObservacionesMalFuncionamientoSAC__c,
                    CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c,
                    CBK_Case_Extension_Id__r.SPV_ObservacionesActuacionSAC__c,
                    // Campos para Valoración documentación disponible
                    CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c,
                    CBK_Case_Extension_Id__r.SPV_ObservacionesDocumentacionDisponible__c,
                    CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c,
                    // Campos para Comprobaciones realizadas
                    CBK_Case_Extension_Id__r.SPV_InformacionPrecontractual__c,
                    CBK_Case_Extension_Id__r.SPV_ComunicacionesCambiosCondiciones__c,
                    CBK_Case_Extension_Id__r.SPV_ComunicacionesLEC__c,
                    CBK_Case_Extension_Id__r.SPV_JustificantesOperaciones__c,
                    CBK_Case_Extension_Id__r.SPV_ComunicacionesOficinaCliente__c,
                    CBK_Case_Extension_Id__r.SPV_AntecedentesCumplimientoResol__c,
                    CBK_Case_Extension_Id__r.SPV_CumplimientoCondicionesPactadas__c,
                    CBK_Case_Extension_Id__r.SPV_InformeOficina__c,
                    // Campos para el nuevo bloque Análisis Letrado
                    CBK_Case_Extension_Id__r.SPV_MencionarCriterioBdE__c,
                    CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c,
                    CBK_Case_Extension_Id__r.SPV_Documentacion__c,
                    CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c
                FROM Case 
                WHERE RecordTypeId = :RECTYPEPRETENSION 
                AND SAC_Reclamacion__c = :casoId
            ];
        }
        return listaPretensiones;
    }


        /*********************************************************************************
    * Marca una rectificación crear un nuevo formulario de rectificación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             --------     Pablo  Natera   12/05/25        Creación

    ************************************************************************************/
    @AuraEnabled
    public static Id crearNuevoFormularioReclamacion(Id casoId) {
        try {
            if(Schema.sObjectType.SPV_Formulario__c.isCreateable()) {
                SPV_Formulario__c nuevoFormulario = new SPV_Formulario__c();
                nuevoFormulario.SPV_Caso__c = casoId;
                nuevoFormulario.RecordTypeId = RECTYPEFORMULARIO;
                
                insert nuevoFormulario;
                return nuevoFormulario.Id;
            }
            return null;
        } catch(Exception e) {
            throw new AuraHandledException('Error al crear el formulario de reclamación: ' + e.getMessage());
        }
    }
/*********************************************************************************
* Proposito: Recupera los números de contrato asociados a las pretensiones 
*           de reclamación desde el objeto SAC_ProductCase__c
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0             --------     Pablo Natera   06/05/2025        Creación
************************************************************************************/
@AuraEnabled(cacheable=true)
public static Map<Id, String> getNumeroContratos(List<Id> pretensionIds) {
    Map<Id, String> mapContratos = new Map<Id, String>();
    
    if (pretensionIds == null || pretensionIds.isEmpty()) {
        return mapContratos;
    }
        // Verificar permisos de acceso al objeto
        if (Schema.sObjectType.SAC_ProductCase__c.isAccessible() && 
            Schema.sObjectType.SAC_ProductCase__c.fields.N_Contrato__c.isAccessible() &&
            Schema.sObjectType.SAC_ProductCase__c.fields.SAC_Pretension__c.isAccessible()) {
            
            // Consultar los registros SAC_ProductCase relacionados con las pretensiones
            List<SAC_ProductCase__c> productos = [
                SELECT Id, N_Contrato__c, SAC_Pretension__c 
                FROM SAC_ProductCase__c 
                WHERE SAC_Pretension__c IN :pretensionIds
            ];
            
            
            // Construir el mapa de Id de pretensión a número de contrato
            for (SAC_ProductCase__c producto : productos) {
                if (producto.SAC_Pretension__c != null) {
                    // Guardar el número de contrato o un valor por defecto si es nulo
                    String numeroContrato = (producto.N_Contrato__c != null) ? producto.N_Contrato__c : 'No especificado';
                    mapContratos.put(producto.SAC_Pretension__c, numeroContrato);
                    
                }
            }
        } 
    return mapContratos;
}
    /*************************************************************************
    * Proposito: Notificar al propietario del escalado que se ha modificado 
    *            el formulario e la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929908     Sergio Martín   20/06/24        Creación
    * 1.1               ---         Raúl Santos    02/10/24        Modificación: Enviar alerta al owner si esta asignado, o al grupo si el owner es pte asignar
    *************************************************************************/
    @AuraEnabled
    public static void notificarCambioFicha(String casoId, String caseNumber) {

        if(Schema.sObjectType.SAC_Interaccion__c.isAccessible()) {
            List<SAC_Interaccion__c> listaEscalados = [SELECT Id, Name, SAC_CasoEscalado__c, OwnerId, SAC_Estado__c, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.SAC_Email__c, SAC_GrupoColaborador__r.SAC_Email2__c, SAC_GrupoColaborador__r.SAC_Email3__c
                                                         FROM SAC_Interaccion__c 
                                                       WHERE RecordTypeId = :RECTYPEESCALADO AND SAC_CasoEscalado__c = :casoId 
                                                       AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SPV_PendienteEnviar') 
                                                       ORDER BY CreatedDate DESC LIMIT 1];

            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

            if(!cola.isEmpty() && !listaEscalados.isEmpty()){
                for(SAC_Interaccion__c escalado : listaEscalados) {

                    //Preparar una alerta
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(escalado.SAC_CasoEscalado__c,
                                                                        'SPV_018',
                                                                        'La ficha de la reclamación ' + caseNumber + ' ha sido modificada, por favor revise antes de continuar con la resolución del escalado ' + escalado.Name,
                                                                        escalado.OwnerId,
                                                                        '',
                                                                        '',
                                                                        escalado.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.Id;
                                                                        wrapAlerta.idGrupoColaborador = escalado.SAC_GrupoColaborador__c;
                                                                        wrapAlerta.proyecto = 'SPV';

                    //Alerta al grupo si esta pte asignar
                    if(escalado.OwnerId == cola[0].Id) {
                        List<String> listaEmails = new List<String>();  

                        if (escalado.SAC_GrupoColaborador__r.SAC_Email__c != null) {
                            listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email__c);
                        }
                        if (escalado.SAC_GrupoColaborador__r.SAC_Email2__c != null) {
                            listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email2__c);
                        }
                        if (escalado.SAC_GrupoColaborador__r.SAC_Email3__c != null) {
                            listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email3__c);
                        }
                                                                                                
                        wrapAlerta.listaEmailsGrupo = listaEmails;    
                    }

                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
            }

            //Si tenemos alertas que enviar, se llama al método que las envía
            if (!listaWrapperAlerta.isEmpty()) {
                SAC_Alertas.generarAlertas(listaWrapperAlerta);
            }
        }
    }
}